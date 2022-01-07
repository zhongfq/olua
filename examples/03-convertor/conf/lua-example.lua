module "example"

path "src"

headers [[
#include "Convertor.h"
#include "xlua.h"
]]

typedef "example::Identifier"
    .decltype "std::string"
typedef "example::Color"
typedef "example::vector"

typeconv "example::Point"

typeconf "example::Object"
    .exclude "retain"
    .exclude "release"
    .func('__gc', [[
    {
        return xlua_objgc(L);
    }]])
typeconf "example::Node"