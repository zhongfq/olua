local olua = require "olua"
local typedef = olua.typedef

typedef {
    from = 'olua: basictype',
    cppcls = 'void',
    conv = '<NONE>',
}

typedef {
    from = 'olua: basictype',
    cppcls = 'void *',
    luacls = 'void *',
    conv = 'olua_$$_object',
}

typedef {
    from = 'olua: basictype',
    cppcls = 'olua_Return',
    conv = '<NONE>',
}

typedef {
    from = 'olua: basictype',
    cppcls = 'lua_State',
    luacls = 'lua_State',
    conv = '<NONE>',
}

typedef {
    from = 'olua: basictype',
    cppcls = 'bool',
    conv = 'olua_$$_bool',
}

typedef {
    from = 'olua: basictype',
    cppcls = [[
        char *
        const char *
        unsigned char *
        const unsigned char *
    ]],
    conv = 'olua_$$_string',
}

typedef {
    from = 'olua: basictype',
    cppcls = 'std::string',
    conv = 'olua_$$_string',
}

typedef {
    from = 'olua: basictype',
    cppcls = 'std::string_view',
    conv = 'olua_$$_string',
}

typedef {
    from = 'olua: basictype',
    cppcls = 'std::function',
    luacls = 'std.function',
    conv = 'olua_$$_callback',
}

typedef {
    from = 'olua: basictype',
    cppcls = [[
        std::unordered_map
        std::map
    ]],
    conv = 'olua_$$_map',
}

typedef {
    from = 'olua: basictype',
    cppcls = [[
        std::set
        std::vector
    ]],
    conv = 'olua_$$_vector',
}

typedef {
    from = 'olua: basictype',
    cppcls = [[
        std::shared_ptr
        std::weak_ptr
    ]],
    smartptr = true,
    conv = 'olua_$$_object',
}

typedef {
    from = 'olua: basictype',
    cppcls = [[
        float
        double
        long double
        lua_Number
    ]],
    conv = 'olua_$$_number',
}

typedef {
    from = 'olua: basictype',
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
    from = 'olua: basictype',
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
