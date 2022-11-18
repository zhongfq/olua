luacls(function (name)
    return name:gsub('olua_', 'olua.')
end)

typedef 'short int *'
    .luacls 'olua.short'
    .conv 'olua_$$_pointer'

typedef 'unsigned short int *'
    .luacls 'olua.ushort'
    .conv 'olua_$$_pointer'

typedef 'unsigned *'
    .luacls 'olua.uint'
    .conv 'olua_$$_pointer'

typedef 'long int *'
    .luacls 'olua.long'
    .conv 'olua_$$_pointer'

typedef 'unsigned long int *'
    .luacls 'olua.ulong'
    .conv 'olua_$$_pointer'

typedef 'long long int *'
    .luacls 'olua.llong'
    .conv 'olua_$$_pointer'

typedef 'unsigned long long int *'
    .luacls 'olua.ullong'
    .conv 'olua_$$_pointer'

typeconf 'olua_bool'
typeconf 'olua_string'
typeconf 'olua_int8'
typeconf 'olua_uint8'
typeconf 'olua_int16'
typeconf 'olua_uint16'
typeconf 'olua_int32'
typeconf 'olua_uint32'
typeconf 'olua_int64'
typeconf 'olua_uint64'
typeconf 'olua_short'
typeconf 'olua_ushort'
typeconf 'olua_int'
typeconf 'olua_uint'
typeconf 'olua_long'
typeconf 'olua_ulong'
typeconf 'olua_llong'
typeconf 'olua_ullong'
typeconf 'olua_float'
typeconf 'olua_double'
typeconf 'olua_ldouble'
typeconf 'olua_size_t'
typeconf 'olua_ssize_t'
typeconf 'olua_time_t'