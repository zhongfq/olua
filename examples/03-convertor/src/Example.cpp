#include "Example.h"

using namespace example;

int olua_is_example_Color(lua_State *L, int idx)
{
    return olua_isinteger(L, idx);
}

int olua_push_example_Color(lua_State *L, const Color *value)
{
    uint32_t color = 0;
    if (value) {
        color |= value->r << 24;
        color |= value->g << 16;
        color |= value->b << 8;
        color |= value->a;
    }
    lua_pushinteger(L, color);
    return 1;
}

void olua_check_example_Color(lua_State *L, int idx, Color *value)
{
    uint32_t color = (uint32_t)olua_checkinteger(L, idx);
    value->r = (uint8_t)(color >> 24 & 0xFF);
    value->g = (uint8_t)(color >> 16 & 0xFF);
    value->b = (uint8_t)(color >> 8 & 0xFF);
    value->a = (uint8_t)(color & 0xFF);
}