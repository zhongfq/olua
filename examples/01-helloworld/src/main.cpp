#include <stdio.h>
#include <stdlib.h>

#include "AutoreleasePool.h"
#include "xlua.h"
#include "lua_example.h"

int main(int argc, const char * argv[])
{
    int status = 0;
    lua_State *L = xlua_new();
    olua_callfunc(L, luaopen_example);
    status = xlua_dofile(L, "test.lua");
    example::AutoreleasePool::clear();
    lua_close(L);
    return status;
}