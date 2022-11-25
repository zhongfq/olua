cmake_minimum_required(VERSION 3.21)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(03-convertor ${source})
target_link_libraries(03-convertor common)
target_compile_definitions(03-convertor
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
if(WIN32)
    add_custom_command(TARGET 03-convertor POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:03-convertor> $<TARGET_FILE_DIR:03-convertor>
      COMMAND_EXPAND_LISTS
    )
endif()
add_test(NAME test-03-convertor COMMAND 03-convertor)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)