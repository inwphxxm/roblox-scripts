-- Barber Empire Hub v2.0 (Real 5-Star Auto Call & Cut)
-- Game: [💈] Barber Empire (PlaceId: 129516203408961)
-- Clean Dark Slate UI (SourceSansSemibold, Border Stroke, Draggable)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local lp = Players.LocalPlayer
local HairLab = RS:WaitForChild("HairLab")
local Remotes = HairLab:WaitForChild("Remotes")
local NewCustomer = Remotes:WaitForChild("NewCustomer")
local CutStart = Remotes:WaitForChild("CutStart")
local PayCut = Remotes:WaitForChild("PayCut")
local TipJar = Remotes:WaitForChild("TipJar")
local HairCuts = require(HairLab:WaitForChild("HairCuts"))

-- Cleanup old instance
local oldGui = CoreGui:FindFirstChild("BarberEmpireHubGui")
if oldGui then oldGui:Destroy() end

local env = getgenv and getgenv() or _G
if env.BarberHubState then
    env.BarberHubState.alive = false
end

local state = {
    alive = true,
    autoCut = true,
    autoCoins = true,
    autoEggs = true,
    autoTip = true,
    instantPrompt = true,
    speedBoost = true,
    highJump = false,
    infJump = false,
}
env.BarberHubState = state

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

-- Override HairCuts.styleStars so ShopClient ALWAYS evaluates every cut as 5 Stars!
if not env.BarberStyleStarsHooked then
    env.BarberStyleStarsHooked = true
    local origStyleStars = HairCuts.styleStars
    if type(origStyleStars) == "function" then
        if hookfunction then
            hookfunction(origStyleStars, function(...)
                if env.BarberHubState and env.BarberHubState.alive and env.BarberHubState.autoCut then
                    return 5
                end
                return origStyleStars(...)
            end)
        end
        HairCuts.styleStars = function(...)
            if env.BarberHubState and env.BarberHubState.alive and env.BarberHubState.autoCut then
                return 5
            end
            return origStyleStars(...)
        end
    end
end

-- Force 5-Star Hook on PayCut (__namecall)
if not env.BarberPayCutHooked and hookmetamethod and getnamecallmethod and newcclosure then
    env.BarberPayCutHooked = true
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self == PayCut and env.BarberHubState and env.BarberHubState.alive and env.BarberHubState.autoCut then
            local args = {...}
            if type(args[1]) == "number" then
                args[2] = 5
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end))
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "BarberEmpireHubGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mf = Instance.new("Frame")
mf.Name = "MainFrame"
mf.Size = UDim2.new(0, 320, 0, 370)
mf.Position = UDim2.new(1, -340, 1, -390)
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
titleBar.Text = "  💈 Barber Empire Hub v2.0"
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
local pFarm = createTab(1, "✂️ ฟาร์มตัดผม")
local pUtil = createTab(2, "⚡ เสริม/ตัวละคร")

-- Tab 1: Barber Farm
addToggle(pFarm, "Auto Cut 5★ (เรียกลูกค้า+ตัด 5 ดาว)", "autoCut")
addToggle(pFarm, "Auto Coins (ดูดเหรียญตกพื้น)", "autoCoins")
addToggle(pFarm, "Auto Easter Eggs (เก็บไข่ออโต้)", "autoEggs")
addToggle(pFarm, "Auto TipJar (เก็บกระปุกทิป)", "autoTip")

addButton(pFarm, "✂️ เรียกลูกค้าที่รอ + ตัด 5★ ทันที", Color3.fromRGB(48, 64, 92), function()
    task.spawn(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled and d.ActionText:lower():find("call") then
                local hrp = getHRP()
                local part = d.Parent and d.Parent:IsA("BasePart") and d.Parent or d.Parent:FindFirstChildWhichIsA("BasePart", true)
                if hrp and part then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 2, 3)
                    task.wait(0.15)
                end
                pcall(function() fireproximityprompt(d) end)
                break
            end
        end
    end)
end)

-- Tab 2: Utility & Movement
addToggle(pUtil, "Instant Prompts (กด E ทันที)", "instantPrompt")
addToggle(pUtil, "Speed Boost (วิ่งไว 40)", "speedBoost")
addToggle(pUtil, "High Jump (กระโดดสูง 85)", "highJump")
addToggle(pUtil, "Infinite Jump (กระโดดกลางอากาศ)", "infJump")

addButton(pUtil, "🏠 วาร์ปกลับจุดเกิด (Spawn)", Color3.fromRGB(48, 64, 92), function()
    local sp = workspace:FindFirstChildOfClass("SpawnLocation")
    local hrp = getHRP()
    if sp and hrp then
        hrp.CFrame = sp.CFrame + Vector3.new(0, 4, 0)
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
        if state.speedBoost and hum.WalkSpeed < 36 then hum.WalkSpeed = 40 end
        if state.highJump then
            hum.UseJumpPower = true
            hum.JumpPower = 85
        end
    end
end)

-- Helper: Find "Call to chair" prompt
local function findCallPrompt()
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and d.ActionText:lower():find("call") then
            return d
        end
    end
    return nil
end

-- Main Auto Call + Auto Cut 5-Star Loop
task.spawn(function()
    while state.alive do
        if state.autoCut then
            local cutHud = lp.PlayerGui:FindFirstChild("CutHUD")
            if cutHud and cutHud.Enabled then
                -- Wait for server cut timer (~2.3s), then click DONE! (HairCuts.styleStars returns 5!)
                task.wait(2.4)
                if not state.alive or not state.autoCut then continue end
                local doneBtn = cutHud:FindFirstChild("Done", true)
                local face = doneBtn and doneBtn:FindFirstChild("Face")
                if face and face:IsA("GuiButton") and face.Visible and firesignal then
                    pcall(function() firesignal(face.Activated) end)
                end
                task.wait(1.5)
            else
                -- 1. Check if waiting customer is in chairs ("Call to chair")
                local callPrompt = findCallPrompt()
                if callPrompt and fireproximityprompt then
                    local hrp = getHRP()
                    local part = callPrompt.Parent and (callPrompt.Parent:IsA("BasePart") and callPrompt.Parent or callPrompt.Parent:FindFirstChildWhichIsA("BasePart", true))
                    if hrp and part then
                        local dist = (hrp.Position - part.Position).Magnitude
                        if dist > 8 then
                            hrp.CFrame = part.CFrame + Vector3.new(0, 2, 3)
                            task.wait(0.15)
                        end
                    end
                    callPrompt.HoldDuration = 0
                    pcall(function() fireproximityprompt(callPrompt) end)
                    task.wait(1.2)
                else
                    -- 2. If no waiting customers, try NewCustomer
                    local ok, cust = pcall(function() return NewCustomer:InvokeServer() end)
                    if ok and type(cust) == "table" and type(cust.token) == "number" then
                        pcall(function() CutStart:FireServer(cust.token) end)
                        task.wait(2.5)
                        if not state.alive then break end
                        pcall(function()
                            PayCut:FireServer(cust.token, 5, { cover = 1, coop = cust.coop == true, product = false, design = false })
                        end)
                        task.wait(1.0)
                    else
                        task.wait(1.5)
                    end
                end
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Coins, CashDrops, EasterEggs & TipJar Loop
task.spawn(function()
    while state.alive do
        task.wait(0.8)
        local hrp = getHRP()
        if state.autoCoins and hrp then
            for _, folderName in ipairs({"MyCoins", "CashDrops"}) do
                local f = workspace:FindFirstChild(folderName)
                if f then
                    for _, item in ipairs(f:GetChildren()) do
                        local p = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                        if p then p.CFrame = hrp.CFrame end
                    end
                end
            end
        end
        if state.autoEggs and fireproximityprompt then
            local eggs = workspace:FindFirstChild("EasterEggs")
            if eggs then
                for _, d in ipairs(eggs:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        pcall(function() fireproximityprompt(d) end)
                    end
                end
            end
        end
        if state.autoTip then
            pcall(function() TipJar:InvokeServer("collect") end)
        end
    end
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        mf.Visible = not mf.Visible
    end
end)

notify("Barber Empire Hub v2.0", "อัปเกรดแล้ว! เรียกลูกค้า + ตัด 5 ดาวเต็มให้เองอัตโนมัติ")
