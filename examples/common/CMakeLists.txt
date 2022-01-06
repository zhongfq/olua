cmake_minimum_required(VERSION 3.10)

set(source
    AutoreleasePool.h
    AutoreleasePool.cpp
    luauser.h
    Object.h
    Object.cpp
    xlua.h
    xlua.cpp
    ../../olua.h
    ../../olua.hpp
    ../../olua.c
)

add_library(common ${source})
target_link_libraries(common liblua)
target_compile_definitions(common
  PUBLIC
    OLUA_USER_H="luauser.h"
    OLUA_DEBUG
)
target_include_directories(common
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../..
)