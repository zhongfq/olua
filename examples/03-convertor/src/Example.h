#ifndef __EXAMPLES_CONVERTOR__
#define __EXAMPLES_CONVERTOR__

#include "Object.h"
#include "olua-custom.h"
#include "lua_conv.h"

#include <string>
#include <functional>

namespace example {

typedef std::string Identifier;

struct Point {
    int x;
    int y;
};

struct Color {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
};

class Node : public Object {
public:
    Node () {}

    void setPosition(const Point &value) { _position = value; }
    const Point &getPosition() const { return _position; }

    void setIdentifier(const Identifier &value) { _id = value; }
    const Identifier &getIdentifier() const { return _id; }

    void setColor(const Color &value) { _color = value; }
    const Color &getColor() const { return _color; }

    void setChildren(const vector<Node *> &value) { _children = value; }
    const vector<Node *> &getChildren() const { return _children; }

private:
    Point _position;
    Identifier _id;
    Color _color;
    vector<Node *> _children;
};

class NodeExtend {
public:
    static olua_return __index(lua_State *L)
    {
        if(!olua_isuserdata(L, 1)) {
            return 0;
        }
            
        if (olua_isstring(L, 2)) {
            auto self = olua_toobj<Node>(L, 1);
            auto children = self->getChildren();
            std::string name = olua_tostring(L, 2);
            for (auto child : children) {
                if (child->getIdentifier() == name) {
                    olua_pushobj<Node>(L, child);
                    olua_addref(L, 1, "children", -1, OLUA_FLAG_MULTIPLE);
                    return 1;
                }
            }
        }
        lua_settop(L, 2);
        olua_getvariable(L, 1);
        return 1;
    }
};

}

// example::Color
int olua_is_example_Color(lua_State *L, int idx);
int olua_push_example_Color(lua_State *L, const example::Color *value);
void olua_check_example_Color(lua_State *L, int idx, example::Color *value);

#endif