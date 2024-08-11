---@format disable

module "example"

output_dir "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

codeblock [[
static std::string makeForeachTag(int value)
{
    return "foreach" + std::to_string(value);
}
]]

luaopen [[
    printf("insert code in luaopen\n");
]]

import "../common/lua-object.lua"

typeconf "example::Event"
typeconf "example::Callback::Listener"
typeconf "example::Callback"
    .func "setOnceEvent" .tag_scope "once"
    .func "foreach"
        .tag_mode "new"
        .tag_scope "invoker"
        .tag_maker "makeForeachTag(#1)"
