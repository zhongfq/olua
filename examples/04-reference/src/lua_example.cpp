//
// AUTO GENERATED, DO NOT MODIFY!
//
#include "lua_example.h"
#include "Example.h"
#include "olua-custom.h"

static int _olua_module_example(lua_State *L);

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

static int _olua_fun_example_Node_addChild$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** child */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_object(L, 2, &arg1, "example.Node");

    // void addChild(@addref(children |) example::Node *child)
    self->addChild(arg1);

    // insert code after call
    olua_addref(L, 1, "children", 2, OLUA_REF_MULTI);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_addChild$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** child */
    std::string arg2;       /** name */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_object(L, 2, &arg1, "example.Node");
    olua_check_string(L, 3, &arg2);

    // void addChild(@addref(children |) example::Node *child, const std::string &name)
    self->addChild(arg1, arg2);

    // insert code after call
    olua_addref(L, 1, "children", 2, OLUA_REF_MULTI);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_addChild(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        // if ((olua_is_object(L, 1, "example.Node")) && (olua_is_object(L, 2, "example.Node"))) {
            // void addChild(@addref(children |) example::Node *child)
            return _olua_fun_example_Node_addChild$1(L);
        // }
    }

    if (num_args == 3) {
        // if ((olua_is_object(L, 1, "example.Node")) && (olua_is_object(L, 2, "example.Node")) && (olua_is_string(L, 3))) {
            // void addChild(@addref(children |) example::Node *child, const std::string &name)
            return _olua_fun_example_Node_addChild$2(L);
        // }
    }

    luaL_error(L, "method 'example::Node::addChild' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Node_getChildByName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    std::string arg1;       /** name */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_string(L, 2, &arg1);

    // @addref(children |) example::Node *getChildByName(const std::string &name)
    example::Node *ret = self->getChildByName(arg1);
    int num_ret = olua_push_object(L, ret, "example.Node");

    // insert code after call
    olua_addref(L, 1, "children", -1, OLUA_REF_MULTI);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Node_getChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // example::vector<example::Node *> &getChildren()
    example::vector<example::Node *> &ret = self->getChildren();
    int num_ret = olua_push_array<example::Node *>(L, ret, [L](example::Node *arg1) {
        olua_push_object(L, arg1, "example.Node");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Node_getComponent(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // @addref(component ^) example::Node *getComponent()
    example::Node *ret = self->getComponent();
    int num_ret = olua_push_object(L, ret, "example.Node");

    // insert code after call
    olua_addref(L, 1, "component", -1, OLUA_REF_ALONE);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Node_getName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // const std::string &getName()
    const std::string &ret = self->getName();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Node_getNumChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // size_t getNumChildren()
    size_t ret = self->getNumChildren();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_fun_example_Node_getParent(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // example::Node *getParent()
    example::Node *ret = self->getParent();
    int num_ret = olua_push_object(L, ret, "example.Node");

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

static int _olua_fun_example_Node_removeAllChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // @delref(children *) void removeAllChildren()
    self->removeAllChildren();

    // insert code after call
    olua_delallrefs(L, 1, "children");

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_removeChild(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** child */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_object(L, 2, &arg1, "example.Node");

    // void removeChild(@delref(children |) example::Node *child)
    self->removeChild(arg1);

    // insert code after call
    olua_delref(L, 1, "children", 2, OLUA_REF_MULTI);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_removeChildByName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    std::string arg1;       /** name */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_string(L, 2, &arg1);

    // insert code before call
    olua_startcmpref(L, 1, "children");

    // @delref(children ~) void removeChildByName(const std::string &name)
    self->removeChildByName(arg1);

    // insert code after call
    olua_endcmpref(L, 1, "children");

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_removeSelf(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_object(L, 1, &self, "example.Node");

    // insert code before call
    if (!self->getParent()) {
        return 0;
    }
    olua_pushobj<example::Node>(L, self->getParent());
    int parent = lua_gettop(L);

    // @delref(children | parent) void removeSelf()
    self->removeSelf();

    // insert code after call
    olua_delref(L, parent, "children", 1, OLUA_REF_MULTI);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_setComponent(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_object(L, 2, &arg1, "example.Node");

    // void setComponent(@addref(component ^) example::Node *value)
    self->setComponent(arg1);

    // insert code after call
    olua_addref(L, 1, "component", 2, OLUA_REF_ALONE);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Node_setName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    std::string arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Node");
    olua_check_string(L, 2, &arg1);

    // void setName(const std::string &value)
    self->setName(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_cls_example_Node(lua_State *L)
{
    oluacls_class<example::Node, example::Object>(L, "example.Node");
    oluacls_func(L, "addChild", _olua_fun_example_Node_addChild);
    oluacls_func(L, "getChildByName", _olua_fun_example_Node_getChildByName);
    oluacls_func(L, "getChildren", _olua_fun_example_Node_getChildren);
    oluacls_func(L, "getComponent", _olua_fun_example_Node_getComponent);
    oluacls_func(L, "getName", _olua_fun_example_Node_getName);
    oluacls_func(L, "getNumChildren", _olua_fun_example_Node_getNumChildren);
    oluacls_func(L, "getParent", _olua_fun_example_Node_getParent);
    oluacls_func(L, "new", _olua_fun_example_Node_new);
    oluacls_func(L, "removeAllChildren", _olua_fun_example_Node_removeAllChildren);
    oluacls_func(L, "removeChild", _olua_fun_example_Node_removeChild);
    oluacls_func(L, "removeChildByName", _olua_fun_example_Node_removeChildByName);
    oluacls_func(L, "removeSelf", _olua_fun_example_Node_removeSelf);
    oluacls_func(L, "setComponent", _olua_fun_example_Node_setComponent);
    oluacls_func(L, "setName", _olua_fun_example_Node_setName);
    oluacls_prop(L, "children", _olua_fun_example_Node_getChildren, nullptr);
    oluacls_prop(L, "component", _olua_fun_example_Node_getComponent, _olua_fun_example_Node_setComponent);
    oluacls_prop(L, "name", _olua_fun_example_Node_getName, _olua_fun_example_Node_setName);
    oluacls_prop(L, "numChildren", _olua_fun_example_Node_getNumChildren, nullptr);
    oluacls_prop(L, "parent", _olua_fun_example_Node_getParent, nullptr);

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
