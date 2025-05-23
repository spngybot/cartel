--[[
TODO:
-- Enhancements
    - Optimize loops
    - Calculate FOV Circle [Field Of View jargi]
    - Add font selection
    - Chams glow options

-- New Features
    - Speed hack
    - Auto-fire toggle [?]
    - Offscreen indicators
    - Enhance viewangle
    - Chams glow effect
    - Noclip mode [?]
    - Teleport feature [?]
]]--

--[[
FIXME:
    - Glow Chams stops working after a while
    - Optimization suht sitt
]]--


-----------------------------------------------------
-- Services and Global Variables
-----------------------------------------------------
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local originalAmbient = Lighting.Ambient

local v2 = Vector2.new
local floor = math.floor
local format = string.format
local WorldToScreenPoint = Camera.WorldToScreenPoint
local GetMouseLocation = UserInputService.GetMouseLocation

local Melee = {}
local meleeConn = nil

local originalScales = {}

local fconnection
local fspeed = 50

local possibleHitParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}

-----------------------------------------------------
-- UI Setup
-----------------------------------------------------
local uiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/spngybot/cartel/refs/heads/main/libs/ui"))()
local flags = uiLibrary.flags
local config_flags = uiLibrary.config_flags

local W = uiLibrary:window({ name = "cartel", size = UDim2.fromOffset(500, 650) })

-- Tabs
local legitTab = W:tab({name = "Legit"})
local visualTab = W:tab({name = "Visual"})
local miscTab = W:tab({name = "Misc"})
local configTab = W:tab({name = "Config"})

-- Aimbot Section
local aimbotSection = legitTab:section({name = "Aim Assist", side = "left"})
aimbotSection:toggle({name="Enabled", flag="aimEnabled", default=false})
aimbotSection:dropdown({name="Aim Key", flag="aimKey", items={"Mouse1", "Mouse2", "Always"}, default="Mouse2"})
aimbotSection:dropdown({name="Target Priority (-)", flag="aimPriority", items={"Distance", "Health", "Mouse"}, default="Mouse"})
aimbotSection:toggle({name="Sticky Aim", flag="aimSticky", default=false})
aimbotSection:toggle({name="Wall Check",flag="aimWallcheck", default=false})
aimbotSection:toggle({name="Prediction", flag="aimPrediction", default=false})
aimbotSection:slider({name="Prediction Offset",flag="aimPredOffset", min=0, max=100, default=50})
aimbotSection:toggle({name="Show FOV", flag="showAimFov", default=false})
aimbotSection:colorpicker({object="Show FOV", flag="aimFovColor", color=Color3.fromRGB(255,255,255)})
aimbotSection:slider({name="FOV Size", flag="aimFov", min=10, max=500, default=100})
aimbotSection:slider({name="Smoothing", flag="aimSmoothness", min=0, max=20, default=5})
aimbotSection:dropdown({name="Aim Part", flag="aimPart", items={"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}})

-- Silent Aim Section
local silentAimSection = legitTab:section({name = "Silent aim", side = "right"})
silentAimSection:toggle({name="Enable Silent Aim", flag="silentEnabled", default=false})
silentAimSection:dropdown({name="Target Priority (-)", flag="aimPriority", items={"Distance", "Health", "Mouse"}, default="Mouse"})
silentAimSection:toggle({name="Wall Check", flag="silentWallcheck", default=false})
silentAimSection:toggle({name="Show FOV", flag="silentShowFov", default=false})
silentAimSection:colorpicker({object="Show FOV", flag="silentFovColor", color=Color3.fromRGB(255,255,255)})
silentAimSection:slider({name="FOV", flag="silentFov", min=10, max=500, default=100})
silentAimSection:slider({name="Hitchance", flag="silentHitchance", min=0, max=100, default=100})
silentAimSection:slider({name="ADS Hitchance", flag="silentADSHitchance", min=0, max=100, default=100})
silentAimSection:slider({name="In Air Hitchance", flag="silentInAirHitchance", min=0, max=100, default=100})
silentAimSection:dropdown({name="Hitbox", flag="silentHitbox", items={"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart", "Random"}})

-- Melee Aura Section
local meleeAuraSection = legitTab:section({name = "Melee aura", side = "right"})
meleeAuraSection:toggle({name="Enabled", flag="meleeEnabled", default=false, callback=function(bool) 
    if bool then
        if not meleeConn then
            meleeConn = Melee:startAttackLoop()
        end
    else
        if meleeConn then
            meleeConn:Disconnect()
            meleeConn = nil
        end
    end
end})
meleeAuraSection:keybind({object="Enabled", flag="meleeKeybind", callback=function(bool) 
    config_flags["meleeEnabled"](bool) 
    if bool then
        if not meleeConn then
            meleeConn = Melee:startAttackLoop()
        end
    else
        if meleeConn then
            meleeConn:Disconnect()
            meleeConn = nil
        end
    end
    uiLibrary:notification({text="Melee Aura is set to: ".. tostring(bool)}) 
end})
meleeAuraSection:slider({name="Reach", flag="meleeReach", min=1, max=20, default=10})
meleeAuraSection:slider({name="Hitchance", flag="meleeHitchance", min=0, max=100, default=100})
meleeAuraSection:dropdown({name="Hitbox", flag="meleeHitbox", items={"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart", "Random"}})

-- ESP Section
local espSection = visualTab:section({name = "Players", side = "left"})
espSection:toggle({name="Enabled", flag="espEnabled", default=false})
espSection:toggle({name="Bounding Box", flag="espBox", default=false})
espSection:colorpicker({object="Bounding Box", flag="boxColor", color=Color3.fromRGB(255,255,255)})
espSection:toggle({name="Corner Box", flag="espCornerBox", default=false})
espSection:toggle({name="Name", flag="espName", default=false})
espSection:colorpicker({object="Name", flag="nameColor", color=Color3.fromRGB(255,255,255)})
espSection:toggle({name="Distance", flag="espDistance", default=false})
espSection:colorpicker({object="Distance", flag="distanceColor", color=Color3.fromRGB(255,255,255)})
espSection:toggle({name="Weapon", flag="espWeapon", default=false})
espSection:colorpicker({object="Weapon", flag="weaponColor", color=Color3.fromRGB(255,255,255)})
espSection:toggle({name="Healthbar", flag="espHealthbar", default=false})
espSection:colorpicker({object="Healthbar", flag="healthbarColor", color=Color3.fromRGB(0,255,0)})
espSection:slider({name="Healthbar Width", flag="healthbarWidth", min=0,max=5,default=1})
espSection:toggle({name="Healthtext", flag="espHealthtext", default=false})
espSection:toggle({name="Tracers", flag="espTracers", default=false})
espSection:colorpicker({object="Tracers", flag="tracerColor", color=Color3.fromRGB(255,255,255)})
espSection:dropdown({name="Tracer", flag="tracerType", items={"Cursor", "Bottom", "Top"}, default="Cursor"})
espSection:toggle({name="Viewangle (-)", flag="espViewangle", default=false})
espSection:slider({name="Viewangle Length (-)", flag="viewangleLength", min=1, max=20, default=5})
espSection:toggle({name="Skeleton", flag="espSkeleton", default=false})
espSection:toggle({name="Chams", flag="espChams", default=false})
espSection:colorpicker({object="Chams", flag="chamsColor", color=Color3.fromRGB(255,255,255)})
espSection:toggle({name="Visible Check", flag="chamsVisible", default=false})
espSection:slider({name="Chams Opacity (-)", flag="chamsOpacity", min=1, max=100, default=50})
espSection:slider({name="Font Size", flag="fontSize", min=5, max=25, default=11})
espSection:slider({name="Max Distance", flag="espMaxDistance", min=20, max=1000, default=200})

-- World Section
local worldSection = visualTab:section({name = "World", side = "right"})
worldSection:toggle({name="Show Broken", flag="showBroken", default=false})
worldSection:toggle({name="Register ESP", flag="objectRegister", default=false})
worldSection:colorpicker({name="Register", flag="registerColor", color=Color3.fromRGB(255, 0, 128)})
worldSection:toggle({name="Safe ESP", flag="objectSafe", default=false})
worldSection:dropdown({name="Safe Rarity", flag="safeDropdown", items={"Small", "Big"}, multi=true})
worldSection:colorpicker({name="Small Safe", flag="smallSafeColor", color=Color3.fromRGB(255, 255, 0)})
worldSection:colorpicker({name="Medium Safe", flag="mediumSafeColor", color=Color3.fromRGB(255, 128, 0)})
worldSection:toggle({name="Scrap ESP", flag="objectScrap", default=false})
worldSection:dropdown({name="Scrap Rarity", flag="scrapDropdown", items={"Common", "Legendary"}, multi=true})
worldSection:toggle({name="Crate ESP", flag="objectCrate", default=false})
worldSection:dropdown({name="Crate Rarity", flag="crateDropdown", items={"Common", "Legendary"}, multi=true})
worldSection:toggle({name="Dealer ESP", flag="objectDealer", default=false})
worldSection:colorpicker({name="Dealer", flag="dealerColor", color=Color3.fromRGB(255, 0, 255)})

-- Camera Section
local cameraSection = miscTab:section({name = "Camera", side = "left"})

local utilitySection = miscTab:section({name = "Utility", side = "left"})
utilitySection:toggle({name="Auto Lockpick", flag="autoLockpick", default=false, callback=function(bool)
    if not bool then
        for frame, originalScale in pairs(originalScales) do
            frame.Parent.UIScale.Scale = originalScale
        end
    end
end})

local fenabled = false
local movementSection = miscTab:section({name = "Movement", side = "left"})
movementSection:keybind({
    name = "Fly",
    flag = "flyEnabled",
    default = false,
    callback = function(bool)
        if bool then
            if fenabled then return end
            fenabled = true
            fconnection = RunService.RenderStepped:Connect(function(dt)
                if not fenabled then return end
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local moveDir = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir += Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir -= Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir -= Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir += Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDir += Vector3.new(0,1,0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDir -= Vector3.new(0,1,0)
                    end
                    if moveDir.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (moveDir.Unit * fspeed * dt)
                    end
                end
            end)
        end
        if not bool then
            if not fenabled then return end
            fenabled = false
            if fconnection then
                fconnection:Disconnect()
                fconnection = nil
            end
        end
    end,
})

local playerSection = miscTab:section({name = "Playerlist", side = "right"})
playerSection:playerlist()

local xSection = configTab:section({name = "x", side = "right"})
xSection:toggle({name = "Watermark", flag = "watermark", default = false, callback = function(bool) W.toggle_watermark(bool) end})
xSection:toggle({name = "keybindlist", flag = "keybindlist", default = false, callback = function(bool) W.toggle_list(bool) end})
xSection:colorpicker({color = Color3.fromHex("#6464FF"), flag = "accent", callback = function(color) uiLibrary:update_theme("accent", color) end})

local configSection = configTab:section({name = "Configuration System", side = "left"})
configSection:keybind({name = "UI Bind", default = Enum.KeyCode.End, callback = W.set_menu_visibility})

uiLibrary.config_holder = configSection:dropdown({name = "Configs", items = {}, flag = "config_name_list"})
configSection:textbox({flag = "config_name_text_box"})
configSection:button({name = "Create", callback = function()
    writefile(uiLibrary.directory .. "/configs/" .. flags["config_name_text_box"] .. ".cfg", uiLibrary:get_config())
    uiLibrary:config_list_update()
    uiLibrary:notificaton({text="Config created: " .. flags["config_name_text_box"]})
end})
configSection:button({name = "Delete", callback = function()
    uiLibrary:panel({
        name = "Are you sure you want to delete " .. flags["config_name_list"] .. " ?",
        options = {"Yes", "No"},
        callback = function(option)
            if option == "Yes" then 
                delfile(uiLibrary.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg")
                uiLibrary:config_list_update()
            end 
        end
    })
end})
configSection:button({name = "Load", callback = function()
    local config_path = uiLibrary.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg"
    if isfile(config_path) then
        uiLibrary:load_config(readfile(config_path))
        uiLibrary:notification({text = "Config loaded: " .. flags["config_name_list"]})
    else
        uiLibrary:notification({text = "Config file does not exist: " .. config_path})
    end
end})
configSection:button({name = "Save", callback = function()
    writefile(uiLibrary.directory .. "/configs/" .. flags["config_name_text_box"] .. ".cfg", uiLibrary:get_config())
    uiLibrary:config_list_update()
    uiLibrary:notification({text="Config saved: " .. flags["config_name_text_box"]})
end})

uiLibrary:config_list_update()

-----------------------------------------------------
-- FOV Drawings
-----------------------------------------------------

local aimFov = Drawing.new("Circle")
aimFov.Visible = flags["showAimFov"]
aimFov.Transparency = 1
aimFov.Color = Color3.new(1,1,1)
aimFov.Thickness = 1
aimFov.Radius = flags["aimFov"]

local silentFov = Drawing.new("Circle")
silentFov.Visible = flags["silentShowFov"]
silentFov.Transparency = 1
silentFov.Color = Color3.new(1,1,1)
silentFov.Thickness = 1
silentFov.Radius = flags["silentFov"]


-----------------------------------------------------
-- Character Cache
-----------------------------------------------------
local characterCache = {}

local function updateCharacterCache(player)
    local char = player.Character
    if char then
        local hrp = char:WaitForChild("HumanoidRootPart")
        local humanoid = char:WaitForChild("Humanoid")
        if hrp and humanoid then
            characterCache[player] = {Character = char, HRP = hrp, Humanoid = humanoid}
        else
            characterCache[player] = nil
            warn("Failed to load character for player:", player.Name)
        end
    else
        characterCache[player] = nil
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            updateCharacterCache(player)
        end)
        player.CharacterRemoving:Connect(function()
            characterCache[player] = nil
        end)
        updateCharacterCache(player)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        updateCharacterCache(player)
        player.CharacterAdded:Connect(function(character)
            updateCharacterCache(player)
        end)
        player.CharacterRemoving:Connect(function()
            characterCache[player] = nil
        end)
    end
end

-----------------------------------------------------
-- Aimbot Module
-----------------------------------------------------
local Aimbot = {}
local currentTarget = nil

function Aimbot:GetClosestTarget()
    if flags["aimSticky"] and currentTarget and currentTarget.Parent then
        return currentTarget
    end
    
    local closestTarget = nil
    local shortestDistance = flags["aimFov"]
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if uiLibrary.get_priority(player) == "Friendly" then
            continue
        end
        if player ~= LocalPlayer then
            local cache = characterCache[player]
            if cache and cache.Humanoid and cache.Humanoid.Health > 15 and not cache.Character:FindFirstChildOfClass("ForceField") then
                local part
                if flags["aimPart"] == "Random" then
                    part = cache.Character:FindFirstChild(possibleHitParts[math.random(#possibleHitParts)])
                else
                    part = cache.Character:FindFirstChild(flags["aimPart"])
                end
                
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            if flags["aimWallcheck"] then
                                local rayOrigin = Camera.CFrame.Position
                                local rayDirection = (part.Position - rayOrigin).Unit * 500
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                                if rayResult and rayResult.Instance:IsDescendantOf(cache.Character) then
                                    shortestDistance = distance
                                    closestTarget = part
                                end
                            else
                                shortestDistance = distance
                                closestTarget = part
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

function Aimbot:AimAt(target)
    if target then
        local targetScreenPos = Camera:WorldToViewportPoint(target.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local moveVector = Vector2.new(targetScreenPos.X, targetScreenPos.Y) - mousePos

        if flags["aimPrediction"] then
            local character = target.Parent
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local targetVelocity = humanoidRootPart.Velocity
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                local travelTime = distance / flags["aimPredOffset"]
                local predictedPosition = target.Position + targetVelocity * travelTime
                targetScreenPos = Camera:WorldToViewportPoint(predictedPosition)
                moveVector = Vector2.new(targetScreenPos.X, targetScreenPos.Y) - mousePos
            end
        end
        
        mousemoverel(moveVector.X / flags["aimSmoothness"], moveVector.Y / flags["aimSmoothness"])
        currentTarget = target
    end
end

function Aimbot:update(dt)
    if flags["aimEnabled"] then
        local keyPressed = false
        if (flags["aimKey"] == "Mouse1" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) or
           (flags["aimKey"] == "Mouse2" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or
           (flags["aimKey"] == "Always") then
            keyPressed = true
        end
        
        if keyPressed then
            currentTarget = self:GetClosestTarget()
            self:AimAt(currentTarget)
        else
            currentTarget = nil
        end
    end
end

-----------------------------------------------------
-- Silent Aim Module
-----------------------------------------------------
local silentAim = {}

local VisualizeEvent = ReplicatedStorage.Events2["Visualize"]
local DamageEvent = ReplicatedStorage.Events["ZFKLF_H"]

function silentAim:getTarget()
    local closestTarget = nil
    local closestCache = nil
    local shortestDistance = flags["silentFov"]
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if uiLibrary.get_priority(player) == "Friendly" then
                continue
            end
            local cache = characterCache[player]
            if cache and cache.Humanoid and cache.Humanoid.Health > 15 and not cache.Character:FindFirstChildOfClass("ForceField") then
                local part
                if flags["silentHitbox"] == "Random" then
                    part = cache.Character:FindFirstChild(possibleHitParts[math.random(#possibleHitParts)])
                else
                    part = cache.Character:FindFirstChild(flags["silentHitbox"])
                end
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if screenDistance < shortestDistance then
                            if flags["silentWallcheck"] then
                                local rayOrigin = Camera.CFrame.Position
                                local rayDirection = (part.Position - rayOrigin).Unit * 500
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                                if rayResult and rayResult.Instance:IsDescendantOf(cache.Character) then
                                    shortestDistance = screenDistance
                                    closestTarget = part
                                    closestCache = cache
                                end
                            else
                                shortestDistance = screenDistance
                                closestTarget = part
                                closestCache = cache
                            end
                        end
                    end
                end
            end
        end
    end

    if closestTarget and closestCache and closestCache.Humanoid then
        local hitChance = flags["silentHitchance"]
        if closestCache.Humanoid:GetState() == Enum.HumanoidStateType.Freefall or closestCache.Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            hitChance = flags["silentInAirHitchance"]
        elseif UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            hitChance = flags["silentADSHitchance"]
        end
        if math.random(1, 100) > hitChance then
            closestTarget = nil
        end
    end

    return closestTarget
end

VisualizeEvent.Event:Connect(function(...)
    local Args = {...}
    
    if not flags["silentEnabled"] then return end

    local ShotCode = Args[2]
    local Gun = Args[4]
    local StartPos = Args[6]
    
    local TargetPart = silentAim:getTarget()

    if TargetPart then
        local HitPos = TargetPart.Position
        local Bullets = {}
        
        local LookVector = CFrame.new(StartPos, HitPos).LookVector

        task.wait(0.1)

        DamageEvent:FireServer(
            "\240\159\141\175",
            Gun,
            ShotCode,
            1,
            TargetPart,
            HitPos,
            LookVector
        )

        Gun.Hitmarker:Fire(TargetPart)
    end
end)

-----------------------------------------------------
-- Melee Aura Module
-----------------------------------------------------

function Melee:Attack(target)
    if uiLibrary.get_priority(Players:GetPlayerFromCharacter(target)) == "Friendly" then
        return
    end
    local remote1 = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("XMHH.2")
    local remote2 = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("XMHH2.2")
    if not (target and target:FindFirstChild("Head")) then return end
    local hitChance = flags["meleeHitchance"] or 100
    local isHit = math.random(1, 100) <= hitChance

    local hitbox
    if flags["meleeHitbox"] == "Random" then
        local hitboxes = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}
        hitbox = target:FindFirstChild(hitboxes[math.random(#hitboxes)])
    else
        hitbox = target:FindFirstChild(flags["meleeHitbox"])
    end

    if not hitbox then return end

    local arg1 = {
        [1] = "🍞",
        [2] = tick(),
        [3] = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool"),
        [4] = "43TRFWX",
        [5] = "Normal",
        [6] = tick(),
        [7] = true
    }
    local result = remote1:InvokeServer(unpack(arg1))
    task.wait(0.5)

    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        local Handle = tool:FindFirstChild("WeaponHandle") or tool:FindFirstChild("Handle") or LocalPlayer.Character:FindFirstChild("Right Arm")
        if Handle then
            local arg2 = {
                [1] = "🍞",
                [2] = tick(),
                [3] = tool,
                [4] = "2389ZFX34",
                [5] = isHit and result or nil,
                [6] = isHit,
                [7] = Handle,
                [8] = hitbox,
                [9] = target,
                [10] = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position,
                [11] = hitbox.Position
            }
            remote2:FireServer(unpack(arg2))
        end
    end
end

function Melee:startAttackLoop()
    return RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local cache = characterCache[player]
                if cache and cache.HRP then
                    local dist = (hrp.Position - cache.HRP.Position).Magnitude
                    if dist < flags["meleeReach"] and cache.Humanoid and cache.Humanoid.Health > 15 and not cache.Character:FindFirstChildOfClass("ForceField") then
                        Melee:Attack(cache.Character)
                    end
                end
            end
        end
    end)
end

-----------------------------------------------------
-- Player ESP Module
-----------------------------------------------------
local ESP = {}
local espItems = {}
local tracers = {}

function ESP:Create(Class, Properties)
    local _Instance = (typeof(Class) == 'string') and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do
        _Instance[Property] = Value
    end
    return _Instance
end

local ScreenGui = ESP:Create("ScreenGui", {
    Parent = CoreGui,
    Name = "ESPHolder",
})

local DupeCheck = function(plr)
    if ScreenGui:FindFirstChild(plr.Name) then
        ScreenGui[plr.Name]:Destroy()
    end
end

function ESP:esp(plr)
    DupeCheck(plr)
    local esp = {
        Name = ESP:Create("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, -11),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.Code,
            TextSize = flags["fontSize"],
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0,0,0),
            RichText = true
        }),
        Distance = ESP:Create("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, 11),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.Code,
            TextSize = flags["fontSize"],
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0,0,0),
            RichText = true
        }),
        Weapon = ESP:Create("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, 31),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.Code,
            TextSize = flags["fontSize"],
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0,0,0),
            RichText = true
        }),
        Box = ESP:Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0
        }),
        Gradient1 = ESP:Create("UIGradient", {
            Parent = Box,
            Enabled = true,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(119,120,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
            }
        }),
        Outline = ESP:Create("UIStroke", {
            Parent = Box,
            Enabled = false,
            Transparency = 0,
            Color = Color3.fromRGB(255,255,255),
            LineJoinMode = Enum.LineJoinMode.Miter
        }),
        Gradient2 = ESP:Create("UIGradient", {
            Parent = Outline,
            Enabled = false,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(119,120,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
            }
        }),
        Healthbar = ESP:Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BackgroundTransparency = 0
        }),
        BehindHealthbar = ESP:Create("Frame", {
            Parent = ScreenGui,
            ZIndex = -1,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 0
        }),
        HealthText = ESP:Create("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, 31),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.Code,
            TextSize = flags["fontSize"],
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0,0,0)
        }),
        Chams = ESP:Create("Highlight", {
            Parent = ScreenGui,
            FillTransparency = 0,
            OutlineTransparency = 0,
            OutlineColor = Color3.fromRGB(119,120,255),
            DepthMode = "AlwaysOnTop"
        }),
        WeaponIcon = ESP:Create("ImageLabel", {
            Parent = ScreenGui,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0,0,0),
            BorderSizePixel = 0,
            Size = UDim2.new(0,40,0,40)
        }),
        Gradient3 = ESP:Create("UIGradient", {
            Parent = WeaponIcon,
            Rotation = -90,
            Enabled = true,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(119,120,255))
            }
        }),
        LeftTop = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        LeftSide = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        RightTop = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        RightSide = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        BottomSide = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        BottomDown = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        BottomRightSide = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        BottomRightDown = ESP:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255,255,255)}),
        Flag1 = ESP:Create("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0,100,0,20),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.Code,
            TextSize = flags["fontSize"],
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0,0,0)
        }),
        Flag2 = ESP:Create("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0,100,0,20),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.Code,
            TextSize = flags["fontSize"],
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0,0,0)
        }),
    }
    espItems[plr] = esp
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        ESP:esp(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    ESP:esp(plr)
end)

-----------------------------------------------------
-- World ESP Module
-----------------------------------------------------
local WorldESP = {}

local worldEspItems = {}
local worldEspCache = {}
local dealerEspCache = {}

function WorldESP:CreateESP(object, text, color)
    local label = ESP:Create("TextLabel", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 100, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = color,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        Text = text,
        Font = Enum.Font.Code,
        TextSize = flags["fontSize"],
        RichText = true
    })
    return label
end

function WorldESP:AddObject(object)
    local mainPart = object:FindFirstChild("MainPart")
    if not mainPart then return end
    
    local esp = {
        Label = nil,
        Object = object,
        MainPart = mainPart,
        Values = object:FindFirstChild("Values")
    }
    
    worldEspItems[object] = esp
    worldEspCache[object] = true
    
    object.AncestryChanged:Connect(function()
        if not object.Parent then
            if worldEspItems[object] and worldEspItems[object].Label then
                worldEspItems[object].Label:Destroy()
            end
            worldEspItems[object] = nil
            worldEspCache[object] = nil
        end
    end)
end

for _, object in ipairs(workspace.Map.BredMakurz:GetChildren()) do
    if object:FindFirstChild("MainPart") then
        WorldESP:AddObject(object)
    end
end

workspace.Map.BredMakurz.ChildAdded:Connect(function(object)
    if object:FindFirstChild("MainPart") then
        WorldESP:AddObject(object)
    end
end)

-----------------------------------------------------
-- Misc
-----------------------------------------------------
function checkLockpick(...)
    local frames = { ... };
    for i,v in pairs(frames) do
        if not originalScales[v] then   
            originalScales[v] = v.Parent.UIScale.Scale
        end
        if not flags["autoLockpick"] then
            v.Parent.UIScale.Scale = 1
        end
        if flags["autoLockpick"] then
            v.Parent.UIScale.Scale = 10
        end
        if (v.AbsolutePosition.Y >= 450 and v.AbsolutePosition.Y <= 550) then
            mouse1click(); task.wait(0.1); mouse1release();
        end
    end
end

-----------------------------------------------------
-- Optimized Main Update Loop for ESP and FOV
-----------------------------------------------------
RunService.RenderStepped:Connect(function(dt)
    local cameraPos = Camera.CFrame.Position
    local mousePos = GetMouseLocation(UserInputService)

    for player, esp in pairs(espItems) do
        local cache = characterCache[player]
        if not (cache and cache.Character and cache.Character.Parent and cache.HRP and cache.Humanoid) then
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Weapon.Visible = false
            esp.Box.Visible = false
            esp.Healthbar.Visible = false
            esp.HealthText.Visible = false
            esp.Chams.Enabled = false
            esp.LeftTop.Visible = false
            esp.LeftSide.Visible = false
            esp.RightTop.Visible = false
            esp.RightSide.Visible = false
            esp.BottomSide.Visible = false
            esp.BottomDown.Visible = false
            esp.BottomRightSide.Visible = false
            esp.BottomRightDown.Visible = false
            esp.Flag1.Visible = false
            esp.Flag2.Visible = false
            continue
        end
        
        local HRP = cache.HRP
        local screenPos, onScreen = WorldToScreenPoint(Camera, HRP.Position)
        local distance = (cameraPos - HRP.Position).Magnitude
        if distance > flags["espMaxDistance"] then
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Weapon.Visible = false
            esp.Box.Visible = false
            esp.Healthbar.Visible = false
            esp.HealthText.Visible = false
            esp.Chams.Enabled = false
            esp.LeftTop.Visible = false
            esp.LeftSide.Visible = false
            esp.RightTop.Visible = false
            esp.RightSide.Visible = false
            esp.BottomSide.Visible = false
            esp.BottomDown.Visible = false
            esp.BottomRightSide.Visible = false
            esp.BottomRightDown.Visible = false
            esp.Flag1.Visible = false
            esp.Flag2.Visible = false
            continue
        end

        if not onScreen then
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Weapon.Visible = false
            esp.Box.Visible = false
            esp.Healthbar.Visible = false
            esp.HealthText.Visible = false
            esp.Chams.Enabled = false
            esp.LeftTop.Visible = false
            esp.LeftSide.Visible = false
            esp.RightTop.Visible = false
            esp.RightSide.Visible = false
            esp.BottomSide.Visible = false
            esp.BottomDown.Visible = false
            esp.BottomRightSide.Visible = false
            esp.BottomRightDown.Visible = false
            esp.Flag1.Visible = false
            esp.Flag2.Visible = false
            continue
        end
        
        local scaleFactor = (HRP.Size.Y * Camera.ViewportSize.Y) / (screenPos.Z * 2)
        local w, h = 3 * scaleFactor, 4.5 * scaleFactor
        
        if flags["espEnabled"] then
            if flags["espName"] then
                esp.Name.Visible = true
                esp.Name.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - h/2 - 9)
                esp.Name.Text = player.Name
                if uiLibrary.get_priority(player) == "Friendly" then
                    esp.Name.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif uiLibrary.get_priority(player) == "Enemy" then
                    esp.Name.TextColor3 = Color3.fromRGB(255, 0, 0)
                else    
                    esp.Name.TextColor3 = flags["nameColor"].Color
                end
            else
                esp.Name.Visible = false
            end
            
            if flags["espDistance"] then
                esp.Distance.Visible = true
                local dist = (Camera.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                esp.Distance.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y + h/2 + 17)
                esp.Distance.Text = format("%dm", floor(dist))
                esp.Distance.TextColor3 = flags["distanceColor"].Color
            else
                esp.Distance.Visible = false
            end
            
            if flags["espWeapon"] then
                esp.Weapon.Visible = true
                esp.Weapon.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y + h/2 + 7)
                local tool = cache.Character:FindFirstChildOfClass("Tool")
                esp.Weapon.Text = tool and tool.Name or "None"
                esp.Weapon.TextColor3 = flags["weaponColor"].Color
            else
                esp.Weapon.Visible = false
            end
            
            if flags["espBox"] then
                esp.Box.Visible = true
                esp.Box.Position = UDim2.new(0, screenPos.X - w/2, 0, screenPos.Y - h/2)
                esp.Box.Size = UDim2.new(0, w, 0, h)
            else
                esp.Box.Visible = false
            end
            
            if flags["espHealthbar"] then
                local humanoid = cache.Humanoid
                if humanoid then
                    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    esp.Healthbar.Visible = true
                    esp.Healthbar.Position = UDim2.new(0, screenPos.X - w/2 - 6, 0, screenPos.Y - h/2 + h * (1 - healthPercent))
                    esp.Healthbar.Size = UDim2.new(0, flags["healthbarWidth"], 0, h * healthPercent)
                    esp.Healthbar.BackgroundColor3 = flags["healthbarColor"].Color
                end
            else
                esp.Healthbar.Visible = false
            end
            
            if flags["espHealthtext"] then
                local humanoid = cache.Humanoid
                if humanoid then
                    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    esp.HealthText.Visible = true
                    esp.HealthText.Position = UDim2.new(0, screenPos.X - w/2 - 20, 0, screenPos.Y - h/2 + h * (1 - healthPercent))
                    esp.HealthText.Text = tostring(floor(healthPercent * 100))
                    local color = healthPercent >= 0.75 and Color3.fromRGB(0,255,0) or healthPercent >= 0.5 and Color3.fromRGB(255,255,0) or healthPercent >= 0.25 and Color3.fromRGB(255,170,0) or Color3.fromRGB(255,0,0)
                    esp.HealthText.TextColor3 = color
                end
            else
                esp.HealthText.Visible = false
            end
            
            esp.Chams.Adornee = cache.Character
            esp.Chams.Enabled = flags["espChams"]
            esp.Chams.FillColor = flags["chamsColor"].Color
            esp.Chams.OutlineColor = flags["chamsColor"].Color
            esp.Chams.DepthMode = flags["chamsVisible"] and "Occluded" or "AlwaysOnTop"
            local opacity = (100- flags["chamsOpacity"]) / 100
            esp.Chams.FillTransparency = opacity
            esp.Chams.OutlineTransparency = opacity
            
            if flags["espCornerBox"] then
                esp.LeftTop.Visible = true
                esp.LeftTop.Position = UDim2.new(0, screenPos.X - w/2, 0, screenPos.Y - h/2)
                esp.LeftTop.Size = UDim2.new(0, w/5, 0, 1)
                
                esp.LeftSide.Visible = true
                esp.LeftSide.Position = UDim2.new(0, screenPos.X - w/2, 0, screenPos.Y - h/2)
                esp.LeftSide.Size = UDim2.new(0, 1, 0, h/5)
                
                esp.BottomSide.Visible = true
                esp.BottomSide.Position = UDim2.new(0, screenPos.X - w/2, 0, screenPos.Y + h/2)
                esp.BottomSide.Size = UDim2.new(0, 1, 0, h/5)
                esp.BottomSide.AnchorPoint = Vector2.new(0,5)
                
                esp.BottomDown.Visible = true
                esp.BottomDown.Position = UDim2.new(0, screenPos.X - w/2, 0, screenPos.Y + h/2)
                esp.BottomDown.Size = UDim2.new(0, w/5, 0, 1)
                esp.BottomDown.AnchorPoint = Vector2.new(0,1)
                
                esp.RightTop.Visible = true
                esp.RightTop.Position = UDim2.new(0, screenPos.X + w/2, 0, screenPos.Y - h/2)
                esp.RightTop.Size = UDim2.new(0, w/5, 0, 1)
                esp.RightTop.AnchorPoint = Vector2.new(1,0)
                
                esp.RightSide.Visible = true
                esp.RightSide.Position = UDim2.new(0, screenPos.X + w/2 - 1, 0, screenPos.Y - h/2)
                esp.RightSide.Size = UDim2.new(0, 1, 0, h/5)
                esp.RightSide.AnchorPoint = Vector2.new(0,0)
                
                esp.BottomRightSide.Visible = true
                esp.BottomRightSide.Position = UDim2.new(0, screenPos.X + w/2, 0, screenPos.Y + h/2)
                esp.BottomRightSide.Size = UDim2.new(0, 1, 0, h/5)
                esp.BottomRightSide.AnchorPoint = Vector2.new(1,1)
                
                esp.BottomRightDown.Visible = true
                esp.BottomRightDown.Position = UDim2.new(0, screenPos.X + w/2, 0, screenPos.Y + h/2)
                esp.BottomRightDown.Size = UDim2.new(0, w/5, 0, 1)
                esp.BottomRightDown.AnchorPoint = Vector2.new(1,1)
            else
                esp.LeftTop.Visible = false
                esp.LeftSide.Visible = false
                esp.RightTop.Visible = false
                esp.RightSide.Visible = false
                esp.BottomSide.Visible = false
                esp.BottomDown.Visible = false
                esp.BottomRightSide.Visible = false
                esp.BottomRightDown.Visible = false
            end
            
            esp.Flag1.Visible = flags["flag1Toggle"] or false
            esp.Flag2.Visible = flags["flag2Toggle"] or false
        else
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Weapon.Visible = false
            esp.Box.Visible = false
            esp.Healthbar.Visible = false
            esp.HealthText.Visible = false
            esp.Chams.Enabled = false
            esp.LeftTop.Visible = false
            esp.LeftSide.Visible = false
            esp.RightTop.Visible = false
            esp.RightSide.Visible = false
            esp.BottomSide.Visible = false
            esp.BottomDown.Visible = false
            esp.BottomRightSide.Visible = false
            esp.BottomRightDown.Visible = false
            esp.Flag1.Visible = false
            esp.Flag2.Visible = false
        end
    end

    for object, esp in pairs(worldEspItems) do
        if not (esp.Object and esp.Object.Parent and esp.MainPart and esp.Values) then
            if esp.Label then
                esp.Label:Destroy()
            end
            worldEspItems[object] = nil
            continue
        end
    
        local name = esp.Object.Name
        local broken = esp.Values:FindFirstChild("Broken") and esp.Values.Broken.Value or false
        local screenPos, onScreen = WorldToScreenPoint(Camera, esp.MainPart.Position + Vector3.new(0, 2, 0))
        local distance = (cameraPos - esp.MainPart.Position).Magnitude
        local shouldShow = false
        local text = broken and "(Broken) " or ""
        local color = Color3.fromRGB(255, 255, 255)
    
        if distance > flags["espMaxDistance"] or not onScreen then
            if esp.Label then
                esp.Label.Visible = false
            end
            continue
        end
    
        if string.find(name, "Register") and flags["objectRegister"] then
            shouldShow = true
            text = text .. "Register"
            color = flags["registerColor"].Color
        elseif string.find(name, "SmallSafe") and flags["objectSafe"] and table.find(flags["safeDropdown"], "Small") then
            shouldShow = true
            text = text .. "Small Safe"
            color = flags["smallSafeColor"].Color
        elseif string.find(name, "MediumSafe") and flags["objectSafe"] and table.find(flags["safeDropdown"], "Big") then
            shouldShow = true
            text = text .. "Medium Safe"
            color = flags["mediumSafeColor"].Color
        elseif string.find(name, "Scrap") and flags["objectScrap"] then
            shouldShow = true
            text = text .. "Scrap"
            color = Color3.fromRGB(0, 255, 0)
        elseif string.find(name, "Crate") and flags["objectCrate"] then
            shouldShow = true
            text = text .. "Crate"
            color = Color3.fromRGB(0, 255, 255)
        elseif name == "Dealer" and flags["objectDealer"] then
            shouldShow = true
            text = text .. "Dealer"
            color = Color3.fromRGB(255, 0, 255)
        end
    
        if shouldShow and (flags["showBroken"] or not broken) then
            if not esp.Label then
                esp.Label = WorldESP:CreateESP(object, text, color)
            end
            esp.Label.Visible = true
            esp.Label.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            esp.Label.Text = text
            esp.Label.TextColor3 = color
            esp.Label.TextSize = flags["fontSize"]
        elseif esp.Label then
            esp.Label.Visible = false
        end
    end

    -- Update FOV circles
    if flags["aimEnabled"] and flags["showAimFov"] then
        aimFov.Position = mousePos
        aimFov.Radius = flags["aimFov"]
        aimFov.Color = flags["aimFovColor"].Color
        aimFov.Transparency = flags["aimFovColor"].Transparency
        aimFov.Visible = true
    else
        aimFov.Visible = false
    end

    if flags["silentEnabled"] and flags["silentShowFov"] then
        silentFov.Position = mousePos
        silentFov.Radius = flags["silentFov"]
        silentFov.Color = flags["silentFovColor"].Color
        silentFov.Transparency = flags["silentFovColor"].Transparency
        silentFov.Visible = true
    else
        silentFov.Visible = false
    end
end)

-----------------------------------------------------
-- Update Aimbot every Heartbeat
-----------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    Aimbot:update(dt)

    if flags["autoLockpick"] then       
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        local lpgui = pgui and pgui:FindFirstChild("LockpickGUI") 
        if lpgui then
            local B1 = lpgui.MF.LP_Frame.Frames.B1.Bar.Selection
            local B2 = lpgui.MF.LP_Frame.Frames.B2.Bar.Selection
            local B3 = lpgui.MF.LP_Frame.Frames.B3.Bar.Selection
            
            checkLockpick(B1, B2, B3)
        end
    end
end)
