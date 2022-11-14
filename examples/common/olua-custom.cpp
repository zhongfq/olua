#include "olua-custom.h"

#include <unordered_map>
#include <functional>
#include <thread>

using namespace example;

lua_State *olua_invokingstate = NULL;
static lua_State *GL = NULL;
static std::unordered_map<std::string, std::string> _typemap;
static std::thread::id _thread;

extern bool assert_script_compatible(const char *msg)
{
    if (olua_invokingstate) {
        lua_State *L = olua_invokingstate;
        olua_invokingstate = NULL;
        luaL_error(L, msg);
    }
    return false;
}

static int _errorfunc(lua_State *L)
{
    const char *errmsg = NULL;
    const char *errstack = NULL;
    
    if (olua_isthread(L, 1)) {
        errmsg = luaL_optstring(L, 2, "");
        luaL_traceback(L, lua_tothread(L, 1), NULL, 0);
        errstack = lua_tostring(L, -1);
    } else {
        errmsg = lua_tostring(L, 1);
    }
    
    luaL_traceback(L, L, errstack, 1);
    errstack = lua_tostring(L, -1);
    
    if (errmsg == NULL) {
        errmsg = "";
    }
    
    printf("--------------------LUA ERROR--------------------\n%s\n%s\n", errmsg, errstack);
    
    return 0;
}

lua_State *olua_new()
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, _errorfunc);
    lua_setglobal(L, "__TRACEBACK__");
    GL = L;
    _thread = std::this_thread::get_id();
    return L;
}

int olua_dofile(lua_State *L, const char *path)
{
    int status;
    if ((status = luaL_loadfile(L, path)) != LUA_OK) {
        printf("%s\n", lua_tostring(L, -1));
        return status;
    }
    lua_pushstring(L, path);
    return olua_pcall(L, 1, 0);
}

int olua_objgc(lua_State *L)
{
    auto obj = olua_toobj<Object>(L, 1);
    if (olua_isdebug(L)) {
        int top = lua_gettop(L);
        lua_getfield(L, 1, "name");
        const char *name = lua_tostring(L, -1);
        const char *str = olua_objstring(L, 1);
        printf("lua gc: %s(NAME=%s, RC=%d, TC=%d)\n", str,
            name && strlen(name) > 0 ? name : "''",
            obj->getReferenceCount() - 1, (int)olua_objcount(L));
        lua_settop(L, top);
    }
    obj->release();
    olua_setrawobj(L, 1, nullptr);
    lua_pushnil(L);
    lua_setuservalue(L, 1);
    return 0;
}

#ifdef OLUA_HAVE_MAINTHREAD
OLUA_API lua_State *olua_mainthread(lua_State *L)
{
    return GL;
}
#endif

#ifdef OLUA_HAVE_CHECKHOSTTHREAD
OLUA_API void olua_checkhostthread()
{
    assert(std::this_thread::get_id() == _thread);
}
#endif

#ifdef OLUA_HAVE_CMPREF
OLUA_API void olua_startcmpref(lua_State *L, int idx, const char *refname)
{
    if (olua_loadref(L, idx, refname) == LUA_TTABLE) {
        lua_pushnil(L);
        while (lua_next(L, -2)) {
            if (olua_isa<Object>(L, -2)) {
                auto obj = olua_toobj<Object>(L, -2);
                lua_pushvalue(L, -2);
                lua_pushinteger(L, obj->getReferenceCount());
                lua_rawset(L, -5);
            }
            lua_pop(L, 1);
        }
    }
    lua_pop(L, 1);
}

static bool should_delref(lua_State *L, int idx)
{
    if (olua_isa<Object>(L, idx)) {
        auto obj = olua_toobj<Object>(L, idx);
        if (olua_isinteger(L, -1)) {
            unsigned int last = (unsigned int)olua_tointeger(L, -1);
            unsigned int curr = obj->getReferenceCount();
            if (curr < last || curr == 1) {
                return true;
            }
        }
    }
    return false;
}

OLUA_API void olua_endcmpref(lua_State *L, int idx, const char *refname)
{
    olua_visitrefs(L, idx, refname, should_delref);
}
#endif

#ifdef OLUA_HAVE_LUATYPE
OLUA_API void olua_registerluatype(lua_State *L, const char *cpptype, const char *cls)
{
    _typemap[cpptype] = cls;
}

OLUA_API const char *olua_getluatype(lua_State *L, const char *cpptype)
{
    auto cls = _typemap.find(cpptype);
    return cls != _typemap.end() ? cls->second.c_str() : nullptr;
}
#endif
