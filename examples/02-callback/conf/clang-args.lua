clang {
    headers = [[
        #include "Callback.h"
    ]],
    flags = {
        '-DOLUA_DEBUG',
        '-Isrc',
        '-I../common',
        '-I../..',
    },
}