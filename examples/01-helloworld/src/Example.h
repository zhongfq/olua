#ifndef __EXAMPLE__
#define __EXAMPLE__

#include "Object.h"

#include <string>
#include <vector>

using namespace std;

namespace example {

enum class TestWildcardClickEvent {
    H1, H2, H3
};

enum class TestWildcardTouchEvent {
    T1, T2, T3
};

template<class T> class Singleton
{
public:
    static T *create() {
        T *ret = new T();
        return ret;
    }

    void printSingleton() {
        printf("printSingleton: %s\n", typeid(*this).name());
    }

    template<class N> void printN(N *n) {

    }
};

class ExportParent : public Object {
public:
    void printExportParent() {
        printf("printExportParent: %s\n", typeid(*this).name());
    }
};

class Hello : public ExportParent, public Singleton<Hello> {
public:
    Hello() {
        printf("new '%s': %p\n", typeid(*this).name(), this);
    };

    void say();

    const std::string &getName() const;
    void setName(const std::string &value);

private:
    std::string _name;
};

}

#endif