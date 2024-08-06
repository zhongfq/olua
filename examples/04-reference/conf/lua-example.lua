---@format disable

module "example"

output_dir "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

import "../common/lua-object.lua"

typedef "example::vector"
    .conv "olua_$$_array"

typeconf "example::Node"
    .func "setComponent" .annotate "arg1" .attr "@addref(component ^)"
    .func "getComponent".annotate "ret" .attr "@addref(component ^)"
    .func "addChild" .annotate "arg1" .attr "@addref(children |)"
    .func "removeChild" .annotate "arg1" .attr "@delref(children |)"
    .func "removeChildByName" .annotate "ret" .attr "@delref(children ~)"
    .func "getChildByName" .annotate "ret" .attr "@addref(children |)"
    .func "removeAllChildren" .annotate "ret" .attr "@delref(children *)"
    .func "removeSelf" .annotate "ret" .attr "@delref(children | parent)"
        .insert_before [[
            if (!self->getParent()) {
                return 0;
            }
            olua_pushobj<example::Node>(L, self->getParent());
            int parent = lua_gettop(L);
        ]]
