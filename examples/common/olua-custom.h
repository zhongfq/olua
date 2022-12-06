#ifndef __EXAMPLES_OLUA_CUSTOM_H__
#define __EXAMPLES_OLUA_CUSTOM_H__

#include "luauser.h"
#include "olua.hpp"
#include "Object.h"

extern lua_State *olua_invokingstate;

lua_State *olua_new();
int olua_dofile(lua_State *L, const char *filename);
int olua_objgc(lua_State *L);

//
// implement olua api
//
#ifdef OLUA_HAVE_MAINTHREAD
OLUA_API lua_State *olua_mainthread(lua_State *L);
#endif

#ifdef OLUA_HAVE_CHECKHOSTTHREAD
OLUA_API void olua_checkhostthread();
#endif

#ifdef OLUA_HAVE_TRACEINVOKING
#define olua_startinvoke(L)     (olua_invokingstate = L)
#define olua_endinvoke(L)       (olua_invokingstate = nullptr)
#endif

#ifdef OLUA_HAVE_CMPREF
OLUA_API void olua_startcmpref(lua_State *L, int idx, const char *refname);
OLUA_API void olua_endcmpref(lua_State *L, int idx, const char *refname);
#endif

#ifdef OLUA_HAVE_LUATYPE
OLUA_API void olua_registerluatype(lua_State *L, const char *cpptype, const char *cls);
OLUA_API const char *olua_getluatype(lua_State *L, const char *cpptype);
#endif

#ifdef OLUA_HAVE_POSTPUSH
template <typename T>
void olua_postpush(lua_State *L, T* obj, int status)
{
    if (std::is_base_of<example::Object, T>::value &&
            (status == OLUA_OBJ_NEW || status == OLUA_OBJ_UPDATE)) {
        ((example::Object *)obj)->retain();
#ifdef OLUA_DEBUG
        if (!olua_isa<example::Object>(L, -1)) {
            luaL_error(L, "class '%s' not inherit from 'example::Object'", olua_getluatype(L, obj, ""));
        }
#endif
    }
}
#endif

#ifdef OLUA_HAVE_POSTNEW
template <typename T>
void olua_postnew(lua_State *L, T *obj)
{
    if (std::is_base_of<example::Object, T>::value) {
        ((example::Object *)obj)->autorelease();
    } else if (olua_getrawobj(L, obj)) {
        olua_setownership(L, -1, OLUA_OWNERSHIP_VM);
        lua_pop(L, 1);
    }
}
#endif

#endif
