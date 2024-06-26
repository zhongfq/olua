module "example"

outputdir "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

import "../common/lua-object.lua"

typeconf "example::Hello"
