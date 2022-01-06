cmake_minimum_required(VERSION 3.10)

set(source
    src/Callback.h
    src/Callback.cpp
    src/lua_callback.h
    src/lua_callback.cpp
    src/main.cpp
)

add_executable(callback ${source})
target_link_libraries(callback common)
add_custom_command(
  TARGET
    callback
  PRE_BUILD
  COMMAND
    cp -v ${CMAKE_CURRENT_SOURCE_DIR}/src/*.lua ${CMAKE_CURRENT_BINARY_DIR}
)
add_test(NAME test_callback COMMAND callback)