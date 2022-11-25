package.path = "../../../?.lua;../../../?/init.lua;" .. package.path

require "olua.tools"

autoconf "../common/lua-types.lua"
autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"