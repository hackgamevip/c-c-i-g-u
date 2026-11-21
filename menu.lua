--[[
    ========================================================================
    THỦ THÀNH 2D - STANDALONE v1.0
    Game Thủ Thành (Tower Defense) 2D Toàn Màn Hình cho Roblox Mobile & PC
    - 3 Bản đồ: Thảo Nguyên (10 đợt), Sa Mạc Cổ (15 đợt), Vực Dung Nham (20 đợt)
    - 4 Tháp phòng thủ: Tháp Cung, Tháp Băng (làm chậm), Tháp Pháo (nổ lan), Tháp Sấm
    - Nâng cấp Tháp Lv1 -> Lv3, Bán tháp, Vòng tầm bắn, Tốc độ 1x / 2x, Tự gọi đợt
    - 5 loại quái + Boss mỗi 5 đợt, Kỹ năng Sấm Sét Toàn Bản Đồ (25 Xu)
    - Giao diện Royal Blue 3D matte an toàn cho mobile, lưu Xu tự động
    ========================================================================
]]

if _G.ThuThanh2DCleanup then
    pcall(_G.ThuThanh2DCleanup)
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ========================================================================
-- [PHẦN 01] CẤU HÌNH, BẢNG MÀU MATTE, 3 BẢN ĐỒ & 4 LOẠI THÁP
-- ========================================================================
local SAVE_FILE = "ThuThanh2D_Stats_v1.json"

-- Bảng màu Royal Blue 3D matte (mọi kênh RGB của chữ đều <= 215)
local UITheme = {
    BgMain        = Color3.fromRGB(11, 22, 52),
    BgMainLight   = Color3.fromRGB(18, 38, 86),
    BgPanel       = Color3.fromRGB(16, 35, 78),
    BgPanelDark   = Color3.fromRGB(12, 24, 58),
    BgCard        = Color3.fromRGB(22, 48, 102),
    BgButton      = Color3.fromRGB(26, 60, 124),
    RimBlue       = Color3.fromRGB(58, 158, 212),
    StrokeSubtle  = Color3.fromRGB(44, 108, 172),

    BtnGreen      = Color3.fromRGB(42, 148, 56),
    BtnGreenDark  = Color3.fromRGB(22, 92, 32),
    BtnBlue       = Color3.fromRGB(32, 112, 198),
    BtnBlueDark   = Color3.fromRGB(18, 66, 132),
    BtnPurple     = Color3.fromRGB(118, 58, 194),
    BtnPurpleDark = Color3.fromRGB(74, 30, 132),
    BtnRed        = Color3.fromRGB(184, 46, 56),
    BtnRedDark    = Color3.fromRGB(122, 24, 32),
    BtnGold       = Color3.fromRGB(194, 140, 28),
    BtnGoldDark   = Color3.fromRGB(132, 88, 14),

    TextPrimary   = Color3.fromRGB(210, 214, 215),
    TextSecondary = Color3.fromRGB(160, 186, 212),
    TextMuted     = Color3.fromRGB(122, 154, 192),
    ColorGold     = Color3.fromRGB(212, 182, 82),
    ColorRed      = Color3.fromRGB(210, 96, 98),
    ColorGreen    = Color3.fromRGB(112, 206, 132),
    AccentCyan    = Color3.fromRGB(92, 198, 214),
}

local FONT_MAIN = Enum.Font.GothamSemibold
local FONT_BODY = Enum.Font.GothamMedium

local GRID_COLS = 12
local GRID_ROWS = 8

-- 3 Bản đồ với đường đi dạng lưới (col, row) từ 1..12, 1..8
local MAPS = {
    {
        id       = 1,
        name     = "Thảo Nguyên",
        waves    = 10,
        rewardXu = 150,
        startGold = 160,
        bgTile   = Color3.fromRGB(34, 72, 48),
        bgTile2  = Color3.fromRGB(30, 65, 43),
        pathCol  = Color3.fromRGB(146, 122, 88),
        pathRim  = Color3.fromRGB(108, 86, 58),
        waypoints = {
            { 1, 2 }, { 4, 2 }, { 4, 6 }, { 8, 6 }, { 8, 2 }, { 12, 2 },
        },
    },
    {
        id       = 2,
        name     = "Sa Mạc Cổ",
        waves    = 15,
        rewardXu = 350,
        startGold = 180,
        bgTile   = Color3.fromRGB(128, 102, 66),
        bgTile2  = Color3.fromRGB(118, 93, 60),
        pathCol  = Color3.fromRGB(76, 62, 48),
        pathRim  = Color3.fromRGB(54, 44, 34),
        waypoints = {
            { 1, 1 }, { 10, 1 }, { 10, 4 }, { 3, 4 }, { 3, 7 }, { 12, 7 },
        },
    },
    {
        id       = 3,
        name     = "Vực Dung Nham",
        waves    = 20,
        rewardXu = 800,
        startGold = 210,
        bgTile   = Color3.fromRGB(48, 28, 34),
        bgTile2  = Color3.fromRGB(42, 24, 30),
        pathCol  = Color3.fromRGB(96, 46, 42),
        pathRim  = Color3.fromRGB(146, 68, 44),
        waypoints = {
            { 1, 7 }, { 3, 7 }, { 3, 2 }, { 6, 2 }, { 6, 7 }, { 9, 7 }, { 9, 2 }, { 12, 2 },
        },
    },
}

local DIFFS = {
    { key = "Easy",   label = "Dễ",  hpMult = 0.85, xuMult = 1.0 },
    { key = "Medium", label = "Vừa", hpMult = 1.15, xuMult = 1.5 },
    { key = "Hard",   label = "Khó", hpMult = 1.55, xuMult = 2.2 },
}

-- 4 Loại Tháp phòng thủ
local TOWERS = {
    {
        key      = "Arrow",
        name     = "Tháp Cung",
        desc     = "Bắn nhanh",
        cost     = 50,
        dmg      = 16,
        range    = 2.6,     -- Đơn vị theo số ô
        cooldown = 0.45,
        color    = Color3.fromRGB(74, 178, 96),
        projCol  = Color3.fromRGB(204, 188, 92),
        splash   = 0,
        slow     = 0,
        chain    = 0,
    },
    {
        key      = "Ice",
        name     = "Tháp Băng",
        desc     = "Làm chậm",
        cost     = 80,
        dmg      = 12,
        range    = 2.5,
        cooldown = 0.72,
        color    = Color3.fromRGB(76, 186, 208),
        projCol  = Color3.fromRGB(132, 204, 214),
        splash   = 0.85,
        slow     = 0.42,    -- Giảm 42% tốc độ trong 2.2s
        chain    = 0,
    },
    {
        key      = "Cannon",
        name     = "Tháp Pháo",
        desc     = "Nổ lan",
        cost     = 110,
        dmg      = 42,
        range    = 2.8,
        cooldown = 1.35,
        color    = Color3.fromRGB(198, 122, 46),
        projCol  = Color3.fromRGB(208, 134, 62),
        splash   = 1.35,
        slow     = 0,
        chain    = 0,
    },
    {
        key      = "Tesla",
        name     = "Tháp Sấm",
        desc     = "Sét lan",
        cost     = 150,
        dmg      = 34,
        range    = 3.1,
        cooldown = 0.80,
        color    = Color3.fromRGB(142, 82, 206),
        projCol  = Color3.fromRGB(178, 136, 214),
        splash   = 0,
        slow     = 0,
        chain    = 3,       -- Giật lan tối đa 3 mục tiêu
    },
}

local Config = {
    MapIndex     = 1,
    DiffIndex    = 1,
    AutoWave     = false,
    SoundEnabled = true,
}

local State = {
    Screen          = "HOME",   -- "HOME" | "GAME"
    SelectedTool    = 1,        -- Index 1..4 của TOWERS
    SelectedTower   = nil,      -- Tháp đang chọn để Nâng cấp / Bán
    Gold            = 160,
    Lives           = 20,
    Wave            = 0,
    MaxWaves        = 10,
    WaveActive      = false,
    SpawnQueue      = {},
    SpawnTimer      = 0,
    AutoWaveTimer   = 0,
    GameSpeed       = 1,        -- 1 hoặc 2
    Paused          = false,
    GameOver        = false,
    Won             = false,
    Minimized       = false,
    Destroyed       = false,
    PathCells       = {},       -- PathCells[r][c] = true
    PathPoints      = {},       -- Danh sách điểm {x, y} theo tọa độ ô
    PlacedTowers    = {},       -- Danh sách object tháp
    TowerGrid       = {},       -- TowerGrid[r][c] = tower
    Enemies         = {},
    Projectiles     = {},
    Effects         = {},
    TileSize        = 40,
    NextId          = 1,
    TempAlertToken  = 0,
}

local Stats = {
    Wins = 0,
    Xu   = 0,
}

local UI = {
    Connections = {},
}

-- ========================================================================
-- [PHẦN 02] TIỆN ÍCH LƯU XU, ÂM THANH & NÚT 3D MATTE
-- ========================================================================
local function getMap() return MAPS[Config.MapIndex] or MAPS[1] end
local function getDiff() return DIFFS[Config.DiffIndex] or DIFFS[1] end

local function loadStats()
    if type(isfile) == "function" and type(readfile) == "function" then
        local ok, exists = pcall(isfile, SAVE_FILE)
        if ok and exists then
            local okR, raw = pcall(readfile, SAVE_FILE)
            if okR and type(raw) == "string" and #raw > 0 then
                local okD, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if okD and type(data) == "table" then
                    Stats.Wins = tonumber(data.Wins) or 0
                    Stats.Xu   = tonumber(data.Xu) or 0
                end
            end
        end
    end
end

local function saveStats()
    if type(writefile) == "function" then
        pcall(function()
            writefile(SAVE_FILE, HttpService:JSONEncode(Stats))
        end)
    end
end

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local okCore = pcall(function() return CoreGui.Name end)
    if okCore then return CoreGui end
    if LocalPlayer then return LocalPlayer:WaitForChild("PlayerGui") end
    return CoreGui
end

local function trackConn(conn)
    if conn then table.insert(UI.Connections, conn) end
    return conn
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or UITheme.RimBlue
    s.Thickness = thickness or 1.5
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function addGradient(parent, topColor, bottomColor, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(topColor, bottomColor)
    g.Rotation = rot or 90
    g.Parent = parent
    return g
end

local function bindInstantTap(button, callback)
    local pressPos, lastFire = nil, 0
    trackConn(button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressPos = input.Position
        end
    end))
    trackConn(button.InputEnded:Connect(function(input)
        if not pressPos then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local delta = (input.Position - pressPos).Magnitude
            pressPos = nil
            local now = os.clock()
            if delta <= 14 and (now - lastFire) >= 0.07 then
                lastFire = now
                callback(input.Position)
            end
        end
    end))
end

local function make3DButton(parent, text, size, pos, mainColor, darkColor, textColor, textSize, onTap)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = darkColor
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = parent
    addCorner(btn, 9)
    addStroke(btn, Color3.fromRGB(10, 18, 38), 1.6, 0.1)

    local face = Instance.new("Frame")
    face.Size = UDim2.new(1, 0, 1, -4)
    face.BackgroundColor3 = mainColor
    face.BorderSizePixel = 0
    face.ZIndex = btn.ZIndex + 1
    face.Parent = btn
    addCorner(face, 8)

    local gloss = Instance.new("Frame")
    gloss.Size = UDim2.new(1, -6, 0.40, 0)
    gloss.Position = UDim2.new(0, 3, 0, 2)
    gloss.BackgroundColor3 = Color3.fromRGB(205, 212, 215)
    gloss.BackgroundTransparency = 0.82
    gloss.BorderSizePixel = 0
    gloss.ZIndex = face.ZIndex + 1
    gloss.Parent = face
    addCorner(gloss, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = FONT_MAIN
    lbl.TextSize = textSize or 13
    lbl.TextColor3 = textColor or UITheme.TextPrimary
    lbl.ZIndex = gloss.ZIndex + 1
    lbl.Parent = face

    bindInstantTap(btn, onTap)
    return btn, face, lbl
end

local Icons = {}

function Icons.drawMinus(parent, color)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 14, 0, 2.8)
    bar.AnchorPoint = Vector2.new(0.5, 0.5)
    bar.Position = UDim2.new(0.5, 0, 0.5, 0)
    bar.BackgroundColor3 = color or UITheme.TextPrimary
    bar.BorderSizePixel = 0
    bar.ZIndex = parent.ZIndex + 2
    bar.Parent = parent
    addCorner(bar, 2)
end

function Icons.drawCloseX(parent, color)
    local col = color or UITheme.TextPrimary
    for _, rot in ipairs({ 45, -45 }) do
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 15, 0, 2.8)
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
        bar.Rotation = rot
        bar.BackgroundColor3 = col
        bar.BorderSizePixel = 0
        bar.ZIndex = parent.ZIndex + 2
        bar.Parent = parent
        addCorner(bar, 2)
    end
end

function Icons.drawHome(parent, color)
    local col = color or UITheme.TextPrimary
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(0, 18, 0, 18)
    wrap.AnchorPoint = Vector2.new(0.5, 0.5)
    wrap.Position = UDim2.new(0.5, 0, 0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = parent.ZIndex + 2
    wrap.Parent = parent
    for _, cfg in ipairs({ { -4, -38 }, { 4, 38 } }) do
        local roof = Instance.new("Frame")
        roof.Size = UDim2.new(0, 11, 0, 2.5)
        roof.AnchorPoint = Vector2.new(0.5, 0.5)
        roof.Position = UDim2.new(0.5, cfg[1], 0, 5)
        roof.Rotation = cfg[2]
        roof.BackgroundColor3 = col
        roof.BorderSizePixel = 0
        roof.ZIndex = wrap.ZIndex
        roof.Parent = wrap
        addCorner(roof, 2)
    end
    local body = Instance.new("Frame")
    body.Size = UDim2.new(0, 12, 0, 9)
    body.AnchorPoint = Vector2.new(0.5, 1)
    body.Position = UDim2.new(0.5, 0, 1, -1)
    body.BackgroundTransparency = 1
    body.ZIndex = wrap.ZIndex
    body.Parent = wrap
    addStroke(body, col, 2, 0)
    addCorner(body, 2)
end

function Icons.drawCastle(parent)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(0, 56, 0, 52)
    wrap.AnchorPoint = Vector2.new(0.5, 0.5)
    wrap.Position = UDim2.new(0.5, 0, 0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent

    -- Thân thành
    local base = Instance.new("Frame")
    base.Size = UDim2.new(0, 44, 0, 32)
    base.Position = UDim2.new(0.5, -22, 1, -32)
    base.BackgroundColor3 = Color3.fromRGB(132, 152, 184)
    base.BorderSizePixel = 0
    base.Parent = wrap
    addCorner(base, 4)
    addStroke(base, Color3.fromRGB(32, 44, 68), 2, 0)

    -- 3 Tháp nhỏ trên đỉnh thành
    for _, xOff in ipairs({ -22, -6, 10 }) do
        local merlon = Instance.new("Frame")
        merlon.Size = UDim2.new(0, 12, 0, 14)
        merlon.Position = UDim2.new(0.5, xOff, 0, 6)
        merlon.BackgroundColor3 = Color3.fromRGB(154, 174, 202)
        merlon.BorderSizePixel = 0
        merlon.Parent = wrap
        addCorner(merlon, 3)
        addStroke(merlon, Color3.fromRGB(32, 44, 68), 1.6, 0)
    end

    -- Cổng vòm
    local gate = Instance.new("Frame")
    gate.Size = UDim2.new(0, 14, 0, 18)
    gate.AnchorPoint = Vector2.new(0.5, 1)
    gate.Position = UDim2.new(0.5, 0, 1, 0)
    gate.BackgroundColor3 = Color3.fromRGB(64, 44, 34)
    gate.BorderSizePixel = 0
    gate.Parent = base
    addCorner(gate, 6)
end

function Icons.drawCoin(parent)
    local coin = Instance.new("Frame")
    coin.Size = UDim2.new(0, 20, 0, 20)
    coin.AnchorPoint = Vector2.new(0, 0.5)
    coin.Position = UDim2.new(0, 8, 0.5, 0)
    coin.BackgroundColor3 = Color3.fromRGB(204, 158, 44)
    coin.BorderSizePixel = 0
    coin.Parent = parent
    addCorner(coin, 12)
    addStroke(coin, Color3.fromRGB(28, 22, 14), 1.6, 0)
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(0, 12, 0, 12)
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.Position = UDim2.new(0.5, 0, 0.5, 0)
    inner.BackgroundColor3 = Color3.fromRGB(212, 178, 64)
    inner.BorderSizePixel = 0
    inner.Parent = coin
    addCorner(inner, 10)
end

local function createXuPill(parent)
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 118, 0, 34)
    pill.Position = UDim2.new(1, -212, 0.5, -17)
    pill.BackgroundColor3 = UITheme.BgPanelDark
    pill.BorderSizePixel = 0
    pill.Parent = parent
    addCorner(pill, 9)
    addStroke(pill, UITheme.ColorGold, 1.6, 0.1)
    Icons.drawCoin(pill)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -36, 1, 0)
    lbl.Position = UDim2.new(0, 32, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "0 Xu"
    lbl.Font = FONT_MAIN
    lbl.TextSize = 13
    lbl.TextColor3 = UITheme.ColorGold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = pill
    return lbl
end

local function makeArcadeIconBtn(parent, sizePx, pos, mainCol, darkCol, drawFn, onTap)
    local b, face = make3DButton(parent, "", UDim2.new(0, sizePx, 0, sizePx), pos, mainCol, darkCol, UITheme.TextPrimary, 12, onTap)
    if drawFn then drawFn(face, UITheme.TextPrimary) end
    return b
end

local SoundFolder = nil
local function playSfx(soundId, volume, pitch)
    if not Config.SoundEnabled or State.Destroyed or not SoundFolder then return end
    pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = soundId
        snd.Volume = volume or 0.25
        snd.PlaybackSpeed = pitch or 1.0
        snd.Parent = SoundFolder
        snd:Play()
        task.delay(1.0, function() if snd and snd.Parent then snd:Destroy() end end)
    end)
end

local function sfxShoot(pitch) playSfx("rbxassetid://421058925", 0.18, pitch or 1.3) end
local function sfxBuild()      playSfx("rbxassetid://421058925", 0.30, 1.05) end
local function sfxWin()        playSfx("rbxassetid://4590662766", 0.45, 1.0) end
local function sfxClick()      playSfx("rbxassetid://421058925", 0.22, 1.35) end

-- ========================================================================
-- [PHẦN 03] KHỞI TẠO SCREEN GUI & NÚT THU GỌN NỔI
-- ========================================================================
loadStats()

local guiParent = getGuiParent()
do
    local old = guiParent:FindFirstChild("ThuThanh2D_Standalone")
    if old then pcall(function() old:Destroy() end) end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThuThanh2D_Standalone"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = guiParent

SoundFolder = Instance.new("Folder")
SoundFolder.Name = "TdAudio"
SoundFolder.Parent = ScreenGui

local Root = Instance.new("Frame")
Root.Size = UDim2.new(1, 0, 1, 0)
Root.BackgroundColor3 = UITheme.BgMain
Root.BorderSizePixel = 0
Root.Active = true
Root.Parent = ScreenGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 114, 0, 38)
FloatBtn.Position = UDim2.new(0, 16, 0, 74)
FloatBtn.BackgroundColor3 = UITheme.BtnBlue
FloatBtn.BorderSizePixel = 0
FloatBtn.AutoButtonColor = false
FloatBtn.Text = "THỦ THÀNH"
FloatBtn.Font = FONT_MAIN
FloatBtn.TextSize = 13
FloatBtn.TextColor3 = UITheme.TextPrimary
FloatBtn.Visible = false
FloatBtn.ZIndex = 50
FloatBtn.Parent = ScreenGui
addCorner(FloatBtn, 10)
addStroke(FloatBtn, UITheme.RimBlue, 2, 0.05)

do
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    trackConn(FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; moved = false; dragStart = input.Position; startPos = FloatBtn.Position
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 8 then moved = true end
            FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            if not moved then
                State.Minimized = false
                Root.Visible = true
                FloatBtn.Visible = false
                sfxClick()
            end
        end
    end))
end

local openHomeScreen, enterGameScreen, startNewMatch, startNextWave, buildMapVisuals
local updateHomeUI, updateHud, updateSelectionUI, selectTower, clearSelection
local placeTowerAt, upgradeSelectedTower, sellSelectedTower, castLightningSkill, showBanner, hideBanner, showTempAlert

-- ========================================================================
-- [PHẦN 04] SẢNH CHÍNH (HOME SCREEN)
-- ========================================================================
local HomeScreen = Instance.new("Frame")
HomeScreen.Size = UDim2.new(1, 0, 1, 0)
HomeScreen.BackgroundColor3 = UITheme.BgMain
HomeScreen.BorderSizePixel = 0
HomeScreen.Visible = true
HomeScreen.Parent = Root
addGradient(HomeScreen, UITheme.BgMainLight, UITheme.BgMain, 135)

do
    local HomeTop = Instance.new("Frame")
    HomeTop.Size = UDim2.new(1, 0, 0, 52)
    HomeTop.BackgroundColor3 = UITheme.BgPanel
    HomeTop.BorderSizePixel = 0
    HomeTop.Parent = HomeScreen
    addStroke(HomeTop, UITheme.RimBlue, 1.5, 0.2)

    local Brand = Instance.new("TextLabel")
    Brand.Size = UDim2.new(0, 200, 1, 0)
    Brand.Position = UDim2.new(0, 18, 0, 0)
    Brand.BackgroundTransparency = 1
    Brand.Text = "THỦ THÀNH 2D"
    Brand.Font = FONT_MAIN
    Brand.TextSize = 18
    Brand.TextColor3 = UITheme.ColorGold
    Brand.TextXAlignment = Enum.TextXAlignment.Left
    Brand.Parent = HomeTop

    UI.HomeXuLabel = createXuPill(HomeTop)

    makeArcadeIconBtn(HomeTop, 36, UDim2.new(1, -88, 0.5, -18), UITheme.BtnBlue, UITheme.BtnBlueDark, Icons.drawMinus, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    makeArcadeIconBtn(HomeTop, 36, UDim2.new(1, -44, 0.5, -18), UITheme.BtnRed, UITheme.BtnRedDark, Icons.drawCloseX, function()
        if _G.ThuThanh2DCleanup then _G.ThuThanh2DCleanup() end
    end)

    local HomeBody = Instance.new("Frame")
    HomeBody.Size = UDim2.new(1, -24, 1, -68)
    HomeBody.Position = UDim2.new(0, 12, 0, 60)
    HomeBody.BackgroundTransparency = 1
    HomeBody.Parent = HomeScreen

    -- CỘT TRÁI
    local LeftCard = Instance.new("Frame")
    LeftCard.Size = UDim2.new(0.40, -8, 1, 0)
    LeftCard.BackgroundColor3 = UITheme.BgPanel
    LeftCard.BorderSizePixel = 0
    LeftCard.Parent = HomeBody
    addCorner(LeftCard, 14)
    addStroke(LeftCard, UITheme.RimBlue, 2.2, 0.1)
    addGradient(LeftCard, UITheme.BgCard, UITheme.BgPanelDark, 135)

    local Crest = Instance.new("Frame")
    Crest.Size = UDim2.new(0, 94, 0, 84)
    Crest.AnchorPoint = Vector2.new(0.5, 0)
    Crest.Position = UDim2.new(0.5, 0, 0, 26)
    Crest.BackgroundColor3 = UITheme.BgPanelDark
    Crest.BorderSizePixel = 0
    Crest.Parent = LeftCard
    addCorner(Crest, 14)
    addStroke(Crest, UITheme.ColorGold, 2, 0.15)
    Icons.drawCastle(Crest)

    local HeroTitle = Instance.new("TextLabel")
    HeroTitle.Size = UDim2.new(1, -20, 0, 34)
    HeroTitle.Position = UDim2.new(0, 10, 0, 122)
    HeroTitle.BackgroundTransparency = 1
    HeroTitle.Text = "THỦ THÀNH 2D"
    HeroTitle.Font = FONT_MAIN
    HeroTitle.TextSize = 24
    HeroTitle.TextColor3 = UITheme.TextPrimary
    HeroTitle.Parent = LeftCard

    make3DButton(LeftCard, "CHƠI NGAY", UDim2.new(1, -32, 0, 48), UDim2.new(0, 16, 1, -68), UITheme.BtnGreen, UITheme.BtnGreenDark, UITheme.TextPrimary, 16, function()
        sfxClick()
        enterGameScreen()
    end)

    -- CỘT PHẢI: Chọn Bản đồ + Độ khó + Giới thiệu 4 Tháp
    local RightCard = Instance.new("ScrollingFrame")
    RightCard.Size = UDim2.new(0.60, -4, 1, 0)
    RightCard.Position = UDim2.new(0.40, 4, 0, 0)
    RightCard.BackgroundColor3 = UITheme.BgPanel
    RightCard.BorderSizePixel = 0
    RightCard.ScrollBarThickness = 4
    RightCard.ScrollBarImageColor3 = UITheme.RimBlue
    RightCard.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightCard.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightCard.Parent = HomeBody
    addCorner(RightCard, 14)
    addStroke(RightCard, UITheme.RimBlue, 2.2, 0.1)
    addGradient(RightCard, UITheme.BgCard, UITheme.BgPanelDark, 135)

    local rPad = Instance.new("UIPadding")
    rPad.PaddingTop = UDim.new(0, 12)
    rPad.PaddingBottom = UDim.new(0, 12)
    rPad.PaddingLeft = UDim.new(0, 14)
    rPad.PaddingRight = UDim.new(0, 14)
    rPad.Parent = RightCard

    local rList = Instance.new("UIListLayout")
    rList.SortOrder = Enum.SortOrder.LayoutOrder
    rList.Padding = UDim.new(0, 9)
    rList.Parent = RightCard

    local function makeHeader(text, order)
        local lbl = Instance.new("TextLabel")
        lbl.LayoutOrder = order
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = FONT_MAIN
        lbl.TextSize = 11
        lbl.TextColor3 = UITheme.TextSecondary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = RightCard
        return lbl
    end

    makeHeader("CHỌN BẢN ĐỒ", 1)

    local MapRow = Instance.new("Frame")
    MapRow.LayoutOrder = 2
    MapRow.Size = UDim2.new(1, 0, 0, 74)
    MapRow.BackgroundTransparency = 1
    MapRow.Parent = RightCard

    UI.HomeMapBtns = {}
    for idx, m in ipairs(MAPS) do
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0.32, 0, 1, 0)
        card.Position = UDim2.new((idx - 1) * 0.34, 0, 0, 0)
        card.BackgroundColor3 = UITheme.BgButton
        card.BorderSizePixel = 0
        card.AutoButtonColor = false
        card.Text = ""
        card.Parent = MapRow
        addCorner(card, 9)
        local st = addStroke(card, UITheme.StrokeSubtle, 1.5, 0.15)

        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, -6, 0, 22)
        t1.Position = UDim2.new(0, 3, 0, 8)
        t1.BackgroundTransparency = 1
        t1.Text = m.name
        t1.Font = FONT_MAIN
        t1.TextSize = 12
        t1.TextColor3 = UITheme.TextPrimary
        t1.Parent = card

        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, -6, 0, 16)
        t2.Position = UDim2.new(0, 3, 0, 32)
        t2.BackgroundTransparency = 1
        t2.Text = m.waves .. " đợt quái"
        t2.Font = FONT_BODY
        t2.TextSize = 10
        t2.TextColor3 = UITheme.TextSecondary
        t2.Parent = card

        local t3 = Instance.new("TextLabel")
        t3.Size = UDim2.new(1, -6, 0, 16)
        t3.Position = UDim2.new(0, 3, 0, 50)
        t3.BackgroundTransparency = 1
        t3.Text = "+" .. m.rewardXu .. " Xu"
        t3.Font = FONT_MAIN
        t3.TextSize = 11
        t3.TextColor3 = UITheme.ColorGold
        t3.Parent = card

        local mIdx = idx
        bindInstantTap(card, function()
            Config.MapIndex = mIdx
            sfxClick()
            updateHomeUI()
        end)
        UI.HomeMapBtns[mIdx] = { card = card, stroke = st, t1 = t1, t3 = t3 }
    end

    makeHeader("ĐỘ KHÓ", 3)

    local DiffRow = Instance.new("Frame")
    DiffRow.LayoutOrder = 4
    DiffRow.Size = UDim2.new(1, 0, 0, 36)
    DiffRow.BackgroundTransparency = 1
    DiffRow.Parent = RightCard

    UI.HomeDiffBtns = {}
    for idx, d in ipairs(DIFFS) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.32, 0, 1, 0)
        b.Position = UDim2.new((idx - 1) * 0.34, 0, 0, 0)
        b.BackgroundColor3 = UITheme.BgButton
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Text = d.label
        b.Font = FONT_MAIN
        b.TextSize = 12
        b.TextColor3 = UITheme.TextSecondary
        b.Parent = DiffRow
        addCorner(b, 8)
        local st = addStroke(b, UITheme.StrokeSubtle, 1.4, 0.2)
        local dIdx = idx
        bindInstantTap(b, function()
            Config.DiffIndex = dIdx
            sfxClick()
            updateHomeUI()
        end)
        UI.HomeDiffBtns[dIdx] = { btn = b, stroke = st }
    end

    makeHeader("KHO THÁP PHÒNG THỦ", 5)

    local InfoRow = Instance.new("Frame")
    InfoRow.LayoutOrder = 6
    InfoRow.Size = UDim2.new(1, 0, 0, 58)
    InfoRow.BackgroundTransparency = 1
    InfoRow.Parent = RightCard

    for idx, tw in ipairs(TOWERS) do
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0.238, 0, 1, 0)
        box.Position = UDim2.new((idx - 1) * 0.254, 0, 0, 0)
        box.BackgroundColor3 = UITheme.BgPanelDark
        box.BorderSizePixel = 0
        box.Parent = InfoRow
        addCorner(box, 8)
        addStroke(box, tw.color, 1.4, 0.25)

        local nLbl = Instance.new("TextLabel")
        nLbl.Size = UDim2.new(1, -4, 0, 20)
        nLbl.Position = UDim2.new(0, 2, 0, 6)
        nLbl.BackgroundTransparency = 1
        nLbl.Text = tw.name
        nLbl.Font = FONT_MAIN
        nLbl.TextSize = 11
        nLbl.TextColor3 = tw.color
        nLbl.Parent = box

        local dLbl = Instance.new("TextLabel")
        dLbl.Size = UDim2.new(1, -4, 0, 16)
        dLbl.Position = UDim2.new(0, 2, 0, 26)
        dLbl.BackgroundTransparency = 1
        dLbl.Text = tw.desc
        dLbl.Font = FONT_BODY
        dLbl.TextSize = 10
        dLbl.TextColor3 = UITheme.TextSecondary
        dLbl.Parent = box

        local cLbl = Instance.new("TextLabel")
        cLbl.Size = UDim2.new(1, -4, 0, 14)
        cLbl.Position = UDim2.new(0, 2, 0, 42)
        cLbl.BackgroundTransparency = 1
        cLbl.Text = tw.cost .. " Vàng"
        cLbl.Font = FONT_MAIN
        cLbl.TextSize = 10
        cLbl.TextColor3 = UITheme.ColorGold
        cLbl.Parent = box
    end
end

-- ========================================================================
-- [PHẦN 05] MÀN HÌNH TRONG TRẬN (BẢN ĐỒ + BẢNG THÁP BÊN PHẢI)
-- ========================================================================
local GameScreen = Instance.new("Frame")
GameScreen.Size = UDim2.new(1, 0, 1, 0)
GameScreen.BackgroundColor3 = UITheme.BgMain
GameScreen.BorderSizePixel = 0
GameScreen.Visible = false
GameScreen.Parent = Root
addGradient(GameScreen, UITheme.BgMainLight, UITheme.BgMain, 135)

do
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.BackgroundColor3 = UITheme.BgPanel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = GameScreen
    addStroke(TopBar, UITheme.RimBlue, 1.5, 0.2)

    makeArcadeIconBtn(TopBar, 36, UDim2.new(0, 12, 0.5, -18), UITheme.BtnBlue, UITheme.BtnBlueDark, Icons.drawHome, function()
        sfxClick()
        openHomeScreen()
    end)

    local MapLbl = Instance.new("TextLabel")
    MapLbl.Size = UDim2.new(0, 150, 0, 18)
    MapLbl.Position = UDim2.new(0, 58, 0, 8)
    MapLbl.BackgroundTransparency = 1
    MapLbl.Text = "Thảo Nguyên"
    MapLbl.Font = FONT_MAIN
    MapLbl.TextSize = 13
    MapLbl.TextColor3 = UITheme.TextPrimary
    MapLbl.TextXAlignment = Enum.TextXAlignment.Left
    MapLbl.Parent = TopBar
    UI.MapLbl = MapLbl

    local WaveLbl = Instance.new("TextLabel")
    WaveLbl.Size = UDim2.new(0, 150, 0, 16)
    WaveLbl.Position = UDim2.new(0, 58, 0, 28)
    WaveLbl.BackgroundTransparency = 1
    WaveLbl.Text = "Đợt: 0/10"
    WaveLbl.Font = FONT_BODY
    WaveLbl.TextSize = 11
    WaveLbl.TextColor3 = UITheme.AccentCyan
    WaveLbl.TextXAlignment = Enum.TextXAlignment.Left
    WaveLbl.Parent = TopBar
    UI.WaveLbl = WaveLbl

    local StatusPill = Instance.new("Frame")
    StatusPill.Size = UDim2.new(0, 240, 0, 36)
    StatusPill.AnchorPoint = Vector2.new(0.5, 0.5)
    StatusPill.Position = UDim2.new(0.5, 0, 0.5, 0)
    StatusPill.BackgroundColor3 = UITheme.BgPanelDark
    StatusPill.BorderSizePixel = 0
    StatusPill.Parent = TopBar
    addCorner(StatusPill, 9)
    addStroke(StatusPill, UITheme.RimBlue, 1.6, 0.1)

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -12, 1, 0)
    StatusText.Position = UDim2.new(0, 6, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Thành: 20  |  Vàng: 160"
    StatusText.Font = FONT_MAIN
    StatusText.TextSize = 13
    StatusText.TextColor3 = UITheme.TextPrimary
    StatusText.Parent = StatusPill
    UI.StatusText = StatusText

    UI.GameXuLabel = createXuPill(TopBar)

    makeArcadeIconBtn(TopBar, 36, UDim2.new(1, -88, 0.5, -18), UITheme.BtnBlue, UITheme.BtnBlueDark, Icons.drawMinus, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    makeArcadeIconBtn(TopBar, 36, UDim2.new(1, -44, 0.5, -18), UITheme.BtnRed, UITheme.BtnRedDark, Icons.drawCloseX, function()
        if _G.ThuThanh2DCleanup then _G.ThuThanh2DCleanup() end
    end)
end

local MainArea = Instance.new("Frame")
MainArea.Size = UDim2.new(1, -16, 1, -60)
MainArea.Position = UDim2.new(0, 8, 0, 56)
MainArea.BackgroundTransparency = 1
MainArea.Parent = GameScreen

-- Khung Bản Đồ (trái)
local MapContainer = Instance.new("Frame")
MapContainer.Size = UDim2.new(1, -248, 1, 0)
MapContainer.BackgroundColor3 = UITheme.BgPanelDark
MapContainer.BorderSizePixel = 0
MapContainer.ClipsDescendants = true
MapContainer.Parent = MainArea
addCorner(MapContainer, 14)
addStroke(MapContainer, UITheme.RimBlue, 2.2, 0.1)

local AlertStrip = Instance.new("TextLabel")
AlertStrip.Size = UDim2.new(0, 270, 0, 24)
AlertStrip.AnchorPoint = Vector2.new(0.5, 0)
AlertStrip.Position = UDim2.new(0.5, 0, 0, 8)
AlertStrip.BackgroundColor3 = UITheme.BgPanelDark
AlertStrip.BackgroundTransparency = 0.05
AlertStrip.BorderSizePixel = 0
AlertStrip.Text = ""
AlertStrip.Font = FONT_MAIN
AlertStrip.TextSize = 11
AlertStrip.TextColor3 = UITheme.ColorGold
AlertStrip.Visible = false
AlertStrip.ZIndex = 30
AlertStrip.Parent = MapContainer
addCorner(AlertStrip, 7)
addStroke(AlertStrip, UITheme.ColorGold, 1.4, 0.15)
UI.AlertStrip = AlertStrip

local MapFrame = Instance.new("Frame")
MapFrame.Name = "MapFrame"
MapFrame.Size = UDim2.new(0, 480, 0, 320)
MapFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MapFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MapFrame.BackgroundColor3 = UITheme.BgMain
MapFrame.BorderSizePixel = 0
MapFrame.ClipsDescendants = true
MapFrame.Parent = MapContainer
addCorner(MapFrame, 8)
addStroke(MapFrame, Color3.fromRGB(16, 36, 76), 2, 0.1)

local TilesLayer = Instance.new("Frame")
TilesLayer.Size = UDim2.new(1, 0, 1, 0)
TilesLayer.BackgroundTransparency = 1
TilesLayer.ZIndex = 2
TilesLayer.Parent = MapFrame

local RangeLayer = Instance.new("Frame")
RangeLayer.Size = UDim2.new(1, 0, 1, 0)
RangeLayer.BackgroundTransparency = 1
RangeLayer.ZIndex = 4
RangeLayer.Parent = MapFrame

local TowersLayer = Instance.new("Frame")
TowersLayer.Size = UDim2.new(1, 0, 1, 0)
TowersLayer.BackgroundTransparency = 1
TowersLayer.ZIndex = 6
TowersLayer.Parent = MapFrame

local EnemiesLayer = Instance.new("Frame")
EnemiesLayer.Size = UDim2.new(1, 0, 1, 0)
EnemiesLayer.BackgroundTransparency = 1
EnemiesLayer.ZIndex = 9
EnemiesLayer.Parent = MapFrame

local FxLayer = Instance.new("Frame")
FxLayer.Size = UDim2.new(1, 0, 1, 0)
FxLayer.BackgroundTransparency = 1
FxLayer.ZIndex = 12
FxLayer.Parent = MapFrame

-- Vòng tầm bắn dùng lại khi chọn tháp
local RangeCircle = Instance.new("Frame")
RangeCircle.BackgroundColor3 = UITheme.AccentCyan
RangeCircle.BackgroundTransparency = 0.86
RangeCircle.BorderSizePixel = 0
RangeCircle.AnchorPoint = Vector2.new(0.5, 0.5)
RangeCircle.Visible = false
RangeCircle.ZIndex = 4
RangeCircle.Parent = RangeLayer
addCorner(RangeCircle, 400)
addStroke(RangeCircle, UITheme.AccentCyan, 1.5, 0.25)

local MapInput = Instance.new("TextButton")
MapInput.Size = UDim2.new(1, 0, 1, 0)
MapInput.BackgroundTransparency = 1
MapInput.Text = ""
MapInput.AutoButtonColor = false
MapInput.ZIndex = 16
MapInput.Parent = MapFrame

bindInstantTap(MapInput, function(screenPos)
    if State.GameOver then return end
    local absPos = MapFrame.AbsolutePosition
    local ts = State.TileSize
    local col = math.floor((screenPos.X - absPos.X) / ts) + 1
    local row = math.floor((screenPos.Y - absPos.Y) / ts) + 1
    if col < 1 or col > GRID_COLS or row < 1 or row > GRID_ROWS then return end

    local existing = State.TowerGrid[row] and State.TowerGrid[row][col]
    if existing then
        selectTower(existing)
        sfxClick()
        return
    end

    if State.PathCells[row] and State.PathCells[row][col] then
        clearSelection()
        return
    end

    placeTowerAt(row, col)
end)

-- Banner kết thúc trận
do
    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(0, 320, 0, 168)
    Banner.AnchorPoint = Vector2.new(0.5, 0.5)
    Banner.Position = UDim2.new(0.5, 0, 0.5, 0)
    Banner.BackgroundColor3 = UITheme.BgCard
    Banner.BorderSizePixel = 0
    Banner.Visible = false
    Banner.ZIndex = 35
    Banner.Parent = MapContainer
    addCorner(Banner, 14)
    UI.BannerStroke = addStroke(Banner, UITheme.RimBlue, 2.5, 0.05)
    UI.EndBanner = Banner

    local BTitle = Instance.new("TextLabel")
    BTitle.Size = UDim2.new(1, -20, 0, 34)
    BTitle.Position = UDim2.new(0, 10, 0, 18)
    BTitle.BackgroundTransparency = 1
    BTitle.Text = "CHIẾN THẮNG!"
    BTitle.Font = FONT_MAIN
    BTitle.TextSize = 22
    BTitle.TextColor3 = UITheme.ColorGold
    BTitle.ZIndex = 36
    BTitle.Parent = Banner
    UI.BTitle = BTitle

    local BSub = Instance.new("TextLabel")
    BSub.Size = UDim2.new(1, -20, 0, 36)
    BSub.Position = UDim2.new(0, 10, 0, 58)
    BSub.BackgroundTransparency = 1
    BSub.Text = ""
    BSub.Font = FONT_BODY
    BSub.TextSize = 13
    BSub.TextColor3 = UITheme.TextPrimary
    BSub.TextWrapped = true
    BSub.ZIndex = 36
    BSub.Parent = Banner
    UI.BSub = BSub

    local rBtn = make3DButton(Banner, "Chơi lại", UDim2.new(0, 138, 0, 38), UDim2.new(0, 16, 1, -50), UITheme.BtnGreen, UITheme.BtnGreenDark, UITheme.TextPrimary, 13, function()
        sfxClick()
        startNewMatch()
    end)
    rBtn.ZIndex = 36

    local hBtn = make3DButton(Banner, "Trang chủ", UDim2.new(0, 138, 0, 38), UDim2.new(1, -154, 1, -50), UITheme.BtnBlue, UITheme.BtnBlueDark, UITheme.TextPrimary, 13, function()
        sfxClick()
        hideBanner()
        openHomeScreen()
    end)
    hBtn.ZIndex = 36
end

-- ========================================================================
-- [PHẦN 06] BẢNG ĐIỀU KHIỂN PHẢI (CHỌN THÁP, NÂNG CẤP, KỸ NĂNG & ĐỢT QUÁI)
-- ========================================================================
do
    local SidePanel = Instance.new("ScrollingFrame")
    SidePanel.Size = UDim2.new(0, 240, 1, 0)
    SidePanel.Position = UDim2.new(1, -240, 0, 0)
    SidePanel.BackgroundColor3 = UITheme.BgPanel
    SidePanel.BorderSizePixel = 0
    SidePanel.ScrollBarThickness = 4
    SidePanel.ScrollBarImageColor3 = UITheme.RimBlue
    SidePanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidePanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidePanel.Parent = MainArea
    addCorner(SidePanel, 14)
    addStroke(SidePanel, UITheme.RimBlue, 2.2, 0.1)
    addGradient(SidePanel, UITheme.BgCard, UITheme.BgPanelDark, 135)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = SidePanel

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 7)
    layout.Parent = SidePanel

    -- 4 Thẻ chọn Tháp (2x2)
    local TowerGrid = Instance.new("Frame")
    TowerGrid.LayoutOrder = 1
    TowerGrid.Size = UDim2.new(1, 0, 0, 108)
    TowerGrid.BackgroundTransparency = 1
    TowerGrid.Parent = SidePanel

    UI.TowerBtns = {}
    for idx, tw in ipairs(TOWERS) do
        local col = (idx - 1) % 2
        local row = math.floor((idx - 1) / 2)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0.485, 0, 0, 50)
        card.Position = UDim2.new(col * 0.515, 0, 0, row * 56)
        card.BackgroundColor3 = UITheme.BgPanelDark
        card.BorderSizePixel = 0
        card.AutoButtonColor = false
        card.Text = ""
        card.Parent = TowerGrid
        addCorner(card, 9)
        local st = addStroke(card, tw.color, 1.5, 0.25)

        local nLbl = Instance.new("TextLabel")
        nLbl.Size = UDim2.new(1, -6, 0, 20)
        nLbl.Position = UDim2.new(0, 3, 0, 5)
        nLbl.BackgroundTransparency = 1
        nLbl.Text = tw.name
        nLbl.Font = FONT_MAIN
        nLbl.TextSize = 12
        nLbl.TextColor3 = tw.color
        nLbl.Parent = card

        local cLbl = Instance.new("TextLabel")
        cLbl.Size = UDim2.new(1, -6, 0, 18)
        cLbl.Position = UDim2.new(0, 3, 0, 27)
        cLbl.BackgroundTransparency = 1
        cLbl.Text = tw.cost .. " Vàng"
        cLbl.Font = FONT_BODY
        cLbl.TextSize = 11
        cLbl.TextColor3 = UITheme.ColorGold
        cLbl.Parent = card

        local tIdx = idx
        bindInstantTap(card, function()
            State.SelectedTool = tIdx
            clearSelection()
            sfxClick()
            updateSelectionUI()
        end)
        UI.TowerBtns[tIdx] = { card = card, stroke = st }
    end

    -- Khung Nâng cấp / Bán khi bấm vào 1 tháp trên bản đồ
    local SelBox = Instance.new("Frame")
    SelBox.LayoutOrder = 2
    SelBox.Size = UDim2.new(1, 0, 0, 66)
    SelBox.BackgroundColor3 = UITheme.BgPanelDark
    SelBox.BorderSizePixel = 0
    SelBox.Visible = false
    SelBox.Parent = SidePanel
    addCorner(SelBox, 9)
    addStroke(SelBox, UITheme.ColorGold, 1.5, 0.15)
    UI.SelBox = SelBox

    local SelTitle = Instance.new("TextLabel")
    SelTitle.Size = UDim2.new(1, -10, 0, 20)
    SelTitle.Position = UDim2.new(0, 5, 0, 4)
    SelTitle.BackgroundTransparency = 1
    SelTitle.Text = "Tháp Cung Lv1"
    SelTitle.Font = FONT_MAIN
    SelTitle.TextSize = 12
    SelTitle.TextColor3 = UITheme.ColorGold
    SelTitle.Parent = SelBox
    UI.SelTitle = SelTitle

    UI.UpBtn, UI.UpFace, UI.UpLbl = make3DButton(SelBox, "Nâng 60V", UDim2.new(0.47, 0, 0, 32), UDim2.new(0, 5, 1, -37), UITheme.BtnGreen, UITheme.BtnGreenDark, UITheme.TextPrimary, 11, function()
        upgradeSelectedTower()
    end)

    UI.SellBtn, UI.SellFace, UI.SellLbl = make3DButton(SelBox, "Bán +35V", UDim2.new(0.47, 0, 0, 32), UDim2.new(0.51, 0, 1, -37), UITheme.BtnRed, UITheme.BtnRedDark, UITheme.TextPrimary, 11, function()
        sellSelectedTower()
    end)

    -- Nút Gọi Đợt Quái
    UI.WaveBtn, UI.WaveFace, UI.WaveBtnLbl = make3DButton(SidePanel, "GỌI ĐỢT QUÁI", UDim2.new(1, 0, 0, 38), UDim2.new(0, 0, 0, 0), UITheme.BtnGreen, UITheme.BtnGreenDark, UITheme.TextPrimary, 13, function()
        sfxClick()
        startNextWave()
    end)
    UI.WaveBtn.LayoutOrder = 3

    -- Kỹ năng Sấm Sét Toàn Bản Đồ dùng Xu
    local skillBtn = make3DButton(SidePanel, "Sấm Sét Toàn Đồ 25 Xu", UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 0), UITheme.BtnPurple, UITheme.BtnPurpleDark, UITheme.ColorGold, 12, function()
        castLightningSkill()
    end)
    skillBtn.LayoutOrder = 4

    -- Hàng Tốc độ 1x/2x & Tự động gọi đợt
    local CtrlRow = Instance.new("Frame")
    CtrlRow.LayoutOrder = 5
    CtrlRow.Size = UDim2.new(1, 0, 0, 34)
    CtrlRow.BackgroundTransparency = 1
    CtrlRow.Parent = SidePanel

    UI.SpdBtn, UI.SpdFace, UI.SpdLbl = make3DButton(CtrlRow, "Tốc độ: 1x", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BtnBlue, UITheme.BtnBlueDark, UITheme.TextPrimary, 11, function()
        State.GameSpeed = (State.GameSpeed == 1) and 2 or 1
        sfxClick()
        updateSelectionUI()
    end)

    UI.AutoBtn, UI.AutoFace, UI.AutoLbl = make3DButton(CtrlRow, "Tự gọi: Tắt", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), UITheme.BgButton, UITheme.BgPanelDark, UITheme.TextSecondary, 11, function()
        Config.AutoWave = not Config.AutoWave
        sfxClick()
        updateSelectionUI()
    end)

    -- Hàng Tạm dừng & Chơi lại
    local CtrlRow2 = Instance.new("Frame")
    CtrlRow2.LayoutOrder = 6
    CtrlRow2.Size = UDim2.new(1, 0, 0, 34)
    CtrlRow2.BackgroundTransparency = 1
    CtrlRow2.Parent = SidePanel

    UI.PauseBtn, UI.PauseFace, UI.PauseLbl = make3DButton(CtrlRow2, "Tạm dừng", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BgButton, UITheme.BgPanelDark, UITheme.TextPrimary, 11, function()
        State.Paused = not State.Paused
        sfxClick()
        updateSelectionUI()
    end)

    make3DButton(CtrlRow2, "Chơi lại", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), UITheme.BtnRed, UITheme.BtnRedDark, UITheme.TextPrimary, 11, function()
        sfxClick()
        startNewMatch()
    end)
end

-- ========================================================================
-- [PHẦN 07] XÂY DỰNG BẢN ĐỒ, THÁP, QUÁI & HIỆU ỨNG CHIẾN ĐẤU
-- ========================================================================
showTempAlert = function(msg)
    UI.AlertStrip.Text = msg
    UI.AlertStrip.Visible = true
    local token = os.clock()
    State.TempAlertToken = token
    task.delay(2.2, function()
        if not State.Destroyed and State.TempAlertToken == token then
            UI.AlertStrip.Visible = false
        end
    end)
end

showBanner = function(isWin, titleText, subText)
    UI.EndBanner.BackgroundColor3 = isWin and Color3.fromRGB(20, 62, 146) or Color3.fromRGB(134, 24, 34)
    UI.BannerStroke.Color = isWin and UITheme.RimBlue or Color3.fromRGB(206, 86, 86)
    UI.BTitle.Text = titleText
    UI.BTitle.TextColor3 = isWin and UITheme.ColorGold or UITheme.TextPrimary
    UI.BSub.Text = subText
    UI.EndBanner.Visible = true
end

hideBanner = function()
    UI.EndBanner.Visible = false
end

local function computePathCells(waypoints)
    State.PathCells = {}
    State.PathPoints = {}
    for r = 1, GRID_ROWS do State.PathCells[r] = {} end

    for i = 1, #waypoints do
        table.insert(State.PathPoints, { x = waypoints[i][1] - 0.5, y = waypoints[i][2] - 0.5 })
        if i < #waypoints then
            local c1, r1 = waypoints[i][1], waypoints[i][2]
            local c2, r2 = waypoints[i + 1][1], waypoints[i + 1][2]
            local dc = (c2 > c1) and 1 or ((c2 < c1) and -1 or 0)
            local dr = (r2 > r1) and 1 or ((r2 < r1) and -1 or 0)
            local cc, rr = c1, r1
            while true do
                State.PathCells[rr][cc] = true
                if cc == c2 and rr == r2 then break end
                cc = cc + dc
                rr = rr + dr
            end
        end
    end
end

buildMapVisuals = function()
    for _, ch in ipairs(TilesLayer:GetChildren()) do ch:Destroy() end
    for _, ch in ipairs(TowersLayer:GetChildren()) do ch:Destroy() end
    for _, ch in ipairs(EnemiesLayer:GetChildren()) do ch:Destroy() end
    for _, ch in ipairs(FxLayer:GetChildren()) do ch:Destroy() end

    local m = getMap()
    computePathCells(m.waypoints)

    local availW = math.max(240, MapContainer.AbsoluteSize.X - 20)
    local availH = math.max(180, MapContainer.AbsoluteSize.Y - 20)
    local ts = math.clamp(math.floor(math.min(availW / GRID_COLS, availH / GRID_ROWS)), 24, 56)
    State.TileSize = ts
    MapFrame.Size = UDim2.new(0, GRID_COLS * ts, 0, GRID_ROWS * ts)

    for r = 1, GRID_ROWS do
        for c = 1, GRID_COLS do
            local isPath = State.PathCells[r][c] == true
            local tile = Instance.new("Frame")
            tile.Size = UDim2.new(0, ts, 0, ts)
            tile.Position = UDim2.new(0, (c - 1) * ts, 0, (r - 1) * ts)
            if isPath then
                tile.BackgroundColor3 = m.pathCol
                tile.BorderColor3 = m.pathRim
                tile.BorderSizePixel = 1
            else
                tile.BackgroundColor3 = ((r + c) % 2 == 0) and m.bgTile or m.bgTile2
                tile.BorderColor3 = Color3.fromRGB(22, 34, 46)
                tile.BorderSizePixel = 1
            end
            tile.ZIndex = 2
            tile.Parent = TilesLayer
        end
    end

    -- Đánh dấu Cổng Quái (đầu đường) & Thành Chính (cuối đường)
    local firstWp = m.waypoints[1]
    local startMark = Instance.new("TextLabel")
    startMark.Size = UDim2.new(0, ts, 0, ts)
    startMark.Position = UDim2.new(0, (firstWp[1] - 1) * ts, 0, (firstWp[2] - 1) * ts)
    startMark.BackgroundColor3 = Color3.fromRGB(132, 34, 46)
    startMark.BorderSizePixel = 0
    startMark.Text = "QUÁI"
    startMark.Font = FONT_MAIN
    startMark.TextSize = math.clamp(math.floor(ts * 0.28), 9, 13)
    startMark.TextColor3 = UITheme.TextPrimary
    startMark.ZIndex = 3
    startMark.Parent = TilesLayer
    addCorner(startMark, 6)

    local lastWp = m.waypoints[#m.waypoints]
    local endMark = Instance.new("TextLabel")
    endMark.Size = UDim2.new(0, ts, 0, ts)
    endMark.Position = UDim2.new(0, (lastWp[1] - 1) * ts, 0, (lastWp[2] - 1) * ts)
    endMark.BackgroundColor3 = UITheme.BtnBlue
    endMark.BorderSizePixel = 0
    endMark.Text = "THÀNH"
    endMark.Font = FONT_MAIN
    endMark.TextSize = math.clamp(math.floor(ts * 0.25), 8, 12)
    endMark.TextColor3 = UITheme.ColorGold
    endMark.ZIndex = 3
    endMark.Parent = TilesLayer
    addCorner(endMark, 6)
end

local function spawnFxRing(gx, gy, radiusTiles, color, duration)
    local ts = State.TileSize
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, ts * 0.4, 0, ts * 0.4)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0, gx * ts, 0, gy * ts)
    f.BackgroundColor3 = color
    f.BackgroundTransparency = 0.55
    f.BorderSizePixel = 0
    f.ZIndex = 12
    f.Parent = FxLayer
    addCorner(f, 200)
    addStroke(f, color, 2, 0.1)

    table.insert(State.Effects, {
        node = f,
        life = 0,
        maxLife = duration or 0.26,
        startPx = ts * 0.4,
        endPx = radiusTiles * 2 * ts,
        kind = "RING",
    })
end

local function spawnBeam(x1, y1, x2, y2, color)
    local ts = State.TileSize
    local px1, py1, px2, py2 = x1 * ts, y1 * ts, x2 * ts, y2 * ts
    local dx, dy = px2 - px1, py2 - py1
    local len = math.sqrt(dx * dx + dy * dy)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, len, 0, 3)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(0, (px1 + px2) / 2, 0, (py1 + py2) / 2)
    line.Rotation = math.deg(math.atan2(dy, dx))
    line.BackgroundColor3 = color
    line.BorderSizePixel = 0
    line.ZIndex = 13
    line.Parent = FxLayer

    table.insert(State.Effects, {
        node = line,
        life = 0,
        maxLife = 0.16,
        kind = "BEAM",
    })
end

-- ========================================================================
-- [PHẦN 08] ĐẶT THÁP, NÂNG CẤP, BÁN THÁP & KỸ NĂNG SẤM SÉT
-- ========================================================================
clearSelection = function()
    State.SelectedTower = nil
    RangeCircle.Visible = false
    updateSelectionUI()
end

selectTower = function(tw)
    State.SelectedTower = tw
    local ts = State.TileSize
    local diam = tw.range * 2 * ts
    RangeCircle.Size = UDim2.new(0, diam, 0, diam)
    RangeCircle.Position = UDim2.new(0, (tw.c - 0.5) * ts, 0, (tw.r - 0.5) * ts)
    RangeCircle.Visible = true
    updateSelectionUI()
end

placeTowerAt = function(r, c)
    local spec = TOWERS[State.SelectedTool]
    if not spec then return end
    if State.Gold < spec.cost then
        showTempAlert("Không đủ Vàng! Cần " .. spec.cost .. " Vàng")
        return
    end

    State.Gold = State.Gold - spec.cost
    sfxBuild()

    local ts = State.TileSize
    local base = Instance.new("Frame")
    base.Size = UDim2.new(0, ts - 6, 0, ts - 6)
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.Position = UDim2.new(0, (c - 0.5) * ts, 0, (r - 0.5) * ts)
    base.BackgroundColor3 = Color3.fromRGB(28, 38, 56)
    base.BorderSizePixel = 0
    base.ZIndex = 6
    base.Parent = TowersLayer
    addCorner(base, 8)
    addStroke(base, spec.color, 2, 0.05)

    -- Tháp xoay hướng bắn
    local turret = Instance.new("Frame")
    turret.Size = UDim2.new(0.68, 0, 0.68, 0)
    turret.AnchorPoint = Vector2.new(0.5, 0.5)
    turret.Position = UDim2.new(0.5, 0, 0.5, 0)
    turret.BackgroundColor3 = spec.color
    turret.BorderSizePixel = 0
    turret.ZIndex = 7
    turret.Parent = base
    addCorner(turret, 20)

    local barrel = Instance.new("Frame")
    barrel.Size = UDim2.new(0.65, 0, 0.28, 0)
    barrel.AnchorPoint = Vector2.new(0, 0.5)
    barrel.Position = UDim2.new(0.45, 0, 0.5, 0)
    barrel.BackgroundColor3 = UITheme.TextPrimary
    barrel.BorderSizePixel = 0
    barrel.ZIndex = 8
    barrel.Parent = turret
    addCorner(barrel, 3)

    local lvLbl = Instance.new("TextLabel")
    lvLbl.Size = UDim2.new(1, 0, 0, 12)
    lvLbl.Position = UDim2.new(0, 0, 1, -12)
    lvLbl.BackgroundTransparency = 1
    lvLbl.Text = "1"
    lvLbl.Font = FONT_MAIN
    lvLbl.TextSize = 10
    lvLbl.TextColor3 = UITheme.ColorGold
    lvLbl.ZIndex = 9
    lvLbl.Parent = base

    local tw = {
        id       = State.NextId,
        r        = r,
        c        = c,
        spec     = spec,
        level    = 1,
        spent    = spec.cost,
        dmg      = spec.dmg,
        range    = spec.range,
        cooldown = spec.cooldown,
        cdLeft   = 0,
        node     = base,
        turret   = turret,
        lvLbl    = lvLbl,
    }
    State.NextId = State.NextId + 1
    State.TowerGrid[r][c] = tw
    table.insert(State.PlacedTowers, tw)

    selectTower(tw)
    updateHud()
end

upgradeSelectedTower = function()
    local tw = State.SelectedTower
    if not tw or tw.level >= 3 then return end
    local upCost = math.floor(tw.spec.cost * (tw.level == 1 and 0.9 or 1.4))
    if State.Gold < upCost then
        showTempAlert("Không đủ Vàng! Cần " .. upCost .. " Vàng")
        return
    end
    State.Gold = State.Gold - upCost
    tw.spent = tw.spent + upCost
    tw.level = tw.level + 1
    tw.dmg = math.floor(tw.dmg * 1.55)
    tw.range = tw.range + 0.35
    tw.cooldown = math.max(0.22, tw.cooldown * 0.88)
    tw.lvLbl.Text = tostring(tw.level)
    sfxBuild()
    spawnFxRing(tw.c - 0.5, tw.r - 0.5, 0.7, UITheme.ColorGold, 0.25)
    selectTower(tw)
    updateHud()
end

sellSelectedTower = function()
    local tw = State.SelectedTower
    if not tw then return end
    local refund = math.floor(tw.spent * 0.7)
    State.Gold = State.Gold + refund
    State.TowerGrid[tw.r][tw.c] = nil
    for i, item in ipairs(State.PlacedTowers) do
        if item.id == tw.id then
            table.remove(State.PlacedTowers, i)
            break
        end
    end
    if tw.node then tw.node:Destroy() end
    sfxClick()
    clearSelection()
    updateHud()
end

local function damageEnemy(en, dmg, slowAmt)
    if en.dead then return end
    en.hp = en.hp - dmg
    if slowAmt and slowAmt > 0 then
        en.slowTimer = math.max(en.slowTimer, 2.2)
        en.slowFactor = math.min(en.slowFactor, 1 - slowAmt)
    end
    if en.hp <= 0 then
        en.dead = true
        State.Gold = State.Gold + en.goldDrop
        if en.isBoss then
            Stats.Xu = Stats.Xu + 35
            saveStats()
            showTempAlert("Hạ gục BOSS! +35 Xu")
        end
        if en.node then en.node:Destroy() end
        updateHud()
    else
        local ratio = math.clamp(en.hp / en.maxHp, 0, 1)
        en.hpFill.Size = UDim2.new(ratio, 0, 1, 0)
    end
end

castLightningSkill = function()
    if State.GameOver then return end
    if #State.Enemies == 0 then
        showTempAlert("Chưa có quái trên bản đồ!")
        return
    end
    if Stats.Xu < 25 then
        showTempAlert("Không đủ Xu! Cần 25 Xu cho Sấm Sét")
        return
    end
    Stats.Xu = Stats.Xu - 25
    saveStats()
    sfxWin()

    local strikeDmg = 85 + State.Wave * 28
    for _, en in ipairs(State.Enemies) do
        if not en.dead then
            spawnFxRing(en.x, en.y, 0.9, UITheme.AccentCyan, 0.30)
            damageEnemy(en, strikeDmg, 0.35)
        end
    end
    updateHud()
    showTempAlert("Sấm Sét toàn bản đồ! Gây " .. strikeDmg .. " sát thương")
end

-- ========================================================================
-- [PHẦN 09] SINH ĐỢT QUÁI & VÒNG LẶP CHIẾN ĐẤU 60 FPS
-- ========================================================================
local function spawnEnemy(kind)
    local d = getDiff()
    local w = State.Wave
    local scale = (1 + (w - 1) * 0.24) * d.hpMult
    local ts = State.TileSize

    local hp, spd, goldDrop, szScale, col, isBoss
    if kind == "Fast" then
        hp = math.floor(38 * scale); spd = 2.55; goldDrop = 10; szScale = 0.50; col = Color3.fromRGB(204, 174, 72)
    elseif kind == "Tank" then
        hp = math.floor(125 * scale); spd = 1.15; goldDrop = 16; szScale = 0.68; col = Color3.fromRGB(118, 134, 166)
    elseif kind == "Boss" then
        hp = math.floor(420 * scale); spd = 0.95; goldDrop = 55; szScale = 0.84; col = Color3.fromRGB(198, 52, 62); isBoss = true
    else
        hp = math.floor(58 * scale); spd = 1.65; goldDrop = 9; szScale = 0.56; col = Color3.fromRGB(194, 88, 92)
    end

    local startPt = State.PathPoints[1]
    local px = math.floor(ts * szScale)

    local node = Instance.new("Frame")
    node.Size = UDim2.new(0, px, 0, px)
    node.AnchorPoint = Vector2.new(0.5, 0.5)
    node.Position = UDim2.new(0, startPt.x * ts, 0, startPt.y * ts)
    node.BackgroundColor3 = col
    node.BorderSizePixel = 0
    node.ZIndex = isBoss and 11 or 9
    node.Parent = EnemiesLayer
    addCorner(node, isBoss and 8 or 20)
    addStroke(node, isBoss and UITheme.ColorGold or Color3.fromRGB(24, 24, 34), isBoss and 2 or 1.4, 0)

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, 4, 0, 4)
    hpBg.Position = UDim2.new(0, -2, 0, -7)
    hpBg.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    hpBg.BorderSizePixel = 0
    hpBg.ZIndex = node.ZIndex + 1
    hpBg.Parent = node

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = isBoss and UITheme.ColorGold or UITheme.ColorGreen
    hpFill.BorderSizePixel = 0
    hpFill.ZIndex = hpBg.ZIndex + 1
    hpFill.Parent = hpBg

    table.insert(State.Enemies, {
        id         = State.NextId,
        x          = startPt.x,
        y          = startPt.y,
        wpIdx      = 2,
        progress   = 0,
        hp         = hp,
        maxHp      = hp,
        speed      = spd,
        goldDrop   = goldDrop,
        isBoss     = isBoss == true,
        slowTimer  = 0,
        slowFactor = 1,
        dead       = false,
        node       = node,
        hpFill     = hpFill,
    })
    State.NextId = State.NextId + 1
end

startNextWave = function()
    if State.GameOver or State.WaveActive or State.Wave >= State.MaxWaves then return end
    State.Wave = State.Wave + 1
    State.WaveActive = true
    State.SpawnQueue = {}
    State.SpawnTimer = 0.1

    local count = 6 + State.Wave * 2
    for i = 1, count do
        if State.Wave >= 3 and i % 4 == 0 then
            table.insert(State.SpawnQueue, "Fast")
        elseif State.Wave >= 4 and i % 5 == 0 then
            table.insert(State.SpawnQueue, "Tank")
        else
            table.insert(State.SpawnQueue, "Normal")
        end
    end
    if State.Wave % 5 == 0 then
        table.insert(State.SpawnQueue, "Boss")
        showTempAlert("CẢNH BÁO: BOSS ĐỢT " .. State.Wave .. " XUẤT HIỆN!")
    end
    updateHud()
    updateSelectionUI()
end

local function fireTowerAt(tw, target)
    local spec = tw.spec
    local tx, ty = tw.c - 0.5, tw.r - 0.5
    tw.turret.Rotation = math.deg(math.atan2(target.y - ty, target.x - tx))

    if spec.chain > 0 then
        -- Tháp Sấm đánh sét trực tiếp + giật lan
        sfxShoot(1.55)
        local hitSet = { [target.id] = true }
        local curTarget = target
        local prevX, prevY = tx, ty
        for step = 1, spec.chain do
            spawnBeam(prevX, prevY, curTarget.x, curTarget.y, spec.projCol)
            damageEnemy(curTarget, math.floor(tw.dmg * (step == 1 and 1.0 or 0.72)), 0)
            prevX, prevY = curTarget.x, curTarget.y
            local nextTarget, bestD = nil, 2.2
            for _, en in ipairs(State.Enemies) do
                if not en.dead and not hitSet[en.id] then
                    local d = math.sqrt((en.x - prevX)^2 + (en.y - prevY)^2)
                    if d < bestD then bestD = d; nextTarget = en end
                end
            end
            if not nextTarget then break end
            hitSet[nextTarget.id] = true
            curTarget = nextTarget
        end
        return
    end

    sfxShoot(spec.key == "Cannon" and 0.65 or 1.25)
    local ts = State.TileSize
    local dot = Instance.new("Frame")
    local sz = (spec.key == "Cannon") and 9 or 6
    dot.Size = UDim2.new(0, sz, 0, sz)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Position = UDim2.new(0, tx * ts, 0, ty * ts)
    dot.BackgroundColor3 = spec.projCol
    dot.BorderSizePixel = 0
    dot.ZIndex = 12
    dot.Parent = FxLayer
    addCorner(dot, 10)

    table.insert(State.Projectiles, {
        x      = tx,
        y      = ty,
        target = target,
        speed  = (spec.key == "Cannon") and 7.5 or 11.5,
        dmg    = tw.dmg,
        splash = spec.splash,
        slow   = spec.slow,
        color  = spec.projCol,
        node   = dot,
    })
end

-- Vòng lặp Heartbeat 60 FPS
trackConn(RunService.Heartbeat:Connect(function(rawDt)
    if State.Destroyed or State.Screen ~= "GAME" or State.Paused or State.GameOver or State.Minimized then
        return
    end

    local dt = math.min(rawDt, 0.05) * State.GameSpeed
    local ts = State.TileSize

    -- 1. Sinh quái từ hàng đợi
    if State.WaveActive then
        if #State.SpawnQueue > 0 then
            State.SpawnTimer = State.SpawnTimer - dt
            if State.SpawnTimer <= 0 then
                local kind = table.remove(State.SpawnQueue, 1)
                spawnEnemy(kind)
                State.SpawnTimer = math.max(0.32, 0.85 - State.Wave * 0.025)
            end
        elseif #State.Enemies == 0 then
            State.WaveActive = false
            local bonusGold = 25 + State.Wave * 5
            State.Gold = State.Gold + bonusGold
            if State.Wave >= State.MaxWaves then
                State.GameOver = true
                State.Won = true
                local winXu = math.floor(getMap().rewardXu * getDiff().xuMult)
                Stats.Wins = Stats.Wins + 1
                Stats.Xu = Stats.Xu + winXu
                saveStats()
                sfxWin()
                updateHud()
                showBanner(true, "CHIẾN THẮNG!", string.format("Hoàn thành %s  |  +%d Xu", getMap().name, winXu))
                return
            else
                State.AutoWaveTimer = 2.2
                updateHud()
                updateSelectionUI()
            end
        end
    elseif Config.AutoWave and State.Wave > 0 and State.Wave < State.MaxWaves then
        State.AutoWaveTimer = State.AutoWaveTimer - dt
        if State.AutoWaveTimer <= 0 then
            startNextWave()
        end
    end

    -- 2. Di chuyển quái theo đường đi
    for i = #State.Enemies, 1, -1 do
        local en = State.Enemies[i]
        if en.dead then
            table.remove(State.Enemies, i)
        else
            if en.slowTimer > 0 then
                en.slowTimer = en.slowTimer - dt
                if en.slowTimer <= 0 then en.slowFactor = 1 end
            end
            local targetWp = State.PathPoints[en.wpIdx]
            if not targetWp then
                -- Quái lọt vào thành
                en.dead = true
                if en.node then en.node:Destroy() end
                table.remove(State.Enemies, i)
                State.Lives = math.max(0, State.Lives - (en.isBoss and 5 or 1))
                updateHud()
                if State.Lives <= 0 then
                    State.GameOver = true
                    State.Won = false
                    showBanner(false, "THẤT THỦ!", "Thành chính đã sụp đổ ở đợt " .. State.Wave)
                    return
                end
            else
                local dx, dy = targetWp.x - en.x, targetWp.y - en.y
                local dist = math.sqrt(dx * dx + dy * dy)
                local step = en.speed * en.slowFactor * dt
                if dist <= step then
                    en.x, en.y = targetWp.x, targetWp.y
                    en.wpIdx = en.wpIdx + 1
                else
                    en.x = en.x + (dx / dist) * step
                    en.y = en.y + (dy / dist) * step
                end
                en.progress = en.progress + step
                en.node.Position = UDim2.new(0, en.x * ts, 0, en.y * ts)
            end
        end
    end

    -- 3. Tháp tìm mục tiêu đi xa nhất trong tầm và bắn
    for _, tw in ipairs(State.PlacedTowers) do
        tw.cdLeft = math.max(0, tw.cdLeft - dt)
        if tw.cdLeft <= 0 then
            local tx, ty = tw.c - 0.5, tw.r - 0.5
            local bestEn, bestProg = nil, -1
            for _, en in ipairs(State.Enemies) do
                if not en.dead then
                    local d = math.sqrt((en.x - tx)^2 + (en.y - ty)^2)
                    if d <= tw.range and en.progress > bestProg then
                        bestProg = en.progress
                        bestEn = en
                    end
                end
            end
            if bestEn then
                tw.cdLeft = tw.cooldown
                fireTowerAt(tw, bestEn)
            end
        end
    end

    -- 4. Cập nhật đạn bay
    for i = #State.Projectiles, 1, -1 do
        local pr = State.Projectiles[i]
        local tgt = pr.target
        if not tgt or tgt.dead then
            if pr.node then pr.node:Destroy() end
            table.remove(State.Projectiles, i)
        else
            local dx, dy = tgt.x - pr.x, tgt.y - pr.y
            local dist = math.sqrt(dx * dx + dy * dy)
            local step = pr.speed * dt
            if dist <= step + 0.15 then
                if pr.splash > 0 then
                    spawnFxRing(tgt.x, tgt.y, pr.splash, pr.color, 0.24)
                    for _, en in ipairs(State.Enemies) do
                        if not en.dead then
                            local ed = math.sqrt((en.x - tgt.x)^2 + (en.y - tgt.y)^2)
                            if ed <= pr.splash then
                                damageEnemy(en, pr.dmg, pr.slow)
                            end
                        end
                    end
                else
                    damageEnemy(tgt, pr.dmg, pr.slow)
                end
                if pr.node then pr.node:Destroy() end
                table.remove(State.Projectiles, i)
            else
                pr.x = pr.x + (dx / dist) * step
                pr.y = pr.y + (dy / dist) * step
                pr.node.Position = UDim2.new(0, pr.x * ts, 0, pr.y * ts)
            end
        end
    end

    -- 5. Cập nhật hiệu ứng nổ / tia sét
    for i = #State.Effects, 1, -1 do
        local fx = State.Effects[i]
        fx.life = fx.life + dt
        if fx.life >= fx.maxLife then
            if fx.node then fx.node:Destroy() end
            table.remove(State.Effects, i)
        else
            local alpha = fx.life / fx.maxLife
            if fx.kind == "RING" then
                local cur = fx.startPx + (fx.endPx - fx.startPx) * alpha
                fx.node.Size = UDim2.new(0, cur, 0, cur)
                fx.node.BackgroundTransparency = 0.55 + alpha * 0.45
            else
                fx.node.BackgroundTransparency = alpha
            end
        end
    end
end))

-- ========================================================================
-- [PHẦN 10] CẬP NHẬT UI, CHUYỂN MÀN HÌNH & DỌN DẸP SCRIPT
-- ========================================================================
updateHomeUI = function()
    if UI.HomeXuLabel then UI.HomeXuLabel.Text = tostring(Stats.Xu) .. " Xu" end
    local d = getDiff()
    for idx, pack in pairs(UI.HomeMapBtns) do
        local active = (Config.MapIndex == idx)
        pack.card.BackgroundColor3 = active and UITheme.BtnBlue or UITheme.BgButton
        pack.stroke.Color = active and UITheme.ColorGold or UITheme.StrokeSubtle
        pack.t1.TextColor3 = active and UITheme.ColorGold or UITheme.TextPrimary
        pack.t3.Text = "+" .. math.floor(MAPS[idx].rewardXu * d.xuMult) .. " Xu"
    end
    for idx, pack in pairs(UI.HomeDiffBtns) do
        local active = (Config.DiffIndex == idx)
        pack.btn.BackgroundColor3 = active and UITheme.BtnBlue or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.RimBlue or UITheme.StrokeSubtle
    end
end

updateHud = function()
    UI.MapLbl.Text = getMap().name .. "  " .. getDiff().label
    UI.WaveLbl.Text = string.format("Đợt: %d/%d", State.Wave, State.MaxWaves)
    UI.StatusText.Text = string.format("Thành: %d  |  Vàng: %d", State.Lives, State.Gold)
    if UI.GameXuLabel then UI.GameXuLabel.Text = tostring(Stats.Xu) .. " Xu" end
    if UI.HomeXuLabel then UI.HomeXuLabel.Text = tostring(Stats.Xu) .. " Xu" end
end

updateSelectionUI = function()
    for idx, pack in pairs(UI.TowerBtns) do
        local active = (State.SelectedTool == idx and not State.SelectedTower)
        pack.card.BackgroundColor3 = active and UITheme.BgCard or UITheme.BgPanelDark
        pack.stroke.Thickness = active and 2.2 or 1.4
    end

    local tw = State.SelectedTower
    if tw then
        UI.SelBox.Visible = true
        UI.SelTitle.Text = string.format("%s Lv%d  |  Sát thương: %d", tw.spec.name, tw.level, tw.dmg)
        if tw.level >= 3 then
            UI.UpLbl.Text = "Tối đa"
            UI.UpFace.BackgroundColor3 = UITheme.BgButton
        else
            local upCost = math.floor(tw.spec.cost * (tw.level == 1 and 0.9 or 1.4))
            UI.UpLbl.Text = "Nâng " .. upCost .. "V"
            UI.UpFace.BackgroundColor3 = UITheme.BtnGreen
        end
        UI.SellLbl.Text = "Bán +" .. math.floor(tw.spent * 0.7) .. "V"
    else
        UI.SelBox.Visible = false
    end

    UI.WaveBtnLbl.Text = State.WaveActive and "ĐANG CHIẾN ĐẤU..." or ("GỌI ĐỢT " .. math.min(State.MaxWaves, State.Wave + 1))
    UI.WaveFace.BackgroundColor3 = State.WaveActive and UITheme.BgButton or UITheme.BtnGreen
    UI.SpdLbl.Text = "Tốc độ: " .. State.GameSpeed .. "x"
    UI.AutoLbl.Text = Config.AutoWave and "Tự gọi: Bật" or "Tự gọi: Tắt"
    UI.AutoLbl.TextColor3 = Config.AutoWave and UITheme.ColorGreen or UITheme.TextSecondary
    UI.PauseLbl.Text = State.Paused and "Tiếp tục" or "Tạm dừng"
end

startNewMatch = function()
    local m = getMap()
    State.Gold = m.startGold
    State.Lives = 20
    State.Wave = 0
    State.MaxWaves = m.waves
    State.WaveActive = false
    State.SpawnQueue = {}
    State.SpawnTimer = 0
    State.AutoWaveTimer = 0
    State.Paused = false
    State.GameOver = false
    State.Won = false
    State.SelectedTower = nil
    State.PlacedTowers = {}
    State.Enemies = {}
    State.Projectiles = {}
    State.Effects = {}
    State.TowerGrid = {}
    for r = 1, GRID_ROWS do State.TowerGrid[r] = {} end

    RangeCircle.Visible = false
    hideBanner()
    buildMapVisuals()
    updateHud()
    updateSelectionUI()
end

openHomeScreen = function()
    State.Screen = "HOME"
    State.Paused = true
    HomeScreen.Visible = true
    GameScreen.Visible = false
    updateHomeUI()
end

enterGameScreen = function()
    State.Screen = "GAME"
    HomeScreen.Visible = false
    GameScreen.Visible = true
    task.defer(function()
        if not State.Destroyed then startNewMatch() end
    end)
end

trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or State.Destroyed then return end
    if State.Screen == "GAME" and Root.Visible then
        if input.KeyCode == Enum.KeyCode.Space then
            startNextWave()
        elseif input.KeyCode == Enum.KeyCode.One then
            State.SelectedTool = 1; clearSelection()
        elseif input.KeyCode == Enum.KeyCode.Two then
            State.SelectedTool = 2; clearSelection()
        elseif input.KeyCode == Enum.KeyCode.Three then
            State.SelectedTool = 3; clearSelection()
        elseif input.KeyCode == Enum.KeyCode.Four then
            State.SelectedTool = 4; clearSelection()
        end
    end
    if input.KeyCode == Enum.KeyCode.M then
        State.Minimized = not State.Minimized
        Root.Visible = not State.Minimized
        FloatBtn.Visible = State.Minimized
    end
end))

_G.ThuThanh2DCleanup = function()
    State.Destroyed = true
    for _, conn in ipairs(UI.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    UI.Connections = {}
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    _G.ThuThanh2DCleanup = nil
end

openHomeScreen()
