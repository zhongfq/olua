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

struct ExcludeType {
    bool flag;
};

enum class Type {
    LVALUE, RVALUE, POINTER
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
typedef std::function<void (Hello *)> ClickCallback2;
typedef std::function<std::string (Hello *, int)> NotifyCallback;
typedef ClickCallback TouchCallback;
typedef TouchCallback DragCallback;

typedef Hello HelloAlias;
typedef Point Vec2;

typedef olua::pointer<std::vector<int>> VectorInt;

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

    void setType(Type t) {_type = t;}
    Type getType() {return _type;}

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
    
    ExcludeType *getExcludeType() {return nullptr;}
    void setExcludeType(struct ExcludeType &v) {}
    void setExcludeTypes(const std::vector<ExcludeType> &v) {}

    void setCallback(const std::function<int (Hello *)> &callback) {}
    void setNotifyCallback(const NotifyCallback &callback) {}
    void setClickCallback(const ClickCallback &callback) {callback(this);}
    void setClickCallback(const NotifyCallback &callback) {callback(this, 2);}
    void setTouchCallback(const TouchCallback &callback) {}
    void setDragCallback(const DragCallback &callback) {}

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
    
    void checkVectorInt(std::vector<int> &v) {
        v.push_back(1);
        v.push_back(2);
    }

    void run(Hello *obj, ...) {}

    void read(OLUA_TYPE(olua_char_t *) char *result, size_t *len) {
        const char *str = "hello read!";
        strcpy(result, str);
        *len = strlen(str);
    }
    

    void testPointerTypes(
        OLUA_TYPE(olua_char_t *) char *,
        OLUA_TYPE(olua_uchar_t *) unsigned char *,
        short *, short int *,
        unsigned short *, unsigned short int *,
        signed *, int *,
        unsigned *, unsigned int *,
        long *, long int *,
        unsigned long *, unsigned long int *,
        long long *, long long int *,
        unsigned long long *, unsigned long long int *,
        float *,
        double *,
        long double *) {}

private:
    std::string _name;
    int _id = 0;
    void *_ptr = nullptr;
    Point _p;
    Type _type = Type::POINTER;
};

}

#endif
