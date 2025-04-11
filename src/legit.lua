--[[ Anti-Adonis hook (commented out)
repeat task.wait() until game:IsLoaded()

do
	local function isAdonisAC(tbl)
		return rawget(tbl, "Detected") and typeof(rawget(tbl, "Detected")) == "function" and rawget(tbl, "RLocked")
	end

	for _, v in next, getgc(true) do
		if typeof(v) == "table" and isAdonisAC(v) then
			for i, func in next, v do
				if rawequal(i, "Detected") then
					local old
					old = hookfunction(func, function(action, info, crash)
						if rawequal(action, "_") and rawequal(info, "_") and rawequal(crash, false) then
							return old(action, info, crash)
						end
						return task.wait(9e9)
					end)
					warn("bypassed")
					break
				end
			end
		end
	end
end
]]

-- Global toggles
_G.autoLockPick   = false
_G.showBroken     = false
_G.showRegister   = false
_G.showSmallSafe  = false
_G.showMediumSafe = false

-- Services and Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")

local BredMakurz  = workspace.Map.BredMakurz
local LocalPlayer = Players.LocalPlayer

local ClientWarnRemote = ReplicatedStorage.Events2.ClientWarn
local originalScales = {}

local function ClientWarn(settings)
    ClientWarnRemote:Fire({
        settings.Text or "No Message", 
        settings.Length or 1, 
        settings.Color or Color3.fromRGB(255, 121, 121), 
        settings.OutlineColor or Color3.new(0, 0, 0)
    }) 
end

ClientWarn{Text = "Thank you for using Cartel Lite..."}

-- Helper function to toggle a feature
local function toggleFeature(toggleName, message)
	_G[toggleName] = not _G[toggleName]
	ClientWarn{Text = message .. " was turned: " .. (_G[toggleName] and "ON" or "OFF")}
end

-- Keybind handling (using a simple if/elseif chain)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleFeature("showRegister", "Register ESP")
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleFeature("showSmallSafe", "Small Safe ESP")
    elseif input.KeyCode == Enum.KeyCode.F3 then
        toggleFeature("showMediumSafe", "Medium Safe ESP")
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleFeature("autoLockPick", "Auto Lockpick")
        if not _G.autoLockPick then
            for frame, originalScale in pairs(originalScales) do
                frame.Parent.UIScale.Scale = originalScale
            end
        end
    end
end)

-- Check lockpick frames and simulate mouse click when appropriate
local function checkLockpick(...)
    local frames = { ... }
    for _, frame in ipairs(frames) do
        if not originalScales[frame] then
            originalScales[frame] = frame.Parent.UIScale.Scale
        end
        frame.Parent.UIScale.Scale = _G.autoLockPick and 10 or 1
        if frame.AbsolutePosition.Y >= 450 and frame.AbsolutePosition.Y <= 550 then
            mouse1click()
            task.wait(0.1)
            mouse1release()
        end
    end
end

-- Create ESP billboard
local function createESP(part, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.Text = text
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14

    return billboard
end

-- Update ESP for a single object; simplified broken check
local function updateObject(part, espMap, show, text, color)
    local esp = espMap[part]
    if not show then
        if esp then
            esp:Destroy()
            espMap[part] = nil
        end
        return
    end

    local parent = part.Parent
    local values = parent and parent:FindFirstChild("Values")
    if values then
        local broken = values.Broken.Value
        local shouldShow = (broken == _G.showBroken)
        if shouldShow then
            if not esp then
                esp = createESP(part, text, color)
                esp.Parent = game.CoreGui
                espMap[part] = esp
            end
        elseif esp then
            esp:Destroy()
            espMap[part] = nil
        end
    end
end

-- Mapping table for ESP configurations
local ESP_CONFIG = {
    { key = "Register", toggle = function() return _G.showRegister end, text = "Register", color = Color3.fromRGB(255, 0, 128) },
    { key = "SmallSafe", toggle = function() return _G.showSmallSafe end, text = "Small Safe", color = Color3.fromRGB(255, 255, 0) },
    { key = "MediumSafe", toggle = function() return _G.showMediumSafe end, text = "Medium Safe", color = Color3.fromRGB(255, 128, 0) },
}

local espItems = {}

-- Main update loop using RenderStepped
RunService.RenderStepped:Connect(function()
    for _, object in ipairs(BredMakurz:GetChildren()) do
        local mainPart = object:FindFirstChild("MainPart")
        if mainPart then
            for _, config in ipairs(ESP_CONFIG) do
                if string.find(object.Name, config.key) then
                    updateObject(mainPart, espItems, config.toggle(), config.text, config.color)
                end
            end
        end
    end

    if _G.autoLockPick then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local lockpickGui = playerGui and playerGui:FindFirstChild("LockpickGUI")
        if lockpickGui then
            local frames = {
                lockpickGui.MF.LP_Frame.Frames.B1.Bar.Selection,
                lockpickGui.MF.LP_Frame.Frames.B2.Bar.Selection,
                lockpickGui.MF.LP_Frame.Frames.B3.Bar.Selection,
            }
            checkLockpick(unpack(frames))
        end
    end
end)
