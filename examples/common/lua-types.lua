module "types"

output_dir "../common"

headers [[
#include "olua-custom.h"
]]

import "../../lua-types.lua"
