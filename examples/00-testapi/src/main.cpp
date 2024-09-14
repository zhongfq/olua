#include <stdio.h>
#include <stdlib.h>

#include "AutoreleasePool.h"
#include "olua-custom.h"
#include "lua_example.h"
#include "Example.h"
#include <iostream>

struct A {
    void *a;
    uint16_t b;
    int c;
};

struct B {
    void *a;
    char b;
    int c;
};

struct C {
    void *a;
    int b;
    int c;
};

int main(int argc, const char * argv[])
{

    std::cout << sizeof(A) << " " << sizeof(B) << " " << sizeof(C) << std::endl;

    int status = 0;
    lua_State *L = olua_new();
    olua_import(L, luaopen_example);
    status = olua_dofile(L, LUA_TEST);
    example::AutoreleasePool::clear();
    lua_close(L);
    return status;
}
