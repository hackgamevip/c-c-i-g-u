-- ==========================================
-- MENU VIP PRO V38 (Bản Cập Nhật - Join by ID & Tối Ưu Font)
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
    WalkOnWater = false, XRay = false, LockPosition = false, AutoCollect = false,
    SpeedValue = 60, JumpValue = 120, LightRange = 60, LightBrightness = 3 
}

-- [BẢNG MÀU CHỦ ĐẠO - PREMIUM DARK MODE]
local Theme = {
    MainBg = Color3.fromRGB(20, 20, 26),      
    HeaderBg = Color3.fromRGB(26, 26, 34),    
    TabBg = Color3.fromRGB(24, 24, 30),       
    ItemBg = Color3.fromRGB(35, 35, 45),      
    Stroke = Color3.fromRGB(60, 60, 75),      
    -- Đổi màu chữ trắng đậm thành xanh xám nhạt thanh thoát hơn
    TextTitle = Color3.fromRGB(210, 225, 240),
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
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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

-- [LỚP PHỦ MÀN HÌNH ĐEN/TRẮNG]
local screenOverlay = Instance.new("Frame", gui)
screenOverlay.Size = UDim2.new(2, 0, 2, 0)
screenOverlay.Position = UDim2.new(-0.5, 0, -0.5, 0)
screenOverlay.BackgroundColor3 = Color3.new(0,0,0)
screenOverlay.ZIndex = 0
screenOverlay.Visible = false

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
openBtn.ZIndex = 10
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
frame.ZIndex = 10
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
local frameStroke = Instance.new("UIStroke", frame); frameStroke.Color = Theme.Stroke; frameStroke.Thickness = 1

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Theme.HeaderBg; header.BackgroundTransparency = 0; header.BorderSizePixel = 0
header.ZIndex = 10
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 18)
local headerCover = Instance.new("Frame", header) 
headerCover.Size = UDim2.new(1, 0, 0, 15); headerCover.Position = UDim2.new(0, 0, 1, -15)
headerCover.BackgroundColor3 = Theme.HeaderBg; headerCover.BackgroundTransparency = 0; headerCover.BorderSizePixel = 0
headerCover.ZIndex = 10

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, 0, 1, 0); titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MENU VIP PRO"
titleLabel.TextColor3 = Color3.new(1, 1, 1); titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextSize = 14
titleLabel.ZIndex = 10
local titleGradient = Instance.new("UIGradient", titleLabel)
titleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Brand), ColorSequenceKeypoint.new(1, Theme.BrandGradient)})

-- [AVATAR GÓC MENU]
local avatarImg = Instance.new("ImageLabel", header)
avatarImg.Size = UDim2.new(0, 32, 0, 32)
avatarImg.Position = UDim2.new(0, 10, 0, 6)
avatarImg.BackgroundTransparency = 1
avatarImg.ZIndex = 10
pcall(function()
    avatarImg.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)
Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)
local avatarStroke = Instance.new("UIStroke", avatarImg)
avatarStroke.Color = Theme.Brand; avatarStroke.Thickness = 1.5; avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

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

-- [HỆ THỐNG TAB]
local tabBar = Instance.new("Frame", frame)
tabBar.Size = UDim2.new(1, 0, 0, 38); tabBar.Position = UDim2.new(0, 0, 0, 45)
tabBar.BackgroundColor3 = Theme.TabBg; tabBar.BackgroundTransparency = 0; tabBar.BorderSizePixel = 0
tabBar.ZIndex = 10

local function createTab(name, x, width)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(width, 0, 1, 0); btn.Position = UDim2.new(x, 0, 0, 0)
    btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 9
    btn.ZIndex = 10
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0.5, 0, 0, 3); indicator.Position = UDim2.new(0.25, 0, 1, -3)
    indicator.BackgroundColor3 = Theme.Brand; indicator.BorderSizePixel = 0; indicator.Visible = false
    indicator.ZIndex = 10
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    return btn, indicator
end

local tab1, ind1 = createTab("THÔNG TIN", 0, 0.2)
local tab2, ind2 = createTab("TÍNH NĂNG", 0.2, 0.2)
local tab3, ind3 = createTab("TIỆN ÍCH", 0.4, 0.2)
local tab4, ind4 = createTab("TP SAVE", 0.6, 0.2)
local tab5, ind5 = createTab("TP PLAYER", 0.8, 0.2)

local pageContainer = Instance.new("Frame", frame)
pageContainer.Size = UDim2.new(1, 0, 1, -95); pageContainer.Position = UDim2.new(0, 0, 0, 88)
pageContainer.BackgroundTransparency = 1
pageContainer.ZIndex = 10

local function createPage()
    local pg = Instance.new("ScrollingFrame", pageContainer)
    pg.Size = UDim2.new(1, 0, 1, 0); pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 3; pg.ScrollBarImageColor3 = Theme.Brand; pg.Visible = false; pg.BorderSizePixel = 0
    pg.ZIndex = 10
    local layout = Instance.new("UIListLayout", pg)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", pg).PaddingTop = UDim.new(0, 10); Instance.new("UIPadding", pg).PaddingBottom = UDim.new(0, 30) 
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
        pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 60) 
    end)
    return pg
end

local page1, page2, page3, page4, page5 = createPage(), createPage(), createPage(), createPage(), createPage()

local function showTab(pg, tb, ind)
    for _, p in pairs({page1, page2, page3, page4, page5}) do p.Visible = false end
    for _, t in pairs({tab1, tab2, tab3, tab4, tab5}) do t.TextColor3 = Theme.TextDim end
    for _, i in pairs({ind1, ind2, ind3, ind4, ind5}) do i.Visible = false end
    pg.Visible = true; tb.TextColor3 = Theme.TextTitle; ind.Visible = true
    ind.Size = UDim2.new(0, 0, 0, 3)
    TweenService:Create(ind, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0.5, 0, 0, 3)}):Play()
end

tab1.MouseButton1Click:Connect(function() showTab(page1, tab1, ind1) end)
tab2.MouseButton1Click:Connect(function() showTab(page2, tab2, ind2) end)
tab3.MouseButton1Click:Connect(function() showTab(page3, tab3, ind3) end)
tab4.MouseButton1Click:Connect(function() showTab(page4, tab4, ind4) end)
tab5.MouseButton1Click:Connect(function() showTab(page5, tab5, ind5) end)
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

-- [CÁC HÀM TẠO NÚT CƠ BẢN]
local function createButton(parent, text, color, callback)
    local btnFrame = Instance.new("Frame", parent)
    btnFrame.Size = UDim2.new(0.9, 0, 0, 42); btnFrame.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", btnFrame)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = color; stroke.Thickness = 1; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local title = Instance.new("TextLabel", btn)
    title.Size = UDim2.new(1, 0, 1, 0); title.BackgroundTransparency = 1; title.Text = text
    title.TextColor3 = color; title.Font = Enum.Font.GothamBold; title.TextSize = 13; title.ZIndex = 10
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
        btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn); stroke.Color = col; stroke.Thickness = 1; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local title = Instance.new("TextLabel", btn)
        title.Size = UDim2.new(1, 0, 1, 0); title.BackgroundTransparency = 1; title.Text = txt
        title.TextColor3 = col; title.Font = Enum.Font.GothamBold; title.TextSize = 11; title.ZIndex = 10
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
    btn.Size = UDim2.new(1, 0, 1, 0); btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1
    local title = Instance.new("TextLabel", btn)
    title.Size = UDim2.new(0.7, 0, 1, 0); title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1; title.Text = text; title.TextColor3 = Theme.TextTitle; title.Font = Enum.Font.GothamSemibold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 10
    local status = Instance.new("TextLabel", btn)
    status.Size = UDim2.new(0.2, 0, 1, 0); status.Position = UDim2.new(0.75, 0, 0, 0)
    status.BackgroundTransparency = 1; status.Font = Enum.Font.GothamBold; status.TextSize = 12; status.TextXAlignment = Enum.TextXAlignment.Right; status.ZIndex = 10
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
    bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Theme.ItemBg; bg.ZIndex = 10
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", bg); stroke.Color = Theme.Stroke; stroke.Thickness = 1
    local titleLabel = Instance.new("TextLabel", bg)
    titleLabel.Size = UDim2.new(0.7, 0, 0.4, 0); titleLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = text; titleLabel.TextColor3 = Theme.TextDim; titleLabel.Font = Enum.Font.GothamSemibold; titleLabel.TextSize = 12; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.ZIndex = 10
    local valLabel = Instance.new("TextLabel", bg)
    valLabel.Size = UDim2.new(0.25, 0, 0.4, 0); valLabel.Position = UDim2.new(0.7, 0, 0.1, 0)
    valLabel.BackgroundTransparency = 1; valLabel.Text = tostring(default); valLabel.TextColor3 = Theme.Brand; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 12; valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.ZIndex = 10
    local track = Instance.new("Frame", bg)
    track.Size = UDim2.new(0.9, 0, 0.15, 0); track.Position = UDim2.new(0.05, 0, 0.65, 0); track.BackgroundColor3 = Theme.MainBg; track.ZIndex = 10
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Theme.AccentOn; fill.ZIndex = 10
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

-- ==========================================
-- [TAB 1: THÔNG TIN - DASHBOARD]
-- ==========================================

local function createInfoBox(parent, icon, titleText, heightOffset)
    local item = Instance.new("Frame", parent)
    item.Size = UDim2.new(0.9, 0, 0, heightOffset or 85) 
    item.BackgroundColor3 = Theme.ItemBg; item.ZIndex = 10
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", item); stroke.Color = Theme.Stroke; stroke.Thickness = 1
    
    local title = Instance.new("TextLabel", item)
    title.Size = UDim2.new(1, -20, 0, 25); title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1; title.Text = icon .. " " .. titleText
    title.TextColor3 = Theme.Brand; title.Font = Enum.Font.GothamBold; title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 10
    
    local content = Instance.new("TextLabel", item)
    content.Size = UDim2.new(1, -20, 1, -35); content.Position = UDim2.new(0, 10, 0, 30)
    content.BackgroundTransparency = 1; content.Text = "Đang tải..."
    content.TextColor3 = Theme.TextTitle -- Font xanh xám nhạt nhẹ nhàng
    content.Font = Enum.Font.Gotham; content.TextSize = 11 -- Bỏ in đậm
    content.TextXAlignment = Enum.TextXAlignment.Left; content.TextYAlignment = Enum.TextYAlignment.Top
    content.RichText = true; content.ZIndex = 10
    
    return content, item
end

local playerInfoLabel = createInfoBox(page1, "👤", "THÔNG TIN NHÂN VẬT", 85)
local serverInfoLabel, serverInfoFrame = createInfoBox(page1, "🌐", "THÔNG TIN MÁY CHỦ", 85)

-- NÚT COPY ID NHỎ GỌN TRONG GÓC
local copyIdBtn = Instance.new("TextButton", serverInfoFrame)
copyIdBtn.Size = UDim2.new(0, 24, 0, 24)
copyIdBtn.Position = UDim2.new(1, -30, 1, -28) -- Góc phải dưới
copyIdBtn.Text = "📜"
copyIdBtn.BackgroundTransparency = 1
copyIdBtn.TextSize = 14
copyIdBtn.ZIndex = 11

copyIdBtn.MouseButton1Click:Connect(function()
    clickAnimate(copyIdBtn)
    pcall(function() 
        if setclipboard then 
            setclipboard(tostring(game.JobId))
            local oldText = copyIdBtn.Text
            copyIdBtn.Text = "✅"
            task.wait(1)
            copyIdBtn.Text = oldText
        end 
    end)
end)

-- Ô DÁN ID ĐỂ THAM GIA LẠI
local joinIdFrame = Instance.new("Frame", page1)
joinIdFrame.Size = UDim2.new(0.9, 0, 0, 44)
joinIdFrame.BackgroundColor3 = Theme.ItemBg
joinIdFrame.ZIndex = 10
Instance.new("UICorner", joinIdFrame).CornerRadius = UDim.new(0, 8)
local jStroke = Instance.new("UIStroke", joinIdFrame)
jStroke.Color = Theme.Stroke; jStroke.Thickness = 1

local idBox = Instance.new("TextBox", joinIdFrame)
idBox.Size = UDim2.new(0.65, 0, 1, 0)
idBox.Position = UDim2.new(0.05, 0, 0, 0)
idBox.BackgroundTransparency = 1
idBox.PlaceholderText = "Dán ID Server vào đây..."
idBox.Text = ""
idBox.TextColor3 = Theme.Brand
idBox.Font = Enum.Font.Gotham
idBox.TextSize = 11
idBox.TextXAlignment = Enum.TextXAlignment.Left
idBox.ClearTextOnFocus = false
idBox.ZIndex = 10

local joinBtn = Instance.new("TextButton", joinIdFrame)
joinBtn.Size = UDim2.new(0.25, 0, 0.65, 0)
joinBtn.Position = UDim2.new(0.72, 0, 0.175, 0)
joinBtn.BackgroundColor3 = Theme.AccentOn
joinBtn.Text = "VÀO"
joinBtn.TextColor3 = Color3.new(1, 1, 1)
joinBtn.Font = Enum.Font.GothamBold
joinBtn.TextSize = 11
joinBtn.ZIndex = 10
Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 6)

joinBtn.MouseButton1Click:Connect(function()
    clickAnimate(joinBtn)
    local targetId = idBox.Text:gsub("%s+", "")
    if targetId ~= "" then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, player)
        end)
    end
end)

local extraInfoLabel = createInfoBox(page1, "⚙️", "TRẠNG THÁI", 80)

local fps = 0
RunService.RenderStepped:Connect(function(dt) fps = math.floor(1/dt) end)

task.spawn(function()
    while task.wait(0.5) do
        local hp, maxHp, ws, jp = 0, 0, 0, 0
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            hp = math.floor(hum.Health)
            maxHp = math.floor(hum.MaxHealth)
            ws = math.floor(hum.WalkSpeed)
            jp = math.floor(hum.JumpPower)
        end
        playerInfoLabel.Text = string.format(
            "<font color='#00C8FF'>Tên:</font> %s (@%s)\n<font color='#00C8FF'>Máu:</font> %d / %d\n<font color='#00C8FF'>Tốc độ:</font> %d\n<font color='#00C8FF'>Lực nhảy:</font> %d",
            player.DisplayName, player.Name, hp, maxHp, ws, jp
        )
        
        local ping = "0"
        pcall(function()
            local stats = game:GetService("Stats")
            if stats and stats:FindFirstChild("Network") and stats.Network:FindFirstChild("ServerStatsItem") then
                ping = stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
            else
                ping = tostring(math.floor(player:GetNetworkPing() * 1000)) .. " ms"
            end
        end)
        
        local pCount = #Players:GetPlayers()
        local maxP = Players.MaxPlayers
        local jobText = game.JobId ~= "" and string.sub(game.JobId, 1, 15).."..." or "N/A"
        
        serverInfoLabel.Text = string.format(
            "<font color='#00C8FF'>FPS:</font> %d\n<font color='#00C8FF'>Ping:</font> %s\n<font color='#00C8FF'>Người chơi:</font> %d / %d\n<font color='#00C8FF'>ID SV:</font> %s",
            fps, ping, pCount, maxP, jobText
        )
        
        local execTime = math.floor(workspace.DistributedGameTime)
        local hours = math.floor(execTime / 3600)
        local mins = math.floor((execTime % 3600) / 60)
        local secs = execTime % 60
        local timeString = string.format("%02d:%02d:%02d", hours, mins, secs)
        
        extraInfoLabel.Text = string.format(
            "<font color='#00C8FF'>Thời gian chơi:</font> %s\n<font color='#00C8FF'>Giờ hệ thống:</font> %s\n<font color='#00C8FF'>Phiên bản:</font> MENU VIP PRO 🇻🇳",
            timeString, os.date("%H:%M:%S")
        )
    end
end)


-- ==========================================
-- [TAB 2: NHÂN VẬT]
-- ==========================================

local astralClone = nil
local astralProps = {}
createToggle(page2, "🏃 Chạy nhanh", false, function(v) 
    State.Speed = v; if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end
end)
createSlider(page2, "Tốc độ chạy", 16, 1000, 60, function(val) State.SpeedValue = val end)

createToggle(page2, "🦘 Nhảy cao", false, function(v) 
    State.Jump = v; if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.UseJumpPower = true; player.Character.Humanoid.JumpPower = 50 end
end)
createSlider(page2, "Lực nhảy", 50, 300, 120, function(val) State.JumpValue = val end)

createToggle(page2, "🛡️ Chống ngã & Chống văng", false, function(v) 
    State.AntiStun = v 
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not v)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, not v)
    end
end)

createToggle(page2, "🔒 Khóa vị trí", false, function(v) 
    State.LockPosition = v; if not v and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.Anchored = false end
end)
createToggle(page2, "🚀 Nhảy trên không", false, function(v) State.InfJump = v end) 
createToggle(page2, "🐿️ Lấy đồ nhanh", false, function(v) 
    State.Instant = v; if v then for _, prompt in pairs(workspace:GetDescendants()) do if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0; prompt.MaxActivationDistance = 25 end end end
end)
createToggle(page2, "🚷 Đi xuyên tường", false, function(v) 
    State.Noclip = v; if not v and player.Character then for _, part in pairs(player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
end)

createToggle(page2, "👻 Xuất hồn", false, function(v)
    local char = player.Character
    if v then
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.Archivable = true
            astralClone = char:Clone()
            astralClone.Name = player.Name .. "_Thế_Thân"
            astralClone.Parent = workspace
            
            local cloneRoot = astralClone:FindFirstChild("HumanoidRootPart")
            if cloneRoot then cloneRoot.Anchored = true end
            
            astralProps = {}
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    astralProps[part] = {Transparency = part.Transparency, Material = part.Material}
                    part.Transparency = 0.6
                    part.Material = Enum.Material.ForceField
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    astralProps[part] = {Transparency = part.Transparency}
                    part.Transparency = 0.6
                end
            end
        end
    else
        if astralClone then
            if char and char:FindFirstChild("HumanoidRootPart") then
                local cloneRoot = astralClone:FindFirstChild("HumanoidRootPart")
                if cloneRoot then char.HumanoidRootPart.CFrame = cloneRoot.CFrame end
            end
            astralClone:Destroy()
            astralClone = nil
        end
        for part, props in pairs(astralProps) do
            if part and part.Parent then for k, val in pairs(props) do pcall(function() part[k] = val end) end end
        end
        astralProps = {}
    end
end)

player.CharacterAdded:Connect(function()
    if astralClone then astralClone:Destroy(); astralClone = nil end
    astralProps = {}
end)
local waterPart = Instance.new("Part"); waterPart.Size = Vector3.new(10, 1, 10); waterPart.Transparency = 1; waterPart.Anchored = true; waterPart.CanCollide = true
createToggle(page2, "🌊 Đi trên mặt nước", false, function(v) State.WalkOnWater = v end)

local xrayMats = {}
createToggle(page2, "👀 Nhìn xuyên map", false, function(v) 
    State.XRay = v 
    task.spawn(function()
        if v then
            for i, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) and obj.Name ~= "Terrain" and obj.Transparency < 1 then
                    if not xrayMats[obj] then xrayMats[obj] = obj.Transparency end; obj.Transparency = 0.5
                end
                if i % 500 == 0 then task.wait() end 
            end
        else
            local count = 0
            for obj, origTrans in pairs(xrayMats) do
                if obj and obj.Parent then obj.Transparency = origTrans end
                count = count + 1; if count % 500 == 0 then task.wait() end
            end
            xrayMats = {}
        end
    end)
end)

createToggle(page2, "🔴 ESP người chơi", false, function(v) State.ESP = v end)

createToggle(page2, "💡 Ánh sáng quanh người chơi", false, function(v) 
    State.PlayerLight = v; if not v and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then 
        local light = player.Character.HumanoidRootPart:FindFirstChild("PlayerPointLight"); if light then light:Destroy() end 
    end
end)
createSlider(page2, "Phạm vi sáng", 50, 2000, 60, function(val) State.LightRange = val end)
createSlider(page2, "Độ sáng", 0, 5, 3, function(val) State.LightBrightness = val end)

UIS.JumpRequest:Connect(function() 
    if State.InfJump and player.Character then 
        local hum = player.Character:FindFirstChildOfClass("Humanoid") 
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end 
    end 
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt) if State.Instant then pcall(function() fireproximityprompt(prompt) end) end end)

-- ==========================================
-- [TAB 3: TIỆN ÍCH]
-- ==========================================

local function hopServer(sortOrder)
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"
    local function getServers(cursor)
        local url = api .. (cursor and "&cursor=" .. cursor or "")
        local success, res = pcall(game.HttpGet, game, url)
        if success then return HttpService:JSONDecode(res) end
    end
    local nextCursor = nil; local targetServer = nil
    repeat
        local data = getServers(nextCursor)
        if not data or not data.data then break end
        for _, s in pairs(data.data) do
            if s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
                if sortOrder == "Asc" then
                    if s.playing > 0 then targetServer = s; break end
                else targetServer = s; break end
            end
        end
        if targetServer then break end
        nextCursor = data.nextPageCursor
    until not nextCursor
    
    if targetServer then TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, player) end
end

local function rejoinServer()
    if #Players:GetPlayers() <= 1 then
        player:Kick("\nĐang vào lại server..."); task.wait(); TeleportService:Teleport(game.PlaceId, player)
    else TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end
end

createToggle(page3, "🧲 Auto nhặt đồ xung quanh", false, function(v) State.AutoCollect = v end)
task.spawn(function()
    while task.wait(0.2) do
        if State.AutoCollect and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            for _, obj in pairs(workspace:GetDescendants()) do
                if not State.AutoCollect then break end
                
                if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                    if (obj.Handle.Position - root.Position).Magnitude <= 50 then
                        pcall(function()
                            if firetouchinterest then 
                                firetouchinterest(root, obj.Handle, 0)
                                task.wait(0.01)
                                firetouchinterest(root, obj.Handle, 1) 
                            else 
                                obj.Handle.CFrame = root.CFrame 
                            end
                        end)
                    end
                elseif obj:IsA("ProximityPrompt") and obj.Enabled then
                    local parentPart = obj.Parent
                    if parentPart and parentPart:IsA("BasePart") and (parentPart.Position - root.Position).Magnitude <= 50 then
                        pcall(function()
                            if fireproximityprompt then fireproximityprompt(obj) end
                        end)
                    end
                end
            end
        end
    end
end)

createToggle(page3, "⬛ Màn hình đen (Giảm lag)", false, function(v) screenOverlay.BackgroundColor3 = Color3.new(0, 0, 0); screenOverlay.Visible = v end)
createToggle(page3, "⬜ Màn hình trắng (Treo máy)", false, function(v) screenOverlay.BackgroundColor3 = Color3.new(1, 1, 1); screenOverlay.Visible = v end)
createToggle(page3, "🛡️ Chống AFK", true, function(v) State.AntiAfk = v end)

createDualButtons(page3, "🌞 SÁNG (FAKE)", Color3.fromRGB(243, 156, 18), function() Lighting.ClockTime = 12 end, "🌚 TỐI (FAKE)", Color3.fromRGB(160, 32, 240), function() Lighting.ClockTime = 0 end)

createDualButtons(page3, "🔄 VÀO LẠI SV", Theme.AccentOn, rejoinServer, "🎲 ĐỔI SV NGẪU NHIÊN", Theme.Brand, function() hopServer("Desc") end)
createDualButtons(page3, "📉 ĐỔI SV ÍT NGƯỜI", Color3.fromRGB(52, 152, 219), function() hopServer("Asc") end, "📈 ĐỔI SV NHIỀU NGƯỜI", Color3.fromRGB(231, 76, 60), function() hopServer("Desc") end)

createDualButtons(page3, "💻 LỆNH ADMIN", Theme.AccentOn, function() pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end) end, 
"🔨 LẤY BTOOLS", Theme.Brand, function() pcall(function() 
    local b1 = Instance.new("HopperBin", player.Backpack); b1.BinType = Enum.BinType.Clone
    local b2 = Instance.new("HopperBin", player.Backpack); b2.BinType = Enum.BinType.Hammer
    local b3 = Instance.new("HopperBin", player.Backpack); b3.BinType = Enum.BinType.Grab
end) end)

createDualButtons(page3, "🕊️ FLY V1", Theme.Brand, function() pcall(function() loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\40\39\104\116\116\112\115\58\47\47\103\105\115\116\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\109\101\111\122\111\110\101\89\84\47\98\102\48\51\55\100\102\102\57\102\48\97\55\48\48\49\55\51\48\52\100\100\100\54\55\102\100\99\100\51\55\48\47\114\97\119\47\101\49\52\101\55\52\102\52\50\53\98\48\54\48\100\102\53\50\51\51\52\51\99\102\51\48\98\55\56\55\48\55\52\101\98\51\99\53\100\50\47\97\114\99\101\117\115\37\50\53\50\48\120\37\50\53\50\48\102\108\121\37\50\53\50\48\50\37\50\53\50\48\111\98\102\108\117\99\97\116\111\114\39\41\44\116\114\117\101\41\41\40\41\10\10")() end) end, 
"🕊️ FLY V3 ", Theme.Brand, function() pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-V3-X-132770"))() end) end)

createButton(page3, "📂 TP SAVE V2 GUI", Theme.Brand, function() pcall(function() loadstring(game:HttpGet(('https://raw.githubusercontent.com/0Ben1/fe/main/Tp%20Place%20GUI'),true))() end) end)

-- ==========================================
-- [TAB 4: VỊ TRÍ TP SAVE]
-- ==========================================
local savedLocCount = 0
local function createPosItem(name, cframe)
    local item = Instance.new("Frame", page4)
    item.Size = UDim2.new(0.9, 0, 0, 48); item.BackgroundColor3 = Theme.ItemBg; item.ZIndex = 10
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", item); stroke.Color = Theme.Stroke; stroke.Thickness = 1
    local nameBox = Instance.new("TextBox", item)
    nameBox.Size = UDim2.new(0.45, 0, 1, 0); nameBox.Position = UDim2.new(0.05, 0, 0, 0)
    nameBox.Text = name; nameBox.TextColor3 = Theme.TextTitle; nameBox.Font = Enum.Font.GothamSemibold; nameBox.TextSize = 12
    nameBox.BackgroundTransparency = 1; nameBox.TextXAlignment = Enum.TextXAlignment.Left; nameBox.ClearTextOnFocus = false; nameBox.ZIndex = 10
    local tpBtn = Instance.new("TextButton", item)
    tpBtn.Size = UDim2.new(0.25, 0, 0.6, 0); tpBtn.Position = UDim2.new(0.53, 0, 0.2, 0)
    tpBtn.Text = "TP"; tpBtn.BackgroundColor3 = Theme.Brand; tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Font = Enum.Font.GothamBold; tpBtn.TextSize = 11; tpBtn.ZIndex = 10; Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
    local delBtn = Instance.new("TextButton", item)
    delBtn.Size = UDim2.new(0.15, 0, 0.6, 0); delBtn.Position = UDim2.new(0.81, 0, 0.2, 0)
    delBtn.Text = "X"; delBtn.BackgroundColor3 = Theme.AccentOff; delBtn.TextColor3 = Color3.new(1,1,1)
    delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 12; delBtn.ZIndex = 10; Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
    
    tpBtn.MouseButton1Click:Connect(function() clickAnimate(tpBtn); if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = cframe end end)
    delBtn.MouseButton1Click:Connect(function() clickAnimate(delBtn); task.wait(0.1); item:Destroy() end)
end
createButton(page4, "📍 LƯU TỌA ĐỘ", Theme.AccentOn, function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedLocCount = savedLocCount + 1
        createPosItem("Vị trí " .. savedLocCount, player.Character.HumanoidRootPart.CFrame)
    end
end)

-- ==========================================
-- [TAB 5: TP NGƯỜI CHƠI]
-- ==========================================
local function updatePlayerList()
    for _, child in pairs(page5:GetChildren()) do if child.Name == "PaddingFrame" then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pFrame = Instance.new("Frame", page5); pFrame.Name = "PaddingFrame"; pFrame.Size = UDim2.new(0.9, 0, 0, 48); pFrame.BackgroundTransparency = 1; pFrame.ZIndex = 10
            local btn = Instance.new("TextButton", pFrame)
            btn.Name = "PlayerBtn_TP"; btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = Theme.ItemBg; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 10
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", btn); stroke.Color = Theme.Stroke; stroke.Thickness = 1
            
            local nLabel = Instance.new("TextLabel", btn)
            nLabel.Size = UDim2.new(0.7, 0, 0.5, 0); nLabel.Position = UDim2.new(0.05, 0, 0.05, 0); nLabel.BackgroundTransparency = 1
            nLabel.Text = "👤  " .. p.DisplayName; nLabel.TextColor3 = Theme.TextTitle; nLabel.Font = Enum.Font.GothamSemibold; nLabel.TextSize = 13; nLabel.TextXAlignment = Enum.TextXAlignment.Left; nLabel.ZIndex = 10
            
            local subLabel = Instance.new("TextLabel", btn)
            subLabel.Size = UDim2.new(0.7, 0, 0.45, 0); subLabel.Position = UDim2.new(0.05, 0, 0.5, 0); subLabel.BackgroundTransparency = 1
            subLabel.Text = "@" .. p.Name 
            subLabel.TextColor3 = Color3.fromRGB(100, 255, 100) 
            subLabel.Font = Enum.Font.Gotham; subLabel.TextSize = 10; subLabel.TextXAlignment = Enum.TextXAlignment.Left; subLabel.ZIndex = 10

            local arrow = Instance.new("TextLabel", btn)
            arrow.Size = UDim2.new(0.2, 0, 1, 0); arrow.Position = UDim2.new(0.75, 0, 0, 0); arrow.BackgroundTransparency = 1
            arrow.Text = " 🐿️🧂 "; arrow.TextColor3 = Theme.Brand; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 11; arrow.TextXAlignment = Enum.TextXAlignment.Right; arrow.ZIndex = 10
            
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
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

player.Idled:Connect(function()
    if State.AntiAfk then VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end
end)

RunService.Stepped:Connect(function()
    local char = player.Character
    if State.Noclip and char then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end 
    end
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if State.LockPosition and root then root.Anchored = true end
        
        if State.Speed then hum.WalkSpeed = State.SpeedValue end
        if State.Jump then hum.UseJumpPower = true; hum.JumpPower = State.JumpValue end
        if State.AntiStun then hum.PlatformStand = false; if root then root.RotVelocity = Vector3.new(0, 0, 0) end end
            
        if State.WalkOnWater and root then
            local params = RaycastParams.new(); params.FilterDescendantsInstances = {char, waterPart, astralClone}; params.FilterType = Enum.RaycastFilterType.Exclude; params.IgnoreWater = false 
            local result = workspace:Raycast(root.Position, Vector3.new(0, -15, 0), params)
            if result and (result.Material == Enum.Material.Water or hum:GetState() == Enum.HumanoidStateType.Swimming) then
                waterPart.Parent = workspace
                local targetY = result and result.Position.Y or (root.Position.Y - 2.5)
                waterPart.CFrame = CFrame.new(root.Position.X, targetY + 0.5, root.Position.Z)
                if hum:GetState() == Enum.HumanoidStateType.Swimming then hum:ChangeState(Enum.HumanoidStateType.Running) end
            else waterPart.Parent = nil end
        else waterPart.Parent = nil end

        if root then
            local light = root:FindFirstChild("PlayerPointLight")
            if State.PlayerLight then 
                if not light then light = Instance.new("PointLight", root); light.Name = "PlayerPointLight"; light.Shadows = false end 
                light.Brightness = State.LightBrightness; light.Range = State.LightRange
            else if light then light:Destroy() end end
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
                        local dist = math.floor((root.Position - tChar.HumanoidRootPart.Position).Magnitude)
                        bgui.NameLabel.Text = p.DisplayName .. '\n<font color="#4CAF50">[' .. dist .. 'm]</font>'
                    else bgui.NameLabel.Text = p.DisplayName end
                else
                    local bgui = head:FindFirstChild("MobileESP_Name"); if bgui then bgui:Destroy() end
                end
            end
        end
    end
end)

workspace.DescendantAdded:Connect(function(v)
    if State.XRay and v:IsA("BasePart") and not v:IsDescendantOf(player.Character) and v.Name ~= "Terrain" and v.Transparency < 1 then
        if not xrayMats[v] then xrayMats[v] = v.Transparency end; v.Transparency = 0.5
    end
    if State.Instant and v:IsA("ProximityPrompt") then v.HoldDuration = 0; v.MaxActivationDistance = 25 end
end)
