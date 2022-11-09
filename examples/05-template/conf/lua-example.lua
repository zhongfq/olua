module "example"

path "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

include "../common/lua-object.lua"

typeconf 'example::Singleton'
typeconf "example::Hello"
typeconf "example::TestGC"

typeconf '^example::TestWildcard*'
    .exclude 'hello'
    .luaopen [[
        printf("test wildcard luaopen\n");
    ]]