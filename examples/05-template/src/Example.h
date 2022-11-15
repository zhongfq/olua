#ifndef __EXAMPLE__
#define __EXAMPLE__

#include "Object.h"
#include "olua-custom.h"

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

class TestWildcardListener {
public:
    virtual void onClick() 
    {
        printf("onClick: %s\n", typeid(*this).name());
    }

    void hello() 
    {
    }
private:
    // int x;
};

template<class T> class Singleton
{
public:
    static T *create() {
        T *ret = new T();
        return ret;
    }
    
    inline explicit Singleton()
    {
    }

    virtual void printSingleton() {
        printf("printSingleton: %s\n", typeid(*this).name());
    }

    template<class N> void printN(N *n) {

    }
protected:
    int i = 0;
};

class ExportParent : public ::example::Object {
public:
    void printExportParent() {
        printf("printExportParent: %s\n", typeid(*this).name());
    }
    
    void setObject(::example::Object *obj) {
    }
};

class Hello : public ExportParent, public TestWildcardListener, public Singleton<Hello> {
public:
    Hello() {
        printf("new '%s': %p\n", typeid(*this).name(), this);
    };

    void say();

    const std::string &getName() const;
    void setName(const std::string &value);
    
    void setSingleton(Singleton<Hello> *sh)
    {
        sh->printSingleton();
    }
    
    void setBool(const std::vector<bool> &bools)
    {
    }
    
    std::vector<bool> getBool()
    {
        return std::vector<bool>();
    }
    
    Singleton<Hello> * getSingleton()
    {
        return this;
    }

private:
    std::string _name;
};

class GC {
public:
    olua_Return __gc(lua_State *L)
    {
        GC *self = olua_checkobj<GC>(L, 1);
        delete self;
        return 1;
    }
    virtual void gc() {
        
    }
};

class TestGC : public TestWildcardListener, public GC {
public:
    TestGC() {
        
    }
    
    virtual void testGC()
    {
        printf("hello test gc\n");
    }
};

}

#endif
