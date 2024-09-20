module "types"

output_dir "../common"

api_dir "../../addons/example"

headers [[
#include "olua-custom.h"
]]

import "../../lua-types.lua"
