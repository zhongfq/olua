package.path = "../../?.lua;" .. package.path

require "init"

olua.AUTO_EXPORT_PARENT = true
olua.VERBOSE = true

clang {
    "-DOLUA_DEBUG",
    "-DTEST_OLUA_MACRO",
    "-Isrc",
    "-I../common",
    "-I../lua",
    "-I../..",
}

autoconf "../common/lua-types.lua"
autoconf "conf/lua-example.lua"
