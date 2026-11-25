-- Anime Nexus RNG Hub v1.1 (Auto Wiki Codes + Fast Roll + Collectibles)
-- Game: [UPD] Anime Nexus RNG : EMINENCE IN SHADOW (PlaceId: 85829558919037)
-- Clean Dark Slate UI (SourceSansSemibold, Border Stroke, Draggable)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
local Remotes = RS:WaitForChild("Remotes")
local RequestRoll = Remotes:WaitForChild("RequestRoll")
local Wheelspinner = Remotes:WaitForChild("Wheelspinner")
local ClaimIndexReward = Remotes:WaitForChild("ClaimIndexReward")
local Battlepass = Remotes:WaitForChild("Battlepass")
local Questline = Remotes:WaitForChild("Questline")
local RedeemCode = Remotes:FindFirstChild("RedeemCode", true)
local NWWikiCodes = Remotes:FindFirstChild("NWWikiCodes", true)
local Daily = Remotes:FindFirstChild("Daily", true)
local GroupRewards = Remotes:FindFirstChild("GroupRewards", true)
local NWLevelRewards = Remotes:FindFirstChild("NWLevelRewards", true)
local ClaimQuest = Remotes:FindFirstChild("ClaimQuest", true)
local ClaimMilestone = Remotes:FindFirstChild("ClaimMilestone", true)
local ClaimMainMilestone = Remotes:FindFirstChild("ClaimMainMilestone", true)
local ClaimAFKMilestone = Remotes:FindFirstChild("ClaimAFKMilestone", true)

-- Cleanup old instance
local oldGui = CoreGui:FindFirstChild("AnimeNexusRngHubGui")
if oldGui then oldGui:Destroy() end

local env = getgenv and getgenv() or _G
if env.NexusRngState then
    env.NexusRngState.alive = false
end

local state = {
    alive = true,
    autoRoll = false,
    autoSpin = false,
    autoClaim = false,
    antiAfk = true,
    instantPrompt = true,
    speedBoost = true,
    highJump = false,
    infJump = false,
}
env.NexusRngState = state

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
gui.Name = "AnimeNexusRngHubGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mf = Instance.new("Frame")
mf.Name = "MainFrame"
mf.Size = UDim2.new(0, 325, 0, 375)
mf.Position = UDim2.new(1, -345, 1, -395)
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
titleBar.Text = "  🌑 Anime Nexus RNG Hub v1.1"
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

-- Tabs Bar
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
    tb.Size = UDim2.new(0.5, -3, 1, 0)
    tb.BackgroundColor3 = (idx == 1) and Color3.fromRGB(58, 84, 128) or Color3.fromRGB(36, 40, 52)
    tb.BorderSizePixel = 0
    tb.Font = Enum.Font.SourceSansSemibold
    tb.Text = text
    tb.TextColor3 = Color3.fromRGB(224, 230, 240)
    tb.TextSize = 13
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
    b.TextSize = 14
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
local pRoll = createTab(1, "🎲 สุ่ม & เก็บของลับ")
local pUtil = createTab(2, "⚡ ตัวละคร & AFK")

-- Tab 1: RNG & Collectibles
addToggle(pRoll, "Fast Auto Roll (สุ่มเร็วข้ามฉาก)", "autoRoll")
addToggle(pRoll, "Auto Wheel Spin (หมุนวงล้อ)", "autoSpin")
addToggle(pRoll, "Auto Claim (Index/BP/Quest)", "autoClaim")

addButton(pRoll, "🗺️ กวาดเก็บของลับทั้งแมพทันที", Color3.fromRGB(48, 64, 92), function()
    task.spawn(function()
        local hrp = getHRP()
        if not hrp then return end
        local origCF = hrp.CFrame
        local folders = {"NW_TYBWFinds", "NW_EnkiduTablets", "NW_TrickOrTreat", "NW_IchigoEchoes", "NW_BangNotes"}
        local count = 0
        for _, fn in ipairs(folders) do
            local f = workspace:FindFirstChild(fn)
            if f then
                for _, item in ipairs(f:GetChildren()) do
                    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.15)
                        for _, d in ipairs(item:GetDescendants()) do
                            if d:IsA("ProximityPrompt") and d.Enabled and fireproximityprompt then
                                d.HoldDuration = 0
                                pcall(function() fireproximityprompt(d) end)
                            elseif d:IsA("ClickDetector") and fireclickdetector then
                                pcall(function() fireclickdetector(d) end)
                            elseif d:IsA("TouchTransmitter") and firetouchinterest and d.Parent:IsA("BasePart") then
                                pcall(function()
                                    firetouchinterest(hrp, d.Parent, 0)
                                    firetouchinterest(hrp, d.Parent, 1)
                                end)
                            end
                        end
                        count += 1
                    end
                end
            end
        end
        hrp.CFrame = origCF
        notify("Anime Nexus RNG", "กวาดจุดของลับครบ " .. count .. " จุดแล้ว!")
    end)
end)

addButton(pRoll, "🎟️ เติมโค้ดฟรีทั้งหมดจากเซิร์ฟเวอร์ (Auto Wiki Codes)", Color3.fromRGB(72, 54, 112), function()
    task.spawn(function()
        if not NWWikiCodes or not RedeemCode then
            notify("Wiki Codes", "ไม่พบ Remote โค้ดในเซิร์ฟเวอร์นี้")
            return
        end
        local ok, res = pcall(function() return NWWikiCodes:InvokeServer() end)
        if ok and type(res) == "table" and type(res.codes) == "table" then
            local usedCount = 0
            for _, c in ipairs(res.codes) do
                if not c.used and c.code then
                    pcall(function() RedeemCode:FireServer(c.code) end)
                    usedCount += 1
                    task.wait(0.8)
                end
            end
            notify("Wiki Codes", "เติมโค้ดใหม่ทั้งหมด " .. usedCount .. " โค้ดแล้ว!")
        else
            notify("Wiki Codes", "ดึงรายการโค้ดไม่สำเร็จ")
        end
    end)
end)

addButton(pRoll, "🎁 กดรับรางวัล Index/BP/Quest/Daily ทันที", Color3.fromRGB(44, 82, 58), function()
    pcall(function() ClaimIndexReward:FireServer() end)
    pcall(function() Battlepass:FireServer("claimAll") end)
    pcall(function() Questline:FireServer("claimAll") end)
    if Daily then pcall(function() Daily:FireServer() end) end
    if GroupRewards then pcall(function() GroupRewards:FireServer() end) end
    if NWLevelRewards then pcall(function() NWLevelRewards:FireServer() end) end
    if ClaimQuest then pcall(function() ClaimQuest:FireServer() end) end
    if ClaimMilestone then pcall(function() ClaimMilestone:FireServer() end) end
    if ClaimMainMilestone then pcall(function() ClaimMainMilestone:FireServer() end) end
    if ClaimAFKMilestone then pcall(function() ClaimAFKMilestone:FireServer() end) end
    notify("Anime Nexus RNG", "ส่งคำสั่งรับรางวัลทั้งหมดแล้ว!")
end)

-- Tab 2: Movement & Anti-AFK
addToggle(pUtil, "Anti-AFK (กันหลุด 20 นาที)", "antiAfk")
addToggle(pUtil, "Instant Prompts (กด E ทันที)", "instantPrompt")
addToggle(pUtil, "Speed Boost (วิ่งไว 45)", "speedBoost")
addToggle(pUtil, "High Jump (กระโดดสูง 85)", "highJump")
addToggle(pUtil, "Infinite Jump (กระโดดกลางอากาศ)", "infJump")

addButton(pUtil, "🏠 วาร์ปกลับ Spawn", Color3.fromRGB(48, 64, 92), function()
    local sp = workspace:FindFirstChildOfClass("SpawnLocation")
    local hrp = getHRP()
    if sp and hrp then
        hrp.CFrame = sp.CFrame + Vector3.new(0, 4, 0)
    end
end)

-- Anti-AFK Listener
lp.Idled:Connect(function()
    if state.alive and state.antiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Instant Prompts & Infinite Jump
ProximityPromptService.PromptShown:Connect(function(prompt)
    if state.alive and state.instantPrompt then
        prompt.HoldDuration = 0
    end
end)

UserInputService.JumpRequest:Connect(function()
    if state.alive and state.infJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Movement Heartbeat
RunService.Heartbeat:Connect(function()
    if not state.alive then return end
    local hum = getHumanoid()
    if hum then
        if state.speedBoost and hum.WalkSpeed < 40 then hum.WalkSpeed = 45 end
        if state.highJump then
            hum.UseJumpPower = true
            hum.JumpPower = 85
        end
    end
end)

-- Fast Auto Roll Loop
local reqCounter = 1
task.spawn(function()
    while state.alive do
        if state.autoRoll then
            reqCounter += 1
            pcall(function()
                RequestRoll:FireServer({
                    reqId = reqCounter,
                    count = 1,
                    auto = true,
                    fast = true
                })
            end)
            task.wait(0.35)
        else
            task.wait(0.3)
        end
    end
end)

-- Wheel Spin & Auto Claim Loop
task.spawn(function()
    while state.alive do
        task.wait(2.0)
        if state.autoSpin then
            pcall(function() Wheelspinner:FireServer() end)
        end
        if state.autoClaim then
            pcall(function() ClaimIndexReward:FireServer() end)
            pcall(function() Battlepass:FireServer("claimAll") end)
            pcall(function() Questline:FireServer("claimAll") end)
        end
    end
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        mf.Visible = not mf.Visible
    end
end)

notify("Anime Nexus RNG Hub v1.1", "อัปเกรดแล้ว! เพิ่มระบบเติมโค้ดอัตโนมัติ + รับของฟรีครบชุด")
