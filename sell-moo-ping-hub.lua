-- Sell Moo Ping Hub v3.0 (Overpowered God Edition)
-- Game: [UPD] Sell Moo Ping 🍢 (PlaceId: 131921813450863)
-- Clean Dark Slate UI (SourceSansSemibold, Border Stroke, Draggable)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local lp = Players.LocalPlayer
local MooRemotes = RS:WaitForChild("MooRemotes")
local GrillAction = MooRemotes:WaitForChild("GrillAction")
local DeliveryAction = MooRemotes:WaitForChild("DeliveryAction")
local ClubSwing = MooRemotes:WaitForChild("ClubSwing")
local GoHome = MooRemotes:WaitForChild("GoHome")
local HoverBoard = MooRemotes:WaitForChild("HoverBoard")
local Phone = MooRemotes:WaitForChild("Phone")
local Daily = MooRemotes:WaitForChild("Daily")
local Playtime = MooRemotes:WaitForChild("Playtime")
local FreeReward = MooRemotes:WaitForChild("FreeReward")
local Missions = MooRemotes:WaitForChild("Missions")
local Staff = MooRemotes:WaitForChild("Staff")
local MoneyRain = MooRemotes:WaitForChild("MoneyRain")
local LitterMop = MooRemotes:WaitForChild("LitterMop")
local RedeemCode = MooRemotes:WaitForChild("RedeemCode")
local Tour = MooRemotes:FindFirstChild("Tour")
local TourState = MooRemotes:FindFirstChild("TourState")
local KitchenCrewUp = MooRemotes:FindFirstChild("KitchenCrewUp")

-- Cleanup old instance
local oldGui = CoreGui:FindFirstChild("SellMooPingHubGui")
if oldGui then oldGui:Destroy() end

local env = getgenv and getgenv() or _G
if env.MooPingState then
    env.MooPingState.alive = false
end

local state = {
    alive = true,
    autoBuyPads = true,
    autoTour = true,
    autoPhone = true,
    autoGrill = true,
    remoteGrill = false,
    autoDelivery = true,
    autoThief = true,
    autoCleanPlates = true,
    autoMissions = true,
    autoRewards = true,
    autoStaffUpgrade = true,
    autoKitchenCrew = true,
    autoMoneyRain = true,
    noclip = false,
    instantPrompt = true,
    speedBoost = true,
    infJump = false,
    highJump = false,
}
env.MooPingState = state

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

local function getControls()
    local pm = lp.PlayerScripts:FindFirstChild("PlayerModule")
    if pm then
        local ok, ctrl = pcall(function() return require(pm):GetControls() end)
        if ok and ctrl then return ctrl end
    end
    return nil
end

local function getCash()
    local leaderstats = lp:FindFirstChild("leaderstats")
    local cash = leaderstats and leaderstats:FindFirstChild("Cash")
    return cash and cash.Value or 0
end

local function getMyStall()
    local plotId = lp:GetAttribute("PlotId")
    local stalls = workspace:FindFirstChild("Stalls")
    if stalls then
        if plotId then
            local byId = stalls:FindFirstChild("Plot" .. tostring(plotId))
            if byId then return byId end
        end
        for _, s in ipairs(stalls:GetChildren()) do
            if s:GetAttribute("Owner") == lp.Name or s:GetAttribute("Owner") == lp.UserId then
                return s
            end
        end
        local plot1 = stalls:FindFirstChild("Plot1")
        if plot1 and (plot1:GetAttribute("Owner") == lp.Name or plot1:GetAttribute("Owner") == lp.UserId) then
            return plot1
        end
    end
    return nil
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "SellMooPingHubGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

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
titleBar.Text = "  🍢 Sell Moo Ping Hub v3.0 (GOD)"
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
local pMain = createTab(1, "🍢 ออโต้หลัก")
local pTycoon = createTab(2, "🏗️ ไทคูน/พนักงาน")
local pWarp = createTab(3, "🌀 วาร์ป/โกงตัว")

-- Tab 1: Core Automation
addToggle(pMain, "Auto Phone (รับออเดอร์+ต่อราคา)", "autoPhone")
addToggle(pMain, "Auto Tour Bus (ออโต้รับรถทัวร์กวาดเงิน)", "autoTour")
addToggle(pMain, "Auto Grill (ปิ้งทุกเตา หน้าร้าน+ครัว)", "autoGrill")
addToggle(pMain, "Remote Grill (ย่างระยะไกล)", "remoteGrill")
addToggle(pMain, "Auto Delivery (โหลดส่งเดลิเวอรี่)", "autoDelivery")
addToggle(pMain, "Auto Bonk Thief (ตีโจร KillAura)", "autoThief")
addToggle(pMain, "Auto Clean & Plates (กวาดขยะ/จาน)", "autoCleanPlates")
addToggle(pMain, "Auto Money Rain (ดูดฝนเงิน)", "autoMoneyRain")

-- Tab 2: Tycoon Auto-Builder & Staff
addToggle(pTycoon, "⚡ Auto-Buy Tycoon Pads (ซื้อสร้างร้าน 100%)", "autoBuyPads")
addToggle(pTycoon, "Auto Kitchen Crew (จ้าง/อัปเกรดครัว)", "autoKitchenCrew")
addToggle(pTycoon, "Auto Upgrade Staff (อัปพนักงานทั่วไป)", "autoStaffUpgrade")
addToggle(pTycoon, "Auto Missions (รับภารกิจ)", "autoMissions")
addToggle(pTycoon, "Auto Claim (Daily/Playtime/FreeGift)", "autoRewards")
addToggle(pTycoon, "Instant Prompts (กดปุ่ม E ทันที)", "instantPrompt")

addButton(pTycoon, "🎁 เคลมภารกิจ & ของขวัญฟรีทั้งหมด", Color3.fromRGB(44, 82, 58), function()
    pcall(function() Daily:InvokeServer("claim") end)
    pcall(function() Playtime:InvokeServer() end)
    pcall(function() FreeReward:InvokeServer("claim") end)
    pcall(function()
        local res = Missions:InvokeServer("get")
        if type(res) == "table" and type(res.list) == "table" then
            for _, m in ipairs(res.list) do
                if m.id then pcall(function() Missions:InvokeServer("claim", m.id) end) end
            end
        end
        Missions:InvokeServer("bonus")
    end)
    notify("Moo Ping Hub", "เคลมรางวัลภารกิจและของขวัญเรียบร้อย!")
end)

addButton(pTycoon, "🛹 เปิด/ปิด Hoverboard", Color3.fromRGB(48, 64, 92), function()
    pcall(function() HoverBoard:FireServer("toggle") end)
end)

-- Promo Code Input Box
orderCounter += 1
local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -6, 0, 30)
codeBox.BackgroundColor3 = Color3.fromRGB(30, 33, 44)
codeBox.BorderSizePixel = 0
codeBox.Font = Enum.Font.SourceSansSemibold
codeBox.PlaceholderText = "พิมพ์โค้ดที่นี่ (Promo Code)..."
codeBox.Text = ""
codeBox.TextColor3 = Color3.fromRGB(224, 230, 240)
codeBox.TextSize = 13
codeBox.LayoutOrder = orderCounter
codeBox.Parent = pTycoon
local cbc = Instance.new("UICorner")
cbc.CornerRadius = UDim.new(0, 6)
cbc.Parent = codeBox

addButton(pTycoon, "🎟️ แลกโค้ด (Redeem Code)", Color3.fromRGB(68, 58, 102), function()
    local code = codeBox.Text:match("^%s*(.-)%s*$")
    if code ~= "" then
        local ok, res = pcall(function() return RedeemCode:InvokeServer(code) end)
        notify("Redeem Code", ok and tostring(res) or "Error")
    else
        notify("Redeem Code", "กรุณาพิมพ์โค้ดก่อนครับ")
    end
end)

-- Tab 3: Warps, Movement & Exploits
addToggle(pWarp, "Noclip (เดินทะลุกำแพง/สิ่งกีดขวาง)", "noclip")
addToggle(pWarp, "Hyper Speed (วิ่งไวติดจรวด 45)", "speedBoost")
addToggle(pWarp, "High Jump (กระโดดสูง 85)", "highJump")
addToggle(pWarp, "Infinite Jump (กระโดดกลางอากาศ)", "infJump")

addButton(pWarp, "🔓 ปลดล็อกตัวละคร (Unfreeze)", Color3.fromRGB(145, 52, 56), function()
    local hrp = getHRP()
    if hrp then hrp.Anchored = false end
    local ctrl = getControls()
    if ctrl then ctrl:Enable() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    notify("Moo Ping Hub", "ปลดล็อกตัวละครและมุมกล้องแล้ว!")
end)

addButton(pWarp, "🏠 วาร์ปกลับร้านตัวเอง (My Stall)", Color3.fromRGB(48, 64, 92), function()
    pcall(function() GoHome:FireServer() end)
    local s = getMyStall()
    local hrp = getHRP()
    if s and hrp then
        local p = s:FindFirstChild("CookGrillPad") or s:FindFirstChildWhichIsA("BasePart", true)
        if p then hrp.CFrame = p.CFrame + Vector3.new(0, 3, 0) end
    end
end)

for i = 1, 8 do
    addButton(pWarp, "🍢 วาร์ปไป Plot " .. i, Color3.fromRGB(36, 40, 52), function()
        local stalls = workspace:FindFirstChild("Stalls")
        local p = stalls and stalls:FindFirstChild("Plot" .. i)
        local hrp = getHRP()
        if p and hrp then
            local part = p:FindFirstChild("CookGrillPad") or p:FindFirstChildWhichIsA("BasePart", true)
            if part then hrp.CFrame = part.CFrame + Vector3.new(0, 4, 0) end
        end
    end)
end

-- 1. Auto Phone Order Listener
Phone.OnClientEvent:Connect(function(action, data)
    if not state.alive or not state.autoPhone then return end
    if action == "offer" and type(data) == "table" and data.id then
        task.wait(0.2)
        pcall(function() Phone:FireServer("more", data.id) end)
        task.wait(1.0)
        pcall(function() Phone:FireServer("accept", data.id) end)
        notify("📞 Phone Order", "รับออเดอร์ล็อตใหญ่เรียบร้อย!")
    elseif action == "raised" and type(data) == "table" and data.id then
        task.wait(0.2)
        pcall(function() Phone:FireServer("accept", data.id) end)
        notify("📞 Phone Order", "ต่อราคาสำเร็จ! กดยืนยันรับเงินแล้ว")
    end
end)

-- 2. Auto Tour Bus Listener
if TourState and Tour then
    TourState.OnClientEvent:Connect(function(bus)
        if state.alive and state.autoTour then
            task.wait(0.3)
            pcall(function() Tour:InvokeServer("accept") end)
            notify("🚌 Tour Bus", "รถทัวร์มาถึงแล้ว! กดรับนักท่องเที่ยวกวาดเงินทันที")
        end
    end)
end

-- 3. Auto Money Rain Listener
MoneyRain.OnClientEvent:Connect(function(id, count)
    if not state.alive or not state.autoMoneyRain then return end
    if id then
        local n = tonumber(count) or 20
        for k = 1, n do
            pcall(function() MoneyRain:FireServer("grab", id, k) end)
        end
    end
end)

-- 4. Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if state.alive and state.infJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 5. Instant Proximity Prompts
ProximityPromptService.PromptShown:Connect(function(prompt)
    if state.alive and state.instantPrompt then
        prompt.HoldDuration = 0
    end
end)

-- 6. Noclip Loop
RunService.Stepped:Connect(function()
    if state.alive and state.noclip and lp.Character then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 7. Heartbeat Anti-Freeze & Movement Loop
RunService.Heartbeat:Connect(function()
    if not state.alive then return end
    local hrp = getHRP()
    local hum = getHumanoid()

    if hrp and hrp.Anchored then
        hrp.Anchored = false
    end
    local ctrl = getControls()
    if ctrl and not ctrl.enabled then
        pcall(function() ctrl:Enable() end)
    end
    if state.remoteGrill then
        pcall(function() RunService:UnbindFromRenderStep("MooGrillCam") end)
        local pg = lp:FindFirstChild("PlayerGui")
        local gh = pg and pg:FindFirstChild("GrillHUD")
        if gh and gh.Enabled then
            gh.Enabled = false
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            if hum then workspace.CurrentCamera.CameraSubject = hum end
        end
    end
    if hum then
        if state.speedBoost and hum.WalkSpeed < 40 then hum.WalkSpeed = 45 end
        if state.highJump then
            hum.UseJumpPower = true
            hum.JumpPower = 85
        end
    end
end)

-- 8. Main Auto Grill Loop (Stall + CookGrill + HouseGrill)
local function processGrillTarget(target, pad)
    if not target then return end
    local hrp = getHRP()
    if state.remoteGrill and hrp and pad then
        pcall(function() firetouchinterest(hrp, pad, 0) end)
    end
    local hb = target:FindFirstChild("Hitboxes")
    if hb then
        for _, slot in ipairs(hb:GetChildren()) do
            local num = tonumber(slot.Name:match("%d+"))
            local slotState = slot:GetAttribute("State")
            if num then
                if slotState == "cooked" then
                    pcall(function() GrillAction:FireServer(target, num, "collect") end)
                elseif slotState == "empty" then
                    pcall(function() GrillAction:FireServer(target, num, "place") end)
                end
            end
        end
    end
end

task.spawn(function()
    while state.alive do
        task.wait(0.2)
        if state.autoGrill then
            local stall = getMyStall()
            if stall then
                processGrillTarget(stall, stall:FindFirstChild("CookGrillPad"))
                local cookGrill = stall:FindFirstChild("CookGrill")
                if cookGrill then
                    processGrillTarget(cookGrill, stall:FindFirstChild("KitchenGrillPad"))
                end
            end
            local hk = workspace:FindFirstChild("HouseKitchen")
            local houseGrill = hk and hk:FindFirstChild("HouseGrill")
            if houseGrill then
                processGrillTarget(houseGrill, nil)
            end
        end
    end
end)

-- 9. Auto-Buy Tycoon Pads Loop (God-Tier Feature)
task.spawn(function()
    while state.alive do
        task.wait(1.5)
        if state.autoBuyPads then
            local stall = getMyStall()
            local hrp = getHRP()
            if stall and hrp then
                local currentCash = getCash()
                local cheapestPad = nil
                local minPrice = math.huge

                for _, child in ipairs(stall:GetChildren()) do
                    local price = child:GetAttribute("Price")
                    local shown = child:GetAttribute("Shown")
                    if shown and price and type(price) == "number" and price > 0 and price <= currentCash then
                        if price < minPrice then
                            minPrice = price
                            cheapestPad = child
                        end
                    end
                end

                if cheapestPad then
                    local origCF = hrp.CFrame
                    local ground = cheapestPad:GetAttribute("Ground")
                    local targetPos = (ground and ground.Position) or cheapestPad.Position
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.5, 0))
                    task.wait(0.35)
                    hrp.CFrame = origCF
                    task.wait(0.4)
                end
            end
        end
    end
end)

-- 10. Delivery, Thief, Litter & Plates Loop
task.spawn(function()
    while state.alive do
        task.wait(0.8)
        if state.autoDelivery then
            pcall(function() DeliveryAction:InvokeServer("load") end)
            pcall(function() DeliveryAction:InvokeServer("sell") end)
        end
        if state.autoTour and Tour then
            pcall(function() Tour:InvokeServer("accept") end)
        end
        if state.autoThief then
            local thieves = workspace:FindFirstChild("Thieves")
            if thieves then
                for _, thief in ipairs(thieves:GetChildren()) do
                    pcall(function() ClubSwing:FireServer(thief) end)
                end
            end
        end
        if state.autoCleanPlates then
            pcall(function() LitterMop:FireServer(true) end)
            local stall = getMyStall()
            if stall and fireproximityprompt then
                for _, d in ipairs(stall:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        local pName = d.Parent and d.Parent.Name:lower() or ""
                        if pName:find("plate") or pName:find("dirty") or pName:find("litter") or pName:find("rice") then
                            pcall(function() fireproximityprompt(d) end)
                        end
                    end
                end
            end
            local litter = workspace:FindFirstChild("Litter")
            if litter and fireproximityprompt then
                for _, d in ipairs(litter:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        pcall(function() fireproximityprompt(d) end)
                    end
                end
            end
        end
    end
end)

-- 11. Rewards, Missions & Staff Auto-Upgrade Loop
task.spawn(function()
    while state.alive do
        task.wait(3.5)
        if state.autoRewards then
            pcall(function() Daily:InvokeServer("claim") end)
            pcall(function() Playtime:InvokeServer() end)
            pcall(function() FreeReward:InvokeServer("claim") end)
        end
        if state.autoMissions then
            pcall(function()
                local res = Missions:InvokeServer("get")
                if type(res) == "table" and type(res.list) == "table" then
                    for _, m in ipairs(res.list) do
                        if m.id and (m.done or m.ready or (m.progress and m.goal and m.progress >= m.goal)) then
                            pcall(function() Missions:InvokeServer("claim", m.id) end)
                        end
                    end
                end
                Missions:InvokeServer("bonus")
            end)
        end
        if state.autoStaffUpgrade then
            for _, job in ipairs({"cook", "waiter", "helper", "driver"}) do
                pcall(function() Staff:InvokeServer("upgrade", job) end)
            end
        end
        if state.autoKitchenCrew and KitchenCrewUp then
            pcall(function()
                for _, k in ipairs({"dish", "grill", "pack"}) do
                    KitchenCrewUp:InvokeServer("buy", k, 1, 1)
                end
            end)
        end
    end
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        mf.Visible = not mf.Visible
    end
end)

notify("Sell Moo Ping Hub v3.0", "Overpowered Edition ทำงานแล้ว! กด RightShift ซ่อน/แสดง")