local olua = require "olua"
local typedef = olua.typedef

typedef {
    cppcls = 'void',
    conv = '<NONE>',
}

typedef {
    cppcls = 'olua_Return',
    conv = '<NONE>',
}

typedef {
    cppcls = 'lua_State',
    conv = 'olua_$$_object',
}

typedef {
    cppcls = 'void *',
    luacls = 'void *',
    conv = 'olua_$$_object',
}

typedef {
    cppcls = 'bool',
    conv = 'olua_$$_bool',
}

typedef {
    cppcls = [[
        char *
        const char *
        unsigned char *
        const unsigned char *
    ]],
    conv = 'olua_$$_string',
}

typedef {
    cppcls = 'std::string',
    conv = 'olua_$$_string',
}

typedef {
    cppcls = 'std::string_view',
    conv = 'olua_$$_string',
}

typedef {
    cppcls = 'std::function',
    luacls = 'std.function',
    conv = 'olua_$$_callback',
}

typedef {
    cppcls = [[
        std::unordered_map
        std::map
    ]],
    conv = 'olua_$$_map',
}

typedef {
    cppcls = [[
        std::set
        std::vector
    ]],
    conv = 'olua_$$_array',
}

typedef {
    cppcls = [[
        std::shared_ptr
        std::weak_ptr
    ]],
    smartptr = true,
    conv = 'olua_$$_object',
}

typedef {
    cppcls = [[
        float
        double
        long double
        lua_Number
    ]],
    conv = 'olua_$$_number',
}

typedef {
    cppcls = [[
        intptr_t
        ssize_t
        time_t
        char
        short
        short int
        int
        long
        long int
        long long
        long long int
        signed char
        signed short
        signed short int
        signed
        signed int
        signed long
        signed long int
        signed long long
        signed long long int
        lua_Integer
    ]],
    conv = 'olua_$$_integer',
}

typedef {
    cppcls = [[
        uintptr_t
        size_t
        unsigned char
        unsigned short
        unsigned short int
        unsigned
        unsigned int
        unsigned long
        unsigned long int
        unsigned long long
        unsigned long long int
        lua_Unsigned
    ]],
    conv = 'olua_$$_integer',
}
