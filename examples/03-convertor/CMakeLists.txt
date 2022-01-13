cmake_minimum_required(VERSION 3.10)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(convertor ${source})
target_link_libraries(convertor common)
add_custom_command(
  TARGET
    convertor
  PRE_BUILD
  COMMAND
    cp -v ${CMAKE_CURRENT_SOURCE_DIR}/src/*.lua ${CMAKE_CURRENT_BINARY_DIR}
  COMMAND
    cp -v ${CMAKE_CURRENT_SOURCE_DIR}/../common/*.lua ${CMAKE_CURRENT_BINARY_DIR}
)
add_test(NAME test_convertor COMMAND convertor)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)