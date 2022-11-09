module "example"

path "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

include "../common/lua-object.lua"

typeconf "example::Hello"
