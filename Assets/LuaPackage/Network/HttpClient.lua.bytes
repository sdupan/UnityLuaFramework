local HttpClient = {}

function HttpClient.request(url, post, fnSuc, fnFail, method, append)
    method = method or "GET"
    local wwwFrom = nil
    if type(post) == "table" then
        if method == "GET" then
            local reqParamsTab = {}
            for key, value in pairs(post) do
                table.insert(reqParamsTab, string.format("%s=%s",tostring(key), string.urlencode(tostring(value))))
            end
                    
            local reqParamStr = table.concat(reqParamsTab, "&")
            if string.sub(url, -1) == "?" then
                url = url..reqParamStr
            else
                url = url.."?"..reqParamStr
            end
        elseif method == "POST" then
            wwwFrom = CS.UnityEngine.WWWForm()
            for k, v in pairs(post) do
                if type(k) =="string" and type(v) =="string" then
                    wwwFrom:AddField(k, v)
                end
            end
        end
    end

    if append then
        url = HttpClient.appendInfoWithUrl(url)  
    end

    local request = nil
    if method == "GET" then
        request = CS.UnityEngine.Networking.UnityWebRequest.Get(url)
    elseif method == "POST" then
        if not wwwFrom then
            wwwFrom = CS.UnityEngine.WWWForm()
        end
        request = CS.UnityEngine.Networking.UnityWebRequest.Post(url, wwwFrom)
    end

    if not request then
        print("[HttpClient] does not support request type -->", method)
        if not fnFail then
            fnFail()
        end
        return
    end

    local sendOp = request:SendWebRequest()

    local function httpCallback()
        if request.isHttpError or request.isNetworkError or request.responseCode ~= 200 then
            fnFail(request)
        else
            fnSuc(request)
        end
    end

    sendOp:completed("+", httpCallback)
end

function HttpClient.appendInfoWithUrl(url)
    -- if url == nil then return nil end
    -- local tData = {}
    -- table.insert(tData, string.format("systemName=%s", device.platform))
    -- local chanel_Id_name = GAME_AREA_CHANEL_ID
    -- if device.platform == "ios" then
    --   chanel_Id_name = nil==string.find(chanel_Id_name,"ios") and chanel_Id_name.."ios" or chanel_Id_name
    -- end
    -- local Versions = require("fix.Versions")
    -- table.insert(tData, string.format("channelSimpleName=%s", string.urlencode(chanel_Id_name))) 
    -- table.insert(tData, string.format("versionName=%s", string.urlencode(Versions.getCurrentVersionName())))
    -- table.insert(tData, string.format("versionCode=%s", string.urlencode(Versions.getCurrentVersionCode())))
    -- table.insert(tData, string.format("imei=%s", string.urlencode(FN_DeviceInfo.deviceImei or "1")))
    -- table.insert(tData, string.format("systemVersion=%s", string.urlencode(FN_DeviceInfo.deviceSystemVersion or "1")))
    -- table.insert(tData, string.format("mobileModel=%s", string.urlencode(FN_DeviceInfo.deviceName or "1")))
    -- -- table.insert(tData, string.format("networkType=%s", FN_DeviceInfo.deviceNetworkType or "1"))
    -- table.insert(tData, string.format("mac=%s", string.urlencode(FN_DeviceInfo.deviceMacAddress or "1")))
    -- table.insert(tData, string.format("ip=%s", string.urlencode(FN_DeviceInfo.deviceLocalIp or "1")))
    -- table.insert(tData, string.format("dt=%s", string.urlencode(os.time())))
    -- local deviceInfo = table.concat(tData, "&")
    
    -- if string.find(url, "?") then
    --     return url.."&"..deviceInfo
    -- else
    --     return url.."?"..deviceInfo
    -- end
    return url
end

function HttpClient.requestData(url, params, fnSuc, fnFail, method, append)
    local function _succCb(request)
        print("requestData--->>", request.downloadHandler.text)
        local rspData = json.decode(request.downloadHandler.text)
        if fnSuc then
            fnSuc(request, rspData)
        end
    end
    local function _failCb(request)
        if fnFail then
            fnFail(request)
        end
    end
    HttpClient.request(url, params, _succCb, _failCb, method, append)
end

function HttpClient.requestFile(url, filePath, fnSuc, fnFail)
    local function _succCb(request)
        GameUtility.SafeWriteAllText(filePath, request.downloadHandler.text)
        if fnSuc then
            fnSuc(request)
        end
    end
    local function _failCb(request)
        if fnFail then
            fnFail(request)
        end
    end
    HttpClient.request(url, nil, _succCb, _failCb)
end

return HttpClient