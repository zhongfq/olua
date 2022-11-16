module "types"

path "src"

headers [[
#include "olua-custom.h"
]]

include "../../lua-types.lua"