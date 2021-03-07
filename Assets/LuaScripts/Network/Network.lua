--------------------------------
-- @module Network

--[[--

网络服务

]]

local Network = {}

local internetType = CS.UnityEngine.Application.internetReachability
local NetworkReachability = CS.UnityEngine.NetworkReachability
local NetworkType = {
    [NetworkReachability.NotReachable] = 0,
    [NetworkReachability.ReachableViaLocalAreaNetwork] = 1,
    [NetworkReachability.ReachableViaCarrierDataNetwork] = 2,
}

-- start --

--------------------------------
-- 检查地 WIFI 网络是否可用
-- @function [parent=#Network] isLocalWiFiAvailable
-- @return boolean#boolean ret (return value: bool)  网络是否可用

--[[--

检查地 WIFI 网络是否可用

提示： WIFI 网络可用不代表可以访问互联网。

]]
-- end --

function Network.IsLocalWiFiAvailable()
    return internetType == NetworkReachability.ReachableViaLocalAreaNetwork
end

-- start --

--------------------------------
-- 检查互联网连接是否可用
-- @function [parent=#Network] isInternetConnectionAvailable
-- @return boolean#boolean ret (return value: bool)  网络是否可用

--[[--

检查互联网连接是否可用

通常，这里接口返回 3G 网络的状态，具体情况与设备和操作系统有关。 

]]
-- end --

function Network.IsInternetConnectionAvailable()
    return internetType ~= NetworkReachability.NotReachable
end

-- start --

--------------------------------
-- 检查是否可以解析指定的主机名
-- @function [parent=#Network] isHostNameReachable
-- @param string hostname 主机名
-- @return boolean#boolean ret (return value: bool)  主机名是否可以解析

--[[--

检查是否可以解析指定的主机名

~~~ lua

if Network.isHostNameReachable("www.google.com") then
    -- 域名可以解析
end

~~~

注意： 该接口会阻塞程序，因此在调用该接口时应该提醒用户应用程序在一段时间内会失去响应。 

]]
-- end --

function Network.IsHostNameReachable(hostname)
    if type(hostname) ~= "string" then
        printError("Network.isHostNameReachable() - invalid hostname %s", tostring(hostname))
        return false
    end
    return true
end

-- start --

--------------------------------
-- 返回互联网连接状态值
-- @function [parent=#Network] getInternetConnectionStatus
-- @return string#string ret (return value: string)  互联网连接状态值

--[[--

返回互联网连接状态值

状态值有三种：

-   NotReachable: 无法访问互联网      0
-   ReachableViaLocalAreaNetwork: 通过 WIFI     1
-   ReachableViaCarrierDataNetwork: 通过 2/3/4G 网络   2

]]
-- end --

function Network.GetInternetConnectionStatus()
    return NetworkType[internetType] or 0
end

local function parseTrueFalse(t)
    t = string.lower(tostring(t))
    if t == "yes" or t == "true" then return true end
    return false
end

-- start --

--------------------------------
-- 转换cookie为一个字串
-- @function [parent=#Network] makeCookieString
-- @param tabel cookie
-- @return string#string  结果

-- end --

function Network.MakeCookieString(cookie)
    local arr = {}
    for name, value in pairs(cookie) do
        if type(value) == "table" then
            value = tostring(value.value)
        else
            value = tostring(value)
        end

        arr[#arr + 1] = tostring(name) .. "=" .. string.urlencode(value)
    end

    return table.concat(arr, "; ")
end

-- start --

--------------------------------
-- 转换字串为一个cookie表
-- @function [parent=#Network] parseCookie
-- @param string cookieString
-- @return table#table  结果

-- end --

function Network.ParseCookie(cookieString)
    local cookie = {}
    local arr = string.split(cookieString, "\n")
    for _, item in ipairs(arr) do
        item = string.trim(item)
        if item ~= "" then
            local parts = string.split(item, "\t")
            -- ".amazon.com" represents the domain name of the Web server that created the cookie and will be able to read the cookie in the future
            -- TRUE indicates that all machines within the given domain can access the cookie
            -- "/" denotes the path within the domain for which the variable is valid
            -- "FALSE" indicates that the connection is not secure
            -- "2082787601" represents the expiration date in UNIX time (number of seconds since January 1, 1970 00:00:00 GMT)
            -- "ubid-main" is the name of the cookie
            -- "002-2904428-3375661" is the value of the cookie

            local c = {
                domain = parts[1],
                access = parseTrueFalse(parts[2]),
                path = parts[3],
                secure = parseTrueFalse(parts[4]),
                expire = checkint(parts[5]),
                name = parts[6],
                value = string.urldecode(parts[7]),
            }

            cookie[c.name] = c
        end
    end

    return cookie
end

return Network
