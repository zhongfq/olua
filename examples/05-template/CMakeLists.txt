cmake_minimum_required(VERSION 3.21)

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
if(WIN32)
    add_custom_command(TARGET template POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:template> $<TARGET_FILE_DIR:template>
      COMMAND_EXPAND_LISTS
    )
endif()
add_test(NAME test_template COMMAND template)

execute_process(
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}
  COMMAND
    lua build.lua
)