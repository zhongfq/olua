luacls(function (name)
    return name:gsub('olua_', 'olua.')
end)

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
typeconf 'olua_float'
typeconf 'olua_double'
typeconf 'olua_long_double'
typeconf 'olua_size_t'
typeconf 'olua_ssize_t'
typeconf 'olua_time_t'