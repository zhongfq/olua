cmake_minimum_required(VERSION 3.10)

set(source
    src/Hello.h
    src/Hello.cpp
    src/lua_hello.h
    src/lua_hello.cpp
    src/main.cpp
)

add_executable(helloworld ${source})
target_link_libraries(helloworld common)
add_custom_command(
  TARGET
    helloworld
  PRE_BUILD
  COMMAND
    cp -v ${CMAKE_CURRENT_SOURCE_DIR}/src/*.lua ${CMAKE_CURRENT_BINARY_DIR}
)
add_test(NAME test_helloworld COMMAND helloworld)