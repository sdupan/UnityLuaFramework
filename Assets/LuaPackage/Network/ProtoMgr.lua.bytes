local protobuf = require("pb")
local protoc = require("Network.Proto.protoc")
local tmProto = require("Network.Protos")

local all_proto_files = {}
local all_loaded_protos = {}

local M = {}

function M.Register(protos)
    all_proto_files = protos or {}
    protoc.unknown_import = function(self, module_name)
        for k, v in pairs(all_proto_files) do
            if string.find(k, module_name) then
                if protoc.loaded[k] then
                    return true
                else
                    all_loaded_protos[k] = true
                    return protoc:load(v, k)
                end
            end
        end
    end
    
    for k, v in pairs(all_proto_files) do
        if not all_loaded_protos[k] then
            protoc:load(v, k)
            all_loaded_protos[k] = true
        end
    end

    --注册每个字段的类型
    for _, proto in pairs(tmProto) do
        if proto.type == "message" then
            for _, field in pairs(proto.tmField) do
                local proto = tmProto[field.type]
                if proto and proto.type == "message" then
                    field.ismessage = true
                end
                if proto and proto.type == "enum" then
                    field.isenum = true
                end
            end
        end
    end
end

--获取Proto的信息
function M.GetProto(protoName)
    return tmProto[protoName]
end

--获取enumId
function M.GetEnumId(protoName, enum)
    local proto = M.getProto(protoName)
    return proto.enums[enum]
end

--获取enum
function M.GetEnum(protoName, enumId)
    local proto = M.getProto(protoName)
    for _enum,_enumId in pairs(proto.enums) do
        if _enumId == enumId then
            return _enum
        end
    end 
    return nil
end

function M.Encode(protoName, data)
    local proto = M.GetProto(protoName)
    return protobuf.encode(proto.fullName, data)
end

function M.Decode(protoName, data)
    local proto = M.GetProto(protoName)
    return protobuf.decode(proto.fullName, data)
end

return M