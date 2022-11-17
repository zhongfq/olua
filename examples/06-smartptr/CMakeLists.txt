cmake_minimum_required(VERSION 3.21)

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
if(WIN32)
    add_custom_command(TARGET smartptr POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:smartptr> $<TARGET_FILE_DIR:smartptr>
      COMMAND_EXPAND_LISTS
    )
endif()
add_test(NAME test_smartptr COMMAND smartptr)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)