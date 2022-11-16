//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_types.h"
#include "olua-custom.h"

static int _olua_string_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::string *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.string");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) std::string get(unsigned int idx)
    std::string ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_std_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_string_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::string *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    std::string arg2;       /** v */

    olua_to_obj(L, 1, &self, "olua.string");
    olua_check_uint(L, 2, &arg1);
    olua_check_std_string(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const std::string &v)
    self->set((unsigned int)arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_string___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::string *)olua_toobj(L, 1, "olua.string");
    olua_push_obj(L, self, "olua.string");

    olua_endinvoke(L);

    return 1;
}

static int _olua_string_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<std::string> *array(size_t len)
    olua::pointer<std::string> *ret = olua::string::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.string");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_string_create(lua_State *L)
{
    olua_startinvoke(L);

    std::string arg1;       /** v */

    olua_check_std_string(L, 1, &arg1);

    // @name(new) static olua::pointer<std::string> *create(const std::string &v)
    olua::pointer<std::string> *ret = olua::string::create(arg1);
    int num_ret = olua_push_obj(L, ret, "olua.string");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_string_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::string *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.string");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_string_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::string *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.string");

    // @getter const std::string &value()
    const std::string &ret = self->value();
    int num_ret = olua_push_std_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_string(lua_State *L)
{
    oluacls_class(L, "olua.string", nullptr);
    oluacls_func(L, "__index", _olua_string_get);
    oluacls_func(L, "__newindex", _olua_string_set);
    oluacls_func(L, "__olua_move", _olua_string___olua_move);
    oluacls_func(L, "array", _olua_string_array);
    oluacls_func(L, "new", _olua_string_create);
    oluacls_prop(L, "length", _olua_string_length, nullptr);
    oluacls_prop(L, "value", _olua_string_value, nullptr);

    olua_registerluatype<olua::string>(L, "olua.string");

    return 1;
}
OLUA_END_DECLS

static int _olua_int8_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::int8_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.int8_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) int8_t get(unsigned int idx)
    int8_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int8_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::int8_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Integer arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.int8_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_int(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const int8_t &v)
    self->set((unsigned int)arg1, (int8_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_int8_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::int8_t *)olua_toobj(L, 1, "olua.int8_t");
    olua_push_obj(L, self, "olua.int8_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_int8_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<int8_t> *array(size_t len)
    olua::pointer<int8_t> *ret = olua::int8_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int8_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int8_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Integer arg1 = 0;       /** v */

    olua_check_int(L, 1, &arg1);

    // @name(new) static olua::pointer<int8_t> *create(const int8_t &v)
    olua::pointer<int8_t> *ret = olua::int8_t::create((int8_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int8_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int8_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::int8_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int8_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int8_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::int8_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int8_t");

    // @getter const int8_t &value()
    const int8_t &ret = self->value();
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_int8_t(lua_State *L)
{
    oluacls_class(L, "olua.int8_t", nullptr);
    oluacls_func(L, "__index", _olua_int8_t_get);
    oluacls_func(L, "__newindex", _olua_int8_t_set);
    oluacls_func(L, "__olua_move", _olua_int8_t___olua_move);
    oluacls_func(L, "array", _olua_int8_t_array);
    oluacls_func(L, "new", _olua_int8_t_create);
    oluacls_prop(L, "length", _olua_int8_t_length, nullptr);
    oluacls_prop(L, "value", _olua_int8_t_value, nullptr);

    olua_registerluatype<olua::int8_t>(L, "olua.int8_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_uint8_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint8_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.uint8_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) uint8_t get(unsigned int idx)
    uint8_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint8_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint8_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Unsigned arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.uint8_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_uint(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const uint8_t &v)
    self->set((unsigned int)arg1, (uint8_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_uint8_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::uint8_t *)olua_toobj(L, 1, "olua.uint8_t");
    olua_push_obj(L, self, "olua.uint8_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_uint8_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<uint8_t> *array(size_t len)
    olua::pointer<uint8_t> *ret = olua::uint8_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint8_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint8_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** v */

    olua_check_uint(L, 1, &arg1);

    // @name(new) static olua::pointer<uint8_t> *create(const uint8_t &v)
    olua::pointer<uint8_t> *ret = olua::uint8_t::create((uint8_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint8_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint8_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint8_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint8_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint8_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint8_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint8_t");

    // @getter const uint8_t &value()
    const uint8_t &ret = self->value();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_uint8_t(lua_State *L)
{
    oluacls_class(L, "olua.uint8_t", nullptr);
    oluacls_func(L, "__index", _olua_uint8_t_get);
    oluacls_func(L, "__newindex", _olua_uint8_t_set);
    oluacls_func(L, "__olua_move", _olua_uint8_t___olua_move);
    oluacls_func(L, "array", _olua_uint8_t_array);
    oluacls_func(L, "new", _olua_uint8_t_create);
    oluacls_prop(L, "length", _olua_uint8_t_length, nullptr);
    oluacls_prop(L, "value", _olua_uint8_t_value, nullptr);

    olua_registerluatype<olua::uint8_t>(L, "olua.uint8_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_int16_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::int16_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.int16_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) int16_t get(unsigned int idx)
    int16_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int16_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::int16_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Integer arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.int16_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_int(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const int16_t &v)
    self->set((unsigned int)arg1, (int16_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_int16_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::int16_t *)olua_toobj(L, 1, "olua.int16_t");
    olua_push_obj(L, self, "olua.int16_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_int16_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<int16_t> *array(size_t len)
    olua::pointer<int16_t> *ret = olua::int16_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int16_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int16_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Integer arg1 = 0;       /** v */

    olua_check_int(L, 1, &arg1);

    // @name(new) static olua::pointer<int16_t> *create(const int16_t &v)
    olua::pointer<int16_t> *ret = olua::int16_t::create((int16_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int16_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int16_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::int16_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int16_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int16_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::int16_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int16_t");

    // @getter const int16_t &value()
    const int16_t &ret = self->value();
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_int16_t(lua_State *L)
{
    oluacls_class(L, "olua.int16_t", nullptr);
    oluacls_func(L, "__index", _olua_int16_t_get);
    oluacls_func(L, "__newindex", _olua_int16_t_set);
    oluacls_func(L, "__olua_move", _olua_int16_t___olua_move);
    oluacls_func(L, "array", _olua_int16_t_array);
    oluacls_func(L, "new", _olua_int16_t_create);
    oluacls_prop(L, "length", _olua_int16_t_length, nullptr);
    oluacls_prop(L, "value", _olua_int16_t_value, nullptr);

    olua_registerluatype<olua::int16_t>(L, "olua.int16_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_uint16_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint16_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.uint16_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) uint16_t get(unsigned int idx)
    uint16_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint16_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint16_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Unsigned arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.uint16_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_uint(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const uint16_t &v)
    self->set((unsigned int)arg1, (uint16_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_uint16_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::uint16_t *)olua_toobj(L, 1, "olua.uint16_t");
    olua_push_obj(L, self, "olua.uint16_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_uint16_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<uint16_t> *array(size_t len)
    olua::pointer<uint16_t> *ret = olua::uint16_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint16_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint16_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** v */

    olua_check_uint(L, 1, &arg1);

    // @name(new) static olua::pointer<uint16_t> *create(const uint16_t &v)
    olua::pointer<uint16_t> *ret = olua::uint16_t::create((uint16_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint16_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint16_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint16_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint16_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint16_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint16_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint16_t");

    // @getter const uint16_t &value()
    const uint16_t &ret = self->value();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_uint16_t(lua_State *L)
{
    oluacls_class(L, "olua.uint16_t", nullptr);
    oluacls_func(L, "__index", _olua_uint16_t_get);
    oluacls_func(L, "__newindex", _olua_uint16_t_set);
    oluacls_func(L, "__olua_move", _olua_uint16_t___olua_move);
    oluacls_func(L, "array", _olua_uint16_t_array);
    oluacls_func(L, "new", _olua_uint16_t_create);
    oluacls_prop(L, "length", _olua_uint16_t_length, nullptr);
    oluacls_prop(L, "value", _olua_uint16_t_value, nullptr);

    olua_registerluatype<olua::uint16_t>(L, "olua.uint16_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_int32_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::int32_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.int32_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) int32_t get(unsigned int idx)
    int32_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int32_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::int32_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Integer arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.int32_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_int(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const int32_t &v)
    self->set((unsigned int)arg1, (int32_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_int32_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::int32_t *)olua_toobj(L, 1, "olua.int32_t");
    olua_push_obj(L, self, "olua.int32_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_int32_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<int32_t> *array(size_t len)
    olua::pointer<int32_t> *ret = olua::int32_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int32_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int32_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Integer arg1 = 0;       /** v */

    olua_check_int(L, 1, &arg1);

    // @name(new) static olua::pointer<int32_t> *create(const int32_t &v)
    olua::pointer<int32_t> *ret = olua::int32_t::create((int32_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int32_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int32_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::int32_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int32_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int32_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::int32_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int32_t");

    // @getter const int32_t &value()
    const int32_t &ret = self->value();
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_int32_t(lua_State *L)
{
    oluacls_class(L, "olua.int32_t", nullptr);
    oluacls_func(L, "__index", _olua_int32_t_get);
    oluacls_func(L, "__newindex", _olua_int32_t_set);
    oluacls_func(L, "__olua_move", _olua_int32_t___olua_move);
    oluacls_func(L, "array", _olua_int32_t_array);
    oluacls_func(L, "new", _olua_int32_t_create);
    oluacls_prop(L, "length", _olua_int32_t_length, nullptr);
    oluacls_prop(L, "value", _olua_int32_t_value, nullptr);

    olua_registerluatype<olua::int32_t>(L, "olua.int32_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_uint32_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint32_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.uint32_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) uint32_t get(unsigned int idx)
    uint32_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint32_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint32_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Unsigned arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.uint32_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_uint(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const uint32_t &v)
    self->set((unsigned int)arg1, (uint32_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_uint32_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::uint32_t *)olua_toobj(L, 1, "olua.uint32_t");
    olua_push_obj(L, self, "olua.uint32_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_uint32_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<uint32_t> *array(size_t len)
    olua::pointer<uint32_t> *ret = olua::uint32_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint32_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint32_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** v */

    olua_check_uint(L, 1, &arg1);

    // @name(new) static olua::pointer<uint32_t> *create(const uint32_t &v)
    olua::pointer<uint32_t> *ret = olua::uint32_t::create((uint32_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint32_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint32_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint32_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint32_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint32_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint32_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint32_t");

    // @getter const uint32_t &value()
    const uint32_t &ret = self->value();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_uint32_t(lua_State *L)
{
    oluacls_class(L, "olua.uint32_t", nullptr);
    oluacls_func(L, "__index", _olua_uint32_t_get);
    oluacls_func(L, "__newindex", _olua_uint32_t_set);
    oluacls_func(L, "__olua_move", _olua_uint32_t___olua_move);
    oluacls_func(L, "array", _olua_uint32_t_array);
    oluacls_func(L, "new", _olua_uint32_t_create);
    oluacls_prop(L, "length", _olua_uint32_t_length, nullptr);
    oluacls_prop(L, "value", _olua_uint32_t_value, nullptr);

    olua_registerluatype<olua::uint32_t>(L, "olua.uint32_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_int64_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::int64_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.int64_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) int64_t get(unsigned int idx)
    int64_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int64_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::int64_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Integer arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.int64_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_int(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const int64_t &v)
    self->set((unsigned int)arg1, (int64_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_int64_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::int64_t *)olua_toobj(L, 1, "olua.int64_t");
    olua_push_obj(L, self, "olua.int64_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_int64_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<int64_t> *array(size_t len)
    olua::pointer<int64_t> *ret = olua::int64_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int64_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int64_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Integer arg1 = 0;       /** v */

    olua_check_int(L, 1, &arg1);

    // @name(new) static olua::pointer<int64_t> *create(const int64_t &v)
    olua::pointer<int64_t> *ret = olua::int64_t::create((int64_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.int64_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int64_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::int64_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int64_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_int64_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::int64_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.int64_t");

    // @getter const int64_t &value()
    const int64_t &ret = self->value();
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_int64_t(lua_State *L)
{
    oluacls_class(L, "olua.int64_t", nullptr);
    oluacls_func(L, "__index", _olua_int64_t_get);
    oluacls_func(L, "__newindex", _olua_int64_t_set);
    oluacls_func(L, "__olua_move", _olua_int64_t___olua_move);
    oluacls_func(L, "array", _olua_int64_t_array);
    oluacls_func(L, "new", _olua_int64_t_create);
    oluacls_prop(L, "length", _olua_int64_t_length, nullptr);
    oluacls_prop(L, "value", _olua_int64_t_value, nullptr);

    olua_registerluatype<olua::int64_t>(L, "olua.int64_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_uint64_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint64_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.uint64_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) uint64_t get(unsigned int idx)
    uint64_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint64_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint64_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Unsigned arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.uint64_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_uint(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const uint64_t &v)
    self->set((unsigned int)arg1, (uint64_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_uint64_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::uint64_t *)olua_toobj(L, 1, "olua.uint64_t");
    olua_push_obj(L, self, "olua.uint64_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_uint64_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<uint64_t> *array(size_t len)
    olua::pointer<uint64_t> *ret = olua::uint64_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint64_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint64_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** v */

    olua_check_uint(L, 1, &arg1);

    // @name(new) static olua::pointer<uint64_t> *create(const uint64_t &v)
    olua::pointer<uint64_t> *ret = olua::uint64_t::create((uint64_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.uint64_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint64_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint64_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint64_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_uint64_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::uint64_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.uint64_t");

    // @getter const uint64_t &value()
    const uint64_t &ret = self->value();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_uint64_t(lua_State *L)
{
    oluacls_class(L, "olua.uint64_t", nullptr);
    oluacls_func(L, "__index", _olua_uint64_t_get);
    oluacls_func(L, "__newindex", _olua_uint64_t_set);
    oluacls_func(L, "__olua_move", _olua_uint64_t___olua_move);
    oluacls_func(L, "array", _olua_uint64_t_array);
    oluacls_func(L, "new", _olua_uint64_t_create);
    oluacls_prop(L, "length", _olua_uint64_t_length, nullptr);
    oluacls_prop(L, "value", _olua_uint64_t_value, nullptr);

    olua_registerluatype<olua::uint64_t>(L, "olua.uint64_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_float_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::float_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.float_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) float get(unsigned int idx)
    float ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_number(L, (lua_Number)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_float_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::float_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Number arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.float_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_number(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const float &v)
    self->set((unsigned int)arg1, (float)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_float_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::float_t *)olua_toobj(L, 1, "olua.float_t");
    olua_push_obj(L, self, "olua.float_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_float_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<float> *array(size_t len)
    olua::pointer<float> *ret = olua::float_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.float_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_float_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Number arg1 = 0;       /** v */

    olua_check_number(L, 1, &arg1);

    // @name(new) static olua::pointer<float> *create(const float &v)
    olua::pointer<float> *ret = olua::float_t::create((float)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.float_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_float_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::float_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.float_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_float_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::float_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.float_t");

    // @getter const float &value()
    const float &ret = self->value();
    int num_ret = olua_push_number(L, (lua_Number)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_float_t(lua_State *L)
{
    oluacls_class(L, "olua.float_t", nullptr);
    oluacls_func(L, "__index", _olua_float_t_get);
    oluacls_func(L, "__newindex", _olua_float_t_set);
    oluacls_func(L, "__olua_move", _olua_float_t___olua_move);
    oluacls_func(L, "array", _olua_float_t_array);
    oluacls_func(L, "new", _olua_float_t_create);
    oluacls_prop(L, "length", _olua_float_t_length, nullptr);
    oluacls_prop(L, "value", _olua_float_t_value, nullptr);

    olua_registerluatype<olua::float_t>(L, "olua.float_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_double_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::double_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.double_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) double get(unsigned int idx)
    double ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_number(L, (lua_Number)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_double_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::double_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Number arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.double_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_number(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const double &v)
    self->set((unsigned int)arg1, (double)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_double_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::double_t *)olua_toobj(L, 1, "olua.double_t");
    olua_push_obj(L, self, "olua.double_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_double_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<double> *array(size_t len)
    olua::pointer<double> *ret = olua::double_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.double_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_double_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Number arg1 = 0;       /** v */

    olua_check_number(L, 1, &arg1);

    // @name(new) static olua::pointer<double> *create(const double &v)
    olua::pointer<double> *ret = olua::double_t::create((double)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.double_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_double_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::double_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.double_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_double_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::double_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.double_t");

    // @getter const double &value()
    const double &ret = self->value();
    int num_ret = olua_push_number(L, (lua_Number)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_double_t(lua_State *L)
{
    oluacls_class(L, "olua.double_t", nullptr);
    oluacls_func(L, "__index", _olua_double_t_get);
    oluacls_func(L, "__newindex", _olua_double_t_set);
    oluacls_func(L, "__olua_move", _olua_double_t___olua_move);
    oluacls_func(L, "array", _olua_double_t_array);
    oluacls_func(L, "new", _olua_double_t_create);
    oluacls_prop(L, "length", _olua_double_t_length, nullptr);
    oluacls_prop(L, "value", _olua_double_t_value, nullptr);

    olua_registerluatype<olua::double_t>(L, "olua.double_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_long_double_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::long_double_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.long_double_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) long double get(unsigned int idx)
    long double ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_number(L, (lua_Number)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_long_double_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::long_double_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Number arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.long_double_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_number(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const long double &v)
    self->set((unsigned int)arg1, (long double)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_long_double_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::long_double_t *)olua_toobj(L, 1, "olua.long_double_t");
    olua_push_obj(L, self, "olua.long_double_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_long_double_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<long double> *array(size_t len)
    olua::pointer<long double> *ret = olua::long_double_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.long_double_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_long_double_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Number arg1 = 0;       /** v */

    olua_check_number(L, 1, &arg1);

    // @name(new) static olua::pointer<long double> *create(const long double &v)
    olua::pointer<long double> *ret = olua::long_double_t::create((long double)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.long_double_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_long_double_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::long_double_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.long_double_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_long_double_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::long_double_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.long_double_t");

    // @getter const long double &value()
    const long double &ret = self->value();
    int num_ret = olua_push_number(L, (lua_Number)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_long_double_t(lua_State *L)
{
    oluacls_class(L, "olua.long_double_t", nullptr);
    oluacls_func(L, "__index", _olua_long_double_t_get);
    oluacls_func(L, "__newindex", _olua_long_double_t_set);
    oluacls_func(L, "__olua_move", _olua_long_double_t___olua_move);
    oluacls_func(L, "array", _olua_long_double_t_array);
    oluacls_func(L, "new", _olua_long_double_t_create);
    oluacls_prop(L, "length", _olua_long_double_t_length, nullptr);
    oluacls_prop(L, "value", _olua_long_double_t_value, nullptr);

    olua_registerluatype<olua::long_double_t>(L, "olua.long_double_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_size_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::size_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.size_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) size_t get(unsigned int idx)
    size_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_size_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::size_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Unsigned arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.size_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_uint(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const size_t &v)
    self->set((unsigned int)arg1, (size_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_size_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::size_t *)olua_toobj(L, 1, "olua.size_t");
    olua_push_obj(L, self, "olua.size_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_size_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<size_t> *array(size_t len)
    olua::pointer<size_t> *ret = olua::size_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.size_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_size_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** v */

    olua_check_uint(L, 1, &arg1);

    // @name(new) static olua::pointer<size_t> *create(const size_t &v)
    olua::pointer<size_t> *ret = olua::size_t::create((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.size_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_size_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::size_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.size_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_size_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::size_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.size_t");

    // @getter const size_t &value()
    const size_t &ret = self->value();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_size_t(lua_State *L)
{
    oluacls_class(L, "olua.size_t", nullptr);
    oluacls_func(L, "__index", _olua_size_t_get);
    oluacls_func(L, "__newindex", _olua_size_t_set);
    oluacls_func(L, "__olua_move", _olua_size_t___olua_move);
    oluacls_func(L, "array", _olua_size_t_array);
    oluacls_func(L, "new", _olua_size_t_create);
    oluacls_prop(L, "length", _olua_size_t_length, nullptr);
    oluacls_prop(L, "value", _olua_size_t_value, nullptr);

    olua_registerluatype<olua::size_t>(L, "olua.size_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_ssize_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::ssize_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.ssize_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) ssize_t get(unsigned int idx)
    ssize_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_ssize_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::ssize_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Integer arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.ssize_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_int(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const ssize_t &v)
    self->set((unsigned int)arg1, (ssize_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_ssize_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::ssize_t *)olua_toobj(L, 1, "olua.ssize_t");
    olua_push_obj(L, self, "olua.ssize_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_ssize_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<ssize_t> *array(size_t len)
    olua::pointer<ssize_t> *ret = olua::ssize_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.ssize_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_ssize_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Integer arg1 = 0;       /** v */

    olua_check_int(L, 1, &arg1);

    // @name(new) static olua::pointer<ssize_t> *create(const ssize_t &v)
    olua::pointer<ssize_t> *ret = olua::ssize_t::create((ssize_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.ssize_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_ssize_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::ssize_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.ssize_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_ssize_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::ssize_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.ssize_t");

    // @getter const ssize_t &value()
    const ssize_t &ret = self->value();
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_ssize_t(lua_State *L)
{
    oluacls_class(L, "olua.ssize_t", nullptr);
    oluacls_func(L, "__index", _olua_ssize_t_get);
    oluacls_func(L, "__newindex", _olua_ssize_t_set);
    oluacls_func(L, "__olua_move", _olua_ssize_t___olua_move);
    oluacls_func(L, "array", _olua_ssize_t_array);
    oluacls_func(L, "new", _olua_ssize_t_create);
    oluacls_prop(L, "length", _olua_ssize_t_length, nullptr);
    oluacls_prop(L, "value", _olua_ssize_t_value, nullptr);

    olua_registerluatype<olua::ssize_t>(L, "olua.ssize_t");

    return 1;
}
OLUA_END_DECLS

static int _olua_time_t_get(lua_State *L)
{
    olua_startinvoke(L);

    olua::time_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */

    olua_to_obj(L, 1, &self, "olua.time_t");
    olua_check_uint(L, 2, &arg1);

    // @name(__index) time_t get(unsigned int idx)
    time_t ret = self->get((unsigned int)arg1);
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_time_t_set(lua_State *L)
{
    olua_startinvoke(L);

    olua::time_t *self = nullptr;
    lua_Unsigned arg1 = 0;       /** idx */
    lua_Integer arg2 = 0;       /** v */

    olua_to_obj(L, 1, &self, "olua.time_t");
    olua_check_uint(L, 2, &arg1);
    olua_check_int(L, 3, &arg2);

    // @name(__newindex) void set(unsigned int idx, const time_t &v)
    self->set((unsigned int)arg1, (time_t)arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_time_t___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (olua::time_t *)olua_toobj(L, 1, "olua.time_t");
    olua_push_obj(L, self, "olua.time_t");

    olua_endinvoke(L);

    return 1;
}

static int _olua_time_t_array(lua_State *L)
{
    olua_startinvoke(L);

    lua_Unsigned arg1 = 0;       /** len */

    olua_check_uint(L, 1, &arg1);

    // static olua::pointer<time_t> *array(size_t len)
    olua::pointer<time_t> *ret = olua::time_t::array((size_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.time_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_time_t_create(lua_State *L)
{
    olua_startinvoke(L);

    lua_Integer arg1 = 0;       /** v */

    olua_check_int(L, 1, &arg1);

    // @name(new) static olua::pointer<time_t> *create(const time_t &v)
    olua::pointer<time_t> *ret = olua::time_t::create((time_t)arg1);
    int num_ret = olua_push_obj(L, ret, "olua.time_t");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_time_t_length(lua_State *L)
{
    olua_startinvoke(L);

    olua::time_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.time_t");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_time_t_value(lua_State *L)
{
    olua_startinvoke(L);

    olua::time_t *self = nullptr;

    olua_to_obj(L, 1, &self, "olua.time_t");

    // @getter const time_t &value()
    const time_t &ret = self->value();
    int num_ret = olua_push_int(L, (lua_Integer)ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_olua_time_t(lua_State *L)
{
    oluacls_class(L, "olua.time_t", nullptr);
    oluacls_func(L, "__index", _olua_time_t_get);
    oluacls_func(L, "__newindex", _olua_time_t_set);
    oluacls_func(L, "__olua_move", _olua_time_t___olua_move);
    oluacls_func(L, "array", _olua_time_t_array);
    oluacls_func(L, "new", _olua_time_t_create);
    oluacls_prop(L, "length", _olua_time_t_length, nullptr);
    oluacls_prop(L, "value", _olua_time_t_value, nullptr);

    olua_registerluatype<olua::time_t>(L, "olua.time_t");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_types(lua_State *L)
{
    olua_require(L, "olua.string", luaopen_olua_string);
    olua_require(L, "olua.int8_t", luaopen_olua_int8_t);
    olua_require(L, "olua.uint8_t", luaopen_olua_uint8_t);
    olua_require(L, "olua.int16_t", luaopen_olua_int16_t);
    olua_require(L, "olua.uint16_t", luaopen_olua_uint16_t);
    olua_require(L, "olua.int32_t", luaopen_olua_int32_t);
    olua_require(L, "olua.uint32_t", luaopen_olua_uint32_t);
    olua_require(L, "olua.int64_t", luaopen_olua_int64_t);
    olua_require(L, "olua.uint64_t", luaopen_olua_uint64_t);
    olua_require(L, "olua.float_t", luaopen_olua_float_t);
    olua_require(L, "olua.double_t", luaopen_olua_double_t);
    olua_require(L, "olua.long_double_t", luaopen_olua_long_double_t);
    olua_require(L, "olua.size_t", luaopen_olua_size_t);
    olua_require(L, "olua.ssize_t", luaopen_olua_ssize_t);
    olua_require(L, "olua.time_t", luaopen_olua_time_t);

    return 0;
}
OLUA_END_DECLS
