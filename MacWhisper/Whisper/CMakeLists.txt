cmake_minimum_required(VERSION 3.13)
project(whisper C CXX)

set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")

set(BUILD_SHARED_LIBS OFF)

set(WHISPER_BUILD_TESTS OFF CACHE BOOL "")
set(WHISPER_BUILD_EXAMPLES OFF CACHE BOOL "")

add_subdirectory(whisper.cpp)

# Add a target for our wrapper.
add_library(whisper_wrapper STATIC
    whisper_wrapper.cpp
)

target_link_libraries(whisper_wrapper PRIVATE whisper)
