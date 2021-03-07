-----------------------------------------------------------------------------------------------
-- @description  管理游戏里用到的文字描述
--------------------------------------------------------------------------------------------
local LanguageManager = {}

local tabText = require("Config.Other.TipsText")

-- 根据id获取文字描述，没有对应描述返回 "*_*"
-- LanguageManager:getTextByID
---@return string
function LanguageManager:GetTextByID(nID, ...)
    local format = tabText[tostring(nID)] or "%s"
    if ... then
        return string.format(format, ...)
    end
    return format
end

return LanguageManager