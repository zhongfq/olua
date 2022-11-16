cmake_minimum_required(VERSION 3.10)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/lua_types.h
    src/lua_types.cpp
    src/main.cpp
)

add_executable(template ${source})
target_link_libraries(template common)
target_compile_definitions(template
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
add_test(NAME test_template COMMAND template)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)