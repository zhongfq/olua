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

    olua_to_object(L, 1, &self, "example.GC");

    // olua_Return __gc(lua_State *L)
    olua_Return ret = self->__gc(L);

    olua_endinvoke(L);

    return (int)ret;
}

static int _example_GC___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::GC *)olua_toobj(L, 1, "example.GC");
    olua_push_object(L, self, "example.GC");

    olua_endinvoke(L);

    return 1;
}

static int _example_GC_gc(lua_State *L)
{
    olua_startinvoke(L);

    example::GC *self = nullptr;

    olua_to_object(L, 1, &self, "example.GC");

    // @copyfrom(example::GC) void gc()
    self->gc();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_GC(lua_State *L)
{
    oluacls_class<example::GC>(L, "example.GC");
    oluacls_func(L, "__gc", _example_GC___gc);
    oluacls_func(L, "__olua_move", _example_GC___olua_move);
    oluacls_func(L, "gc", _example_GC_gc);

    return 1;
}
OLUA_END_DECLS

static int _example_TestWildcardListener___gc(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::TestWildcardListener *)olua_toobj(L, 1, "example.TestWildcardListener");
    olua_postgc(L, self);

    olua_endinvoke(L);

    return 0;
}

static int _example_TestWildcardListener___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::TestWildcardListener *)olua_toobj(L, 1, "example.TestWildcardListener");
    olua_push_object(L, self, "example.TestWildcardListener");

    olua_endinvoke(L);

    return 1;
}

static int _example_TestWildcardListener_hello(lua_State *L)
{
    olua_startinvoke(L);

    example::TestWildcardListener *self = nullptr;

    olua_to_object(L, 1, &self, "example.TestWildcardListener");

    // @copyfrom(example::TestWildcardListener) void hello()
    self->hello();

    olua_endinvoke(L);

    return 0;
}

static int _example_TestWildcardListener_onClick(lua_State *L)
{
    olua_startinvoke(L);

    example::TestWildcardListener *self = nullptr;

    olua_to_object(L, 1, &self, "example.TestWildcardListener");

    // @copyfrom(example::TestWildcardListener) void onClick()
    self->onClick();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestWildcardListener(lua_State *L)
{
    oluacls_class<example::TestWildcardListener>(L, "example.TestWildcardListener");
    oluacls_func(L, "__gc", _example_TestWildcardListener___gc);
    oluacls_func(L, "__olua_move", _example_TestWildcardListener___olua_move);
    oluacls_func(L, "hello", _example_TestWildcardListener_hello);
    oluacls_func(L, "onClick", _example_TestWildcardListener_onClick);

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

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Object(lua_State *L)
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

static int _example_ExportParent_setObject(lua_State *L)
{
    olua_startinvoke(L);

    example::ExportParent *self = nullptr;
    example::Object *arg1 = nullptr;       /** obj */

    olua_to_object(L, 1, &self, "example.ExportParent");
    olua_check_object(L, 2, &arg1, "example.Object");

    // void setObject(example::Object *obj)
    self->setObject(arg1);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ExportParent(lua_State *L)
{
    oluacls_class<example::ExportParent, example::Object>(L, "example.ExportParent");
    oluacls_func(L, "printExportParent", _example_ExportParent_printExportParent);
    oluacls_func(L, "setObject", _example_ExportParent_setObject);

    return 1;
}
OLUA_END_DECLS

static int _example_Hello_as(lua_State *L)
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
        if (olua_strequal(arg1, "example.TestWildcardListener")) {
            olua_pushobj_as<example::TestWildcardListener>(L, 1, self, "as.example.TestWildcardListener");
            break;
        }

        luaL_error(L, "'example::Hello' can't cast to '%s'", arg1);
    } while (0);

    olua_endinvoke(L);

    return 1;
}

static int _example_Hello_checkValue(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    int32_t *arg1 = nullptr;       /** t */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_pointer(L, 2, &arg1, "olua.int32");

    // void checkValue(int32_t *t)
    self->checkValue(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // @copyfrom(example::Singleton) static example::Hello *create()
    example::Hello *ret = example::Hello::create();
    int num_ret = olua_push_object(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getBool(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<bool> getBool()
    std::vector<bool> ret = self->getBool();
    int num_ret = olua_push_array<bool>(L, ret, [L](bool &arg1) {
        olua_push_bool(L, arg1);
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

static int _example_Hello_getSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // example::Singleton<example::Hello> *getSingleton()
    example::Singleton<example::Hello> *ret = self->getSingleton();
    int num_ret = olua_push_object(L, ret, "example.Singleton<example.Hello>");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_hello(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @copyfrom(example::TestWildcardListener) void hello()
    self->hello();

    olua_endinvoke(L);

    return 0;
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

static int _example_Hello_onClick(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @copyfrom(example::TestWildcardListener) void onClick()
    self->onClick();

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // @copyfrom(example::Singleton) void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
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

static int _example_Hello_setBool(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<bool> arg1;       /** bools */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<bool>(L, 2, arg1, [L](bool *arg1) {
        olua_check_bool(L, -1, arg1);
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

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

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

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "example.Singleton<example.Hello>");

    // void setSingleton(example::Singleton<example::Hello> *sh)
    self->setSingleton(arg1);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Hello(lua_State *L)
{
    oluacls_class<example::Hello, example::ExportParent>(L, "example.Hello");
    oluacls_func(L, "as", _example_Hello_as);
    oluacls_func(L, "checkValue", _example_Hello_checkValue);
    oluacls_func(L, "create", _example_Hello_create);
    oluacls_func(L, "getBool", _example_Hello_getBool);
    oluacls_func(L, "getName", _example_Hello_getName);
    oluacls_func(L, "getSingleton", _example_Hello_getSingleton);
    oluacls_func(L, "hello", _example_Hello_hello);
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

    return 1;
}
OLUA_END_DECLS

static int _example_TestGC_as(lua_State *L)
{
    olua_startinvoke(L);

    example::TestGC *self = nullptr;
    const char *arg1 = nullptr;       /** cls */

    olua_to_object(L, 1, &self, "example.TestGC");
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

    olua_to_object(L, 1, &self, "example.TestGC");

    // @copyfrom(example::GC) void gc()
    self->gc();

    olua_endinvoke(L);

    return 0;
}

static int _example_TestGC_new(lua_State *L)
{
    olua_startinvoke(L);

    // example::TestGC()
    example::TestGC *ret = new example::TestGC();
    int num_ret = olua_push_object(L, ret, "example.TestGC");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_TestGC_testGC(lua_State *L)
{
    olua_startinvoke(L);

    example::TestGC *self = nullptr;

    olua_to_object(L, 1, &self, "example.TestGC");

    // void testGC()
    self->testGC();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestGC(lua_State *L)
{
    oluacls_class<example::TestGC, example::TestWildcardListener>(L, "example.TestGC");
    oluacls_func(L, "as", _example_TestGC_as);
    oluacls_func(L, "gc", _example_TestGC_gc);
    oluacls_func(L, "new", _example_TestGC_new);
    oluacls_func(L, "testGC", _example_TestGC_testGC);

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestWildcardClickEvent(lua_State *L)
{
    oluacls_class<example::TestWildcardClickEvent>(L, "example.TestWildcardClickEvent");
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_enum(L, "H1", (lua_Integer)example::TestWildcardClickEvent::H1);
    oluacls_enum(L, "H2", (lua_Integer)example::TestWildcardClickEvent::H2);
    oluacls_enum(L, "H3", (lua_Integer)example::TestWildcardClickEvent::H3);

    printf("test wildcard luaopen\n");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_TestWildcardTouchEvent(lua_State *L)
{
    oluacls_class<example::TestWildcardTouchEvent>(L, "example.TestWildcardTouchEvent");
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_enum(L, "T1", (lua_Integer)example::TestWildcardTouchEvent::T1);
    oluacls_enum(L, "T2", (lua_Integer)example::TestWildcardTouchEvent::T2);
    oluacls_enum(L, "T3", (lua_Integer)example::TestWildcardTouchEvent::T3);

    printf("test wildcard luaopen\n");

    return 1;
}
OLUA_END_DECLS

static int _example_Singleton_example_Hello___gc(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Singleton<example::Hello> *)olua_toobj(L, 1, "example.Singleton<example.Hello>");
    olua_postgc(L, self);

    olua_endinvoke(L);

    return 0;
}

static int _example_Singleton_example_Hello___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Singleton<example::Hello> *)olua_toobj(L, 1, "example.Singleton<example.Hello>");
    olua_push_object(L, self, "example.Singleton<example.Hello>");

    olua_endinvoke(L);

    return 1;
}

static int _example_Singleton_example_Hello_create(lua_State *L)
{
    olua_startinvoke(L);

    // @copyfrom(example::Singleton) static example::Hello *create()
    example::Hello *ret = example::Singleton<example::Hello>::create();
    int num_ret = olua_push_object(L, ret, "example.Hello");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Singleton_example_Hello_printSingleton(lua_State *L)
{
    olua_startinvoke(L);

    example::Singleton<example::Hello> *self = nullptr;

    olua_to_object(L, 1, &self, "example.Singleton<example.Hello>");

    // @copyfrom(example::Singleton) void printSingleton()
    self->printSingleton();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Singleton_example_Hello(lua_State *L)
{
    oluacls_class<example::Singleton<example::Hello>>(L, "example.Singleton<example.Hello>");
    oluacls_func(L, "__gc", _example_Singleton_example_Hello___gc);
    oluacls_func(L, "__olua_move", _example_Singleton_example_Hello___olua_move);
    oluacls_func(L, "create", _example_Singleton_example_Hello_create);
    oluacls_func(L, "printSingleton", _example_Singleton_example_Hello_printSingleton);

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
