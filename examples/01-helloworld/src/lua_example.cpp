//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"
#include "Example.h"
#include "olua-custom.h"

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

    // example::Object()
    example::Object *ret = new example::Object();
    int num_ret = olua_push_object(L, ret, "example.Object");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object(lua_State *L)
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

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Object(lua_State *L)
{
    olua_require(L, "example",  luaopen_example);
    if (!olua_getclass(L, olua_getluatype<example::Object>(L))) {
        luaL_error(L, "class not found: example::Object");
    }
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

static int _example_ExportParent(lua_State *L)
{
    oluacls_class<example::ExportParent, example::Object>(L, "example.ExportParent");
    oluacls_func(L, "printExportParent", _example_ExportParent_printExportParent);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ExportParent(lua_State *L)
{
    olua_require(L, "example",  luaopen_example);
    if (!olua_getclass(L, olua_getluatype<example::ExportParent>(L))) {
        luaL_error(L, "class not found: example::ExportParent");
    }
    return 1;
}
OLUA_END_DECLS

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

static int _example_Hello_new(lua_State *L)
{
    olua_startinvoke(L);

    // example::Hello()
    example::Hello *ret = new example::Hello();
    int num_ret = olua_push_object(L, ret, "example.Hello");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_say(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // void say()
    self->say();

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

static int _example_Hello(lua_State *L)
{
    oluacls_class<example::Hello, example::ExportParent>(L, "example.Hello");
    oluacls_func(L, "getName", _example_Hello_getName);
    oluacls_func(L, "new", _example_Hello_new);
    oluacls_func(L, "say", _example_Hello_say);
    oluacls_func(L, "setName", _example_Hello_setName);
    oluacls_prop(L, "name", _example_Hello_getName, _example_Hello_setName);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Hello(lua_State *L)
{
    olua_require(L, "example",  luaopen_example);
    if (!olua_getclass(L, olua_getluatype<example::Hello>(L))) {
        luaL_error(L, "class not found: example::Hello");
    }
    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, "example.Object", _example_Object);
    olua_require(L, "example.ExportParent", _example_ExportParent);
    olua_require(L, "example.Hello", _example_Hello);

    return 0;
}
OLUA_END_DECLS
