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
    cppcls = 'lua_State *',
    conv = 'olua_$$_obj',
}

typedef {
    cppcls = [[
        void *
    ]],
    luacls = 'void *',
    conv = 'olua_$$_obj',
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
    decltype = 'const char *',
    conv = 'olua_$$_string',
}

typedef {
    cppcls = 'std::string',
    conv = 'olua_$$_std_string',
}

typedef {
    cppcls = 'std::string_view',
    conv = 'olua_$$_std_string_view',
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
    conv = 'olua_$$_obj',
}

typedef {
    cppcls = [[
        float
        double
        long double
        lua_Number
    ]],
    decltype = 'lua_Number',
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
    decltype = 'lua_Integer',
    conv = 'olua_$$_int',
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
    decltype = 'lua_Unsigned',
    conv = 'olua_$$_uint',
}
