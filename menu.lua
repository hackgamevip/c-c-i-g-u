--[[
    ========================================================================
    DÒ MÌN - STANDALONE v1.0
    Game Dò Mìn (Minesweeper) 2D Toàn Màn Hình cho Roblox Mobile & PC
    - Đồ họa Cyber-Navy & Cyan-Teal matte đồng bộ bộ icon vector
    - 6 màn chơi: 9x9 (10 mìn) đến 30x30 (190 mìn) chạy mượt 60 FPS mobile
    - Nước mở đầu luôn an toàn, hỗ trợ Mở nhanh ô số, Cắm cờ 1 chạm & chuột phải PC
    - Hệ thống Xu thưởng theo độ khó, Gợi ý 10 Xu và Hồi sinh gỡ mìn 30 Xu
    ========================================================================
]]

if _G.DoMinStandaloneCleanup then
    pcall(_G.DoMinStandaloneCleanup)
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ========================================================================
-- [PHẦN 01] CẤU HÌNH, BẢNG MÀU CYBER-NAVY MATTE & 6 MÀN CHƠI
-- ========================================================================
local SAVE_FILE = "DoMin_Stats_v1.json"

local UITheme = {
    BgMain        = Color3.fromRGB(9, 15, 28),
    BgPanel       = Color3.fromRGB(14, 23, 40),
    BgPanelLight  = Color3.fromRGB(18, 30, 52),
    BgCard        = Color3.fromRGB(18, 31, 54),
    BgButton      = Color3.fromRGB(20, 35, 60),
    BgActive      = Color3.fromRGB(24, 58, 82),
    StrokeSubtle  = Color3.fromRGB(36, 76, 98),
    StrokeStrong  = Color3.fromRGB(56, 134, 152),
    AccentCyan    = Color3.fromRGB(76, 192, 206),

    TextPrimary   = Color3.fromRGB(206, 212, 215),
    TextSecondary = Color3.fromRGB(142, 168, 186),
    TextMuted     = Color3.fromRGB(104, 134, 154),

    ColorRed      = Color3.fromRGB(204, 92, 96),
    ColorGold     = Color3.fromRGB(204, 168, 84),
    ColorGreen    = Color3.fromRGB(88, 186, 132),
    ColorDanger   = Color3.fromRGB(190, 82, 86),
}

-- 4 Chủ đề bàn Dò Mìn (mọi kênh RGB của chữ/số đều <= 215)
local BoardThemes = {
    Dark = {
        Name        = "Tối",
        BoardOuter  = Color3.fromRGB(12, 20, 36),
        CellHidden  = Color3.fromRGB(32, 46, 72),
        CellOpen    = Color3.fromRGB(17, 25, 42),
        GridLine    = Color3.fromRGB(48, 72, 102),
        CellMineHit = Color3.fromRGB(96, 34, 40),
        CellHint    = Color3.fromRGB(34, 78, 62),
        FlagColor   = Color3.fromRGB(206, 94, 92),
        MineColor   = Color3.fromRGB(194, 88, 92),
        NumColors   = {
            Color3.fromRGB(96, 184, 212),   -- 1
            Color3.fromRGB(94, 188, 128),   -- 2
            Color3.fromRGB(206, 104, 104),  -- 3
            Color3.fromRGB(152, 136, 210),  -- 4
            Color3.fromRGB(206, 152, 84),   -- 5
            Color3.fromRGB(86, 194, 184),   -- 6
            Color3.fromRGB(186, 188, 196),  -- 7
            Color3.fromRGB(146, 154, 168),  -- 8
        },
    },
    Emerald = {
        Name        = "Ngọc",
        BoardOuter  = Color3.fromRGB(13, 28, 25),
        CellHidden  = Color3.fromRGB(32, 66, 56),
        CellOpen    = Color3.fromRGB(18, 38, 33),
        GridLine    = Color3.fromRGB(48, 90, 76),
        CellMineHit = Color3.fromRGB(96, 36, 40),
        CellHint    = Color3.fromRGB(48, 98, 72),
        FlagColor   = Color3.fromRGB(208, 102, 92),
        MineColor   = Color3.fromRGB(198, 92, 92),
        NumColors   = {
            Color3.fromRGB(108, 196, 208),
            Color3.fromRGB(116, 202, 138),
            Color3.fromRGB(208, 112, 106),
            Color3.fromRGB(168, 146, 210),
            Color3.fromRGB(208, 164, 92),
            Color3.fromRGB(94, 200, 188),
            Color3.fromRGB(186, 196, 192),
            Color3.fromRGB(144, 162, 156),
        },
    },
    Sand = {
        Name        = "Cát",
        BoardOuter  = Color3.fromRGB(42, 33, 24),
        CellHidden  = Color3.fromRGB(142, 116, 84),
        CellOpen    = Color3.fromRGB(108, 86, 60),
        GridLine    = Color3.fromRGB(82, 62, 42),
        CellMineHit = Color3.fromRGB(138, 52, 52),
        CellHint    = Color3.fromRGB(94, 134, 86),
        FlagColor   = Color3.fromRGB(178, 46, 46),
        MineColor   = Color3.fromRGB(46, 36, 28),
        NumColors   = {
            Color3.fromRGB(36, 98, 164),
            Color3.fromRGB(36, 122, 64),
            Color3.fromRGB(168, 42, 44),
            Color3.fromRGB(96, 52, 146),
            Color3.fromRGB(146, 76, 26),
            Color3.fromRGB(28, 116, 118),
            Color3.fromRGB(42, 36, 30),
            Color3.fromRGB(72, 64, 56),
        },
    },
    Paper = {
        Name        = "Vở Ô Ly",
        BoardOuter  = Color3.fromRGB(146, 142, 132),
        CellHidden  = Color3.fromRGB(196, 192, 182),
        CellOpen    = Color3.fromRGB(168, 164, 154),
        GridLine    = Color3.fromRGB(130, 144, 160),
        CellMineHit = Color3.fromRGB(186, 112, 112),
        CellHint    = Color3.fromRGB(142, 182, 146),
        FlagColor   = Color3.fromRGB(178, 46, 50),
        MineColor   = Color3.fromRGB(46, 52, 64),
        NumColors   = {
            Color3.fromRGB(34, 92, 164),
            Color3.fromRGB(34, 124, 62),
            Color3.fromRGB(172, 42, 46),
            Color3.fromRGB(92, 52, 152),
            Color3.fromRGB(154, 82, 26),
            Color3.fromRGB(26, 118, 122),
            Color3.fromRGB(44, 48, 56),
            Color3.fromRGB(82, 88, 98),
        },
    },
}

local THEME_ORDER = { "Dark", "Emerald", "Sand", "Paper" }

local STAGES = {
    { key = "Easy",   title = "Dễ",       size = 9,  mines = 10,  reward = 100 },
    { key = "Medium", title = "Vừa",      size = 12, mines = 22,  reward = 200 },
    { key = "Hard",   title = "Khó",      size = 16, mines = 40,  reward = 400 },
    { key = "Pro",    title = "Cao Thủ",  size = 20, mines = 70,  reward = 800 },
    { key = "Master", title = "Siêu Khó", size = 25, mines = 120, reward = 1500 },
    { key = "Hell",   title = "Địa Ngục", size = 30, mines = 190, reward = 2999 },
}

local FONT_MAIN = Enum.Font.GothamSemibold
local FONT_BODY = Enum.Font.GothamMedium

local Config = {
    StageIndex    = 1,
    ThemeKey      = "Dark",
    QuickChord    = true,     -- Chạm vào ô số đã đủ cờ để mở nhanh xung quanh
    SoundEnabled  = true,
    CellSize      = 32,
}

local State = {
    Screen          = "HOME",   -- "HOME" | "GAME"
    TouchMode       = "DIG",    -- "DIG" (Mở ô) | "FLAG" (Cắm cờ)
    Mines           = {},       -- Mines[r][c] = true/false
    Counts          = {},       -- Counts[r][c] = 0..8
    Revealed        = {},       -- Revealed[r][c] = true/false
    Flagged         = {},       -- Flagged[r][c] = true/false
    Generated       = false,
    GameOver        = false,
    Won             = false,
    RevealedCount   = 0,
    FlagsPlaced     = 0,
    Elapsed         = 0,
    HitMineCell     = nil,      -- { r, c } ô mìn vừa chạm để hỗ trợ Hồi sinh 30 Xu
    HintCell        = nil,
    Minimized       = false,
    Destroyed       = false,
    ResetConfirmAt  = 0,
    TempAlertToken  = 0,
}

local Stats = {
    Wins   = 0,
    Losses = 0,
    Xu     = 0,
}

local UI = {
    CellNodes = {},
    Connections = {},
}

-- ========================================================================
-- [PHẦN 02] TIỆN ÍCH LƯU DỮ LIỆU, ÂM THANH & BỘ ICON VECTOR CYBER-TEAL
-- ========================================================================
local function getStage()
    return STAGES[Config.StageIndex] or STAGES[1]
end

local function getTheme()
    return BoardThemes[Config.ThemeKey] or BoardThemes.Dark
end

local function cellKey(r, c)
    return r * 1000 + c
end

local function loadStats()
    if type(isfile) == "function" and type(readfile) == "function" then
        local ok, exists = pcall(isfile, SAVE_FILE)
        if ok and exists then
            local okRead, raw = pcall(readfile, SAVE_FILE)
            if okRead and type(raw) == "string" and #raw > 0 then
                local okDec, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if okDec and type(data) == "table" then
                    Stats.Wins   = tonumber(data.Wins) or 0
                    Stats.Losses = tonumber(data.Losses) or 0
                    Stats.Xu     = tonumber(data.Xu) or 0
                    if data.ThemeKey and BoardThemes[data.ThemeKey] then
                        Config.ThemeKey = data.ThemeKey
                    end
                end
            end
        end
    end
end

local function saveStats()
    if type(writefile) == "function" then
        pcall(function()
            writefile(SAVE_FILE, HttpService:JSONEncode({
                Wins     = Stats.Wins,
                Losses   = Stats.Losses,
                Xu       = Stats.Xu,
                ThemeKey = Config.ThemeKey,
            }))
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
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or UITheme.StrokeSubtle
    s.Thickness = thickness or 1.2
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

-- Bộ icon vector sắc nét (không dùng emoji bị lỗi ô vuông trên mobile)
local Icons = {}

function Icons.drawMinus(parent, color)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 14, 0, 2.5)
    bar.AnchorPoint = Vector2.new(0.5, 0.5)
    bar.Position = UDim2.new(0.5, 0, 0.5, 0)
    bar.BackgroundColor3 = color or UITheme.AccentCyan
    bar.BorderSizePixel = 0
    bar.Parent = parent
    addCorner(bar, 2)
end

function Icons.drawPlus(parent, color)
    local col = color or UITheme.AccentCyan
    Icons.drawMinus(parent, col)
    local vbar = Instance.new("Frame")
    vbar.Size = UDim2.new(0, 2.5, 0, 14)
    vbar.AnchorPoint = Vector2.new(0.5, 0.5)
    vbar.Position = UDim2.new(0.5, 0, 0.5, 0)
    vbar.BackgroundColor3 = col
    vbar.BorderSizePixel = 0
    vbar.Parent = parent
    addCorner(vbar, 2)
end

function Icons.drawCloseX(parent, color)
    local col = color or UITheme.ColorRed
    for _, rot in ipairs({ 45, -45 }) do
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 15, 0, 2.5)
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
        bar.Rotation = rot
        bar.BackgroundColor3 = col
        bar.BorderSizePixel = 0
        bar.Parent = parent
        addCorner(bar, 2)
    end
end

function Icons.drawHome(parent, color)
    local col = color or UITheme.AccentCyan
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(0, 18, 0, 18)
    wrap.AnchorPoint = Vector2.new(0.5, 0.5)
    wrap.Position = UDim2.new(0.5, 0, 0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent

    for _, cfg in ipairs({ { -4, -38 }, { 4, 38 } }) do
        local roof = Instance.new("Frame")
        roof.Size = UDim2.new(0, 11, 0, 2.4)
        roof.AnchorPoint = Vector2.new(0.5, 0.5)
        roof.Position = UDim2.new(0.5, cfg[1], 0, 5)
        roof.Rotation = cfg[2]
        roof.BackgroundColor3 = col
        roof.BorderSizePixel = 0
        roof.Parent = wrap
        addCorner(roof, 2)
    end
    local body = Instance.new("Frame")
    body.Size = UDim2.new(0, 12, 0, 9)
    body.AnchorPoint = Vector2.new(0.5, 1)
    body.Position = UDim2.new(0.5, 0, 1, -1)
    body.BackgroundTransparency = 1
    body.Parent = wrap
    addStroke(body, col, 2, 0)
    addCorner(body, 2)

    local door = Instance.new("Frame")
    door.Size = UDim2.new(0, 4, 0, 5)
    door.AnchorPoint = Vector2.new(0.5, 1)
    door.Position = UDim2.new(0.5, 0, 1, 0)
    door.BackgroundColor3 = col
    door.BorderSizePixel = 0
    door.Parent = body
    addCorner(door, 1)
end

function Icons.drawMine(parent, sizeScale, color)
    local col = color or UITheme.ColorRed
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(sizeScale or 0.68, 0, sizeScale or 0.68, 0)
    wrap.AnchorPoint = Vector2.new(0.5, 0.5)
    wrap.Position = UDim2.new(0.5, 0, 0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 7
    wrap.Parent = parent

    -- 4 gai chéo & ngang/dọc
    for _, rot in ipairs({ 0, 45, 90, 135 }) do
        local spike = Instance.new("Frame")
        spike.Size = UDim2.new(0.96, 0, 0.14, 0)
        spike.AnchorPoint = Vector2.new(0.5, 0.5)
        spike.Position = UDim2.new(0.5, 0, 0.5, 0)
        spike.Rotation = rot
        spike.BackgroundColor3 = col
        spike.BorderSizePixel = 0
        spike.ZIndex = 7
        spike.Parent = wrap
        addCorner(spike, 2)
    end

    local core = Instance.new("Frame")
    core.Size = UDim2.new(0.62, 0, 0.62, 0)
    core.AnchorPoint = Vector2.new(0.5, 0.5)
    core.Position = UDim2.new(0.5, 0, 0.5, 0)
    core.BackgroundColor3 = col
    core.BorderSizePixel = 0
    core.ZIndex = 8
    core.Parent = wrap
    addCorner(core, 30)

    local shine = Instance.new("Frame")
    shine.Size = UDim2.new(0.24, 0, 0.24, 0)
    shine.Position = UDim2.new(0.22, 0, 0.22, 0)
    shine.BackgroundColor3 = UITheme.TextPrimary
    shine.BackgroundTransparency = 0.35
    shine.BorderSizePixel = 0
    shine.ZIndex = 9
    shine.Parent = core
    addCorner(shine, 10)
    return wrap
end

function Icons.drawFlag(parent, sizeScale, color)
    local col = color or UITheme.ColorRed
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(sizeScale or 0.64, 0, sizeScale or 0.64, 0)
    wrap.AnchorPoint = Vector2.new(0.5, 0.5)
    wrap.Position = UDim2.new(0.5, 0, 0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 7
    wrap.Parent = parent

    -- Cán cờ
    local pole = Instance.new("Frame")
    pole.Size = UDim2.new(0.14, 0, 0.84, 0)
    pole.Position = UDim2.new(0.24, 0, 0.08, 0)
    pole.BackgroundColor3 = UITheme.TextPrimary
    pole.BorderSizePixel = 0
    pole.ZIndex = 7
    pole.Parent = wrap
    addCorner(pole, 2)

    -- Đế cờ
    local base = Instance.new("Frame")
    base.Size = UDim2.new(0.54, 0, 0.14, 0)
    base.Position = UDim2.new(0.16, 0, 0.84, 0)
    base.BackgroundColor3 = UITheme.TextSecondary
    base.BorderSizePixel = 0
    base.ZIndex = 7
    base.Parent = wrap
    addCorner(base, 2)

    -- Lá cờ
    local cloth = Instance.new("Frame")
    cloth.Size = UDim2.new(0.52, 0, 0.40, 0)
    cloth.Position = UDim2.new(0.36, 0, 0.10, 0)
    cloth.BackgroundColor3 = col
    cloth.BorderSizePixel = 0
    cloth.ZIndex = 8
    cloth.Parent = wrap
    addCorner(cloth, 3)
    return wrap
end

function Icons.drawSpeaker(parent, muted, color)
    local col = color or UITheme.AccentCyan
    local wrap = Instance.new("Frame")
    wrap.Name = "SpeakerIcon"
    wrap.Size = UDim2.new(0, 20, 0, 16)
    wrap.AnchorPoint = Vector2.new(0, 0.5)
    wrap.Position = UDim2.new(0, 10, 0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 5, 0, 7)
    box.Position = UDim2.new(0, 1, 0.5, -3)
    box.BackgroundColor3 = col
    box.BorderSizePixel = 0
    box.Parent = wrap
    addCorner(box, 1)

    local cone = Instance.new("Frame")
    cone.Size = UDim2.new(0, 5, 0, 12)
    cone.Position = UDim2.new(0, 5, 0.5, -6)
    cone.BackgroundColor3 = col
    cone.BorderSizePixel = 0
    cone.Parent = wrap
    addCorner(cone, 2)

    if muted then
        for _, rot in ipairs({ 45, -45 }) do
            local xbar = Instance.new("Frame")
            xbar.Size = UDim2.new(0, 8, 0, 2)
            xbar.AnchorPoint = Vector2.new(0.5, 0.5)
            xbar.Position = UDim2.new(0, 15, 0.5, 0)
            xbar.Rotation = rot
            xbar.BackgroundColor3 = UITheme.ColorRed
            xbar.BorderSizePixel = 0
            xbar.Parent = wrap
            addCorner(xbar, 1)
        end
    else
        for idx, h in ipairs({ 6, 11 }) do
            local wave = Instance.new("Frame")
            wave.Size = UDim2.new(0, 2, 0, h)
            wave.AnchorPoint = Vector2.new(0.5, 0.5)
            wave.Position = UDim2.new(0, 11 + idx * 3, 0.5, 0)
            wave.BackgroundColor3 = col
            wave.BorderSizePixel = 0
            wave.Parent = wrap
            addCorner(wave, 2)
        end
    end
    return wrap
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
    inner.Size = UDim2.new(0, 13, 0, 13)
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.Position = UDim2.new(0.5, 0, 0.5, 0)
    inner.BackgroundColor3 = Color3.fromRGB(212, 178, 64)
    inner.BorderSizePixel = 0
    inner.Parent = coin
    addCorner(inner, 10)

    for _, rot in ipairs({ 0, 45 }) do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, 6, 0, 6)
        star.AnchorPoint = Vector2.new(0.5, 0.5)
        star.Position = UDim2.new(0.5, 0, 0.5, 0)
        star.Rotation = rot
        star.BackgroundColor3 = Color3.fromRGB(168, 114, 24)
        star.BorderSizePixel = 0
        star.Parent = inner
        addCorner(star, 1)
    end
    return coin
end

local function createXuPill(parent)
    local pill = Instance.new("Frame")
    pill.Name = "XuPill"
    pill.Size = UDim2.new(0, 116, 0, 34)
    pill.Position = UDim2.new(1, -210, 0.5, -17)
    pill.BackgroundColor3 = UITheme.BgCard
    pill.BorderSizePixel = 0
    pill.Parent = parent
    addCorner(pill, 7)
    addStroke(pill, UITheme.ColorGold, 1.4, 0.2)
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

local function bindInstantTap(button, callback, rightClickCb)
    local pressPos = nil
    local pressType = nil
    local lastFire = 0

    trackConn(button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.MouseButton2 then
            pressPos = input.Position
            pressType = input.UserInputType
        end
    end))

    trackConn(button.InputEnded:Connect(function(input)
        if not pressPos or input.UserInputType ~= pressType then return end
        local delta = (input.Position - pressPos).Magnitude
        local pType = pressType
        pressPos = nil
        pressType = nil
        local now = os.clock()
        if delta <= 14 and (now - lastFire) >= 0.07 then
            lastFire = now
            if pType == Enum.UserInputType.MouseButton2 and rightClickCb then
                rightClickCb(input.Position)
            elseif pType ~= Enum.UserInputType.MouseButton2 then
                callback(input.Position)
            end
        end
    end))
end

local function makeCyberIconBtn(parent, sizePx, pos, strokeColor, drawFn, onTap)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, sizePx, 0, sizePx)
    b.Position = pos
    b.BackgroundColor3 = UITheme.BgCard
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = ""
    b.Parent = parent
    addCorner(b, 6)
    addStroke(b, strokeColor or UITheme.AccentCyan, 1.4, 0.15)
    if drawFn then drawFn(b, strokeColor or UITheme.AccentCyan) end
    bindInstantTap(b, onTap)
    return b
end

local SoundFolder = nil
local function playSfx(soundId, volume, pitch)
    if not Config.SoundEnabled or State.Destroyed or not SoundFolder then return end
    pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = soundId
        snd.Volume = volume or 0.32
        snd.PlaybackSpeed = pitch or 1.0
        snd.Parent = SoundFolder
        snd:Play()
        task.delay(1.2, function()
            if snd and snd.Parent then snd:Destroy() end
        end)
    end)
end

local function sfxDig()   playSfx("rbxassetid://421058925", 0.30, 1.2) end
local function sfxFlag()  playSfx("rbxassetid://421058925", 0.28, 0.88) end
local function sfxBoom()  playSfx("rbxassetid://421058925", 0.48, 0.45) end
local function sfxWin()   playSfx("rbxassetid://4590662766", 0.45, 1.0) end
local function sfxClick() playSfx("rbxassetid://421058925", 0.22, 1.35) end

local function formatTime(sec)
    local s = math.max(0, math.floor(sec))
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end

-- ========================================================================
-- [PHẦN 03] LOGIC DÒ MÌN (AN TOÀN NƯỚC ĐẦU, LOANG VÙNG 0 & MỞ NHANH Ô SỐ)
-- ========================================================================
local function inBounds(r, c)
    local n = getStage().size
    return r >= 1 and r <= n and c >= 1 and c <= n
end

local function resetArrays()
    local n = getStage().size
    State.Mines, State.Counts, State.Revealed, State.Flagged = {}, {}, {}, {}
    for r = 1, n do
        State.Mines[r], State.Counts[r], State.Revealed[r], State.Flagged[r] = {}, {}, {}, {}
        for c = 1, n do
            State.Mines[r][c] = false
            State.Counts[r][c] = 0
            State.Revealed[r][c] = false
            State.Flagged[r][c] = false
        end
    end
end

-- Sinh mìn sau nước chạm đầu tiên, đảm bảo vùng 3x3 quanh nước đầu không có mìn
local function generateMines(safeR, safeC)
    local stg = getStage()
    local n = stg.size
    local totalMines = stg.mines
    local pool = {}

    for r = 1, n do
        for c = 1, n do
            if math.abs(r - safeR) > 1 or math.abs(c - safeC) > 1 then
                table.insert(pool, { r, c })
            end
        end
    end

    -- Xáo trộn Fisher-Yates
    for i = #pool, 2, -1 do
        local j = math.random(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    local placed = math.min(totalMines, #pool)
    for i = 1, placed do
        local pos = pool[i]
        State.Mines[pos[1]][pos[2]] = true
    end

    -- Tính số mìn xung quanh cho từng ô
    for r = 1, n do
        for c = 1, n do
            if not State.Mines[r][c] then
                local cnt = 0
                for dr = -1, 1 do
                    for dc = -1, 1 do
                        if not (dr == 0 and dc == 0) then
                            local nr, nc = r + dr, c + dc
                            if inBounds(nr, nc) and State.Mines[nr][nc] then
                                cnt = cnt + 1
                            end
                        end
                    end
                end
                State.Counts[r][c] = cnt
            end
        end
    end
    State.Generated = true
end

-- ========================================================================
-- [PHẦN 04] KHỞI TẠO SCREEN GUI & NÚT THU GỌN NỔI
-- ========================================================================
loadStats()

local guiParent = getGuiParent()
do
    local old = guiParent:FindFirstChild("DoMin_Standalone")
    if old then pcall(function() old:Destroy() end) end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoMin_Standalone"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = guiParent

SoundFolder = Instance.new("Folder")
SoundFolder.Name = "DoMinAudio"
SoundFolder.Parent = ScreenGui

local Root = Instance.new("Frame")
Root.Name = "Root"
Root.Size = UDim2.new(1, 0, 1, 0)
Root.BackgroundColor3 = UITheme.BgMain
Root.BorderSizePixel = 0
Root.Active = true
Root.Parent = ScreenGui

-- Nút nổi khi thu gọn (KHÔNG dùng UIGradient trực tiếp lên TextButton để chữ luôn sáng rõ)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatingReopen"
FloatBtn.Size = UDim2.new(0, 96, 0, 38)
FloatBtn.Position = UDim2.new(0, 16, 0, 74)
FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 34, 58)
FloatBtn.BorderSizePixel = 0
FloatBtn.AutoButtonColor = false
FloatBtn.Text = "DÒ MÌN"
FloatBtn.Font = FONT_MAIN
FloatBtn.TextSize = 14
FloatBtn.TextColor3 = Color3.fromRGB(172, 212, 215)
FloatBtn.Visible = false
FloatBtn.ZIndex = 50
FloatBtn.Parent = ScreenGui
addCorner(FloatBtn, 8)
addStroke(FloatBtn, UITheme.AccentCyan, 1.8, 0.1)

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

local openHomeScreen, enterGameScreen, rebuildBoard, renderCell, updateTopStatus, updateControlsUI, updateHomeUI
local startNewGame, handleDig, handleFlag, useHint, reviveFromMine, showBanner, hideBanner, showTempAlert

-- ========================================================================
-- [PHẦN 05] SẢNH CHÍNH (HOME SCREEN)
-- ========================================================================
local HomeScreen = Instance.new("Frame")
HomeScreen.Name = "HomeScreen"
HomeScreen.Size = UDim2.new(1, 0, 1, 0)
HomeScreen.BackgroundColor3 = UITheme.BgMain
HomeScreen.BorderSizePixel = 0
HomeScreen.Visible = true
HomeScreen.Parent = Root
addGradient(HomeScreen, Color3.fromRGB(12, 21, 38), UITheme.BgMain, 135)

do
    local HomeTop = Instance.new("Frame")
    HomeTop.Size = UDim2.new(1, 0, 0, 50)
    HomeTop.BackgroundColor3 = UITheme.BgPanel
    HomeTop.BorderSizePixel = 0
    HomeTop.Parent = HomeScreen
    addGradient(HomeTop, UITheme.BgPanelLight, UITheme.BgPanel, 90)
    addStroke(HomeTop, UITheme.StrokeSubtle, 1, 0.25)

    local HomeBrand = Instance.new("TextLabel")
    HomeBrand.Size = UDim2.new(0, 180, 1, 0)
    HomeBrand.Position = UDim2.new(0, 18, 0, 0)
    HomeBrand.BackgroundTransparency = 1
    HomeBrand.Text = "DÒ MÌN"
    HomeBrand.Font = FONT_MAIN
    HomeBrand.TextSize = 17
    HomeBrand.TextColor3 = UITheme.AccentCyan
    HomeBrand.TextXAlignment = Enum.TextXAlignment.Left
    HomeBrand.Parent = HomeTop

    UI.HomeXuLabel = createXuPill(HomeTop)

    makeCyberIconBtn(HomeTop, 34, UDim2.new(1, -86, 0.5, -17), UITheme.AccentCyan, Icons.drawMinus, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    makeCyberIconBtn(HomeTop, 34, UDim2.new(1, -44, 0.5, -17), UITheme.ColorRed, Icons.drawCloseX, function()
        if _G.DoMinStandaloneCleanup then _G.DoMinStandaloneCleanup() end
    end)

    local HomeBody = Instance.new("Frame")
    HomeBody.Size = UDim2.new(1, -24, 1, -66)
    HomeBody.Position = UDim2.new(0, 12, 0, 58)
    HomeBody.BackgroundTransparency = 1
    HomeBody.Parent = HomeScreen

    -- CỘT TRÁI: Biểu tượng Mìn & Cờ + Nút Bắt đầu
    local LeftCard = Instance.new("Frame")
    LeftCard.Size = UDim2.new(0.40, -8, 1, 0)
    LeftCard.BackgroundColor3 = UITheme.BgPanel
    LeftCard.BorderSizePixel = 0
    LeftCard.Parent = HomeBody
    addCorner(LeftCard, 12)
    addStroke(LeftCard, UITheme.StrokeSubtle, 1.2, 0.15)
    addGradient(LeftCard, UITheme.BgPanelLight, UITheme.BgPanel, 135)

    local LogoWrap = Instance.new("Frame")
    LogoWrap.Size = UDim2.new(0, 136, 0, 66)
    LogoWrap.AnchorPoint = Vector2.new(0.5, 0)
    LogoWrap.Position = UDim2.new(0.5, 0, 0, 32)
    LogoWrap.BackgroundColor3 = UITheme.BgCard
    LogoWrap.BorderSizePixel = 0
    LogoWrap.Parent = LeftCard
    addCorner(LogoWrap, 12)
    addStroke(LogoWrap, UITheme.AccentCyan, 1.6, 0.2)

    local mSlot = Instance.new("Frame")
    mSlot.Size = UDim2.new(0, 44, 0, 44)
    mSlot.Position = UDim2.new(0, 16, 0.5, -22)
    mSlot.BackgroundTransparency = 1
    mSlot.Parent = LogoWrap
    Icons.drawMine(mSlot, 0.85, UITheme.ColorRed)

    local fSlot = Instance.new("Frame")
    fSlot.Size = UDim2.new(0, 44, 0, 44)
    fSlot.Position = UDim2.new(1, -60, 0.5, -22)
    fSlot.BackgroundTransparency = 1
    fSlot.Parent = LogoWrap
    Icons.drawFlag(fSlot, 0.82, UITheme.AccentCyan)

    local HeroTitle = Instance.new("TextLabel")
    HeroTitle.Size = UDim2.new(1, -20, 0, 34)
    HeroTitle.Position = UDim2.new(0, 10, 0, 110)
    HeroTitle.BackgroundTransparency = 1
    HeroTitle.Text = "DÒ MÌN"
    HeroTitle.Font = FONT_MAIN
    HeroTitle.TextSize = 26
    HeroTitle.TextColor3 = UITheme.TextPrimary
    HeroTitle.Parent = LeftCard

    local heroLine = Instance.new("Frame")
    heroLine.Size = UDim2.new(0, 64, 0, 2)
    heroLine.AnchorPoint = Vector2.new(0.5, 0)
    heroLine.Position = UDim2.new(0.5, 0, 0, 148)
    heroLine.BackgroundColor3 = UITheme.AccentCyan
    heroLine.BackgroundTransparency = 0.35
    heroLine.BorderSizePixel = 0
    heroLine.Parent = LeftCard
    addCorner(heroLine, 2)

    -- Nút BẮT ĐẦU CHƠI (chữ sáng rõ, không addGradient lên TextButton)
    local PlayBtn = Instance.new("TextButton")
    PlayBtn.Size = UDim2.new(1, -28, 0, 48)
    PlayBtn.Position = UDim2.new(0, 14, 1, -70)
    PlayBtn.BackgroundColor3 = Color3.fromRGB(24, 72, 58)
    PlayBtn.BorderSizePixel = 0
    PlayBtn.AutoButtonColor = false
    PlayBtn.Text = "BẮT ĐẦU CHƠI"
    PlayBtn.Font = FONT_MAIN
    PlayBtn.TextSize = 16
    PlayBtn.TextColor3 = Color3.fromRGB(186, 214, 198)
    PlayBtn.Parent = LeftCard
    addCorner(PlayBtn, 9)
    addStroke(PlayBtn, UITheme.ColorGreen, 1.6, 0.15)
    bindInstantTap(PlayBtn, function()
        sfxClick()
        enterGameScreen()
    end)

    -- CỘT PHẢI: Chọn 6 màn chơi + 4 giao diện bàn cờ
    local RightCard = Instance.new("ScrollingFrame")
    RightCard.Size = UDim2.new(0.60, -4, 1, 0)
    RightCard.Position = UDim2.new(0.40, 4, 0, 0)
    RightCard.BackgroundColor3 = UITheme.BgPanel
    RightCard.BorderSizePixel = 0
    RightCard.ScrollBarThickness = 4
    RightCard.ScrollBarImageColor3 = UITheme.StrokeStrong
    RightCard.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightCard.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightCard.Parent = HomeBody
    addCorner(RightCard, 12)
    addStroke(RightCard, UITheme.StrokeSubtle, 1.2, 0.15)
    addGradient(RightCard, UITheme.BgPanelLight, UITheme.BgPanel, 135)

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
        lbl.TextColor3 = UITheme.TextMuted
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = RightCard
        return lbl
    end

    makeHeader("CHỌN MÀN CHƠI", 1)

    local StageGrid = Instance.new("Frame")
    StageGrid.LayoutOrder = 2
    StageGrid.Size = UDim2.new(1, 0, 0, 126)
    StageGrid.BackgroundTransparency = 1
    StageGrid.Parent = RightCard

    UI.HomeStageBtns = {}
    for idx, stg in ipairs(STAGES) do
        local col = (idx - 1) % 3
        local row = math.floor((idx - 1) / 3)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0.32, 0, 0, 58)
        card.Position = UDim2.new(col * 0.34, 0, 0, row * 64)
        card.BackgroundColor3 = UITheme.BgCard
        card.BorderSizePixel = 0
        card.AutoButtonColor = false
        card.Text = ""
        card.Parent = StageGrid
        addCorner(card, 8)
        local st = addStroke(card, UITheme.StrokeSubtle, 1.2, 0.25)

        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, 0, 0, 22)
        t1.Position = UDim2.new(0, 0, 0, 5)
        t1.BackgroundTransparency = 1
        t1.Text = stg.title .. "  " .. stg.size .. "x" .. stg.size
        t1.Font = FONT_MAIN
        t1.TextSize = 12
        t1.TextColor3 = UITheme.TextPrimary
        t1.Parent = card

        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, 0, 0, 16)
        t2.Position = UDim2.new(0, 0, 0, 26)
        t2.BackgroundTransparency = 1
        t2.Text = stg.mines .. " mìn  |  +" .. stg.reward .. " Xu"
        t2.Font = FONT_BODY
        t2.TextSize = 10
        t2.TextColor3 = UITheme.ColorGold
        t2.Parent = card

        local sIdx = idx
        bindInstantTap(card, function()
            Config.StageIndex = sIdx
            sfxClick()
            updateHomeUI()
        end)

        UI.HomeStageBtns[sIdx] = { card = card, stroke = st, t1 = t1 }
    end

    makeHeader("GIAO DIỆN BÀN CỜ", 3)

    local HomeThemeRow = Instance.new("Frame")
    HomeThemeRow.LayoutOrder = 4
    HomeThemeRow.Size = UDim2.new(1, 0, 0, 34)
    HomeThemeRow.BackgroundTransparency = 1
    HomeThemeRow.Parent = RightCard

    UI.HomeThemeBtns = {}
    for idx, key in ipairs(THEME_ORDER) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.238, 0, 1, 0)
        b.Position = UDim2.new((idx - 1) * 0.254, 0, 0, 0)
        b.BackgroundColor3 = UITheme.BgButton
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Text = BoardThemes[key].Name
        b.Font = FONT_MAIN
        b.TextSize = 12
        b.TextColor3 = UITheme.TextSecondary
        b.Parent = HomeThemeRow
        addCorner(b, 7)
        local st = addStroke(b, UITheme.StrokeSubtle, 1.2, 0.3)
        bindInstantTap(b, function()
            Config.ThemeKey = key
            saveStats()
            sfxClick()
            updateHomeUI()
        end)
        UI.HomeThemeBtns[key] = { btn = b, stroke = st }
    end

    makeHeader("CHẾ ĐỘ CHƠI", 5)

    local OptRow = Instance.new("Frame")
    OptRow.LayoutOrder = 6
    OptRow.Size = UDim2.new(1, 0, 0, 34)
    OptRow.BackgroundTransparency = 1
    OptRow.Parent = RightCard

    local function makeOpt(xScale, wScale, text, onTap)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(wScale, 0, 1, 0)
        b.Position = UDim2.new(xScale, 0, 0, 0)
        b.BackgroundColor3 = UITheme.BgButton
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Text = text
        b.Font = FONT_MAIN
        b.TextSize = 11
        b.TextColor3 = UITheme.TextPrimary
        b.Parent = OptRow
        addCorner(b, 7)
        local st = addStroke(b, UITheme.StrokeSubtle, 1.2, 0.3)
        bindInstantTap(b, onTap)
        return b, st
    end

    UI.HomeChordBtn, UI.HomeChordStroke = makeOpt(0, 0.49, "Mở nhanh ô số: Bật", function()
        Config.QuickChord = not Config.QuickChord
        sfxClick()
        updateHomeUI()
    end)

    UI.HomeSoundBtn, UI.HomeSoundStroke = makeOpt(0.51, 0.49, "Âm thanh: Bật", function()
        Config.SoundEnabled = not Config.SoundEnabled
        if Config.SoundEnabled then sfxClick() end
        updateHomeUI()
    end)
end

-- ========================================================================
-- [PHẦN 06] MÀN HÌNH CHƠI GAME (GAME SCREEN)
-- ========================================================================
local GameScreen = Instance.new("Frame")
GameScreen.Name = "GameScreen"
GameScreen.Size = UDim2.new(1, 0, 1, 0)
GameScreen.BackgroundColor3 = UITheme.BgMain
GameScreen.BorderSizePixel = 0
GameScreen.Visible = false
GameScreen.Parent = Root
addGradient(GameScreen, Color3.fromRGB(12, 21, 38), UITheme.BgMain, 135)

do
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = UITheme.BgPanel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = GameScreen
    addGradient(TopBar, UITheme.BgPanelLight, UITheme.BgPanel, 90)
    addStroke(TopBar, UITheme.StrokeSubtle, 1, 0.25)

    makeCyberIconBtn(TopBar, 34, UDim2.new(0, 12, 0.5, -17), UITheme.AccentCyan, Icons.drawHome, function()
        sfxClick()
        openHomeScreen()
    end)

    local StageLabel = Instance.new("TextLabel")
    StageLabel.Size = UDim2.new(0, 160, 0, 18)
    StageLabel.Position = UDim2.new(0, 56, 0, 7)
    StageLabel.BackgroundTransparency = 1
    StageLabel.Text = "Dễ  9x9"
    StageLabel.Font = FONT_MAIN
    StageLabel.TextSize = 13
    StageLabel.TextColor3 = UITheme.TextPrimary
    StageLabel.TextXAlignment = Enum.TextXAlignment.Left
    StageLabel.Parent = TopBar
    UI.StageLabel = StageLabel

    local ClockLabel = Instance.new("TextLabel")
    ClockLabel.Size = UDim2.new(0, 160, 0, 16)
    ClockLabel.Position = UDim2.new(0, 56, 0, 27)
    ClockLabel.BackgroundTransparency = 1
    ClockLabel.Text = "Thời gian: 00:00"
    ClockLabel.Font = FONT_BODY
    ClockLabel.TextSize = 11
    ClockLabel.TextColor3 = UITheme.TextSecondary
    ClockLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClockLabel.Parent = TopBar
    UI.ClockLabel = ClockLabel

    local StatusPill = Instance.new("Frame")
    StatusPill.Size = UDim2.new(0, 232, 0, 34)
    StatusPill.AnchorPoint = Vector2.new(0.5, 0.5)
    StatusPill.Position = UDim2.new(0.5, 0, 0.5, 0)
    StatusPill.BackgroundColor3 = UITheme.BgCard
    StatusPill.BorderSizePixel = 0
    StatusPill.Parent = TopBar
    addCorner(StatusPill, 8)
    UI.StatusStroke = addStroke(StatusPill, UITheme.AccentCyan, 1.5, 0.15)

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -12, 1, 0)
    StatusLabel.Position = UDim2.new(0, 6, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Mìn còn: 10  |  Mở: 0/71"
    StatusLabel.Font = FONT_MAIN
    StatusLabel.TextSize = 13
    StatusLabel.TextColor3 = UITheme.TextPrimary
    StatusLabel.Parent = StatusPill
    UI.StatusLabel = StatusLabel

    UI.GameXuLabel = createXuPill(TopBar)

    makeCyberIconBtn(TopBar, 34, UDim2.new(1, -86, 0.5, -17), UITheme.AccentCyan, Icons.drawMinus, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    makeCyberIconBtn(TopBar, 34, UDim2.new(1, -44, 0.5, -17), UITheme.ColorRed, Icons.drawCloseX, function()
        if _G.DoMinStandaloneCleanup then _G.DoMinStandaloneCleanup() end
    end)
end

local MainArea = Instance.new("Frame")
MainArea.Size = UDim2.new(1, -16, 1, -58)
MainArea.Position = UDim2.new(0, 8, 0, 54)
MainArea.BackgroundTransparency = 1
MainArea.Parent = GameScreen

local BoardContainer = Instance.new("Frame")
BoardContainer.Size = UDim2.new(1, -244, 1, 0)
BoardContainer.BackgroundColor3 = getTheme().BoardOuter
BoardContainer.BorderSizePixel = 0
BoardContainer.ClipsDescendants = true
BoardContainer.Parent = MainArea
addCorner(BoardContainer, 10)
addStroke(BoardContainer, UITheme.StrokeSubtle, 1.3, 0.2)
UI.BoardContainer = BoardContainer

local AlertStrip = Instance.new("TextLabel")
AlertStrip.Size = UDim2.new(0, 270, 0, 24)
AlertStrip.AnchorPoint = Vector2.new(0.5, 0)
AlertStrip.Position = UDim2.new(0.5, 0, 0, 8)
AlertStrip.BackgroundColor3 = UITheme.BgPanel
AlertStrip.BackgroundTransparency = 0.06
AlertStrip.BorderSizePixel = 0
AlertStrip.Text = ""
AlertStrip.Font = FONT_MAIN
AlertStrip.TextSize = 11
AlertStrip.TextColor3 = UITheme.ColorGold
AlertStrip.Visible = false
AlertStrip.ZIndex = 25
AlertStrip.Parent = BoardContainer
addCorner(AlertStrip, 6)
addStroke(AlertStrip, UITheme.ColorGold, 1.2, 0.2)
UI.AlertStrip = AlertStrip

local BoardScroll = Instance.new("ScrollingFrame")
BoardScroll.Size = UDim2.new(1, -8, 1, -8)
BoardScroll.Position = UDim2.new(0, 4, 0, 4)
BoardScroll.BackgroundTransparency = 1
BoardScroll.BorderSizePixel = 0
BoardScroll.ScrollBarThickness = 5
BoardScroll.ScrollBarImageColor3 = UITheme.StrokeStrong
BoardScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
BoardScroll.ScrollingDirection = Enum.ScrollingDirection.XY
BoardScroll.CanvasSize = UDim2.new(0, 400, 0, 400)
BoardScroll.Parent = BoardContainer
UI.BoardScroll = BoardScroll

local BoardFrame = Instance.new("Frame")
BoardFrame.Size = UDim2.new(0, 360, 0, 360)
BoardFrame.BackgroundColor3 = getTheme().CellHidden
BoardFrame.BorderSizePixel = 0
BoardFrame.ClipsDescendants = true
BoardFrame.Parent = BoardScroll
addCorner(BoardFrame, 4)
addStroke(BoardFrame, UITheme.StrokeStrong, 1.6, 0.2)
UI.BoardFrame = BoardFrame

local CellsLayer = Instance.new("Frame")
CellsLayer.Size = UDim2.new(1, 0, 1, 0)
CellsLayer.BackgroundTransparency = 1
CellsLayer.ZIndex = 3
CellsLayer.Parent = BoardFrame

local GridLayer = Instance.new("Frame")
GridLayer.Size = UDim2.new(1, 0, 1, 0)
GridLayer.BackgroundTransparency = 1
GridLayer.ZIndex = 10
GridLayer.Parent = BoardFrame

local InputOverlay = Instance.new("TextButton")
InputOverlay.Size = UDim2.new(1, 0, 1, 0)
InputOverlay.BackgroundTransparency = 1
InputOverlay.Text = ""
InputOverlay.AutoButtonColor = false
InputOverlay.ZIndex = 15
InputOverlay.Parent = BoardFrame

local function screenToCell(screenPos)
    local absPos = BoardFrame.AbsolutePosition
    local cs = Config.CellSize
    local c = math.floor((screenPos.X - absPos.X) / cs) + 1
    local r = math.floor((screenPos.Y - absPos.Y) / cs) + 1
    return r, c
end

bindInstantTap(InputOverlay, function(screenPos)
    if State.GameOver then return end
    local r, c = screenToCell(screenPos)
    if not inBounds(r, c) then return end
    if State.TouchMode == "FLAG" then
        handleFlag(r, c)
    else
        handleDig(r, c)
    end
end, function(screenPos)
    if State.GameOver then return end
    local r, c = screenToCell(screenPos)
    if inBounds(r, c) then
        handleFlag(r, c)
    end
end)

-- Banner kết quả trận (có nút Hồi sinh 30 Xu khi đạp trúng mìn!)
do
    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(0, 316, 0, 158)
    Banner.AnchorPoint = Vector2.new(0.5, 0.5)
    Banner.Position = UDim2.new(0.5, 0, 0.5, 0)
    Banner.BackgroundColor3 = UITheme.BgPanel
    Banner.BorderSizePixel = 0
    Banner.Visible = false
    Banner.ZIndex = 35
    Banner.Parent = BoardContainer
    addCorner(Banner, 12)
    addGradient(Banner, UITheme.BgPanelLight, UITheme.BgPanel, 135)
    UI.BannerStroke = addStroke(Banner, UITheme.ColorGold, 2, 0.1)
    UI.WinBanner = Banner

    local BannerTitle = Instance.new("TextLabel")
    BannerTitle.Size = UDim2.new(1, -20, 0, 34)
    BannerTitle.Position = UDim2.new(0, 10, 0, 14)
    BannerTitle.BackgroundTransparency = 1
    BannerTitle.Text = "CHIẾN THẮNG!"
    BannerTitle.Font = FONT_MAIN
    BannerTitle.TextSize = 20
    BannerTitle.TextColor3 = UITheme.ColorGreen
    BannerTitle.ZIndex = 36
    BannerTitle.Parent = Banner
    UI.BannerTitle = BannerTitle

    local BannerSub = Instance.new("TextLabel")
    BannerSub.Size = UDim2.new(1, -20, 0, 36)
    BannerSub.Position = UDim2.new(0, 10, 0, 50)
    BannerSub.BackgroundTransparency = 1
    BannerSub.Text = ""
    BannerSub.Font = FONT_BODY
    BannerSub.TextSize = 13
    BannerSub.TextColor3 = UITheme.TextSecondary
    BannerSub.TextWrapped = true
    BannerSub.ZIndex = 36
    BannerSub.Parent = Banner
    UI.BannerSub = BannerSub

    local PlayAgainBtn = Instance.new("TextButton")
    PlayAgainBtn.Size = UDim2.new(0, 138, 0, 36)
    PlayAgainBtn.Position = UDim2.new(0, 14, 1, -48)
    PlayAgainBtn.BackgroundColor3 = Color3.fromRGB(24, 72, 58)
    PlayAgainBtn.BorderSizePixel = 0
    PlayAgainBtn.AutoButtonColor = false
    PlayAgainBtn.Text = "Chơi ván mới"
    PlayAgainBtn.Font = FONT_MAIN
    PlayAgainBtn.TextSize = 13
    PlayAgainBtn.TextColor3 = Color3.fromRGB(186, 214, 198)
    PlayAgainBtn.ZIndex = 36
    PlayAgainBtn.Parent = Banner
    addCorner(PlayAgainBtn, 8)
    addStroke(PlayAgainBtn, UITheme.ColorGreen, 1.3, 0.2)
    bindInstantTap(PlayAgainBtn, function()
        sfxClick()
        startNewGame()
    end)

    local ReviveBtn = Instance.new("TextButton")
    ReviveBtn.Size = UDim2.new(0, 142, 0, 36)
    ReviveBtn.Position = UDim2.new(1, -156, 1, -48)
    ReviveBtn.BackgroundColor3 = Color3.fromRGB(64, 54, 28)
    ReviveBtn.BorderSizePixel = 0
    ReviveBtn.AutoButtonColor = false
    ReviveBtn.Text = "Hồi sinh 30 Xu"
    ReviveBtn.Font = FONT_MAIN
    ReviveBtn.TextSize = 13
    ReviveBtn.TextColor3 = UITheme.ColorGold
    ReviveBtn.ZIndex = 36
    ReviveBtn.Parent = Banner
    addCorner(ReviveBtn, 8)
    addStroke(ReviveBtn, UITheme.ColorGold, 1.3, 0.2)
    bindInstantTap(ReviveBtn, function()
        reviveFromMine()
    end)
    UI.ReviveBtn = ReviveBtn

    local ViewBtn = Instance.new("TextButton")
    ViewBtn.Size = UDim2.new(0, 142, 0, 36)
    ViewBtn.Position = UDim2.new(1, -156, 1, -48)
    ViewBtn.BackgroundColor3 = UITheme.BgButton
    ViewBtn.BorderSizePixel = 0
    ViewBtn.AutoButtonColor = false
    ViewBtn.Text = "Xem bàn cờ"
    ViewBtn.Font = FONT_BODY
    ViewBtn.TextSize = 13
    ViewBtn.TextColor3 = UITheme.TextPrimary
    ViewBtn.Visible = false
    ViewBtn.ZIndex = 36
    ViewBtn.Parent = Banner
    addCorner(ViewBtn, 8)
    addStroke(ViewBtn, UITheme.StrokeSubtle, 1.2, 0.25)
    bindInstantTap(ViewBtn, function()
        sfxClick()
        hideBanner()
    end)
    UI.ViewBtn = ViewBtn
end

-- ========================================================================
-- [PHẦN 07] BẢNG ĐIỀU KHIỂN PHẢI (MỞ Ô / CẮM CỜ + TIỆN ÍCH + THU PHÓNG)
-- ========================================================================
do
    local SidePanel = Instance.new("ScrollingFrame")
    SidePanel.Size = UDim2.new(0, 236, 1, 0)
    SidePanel.Position = UDim2.new(1, -236, 0, 0)
    SidePanel.BackgroundColor3 = UITheme.BgPanel
    SidePanel.BorderSizePixel = 0
    SidePanel.ScrollBarThickness = 4
    SidePanel.ScrollBarImageColor3 = UITheme.StrokeStrong
    SidePanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidePanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidePanel.Parent = MainArea
    addCorner(SidePanel, 10)
    addStroke(SidePanel, UITheme.StrokeSubtle, 1.2, 0.15)
    addGradient(SidePanel, UITheme.BgPanelLight, UITheme.BgPanel, 135)

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

    local function makeHeader(text, order)
        local lbl = Instance.new("TextLabel")
        lbl.LayoutOrder = order
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = FONT_MAIN
        lbl.TextSize = 11
        lbl.TextColor3 = UITheme.TextMuted
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = SidePanel
        return lbl
    end

    local function makeBtn(parent, text, size, pos, bgColor, textColor, strokeColor, onTap)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = bgColor or UITheme.BgButton
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = text
        btn.Font = FONT_MAIN
        btn.TextSize = 12
        btn.TextColor3 = textColor or UITheme.TextPrimary
        btn.Parent = parent
        addCorner(btn, 7)
        local st = addStroke(btn, strokeColor or UITheme.StrokeSubtle, 1.2, 0.25)
        bindInstantTap(btn, onTap)
        return btn, st
    end

    makeHeader("CHẾ ĐỘ CHẠM", 1)

    local TouchRow = Instance.new("Frame")
    TouchRow.LayoutOrder = 2
    TouchRow.Size = UDim2.new(1, 0, 0, 36)
    TouchRow.BackgroundTransparency = 1
    TouchRow.Parent = SidePanel

    UI.DigBtn, UI.DigStroke = makeBtn(TouchRow, "Mở ô", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BgActive, UITheme.AccentCyan, UITheme.AccentCyan, function()
        State.TouchMode = "DIG"
        sfxClick()
        updateControlsUI()
    end)

    UI.FlagBtn, UI.FlagStroke = makeBtn(TouchRow, "Cắm cờ", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), UITheme.BgButton, UITheme.TextSecondary, UITheme.StrokeSubtle, function()
        State.TouchMode = "FLAG"
        sfxClick()
        updateControlsUI()
    end)

    makeHeader("THAO TÁC NHANH", 3)

    local ActRow = Instance.new("Frame")
    ActRow.LayoutOrder = 4
    ActRow.Size = UDim2.new(1, 0, 0, 34)
    ActRow.BackgroundTransparency = 1
    ActRow.Parent = SidePanel

    makeBtn(ActRow, "Ván mới", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(24, 68, 58), Color3.fromRGB(186, 214, 198), UITheme.ColorGreen, function()
        sfxClick()
        startNewGame()
    end)

    makeBtn(ActRow, "Gợi ý 10 Xu", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(54, 48, 28), UITheme.ColorGold, UITheme.ColorGold, function()
        useHint()
    end)

    makeHeader("TIỆN ÍCH", 5)

    local function makeToggle(order, initText, onTap)
        local b, s = makeBtn(SidePanel, initText, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), UITheme.BgButton, UITheme.TextPrimary, UITheme.StrokeSubtle, onTap)
        b.LayoutOrder = order
        b.TextSize = 11
        return b, s
    end

    UI.ChordBtn, UI.ChordStroke = makeToggle(6, "Mở nhanh ô số: Bật", function()
        Config.QuickChord = not Config.QuickChord
        sfxClick()
        updateControlsUI()
    end)

    UI.SoundBtn, UI.SoundStroke = makeToggle(7, "Âm thanh: Bật", function()
        Config.SoundEnabled = not Config.SoundEnabled
        if Config.SoundEnabled then sfxClick() end
        updateControlsUI()
    end)

    UI.ResetBtn, UI.ResetStroke = makeToggle(8, "Đặt lại thống kê", function()
        local now = os.clock()
        if (now - State.ResetConfirmAt) <= 3.0 then
            State.ResetConfirmAt = 0
            Stats.Wins, Stats.Losses, Stats.Xu = 0, 0, 0
            saveStats()
            sfxClick()
            UI.ResetBtn.Text = "Đặt lại thống kê"
            updateTopStatus()
        else
            State.ResetConfirmAt = now
            sfxFlag()
            UI.ResetBtn.Text = "Chạm lần nữa để xóa!"
            task.delay(3.1, function()
                if not State.Destroyed and State.ResetConfirmAt == now then
                    UI.ResetBtn.Text = "Đặt lại thống kê"
                end
            end)
        end
    end)
    UI.ResetBtn.BackgroundColor3 = Color3.fromRGB(54, 28, 34)
    UI.ResetBtn.TextColor3 = UITheme.ColorRed
    UI.ResetStroke.Color = UITheme.ColorDanger

    makeHeader("PHÓNG TO / THU NHỎ", 9)

    local ZoomRow = Instance.new("Frame")
    ZoomRow.LayoutOrder = 10
    ZoomRow.Size = UDim2.new(1, 0, 0, 34)
    ZoomRow.BackgroundTransparency = 1
    ZoomRow.Parent = SidePanel

    local ZoomOutBtn = makeBtn(ZoomRow, "", UDim2.new(0.28, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BgCard, UITheme.AccentCyan, UITheme.AccentCyan, function()
        Config.CellSize = math.max(18, Config.CellSize - 4)
        sfxClick()
        rebuildBoard(true)
    end)
    Icons.drawMinus(ZoomOutBtn, UITheme.AccentCyan)

    makeBtn(ZoomRow, "Vừa màn", UDim2.new(0.40, 0, 1, 0), UDim2.new(0.30, 0, 0, 0), UITheme.BgActive, UITheme.TextPrimary, UITheme.StrokeStrong, function()
        local n = getStage().size
        local availW = math.max(180, BoardScroll.AbsoluteSize.X - 18)
        local availH = math.max(180, BoardScroll.AbsoluteSize.Y - 18)
        local fit = math.floor(math.min(availW, availH) / n)
        Config.CellSize = math.clamp(fit, (n >= 25 and 24 or 20), 46)
        sfxClick()
        rebuildBoard(false)
    end).TextSize = 11

    local ZoomInBtn = makeBtn(ZoomRow, "", UDim2.new(0.28, 0, 1, 0), UDim2.new(0.72, 0, 0, 0), UITheme.BgCard, UITheme.AccentCyan, UITheme.AccentCyan, function()
        Config.CellSize = math.min(54, Config.CellSize + 4)
        sfxClick()
        rebuildBoard(true)
    end)
    Icons.drawPlus(ZoomInBtn, UITheme.AccentCyan)
end

-- ========================================================================
-- [PHẦN 08] VẼ BÀN DÒ MÌN SIÊU NHẸ (THEO YÊU CẦU TỪNG Ô)
-- ========================================================================
renderCell = function(r, c)
    local key = cellKey(r, c)
    if UI.CellNodes[key] then
        UI.CellNodes[key]:Destroy()
        UI.CellNodes[key] = nil
    end

    local isRev = State.Revealed[r][c]
    local isFlag = State.Flagged[r][c]
    local isHint = State.HintCell and State.HintCell.r == r and State.HintCell.c == c and not isRev
    local isHit = State.HitMineCell and State.HitMineCell.r == r and State.HitMineCell.c == c
    local showMine = State.GameOver and not State.Won and State.Mines[r][c] and not isFlag

    if not isRev and not isFlag and not isHint and not showMine and not isHit then
        return
    end

    local th = getTheme()
    local cs = Config.CellSize
    local cell = Instance.new("Frame")
    cell.Name = "C_" .. r .. "_" .. c
    cell.Size = UDim2.new(0, cs, 0, cs)
    cell.Position = UDim2.new(0, (c - 1) * cs, 0, (r - 1) * cs)
    cell.BorderSizePixel = 0
    cell.ZIndex = 4
    cell.Parent = CellsLayer
    UI.CellNodes[key] = cell

    if isHit then
        cell.BackgroundColor3 = th.CellMineHit
        Icons.drawMine(cell, 0.72, th.MineColor)
    elseif isRev then
        cell.BackgroundColor3 = th.CellOpen
        local cnt = State.Counts[r][c]
        if cnt and cnt > 0 then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = tostring(cnt)
            lbl.Font = FONT_MAIN
            lbl.TextSize = math.clamp(math.floor(cs * 0.56), 11, 26)
            lbl.TextColor3 = th.NumColors[cnt] or UITheme.TextPrimary
            lbl.ZIndex = 6
            lbl.Parent = cell
        end
    elseif showMine then
        cell.BackgroundColor3 = th.CellOpen
        Icons.drawMine(cell, 0.68, th.MineColor)
    elseif isFlag then
        cell.BackgroundTransparency = 1
        Icons.drawFlag(cell, 0.68, th.FlagColor)
    elseif isHint then
        cell.BackgroundColor3 = th.CellHint
        addStroke(cell, UITheme.ColorGreen, 1.8, 0.05)
    end
end

local function centerBoardScroll()
    task.defer(function()
        if State.Destroyed then return end
        local cw, ch = BoardScroll.CanvasSize.X.Offset, BoardScroll.CanvasSize.Y.Offset
        local vw, vh = BoardScroll.AbsoluteSize.X, BoardScroll.AbsoluteSize.Y
        BoardScroll.CanvasPosition = Vector2.new(
            math.max(0, math.floor((cw - vw) / 2)),
            math.max(0, math.floor((ch - vh) / 2))
        )
    end)
end

rebuildBoard = function(preserveScroll)
    local th = getTheme()
    local n = getStage().size
    local cs = Config.CellSize
    local totalPx = n * cs

    BoardContainer.BackgroundColor3 = th.BoardOuter
    BoardFrame.BackgroundColor3 = th.CellHidden

    for _, ch in ipairs(CellsLayer:GetChildren()) do ch:Destroy() end
    for _, ch in ipairs(GridLayer:GetChildren()) do ch:Destroy() end
    UI.CellNodes = {}

    BoardFrame.Size = UDim2.new(0, totalPx, 0, totalPx)
    local vw, vh = math.max(180, BoardScroll.AbsoluteSize.X), math.max(180, BoardScroll.AbsoluteSize.Y)
    local padX, padY = math.max(14, math.floor((vw - totalPx) / 2)), math.max(14, math.floor((vh - totalPx) / 2))
    BoardFrame.Position = UDim2.new(0, padX, 0, padY)
    BoardScroll.CanvasSize = UDim2.new(0, totalPx + padX * 2, 0, totalPx + padY * 2)

    for i = 1, n - 1 do
        local vLine = Instance.new("Frame")
        vLine.Size = UDim2.new(0, 1, 1, 0)
        vLine.Position = UDim2.new(0, i * cs, 0, 0)
        vLine.BackgroundColor3 = th.GridLine
        vLine.BorderSizePixel = 0
        vLine.ZIndex = 10
        vLine.Parent = GridLayer

        local hLine = Instance.new("Frame")
        hLine.Size = UDim2.new(1, 0, 0, 1)
        hLine.Position = UDim2.new(0, 0, 0, i * cs)
        hLine.BackgroundColor3 = th.GridLine
        hLine.BorderSizePixel = 0
        hLine.ZIndex = 10
        hLine.Parent = GridLayer
    end

    for r = 1, n do
        for c = 1, n do
            renderCell(r, c)
        end
    end

    if not preserveScroll then centerBoardScroll() end
end

-- ========================================================================
-- [PHẦN 09] CẬP NHẬT TRẠNG THÁI, XỬ LÝ MỞ Ô, CẮM CỜ, GỢI Ý & HỒI SINH
-- ========================================================================
showTempAlert = function(msg)
    UI.AlertStrip.Text = msg
    UI.AlertStrip.Visible = true
    local token = os.clock()
    State.TempAlertToken = token
    task.delay(2.4, function()
        if not State.Destroyed and State.TempAlertToken == token then
            UI.AlertStrip.Visible = false
        end
    end)
end

showBanner = function(titleText, subText, accent, allowRevive)
    UI.BannerTitle.Text = titleText
    UI.BannerTitle.TextColor3 = accent or UITheme.ColorGold
    UI.BannerStroke.Color = accent or UITheme.ColorGold
    UI.BannerSub.Text = subText
    UI.ReviveBtn.Visible = allowRevive
    UI.ViewBtn.Visible = not allowRevive
    UI.WinBanner.Visible = true
end

hideBanner = function()
    UI.WinBanner.Visible = false
end

updateHomeUI = function()
    if UI.HomeXuLabel then UI.HomeXuLabel.Text = tostring(Stats.Xu) .. " Xu" end

    for idx, pack in pairs(UI.HomeStageBtns) do
        local active = (Config.StageIndex == idx)
        pack.card.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgCard
        pack.stroke.Color = active and UITheme.AccentCyan or UITheme.StrokeSubtle
        pack.t1.TextColor3 = active and UITheme.AccentCyan or UITheme.TextPrimary
    end

    for key, pack in pairs(UI.HomeThemeBtns) do
        local active = (Config.ThemeKey == key)
        pack.btn.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.ColorGreen or UITheme.StrokeSubtle
    end

    UI.HomeChordBtn.Text = Config.QuickChord and "Mở nhanh ô số: Bật" or "Mở nhanh ô số: Tắt"
    UI.HomeChordBtn.TextColor3 = Config.QuickChord and UITheme.AccentCyan or UITheme.TextSecondary
    UI.HomeChordStroke.Color = Config.QuickChord and UITheme.AccentCyan or UITheme.StrokeSubtle

    UI.HomeSoundBtn.Text = Config.SoundEnabled and "Âm thanh: Bật" or "Âm thanh: Tắt"
    UI.HomeSoundBtn.TextColor3 = Config.SoundEnabled and UITheme.ColorGreen or UITheme.TextSecondary
    UI.HomeSoundStroke.Color = Config.SoundEnabled and UITheme.ColorGreen or UITheme.StrokeSubtle
end

updateTopStatus = function()
    local stg = getStage()
    local safeTotal = stg.size * stg.size - stg.mines
    local remMines = stg.mines - State.FlagsPlaced

    UI.StageLabel.Text = stg.title .. "  " .. stg.size .. "x" .. stg.size
    UI.ClockLabel.Text = "Thời gian: " .. formatTime(State.Elapsed)
    UI.StatusLabel.Text = string.format("Mìn còn: %d  |  Mở: %d/%d", remMines, State.RevealedCount, safeTotal)
    UI.StatusStroke.Color = (State.TouchMode == "FLAG") and UITheme.ColorRed or UITheme.AccentCyan

    if UI.GameXuLabel then UI.GameXuLabel.Text = tostring(Stats.Xu) .. " Xu" end
    if UI.HomeXuLabel then UI.HomeXuLabel.Text = tostring(Stats.Xu) .. " Xu" end
end

updateControlsUI = function()
    local isDig = (State.TouchMode == "DIG")
    UI.DigBtn.BackgroundColor3 = isDig and UITheme.BgActive or UITheme.BgButton
    UI.DigBtn.TextColor3 = isDig and UITheme.AccentCyan or UITheme.TextSecondary
    UI.DigStroke.Color = isDig and UITheme.AccentCyan or UITheme.StrokeSubtle

    UI.FlagBtn.BackgroundColor3 = (not isDig) and Color3.fromRGB(64, 30, 36) or UITheme.BgButton
    UI.FlagBtn.TextColor3 = (not isDig) and UITheme.ColorRed or UITheme.TextSecondary
    UI.FlagStroke.Color = (not isDig) and UITheme.ColorRed or UITheme.StrokeSubtle

    UI.ChordBtn.Text = Config.QuickChord and "Mở nhanh ô số: Bật" or "Mở nhanh ô số: Tắt"
    UI.ChordBtn.TextColor3 = Config.QuickChord and UITheme.AccentCyan or UITheme.TextSecondary
    UI.ChordStroke.Color = Config.QuickChord and UITheme.AccentCyan or UITheme.StrokeSubtle

    UI.SoundBtn.Text = Config.SoundEnabled and "Âm thanh: Bật" or "Âm thanh: Tắt"
    UI.SoundBtn.TextColor3 = Config.SoundEnabled and UITheme.AccentCyan or UITheme.TextSecondary
    UI.SoundStroke.Color = Config.SoundEnabled and UITheme.StrokeStrong or UITheme.StrokeSubtle

    local oldIcon = UI.SoundBtn:FindFirstChild("SpeakerIcon")
    if oldIcon then oldIcon:Destroy() end
    Icons.drawSpeaker(UI.SoundBtn, not Config.SoundEnabled, Config.SoundEnabled and UITheme.AccentCyan or UITheme.TextMuted)
    updateTopStatus()
end

local function checkVictory()
    local stg = getStage()
    local safeTotal = stg.size * stg.size - stg.mines
    if State.RevealedCount >= safeTotal then
        State.GameOver = true
        State.Won = true
        Stats.Wins = Stats.Wins + 1
        Stats.Xu = Stats.Xu + stg.reward
        saveStats()
        sfxWin()

        -- Tự động cắm cờ các mìn còn lại
        local n = stg.size
        for r = 1, n do
            for c = 1, n do
                if State.Mines[r][c] and not State.Flagged[r][c] then
                    State.Flagged[r][c] = true
                    State.FlagsPlaced = State.FlagsPlaced + 1
                    renderCell(r, c)
                end
            end
        end

        updateTopStatus()
        showBanner("CHIẾN THẮNG!", string.format("+%d Xu  |  Thời gian: %s", stg.reward, formatTime(State.Elapsed)), UITheme.ColorGreen, false)
        return true
    end
    return false
end

local function floodReveal(startR, startC)
    local queue = { { startR, startC } }
    local head = 1
    while head <= #queue do
        local cur = queue[head]
        head = head + 1
        local r, c = cur[1], cur[2]
        if inBounds(r, c) and not State.Revealed[r][c] and not State.Flagged[r][c] and not State.Mines[r][c] then
            State.Revealed[r][c] = true
            State.RevealedCount = State.RevealedCount + 1
            if State.HintCell and State.HintCell.r == r and State.HintCell.c == c then
                State.HintCell = nil
            end
            renderCell(r, c)
            if State.Counts[r][c] == 0 then
                for dr = -1, 1 do
                    for dc = -1, 1 do
                        if not (dr == 0 and dc == 0) then
                            local nr, nc = r + dr, c + dc
                            if inBounds(nr, nc) and not State.Revealed[nr][nc] and not State.Flagged[nr][nc] then
                                table.insert(queue, { nr, nc })
                            end
                        end
                    end
                end
            end
        end
    end
end

local function triggerMineHit(r, c)
    State.GameOver = true
    State.Won = false
    State.HitMineCell = { r = r, c = c }
    Stats.Losses = Stats.Losses + 1
    saveStats()
    sfxBoom()

    local n = getStage().size
    for rr = 1, n do
        for cc = 1, n do
            if State.Mines[rr][cc] then
                renderCell(rr, cc)
            end
        end
    end
    updateTopStatus()
    showBanner("ĐẠP TRÚNG MÌN!", "Bạn có thể dùng 30 Xu để gỡ mìn và chơi tiếp", UITheme.ColorRed, true)
end

handleDig = function(r, c)
    if State.GameOver or State.Flagged[r][c] then return end

    if not State.Generated then
        generateMines(r, c)
    end

    -- Mở nhanh ô số nếu đã cắm đủ số cờ xung quanh
    if State.Revealed[r][c] then
        if not Config.QuickChord then return end
        local need = State.Counts[r][c]
        if need <= 0 then return end
        local flags = 0
        for dr = -1, 1 do
            for dc = -1, 1 do
                if not (dr == 0 and dc == 0) and inBounds(r + dr, c + dc) and State.Flagged[r + dr][c + dc] then
                    flags = flags + 1
                end
            end
        end
        if flags == need then
            local openedAny = false
            for dr = -1, 1 do
                for dc = -1, 1 do
                    local nr, nc = r + dr, c + dc
                    if not (dr == 0 and dc == 0) and inBounds(nr, nc) and not State.Revealed[nr][nc] and not State.Flagged[nr][nc] then
                        if State.Mines[nr][nc] then
                            triggerMineHit(nr, nc)
                            return
                        else
                            floodReveal(nr, nc)
                            openedAny = true
                        end
                    end
                end
            end
            if openedAny then
                sfxDig()
                updateTopStatus()
                checkVictory()
            end
        end
        return
    end

    if State.Mines[r][c] then
        triggerMineHit(r, c)
        return
    end

    floodReveal(r, c)
    sfxDig()
    updateTopStatus()
    checkVictory()
end

handleFlag = function(r, c)
    if State.GameOver or State.Revealed[r][c] then return end
    State.Flagged[r][c] = not State.Flagged[r][c]
    State.FlagsPlaced = State.FlagsPlaced + (State.Flagged[r][c] and 1 or -1)
    sfxFlag()
    renderCell(r, c)
    updateTopStatus()
end

useHint = function()
    if State.GameOver then return end
    if Stats.Xu < 10 then
        sfxFlag()
        showTempAlert("Không đủ Xu! Cần 10 Xu để Gợi ý")
        return
    end

    local n = getStage().size
    if not State.Generated then
        local mid = math.floor((n + 1) / 2)
        Stats.Xu = Stats.Xu - 10
        saveStats()
        handleDig(mid, mid)
        return
    end

    -- Ưu tiên chọn ô an toàn giáp ranh vùng đã mở
    local frontier, fallback = {}, {}
    for r = 1, n do
        for c = 1, n do
            if not State.Revealed[r][c] and not State.Flagged[r][c] and not State.Mines[r][c] then
                local nearOpen = false
                for dr = -1, 1 do
                    for dc = -1, 1 do
                        if inBounds(r + dr, c + dc) and State.Revealed[r + dr][c + dc] then
                            nearOpen = true
                            break
                        end
                    end
                    if nearOpen then break end
                end
                if nearOpen then
                    table.insert(frontier, { r, c })
                else
                    table.insert(fallback, { r, c })
                end
            end
        end
    end

    local pool = (#frontier > 0) and frontier or fallback
    if #pool == 0 then return end
    local pick = pool[math.random(1, #pool)]

    Stats.Xu = Stats.Xu - 10
    saveStats()
    floodReveal(pick[1], pick[2])
    sfxDig()
    updateTopStatus()
    checkVictory()
end

reviveFromMine = function()
    if not State.GameOver or State.Won or not State.HitMineCell then return end
    if Stats.Xu < 30 then
        sfxFlag()
        showTempAlert("Không đủ Xu! Cần 30 Xu để Hồi sinh")
        return
    end

    Stats.Xu = Stats.Xu - 30
    Stats.Losses = math.max(0, Stats.Losses - 1)
    saveStats()

    local mr, mc = State.HitMineCell.r, State.HitMineCell.c
    State.GameOver = false
    State.HitMineCell = nil
    if not State.Flagged[mr][mc] then
        State.Flagged[mr][mc] = true
        State.FlagsPlaced = State.FlagsPlaced + 1
    end
    hideBanner()
    sfxClick()

    -- Ẩn lại tất cả mìn chưa mở
    local n = getStage().size
    for r = 1, n do
        for c = 1, n do
            if State.Mines[r][c] then
                renderCell(r, c)
            end
        end
    end
    updateTopStatus()
    showTempAlert("Đã gỡ mìn thành công! Tiếp tục chơi nhé")
end

openHomeScreen = function()
    State.Screen = "HOME"
    HomeScreen.Visible = true
    GameScreen.Visible = false
    updateHomeUI()
end

enterGameScreen = function()
    State.Screen = "GAME"
    HomeScreen.Visible = false
    GameScreen.Visible = true
    task.defer(function()
        if not State.Destroyed then startNewGame(true) end
    end)
end

startNewGame = function(forceResize)
    local stg = getStage()
    State.TouchMode = "DIG"
    State.Generated = false
    State.GameOver = false
    State.Won = false
    State.RevealedCount = 0
    State.FlagsPlaced = 0
    State.Elapsed = 0
    State.HitMineCell = nil
    State.HintCell = nil
    hideBanner()
    resetArrays()

    if forceResize or Config.CellSize < 18 then
        local availW = math.max(180, BoardScroll.AbsoluteSize.X - 20)
        local availH = math.max(180, BoardScroll.AbsoluteSize.Y - 20)
        local fit = math.floor(math.min(availW, availH) / stg.size)
        Config.CellSize = math.clamp(fit, (stg.size >= 25 and 24 or 22), 44)
    end

    rebuildBoard(false)
    updateControlsUI()
    updateTopStatus()
end

-- Bộ đếm thời gian trận đấu
task.spawn(function()
    while not State.Destroyed do
        task.wait(0.5)
        if not State.Destroyed and State.Screen == "GAME" and State.Generated and not State.GameOver and not State.Minimized then
            State.Elapsed = State.Elapsed + 0.5
            UI.ClockLabel.Text = "Thời gian: " .. formatTime(State.Elapsed)
        end
    end
end)

-- ========================================================================
-- [PHẦN 10] PHÍM TẮT PC & DỌN DẸP TOÀN BỘ SCRIPT
-- ========================================================================
trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or State.Destroyed then return end
    if State.Screen == "GAME" and Root.Visible then
        if input.KeyCode == Enum.KeyCode.F then
            State.TouchMode = (State.TouchMode == "DIG") and "FLAG" or "DIG"
            updateControlsUI()
        elseif input.KeyCode == Enum.KeyCode.R then
            startNewGame()
        elseif input.KeyCode == Enum.KeyCode.H then
            useHint()
        end
    end
    if input.KeyCode == Enum.KeyCode.M then
        State.Minimized = not State.Minimized
        Root.Visible = not State.Minimized
        FloatBtn.Visible = State.Minimized
    end
end))

_G.DoMinStandaloneCleanup = function()
    State.Destroyed = true
    for _, conn in ipairs(UI.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    UI.Connections = {}
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    _G.DoMinStandaloneCleanup = nil
end

openHomeScreen()
