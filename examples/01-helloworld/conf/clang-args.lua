clang {
    headers = [[
        #include "Hello.h"
    ]],
    flags = {
        '-DOLUA_DEBUG',
        '-Isrc',
        '-I../common',
        '-I../..',
    },
}