cmake_minimum_required(VERSION 3.8)
project(sdc)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
   message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

# SystemC dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Find SystemC using SystemC's CMake integration
find_package(SystemCLanguage QUIET)
# Create a new executable target that will contain all your sources
add_executable(sdc_v ../../tb/sc_main.cpp)

# Add the Verilated circuit to the target
verilate(sdc_v SYSTEMC
   INCLUDE_DIRS "../rtl"
   INCLUDE_DIRS "../micron"
   SOURCES sdc_agent.v)

verilator_link_systemc(sdc_v)
