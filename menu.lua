-- ==========================================
-- MENU VIP PRO V42.7 (MAX CẤP + AURA + TỐI ƯU SIÊU MƯỢT)
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
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local State = {
    Instant = false, Noclip = false, LowGfx = false, Speed = false, Jump = false,
    InfJump = false, PlayerLight = false, ESP = false, AntiAfk = true, AntiStun = false, 
    XRay = false, LockPosition = false, AutoCollect = false, WaterWalk = false,
    SpinBot = false, SpinSpeed = 50, Hitbox = false, HitboxSize = 15, AutoClick = false, RGB = false,
    Reach = false, ReachSize = 15, FastAttack = false, FastAttackSpeed = 5,
    Aura = false, AuraColorIndex = 1,
    SpeedValue = 60, JumpValue = 120, LightRange = 60, LightBrightness = 3,
    MusicVolume = 5
}

-- [BẢNG MÀU]
local Theme = {
    MainBg = Color3.fromRGB(20, 20, 26), HeaderBg = Color3.fromRGB(26, 26, 34),    
    TabBg = Color3.fromRGB(24, 24, 30), ItemBg = Color3.fromRGB(35, 35, 45),      
    Stroke = Color3.fromRGB(60, 60, 75), TextTitle = Color3.fromRGB(210, 225, 240),
    TextDim = Color3.fromRGB(160, 160, 175), AccentOn = Color3.fromRGB(46, 204, 113),  
    AccentOff = Color3.fromRGB(255, 71, 87), Brand = Color3.fromRGB(0, 200, 255)      
}

local RGBElements = {}
local guiParent = player:WaitForChild("PlayerGui")
pcall(function()
    if gethui and type(gethui) == "function" then local hui = gethui() if hui then guiParent = hui end
    elseif game:GetService("CoreGui") then guiParent = game:GetService("CoreGui") end
end)
for _, v in pairs(guiParent:GetChildren()) do if v.Name == "MobileProMax" then v:Destroy() end end

local gui = Instance.new("ScreenGui")
gui.Name = "MobileProMax"
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.Parent = guiParent

-- ==========================================
-- HỆ THỐNG THÔNG BÁO GÓC MÀN HÌNH (TÍNH NĂNG 4)
-- ==========================================
local notifContainer = Instance.new("Frame", gui)
notifContainer.Size = UDim2.new(0, 200, 1, -100)
notifContainer.Position = UDim2.new(1, -210, 0, 50)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 9999
local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 8)

local function Notify(text)
    local f = Instance.new("Frame", notifContainer)
    f.Size = UDim2.new(1, 0, 0, 45)
    f.BackgroundColor3 = Theme.ItemBg
    f.BackgroundTransparency = 1
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = Theme.Brand; stroke.Thickness = 1.5; stroke.Transparency = 1
    
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -15, 1, 0); t.Position = UDim2.new(0, 10, 0, 0)
    t.BackgroundTransparency = 1; t.Text = text
    t.TextColor3 = Theme.TextTitle; t.Font = Enum.Font.GothamSemibold
    t.TextSize = 11; t.TextWrapped = true; t.TextTransparency = 1; t.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    task.delay(2.5, function()
        TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3); f:Destroy()
    end)
end

-- GUI CHÍNH
local screenOverlay = Instance.new("Frame", gui)
screenOverlay.Size = UDim2.new(2, 0, 2, 0); screenOverlay.Position = UDim2.new(-0.5, 0, -0.5, 0); screenOverlay.BackgroundColor3 = Color3.new(0,0,0); screenOverlay.Visible = false

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 45, 0, 45); openBtn.Position = UDim2.new(0, 15, 0, 15); openBtn.Text = "🇻🇳"; openBtn.BackgroundColor3 = Theme.MainBg; openBtn.BackgroundTransparency = 0.3; openBtn.TextColor3 = Theme.Brand; openBtn.Font = Enum.Font.GothamBold; openBtn.TextSize = 22; openBtn.ZIndex = 10
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
local openStroke = Instance.new("UIStroke", openBtn); openStroke.Color = Theme.Brand; openStroke.Thickness = 2; openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local btnDragToggle, btnDragStart, btnStartPos
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then btnDragToggle = true; btnDragStart = input.Position; btnStartPos = openBtn.Position end
end)
UIS.InputChanged:Connect(function(input)
    if btnDragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        openBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + (input.Position.X - btnDragStart.X), btnStartPos.Y.Scale, btnStartPos.Y.Offset + (input.Position.Y - btnDragStart.Y))
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then btnDragToggle = false end end)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 420, 0, 500); frame.Position = UDim2.new(0.5, -210, 0.53, -250); frame.BackgroundColor3 = Theme.MainBg; frame.BackgroundTransparency = 0.05; frame.ZIndex = 10
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
local frameStroke = Instance.new("UIStroke", frame); frameStroke.Color = Theme.Stroke; frameStroke.Thickness = 2; table.insert(RGBElements, {Type = "Frame", Stroke = frameStroke})

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 45); header.BackgroundColor3 = Theme.HeaderBg; header.BorderSizePixel = 0; header.ZIndex = 10
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 18)
local headerCover = Instance.new("Frame", header); headerCover.Size = UDim2.new(1, 0, 0, 15); headerCover.Position = UDim2.new(0, 0, 1, -15); headerCover.BackgroundColor3 = Theme.HeaderBg; headerCover.BorderSizePixel = 0; headerCover.ZIndex = 10
local headerStroke = Instance.new("UIStroke", header); headerStroke.Color = Theme.Stroke; headerStroke.Thickness = 1.5; headerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; table.insert(RGBElements, {Type = "Header", Stroke = headerStroke})

local titleLabel = Instance.new("TextLabel", header); titleLabel.Size = UDim2.new(1, 0, 1, 0); titleLabel.BackgroundTransparency = 1; titleLabel.Text = "MENU PRO MAX V42.7"; titleLabel.TextColor3 = Theme.TextTitle; titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextSize = 16; titleLabel.ZIndex = 10
local avatarImg = Instance.new("ImageLabel", header); avatarImg.Size = UDim2.new(0, 40, 0, 40); avatarImg.Position = UDim2.new(0, 10, 0, 8); avatarImg.BackgroundTransparency = 1; avatarImg.ZIndex = 10
pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)
local avatarStroke = Instance.new("UIStroke", avatarImg); avatarStroke.Color = Theme.Brand; avatarStroke.Thickness = 1.5; avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

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

local tabBar = Instance.new("Frame", frame); tabBar.Size = UDim2.new(1, 0, 0, 38); tabBar.Position = UDim2.new(0, 0, 0, 45); tabBar.BackgroundColor3 = Theme.TabBg; tabBar.BorderSizePixel = 0; tabBar.ZIndex = 10

local function createTab(name, x, width)
    local btn = Instance.new("TextButton", tabBar); btn.Size = UDim2.new(width, 0, 1, 0); btn.Position = UDim2.new(x, 0, 0, 0); btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Theme.TextDim; btn.Font = Enum.Font.GothamBold; btn.TextSize = 8; btn.ZIndex = 10
    local indicator = Instance.new("Frame", btn); indicator.Size = UDim2.new(0.5, 0, 0, 3); indicator.Position = UDim2.new(0.25, 0, 1, -3); indicator.BackgroundColor3 = Theme.Brand; indicator.BorderSizePixel = 0; indicator.Visible = false; indicator.ZIndex = 10
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    return btn, indicator
end

local tab1, ind1 = createTab("THÔNG TIN", 0.00, 0.14)
local tab2, ind2 = createTab("TÍNH NĂNG", 0.14, 0.14)
local tab3, ind3 = createTab("PLAYER",    0.28, 0.14)
local tab4, ind4 = createTab("TIỆN ÍCH",  0.42, 0.14)
local tab5, ind5 = createTab("NHẠC ID",   0.56, 0.12) 
local tab6, ind6 = createTab("TP SAVE",   0.68, 0.15)
local tab7, ind7 = createTab("TP PLAYER", 0.83, 0.17)

local pageContainer = Instance.new("Frame", frame); pageContainer.Size = UDim2.new(1, 0, 1, -95); pageContainer.Position = UDim2.new(0, 0, 0, 88); pageContainer.BackgroundTransparency = 1; pageContainer.ZIndex = 10

local function createPage()
    local pg = Instance.new("ScrollingFrame", pageContainer); pg.Size = UDim2.new(1, 0, 1, 0); pg.BackgroundTransparency = 1; pg.ScrollBarThickness = 3; pg.ScrollBarImageColor3 = Theme.Brand; pg.Visible = false; pg.BorderSizePixel = 0; pg.ZIndex = 10
    local layout = Instance.new("UIListLayout", pg); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder 
    Instance.new("UIPadding", pg).PaddingTop = UDim.new(0, 10); Instance.new("UIPadding", pg).PaddingBottom = UDim.new(0, 30) 
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 120) end)
    return pg
end
local page1, page2, page3, page4, page5, page6, page7 = createPage(), createPage(), createPage(), createPage(), createPage(), createPage(), createPage()

local function showTab(pg, tb, ind)
    for _, p in pairs({page1, page2, page3, page4, page5, page6, page7}) do p.Visible = false end
    for _, t in pairs({tab1, tab2, tab3, tab4, tab5, tab6, tab7}) do t.TextColor3 = Theme.TextDim end
    for _, i in pairs({ind1, ind2, ind3, ind4, ind5, ind6, ind7}) do i.Visible = false end
    pg.Visible = true; tb.TextColor3 = Theme.TextTitle; ind.Visible = true; ind.Size = UDim2.new(0, 0, 0, 3)
    TweenService:Create(ind, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0.5, 0, 0, 3)}):Play()
end

tab1.MouseButton1Click:Connect(function() showTab(page1, tab1, ind1) end)
tab2.MouseButton1Click:Connect(function() showTab(page2, tab2, ind2) end)
tab3.MouseButton1Click:Connect(function() showTab(page3, tab3, ind3) end)
tab4.MouseButton1Click:Connect(function() showTab(page4, tab4, ind4) end)
tab5.MouseButton1Click:Connect(function() showTab(page5, tab5, ind5) end)
tab6.MouseButton1Click:Connect(function() showTab(page6, tab6, ind6) end)
tab7.MouseButton1Click:Connect(function() showTab(page7, tab7, ind7) end)
showTab(page1, tab1, ind1)

openBtn.MouseButton1Click:Connect(function()
    local scale = Instance.new("UIScale", openBtn); TweenService:Create(scale, TweenInfo.new(0.1), {Scale = 0.9}):Play(); task.wait(0.1); TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1}):Play(); task.delay(0.3, function() scale:Destroy() end)
    local opened = (frame.Position.Y.Scale > 1)
    frame:TweenPosition(opened and UDim2.new(0.5, -210, 0.53, -250) or UDim2.new(0.5, -210, 1.2, 0), "Out", "Back", 0.5)
end)

local function createToggle(parent, text, varName, callback)
    local btnFrame = Instance.new("Frame", parent); btnFrame.Size = UDim2.new(0.9, 0, 0, 44); btnFrame.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", btnFrame); btn.Size = UDim2.new(1, 0, 1, 0); btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 10; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1.5
    
    local title = Instance.new("TextLabel", btn); title.Size = UDim2.new(0.7, 0, 1, 0); title.Position = UDim2.new(0.05, 0, 0, 0); title.BackgroundTransparency = 1; title.Text = text; title.TextColor3 = Theme.TextTitle; title.Font = Enum.Font.GothamSemibold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 10
    local status = Instance.new("TextLabel", btn); status.Size = UDim2.new(0.2, 0, 1, 0); status.Position = UDim2.new(0.75, 0, 0, 0); status.BackgroundTransparency = 1; status.Font = Enum.Font.GothamBold; status.TextSize = 12; status.TextXAlignment = Enum.TextXAlignment.Right; status.ZIndex = 10
    
    local active = State[varName]
    status.Text = active and "ON" or "OFF"; status.TextColor3 = active and Theme.AccentOn or Theme.AccentOff
    stroke.Color = State.RGB and Color3.fromHSV(tick() % 5 / 5, 1, 1) or (active and Theme.AccentOn or Theme.Stroke)
    btn.BackgroundColor3 = active and Color3.fromRGB(35, 45, 40) or Theme.ItemBg
    table.insert(RGBElements, {Type = "Toggle", Stroke = stroke, State = function() return State[varName] end})

    btn.MouseButton1Click:Connect(function()
        local s = Instance.new("UIScale", btn); TweenService:Create(s, TweenInfo.new(0.1), {Scale = 0.95}):Play(); task.wait(0.1); TweenService:Create(s, TweenInfo.new(0.1), {Scale = 1}):Play(); task.delay(0.2, function() s:Destroy() end)
        State[varName] = not State[varName]
        active = State[varName]
        status.Text = active and "ON" or "OFF"
        TweenService:Create(status, TweenInfo.new(0.2), {TextColor3 = active and Theme.AccentOn or Theme.AccentOff}):Play()
        if not State.RGB then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = active and Theme.AccentOn or Theme.Stroke}):Play() end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(35, 45, 40) or Theme.ItemBg}):Play()
        Notify(text .. " -> " .. (active and "BẬT" or "TẮT"))
        if callback then callback(active) end
    end)
    return btnFrame
end

local function createSlider(parent, text, min, max, varName, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(0.9, 0, 0, 48); frame.BackgroundTransparency = 1
    local bg = Instance.new("Frame", frame); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Theme.ItemBg; bg.ZIndex = 10; Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", bg); stroke.Color = State.RGB and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Theme.Stroke; stroke.Thickness = 1.5; table.insert(RGBElements, {Type = "Slider", Stroke = stroke})
    
    local titleLabel = Instance.new("TextLabel", bg); titleLabel.Size = UDim2.new(0.7, 0, 0.4, 0); titleLabel.Position = UDim2.new(0.05, 0, 0.1, 0); titleLabel.BackgroundTransparency = 1; titleLabel.Text = text; titleLabel.TextColor3 = Theme.TextDim; titleLabel.Font = Enum.Font.GothamSemibold; titleLabel.TextSize = 12; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.ZIndex = 10
    local valLabel = Instance.new("TextLabel", bg); valLabel.Size = UDim2.new(0.25, 0, 0.4, 0); valLabel.Position = UDim2.new(0.7, 0, 0.1, 0); valLabel.BackgroundTransparency = 1; valLabel.Text = tostring(State[varName]); valLabel.TextColor3 = Theme.Brand; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 12; valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.ZIndex = 10
    local track = Instance.new("Frame", bg); track.Size = UDim2.new(0.9, 0, 0.15, 0); track.Position = UDim2.new(0.05, 0, 0.65, 0); track.BackgroundColor3 = Theme.MainBg; track.ZIndex = 10; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", track); fill.Size = UDim2.new((State[varName] - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Theme.AccentOn; fill.ZIndex = 10; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + ((max - min) * pos))
        valLabel.Text = tostring(value); TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        State[varName] = value; if callback then callback(value) end
    end
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end end)
    UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    return frame
end

local function createButton(parent, text, color, callback)
    local btnFrame = Instance.new("Frame", parent); btnFrame.Size = UDim2.new(0.9, 0, 0, 42); btnFrame.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", btnFrame); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 10; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = color; stroke.Thickness = 1.5; table.insert(RGBElements, {Type = "Button", Stroke = stroke, DefaultColor = color})
    local title = Instance.new("TextLabel", btn); title.Size = UDim2.new(1, 0, 1, 0); title.BackgroundTransparency = 1; title.Text = text; title.TextColor3 = color; title.Font = Enum.Font.GothamBold; title.TextSize = 13; title.ZIndex = 10
    btn.MouseButton1Click:Connect(function()
        local s = Instance.new("UIScale", btn); TweenService:Create(s, TweenInfo.new(0.1), {Scale = 0.9}):Play(); task.wait(0.1); TweenService:Create(s, TweenInfo.new(0.1), {Scale = 1}):Play(); task.delay(0.2, function() s:Destroy() end)
        callback()
    end)
    return btnFrame
end

local function createDualButtons(parent, text1, color1, cb1, text2, color2, cb2)
    local dFrame = Instance.new("Frame", parent); dFrame.Size = UDim2.new(0.9, 0, 0, 42); dFrame.BackgroundTransparency = 1
    local function makeBtn(xPos, txt, col, cb)
        local btn = Instance.new("TextButton", dFrame); btn.Size = UDim2.new(0.48, 0, 1, 0); btn.Position = UDim2.new(xPos, 0, 0, 0); btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 10; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn); stroke.Color = col; stroke.Thickness = 1.5; table.insert(RGBElements, {Type = "Button", Stroke = stroke, DefaultColor = col})
        local title = Instance.new("TextLabel", btn); title.Size = UDim2.new(1, 0, 1, 0); title.BackgroundTransparency = 1; title.Text = txt; title.TextColor3 = col; title.Font = Enum.Font.GothamBold; title.TextSize = 11; title.ZIndex = 10
        btn.MouseButton1Click:Connect(function()
            local s = Instance.new("UIScale", btn); TweenService:Create(s, TweenInfo.new(0.1), {Scale = 0.9}):Play(); task.wait(0.1); TweenService:Create(s, TweenInfo.new(0.1), {Scale = 1}):Play(); task.delay(0.2, function() s:Destroy() end)
            cb()
        end)
    end
    makeBtn(0, text1, color1, cb1); makeBtn(0.52, text2, color2, cb2)
    return dFrame
end

-- TÍNH NĂNG ĐỔI MÀU < > (TÍNH NĂNG 3)
local function createCycler(parent, text, options, varName, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(0.9, 0, 0, 42); frame.BackgroundTransparency = 1
    local bg = Instance.new("Frame", frame); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Theme.ItemBg; Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", bg); stroke.Color = Theme.Stroke; stroke.Thickness = 1.5; table.insert(RGBElements, {Type = "Info", Stroke = stroke})

    local title = Instance.new("TextLabel", bg); title.Size = UDim2.new(0.4, 0, 1, 0); title.Position = UDim2.new(0.05, 0, 0, 0); title.BackgroundTransparency = 1; title.Text = text; title.TextColor3 = Theme.TextTitle; title.Font = Enum.Font.GothamSemibold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left
    local valLabel = Instance.new("TextLabel", bg); valLabel.Size = UDim2.new(0.3, 0, 1, 0); valLabel.Position = UDim2.new(0.55, 0, 0, 0); valLabel.BackgroundTransparency = 1; valLabel.Text = options[State[varName]]; valLabel.TextColor3 = Theme.Brand; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 12

    local btnLeft = Instance.new("TextButton", bg); btnLeft.Size = UDim2.new(0, 30, 0, 30); btnLeft.Position = UDim2.new(0.45, 0, 0.5, -15); btnLeft.Text = "<"; btnLeft.BackgroundTransparency = 1; btnLeft.TextColor3 = Theme.AccentOn; btnLeft.Font = Enum.Font.GothamBold; btnLeft.TextSize = 16
    local btnRight = Instance.new("TextButton", bg); btnRight.Size = UDim2.new(0, 30, 0, 30); btnRight.Position = UDim2.new(0.85, 0, 0.5, -15); btnRight.Text = ">"; btnRight.BackgroundTransparency = 1; btnRight.TextColor3 = Theme.AccentOn; btnRight.Font = Enum.Font.GothamBold; btnRight.TextSize = 16

    local function update()
        valLabel.Text = options[State[varName]]
        Notify(text .. " -> " .. options[State[varName]])
        if callback then callback(State[varName]) end
    end
    btnLeft.MouseButton1Click:Connect(function()
        State[varName] = State[varName] - 1; if State[varName] < 1 then State[varName] = #options end; update()
    end)
    btnRight.MouseButton1Click:Connect(function()
        State[varName] = State[varName] + 1; if State[varName] > #options then State[varName] = 1 end; update()
    end)
    return frame
end

-- ==========================================
-- [TAB 1: THÔNG TIN]
-- ==========================================
local function createInfoBox(parent, icon, titleText)
    local item = Instance.new("Frame", parent); item.Size = UDim2.new(0.9, 0, 0, 85); item.BackgroundColor3 = Theme.ItemBg; item.ZIndex = 10; Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", item); stroke.Color = Theme.Stroke; stroke.Thickness = 1.5; table.insert(RGBElements, {Type = "Info", Stroke = stroke})
    local title = Instance.new("TextLabel", item); title.Size = UDim2.new(1, -20, 0, 25); title.Position = UDim2.new(0, 10, 0, 5); title.BackgroundTransparency = 1; title.Text = icon .. " " .. titleText; title.TextColor3 = Theme.Brand; title.Font = Enum.Font.GothamBold; title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 10
    local content = Instance.new("TextLabel", item); content.Size = UDim2.new(1, -20, 1, -35); content.Position = UDim2.new(0, 10, 0, 30); content.BackgroundTransparency = 1; content.TextColor3 = Theme.TextTitle; content.Font = Enum.Font.Gotham; content.TextSize = 11; content.TextXAlignment = Enum.TextXAlignment.Left; content.TextYAlignment = Enum.TextYAlignment.Top; content.RichText = true; content.ZIndex = 10
    return content
end

local playerInfoLabel = createInfoBox(page1, "👤", "THÔNG TIN NHÂN VẬT")
local serverInfoLabel = createInfoBox(page1, "🌐", "THÔNG TIN MÁY CHỦ")
local extraInfoLabel = createInfoBox(page1, "⚙️", "TRẠNG THÁI")

local fps = 0; RunService.RenderStepped:Connect(function(dt) fps = math.floor(1/dt) end)
task.spawn(function()
    while task.wait(0.5) do
        local hp, maxHp, ws, jp = 0, 0, 0, 0
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid; hp = math.floor(hum.Health); maxHp = math.floor(hum.MaxHealth); ws = math.floor(hum.WalkSpeed); jp = math.floor(hum.JumpPower)
        end
        playerInfoLabel.Text = string.format("<font color='#FF3300'>Tên:</font> %s\n<font color='#FF3300'>Máu:</font> %d/%d\n<font color='#FF3300'>Tốc độ:</font> %d\n<font color='#FF3300'>Nhảy:</font> %d", player.DisplayName, hp, maxHp, ws, jp)
        local ping = tostring(math.floor(player:GetNetworkPing() * 1000)) .. " ms"
        serverInfoLabel.Text = string.format("<font color='#FF3300'>FPS:</font> %d\n<font color='#FF3300'>Ping:</font> %s\n<font color='#FF3300'>Player:</font> %d/%d", fps, ping, #Players:GetPlayers(), Players.MaxPlayers)
        extraInfoLabel.Text = string.format("<font color='#FF3300'>Giờ hệ thống:</font> %s\n<font color='#FF3300'>Phiên bản:</font> V42.7 MAX", os.date("%H:%M:%S"))
    end
end)

-- ==========================================
-- [TAB 2: TÍNH NĂNG (BẬT/TẮT CƠ BẢN)]
-- ==========================================
createToggle(page2, "🛡️ Chống ngã", "AntiStun")
createToggle(page2, "🔒 Khóa vị trí", "LockPosition", function(v) if not v and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.Anchored = false end end)
createToggle(page2, "🚀 Nhảy trên không", "InfJump") 
createToggle(page2, "🐿️ Lấy đồ nhanh (Cache)", "Instant")
createToggle(page2, "🧲 Auto nhặt đồ (Cache)", "AutoCollect")
createToggle(page2, "🚷 Đi xuyên tường", "Noclip", function(v) if not v and player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end)
createToggle(page2, "🌊 Đi trên mặt nước", "WaterWalk")
createToggle(page2, "👻 Tàng hình (Local)", "Invisible", function(v) 
    if player.Character then 
        for _, p in pairs(player.Character:GetDescendants()) do 
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = v and 1 or 0 
            elseif p:IsA("Decal") then p.Transparency = v and 1 or 0 end 
        end 
    end 
end)
createToggle(page2, "🔴 ESP người chơi", "ESP")

-- TÍNH NĂNG 3: BẬT MA KHÍ
createToggle(page2, "🔥 Bật Ma Khí (Aura)", "Aura")
local AuraColors = {Color3.new(1,0,0), Color3.new(0,0,1), Color3.new(0,1,0), Color3.new(0.5,0,1), Color3.new(0,0,0), Color3.new(1,1,1)}
createCycler(page2, "Màu Ma Khí", {"Đỏ", "Xanh dương", "Xanh lá", "Tím", "Đen", "Trắng"}, "AuraColorIndex")

-- ==========================================
-- [TAB 3: PLAYER (ĐIỀU CHỈNH CHỈ SỐ)]
-- ==========================================
createToggle(page3, "🏃 Chạy nhanh", "Speed", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end end)
createSlider(page3, "Tốc độ chạy", 16, 1000, "SpeedValue")

createToggle(page3, "🦘 Nhảy cao", "Jump", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.UseJumpPower = true; player.Character.Humanoid.JumpPower = 50 end end)
createSlider(page3, "Lực nhảy", 50, 1000, "JumpValue") -- NÂNG MAX LÊN 1000

createToggle(page3, "⚡ Đánh nhanh", "FastAttack")
createSlider(page3, "Tốc độ đánh (Max=20)", 1, 20, "FastAttackSpeed")

createToggle(page3, "⚔️ Đánh xa", "Reach")
createSlider(page3, "Phạm vi đánh xa", 2, 300, "ReachSize") -- NÂNG MAX LÊN 300

createToggle(page3, "🎯 Hitbox V2", "Hitbox")
createSlider(page3, "Kích thước đối thủ", 2, 100, "HitboxSize")

createToggle(page3, "🌪️ Xoay vòng tròn", "SpinBot")
createSlider(page3, "Tốc độ xoay", 10, 100, "SpinSpeed")

createSlider(page3, "👁️ Phạm vi góc nhìn", 70, 500, "FOVValue", function(val) workspace.CurrentCamera.FieldOfView = val end) -- NÂNG MAX LÊN 500
State.FOVValue = 70

-- ==========================================
-- THUẬT TOÁN CACHE CHỐNG LAG LẤY ĐỒ
-- ==========================================
local cachedPrompts = {}
local originalPrompts = {}
local originalToolSizes = {}

task.spawn(function()
    local c = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then table.insert(cachedPrompts, obj) end
        c = c + 1; if c % 1000 == 0 then task.wait() end
    end
end)
workspace.DescendantAdded:Connect(function(obj) if obj:IsA("ProximityPrompt") then table.insert(cachedPrompts, obj) end end)

task.spawn(function()
    while task.wait(1) do
        if State.Instant then
            for i = #cachedPrompts, 1, -1 do
                local prompt = cachedPrompts[i]
                if prompt.Parent then
                    if not originalPrompts[prompt] then originalPrompts[prompt] = { HoldDuration = prompt.HoldDuration, MaxActivationDistance = prompt.MaxActivationDistance } end
                    prompt.HoldDuration = 0; prompt.MaxActivationDistance = 25 
                else table.remove(cachedPrompts, i) end
            end
        else
            if next(originalPrompts) then
                for prompt, data in pairs(originalPrompts) do if prompt and prompt.Parent then prompt.HoldDuration = data.HoldDuration; prompt.MaxActivationDistance = data.MaxActivationDistance end end
                originalPrompts = {}
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if State.AutoCollect and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                for _, prompt in ipairs(cachedPrompts) do
                    if prompt.Parent and prompt.Parent:IsA("BasePart") and prompt.Enabled and (prompt.Parent.Position - root.Position).Magnitude <= 50 then
                        if fireproximityprompt then fireproximityprompt(prompt) end
                    end
                end
                local overlapParams = OverlapParams.new()
                overlapParams.FilterDescendantsInstances = {player.Character}
                overlapParams.FilterType = Enum.RaycastFilterType.Exclude
                for _, part in ipairs(workspace:GetPartBoundsInRadius(root.Position, 50, overlapParams)) do
                    if part.Name == "Handle" and part.Parent and part.Parent:IsA("Tool") then
                        if firetouchinterest then firetouchinterest(root, part, 0); task.wait(0.01); firetouchinterest(root, part, 1) else part.CFrame = root.CFrame end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if State.Reach and player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not originalToolSizes[part] then originalToolSizes[part] = { Size = part.Size, Trans = part.Transparency, Massless = part.Massless, CanCollide = part.CanCollide } end
                            part.Size = Vector3.new(State.ReachSize, State.ReachSize, State.ReachSize)
                            part.Massless = true; part.CanCollide = false; part.Transparency = 0.8 
                        end
                    end
                end
            else
                for part, origData in pairs(originalToolSizes) do
                    if part and part.Parent then part.Size = origData.Size; part.Transparency = origData.Trans; part.Massless = origData.Massless; part.CanCollide = origData.CanCollide end
                end; originalToolSizes = {}
            end
        end)
    end
end)

-- HITBOX V2 CẬP NHẬT 
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if State.Hitbox then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if hrp.Size.X ~= State.HitboxSize then
                                hrp.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                                hrp.Transparency = 0.7; hrp.Color = Color3.fromRGB(255, 50, 50); hrp.Material = Enum.Material.Neon 
                            end
                        else
                            if hrp.Size.X ~= 2 then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.Material = Enum.Material.Plastic end
                        end
                    end
                end
            else
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        if hrp.Size.X ~= 2 then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.Material = Enum.Material.Plastic end
                    end
                end
            end
        end)
    end
end)

UIS.JumpRequest:Connect(function() 
    if State.InfJump and player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end 
end)

-- NỀN TẢNG WATER WALK
local wwPart = Instance.new("Part")
wwPart.Size = Vector3.new(10, 1, 10); wwPart.Transparency = 1; wwPart.Anchored = true; wwPart.CanCollide = true
task.spawn(function()
    while task.wait(0.1) do
        if State.WaterWalk and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local ray = Ray.new(hrp.Position, Vector3.new(0, -5, 0))
            local hit, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
            if mat == Enum.Material.Water then
                wwPart.Position = Vector3.new(hrp.Position.X, pos.Y - 0.5, hrp.Position.Z)
                wwPart.Parent = workspace
            else wwPart.Parent = nil end
        else wwPart.Parent = nil end
    end
end)

-- ==========================================
-- [TAB 4: TIỆN ÍCH] LƯU MENU
-- ==========================================
-- TÍNH NĂNG 1: LƯU / TẢI CÀI ĐẶT
local configFileName = "MenuProMax_Config_V42.7.json"
local function saveConfig()
    pcall(function()
        if writefile then
            writefile(configFileName, HttpService:JSONEncode(State))
            Notify("💾 Đã lưu cấu hình hiện tại!")
        else Notify("⚠️ Executor của bạn không hỗ trợ writefile") end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and isfile(configFileName) then
            local data = HttpService:JSONDecode(readfile(configFileName))
            for k, v in pairs(data) do if State[k] ~= nil then State[k] = v end end
            Notify("📂 Đã tải cấu hình! (Giao diện giữ nguyên nhưng hiệu ứng đã áp dụng)")
        else Notify("⚠️ Không tìm thấy file cấu hình!") end
    end)
end

createDualButtons(page4, "💾 LƯU CÀI ĐẶT", Theme.AccentOn, saveConfig, "📂 TẢI CÀI ĐẶT", Theme.Brand, loadConfig)

createToggle(page4, "🌈 Chế độ RGB", "RGB", function(v) 
    if not v then 
        titleLabel.TextColor3 = Theme.TextTitle; frameStroke.Color = Theme.Stroke; headerStroke.Color = Theme.Stroke; avatarStroke.Color = Theme.Brand; openStroke.Color = opened and Theme.AccentOff or Theme.Brand
        for _, obj in pairs(RGBElements) do
            if obj.Stroke and obj.Stroke.Parent then
                if obj.Type == "Toggle" then obj.Stroke.Color = obj.State() and Theme.AccentOn or Theme.Stroke
                elseif obj.Type == "Button" then obj.Stroke.Color = obj.DefaultColor else obj.Stroke.Color = Theme.Stroke end
            end
        end
    end 
end)

createToggle(page4, "🖱️ Auto Click", "AutoClick")
task.spawn(function()
    while task.wait(0.1) do
        if State.AutoClick then
            pcall(function()
                if player.Character then local tool = player.Character:FindFirstChildOfClass("Tool") if tool then tool:Activate() end end
                local center = workspace.CurrentCamera.ViewportSize / 2
                VirtualUser:ClickButton1(Vector2.new(center.X, center.Y), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

createDualButtons(page4, "💻 LỆNH ADMIN", Theme.AccentOn, function() pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end); Notify("Đã nạp Lệnh Admin") end, 
"📂 TP SAVE GUI", Theme.Brand, function() pcall(function() loadstring(game:HttpGet(('https://raw.githubusercontent.com/0Ben1/fe/main/Tp%20Place%20GUI'),true))() end); Notify("Đã nạp TP Save GUI") end)

-- ==========================================
-- BẢO TỒN HOẠT ĐỘNG LIÊN TỤC VÀ AURA
-- ==========================================
RunService.RenderStepped:Connect(function()
    if State.RGB then
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        titleLabel.TextColor3 = color; frameStroke.Color = color; headerStroke.Color = color; avatarStroke.Color = color; openStroke.Color = color
        for _, obj in pairs(RGBElements) do if obj.Stroke and obj.Stroke.Parent then obj.Stroke.Color = color end end
    end

    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if State.LockPosition and root then root.Anchored = true end
        if State.Speed then hum.WalkSpeed = State.SpeedValue end
        if State.Jump then hum.UseJumpPower = true; hum.JumpPower = State.JumpValue end
        
        if State.FastAttack then
            pcall(function()
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
                for _, anim in pairs(hum:GetPlayingAnimationTracks()) do
                    anim:AdjustSpeed(State.FastAttackSpeed) -- Áp dụng tốc độ đánh từ Slider
                end
            end)
        end
        
        if State.AntiStun then 
            hum.PlatformStand = false; hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false); hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            if root then 
                root.RotVelocity = Vector3.new(0, 0, 0)
                if Vector3.new(root.Velocity.X, 0, root.Velocity.Z).Magnitude > (hum.WalkSpeed + 35) then root.Velocity = Vector3.new(0, root.Velocity.Y, 0) end
            end 
        end

        if State.SpinBot and root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed), 0) end

        -- XỬ LÝ MA KHÍ (AURA)
        if State.Aura and root then
            local emitter = root:FindFirstChild("MaKhiAura")
            if not emitter then
                emitter = Instance.new("ParticleEmitter", root)
                emitter.Name = "MaKhiAura"
                emitter.Texture = "rbxassetid://899756149" -- Hắc khí (Khói)
                emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 4)})
                emitter.Rate = 25
                emitter.Speed = NumberRange.new(2, 4)
                emitter.Lifetime = NumberRange.new(1, 1.5)
                emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
            end
            emitter.Color = ColorSequence.new(AuraColors[State.AuraColorIndex])
            emitter.Enabled = true
        else
            if root then local emitter = root:FindFirstChild("MaKhiAura"); if emitter then emitter.Enabled = false end end
        end
        
        if State.Noclip and char then
            for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end
        end

        if State.Hitbox then
            for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.CanCollide = false end end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local tChar = p.Character; local head = tChar.Head
                if State.ESP then
                    local bgui = head:FindFirstChild("MobileESP_Name")
                    if not bgui then
                        bgui = Instance.new("BillboardGui", head); bgui.Name = "MobileESP_Name"; bgui.Size = UDim2.new(0, 200, 0, 50); bgui.StudsOffset = Vector3.new(0, 2, 0); bgui.AlwaysOnTop = true; bgui.Adornee = head
                        local tLabel = Instance.new("TextLabel", bgui); tLabel.Name = "NameLabel"; tLabel.Size = UDim2.new(1, 0, 1, 0); tLabel.BackgroundTransparency = 1; tLabel.TextColor3 = Color3.fromRGB(255, 60, 60); tLabel.TextStrokeTransparency = 0.2; tLabel.TextStrokeColor3 = Color3.new(0, 0, 0); tLabel.Font = Enum.Font.GothamBold; tLabel.TextSize = 11; tLabel.RichText = true 
                    end
                    if root and tChar:FindFirstChild("HumanoidRootPart") then
                        bgui.NameLabel.Text = p.DisplayName .. '\n<font color="#4CAF50">[' .. math.floor((root.Position - tChar.HumanoidRootPart.Position).Magnitude) .. 'm]</font>'
                    else bgui.NameLabel.Text = p.DisplayName end
                else
                    local bgui = head:FindFirstChild("MobileESP_Name"); if bgui then bgui:Destroy() end
                end
            end
        end
    end
end)
