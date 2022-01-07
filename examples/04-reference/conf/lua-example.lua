module "example"

path "src"

headers [[
#include "Example.h"
#include "xlua.h"
]]

include "../common/lua-object.lua"

typedef "example::vector"

typeconf "example::Node"
    .attr('setComponent', {arg1 = '@addref(component ^)'})
    .attr('getComponent', {ret = '@addref(component ^)'})
    .attr('addChild', {arg1 = '@addref(children |)'})
    .attr('removeChild', {arg1 = '@delref(children |)'})
    .attr('removeChildByName', {ret = '@delref(children ~)'})
    .attr('getChildByName', {ret = '@addref(children |)'})
    .attr('removeAllChildren', {ret = '@delref(children *)'})
    .attr('removeSelf', {ret = '@delref(children | parent)'})
    .insert('removeSelf', {
        before = [[
            if (!self->getParent()) {
                return 0;
            }
            olua_push_cppobj<example::Node>(L, self->getParent());
            int parent = lua_gettop(L);
        ]]
    })


--[[
Node *getParent() const { return _parent; }

    void setComponent(Node *value) { _component = value; }
    Node *getComponent() const { return _component; }

    void addChild(Node *child);
    void removeChild(Node *child);
    void removeChildByName(const std::string &name);
    void removeSelf();
    Node *getChildByName(const std::string &name);
    size_t getNumChildren() const { return _children.size(); }
]]