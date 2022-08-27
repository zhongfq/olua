package.path = "../../../?.lua;../../../?/init.lua;" .. package.path

require "olua.tools"

autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"