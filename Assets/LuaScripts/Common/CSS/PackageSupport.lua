local unpack = unpack or table.unpack

CSS.loaded_packages = {}
local loaded_packages = CSS.loaded_packages

function CSS.Register(name, package)
    CSS.loaded_packages[name] = package
end

function CSS.Load(...)
    local names = {...}
    assert(#names > 0, "CSS.Load() - invalid package names")

    local packages = {}
    for _, name in ipairs(names) do
        assert(type(name) == "string", string.format("CSS.Load() - invalid package name \"%s\"", tostring(name)))
        if not loaded_packages[name] then
            local packageName = string.format("packages.%s.init", name)
            local cls = require(packageName)
            assert(cls, string.format("CSS.Load() - package class \"%s\" load failed", packageName))
            loaded_packages[name] = cls
        end
        packages[#packages + 1] = loaded_packages[name]
    end
    return unpack(packages)
end

local load_ = CSS.Load
local bind_
bind_ = function(target, ...)
    print("CSS.Bind target ---->>")
    local t = type(target)
    assert(t == "table" or t == "userdata", string.format("CSS.Bind() - invalid target, expected is object, actual is %s", t))
    local names = {...}
    assert(#names > 0, "CSS.Bind() - package names expected")

    load_(...)
    if not target.components_ then target.components_ = {} end
    for _, name in ipairs(names) do
        assert(type(name) == "string" and name ~= "", string.format("CSS.Bind() - invalid package name \"%s\"", name))
        if not target.components_[name] then
            print("---> name = "..name)
            local cls = loaded_packages[name]
            for __, depend in ipairs(cls.depends or {}) do
                if not target.components_[depend] then
                    bind_(target, depend)
                end
            end
            --dump(cls, "what the fuck", 60)
            local component = cls:create()
            target.components_[name] = component
            component:Bind(target)
        end
    end

    return target
end
CSS.Bind = bind_

function CSS.UnBind(target, ...)
    if not target.components_ then return end

    local names = {...}
    assert(#names > 0, "CSS.UnBind() - invalid package names")

    for _, name in ipairs(names) do
        assert(type(name) == "string" and name ~= "", string.format("CSS.UnBind() - invalid package name \"%s\"", name))
        local component = target.components_[name]
        assert(component, string.format("CSS.UnBind() - component \"%s\" not found", tostring(name)))
        component:UnBind(target)
        target.components_[name] = nil
    end
    return target
end

function CSS.SetMethods(target, component, methods)
    for _, name in ipairs(methods) do
        local method = component[name]
        target[name] = function(__, ...)
            return method(component, ...)
        end
    end
end

function CSS.UnSetMethods(target, methods)
    for _, name in ipairs(methods) do
        target[name] = nil
    end
end
