module "hello"

path "src"

headers [[
#include "Hello.h"
#include "xlua.h"
]]

typeconf "example::Object"
    .exclude "retain"
    .exclude "release"
    .func('__gc', [[
    {
        return xlua_objgc(L);
    }]])
typeconf "example::Hello"