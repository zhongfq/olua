package.path = "../../?.lua;" .. package.path

olua.AUTO_EXPORT_PARENT = true

olua.VERBOSE = true

require "init"

autoconf "../common/lua-types.lua"
autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"
