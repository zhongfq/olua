package.path = "../../?.lua;" .. package.path

require "init"

OLUA_AUTO_EXPORT_PARENT = true
OLUA_VERBOSE = true

autoconf "../common/lua-types.lua"
autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"
