#ifndef __EXAMPLES_CONVERTOR__
#define __EXAMPLES_CONVERTOR__

#include "Object.h"
#include "olua-custom.h"
#include "lua_conv.h"

#include <string>
#include <functional>

namespace example {

class Node : public Object {
public:
    Node () {}

    const std::string &getName() const { return _name; }
    void setName(const std::string &value) { _name = value; }
 
    Node *getParent() const { return _parent; }

    void setComponent(Node *value) { _component = value; }
    Node *getComponent() const { return _component; }

    vector<Node *> &getChildren() {return _children;}

    void addChild(Node *child);
    void addChild(Node *child, const std::string &name);
    void removeChild(Node *child);
    void removeChildByName(const std::string &name);
    void removeAllChildren();
    void removeSelf();
    Node *getChildByName(const std::string &name);
    size_t getNumChildren() const { return _children.size(); }
private:
    Node *_component = nullptr;
    Node *_parent = nullptr;
    vector<Node *> _children;
    std::string _name;
};

}

#endif