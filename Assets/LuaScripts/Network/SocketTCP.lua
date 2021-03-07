local SOCKET_TICK_TIME = 0.1         -- check socket data interval
local SOCKET_RECONNECT_TIME = 5         -- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 10   -- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local LENGTH_HEAD = 4 --粘包头长度

local socket = require "socket"

local SocketTCP = class("SocketTCP")

SocketTCP.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTCP.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTCP.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTCP.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

SocketTCP._VERSION = socket._VERSION
SocketTCP._DEBUG = socket._DEBUG

--[[
获取数字的整数部分
]]
local function GetIntPart(x)
    if x <= 0 then
       return math.ceil(x);
    end
    
    if math.ceil(x) == x then
       x = math.ceil(x);
    else
       x = math.ceil(x) - 1;
    end
    return x;
end

--[[
将数字转换成字节数据并返回，最大支持99999999
与Bytes2Num(bytes)配合使用
]]
local function Num2Bytes(num)
    local BASE_ZERO = 28
    if type(num) =="number"  and  num >0 and num <= 99999999 then 
        local temp =num
        local weiItem=0
        local re_btyes={}
        local i
        for i=1,4 do
            if temp >0 then 
                weiItem= temp % 100
                re_btyes[#re_btyes+1] = weiItem+BASE_ZERO
                temp = GetIntPart(temp / 100)
            else
                re_btyes[#re_btyes+1]=BASE_ZERO
            end
        end 
        return string.char(re_btyes[4],re_btyes[3],re_btyes[2],re_btyes[1])
    end
    print("num must >0 and <= 99999999") 
end 

--[[
将字节数据转换为数字并返回，与num2Btyes(num) 配合使用
]]
local function Bytes2Num(bytes)
    local BASE_ZERO =28
    if type(bytes) =="string" and  string.len(bytes)==4 then
        local wei =1
        local re_num=0
        local i
        for i=4,1,-1 do
            re_num = re_num + (string.byte(bytes,i)-BASE_ZERO) * wei
            if i > 1 then 
                wei = wei * 100
            end
        end
        return re_num 
    end 
    print("bytes len must is 4")
end

function SocketTCP.GetTime()
    return socket.gettime()
end

function SocketTCP:ctor(__host, __port, __retryConnectWhenFailure)
    CSS.Bind(self, "Event")

    self.host = __host
    self.port = __port
    self.tickScheduler = nil            -- timer for data
    self.reconnectScheduler = nil       -- timer for reconnect
    self.connectTimeTickScheduler = nil -- timer for connect timeout
    self.name = 'SocketTCP'
    self.tcp = nil
    self.isRetryConnect = __retryConnectWhenFailure
    self.isConnected = false
end

function SocketTCP:SetName( __name )
    self.name = __name
    return self
end

function SocketTCP:SetTickTime(__time)
    SOCKET_TICK_TIME = __time
    return self
end

function SocketTCP:SetReconnTime(__time)
    SOCKET_RECONNECT_TIME = __time
    return self
end

function SocketTCP:SetConnFailTime(__time)
    SOCKET_CONNECT_FAIL_TIMEOUT = __time
    return self
end

function SocketTCP:Connect(__host, __port, __retryConnectWhenFailure)
    if __host then self.host = __host end
    if __port then self.port = __port end
    if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
    assert(self.host or self.port, "Host and port are necessary!")
    --printInfo("%s.connect(%s, %d)", self.name, self.host, self.port)

    --增加ipv6的检测
    local isIpv6_only = false;
    local addrifo, err = socket.dns.getaddrinfo(self.host)
    if addrifo then
        for k, v in pairs(addrifo) do
            if v.family == "inet6" then
                isIpv6_only = true
                break
            end
        end
    end

    if isIpv6_only then
        self.tcp = socket.tcp6()
    else
        self.tcp = socket.tcp()
    end

    self.tcp:settimeout(0)

    local function __CheckConnect()
        local __succ = self:_Connect()
        if __succ then
            self:_OnConnected()
        end
        return __succ
    end

    if not __CheckConnect() then
        -- check whether connection is success
        -- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
        local starttime = os.time()
        self.waitConnect = starttime

        local __connectTimeTick = function ()
            -- printInfo("%s.connectTimeTick", self.name)
            if self.isConnected then return end
            self.waitConnect = os.time()
            --self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
            if self.waitConnect - starttime >= SOCKET_CONNECT_FAIL_TIMEOUT then
                self.waitConnect = nil
                self:Close()
                self:_ConnectFailure()
            end
            __CheckConnect()
        end
        self.connectTimeTickScheduler = TimerManagerInst:GetTimer(0.2, __connectTimeTick, self, false, false, true)
        self.connectTimeTickScheduler:Start()
    end
end

function SocketTCP:_Send(__data)
    assert(self.isConnected, self.name .. " is not connected.")
    self.tcp:send(__data)
end

function SocketTCP:Send(__data)
    local len = LENGTH_HEAD + string.len(__data)
    __data = Num2Bytes(len)..__data
    self:_Send(__data)
end

function SocketTCP:Close( ... )
    --printInfo("%s.close", self.name)
    self.tcp:close();
    if self.connectTimeTickScheduler then
        self.connectTimeTickScheduler:Stop()
        self.connectTimeTickScheduler = nil
    end
    if self.tickScheduler then 
        self.tickScheduler:Stop()
        self.tickScheduler = nil
    end
    self:DispatchEvent({name=SocketTCP.EVENT_CLOSE})
end

-- disconnect on user's own initiative.
function SocketTCP:Disconnect()
    self:_Disconnect()
    self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function SocketTCP:_Connect()
    local __succ, __status = self.tcp:connect(self.host, self.port)
    -- print("SocketTCP._connect:", __succ, __status)
    return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function SocketTCP:_Disconnect()
    self.isConnected = false
    self.tcp:shutdown()
    self:DispatchEvent({name=SocketTCP.EVENT_CLOSED})
end

function SocketTCP:_onDisconnect()
    --printInfo("%s._onDisConnect", self.name);
    self.isConnected = false
    self:DispatchEvent({name=SocketTCP.EVENT_CLOSED})
    self:_Reconnect();
end

-- connecte success, cancel the connection timerout timer
function SocketTCP:_OnConnected()
    --printInfo("%s._onConnectd", self.name)
    self.isConnected = true
    self:DispatchEvent({name=SocketTCP.EVENT_CONNECTED})
    if self.connectTimeTickScheduler then
        self.connectTimeTickScheduler:Stop()
        self.connectTimeTickScheduler = nil
    end


    --创建一个 长度为len的 接收函数
    local function CreateReceive(len)
        
        local len = len
        local tlData = {}
            
        return function()
            if len == 0 then 
                return table.concat(tlData)
            end
            
            --请求
            local __body, __status, __partial = self.tcp:receive(len) 
            --请求失败
            if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
                self:Close()
                if self.isConnected then
                    self:_OnDisconnect()
                else
                    self:_ConnectFailure()
                end
                return false
            end

            --拼接数据
            if  (__body and string.len(__body) == 0) or (__partial and string.len(__partial) == 0) then return true end
            if __body and __partial then __body = __body .. __partial end
            __body = __partial or __body

            if not __body then return true end

            --table.insert(tlData, __body)
            tlData[#tlData + 1] = __body
            len = len-string.len(__body)
            if len ~= 0 then return true end

            return table.concat(tlData)
        end
        

    end

    
    local status = "idle" -- or "head" or "body" or "die"
    local receive = nil
    local isHaveHead=false

    local function SwitchIdle()
        status = "idle"
        receive = nil
    end

    local function SwitchHead()
        status = "head"
        receive = CreateReceive(LENGTH_HEAD)
    end

    local function SwitchDie()
        status = "die"
        receive = nil
    end

    local function Body()
        -- print("-----receive1")
        local ret = receive()
        if ret == false then
            SwitchDie()
            return
        end
        -- print("-----receive2")
        if ret == true or ret == nil then
            return
        end
        -- print("-----receive3")
        SwitchIdle()

        self:DispatchEvent{name=SocketTCP.EVENT_DATA, data=ret}
    end

    local function SwitchBody(len)
        status = "body"
        receive = CreateReceive(len)

        --调用一次body
        Body()
    end

    local function Idle()
        -- print("-----idle")
        SwitchHead()
    end

    local function Head()
        local ret = receive()
        -- print("-----head1")
        if ret == false then
            SwitchDie()
            return
        end
        -- print("-----head2")
        if ret == true or ret == nil then
            isHaveHead = false
            return
        end
        isHaveHead = true
        local number = Bytes2Num(ret)
        SwitchBody(number - LENGTH_HEAD) --有时候好像需要加2个字节长度? 因为服务端的框架会发多2个字节
    end



    local function Die()
        -- do nothing
    end

    local tm = {
        idle = Idle,
        head = Head,
        body = Body,
        die = Die,
    }
    local __Tick = function()
        if self.tickScheduler then
            for i=1,20 do
                tm[status]()
                if status == "idle" or not isHaveHead then
                    tm[status]()
                    if status == "idle" or not isHaveHead then
                        break
                    end
                end
            end
        end
    end

    -- start to read TCP data
    self.tickScheduler = TimerManagerInst:GetTimer(SOCKET_TICK_TIME, __Tick, self, false, false, true)
    self.tickScheduler:Start()
end

function SocketTCP:_ConnectFailure(status)
    self:DispatchEvent({name=SocketTCP.EVENT_CONNECT_FAILURE})
    self:_Reconnect();
end

-- if connection is initiative, do not reconnect
function SocketTCP:_Reconnect(__immediately)
    if not self.isRetryConnect then return end
    if __immediately then self:Connect() return end
    if self.reconnectScheduler then
        self.reconnectScheduler:Stop()
        self.reconnectScheduler = nil
    end

    local __DoReConnect = function ()
        self:Connect()
    end

    self.reconnectScheduler = TimerManagerInst:GetTimer(SOCKET_RECONNECT_TIME, __DoReConnect, self, false, false, true)
    self.reconnectScheduler:Start()
end

return SocketTCP
