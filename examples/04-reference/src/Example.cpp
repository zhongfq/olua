#include "Example.h"

using namespace example;

void Node::addChild(Node *child)
{
    child->_parent = this;
    _children.push_back(child);
}

void Node::addChild(Node *child, const std::string &name)
{
    child->_name = name;
    addChild(child);
}

void Node::removeChild(Node *child)
{
    auto index = _children.get_index(child);
    if (index >= 0) {
        child->_parent = nullptr;
        _children.erase(index);
    }
}

void Node::removeChildByName(const std::string &name)
{
    for (int i = 0; i < _children.size(); i++) {
        auto child = _children.at(i);
        if (child->_name == name) {
            child->_parent = nullptr;
            _children.erase(i);
            break;
        }
    }
}

void Node::removeAllChildren()
{
    for (auto child : _children) {
        child->_parent = nullptr;
    }
    _children.clear();
}

void Node::removeSelf()
{
    if (_parent) {
        _parent->removeChild(this);
    }
}

Node *Node::getChildByName(const std::string &name)
{
    for (int i = 0; i < _children.size(); i++) {
        auto child = _children.at(i);
        if (child->_name == name) {
            return child;
        }
    }
    return nullptr;
}