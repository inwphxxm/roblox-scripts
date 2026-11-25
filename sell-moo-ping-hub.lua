-- Sell Moo Ping Hub v1.3 (Auto Phone Orders & Haggling Edition)
-- Game: [UPD] Sell Moo Ping 🍢 (PlaceId: 131921813450863)
-- Clean Dark Slate UI (SourceSansSemibold, Border Stroke, Draggable)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

-- Cleanup old instance
local oldGui = CoreGui:FindFirstChild("SellMooPingHubGui")
if oldGui then oldGui:Destroy() end

local env = getgenv and getgenv() or _G
if env.MooPingState then
    env.MooPingState.alive = false
end

local state = {
    alive = true,
    autoPhone = true,   -- รับออเดอร์มือถือ + ต่อราคาให้อัตโนมัติ
    autoGrill = true,
    remoteGrill = true, -- ย่างระยะไกล ไม่ต้องยืนหน้าร้าน
    autoDelivery = true,
    autoThief = true,
    autoRewards = true,
    speedBoost = true,  -- เปิดวิ่งไวเพื่อเดินคล่อง
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

local function getMyStall()
    local plotId = lp:GetAttribute("PlotId")
    local stalls = workspace:FindFirstChild("Stalls")
    if stalls then
        if plotId then
            local byId = stalls:FindFirstChild("Plot" .. tostring(plotId))
            if byId then return byId end
        end
        for _, s in ipairs(stalls:GetChildren()) do
            if s:GetAttribute("Owner") == lp.Name then
                return s
            end
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
mf.Size = UDim2.new(0, 320, 0, 420)
mf.Position = UDim2.new(1, -340, 1, -440)
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
titleBar.Text = "  🍢 Sell Moo Ping Hub v1.3"
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
local pMain = createTab(1, "🍢 ออโต้หมูปิ้ง")
local pWarp = createTab(2, "🌀 วาร์ป & ตัวละคร")

-- Tab 1: Auto Grill & Automation
addToggle(pMain, "Auto Phone (รับออเดอร์มือถือ + เพิ่มราคา)", "autoPhone")
addToggle(pMain, "Auto Grill (ย่าง & เก็บหมูปิ้ง)", "autoGrill")
addToggle(pMain, "Remote Grill (ย่างได้ทุกที่ เดินได้อิสระ)", "remoteGrill")
addToggle(pMain, "Auto Delivery (ส่งเดลิเวอรี่)", "autoDelivery")
addToggle(pMain, "Auto Bonk Thief (ไล่หวดโจร)", "autoThief")
addToggle(pMain, "Auto Claim (ของฟรี/Daily)", "autoRewards")

addButton(pMain, "🛹 เปิด/ปิด Hoverboard", Color3.fromRGB(48, 64, 92), function()
    pcall(function() HoverBoard:FireServer("toggle") end)
end)

addButton(pMain, "🎁 กดรับ Daily / Playtime ทันที", Color3.fromRGB(44, 82, 58), function()
    pcall(function() Daily:InvokeServer() end)
    pcall(function() Playtime:InvokeServer() end)
    pcall(function() FreeReward:InvokeServer() end)
    notify("Moo Ping Hub", "กดรับของรางวัลฟรีทั้งหมดแล้ว!")
end)

-- Tab 2: Warps & Movement
addToggle(pWarp, "Speed Boost (วิ่งไว 38)", "speedBoost")

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

-- 1. Auto Phone Order Listener (Remote Hook)
Phone.OnClientEvent:Connect(function(action, data)
    if not state.alive or not state.autoPhone then return end
    if action == "offer" and type(data) == "table" and data.id then
        task.wait(0.3)
        -- First try to negotiate for more money ("more")
        pcall(function()
            Phone:FireServer("more", data.id)
        end)
        task.wait(1.2)
        -- Then accept the highest offer ("accept")
        pcall(function()
            Phone:FireServer("accept", data.id)
        end)
        notify("📞 Phone Order", "รับออเดอร์ล็อตใหญ่เรียบร้อย!")
    elseif action == "raised" and type(data) == "table" and data.id then
        task.wait(0.3)
        pcall(function()
            Phone:FireServer("accept", data.id)
        end)
        notify("📞 Phone Order", "ต่อราคาสำเร็จ! กดยืนยันรับเงินแล้ว")
    end
end)

-- 2. Backup Phone UI Auto-Clicker
task.spawn(function()
    while state.alive do
        task.wait(0.5)
        if state.autoPhone then
            local pg = lp:FindFirstChild("PlayerGui")
            local phoneGui = pg and pg:FindFirstChild("Phone")
            if phoneGui and phoneGui.Enabled then
                for _, b in ipairs(phoneGui:GetDescendants()) do
                    if b:IsA("TextButton") and b.Visible then
                        if b.Text:find("ตกลง") or b.Text:find("accept") then
                            pcall(function()
                                if firesignal then
                                    firesignal(b.Activated)
                                elseif b.MouseButton1Click then
                                    b.MouseButton1Click:Fire()
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 3. Continuous Anti-Freeze / Anti-Lock Loop (Runs on Heartbeat)
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
        pcall(function()
            RunService:UnbindFromRenderStep("MooGrillCam")
        end)
        local pg = lp:FindFirstChild("PlayerGui")
        local gh = pg and pg:FindFirstChild("GrillHUD")
        if gh and gh.Enabled then
            gh.Enabled = false
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
            end
        end
    end

    if hum and state.speedBoost and hum.WalkSpeed < 35 then
        hum.WalkSpeed = 38
    end
end)

-- 4. Main Auto Grill Loop
task.spawn(function()
    while state.alive do
        task.wait(0.2)
        local stall = getMyStall()
        local hrp = getHRP()
        local pad = stall and stall:FindFirstChild("CookGrillPad")

        if state.autoGrill and stall then
            if state.remoteGrill and hrp and pad then
                pcall(function()
                    firetouchinterest(hrp, pad, 0)
                end)
            end

            if stall:FindFirstChild("Hitboxes") then
                for _, slot in ipairs(stall.Hitboxes:GetChildren()) do
                    local num = tonumber(slot.Name:match("%d+"))
                    local slotState = slot:GetAttribute("State")
                    if num then
                        if slotState == "cooked" then
                            pcall(function() GrillAction:FireServer(stall, num, "collect") end)
                        elseif slotState == "empty" then
                            pcall(function() GrillAction:FireServer(stall, num, "place") end)
                        end
                    end
                end
            end
        end
    end
end)

-- 5. Delivery & Thief Loop
task.spawn(function()
    while state.alive do
        task.wait(0.8)
        if state.autoDelivery then
            pcall(function() DeliveryAction:InvokeServer("load") end)
            pcall(function() DeliveryAction:InvokeServer("sell") end)
        end
        if state.autoThief then
            local thieves = workspace:FindFirstChild("Thieves")
            if thieves then
                for _, thief in ipairs(thieves:GetChildren()) do
                    pcall(function() ClubSwing:FireServer(thief) end)
                end
            end
        end
    end
end)

-- 6. Rewards Loop
task.spawn(function()
    while state.alive do
        task.wait(3.0)
        if state.autoRewards then
            pcall(function() Daily:InvokeServer() end)
            pcall(function() Playtime:InvokeServer() end)
            pcall(function() FreeReward:InvokeServer() end)
        end
    end
end)

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        mf.Visible = not mf.Visible
    end
end)

notify("Sell Moo Ping Hub v1.3", "เปิดระบบ Auto Phone Order แล้ว! มีออเดอร์โทรศัพท์เข้ารับให้อัตโนมัติ")
