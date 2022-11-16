/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019-2022 codetypes@gmail.com
 *
 * https://github.com/zhongfq/olua
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef __OLUA_TYPES_H__
#define __OLUA_TYPES_H__

#include "olua.h"

namespace olua {

template<class T>
class pointer {
public:
    pointer(const pointer &) = delete;
    pointer &operator=(const pointer &) = delete;
    
    pointer() {}
    ~pointer() {
        if (_len > 0) {
            delete[] _data;
        }
    }
    
    pointer(const T *v)
    :_len(0)
    ,_data(v)
    {}
    
    static pointer<T> *array(size_t len) {
        pointer<T> *ret = new pointer<T>();
        ret->_len = len;
        ret->_data = new T[len];
        return ret;
    }
    
    OLUA_NAME(__index) T get(unsigned idx) {
         olua_assert(idx >= 1 && idx <= _len, "index out of range");
         return _data[idx - 1];
    }
    
    OLUA_NAME(__newindex) void set(unsigned idx, const T &v)
    {
        olua_assert(idx >= 1 && idx <= _len, "index out of range");
        _data[idx - 1] = v;
    }
    
    OLUA_NAME(new) static pointer<T> *create(const T &v) {
        pointer<T> *ret = new pointer<T>();
        ret->_len = 1;
        ret->_data = new T[1];
        ret->_data[0] = v;
        return ret;
    }
    
    OLUA_GETTER const T &value() {return *_data;}
    OLUA_GETTER size_t length() {return _len;}
    OLUA_EXCLUDE T *data() {return _data;}
    OLUA_EXCLUDE const char *name() {return typeid(T).name();}
private:
    T *_data = nullptr;
    size_t _len = 0;
};

typedef pointer<std::string> string;
typedef pointer<int8_t> int8_t;
typedef pointer<uint8_t> uint8_t;
typedef pointer<int16_t> int16_t;
typedef pointer<uint16_t> uint16_t;
typedef pointer<int32_t> int32_t;
typedef pointer<uint32_t> uint32_t;
typedef pointer<int64_t> int64_t;
typedef pointer<uint64_t> uint64_t;
typedef pointer<float> float_t;
typedef pointer<double> double_t;
typedef pointer<long double> long_double_t;
typedef pointer<size_t> size_t;
typedef pointer<ssize_t> ssize_t;
typedef pointer<time_t> time_t;
}

static inline int olua_is_pointer(lua_State *L, int idx, const char *cls)
{
    return olua_isa(L, idx, cls);
}

template <class T>
void olua_check_pointer(lua_State *L, int idx, T **value, const char *cls)
{
    olua::pointer<T> *obj = (olua::pointer<T> *)olua_checkobj(L, idx, cls);
    *value = obj->data();
}

template <class T>
int olua_push_pointer(lua_State *L, T *value, const char *cls)
{
    olua::pointer<T> *obj = new olua::pointer<T>(value);
    olua_pushobj<olua::pointer<T>>(L, obj, cls);
    olua_postnew(L, obj);
    return 1;
}

#endif
