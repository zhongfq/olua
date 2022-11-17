cmake_minimum_required(VERSION 3.21)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(helloworld ${source})
target_link_libraries(helloworld common)
target_compile_definitions(helloworld
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
add_custom_command(TARGET helloworld POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:helloworld> $<TARGET_FILE_DIR:helloworld>
  COMMAND_EXPAND_LISTS
)
add_test(NAME test_helloworld COMMAND helloworld)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)