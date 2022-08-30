typeconf "example::Object"
    .exclude "retain"
    .exclude "release"
    .func'__gc'
        .snippet [[
        {
            return olua_objgc(L);
        }]]