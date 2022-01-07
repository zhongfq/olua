clang {
    headers = [[
        #include "Example.h"
    ]],
    flags = {
        '-DOLUA_DEBUG',
        '-Isrc',
        '-I../common',
        '-I../..',
    },
}