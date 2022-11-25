module "example"

path "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

import "../common/lua-object.lua"

typedef "example::Color"
typedef "example::vector"
    .conv "olua_$$_array"

typeconf "example::Point"
    .packable 'true'

typeconf "example::Node"
    .extend 'example::NodeExtend'