#ifndef __EXAMPLE__
#define __EXAMPLE__

#include "Object.h"
#include "olua-custom.h"

#include <string>
#include <vector>
#include <deque>
#include <memory>

typedef void GLvoid;
typedef char GLchar;
typedef float GLfloat;

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
    Point(const Point &p):x(p.x), y(p.y) {}
    Point(float x, float y):x(x), y(y) {}

    float length() {return (float)sqrt(x * x + y * y);}
};

class Const {
public:
    static const bool BOOL;
    static const char CHAR;
    static const short SHORT;
    static const int INT;
    static const long LONG;
    static const long long LLONG;
    static const unsigned char UCHAR;
    static const unsigned short USHORT;
    static const unsigned int UINT;
    static const unsigned long ULONG;
    static const unsigned long long ULLONG;
    static const float FLOAT;
    static const double DOUBLE;
    static const long double LDOUBLE;
    static const std::string STRING;
    static const Point POINT;
    static const Type ENUM;
    static const char *CONST_CHAR;
};

class NoGC {
public:
    // flags in gc: 0b0000000000000010
    static NoGC *create() { return new NoGC(0, nullptr); }

    NoGC(int i, const std::function<int(NoGC *)> &callbak) {}
};

class ExportParent : public Object {
public:
    void printExportParent()
    {
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
typedef olua::pointer<std::vector<Point>> VectorPoint;
typedef olua::pointer<std::vector<std::string>> VectorString;
typedef olua::pointer<Point> PointArray;

template<class T> class Singleton {
public:
    static T *create()
    {
        T *ret = new T();
        return ret;
    }
    
    inline explicit Singleton() {}

    virtual void printSingleton()
    {
        printf("printSingleton: %s\n", typeid(*this).name());
    }

    template<class N> void printN(N *n) {}
protected:
    int i = 0;
};

class Hello : public ExportParent, public Singleton<Hello> {
public:
    Hello()
    {
        _ptr = malloc(sizeof(void *));
        _p.x = 34;
        _p.y = 50;
    };

    virtual ~Hello()
    {
        free(_ptr);
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
    
    void setGLfloat(GLfloat *) {}

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

    void setCallback(const std::function<int (Hello *, Point *)> &callback) { _callback = callback; }
    void doCallback() {
        if (_callback) {
            Point p(10, 10);
            _callback(this, &p);
        }
    }
    static int load(const std::string &path, const NotifyCallback &callback) { return 0; }
    void setNotifyCallback(const NotifyCallback &callback) {}
    void setClickCallback(const ClickCallback &callback) {callback(this);}
    void setClickCallback(const NotifyCallback &callback) {callback(this, 2);}
    void setTouchCallback(const TouchCallback &callback) {}
    void setDragCallback(const DragCallback &callback) {}

    std::vector<Point> getPoints() { return std::vector<Point>(); }
    void setPoints(const std::vector<Point> &v) {};

    std::vector<Point *> getPointers() { return std::vector<Point *>(); }
    void setPointers(const std::vector<Point *> &v) {};

    std::vector<GLvoid *> getVoids() { return std::vector<GLvoid *>(); }
    void setVoids(const std::vector<GLvoid *> &v) {};

    std::vector<const char *> getCStrs() {return std::vector<const char *>();}
    void setCStrs(const std::vector<const char *> &v) {};

    std::vector<int64_t> getInts() {return std::vector<int64_t>();}
    void setInts(const std::vector<int64_t> &v) {};

    std::vector<short *> getIntPtrs() {return std::vector<short *>();}
    void setIntPtrs(const std::vector<short *> &v) {};
    
    void checkString(std::vector<std::string> *) {}
    
    void checkVectorInt(std::vector<int> &v)
    {
        v.push_back(1);
        v.push_back(2);
    }
    
    void checkVectorPoint(std::vector<Point> &v)
    {
        v.push_back(Point(10, 10));
        v.push_back(Point(10, 100));
    }

    void run(Hello *obj, ...) {}

    void read(OLUA_TYPE(olua_char_t *) char *result, size_t *len)
    {
        const char *str = "hello read!";
        strcpy(result, str);
        *len = strlen(str);
    }
    

    void testPointerTypes(
        OLUA_TYPE(olua_char_t *) char *,
        OLUA_TYPE(olua_uchar_t *) unsigned char *,
        short *, short int *, std::vector<short> &,
        unsigned short *, unsigned short int *, std::vector<unsigned short> &,
        signed *, int *, std::vector<int> &,
        unsigned *, unsigned int *, std::vector<unsigned int> &,
        long *, long int *, std::vector<long> &,
        unsigned long *, unsigned long int *, std::vector<unsigned long> &,
        long long *, long long int *, std::vector<long long> &,
        unsigned long long *, unsigned long long int *, std::vector<unsigned long long> &,
        float *, std::vector<float> &,
        double *, std::vector<double> &,
        long double *, std::vector<long double> &) {}
    
    void testPointerTypes(const std::function<void (
        OLUA_TYPE(olua_char_t *) char *,
        OLUA_TYPE(olua_uchar_t *) unsigned char *,
        short *, short int *, std::vector<short> &,
        unsigned short *, unsigned short int *, std::vector<unsigned short> &,
        signed *, int *, std::vector<int> &,
        unsigned *, unsigned int *, std::vector<unsigned int> &,
        long *, long int *, std::vector<long> &,
        unsigned long *, unsigned long int *, std::vector<unsigned long> &,
        long long *, long long int *, std::vector<long long> &,
        unsigned long long *, unsigned long long int *, std::vector<unsigned long long> &,
        float *, std::vector<float> &,
        double *, std::vector<double> &,
        long double *, std::vector<long double> &)> &) {}
    
    int *getIntPtr() {return nullptr;}
    
    std::vector<int> *getVectorIntPtr()
    {
        auto v = new std::vector<int>();
        v->push_back(100);
        v->push_back(101);
        return v;
    }

    std::deque<Hello *> getDeque() {return _deque;}
    void setDeque(const std::deque<Hello *> &deque) {_deque = deque;}

private:
    std::function<int (Hello *, Point *)> _callback;
    std::string _name;
    int _id = 0;
    void *_ptr = nullptr;
    Point _p;
    Type _type = Type::POINTER;
    std::deque<Hello *> _deque;
};

class SharedHello : public std::enable_shared_from_this<SharedHello> {
public:

    OLUA_NAME(new) static std::shared_ptr<SharedHello> create()
    {
        auto obj = new SharedHello();
        obj->_name = "shared";
        return std::shared_ptr<SharedHello>(obj);
    }

    ~SharedHello() {
        printf("del SharedHello\n");
    };

    void say() {}

    const std::string &getName() const {return _name;}
    
    std::shared_ptr<SharedHello> getThis()
    {
        return shared_from_this();
    }
    
    std::weak_ptr<SharedHello> getWeakPtr() {
        return std::weak_ptr<SharedHello>(shared_from_this());
    }
    
    void setThis(const std::shared_ptr<SharedHello> &sp)
    {
        printf("set this: %p %p\n", this, sp.get());
    }
private:
    std::string _name;
};

}

#endif
