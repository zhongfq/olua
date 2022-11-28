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
    oluacls_class(L, "example.Object", nullptr);
    oluacls_func(L, "__gc", _example_Object___gc);
    oluacls_func(L, "__olua_move", _example_Object___olua_move);
    oluacls_func(L, "autorelease", _example_Object_autorelease);
    oluacls_func(L, "getReferenceCount", _example_Object_getReferenceCount);
    oluacls_func(L, "new", _example_Object_new);
    oluacls_prop(L, "referenceCount", _example_Object_getReferenceCount, nullptr);

    olua_registerluatype<example::Object>(L, "example.Object");

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
    oluacls_class(L, "example.ExportParent", "example.Object");
    oluacls_func(L, "printExportParent", _example_ExportParent_printExportParent);

    olua_registerluatype<example::ExportParent>(L, "example.ExportParent");

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

static int _example_VectorInt___index(lua_State *L)
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

static int _example_VectorInt___newindex(lua_State *L)
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

    size_t arg1 = 0;       /** len */

    olua_check_integer(L, 1, &arg1);

    // @name(new) static example::VectorInt *create(@optional size_t len)
    example::VectorInt *ret = example::VectorInt::create(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_create$2(lua_State *L)
{
    olua_startinvoke(L);

    // @name(new) static example::VectorInt *create(@optional size_t len)
    example::VectorInt *ret = example::VectorInt::create();
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_create(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // @name(new) static example::VectorInt *create(@optional size_t len)
        return _example_VectorInt_create$2(L);
    }

    if (num_args == 1) {
        // if ((olua_is_integer(L, 1))) {
            // @name(new) static example::VectorInt *create(@optional size_t len)
            return _example_VectorInt_create$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorInt::create' not support '%d' arguments", num_args);

    return 0;
}

static int _example_VectorInt_setstring(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    const char *arg1 = nullptr;       /** data */
    size_t arg2 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_string(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // void setstring(const char *data, size_t len)
    self->setstring(arg1, arg2);

    olua_endinvoke(L);

    return 0;
}

static int _example_VectorInt_sub$1(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** from */
    size_t arg2 = 0;       /** to */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);
    olua_check_integer(L, 3, &arg2);

    // example::VectorInt *sub(size_t from, @optional size_t to)
    example::VectorInt *ret = self->sub(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_sub$2(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** from */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);

    // example::VectorInt *sub(size_t from, @optional size_t to)
    example::VectorInt *ret = self->sub(arg1);
    int num_ret = olua_push_object(L, ret, "example.VectorInt");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_sub(lua_State *L)
{
    int num_args = lua_gettop(L) - 1;

    if (num_args == 1) {
        // if ((olua_is_integer(L, 2))) {
            // example::VectorInt *sub(size_t from, @optional size_t to)
            return _example_VectorInt_sub$2(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_integer(L, 2)) && (olua_is_integer(L, 3))) {
            // example::VectorInt *sub(size_t from, @optional size_t to)
            return _example_VectorInt_sub$1(L);
        // }
    }

    luaL_error(L, "method 'example::VectorInt::sub' not support '%d' arguments", num_args);

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

static int _example_VectorInt_tostring(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg2 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg2);

    // olua_Return tostring(lua_State *L, size_t len)
    olua_Return ret = self->tostring(L, arg2);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_VectorInt_getLength(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter @name(length) size_t getLength()
    size_t ret = self->getLength();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_setLength(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    size_t arg1 = 0;       /** len */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_integer(L, 2, &arg1);

    // @setter @name(length) void setLength(size_t len)
    self->setLength(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_VectorInt_getValue(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;

    olua_to_object(L, 1, &self, "example.VectorInt");

    // @getter @name(value) const std::vector<int> &getValue()
    const std::vector<int> &ret = self->getValue();
    int num_ret = olua_push_array<int>(L, ret, [L](int &arg1) {
        olua_push_integer(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_VectorInt_setValue(lua_State *L)
{
    olua_startinvoke(L);

    example::VectorInt *self = nullptr;
    std::vector<int> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.VectorInt");
    olua_check_array<int>(L, 2, arg1, [L](int *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // @setter @name(value) void setValue(const std::vector<int> &v)
    self->setValue(arg1);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_VectorInt(lua_State *L)
{
    oluacls_class(L, "example.VectorInt", nullptr);
    oluacls_func(L, "__gc", _example_VectorInt___gc);
    oluacls_func(L, "__index", _example_VectorInt___index);
    oluacls_func(L, "__newindex", _example_VectorInt___newindex);
    oluacls_func(L, "__olua_move", _example_VectorInt___olua_move);
    oluacls_func(L, "new", _example_VectorInt_create);
    oluacls_func(L, "setstring", _example_VectorInt_setstring);
    oluacls_func(L, "sub", _example_VectorInt_sub);
    oluacls_func(L, "take", _example_VectorInt_take);
    oluacls_func(L, "tostring", _example_VectorInt_tostring);
    oluacls_prop(L, "length", _example_VectorInt_getLength, _example_VectorInt_setLength);
    oluacls_prop(L, "value", _example_VectorInt_getValue, _example_VectorInt_setValue);

    olua_registerluatype<example::VectorInt>(L, "example.VectorInt");

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
    oluacls_class(L, "example.ClickCallback", nullptr);
    oluacls_func(L, "__call", _example_ClickCallback___call);

    olua_registerluatype<example::ClickCallback>(L, "example.ClickCallback");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Type(lua_State *L)
{
    oluacls_class(L, "example.Type", nullptr);
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_enum(L, "LVALUE", (lua_Integer)example::Type::LVALUE);
    oluacls_enum(L, "POINTER", (lua_Integer)example::Type::POINTER);
    oluacls_enum(L, "RVALUE", (lua_Integer)example::Type::RVALUE);

    olua_registerluatype<example::Type>(L, "example.Type");

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

    olua_postgc<example::Point>(L, 1);

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
    oluacls_class(L, "example.Point", nullptr);
    oluacls_func(L, "__call", _example_Point___call);
    oluacls_func(L, "__gc", _example_Point___gc);
    oluacls_func(L, "__olua_move", _example_Point___olua_move);
    oluacls_func(L, "length", _example_Point_length);
    oluacls_func(L, "new", _example_Point_new);
    oluacls_prop(L, "x", _example_Point_get_x, _example_Point_set_x);
    oluacls_prop(L, "y", _example_Point_get_y, _example_Point_set_y);

    olua_registerluatype<example::Point>(L, "example.Point");

    return 1;
}
OLUA_END_DECLS

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
    int num_ret = olua_push_array<const char *>(L, ret, [L](const char *arg1) {
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

static int _example_Hello_getIntPtrs(lua_State *L)
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

static int _example_Hello_getIntRef(lua_State *L)
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

static int _example_Hello_getInts(lua_State *L)
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
    int num_ret = olua_push_array<example::Point *>(L, ret, [L](example::Point *arg1) {
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
    int num_ret = olua_push_array<example::Point>(L, ret, [L](example::Point &arg1) {
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

static int _example_Hello_getVoids(lua_State *L)
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

static int _example_Hello_read(lua_State *L)
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
    olua_check_array<const char *>(L, 2, arg1, [L](const char **arg1) {
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
    std::function<int (example::Hello *)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "Callback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        int ret = 0;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
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

    // void setCallback(@localvar const std::function<int (example::Hello *)> &callback)
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
    olua_check_array<short *>(L, 2, arg1, [L](short **arg1) {
        olua_check_pointer(L, -1, arg1, "olua.short");
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
    olua_check_array<int64_t>(L, 2, arg1, [L](int64_t *arg1) {
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
    olua_check_array<example::Point *>(L, 2, arg1, [L](example::Point **arg1) {
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
    olua_check_array<example::Point>(L, 2, arg1, [L](example::Point *arg1) {
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
    olua_check_array<GLvoid *>(L, 2, arg1, [L](GLvoid **arg1) {
        olua_check_object(L, -1, arg1, "void *");
    });

    // void setVoids(const std::vector<GLvoid *> &v)
    self->setVoids(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_testPointerTypes(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    olua_char_t *arg1 = nullptr;       /**  */
    olua_uchar_t *arg2 = nullptr;       /**  */
    short *arg3 = nullptr;       /**  */
    short *arg4 = nullptr;       /**  */
    unsigned short *arg5 = nullptr;       /**  */
    unsigned short *arg6 = nullptr;       /**  */
    int *arg7 = nullptr;       /**  */
    int *arg8 = nullptr;       /**  */
    unsigned int *arg9 = nullptr;       /**  */
    unsigned int *arg10 = nullptr;       /**  */
    long *arg11 = nullptr;       /**  */
    long *arg12 = nullptr;       /**  */
    unsigned long *arg13 = nullptr;       /**  */
    unsigned long *arg14 = nullptr;       /**  */
    long long *arg15 = nullptr;       /**  */
    long long *arg16 = nullptr;       /**  */
    unsigned long long *arg17 = nullptr;       /**  */
    unsigned long long *arg18 = nullptr;       /**  */
    float *arg19 = nullptr;       /**  */
    double *arg20 = nullptr;       /**  */
    long double *arg21 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "olua.char");
    olua_check_pointer(L, 3, &arg2, "olua.uchar");
    olua_check_pointer(L, 4, &arg3, "olua.short");
    olua_check_pointer(L, 5, &arg4, "olua.short");
    olua_check_pointer(L, 6, &arg5, "olua.ushort");
    olua_check_pointer(L, 7, &arg6, "olua.ushort");
    olua_check_pointer(L, 8, &arg7, "olua.int");
    olua_check_pointer(L, 9, &arg8, "olua.int");
    olua_check_pointer(L, 10, &arg9, "olua.uint");
    olua_check_pointer(L, 11, &arg10, "olua.uint");
    olua_check_pointer(L, 12, &arg11, "olua.long");
    olua_check_pointer(L, 13, &arg12, "olua.long");
    olua_check_pointer(L, 14, &arg13, "olua.ulong");
    olua_check_pointer(L, 15, &arg14, "olua.ulong");
    olua_check_pointer(L, 16, &arg15, "olua.llong");
    olua_check_pointer(L, 17, &arg16, "olua.llong");
    olua_check_pointer(L, 18, &arg17, "olua.ullong");
    olua_check_pointer(L, 19, &arg18, "olua.ullong");
    olua_check_pointer(L, 20, &arg19, "olua.float");
    olua_check_pointer(L, 21, &arg20, "olua.double");
    olua_check_pointer(L, 22, &arg21, "olua.ldouble");

    // void testPointerTypes(@type(olua_char_t *) char *, @type(olua_uchar_t *) unsigned char *, short *, short *, unsigned short *, unsigned short *, int *, int *, unsigned int *, unsigned int *, long *, long *, unsigned long *, unsigned long *, long long *, long long *, unsigned long long *, unsigned long long *, float *, double *, long double *)
    self->testPointerTypes(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Hello(lua_State *L)
{
    oluacls_class(L, "example.Hello", "example.ExportParent");
    oluacls_func(L, "checkVectorInt", _example_Hello_checkVectorInt);
    oluacls_func(L, "convertPoint", _example_Hello_convertPoint);
    oluacls_func(L, "getAliasHello", _example_Hello_getAliasHello);
    oluacls_func(L, "getCGLchar", _example_Hello_getCGLchar);
    oluacls_func(L, "getCName", _example_Hello_getCName);
    oluacls_func(L, "getCStrs", _example_Hello_getCStrs);
    oluacls_func(L, "getGLchar", _example_Hello_getGLchar);
    oluacls_func(L, "getGLvoid", _example_Hello_getGLvoid);
    oluacls_func(L, "getID", _example_Hello_getID);
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
    oluacls_func(L, "getVoids", _example_Hello_getVoids);
    oluacls_func(L, "new", _example_Hello_new);
    oluacls_func(L, "read", _example_Hello_read);
    oluacls_func(L, "run", _example_Hello_run);
    oluacls_func(L, "setCGLchar", _example_Hello_setCGLchar);
    oluacls_func(L, "setCName", _example_Hello_setCName);
    oluacls_func(L, "setCStrs", _example_Hello_setCStrs);
    oluacls_func(L, "setCallback", _example_Hello_setCallback);
    oluacls_func(L, "setClickCallback", _example_Hello_setClickCallback);
    oluacls_func(L, "setDragCallback", _example_Hello_setDragCallback);
    oluacls_func(L, "setGLchar", _example_Hello_setGLchar);
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
    oluacls_prop(L, "intPtrs", _example_Hello_getIntPtrs, _example_Hello_setIntPtrs);
    oluacls_prop(L, "ints", _example_Hello_getInts, _example_Hello_setInts);
    oluacls_prop(L, "name", _example_Hello_getName, _example_Hello_setName);
    oluacls_prop(L, "pointers", _example_Hello_getPointers, _example_Hello_setPointers);
    oluacls_prop(L, "points", _example_Hello_getPoints, _example_Hello_setPoints);
    oluacls_prop(L, "ptr", _example_Hello_getPtr, _example_Hello_setPtr);
    oluacls_prop(L, "type", _example_Hello_getType, _example_Hello_setType);
    oluacls_prop(L, "vec2", _example_Hello_getVec2, nullptr);
    oluacls_prop(L, "voids", _example_Hello_getVoids, _example_Hello_setVoids);

    olua_registerluatype<example::Hello>(L, "example.Hello");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, "example.Object", luaopen_example_Object);
    olua_require(L, "example.ExportParent", luaopen_example_ExportParent);
    olua_require(L, "example.VectorInt", luaopen_example_VectorInt);
    olua_require(L, "example.ClickCallback", luaopen_example_ClickCallback);
    olua_require(L, "example.Type", luaopen_example_Type);
    olua_require(L, "example.Point", luaopen_example_Point);
    olua_require(L, "example.Hello", luaopen_example_Hello);

    return 0;
}
OLUA_END_DECLS
