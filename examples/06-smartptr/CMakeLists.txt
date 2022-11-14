cmake_minimum_required(VERSION 3.10)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(smartptr ${source})
target_link_libraries(smartptr common)
target_compile_definitions(smartptr
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
add_test(NAME test_smartptr COMMAND smartptr)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)