#ifndef __EXAMPLES_OBJECT__
#define __EXAMPLES_OBJECT__

#include <assert.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <vector>
#include <algorithm>
#include <functional>

extern bool assert_script_compatible(const char *msg);

#define ASSERT(cond, msg) do {                              \
if (!(cond)) {                                              \
    if (!assert_script_compatible(msg) && strlen(msg))      \
      printf("assert failed: %s", msg);                     \
    assert((cond) && (msg));                                \
  }                                                         \
} while (0)

namespace example {

class Object {
public:
    Object();
    virtual ~Object();

    void retain();
    void release();

    Object *autorelease();
    unsigned int getReferenceCount() const;

protected:
    unsigned int _referenceCount;
};

template<class T>
class vector
{
public:
    using iterator = typename std::vector<T>::iterator;
    using const_iterator = typename std::vector<T>::const_iterator;
    using size_type = typename std::vector<T>::size_type;
    
    vector<T>()
    : _data()
    {
        static_assert(std::is_convertible<T, Object *>::value, "invalid Type for example::vector<T>!");
    }
    
    explicit vector<T>(size_type capacity)
    : _data()
    {
        static_assert(std::is_convertible<T, Object *>::value, "invalid Type for example::vector<T>!");
        reserve(capacity);
    }

    vector<T>(std::initializer_list<T> list)
    {
        for (auto& element : list)
        {
	        push_back(element);
        }
    }

    ~vector<T>()
    {
        clear();
    }

    vector<T>(const vector<T>& other)
    {
        static_assert(std::is_convertible<T, Object *>::value, "invalid Type for example::vector<T>!");
        _data = other._data;
        add_ref_for_all_objects();
    }
    
    vector<T>(vector<T>&& other)
    {
        static_assert(std::is_convertible<T, Object *>::value, "invalid Type for example::vector<T>!");
        _data = std::move(other._data);
    }
    
    vector<T>& operator=(const vector<T>& other)
    {
        if (this != &other) {
            clear();
            _data = other._data;
            add_ref_for_all_objects();
        }
        return *this;
    }
    
    vector<T>& operator=(vector<T>&& other)
    {
        if (this != &other) {
            clear();
            _data = std::move(other._data);
        }
        return *this;
    }

    iterator begin() { return _data.begin(); }
    const_iterator begin() const { return _data.begin(); }
    iterator end() { return _data.end(); }
    const_iterator end() const { return _data.end(); } 
    void reserve(size_type n) { _data.reserve(n); }
    size_type capacity() const { return _data.capacity(); }
    size_type size() const { return  _data.size(); }
    bool empty() const { return _data.empty(); }
    size_type max_size() const { return _data.max_size(); }
    
    size_type get_index(T object) const
    {
        auto iter = std::find(_data.begin(), _data.end(), object);
        if (iter != _data.end())
            return iter - _data.begin();

        return -1;
    }

    const_iterator find(T object) const { return std::find(_data.begin(), _data.end(), object); }
    iterator find(T object) { return std::find(_data.begin(), _data.end(), object); }
    
    T at(size_type index) const
    {
        ASSERT(index >= 0 && index < size(), "index out of range");
        return _data[index];
    }

    T front() const { return _data.front(); }
    T back() const { return _data.back(); }

    bool contains(T object) const
    {
        return std::find(_data.begin(), _data.end(), object) != _data.end();
    }

    bool equals(const vector<T> &other) const
    {
        size_type s = this->size();
        if (s != other.size()) {
            return false;
        }
        
        for (size_type i = 0; i < s; i++) {
            if (this->at(i) != other.at(i)) {
                return false;
            }
        }
        return true;
    }

    void push_back(T object)
    {
        ASSERT(object != nullptr, "the object should not be nullptr");
        _data.push_back(object);
        object->retain();
    }
    
    void push_back(const vector<T>& other)
    {
        for(const auto &obj : other) {
            _data.push_back(obj);
            obj->retain();
        }
    }

    void insert(size_type index, T object)
    {
        ASSERT(index >= 0 && index <= size(), "invalid index");
        ASSERT(object != nullptr, "the object should not be nullptr");
        _data.insert((std::begin(_data) + index), object);
        object->retain();
    }
    
    void pop_back()
    {
        ASSERT(!_data.empty(), "no objects added");
        auto last = _data.back();
        _data.pop_back();
        last->release();
    }
    
    void erase_object(T object, bool remove_all = false)
    {
        ASSERT(object != nullptr, "the object should not be nullptr");
        
        if (remove_all) {
            for (auto iter = _data.begin(); iter != _data.end();) {
                if ((*iter) == object) {
                    iter = _data.erase(iter);
                    object->release();
                } else {
                    ++iter;
                }
            }
        } else {
            auto iter = std::find(_data.begin(), _data.end(), object);
            if (iter != _data.end()) {
                _data.erase(iter);
                object->release();
            }
        }
    }

    iterator erase(iterator position)
    {
        ASSERT(position >= _data.begin() && position < _data.end(), "invalid position");
        (*position)->release();
        return _data.erase(position);
    }
    
    iterator erase(iterator first, iterator last)
    {
        for (auto iter = first; iter != last; ++iter) {
            (*iter)->release();
        }
        return _data.erase(first, last);
    }
    
    iterator erase(size_type index)
    {
        ASSERT(!_data.empty() && index >=0 && index < size(), "invalid index");
        auto it = std::next(begin(), index);
        (*it)->release();
        return _data.erase(it);
    }

    void clear()
    {
        for( auto& it : _data) {
            it->release();
        }
        _data.clear();
    }

    void swap(T object1, T object2)
    {
        size_type idx1 = get_index(object1);
        size_type idx2 = get_index(object2);
        ASSERT(idx1>=0 && idx2>=0, "invalid object index");
        std::swap(_data[idx1], _data[idx2]);
    }
    
    void swap(size_type index1, size_type index2)
    {
        ASSERT(index1 >=0 && index1 < size() && index2 >= 0 && index2 < size(), "invalid indices");
        std::swap(_data[index1], _data[index2]);
    }

    void replace(size_type index, T object)
    {
        ASSERT(index >= 0 && index < size(), "invalid index!");
        ASSERT(object != nullptr, "the object should not be nullptr");
        _data[index]->release();
        _data[index] = object;
        object->retain();
    }

    void reverse()
    {
        std::reverse(std::begin(_data), std::end(_data));
    }
    
    void shrink_to_fit()
    {
        _data.shrink_to_fit();
    }
    
protected:
    void add_ref_for_all_objects()
    {
        for(const auto &obj : _data) {
            obj->retain();
        }
    }
    
    std::vector<T> _data;
};

}

#endif