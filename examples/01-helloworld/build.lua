package.path = "../../?.lua;" .. package.path

OLUA_AUTO_EXPORT_PARENT = true

OLUA_VERBOSE = true

require "init"

autoconf "../common/lua-types.lua"
autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"
