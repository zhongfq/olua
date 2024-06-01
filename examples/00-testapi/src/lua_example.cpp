//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"


OLUA_LIB void olua_pack_object(lua_State *L, int idx, example::Point *value)
{
    idx = lua_absindex(L, idx);

    float arg1 = 0;       /** x */
    float arg2 = 0;       /** y */

    olua_check_number(L, idx + 0, &arg1);
    value->x = arg1;

    olua_check_number(L, idx + 1, &arg2);
    value->y = arg2;
}

OLUA_LIB int olua_unpack_object(lua_State *L, const example::Point *value)
{
    olua_push_number(L, value->x);
    olua_push_number(L, value->y);

    return 2;
}

OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const example::Point *)
{
    return olua_is_number(L, idx + 0) && olua_is_number(L, idx + 1);
}

static int _example_Object___gc(lua_State *L)
{
    olua_startinvoke(L);

    olua_endinvoke(L);

    return olua_objgc(L);
}

static int _example_Object___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Object *)olua_toobj(L, 1, "example.Object");
    olua_push_object(L, self, "example.Object");

    olua_endinvoke(L);

    return 1;
}

static int _example_Object_autorelease(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_object(L, 1, &self, "example.Object");

    // example::Object *autorelease()
    example::Object *ret = self->autorelease();
    int num_ret = olua_push_object(L, ret, "example.Object");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_getReferenceCount(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_object(L, 1, &self, "example.Object");

    // unsigned int getReferenceCount()
    unsigned int ret = self->getReferenceCount();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_new(lua_State *L)
{
    olua_startinvoke(L);

    // Object()
    example::Object *ret = new example::Object();
    int num_ret = olua_push_object(L, ret, "example.Object");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Object(lua_State *L)
{
    oluacls_class<example::Object>(L, "example.Object");
    oluacls_func(L, "__gc", _example_Object___gc);
    oluacls_func(L, "__olua_move", _example_Object___olua_move);
    oluacls_func(L, "autorelease", _example_Object_autorelease);
    oluacls_func(L, "getReferenceCount", _example_Object_getReferenceCount);
    oluacls_func(L, "new", _example_Object_new);
    oluacls_prop(L, "referenceCount", _example_Object_getReferenceCount, nullptr);

    return 1;
}
OLUA_END_DECLS

static int _example_ExportParent_printExportParent(lua_State *L)
{
    olua_startinvoke(L);

    example::ExportParent *self = nullptr;

    olua_to_object(L, 1, &self, "example.ExportParent");

    // void printExportParent()
    self->printExportParent();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ExportParent(lua_State *L)
{
    oluacls_class<example::ExportParent, example::Object>(L, "example.ExportParent");
    oluacls_func(L, "printExportParent", _example_ExportParent_printExportParent);

    return 1;
}
OLUA_END_DECLS

static int _example_VectorInt___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_VectorInt___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::VectorInt *)olua_toobj(L, 1, "example.VectorInt");
    olua_push_object(L, self, "example.VectorInt");

    olua_endinvoke(L);

    return 1;
}

static int _example_VectorInt_create$1(lua_State *L)
{
    olua_startinvoke(L);

    // @postnew @name(new) static example::VectorInt *create()
    example::VectorInt *ret = example::VectorInt::create();
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_create$2(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<int> arg1;       /** v */

    olua_check_vector<int>(L, 1, arg1, [L](int *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // @postnew @name(new) static example::VectorInt *create(const std::vector<int> &v)
    example::VectorInt *ret = example::VectorInt::create(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_create(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // @postnew @name(new) static example::VectorInt *create()
        return _example_VectorInt_create$1(L);
    }

    if (num_args == 1) {
        // if ((olua_is_vector(L, 1))) {
            // @postnew @name(new) static example::VectorInt *create(const std::vector<int> &v)
            return _example_VectorInt_create$2(L);
        // }
    }

    luaL_error(L, "method 'example::VectorInt::create' not support '%d' arguments", num_args);

    return 0;
}

static int _example_VectorInt_take(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // example::VectorInt *take()
    example::VectorInt *ret = self->take();
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_data(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter @name(data) std::vector<int> *data()
    std::vector<int> *ret = self->data();
    int num_ret = olua_push_pointer(L, ret, "example.VectorInt");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_rawdata(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter @name(rawdata) void *rawdata()
    void *ret = self->rawdata();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_size(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter @name(sizeof) size_t size()
    size_t ret = self->size();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_value(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter @name(value) const std::vector<int> &value()
    const std::vector<int> &ret = self->value();
    int num_ret = olua_push_vector<int>(L, ret, [L](int &arg1) {
        olua_push_integer(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_VectorInt(lua_State *L)
{
    oluacls_class<example::VectorInt>(L, "example.VectorInt");
    oluacls_func(L, "__gc", _example_VectorInt___gc);
    oluacls_func(L, "__olua_move", _example_VectorInt___olua_move);
    oluacls_func(L, "new", _example_VectorInt_create);
    oluacls_func(L, "take", _example_VectorInt_take);
    oluacls_prop(L, "data", _example_VectorInt_data, nullptr);
    oluacls_prop(L, "rawdata", _example_VectorInt_rawdata, nullptr);
    oluacls_prop(L, "sizeof", _example_VectorInt_size, nullptr);
    oluacls_prop(L, "value", _example_VectorInt_value, _example_VectorInt_value);

    return 1;
}
OLUA_END_DECLS

static int _example_VectorPoint___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_VectorPoint___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::VectorPoint *)olua_toobj(L, 1, "example.VectorPoint");
    olua_push_object(L, self, "example.VectorPoint");

    olua_endinvoke(L);

    return 1;
}

static int _example_VectorPoint_create$1(lua_State *L)
{
    olua_startinvoke(L);

    // @postnew @name(new) static example::VectorPoint *create()
    example::VectorPoint *ret = example::VectorPoint::create();
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorPoint_create$2(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<example::Point> arg1;       /** v */

    olua_check_vector<example::Point>(L, 1, arg1, [L](example::Point *arg1) {
        olua_check_object(L, -1, arg1, "example.Point");
    });

    // @postnew @name(new) static example::VectorPoint *create(const std::vector<example::Point> &v)
    example::VectorPoint *ret = example::VectorPoint::create(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorPoint_create(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // @postnew @name(new) static example::VectorPoint *create()
        return _example_VectorPoint_create$1(L);
    }

    if (num_args == 1) {
        // if ((olua_is_vector(L, 1))) {
            // @postnew @name(new) static example::VectorPoint *create(const std::vector<example::Point> &v)
            return _example_VectorPoint_create$2(L);
        // }
    }

    luaL_error(L, "method 'example::VectorPoint::create' not support '%d' arguments", num_args);

    return 0;
}

static int _example_VectorPoint_take(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // example::VectorPoint *take()
    example::VectorPoint *ret = self->take();
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorPoint_data(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // @getter @name(data) std::vector<example::Point> *data()
    std::vector<example::Point> *ret = self->data();
    int num_ret = olua_push_pointer(L, ret, "example.VectorPoint");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorPoint_rawdata(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // @getter @name(rawdata) void *rawdata()
    void *ret = self->rawdata();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorPoint_size(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // @getter @name(sizeof) size_t size()
    size_t ret = self->size();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorPoint_value(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // @getter @name(value) const std::vector<example::Point> &value()
    const std::vector<example::Point> &ret = self->value();
    int num_ret = olua_push_vector<example::Point>(L, ret, [L](example::Point &arg1) {
        olua_pushcopy_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_VectorPoint(lua_State *L)
{
    oluacls_class<example::VectorPoint>(L, "example.VectorPoint");
    oluacls_func(L, "__gc", _example_VectorPoint___gc);
    oluacls_func(L, "__olua_move", _example_VectorPoint___olua_move);
    oluacls_func(L, "new", _example_VectorPoint_create);
    oluacls_func(L, "take", _example_VectorPoint_take);
    oluacls_prop(L, "data", _example_VectorPoint_data, nullptr);
    oluacls_prop(L, "rawdata", _example_VectorPoint_rawdata, nullptr);
    oluacls_prop(L, "sizeof", _example_VectorPoint_size, nullptr);
    oluacls_prop(L, "value", _example_VectorPoint_value, _example_VectorPoint_value);

    return 1;
}
OLUA_END_DECLS

static int _example_VectorString___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_VectorString___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::VectorString *)olua_toobj(L, 1, "example.VectorString");
    olua_push_object(L, self, "example.VectorString");

    olua_endinvoke(L);

    return 1;
}

static int _example_VectorString_create$1(lua_State *L)
{
    olua_startinvoke(L);

    // @postnew @name(new) static example::VectorString *create()
    example::VectorString *ret = example::VectorString::create();
    int num_ret = olua_push_object(L, ret, "example.VectorString");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorString_create$2(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<std::string> arg1;       /** v */

    olua_check_vector<std::string>(L, 1, arg1, [L](std::string *arg1) {
        olua_check_string(L, -1, arg1);
    });

    // @postnew @name(new) static example::VectorString *create(const std::vector<std::string> &v)
    example::VectorString *ret = example::VectorString::create(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorString");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorString_create(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // @postnew @name(new) static example::VectorString *create()
        return _example_VectorString_create$1(L);
    }

    if (num_args == 1) {
        // if ((olua_is_vector(L, 1))) {
            // @postnew @name(new) static example::VectorString *create(const std::vector<std::string> &v)
            return _example_VectorString_create$2(L);
        // }
    }

    luaL_error(L, "method 'example::VectorString::create' not support '%d' arguments", num_args);

    return 0;
}

static int _example_VectorString_take(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // example::VectorString *take()
    example::VectorString *ret = self->take();
    int num_ret = olua_push_object(L, ret, "example.VectorString");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorString_data(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // @getter @name(data) std::vector<std::string> *data()
    std::vector<std::string> *ret = self->data();
    int num_ret = olua_push_pointer(L, ret, "example.VectorString");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorString_rawdata(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // @getter @name(rawdata) void *rawdata()
    void *ret = self->rawdata();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorString_size(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // @getter @name(sizeof) size_t size()
    size_t ret = self->size();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorString_value(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // @getter @name(value) const std::vector<std::string> &value()
    const std::vector<std::string> &ret = self->value();
    int num_ret = olua_push_vector<std::string>(L, ret, [L](std::string &arg1) {
        olua_push_string(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_VectorString(lua_State *L)
{
    oluacls_class<example::VectorString>(L, "example.VectorString");
    oluacls_func(L, "__gc", _example_VectorString___gc);
    oluacls_func(L, "__olua_move", _example_VectorString___olua_move);
    oluacls_func(L, "new", _example_VectorString_create);
    oluacls_func(L, "take", _example_VectorString_take);
    oluacls_prop(L, "data", _example_VectorString_data, nullptr);
    oluacls_prop(L, "rawdata", _example_VectorString_rawdata, nullptr);
    oluacls_prop(L, "sizeof", _example_VectorString_size, nullptr);
    oluacls_prop(L, "value", _example_VectorString_value, _example_VectorString_value);

    return 1;
}
OLUA_END_DECLS

static int _example_PointArray___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_PointArray___index(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    unsigned int arg1 = 0;       /** idx */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);

    // example::Point __index(unsigned int idx)
    example::Point ret = self->__index(arg1);
    int num_ret = olua_pushcopy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray___newindex(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    unsigned int arg1 = 0;       /** idx */
    example::Point arg2;       /** v */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);
    olua_check_object(L, 3, &arg2, "example.Point");

    // void __newindex(unsigned int idx, const example::Point &v)
    self->__newindex(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _example_PointArray___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::PointArray *)olua_toobj(L, 1, "example.PointArray");
    olua_push_object(L, self, "example.PointArray");

    olua_endinvoke(L);

    return 1;
}

static int _example_PointArray_create$1(lua_State *L)
{
    olua_startinvoke(L);

    size_t arg1 = 0;       /** len */

    olua_check_integer(L, 1, &arg1);

    // @postnew @name(new) static example::PointArray *create(@optional size_t len)
    example::PointArray *ret = example::PointArray::create(arg1);
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_create$2(lua_State *L)
{
    olua_startinvoke(L);

    // @postnew @name(new) static example::PointArray *create(@optional size_t len)
    example::PointArray *ret = example::PointArray::create();
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_create(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // @postnew @name(new) static example::PointArray *create(@optional size_t len)
        return _example_PointArray_create$2(L);
    }

    if (num_args == 1) {
        // if ((olua_is_integer(L, 1))) {
            // @postnew @name(new) static example::PointArray *create(@optional size_t len)
            return _example_PointArray_create$1(L);
        // }
    }

    luaL_error(L, "method 'example::PointArray::create' not support '%d' arguments", num_args);

    return 0;
}

static int _example_PointArray_setstring(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    const char *arg1 = nullptr;       /** data */
    size_t arg2 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_string(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // void setstring(const char *data, size_t len)
    self->setstring(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _example_PointArray_sub$1(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::PointArray *sub(size_t from, @optional size_t to)
    example::PointArray *ret = self->sub(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_sub$2(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::PointArray *sub(size_t from, @optional size_t to)
    example::PointArray *ret = self->sub(arg1);
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_sub(lua_State *L)
{
    int num_args = lua_gettop(L) - 1;

    if (num_args == 1) {
        // if ((olua_is_integer(L, 2))) {
            // @postnew example::PointArray *sub(size_t from, @optional size_t to)
            return _example_PointArray_sub$2(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::PointArray *sub(size_t from, @optional size_t to)
            return _example_PointArray_sub$1(L);
        // }
    }

    luaL_error(L, "method 'example::PointArray::sub' not support '%d' arguments", num_args);

    return 0;
}

static int _example_PointArray_take(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // example::PointArray *take()
    example::PointArray *ret = self->take();
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_tostring(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    size_t arg2 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg2);

    // olua_Return tostring(lua_State *L, size_t len)
    olua_Return ret = self->tostring(L, arg2);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_PointArray_data(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter @name(data) example::Point *data()
    example::Point *ret = self->data();
    int num_ret = olua_push_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_length(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter @name(length) size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_rawdata(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter @name(rawdata) void *rawdata()
    void *ret = self->rawdata();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_size(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter @name(sizeof) size_t size()
    size_t ret = self->size();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_PointArray_value(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter @name(value) const example::Point &value()
    const example::Point &ret = self->value();
    int num_ret = olua_push_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_PointArray(lua_State *L)
{
    oluacls_class<example::PointArray>(L, "example.PointArray");
    oluacls_func(L, "__gc", _example_PointArray___gc);
    oluacls_func(L, "__index", _example_PointArray___index);
    oluacls_func(L, "__newindex", _example_PointArray___newindex);
    oluacls_func(L, "__olua_move", _example_PointArray___olua_move);
    oluacls_func(L, "new", _example_PointArray_create);
    oluacls_func(L, "setstring", _example_PointArray_setstring);
    oluacls_func(L, "sub", _example_PointArray_sub);
    oluacls_func(L, "take", _example_PointArray_take);
    oluacls_func(L, "tostring", _example_PointArray_tostring);
    oluacls_prop(L, "data", _example_PointArray_data, nullptr);
    oluacls_prop(L, "length", _example_PointArray_length, _example_PointArray_length);
    oluacls_prop(L, "rawdata", _example_PointArray_rawdata, nullptr);
    oluacls_prop(L, "sizeof", _example_PointArray_size, nullptr);
    oluacls_prop(L, "value", _example_PointArray_value, _example_PointArray_value);

    return 1;
}
OLUA_END_DECLS

static int _example_ClickCallback___call(lua_State *L)
{
    olua_startinvoke(L);

    luaL_checktype(L, -1, LUA_TFUNCTION);
    olua_push_callback(L, (example::ClickCallback *)nullptr, "example.ClickCallback");

    olua_endinvoke(L);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ClickCallback(lua_State *L)
{
    oluacls_class<example::ClickCallback>(L, "example.ClickCallback");
    oluacls_func(L, "__call", _example_ClickCallback___call);

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Type(lua_State *L)
{
    oluacls_class<example::Type>(L, "example.Type");
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_enum(L, "LVALUE", (lua_Integer)example::Type::LVALUE);
    oluacls_enum(L, "POINTER", (lua_Integer)example::Type::POINTER);
    oluacls_enum(L, "RVALUE", (lua_Integer)example::Type::RVALUE);

    return 1;
}
OLUA_END_DECLS

static int _example_Point___call(lua_State *L)
{
    olua_startinvoke(L);

    example::Point ret;

    luaL_checktype(L, 2, LUA_TTABLE);

    float arg1 = 0;       /** x */
    float arg2 = 0;       /** y */

    olua_getfield(L, 2, "x");
    if (!olua_isnoneornil(L, -1)) {
        olua_check_number(L, -1, &arg1);
        ret.x = arg1;
    }
    lua_pop(L, 1);

    olua_getfield(L, 2, "y");
    if (!olua_isnoneornil(L, -1)) {
        olua_check_number(L, -1, &arg2);
        ret.y = arg2;
    }
    lua_pop(L, 1);

    olua_pushcopy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return 1;
}

static int _example_Point___gc(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Point *)olua_toobj(L, 1, "example.Point");
    olua_postgc(L, self);

    olua_endinvoke(L);

    return 0;
}

static int _example_Point___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Point *)olua_toobj(L, 1, "example.Point");
    olua_push_object(L, self, "example.Point");

    olua_endinvoke(L);

    return 1;
}

static int _example_Point_length(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // float length()
    float ret = self->length();
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_new$1(lua_State *L)
{
    olua_startinvoke(L);

    // Point()
    example::Point *ret = new example::Point();
    int num_ret = olua_push_object(L, ret, "example.Point");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_new$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Point arg1;       /** p */

    olua_check_object(L, 1, &arg1, "example.Point");

    // Point(const example::Point &p)
    example::Point *ret = new example::Point(arg1);
    int num_ret = olua_push_object(L, ret, "example.Point");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_new$3(lua_State *L)
{
    olua_startinvoke(L);

    float arg1 = 0;       /** x */
    float arg2 = 0;       /** y */

    olua_check_number(L, 1, &arg1);
    olua_check_number(L, 2, &arg2);

    // Point(float x, float y)
    example::Point *ret = new example::Point(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.Point");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_new(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // Point()
        return _example_Point_new$1(L);
    }

    if (num_args == 1) {
        // if ((olua_is_object(L, 1, "example.Point"))) {
            // Point(const example::Point &p)
            return _example_Point_new$2(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_number(L, 1)) && (olua_is_number(L, 2))) {
            // Point(float x, float y)
            return _example_Point_new$3(L);
        // }
    }

    luaL_error(L, "method 'example::Point::new' not support '%d' arguments", num_args);

    return 0;
}

static int _example_Point_get_x(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // @optional float x
    float ret = self->x;
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_set_x(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** x */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // @optional float x
    self->x = arg1;

    olua_endinvoke(L);

    return 0;
}

static int _example_Point_get_y(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // @optional float y
    float ret = self->y;
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_set_y(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** y */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // @optional float y
    self->y = arg1;

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Point(lua_State *L)
{
    oluacls_class<example::Point>(L, "example.Point");
    oluacls_func(L, "__call", _example_Point___call);
    oluacls_func(L, "__gc", _example_Point___gc);
    oluacls_func(L, "__olua_move", _example_Point___olua_move);
    oluacls_func(L, "length", _example_Point_length);
    oluacls_func(L, "new", _example_Point_new);
    oluacls_prop(L, "x", _example_Point_get_x, _example_Point_set_x);
    oluacls_prop(L, "y", _example_Point_get_y, _example_Point_set_y);

    return 1;
}
OLUA_END_DECLS

static int _example_Hello_as(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    const char *arg1 = nullptr;       /** cls */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    do {
        if (olua_isa(L, 1, arg1)) {
            lua_pushvalue(L, 1);
            break;
        }
        if (olua_strequal(arg1, "example.Singleton")) {
            olua_pushobj_as<example::Singleton<example::Hello>>(L, 1, self, "as.example.Singleton");
            break;
        }

        luaL_error(L, "'example::Hello' can't cast to '%s'", arg1);
    } while (0);

    olua_endinvoke(L);

    return 1;
}

static int _example_Hello_checkString(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<std::string> *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "example.VectorString");

    // void checkString(std::vector<std::string> *)
    self->checkString(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_checkVectorInt(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<int> *arg1 = nullptr;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "example.VectorInt");

    // void checkVectorInt(std::vector<int> &v)
    self->checkVectorInt(*arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_checkVectorPoint(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<example::Point> *arg1 = nullptr;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "example.VectorPoint");

    // void checkVectorPoint(std::vector<example::Point> &v)
    self->checkVectorPoint(*arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_convertPoint$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Point arg1;       /** p */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Point");

    // example::Point convertPoint(const example::Point &p)
    example::Point ret = self->convertPoint(arg1);
    int num_ret = olua_pushcopy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_convertPoint$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Point arg1;       /** p */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_pack_object(L, 2, &arg1);

    // example::Point convertPoint(@pack const example::Point &p)
    example::Point ret = self->convertPoint(arg1);
    int num_ret = olua_unpack_object(L, &ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_convertPoint(lua_State *L)
{
    int num_args = lua_gettop(L) - 1;

    if (num_args == 1) {
        // if ((olua_is_object(L, 2, "example.Point"))) {
            // example::Point convertPoint(const example::Point &p)
            return _example_Hello_convertPoint$1(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_canpack_object(L, 2, (example::Point *)nullptr))) {
            // example::Point convertPoint(@pack const example::Point &p)
            return _example_Hello_convertPoint$2(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::convertPoint' not support '%d' arguments", num_args);

    return 0;
}

static int _example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // @copyfrom(example::Singleton) static example::Hello *create()
    example::Hello *ret = example::Hello::create();
    int num_ret = olua_push_object(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_doCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // void doCallback()
    self->doCallback();

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_getAliasHello(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // example::HelloAlias *getAliasHello()
    example::HelloAlias *ret = self->getAliasHello();
    int num_ret = olua_push_object(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getCGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // const GLchar *getCGLchar()
    const GLchar *ret = self->getCGLchar();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getCName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // const char *getCName()
    const char *ret = self->getCName();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getCStrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<const char *> getCStrs()
    std::vector<const char *> ret = self->getCStrs();
    int num_ret = olua_push_vector<const char *>(L, ret, [L](const char *arg1) {
        olua_push_string(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // GLchar *getGLchar()
    GLchar *ret = self->getGLchar();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getGLvoid(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // GLvoid *getGLvoid()
    GLvoid *ret = self->getGLvoid();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getID(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // int getID()
    int ret = self->getID();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getIntPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // int *getIntPtr()
    int *ret = self->getIntPtr();
    int num_ret = olua_push_array(L, ret, "olua.int");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getIntPtrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<short *> getIntPtrs()
    std::vector<short *> ret = self->getIntPtrs();
    int num_ret = olua_push_vector<short *>(L, ret, [L](short *arg1) {
        olua_push_array(L, arg1, "olua.short");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getIntRef(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    int *arg1 = nullptr;       /** ref */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array(L, 2, &arg1, "olua.int");

    // void getIntRef(int &ref)
    self->getIntRef(*arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_getInts(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<int64_t> getInts()
    std::vector<int64_t> ret = self->getInts();
    int num_ret = olua_push_vector<int64_t>(L, ret, [L](int64_t &arg1) {
        olua_push_integer(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // const std::string &getName()
    const std::string &ret = self->getName();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getPointers(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<example::Point *> getPointers()
    std::vector<example::Point *> ret = self->getPointers();
    int num_ret = olua_push_vector<example::Point *>(L, ret, [L](example::Point *arg1) {
        olua_push_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getPoints(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<example::Point> getPoints()
    std::vector<example::Point> ret = self->getPoints();
    int num_ret = olua_push_vector<example::Point>(L, ret, [L](example::Point &arg1) {
        olua_pushcopy_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // void *getPtr()
    void *ret = self->getPtr();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getStringRef(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::string *arg1 = nullptr;       /** ref */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "olua.string");

    // void getStringRef(std::string &ref)
    self->getStringRef(*arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_getType(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // example::Type getType()
    example::Type ret = self->getType();
    int num_ret = olua_push_enum(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getVec2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @unpack example::Vec2 getVec2()
    example::Vec2 ret = self->getVec2();
    int num_ret = olua_unpack_object(L, &ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getVectorIntPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<int> *getVectorIntPtr()
    std::vector<int> *ret = self->getVectorIntPtr();
    int num_ret = olua_push_pointer(L, ret, "example.VectorInt");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getVoids(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<GLvoid *> getVoids()
    std::vector<GLvoid *> ret = self->getVoids();
    int num_ret = olua_push_vector<GLvoid *>(L, ret, [L](GLvoid *arg1) {
        olua_push_object(L, arg1, "void *");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_load(lua_State *L)
{
    olua_startinvoke(L);

    std::string arg1;       /** path */
    std::function<std::string (example::Hello *, int)> arg2;       /** callback */

    olua_check_string(L, 1, &arg1);
    olua_check_callback(L, 2, &arg2, "std.function");

    void *cb_store = (void *)olua_pushclassobj(L, "example.Hello");
    std::string cb_tag = "load";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg2 = [cb_store, cb_name, cb_ctx](example::Hello *arg1, int arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_push_integer(L, arg2);
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 2);

            if (olua_is_string(L, -1)) {
                olua_check_string(L, -1, &ret);
            }

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
        return ret;
    };

    // static int load(const std::string &path, @localvar const std::function<std::string (example::Hello *, int)> &callback)
    int ret = example::Hello::load(arg1, arg2);
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_new(lua_State *L)
{
    olua_startinvoke(L);

    // Hello()
    example::Hello *ret = new example::Hello();
    int num_ret = olua_push_object(L, ret, "example.Hello");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @copyfrom(example::Singleton) void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_read(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    olua_char_t *arg1 = nullptr;       /** result */
    size_t *arg2 = nullptr;       /** len */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array(L, 2, &arg1, "olua.char");
    olua_check_array(L, 3, &arg2, "olua.size_t");

    // void read(@type(olua_char_t *) char *result, size_t *len)
    self->read(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */
    example::Hello *arg11 = nullptr;       /** obj_$10 */
    example::Hello *arg12 = nullptr;       /** obj_$11 */
    example::Hello *arg13 = nullptr;       /** obj_$12 */
    example::Hello *arg14 = nullptr;       /** obj_$13 */
    example::Hello *arg15 = nullptr;       /** obj_$14 */
    example::Hello *arg16 = nullptr;       /** obj_$15 */
    example::Hello *arg17 = nullptr;       /** obj_$16 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");
    olua_check_object(L, 12, &arg11, "example.Hello");
    olua_check_object(L, 13, &arg12, "example.Hello");
    olua_check_object(L, 14, &arg13, "example.Hello");
    olua_check_object(L, 15, &arg14, "example.Hello");
    olua_check_object(L, 16, &arg15, "example.Hello");
    olua_check_object(L, 17, &arg16, "example.Hello");
    olua_check_object(L, 18, &arg17, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$3(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$4(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$5(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$6(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$7(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$8(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$9(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$10(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$11(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$12(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */
    example::Hello *arg11 = nullptr;       /** obj_$10 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");
    olua_check_object(L, 12, &arg11, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$13(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */
    example::Hello *arg11 = nullptr;       /** obj_$10 */
    example::Hello *arg12 = nullptr;       /** obj_$11 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");
    olua_check_object(L, 12, &arg11, "example.Hello");
    olua_check_object(L, 13, &arg12, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$14(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */
    example::Hello *arg11 = nullptr;       /** obj_$10 */
    example::Hello *arg12 = nullptr;       /** obj_$11 */
    example::Hello *arg13 = nullptr;       /** obj_$12 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");
    olua_check_object(L, 12, &arg11, "example.Hello");
    olua_check_object(L, 13, &arg12, "example.Hello");
    olua_check_object(L, 14, &arg13, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$15(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */
    example::Hello *arg11 = nullptr;       /** obj_$10 */
    example::Hello *arg12 = nullptr;       /** obj_$11 */
    example::Hello *arg13 = nullptr;       /** obj_$12 */
    example::Hello *arg14 = nullptr;       /** obj_$13 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");
    olua_check_object(L, 12, &arg11, "example.Hello");
    olua_check_object(L, 13, &arg12, "example.Hello");
    olua_check_object(L, 14, &arg13, "example.Hello");
    olua_check_object(L, 15, &arg14, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$16(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */
    example::Hello *arg11 = nullptr;       /** obj_$10 */
    example::Hello *arg12 = nullptr;       /** obj_$11 */
    example::Hello *arg13 = nullptr;       /** obj_$12 */
    example::Hello *arg14 = nullptr;       /** obj_$13 */
    example::Hello *arg15 = nullptr;       /** obj_$14 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");
    olua_check_object(L, 12, &arg11, "example.Hello");
    olua_check_object(L, 13, &arg12, "example.Hello");
    olua_check_object(L, 14, &arg13, "example.Hello");
    olua_check_object(L, 15, &arg14, "example.Hello");
    olua_check_object(L, 16, &arg15, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run$17(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */
    example::Hello *arg3 = nullptr;       /** obj_$2 */
    example::Hello *arg4 = nullptr;       /** obj_$3 */
    example::Hello *arg5 = nullptr;       /** obj_$4 */
    example::Hello *arg6 = nullptr;       /** obj_$5 */
    example::Hello *arg7 = nullptr;       /** obj_$6 */
    example::Hello *arg8 = nullptr;       /** obj_$7 */
    example::Hello *arg9 = nullptr;       /** obj_$8 */
    example::Hello *arg10 = nullptr;       /** obj_$9 */
    example::Hello *arg11 = nullptr;       /** obj_$10 */
    example::Hello *arg12 = nullptr;       /** obj_$11 */
    example::Hello *arg13 = nullptr;       /** obj_$12 */
    example::Hello *arg14 = nullptr;       /** obj_$13 */
    example::Hello *arg15 = nullptr;       /** obj_$14 */
    example::Hello *arg16 = nullptr;       /** obj_$15 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");
    olua_check_object(L, 4, &arg3, "example.Hello");
    olua_check_object(L, 5, &arg4, "example.Hello");
    olua_check_object(L, 6, &arg5, "example.Hello");
    olua_check_object(L, 7, &arg6, "example.Hello");
    olua_check_object(L, 8, &arg7, "example.Hello");
    olua_check_object(L, 9, &arg8, "example.Hello");
    olua_check_object(L, 10, &arg9, "example.Hello");
    olua_check_object(L, 11, &arg10, "example.Hello");
    olua_check_object(L, 12, &arg11, "example.Hello");
    olua_check_object(L, 13, &arg12, "example.Hello");
    olua_check_object(L, 14, &arg13, "example.Hello");
    olua_check_object(L, 15, &arg14, "example.Hello");
    olua_check_object(L, 16, &arg15, "example.Hello");
    olua_check_object(L, 17, &arg16, "example.Hello");

    // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_run(lua_State *L)
{
    int num_args = lua_gettop(L) - 1;

    if (num_args == 1) {
        // if ((olua_is_object(L, 2, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$2(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$3(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$4(L);
        // }
    }

    if (num_args == 4) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$5(L);
        // }
    }

    if (num_args == 5) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$6(L);
        // }
    }

    if (num_args == 6) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$7(L);
        // }
    }

    if (num_args == 7) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$8(L);
        // }
    }

    if (num_args == 8) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$9(L);
        // }
    }

    if (num_args == 9) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$10(L);
        // }
    }

    if (num_args == 10) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$11(L);
        // }
    }

    if (num_args == 11) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$12(L);
        // }
    }

    if (num_args == 12) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$13(L);
        // }
    }

    if (num_args == 13) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$14(L);
        // }
    }

    if (num_args == 14) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$15(L);
        // }
    }

    if (num_args == 15) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello")) && (olua_is_object(L, 16, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$16(L);
        // }
    }

    if (num_args == 16) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello")) && (olua_is_object(L, 16, "example.Hello")) && (olua_is_object(L, 17, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$17(L);
        // }
    }

    if (num_args == 17) {
        // if ((olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello")) && (olua_is_object(L, 16, "example.Hello")) && (olua_is_object(L, 17, "example.Hello")) && (olua_is_object(L, 18, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, @optional example::Hello *obj_$1, @optional example::Hello *obj_$2, @optional example::Hello *obj_$3, @optional example::Hello *obj_$4, @optional example::Hello *obj_$5, @optional example::Hello *obj_$6, @optional example::Hello *obj_$7, @optional example::Hello *obj_$8, @optional example::Hello *obj_$9, @optional example::Hello *obj_$10, @optional example::Hello *obj_$11, @optional example::Hello *obj_$12, @optional example::Hello *obj_$13, @optional example::Hello *obj_$14, @optional example::Hello *obj_$15, @optional example::Hello *obj_$16)
            return _example_Hello_run$1(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::run' not support '%d' arguments", num_args);

    return 0;
}

static int _example_Hello_setCGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    const GLchar *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setCGLchar(const GLchar *)
    self->setCGLchar(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setCName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    const char *arg1 = nullptr;       /** value */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setCName(const char *value)
    self->setCName(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setCStrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<const char *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_vector<const char *>(L, 2, arg1, [L](const char **arg1) {
        olua_check_string(L, -1, arg1);
    });

    // void setCStrs(const std::vector<const char *> &v)
    self->setCStrs(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<int (example::Hello *, example::Point *)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "Callback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1, example::Point *arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        int ret = 0;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_push_object(L, arg2, "example.Point");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 2);

            if (olua_is_integer(L, -1)) {
                olua_check_integer(L, -1, &ret);
            }

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
        return ret;
    };

    // void setCallback(@localvar const std::function<int (example::Hello *, example::Point *)> &callback)
    self->setCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setClickCallback$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::ClickCallback arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "example.ClickCallback");

    void *cb_store = (void *)self;
    std::string cb_tag = "ClickCallback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setClickCallback(@localvar const example::ClickCallback &callback)
    self->setClickCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setClickCallback$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<std::string (example::Hello *, int)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "ClickCallback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1, int arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_push_integer(L, arg2);
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 2);

            if (olua_is_string(L, -1)) {
                olua_check_string(L, -1, &ret);
            }

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
        return ret;
    };

    // void setClickCallback(@localvar const std::function<std::string (example::Hello *, int)> &callback)
    self->setClickCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setClickCallback(lua_State *L)
{
    int num_args = lua_gettop(L) - 1;

    if (num_args == 1) {
        if ((olua_is_callback(L, 2, "example.ClickCallback"))) {
            // void setClickCallback(@localvar const example::ClickCallback &callback)
            return _example_Hello_setClickCallback$1(L);
        }

        // if ((olua_is_callback(L, 2, "std.function"))) {
            // void setClickCallback(@localvar const std::function<std::string (example::Hello *, int)> &callback)
            return _example_Hello_setClickCallback$2(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::setClickCallback' not support '%d' arguments", num_args);

    return 0;
}

static int _example_Hello_setDragCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<void (example::Hello *)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "DragCallback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setDragCallback(@localvar const std::function<void (example::Hello *)> &callback)
    self->setDragCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLchar *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setGLchar(GLchar *)
    self->setGLchar(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setGLfloat(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLfloat *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array(L, 2, &arg1, "olua.float");

    // void setGLfloat(GLfloat *)
    self->setGLfloat(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setGLvoid(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLvoid *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "void *");

    // void setGLvoid(GLvoid *)
    self->setGLvoid(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setID(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    int arg1 = 0;       /** id */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_integer(L, 2, &arg1);

    // void setID(int id)
    self->setID(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setIntPtrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<short *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_vector<short *>(L, 2, arg1, [L](short **arg1) {
        olua_check_array(L, -1, arg1, "olua.short");
    });

    // void setIntPtrs(const std::vector<short *> &v)
    self->setIntPtrs(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setInts(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<int64_t> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_vector<int64_t>(L, 2, arg1, [L](int64_t *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // void setInts(const std::vector<int64_t> &v)
    self->setInts(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::string arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setName(const std::string &value)
    self->setName(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setNotifyCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<std::string (example::Hello *, int)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "NotifyCallback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1, int arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_push_integer(L, arg2);
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 2);

            if (olua_is_string(L, -1)) {
                olua_check_string(L, -1, &ret);
            }

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
        return ret;
    };

    // void setNotifyCallback(@localvar const std::function<std::string (example::Hello *, int)> &callback)
    self->setNotifyCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setPointers(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<example::Point *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_vector<example::Point *>(L, 2, arg1, [L](example::Point **arg1) {
        olua_check_object(L, -1, arg1, "example.Point");
    });

    // void setPointers(const std::vector<example::Point *> &v)
    self->setPointers(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setPoints(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<example::Point> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_vector<example::Point>(L, 2, arg1, [L](example::Point *arg1) {
        olua_check_object(L, -1, arg1, "example.Point");
    });

    // void setPoints(const std::vector<example::Point> &v)
    self->setPoints(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    void *arg1 = nullptr;       /** p */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "void *");

    // void setPtr(void *p)
    self->setPtr(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setTouchCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::TouchCallback arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "example.ClickCallback");

    void *cb_store = (void *)self;
    std::string cb_tag = "TouchCallback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setTouchCallback(@localvar const example::TouchCallback &callback)
    self->setTouchCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setType(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Type arg1 = (example::Type)0;       /** t */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_enum(L, 2, &arg1);

    // void setType(example::Type t)
    self->setType(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setVoids(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<GLvoid *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_vector<GLvoid *>(L, 2, arg1, [L](GLvoid **arg1) {
        olua_check_object(L, -1, arg1, "void *");
    });

    // void setVoids(const std::vector<GLvoid *> &v)
    self->setVoids(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_testPointerTypes$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    olua_char_t *arg1 = nullptr;       /**  */
    olua_uchar_t *arg2 = nullptr;       /**  */
    short *arg3 = nullptr;       /**  */
    short *arg4 = nullptr;       /**  */
    std::vector<short> arg5;       /**  */
    unsigned short *arg6 = nullptr;       /**  */
    unsigned short *arg7 = nullptr;       /**  */
    std::vector<unsigned short> arg8;       /**  */
    int *arg9 = nullptr;       /**  */
    int *arg10 = nullptr;       /**  */
    std::vector<int> *arg11 = nullptr;       /**  */
    unsigned int *arg12 = nullptr;       /**  */
    unsigned int *arg13 = nullptr;       /**  */
    std::vector<unsigned int> arg14;       /**  */
    long *arg15 = nullptr;       /**  */
    long *arg16 = nullptr;       /**  */
    std::vector<long> arg17;       /**  */
    unsigned long *arg18 = nullptr;       /**  */
    unsigned long *arg19 = nullptr;       /**  */
    std::vector<unsigned long> arg20;       /**  */
    long long *arg21 = nullptr;       /**  */
    long long *arg22 = nullptr;       /**  */
    std::vector<long long> arg23;       /**  */
    unsigned long long *arg24 = nullptr;       /**  */
    unsigned long long *arg25 = nullptr;       /**  */
    std::vector<unsigned long long> arg26;       /**  */
    float *arg27 = nullptr;       /**  */
    std::vector<float> arg28;       /**  */
    double *arg29 = nullptr;       /**  */
    std::vector<double> arg30;       /**  */
    long double *arg31 = nullptr;       /**  */
    std::vector<long double> arg32;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array(L, 2, &arg1, "olua.char");
    olua_check_array(L, 3, &arg2, "olua.uchar");
    olua_check_array(L, 4, &arg3, "olua.short");
    olua_check_array(L, 5, &arg4, "olua.short");
    olua_check_vector<short>(L, 6, arg5, [L](short *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_array(L, 7, &arg6, "olua.ushort");
    olua_check_array(L, 8, &arg7, "olua.ushort");
    olua_check_vector<unsigned short>(L, 9, arg8, [L](unsigned short *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_array(L, 10, &arg9, "olua.int");
    olua_check_array(L, 11, &arg10, "olua.int");
    olua_check_pointer(L, 12, &arg11, "example.VectorInt");
    olua_check_array(L, 13, &arg12, "olua.uint");
    olua_check_array(L, 14, &arg13, "olua.uint");
    olua_check_vector<unsigned int>(L, 15, arg14, [L](unsigned int *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_array(L, 16, &arg15, "olua.long");
    olua_check_array(L, 17, &arg16, "olua.long");
    olua_check_vector<long>(L, 18, arg17, [L](long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_array(L, 19, &arg18, "olua.ulong");
    olua_check_array(L, 20, &arg19, "olua.ulong");
    olua_check_vector<unsigned long>(L, 21, arg20, [L](unsigned long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_array(L, 22, &arg21, "olua.llong");
    olua_check_array(L, 23, &arg22, "olua.llong");
    olua_check_vector<long long>(L, 24, arg23, [L](long long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_array(L, 25, &arg24, "olua.ullong");
    olua_check_array(L, 26, &arg25, "olua.ullong");
    olua_check_vector<unsigned long long>(L, 27, arg26, [L](unsigned long long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_array(L, 28, &arg27, "olua.float");
    olua_check_vector<float>(L, 29, arg28, [L](float *arg1) {
        olua_check_number(L, -1, arg1);
    });
    olua_check_array(L, 30, &arg29, "olua.double");
    olua_check_vector<double>(L, 31, arg30, [L](double *arg1) {
        olua_check_number(L, -1, arg1);
    });
    olua_check_array(L, 32, &arg31, "olua.ldouble");
    olua_check_vector<long double>(L, 33, arg32, [L](long double *arg1) {
        olua_check_number(L, -1, arg1);
    });

    // void testPointerTypes(@type(olua_char_t *) char *, @type(olua_uchar_t *) unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)
    self->testPointerTypes(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, *arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31, arg32);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_testPointerTypes$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<void (char *, unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)> arg1;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "testPointerTypes";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](char *arg1, unsigned char *arg2, short *arg3, short *arg4, std::vector<short> &arg5, unsigned short *arg6, unsigned short *arg7, std::vector<unsigned short> &arg8, int *arg9, int *arg10, std::vector<int> &arg11, unsigned int *arg12, unsigned int *arg13, std::vector<unsigned int> &arg14, long *arg15, long *arg16, std::vector<long> &arg17, unsigned long *arg18, unsigned long *arg19, std::vector<unsigned long> &arg20, long long *arg21, long long *arg22, std::vector<long long> &arg23, unsigned long long *arg24, unsigned long long *arg25, std::vector<unsigned long long> &arg26, float *arg27, std::vector<float> &arg28, double *arg29, std::vector<double> &arg30, long double *arg31, std::vector<long double> &arg32) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_string(L, arg1);
            olua_push_string(L, arg2);
            olua_push_array(L, arg3, "olua.short");
            olua_push_array(L, arg4, "olua.short");
            olua_push_vector<short>(L, arg5, [L](short &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_array(L, arg6, "olua.ushort");
            olua_push_array(L, arg7, "olua.ushort");
            olua_push_vector<unsigned short>(L, arg8, [L](unsigned short &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_array(L, arg9, "olua.int");
            olua_push_array(L, arg10, "olua.int");
            olua_push_pointer(L, &arg11, "example.VectorInt");
            olua_push_array(L, arg12, "olua.uint");
            olua_push_array(L, arg13, "olua.uint");
            olua_push_vector<unsigned int>(L, arg14, [L](unsigned int &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_array(L, arg15, "olua.long");
            olua_push_array(L, arg16, "olua.long");
            olua_push_vector<long>(L, arg17, [L](long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_array(L, arg18, "olua.ulong");
            olua_push_array(L, arg19, "olua.ulong");
            olua_push_vector<unsigned long>(L, arg20, [L](unsigned long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_array(L, arg21, "olua.llong");
            olua_push_array(L, arg22, "olua.llong");
            olua_push_vector<long long>(L, arg23, [L](long long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_array(L, arg24, "olua.ullong");
            olua_push_array(L, arg25, "olua.ullong");
            olua_push_vector<unsigned long long>(L, arg26, [L](unsigned long long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_array(L, arg27, "olua.float");
            olua_push_vector<float>(L, arg28, [L](float &arg1) {
                olua_push_number(L, arg1);
            });
            olua_push_array(L, arg29, "olua.double");
            olua_push_vector<double>(L, arg30, [L](double &arg1) {
                olua_push_number(L, arg1);
            });
            olua_push_array(L, arg31, "olua.ldouble");
            olua_push_vector<long double>(L, arg32, [L](long double &arg1) {
                olua_push_number(L, arg1);
            });
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 32);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void testPointerTypes(@localvar const std::function<void (char *, unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)> &)
    self->testPointerTypes(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_testPointerTypes(lua_State *L)
{
    int num_args = lua_gettop(L) - 1;

    if (num_args == 1) {
        // if ((olua_is_callback(L, 2, "std.function"))) {
            // void testPointerTypes(@localvar const std::function<void (char *, unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)> &)
            return _example_Hello_testPointerTypes$2(L);
        // }
    }

    if (num_args == 32) {
        // if ((olua_is_array(L, 2, "olua.char")) && (olua_is_array(L, 3, "olua.uchar")) && (olua_is_array(L, 4, "olua.short")) && (olua_is_array(L, 5, "olua.short")) && (olua_is_vector(L, 6)) && (olua_is_array(L, 7, "olua.ushort")) && (olua_is_array(L, 8, "olua.ushort")) && (olua_is_vector(L, 9)) && (olua_is_array(L, 10, "olua.int")) && (olua_is_array(L, 11, "olua.int")) && (olua_is_pointer(L, 12, "example.VectorInt")) && (olua_is_array(L, 13, "olua.uint")) && (olua_is_array(L, 14, "olua.uint")) && (olua_is_vector(L, 15)) && (olua_is_array(L, 16, "olua.long")) && (olua_is_array(L, 17, "olua.long")) && (olua_is_vector(L, 18)) && (olua_is_array(L, 19, "olua.ulong")) && (olua_is_array(L, 20, "olua.ulong")) && (olua_is_vector(L, 21)) && (olua_is_array(L, 22, "olua.llong")) && (olua_is_array(L, 23, "olua.llong")) && (olua_is_vector(L, 24)) && (olua_is_array(L, 25, "olua.ullong")) && (olua_is_array(L, 26, "olua.ullong")) && (olua_is_vector(L, 27)) && (olua_is_array(L, 28, "olua.float")) && (olua_is_vector(L, 29)) && (olua_is_array(L, 30, "olua.double")) && (olua_is_vector(L, 31)) && (olua_is_array(L, 32, "olua.ldouble")) && (olua_is_vector(L, 33))) {
            // void testPointerTypes(@type(olua_char_t *) char *, @type(olua_uchar_t *) unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)
            return _example_Hello_testPointerTypes$1(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::testPointerTypes' not support '%d' arguments", num_args);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Hello(lua_State *L)
{
    oluacls_class<example::Hello, example::ExportParent>(L, "example.Hello");
    oluacls_func(L, "as", _example_Hello_as);
    oluacls_func(L, "checkString", _example_Hello_checkString);
    oluacls_func(L, "checkVectorInt", _example_Hello_checkVectorInt);
    oluacls_func(L, "checkVectorPoint", _example_Hello_checkVectorPoint);
    oluacls_func(L, "convertPoint", _example_Hello_convertPoint);
    oluacls_func(L, "create", _example_Hello_create);
    oluacls_func(L, "doCallback", _example_Hello_doCallback);
    oluacls_func(L, "getAliasHello", _example_Hello_getAliasHello);
    oluacls_func(L, "getCGLchar", _example_Hello_getCGLchar);
    oluacls_func(L, "getCName", _example_Hello_getCName);
    oluacls_func(L, "getCStrs", _example_Hello_getCStrs);
    oluacls_func(L, "getGLchar", _example_Hello_getGLchar);
    oluacls_func(L, "getGLvoid", _example_Hello_getGLvoid);
    oluacls_func(L, "getID", _example_Hello_getID);
    oluacls_func(L, "getIntPtr", _example_Hello_getIntPtr);
    oluacls_func(L, "getIntPtrs", _example_Hello_getIntPtrs);
    oluacls_func(L, "getIntRef", _example_Hello_getIntRef);
    oluacls_func(L, "getInts", _example_Hello_getInts);
    oluacls_func(L, "getName", _example_Hello_getName);
    oluacls_func(L, "getPointers", _example_Hello_getPointers);
    oluacls_func(L, "getPoints", _example_Hello_getPoints);
    oluacls_func(L, "getPtr", _example_Hello_getPtr);
    oluacls_func(L, "getStringRef", _example_Hello_getStringRef);
    oluacls_func(L, "getType", _example_Hello_getType);
    oluacls_func(L, "getVec2", _example_Hello_getVec2);
    oluacls_func(L, "getVectorIntPtr", _example_Hello_getVectorIntPtr);
    oluacls_func(L, "getVoids", _example_Hello_getVoids);
    oluacls_func(L, "load", _example_Hello_load);
    oluacls_func(L, "new", _example_Hello_new);
    oluacls_func(L, "printSingleton", _example_Hello_printSingleton);
    oluacls_func(L, "read", _example_Hello_read);
    oluacls_func(L, "run", _example_Hello_run);
    oluacls_func(L, "setCGLchar", _example_Hello_setCGLchar);
    oluacls_func(L, "setCName", _example_Hello_setCName);
    oluacls_func(L, "setCStrs", _example_Hello_setCStrs);
    oluacls_func(L, "setCallback", _example_Hello_setCallback);
    oluacls_func(L, "setClickCallback", _example_Hello_setClickCallback);
    oluacls_func(L, "setDragCallback", _example_Hello_setDragCallback);
    oluacls_func(L, "setGLchar", _example_Hello_setGLchar);
    oluacls_func(L, "setGLfloat", _example_Hello_setGLfloat);
    oluacls_func(L, "setGLvoid", _example_Hello_setGLvoid);
    oluacls_func(L, "setID", _example_Hello_setID);
    oluacls_func(L, "setIntPtrs", _example_Hello_setIntPtrs);
    oluacls_func(L, "setInts", _example_Hello_setInts);
    oluacls_func(L, "setName", _example_Hello_setName);
    oluacls_func(L, "setNotifyCallback", _example_Hello_setNotifyCallback);
    oluacls_func(L, "setPointers", _example_Hello_setPointers);
    oluacls_func(L, "setPoints", _example_Hello_setPoints);
    oluacls_func(L, "setPtr", _example_Hello_setPtr);
    oluacls_func(L, "setTouchCallback", _example_Hello_setTouchCallback);
    oluacls_func(L, "setType", _example_Hello_setType);
    oluacls_func(L, "setVoids", _example_Hello_setVoids);
    oluacls_func(L, "testPointerTypes", _example_Hello_testPointerTypes);
    oluacls_prop(L, "aliasHello", _example_Hello_getAliasHello, nullptr);
    oluacls_prop(L, "cName", _example_Hello_getCName, _example_Hello_setCName);
    oluacls_prop(L, "cStrs", _example_Hello_getCStrs, _example_Hello_setCStrs);
    oluacls_prop(L, "cgLchar", _example_Hello_getCGLchar, _example_Hello_setCGLchar);
    oluacls_prop(L, "gLchar", _example_Hello_getGLchar, _example_Hello_setGLchar);
    oluacls_prop(L, "gLvoid", _example_Hello_getGLvoid, _example_Hello_setGLvoid);
    oluacls_prop(L, "id", _example_Hello_getID, _example_Hello_setID);
    oluacls_prop(L, "intPtr", _example_Hello_getIntPtr, nullptr);
    oluacls_prop(L, "intPtrs", _example_Hello_getIntPtrs, _example_Hello_setIntPtrs);
    oluacls_prop(L, "ints", _example_Hello_getInts, _example_Hello_setInts);
    oluacls_prop(L, "name", _example_Hello_getName, _example_Hello_setName);
    oluacls_prop(L, "pointers", _example_Hello_getPointers, _example_Hello_setPointers);
    oluacls_prop(L, "points", _example_Hello_getPoints, _example_Hello_setPoints);
    oluacls_prop(L, "ptr", _example_Hello_getPtr, _example_Hello_setPtr);
    oluacls_prop(L, "type", _example_Hello_getType, _example_Hello_setType);
    oluacls_prop(L, "vec2", _example_Hello_getVec2, nullptr);
    oluacls_prop(L, "vectorIntPtr", _example_Hello_getVectorIntPtr, nullptr);
    oluacls_prop(L, "voids", _example_Hello_getVoids, _example_Hello_setVoids);

    return 1;
}
OLUA_END_DECLS

static int _example_Const___gc(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Const *)olua_toobj(L, 1, "example.Const");
    olua_postgc(L, self);

    olua_endinvoke(L);

    return 0;
}

static int _example_Const___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Const *)olua_toobj(L, 1, "example.Const");
    olua_push_object(L, self, "example.Const");

    olua_endinvoke(L);

    return 1;
}

static int _example_Const_get_CONST_CHAR(lua_State *L)
{
    olua_startinvoke(L);

    // static const char *CONST_CHAR
    const char *ret = example::Const::CONST_CHAR;
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Const_set_CONST_CHAR(lua_State *L)
{
    olua_startinvoke(L);

    const char *arg1 = nullptr;       /** CONST_CHAR */

    olua_check_string(L, 1, &arg1);

    // static const char *CONST_CHAR
    example::Const::CONST_CHAR = arg1;

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Const(lua_State *L)
{
    oluacls_class<example::Const>(L, "example.Const");
    oluacls_func(L, "__gc", _example_Const___gc);
    oluacls_func(L, "__olua_move", _example_Const___olua_move);
    oluacls_prop(L, "CONST_CHAR", _example_Const_get_CONST_CHAR, _example_Const_set_CONST_CHAR);
    oluacls_const(L, "BOOL", example::Const::BOOL);
    oluacls_const(L, "CHAR", example::Const::CHAR);
    oluacls_const(L, "DOUBLE", example::Const::DOUBLE);
    oluacls_const(L, "ENUM", example::Const::ENUM);
    oluacls_const(L, "FLOAT", example::Const::FLOAT);
    oluacls_const(L, "INT", example::Const::INT);
    oluacls_const(L, "LDOUBLE", example::Const::LDOUBLE);
    oluacls_const(L, "LLONG", example::Const::LLONG);
    oluacls_const(L, "LONG", example::Const::LONG);
    oluacls_const(L, "POINT", &example::Const::POINT);
    oluacls_const(L, "SHORT", example::Const::SHORT);
    oluacls_const(L, "STRING", example::Const::STRING);
    oluacls_const(L, "UCHAR", example::Const::UCHAR);
    oluacls_const(L, "UINT", example::Const::UINT);
    oluacls_const(L, "ULLONG", example::Const::ULLONG);
    oluacls_const(L, "ULONG", example::Const::ULONG);
    oluacls_const(L, "USHORT", example::Const::USHORT);

    return 1;
}
OLUA_END_DECLS

static int _example_SharedHello___gc(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::SharedHello *)olua_toobj(L, 1, "example.SharedHello");
    olua_postgc(L, self);

    olua_endinvoke(L);

    return 0;
}

static int _example_SharedHello___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::SharedHello *)olua_toobj(L, 1, "example.SharedHello");
    olua_push_object(L, self, "example.SharedHello");

    olua_endinvoke(L);

    return 1;
}

static int _example_SharedHello_getName(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // const std::string &getName()
    const std::string &ret = self->getName();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_SharedHello_getThis(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // std::shared_ptr<example::SharedHello> getThis()
    std::shared_ptr<example::SharedHello> ret = self->getThis();
    int num_ret = olua_push_object(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_SharedHello_getWeakPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // std::weak_ptr<example::SharedHello> getWeakPtr()
    std::weak_ptr<example::SharedHello> ret = self->getWeakPtr();
    int num_ret = olua_push_object(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_SharedHello_create(lua_State *L)
{
    olua_startinvoke(L);

    // @name(new) static std::shared_ptr<example::SharedHello> create()
    std::shared_ptr<example::SharedHello> ret = example::SharedHello::create();
    int num_ret = olua_push_object(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_SharedHello_say(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // void say()
    self->say();

    olua_endinvoke(L);

    return 0;
}

static int _example_SharedHello_setThis(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;
    std::shared_ptr<example::SharedHello> arg1;       /** sp */

    olua_to_object(L, 1, &self, "example.SharedHello");
    olua_check_object(L, 2, &arg1, "example.SharedHello");

    // void setThis(const std::shared_ptr<example::SharedHello> &sp)
    self->setThis(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_SharedHello_shared_from_this(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // @copyfrom(std::enable_shared_from_this) std::shared_ptr<example::SharedHello> shared_from_this()
    std::shared_ptr<example::SharedHello> ret = self->shared_from_this();
    int num_ret = olua_push_object(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_SharedHello(lua_State *L)
{
    oluacls_class<example::SharedHello>(L, "example.SharedHello");
    oluacls_func(L, "__gc", _example_SharedHello___gc);
    oluacls_func(L, "__olua_move", _example_SharedHello___olua_move);
    oluacls_func(L, "getName", _example_SharedHello_getName);
    oluacls_func(L, "getThis", _example_SharedHello_getThis);
    oluacls_func(L, "getWeakPtr", _example_SharedHello_getWeakPtr);
    oluacls_func(L, "new", _example_SharedHello_create);
    oluacls_func(L, "say", _example_SharedHello_say);
    oluacls_func(L, "setThis", _example_SharedHello_setThis);
    oluacls_func(L, "shared_from_this", _example_SharedHello_shared_from_this);
    oluacls_prop(L, "name", _example_SharedHello_getName, nullptr);
    oluacls_prop(L, "this", _example_SharedHello_getThis, _example_SharedHello_setThis);
    oluacls_prop(L, "weakPtr", _example_SharedHello_getWeakPtr, nullptr);

    return 1;
}
OLUA_END_DECLS

static int _example_NoGC___gc(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::NoGC *)olua_toobj(L, 1, "example.NoGC");
    olua_postgc(L, self);

    olua_endinvoke(L);

    return 0;
}

static int _example_NoGC___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::NoGC *)olua_toobj(L, 1, "example.NoGC");
    olua_push_object(L, self, "example.NoGC");

    olua_endinvoke(L);

    return 1;
}

static int _example_NoGC_create(lua_State *L)
{
    olua_startinvoke(L);

    // static example::NoGC *create()
    example::NoGC *ret = example::NoGC::create();
    int num_ret = olua_push_object(L, ret, "example.NoGC");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_NoGC_new(lua_State *L)
{
    olua_startinvoke(L);

    int arg1 = 0;       /** i */
    std::function<int (example::NoGC *)> arg2;       /** callbak */

    olua_check_integer(L, 1, &arg1);
    olua_check_callback(L, 2, &arg2, "std.function");

    void *cb_store = (void *)olua_newobjstub(L, "example.NoGC");
    std::string cb_tag = "NoGC";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg2 = [cb_store, cb_name, cb_ctx](example::NoGC *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        int ret = 0;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.NoGC");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            if (olua_is_integer(L, -1)) {
                olua_check_integer(L, -1, &ret);
            }

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
        return ret;
    };

    // NoGC(int i, @localvar const std::function<int (example::NoGC *)> &callbak)
    example::NoGC *ret = new example::NoGC(arg1, arg2);
    if (olua_pushobjstub(L, ret, cb_store, "example.NoGC") == OLUA_OBJ_EXIST) {
        olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_EQUAL);
        lua_pushstring(L, cb_name.c_str());
        lua_pushvalue(L, 2);
        olua_setvariable(L, -3);
    } else {
        olua_postnew(L, ret);
    };
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_NoGC(lua_State *L)
{
    oluacls_class<example::NoGC>(L, "example.NoGC");
    oluacls_func(L, "__gc", _example_NoGC___gc);
    oluacls_func(L, "__olua_move", _example_NoGC___olua_move);
    oluacls_func(L, "create", _example_NoGC_create);
    oluacls_func(L, "new", _example_NoGC_new);

    return 1;
}
OLUA_END_DECLS

static int _example_Singleton_example_Hello___gc(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Singleton<example::Hello> *)olua_toobj(L, 1, "example.Singleton<example.Hello>");
    olua_postgc(L, self);

    olua_endinvoke(L);

    return 0;
}

static int _example_Singleton_example_Hello___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Singleton<example::Hello> *)olua_toobj(L, 1, "example.Singleton<example.Hello>");
    olua_push_object(L, self, "example.Singleton<example.Hello>");

    olua_endinvoke(L);

    return 1;
}

static int _example_Singleton_example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // static example::Hello *create()
    example::Hello *ret = example::Singleton<example::Hello>::create();
    int num_ret = olua_push_object(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Singleton_example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Singleton<example::Hello> *self = nullptr;

    olua_to_object(L, 1, &self, "example.Singleton<example.Hello>");

    // void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Singleton_example_Hello(lua_State *L)
{
    oluacls_class<example::Singleton<example::Hello>>(L, "example.Singleton<example.Hello>");
    oluacls_func(L, "__gc", _example_Singleton_example_Hello___gc);
    oluacls_func(L, "__olua_move", _example_Singleton_example_Hello___olua_move);
    oluacls_func(L, "create", _example_Singleton_example_Hello_create);
    oluacls_func(L, "printSingleton", _example_Singleton_example_Hello_printSingleton);

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, "example.Object", luaopen_example_Object);
    olua_require(L, "example.ExportParent", luaopen_example_ExportParent);
    olua_require(L, "example.VectorInt", luaopen_example_VectorInt);
    olua_require(L, "example.VectorPoint", luaopen_example_VectorPoint);
    olua_require(L, "example.VectorString", luaopen_example_VectorString);
    olua_require(L, "example.PointArray", luaopen_example_PointArray);
    olua_require(L, "example.ClickCallback", luaopen_example_ClickCallback);
    olua_require(L, "example.Type", luaopen_example_Type);
    olua_require(L, "example.Point", luaopen_example_Point);
    olua_require(L, "example.Hello", luaopen_example_Hello);
    olua_require(L, "example.Const", luaopen_example_Const);
    olua_require(L, "example.SharedHello", luaopen_example_SharedHello);
    olua_require(L, "example.NoGC", luaopen_example_NoGC);
    olua_require(L, "example.Singleton<example.Hello>", luaopen_example_Singleton_example_Hello);

    return 0;
}
OLUA_END_DECLS
