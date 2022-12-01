cmake_minimum_required(VERSION 3.21)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(02-callback ${source})
target_link_libraries(02-callback common)
target_compile_definitions(02-callback
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
if(WIN32)
    add_custom_command(TARGET 02-callback POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:02-callback> $<TARGET_FILE_DIR:02-callback>
      COMMAND_EXPAND_LISTS
    )
endif()
add_test(NAME test-02-callback COMMAND 02-callback)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)