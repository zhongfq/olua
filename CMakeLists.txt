cmake_minimum_required(VERSION 3.21)

project(olua)

set(CMAKE_CXX_STANDARD 11)

enable_testing()

add_subdirectory(examples/lua)
add_subdirectory(examples/common)
add_subdirectory(examples/00-testapi)
add_subdirectory(examples/01-helloworld)
add_subdirectory(examples/02-callback)
add_subdirectory(examples/03-convertor)
add_subdirectory(examples/04-reference)
add_subdirectory(examples/05-template)
add_subdirectory(examples/06-smartptr)