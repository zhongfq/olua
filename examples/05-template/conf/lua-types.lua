module "types"

path "src"

headers [[
#include "olua-custom.h"
]]

import "../../lua-types.lua"