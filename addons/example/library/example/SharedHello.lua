---AUTO GENERATED, DO NOT MODIFY!
---@meta example.SharedHello

---
---@class example.SharedHello 
---@field name string 
---@field this example.SharedHello 
---@field weakPtr example.SharedHello 
local SharedHello = {}

---@return any
function SharedHello:__gc() end

---@return string
function SharedHello:getName() end

---@return example.SharedHello
function SharedHello:getThis() end

---@return example.SharedHello
function SharedHello:getWeakPtr() end

---@return example.SharedHello
function SharedHello.new() end

function SharedHello:say() end

---@param sp example.SharedHello
function SharedHello:setThis(sp) end

---@return example.SharedHello
function SharedHello:shared_from_this() end

return SharedHello