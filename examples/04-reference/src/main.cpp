#include <stdio.h>
#include <stdlib.h>

#include "AutoreleasePool.h"
#include "olua-custom.h"
#include "lua_example.h"

int main(int argc, const char * argv[])
{
    int status;
    lua_State *L = olua_new();
    olua_callfunc(L, luaopen_example);
    status = olua_dofile(L, LUA_TEST);
    example::AutoreleasePool::clear();
    lua_close(L);
    return 0;
}