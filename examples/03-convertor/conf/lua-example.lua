module "example"

path "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

import "../common/lua-object.lua"

typedef "example::Identifier"
    .decltype "std::string"
typedef "example::Color"
typedef "example::vector"
    .conv "olua_$$_array"

typeconv "example::Point"

typeconf "example::Node"
    .extend 'example::NodeExtend'