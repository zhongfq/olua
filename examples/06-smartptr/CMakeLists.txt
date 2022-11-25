cmake_minimum_required(VERSION 3.21)

set(source
    src/Example.h
    src/Example.cpp
    src/lua_example.h
    src/lua_example.cpp
    src/main.cpp
)

add_executable(06-smartptr ${source})
target_link_libraries(06-smartptr common)
target_compile_definitions(06-smartptr
  PUBLIC
    LUA_TEST="${CMAKE_CURRENT_SOURCE_DIR}/src/test.lua"
)
if(WIN32)
    add_custom_command(TARGET 06-smartptr POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:06-smartptr> $<TARGET_FILE_DIR:06-smartptr>
      COMMAND_EXPAND_LISTS
    )
endif()
add_test(NAME test-06-smartptr COMMAND 06-smartptr)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)