package.path = "../../?.lua;" .. package.path

require "init"

autoconf "../common/lua-types.lua"
autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"
