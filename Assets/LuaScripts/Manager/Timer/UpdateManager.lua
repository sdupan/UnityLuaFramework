---------------------------------------------------------------------------------------------------------------
-- 更新管理，负责Unity侧Update、LateUpdate、FixedUpdate对Lua脚本的调用
-- 注意：
-- 1、别直接用tolua的UpdateBeat、LateUpdateBeat、FixedUpdateBeat，所有需要以上三个更新函数的脚本，都从这里注册。
-- 2、tolua的event没有使用weak表，直接使用tolua的更新系统会导致脚本被event持有引用而无法释放---除非每次都记得手动去释放
---------------------------------------------------------------------------------------------------------------

local UpdateManager = class("UpdateManager", Singleton)
local UpdateMsgName = "Update"
local LateUpdateMsgName = "LateUpdateMsgName"
local FixedUpdateMsgName = "FixedUpdateMsgName"

-- 构造函数
function UpdateManager:ctor()
	UpdateManager.super.ctor(self)
	-- 成员变量
	-- 消息中心
	self.ui_message_center = {}
	CSS.Bind(self.ui_message_center, "Event")
	-- Update
	self.__update_handle = nil
	-- LateUpdate
	self.__lateupdate_handle = nil
	-- FixedUpdate
	self.__fixedupdate_handle = nil
end

-- Update回调
function UpdateManager:UpdateHandle()
	self.ui_message_center:DispatchEvent({name = UpdateMsgName})
end

-- LateUpdate回调
function UpdateManager:LateUpdateHandle()
	self.ui_message_center:DispatchEvent({name = LateUpdateMsgName})
end

-- FixedUpdate回调
function UpdateManager:FixedUpdateHandle()
	self.ui_message_center:DispatchEvent({name = FixedUpdateMsgName})
end

-- 启动
function UpdateManager:Startup()
	self:Dispose()
	self.__update_handle = UpdateBeat:CreateListener(self.UpdateHandle, UpdateManager:GetInstance())
	self.__lateupdate_handle = LateUpdateBeat:CreateListener(self.LateUpdateHandle, UpdateManager:GetInstance())
	self.__fixedupdate_handle = FixedUpdateBeat:CreateListener(self.FixedUpdateHandle, UpdateManager:GetInstance())
	UpdateBeat:AddListener(self.__update_handle)
	LateUpdateBeat:AddListener(self.__lateupdate_handle)
	FixedUpdateBeat:AddListener(self.__fixedupdate_handle)
end

-- 释放
function UpdateManager:Dispose()
	if self.__update_handle ~= nil then
		UpdateBeat:RemoveListener(self.__update_handle)
		self.__update_handle = nil
	end
	if self.__lateupdate_handle ~= nil then
		LateUpdateBeat:RemoveListener(self.__lateupdate_handle)
		self.__lateupdate_handle = nil
	end
	if self.__fixedupdate_handle ~= nil then
		FixedUpdateBeat:RemoveListener(self.__fixedupdate_handle)
		self.__fixedupdate_handle = nil
	end
end

-- 清理：消息系统不需要强行清理
function UpdateManager:Cleanup()
end

-- 添加Update更新
function UpdateManager:AddUpdate(e_listener)
	self.ui_message_center:AddEventListener(UpdateMsgName, e_listener)
end

-- 添加LateUpdate更新
function UpdateManager:AddLateUpdate(e_listener)
	self.ui_message_center:AddEventListener(LateUpdateMsgName, e_listener)
end

-- 添加FixedUpdate更新
function UpdateManager:AddFixedUpdate(e_listener)
	self.ui_message_center:AddEventListener(FixedUpdateMsgName, e_listener)
end

-- 移除Update更新
function UpdateManager:RemoveUpdate(e_listener)
	self.ui_message_center:RemoveEventListener(e_listener)
end

-- 移除LateUpdate更新
function UpdateManager:RemoveLateUpdate(e_listener)
	self.ui_message_center:RemoveEventListener(e_listener)
end

-- 移除FixedUpdate更新
function UpdateManager:RemoveFixedUpdate(e_listener)
	self.ui_message_center:RemoveEventListener(e_listener)
end

-- 析构函数
function UpdateManager:__delete()
	self:Cleanup()
	self.ui_message_center = nil
end

return UpdateManager