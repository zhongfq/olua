local olua = require "olua"

local function check_func(cls, fn, refmap)
    if not fn.STATIC and refmap[fn.RET.TYPE.CPPCLS] then
        if not (fn.RET.ATTR.DELREF or fn.RET.ATTR.REF) then
            print('not specify ref: ' .. cls.CPPCLS .. ' => ' .. fn.FUNCDECL)
        end
    end
end

local function check_class(cls, refmap)
    for _, fns in ipairs(cls.FUNCS) do
        for _, fn in ipairs(fns) do
            check_func(cls, fn, refmap)
        end
    end
end

local function check_should_ref(cls, refmap, classmap)
    if cls then
        local NAME = cls.CPPCLS .. ' *'
        if refmap[NAME] == nil then
            if cls.SUPERCLS and check_should_ref(classmap[cls.SUPERCLS], refmap, classmap) then
                refmap[NAME] = true
                return true
            end
        elseif refmap[NAME] then
            return true
        end
    end
end

function olua.checkref(conf)
    local classmap = olua.getclass('*')
    local refmap = {}
    for _, v in ipairs(conf.REF) do
        refmap[v] = true
    end
    for _, cls in pairs(classmap) do
        check_should_ref(cls, refmap, classmap)
    end
    for _, cls in pairs(classmap) do
        check_class(cls, refmap)
    end
end

return olua