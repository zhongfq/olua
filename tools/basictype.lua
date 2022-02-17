local olua = require "olua"
local typedef = olua.typedef

typedef {
    cppcls = 'void',
    conv = '<NONE>',
}

typedef {
    cppcls = [[
        void *
        GLvoid *
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
        uint8_t *
        char *
        const char *
        unsigned char *
        const unsigned char *
        const GLchar *
    ]],
    decltype = 'const char *',
    conv = 'olua_$$_string',
}

typedef {
    cppcls = 'std::string',
    conv = 'olua_$$_std_string',
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
        float
        double
        GLfloat
        lua_Number
    ]],
    decltype = 'lua_Number',
    conv = 'olua_$$_number',
}

typedef {
    cppcls = [[
        byte
        GLint
        GLshort
        GLsizei
        ssize_t
        int8_t
        int16_t
        int32_t
        int64_t
        std::int8_t
        std::int16_t
        std::int32_t
        std::int64_t
        char
        signed char
        short
        short int
        signed short
        signed short int
        int
        signed
        signed int
        long
        long int
        signed long
        signed long int
        long long
        long long int
        signed long long
        signed long long int
        lua_Integer
    ]],
    decltype = 'lua_Integer',
    conv = 'olua_$$_int',
}

typedef {
    cppcls = [[
        GLboolean
        GLenum
        GLubyte
        GLuint
        size_t
        std::size_t
        std::string::size_type
        uint8_t
        uint16_t
        uint32_t
        uint64_t
        uintptr_t
        std::uint8_t
        std::uint16_t
        std::uint32_t
        std::uint64_t
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
