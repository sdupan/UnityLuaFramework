-- 定义为全局模块，整个lua程序的入口类
GameMain = {};

--设置游戏帧率
CS.UnityEngine.Application.targetFrameRate = 60

local function OnApplicationQuit()
    -- 模块注销
    if LogicUpdateManagerInst then
        LogicUpdateManagerInst:Dispose()
    end
    if UpdateManagerInst then
        UpdateManagerInst:Dispose()
    end
    if TimerManagerInst then
        TimerManagerInst:Dispose()
    end
    if GAME_EVENT_CENTER_DISPOSE then
        GAME_EVENT_CENTER_DISPOSE()
    end

	print("Game OnApplicationQuit ...lua")
end

local function StartGame()
	require("Updater.UpdateMain")
end

-- GameMain公共接口，其它的一律为私有接口，只能在本模块访问
GameMain.OnApplicationQuit = OnApplicationQuit

local gamePlatform = CS.UnityEngine.Application.platform
local RuntimePlatform = CS.UnityEngine.RuntimePlatform

--错误回调
function __G__TRACKBACK__(errorMessage)
    printInfo("----------------------------------------")
    printInfo("[LUA ERROR]: " .. tostring(errorMessage) .. "\n")
    printInfo(debug.traceback("", 2))
    printInfo("----------------------------------------")
    
    if not gamePlatform or gamePlatform == RuntimePlatform.OSXEditor or gamePlatform == RuntimePlatform.OSXPlayer
        or gamePlatform == RuntimePlatform.WindowsPlayer or gamePlatform == RuntimePlatform.WindowsEditor then
        -- Windows/Mac平台下直接暂停，以查看出错堆栈
        -- os.execute 'pause'
    end

    return errorMessage
end

xpcall(function()
    StartGame()
end, __G__TRACKBACK__)