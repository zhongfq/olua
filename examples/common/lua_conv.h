#ifndef __EXAMPLES_CONV__
#define __EXAMPLES_CONV__

#include "Object.h"

// example::vector
template <class T>
void olua_insert_array(example::vector<T> *array, T value)
{
    array->push_back(value);
}

template <class T>
void olua_foreach_array(const example::vector<T> *array, const std::function<void(T)> &callback)
{
    for (auto itor : (*array)) {
        callback(itor);
    }
}

static inline bool olua_is_example_vector(lua_State *L, int idx)
{
    return olua_istable(L, idx);
}

template <class T>
int olua_push_example_vector(lua_State *L, const example::vector<T> *array, const std::function<void(T)> &push)
{
    return olua_push_array<T, example::vector>(L, array, push);
}

template <class T>
void olua_check_example_vector(lua_State *L, int idx, example::vector<T> *array, const std::function<void(T *)> &check)
{
    olua_check_array<T, example::vector>(L, idx, array, check);
}

template <typename T>
void olua_pack_example_vector(lua_State *L, int idx, example::vector<T> *array, const std::function<void(T *)> &check)
{
    olua_pack_array<T, example::vector>(L, idx, array, check);
}

#endif
