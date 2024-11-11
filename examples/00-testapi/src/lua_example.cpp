//
// AUTO GENERATED, DO NOT MODIFY!
//
#include "lua_example.h"

static int _olua_module_example(lua_State *L);

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

OLUA_LIB void olua_check_table(lua_State *L, int idx, example::Point *value)
{
    float arg1 = 0;       /** x */
    float arg2 = 0;       /** y */

    olua_getfield(L, idx, "x");
    olua_check_number(L, -1, &arg1);
    value->x = arg1;
    lua_pop(L, 1);

    olua_getfield(L, idx, "y");
    olua_check_number(L, -1, &arg2);
    value->y = arg2;
    lua_pop(L, 1);
}

OLUA_LIB bool olua_is_table(lua_State *L, int idx, example::Point *)
{
    return olua_hasfield(L, idx, "y") && olua_hasfield(L, idx, "x");
}


static int _olua_fun_example_Object___gc(lua_State *L)
{
    olua_startinvoke(L);
    olua_endinvoke(L);
    return olua_objgc(L);
}

static int _olua_fun_example_Object_autorelease(lua_State *L)
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

static int _olua_fun_example_Object_getReferenceCount(lua_State *L)
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

static int _olua_fun_example_Object_new(lua_State *L)
{
    olua_startinvoke(L);

    // example::Object()
    example::Object *ret = new example::Object();
    int num_ret = olua_push_object(L, ret, "example.Object");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_cls_example_Object(lua_State *L)
{
    oluacls_class<example::Object>(L, "example.Object");
    oluacls_func(L, "__gc", _olua_fun_example_Object___gc);
    oluacls_func(L, "autorelease", _olua_fun_example_Object_autorelease);
    oluacls_func(L, "getReferenceCount", _olua_fun_example_Object_getReferenceCount);
    oluacls_func(L, "new", _olua_fun_example_Object_new);
    oluacls_prop(L, "referenceCount", _olua_fun_example_Object_getReferenceCount, nullptr);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Object(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Object")) {
        luaL_error(L, "class not found: example::Object");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_ExportParent_printExportParent(lua_State *L)
{
    olua_startinvoke(L);

    example::ExportParent *self = nullptr;

    olua_to_object(L, 1, &self, "example.ExportParent");

    // void printExportParent()
    self->printExportParent();

    olua_endinvoke(L);

    return 0;
}

static int _olua_cls_example_ExportParent(lua_State *L)
{
    oluacls_class<example::ExportParent, example::Object>(L, "example.ExportParent");
    oluacls_func(L, "printExportParent", _olua_fun_example_ExportParent_printExportParent);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ExportParent(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.ExportParent")) {
        luaL_error(L, "class not found: example::ExportParent");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_VectorInt___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_VectorInt___index(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    unsigned int arg1 = 0;       /** idx */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);

    // std::vector<int> __index(unsigned int idx)
    std::vector<int> ret = self->__index(arg1);
    int num_ret = olua_push_array<int>(L, ret, [L](int &arg1) {
        olua_push_integer(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt___newindex(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    unsigned int arg1 = 0;       /** idx */
    std::vector<int> arg2;       /** v */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);
    olua_check_array<int>(L, 3, arg2, [L](int *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // void __newindex(unsigned int idx, const std::vector<int> &v)
    self->__newindex(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_VectorInt_buffer(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter @type(void *) std::vector<int> *buffer()
    void *ret = self->buffer();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_length(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_new$1(lua_State *L)
{
    olua_startinvoke(L);

    size_t arg1 = 0;       /** len */

    olua_check_integer(L, 1, &arg1);

    // example::VectorInt(@optional size_t len)
    example::VectorInt *ret = new example::VectorInt(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_new$2(lua_State *L)
{
    olua_startinvoke(L);

    // example::VectorInt()
    example::VectorInt *ret = new example::VectorInt();
    int num_ret = olua_push_object(L, ret, "example.VectorInt");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_new$3(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<int> *arg1 = nullptr;       /** v */
    size_t arg2 = 0;       /** len */

    olua_check_pointer(L, 1, &arg1, "example.VectorInt");
    olua_check_integer(L, 2, &arg2);

    // example::VectorInt(std::vector<int> *v, @optional size_t len)
    example::VectorInt *ret = new example::VectorInt(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_new$4(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<int> *arg1 = nullptr;       /** v */

    olua_check_pointer(L, 1, &arg1, "example.VectorInt");

    // example::VectorInt(std::vector<int> *v)
    example::VectorInt *ret = new example::VectorInt(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_new(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // example::VectorInt()
        return _olua_fun_example_VectorInt_new$2(L);
    }

    if (num_args == 1) {
        if ((olua_is_integer(L, 1))) {
            // example::VectorInt(@optional size_t len)
            return _olua_fun_example_VectorInt_new$1(L);
        }

        // if ((olua_is_pointer(L, 1, "example.VectorInt"))) {
            // example::VectorInt(std::vector<int> *v)
            return _olua_fun_example_VectorInt_new$4(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_pointer(L, 1, "example.VectorInt")) && (olua_is_integer(L, 2))) {
            // example::VectorInt(std::vector<int> *v, @optional size_t len)
            return _olua_fun_example_VectorInt_new$3(L);
        // }
    }

    luaL_error(L, "method 'example::VectorInt::new' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorInt_slice$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::VectorInt *slice(size_t from, @optional size_t to)
    example::VectorInt *ret = self->slice(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_slice$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::VectorInt *slice(size_t from)
    example::VectorInt *ret = self->slice(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_slice(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorInt")) && (olua_is_integer(L, 2))) {
            // @postnew example::VectorInt *slice(size_t from)
            return _olua_fun_example_VectorInt_slice$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.VectorInt")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::VectorInt *slice(size_t from, @optional size_t to)
            return _olua_fun_example_VectorInt_slice$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorInt::slice' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorInt_sub$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::VectorInt *sub(size_t from, @optional size_t to)
    example::VectorInt *ret = self->sub(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_sub$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::VectorInt *sub(size_t from)
    example::VectorInt *ret = self->sub(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_sub(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorInt")) && (olua_is_integer(L, 2))) {
            // @postnew example::VectorInt *sub(size_t from)
            return _olua_fun_example_VectorInt_sub$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.VectorInt")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::VectorInt *sub(size_t from, @optional size_t to)
            return _olua_fun_example_VectorInt_sub$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorInt::sub' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorInt_take(lua_State *L)
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

static int _olua_fun_example_VectorInt_tostring(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);

    // olua_Return tostring(lua_State *L, size_t len)
    olua_Return ret = self->tostring(L, arg1);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_VectorInt_value$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter const std::vector<int> &value()
    const std::vector<int> &ret = self->value();
    int num_ret = olua_push_array<int>(L, ret, [L](int &arg1) {
        olua_push_integer(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorInt_value$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    std::vector<int> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_array<int>(L, 2, arg1, [L](int *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // @setter void value(const std::vector<int> &v)
    self->value(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_VectorInt_value(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // @getter const std::vector<int> &value()
        return _olua_fun_example_VectorInt_value$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorInt")) && (olua_is_array(L, 2))) {
            // @setter void value(const std::vector<int> &v)
            return _olua_fun_example_VectorInt_value$2(L);
        // }
    }

    luaL_error(L, "method 'example::VectorInt::value' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_cls_example_VectorInt(lua_State *L)
{
    oluacls_class<example::VectorInt>(L, "example.VectorInt");
    oluacls_func(L, "__gc", _olua_fun_example_VectorInt___gc);
    oluacls_func(L, "__index", _olua_fun_example_VectorInt___index);
    oluacls_func(L, "__newindex", _olua_fun_example_VectorInt___newindex);
    oluacls_func(L, "new", _olua_fun_example_VectorInt_new);
    oluacls_func(L, "slice", _olua_fun_example_VectorInt_slice);
    oluacls_func(L, "sub", _olua_fun_example_VectorInt_sub);
    oluacls_func(L, "take", _olua_fun_example_VectorInt_take);
    oluacls_func(L, "tostring", _olua_fun_example_VectorInt_tostring);
    oluacls_prop(L, "buffer", _olua_fun_example_VectorInt_buffer, nullptr);
    oluacls_prop(L, "length", _olua_fun_example_VectorInt_length, nullptr);
    oluacls_prop(L, "value", _olua_fun_example_VectorInt_value, _olua_fun_example_VectorInt_value);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_VectorInt(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.VectorInt")) {
        luaL_error(L, "class not found: example::VectorInt");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_VectorPoint___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_VectorPoint___index(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    unsigned int arg1 = 0;       /** idx */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_integer(L, 2, &arg1);

    // std::vector<example::Point> __index(unsigned int idx)
    std::vector<example::Point> ret = self->__index(arg1);
    int num_ret = olua_push_array<example::Point>(L, ret, [L](example::Point &arg1) {
        olua_copy_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint___newindex(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    unsigned int arg1 = 0;       /** idx */
    std::vector<example::Point> arg2;       /** v */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_integer(L, 2, &arg1);
    olua_check_array<example::Point>(L, 3, arg2, [L](example::Point *arg1) {
        if (olua_istable(L, -1)) {
            olua_check_table(L, -1, arg1);
        } else {
            olua_check_object(L, -1, arg1, "example.Point");
        }
    });

    // void __newindex(unsigned int idx, const std::vector<example::Point> &v)
    self->__newindex(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_VectorPoint_buffer(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // @getter @type(void *) std::vector<example::Point> *buffer()
    void *ret = self->buffer();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_length(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_new$1(lua_State *L)
{
    olua_startinvoke(L);

    size_t arg1 = 0;       /** len */

    olua_check_integer(L, 1, &arg1);

    // example::VectorPoint(@optional size_t len)
    example::VectorPoint *ret = new example::VectorPoint(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_new$2(lua_State *L)
{
    olua_startinvoke(L);

    // example::VectorPoint()
    example::VectorPoint *ret = new example::VectorPoint();
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_new$3(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<example::Point> *arg1 = nullptr;       /** v */
    size_t arg2 = 0;       /** len */

    olua_check_pointer(L, 1, &arg1, "example.VectorPoint");
    olua_check_integer(L, 2, &arg2);

    // example::VectorPoint(std::vector<example::Point> *v, @optional size_t len)
    example::VectorPoint *ret = new example::VectorPoint(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_new$4(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<example::Point> *arg1 = nullptr;       /** v */

    olua_check_pointer(L, 1, &arg1, "example.VectorPoint");

    // example::VectorPoint(std::vector<example::Point> *v)
    example::VectorPoint *ret = new example::VectorPoint(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_new(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // example::VectorPoint()
        return _olua_fun_example_VectorPoint_new$2(L);
    }

    if (num_args == 1) {
        if ((olua_is_integer(L, 1))) {
            // example::VectorPoint(@optional size_t len)
            return _olua_fun_example_VectorPoint_new$1(L);
        }

        // if ((olua_is_pointer(L, 1, "example.VectorPoint"))) {
            // example::VectorPoint(std::vector<example::Point> *v)
            return _olua_fun_example_VectorPoint_new$4(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_pointer(L, 1, "example.VectorPoint")) && (olua_is_integer(L, 2))) {
            // example::VectorPoint(std::vector<example::Point> *v, @optional size_t len)
            return _olua_fun_example_VectorPoint_new$3(L);
        // }
    }

    luaL_error(L, "method 'example::VectorPoint::new' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorPoint_slice$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::VectorPoint *slice(size_t from, @optional size_t to)
    example::VectorPoint *ret = self->slice(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_slice$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::VectorPoint *slice(size_t from)
    example::VectorPoint *ret = self->slice(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_slice(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorPoint")) && (olua_is_integer(L, 2))) {
            // @postnew example::VectorPoint *slice(size_t from)
            return _olua_fun_example_VectorPoint_slice$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.VectorPoint")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::VectorPoint *slice(size_t from, @optional size_t to)
            return _olua_fun_example_VectorPoint_slice$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorPoint::slice' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorPoint_sub$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::VectorPoint *sub(size_t from, @optional size_t to)
    example::VectorPoint *ret = self->sub(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_sub$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::VectorPoint *sub(size_t from)
    example::VectorPoint *ret = self->sub(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorPoint");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_sub(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorPoint")) && (olua_is_integer(L, 2))) {
            // @postnew example::VectorPoint *sub(size_t from)
            return _olua_fun_example_VectorPoint_sub$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.VectorPoint")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::VectorPoint *sub(size_t from, @optional size_t to)
            return _olua_fun_example_VectorPoint_sub$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorPoint::sub' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorPoint_take(lua_State *L)
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

static int _olua_fun_example_VectorPoint_tostring(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    size_t arg1 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_integer(L, 2, &arg1);

    // olua_Return tostring(lua_State *L, size_t len)
    olua_Return ret = self->tostring(L, arg1);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_VectorPoint_value$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorPoint");

    // @getter const std::vector<example::Point> &value()
    const std::vector<example::Point> &ret = self->value();
    int num_ret = olua_push_array<example::Point>(L, ret, [L](example::Point &arg1) {
        olua_copy_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorPoint_value$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorPoint *self = nullptr;
    std::vector<example::Point> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.VectorPoint");
    olua_check_array<example::Point>(L, 2, arg1, [L](example::Point *arg1) {
        if (olua_istable(L, -1)) {
            olua_check_table(L, -1, arg1);
        } else {
            olua_check_object(L, -1, arg1, "example.Point");
        }
    });

    // @setter void value(const std::vector<example::Point> &v)
    self->value(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_VectorPoint_value(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // @getter const std::vector<example::Point> &value()
        return _olua_fun_example_VectorPoint_value$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorPoint")) && (olua_is_array(L, 2))) {
            // @setter void value(const std::vector<example::Point> &v)
            return _olua_fun_example_VectorPoint_value$2(L);
        // }
    }

    luaL_error(L, "method 'example::VectorPoint::value' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_cls_example_VectorPoint(lua_State *L)
{
    oluacls_class<example::VectorPoint>(L, "example.VectorPoint");
    oluacls_func(L, "__gc", _olua_fun_example_VectorPoint___gc);
    oluacls_func(L, "__index", _olua_fun_example_VectorPoint___index);
    oluacls_func(L, "__newindex", _olua_fun_example_VectorPoint___newindex);
    oluacls_func(L, "new", _olua_fun_example_VectorPoint_new);
    oluacls_func(L, "slice", _olua_fun_example_VectorPoint_slice);
    oluacls_func(L, "sub", _olua_fun_example_VectorPoint_sub);
    oluacls_func(L, "take", _olua_fun_example_VectorPoint_take);
    oluacls_func(L, "tostring", _olua_fun_example_VectorPoint_tostring);
    oluacls_prop(L, "buffer", _olua_fun_example_VectorPoint_buffer, nullptr);
    oluacls_prop(L, "length", _olua_fun_example_VectorPoint_length, nullptr);
    oluacls_prop(L, "value", _olua_fun_example_VectorPoint_value, _olua_fun_example_VectorPoint_value);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_VectorPoint(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.VectorPoint")) {
        luaL_error(L, "class not found: example::VectorPoint");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_VectorString___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_VectorString___index(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    unsigned int arg1 = 0;       /** idx */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_integer(L, 2, &arg1);

    // std::vector<std::string> __index(unsigned int idx)
    std::vector<std::string> ret = self->__index(arg1);
    int num_ret = olua_push_array<std::string>(L, ret, [L](std::string &arg1) {
        olua_push_string(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString___newindex(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    unsigned int arg1 = 0;       /** idx */
    std::vector<std::string> arg2;       /** v */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_integer(L, 2, &arg1);
    olua_check_array<std::string>(L, 3, arg2, [L](std::string *arg1) {
        olua_check_string(L, -1, arg1);
    });

    // void __newindex(unsigned int idx, const std::vector<std::string> &v)
    self->__newindex(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_VectorString_buffer(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // @getter @type(void *) std::vector<std::string> *buffer()
    void *ret = self->buffer();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_length(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_new$1(lua_State *L)
{
    olua_startinvoke(L);

    size_t arg1 = 0;       /** len */

    olua_check_integer(L, 1, &arg1);

    // example::VectorString(@optional size_t len)
    example::VectorString *ret = new example::VectorString(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorString");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_new$2(lua_State *L)
{
    olua_startinvoke(L);

    // example::VectorString()
    example::VectorString *ret = new example::VectorString();
    int num_ret = olua_push_object(L, ret, "example.VectorString");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_new$3(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<std::string> *arg1 = nullptr;       /** v */
    size_t arg2 = 0;       /** len */

    olua_check_pointer(L, 1, &arg1, "example.VectorString");
    olua_check_integer(L, 2, &arg2);

    // example::VectorString(std::vector<std::string> *v, @optional size_t len)
    example::VectorString *ret = new example::VectorString(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorString");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_new$4(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<std::string> *arg1 = nullptr;       /** v */

    olua_check_pointer(L, 1, &arg1, "example.VectorString");

    // example::VectorString(std::vector<std::string> *v)
    example::VectorString *ret = new example::VectorString(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorString");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_new(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // example::VectorString()
        return _olua_fun_example_VectorString_new$2(L);
    }

    if (num_args == 1) {
        if ((olua_is_integer(L, 1))) {
            // example::VectorString(@optional size_t len)
            return _olua_fun_example_VectorString_new$1(L);
        }

        // if ((olua_is_pointer(L, 1, "example.VectorString"))) {
            // example::VectorString(std::vector<std::string> *v)
            return _olua_fun_example_VectorString_new$4(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_pointer(L, 1, "example.VectorString")) && (olua_is_integer(L, 2))) {
            // example::VectorString(std::vector<std::string> *v, @optional size_t len)
            return _olua_fun_example_VectorString_new$3(L);
        // }
    }

    luaL_error(L, "method 'example::VectorString::new' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorString_slice$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::VectorString *slice(size_t from, @optional size_t to)
    example::VectorString *ret = self->slice(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorString");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_slice$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::VectorString *slice(size_t from)
    example::VectorString *ret = self->slice(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorString");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_slice(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorString")) && (olua_is_integer(L, 2))) {
            // @postnew example::VectorString *slice(size_t from)
            return _olua_fun_example_VectorString_slice$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.VectorString")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::VectorString *slice(size_t from, @optional size_t to)
            return _olua_fun_example_VectorString_slice$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorString::slice' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorString_sub$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::VectorString *sub(size_t from, @optional size_t to)
    example::VectorString *ret = self->sub(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorString");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_sub$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::VectorString *sub(size_t from)
    example::VectorString *ret = self->sub(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorString");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_sub(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorString")) && (olua_is_integer(L, 2))) {
            // @postnew example::VectorString *sub(size_t from)
            return _olua_fun_example_VectorString_sub$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.VectorString")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::VectorString *sub(size_t from, @optional size_t to)
            return _olua_fun_example_VectorString_sub$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorString::sub' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_VectorString_take(lua_State *L)
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

static int _olua_fun_example_VectorString_tostring(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    size_t arg1 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_integer(L, 2, &arg1);

    // olua_Return tostring(lua_State *L, size_t len)
    olua_Return ret = self->tostring(L, arg1);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_VectorString_value$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorString");

    // @getter const std::vector<std::string> &value()
    const std::vector<std::string> &ret = self->value();
    int num_ret = olua_push_array<std::string>(L, ret, [L](std::string &arg1) {
        olua_push_string(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_VectorString_value$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorString *self = nullptr;
    std::vector<std::string> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.VectorString");
    olua_check_array<std::string>(L, 2, arg1, [L](std::string *arg1) {
        olua_check_string(L, -1, arg1);
    });

    // @setter void value(const std::vector<std::string> &v)
    self->value(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_VectorString_value(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // @getter const std::vector<std::string> &value()
        return _olua_fun_example_VectorString_value$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.VectorString")) && (olua_is_array(L, 2))) {
            // @setter void value(const std::vector<std::string> &v)
            return _olua_fun_example_VectorString_value$2(L);
        // }
    }

    luaL_error(L, "method 'example::VectorString::value' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_cls_example_VectorString(lua_State *L)
{
    oluacls_class<example::VectorString>(L, "example.VectorString");
    oluacls_func(L, "__gc", _olua_fun_example_VectorString___gc);
    oluacls_func(L, "__index", _olua_fun_example_VectorString___index);
    oluacls_func(L, "__newindex", _olua_fun_example_VectorString___newindex);
    oluacls_func(L, "new", _olua_fun_example_VectorString_new);
    oluacls_func(L, "slice", _olua_fun_example_VectorString_slice);
    oluacls_func(L, "sub", _olua_fun_example_VectorString_sub);
    oluacls_func(L, "take", _olua_fun_example_VectorString_take);
    oluacls_func(L, "tostring", _olua_fun_example_VectorString_tostring);
    oluacls_prop(L, "buffer", _olua_fun_example_VectorString_buffer, nullptr);
    oluacls_prop(L, "length", _olua_fun_example_VectorString_length, nullptr);
    oluacls_prop(L, "value", _olua_fun_example_VectorString_value, _olua_fun_example_VectorString_value);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_VectorString(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.VectorString")) {
        luaL_error(L, "class not found: example::VectorString");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_PointArray___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_PointArray___index(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    unsigned int arg1 = 0;       /** idx */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);

    // example::Point __index(unsigned int idx)
    example::Point ret = self->__index(arg1);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray___newindex(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    unsigned int arg1 = 0;       /** idx */
    example::Point *arg2;       /** v */
    example::Point arg2_from_table;       /** v */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);
    if (olua_istable(L, 3)) {
        olua_check_table(L, 3, &arg2_from_table);
        arg2 = &arg2_from_table;
    } else {
        olua_check_object(L, 3, &arg2, "example.Point");
    }

    // void __newindex(unsigned int idx, const example::Point &v)
    self->__newindex(arg1, *arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_PointArray_buffer(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter @type(void *) example::Point *buffer()
    void *ret = self->buffer();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_length(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter size_t length()
    size_t ret = self->length();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_new$1(lua_State *L)
{
    olua_startinvoke(L);

    size_t arg1 = 0;       /** len */

    olua_check_integer(L, 1, &arg1);

    // example::PointArray(@optional size_t len)
    example::PointArray *ret = new example::PointArray(arg1);
    int num_ret = olua_push_object(L, ret, "example.PointArray");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_new$2(lua_State *L)
{
    olua_startinvoke(L);

    // example::PointArray()
    example::PointArray *ret = new example::PointArray();
    int num_ret = olua_push_object(L, ret, "example.PointArray");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_new$3(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *arg1 = nullptr;       /** v */
    size_t arg2 = 0;       /** len */

    olua_check_object(L, 1, &arg1, "example.Point");
    olua_check_integer(L, 2, &arg2);

    // example::PointArray(example::Point *v, @optional size_t len)
    example::PointArray *ret = new example::PointArray(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.PointArray");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_new$4(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *arg1 = nullptr;       /** v */

    olua_check_object(L, 1, &arg1, "example.Point");

    // example::PointArray(example::Point *v)
    example::PointArray *ret = new example::PointArray(arg1);
    int num_ret = olua_push_object(L, ret, "example.PointArray");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_new(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // example::PointArray()
        return _olua_fun_example_PointArray_new$2(L);
    }

    if (num_args == 1) {
        if ((olua_is_object(L, 1, "example.Point"))) {
            // example::PointArray(example::Point *v)
            return _olua_fun_example_PointArray_new$4(L);
        }

        // if ((olua_is_integer(L, 1))) {
            // example::PointArray(@optional size_t len)
            return _olua_fun_example_PointArray_new$1(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Point")) && (olua_is_integer(L, 2))) {
            // example::PointArray(example::Point *v, @optional size_t len)
            return _olua_fun_example_PointArray_new$3(L);
        // }
    }

    luaL_error(L, "method 'example::PointArray::new' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_PointArray_slice$1(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // @postnew example::PointArray *slice(size_t from, @optional size_t to)
    example::PointArray *ret = self->slice(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_slice$2(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::PointArray *slice(size_t from)
    example::PointArray *ret = self->slice(arg1);
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_slice(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.PointArray")) && (olua_is_integer(L, 2))) {
            // @postnew example::PointArray *slice(size_t from)
            return _olua_fun_example_PointArray_slice$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.PointArray")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::PointArray *slice(size_t from, @optional size_t to)
            return _olua_fun_example_PointArray_slice$1(L);
        // }
    }

    luaL_error(L, "method 'example::PointArray::slice' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_PointArray_sub$1(lua_State *L)
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

static int _olua_fun_example_PointArray_sub$2(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);

    // @postnew example::PointArray *sub(size_t from)
    example::PointArray *ret = self->sub(arg1);
    int num_ret = olua_push_object(L, ret, "example.PointArray");

    // insert code after call
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_sub(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.PointArray")) && (olua_is_integer(L, 2))) {
            // @postnew example::PointArray *sub(size_t from)
            return _olua_fun_example_PointArray_sub$2(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.PointArray")) && (olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // @postnew example::PointArray *sub(size_t from, @optional size_t to)
            return _olua_fun_example_PointArray_sub$1(L);
        // }
    }

    luaL_error(L, "method 'example::PointArray::sub' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_PointArray_take(lua_State *L)
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

static int _olua_fun_example_PointArray_tostring(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    size_t arg1 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.PointArray");
    olua_check_integer(L, 2, &arg1);

    // olua_Return tostring(lua_State *L, size_t len)
    olua_Return ret = self->tostring(L, arg1);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_PointArray_value$1(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;

    olua_to_object(L, 1, &self, "example.PointArray");

    // @getter const example::Point &value()
    const example::Point &ret = self->value();
    int num_ret = olua_push_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_PointArray_value$2(lua_State *L)
{
    olua_startinvoke(L);

    example::PointArray *self = nullptr;
    example::Point *arg1;       /** v */
    example::Point arg1_from_table;       /** v */

    olua_to_object(L, 1, &self, "example.PointArray");
    if (olua_istable(L, 2)) {
        olua_check_table(L, 2, &arg1_from_table);
        arg1 = &arg1_from_table;
    } else {
        olua_check_object(L, 2, &arg1, "example.Point");
    }

    // @setter void value(const example::Point &v)
    self->value(*arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_PointArray_value(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // @getter const example::Point &value()
        return _olua_fun_example_PointArray_value$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.PointArray")) && (olua_is_object(L, 2, "example.Point") || olua_is_table(L, 2, (example::Point *)nullptr))) {
            // @setter void value(const example::Point &v)
            return _olua_fun_example_PointArray_value$2(L);
        // }
    }

    luaL_error(L, "method 'example::PointArray::value' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_cls_example_PointArray(lua_State *L)
{
    oluacls_class<example::PointArray>(L, "example.PointArray");
    oluacls_func(L, "__gc", _olua_fun_example_PointArray___gc);
    oluacls_func(L, "__index", _olua_fun_example_PointArray___index);
    oluacls_func(L, "__newindex", _olua_fun_example_PointArray___newindex);
    oluacls_func(L, "new", _olua_fun_example_PointArray_new);
    oluacls_func(L, "slice", _olua_fun_example_PointArray_slice);
    oluacls_func(L, "sub", _olua_fun_example_PointArray_sub);
    oluacls_func(L, "take", _olua_fun_example_PointArray_take);
    oluacls_func(L, "tostring", _olua_fun_example_PointArray_tostring);
    oluacls_prop(L, "buffer", _olua_fun_example_PointArray_buffer, nullptr);
    oluacls_prop(L, "length", _olua_fun_example_PointArray_length, nullptr);
    oluacls_prop(L, "value", _olua_fun_example_PointArray_value, _olua_fun_example_PointArray_value);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_PointArray(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.PointArray")) {
        luaL_error(L, "class not found: example::PointArray");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_ClickCallback___call(lua_State *L)
{
    olua_startinvoke(L);
    luaL_checktype(L, -1, LUA_TFUNCTION);
    olua_push_callback(L, (example::ClickCallback *)nullptr, "example.ClickCallback");
    olua_endinvoke(L);
    return 1;
}

static int _olua_cls_example_ClickCallback(lua_State *L)
{
    oluacls_class<example::ClickCallback>(L, "example.ClickCallback");
    oluacls_func(L, "__call", _olua_fun_example_ClickCallback___call);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ClickCallback(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.ClickCallback")) {
        luaL_error(L, "class not found: example::ClickCallback");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_cls_example_Type(lua_State *L)
{
    oluacls_class<example::Type>(L, "example.Type");
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_enum(L, "LVALUE", (lua_Integer)example::Type::LVALUE);
    oluacls_enum(L, "POINTER", (lua_Integer)example::Type::POINTER);
    oluacls_enum(L, "RVALUE", (lua_Integer)example::Type::RVALUE);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Type(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Type")) {
        luaL_error(L, "class not found: example::Type");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_Point___add$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    example::Point *arg1;       /** p */
    example::Point arg1_from_table;       /** p */

    olua_to_object(L, 1, &self, "example.Point");
    if (olua_istable(L, 2)) {
        olua_check_table(L, 2, &arg1_from_table);
        arg1 = &arg1_from_table;
    } else {
        olua_check_object(L, 2, &arg1, "example.Point");
    }

    // @operator(operator+) example::Point operator+(const example::Point &p)
    example::Point ret = (*self) + (*arg1);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point___add$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *arg1;       /** p1 */
    example::Point arg1_from_table;       /** p1 */
    example::Point *arg2;       /** p2 */
    example::Point arg2_from_table;       /** p2 */

    if (olua_istable(L, 1)) {
        olua_check_table(L, 1, &arg1_from_table);
        arg1 = &arg1_from_table;
    } else {
        olua_check_object(L, 1, &arg1, "example.Point");
    }
    if (olua_istable(L, 2)) {
        olua_check_table(L, 2, &arg2_from_table);
        arg2 = &arg2_from_table;
    } else {
        olua_check_object(L, 2, &arg2, "example.Point");
    }

    // @operator(operator+) static example::Point operator+(const example::Point &p1, const example::Point &p2)
    example::Point ret = (*arg1) + (*arg2);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point___add(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        if ((olua_is_object(L, 1, "example.Point")) && (olua_is_object(L, 2, "example.Point") || olua_is_table(L, 2, (example::Point *)nullptr))) {
            // @operator(operator+) example::Point operator+(const example::Point &p)
            return _olua_fun_example_Point___add$1(L);
        }

        // if ((olua_is_object(L, 1, "example.Point") || olua_is_table(L, 1, (example::Point *)nullptr)) && (olua_is_object(L, 2, "example.Point") || olua_is_table(L, 2, (example::Point *)nullptr))) {
            // @operator(operator+) static example::Point operator+(const example::Point &p1, const example::Point &p2)
            return _olua_fun_example_Point___add$2(L);
        // }
    }

    luaL_error(L, "method 'example::Point::__add' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Point___div(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** s */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // @operator(operator/) example::Point operator/(float s)
    example::Point ret = (*self) / (arg1);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point___eq(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *arg1;       /** p1 */
    example::Point arg1_from_table;       /** p1 */
    example::Point *arg2;       /** p2 */
    example::Point arg2_from_table;       /** p2 */

    if (olua_istable(L, 1)) {
        olua_check_table(L, 1, &arg1_from_table);
        arg1 = &arg1_from_table;
    } else {
        olua_check_object(L, 1, &arg1, "example.Point");
    }
    if (olua_istable(L, 2)) {
        olua_check_table(L, 2, &arg2_from_table);
        arg2 = &arg2_from_table;
    } else {
        olua_check_object(L, 2, &arg2, "example.Point");
    }

    // @operator(operator==) static bool operator==(const example::Point &p1, const example::Point &p2)
    bool ret = (*arg1) == (*arg2);
    int num_ret = olua_push_bool(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::Point *)olua_toobj(L, 1, "example.Point");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_fun_example_Point___mul(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** s */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // @operator(operator*) example::Point operator*(float s)
    example::Point ret = (*self) * (arg1);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point___sub(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    example::Point *arg1;       /** p */
    example::Point arg1_from_table;       /** p */

    olua_to_object(L, 1, &self, "example.Point");
    if (olua_istable(L, 2)) {
        olua_check_table(L, 2, &arg1_from_table);
        arg1 = &arg1_from_table;
    } else {
        olua_check_object(L, 2, &arg1, "example.Point");
    }

    // @operator(operator-) example::Point operator-(const example::Point &p)
    example::Point ret = (*self) - (*arg1);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point___tostring(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // olua_Return __tostring(lua_State *L)
    olua_Return ret = self->__tostring(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_Point___unm(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // @operator(operator-) example::Point operator-()
    example::Point ret = -(*self);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point_length(lua_State *L)
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

static int _olua_fun_example_Point_new$1(lua_State *L)
{
    olua_startinvoke(L);

    // example::Point()
    example::Point *ret = new example::Point();
    int num_ret = olua_push_object(L, ret, "example.Point");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point_new$2(lua_State *L)
{
    olua_startinvoke(L);

    float arg1 = 0;       /** x */
    float arg2 = 0;       /** y */

    olua_check_number(L, 1, &arg1);
    olua_check_number(L, 2, &arg2);

    // example::Point(float x, float y)
    example::Point *ret = new example::Point(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.Point");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point_new(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // example::Point()
        return _olua_fun_example_Point_new$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_number(L, 1)) && (olua_is_number(L, 2))) {
            // example::Point(float x, float y)
            return _olua_fun_example_Point_new$2(L);
        // }
    }

    luaL_error(L, "method 'example::Point::new' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Point_x$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // float x
    float ret = self->x;
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point_x$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** x */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // float x
    self->x = arg1;

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Point_x(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // float x
        return _olua_fun_example_Point_x$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Point")) && (olua_is_number(L, 2))) {
            // float x
            return _olua_fun_example_Point_x$2(L);
        // }
    }

    luaL_error(L, "method 'example::Point::x' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Point_y$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // float y
    float ret = self->y;
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point_y$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** y */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // float y
    self->y = arg1;

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Point_y(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // float y
        return _olua_fun_example_Point_y$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Point")) && (olua_is_number(L, 2))) {
            // float y
            return _olua_fun_example_Point_y$2(L);
        // }
    }

    luaL_error(L, "method 'example::Point::y' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_cls_example_Point(lua_State *L)
{
    oluacls_class<example::Point>(L, "example.Point");
    oluacls_func(L, "__add", _olua_fun_example_Point___add);
    oluacls_func(L, "__div", _olua_fun_example_Point___div);
    oluacls_func(L, "__eq", _olua_fun_example_Point___eq);
    oluacls_func(L, "__gc", _olua_fun_example_Point___gc);
    oluacls_func(L, "__mul", _olua_fun_example_Point___mul);
    oluacls_func(L, "__sub", _olua_fun_example_Point___sub);
    oluacls_func(L, "__tostring", _olua_fun_example_Point___tostring);
    oluacls_func(L, "__unm", _olua_fun_example_Point___unm);
    oluacls_func(L, "length", _olua_fun_example_Point_length);
    oluacls_func(L, "new", _olua_fun_example_Point_new);
    oluacls_prop(L, "x", _olua_fun_example_Point_x, _olua_fun_example_Point_x);
    oluacls_prop(L, "y", _olua_fun_example_Point_y, _olua_fun_example_Point_y);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Point(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Point")) {
        luaL_error(L, "class not found: example::Point");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_Hello_as(lua_State *L)
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

static int _olua_fun_example_Hello_checkString(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<std::string> *arg1 = nullptr;       /** arg1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "example.VectorString");

    // void checkString(std::vector<std::string> *arg1)
    self->checkString(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_checkVectorInt(lua_State *L)
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

static int _olua_fun_example_Hello_checkVectorPoint(lua_State *L)
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

static int _olua_fun_example_Hello_convertPoint$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Point *arg1;       /** p */
    example::Point arg1_from_table;       /** p */

    olua_to_object(L, 1, &self, "example.Hello");
    if (olua_istable(L, 2)) {
        olua_check_table(L, 2, &arg1_from_table);
        arg1 = &arg1_from_table;
    } else {
        olua_check_object(L, 2, &arg1, "example.Point");
    }

    // example::Point convertPoint(const example::Point &p)
    example::Point ret = self->convertPoint(*arg1);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_convertPoint$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Point arg1;       /** p */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_pack_object(L, 2, &arg1);

    // @unpack example::Point convertPoint(@pack const example::Point &p)
    example::Point ret = self->convertPoint(arg1);
    int num_ret = olua_unpack_object(L, &ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_convertPoint(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Point") || olua_is_table(L, 2, (example::Point *)nullptr))) {
            // example::Point convertPoint(const example::Point &p)
            return _olua_fun_example_Hello_convertPoint$1(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_canpack_object(L, 2, (example::Point *)nullptr))) {
            // @unpack example::Point convertPoint(@pack const example::Point &p)
            return _olua_fun_example_Hello_convertPoint$2(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::convertPoint' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // @copyfrom(example::Singleton) static example::Hello *create()
    example::Hello *ret = example::Hello::create();
    int num_ret = olua_push_object(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_doCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // void doCallback()
    self->doCallback();

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_getAliasHello(lua_State *L)
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

static int _olua_fun_example_Hello_getCGLchar(lua_State *L)
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

static int _olua_fun_example_Hello_getCName(lua_State *L)
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

static int _olua_fun_example_Hello_getCStrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<const char *> getCStrs()
    std::vector<const char *> ret = self->getCStrs();
    int num_ret = olua_push_array<const char *>(L, ret, [L](const char *arg1) {
        olua_push_string(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    int arg1 = 0;       /** arg */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_integer(L, 2, &arg1);

    void *cb_store = (void *)self;
    std::string cb_tag = "Callback";
    olua_getcallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_EQUAL);

    // std::function<int (example::Hello *, example::Point *)> getCallback(int arg)
    std::function<int (example::Hello *, example::Point *)> ret = self->getCallback(arg1);
    int num_ret = olua_push_callback(L, &ret, "std.function");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getDeque(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::deque<example::Hello *> getDeque()
    std::deque<example::Hello *> ret = self->getDeque();
    int num_ret = olua_push_array<example::Hello *>(L, ret, [L](example::Hello *arg1) {
        olua_push_object(L, arg1, "example.Hello");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getGLchar(lua_State *L)
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

static int _olua_fun_example_Hello_getGLvoid(lua_State *L)
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

static int _olua_fun_example_Hello_getID(lua_State *L)
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

static int _olua_fun_example_Hello_getIntPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // int *getIntPtr()
    int *ret = self->getIntPtr();
    int num_ret = olua_push_pointer(L, ret, "olua.int");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getIntPtrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<short *> getIntPtrs()
    std::vector<short *> ret = self->getIntPtrs();
    int num_ret = olua_push_array<short *>(L, ret, [L](short *arg1) {
        olua_push_pointer(L, arg1, "olua.short");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getIntRef(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    int *arg1 = nullptr;       /** ref */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "olua.int");

    // void getIntRef(int &ref)
    self->getIntRef(*arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_getInts(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<int64_t> getInts()
    std::vector<int64_t> ret = self->getInts();
    int num_ret = olua_push_array<int64_t>(L, ret, [L](int64_t &arg1) {
        olua_push_integer(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getName(lua_State *L)
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

static int _olua_fun_example_Hello_getPointers(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<example::Point *> getPointers()
    std::vector<example::Point *> ret = self->getPointers();
    int num_ret = olua_push_array<example::Point *>(L, ret, [L](example::Point *arg1) {
        olua_push_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getPoints(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<example::Point> getPoints()
    std::vector<example::Point> ret = self->getPoints();
    int num_ret = olua_push_array<example::Point>(L, ret, [L](example::Point &arg1) {
        olua_copy_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_getPtr(lua_State *L)
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

static int _olua_fun_example_Hello_getStringRef(lua_State *L)
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

static int _olua_fun_example_Hello_getType(lua_State *L)
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

static int _olua_fun_example_Hello_getVec2(lua_State *L)
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

static int _olua_fun_example_Hello_getVectorIntPtr(lua_State *L)
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

static int _olua_fun_example_Hello_getVoids(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<GLvoid *> getVoids()
    std::vector<GLvoid *> ret = self->getVoids();
    int num_ret = olua_push_array<GLvoid *>(L, ret, [L](GLvoid *arg1) {
        olua_push_object(L, arg1, "void *");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_load(lua_State *L)
{
    olua_startinvoke(L);

    std::string arg1;       /** path */
    std::function<std::string (example::Hello *, int)> arg2;       /** callback */

    olua_check_string(L, 1, &arg1);
    olua_check_callback(L, 2, &arg2, "std.function");

    void *cb_store = (void *)olua_pushclassobj(L, "example.Hello");
    std::string cb_tag = "load";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg2 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1, int cb_arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_push_integer(L, cb_arg2);
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

    // static int load(const std::string &path, const std::function<std::string (example::Hello *, int)> &callback)
    int ret = example::Hello::load(arg1, arg2);
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_new(lua_State *L)
{
    olua_startinvoke(L);

    // example::Hello()
    example::Hello *ret = new example::Hello();
    int num_ret = olua_push_object(L, ret, "example.Hello");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @copyfrom(example::Singleton) void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_read(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    olua_char_t *arg1 = nullptr;       /** result */
    size_t *arg2 = nullptr;       /** len */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "olua.char");
    olua_check_pointer(L, 3, &arg2, "olua.size_t");

    // void read(@type(olua_char_t *) char *result, size_t *len)
    self->read(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_readonlyInt(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @readonly int readonlyInt
    int ret = self->readonlyInt;
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Hello_run$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");

    // @variadic void run(example::Hello *obj)
    self->run(arg1, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Hello *arg1 = nullptr;       /** obj */
    example::Hello *arg2 = nullptr;       /** obj_$1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Hello");
    olua_check_object(L, 3, &arg2, "example.Hello");

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1)
    self->run(arg1, arg2, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$3(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2)
    self->run(arg1, arg2, arg3, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$4(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3)
    self->run(arg1, arg2, arg3, arg4, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$5(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4)
    self->run(arg1, arg2, arg3, arg4, arg5, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$6(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$7(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$8(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$9(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$10(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$11(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$12(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$13(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$14(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$15(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13, example::Hello *obj_$14)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$16(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13, example::Hello *obj_$14, example::Hello *obj_$15)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run$17(lua_State *L)
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

    // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13, example::Hello *obj_$14, example::Hello *obj_$15, example::Hello *obj_$16)
    self->run(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, nullptr);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_run(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello"))) {
            // @variadic void run(example::Hello *obj)
            return _olua_fun_example_Hello_run$1(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1)
            return _olua_fun_example_Hello_run$2(L);
        // }
    }

    if (num_args == 4) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2)
            return _olua_fun_example_Hello_run$3(L);
        // }
    }

    if (num_args == 5) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3)
            return _olua_fun_example_Hello_run$4(L);
        // }
    }

    if (num_args == 6) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4)
            return _olua_fun_example_Hello_run$5(L);
        // }
    }

    if (num_args == 7) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5)
            return _olua_fun_example_Hello_run$6(L);
        // }
    }

    if (num_args == 8) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6)
            return _olua_fun_example_Hello_run$7(L);
        // }
    }

    if (num_args == 9) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7)
            return _olua_fun_example_Hello_run$8(L);
        // }
    }

    if (num_args == 10) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8)
            return _olua_fun_example_Hello_run$9(L);
        // }
    }

    if (num_args == 11) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9)
            return _olua_fun_example_Hello_run$10(L);
        // }
    }

    if (num_args == 12) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10)
            return _olua_fun_example_Hello_run$11(L);
        // }
    }

    if (num_args == 13) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11)
            return _olua_fun_example_Hello_run$12(L);
        // }
    }

    if (num_args == 14) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12)
            return _olua_fun_example_Hello_run$13(L);
        // }
    }

    if (num_args == 15) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13)
            return _olua_fun_example_Hello_run$14(L);
        // }
    }

    if (num_args == 16) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello")) && (olua_is_object(L, 16, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13, example::Hello *obj_$14)
            return _olua_fun_example_Hello_run$15(L);
        // }
    }

    if (num_args == 17) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello")) && (olua_is_object(L, 16, "example.Hello")) && (olua_is_object(L, 17, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13, example::Hello *obj_$14, example::Hello *obj_$15)
            return _olua_fun_example_Hello_run$16(L);
        // }
    }

    if (num_args == 18) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_object(L, 2, "example.Hello")) && (olua_is_object(L, 3, "example.Hello")) && (olua_is_object(L, 4, "example.Hello")) && (olua_is_object(L, 5, "example.Hello")) && (olua_is_object(L, 6, "example.Hello")) && (olua_is_object(L, 7, "example.Hello")) && (olua_is_object(L, 8, "example.Hello")) && (olua_is_object(L, 9, "example.Hello")) && (olua_is_object(L, 10, "example.Hello")) && (olua_is_object(L, 11, "example.Hello")) && (olua_is_object(L, 12, "example.Hello")) && (olua_is_object(L, 13, "example.Hello")) && (olua_is_object(L, 14, "example.Hello")) && (olua_is_object(L, 15, "example.Hello")) && (olua_is_object(L, 16, "example.Hello")) && (olua_is_object(L, 17, "example.Hello")) && (olua_is_object(L, 18, "example.Hello"))) {
            // @variadic void run(example::Hello *obj, example::Hello *obj_$1, example::Hello *obj_$2, example::Hello *obj_$3, example::Hello *obj_$4, example::Hello *obj_$5, example::Hello *obj_$6, example::Hello *obj_$7, example::Hello *obj_$8, example::Hello *obj_$9, example::Hello *obj_$10, example::Hello *obj_$11, example::Hello *obj_$12, example::Hello *obj_$13, example::Hello *obj_$14, example::Hello *obj_$15, example::Hello *obj_$16)
            return _olua_fun_example_Hello_run$17(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::run' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Hello_setCGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    const GLchar *arg1 = nullptr;       /** arg1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setCGLchar(const GLchar *arg1)
    self->setCGLchar(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setCName(lua_State *L)
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

static int _olua_fun_example_Hello_setCStrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<const char *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<const char *>(L, 2, arg1, [L](const char **arg1) {
        olua_check_string(L, -1, arg1);
    });

    // void setCStrs(const std::vector<const char *> &v)
    self->setCStrs(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<int (example::Hello *, example::Point *)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "Callback";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1, example::Point *cb_arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        int ret = 0;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_push_object(L, cb_arg2, "example.Point");
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

    // void setCallback(const std::function<int (example::Hello *, example::Point *)> &callback)
    self->setCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setClickCallback$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::ClickCallback arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "example.ClickCallback");

    void *cb_store = (void *)self;
    std::string cb_tag = "ClickCallback";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setClickCallback(const example::ClickCallback &callback)
    self->setClickCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setClickCallback$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<std::string (example::Hello *, int)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "ClickCallback";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1, int cb_arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_push_integer(L, cb_arg2);
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

    // void setClickCallback(const std::function<std::string (example::Hello *, int)> &callback)
    self->setClickCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setClickCallback(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_callback(L, 2, "example.ClickCallback"))) {
            // void setClickCallback(const example::ClickCallback &callback)
            return _olua_fun_example_Hello_setClickCallback$1(L);
        }

        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_callback(L, 2, "std.function"))) {
            // void setClickCallback(const std::function<std::string (example::Hello *, int)> &callback)
            return _olua_fun_example_Hello_setClickCallback$2(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::setClickCallback' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Hello_setDeque(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::deque<example::Hello *> arg1;       /** deque */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<example::Hello *>(L, 2, arg1, [L](example::Hello **arg1) {
        olua_check_object(L, -1, arg1, "example.Hello");
    });

    // void setDeque(const std::deque<example::Hello *> &deque)
    self->setDeque(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setDragCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<void (example::Hello *)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "DragCallback";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setDragCallback(const std::function<void (example::Hello *)> &callback)
    self->setDragCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLchar *arg1 = nullptr;       /** arg1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setGLchar(GLchar *arg1)
    self->setGLchar(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setGLfloat(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLfloat *arg1 = nullptr;       /** arg1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "olua.float");

    // void setGLfloat(GLfloat *arg1)
    self->setGLfloat(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setGLvoid(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLvoid *arg1 = nullptr;       /** arg1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "void *");

    // void setGLvoid(GLvoid *arg1)
    self->setGLvoid(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setID(lua_State *L)
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

static int _olua_fun_example_Hello_setIntPtrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<short *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<short *>(L, 2, arg1, [L](short **arg1) {
        olua_check_pointer(L, -1, arg1, "olua.short");
    });

    // void setIntPtrs(const std::vector<short *> &v)
    self->setIntPtrs(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setInts(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<int64_t> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<int64_t>(L, 2, arg1, [L](int64_t *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // void setInts(const std::vector<int64_t> &v)
    self->setInts(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setName(lua_State *L)
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

static int _olua_fun_example_Hello_setNotifyCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<std::string (example::Hello *, int)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "NotifyCallback";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1, int cb_arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_push_integer(L, cb_arg2);
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

    // void setNotifyCallback(const std::function<std::string (example::Hello *, int)> &callback)
    self->setNotifyCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setPointers(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<example::Point *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<example::Point *>(L, 2, arg1, [L](example::Point **arg1) {
        olua_check_object(L, -1, arg1, "example.Point");
    });

    // void setPointers(const std::vector<example::Point *> &v)
    self->setPointers(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setPoints(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<example::Point> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<example::Point>(L, 2, arg1, [L](example::Point *arg1) {
        if (olua_istable(L, -1)) {
            olua_check_table(L, -1, arg1);
        } else {
            olua_check_object(L, -1, arg1, "example.Point");
        }
    });

    // void setPoints(const std::vector<example::Point> &v)
    self->setPoints(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setPtr(lua_State *L)
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

static int _olua_fun_example_Hello_setTouchCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::TouchCallback arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "example.ClickCallback");

    void *cb_store = (void *)self;
    std::string cb_tag = "TouchCallback";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setTouchCallback(const example::TouchCallback &callback)
    self->setTouchCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setType(lua_State *L)
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

static int _olua_fun_example_Hello_setVoids(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<GLvoid *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<GLvoid *>(L, 2, arg1, [L](GLvoid **arg1) {
        olua_check_object(L, -1, arg1, "void *");
    });

    // void setVoids(const std::vector<GLvoid *> &v)
    self->setVoids(arg1);

    olua_endinvoke(L);

    return 0;
}

#ifdef TEST_OLUA_MACRO
static int _olua_fun_example_Hello_testMacro(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // void testMacro()
    self->testMacro();

    olua_endinvoke(L);

    return 0;
}
#endif

static int _olua_fun_example_Hello_testMoveCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<std::string (example::Hello *, int)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "testMoveCallback";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](example::Hello *cb_arg1, int cb_arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.Hello");
            olua_push_integer(L, cb_arg2);
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

    // void testMoveCallback(const std::function<std::string (example::Hello *, int)> &callback)
    self->testMoveCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_testPointerTypes$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    olua_char_t *arg1 = nullptr;       /** arg1 */
    olua_uchar_t *arg2 = nullptr;       /** arg2 */
    short *arg3 = nullptr;       /** arg3 */
    short *arg4 = nullptr;       /** arg4 */
    std::vector<short> arg5;       /** arg5 */
    unsigned short *arg6 = nullptr;       /** arg6 */
    unsigned short *arg7 = nullptr;       /** arg7 */
    std::vector<unsigned short> arg8;       /** arg8 */
    int *arg9 = nullptr;       /** arg9 */
    int *arg10 = nullptr;       /** arg10 */
    std::vector<int> *arg11 = nullptr;       /** arg11 */
    unsigned int *arg12 = nullptr;       /** arg12 */
    unsigned int *arg13 = nullptr;       /** arg13 */
    std::vector<unsigned int> arg14;       /** arg14 */
    long *arg15 = nullptr;       /** arg15 */
    long *arg16 = nullptr;       /** arg16 */
    std::vector<long> arg17;       /** arg17 */
    unsigned long *arg18 = nullptr;       /** arg18 */
    unsigned long *arg19 = nullptr;       /** arg19 */
    std::vector<unsigned long> arg20;       /** arg20 */
    long long *arg21 = nullptr;       /** arg21 */
    long long *arg22 = nullptr;       /** arg22 */
    std::vector<long long> arg23;       /** arg23 */
    unsigned long long *arg24 = nullptr;       /** arg24 */
    unsigned long long *arg25 = nullptr;       /** arg25 */
    std::vector<unsigned long long> arg26;       /** arg26 */
    float *arg27 = nullptr;       /** arg27 */
    std::vector<float> arg28;       /** arg28 */
    double *arg29 = nullptr;       /** arg29 */
    std::vector<double> arg30;       /** arg30 */
    long double *arg31 = nullptr;       /** arg31 */
    std::vector<long double> arg32;       /** arg32 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "olua.char");
    olua_check_pointer(L, 3, &arg2, "olua.uchar");
    olua_check_pointer(L, 4, &arg3, "olua.short");
    olua_check_pointer(L, 5, &arg4, "olua.short");
    olua_check_array<short>(L, 6, arg5, [L](short *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_pointer(L, 7, &arg6, "olua.ushort");
    olua_check_pointer(L, 8, &arg7, "olua.ushort");
    olua_check_array<unsigned short>(L, 9, arg8, [L](unsigned short *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_pointer(L, 10, &arg9, "olua.int");
    olua_check_pointer(L, 11, &arg10, "olua.int");
    olua_check_pointer(L, 12, &arg11, "example.VectorInt");
    olua_check_pointer(L, 13, &arg12, "olua.uint");
    olua_check_pointer(L, 14, &arg13, "olua.uint");
    olua_check_array<unsigned int>(L, 15, arg14, [L](unsigned int *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_pointer(L, 16, &arg15, "olua.long");
    olua_check_pointer(L, 17, &arg16, "olua.long");
    olua_check_array<long>(L, 18, arg17, [L](long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_pointer(L, 19, &arg18, "olua.ulong");
    olua_check_pointer(L, 20, &arg19, "olua.ulong");
    olua_check_array<unsigned long>(L, 21, arg20, [L](unsigned long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_pointer(L, 22, &arg21, "olua.llong");
    olua_check_pointer(L, 23, &arg22, "olua.llong");
    olua_check_array<long long>(L, 24, arg23, [L](long long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_pointer(L, 25, &arg24, "olua.ullong");
    olua_check_pointer(L, 26, &arg25, "olua.ullong");
    olua_check_array<unsigned long long>(L, 27, arg26, [L](unsigned long long *arg1) {
        olua_check_integer(L, -1, arg1);
    });
    olua_check_pointer(L, 28, &arg27, "olua.float");
    olua_check_array<float>(L, 29, arg28, [L](float *arg1) {
        olua_check_number(L, -1, arg1);
    });
    olua_check_pointer(L, 30, &arg29, "olua.double");
    olua_check_array<double>(L, 31, arg30, [L](double *arg1) {
        olua_check_number(L, -1, arg1);
    });
    olua_check_pointer(L, 32, &arg31, "olua.ldouble");
    olua_check_array<long double>(L, 33, arg32, [L](long double *arg1) {
        olua_check_number(L, -1, arg1);
    });

    // void testPointerTypes(@type(olua_char_t *) char *arg1, @type(olua_uchar_t *) unsigned char *arg2, short *arg3, short *arg4, std::vector<short> &arg5, unsigned short *arg6, unsigned short *arg7, std::vector<unsigned short> &arg8, int *arg9, int *arg10, std::vector<int> &arg11, unsigned int *arg12, unsigned int *arg13, std::vector<unsigned int> &arg14, long *arg15, long *arg16, std::vector<long> &arg17, unsigned long *arg18, unsigned long *arg19, std::vector<unsigned long> &arg20, long long *arg21, long long *arg22, std::vector<long long> &arg23, unsigned long long *arg24, unsigned long long *arg25, std::vector<unsigned long long> &arg26, float *arg27, std::vector<float> &arg28, double *arg29, std::vector<double> &arg30, long double *arg31, std::vector<long double> &arg32)
    self->testPointerTypes(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, *arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31, arg32);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_testPointerTypes$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<void (char *, unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)> arg1;       /** arg1 */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "testPointerTypes";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg1 = [cb_store, cb_name, cb_ctx /*, ML */](char *cb_arg1, unsigned char *cb_arg2, short *cb_arg3, short *cb_arg4, std::vector<short> &cb_arg5, unsigned short *cb_arg6, unsigned short *cb_arg7, std::vector<unsigned short> &cb_arg8, int *cb_arg9, int *cb_arg10, std::vector<int> &cb_arg11, unsigned int *cb_arg12, unsigned int *cb_arg13, std::vector<unsigned int> &cb_arg14, long *cb_arg15, long *cb_arg16, std::vector<long> &cb_arg17, unsigned long *cb_arg18, unsigned long *cb_arg19, std::vector<unsigned long> &cb_arg20, long long *cb_arg21, long long *cb_arg22, std::vector<long long> &cb_arg23, unsigned long long *cb_arg24, unsigned long long *cb_arg25, std::vector<unsigned long long> &cb_arg26, float *cb_arg27, std::vector<float> &cb_arg28, double *cb_arg29, std::vector<double> &cb_arg30, long double *cb_arg31, std::vector<long double> &cb_arg32) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_string(L, cb_arg1);
            olua_push_string(L, cb_arg2);
            olua_push_pointer(L, cb_arg3, "olua.short");
            olua_push_pointer(L, cb_arg4, "olua.short");
            olua_push_array<short>(L, cb_arg5, [L](short &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_pointer(L, cb_arg6, "olua.ushort");
            olua_push_pointer(L, cb_arg7, "olua.ushort");
            olua_push_array<unsigned short>(L, cb_arg8, [L](unsigned short &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_pointer(L, cb_arg9, "olua.int");
            olua_push_pointer(L, cb_arg10, "olua.int");
            olua_push_pointer(L, &cb_arg11, "example.VectorInt");
            olua_push_pointer(L, cb_arg12, "olua.uint");
            olua_push_pointer(L, cb_arg13, "olua.uint");
            olua_push_array<unsigned int>(L, cb_arg14, [L](unsigned int &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_pointer(L, cb_arg15, "olua.long");
            olua_push_pointer(L, cb_arg16, "olua.long");
            olua_push_array<long>(L, cb_arg17, [L](long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_pointer(L, cb_arg18, "olua.ulong");
            olua_push_pointer(L, cb_arg19, "olua.ulong");
            olua_push_array<unsigned long>(L, cb_arg20, [L](unsigned long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_pointer(L, cb_arg21, "olua.llong");
            olua_push_pointer(L, cb_arg22, "olua.llong");
            olua_push_array<long long>(L, cb_arg23, [L](long long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_pointer(L, cb_arg24, "olua.ullong");
            olua_push_pointer(L, cb_arg25, "olua.ullong");
            olua_push_array<unsigned long long>(L, cb_arg26, [L](unsigned long long &arg1) {
                olua_push_integer(L, arg1);
            });
            olua_push_pointer(L, cb_arg27, "olua.float");
            olua_push_array<float>(L, cb_arg28, [L](float &arg1) {
                olua_push_number(L, arg1);
            });
            olua_push_pointer(L, cb_arg29, "olua.double");
            olua_push_array<double>(L, cb_arg30, [L](double &arg1) {
                olua_push_number(L, arg1);
            });
            olua_push_pointer(L, cb_arg31, "olua.ldouble");
            olua_push_array<long double>(L, cb_arg32, [L](long double &arg1) {
                olua_push_number(L, arg1);
            });
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 32);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void testPointerTypes(const std::function<void (char *, unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)> &arg1)
    self->testPointerTypes(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_testPointerTypes(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_callback(L, 2, "std.function"))) {
            // void testPointerTypes(const std::function<void (char *, unsigned char *, short *, short *, std::vector<short> &, unsigned short *, unsigned short *, std::vector<unsigned short> &, int *, int *, std::vector<int> &, unsigned int *, unsigned int *, std::vector<unsigned int> &, long *, long *, std::vector<long> &, unsigned long *, unsigned long *, std::vector<unsigned long> &, long long *, long long *, std::vector<long long> &, unsigned long long *, unsigned long long *, std::vector<unsigned long long> &, float *, std::vector<float> &, double *, std::vector<double> &, long double *, std::vector<long double> &)> &arg1)
            return _olua_fun_example_Hello_testPointerTypes$2(L);
        // }
    }

    if (num_args == 33) {
        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_pointer(L, 2, "olua.char")) && (olua_is_pointer(L, 3, "olua.uchar")) && (olua_is_pointer(L, 4, "olua.short")) && (olua_is_pointer(L, 5, "olua.short")) && (olua_is_array(L, 6)) && (olua_is_pointer(L, 7, "olua.ushort")) && (olua_is_pointer(L, 8, "olua.ushort")) && (olua_is_array(L, 9)) && (olua_is_pointer(L, 10, "olua.int")) && (olua_is_pointer(L, 11, "olua.int")) && (olua_is_pointer(L, 12, "example.VectorInt")) && (olua_is_pointer(L, 13, "olua.uint")) && (olua_is_pointer(L, 14, "olua.uint")) && (olua_is_array(L, 15)) && (olua_is_pointer(L, 16, "olua.long")) && (olua_is_pointer(L, 17, "olua.long")) && (olua_is_array(L, 18)) && (olua_is_pointer(L, 19, "olua.ulong")) && (olua_is_pointer(L, 20, "olua.ulong")) && (olua_is_array(L, 21)) && (olua_is_pointer(L, 22, "olua.llong")) && (olua_is_pointer(L, 23, "olua.llong")) && (olua_is_array(L, 24)) && (olua_is_pointer(L, 25, "olua.ullong")) && (olua_is_pointer(L, 26, "olua.ullong")) && (olua_is_array(L, 27)) && (olua_is_pointer(L, 28, "olua.float")) && (olua_is_array(L, 29)) && (olua_is_pointer(L, 30, "olua.double")) && (olua_is_array(L, 31)) && (olua_is_pointer(L, 32, "olua.ldouble")) && (olua_is_array(L, 33))) {
            // void testPointerTypes(@type(olua_char_t *) char *arg1, @type(olua_uchar_t *) unsigned char *arg2, short *arg3, short *arg4, std::vector<short> &arg5, unsigned short *arg6, unsigned short *arg7, std::vector<unsigned short> &arg8, int *arg9, int *arg10, std::vector<int> &arg11, unsigned int *arg12, unsigned int *arg13, std::vector<unsigned int> &arg14, long *arg15, long *arg16, std::vector<long> &arg17, unsigned long *arg18, unsigned long *arg19, std::vector<unsigned long> &arg20, long long *arg21, long long *arg22, std::vector<long long> &arg23, unsigned long long *arg24, unsigned long long *arg25, std::vector<unsigned long long> &arg26, float *arg27, std::vector<float> &arg28, double *arg29, std::vector<double> &arg30, long double *arg31, std::vector<long double> &arg32)
            return _olua_fun_example_Hello_testPointerTypes$1(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::testPointerTypes' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_cls_example_Hello(lua_State *L)
{
    oluacls_class<example::Hello, example::ExportParent>(L, "example.Hello");
    oluacls_func(L, "as", _olua_fun_example_Hello_as);
    oluacls_func(L, "checkString", _olua_fun_example_Hello_checkString);
    oluacls_func(L, "checkVectorInt", _olua_fun_example_Hello_checkVectorInt);
    oluacls_func(L, "checkVectorPoint", _olua_fun_example_Hello_checkVectorPoint);
    oluacls_func(L, "convertPoint", _olua_fun_example_Hello_convertPoint);
    oluacls_func(L, "create", _olua_fun_example_Hello_create);
    oluacls_func(L, "doCallback", _olua_fun_example_Hello_doCallback);
    oluacls_func(L, "getAliasHello", _olua_fun_example_Hello_getAliasHello);
    oluacls_func(L, "getCGLchar", _olua_fun_example_Hello_getCGLchar);
    oluacls_func(L, "getCName", _olua_fun_example_Hello_getCName);
    oluacls_func(L, "getCStrs", _olua_fun_example_Hello_getCStrs);
    oluacls_func(L, "getCallback", _olua_fun_example_Hello_getCallback);
    oluacls_func(L, "getDeque", _olua_fun_example_Hello_getDeque);
    oluacls_func(L, "getGLchar", _olua_fun_example_Hello_getGLchar);
    oluacls_func(L, "getGLvoid", _olua_fun_example_Hello_getGLvoid);
    oluacls_func(L, "getID", _olua_fun_example_Hello_getID);
    oluacls_func(L, "getIntPtr", _olua_fun_example_Hello_getIntPtr);
    oluacls_func(L, "getIntPtrs", _olua_fun_example_Hello_getIntPtrs);
    oluacls_func(L, "getIntRef", _olua_fun_example_Hello_getIntRef);
    oluacls_func(L, "getInts", _olua_fun_example_Hello_getInts);
    oluacls_func(L, "getName", _olua_fun_example_Hello_getName);
    oluacls_func(L, "getPointers", _olua_fun_example_Hello_getPointers);
    oluacls_func(L, "getPoints", _olua_fun_example_Hello_getPoints);
    oluacls_func(L, "getPtr", _olua_fun_example_Hello_getPtr);
    oluacls_func(L, "getStringRef", _olua_fun_example_Hello_getStringRef);
    oluacls_func(L, "getType", _olua_fun_example_Hello_getType);
    oluacls_func(L, "getVec2", _olua_fun_example_Hello_getVec2);
    oluacls_func(L, "getVectorIntPtr", _olua_fun_example_Hello_getVectorIntPtr);
    oluacls_func(L, "getVoids", _olua_fun_example_Hello_getVoids);
    oluacls_func(L, "load", _olua_fun_example_Hello_load);
    oluacls_func(L, "new", _olua_fun_example_Hello_new);
    oluacls_func(L, "printSingleton", _olua_fun_example_Hello_printSingleton);
    oluacls_func(L, "read", _olua_fun_example_Hello_read);
    oluacls_func(L, "run", _olua_fun_example_Hello_run);
    oluacls_func(L, "setCGLchar", _olua_fun_example_Hello_setCGLchar);
    oluacls_func(L, "setCName", _olua_fun_example_Hello_setCName);
    oluacls_func(L, "setCStrs", _olua_fun_example_Hello_setCStrs);
    oluacls_func(L, "setCallback", _olua_fun_example_Hello_setCallback);
    oluacls_func(L, "setClickCallback", _olua_fun_example_Hello_setClickCallback);
    oluacls_func(L, "setDeque", _olua_fun_example_Hello_setDeque);
    oluacls_func(L, "setDragCallback", _olua_fun_example_Hello_setDragCallback);
    oluacls_func(L, "setGLchar", _olua_fun_example_Hello_setGLchar);
    oluacls_func(L, "setGLfloat", _olua_fun_example_Hello_setGLfloat);
    oluacls_func(L, "setGLvoid", _olua_fun_example_Hello_setGLvoid);
    oluacls_func(L, "setID", _olua_fun_example_Hello_setID);
    oluacls_func(L, "setIntPtrs", _olua_fun_example_Hello_setIntPtrs);
    oluacls_func(L, "setInts", _olua_fun_example_Hello_setInts);
    oluacls_func(L, "setName", _olua_fun_example_Hello_setName);
    oluacls_func(L, "setNotifyCallback", _olua_fun_example_Hello_setNotifyCallback);
    oluacls_func(L, "setPointers", _olua_fun_example_Hello_setPointers);
    oluacls_func(L, "setPoints", _olua_fun_example_Hello_setPoints);
    oluacls_func(L, "setPtr", _olua_fun_example_Hello_setPtr);
    oluacls_func(L, "setTouchCallback", _olua_fun_example_Hello_setTouchCallback);
    oluacls_func(L, "setType", _olua_fun_example_Hello_setType);
    oluacls_func(L, "setVoids", _olua_fun_example_Hello_setVoids);
#ifdef TEST_OLUA_MACRO
    oluacls_func(L, "testMacro", _olua_fun_example_Hello_testMacro);
#endif
    oluacls_func(L, "testMoveCallback", _olua_fun_example_Hello_testMoveCallback);
    oluacls_func(L, "testPointerTypes", _olua_fun_example_Hello_testPointerTypes);
    oluacls_prop(L, "aliasHello", _olua_fun_example_Hello_getAliasHello, nullptr);
    oluacls_prop(L, "cName", _olua_fun_example_Hello_getCName, _olua_fun_example_Hello_setCName);
    oluacls_prop(L, "cStrs", _olua_fun_example_Hello_getCStrs, _olua_fun_example_Hello_setCStrs);
    oluacls_prop(L, "cgLchar", _olua_fun_example_Hello_getCGLchar, _olua_fun_example_Hello_setCGLchar);
    oluacls_prop(L, "deque", _olua_fun_example_Hello_getDeque, _olua_fun_example_Hello_setDeque);
    oluacls_prop(L, "gLchar", _olua_fun_example_Hello_getGLchar, _olua_fun_example_Hello_setGLchar);
    oluacls_prop(L, "gLvoid", _olua_fun_example_Hello_getGLvoid, _olua_fun_example_Hello_setGLvoid);
    oluacls_prop(L, "id", _olua_fun_example_Hello_getID, _olua_fun_example_Hello_setID);
    oluacls_prop(L, "intPtr", _olua_fun_example_Hello_getIntPtr, nullptr);
    oluacls_prop(L, "intPtrs", _olua_fun_example_Hello_getIntPtrs, _olua_fun_example_Hello_setIntPtrs);
    oluacls_prop(L, "ints", _olua_fun_example_Hello_getInts, _olua_fun_example_Hello_setInts);
    oluacls_prop(L, "name", _olua_fun_example_Hello_getName, _olua_fun_example_Hello_setName);
    oluacls_prop(L, "pointers", _olua_fun_example_Hello_getPointers, _olua_fun_example_Hello_setPointers);
    oluacls_prop(L, "points", _olua_fun_example_Hello_getPoints, _olua_fun_example_Hello_setPoints);
    oluacls_prop(L, "ptr", _olua_fun_example_Hello_getPtr, _olua_fun_example_Hello_setPtr);
    oluacls_prop(L, "type", _olua_fun_example_Hello_getType, _olua_fun_example_Hello_setType);
    oluacls_prop(L, "vec2", _olua_fun_example_Hello_getVec2, nullptr);
    oluacls_prop(L, "vectorIntPtr", _olua_fun_example_Hello_getVectorIntPtr, nullptr);
    oluacls_prop(L, "voids", _olua_fun_example_Hello_getVoids, _olua_fun_example_Hello_setVoids);
    oluacls_prop(L, "readonlyInt", _olua_fun_example_Hello_readonlyInt, nullptr);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Hello(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Hello")) {
        luaL_error(L, "class not found: example::Hello");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_Const_CONST_CHAR$1(lua_State *L)
{
    olua_startinvoke(L);

    // static const char *CONST_CHAR
    const char *ret = example::Const::CONST_CHAR;
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Const_CONST_CHAR$2(lua_State *L)
{
    olua_startinvoke(L);

    const char *arg1 = nullptr;       /** CONST_CHAR */

    olua_check_string(L, 1, &arg1);

    // static const char *CONST_CHAR
    example::Const::CONST_CHAR = arg1;

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Const_CONST_CHAR(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // static const char *CONST_CHAR
        return _olua_fun_example_Const_CONST_CHAR$1(L);
    }

    if (num_args == 1) {
        // if ((olua_is_string(L, 1))) {
            // static const char *CONST_CHAR
            return _olua_fun_example_Const_CONST_CHAR$2(L);
        // }
    }

    luaL_error(L, "method 'example::Const::CONST_CHAR' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Const___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::Const *)olua_toobj(L, 1, "example.Const");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_cls_example_Const(lua_State *L)
{
    oluacls_class<example::Const>(L, "example.Const");
    oluacls_func(L, "__gc", _olua_fun_example_Const___gc);
    oluacls_prop(L, "CONST_CHAR", _olua_fun_example_Const_CONST_CHAR, _olua_fun_example_Const_CONST_CHAR);
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

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Const(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Const")) {
        luaL_error(L, "class not found: example::Const");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_SharedHello___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::SharedHello *)olua_toobj(L, 1, "example.SharedHello");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_fun_example_SharedHello_getName(lua_State *L)
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

static int _olua_fun_example_SharedHello_getThis(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // std::shared_ptr<example::SharedHello> getThis()
    std::shared_ptr<example::SharedHello> ret = self->getThis();
    int num_ret = olua_push_smartptr(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_SharedHello_getWeakPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // std::weak_ptr<example::SharedHello> getWeakPtr()
    std::weak_ptr<example::SharedHello> ret = self->getWeakPtr();
    int num_ret = olua_push_smartptr(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_SharedHello_new(lua_State *L)
{
    olua_startinvoke(L);

    // @name(new) static std::shared_ptr<example::SharedHello> create()
    std::shared_ptr<example::SharedHello> ret = example::SharedHello::create();
    int num_ret = olua_push_smartptr(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_SharedHello_say(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // void say()
    self->say();

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_SharedHello_setThis(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;
    std::shared_ptr<example::SharedHello> arg1;       /** sp */

    olua_to_object(L, 1, &self, "example.SharedHello");
    olua_check_smartptr(L, 2, &arg1, "example.SharedHello");

    // void setThis(const std::shared_ptr<example::SharedHello> &sp)
    self->setThis(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_SharedHello_shared_from_this(lua_State *L)
{
    olua_startinvoke(L);

    example::SharedHello *self = nullptr;

    olua_to_object(L, 1, &self, "example.SharedHello");

    // @copyfrom(std::enable_shared_from_this) std::shared_ptr<example::SharedHello> shared_from_this()
    std::shared_ptr<example::SharedHello> ret = self->shared_from_this();
    int num_ret = olua_push_smartptr(L, &ret, "example.SharedHello");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_cls_example_SharedHello(lua_State *L)
{
    oluacls_class<example::SharedHello>(L, "example.SharedHello");
    oluacls_func(L, "__gc", _olua_fun_example_SharedHello___gc);
    oluacls_func(L, "getName", _olua_fun_example_SharedHello_getName);
    oluacls_func(L, "getThis", _olua_fun_example_SharedHello_getThis);
    oluacls_func(L, "getWeakPtr", _olua_fun_example_SharedHello_getWeakPtr);
    oluacls_func(L, "new", _olua_fun_example_SharedHello_new);
    oluacls_func(L, "say", _olua_fun_example_SharedHello_say);
    oluacls_func(L, "setThis", _olua_fun_example_SharedHello_setThis);
    oluacls_func(L, "shared_from_this", _olua_fun_example_SharedHello_shared_from_this);
    oluacls_prop(L, "name", _olua_fun_example_SharedHello_getName, nullptr);
    oluacls_prop(L, "this", _olua_fun_example_SharedHello_getThis, _olua_fun_example_SharedHello_setThis);
    oluacls_prop(L, "weakPtr", _olua_fun_example_SharedHello_getWeakPtr, nullptr);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_SharedHello(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.SharedHello")) {
        luaL_error(L, "class not found: example::SharedHello");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_NoGC___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::NoGC *)olua_toobj(L, 1, "example.NoGC");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_fun_example_NoGC_create(lua_State *L)
{
    olua_startinvoke(L);

    // static example::NoGC *create()
    example::NoGC *ret = example::NoGC::create();
    int num_ret = olua_push_object(L, ret, "example.NoGC");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_NoGC_new(lua_State *L)
{
    olua_startinvoke(L);

    int arg1 = 0;       /** i */
    std::function<int (example::NoGC *)> arg2;       /** callbak */

    olua_check_integer(L, 1, &arg1);
    olua_check_callback(L, 2, &arg2, "std.function");

    void *cb_store = (void *)olua_newobjstub(L, "example.NoGC");
    std::string cb_tag = "NoGC";
    std::string cb_name = olua_setcallback(L, cb_store, 2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    // lua_State *ML = olua_mainthread(L);
    arg2 = [cb_store, cb_name, cb_ctx /*, ML */](example::NoGC *cb_arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        int ret = 0;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, cb_arg1, "example.NoGC");
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

    // example::NoGC(int i, const std::function<int (example::NoGC *)> &callbak)
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

static int _olua_cls_example_NoGC(lua_State *L)
{
    oluacls_class<example::NoGC>(L, "example.NoGC");
    oluacls_func(L, "__gc", _olua_fun_example_NoGC___gc);
    oluacls_func(L, "create", _olua_fun_example_NoGC_create);
    oluacls_func(L, "new", _olua_fun_example_NoGC_new);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_NoGC(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.NoGC")) {
        luaL_error(L, "class not found: example::NoGC");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_PointIterator___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::PointIterator *)olua_toobj(L, 1, "example.PointIterator");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_fun_example_PointIterator___pairs(lua_State *L)
{
    olua_startinvoke(L);
    auto self = olua_toobj<example::PointIterator>(L, 1);
    int ret = olua_pairs<example::PointIterator, example::PointIterator::Iterator>(L, self, false);
    olua_endinvoke(L);
    return ret;
}

static int _olua_fun_example_PointIterator_new(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<example::Point> arg1;       /** points */

    olua_check_array<example::Point>(L, 1, arg1, [L](example::Point *arg1) {
        if (olua_istable(L, -1)) {
            olua_check_table(L, -1, arg1);
        } else {
            olua_check_object(L, -1, arg1, "example.Point");
        }
    });

    // example::PointIterator(const std::vector<example::Point> &points)
    example::PointIterator *ret = new example::PointIterator(arg1);
    int num_ret = olua_push_object(L, ret, "example.PointIterator");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_cls_example_PointIterator(lua_State *L)
{
    oluacls_class<example::PointIterator>(L, "example.PointIterator");
    oluacls_func(L, "__gc", _olua_fun_example_PointIterator___gc);
    oluacls_func(L, "__pairs", _olua_fun_example_PointIterator___pairs);
    oluacls_func(L, "new", _olua_fun_example_PointIterator_new);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_PointIterator(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.PointIterator")) {
        luaL_error(L, "class not found: example::PointIterator");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_PointIterator_Iterator___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::PointIterator::Iterator *)olua_toobj(L, 1, "example.PointIterator.Iterator");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_cls_example_PointIterator_Iterator(lua_State *L)
{
    oluacls_class<example::PointIterator::Iterator>(L, "example.PointIterator.Iterator");
    oluacls_func(L, "__gc", _olua_fun_example_PointIterator_Iterator___gc);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_PointIterator_Iterator(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.PointIterator.Iterator")) {
        luaL_error(L, "class not found: example::PointIterator::Iterator");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_IntIterator___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::IntIterator *)olua_toobj(L, 1, "example.IntIterator");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_fun_example_IntIterator___pairs(lua_State *L)
{
    olua_startinvoke(L);
    auto self = olua_toobj<example::IntIterator>(L, 1);
    int ret = olua_pairs<example::IntIterator, example::IntIterator::Iterator>(L, self, false);
    olua_endinvoke(L);
    return ret;
}

static int _olua_fun_example_IntIterator_new(lua_State *L)
{
    olua_startinvoke(L);

    std::vector<int> arg1;       /** ints */

    olua_check_array<int>(L, 1, arg1, [L](int *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // example::IntIterator(const std::vector<int> &ints)
    example::IntIterator *ret = new example::IntIterator(arg1);
    int num_ret = olua_push_object(L, ret, "example.IntIterator");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_cls_example_IntIterator(lua_State *L)
{
    oluacls_class<example::IntIterator>(L, "example.IntIterator");
    oluacls_func(L, "__gc", _olua_fun_example_IntIterator___gc);
    oluacls_func(L, "__pairs", _olua_fun_example_IntIterator___pairs);
    oluacls_func(L, "new", _olua_fun_example_IntIterator_new);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_IntIterator(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.IntIterator")) {
        luaL_error(L, "class not found: example::IntIterator");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_IntIterator_Iterator___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::IntIterator::Iterator *)olua_toobj(L, 1, "example.IntIterator.Iterator");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_cls_example_IntIterator_Iterator(lua_State *L)
{
    oluacls_class<example::IntIterator::Iterator>(L, "example.IntIterator.Iterator");
    oluacls_func(L, "__gc", _olua_fun_example_IntIterator_Iterator___gc);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_IntIterator_Iterator(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.IntIterator.Iterator")) {
        luaL_error(L, "class not found: example::IntIterator::Iterator");
    }
    return 1;
}
OLUA_END_DECLS

static int _olua_fun_example_Singleton_example_Hello___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::Singleton<example::Hello> *)olua_toobj(L, 1, "example.Singleton_example_Hello");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_fun_example_Singleton_example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // static example::Hello *create()
    example::Hello *ret = example::Singleton<example::Hello>::create();
    int num_ret = olua_push_object(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Singleton_example_Hello_new(lua_State *L)
{
    olua_startinvoke(L);

    // example::Singleton<example::Hello>()
    example::Singleton<example::Hello> *ret = new example::Singleton<example::Hello>();
    int num_ret = olua_push_object(L, ret, "example.Singleton_example_Hello");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Singleton_example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Singleton<example::Hello> *self = nullptr;

    olua_to_object(L, 1, &self, "example.Singleton_example_Hello");

    // void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
}

static int _olua_cls_example_Singleton_example_Hello(lua_State *L)
{
    oluacls_class<example::Singleton<example::Hello>>(L, "example.Singleton_example_Hello");
    oluacls_func(L, "__gc", _olua_fun_example_Singleton_example_Hello___gc);
    oluacls_func(L, "create", _olua_fun_example_Singleton_example_Hello_create);
    oluacls_func(L, "new", _olua_fun_example_Singleton_example_Hello_new);
    oluacls_func(L, "printSingleton", _olua_fun_example_Singleton_example_Hello_printSingleton);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Singleton_example_Hello(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Singleton_example_Hello")) {
        luaL_error(L, "class not found: example::Singleton<example::Hello>");
    }
    return 1;
}
OLUA_END_DECLS

int _olua_module_example(lua_State *L)
{
    olua_require(L, "example.Object", _olua_cls_example_Object);
    olua_require(L, "example.ExportParent", _olua_cls_example_ExportParent);
    olua_require(L, "example.VectorInt", _olua_cls_example_VectorInt);
    olua_require(L, "example.VectorPoint", _olua_cls_example_VectorPoint);
    olua_require(L, "example.VectorString", _olua_cls_example_VectorString);
    olua_require(L, "example.PointArray", _olua_cls_example_PointArray);
    olua_require(L, "example.ClickCallback", _olua_cls_example_ClickCallback);
    olua_require(L, "example.Type", _olua_cls_example_Type);
    olua_require(L, "example.Point", _olua_cls_example_Point);
    olua_require(L, "example.Hello", _olua_cls_example_Hello);
    olua_require(L, "example.Const", _olua_cls_example_Const);
    olua_require(L, "example.SharedHello", _olua_cls_example_SharedHello);
    olua_require(L, "example.NoGC", _olua_cls_example_NoGC);
    olua_require(L, "example.PointIterator", _olua_cls_example_PointIterator);
    olua_require(L, "example.PointIterator.Iterator", _olua_cls_example_PointIterator_Iterator);
    olua_require(L, "example.IntIterator", _olua_cls_example_IntIterator);
    olua_require(L, "example.IntIterator.Iterator", _olua_cls_example_IntIterator_Iterator);
    olua_require(L, "example.Singleton_example_Hello", _olua_cls_example_Singleton_example_Hello);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);

    return 0;
}
OLUA_END_DECLS
