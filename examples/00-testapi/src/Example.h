#ifndef __EXAMPLE__
#define __EXAMPLE__

#include "Object.h"
#include "olua-custom.h"

#include <string>
#include <vector>
#include <memory>

typedef void GLvoid;
typedef char GLchar;

namespace example {

enum class Type {
    VALUE, POINTEE
};

class Point {
public:
    float x = 0;
    float y = 0;

    Point() {}
    
    Point(const Point &p):x(p.x), y(p.y) {
        
    }

    Point(float x, float y):x(x), y(y) {}

    ~Point() {
        printf("~Point\n");
    }

    float length() {
        return (float)sqrt(x * x + y * y);
    }
};

class ExportParent : public Object {
public:
    void printExportParent() {
        printf("printExportParent: %s\n", typeid(*this).name());
    }
};

class Hello;

typedef std::function<void (Hello *)> ClickCallback;
typedef std::function<std::string (Hello *, int)> NotifyCallback;
typedef ClickCallback TouchCallback;

typedef Hello HelloAlias;
typedef Point Vec2;

class Hello : public ExportParent {
public:
    Hello() {
        printf("Hello() '%s': %p\n", typeid(*this).name(), this);
        _ptr = malloc(sizeof(void *));
        _p.x = 34;
        _p.y = 50;
    };

    virtual ~Hello() {
        free(_ptr);
        printf("~Hello() '%s': %p\n", typeid(*this).name(), this);
    }

    const std::string &getName() const {return _name;}
    void setName(const std::string &value) {_name = value;}

    const char *getCName() const {return _name.c_str();}
    void setCName(const char *value) {_name = value;}

    void setType(Type t) {}
    Type getType() {return Type::VALUE;}

    void setGLvoid(GLvoid *) {}
    GLvoid *getGLvoid() { return NULL;}

    void setGLchar(GLchar *) {}
    GLchar *getGLchar() { return NULL;}

    void setCGLchar(const GLchar *) {}
    const GLchar *getCGLchar() { return NULL;}

    void *getPtr() { return _ptr;}
    void setPtr(void *p) { _ptr = p;}

    void setID(int id) {_id = id;}
    int getID() {return _id;}
    
    void getIntRef(int &ref) {ref = 120;}
    void getStringRef(std::string &ref) {ref = "120";}
    
    Point convertPoint(const Point &p) {return p;}
    
    HelloAlias *getAliasHello() {return this;}
    OLUA_UNPACK Vec2 getVec2() {return Vec2();}

    void setCallback(const std::function<int (Hello *)> &callback) {}
    void setNotify(const NotifyCallback &callback) {}
    void setClick(const ClickCallback &callback) {}
    void setTouch(const TouchCallback &callback) {}

    std::vector<Point> getPoints() { return std::vector<Point>(); }
    void setPoints(const std::vector<Point> &v) {};

    std::vector<Point*> getPointers() { return std::vector<Point*>(); }
    void setPointers(const std::vector<Point *> &v) {};

    std::vector<GLvoid *> getVoids() { return std::vector<GLvoid *>(); }
    void setVoids(const std::vector<GLvoid *> &v) {};

    std::vector<const char *> getCStrs() {return std::vector<const char *>();}
    void setCStrs(const std::vector<const char *> &v) {};

    std::vector<int64_t> getInts() {return std::vector<int64_t>();}
    void setInts(const std::vector<int64_t> &v) {};

    std::vector<short *> getIntPtrs() {return std::vector<short *>();}
    void setIntPtrs(const std::vector<short *> &v) {};

    void run(Hello *obj, ...) {}

private:
    std::string _name;
    int _id = 0;
    void *_ptr = nullptr;
    Point _p;
};

}

#endif
