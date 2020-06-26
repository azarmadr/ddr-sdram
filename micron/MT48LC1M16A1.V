/****************************************************************************************
*
*    File Name:  MT48LC1M16A1.V  
*      Version:  0.0f
*         Date:  May 6th, 1999
*        Model:  BUS Functional
*    Simulator:  Model Technology (PC version 5.2e PE)
*
* Dependencies:  None
*
*       Author:  Son P. Huynh
*        Email:  sphuynh@micron.com
*        Phone:  (208) 368-3825
*      Company:  Micron Technology, Inc.
*        Model:  MT48LC1M16A1 (512K x 16 x 2 Banks)
*
*  Description:  Micron 16Mb SDRAM Verilog model
*
*   Limitation:  - Doesn't check for 4096 cycle refresh
*
*         Note:  - Set simulator resolution to "ps" accuracy
*                - Set Debug = 0 to disable $display messages
*
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
*                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY 
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
*
*                Copyright © 1998 Micron Semiconductor Products, Inc.
*                All rights researved
*
* Rev   Author          Phone         Date        Changes
* ----  ----------------------------  ----------  ---------------------------------------
* 0.0f  Son Huynh       208-368-3825  05/06/1999  - Fix Read to Precharge/Burst Terminate
*       Micron Technology Inc.                      not tri-state the DQ
*
* 0.0e  Son Huynh       208-368-3825  01/15/1998  - Fix some problem in 0.0c
*       Micron Technology Inc.
*
* 0.0c  Son Huynh       208-368-3825  11/23/1998  - Fix Precharge pipeline for R/W
*       Micron Technology Inc.                    - Fix R/W with Concurrent AutoPrecharge
*
* 0.0b  Son Huynh       208-368-3825  09/28/1998  - Fix DQM 2-bit for READ/WRITE
*       Micron Technology Inc.                    - Fix Interleaved Burst Counter
*
* 0.0a  Son Huynh       208-368-3825  08/03/1998  - First Release
*       Micron Technology Inc.                    - Simple testbench included
****************************************************************************************/

//`timescale 1ns / 100ps

module mt48lc1m16a1 (Dq, Addr, Ba, Clk, Cke, Cs_n, Ras_n, Cas_n, We_n, Dqm);

    parameter addr_bits =     11;
    parameter data_bits =     16;
    parameter col_bits  =      8;
    parameter mem_sizes = 524287;
    parameter mode_bits =     11;

    inout     [data_bits - 1 : 0] Dq;
    input     [addr_bits - 1 : 0] Addr;
    input                         Ba;
    input                         Clk;
    input                         Cke;
    input                         Cs_n;
    input                         Ras_n;
    input                         Cas_n;
    input                         We_n;
    input                 [1 : 0] Dqm;

    reg       [data_bits - 1 : 0] Bank0 [0 : mem_sizes];
    reg       [data_bits - 1 : 0] Bank1 [0 : mem_sizes];

    reg                           Bank_addr [0 : 3];
    reg        [col_bits - 1 : 0] Col_addr  [0 : 3];
    reg                   [3 : 0] Command   [0 : 3];
    reg                   [1 : 0] Dqm_reg0, Dqm_reg1;
    reg       [addr_bits - 1 : 0] B0_row_addr, B1_row_addr;

    reg       [mode_bits - 1 : 0] Mode_reg;
    reg       [data_bits - 1 : 0] Dq_reg, Dq_dqm;
    reg        [col_bits - 1 : 0] Col_temp, Burst_counter;

    reg                           Act_b0, Act_b1;
    reg                           Pc_b0, Pc_b1;

    reg                           Bank_precharge     [0 : 3];       // Precharge Command
    reg                           A10_precharge      [0 : 3];       // Addr[10] = 1 (All banks)
    reg                           Auto_precharge     [0 : 1];       // RW AutoPrecharge (Bank)
    reg                           Read_precharge     [0 : 1];       // R  AutoPrecharge
    reg                           Write_precharge    [0 : 1];       //  W AutoPrecharge
    integer                       Count_precharge    [0 : 1];       // RW AutoPrecharge (Counter)
    reg                           RW_interrupt_read  [0 : 1];       // RW interrupt Read with Auto Precharge
    reg                           RW_interrupt_write [0 : 1];       // RW interrupt Write with Auto Precharge

    reg                           Data_in_enable;
    reg                           Data_out_enable;

    reg                           Bank, Previous_bank;
    reg       [addr_bits - 1 : 0] Row;
    reg        [col_bits - 1 : 0] Col, Col_brst;

    // Internal system clock
    reg                           CkeZ, Sys_clk;

    // Commands Decode
    wire      Active_enable    = ~Cs_n & ~Ras_n &  Cas_n &  We_n;
    wire      Aref_enable      = ~Cs_n & ~Ras_n & ~Cas_n &  We_n;
    wire      Burst_term       = ~Cs_n &  Ras_n &  Cas_n & ~We_n;
    wire      Mode_reg_enable  = ~Cs_n & ~Ras_n & ~Cas_n & ~We_n & ~Ba;
    wire      Prech_enable     = ~Cs_n & ~Ras_n &  Cas_n & ~We_n;
    wire      Read_enable      = ~Cs_n &  Ras_n & ~Cas_n &  We_n;
    wire      Write_enable     = ~Cs_n &  Ras_n & ~Cas_n & ~We_n;

    // Burst Length Decode
    wire      Burst_length_1   = ~Mode_reg[2] & ~Mode_reg[1] & ~Mode_reg[0];
    wire      Burst_length_2   = ~Mode_reg[2] & ~Mode_reg[1] &  Mode_reg[0];
    wire      Burst_length_4   = ~Mode_reg[2] &  Mode_reg[1] & ~Mode_reg[0];
    wire      Burst_length_8   = ~Mode_reg[2] &  Mode_reg[1] &  Mode_reg[0];

    // CAS Latency Decode
//  wire      Cas_latency_1    = ~Mode_reg[6] & ~Mode_reg[5] &  Mode_reg[4];
    wire      Cas_latency_2    = ~Mode_reg[6] &  Mode_reg[5] & ~Mode_reg[4];
    wire      Cas_latency_3    = ~Mode_reg[6] &  Mode_reg[5] &  Mode_reg[4];

    // Write Burst Mode
    wire      Write_burst_mode = Mode_reg[9];

    wire      Debug            = 1'b1;                          // Turn on Debug messages
    wire      Dq_chk           = Sys_clk & Data_in_enable;      // Check setup/hold time for DQ

    assign    Dq               = Dq_reg;                        // DQ buffer

    //Commands Operation
    `define   ACT       0
    `define   NOP       1
    `define   READ      2
    `define   READ_A    3
    `define   WRITE     4
    `define   WRITE_A   5
    `define   PRECH     6
    `define   A_REF     7
    `define   BST       8
    `define   LMR       9

    // Timing Parameters for -10 component (CL = 3)
    parameter tAC  =   7.5;    
    parameter tOH  =   2.5;
    parameter tHZ  =   8;
    parameter tMRD =   2;       // 2 Clk Cycles
    parameter tRC  =  80;
    parameter tRAS =  50;
    parameter tRCD =  30;
    parameter tRP  =  30;
    parameter tRRD =  20;
    parameter tWR  =   1;       // 1 Clk (A1 Version)

    // Timing Check
    integer   MRD_chk;
    integer   WR_chk [0 : 1];
    time      RC_chk, RRD_chk;
    time      RAS_chk0, RAS_chk1;
    time      RCD_chk0, RCD_chk1;
    time      RP_chk, RP_chk0, RP_chk1;

    initial begin
        {Act_b0, Act_b1} = 0;
        {Pc_b0, Pc_b1} = 0;
        Dq_reg = 16'bz;
        Data_in_enable = 0;
        Data_out_enable = 0;
        MRD_chk = 0;
        RC_chk = 0;
        {RAS_chk0, RAS_chk1} = 0;
        {RCD_chk0, RCD_chk1} = 0;
        {RP_chk, RP_chk0, RP_chk1} = 0;
        $timeformat (-9, 0, " ns", 12);
        $readmemh("bank0.txt", Bank0);
        $readmemh("bank1.txt", Bank1);
    end

    // System clock generator
    always begin
        @ (posedge Clk) begin
            Sys_clk = CkeZ;
            CkeZ = Cke;
        end
        @ (negedge Clk) begin
            Sys_clk = 0;
        end
    end

    always @ (posedge Sys_clk) begin
        // Internal Commamd Pipelined
        Command[0] = Command[1];
        Command[1] = Command[2];
        Command[2] = Command[3];
        Command[3] = `NOP;

        Col_addr[0] = Col_addr[1];
        Col_addr[1] = Col_addr[2];
        Col_addr[2] = Col_addr[3];
        Col_addr[3] = {col_bits{1'b0}};

        Bank_addr[0] = Bank_addr[1];
        Bank_addr[1] = Bank_addr[2];
        Bank_addr[2] = Bank_addr[3];
        Bank_addr[3] = 1'b0;

        Bank_precharge[0] = Bank_precharge[1];
        Bank_precharge[1] = Bank_precharge[2];
        Bank_precharge[2] = Bank_precharge[3];
        Bank_precharge[3] = 1'b0;

        A10_precharge[0] = A10_precharge[1];
        A10_precharge[1] = A10_precharge[2];
        A10_precharge[2] = A10_precharge[3];
        A10_precharge[3] = 1'b0;

        // Dqm pipeline for Read
        Dqm_reg0 = Dqm_reg1;
        Dqm_reg1 = Dqm;

        // Read or Write with Auto Precharge Counter
        if (Auto_precharge[0] == 1'b1) begin
            Count_precharge[0] = Count_precharge[0] + 1;
        end
        if (Auto_precharge[1] == 1'b1) begin
            Count_precharge[1] = Count_precharge[1] + 1;
        end

        // tMRD Counter
        MRD_chk = MRD_chk + 1;

        // tWR Counter for Write
        WR_chk[0] = WR_chk[0] + 1;
        WR_chk[1] = WR_chk[1] + 1;
        
        // Auto Refresh
        if (Aref_enable == 1'b1) begin
            if (Debug) $display ("at time %t AREF : Auto Refresh", $time);
            // Auto Refresh to Auto Refresh
            if ($time - RC_chk < tRC) begin
                $display ("at time %t ERROR: tRC violation during Auto Refresh", $time);
            end
            // Precharge to Auto Refresh
            if ($time - RP_chk < tRP) begin
                $display ("at time %t ERROR: tRP violation during Auto Refresh", $time);
            end
            // Banks must be idle before refresh
            if (Pc_b0 == 1'b0 || Pc_b1 == 1'b0) begin
                $display ("at time %t ERROR: All banks must be Precharge before Auto Refresh", $time);
            end
            // Record Current tRC time
            RC_chk = $time;
        end
        
        // Load Mode Register
        if (Mode_reg_enable == 1'b1) begin
            // Decode DLL, CAS Latency, Burst Type, and Burst Length
            if (Pc_b0 == 1'b1 && Pc_b1 == 1'b1) begin
                Mode_reg = Addr;
                if (Debug) begin
                    $display ("at time %t LMR  : Load Mode Register", $time);
                    // CAS Latency
                    if (Addr[6 : 4] == 3'b001)
                        $display ("                            CAS Latency      = 1");
                    else if (Addr[6 : 4] == 3'b010)
                        $display ("                            CAS Latency      = 2");
                    else if (Addr[6 : 4] == 3'b011)
                        $display ("                            CAS Latency      = 3");
                    else
                        $display ("                            CAS Latency      = Reserved");
                    // Burst Length
                    if (Addr[2 : 0] == 3'b000)
                        $display ("                            Burst Length     = 1");
                    else if (Addr[2 : 0] == 3'b001)
                        $display ("                            Burst Length     = 2");
                    else if (Addr[2 : 0] == 3'b010)
                        $display ("                            Burst Length     = 4");
                    else if (Addr[2 : 0] == 3'b011)
                        $display ("                            Burst Length     = 8");
                    else if (Addr[2 : 0] == 3'b111)
                        $display ("                            Burst Length     = Full");
                    else
                        $display ("                            Burst Length     = Reserved");
                    // Burst Type
                    if (Addr[3] == 1'b0)
                        $display ("                            Burst Type       = Sequential");
                    else if (Addr[3] == 1'b1)
                        $display ("                            Burst Type       = Interleaved");
                    else
                        $display ("                            Burst Type       = Reserved");
                    // Write Burst Mode
                    if (Addr[9] == 1'b0)
                        $display ("                            Write Burst Mode = Programmed Burst Length");
                    else if (Addr[9] == 1'b1)
                        $display ("                            Write Burst Mode = Single Location Access");
                    else
                        $display ("                            Write Burst Mode = Reserved");
                end
            end else begin
                $display ("at time %t ERROR: all banks must be Precharge before Load Mode Register", $time);
            end
            // REF to LMR
            if ($time - RC_chk < tRC) begin
                $display ("at time %t ERROR: tRC violation during Load Mode Register", $time);
            end
            // LMR to LMR
            if (MRD_chk < tMRD) begin
                $display ("at time %t ERROR: tMRD violation during Load Mode Register", $time);
            end
            MRD_chk = 0;
        end
        
        // Active Block (Latch Bank Address and Row Address)
        if (Active_enable == 1'b1) begin
            if (Ba == 1'b0 && Pc_b0 == 1'b1) begin
                {Act_b0, Pc_b0} = 2'b10;
                B0_row_addr = Addr [addr_bits - 1 : 0];
                RCD_chk0 = $time;
                RAS_chk0 = $time;
                if (Debug) $display ("at time %t ACT  : Bank = 0 Row = %d",$time, Addr);
                // Precharge to Activate Bank 0
                if ($time - RP_chk0 < tRP) begin
                    $display ("at time %t ERROR: tRP violation during Activate bank 0", $time);
                end
            end else if (Ba == 1'b1 && Pc_b1 == 1'b1) begin
                {Act_b1, Pc_b1} = 2'b10;
                B1_row_addr = Addr [addr_bits - 1 : 0];
                RCD_chk1 = $time;
                RAS_chk1 = $time;
                if (Debug) $display ("at time %t ACT  : Bank = 1 Row = %d",$time, Addr);
                // Precharge to Activate Bank 1
                if ($time - RP_chk1 < tRP) begin
                    $display ("at time %t ERROR: tRP violation during Activate bank 1", $time);
                end
            end else if (Ba == 1'b0 && Pc_b0 == 1'b0) begin
                $display ("at time %t ERROR: Bank 0 is not Precharged.", $time);
            end else if (Ba == 1'b1 && Pc_b1 == 1'b0) begin
                $display ("at time %t ERROR: Bank 1 is not Precharged.", $time);
            end
            // Active Bank A to Active Bank B
            if ((Previous_bank != Ba) && ($time - RRD_chk < tRRD)) begin
                $display ("at time %t ERROR: tRRD violation during Activate Bank = %d", $time, Ba);
            end
            // Load Mode Register to Active
            if (MRD_chk < tMRD ) begin
                $display ("at time %t ERROR: tMRD violation during Activate bank = %d", $time, Ba);
            end
            // Auto Refresh to Active
            if ($time - RC_chk < tRC ) begin
                $display ("at time %t ERROR: tRC violation during Activate bank = %d", $time, Ba);
            end
            // Record variables for checking violation
            RRD_chk = $time;
            Previous_bank = Ba;
        end
        
        // Precharge Block
        if (Prech_enable == 1'b1) begin
            if (Addr[10] == 1'b1) begin
                {Pc_b0, Pc_b1} = 2'b11;
                {Act_b0, Act_b1} = 2'b00;
                RP_chk0 = $time;
                RP_chk1 = $time;
                if (Debug) $display ("at time %t PRE  : Bank = ALL",$time);
                // Activate to Precharge all banks
                if (($time - RAS_chk0 < tRAS) || ($time - RAS_chk1 < tRAS)) begin
                    $display ("at time %t ERROR: tRAS violation during Precharge all bank", $time);
                end
                // tWR violation check for write
                if (WR_chk[0] < tWR || WR_chk[1] < tWR) begin
                    $display ("at time %t ERROR: tWR violation during Precharge all banks", $time);
                end
            end else if (Addr[10] == 1'b0) begin
                if (Ba == 1'b0) begin
                    {Pc_b0, Act_b0} = 2'b10;
                    RP_chk0 = $time;
                    if (Debug) $display ("at time %t PRE  : Bank = 0",$time);
                    // Activate to Precharge Bank 0
                    if ($time - RAS_chk0 < tRAS) begin
                        $display ("at time %t ERROR: tRAS violation during Precharge bank 0", $time);
                    end
                end else if (Ba == 1'b1) begin
                    {Pc_b1, Act_b1} = 2'b10;
                    RP_chk1 = $time;
                    if (Debug) $display ("at time %t PRE  : Bank = 1",$time);
                    // Activate to Precharge Bank 1
                    if ($time - RAS_chk1 < tRAS) begin
                        $display ("at time %t ERROR: tRAS violation during Precharge bank 1", $time);
                    end
                end
                // tWR violation check for write
                if (WR_chk[Ba] < tWR) begin
                    $display ("at time %t ERROR: tWR violation during Precharge Bank %d", $time, Ba);
                end
            end

            // Terminate a Write Immediately (if same bank or all banks)
            if (Data_in_enable == 1'b1 && (Bank == Ba || Addr[10] == 1'b1)) begin
                Data_in_enable = 1'b0;
            end

            // Precharge Command Pipeline for Read
            if (Cas_latency_3 == 1'b1) begin
                Command[2] = `PRECH;
                Bank_precharge[2] = Ba;
                A10_precharge[2] = Addr[10];
            end else if (Cas_latency_2 == 1'b1) begin
                Command[1] = `PRECH;
                Bank_precharge[1] = Ba;
                A10_precharge[1] = Addr[10];
//          end else if (Cas_latency_1 == 1'b1) begin
//              Command[0] = `PRECH;
//              Bank_precharge[0] = Ba;
//              A10_precharge[0] = Addr[10];
            end

            // Record Precharge Bank and Current tRP time
            RP_chk = $time;
        end
        
        // Burst terminate
        if (Burst_term == 1'b1) begin
            // Terminate a Write Immediately
            if (Data_in_enable == 1'b1) begin
                Data_in_enable = 1'b0;
            end

            // Terminate a Read Depend on CAS Latency
            if (Cas_latency_3 == 1'b1) begin
                Command[2] = `BST;
            end else if (Cas_latency_2 == 1'b1) begin
                Command[1] = `BST;
//          end else if (Cas_latency_1 == 1'b1) begin
//              Command[0] = `BST;
            end

            // Display message
            if (Debug) $display ("at time %t BST  : Burst Terminate",$time);
        end
        
        // Read, Write, Column Latch
        if (Read_enable == 1'b1 || Write_enable == 1'b1) begin
            // Check to see if bank is open (ACT)
            if ((Ba == 1'b0 && Pc_b0 == 1'b1) || (Ba == 1'b1 && Pc_b1 == 1'b1)) begin
                $display("at time %t ERROR: Cannot Read or Write - Bank %b is not Activated", $time, Ba);
            end
            // Activate to Read or Write
            if ((Ba == 1'b0) && ($time - RCD_chk0 < tRCD))
                $display("at time %t ERROR: tRCD violation during Read or Write to Bank 0", $time);
            if ((Ba == 1'b1) && ($time - RCD_chk1 < tRCD))
                $display("at time %t ERROR: tRCD violation during Read or Write to Bank 1", $time);

            // Read Command
            if (Read_enable == 1'b1) begin
                // CAS Latency pipeline
                if (Cas_latency_3 == 1'b1) begin
                    if (Addr[10] == 1'b1) begin
                        Command[2] = `READ_A;
                    end else begin
                        Command[2] = `READ;
                    end
                    Col_addr[2] = Addr;
                    Bank_addr[2] = Ba;
                end else if (Cas_latency_2 == 1'b1) begin
                    if (Addr[10] == 1'b1) begin
                        Command[1] = `READ_A;
                    end else begin
                        Command[1] = `READ;
                    end
                    Col_addr[1] = Addr;
                    Bank_addr[1] = Ba;
//              end else if (Cas_latency_1 == 1'b1) begin
//                  if (Addr[10] == 1'b1) begin
//                      Command[0] = `READ_A;
//                  end else begin
//                      Command[0] = `READ;
//                  end
//                  Col_addr[0] = Addr;
//                  Bank_addr[0] = Ba;
                end

                // Read Interrupt Write (terminate Write immediately)
                if (Data_in_enable == 1'b1) begin
                    if (Auto_precharge[Bank] == 1'b1 && Write_precharge[Bank] == 1'b1) begin
                        Data_in_enable = 1'b0;
                        RW_interrupt_write[Bank] = 1'b1;
                        $display ("at time %t NOTE : Read Bank %d interrupt Write Bank %d", $time, Ba, Bank);
                    end
                end

                // Read Interrupt Read (terminate Read after CAS latency)
                if (Data_out_enable == 1'b1) begin
                    if (Auto_precharge[Bank] == 1'b1 && Read_precharge[Bank] == 1'b1) begin
                        RW_interrupt_read[Bank] = 1'b1;
                        $display ("at time %t NOTE : Read Bank %d interrupt Read Bank %d", $time, Ba, Bank);
                    end
                end

            // Write Command
            end else if (Write_enable == 1'b1) begin
                if (Addr[10] == 1'b1) begin
                    Command[0] = `WRITE_A;
                end else begin
                    Command[0] = `WRITE;
                end
                Col_addr[0] = Addr;
                Bank_addr[0] = Ba;

                // Write Interrupt Write (terminate immediately)
                if (Data_in_enable == 1'b1) begin
                    if (Auto_precharge[Bank] == 1'b1 && Write_precharge[Bank] == 1'b1) begin
                        Data_in_enable = 1'b0;
                        RW_interrupt_write[Bank] = 1'b1;
                        $display ("at time %t NOTE : Write Bank %d interrupt Write Bank %d", $time, Ba, Bank);
                    end
                end

                // Write Interrupt Read (terminate immediately)
                if (Data_out_enable == 1'b1) begin
                    if (Auto_precharge[Bank] == 1'b1 && Read_precharge[Bank] == 1'b1) begin
                        Data_out_enable = 1'b0;
                        RW_interrupt_read[Bank] = 1'b1;
                        $display ("at time %t NOTE : Write Bank %d interrupt Read Bank %d", $time, Ba, Bank);
                    end
                end
            end

            // Read or Write with Auto Precharge
            if (Addr[10] == 1'b1) begin
                Auto_precharge[Ba] = 1'b1;
                Count_precharge[Ba] = 0;
                if (Read_enable == 1'b1) begin
                    Read_precharge[Ba] = 1'b1;
                end else if (Write_enable == 1'b1) begin
                    Write_precharge[Ba] = 1'b1;
                end
            end
        end

        //  Read with Auto Precharge Calculation
        //      The device start internal precharge:
        //          1.  CAS Latency - 1 cycles before last burst
        //      and 2.  Meet minimum tRAS requirement
        //       or 3.  Interrupt by a Read or Write (with or without AutoPrecharge)
        if ((Auto_precharge[0] == 1'b1) && (Read_precharge[0] == 1'b1)) begin
            if ((($time - RAS_chk0 >= tRAS) &&
                ((Burst_length_1 == 1'b1 && Count_precharge[0] >= 1) || 
                 (Burst_length_2 == 1'b1 && Count_precharge[0] >= 2) ||
                 (Burst_length_4 == 1'b1 && Count_precharge[0] >= 4) ||
                 (Burst_length_8 == 1'b1 && Count_precharge[0] >= 8))) ||
                 (RW_interrupt_read[0] == 1'b1)) begin
                    Pc_b0 = 1'b1;
                    Act_b0 = 1'b0;
                    RP_chk0 = $time;
                    Auto_precharge[0] = 1'b0;
                    Read_precharge[0] = 1'b0;
                    RW_interrupt_read[0] = 1'b0;
                    if (Debug) $display ("at time %t NOTE : Start Internal Auto Precharge for Bank 0", $time);
            end
        end
        if ((Auto_precharge[1] == 1'b1) && (Read_precharge[1] == 1'b1)) begin
            if ((($time - RAS_chk1 >= tRAS) && 
                ((Burst_length_1 == 1'b1 && Count_precharge[1] >= 1) || 
                 (Burst_length_2 == 1'b1 && Count_precharge[1] >= 2) ||
                 (Burst_length_4 == 1'b1 && Count_precharge[1] >= 4) ||
                 (Burst_length_8 == 1'b1 && Count_precharge[1] >= 8))) ||
                 (RW_interrupt_read[1] == 1'b1)) begin
                    Pc_b1 = 1'b1;
                    Act_b1 = 1'b0;
                    RP_chk1 = $time;
                    Auto_precharge[1] = 1'b0;
                    Read_precharge[1] = 1'b0;
                    RW_interrupt_read[1] = 1'b0;
                    if (Debug) $display ("at time %t NOTE : Start Internal Auto Precharge for Bank 1", $time);
            end
        end
        //  Write with Auto Precharge Calculation
        //      The device start internal precharge:
        //          1.  tWR Clock after last burst
        //      and 2.  Meet minimum tRAS requirement
        //       or 3.  Interrupt by a Read or Write (with or without AutoPrecharge)
        if ((Auto_precharge[0] == 1'b1) && (Write_precharge[0] == 1'b1)) begin
            if ((($time - RAS_chk0 >= tRAS) &&
               (((Burst_length_1 == 1'b1 || Write_burst_mode == 1'b1) && Count_precharge [0] >= 1) || 
                 (Burst_length_2 == 1'b1                              && Count_precharge [0] >= 2) ||
                 (Burst_length_4 == 1'b1                              && Count_precharge [0] >= 4) ||
                 (Burst_length_8 == 1'b1                              && Count_precharge [0] >= 8))) ||
                 (RW_interrupt_write[0] == 1'b1 && WR_chk[0] >= 3)) begin
                    Pc_b0 = 1'b1;
                    Act_b0 = 1'b0;
                    RP_chk0 = $time;
                    Auto_precharge[0] = 1'b0;
                    Write_precharge[0] = 1'b0;
                    RW_interrupt_write[0] = 1'b0;
                    if (Debug) $display ("at time %t NOTE : Start Internal Auto Precharge for Bank 0", $time);
            end
        end
        if ((Auto_precharge[1] == 1'b1) && (Write_precharge[1] == 1'b1)) begin
            if ((($time - RAS_chk1 >= tRAS) &&
               (((Burst_length_1 == 1'b1 || Write_burst_mode == 1'b1) && Count_precharge [1] >= 1) || 
                 (Burst_length_2 == 1'b1                              && Count_precharge [1] >= 2) ||
                 (Burst_length_4 == 1'b1                              && Count_precharge [1] >= 4) ||
                 (Burst_length_8 == 1'b1                              && Count_precharge [1] >= 8))) ||
                 (RW_interrupt_write[1] == 1'b1 && WR_chk[1] >= 3)) begin
                    Pc_b1 = 1'b1;
                    Act_b1 = 1'b0;
                    RP_chk1 = $time;
                    Auto_precharge[1] = 1'b0;
                    Write_precharge[1] = 1'b0;
                    RW_interrupt_write[1] = 1'b0;
                    if (Debug) $display ("at time %t NOTE : Start Internal Auto Precharge for Bank 1", $time);
            end
        end

        // Internal Precharge or Bst
        if (Command[0] == `PRECH) begin                         // Precharge terminate a read with same bank or all banks
            if (Bank_precharge[0] === Bank || A10_precharge[0] === 1'b1) begin
                if (Data_out_enable == 1'b1) begin
                    Data_out_enable = 1'b0;
                    if (Debug) $display ("at time %t NOTE : Internal Precharge Terminates Read", $time);
                end
            end
        end else if (Command[0] == `BST) begin                  // BST terminate a read to current bank
            if (Data_out_enable == 1'b1) begin
                Data_out_enable = 1'b0;
                if (Debug) $display ("at time %t NOTE : Internal Burst Terminate Terminates Read", $time);
            end
        end

        if (Data_out_enable == 1'b0) begin
            Dq_reg <= #tOH {data_bits{1'bz}};
        end

        // Detect Read or Write command
        if (Command[0] == `READ || Command[0] == `READ_A) begin
            Bank = Bank_addr[0];
            Col = Col_addr[0];
            Col_brst = Col_addr[0];
            if (Bank_addr[0] == 1'b0) begin
                Row = B0_row_addr;
            end else if (Bank_addr[0] == 1'b1) begin
                Row = B1_row_addr;
            end
            Burst_counter = 0;
            Data_in_enable = 1'b0;
            Data_out_enable = 1'b1;
        end else if (Command[0] == `WRITE || Command[0] == `WRITE_A) begin
            Bank = Bank_addr[0];
            Col = Col_addr[0];
            Col_brst = Col_addr[0];
            if (Bank_addr[0] == 1'b0) begin
                Row = B0_row_addr;
            end else if (Bank_addr[0] == 1'b1) begin
                Row = B1_row_addr;
            end
            Burst_counter = 0;
            Data_in_enable = 1'b1;
            Data_out_enable = 1'b0;
        end

        // DQ buffer
        if (Data_in_enable == 1'b1) begin                                   // Writing Data to Memory
            if (Dqm [1 : 0] == 2'b11) begin
                if (Debug) $display("at time %t WRITE: Bank = %b Row = %d, Col = %d, Data = don't care due to DQM", $time, Bank, Row, Col);
            end else begin
                // Array buffer
                if (Bank == 1'b0) Dq_dqm [15 : 0] = Bank0 [{Row, Col}];
                if (Bank == 1'b1) Dq_dqm [15 : 0] = Bank1 [{Row, Col}];
                // Dqm operation
                if (Dqm[0] == 1'b0) Dq_dqm [ 7 : 0] = Dq [ 7 : 0];
                if (Dqm[1] == 1'b0) Dq_dqm [15 : 8] = Dq [15 : 8];
                // Write to Memory
                if (Bank == 1'b0) Bank0 [{Row, Col}] = Dq_dqm [15 : 0];
                if (Bank == 1'b1) Bank1 [{Row, Col}] = Dq_dqm [15 : 0];
                if (Debug) $display("at time %t WRITE: Bank = %b Row = %d, Col = %d, Data = %d, Dqm = %b", $time, Bank, Row, Col, Dq_dqm, Dqm);
                // Reset tWR counter
                WR_chk[Bank] = 0;
            end
            // Advance burst counter
            #tOH Burst;
        end else if (Data_out_enable == 1'b1) begin                         // Reading Data from Memory
            if (Dqm_reg0 [1 : 0] == 2'b11) begin
                Dq_reg = #tHZ {data_bits{1'bz}};
                if (Debug) $display("at time %t READ : Bank = %d Row = %d, Col = %d, Data = Hi-Z due to DQM", $time, Bank, Row, Col);
            end else begin
                // Array buffer
                if (Bank == 1'b0) Dq_dqm [15 : 0] = Bank0 [{Row, Col}];
                if (Bank == 1'b1) Dq_dqm [15 : 0] = Bank1 [{Row, Col}];
                // Dqm operation
                if (Dqm_reg0[0] == 1'b1) Dq_dqm [ 7 : 0] = 8'bz;
                if (Dqm_reg0[1] == 1'b1) Dq_dqm [15 : 8] = 8'bz;
                // Display result
                Dq_reg = #tAC Dq_dqm;
                if (Debug) $display("at time %t READ : Bank = %b Row = %d, Col = %d, Data = %d, Dqm = %b", $time, Bank, Row, Col, Dq_reg, Dqm_reg0);
            end
            Burst;
        end
    end

    task Burst;
        begin
            // Advance Burst Counter
            Burst_counter = Burst_counter + 1;

            // Burst Type
            if (Mode_reg[3] == 1'b0) begin                                  // Sequential Burst
                Col_temp = Col + 1;
            end else if (Mode_reg[3] == 1'b1) begin                         // Interleaved Burst
                Col_temp[2] =  Burst_counter[2] ^  Col_brst[2];
                Col_temp[1] =  Burst_counter[1] ^  Col_brst[1];
                Col_temp[0] =  Burst_counter[0] ^  Col_brst[0];
            end

            // Burst Length
            if (Burst_length_2) begin                                       // Burst Length = 2
                Col [0] = Col_temp [0];
            end else if (Burst_length_4) begin                              // Burst Length = 4
                Col [1 : 0] = Col_temp [1 : 0];
            end else if (Burst_length_8) begin                              // Burst Length = 8
                Col [2 : 0] = Col_temp [2 : 0];
            end else begin                                                  // Burst Length = FULL
                Col = Col_temp;
            end

            // Burst Read Single Write            
            if (Write_burst_mode == 1'b1) begin
                Data_in_enable = 1'b0;
            end

            // Data Counter
            if (Burst_length_1 == 1'b1) begin
                if (Burst_counter >= 1) begin
                    Data_in_enable = 1'b0;
                    Data_out_enable = 1'b0;
                end
            end else if (Burst_length_2 == 1'b1) begin
                if (Burst_counter >= 2) begin
                    Data_in_enable = 1'b0;
                    Data_out_enable = 1'b0;
                end
            end else if (Burst_length_4 == 1'b1) begin
                if (Burst_counter >= 4) begin
                    Data_in_enable = 1'b0;
                    Data_out_enable = 1'b0;
                end
            end else if (Burst_length_8 == 1'b1) begin
                if (Burst_counter >= 8) begin
                    Data_in_enable = 1'b0;
                    Data_out_enable = 1'b0;
                end
            end
        end
    endtask

    // Timing Check for -10 component (CL = 3)
    specify
        specparam
                    tAH  =  1,                                          // Addr, Ba Hold Time
                    tAS  =  3,                                          // Addr, Ba Setup Time
                    tCH  =  3.5,                                        // Clock High-Level Width
                    tCL  =  3.5,                                        // Clock Low-Level Width
                    tCK  = 10,                                          // Clock Cycle Time
                    tDH  =  1,                                          // Data-in Hold Time
                    tDS  =  3,                                          // Data-in Setup Time
                    tCKH =  1,                                          // CKE Hold Time
                    tCKS =  3,                                          // CKE Setup Time
                    tCMH =  1,                                          // CS#, RAS#, CAS#, WE#, DQM# Hold Time
                    tCMS =  3;                                          // CS#, RAS#, CAS#, WE#, DQM# Setup Time
        $width    (posedge Clk,           tCH);
        $width    (negedge Clk,           tCL);
        $period   (negedge Clk,           tCK);
        $period   (posedge Clk,           tCK);
        $setuphold(posedge Clk,    Cke,   tCKS, tCKH);
        $setuphold(posedge Clk,    Cs_n,  tCMS, tCMH);
        $setuphold(posedge Clk,    Cas_n, tCMS, tCMH);
        $setuphold(posedge Clk,    Ras_n, tCMS, tCMH);
        $setuphold(posedge Clk,    We_n,  tCMS, tCMH);
        $setuphold(posedge Clk,    Addr,  tAS,  tAH);
        $setuphold(posedge Clk,    Ba,    tAS,  tAH);
        $setuphold(posedge Clk,    Dqm,   tCMS, tCMH);
        $setuphold(posedge Dq_chk, Dq,    tDS,  tDH);
    endspecify

endmodule

