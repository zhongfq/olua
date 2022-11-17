luacls(function (name)
    return name:gsub('olua_', 'olua.')
end)

typeconf 'olua_string'
typedef 'std::string *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.string'

typeconf 'olua_int8_t'
typedef 'int8_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int8_t'

typeconf 'olua_uint8_t'
typedef 'uint8_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint8_t'

typeconf 'olua_int16_t'
typedef 'int16_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int16_t'

typeconf 'olua_uint16_t'
typedef 'uint16_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint16_t'

typeconf 'olua_int32_t'
typedef 'int32_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int32_t'

typeconf 'olua_uint32_t'
typedef 'uint32_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint32_t'

typeconf 'olua_int64_t'
typedef 'int64_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int64_t'

typeconf 'olua_uint64_t'
typedef 'uint64_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint64_t'

typeconf 'olua_float_t'
typedef 'float_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.float_t'

typeconf 'olua_double_t'
typedef 'double_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.double_t'

typeconf 'olua_long_double_t'
typedef 'long_double_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.long_double_t'

typeconf 'olua_size_t'
typedef 'size_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.size_t'

typeconf 'olua_ssize_t'
typedef 'ssize_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.ssize_t'

typeconf 'olua_time_t'
typedef 'time_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.time_t'