--------------------------------
-- @module json

--[[--

JSON 编码与解码

]]
local json = {}

local rapidjson
local function safeLoad()
    rapidjson = require("rapidjson")
end

if not pcall(safeLoad) then 
    rapidjson = nil
end

-- start --

--------------------------------
-- 将表格数据编码为 JSON 字符串
-- @function [parent=#json] encode
-- @param table 表格对象
-- @return string#string ret (return value: string)  json字符串

--[[--

将表格数据编码为 JSON 字符串

~~~ lua

local str = json.encode({a=1,b="ss",c={c1=1,c2=2},d={10,11},100})
echo(str) -- {"a":1,"b":"ss","c":{"c1":1,"c2":2},"d":[10,11],"1":100}
local str = json.encode({1,2,"3",{10,11}})
echo(str) -- [ 1,2,"3",[10,11] ]

~~~

注意: table作为字典使用时，整型键值将被转换为字符串键值

~~~ lua

local str = json.encode({a=1,[5]=3})
echo(str) -- {"a":1,"5":3}

~~~

注意: table所有键值为整型时，会当作数组看待，空位将转化为null

~~~ lua

local str = json.encode({[3]=2,[5]=3})
echo(str) -- [null,null,2,null,3]

~~~

]]
-- end --

function json.encode(var)
    local status, result = pcall(rapidjson.encode, var)
    if status then return result end
    if DEBUG > 1 then
        printError("json.encode() - encoding failed: %s", tostring(result))
    end
end

-- start --

--------------------------------
-- 将 JSON 字符串解码为表格对象
-- @function [parent=#json] decode
-- @param string json字符串
-- @return table#table ret (return value: table)  表格对象

--[[--

将 JSON 字符串解码为表格对象

~~~ lua

local json = require("Common.Tools.json")
local tb = json.decode('{"a":1,"b":"ss","c":{"c1":1,"c2":2},"d":[10,11],"1":100}')
dump(tb) --[ [
- "<var>" = {
-     "1" = 100
-     "a" = 1
-     "b" = "ss"
-     "c" = {
-         "c1" = 1
-         "c2" = 2
-     }
-     "d" = {
-         1 = 10
-         2 = 11
-     }
- }
] ]
local tb = json.decode('[1,2,"3",[10,11] ]')
dump(tb) --[ [
- "<var>" = {
-     1 = 1
-     2 = 2
-     3 = "3"
-     4 = {
-         1 = 10
-         2 = 11
-     }
- }
] ]

~~~

]]
-- end --

function json.decode(text)
    local status, result = pcall(rapidjson.decode, text)
    if status then return result end
    -- if DEBUG > 1 then
        printError("json.decode() - decoding failed: %s", tostring(result))
    -- end
end

if rapidjson then
    json.null = rapidjson.null
else
    json = nil
end

return json
