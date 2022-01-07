#include <stdio.h>
#include <stdlib.h>

#include "AutoreleasePool.h"
#include "xlua.h"
#include "lua_example.h"

int main(int argc, const char * argv[])
{
    int status;
    lua_State *L = xlua_new();
    olua_require(L, "olua", luaopen_olua);
    olua_callfunc(L, luaopen_example);
    status = xlua_dofile(L, "test.lua");
    example::AutoreleasePool::clear();
    lua_close(L);
    return 0;
}