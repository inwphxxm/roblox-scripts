-- Pet Hunt Party Hub v1.0 (All-in-One)
-- Game: [WORLD 2] Pet Hunt Party RPG (PlaceId: 88452215181406)
-- Clean UI (SourceSansSemibold, no neon Contextual stroke)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local Remotes = RS:WaitForChild("Remotes")
local SetTarget = Remotes:WaitForChild("SetTarget")
local UseSkill = Remotes:WaitForChild("UseSkill")
local Warp = Remotes:WaitForChild("Warp")
local Home = Remotes:WaitForChild("Home")
local Revive = Remotes:WaitForChild("Revive")
local Loot = Remotes:WaitForChild("Loot")
local Mail = Remotes:WaitForChild("Mail")
local MacroCheck = Remotes:WaitForChild("MacroCheck")

-- Cleanup previous instance
local oldGui = CoreGui:FindFirstChild("PetHuntPartyHubGui")
if oldGui then oldGui:Destroy() end

local env = getgenv and getgenv() or _G
if env.PetHuntHubState then
    env.PetHuntHubState.alive = false
end

local state = {
    alive = true,
    autoTarget = true,
    autoFarm = false,
    snipeBoss = false,
    autoSkill = true,
    autoLoot = true,
    esp = false,
    autoRevive = true,
    macroAlert = true,
    speedBoost = false,
}
env.PetHuntHubState = state

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 })
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

local function getMobPart(mob)
    return mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChildWhichIsA("BasePart")
end

local function getSkillBar()
    local raw = lp:GetAttribute("SkillBar")
    if type(raw) == "string" and raw ~= "" then
        local ok, arr = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and type(arr) == "table" then
            local skills = {}
            for _, s in ipairs(arr) do
                if type(s) == "string" and s ~= "" then
                    table.insert(skills, s)
                end
            end
            return skills
        end
    end
    return {}
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PetHuntPartyHubGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mf = Instance.new("Frame")
mf.Name = "MainFrame"
mf.Size = UDim2.new(0, 325, 0, 380)
mf.Position = UDim2.new(1, -345, 1, -400)
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
titleBar.Text = "  🐾 Pet Hunt Party Hub v1.0"
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
    tb.Size = UDim2.new(0.333, -4, 1, 0)
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
local pFarm = createTab(1, "⚔️ ฟาร์ม/ต่อสู้")
local pUtil = createTab(2, "🛡️ ระบบ/ของฟรี")
local pWarp = createTab(3, "🌀 วาร์ปโซน")

-- Tab 1: Combat / Farm
addToggle(pFarm, "Auto Target (ล็อกเป้ามอนใกล้)", "autoTarget")
addToggle(pFarm, "Auto Farm All (วาร์ปไล่ตี)", "autoFarm")
addToggle(pFarm, "Snipe Boss Only (ล่าเฉพาะบอส)", "snipeBoss")
addToggle(pFarm, "Auto Skill (วนกดสกิลออโต้)", "autoSkill")
addToggle(pFarm, "Auto Loot (เก็บของดรอป)", "autoLoot")
addToggle(pFarm, "Monster / Boss ESP", "esp")

-- Tab 2: Utility / Freebies
addToggle(pUtil, "MacroCheck Alert (เตือนจับบอท)", "macroAlert")
addToggle(pUtil, "Auto Revive (เกิดใหม่ออโต้)", "autoRevive")
addToggle(pUtil, "Speed Boost (วิ่งไว 40)", "speedBoost")

addButton(pUtil, "🏠 วาร์ปกลับเมือง (Home)", Color3.fromRGB(48, 64, 92), function()
    pcall(function() Home:FireServer() end)
end)

addButton(pUtil, "📬 รับของใน Mail ทั้งหมด", Color3.fromRGB(44, 82, 58), function()
    pcall(function() Mail:InvokeServer("claimAll") end)
    notify("Pet Hunt Party Hub", "ส่งคำสั่งรับ Mail ทั้งหมดแล้ว!")
end)

-- Tab 3: Zone Warps (19 zones)
local warpList = {
    "town", "backyard", "cafe", "splash", "toy", "gem",
    "snow", "moon", "sky", "jungle", "neon", "wizard",
    "volcano", "camp", "grove", "gale", "mist", "ember", "heart"
}
for _, zid in ipairs(warpList) do
    addButton(pWarp, "🌀 Warp: " .. zid, Color3.fromRGB(36, 40, 52), function()
        pcall(function() Warp:FireServer(zid) end)
    end)
end

-- MacroCheck Alert Listener
MacroCheck.OnClientEvent:Connect(function(...)
    if state.alive and state.macroAlert then
        notify("⚠️ MACRO CHECK!", "ระบบสุ่มตรวจจับบอทเด้ง! รีบกดยืนยันบนหน้าจอ!")
    end
end)

-- Combat / Farm / Skill Loop
local currentTarget
task.spawn(function()
    while state.alive do
        task.wait(0.2)
        local hrp = getHRP()
        local mons = workspace:FindFirstChild("Monsters")
        if hrp and mons then
            local bestMob, bestPart
            local bestDist = math.huge
            for _, mob in ipairs(mons:GetChildren()) do
                local hp = mob:GetAttribute("Health") or 0
                if hp > 0 then
                    local isBoss = mob:GetAttribute("IsBoss") == true
                    if not state.snipeBoss or isBoss then
                        local part = getMobPart(mob)
                        if part then
                            local d = (part.Position - hrp.Position).Magnitude
                            if d < bestDist then
                                bestDist = d
                                bestMob = mob
                                bestPart = part
                            end
                        end
                    end
                end
            end

            if bestMob then
                if state.autoFarm and bestPart and bestDist > 12 then
                    hrp.CFrame = bestPart.CFrame * CFrame.new(0, 0, 8)
                end
                if state.autoTarget and currentTarget ~= bestMob then
                    currentTarget = bestMob
                    pcall(function() SetTarget:FireServer(bestMob) end)
                end
                if state.autoSkill then
                    local skills = getSkillBar()
                    for _, sid in ipairs(skills) do
                        pcall(function() UseSkill:FireServer(sid, bestMob, false) end)
                    end
                end
            end
        end
    end
end)

-- Utility / Loot / ESP / Revive / Speed Loop
task.spawn(function()
    while state.alive do
        task.wait(0.6)
        local hrp = getHRP()
        local hum = getHumanoid()

        if hum then
            if state.autoRevive and hum.Health <= 0 then
                pcall(function() Revive:FireServer() end)
            end
            if state.speedBoost then
                hum.WalkSpeed = 40
            end
        end

        if state.autoLoot and hrp then
            local lootFolder = workspace:FindFirstChild("LootDrops")
            if lootFolder then
                for _, item in ipairs(lootFolder:GetChildren()) do
                    local p = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                    if p then
                        p.CFrame = hrp.CFrame
                    end
                    local id = item:GetAttribute("Id") or item:GetAttribute("PendingId") or item.Name
                    pcall(function() Loot:InvokeServer("take", id) end)
                end
            end
        end

        if state.esp then
            local mons = workspace:FindFirstChild("Monsters")
            if mons then
                for _, mob in ipairs(mons:GetChildren()) do
                    if not mob:FindFirstChild("HubESP") and (mob:GetAttribute("Health") or 0) > 0 then
                        local isBoss = mob:GetAttribute("IsBoss") == true
                        local hl = Instance.new("Highlight")
                        hl.Name = "HubESP"
                        hl.FillColor = isBoss and Color3.fromRGB(235, 175, 45) or Color3.fromRGB(80, 170, 255)
                        hl.OutlineColor = Color3.fromRGB(230, 240, 255)
                        hl.FillTransparency = 0.6
                        hl.Parent = mob
                    end
                end
            end
        end
    end
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        mf.Visible = not mf.Visible
    end
end)

notify("Pet Hunt Party Hub v1.0", "โหลดสำเร็จ! กด RightShift เพื่อซ่อน/แสดง")
