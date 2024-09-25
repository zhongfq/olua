//
// AUTO GENERATED, DO NOT MODIFY!
//
#include "lua_example.h"

static int _olua_module_example(lua_State *L);

OLUA_LIB void olua_pack_object(lua_State *L, int idx, example::Point *value)
{
    idx = lua_absindex(L, idx);

    int arg1 = 0;       /** x */
    int arg2 = 0;       /** y */

    olua_check_integer(L, idx + 0, &arg1);
    value->x = arg1;

    olua_check_integer(L, idx + 1, &arg2);
    value->y = arg2;
}

OLUA_LIB int olua_unpack_object(lua_State *L, const example::Point *value)
{
    olua_push_integer(L, value->x);
    olua_push_integer(L, value->y);

    return 2;
}

OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const example::Point *)
{
    return olua_is_integer(L, idx + 0) && olua_is_integer(L, idx + 1);
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

static int _olua_fun_example_Point___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::Point *)olua_toobj(L, 1, "example.Point");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
}

static int _olua_fun_example_Point_x$1(lua_State *L)
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

static int _olua_fun_example_Point_x$2(lua_State *L)
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

static int _olua_fun_example_Point_x(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // int x
        return _olua_fun_example_Point_x$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Point")) && (olua_is_integer(L, 2))) {
            // int x
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

    // int y
    int ret = self->y;
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Point_y$2(lua_State *L)
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

static int _olua_fun_example_Point_y(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 1) {
        // int y
        return _olua_fun_example_Point_y$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Point")) && (olua_is_integer(L, 2))) {
            // int y
            return _olua_fun_example_Point_y$2(L);
        // }
    }

    luaL_error(L, "method 'example::Point::y' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_cls_example_Point(lua_State *L)
{
    oluacls_class<example::Point>(L, "example.Point");
    oluacls_func(L, "__gc", _olua_fun_example_Point___gc);
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

static int _olua_fun_example_Node___index(lua_State *L)
{
    olua_startinvoke(L);

    // @extend(example::NodeExtend) static olua_Return __index(lua_State *L)
    olua_Return ret = example::NodeExtend::__index(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _olua_fun_example_Node_getChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // const example::vector<example::Node *> &getChildren()
    const example::vector<example::Node *> &ret = self->getChildren();
    int num_ret = olua_push_array<example::Node *>(L, ret, [L](example::Node *arg1) {
        olua_push_object(L, arg1, "example.Node");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Node_getColor(lua_State *L)
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

static int _olua_fun_example_Node_getIdentifier(lua_State *L)
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

static int _olua_fun_example_Node_getPosition(lua_State *L)
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

static int _olua_fun_example_Node_new(lua_State *L)
{
    olua_startinvoke(L);

    // example::Node()
    example::Node *ret = new example::Node();
    int num_ret = olua_push_object(L, ret, "example.Node");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Node_setChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::vector<example::Node *> arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_array<example::Node *>(L, 2, arg1, [L](example::Node **arg1) {
        olua_check_object(L, -1, arg1, "example.Node");
    });

    // void setChildren(const example::vector<example::Node *> &value)
    self->setChildren(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_setColor(lua_State *L)
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

static int _olua_fun_example_Node_setIdentifier(lua_State *L)
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

static int _olua_fun_example_Node_setPosition(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Point *arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_object(L, 2, &arg1, "example.Point");

    // void setPosition(const example::Point &value)
    self->setPosition(*arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_cls_example_Node(lua_State *L)
{
    oluacls_class<example::Node, example::Object>(L, "example.Node");
    oluacls_func(L, "__index", _olua_fun_example_Node___index);
    oluacls_func(L, "getChildren", _olua_fun_example_Node_getChildren);
    oluacls_func(L, "getColor", _olua_fun_example_Node_getColor);
    oluacls_func(L, "getIdentifier", _olua_fun_example_Node_getIdentifier);
    oluacls_func(L, "getPosition", _olua_fun_example_Node_getPosition);
    oluacls_func(L, "new", _olua_fun_example_Node_new);
    oluacls_func(L, "setChildren", _olua_fun_example_Node_setChildren);
    oluacls_func(L, "setColor", _olua_fun_example_Node_setColor);
    oluacls_func(L, "setIdentifier", _olua_fun_example_Node_setIdentifier);
    oluacls_func(L, "setPosition", _olua_fun_example_Node_setPosition);
    oluacls_prop(L, "children", _olua_fun_example_Node_getChildren, _olua_fun_example_Node_setChildren);
    oluacls_prop(L, "color", _olua_fun_example_Node_getColor, _olua_fun_example_Node_setColor);
    oluacls_prop(L, "identifier", _olua_fun_example_Node_getIdentifier, _olua_fun_example_Node_setIdentifier);
    oluacls_prop(L, "position", _olua_fun_example_Node_getPosition, _olua_fun_example_Node_setPosition);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Node(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Node")) {
        luaL_error(L, "class not found: example::Node");
    }
    return 1;
}
OLUA_END_DECLS

int _olua_module_example(lua_State *L)
{
    olua_require(L, "example.Object", _olua_cls_example_Object);
    olua_require(L, "example.Point", _olua_cls_example_Point);
    olua_require(L, "example.Node", _olua_cls_example_Node);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);

    return 0;
}
OLUA_END_DECLS
