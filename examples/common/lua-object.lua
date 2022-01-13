typeconf "example::Object"
    .exclude "retain"
    .exclude "release"
    .func'__gc'
        .snippet [[
        {
            return xlua_objgc(L);
        }]]