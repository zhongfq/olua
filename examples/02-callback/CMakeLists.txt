cmake_minimum_required(VERSION 3.10)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(callback ${source})
target_link_libraries(callback common)
add_custom_command(
  TARGET
    callback
  PRE_BUILD
  COMMAND
    cd ${CMAKE_CURRENT_SOURCE_DIR} && lua build.lua
  COMMAND
    cp -v ${CMAKE_CURRENT_SOURCE_DIR}/src/*.lua ${CMAKE_CURRENT_BINARY_DIR}
  COMMAND
    cp -v ${CMAKE_CURRENT_SOURCE_DIR}/../common/*.lua ${CMAKE_CURRENT_BINARY_DIR}
)
add_test(NAME test_callback COMMAND callback)