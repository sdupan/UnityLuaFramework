require "FairyGui.FairyGUI"

local GAME_LOCAL_MODE = false

local LuaManager = CS.IdleGame.LuaManager.Instance
local cs_coroutine = require("Common.CoroutineUtil")
local yield_return = cs_coroutine.yield_return
local json = require("Common.Tools.json")

local _loadingBar = nil
local _updateView = nil
local _updateTipsView = nil
local _updateOKBtn = nil
local _updateCancelBtn = nil
local _splashView = nil
local all_proto_files = {}

--加载协议文件
local function _preloadProtos()
    CS.IdleGame.AddressableManager.LoadProtos(function(name, textAsset, count, maxCount)
        all_proto_files[name] = textAsset
        if count >= maxCount then
            if _updateView then
                GRoot.inst:RemoveChild(_updateView)
            end
        
            require("GameEnvInit").StartGame(all_proto_files)
        end
    end)
end

--预加载结束
local function _preloadGameResEnd()
    --加载公共界面元素
    CS.IdleGame.UIManager.AddPackage("Base_fui", "Base", function(name, result)
        CS.IdleGame.UIManager.RemovePackage("Update_fui")
        _preloadProtos()
    end)
end

local function _removeUpdateTipsView()
    _updateOKBtn.onClick:Clear()
    _updateCancelBtn.onClick:Clear()
    GRoot.inst:RemoveChild(_updateTipsView)
end

--预加载游戏脚本及资源
local function _preloadGameRes()
    _removeUpdateTipsView()

    --加载所有脚本
    CS.IdleGame.AddressableManager.LoadLuaScripts(function(count, maxCount)
        _loadingBar.value = math.floor(count*100/maxCount)
        if count >= maxCount then
            _preloadGameResEnd()
        end
    end)
end

local function _onUpdateFinished()
    _removeUpdateTipsView()
    GRoot.inst:RemoveChild(_updateView)
    CS.IdleGame.UIManager.RemovePackage("Update_fui")
    LuaManager:Restart()
end

--更新检查，这里简单模拟更新流程
local function _checkGameUpdate()
    local co = coroutine.create(function()
        local needUpdate = false
        if not GAME_LOCAL_MODE then
            local url = "http://www.fish-money.com/game/version.json"
            local request = CS.UnityEngine.Networking.UnityWebRequest.Get(url)
            yield_return(request:SendWebRequest())
            if request.isHttpError or request.isNetworkError then
                print("--_checkGameUpdate---->>Failed ", request.isHttpError, request.isNetworkError)
                _preloadGameRes()
                return
            end

            local retText = request.downloadHandler.text
            local result = json.decode(retText)
            if result then
                print("--Unity  WebRequest----->>>", retText, result.version_code, result.version_name)
            else
                print("--Unity  WebRequest----->>>failed")
            end

            needUpdate = result and result.version_code > 10000 or false
        end

        if needUpdate then
            --弹出提示
            _updateTipsView = UIPackage.CreateObject("Update", "Tips")
            GRoot.inst:AddChild(_updateTipsView)

            _updateOKBtn = _updateTipsView:GetChild("ok")
            _updateOKBtn.onClick:Add(_onUpdateFinished)

            _updateCancelBtn = _updateTipsView:GetChild("cancel")
            _updateCancelBtn.onClick:Add(_preloadGameRes)
        else
            _preloadGameRes()
        end
    end)
    coroutine.resume(co)
end

--闪屏结束，显示更新界面
local function _splashEnd(name, result)
    GRoot.inst:RemoveChild(_splashView)
    _updateView = UIPackage.CreateObject("Update", "Loading")
    GRoot.inst:AddChild(_updateView)

    _loadingBar = _updateView:GetChild("bar")

    _checkGameUpdate()
end

--界面加载结束，显示闪屏
local function _loadPackageEnd(name, result)
    _splashView = UIPackage.CreateObject("Update", "Splash")
    GRoot.inst:AddChild(_splashView)
    _splashView:GetTransition("t0"):Play(_splashEnd)
end

--加载Loading页面
CS.IdleGame.UIManager.AddPackage("Update_fui", "Update", _loadPackageEnd)