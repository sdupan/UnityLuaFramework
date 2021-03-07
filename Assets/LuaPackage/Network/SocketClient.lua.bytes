local M                         = class(...)

local SocketTCP                 = require("Network.SocketTCP")
local Request                   = require("Network.Request")
local CState                    = require("Network.ConnectState")
local Message                   = require("Network.Message")
local Proto                     = require("Network.ProtoMgr")
local NetDebugNesting = 3

--------------------事件名称---------------------------
M.EVENT_NAME_CLOSE              = "close"
M.EVENT_NAME_CLOSED             = "closed"
M.EVENT_NAME_ERROR              = "error"
M.EVENT_NAME_RECEIVE            = "receive"
M.EVENT_NAME_CONNECT            = "connect"
M.EVENT_NAME_CONNECT_FAILURE    = "connectFailure"
M.EVENT_NAME_REQUEST            = "request"
-----------------------事件注册-----------------------------------------
local function BindEvent(name)
    if not string.isempty(name) then
        M[name] = { }
        CSS.Bind(M[name], "Event")
    else
        CSS.Bind(M, "Event")
    end
end
--普通事件, socket close后, 事件会自动移除
BindEvent("event")
--静态事件, socket close后, 事件不会移除
BindEvent("event_static")
--自身事件分发
BindEvent("")

----------------------参数定义---------------------------------
local isDebugInfo         = false
--超时时间
local _timeout            = 20
--连接次数限制
local _connectLimit       = 5
local _connectTime        = 0

local _socketTcp          = nil
local _state              = CState.CONNECT_STATE_IDLE
local _isNetwork          = nil
--请求
local _tabRequest         = {}
--服务器_id
local _serverId           = nil
--playerId
local _playerId           = nil
--openId
local _openId             = nil
--sessionId
local _sessionId          = nil
-- ip
local _ip                 = nil
-- 端口
local _port               = nil
--定时心跳请求
local _beatHandleSchedule = nil
-- CmdHeartBeat
--加载过程中的推送数据
local _loadingBeforData   = {}
-- 当前是否为加载数据当中  例如登陆请求，重连 loading过程中，服务端返回数据不做处理
-- _isLoading = false
--服务器时间和本地时间差
local _timeDiff           = 0
local _index              = 1
local _serverIndex        = 0

local _localTimeZone      = 8
local _serverTimeZone     = 8

local isRequestMoreMessageName = {
    CmdGoldTrialCalc = true,
    CmdMasterLoadChaptersInfo = true,
    CmdActivityInfo = true,
    CmdGetPlayerDynAct = true,
    CmdLoadTowerInfo   = true,
    CmdEditPlot = true,
}
-------------------------function-----------------------------------
--设置服务器时区
local function UpdateServerTimeZone(timezone)
    --服务器时区 (全球同服 暂时写死)
    local serverTimeZone = timezone
    --当前系统时区
    local localTimeZone  = 0
    local temp           = os.date("*t", 0)
    if temp.year == 1970 then
        localTimeZone = temp.hour
    else
        localTimeZone = temp.hour - 24
    end
    --保存时区
    _localTimeZone  = localTimeZone
    _serverTimeZone = serverTimeZone
end

--定时做超时检测
local function OnUpdate()
    -- 开始重连状体,不处理
    if _state == CState.CONNECT_STATE_START then
        return
    end
    local now     = os.time()
    local timeout = false
    for _, request in pairs(_tabRequest) do
        if now - request.timestamp > _timeout then
            timeout = true
            break
        end
    end
    --超时逻辑
    if timeout then
        if _state == CState.CONNECT_STATE_RECONNECTING or _sessionId == nil then
            M.Disconnect()
        else
            M.ReConnect()
        end
    end
end

--心跳包
local function ReqCmdHeartBeat()
    local isHaveRequest = next(_tabRequest)
    if not isHaveRequest then
        M.Request {
            messageName = "CmdHeartbeat",
            params      = { },
            free        = true,
            fCallback   = nil,
        }
    end
end

local function StopBeatHandleSchedule()
    if _beatHandleSchedule then
        _beatHandleSchedule:Stop()
        _beatHandleSchedule = nil
    end
end

local function StartBeatHandleSchedule()
    StopBeatHandleSchedule()
    if _state == CState.CONNECT_STATE_CONNECTED then
        _beatHandleSchedule = TimerManagerInst:GetTimer(_timeout, ReqCmdHeartBeat, M, false, false, true)
        _beatHandleSchedule:Start()
    end
end

local function UpdateServerTime(serverTime)
    _timeDiff = serverTime - os.time() * 1000
end

--错误处理
---@param req Request
local function OnReceiveError(cmdError, req)
    local notDispatchEvent = false
    if req then
        notDispatchEvent = req:OnReceive(cmdError, false)
    end
    --是否走默认的错误处理逻辑
    if notDispatchEvent then
    else
        local data = {
            cmdX    = cmdError,
            request = req,
        }
        --分发错误事件
        M:DispatchEvent {
            name = M.EVENT_NAME_ERROR,
            data = data
        }
    end
end

local function SetServerIndex(index, playerId, messageId)
    if messageId ~= 0 and playerId ~= 0 and index > _serverIndex then
        _serverIndex = index
    end
end

local function OnReceiveCmdData(cmdData, size)
    local cmdMessage = cmdData.message
    local messageId  = cmdMessage.messageId
    local index      = cmdMessage.index
    local data       = cmdData.data
    --更新时间
    UpdateServerTime(cmdMessage.serverTime)
    -- NetCtl.RemoveRequest(index, Message.GetMessageName(cmdMessage.messageId))

    --更新服务器索引
    SetServerIndex(cmdMessage.serverIndex, cmdMessage.playerId, messageId)
    M.SetPlayerId(cmdMessage.playerId)

    --请求
    local req          = _tabRequest[index]
    _tabRequest[index] = nil

    --解压
    if cmdData.compress then
        -- data = require("zlib").inflate()(data, "finish")
    end
    --反序列化类名
    local rspMessageName = Message.GetRspMessageName(messageId)
    local messageName    = Message.GetMessageName(messageId)
    --反序列化
    local tabCmdData     = Proto.Decode(rspMessageName, data)
    -- 打印 isDebugInfo 是否 打印 服务器 下发 详细 数据
    --构建事件数据
    local cmdReceiveData = {
        cmdX    = tabCmdData,
        request = req,
    }
    --分发协议事件
    M.event_static:DispatchEvent {
        name = messageName,
        data = cmdReceiveData,
    }

    M.event:DispatchEvent {
        name = messageName,
        data = cmdReceiveData,
    }

    --分发接收事件
    M:DispatchEvent {
        name = M.EVENT_NAME_RECEIVE,
        data = cmdReceiveData
    }
    if isDebugInfo then
        if messageName ~= "CmdEventUpdate" then
            dump(tabCmdData,
                 string.format("接收到数据 => <messageId = %s> <messageName = %s>", messageId, messageName),
                 NetDebugNesting)
        end
    else
        print("time = " .. os.time() .. " messageId = %s messageName = %s", messageId, messageName)
    end
    --request接收回调
    if not req then
        return
    end
    req:OnReceive(tabCmdData, true)
end

local function OnReceive(event)
    local data    = event.data
    local cmdData = Proto.Decode("CmdData", data)
    OnReceiveCmdData(cmdData)
    StartBeatHandleSchedule()
    --local ack = cmdData.message.ack
    --if ack and ack ~= GAME_CONST.IntServerNil then
    --    _seq = ack + size
    --end
end

local function ClearNetInfo()
    _state      = "idle"
    _serverId   = nil
    _playerId   = nil
    _sessionId  = nil
    _openId     = nil
    _tabRequest = {}
    StopBeatHandleSchedule()
end

local function OnClose()
    if _state == CState.CONNECT_STATE_CONNECTED and _serverId ~= nil then
        NetCtl.ReConnectNet()
    elseif _connectLimit <= _connectTime then
        --重连次数上限才关闭
        printInfo("client on close -> OnClose")
        --清理数据
        ClearNetInfo()
        --分发接收事件
        M:DispatchEvent { name = M.EVENT_NAME_CLOSE }
    end
end

local function OnClosed()
    ClearNetInfo()
    M:DispatchEvent { name = M.EVENT_NAME_CLOSED }
end

local function ConnectServer(connect, connectFailure)
    _socketTcp = SocketTCP.new(_ip, _port, false)
    _socketTcp:AddEventListener(SocketTCP.EVENT_CONNECTED, connect)
    _socketTcp:AddEventListener(SocketTCP.EVENT_CLOSE, OnClose)
    _socketTcp:AddEventListener(SocketTCP.EVENT_CONNECT_FAILURE, connectFailure)
    _socketTcp:AddEventListener(SocketTCP.EVENT_DATA, OnReceive)
    _socketTcp:AddEventListener(SocketTCP.EVENT_CLOSED, OnClosed)
    _socketTcp:Connect()
end

local function Start(ip, port, serverId)
    print("---------------- come into client start", _state)
    if _state == CState.CONNECT_STATE_CONNECTED then return end
    _ip       = ip
    _port     = port
    _state    = CState.CONNECT_STATE_CONNECTING
    _serverId = serverId
    local function __Connect()
        _state       = CState.CONNECT_STATE_CONNECTED
        _connectTime = 0
        --重置超时参数
        M.SetSessionId(nil)
        M.SetPlayerId(nil)
        --分发接收事件
        M:DispatchEvent { name = M.EVENT_NAME_CONNECT }
    end
    local function __ConnectFailure()
        M:DispatchEvent { name = M.EVENT_NAME_CONNECT_FAILURE }
    end
    ConnectServer(__Connect, __ConnectFailure)
end

local function ReConnect()
    assert(_state == CState.CONNECT_STATE_CONNECTED or _state == CState.CONNECT_STATE_RECONNECT,
           string.format("_state = %s", tostring(_state)))

    --切换状态到开始重连状态
    _state = CState.CONNECT_STATE_START
    StopBeatHandleSchedule()
    printInfo("^^^^^^^^^^^ start reconnect nConnectTime = %d ^^^^^^^^^^^^^^^^", _connectTime)
    _connectTime = _connectTime + 1
    --删除旧所有事件
    _socketTcp:RemoveAllEventListeners()
    _socketTcp:Disconnect()
    _socketTcp:Close()
    local function __ReConnectCallback(cmdPlayerReconnectionRspMsg)
        --是否重连成功
        local result = cmdPlayerReconnectionRspMsg.result
        printInfo("*****************重新连%d接成功******************", result)
        if result > 0 then
            M.Disconnect()
            return
        end
        NetCtl.Clear()
        --恢复为连接状态
        _state       = CState.CONNECT_STATE_CONNECTED
        _connectTime = 0

        --处理重连失败的请求
        local tlRequest = {}
        for index, request in pairs(_tabRequest) do
            tlRequest[#tlRequest + 1] = request
        end
        -- dump(tlRequest,"需要重新连接的数据",10)
        --排序
        table.sort(tlRequest, function(request1, request2)
            return request1.index < request2.index
        end)
        --处理未发送成功的请求
        for _, request in ipairs(tlRequest) do
            --不发心跳包
            if request.messageName ~= "CmdHeartbeat" then
                request:UpdateTimestamp()
                _socketTcp:Send(request.sendData)
            else
                _tabRequest[request.index] = nil
            end
            print("----------------断线重连发送请求", request.messageName)
        end
        
        -- if CTL_ROUTE(GAME_CONST.moduleName.guide, "isRequestGuideIng") then
        --     print("----------------断线重连重置新手引导")
        --     CTL_ROUTE(GAME_CONST.moduleName.guide, "clearGuide")
        --     MDL_ROUTE(GAME_CONST.moduleName.guide, "setPlayGuideState",false)
        -- end
    end
    local function __Connect()
        --切换状态到重连状态
        _state          = CState.CONNECT_STATE_RECONNECTING
        local loginData = {}--GameCtlMgr:route(GAME_CONST.moduleName.login, "getLoginData")
        local params    = {
            userType  = loginData.userType,
            openID    = loginData.id,
            token     = loginData.serverSign,
            timeStamp = tostring(loginData.timestamp),
            playerId  = M.GetPlayerId(),
            --防沉迷参数
            age           = loginData.age or 0,
            authState     = loginData.authState or 0,
        }
        M.request {
            messageName     = "CmdAccountQuickLogin",
            params          = params,
            isLoading       = true,
            ignoreReconnect = true,
            fCallback       = function(cmdPlayerReconnectionRspMsg)
                __ReConnectCallback(cmdPlayerReconnectionRspMsg)
            end,
        }
    end

    local function __ConnectFailure()
        M:DispatchEvent {
            name = M.EVENT_NAME_CONNECT_FAILURE,
            data = true
        }
        _state = CState.CONNECT_STATE_RECONNECT
        printInfo("重连失败。。。。。。。。。M.nConnectTime = %d", _connectTime)
    end
    ConnectServer(__Connect, __ConnectFailure)
end
--添加服务器请求
local function AddRequest(req)
    if _state == CState.CONNECT_STATE_IDLE then
        return false
    end
    --request 唯一索引
    _index              = _index + 1
    _tabRequest[_index] = req
    req.index           = _index
    -- NetCtl.AddRequest(_index, req.messageName)
    local messageName    = req.messageName
    local params         = req.params
    --数据
    local messageId      = Message.GetMessageId(messageName)
    local reqMessageName = Message.GetReqMessageName(messageId)
    --序列化数据
    local data           = Proto.Encode(reqMessageName, params)
    --消息头
    local cmdMessage     = {
        messageId   = messageId,
        serverId    = _serverId,
        playerId    = _playerId,
        index       = _index,
        serverIndex = _serverIndex,
    }
    --封装CmdData
    local cmdData        = {
        message    = cmdMessage,
        data       = data,
        appendCode = nil,
        appendData = nil,
    }

    --分发请求事件
    M:DispatchEvent {
        name = M.EVENT_NAME_REQUEST,
        data = { request = req }
    }
    local sendData = Proto.Encode("CmdData", cmdData)
    req.sendData   = sendData
    --发送数据,且不是重连请求 --直接发送
    if (_state == CState.CONNECT_STATE_CONNECTED and NetCtl.IsConnection()) or req.ignoreReconnect then
        print("<<<<<<<<<< send  data state >>>>>>>>>>", _state)
        _socketTcp:Send(sendData)
    else
        print("<<<<<<<<<< next  send  data state >>>>>>>>>>", _state, req.index, Network.GetInternetConnectionStatus())
    end
    --打印
    -- if isDebugInfo then
    --     dump(params, string.format("send data <messageName = %s> <nIdx = %d>", messageName, _index), NetDebugNesting)
    -- end
    --如果有请求就停止运行
    StopBeatHandleSchedule()
    return true
end
--请求服务器
local function __Request(params)
    --检查socket是否已经关闭
    if _socketTcp and not _socketTcp.isConnected then
        print(">>>>>>>>>>>socket close<<<<<<")
        NetCtl.ShowNetworkCloseTips()
        return
    end
    _isNetwork    = NetCtl.IsConnection(true)
    local req     = Request.new(params)
    local lastReq = _tabRequest[_index]
    if (lastReq and req.isRequest and lastReq.messageName == req.messageName and not isRequestMoreMessageName[req.messageName]) then
        printInfo("存在了一样的请求而且是被频闭掉了isRequest = %s,last = lastReq.messageName = %s,request.messageName",
                  tostring(req.isRequest), tostring(lastReq.messageName), tostring(req.messageName))
        return false
    end
    printInfo("request messageName = %s", req.messageName)
    return AddRequest(req)
end
--断开socket
local function Disconnect()
    if _state == CState.CONNECT_STATE_IDLE then
        return
    end
    _state = CState.CONNECT_STATE_IDLE
    _socketTcp:Disconnect()
    _socketTcp:Close()
end

--是否在重连中
local function IsReconnect()
    return _connectTime > 0
end
--获取服务器日期
local function GetServerDate(format, time)
    --时区差
    local diffTimeZone = _localTimeZone - _serverTimeZone
    return os.date(format, time - diffTimeZone * 3600)
end

local function SetSessionId(id)
    _sessionId = id
end
local function GetSessionId()
    return _sessionId
end

local function SetPlayerId(id)
    _playerId = id
end
local function GetPlayerId()
    return _playerId
end

--获取服务器时间
local function GetServerTime()
    return os.time() * 1000 + _timeDiff
end

local function GetState()
    return _state
end
--获取服务器id
local function GetServerId()
    return _serverId
end
--获取ip
local function GetIp()
    return _ip
end
--获取port
local function GetPort()
    return _port
end

--开始连接socket
M.Start                  = Start
--重连
M.ReConnect              = ReConnect
--关闭
M.Disconnect             = Disconnect
--请求
M.Request                = __Request
--是否重连中
M.IsReconnect            = IsReconnect
--获取服务器日期
M.GetServerDate          = GetServerDate
--暂时不知道用处
M.SetSessionId           = SetSessionId
M.GetSessionId           = GetSessionId
--玩家ID
M.SetPlayerId            = SetPlayerId
M.GetPlayerId            = GetPlayerId
--获取服务器时间
M.GetServerTime          = GetServerTime
--停止心跳包
M.StopBeatHandleSchedule = StopBeatHandleSchedule
--获取状态
M.GetState               = GetState
--获取服务器id
M.GetServerId            = GetServerId
--获取ip
M.GetIp                  = GetIp
--获取port
M.GetPort                = GetPort

return M
