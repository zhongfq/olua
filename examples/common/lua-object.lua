typeconf "example::Object"
    .exclude "retain"
    .exclude "release"
    .func "__gc"
    .body [[
            return olua_objgc(L);
        ]]
