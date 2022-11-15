//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"
#include "Example.h"
#include "olua-custom.h"

static int _example_GC___gc(lua_State *L)
{
    olua_startinvoke(L);

    example::GC *self = nullptr;

    olua_to_obj(L, 1, &self, "example.GC");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_GC___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::GC *)olua_toobj(L, 1, "example.GC");
    olua_push_obj(L, self, "example.GC");

    olua_endinvoke(L);

    return 1;
}

static int _example_GC_gc(lua_State *L)
{
    olua_startinvoke(L);

    example::GC *self = nullptr;

    olua_to_obj(L, 1, &self, "example.GC");

    // void gc()
    self->gc();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_GC(lua_State *L)
{
    oluacls_class(L, "example.GC", nullptr);
    oluacls_func(L, "__gc", _example_GC___gc);
    oluacls_func(L, "__olua_move", _example_GC___olua_move);
    oluacls_func(L, "gc", _example_GC_gc);

    olua_registerluatype<example::GC>(L, "example.GC");

    return 1;
}
OLUA_END_DECLS

static int _example_TestWildcardListener___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::TestWildcardListener *)olua_toobj(L, 1, "example.TestWildcardListener");
    olua_push_obj(L, self, "example.TestWildcardListener");

    olua_endinvoke(L);

    return 1;
}

static int _example_TestWildcardListener_onClick(lua_State *L)
{
    olua_startinvoke(L);

    example::TestWildcardListener *self = nullptr;

    olua_to_obj(L, 1, &self, "example.TestWildcardListener");

    // void onClick()
    self->onClick();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestWildcardListener(lua_State *L)
{
    oluacls_class(L, "example.TestWildcardListener", nullptr);
    oluacls_func(L, "__olua_move", _example_TestWildcardListener___olua_move);
    oluacls_func(L, "onClick", _example_TestWildcardListener_onClick);

    olua_registerluatype<example::TestWildcardListener>(L, "example.TestWildcardListener");
    printf("test wildcard luaopen\n");

    return 1;
}
OLUA_END_DECLS

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
    olua_push_obj(L, self, "example.Object");

    olua_endinvoke(L);

    return 1;
}

static int _example_Object_autorelease(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Object");

    // example::Object *autorelease()
    example::Object *ret = self->autorelease();
    int num_ret = olua_push_obj(L, ret, "example.Object");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_getReferenceCount(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Object");

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
    int num_ret = olua_push_obj(L, ret, "example.Object");
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

static int _example_ExportParent___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::ExportParent *)olua_toobj(L, 1, "example.ExportParent");
    olua_push_obj(L, self, "example.ExportParent");

    olua_endinvoke(L);

    return 1;
}

static int _example_ExportParent_printExportParent(lua_State *L)
{
    olua_startinvoke(L);

    example::ExportParent *self = nullptr;

    olua_to_obj(L, 1, &self, "example.ExportParent");

    // void printExportParent()
    self->printExportParent();

    olua_endinvoke(L);

    return 0;
}

static int _example_ExportParent_setObject(lua_State *L)
{
    olua_startinvoke(L);

    example::ExportParent *self = nullptr;
    example::Object *arg1 = nullptr;       /** obj */

    olua_to_obj(L, 1, &self, "example.ExportParent");
    olua_check_obj(L, 2, &arg1, "example.Object");

    // void setObject(example::Object *obj)
    self->setObject(arg1);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ExportParent(lua_State *L)
{
    oluacls_class(L, "example.ExportParent", "example.Object");
    oluacls_func(L, "__olua_move", _example_ExportParent___olua_move);
    oluacls_func(L, "printExportParent", _example_ExportParent_printExportParent);
    oluacls_func(L, "setObject", _example_ExportParent_setObject);

    olua_registerluatype<example::ExportParent>(L, "example.ExportParent");

    return 1;
}
OLUA_END_DECLS

static int _example_Hello___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Hello *)olua_toobj(L, 1, "example.Hello");
    olua_push_obj(L, self, "example.Hello");

    olua_endinvoke(L);

    return 1;
}

static int _example_Hello_as(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    const char *arg1 = nullptr;       /** cls */

    olua_to_obj(L, 1, &self, "example.Hello");
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
        if (olua_strequal(arg1, "example.TestWildcardListener")) {
            olua_pushobj_as<example::TestWildcardListener>(L, 1, self, "as.example.TestWildcardListener");
            break;
        }

        luaL_error(L, "'example::Hello' can't cast to '%s'", arg1);
    } while (0);

    olua_endinvoke(L);

    return 1;
}

static int _example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // @copyfrom(example::Singleton<example::Hello>) static example::Hello *create()
    example::Hello *ret = example::Hello::create();
    int num_ret = olua_push_obj(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getBool(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Hello");

    // std::vector<bool> getBool()
    std::vector<bool> ret = self->getBool();
    int num_ret = olua_push_array<bool>(L, &ret, [L](bool &value) {
        olua_push_bool(L, (bool)value);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Hello");

    // const std::string &getName()
    const std::string &ret = self->getName();
    int num_ret = olua_push_std_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Hello");

    // example::Singleton<example::Hello> *getSingleton()
    example::Singleton<example::Hello> *ret = self->getSingleton();
    int num_ret = olua_push_obj(L, ret, "example.Singleton<example.Hello>");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_new(lua_State *L)
{
    olua_startinvoke(L);

    // Hello()
    example::Hello *ret = new example::Hello();
    int num_ret = olua_push_obj(L, ret, "example.Hello");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_onClick(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Hello");

    // @copyfrom(example::TestWildcardListener) void onClick()
    self->onClick();

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Hello");

    // @copyfrom(example::Singleton<example::Hello>) void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_say(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Hello");

    // void say()
    self->say();

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setBool(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<bool> arg1;       /** bools */

    olua_to_obj(L, 1, &self, "example.Hello");
    olua_check_array<bool>(L, 2, &arg1, [L](bool *value) {
        olua_check_bool(L, -1, value);
    });

    // void setBool(const std::vector<bool> &bools)
    self->setBool(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::string arg1;       /** value */

    olua_to_obj(L, 1, &self, "example.Hello");
    olua_check_std_string(L, 2, &arg1);

    // void setName(const std::string &value)
    self->setName(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Singleton<example::Hello> *arg1 = nullptr;       /** sh */

    olua_to_obj(L, 1, &self, "example.Hello");
    olua_check_obj(L, 2, &arg1, "example.Singleton<example.Hello>");

    // void setSingleton(example::Singleton<example::Hello> *sh)
    self->setSingleton(arg1);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Hello(lua_State *L)
{
    oluacls_class(L, "example.Hello", "example.ExportParent");
    oluacls_func(L, "__olua_move", _example_Hello___olua_move);
    oluacls_func(L, "as", _example_Hello_as);
    oluacls_func(L, "create", _example_Hello_create);
    oluacls_func(L, "getBool", _example_Hello_getBool);
    oluacls_func(L, "getName", _example_Hello_getName);
    oluacls_func(L, "getSingleton", _example_Hello_getSingleton);
    oluacls_func(L, "new", _example_Hello_new);
    oluacls_func(L, "onClick", _example_Hello_onClick);
    oluacls_func(L, "printSingleton", _example_Hello_printSingleton);
    oluacls_func(L, "say", _example_Hello_say);
    oluacls_func(L, "setBool", _example_Hello_setBool);
    oluacls_func(L, "setName", _example_Hello_setName);
    oluacls_func(L, "setSingleton", _example_Hello_setSingleton);
    oluacls_prop(L, "bool", _example_Hello_getBool, _example_Hello_setBool);
    oluacls_prop(L, "name", _example_Hello_getName, _example_Hello_setName);
    oluacls_prop(L, "singleton", _example_Hello_getSingleton, _example_Hello_setSingleton);

    olua_registerluatype<example::Hello>(L, "example.Hello");

    return 1;
}
OLUA_END_DECLS

static int _example_TestGC___gc(lua_State *L)
{
    olua_startinvoke(L);

    olua_postgc<example::TestGC>(L, 1);

    olua_endinvoke(L);

    return 0;
}

static int _example_TestGC___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::TestGC *)olua_toobj(L, 1, "example.TestGC");
    olua_push_obj(L, self, "example.TestGC");

    olua_endinvoke(L);

    return 1;
}

static int _example_TestGC_as(lua_State *L)
{
    olua_startinvoke(L);

    example::TestGC *self = nullptr;
    const char *arg1 = nullptr;       /** cls */

    olua_to_obj(L, 1, &self, "example.TestGC");
    olua_check_string(L, 2, &arg1);

    do {
        if (olua_isa(L, 1, arg1)) {
            lua_pushvalue(L, 1);
            break;
        }
        if (olua_strequal(arg1, "example.GC")) {
            olua_pushobj_as<example::GC>(L, 1, self, "as.example.GC");
            break;
        }

        luaL_error(L, "'example::TestGC' can't cast to '%s'", arg1);
    } while (0);

    olua_endinvoke(L);

    return 1;
}

static int _example_TestGC_gc(lua_State *L)
{
    olua_startinvoke(L);

    example::TestGC *self = nullptr;

    olua_to_obj(L, 1, &self, "example.TestGC");

    // @copyfrom(example::GC) void gc()
    self->gc();

    olua_endinvoke(L);

    return 0;
}

static int _example_TestGC_new(lua_State *L)
{
    olua_startinvoke(L);

    // TestGC()
    example::TestGC *ret = new example::TestGC();
    int num_ret = olua_push_obj(L, ret, "example.TestGC");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_TestGC_testGC(lua_State *L)
{
    olua_startinvoke(L);

    example::TestGC *self = nullptr;

    olua_to_obj(L, 1, &self, "example.TestGC");

    // void testGC()
    self->testGC();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestGC(lua_State *L)
{
    oluacls_class(L, "example.TestGC", "example.TestWildcardListener");
    oluacls_func(L, "__gc", _example_TestGC___gc);
    oluacls_func(L, "__olua_move", _example_TestGC___olua_move);
    oluacls_func(L, "as", _example_TestGC_as);
    oluacls_func(L, "gc", _example_TestGC_gc);
    oluacls_func(L, "new", _example_TestGC_new);
    oluacls_func(L, "testGC", _example_TestGC_testGC);

    olua_registerluatype<example::TestGC>(L, "example.TestGC");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestWildcardClickEvent(lua_State *L)
{
    oluacls_class(L, "example.TestWildcardClickEvent", nullptr);
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_const_integer(L, "H1", (lua_Integer)example::TestWildcardClickEvent::H1);
    oluacls_const_integer(L, "H2", (lua_Integer)example::TestWildcardClickEvent::H2);
    oluacls_const_integer(L, "H3", (lua_Integer)example::TestWildcardClickEvent::H3);

    olua_registerluatype<example::TestWildcardClickEvent>(L, "example.TestWildcardClickEvent");
    printf("test wildcard luaopen\n");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestWildcardTouchEvent(lua_State *L)
{
    oluacls_class(L, "example.TestWildcardTouchEvent", nullptr);
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_const_integer(L, "T1", (lua_Integer)example::TestWildcardTouchEvent::T1);
    oluacls_const_integer(L, "T2", (lua_Integer)example::TestWildcardTouchEvent::T2);
    oluacls_const_integer(L, "T3", (lua_Integer)example::TestWildcardTouchEvent::T3);

    olua_registerluatype<example::TestWildcardTouchEvent>(L, "example.TestWildcardTouchEvent");
    printf("test wildcard luaopen\n");

    return 1;
}
OLUA_END_DECLS

static int _example_Singleton_example_Hello___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Singleton<example::Hello> *)olua_toobj(L, 1, "example.Singleton<example.Hello>");
    olua_push_obj(L, self, "example.Singleton<example.Hello>");

    olua_endinvoke(L);

    return 1;
}

static int _example_Singleton_example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // static example::Hello *create()
    example::Hello *ret = example::Singleton<example::Hello>::create();
    int num_ret = olua_push_obj(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Singleton_example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Singleton<example::Hello> *self = nullptr;

    olua_to_obj(L, 1, &self, "example.Singleton<example.Hello>");

    // void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Singleton_example_Hello(lua_State *L)
{
    oluacls_class(L, "example.Singleton<example.Hello>", nullptr);
    oluacls_func(L, "__olua_move", _example_Singleton_example_Hello___olua_move);
    oluacls_func(L, "create", _example_Singleton_example_Hello_create);
    oluacls_func(L, "printSingleton", _example_Singleton_example_Hello_printSingleton);

    olua_registerluatype<example::Singleton<example::Hello>>(L, "example.Singleton<example.Hello>");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, "example.GC", luaopen_example_GC);
    olua_require(L, "example.TestWildcardListener", luaopen_example_TestWildcardListener);
    olua_require(L, "example.Object", luaopen_example_Object);
    olua_require(L, "example.ExportParent", luaopen_example_ExportParent);
    olua_require(L, "example.Hello", luaopen_example_Hello);
    olua_require(L, "example.TestGC", luaopen_example_TestGC);
    olua_require(L, "example.TestWildcardClickEvent", luaopen_example_TestWildcardClickEvent);
    olua_require(L, "example.TestWildcardTouchEvent", luaopen_example_TestWildcardTouchEvent);
    olua_require(L, "example.Singleton<example.Hello>", luaopen_example_Singleton_example_Hello);

    return 0;
}
OLUA_END_DECLS
