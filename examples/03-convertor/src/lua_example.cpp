//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"


OLUA_LIB void olua_pack_example_Point(lua_State *L, int idx, example::Point *value)
{
    idx = lua_absindex(L, idx);

    int arg1 = 0;       /** x */
    int arg2 = 0;       /** y */

    olua_check_integer(L, idx + 0, &arg1);
    value->x = arg1;

    olua_check_integer(L, idx + 1, &arg2);
    value->y = arg2;
}

OLUA_LIB int olua_unpack_example_Point(lua_State *L, const example::Point *value)
{
    olua_push_integer(L, value->x);
    olua_push_integer(L, value->y);

    return 2;
}

OLUA_LIB bool olua_canpack_example_Point(lua_State *L, int idx)
{
    return olua_is_integer(L, idx + 0) && olua_is_integer(L, idx + 1);
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

static int _example_Point___call(lua_State *L)
{
    olua_startinvoke(L);

    example::Point ret;

    luaL_checktype(L, 2, LUA_TTABLE);

    int arg1 = 0;       /** x */
    int arg2 = 0;       /** y */

    olua_getfield(L, 2, "x");
    olua_check_integer(L, -1, &arg1);
    ret.x = arg1;
    lua_pop(L, 1);

    olua_getfield(L, 2, "y");
    olua_check_integer(L, -1, &arg2);
    ret.y = arg2;
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

static int _example_Point_get_x(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // int x
    int ret = self->x;
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_set_x(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    int arg1 = 0;       /** x */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_integer(L, 2, &arg1);

    // int x
    self->x = arg1;

    olua_endinvoke(L);

    return 0;
}

static int _example_Point_get_y(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // int y
    int ret = self->y;
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_set_y(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    int arg1 = 0;       /** y */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_integer(L, 2, &arg1);

    // int y
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
    oluacls_prop(L, "x", _example_Point_get_x, _example_Point_set_x);
    oluacls_prop(L, "y", _example_Point_get_y, _example_Point_set_y);

    olua_registerluatype<example::Point>(L, "example.Point");

    return 1;
}
OLUA_END_DECLS

static int _example_Node___index(lua_State *L)
{
    olua_startinvoke(L);

    // @extend(example::NodeExtend) static olua_Return __index(lua_State *L)
    olua_Return ret = example::NodeExtend::__index(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_Node_getChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // const example::vector<example::Node *> &getChildren()
    const example::vector<example::Node *> &ret = self->getChildren();
    int num_ret = olua_push_array<example::Node *>(L, &ret, [L](example::Node *arg1) {
        olua_push_object(L, arg1, "example.Node");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getColor(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // const example::Color &getColor()
    const example::Color &ret = self->getColor();
    int num_ret = olua_push_example_Color(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getIdentifier(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // const example::Identifier &getIdentifier()
    const example::Identifier &ret = self->getIdentifier();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getPosition(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // const example::Point &getPosition()
    const example::Point &ret = self->getPosition();
    int num_ret = olua_push_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_new(lua_State *L)
{
    olua_startinvoke(L);

    // Node()
    example::Node *ret = new example::Node();
    int num_ret = olua_push_object(L, ret, "example.Node");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_setChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::vector<example::Node *> arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_array<example::Node *>(L, 2, &arg1, [L](example::Node **arg1) {
        olua_check_object(L, -1, arg1, "example.Node");
    });

    // void setChildren(const example::vector<example::Node *> &value)
    self->setChildren(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_setColor(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Color arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
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
    example::Identifier arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_string(L, 2, &arg1);

    // void setIdentifier(const example::Identifier &value)
    self->setIdentifier(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_setPosition(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Point arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_object(L, 2, &arg1, "example.Point");

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
    olua_require(L, "example.Point", luaopen_example_Point);
    olua_require(L, "example.Node", luaopen_example_Node);

    return 0;
}
OLUA_END_DECLS
