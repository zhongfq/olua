//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"

static int _example_Object___gc(lua_State *L)
{
    olua_startinvoke(L);

    olua_endinvoke(L);

    return xlua_objgc(L);
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

static int luaopen_example_Object(lua_State *L)
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

static int _example_Node___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Node *)olua_toobj(L, 1, "example.Node");
    olua_push_cppobj(L, self, "example.Node");

    olua_endinvoke(L);

    return 1;
}

static int _example_Node_addChild1(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** child */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_cppobj(L, 2, (void **)&arg1, "example.Node");

    // void addChild(@addref(children |) example::Node *child)
    self->addChild(arg1);

    // insert code after call
    olua_addref(L, 1, "children", 2, OLUA_MODE_MULTIPLE);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_addChild2(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** child */
    std::string arg2;       /** name */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_cppobj(L, 2, (void **)&arg1, "example.Node");
    olua_check_std_string(L, 3, &arg2);

    // void addChild(@addref(children |) example::Node *child, const std::string &name)
    self->addChild(arg1, arg2);

    // insert code after call
    olua_addref(L, 1, "children", 2, OLUA_MODE_MULTIPLE);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_addChild(lua_State *L)
{
    int num_args = lua_gettop(L) - 1;

    if (num_args == 1) {
        // if ((olua_is_cppobj(L, 2, "example.Node"))) {
            // void addChild(@addref(children |) example::Node *child)
            return _example_Node_addChild1(L);
        // }
    }

    if (num_args == 2) {
        // if ((olua_is_cppobj(L, 2, "example.Node")) && (olua_is_std_string(L, 3))) {
            // void addChild(@addref(children |) example::Node *child, const std::string &name)
            return _example_Node_addChild2(L);
        // }
    }

    luaL_error(L, "method 'example::Node::addChild' not support '%d' arguments", num_args);

    return 0;
}

static int _example_Node_getChildByName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    std::string arg1;       /** name */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_std_string(L, 2, &arg1);

    // @addref(children |) example::Node *getChildByName(const std::string &name)
    example::Node *ret = self->getChildByName(arg1);
    int num_ret = olua_push_cppobj(L, ret, "example.Node");

    // insert code after call
    olua_addref(L, 1, "children", -1, OLUA_MODE_MULTIPLE);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getComponent(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // @addref(component ^) example::Node *getComponent()
    example::Node *ret = self->getComponent();
    int num_ret = olua_push_cppobj(L, ret, "example.Node");

    // insert code after call
    olua_addref(L, 1, "component", -1, OLUA_MODE_SINGLE);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // const std::string &getName()
    const std::string &ret = self->getName();
    int num_ret = olua_push_std_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getNumChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // size_t getNumChildren()
    size_t ret = self->getNumChildren();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Node_getParent(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // example::Node *getParent()
    example::Node *ret = self->getParent();
    int num_ret = olua_push_cppobj(L, ret, "example.Node");

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

static int _example_Node_removeAllChildren(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // @delref(children *) void removeAllChildren()
    self->removeAllChildren();

    // insert code after call
    olua_delallrefs(L, 1, "children");

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_removeChild(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** child */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_cppobj(L, 2, (void **)&arg1, "example.Node");

    // void removeChild(@delref(children |) example::Node *child)
    self->removeChild(arg1);

    // insert code after call
    olua_delref(L, 1, "children", 2, OLUA_MODE_MULTIPLE);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_removeChildByName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    std::string arg1;       /** name */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_std_string(L, 2, &arg1);

    // insert code before call
    olua_startcmpref(L, 1, "children");

    // @delref(children ~) void removeChildByName(const std::string &name)
    self->removeChildByName(arg1);

    // insert code after call
    olua_endcmpref(L, 1, "children");

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_removeSelf(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");

    // insert code before call
    if (!self->getParent()) {
        return 0;
    }
    olua_push_cppobj<example::Node>(L, self->getParent());
    int parent = lua_gettop(L);

    // @delref(children | parent) void removeSelf()
    self->removeSelf();

    // insert code after call
    olua_delref(L, parent, "children", 1, OLUA_MODE_MULTIPLE);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_setComponent(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    example::Node *arg1 = nullptr;       /** value */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_cppobj(L, 2, (void **)&arg1, "example.Node");

    // void setComponent(@addref(component ^) example::Node *value)
    self->setComponent(arg1);

    // insert code after call
    olua_addref(L, 1, "component", 2, OLUA_MODE_SINGLE);

    olua_endinvoke(L);

    return 0;
}

static int _example_Node_setName(lua_State *L)
{
    olua_startinvoke(L);

    example::Node *self = nullptr;
    std::string arg1;       /** value */

    olua_to_cppobj(L, 1, (void **)&self, "example.Node");
    olua_check_std_string(L, 2, &arg1);

    // void setName(const std::string &value)
    self->setName(arg1);

    olua_endinvoke(L);

    return 0;
}

static int luaopen_example_Node(lua_State *L)
{
    oluacls_class(L, "example.Node", "example.Object");
    oluacls_func(L, "__olua_move", _example_Node___olua_move);
    oluacls_func(L, "addChild", _example_Node_addChild);
    oluacls_func(L, "getChildByName", _example_Node_getChildByName);
    oluacls_func(L, "getComponent", _example_Node_getComponent);
    oluacls_func(L, "getName", _example_Node_getName);
    oluacls_func(L, "getNumChildren", _example_Node_getNumChildren);
    oluacls_func(L, "getParent", _example_Node_getParent);
    oluacls_func(L, "new", _example_Node_new);
    oluacls_func(L, "removeAllChildren", _example_Node_removeAllChildren);
    oluacls_func(L, "removeChild", _example_Node_removeChild);
    oluacls_func(L, "removeChildByName", _example_Node_removeChildByName);
    oluacls_func(L, "removeSelf", _example_Node_removeSelf);
    oluacls_func(L, "setComponent", _example_Node_setComponent);
    oluacls_func(L, "setName", _example_Node_setName);
    oluacls_prop(L, "component", _example_Node_getComponent, _example_Node_setComponent);
    oluacls_prop(L, "name", _example_Node_getName, _example_Node_setName);
    oluacls_prop(L, "numChildren", _example_Node_getNumChildren, nullptr);
    oluacls_prop(L, "parent", _example_Node_getParent, nullptr);

    olua_registerluatype<example::Node>(L, "example.Node");

    return 1;
}

int luaopen_example(lua_State *L)
{
    olua_require(L, "example.Object", luaopen_example_Object);
    olua_require(L, "example.Node", luaopen_example_Node);
    return 0;
}
