--[[
   The Animal Hospital - ESP v6 (Icon Menu)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ANOMALY_REVEALS = {
    "DifferentEars", "DifferentFace", "SkinwalkerOpensMouth", "Static",
    "TwistNeck", "VoidPresence", "CursedPhoto", "BrokenBones",
    "HiddenFace", "LizInfectedFace"
}
local ANOMALY_TAGS = { "GhostAnomaly", "AnomalyShadow", "StalkerJumpscare", "Skinwalker" }
local SKINWALKER_PARTS = { "Gulp", "Tooth", "TongueMesh", "Spit", "Teeth" }

local espObjects = {}
local espEnabled = true
local anomalyCount = 0
local normalCount = 0
local NAMETAG_RANGE = 14
local HIGHLIGHT_RANGE = 40

local categoryFilters = {
    Ghost = true, Stalker = true, Hider = true,
    TallMonster = true, Skinwalker = true, Shadow = true,
    Normal = true, ESP_MASTER = true
}

-- ==========================================
-- ANOMALY DETECTION
-- ==========================================
local function getNPCType(npc)
    if npc:HasTag("GhostAnomaly") then return "Ghost", true end
    if npc:HasTag("StalkerJumpscare") then return "Stalker", true end
    if npc:HasTag("AnomalyShadow") then return "Shadow", true end
    if npc:HasTag("TallMonsterHead") then return "TallMonster", true end
    if npc:HasTag("Skinwalker") then return "Skinwalker", true end
    if not npc:FindFirstChild("Humanoid") then
        local hc = 0
        for _, c in pairs(npc:GetChildren()) do if c.Name:find("^Head") then hc = hc + 1 end end
        if hc >= 4 then return "Hider", true end
    end
    for _, attr in ipairs({ "CameraEffect", "CameraEffect2", "PhotoEffect", "PhotoEffect2" }) do
        local val = npc:GetAttribute(attr)
        if val then
            for _, r in ipairs(ANOMALY_REVEALS) do
                if val == r then
                    if r == "VoidPresence" or r == "HiddenFace" then return "Ghost", true end
                    return "Skinwalker", true
                end
            end
        end
    end
    if npc:GetAttribute("SecondFace") or npc:GetAttribute("DifferentFace") then return "Skinwalker", true end
    if npc:FindFirstChild("VoidHighlight") then return "Ghost", true end
    if npc:FindFirstChild("NoFaceBillboard") then return "Ghost", true end
    for _, pn in ipairs(SKINWALKER_PARTS) do
        local p = npc:FindFirstChild(pn)
        if p and p:IsA("BasePart") and p.Transparency < 0.5 then return "Skinwalker", true end
    end
    local se = npc:FindFirstChild("SecondEars")
    if se then
        for _, p in pairs(se:GetDescendants()) do
            if p:IsA("BasePart") and p.Transparency < 0.5 then return "Skinwalker", true end
        end
    end
    return "Normal", false
end

-- ==========================================
-- ESP
-- ==========================================
local function createESP(npc, npcType, isAnom)
    if espObjects[npc] then return end
    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("RootPart")
    if not root then return end
    if npcType ~= "Normal" and not categoryFilters[npcType] then return end
    if npcType == "Normal" and not categoryFilters.Normal then return end
    local color = isAnom and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    local bgColor = isAnom and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(0, 120, 0)

    local bb = Instance.new("BillboardGui")
    bb.Name = "AnomalyESP_" .. npc.Name; bb.Adornee = root
    bb.Size = UDim2.new(0, 200, 0, 80); bb.StudsOffset = Vector3.new(0, 3.5, 0); bb.AlwaysOnTop = true

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 0.3
    f.BackgroundColor3 = bgColor; f.BorderSizePixel = 2; f.BorderColor3 = color; f.Parent = bb
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 4); fc.Parent = f
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 24); nl.Position = UDim2.new(0, 0, 0, 2)
    nl.BackgroundTransparency = 1; nl.Text = npc.Name; nl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nl.TextScaled = true; nl.Font = Enum.Font.GothamBold; nl.TextStrokeTransparency = 0.3
    nl.TextStrokeColor3 = Color3.new(0, 0, 0); nl.Parent = f
    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, 0, 0, 24); sl.Position = UDim2.new(0, 0, 0, 28)
    sl.BackgroundTransparency = 1; sl.Text = isAnom and "[ANOMALY]" or "[ANIMAL]"
    sl.TextColor3 = color; sl.TextScaled = true; sl.Font = Enum.Font.GothamBlack
    sl.TextStrokeTransparency = 0.3; sl.TextStrokeColor3 = Color3.new(0, 0, 0); sl.Parent = f
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(0.9, 0, 0, 8); hb.Position = UDim2.new(0.05, 0, 0, 56)
    hb.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hb.BorderSizePixel = 1; hb.BorderColor3 = Color3.fromRGB(0, 0, 0); hb.Parent = f
    local hbc = Instance.new("UICorner"); hbc.CornerRadius = UDim.new(0, 2); hbc.Parent = hb
    local hf = Instance.new("Frame")
    hf.Size = UDim2.new(1, 0, 1, 0); hf.BackgroundColor3 = isAnom and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
    hf.BorderSizePixel = 0; hf.Parent = hb
    local hfc = Instance.new("UICorner"); hfc.CornerRadius = UDim.new(0, 2); hfc.Parent = hf
    bb.Parent = CoreGui
    local hl = Instance.new("Highlight")
    hl.Name = "AnomalyHighlight_" .. npc.Name; hl.Adornee = npc; hl.FillColor = color
    hl.FillTransparency = 0.65; hl.OutlineColor = color; hl.OutlineTransparency = 0.3
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = CoreGui
    espObjects[npc] = { billboard = bb, highlight = hl, hpFill = hf, statusLabel = sl, isAnom = isAnom, npcType = npcType, root = root }
end

local function updateESP()
    local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    for npc, data in pairs(espObjects) do
        if not npc or not npc.Parent then
            if data.billboard then data.billboard:Destroy() end
            if data.highlight then data.highlight:Destroy() end; espObjects[npc] = nil; continue end
        if not data.root or not data.root.Parent then data.root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("RootPart") end
        if not data.root then
            if data.billboard then data.billboard.Enabled = false end; if data.highlight then data.highlight.Enabled = false end; continue end
        local dist = hrp and (data.root.Position - hrp.Position).Magnitude or math.huge
        local bbInRange = dist <= NAMETAG_RANGE; local hlInRange = dist <= HIGHLIGHT_RANGE
        if tick() % 5 < 0.1 then
            local nt, ia = getNPCType(npc)
            if ia ~= data.isAnom or nt ~= data.npcType then
                data.isAnom = ia; data.npcType = nt
                local c = ia and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                data.statusLabel.Text = ia and "[ANOMALY]" or "[ANIMAL]"
                data.statusLabel.TextColor3 = c; data.highlight.FillColor = c; data.highlight.OutlineColor = c
            end
        end
        local catOk = categoryFilters[data.npcType]; if catOk == nil then catOk = true end
        local hum = npc:FindFirstChild("Humanoid"); local alive = not hum or hum.Health >= 0
        local inUse = npc:GetAttribute("InUse"); local active = inUse == nil or inUse == 1 or inUse == true
        local inMaxRange = dist <= 200
        if not espEnabled or not catOk or not bbInRange or not active or not inMaxRange then data.billboard.Enabled = false
        else
            if hum and data.hpFill then data.hpFill.Size = UDim2.new(math.max(0, hum.Health / hum.MaxHealth), 0, 1, 0) end
            data.billboard.Enabled = true
        end
        data.highlight.Enabled = espEnabled and catOk and hlInRange and active and inMaxRange
    end
end

local function scanNPCs()
    local ca, cn = 0, 0
    for _, npc in pairs(CollectionService:GetTagged("NPC")) do
        if npc:IsA("Model") and npc ~= player.Character then
            if not espObjects[npc] then local t, a = getNPCType(npc); createESP(npc, t, a) end
            local _, a = getNPCType(npc); if a then ca = ca + 1 else cn = cn + 1 end
        end
    end
    for _, tag in ipairs(ANOMALY_TAGS) do
        for _, npc in pairs(CollectionService:GetTagged(tag)) do
            if npc:IsA("Model") and npc ~= player.Character and not espObjects[npc] then
                local t, a = getNPCType(npc); createESP(npc, t, a)
                if a then ca = ca + 1 else cn = cn + 1 end
            end
        end
    end
    for _, npc in pairs(CollectionService:GetTagged("TallMonsterHead")) do
        if npc:IsA("Model") and npc ~= player.Character and not espObjects[npc] then createESP(npc, "TallMonster", true); ca = ca + 1 end
    end
    local nf = workspace:FindFirstChild("NPCs")
    if nf then
        for _, npc in pairs(nf:GetChildren()) do
            if npc:IsA("Model") and not espObjects[npc] then local t, a = getNPCType(npc); createESP(npc, t, a); if a then ca = ca + 1 else cn = cn + 1 end end
        end
    end
    anomalyCount, normalCount = ca, cn
end

local function cleanupESP()
    for npc, data in pairs(espObjects) do
        if not npc or not npc.Parent then
            if data.billboard then pcall(data.billboard.Destroy, data.billboard) end
            if data.highlight then pcall(data.highlight.Destroy, data.highlight) end; espObjects[npc] = nil end
    end
end

-- ==========================================
-- ICON + MENU
-- ==========================================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "AnomalyHub"; mainGui.ResetOnSpawn = false; mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = CoreGui

-- === MAIN MENU ===
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 520, 0, 460); menuFrame.Position = UDim2.new(0.12, 0, 0.12, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(32, 31, 31); menuFrame.BorderSizePixel = 0; menuFrame.Visible = false
menuFrame.Parent = mainGui; menuFrame.Active = true; menuFrame.Draggable = true
local menuCorner = Instance.new("UICorner"); menuCorner.CornerRadius = UDim.new(0, 10); menuCorner.Parent = menuFrame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 50); header.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
header.BorderSizePixel = 0; header.Parent = menuFrame
local headerCorner = Instance.new("UICorner"); headerCorner.CornerRadius = UDim.new(0, 10); headerCorner.Parent = header
header.Text = "MAIN HUB"; header.Font = Enum.Font.SourceSans; header.TextSize = 42
header.TextColor3 = Color3.fromRGB(255, 255, 255); header.TextStrokeColor3 = Color3.fromRGB(255, 204, 0)
header.TextStrokeTransparency = 0.58

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32); closeBtn.Position = UDim2.new(1, -40, 0, 9)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextScaled = true; closeBtn.Font = Enum.Font.GothamBold; closeBtn.Parent = header
local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0, 6); closeCorner.Parent = closeBtn

local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, -12, 1, -60); sf.Position = UDim2.new(0, 6, 0, 56)
sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 5
sf.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.Parent = menuFrame
local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10); pad.PaddingTop = UDim.new(0, 6); pad.Parent = sf
local lay = Instance.new("UIListLayout"); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Padding = UDim.new(0, 4); lay.Parent = sf

local function hdr(t)
    local h = Instance.new("TextLabel"); h.Size = UDim2.new(1, 0, 0, 22); h.BackgroundTransparency = 1
    h.Text = t; h.TextColor3 = Color3.fromRGB(220, 200, 120); h.TextScaled = true
    h.TextXAlignment = Enum.TextXAlignment.Left; h.Font = Enum.Font.GothamBold; h.Parent = sf
end

local function tgl(name, key, state, color)
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 30); bg.BackgroundColor3 = Color3.fromRGB(42, 41, 41); bg.BorderSizePixel = 0; bg.Parent = sf
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 5); bgc.Parent = bg
    local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 3, 0, 16); ind.Position = UDim2.new(0, 6, 0, 7); ind.BackgroundColor3 = color; ind.BorderSizePixel = 0; ind.Parent = bg
    local inc = Instance.new("UICorner"); inc.CornerRadius = UDim.new(0, 2); inc.Parent = ind
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextScaled = true; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.GothamSemibold; lbl.Parent = bg
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 32, 0, 20); btn.Position = UDim2.new(1, -38, 0, 5); btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 45) or Color3.fromRGB(75, 75, 85); btn.Text = ""; btn.Parent = bg
    local btnc = Instance.new("UICorner"); btnc.CornerRadius = UDim.new(0, 4); btnc.Parent = btn
    local circ = Instance.new("Frame"); circ.Size = UDim2.new(0, 14, 0, 14); circ.Position = state and UDim2.new(1, -16, 0, 3) or UDim2.new(0, 2, 0, 3); circ.BackgroundColor3 = Color3.fromRGB(255, 255, 255); circ.BackgroundTransparency = 0.15; circ.BorderSizePixel = 0; circ.Parent = btn
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 7); cc.Parent = circ
    local en = state
    btn.MouseButton1Click:Connect(function()
        en = not en; if key == "ESP_MASTER" then espEnabled = en; categoryFilters[key] = en else categoryFilters[key] = en end
        btn.BackgroundColor3 = en and Color3.fromRGB(0, 170, 45) or Color3.fromRGB(75, 75, 85)
        circ:TweenPosition(en and UDim2.new(1, -16, 0, 3) or UDim2.new(0, 2, 0, 3), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)
end

local function bigBtn(name, color, callback)
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 34); bg.BackgroundColor3 = Color3.fromRGB(42, 41, 41); bg.BorderSizePixel = 0; bg.Parent = sf
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 5); bgc.Parent = bg
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -12, 1, -6); btn.Position = UDim2.new(0, 6, 0, 3); btn.BackgroundColor3 = color; btn.Text = name; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextScaled = true; btn.Font = Enum.Font.GothamBold; btn.Parent = bg
    local btnc = Instance.new("UICorner"); btnc.CornerRadius = UDim.new(0, 4); btnc.Parent = btn
    btn.MouseButton1Click:Connect(callback)
end

-- Menu content
local statLbl = Instance.new("TextLabel")
statLbl.Size = UDim2.new(1, 0, 0, 20); statLbl.BackgroundTransparency = 1
statLbl.Text = "Anomalies: 0 | Normals: 0"; statLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
statLbl.TextScaled = true; statLbl.TextXAlignment = Enum.TextXAlignment.Left; statLbl.Font = Enum.Font.GothamBold; statLbl.Parent = sf

local sep = Instance.new("Frame"); sep.Size = UDim2.new(1, 0, 0, 1); sep.BackgroundColor3 = Color3.fromRGB(60, 60, 70); sep.BorderSizePixel = 0; sep.Parent = sf

hdr("FILTERS")
tgl("ESP Master", "ESP_MASTER", true, Color3.fromRGB(100, 180, 255))
tgl("Ghost", "Ghost", true, Color3.fromRGB(200, 100, 255))
tgl("Stalker", "Stalker", true, Color3.fromRGB(255, 50, 50))
tgl("Hider", "Hider", true, Color3.fromRGB(255, 150, 0))
tgl("Tall Monster", "TallMonster", true, Color3.fromRGB(200, 0, 200))
tgl("Skinwalker", "Skinwalker", true, Color3.fromRGB(255, 0, 100))
tgl("Shadow", "Shadow", true, Color3.fromRGB(100, 100, 255))
tgl("Normal", "Normal", true, Color3.fromRGB(0, 255, 0))

local sep2 = Instance.new("Frame"); sep2.Size = UDim2.new(1, 0, 0, 1); sep2.BackgroundColor3 = Color3.fromRGB(60, 60, 70); sep2.BorderSizePixel = 0; sep2.Parent = sf
bigBtn("REFRESH NPC", Color3.fromRGB(50, 50, 60), function() scanNPCs() end)

local sep3 = Instance.new("Frame"); sep3.Size = UDim2.new(1, 0, 0, 1); sep3.BackgroundColor3 = Color3.fromRGB(60, 60, 70); sep3.BorderSizePixel = 0; sep3.Parent = sf

hdr("LEGEND")
local legendItems = {
    {"Ghost", Color3.fromRGB(200, 100, 255)}, {"Stalker", Color3.fromRGB(255, 50, 50)},
    {"Hider", Color3.fromRGB(255, 150, 0)}, {"Tall Monster", Color3.fromRGB(200, 0, 200)},
    {"Skinwalker", Color3.fromRGB(255, 0, 100)}, {"Shadow", Color3.fromRGB(100, 100, 255)},
    {"Normal", Color3.fromRGB(0, 255, 0)}
}
for _, it in ipairs(legendItems) do
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 18); bg.BackgroundTransparency = 1; bg.Parent = sf
    local box = Instance.new("Frame"); box.Size = UDim2.new(0, 10, 0, 10); box.Position = UDim2.new(0, 0, 0, 4); box.BackgroundColor3 = it[2]; box.BorderSizePixel = 0; box.Parent = bg
    local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1, -16, 1, 0); lb.Position = UDim2.new(0, 14, 0, 0); lb.BackgroundTransparency = 1; lb.Text = it[1]; lb.TextColor3 = it[2]; lb.TextScaled = true; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Font = Enum.Font.Gotham; lb.Parent = bg
end

local footerLbl = Instance.new("TextLabel")
footerLbl.Size = UDim2.new(1, 0, 0, 16); footerLbl.BackgroundTransparency = 1
footerLbl.Text = "ESP v6 | Shift=Toggle"; footerLbl.TextColor3 = Color3.fromRGB(100, 100, 110)
footerLbl.TextScaled = true; footerLbl.TextXAlignment = Enum.TextXAlignment.Left; footerLbl.Font = Enum.Font.Gotham; footerLbl.Parent = sf

closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false; menuFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then espEnabled = not espEnabled end
end)

-- === FLOATING ICON ===
local iconBtn = Instance.new("ImageButton")
iconBtn.Size = UDim2.new(0, 60, 0, 60); iconBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); iconBtn.BackgroundTransparency = 0.2
iconBtn.BorderSizePixel = 0; iconBtn.Image = "rbxassetid://74010930701899"
iconBtn.Parent = mainGui
local iconCorner = Instance.new("UICorner"); iconCorner.CornerRadius = UDim.new(0, 12); iconCorner.Parent = iconBtn

local isDragging = false; local isPressed = false
local pressStartTime = 0; local mouseDownPos = nil; local iconStartPos = nil
local menuOpen = false

iconBtn.MouseButton1Down:Connect(function()
    isPressed = true; isDragging = false
    pressStartTime = tick()
    mouseDownPos = UserInputService:GetMouseLocation()
    iconStartPos = iconBtn.Position
end)
iconBtn.MouseButton1Up:Connect(function()
    isPressed = false
    if not isDragging and (tick() - pressStartTime) < 0.3 then
        menuOpen = not menuOpen; menuFrame.Visible = menuOpen
    end
    isDragging = false
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isPressed then
        local delta = UserInputService:GetMouseLocation() - mouseDownPos
        if delta.Magnitude > 10 then isDragging = true end
        if isDragging then
            iconBtn.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        end
    end
end)

-- Events
CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(npc) if npc:IsA("Model") then task.wait(0.5); local t, a = getNPCType(npc); createESP(npc, t, a) end end)
CollectionService:GetInstanceRemovedSignal("NPC"):Connect(function(npc)
    if espObjects[npc] then local d = espObjects[npc]; if d.billboard then pcall(d.billboard.Destroy, d.billboard) end; if d.highlight then pcall(d.highlight.Destroy, d.highlight) end; espObjects[npc] = nil end
end)

RunService.RenderStepped:Connect(function()
    scanNPCs(); updateESP(); cleanupESP()
    statLbl.Text = "Anomalies: " .. anomalyCount .. " | Normals: " .. normalCount
end)

-- Init
task.wait(1); scanNPCs()

-- Abunol part 1
local abunol = Instance.new("Part")
abunol.Name = "Abunol"; abunol.Transparency = 1
abunol.Size = Vector3.new(4.5, 5.1, 0.001)
abunol.Position = Vector3.new(-186.05, 12.15, -5.1)
abunol.Anchored = true; abunol.Orientation = Vector3.new(0, -90, 0); abunol.Parent = workspace
local decal = Instance.new("Decal")
decal.Face = Enum.NormalId.Front; decal.Texture = "rbxassetid://71664025078228"
decal.Parent = abunol

-- Abunol part 2
local abunol2 = Instance.new("Part")
abunol2.Name = "Abunol"; abunol2.Transparency = 1
abunol2.Size = Vector3.new(4.5, 5.1, 0.001)
abunol2.Position = Vector3.new(-122.55, 6.95, 21.4)
abunol2.Anchored = true; abunol2.Orientation = Vector3.new(0, 0, 0); abunol2.Parent = workspace
local decal2 = Instance.new("Decal")
decal2.Face = Enum.NormalId.Front; decal2.Texture = "rbxassetid://71664025078228"
decal2.Parent = abunol2

return "ESP v6 loaded"
