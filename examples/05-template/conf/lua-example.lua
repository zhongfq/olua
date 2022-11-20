module "example"

path "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

import "../common/lua-object.lua"

typeconf "example::Hello"
typeconf "example::TestGC"

typeconf '^example::TestWildcard.*Event'
    .exclude 'hello'
    .luaopen [[
        printf("test wildcard luaopen\n");
    ]]