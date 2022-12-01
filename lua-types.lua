luacls(function (name)
    return name:gsub('olua_', 'olua.')
end)

typedef 'short *;short int *'
    .luacls 'olua.short'
    .conv 'olua_$$_array'

typedef 'unsigned short *;unsigned short int *'
    .luacls 'olua.ushort'
    .conv 'olua_$$_array'

typedef 'signed *;int *'
    .luacls 'olua.int'
    .conv 'olua_$$_array'

typedef 'unsigned *;unsigned int *'
    .luacls 'olua.uint'
    .conv 'olua_$$_array'

typedef 'long *;long int *'
    .luacls 'olua.long'
    .conv 'olua_$$_array'

typedef 'unsigned long *;unsigned long int *'
    .luacls 'olua.ulong'
    .conv 'olua_$$_array'

typedef 'long long *;long long int *'
    .luacls 'olua.llong'
    .conv 'olua_$$_array'

typedef 'unsigned long long *;unsigned long long int *'
    .luacls 'olua.ullong'
    .conv 'olua_$$_array'

typedef 'float *'
    .luacls 'olua.float'
    .conv 'olua_$$_array'

typedef 'double *'
    .luacls 'olua.double'
    .conv 'olua_$$_array'

typedef 'long double *'
    .luacls 'olua.ldouble'
    .conv 'olua_$$_array'

typeconf 'olua_bool'
typeconf 'olua_string'
typeconf 'olua_int8_t'
typeconf 'olua_int16_t'
typeconf 'olua_int32_t'
typeconf 'olua_int64_t'
typeconf 'olua_uint8_t'
typeconf 'olua_uint16_t'
typeconf 'olua_uint32_t'
typeconf 'olua_uint64_t'
typeconf 'olua_char'
typeconf 'olua_short'
typeconf 'olua_int'
typeconf 'olua_long'
typeconf 'olua_llong'
typeconf 'olua_uchar'
typeconf 'olua_ushort'
typeconf 'olua_uint'
typeconf 'olua_ulong'
typeconf 'olua_ullong'
typeconf 'olua_float'
typeconf 'olua_double'
typeconf 'olua_ldouble'
typeconf 'olua_size_t'
typeconf 'olua_ssize_t'
