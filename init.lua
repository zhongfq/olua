local scrpath = select(2, ...)
local osn = package.cpath:find("?.dll") and "windows" or
    ((io.popen("uname"):read("*l"):find("Darwin")) and "macos" or "linux")

local function isdir(path)
    if not string.find(path, "[/\\]$") then
        path = path .. "/"
    end
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok, err
end

local function mkdir(dir)
    if not isdir(dir) then
        if osn == "windows" then
            os.execute("mkdir " .. dir:gsub("/", "\\"))
        else
            os.execute("mkdir -p " .. dir)
        end
    end
end

-- working directory
OLUA_WORKDIR = nil
if osn == "windows" then
    OLUA_WORKDIR = io.popen("cd"):read("*l")
    OLUA_WORKDIR = OLUA_WORKDIR:gsub("\\", "/")
else
    OLUA_WORKDIR = io.popen("pwd"):read("*l")
end

-- home dir
---@type string?
OLUA_HOME = nil
if osn == "windows" then
    OLUA_HOME = os.getenv("USERPROFILE")
    if not OLUA_HOME then
        OLUA_HOME = os.getenv("TMP"):gsub("\\", "/")
        if OLUA_HOME:find("^C:/Users/") then
            OLUA_HOME = OLUA_HOME:match("^C:/Users/[^/]+")
        end
    end
    OLUA_HOME = OLUA_HOME .. "/.olua"
else
    OLUA_HOME = os.getenv("HOME") .. "/.olua"
end

-- version
OLUA_VERSION = "v1.3"
OLUA_HOME = OLUA_HOME .. "/" .. OLUA_VERSION

-- lua search path
package.path = scrpath:gsub("[^/.\\]+%.lua$", "?.lua;") .. package.path

-- lua c search path
local suffix = osn == "windows" and "dll" or "so"
local lua = "lua" .. string.match(_VERSION, "%d.%d"):gsub("%.", "")
local arch
if osn == "windows" then
    arch = os.getenv("PROCESSOR_ARCHITECTURE")
    if arch == "x86" then
        arch = "x86/"
    elseif arch == "AMD64" then
        arch = "x64/"
    else
        error("unsupported architecture: " .. arch)
    end
else
    arch = ""
end
local cpath = string.format("%s/%s/%s?.%s", OLUA_HOME, lua, arch, suffix)
package.cpath = cpath .. ";" .. package.cpath

print(string.format("pwd: %s", OLUA_WORKDIR))
print(string.format("olua home: %s", OLUA_HOME))
print(string.format("lua cpath: %s", cpath))

-- unzip lib and header
if not isdir(OLUA_HOME) or not isdir(OLUA_HOME .. "/" .. lua) or not isdir(OLUA_HOME .. "/include") then
    local dir = scrpath:gsub("[^/.\\]+%.lua$", "bin")
    mkdir(OLUA_HOME)

    local function unzip(path)
        local exe = osn == "windows" and ".exe" or ""
        local cmd = "%s/unzip-%s%s -f %s -o %s"
        cmd = cmd:format(dir, osn, exe, path, OLUA_HOME)
        if osn == "windows" then
            cmd = cmd:gsub("/", "\\")
        end
        os.execute(cmd)
    end

    local function wget(url, path)
        print(string.format("download: %s", url))
        local exe = osn == "windows" and ".exe" or ""
        local cmd = "%s/wget-%s%s -l %s -o %s"
        cmd = cmd:format(dir, osn, exe, "%s", path)
        if osn == "windows" then
            cmd = cmd:gsub("/", "\\")
        end
        cmd = cmd:format(url)
        os.execute(cmd)
    end

    local url = "https://github.com/zhongfq/olua/releases/download/" .. OLUA_VERSION
    local deps = { "include.zip", ("%s-%s.zip"):format(lua, osn) }
    for _, v in ipairs(deps) do
        wget(url .. "/" .. v, dir .. "/" .. v)
    end
    for _, v in ipairs(deps) do
        unzip(dir .. "/" .. v)
    end
end

require "script.olua"
require "script.parser"
require "script.basictype"
require "script.gen-class"
require "script.gen-func"
require "script.gen-callback"
require "script.idl"
require "script.autoconf"

local base64 = require "script.base64"
olua.base64_encode = base64.encode
olua.base64_decode = base64.decode
