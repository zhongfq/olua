local olua = require "olua"
local typedef = olua.typedef

typedef {
    CPPCLS = 'void',
    CONV = '<NONE>',
}

typedef {
    CPPCLS = [[
        void *
        GLvoid *
    ]],
    LUACLS = 'void *',
    CONV = 'olua_$$_obj',
}

typedef {
    CPPCLS = 'bool',
    CONV = 'olua_$$_bool',
}

typedef {
    CPPCLS = [[
        uint8_t *
        char *
        const char *
        unsigned char *
        const unsigned char *
        const GLchar *
    ]],
    DECLTYPE = 'const char *',
    CONV = 'olua_$$_string',
}

typedef {
    CPPCLS = 'std::string',
    CONV = 'olua_$$_std_string',
}

typedef {
    CPPCLS = 'std::function',
    CONV = 'olua_$$_std_function',
}

typedef {
    CPPCLS = 'std::unordered_map',
    CONV = 'olua_$$_std_unordered_map',
}

typedef {
    CPPCLS = 'std::map',
    CONV = 'olua_$$_std_map',
}

typedef {
    CPPCLS = 'std::set',
    CONV = 'olua_$$_std_set',
}

typedef {
    CPPCLS = 'std::vector',
    CONV = 'olua_$$_std_vector',
}

typedef {
    CPPCLS = [[
        float
        double
        GLfloat
        lua_Number
    ]],
    DECLTYPE = 'lua_Number',
    CONV = 'olua_$$_number',
}

typedef {
    CPPCLS = [[
        char
        GLint
        GLshort
        GLsizei
        int
        long
        short
        ssize_t
        int8_t
        int16_t
        int32_t
        int64_t
        std::int32_t
        lua_Integer
    ]],
    DECLTYPE = 'lua_Integer',
    CONV = 'olua_$$_int',
}

typedef {
    CPPCLS = [[
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
        unsigned char
        unsigned int
        unsigned short
        unsigned long
        lua_Unsigned
    ]],
    DECLTYPE = 'lua_Unsigned',
    CONV = 'olua_$$_uint',
}
