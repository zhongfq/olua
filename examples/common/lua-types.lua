module "types"

path "../common"

headers [[
#include "olua-custom.h"
]]

import "../../lua-types.lua"