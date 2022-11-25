module "example"

path "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

import "../common/lua-object.lua"

typeconf "example::ClickCallback"
typeconf 'example::Type'
typeconf 'example::Point'
typeconf "example::Hello"
