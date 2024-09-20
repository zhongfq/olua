local function typedef(t)
    t.from = "olua: basictype"
    olua.typedef(t)
end

typedef {
    cxxcls = "void",
    conv = "<NONE>",
    luatype = "nil",
}

typedef {
    cxxcls = "void *",
    luacls = "void *",
    conv = "olua_$$_object",
    luatype = "any",
}

typedef {
    cxxcls = "olua_Return",
    conv = "<NONE>",
}

typedef {
    cxxcls = [[
        std::strong_ordering
        std::partial_ordering
        std::weak_ordering
    ]],
    conv = "<NONE>",
}

typedef {
    cxxcls = "lua_State",
    luacls = "lua_State",
    conv = "<NONE>",
}

typedef {
    cxxcls = "bool",
    conv = "olua_$$_bool",
    luatype = "boolean",
}

typedef {
    cxxcls = [[
        char *
        const char *
        unsigned char *
        const unsigned char *
    ]],
    conv = "olua_$$_string",
    luatype = "string",
}

typedef {
    cxxcls = [[
        std::string
        std::string_view
    ]],
    conv = "olua_$$_string",
    luatype = "string",
}

typedef {
    cxxcls = "std::function",
    luacls = "std.function",
    conv = "olua_$$_callback",
}

typedef {
    cxxcls = [[
        std::unordered_map
        std::map
    ]],
    conv = "olua_$$_map",
    luatype = "map",
}

typedef {
    cxxcls = [[
        std::set
        std::vector
        std::deque
    ]],
    conv = "olua_$$_array",
    luatype = "array",
}

typedef {
    cxxcls = [[
        std::shared_ptr
        std::weak_ptr
    ]],
    smartptr = true,
    conv = "olua_$$_smartptr",
}

typedef {
    cxxcls = [[
        float
        double
        long double
        lua_Number
    ]],
    conv = "olua_$$_number",
    luatype = "number",
}

typedef {
    cxxcls = [[
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
        int8_t
        int16_t
        int32_t
        int64_t
    ]],
    conv = "olua_$$_integer",
    luatype = "integer",
}

typedef {
    cxxcls = [[
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
        uint8_t
        uint16_t
        uint32_t
        uint64_t
    ]],
    conv = "olua_$$_integer",
    luatype = "integer",
}
