clang {
    headers = [[
        #include "Convertor.h"
    ]],
    flags = {
        '-DOLUA_DEBUG',
        '-Isrc',
        '-I../common',
        '-I../lua',
        '-I../..',
    },
}