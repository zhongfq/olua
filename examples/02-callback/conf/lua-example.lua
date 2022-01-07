module "example"

path "src"

headers [[
#include "Example.h"
#include "xlua.h"
]]

chunk [[
static std::string makeForeachTag(int value)
{
    return "foreach" + std::to_string(value);
}
]]

include "../common/lua-object.lua"

typeconf "example::Event"
typeconf "example::Callback::Listener"
typeconf "example::Callback"
    .callback({
        name = 'setOnceEvent',
        tag_scope = 'once',
    })
    .callback({
        name = 'foreach',
        tag_scope = 'function',
        tag_mode= 'OLUA_TAG_NEW',
        tag_maker = 'makeForeachTag(#1)',
    })