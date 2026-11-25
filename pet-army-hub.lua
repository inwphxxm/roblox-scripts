-- Pet Army Hub v3.0 (All-in-One) for [HARVEST EVENT] Summon a Pet Army
-- Clean UI (SourceSansSemibold, no neon Contextual stroke)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local Remotes = RS:WaitForChild("Remotes")
local Punch = Remotes:WaitForChild("Punch")
local SoulChoice = Remotes:WaitForChild("SoulChoice")
local SoulRemote = Remotes:WaitForChild("Soul")
local CampAction = Remotes:WaitForChild("CampAction")
local HarvestShopAction = Remotes:WaitForChild("HarvestShopAction")
local BlackFridayAction = Remotes:WaitForChild("BlackFridayAction")
local Shroud = Remotes:WaitForChild("Shroud")
local SecretRevealed = Remotes:WaitForChild("SecretRevealed")
local OfflineCollect = Remotes:WaitForChild("OfflineCollect")

-- Cleanup previous instance
local oldGui = CoreGui:FindFirstChild("PetArmyHubGui")
if oldGui then oldGui:Destroy() end

local env = getgenv and getgenv() or _G
if env.PetHubState then
    env.PetHubState.alive = false
end

local state = {
    alive = true,
    killAura = true,
    autoFarm = false,
    snipeBig = false,
    autoArise = true,
    esp = false,
    autoClaim = false,
    autoMysterySoul = false,
    autoBuyDrum = false,
}
env.PetHubState = state

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
    end)
end

local function getHRP()
    local char = lp.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PetArmyHubGui"
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
titleBar.Text = "  🐾 Pet Army Hub v3.0 (All-in-One)"
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
local pFarm = createTab(1, "⚔️ ฟาร์ม/ตีมอน")
local pShop = createTab(2, "🎁 ของฟรี/ร้านค้า")
local pWarp = createTab(3, "🌀 วาร์ปโซน")

-- Tab 1: Farm / Combat
addToggle(pFarm, "Kill Aura (ตีรอบตัว)", "killAura")
addToggle(pFarm, "Auto Farm All (วาร์ปไล่ตี)", "autoFarm")
addToggle(pFarm, "Snipe ตัวใหญ่/Hard/Boss", "snipeBig")
addToggle(pFarm, "Auto Arise (อัญเชิญออโต้)", "autoArise")
addToggle(pFarm, "Monster ESP (สแกนทั้งแมพ)", "esp")

-- Tab 2: Freebies / Shop / Remotes
addToggle(pShop, "Auto Claim (ของฟรี/ปฏิทิน)", "autoClaim")
addToggle(pShop, "Auto Mystery Soul (เปิดโซล)", "autoMysterySoul")
addToggle(pShop, "Auto Buy Drum (อัปกลองออโต้)", "autoBuyDrum")

addButton(pShop, "💰 กดเก็บเหรียญออฟไลน์ทันที", Color3.fromRGB(48, 64, 92), function()
    local piles = workspace:FindFirstChild("OfflinePiles")
    if piles then
        for _, p in ipairs(piles:GetChildren()) do
            pcall(function() OfflineCollect:FireServer(p.Name) end)
        end
    end
    pcall(function() OfflineCollect:FireServer() end)
    notify("Pet Army Hub", "ส่งคำสั่งเก็บเหรียญออฟไลน์แล้ว")
end)

addButton(pShop, "🎁 รับกล่อง Gift & Calendar ทันที", Color3.fromRGB(48, 64, 92), function()
    pcall(function() CampAction:InvokeServer("claimGift") end)
    pcall(function() CampAction:InvokeServer("claimCalendar") end)
    notify("Pet Army Hub", "กดรับ Gift & Calendar แล้ว")
end)

addButton(pShop, "👻 ซื้อ MysterySoul (ร้าน Harvest)", Color3.fromRGB(44, 82, 58), function()
    local ok, res = pcall(function() return HarvestShopAction:InvokeServer("buy", "MysterySoul") end)
    notify("Harvest Shop", ok and tostring(res) or "Error")
end)

addButton(pShop, "🌱 ซื้อ SizeSeed (ร้าน Harvest)", Color3.fromRGB(44, 82, 58), function()
    local ok, res = pcall(function() return HarvestShopAction:InvokeServer("buy", "SizeSeed") end)
    notify("Harvest Shop", ok and tostring(res) or "Error")
end)

addButton(pShop, "🥁 ซื้อกลองบัฟ (Buy Drum)", Color3.fromRGB(48, 64, 92), function()
    local ok, res = pcall(function() return CampAction:InvokeServer("buyDrum") end)
    notify("Buy Drum", ok and tostring(res) or "Error")
end)

addButton(pShop, "🚪 ปลดล็อกประตูลับ Zone 11 & 12", Color3.fromRGB(56, 52, 92), function()
    pcall(function()
        SecretRevealed:FireServer("Zone11")
        SecretRevealed:FireServer("Zone12")
        SecretRevealed:FireServer("Zone12Pad")
    end)
    notify("Pet Army Hub", "ยิงปลดล็อกประตูลับ Zone 11 & 12 แล้ว!")
end)

addButton(pShop, "🚩 สลับแบนเนอร์/ธงบัฟ (Toggle Banner)", Color3.fromRGB(44, 66, 96), function()
    local ok, res = pcall(function() return CampAction:InvokeServer("toggleBanner") end)
    notify("Toggle Banner", ok and tostring(res) or "Error")
end)

addButton(pShop, "🛍️ เช็ค/สลับปากกา Black Friday & Harvest", Color3.fromRGB(82, 62, 42), function()
    local ok, res = pcall(function() return BlackFridayAction:InvokeServer("get") end)
    if ok and type(res) == "table" then
        if res.hasPen then
            pcall(function() BlackFridayAction:InvokeServer("pen", "harvest") end)
            notify("Black Friday", "สลับปากกา Harvest แล้ว!")
        elseif res.live and type(res.items) == "table" then
            for itemId, info in pairs(res.items) do
                if type(info) == "table" and not info.owned and (res.coins or 0) >= (info.price or 9e18) then
                    pcall(function() BlackFridayAction:InvokeServer("buy", itemId) end)
                end
            end
            notify("Black Friday", "เช็คและซื้อของที่เงินพอแล้ว!")
        else
            notify("Black Friday", "ตอนนี้ร้าน BF ยังไม่เปิด (live=false)")
        end
    end
end)

addButton(pShop, "🌾 เช็ค Kernels & สต็อกร้าน Harvest", Color3.fromRGB(44, 82, 58), function()
    local ok, res = pcall(function() return HarvestShopAction:InvokeServer("get") end)
    if ok and type(res) == "table" then
        notify("Harvest Shop", string.format("Kernels: %s | FreeRolls: %s | SizeSeeds: %s",
            tostring(res.kernels or 0), tostring(res.freeRolls or 0), tostring(res.sizeSeeds or 0)))
    end
end)

-- Tab 3: Zone Teleporter
addButton(pWarp, "🏠 วาร์ปกลับแคมป์ (Home)", Color3.fromRGB(48, 64, 92), function()
    pcall(function() CampAction:InvokeServer("home") end)
end)

local zoneNames = {
    "Zone1_Meadow", "Zone2_Canyon", "Zone3_Peaks", "Zone4_Hollow",
    "Zone5_Ocean", "Zone6_Volcano", "Zone7_Jungle", "Zone8_Skyreach",
    "Zone9_Starfall", "Zone10_Godfall", "Zone11_Void", "Zone12_Beyond"
}
for _, zn in ipairs(zoneNames) do
    addButton(pWarp, "🌀 " .. zn, Color3.fromRGB(36, 40, 52), function()
        local zones = workspace:FindFirstChild("Zones")
        local z = zones and zones:FindFirstChild(zn)
        local hrp = getHRP()
        if z and hrp then
            local cf = z:IsA("Model") and z:GetPivot() or (z:IsA("BasePart") and z.CFrame)
            if not cf then
                local p = z:FindFirstChildWhichIsA("BasePart", true)
                if p then cf = p.CFrame end
            end
            if cf then
                hrp.CFrame = cf + Vector3.new(0, 6, 0)
            end
        end
    end)
end

-- Auto Arise Listener
SoulRemote.OnClientEvent:Connect(function(data)
    if not state.alive or not state.autoArise then return end
    if type(data) == "table" and data.id then
        pcall(function() SoulChoice:FireServer(data.id, "summon") end)
    end
end)

-- Combat & Farm Loop
task.spawn(function()
    while state.alive do
        task.wait(0.12)
        local hrp = getHRP()
        local wild = workspace:FindFirstChild("WildCreatures")
        if hrp and wild then
            local targetMob
            local bestDist = math.huge
            for _, mob in ipairs(wild:GetChildren()) do
                local hp = mob:GetAttribute("HP") or 0
                if hp > 0 then
                    local part = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if state.killAura and dist <= 28 then
                            pcall(function() Punch:FireServer(mob) end)
                        end
                        if state.autoFarm then
                            local tier = mob:GetAttribute("Tier") or ""
                            local size = mob:GetAttribute("Size") or 1
                            local isBig = (size >= 3) or (tier == "Hard") or (tier == "Boss")
                            if (not state.snipeBig or isBig) and dist < bestDist then
                                bestDist = dist
                                targetMob = part
                            end
                        end
                    end
                end
            end
            if state.autoFarm and targetMob then
                hrp.CFrame = targetMob.CFrame * CFrame.new(0, 0, 5)
            end
        end
    end
end)

-- Background Utility Loop (Auto Claim / MysterySoul / BuyDrum / ESP)
task.spawn(function()
    while state.alive do
        task.wait(1.0)
        if state.autoClaim then
            pcall(function() CampAction:InvokeServer("claimGift") end)
            pcall(function() CampAction:InvokeServer("claimCalendar") end)
        end
        if state.autoMysterySoul then
            local msFolder = workspace:FindFirstChild("MysterySouls")
            if msFolder then
                for _, m in ipairs(msFolder:GetChildren()) do
                    local id = m:GetAttribute("Id")
                    if id then
                        pcall(function() Shroud:FireServer("open", id) end)
                    end
                end
            end
        end
        if state.autoBuyDrum then
            pcall(function() CampAction:InvokeServer("buyDrum") end)
        end
        if state.esp then
            local wild = workspace:FindFirstChild("WildCreatures")
            if wild then
                for _, mob in ipairs(wild:GetChildren()) do
                    if not mob:FindFirstChild("HubESP") and (mob:GetAttribute("HP") or 0) > 0 then
                        local hl = Instance.new("Highlight")
                        hl.Name = "HubESP"
                        hl.FillColor = Color3.fromRGB(80, 170, 255)
                        hl.OutlineColor = Color3.fromRGB(220, 235, 255)
                        hl.FillTransparency = 0.65
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

notify("Pet Army Hub v3.0", "โหลดสำเร็จ! กด RightShift เพื่อซ่อน/แสดง")
