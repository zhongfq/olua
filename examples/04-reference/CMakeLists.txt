cmake_minimum_required(VERSION 3.21)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(04-reference ${source})
target_link_libraries(04-reference common)
target_compile_definitions(04-reference
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
if(WIN32)
    add_custom_command(TARGET 04-reference POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:04-reference> $<TARGET_FILE_DIR:04-reference>
      COMMAND_EXPAND_LISTS
    )
endif()
add_test(NAME test-04-reference COMMAND 04-reference)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua)