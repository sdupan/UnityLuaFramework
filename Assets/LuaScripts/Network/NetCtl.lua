local M = class("NetCtl")

local CState         = require("Network.ConnectState")

local nWaitTimer     = 3 --数据延时超过3S时，显示loading界面
local nLoadTimer     = 20--当玩家在loading下20秒内没有接受到数据时，作为网络断线处理
local ReconnectTimer = 12--*重连时每12秒尝试一次重连，最多重连5次
local nLoadCount     = 5 --最多重连5次
local tabQueue       = { }
local isStop         = false
local loadLayer      = nil
local updateTimer     = nil

--更新时间

local function LogoutAccount()
    M.Clear()
    -- CTL_ROUTE(GAME_CONST.moduleName.login, "LogoutAccount", nil)
end

local function OnUpdate()
    for i, v in pairs(tabQueue) do
        local nTimer = os.time() - v.time
        printInfo("key = %d messageName = %s nTimer = %d", i, tostring(v.messageName), nTimer)
        if nTimer >= nWaitTimer and nTimer < nLoadTimer then
            --出现load界面
            M.ShowHttpLoad(LanguageManager:GetTextByID(10001))
        else
            --开始做断线重连
            if nTimer >= nLoadTimer then
                --有一个重连数据就够了
                for Idx, data in pairs(tabQueue) do
                    if Idx ~= i then
                        tabQueue[Idx] = nil
                    end
                end
                if 0 == v.reconnectTimer then
                    v.reconnectTimer = os.time()
                    v.loadCount      = 0
                end
                local nReconnectTimer = os.time() - v.reconnectTimer
                if nReconnectTimer % ReconnectTimer == 0 then
                    --如果是正在连接就不管了
                    if v.loadCount >= 0 and (SocketClient.GetState() == CState.CONNECT_STATE_CONNECTED or SocketClient.GetState() == CState.CONNECT_STATE_RECONNECT) then
                        SocketClient.ReConnect()
                    elseif v.loadCount >= 0 and SocketClient.GetState() == CState.CONNECT_STATE_IDLE then
                        LogoutAccount()
                    end
                    v.loadCount = v.loadCount + 1
                    M.RemoveLoad()
                end
                M.ShowHttpLoad(string.format(LanguageManager:GetTextByID(10002), v.loadCount, nLoadCount))
                if v.loadCount and v.loadCount >= nLoadCount then
                    LogoutAccount()
                end
            end
        end
    end
end

--开始
local function StartScheduler()
    if not updateTimer then
        updateTimer = TimerManagerInst:GetTimer(1, OnUpdate, M, false, false, true)
    end
end

--停止
local function StopScheduler()
    if updateTimer then
        updateTimer:Stop()
        updateTimer = nil
    end
end

--------------------------------------------强大的分割线------------------------------------------------------
--添加队列 --如果已经在重连就不添加进来了
function M.AddRequest(nId, messageName)
    if not SocketClient.IsReconnect() then
        tabQueue[tostring(nId)] = { time = os.time(), reconnectTimer = 0, clock = os.clock(), messageName = messageName }
        OnUpdate()
        StartScheduler()
        isStop = false
        printInfo("请求数据时间 nIdx = %d messageName = %s nTimer = %.3f 秒", nId, tostring(messageName), os.time())
    end
end
--结束队列
function M.RemoveRequest(nId, messageName)
    if tabQueue[tostring(nId)] then
        printInfo("收到数据使用时间 nIdx = %d messageName = %s nTimer = %.3f 秒", nId, tostring(messageName),
                  os.clock() - tabQueue[tostring(nId)].clock)
    end
    tabQueue[tostring(nId)] = nil
    if IsEmptyTable(tabQueue) then
        M.Clear()
    end
end
--走一个连接服务器得过程
function M.ReConnectNet()
    M.Clear()
    if IsEmptyTable(tabQueue) then
        tabQueue[tostring(0)] = { time = os.time() - nLoadTimer, reconnectTimer = 0, clock = os.clock(), messageName = "ReConnectNet" }
    end
    OnUpdate()
    StartScheduler()
    isStop = false
end

--清除所有数据
function M.Clear()
    tabQueue = { }
    StopScheduler()
    isStop = true
    M.RemoveLoad()
end

--显示socket请求时候的load动画
--function M.showSocketLoad()
--    if not isStop and nil == loadLayer or tolua.isnull(loadLayer) then
--        loadLayer = NetLoadLayer.new()
--        loadLayer:showLoading()
--        GameLayerMgr.AddLayer(loadLayer)
--    end
--end

function M.IsConnection(isShowError)
    local isConnection = true--Network.GetInternetConnectionStatus()
    -- if device.platform == "ios" or device.platform == "android" then
    --     printInfo("isConnection ========== %s    ddd  ==========%d", device.platform, network.getInternetConnectionStatus())
    --     if network.getInternetConnectionStatus() == 0 and isShowError then
    --         M.showNetworkErrorTips()
    --         isConnection = false
    --     end
    -- end
    return isConnection
end

-- function M.showNetworkErrorTips()
--     if SocketClient.GetState() == CState.CONNECT_STATE_IDLE then
--         M.Clear()
--         SocketClient.stopBeatHandleSchedule()
--         GameLayerMgr.ShowTips({
--                                   content = MBLanguageMgr:getTextByID(971012),
--                                   btnTitleRight = MBLanguageMgr:getTextByID(971010),
--                                   cfRight = function()
--                                       CTL_ROUTE(GAME_CONST.moduleName.login, "LogoutAccount", nil)
--                                   end,
--                                   isLocalZOrder = true
--                               }, false)
--     end
-- end

function M.showNetworkCloseTips()
    M.Clear()
    SocketClient.stopBeatHandleSchedule()
    -- GameLayerMgr.ShowTips(
    --         {
    --             content = MBLanguageMgr:getTextByID(971005),
    --             btnTitleRight = MBLanguageMgr:getTextByID(971010),
    --             cfRight = function()
    --                 CTL_ROUTE(GAME_CONST.moduleName.login, "LogoutAccount", nil)
    --             end,
    --             isLocalZOrder = true
    --         }, false)

end

--显示Http请求时候的load动画
function M.ShowHttpLoad(strTip)
    -- if not isStop and nil == loadLayer or tolua.isnull(loadLayer) then
    --     loadLayer = NetLoadLayer.new()
    --     GameLayerMgr.addLoadingLayer(loadLayer)
    -- end
    -- if not tolua.isnull(loadLayer) then
    --     loadLayer:ShowHttpLoading(strTip)
    -- end
end

--remove load界面
function M.RemoveLoad()
    -- MBGfunction:removeNode(loadLayer)
    -- loadLayer = nil
end

local specialShowMessageFunc = {
    -- [ResultCode.RET_ERROR_NO_MONEY] = function()
    --     GameLayerMgr.ShowLackOfDiamondsTips()
    --     return true
    -- end,
    -- [ResultCode.RET_ACT_NO_GOLD] = function()
    --     GameLayerMgr.ShowLackOfDiamondsTips()
    --     return true
    -- end,
    -- [ResultCode.RET_ERROR_NO_PHYPOWER] = function()
    --     CTL_ROUTE(GAME_CONST.moduleName.player, "reqBuyPhysicalPower")
    -- end,
    -- [ResultCode.RET_ERROR_NO_GOLD] = function()
    --     CTL_ROUTE(GAME_CONST.moduleName.player, "reqBuyGold")
    -- end,
    -- [ResultCode.RET_CHAT_TOO_FAST] = function()
    --     return true
    -- end,
    -- [ResultCode.RET_FCM_OVERTIME] = function()
    --     GameLayerMgr.ShowMsg(MBLanguageMgr:getTextByID(1550002))
    --     SocketClient.stopBeatHandleSchedule()
    --     M.Clear()
    --     return true
    -- end,
    -- [ResultCode.RET_FCM_CANT_LOGIN] = function()
    --     GameLayerMgr.ShowMsg(MBLanguageMgr:getTextByID(1550001))
    --     SocketClient.stopBeatHandleSchedule()
    --     M.Clear()
    --     return true
    -- end,
    -- [ResultCode.RET_FCM_NOT_AUTH] = function()
    --     GameLayerMgr.ShowMsg(MBLanguageMgr:getTextByID(1550008))
    --     SocketClient.stopBeatHandleSchedule()
    --     M.Clear()
    --     return true
    -- end
}

--显示错误消息 812 表示战斗失败。不弹出提示
function M.ShowErrorMessage(nCode, isShowMessageFunc)
    -- if nil == isShowMessageFunc then isShowMessageFunc = true end
    -- if nCode and nCode > 0 and nCode ~= ResultCode.RET_PVE_BATTLE_FAIL then
    --     --拦截错误码
    --     if isShowMessageFunc and specialShowMessageFunc[nCode] and specialShowMessageFunc[nCode]() then
    --         return
    --     end

    --     if (nCode == ResultCode.RET_ERROR_PARAM or nCode == ResultCode.RET_ERROR) and GameBtlMgr and EnumNewPVPSystem[GameBtlMgr:getBtlType()] then
    --         return
    --     end

    --     local message = string.format(MBLanguageMgr:getTextByID(971004), nCode)
    --     if resultCode[nCode] then
    --         message = resultCode[nCode].noticeResult
    --     end
    --     GameLayerMgr.ShowMsg(message)
    -- end
end

return M