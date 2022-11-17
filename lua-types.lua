luacls(function (name)
    return name:gsub('olua_', 'olua.')
end)

typeconf 'olua_bool'
typedef 'bool *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.bool'

typeconf 'olua_string'
typedef 'std::string *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.string'

typeconf 'olua_int8'
typedef 'int8_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int8'

typeconf 'olua_uint8'
typedef 'uint8_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint8'

typeconf 'olua_int16'
typedef 'int16_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int16'

typeconf 'olua_uint16'
typedef 'uint16_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint16'

typeconf 'olua_int32'
typedef 'int32_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int32'

typeconf 'olua_uint32'
typedef 'uint32_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint32'

typeconf 'olua_int64'
typedef 'int64_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.int64'

typeconf 'olua_uint64'
typedef 'uint64_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.uint64'

typeconf 'olua_float'
typedef 'float_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.float'

typeconf 'olua_double'
typedef 'double_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.double'

typeconf 'olua_long_double'
typedef 'long_double_t *'
    .conv 'olua_$$_pointer'
    .luacls 'olua.long_double'

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