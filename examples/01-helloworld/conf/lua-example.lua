module "example"

path "src"

headers [[
#include "Example.h"
#include "xlua.h"
]]

include "../common/lua-object.lua"

typeconf "example::Hello"