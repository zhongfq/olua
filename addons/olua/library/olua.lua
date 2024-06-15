---@meta _

-------------------------------------------------------------------------------
-- Typedef
-------------------------------------------------------------------------------
---@class Typedef
Typedef = {}

---@param convfmt string
---@return Typedef
function Typedef.conv(convfmt) end

---@param luatype string
---@return Typedef
function Typedef.luatype(luatype) end

-- -------------------------------------------------------------------------------
-- -- Typeconf
-- -------------------------------------------------------------------------------
-- ---@class Typeconf
-- Typeconf = {}

-- ---@param maker function
-- function Typeconf.luaname(maker) end


-------------------------------------------------------------------------------
-- define module
-------------------------------------------------------------------------------
---define config module
---@param name string
function module(name) end

---insert codes into luaopen function
---@param codeblock string
function luaopen(codeblock) end

---@param dir string
function metapath(dir) end

---@param path string
function path(path) end

---@param maker fun(cppcls:string):string
function luacls(maker) end

---define headers for generated file
---@param headers string
function headers(headers) end

---@param cppcls string
---@return Typedef
function typedef(cppcls) end

-- ---@param cppcls string
-- ---@return Typeconf
-- function typeconf(cppcls) end
