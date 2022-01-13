module "example"

path "src"

headers [[
#include "Example.h"
#include "xlua.h"
]]

include "../common/lua-object.lua"

typedef "example::vector"

typeconf "example::Node"
    .func 'setComponent' .arg1 '@addref(component ^)'
    .func 'getComponent' .ret '@addref(component ^)'
    .func 'addChild' .arg1 '@addref(children |)'
    .func 'removeChild' .arg1 '@delref(children |)'
    .func 'removeChildByName' .ret '@delref(children ~)'
    .func 'getChildByName' .ret '@addref(children |)'
    .func 'removeAllChildren' .ret '@delref(children *)'
    .func 'removeSelf' .ret '@delref(children | parent)'
    .insert 'removeSelf'
        .before [[
            if (!self->getParent()) {
                return 0;
            }
            olua_push_cppobj<example::Node>(L, self->getParent());
            int parent = lua_gettop(L);
        ]]