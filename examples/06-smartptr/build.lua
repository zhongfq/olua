package.path = "../../../?.lua;../../../?/init.lua;" .. package.path

OLUA_AUTO_EXPORT_PARENT = true
OLUA_VERBOSE = true

require "olua.tools"

autoconf "../common/lua-types.lua"
autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"
