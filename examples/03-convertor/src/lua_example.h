//
// AUTO BUILD, DON'T MODIFY!
//
#ifndef __AUTO_GEN_LUA_EXAMPLE_H__
#define __AUTO_GEN_LUA_EXAMPLE_H__

#include "Convertor.h"
#include "xlua.h"

int luaopen_example(lua_State *L);

// example::Point
int olua_push_example_Point(lua_State *L, const example::Point *value);
void olua_check_example_Point(lua_State *L, int idx, example::Point *value);
bool olua_is_example_Point(lua_State *L, int idx);
void olua_pack_example_Point(lua_State *L, int idx, example::Point *value);
int olua_unpack_example_Point(lua_State *L, const example::Point *value);
bool olua_ispack_example_Point(lua_State *L, int idx);

#endif