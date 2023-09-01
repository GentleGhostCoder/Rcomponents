cmake_minimum_required(VERSION 3.10)
project(Rcomponents)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

find_package(R REQUIRED)
message("R libraries: ${R_LIBRARIES}")
message("R include dirs: ${R_INCLUDE_DIR} ${Rcpp_INCLUDE_DIR}")

# Add inst/include directory for libdeflate headers
add_subdirectory(build/libdeflate)

add_library(Rcomponents SHARED src/compressor.cpp src/Makevars src/compressor.h)
include_directories(${CMAKE_SOURCE_DIR}/src)
include_directories(Rcomponents ${R_INCLUDE_DIR} ${Rcpp_INCLUDE_DIR})
target_link_libraries(Rcomponents ${R_LIBRARIES})
