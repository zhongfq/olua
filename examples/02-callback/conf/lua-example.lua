module "example"

path "src"

headers [[
#include "Callback.h"
#include "xlua.h"
]]

typeconf "example::Event"
typeconf "example::Object"
    .exclude "retain"
    .exclude "release"
    .func('__gc', [[
    {
        return xlua_objgc(L);
    }]])
typeconf "example::Callback::Listener"
typeconf "example::Callback"
    .callback({
        name = 'setOnceEvent',
        tag_scope = 'once',
    })