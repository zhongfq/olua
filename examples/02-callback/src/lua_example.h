//
// AUTO BUILD, DON'T MODIFY!
//
#ifndef __AUTO_GEN_LUA_EXAMPLE_H__
#define __AUTO_GEN_LUA_EXAMPLE_H__

#include "Callback.h"
#include "xlua.h"

int luaopen_example(lua_State *L);

// example::Callback::Listener
bool olua_is_example_Callback_Listener(lua_State *L, int idx);
int olua_push_example_Callback_Listener(lua_State *L, const example::Callback::Listener *value);
void olua_check_example_Callback_Listener(lua_State *L, int idx, example::Callback::Listener *value);

#endif