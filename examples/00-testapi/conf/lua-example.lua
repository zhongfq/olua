---@format disable

module "example"

output_dir "src"

api_dir "../../addons/example"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

exclude_type "example::ExcludeType"

import "../common/lua-object.lua"

typeconf "example::VectorInt"
typeconf "example::VectorPoint"
typeconf "example::VectorString"
typeconf "example::PointArray"

typeconf "example::ClickCallback"
typeconf "example::Type"
typeconf "example::Point"
    .from_table "true"
    .packable "true"
typeconf "example::Hello"
    .func "convertPoint" .arg1 "@pack"
    .macro "#ifdef TEST_OLUA_MACRO"
    .func "testMacro"
    .macro "#endif"
typeconf "example::Const"
typeconf "example::SharedHello"
typeconf "example::NoGC"

typeconf "example::PointIterator"
    .iterator "example::PointIterator::Iterator"
typeconf "example::IntIterator"
    .iterator "example::IntIterator::Iterator"
