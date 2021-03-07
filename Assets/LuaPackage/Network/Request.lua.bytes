-----------------------------------------------------------------------------------------------
-- @description 请求 
--------------------------------------------------------------------------------------------
---@class Request
local M = class(...)
function M:ctor(params)
    --消息名
    self.messageName = params.messageName
    --参数
    self.params = params.params
    --正常回调
    self.fCallback = params.fCallback
    --错误回调
    self.fErrorCallback = params.fErrorCallback
    --超时回调
    self.fTimeoutCallback = params.fTimeoutCallback
    --加载过程是否处理其他响应
    self.isLoading = params.isLoading
    --是否忽略断线重连，直接发送请求
    self.ignoreReconnect = params.ignoreReconnect
    --request的生命周期绑定view, view被销毁后 不会回调
    self.view = params.view
    --没有用到
    self.isReconnect = params.isReconnect
    --请求期间是否允许玩家操作
    self.free = params.free
    --新加 如果是已经请求了。true 数据还没有返回就不在请求了 false 不理会
    self.isRequest = params.isRequest == nil and true or params.isRequest
    --时间
    self.timestamp = os.time()
end

function M:UpdateTimestamp()
    self.timestamp = os.time()
end

function M:OnReceive(tabCmdData, suc)
    ---如果绑定了view, 但是 为空
    -- if MBGfunction:isExistNode(self.view) then
    --     return suc
    -- end
    if suc then
        if IsFunction(self.fCallback) then
            self.fCallback(tabCmdData)
        end
        -- NetCtl.showErrorMessage(tabCmdData.result)
    else
        if IsFunction(self.fErrorCallback) then
            return self.fErrorCallback(tabCmdData)
        else
            return suc
        end
    end
end

function M:OnTimeout()
    --如果绑定了view, 但是 为空
    -- if self.view ~= nil and tolua.isnull(self.view) then
    --     return
    -- end
    if IsFunction(self.fTimeoutCallback) then
        self.fTimeoutCallback()
    end
end

return M



