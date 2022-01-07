typeconf "example::Object"
    .exclude "retain"
    .exclude "release"
    .func('__gc', [[
    {
        return xlua_objgc(L);
    }]])