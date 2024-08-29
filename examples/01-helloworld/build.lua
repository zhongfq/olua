package.path = "../../?.lua;" .. package.path

require "init"

olua.AUTO_EXPORT_PARENT = true
olua.VERBOSE = true


autoconf "../common/lua-types.lua"
autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"
