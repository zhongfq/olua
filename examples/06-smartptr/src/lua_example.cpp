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

static int _olua_fun_example_Hello___gc(lua_State *L)
{
    olua_startinvoke(L);
    auto self = (example::Hello *)olua_toobj(L, 1, "example.Hello");
    olua_postgc(L, self);
    olua_endinvoke(L);
    return 0;
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

static int _olua_fun_example_Hello_getThis(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::shared_ptr<example::Hello> getThis()
    std::shared_ptr<example::Hello> ret = self->getThis();
    int num_ret = olua_push_smartptr(L, &ret, "example.Hello");

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

static int _olua_fun_example_Hello_say(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // void say()
    self->say();

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

static int _olua_fun_example_Hello_setThis$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::shared_ptr<example::Hello> arg1;       /** sp */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_smartptr(L, 2, &arg1, "example.Hello");

    // void setThis(const std::shared_ptr<example::Hello> &sp)
    self->setThis(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setThis$2(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    int arg1 = 0;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_integer(L, 2, &arg1);

    // void setThis(int v)
    self->setThis(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _olua_fun_example_Hello_setThis(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 2) {
        if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_smartptr(L, 2, "example.Hello"))) {
            // void setThis(const std::shared_ptr<example::Hello> &sp)
            return _olua_fun_example_Hello_setThis$1(L);
        }

        // if ((olua_is_object(L, 1, "example.Hello")) && (olua_is_integer(L, 2))) {
            // void setThis(int v)
            return _olua_fun_example_Hello_setThis$2(L);
        // }
    }

    luaL_error(L, "method 'example::Hello::setThis' not support '%d' arguments", num_args);

    return 0;
}

static int _olua_fun_example_Hello_shared_from_this(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @copyfrom(std::enable_shared_from_this) std::shared_ptr<example::Hello> shared_from_this()
    std::shared_ptr<example::Hello> ret = self->shared_from_this();
    int num_ret = olua_push_smartptr(L, &ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _olua_cls_example_Hello(lua_State *L)
{
    oluacls_class<example::Hello>(L, "example.Hello");
    oluacls_func(L, "__gc", _olua_fun_example_Hello___gc);
    oluacls_func(L, "getName", _olua_fun_example_Hello_getName);
    oluacls_func(L, "getThis", _olua_fun_example_Hello_getThis);
    oluacls_func(L, "new", _olua_fun_example_Hello_new);
    oluacls_func(L, "say", _olua_fun_example_Hello_say);
    oluacls_func(L, "setName", _olua_fun_example_Hello_setName);
    oluacls_func(L, "setThis", _olua_fun_example_Hello_setThis);
    oluacls_func(L, "shared_from_this", _olua_fun_example_Hello_shared_from_this);
    oluacls_prop(L, "name", _olua_fun_example_Hello_getName, _olua_fun_example_Hello_setName);
    oluacls_prop(L, "this", _olua_fun_example_Hello_getThis, nullptr);

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

int _olua_module_example(lua_State *L)
{
    olua_require(L, "example.Object", _olua_cls_example_Object);
    olua_require(L, "example.Hello", _olua_cls_example_Hello);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);

    return 0;
}
OLUA_END_DECLS
