-- Dragon Adventures Hub v1.0 (Ultimate Dragon Master Edition)
-- Game: [GUILD WARS] Dragon Adventures 🐉 (PlaceId: 3475397644)
-- Clean Dark Slate UI (SourceSansSemibold, Border Stroke, Draggable)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local parentGui = lp:WaitForChild("PlayerGui")

-- Sonar Services & Remotes
local Sonar = require(RS:WaitForChild("Sonar"))
local RemoteUtils = Sonar("RemoteUtils")

local SetCollectEggRemote = RemoteUtils.GetRemoteFunction("SetCollectEggRemote")
local CollectEggRemote = RemoteUtils.GetRemoteFunction("CollectEggRemote")
local UnlockTreasureChestRemote = RemoteUtils.GetRemoteFunction("UnlockTreasureChestRemote")
local EggNestClass = require(RS:WaitForChild("_replicationFolder"):WaitForChild("EggNestClass"))

-- Cleanup old instance
local oldGui = parentGui:FindFirstChild("DragonAdventuresHubGui")
if oldGui then oldGui:Destroy() end

local env = getgenv and getgenv() or _G
if env.DragonHubState then
    env.DragonHubState.alive = false
end

local state = {
    alive = true,
    autoEggs = false,
    autoChests = false,
    autoMobs = false,
    speedBoost = true,
    noclip = false,
    fly = false,
    infJump = false,
    flySpeed = 60,
    walkSpeed = 45,
}
env.DragonHubState = state

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
    end)
end

local function getHRP()
    local char = lp.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = lp.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "DragonAdventuresHubGui"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local mf = Instance.new("Frame")
mf.Name = "MainFrame"
mf.Size = UDim2.new(0, 340, 0, 440)
mf.Position = UDim2.new(1, -360, 1, -460)
mf.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
mf.BorderSizePixel = 0
mf.Active = true
mf.Draggable = true
mf.Parent = gui

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 10)
mfCorner.Parent = mf

local mfStroke = Instance.new("UIStroke")
mfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mfStroke.Color = Color3.fromRGB(60, 68, 88)
mfStroke.Thickness = 1.2
mfStroke.Parent = mf

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 30, 44)
titleBar.BorderSizePixel = 0
titleBar.Font = Enum.Font.SourceSansBold
titleBar.Text = "  🐉 Dragon Adventures Hub v1.0"
titleBar.TextColor3 = Color3.fromRGB(215, 224, 238)
titleBar.TextSize = 15
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mf

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(145, 52, 56)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(235, 240, 248)
closeBtn.TextSize = 14
closeBtn.Parent = titleBar
local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
    state.alive = false
    gui:Destroy()
end)

-- Tabs Bar (3 Tabs)
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 30)
tabBar.Position = UDim2.new(0, 8, 0, 40)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mf

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

local pages = {}
local tabButtons = {}

local function createTab(idx, text)
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0.333, -4, 1, 0)
    tb.BackgroundColor3 = (idx == 1) and Color3.fromRGB(58, 84, 128) or Color3.fromRGB(36, 40, 52)
    tb.BorderSizePixel = 0
    tb.Font = Enum.Font.SourceSansSemibold
    tb.Text = text
    tb.TextColor3 = Color3.fromRGB(224, 230, 240)
    tb.TextSize = 12
    tb.Parent = tabBar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = tb

    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, -16, 1, -84)
    sf.Position = UDim2.new(0, 8, 0, 76)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Visible = (idx == 1)
    sf.Parent = mf

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = sf

    pages[idx] = sf
    tabButtons[idx] = tb

    tb.MouseButton1Click:Connect(function()
        for i, p in ipairs(pages) do
            p.Visible = (i == idx)
            tabButtons[i].BackgroundColor3 = (i == idx) and Color3.fromRGB(58, 84, 128) or Color3.fromRGB(36, 40, 52)
        end
    end)
    return sf
end

local orderCounter = 0
local function addButton(parent, text, color, callback)
    orderCounter += 1
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -6, 0, 32)
    b.BackgroundColor3 = color or Color3.fromRGB(36, 40, 52)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.SourceSansSemibold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(224, 230, 240)
    b.TextSize = 13
    b.LayoutOrder = orderCounter
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.fromRGB(68, 76, 98)
    s.Transparency = 0.45
    s.Thickness = 1
    s.Parent = b

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
    return b
end

local function addToggle(parent, label, key)
    local function fmt()
        return (state[key] and "🟢 " or "🔴 ") .. label .. " : " .. (state[key] and "ON" or "OFF")
    end
    local function col()
        return state[key] and Color3.fromRGB(36, 94, 62) or Color3.fromRGB(36, 40, 52)
    end
    return addButton(parent, fmt(), col(), function(b)
        state[key] = not state[key]
        b.Text = fmt()
        b.BackgroundColor3 = col()
    end)
end

-- Tabs
local pFarm = createTab(1, "🥚 ไข่ & สมบัติ")
local pCombat = createTab(2, "⚔️ มอนสเตอร์")
local pMove = createTab(3, "🌀 บิน/วาร์ป")

-- ==================== TAB 1: EGGS & CHESTS ====================
addToggle(pFarm, "Auto Collect Eggs (ข้ามมินิเกมขุดดิน)", "autoEggs")
addToggle(pFarm, "Auto Open Chests (เปิดกล่องสมบัติ)", "autoChests")

addButton(pFarm, "⚡ กวาดเก็บไข่ทั้งหมดรอบแมพทันที", Color3.fromRGB(44, 82, 58), function()
    local hrp = getHRP()
    if not hrp then return end
    local origCF = hrp.CFrame
    local nests = EggNestClass.GetAll()
    local collected = 0

    for _, nest in pairs(nests) do
        if not nest.Harvested and nest.NestIndex then
            local pos = nest.EggPosition or (nest.CFrame and nest.CFrame.Position)
            if pos then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.3)
                pcall(function() SetCollectEggRemote:InvokeServer(nest.NestIndex) end)
                task.wait(0.4)
                pcall(function() CollectEggRemote:InvokeServer(nest.NestIndex) end)
                collected += 1
                task.wait(0.2)
            end
        end
    end
    hrp.CFrame = origCF
    notify("Egg Sweeper", "เก็บไข่เสร็จสิ้น: " .. tostring(collected) .. " รัง!")
end)

addButton(pFarm, "💎 วาร์ปเปิดกล่องสมบัติทั้งหมดทันที", Color3.fromRGB(48, 64, 92), function()
    local hrp = getHRP()
    local treasureFolder = workspace:FindFirstChild("Interactions") and workspace.Interactions:FindFirstChild("Nodes") and workspace.Interactions.Nodes:FindFirstChild("Treasure")
    if not hrp or not treasureFolder then return end

    local origCF = hrp.CFrame
    local opened = 0

    for _, chest in ipairs(treasureFolder:GetChildren()) do
        if chest:IsA("BasePart") then
            hrp.CFrame = chest.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
            pcall(function() UnlockTreasureChestRemote:InvokeServer(chest) end)
            opened += 1
            task.wait(0.2)
        end
    end
    hrp.CFrame = origCF
    notify("Chest Sweeper", "เปิดกล่องสมบัติเสร็จสิ้น: " .. tostring(opened) .. " กล่อง!")
end)

-- ==================== TAB 2: COMBAT & MOBS ====================
addToggle(pCombat, "Auto Farm Mobs (ลอยตัวพ่นไฟฟาร์ม)", "autoMobs")

addButton(pCombat, "🔥 พ่นไฟมังกรทันที (Dragon Breath)", Color3.fromRGB(145, 52, 56), function()
    local dragon = lp.Character and lp.Character:FindFirstChild("Dragon")
    local remotes = dragon and dragon:FindFirstChild("RemotesFolder")
    local breathRemote = remotes and remotes:FindFirstChild("BreathFireRemote")
    if breathRemote then
        breathRemote:FireServer(true)
        task.wait(1.5)
        breathRemote:FireServer(false)
        notify("Dragon Breath", "พ่นไฟโจมตีแล้ว!")
    else
        notify("Dragon Breath", "ไม่พบมังกรที่ขี่อยู่ กรุณาเรียกมังกรก่อนครับ")
    end
end)

-- ==================== TAB 3: MOVEMENT & WARPS ====================
addToggle(pMove, "Fly Hack (บินอิสระ WASD/Space/Shift)", "fly")
addToggle(pMove, "Noclip (เดินทะลุกำแพง/ภูเขา)", "noclip")
addToggle(pMove, "Speed Boost (วิ่งไว 45)", "speedBoost")
addToggle(pMove, "Infinite Jump (กระโดดกลางอากาศ)", "infJump")

addButton(pMove, "🏠 วาร์ปไป Origins World (เมืองหลัก)", Color3.fromRGB(36, 40, 52), function()
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(1860, 545, 1120) end
end)

addButton(pMove, "❄️ วาร์ปไป Tundra World (ทุ่งหิมะ)", Color3.fromRGB(36, 40, 52), function()
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(2470, 580, 1530) end
end)

-- 1. Auto Collect Eggs Loop
task.spawn(function()
    while state.alive do
        task.wait(2.5)
        if state.autoEggs then
            local hrp = getHRP()
            if hrp then
                local nests = EggNestClass.GetAll()
                for _, nest in pairs(nests) do
                    if not state.autoEggs or not state.alive then break end
                    if not nest.Harvested and nest.NestIndex then
                        local pos = nest.EggPosition or (nest.CFrame and nest.CFrame.Position)
                        if pos then
                            local origCF = hrp.CFrame
                            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                            task.wait(0.3)
                            pcall(function() SetCollectEggRemote:InvokeServer(nest.NestIndex) end)
                            task.wait(0.4)
                            pcall(function() CollectEggRemote:InvokeServer(nest.NestIndex) end)
                            task.wait(0.2)
                            hrp.CFrame = origCF
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

-- 2. Auto Unlock Treasure Chests Loop
task.spawn(function()
    while state.alive do
        task.wait(5.0)
        if state.autoChests then
            local hrp = getHRP()
            local treasureFolder = workspace:FindFirstChild("Interactions") and workspace.Interactions:FindFirstChild("Nodes") and workspace.Interactions.Nodes:FindFirstChild("Treasure")
            if hrp and treasureFolder then
                for _, chest in ipairs(treasureFolder:GetChildren()) do
                    if not state.autoChests or not state.alive then break end
                    if chest:IsA("BasePart") then
                        local origCF = hrp.CFrame
                        hrp.CFrame = chest.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.3)
                        pcall(function() UnlockTreasureChestRemote:InvokeServer(chest) end)
                        task.wait(0.2)
                        hrp.CFrame = origCF
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- 3. Auto Mob Farm Loop
task.spawn(function()
    while state.alive do
        task.wait(0.8)
        if state.autoMobs then
            local hrp = getHRP()
            local mobFolder = workspace:FindFirstChild("MobFolder")
            if hrp and mobFolder then
                local targetMob = nil
                local minDist = math.huge

                for _, mob in ipairs(mobFolder:GetChildren()) do
                    if mob:IsA("Model") and mob.PrimaryPart then
                        local dist = (mob.PrimaryPart.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            targetMob = mob
                        end
                    end
                end

                if targetMob and targetMob.PrimaryPart then
                    hrp.CFrame = targetMob.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
                    local dragon = lp.Character and lp.Character:FindFirstChild("Dragon")
                    local remotes = dragon and dragon:FindFirstChild("RemotesFolder")
                    local breathRemote = remotes and remotes:FindFirstChild("BreathFireRemote")
                    if breathRemote then
                        breathRemote:FireServer(true)
                    end
                end
            end
        end
    end
end)

-- 4. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if state.alive and state.infJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 5. Noclip Loop
RunService.Stepped:Connect(function()
    if state.alive and state.noclip and lp.Character then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 6. Movement & Speed Loop
RunService.Heartbeat:Connect(function()
    if not state.alive then return end
    local hum = getHumanoid()
    if hum and state.speedBoost and hum.WalkSpeed < 40 then
        hum.WalkSpeed = state.walkSpeed
    end
end)

-- 7. Fly Hack System (BodyVelocity + BodyGyro)
local bv, bg
local flying = false

local function startFlying()
    local hrp = getHRP()
    if not hrp then return end
    flying = true

    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.CFrame = hrp.CFrame
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    bg.Parent = hrp

    task.spawn(function()
        while state.alive and state.fly and flying do
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                dir = dir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                dir = dir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                dir = dir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                dir = dir + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                dir = dir - Vector3.new(0, 1, 0)
            end

            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * state.flySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = cam.CFrame
            task.wait()
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        flying = false
    end)
end

local function stopFlying()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

task.spawn(function()
    while state.alive do
        task.wait(0.2)
        if state.fly and not flying then
            startFlying()
        elseif not state.fly and flying then
            stopFlying()
        end
    end
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        mf.Visible = not mf.Visible
    end
end)

notify("Dragon Adventures Hub", "โหลดสำเร็จแล้ว! กด RightShift เพื่อซ่อน/แสดง")