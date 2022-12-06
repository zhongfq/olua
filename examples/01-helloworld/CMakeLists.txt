cmake_minimum_required(VERSION 3.16)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(01-helloworld ${source})
target_link_libraries(01-helloworld common)
target_compile_definitions(01-helloworld
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
add_test(NAME test-01-helloworld COMMAND 01-helloworld)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)