//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"

int olua_push_example_Point(lua_State *L, const example::Point *value)
{
    if (value) {
        lua_createtable(L, 0, 2);

        olua_push_int(L, (lua_Integer)value->x);
        olua_setfield(L, -2, "x");

        olua_push_int(L, (lua_Integer)value->y);
        olua_setfield(L, -2, "y");
    } else {
        lua_pushnil(L);
    }

    return 1;
}

void olua_check_example_Point(lua_State *L, int idx, example::Point *value)
{
    if (!value) {
        luaL_error(L, "value is NULL");
    }
    idx = lua_absindex(L, idx);
    luaL_checktype(L, idx, LUA_TTABLE);

    lua_Integer arg1 = 0;       /** x */
    lua_Integer arg2 = 0;       /** y */

    olua_getfield(L, idx, "x");
    olua_check_int(L, -1, &arg1);
    value->x = (int)arg1;
    lua_pop(L, 1);

    olua_getfield(L, idx, "y");
    olua_check_int(L, -1, &arg2);
    value->y = (int)arg2;
    lua_pop(L, 1);
}

bool olua_is_example_Point(lua_State *L, int idx)
{
    return olua_istable(L, idx) && olua_hasfield(L, idx, "y") && olua_hasfield(L, idx, "x");
}

void olua_pack_example_Point(lua_State *L, int idx, example::Point *value)
{
    if (!value) {
        luaL_error(L, "value is NULL");
    }
    idx = lua_absindex(L, idx);

    lua_Integer arg1 = 0;       /** x */
    lua_Integer arg2 = 0;       /** y */

    olua_check_int(L, idx + 0, &arg1);
    value->x = (int)arg1;

    olua_check_int(L, idx + 1, &arg2);
    value->y = (int)arg2;
}

int olua_unpack_example_Point(lua_State *L, const example::Point *value)
{
    if (value) {
        olua_push_int(L, (lua_Integer)value->x);
        olua_push_int(L, (lua_Integer)value->y);
    } else {
        for (int i = 0; i < 2; i++) {
            lua_pushnil(L);
        }
    }

    return 2;
}

bool olua_canpack_example_Point(lua_State *L, int idx)
{
    return olua_is_int(L, idx + 0) && olua_is_int(L, idx + 1);
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
    olua_push_cppobj(L, self, "example.Object");

    olua_endinvoke(L);

    return 1;
}

static int _example_Object_autorelease(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Object");

    // example::Object *autorelease()
    example::Object *ret = self->autorelease();
    int num_ret = olua_push_cppobj(L, ret, "example.Object");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_getReferenceCount(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Object");

    // unsigned int getReferenceCount()
    unsigned int ret = self->getReferenceCount();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_new(lua_State *L)
{
    olua_startinvoke(L);

    // Object()
    example::Object *ret = new example::Object();
    int num_ret = olua_push_cppobj(L, ret, "example.Object");
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

static int _example_Node___index(lua_State *L)
{
    olua_startinvoke(L);

    // @extend(example::NodeExtend) static oluaret_t __index(lua_State *L)
    oluaret_t ret = example::NodeExtend::__index(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_Node___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Node *)olua_toobj(L, 1, "example.Node");
    olua_push_cppobj(L, self, "example.Node");

    olua_endinvoke(L);

    return 1;
}

static int _example_Node_getChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // const vector<example::Node *> &getChildren()
    const example::vector<example::Node *> &ret = self->getChildren();
    int num_ret = olua_push_array<example::Node *>(L, &ret, [L](example::Node *value) {
        olua_push_cppobj(L, value, "example.Node");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getColor(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // const example::Color &getColor()
    const example::Color &ret = self->getColor();
    int num_ret = olua_push_example_Color(L, &ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getIdentifier(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // const example::Identifier &getIdentifier()
    const example::Identifier &ret = self->getIdentifier();
    int num_ret = olua_push_std_string(L, (std::string)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getPosition(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // const example::Point &getPosition()
    const example::Point &ret = self->getPosition();
    int num_ret = olua_push_example_Point(L, &ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_new(lua_State *L)
{
    olua_startinvoke(L);

    // Node()
    example::Node *ret = new example::Node();
    int num_ret = olua_push_cppobj(L, ret, "example.Node");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_setChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::vector<example::Node *> arg1;       /** value */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_array<example::Node *>(L, 2, &arg1, [L](example::Node **value) {
        olua_check_cppobj(L, -1, (void **)value, "example.Node");
    });

    // void setChildren(const vector<example::Node *> &value)
    self->setChildren(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_setColor(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Color arg1;       /** value */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_example_Color(L, 2, &arg1);

    // void setColor(const example::Color &value)
    self->setColor(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_setIdentifier(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    std::string arg1;       /** value */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_std_string(L, 2, &arg1);

    // void setIdentifier(const example::Identifier &value)
    self->setIdentifier((example::Identifier)arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_setPosition(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Point arg1;       /** value */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_example_Point(L, 2, &arg1);

    // void setPosition(const example::Point &value)
    self->setPosition(arg1);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Node(lua_State *L)
{
    oluacls_class(L, "example.Node", "example.Object");
    oluacls_func(L, "__index", _example_Node___index);
    oluacls_func(L, "__olua_move", _example_Node___olua_move);
    oluacls_func(L, "getChildren", _example_Node_getChildren);
    oluacls_func(L, "getColor", _example_Node_getColor);
    oluacls_func(L, "getIdentifier", _example_Node_getIdentifier);
    oluacls_func(L, "getPosition", _example_Node_getPosition);
    oluacls_func(L, "new", _example_Node_new);
    oluacls_func(L, "setChildren", _example_Node_setChildren);
    oluacls_func(L, "setColor", _example_Node_setColor);
    oluacls_func(L, "setIdentifier", _example_Node_setIdentifier);
    oluacls_func(L, "setPosition", _example_Node_setPosition);
    oluacls_prop(L, "children", _example_Node_getChildren, _example_Node_setChildren);
    oluacls_prop(L, "color", _example_Node_getColor, _example_Node_setColor);
    oluacls_prop(L, "identifier", _example_Node_getIdentifier, _example_Node_setIdentifier);
    oluacls_prop(L, "position", _example_Node_getPosition, _example_Node_setPosition);

    olua_registerluatype<example::Node>(L, "example.Node");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, "example.Object", luaopen_example_Object);
    olua_require(L, "example.Node", luaopen_example_Node);

    return 0;
}
OLUA_END_DECLS
