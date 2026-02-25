-- ==========================================
-- MENU VIP PRO V38 (Hãy theo dõi tôi)
-- ==========================================
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local State = {
    Instant = false, Noclip = false, LowGfx = false, Speed = false, Jump = false,
    InfJump = false, PlayerLight = false, ESP = false, AntiAfk = true, AntiStun = false, 
    WalkOnWater = false, XRay = false,
    SpeedValue = 60, JumpValue = 120, LightRange = 60, LightBrightness = 3 
}

-- [BẢNG MÀU CHỦ ĐẠO - PREMIUM DARK MODE]
local Theme = {
    MainBg = Color3.fromRGB(20, 20, 26),      
    HeaderBg = Color3.fromRGB(26, 26, 34),    
    TabBg = Color3.fromRGB(24, 24, 30),       
    ItemBg = Color3.fromRGB(35, 35, 45),      
    Stroke = Color3.fromRGB(60, 60, 75),      
    TextTitle = Color3.fromRGB(245, 245, 245),
    TextDim = Color3.fromRGB(160, 160, 175),  
    AccentOn = Color3.fromRGB(46, 204, 113),  
    AccentOff = Color3.fromRGB(255, 71, 87),  
    Brand = Color3.fromRGB(0, 200, 255),      
    BrandGradient = Color3.fromRGB(150, 100, 255) 
}

-- [1. GIAO DIỆN CHÍNH]
local gui = Instance.new("ScreenGui")
gui.Name = "MobileProMax"
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local guiParent = player:WaitForChild("PlayerGui")
pcall(function()
    if gethui and type(gethui) == "function" then
        local hui = gethui()
        if hui then guiParent = hui end
    elseif game:GetService("CoreGui") then
        guiParent = game:GetService("CoreGui")
    end
end)
gui.Parent = guiParent

-- [NÚT MỞ MENU]
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 110, 0, 40)
openBtn.Position = UDim2.new(0, 15, 0, 15)
openBtn.Text = "MỞ MENU"
openBtn.BackgroundColor3 = Theme.MainBg
openBtn.BackgroundTransparency = 0.05
openBtn.TextColor3 = Theme.Brand
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 12
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Color = Theme.Brand; openStroke.Thickness = 1.5; openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local function clickAnimate(obj)
    local scale = Instance.new("UIScale", obj)
    TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.92}):Play()
    task.wait(0.1)
    TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1}):Play()
    task.delay(0.3, function() scale:Destroy() end)
end

local btnDragToggle, btnDragStart, btnStartPos
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragToggle = true; btnDragStart = input.Position; btnStartPos = openBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if btnDragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        openBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + (input.Position.X - btnDragStart.X), btnStartPos.Y.Scale, btnStartPos.Y.Offset + (input.Position.Y - btnDragStart.Y))
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then btnDragToggle = false end end)

-- [KHUNG CHÍNH MENU]
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 450)
frame.Position = UDim2.new(0.5, -170, 0.5, -225)
frame.BackgroundColor3 = Theme.MainBg
frame.BackgroundTransparency = 0.05 
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
local frameStroke = Instance.new("UIStroke", frame); frameStroke.Color = Theme.Stroke; frameStroke.Thickness = 1

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Theme.HeaderBg; header.BackgroundTransparency = 0; header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 18)
local headerCover = Instance.new("Frame", header) 
headerCover.Size = UDim2.new(1, 0, 0, 15); headerCover.Position = UDim2.new(0, 0, 1, -15)
headerCover.BackgroundColor3 = Theme.HeaderBg; headerCover.BackgroundTransparency = 0; headerCover.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, 0, 1, 0); titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MENU PRO MAX"
titleLabel.TextColor3 = Color3.new(1, 1, 1); titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextSize = 14
local titleGradient = Instance.new("UIGradient", titleLabel)
titleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Brand), ColorSequenceKeypoint.new(1, Theme.BrandGradient)})

-- [KÉO THẢ MENU]
local dragToggle, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStart = input.Position; startPos = frame.Position end
end)
UIS.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (input.Position.Y - dragStart.Y))
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end end)

-- [HỆ THỐNG 4 TAB CÂN ĐỐI]
local tabBar = Instance.new("Frame", frame)
tabBar.Size = UDim2.new(1, 0, 0, 38); tabBar.Position = UDim2.new(0, 0, 0, 45)
tabBar.BackgroundColor3 = Theme.TabBg; tabBar.BackgroundTransparency = 0; tabBar.BorderSizePixel = 0
local function createTab(name, x, width)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(width, 0, 1, 0); btn.Position = UDim2.new(x, 0, 0, 0)
    btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 10
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0.5, 0, 0, 3); indicator.Position = UDim2.new(0.25, 0, 1, -3)
    indicator.BackgroundColor3 = Theme.Brand; indicator.BorderSizePixel = 0; indicator.Visible = false
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    return btn, indicator
end

--  Tab Menu 
local tab1, ind1 = createTab("NHÂN VẬT", 0, 0.25)
local tab2, ind2 = createTab("TIỆN ÍCH", 0.25, 0.25)
local tab3, ind3 = createTab("TP SAVE", 0.50, 0.25)
local tab4, ind4 = createTab("TP PLAYER", 0.75, 0.25)

local pageContainer = Instance.new("Frame", frame)
pageContainer.Size = UDim2.new(1, 0, 1, -95); pageContainer.Position = UDim2.new(0, 0, 0, 88)
pageContainer.BackgroundTransparency = 1

local function createPage()
    local pg = Instance.new("ScrollingFrame", pageContainer)
    pg.Size = UDim2.new(1, 0, 1, 0); pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 3; pg.ScrollBarImageColor3 = Theme.Brand; pg.Visible = false; pg.BorderSizePixel = 0
    local layout = Instance.new("UIListLayout", pg)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", pg).PaddingTop = UDim.new(0, 10); Instance.new("UIPadding", pg).PaddingBottom = UDim.new(0, 30) 
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
        pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 60) 
    end)
    return pg
end
local page1, page2, page3, page4 = createPage(), createPage(), createPage(), createPage()

local function showTab(pg, tb, ind)
    for _, p in pairs({page1, page2, page3, page4}) do p.Visible = false end
    for _, t in pairs({tab1, tab2, tab3, tab4}) do t.TextColor3 = Theme.TextDim end
    for _, i in pairs({ind1, ind2, ind3, ind4}) do i.Visible = false end
    pg.Visible = true; tb.TextColor3 = Theme.TextTitle; ind.Visible = true
    ind.Size = UDim2.new(0, 0, 0, 3)
    TweenService:Create(ind, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0.5, 0, 0, 3)}):Play()
end
tab1.MouseButton1Click:Connect(function() showTab(page1, tab1, ind1) end)
tab2.MouseButton1Click:Connect(function() showTab(page2, tab2, ind2) end)
tab3.MouseButton1Click:Connect(function() showTab(page3, tab3, ind3) end)
tab4.MouseButton1Click:Connect(function() showTab(page4, tab4, ind4) end)
showTab(page1, tab1, ind1)

local opened = true
openBtn.MouseButton1Click:Connect(function()
    clickAnimate(openBtn)
    opened = not opened
    openBtn.Text = opened and "ĐÓNG MENU" or "MỞ MENU"
    openBtn.TextColor3 = opened and Theme.AccentOff or Theme.Brand
    TweenService:Create(openStroke, TweenInfo.new(0.3), {Color = opened and Theme.AccentOff or Theme.Brand}):Play()
    frame:TweenPosition(opened and UDim2.new(0.5, -170, 0.5, -225) or UDim2.new(0.5, -170, 1.2, 0), "Out", "Back", 0.5)
end)

-- [CÁC HÀM TẠO NÚT VÀ CÔNG TẮC]
local function createButton(parent, text, color, callback)
    local btnFrame = Instance.new("Frame", parent)
    btnFrame.Size = UDim2.new(0.9, 0, 0, 42); btnFrame.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", btnFrame)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = color; stroke.Thickness = 1; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local title = Instance.new("TextLabel", btn)
    title.Size = UDim2.new(1, 0, 1, 0); title.BackgroundTransparency = 1; title.Text = text
    title.TextColor3 = color; title.Font = Enum.Font.GothamBold; title.TextSize = 13
    btn.MouseButton1Click:Connect(function()
        clickAnimate(btn); TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Theme.TextTitle}):Play()
        task.wait(0.15); TweenService:Create(stroke, TweenInfo.new(0.3), {Color = color}):Play(); callback()
    end)
    return btn
end

local function createDualButtons(parent, text1, color1, cb1, text2, color2, cb2)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.9, 0, 0, 42); frame.BackgroundTransparency = 1
    local function makeBtn(xPos, txt, col, cb)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.48, 0, 1, 0); btn.Position = UDim2.new(xPos, 0, 0, 0)
        btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn); stroke.Color = col; stroke.Thickness = 1; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local title = Instance.new("TextLabel", btn)
        title.Size = UDim2.new(1, 0, 1, 0); title.BackgroundTransparency = 1; title.Text = txt
        title.TextColor3 = col; title.Font = Enum.Font.GothamBold; title.TextSize = 12
        btn.MouseButton1Click:Connect(function()
            clickAnimate(btn); TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Theme.TextTitle}):Play()
            task.wait(0.15); TweenService:Create(stroke, TweenInfo.new(0.3), {Color = col}):Play(); cb()
        end)
    end
    makeBtn(0, text1, color1, cb1); makeBtn(0.52, text2, color2, cb2)
end

local function createToggle(parent, text, defaultState, callback)
    local btnFrame = Instance.new("Frame", parent)
    btnFrame.Size = UDim2.new(0.9, 0, 0, 44); btnFrame.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", btnFrame)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.Text = ""; btn.AutoButtonColor = false 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1
    local title = Instance.new("TextLabel", btn)
    title.Size = UDim2.new(0.7, 0, 1, 0); title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1; title.Text = text; title.TextColor3 = Theme.TextTitle; title.Font = Enum.Font.GothamSemibold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left
    local status = Instance.new("TextLabel", btn)
    status.Size = UDim2.new(0.2, 0, 1, 0); status.Position = UDim2.new(0.75, 0, 0, 0)
    status.BackgroundTransparency = 1; status.Font = Enum.Font.GothamBold; status.TextSize = 12; status.TextXAlignment = Enum.TextXAlignment.Right
    local active = defaultState or false
    status.Text = active and "ON" or "OFF"
    status.TextColor3 = active and Theme.AccentOn or Theme.AccentOff
    stroke.Color = active and Theme.AccentOn or Theme.Stroke
    btn.BackgroundColor3 = active and Color3.fromRGB(35, 45, 40) or Theme.ItemBg
    
    btn.MouseButton1Click:Connect(function()
        clickAnimate(btn); active = not active; status.Text = active and "ON" or "OFF"
        TweenService:Create(status, TweenInfo.new(0.2), {TextColor3 = active and Theme.AccentOn or Theme.AccentOff}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = active and Theme.AccentOn or Theme.Stroke}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(35, 45, 40) or Theme.ItemBg}):Play()
        callback(active)
    end)
end

local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.9, 0, 0, 48); frame.BackgroundTransparency = 1
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Theme.ItemBg
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", bg); stroke.Color = Theme.Stroke; stroke.Thickness = 1
    local titleLabel = Instance.new("TextLabel", bg)
    titleLabel.Size = UDim2.new(0.7, 0, 0.4, 0); titleLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = text; titleLabel.TextColor3 = Theme.TextDim; titleLabel.Font = Enum.Font.GothamSemibold; titleLabel.TextSize = 12; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local valLabel = Instance.new("TextLabel", bg)
    valLabel.Size = UDim2.new(0.25, 0, 0.4, 0); valLabel.Position = UDim2.new(0.7, 0, 0.1, 0)
    valLabel.BackgroundTransparency = 1; valLabel.Text = tostring(default); valLabel.TextColor3 = Theme.Brand; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 12; valLabel.TextXAlignment = Enum.TextXAlignment.Right
    local track = Instance.new("Frame", bg)
    track.Size = UDim2.new(0.9, 0, 0.15, 0); track.Position = UDim2.new(0.05, 0, 0.65, 0); track.BackgroundColor3 = Theme.MainBg
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Theme.AccentOn
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + ((max - min) * pos))
        valLabel.Text = tostring(value); TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play(); callback(value)
    end
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end end)
    UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    callback(default)
    return bg
end

local function optimizePart(obj)
    if State.LowGfx then
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then 
            obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0; obj.CastShadow = false 
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled = false end
    end
end

-- [TAB 1: NHÂN VẬT]
createToggle(page1, "🛡️ Chống ngã & Chống văng xa", false, function(v) State.AntiStun = v end)
createToggle(page1, "🏃 Chạy nhanh", false, function(v) State.Speed = v end)
createSlider(page1, "Tốc độ chạy", 16, 1000, 60, function(val) State.SpeedValue = val end)
createToggle(page1, "🦘 Nhảy cao", false, function(v) State.Jump = v end)
createSlider(page1, "Lực nhảy", 50, 300, 120, function(val) State.JumpValue = val end)
createToggle(page1, "🚀 Nhảy trên không", false, function(v) State.InfJump = v end) 
createToggle(page1, "🐿️ Lấy đồ nhanh", false, function(v) 
    State.Instant = v 
    if v then for _, prompt in pairs(workspace:GetDescendants()) do if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0; prompt.MaxActivationDistance = 25 end end end
end)
createToggle(page1, "👻 Đi xuyên tường", false, function(v) State.Noclip = v end)

local waterPart = Instance.new("Part")
waterPart.Size = Vector3.new(6, 1, 6); waterPart.Transparency = 1; waterPart.Anchored = true; waterPart.CanCollide = true
createToggle(page1, "🌊 Đi trên mặt nước", false, function(v) State.WalkOnWater = v end)

local xrayMats = {}
local origAmbient = Lighting.Ambient
createToggle(page1, "👀 Nhìn xuyên map (X-Ray)", false, function(v) 
    State.XRay = v 
    task.spawn(function()
        if v then
            Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.Brightness = 3
            local descendants = workspace:GetDescendants()
            for i, obj in ipairs(descendants) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) and obj.Name ~= "Terrain" then
                    if not xrayMats[obj] then xrayMats[obj] = {obj.Transparency, obj.Material} end
                    obj.Transparency = 0.8; obj.Material = Enum.Material.SmoothPlastic
                end
                if i % 250 == 0 then task.wait() end 
            end
        else
            Lighting.Ambient = origAmbient; Lighting.Brightness = 1
            local count = 0
            for obj, data in pairs(xrayMats) do
                if obj and obj.Parent then obj.Transparency = data[1]; obj.Material = data[2] end
                count = count + 1; if count % 250 == 0 then task.wait() end
            end
            xrayMats = {}
        end
    end)
end)

createToggle(page1, "🕹️ giảm FPS  (Giảm đồ họa)", false, function(v) 
    State.LowGfx = v 
    if v then 
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9; pcall(function() settings().Rendering.QualityLevel = 1 end)
        pcall(function() workspace.Terrain.WaterWaveSize = 0; workspace.Terrain.WaterWaveSpeed = 0; workspace.Terrain.WaterReflectance = 0; workspace.Terrain.WaterTransparency = 0; workspace.Terrain.Decoration = false end)
        for _, obj in pairs(Lighting:GetChildren()) do if obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") then obj.Enabled = false end end
        for _, obj in pairs(workspace:GetDescendants()) do optimizePart(obj) end
    else 
        Lighting.GlobalShadows = true; pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end) 
    end
end)

createToggle(page1, "🔴 ESP người chơi", false, function(v) State.ESP = v end)

createToggle(page1, "💡 Ánh sáng quanh người chơi", false, function(v) 
    State.PlayerLight = v 
    if not v and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then 
        local light = player.Character.HumanoidRootPart:FindFirstChild("PlayerPointLight"); if light then light:Destroy() end 
    end
end)
createSlider(page1, "Phạm vi sáng", 50, 1000, 60, function(val) State.LightRange = val end)
createSlider(page1, "Độ sáng", 0, 5, 3, function(val) State.LightBrightness = val end)

-- Thiết lập nhảy cho InfJump
UIS.JumpRequest:Connect(function() 
    if State.InfJump and player.Character then 
        local hum = player.Character:FindFirstChildOfClass("Humanoid") 
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end 
    end 
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt) if State.Instant then pcall(function() fireproximityprompt(prompt) end) end end)


-- [TAB 2: TIỆN ÍCH]
createToggle(page2, "🛡️ Chống bị kick (Anti-AFK)", true, function(v) State.AntiAfk = v end)

-- Chuyển từ Bản Đồ sang
createDualButtons(page2, "🌞 TRỜI SÁNG", Color3.fromRGB(243, 156, 18), function() Lighting.ClockTime = 12 end, "🌚 TRỜI TỐI", Color3.fromRGB(160, 32, 240), function() Lighting.ClockTime = 0 end)

createDualButtons(page2, "🔄 VÀO LẠI SERVER", Theme.AccentOn, function()
    if #Players:GetPlayers() <= 1 then
        player:Kick("\nRejoining...")
        task.wait()
        TeleportService:Teleport(game.PlaceId, player)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
end, "🌐 ĐỔI SERVER", Theme.Brand, function()
    local Api = "https://games.roblox.com/v1/games/"
    local _place = game.PlaceId
    local _servers = Api..tostring(_place).."/servers/Public?sortOrder=Asc&limit=100"
    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return HttpService:JSONDecode(Raw)
    end
    local Server, Next; repeat
        local Servers = ListServers(Next)
        Server = Servers.data[1]
        Next = Servers.nextPageCursor
    until Server
    TeleportService:TeleportToPlaceInstance(_place, Server.id, player)
end)

createButton(page2, "💻 Lệnh admin (Infinite Yield)", Theme.AccentOn, function() pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end) end)
createButton(page2, "🔨 LẤY BTOOLS", Theme.Brand, function() pcall(function() loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/BTools.txt"))() end) end)
createButton(page2, "🕊️ FLY (Bay)", Theme.Brand, function() pcall(function() loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\40\39\104\116\116\112\115\58\47\47\103\105\115\116\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\109\101\111\122\111\101\89\84\47\98\102\48\51\55\100\102\102\57\102\48\97\55\48\48\49\55\51\48\52\100\100\100\54\55\102\100\99\100\51\55\48\47\114\97\119\47\101\49\52\101\55\52\102\52\50\53\98\48\54\48\100\102\53\50\51\51\52\51\99\102\51\48\98\55\56\55\48\55\52\101\98\51\99\53\100\50\47\97\114\99\101\117\115\37\50\53\50\48\120\37\50\53\50\48\102\108\121\37\50\53\50\48\50\37\50\53\50\48\111\98\102\108\117\99\97\116\111\114\39\41\44\116\114\117\101\41\41\40\41\10\10")() end) end)
createButton(page2, "📂 MENU TP SAVE V2", Theme.Brand, function() pcall(function() loadstring(game:HttpGet(('https://raw.githubusercontent.com/0Ben1/fe/main/Tp%20Place%20GUI'),true))() end) end)

-- [TAB 3: VỊ TRÍ TP SAVE]
local savedLocCount = 0
local function createPosItem(name, cframe)
    local item = Instance.new("Frame", page3)
    item.Size = UDim2.new(0.9, 0, 0, 48); item.BackgroundColor3 = Theme.ItemBg
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", item); stroke.Color = Theme.Stroke; stroke.Thickness = 1
    local nameBox = Instance.new("TextBox", item)
    nameBox.Size = UDim2.new(0.45, 0, 1, 0); nameBox.Position = UDim2.new(0.05, 0, 0, 0)
    nameBox.Text = name; nameBox.TextColor3 = Theme.TextTitle; nameBox.Font = Enum.Font.GothamSemibold; nameBox.TextSize = 12
    nameBox.BackgroundTransparency = 1; nameBox.TextXAlignment = Enum.TextXAlignment.Left; nameBox.ClearTextOnFocus = false
    local tpBtn = Instance.new("TextButton", item)
    tpBtn.Size = UDim2.new(0.25, 0, 0.6, 0); tpBtn.Position = UDim2.new(0.53, 0, 0.2, 0)
    tpBtn.Text = "TP"; tpBtn.BackgroundColor3 = Theme.Brand; tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Font = Enum.Font.GothamBold; tpBtn.TextSize = 11; Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
    local delBtn = Instance.new("TextButton", item)
    delBtn.Size = UDim2.new(0.15, 0, 0.6, 0); delBtn.Position = UDim2.new(0.81, 0, 0.2, 0)
    delBtn.Text = "X"; delBtn.BackgroundColor3 = Theme.AccentOff; delBtn.TextColor3 = Color3.new(1,1,1)
    delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 12; Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
    
    tpBtn.MouseButton1Click:Connect(function() clickAnimate(tpBtn); if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = cframe end end)
    delBtn.MouseButton1Click:Connect(function() clickAnimate(delBtn); task.wait(0.1); item:Destroy() end)
end
createButton(page3, "📍 LƯU TỌA ĐỘ", Theme.AccentOn, function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedLocCount = savedLocCount + 1
        createPosItem("Vị trí " .. savedLocCount, player.Character.HumanoidRootPart.CFrame)
    end
end)

-- [TAB 4: TP NGƯỜI CHƠI]
local function updatePlayerList()
    for _, child in pairs(page4:GetChildren()) do if child.Name == "PlayerBtn_TP" or child.Name == "PaddingFrame" then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pFrame = Instance.new("Frame", page4); pFrame.Name = "PaddingFrame"; pFrame.Size = UDim2.new(0.9, 0, 0, 42); pFrame.BackgroundTransparency = 1
            local btn = Instance.new("TextButton", pFrame)
            btn.Name = "PlayerBtn_TP"; btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", btn); stroke.Color = Theme.Stroke; stroke.Thickness = 1
            
            local nLabel = Instance.new("TextLabel", btn)
            nLabel.Size = UDim2.new(0.7, 0, 1, 0); nLabel.Position = UDim2.new(0.05, 0, 0, 0); nLabel.BackgroundTransparency = 1
            nLabel.Text = "👤 " .. p.DisplayName; nLabel.TextColor3 = Theme.TextTitle; nLabel.Font = Enum.Font.GothamSemibold; nLabel.TextSize = 13; nLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local arrow = Instance.new("TextLabel", btn)
            arrow.Size = UDim2.new(0.2, 0, 1, 0); arrow.Position = UDim2.new(0.75, 0, 0, 0); arrow.BackgroundTransparency = 1
            arrow.Text = " BAY ➜ "; arrow.TextColor3 = Theme.Brand; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 11; arrow.TextXAlignment = Enum.TextXAlignment.Right
            
            btn.MouseButton1Click:Connect(function()
                clickAnimate(btn)
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    TweenService:Create(stroke, TweenInfo.new(0.3), {Color = Theme.AccentOn}):Play()
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                    task.wait(0.5); TweenService:Create(stroke, TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                end
            end)
        end
    end
end
createButton(page4, "🔄 LÀM MỚI DANH SÁCH", Theme.Brand, updatePlayerList)
updatePlayerList()

-- ==============================================
-- [VÒNG LẶP HỆ THỐNG VÀ XỬ LÝ SỰ KIỆN]
-- ==============================================

player.Idled:Connect(function()
    if State.AntiAfk then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if State.Speed then hum.WalkSpeed = State.SpeedValue else hum.WalkSpeed = 16 end
        if State.Jump then hum.JumpPower = State.JumpValue else hum.JumpPower = 50 end
        if State.Noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        
        if State.AntiStun then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) 
            hum.PlatformStand = false
            if root then root.RotVelocity = Vector3.new(0, 0, 0) end
        else
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        end

        -- LOGIC WALK ON WATER
        if State.WalkOnWater and root then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
            if result and result.Material == Enum.Material.Water then
                waterPart.Parent = workspace
                waterPart.CFrame = CFrame.new(result.Position.X, result.Position.Y - 0.5, result.Position.Z)
            else
                waterPart.Parent = nil
            end
        else
            waterPart.Parent = nil
        end

        -- LOGIC ĐÈN PHÁT SÁNG
        if root then
            local light = root:FindFirstChild("PlayerPointLight")
            if State.PlayerLight then 
                if not light then 
                    light = Instance.new("PointLight", root)
                    light.Name = "PlayerPointLight"
                    light.Shadows = false 
                end 
                light.Brightness = State.LightBrightness
                light.Range = State.LightRange
            else 
                if light then light:Destroy() end 
            end
        end
        
        -- LOGIC ESP VÀ VIỀN ĐỎ
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local tChar = p.Character
                local head = tChar.Head
                
                if State.ESP or State.XRay then
                    local hl = tChar:FindFirstChild("Red_ESP_HL")
                    if not hl then
                        hl = Instance.new("Highlight", tChar)
                        hl.Name = "Red_ESP_HL"
                        hl.FillTransparency = 0.7
                        hl.FillColor = Color3.fromRGB(255, 0, 0) 
                        hl.OutlineColor = Color3.fromRGB(255, 0, 0) 
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                    end
                else
                    local hl = tChar:FindFirstChild("Red_ESP_HL")
                    if hl then hl:Destroy() end
                end

                if State.ESP then
                    local bgui = head:FindFirstChild("MobileESP_Name")
                    if not bgui then
                        bgui = Instance.new("BillboardGui", head)
                        bgui.Name = "MobileESP_Name"
                        bgui.Size = UDim2.new(0, 200, 0, 50)
                        bgui.StudsOffset = Vector3.new(0, 2, 0)
                        bgui.AlwaysOnTop = true
                        bgui.Adornee = head
                        
                        local tLabel = Instance.new("TextLabel", bgui)
                        tLabel.Name = "NameLabel"
                        tLabel.Size = UDim2.new(1, 0, 1, 0)
                        tLabel.BackgroundTransparency = 1
                        tLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
                        tLabel.TextStrokeTransparency = 0.2
                        tLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                        tLabel.Font = Enum.Font.GothamBold
                        tLabel.TextSize = 11
                    end
                    if root and tChar:FindFirstChild("HumanoidRootPart") then
                        local dist = math.floor((root.Position - tChar.HumanoidRootPart.Position).Magnitude)
                        bgui.NameLabel.Text = p.DisplayName .. "\n[" .. dist .. "m]"
                    else
                        bgui.NameLabel.Text = p.DisplayName
                    end
                else
                    local bgui = head:FindFirstChild("MobileESP_Name")
                    if bgui then bgui:Destroy() end
                end
            end
        end
    end
end)

workspace.DescendantAdded:Connect(function(v)
    if State.XRay and v:IsA("BasePart") and not v:IsDescendantOf(player.Character) and v.Name ~= "Terrain" then
        if not xrayMats[v] then xrayMats[v] = {v.Transparency, v.Material} end
        v.Transparency = 0.8
        v.Material = Enum.Material.SmoothPlastic
    end
    if State.Instant and v:IsA("ProximityPrompt") then v.HoldDuration = 0; v.MaxActivationDistance = 25 end
end)
