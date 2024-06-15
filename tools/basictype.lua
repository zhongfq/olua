local olua = require "olua"

local function typedef(t)
    t.from = 'olua: basictype'
    olua.typedef(t)
end

typedef {
    cppcls = 'void',
    conv = '<NONE>',
    luatype = 'nil',
}

typedef {
    cppcls = 'void *',
    luacls = 'void *',
    conv = 'olua_$$_object',
    luatype = 'any',
}

typedef {
    cppcls = 'olua_Return',
    conv = '<NONE>',
}

typedef {
    cppcls = 'lua_State',
    luacls = 'lua_State',
    conv = '<NONE>',
}

typedef {
    cppcls = 'bool',
    conv = 'olua_$$_bool',
    luatype = 'boolean',
}

typedef {
    cppcls = [[
        char *
        const char *
        unsigned char *
        const unsigned char *
    ]],
    conv = 'olua_$$_string',
    luatype = 'string',
}

typedef {
    cppcls = 'std::string',
    conv = 'olua_$$_string',
    luatype = 'string',
}

typedef {
    cppcls = 'std::string_view',
    conv = 'olua_$$_string',
    luatype = 'string',
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
    luatype = 'map',
}

typedef {
    cppcls = [[
        std::set
        std::vector
    ]],
    conv = 'olua_$$_array',
    luatype = 'array',
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
    luatype = 'number',
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
    luatype = 'number',
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
    luatype = 'number',
}
