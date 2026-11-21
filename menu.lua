--[[
    ========================================================================
    CỜ CARO - STANDALONE v3.3
    Game Cờ Caro 2D Toàn Màn Hình cho Roblox Mobile & PC
    - Đồ họa Cyber-Navy & Cyan-Teal matte đồng bộ theo bộ icon vector
    - Sảnh Chính tinh gọn: xóa thanh cấp bậc trên đỉnh, 5 ô thắng cho mọi màn >=12x12
    - Gộp Thời gian mỗi lượt thành 1 nút chuyển nhanh trong mục CHẾ ĐỘ CHƠI
    - Bảng trong trận bổ sung thanh Phóng to / Vừa / Thu nhỏ ở chỗ trống bên dưới
    ========================================================================
]]

if _G.CoCaroProCleanup then
    pcall(_G.CoCaroProCleanup)
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ========================================================================
-- [PHẦN 01] CẤU HÌNH, BẢNG MÀU CYBER-NAVY MATTE & 4 CHỦ ĐỀ BÀN CỜ
-- ========================================================================
local SAVE_FILE = "CoCaroPro_Stats_v3.json"

-- Bảng màu Cyber-Navy & Matte Cyan-Teal (mọi kênh RGB của chữ/icon đều <= 215)
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

    ColorX        = Color3.fromRGB(204, 92, 96),
    ColorO        = Color3.fromRGB(76, 192, 206),
    ColorGold     = Color3.fromRGB(204, 168, 84),
    ColorGreen    = Color3.fromRGB(88, 186, 132),
    ColorDanger   = Color3.fromRGB(190, 82, 86),
}

local BoardThemes = {
    Dark = {
        Name        = "Tối",
        BoardOuter  = Color3.fromRGB(12, 20, 36),
        BoardBg     = Color3.fromRGB(20, 30, 48),
        GridLine    = Color3.fromRGB(38, 60, 84),
        CellLast    = Color3.fromRGB(34, 58, 82),
        CellWin     = Color3.fromRGB(68, 62, 38),
        CellHint    = Color3.fromRGB(32, 68, 58),
        CellPending = Color3.fromRGB(62, 54, 38),
        CenterDot   = Color3.fromRGB(84, 154, 172),
        PieceX      = Color3.fromRGB(204, 92, 96),
        PieceO      = Color3.fromRGB(76, 192, 206),
        WinLine     = Color3.fromRGB(206, 172, 86),
        NumText     = Color3.fromRGB(172, 190, 204),
    },
    Wood = {
        Name        = "Gỗ",
        BoardOuter  = Color3.fromRGB(40, 29, 21),
        BoardBg     = Color3.fromRGB(144, 114, 80),
        GridLine    = Color3.fromRGB(94, 70, 44),
        CellLast    = Color3.fromRGB(168, 138, 92),
        CellWin     = Color3.fromRGB(180, 154, 86),
        CellHint    = Color3.fromRGB(112, 142, 94),
        CellPending = Color3.fromRGB(164, 122, 78),
        CenterDot   = Color3.fromRGB(82, 58, 36),
        PieceX      = Color3.fromRGB(152, 36, 36),
        PieceO      = Color3.fromRGB(26, 74, 118),
        WinLine     = Color3.fromRGB(196, 154, 52),
        NumText     = Color3.fromRGB(44, 34, 24),
    },
    Emerald = {
        Name        = "Ngọc",
        BoardOuter  = Color3.fromRGB(13, 28, 25),
        BoardBg     = Color3.fromRGB(24, 49, 43),
        GridLine    = Color3.fromRGB(42, 76, 66),
        CellLast    = Color3.fromRGB(42, 78, 66),
        CellWin     = Color3.fromRGB(78, 76, 38),
        CellHint    = Color3.fromRGB(46, 90, 68),
        CellPending = Color3.fromRGB(68, 62, 40),
        CenterDot   = Color3.fromRGB(116, 166, 152),
        PieceX      = Color3.fromRGB(204, 102, 96),
        PieceO      = Color3.fromRGB(92, 190, 202),
        WinLine     = Color3.fromRGB(206, 176, 92),
        NumText     = Color3.fromRGB(174, 196, 188),
    },
    Paper = {
        Name        = "Vở Ô Ly",
        BoardOuter  = Color3.fromRGB(150, 146, 136),
        BoardBg     = Color3.fromRGB(195, 191, 181),
        GridLine    = Color3.fromRGB(136, 150, 166),
        CellLast    = Color3.fromRGB(180, 176, 150),
        CellWin     = Color3.fromRGB(196, 182, 126),
        CellHint    = Color3.fromRGB(156, 184, 158),
        CellPending = Color3.fromRGB(192, 170, 140),
        CenterDot   = Color3.fromRGB(88, 102, 118),
        PieceX      = Color3.fromRGB(172, 48, 52),
        PieceO      = Color3.fromRGB(36, 92, 154),
        WinLine     = Color3.fromRGB(178, 128, 34),
        NumText     = Color3.fromRGB(54, 60, 72),
    },
}

local THEME_ORDER = { "Dark", "Wood", "Emerald", "Paper" }

-- 8 Màn chơi: 3x3 là "3 ô thắng", tất cả màn còn lại là "5 ô thắng"
local STAGES = {
    { size = 3,   winLen = 3, title = "3x3",     sub = "3 ô thắng" },
    { size = 12,  winLen = 5, title = "12x12",   sub = "5 ô thắng" },
    { size = 15,  winLen = 5, title = "15x15",   sub = "5 ô thắng" },
    { size = 20,  winLen = 5, title = "20x20",   sub = "5 ô thắng" },
    { size = 35,  winLen = 5, title = "35x35",   sub = "5 ô thắng" },
    { size = 50,  winLen = 5, title = "50x50",   sub = "5 ô thắng" },
    { size = 70,  winLen = 5, title = "70x70",   sub = "5 ô thắng" },
    { size = 100, winLen = 5, title = "100x100", sub = "5 ô thắng" },
}

local TIME_CYCLE = { 0, 15, 30, 60 }

local FONT_MAIN = Enum.Font.GothamSemibold
local FONT_BODY = Enum.Font.GothamMedium

local Config = {
    BoardSize       = 15,
    Mode            = "AI",       -- "AI" | "PVP"
    Difficulty      = "Medium",   -- "Easy" | "Medium" | "Hard" | "Master"
    BlockTwoEnds    = true,
    PlayerSide      = 1,          -- 1 = X, 2 = O
    ThemeKey        = "Dark",
    TurnTimeLimit   = 0,          -- 0 | 15 | 30 | 60
    ConfirmTwoTap   = false,
    ShowMoveNumbers = false,
    SoundEnabled    = true,
    CellSize        = 30,
}

local State = {
    Screen          = "HOME",     -- "HOME" | "GAME"
    Grid            = {},
    CurrentTurn     = 1,
    GameOver        = false,
    Winner          = 0,
    IsDraw          = false,
    AIThinking      = false,
    History         = {},
    WinCells        = {},
    HintCell        = nil,
    PendingCell     = nil,
    Minimized       = false,
    Destroyed       = false,
    ActiveMatchId   = 0,
    MatchElapsed    = 0,
    TurnTimeLeft    = 0,
    SessionX        = 0,
    SessionO        = 0,
    ThreatAlert     = "",
    ResetConfirmAt  = 0,
}

local Stats = {
    Wins       = 0,
    Losses     = 0,
    Draws      = 0,
    Streak     = 0,
    BestStreak = 0,
    Xu         = 0,
}

local UI = {
    PieceNodes = {},
    Connections = {},
}

-- ========================================================================
-- [PHẦN 02] TIỆN ÍCH LƯU DỮ LIỆU, ÂM THANH & BỘ ICON VECTOR CYBER-TEAL
-- ========================================================================
local function getTheme()
    return BoardThemes[Config.ThemeKey] or BoardThemes.Dark
end

local function getWinLength(boardSize)
    return (boardSize <= 3) and 3 or 5
end

local function isBlockTwoEndsActive()
    return Config.BlockTwoEnds and getWinLength(Config.BoardSize) >= 5
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
                    Stats.Wins       = tonumber(data.Wins) or 0
                    Stats.Losses     = tonumber(data.Losses) or 0
                    Stats.Draws      = tonumber(data.Draws) or 0
                    Stats.Streak     = tonumber(data.Streak) or 0
                    Stats.BestStreak = tonumber(data.BestStreak) or 0
                    Stats.Xu         = tonumber(data.Xu) or 0
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
                Wins       = Stats.Wins,
                Losses     = Stats.Losses,
                Draws      = Stats.Draws,
                Streak     = Stats.Streak,
                BestStreak = Stats.BestStreak,
                Xu         = Stats.Xu,
                ThemeKey   = Config.ThemeKey,
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

-- Bộ vẽ icon vector sắc nét đồng bộ phong cách Cyber-Teal
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
    local col = color or UITheme.AccentCyan
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

    -- Mái nhà chữ V ngược
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
    -- Thân nhà
    local body = Instance.new("Frame")
    body.Size = UDim2.new(0, 12, 0, 9)
    body.AnchorPoint = Vector2.new(0.5, 1)
    body.Position = UDim2.new(0.5, 0, 1, -1)
    body.BackgroundTransparency = 1
    body.Parent = wrap
    addStroke(body, col, 2, 0)
    addCorner(body, 2)
    -- Cửa nhỏ ở giữa
    local door = Instance.new("Frame")
    door.Size = UDim2.new(0, 4, 0, 5)
    door.AnchorPoint = Vector2.new(0.5, 1)
    door.Position = UDim2.new(0.5, 0, 1, 0)
    door.BackgroundColor3 = col
    door.BorderSizePixel = 0
    door.Parent = body
    addCorner(door, 1)
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
            xbar.BackgroundColor3 = UITheme.ColorX
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

-- Cảm ứng tức thì cho mobile & PC (lọc cử chỉ vuốt/cuộn > 14px)
local function bindInstantTap(button, callback)
    local pressPos = nil
    local lastFire = 0

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
            if delta <= 14 and (now - lastFire) >= 0.08 then
                lastFire = now
                callback(input.Position)
            end
        end
    end))
end

-- Nút icon vuông Cyber-Teal giống bộ icon tham khảo
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
    addGradient(b, UITheme.BgButton, UITheme.BgPanel, 90)
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
        snd.Volume = volume or 0.35
        snd.PlaybackSpeed = pitch or 1.0
        snd.Parent = SoundFolder
        snd:Play()
        task.delay(1.2, function()
            if snd and snd.Parent then snd:Destroy() end
        end)
    end)
end

local function sfxPlace(player)
    playSfx("rbxassetid://421058925", 0.34, (player == 1) and 1.15 or 0.92)
end
local function sfxWin()   playSfx("rbxassetid://4590662766", 0.45, 1.0) end
local function sfxWarn()  playSfx("rbxassetid://421058925", 0.38, 0.72) end
local function sfxClick() playSfx("rbxassetid://421058925", 0.22, 1.35) end

local function formatTime(sec)
    local s = math.max(0, math.floor(sec))
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end

-- ========================================================================
-- [PHẦN 03] LOGIC BÀN CỜ (3 Ô CHO 3x3 & 5 Ô CHO 12x12..100x100)
-- ========================================================================
local DIRS = { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 1, -1 } }

local function inBounds(r, c)
    local n = Config.BoardSize
    return r >= 1 and r <= n and c >= 1 and c <= n
end

local function initGrid()
    local n = Config.BoardSize
    State.Grid = {}
    for r = 1, n do
        local row = {}
        for c = 1, n do row[c] = 0 end
        State.Grid[r] = row
    end
end

local function checkWinAt(r, c, p)
    local grid = State.Grid
    local opp = (p == 1) and 2 or 1
    local winLen = getWinLength(Config.BoardSize)
    local blockRule = isBlockTwoEndsActive()

    for _, d in ipairs(DIRS) do
        local dr, dc = d[1], d[2]
        local negCells = {}
        local pr, pc = r - dr, c - dc
        while inBounds(pr, pc) and grid[pr][pc] == p do
            table.insert(negCells, { pr, pc })
            pr = pr - dr
            pc = pc - dc
        end
        local blockedNeg = inBounds(pr, pc) and grid[pr][pc] == opp

        local posCells = {}
        local nr, nc = r + dr, c + dc
        while inBounds(nr, nc) and grid[nr][nc] == p do
            table.insert(posCells, { nr, nc })
            nr = nr + dr
            nc = nc + dc
        end
        local blockedPos = inBounds(nr, nc) and grid[nr][nc] == opp

        local line = {}
        for i = #negCells, 1, -1 do table.insert(line, negCells[i]) end
        table.insert(line, { r, c })
        for i = 1, #posCells do table.insert(line, posCells[i]) end

        local count = #line
        if count >= winLen then
            if blockRule then
                if count > winLen or not (blockedPos and blockedNeg) then return line end
            else
                return line
            end
        end
    end
    return nil
end

local function detectThreatAfterMove(r, c, p)
    if getWinLength(Config.BoardSize) < 5 then return "" end
    local grid = State.Grid
    local open3, open4, half4 = 0, 0, 0

    for _, d in ipairs(DIRS) do
        local dr, dc = d[1], d[2]
        local count, openEnds = 1, 0

        local nr, nc = r + dr, c + dc
        while inBounds(nr, nc) and grid[nr][nc] == p do
            count = count + 1
            nr = nr + dr
            nc = nc + dc
        end
        if inBounds(nr, nc) and grid[nr][nc] == 0 then openEnds = openEnds + 1 end

        local pr, pc = r - dr, c - dc
        while inBounds(pr, pc) and grid[pr][pc] == p do
            count = count + 1
            pr = pr - dr
            pc = pc - dc
        end
        if inBounds(pr, pc) and grid[pr][pc] == 0 then openEnds = openEnds + 1 end

        if count == 4 then
            if openEnds == 2 then open4 = open4 + 1
            elseif openEnds == 1 then half4 = half4 + 1 end
        elseif count == 3 and openEnds == 2 then
            open3 = open3 + 1
        end
    end

    local sym = (p == 1) and "X" or "O"
    if open4 >= 1 then return "NGUY HIỂM: " .. sym .. " tạo 4 thoáng!"
    elseif half4 >= 1 and open3 >= 1 then return "THẾ 4-3: " .. sym .. " đang ép thắng!"
    elseif half4 >= 1 then return "CHIẾU 4: " .. sym .. " còn 1 nước!"
    elseif open3 >= 2 then return "THẾ 3 ĐÔI: " .. sym .. " rất mạnh!" end
    return ""
end

local function isBoardFull()
    return #State.History >= (Config.BoardSize * Config.BoardSize)
end

-- ========================================================================
-- [PHẦN 04] AI 4 CẤP ĐỘ THÍCH NGHI MỌI KÍCH THƯỚC (3x3 ĐẾN 100x100)
-- ========================================================================
local AI = {}

function AI.scoreLine(r, c, dr, dc, p)
    local grid = State.Grid
    local opp = (p == 1) and 2 or 1
    local winLen = getWinLength(Config.BoardSize)
    local blockRule = isBlockTwoEndsActive()

    local count, openEnds, blockedByOpp = 1, 0, 0

    local nr, nc = r + dr, c + dc
    while inBounds(nr, nc) and grid[nr][nc] == p do
        count = count + 1
        nr = nr + dr
        nc = nc + dc
    end
    local gapPosCount, gapPosOpen = 0, false
    if inBounds(nr, nc) then
        if grid[nr][nc] == 0 then
            openEnds = openEnds + 1
            local gr, gc = nr + dr, nc + dc
            while inBounds(gr, gc) and grid[gr][gc] == p do
                gapPosCount = gapPosCount + 1
                gr = gr + dr
                gc = gc + dc
            end
            if gapPosCount > 0 and inBounds(gr, gc) and grid[gr][gc] == 0 then gapPosOpen = true end
        elseif grid[nr][nc] == opp then
            blockedByOpp = blockedByOpp + 1
        end
    end

    local pr, pc = r - dr, c - dc
    while inBounds(pr, pc) and grid[pr][pc] == p do
        count = count + 1
        pr = pr - dr
        pc = pc - dc
    end
    local gapNegCount, gapNegOpen = 0, false
    if inBounds(pr, pc) then
        if grid[pr][pc] == 0 then
            openEnds = openEnds + 1
            local gr, gc = pr - dr, pc - dc
            while inBounds(gr, gc) and grid[gr][gc] == p do
                gapNegCount = gapNegCount + 1
                gr = gr - dr
                gc = gc - dc
            end
            if gapNegCount > 0 and inBounds(gr, gc) and grid[gr][gc] == 0 then gapNegOpen = true end
        elseif grid[pr][pc] == opp then
            blockedByOpp = blockedByOpp + 1
        end
    end

    if count >= winLen then
        if not blockRule or count > winLen or blockedByOpp < 2 then
            return 10000000, "WIN"
        else
            return 60, "BLOCKED5"
        end
    end

    local need = winLen - count
    local score, tag = 0, "NONE"

    if need == 1 then
        if openEnds == 2 then score = 1350000; tag = "OPEN4"
        elseif openEnds == 1 then score = 155000; tag = "HALF4" end
    elseif need == 2 then
        if openEnds == 2 then score = 54000; tag = "OPEN3"
        elseif openEnds == 1 then score = 4800; tag = "HALF3" end
    elseif need == 3 then
        if openEnds == 2 then score = 1500; tag = "OPEN2"
        elseif openEnds == 1 then score = 240 end
    else
        if openEnds == 2 then score = 65 elseif openEnds == 1 then score = 18 end
    end

    local bestGap = math.max(gapPosCount, gapNegCount)
    if bestGap > 0 then
        local totalSpan = count + bestGap
        local spanOpen = (bestGap == gapPosCount and gapPosOpen) or (bestGap == gapNegCount and gapNegOpen)
        if totalSpan >= winLen - 1 then
            if 125000 > score then score = 125000; tag = "HALF4" end
        elseif totalSpan == winLen - 2 and openEnds >= 1 and spanOpen then
            if 40000 > score then score = 40000; tag = "OPEN3" end
        elseif totalSpan >= 2 and openEnds >= 1 and spanOpen then
            score = score + 850
        end
    end

    return score, tag
end

function AI.evaluatePointFor(r, c, p)
    local total, half4Count, open3Count = 0, 0, 0
    for _, d in ipairs(DIRS) do
        local s, tag = AI.scoreLine(r, c, d[1], d[2], p)
        total = total + s
        if tag == "WIN" then return 10000000
        elseif tag == "HALF4" then half4Count = half4Count + 1
        elseif tag == "OPEN3" then open3Count = open3Count + 1 end
    end
    if half4Count >= 2 then total = total + 1100000
    elseif half4Count >= 1 and open3Count >= 1 then total = total + 880000
    elseif open3Count >= 2 then total = total + 620000 end
    return total
end

function AI.getCandidates()
    local n = Config.BoardSize
    local grid = State.Grid
    local candidates = {}

    if #State.History == 0 then
        local mid = math.floor((n + 1) / 2)
        return { { r = mid, c = mid } }
    end

    if n <= 3 then
        for r = 1, n do
            for c = 1, n do
                if grid[r][c] == 0 then table.insert(candidates, { r = r, c = c }) end
            end
        end
        return candidates
    end

    local mark = {}
    for _, mv in ipairs(State.History) do
        local mr, mc = mv.r, mv.c
        for dr = -2, 2 do
            local r = mr + dr
            if r >= 1 and r <= n then
                for dc = -2, 2 do
                    local c = mc + dc
                    if c >= 1 and c <= n and grid[r][c] == 0 then
                        local key = cellKey(r, c)
                        if not mark[key] then
                            mark[key] = true
                            table.insert(candidates, { r = r, c = c })
                        end
                    end
                end
            end
        end
    end
    return candidates
end

function AI.chooseMove(side, difficulty)
    local opp = (side == 1) and 2 or 1
    local n = Config.BoardSize
    local mid = (n + 1) / 2
    local candidates = AI.getCandidates()

    if #candidates == 0 then return nil end
    if #candidates == 1 then return candidates[1].r, candidates[1].c end

    local defWeight = (difficulty == "Easy" and 0.76)
        or (difficulty == "Hard" and 1.12)
        or (difficulty == "Master" and 1.16)
        or 1.06

    local scored = {}
    for _, cand in ipairs(candidates) do
        local r, c = cand.r, cand.c
        local atk = AI.evaluatePointFor(r, c, side)
        local def = AI.evaluatePointFor(r, c, opp)
        local combined
        if atk >= 10000000 then
            combined = 60000000
        elseif def >= 10000000 then
            combined = (difficulty == "Easy" and math.random() < 0.25) and (def * 0.4 + atk) or (35000000 + atk)
        else
            local dist = math.abs(r - mid) + math.abs(c - mid)
            combined = atk + def * defWeight + math.max(0, (n - dist)) * 7
        end
        table.insert(scored, { r = r, c = c, score = combined, atk = atk, def = def })
    end

    table.sort(scored, function(a, b) return a.score > b.score end)
    if scored[1].score >= 30000000 then return scored[1].r, scored[1].c end

    if difficulty == "Easy" then
        local pick = scored[math.random(1, math.min(4, #scored))]
        return pick.r, pick.c
    end

    if difficulty == "Medium" then
        local topScore = scored[1].score
        local pool = { scored[1] }
        for i = 2, math.min(3, #scored) do
            if scored[i].score >= topScore * 0.93 then table.insert(pool, scored[i]) end
        end
        local pick = pool[math.random(1, #pool)]
        return pick.r, pick.c
    end

    local topK = (difficulty == "Master") and math.min(14, #scored) or math.min(8, #scored)
    local checkPool = (difficulty == "Master") and math.min(18, #scored) or math.min(12, #scored)
    local bestMove, bestEval = scored[1], -1e15
    local grid = State.Grid

    for i = 1, topK do
        local mv = scored[i]
        grid[mv.r][mv.c] = side
        local oppBest, sideFollowUp, sideThreats = 0, 0, 0
        for j = 1, checkPool do
            if j ~= i then
                local c2 = scored[j]
                if grid[c2.r][c2.c] == 0 then
                    local oScore = AI.evaluatePointFor(c2.r, c2.c, opp)
                    if oScore > oppBest then oppBest = oScore end
                    local sScore = AI.evaluatePointFor(c2.r, c2.c, side)
                    if sScore > sideFollowUp then sideFollowUp = sScore end
                    if sScore >= 120000 then sideThreats = sideThreats + 1 end
                end
            end
        end
        grid[mv.r][mv.c] = 0

        local evalVal = mv.score + sideFollowUp * 0.34 - oppBest * 0.46
        if sideThreats >= 2 then evalVal = evalVal + 950000 end
        if oppBest >= 10000000 then evalVal = evalVal - 20000000
        elseif oppBest >= 1000000 and mv.atk < 1000000 then evalVal = evalVal - 3500000 end

        if evalVal > bestEval then bestEval = evalVal; bestMove = mv end
    end
    return bestMove.r, bestMove.c
end

-- ========================================================================
-- [PHẦN 05] KHỞI TẠO SCREEN GUI & NÚT THU GỌN NỔI
-- ========================================================================
loadStats()

local guiParent = getGuiParent()
do
    local old = guiParent:FindFirstChild("CoCaroPro_Standalone")
    if old then pcall(function() old:Destroy() end) end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoCaroPro_Standalone"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = guiParent

SoundFolder = Instance.new("Folder")
SoundFolder.Name = "CaroAudio"
SoundFolder.Parent = ScreenGui

local Root = Instance.new("Frame")
Root.Name = "Root"
Root.Size = UDim2.new(1, 0, 1, 0)
Root.BackgroundColor3 = UITheme.BgMain
Root.BorderSizePixel = 0
Root.Active = true
Root.Parent = ScreenGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatingReopen"
FloatBtn.Size = UDim2.new(0, 102, 0, 38)
FloatBtn.Position = UDim2.new(0, 16, 0, 74)
FloatBtn.BackgroundColor3 = UITheme.BgPanel
FloatBtn.BorderSizePixel = 0
FloatBtn.AutoButtonColor = false
FloatBtn.Text = "CỜ CARO"
FloatBtn.Font = FONT_MAIN
FloatBtn.TextSize = 14
FloatBtn.TextColor3 = UITheme.AccentCyan
FloatBtn.Visible = false
FloatBtn.ZIndex = 50
FloatBtn.Parent = ScreenGui
addCorner(FloatBtn, 8)
addStroke(FloatBtn, UITheme.AccentCyan, 1.5, 0.15)
addGradient(FloatBtn, UITheme.BgButton, UITheme.BgPanel, 90)

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

local openHomeScreen, enterGameScreen, rebuildBoard, refreshBoardVisuals, updateTopStatus
local updateControlsUI, updateHomeUI
local startNewGame, performMove, undoMove, showHint, surrenderGame, showWinBanner, hideWinBanner, drawWinLine

-- ========================================================================
-- [PHẦN 06] GIAO DIỆN CHÍNH / SẢNH CHÍNH (ĐỒ HỌA CYBER-NAVY NÂNG CẤP)
-- ========================================================================
local HomeScreen = Instance.new("Frame")
HomeScreen.Name = "HomeScreen"
HomeScreen.Size = UDim2.new(1, 0, 1, 0)
HomeScreen.BackgroundColor3 = UITheme.BgMain
HomeScreen.BorderSizePixel = 0
HomeScreen.Visible = true
HomeScreen.Parent = Root
addGradient(HomeScreen, Color3.fromRGB(12, 21, 38), UITheme.BgMain, 135)
UI.HomeScreen = HomeScreen

do
    -- Top Bar Sảnh Chính (đã xóa thanh Tập Sự | 0 Thắng | 0 Xu)
    local HomeTop = Instance.new("Frame")
    HomeTop.Size = UDim2.new(1, 0, 0, 50)
    HomeTop.BackgroundColor3 = UITheme.BgPanel
    HomeTop.BorderSizePixel = 0
    HomeTop.Parent = HomeScreen
    addGradient(HomeTop, UITheme.BgPanelLight, UITheme.BgPanel, 90)
    addStroke(HomeTop, UITheme.StrokeSubtle, 1, 0.25)

    -- Thanh nhấn màu cyan mảnh ở chân TopBar
    local topAccent = Instance.new("Frame")
    topAccent.Size = UDim2.new(1, 0, 0, 1)
    topAccent.Position = UDim2.new(0, 0, 1, -1)
    topAccent.BackgroundColor3 = UITheme.StrokeStrong
    topAccent.BackgroundTransparency = 0.45
    topAccent.BorderSizePixel = 0
    topAccent.Parent = HomeTop

    local HomeBrand = Instance.new("TextLabel")
    HomeBrand.Size = UDim2.new(0, 180, 1, 0)
    HomeBrand.Position = UDim2.new(0, 18, 0, 0)
    HomeBrand.BackgroundTransparency = 1
    HomeBrand.Text = "CỜ CARO"
    HomeBrand.Font = FONT_MAIN
    HomeBrand.TextSize = 17
    HomeBrand.TextColor3 = UITheme.AccentCyan
    HomeBrand.TextXAlignment = Enum.TextXAlignment.Left
    HomeBrand.Parent = HomeTop

    -- 2 nút icon cyber-teal: Thu gọn (-) & Đóng (X)
    makeCyberIconBtn(HomeTop, 34, UDim2.new(1, -86, 0.5, -17), UITheme.AccentCyan, Icons.drawMinus, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    makeCyberIconBtn(HomeTop, 34, UDim2.new(1, -44, 0.5, -17), UITheme.ColorX, Icons.drawCloseX, function()
        if _G.CoCaroProCleanup then _G.CoCaroProCleanup() end
    end)

    local HomeBody = Instance.new("Frame")
    HomeBody.Size = UDim2.new(1, -24, 1, -66)
    HomeBody.Position = UDim2.new(0, 12, 0, 58)
    HomeBody.BackgroundTransparency = 1
    HomeBody.Parent = HomeScreen

    -- CỘT TRÁI
    local LeftCard = Instance.new("Frame")
    LeftCard.Size = UDim2.new(0.40, -8, 1, 0)
    LeftCard.BackgroundColor3 = UITheme.BgPanel
    LeftCard.BorderSizePixel = 0
    LeftCard.Parent = HomeBody
    addCorner(LeftCard, 12)
    addStroke(LeftCard, UITheme.StrokeSubtle, 1.2, 0.15)
    addGradient(LeftCard, UITheme.BgPanelLight, UITheme.BgPanel, 135)

    -- Logo X O khung viền Cyber-Teal
    local LogoWrap = Instance.new("Frame")
    LogoWrap.Size = UDim2.new(0, 136, 0, 66)
    LogoWrap.AnchorPoint = Vector2.new(0.5, 0)
    LogoWrap.Position = UDim2.new(0.5, 0, 0, 30)
    LogoWrap.BackgroundColor3 = UITheme.BgCard
    LogoWrap.BorderSizePixel = 0
    LogoWrap.Parent = LeftCard
    addCorner(LogoWrap, 12)
    addStroke(LogoWrap, UITheme.AccentCyan, 1.6, 0.2)
    addGradient(LogoWrap, Color3.fromRGB(24, 44, 72), UITheme.BgPanel, 90)

    local lx = Instance.new("Frame")
    lx.Size = UDim2.new(0, 36, 0, 36)
    lx.Position = UDim2.new(0, 20, 0.5, -18)
    lx.BackgroundTransparency = 1
    lx.Parent = LogoWrap
    for _, rot in ipairs({ 45, -45 }) do
        local b = Instance.new("Frame")
        b.Size = UDim2.new(1, 0, 0, 6)
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.Position = UDim2.new(0.5, 0, 0.5, 0)
        b.Rotation = rot
        b.BackgroundColor3 = UITheme.ColorX
        b.BorderSizePixel = 0
        b.Parent = lx
        addCorner(b, 3)
    end

    local lo = Instance.new("Frame")
    lo.Size = UDim2.new(0, 32, 0, 32)
    lo.Position = UDim2.new(1, -52, 0.5, -16)
    lo.BackgroundTransparency = 1
    lo.Parent = LogoWrap
    addCorner(lo, 22)
    addStroke(lo, UITheme.AccentCyan, 4.5, 0)

    local HeroTitle = Instance.new("TextLabel")
    HeroTitle.Size = UDim2.new(1, -20, 0, 34)
    HeroTitle.Position = UDim2.new(0, 10, 0, 108)
    HeroTitle.BackgroundTransparency = 1
    HeroTitle.Text = "CỜ CARO"
    HeroTitle.Font = FONT_MAIN
    HeroTitle.TextSize = 26
    HeroTitle.TextColor3 = UITheme.TextPrimary
    HeroTitle.Parent = LeftCard

    -- Đường trang trí mảnh dưới tiêu đề
    local heroLine = Instance.new("Frame")
    heroLine.Size = UDim2.new(0, 64, 0, 2)
    heroLine.AnchorPoint = Vector2.new(0.5, 0)
    heroLine.Position = UDim2.new(0.5, 0, 0, 146)
    heroLine.BackgroundColor3 = UITheme.AccentCyan
    heroLine.BackgroundTransparency = 0.35
    heroLine.BorderSizePixel = 0
    heroLine.Parent = LeftCard
    addCorner(heroLine, 2)

    local PlayAIBtn = Instance.new("TextButton")
    PlayAIBtn.Size = UDim2.new(1, -28, 0, 46)
    PlayAIBtn.Position = UDim2.new(0, 14, 1, -114)
    PlayAIBtn.BackgroundColor3 = Color3.fromRGB(24, 68, 58)
    PlayAIBtn.BorderSizePixel = 0
    PlayAIBtn.AutoButtonColor = false
    PlayAIBtn.Text = "VÀO TRẬN ĐẤU MÁY"
    PlayAIBtn.Font = FONT_MAIN
    PlayAIBtn.TextSize = 14
    PlayAIBtn.TextColor3 = UITheme.ColorGreen
    PlayAIBtn.Parent = LeftCard
    addCorner(PlayAIBtn, 9)
    addStroke(PlayAIBtn, UITheme.ColorGreen, 1.5, 0.2)
    addGradient(PlayAIBtn, Color3.fromRGB(30, 82, 68), Color3.fromRGB(18, 52, 46), 90)
    bindInstantTap(PlayAIBtn, function()
        Config.Mode = "AI"
        sfxClick()
        enterGameScreen()
    end)

    local PlayPVPBtn = Instance.new("TextButton")
    PlayPVPBtn.Size = UDim2.new(1, -28, 0, 42)
    PlayPVPBtn.Position = UDim2.new(0, 14, 1, -58)
    PlayPVPBtn.BackgroundColor3 = UITheme.BgActive
    PlayPVPBtn.BorderSizePixel = 0
    PlayPVPBtn.AutoButtonColor = false
    PlayPVPBtn.Text = "ĐẤU 2 NGƯỜI"
    PlayPVPBtn.Font = FONT_MAIN
    PlayPVPBtn.TextSize = 14
    PlayPVPBtn.TextColor3 = UITheme.AccentCyan
    PlayPVPBtn.Parent = LeftCard
    addCorner(PlayPVPBtn, 9)
    addStroke(PlayPVPBtn, UITheme.AccentCyan, 1.4, 0.2)
    addGradient(PlayPVPBtn, Color3.fromRGB(28, 66, 94), Color3.fromRGB(18, 44, 66), 90)
    bindInstantTap(PlayPVPBtn, function()
        Config.Mode = "PVP"
        sfxClick()
        enterGameScreen()
    end)

    -- CỘT PHẢI
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
    rList.Padding = UDim.new(0, 8)
    rList.Parent = RightCard

    local function makeHomeHeader(text, order)
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

    makeHomeHeader("CHỌN MÀN CHƠI", 1)

    local StageGridHolder = Instance.new("Frame")
    StageGridHolder.LayoutOrder = 2
    StageGridHolder.Size = UDim2.new(1, 0, 0, 108)
    StageGridHolder.BackgroundTransparency = 1
    StageGridHolder.Parent = RightCard

    UI.HomeStageBtns = {}
    for idx, stg in ipairs(STAGES) do
        local col = (idx - 1) % 4
        local row = math.floor((idx - 1) / 4)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0.238, 0, 0, 50)
        card.Position = UDim2.new(col * 0.254, 0, 0, row * 56)
        card.BackgroundColor3 = UITheme.BgCard
        card.BorderSizePixel = 0
        card.AutoButtonColor = false
        card.Text = ""
        card.Parent = StageGridHolder
        addCorner(card, 8)
        local st = addStroke(card, UITheme.StrokeSubtle, 1.2, 0.25)

        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, 0, 0, 24)
        t1.Position = UDim2.new(0, 0, 0, 5)
        t1.BackgroundTransparency = 1
        t1.Text = stg.title
        t1.Font = FONT_MAIN
        t1.TextSize = 13
        t1.TextColor3 = UITheme.TextPrimary
        t1.Parent = card

        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, 0, 0, 16)
        t2.Position = UDim2.new(0, 0, 0, 29)
        t2.BackgroundTransparency = 1
        t2.Text = stg.sub
        t2.Font = FONT_BODY
        t2.TextSize = 10
        t2.TextColor3 = UITheme.TextSecondary
        t2.Parent = card

        local szVal = stg.size
        bindInstantTap(card, function()
            Config.BoardSize = szVal
            sfxClick()
            updateHomeUI()
        end)

        UI.HomeStageBtns[szVal] = { card = card, stroke = st, t1 = t1 }
    end

    makeHomeHeader("ĐỘ KHÓ MÁY", 3)

    local HomeDiffRow = Instance.new("Frame")
    HomeDiffRow.LayoutOrder = 4
    HomeDiffRow.Size = UDim2.new(1, 0, 0, 32)
    HomeDiffRow.BackgroundTransparency = 1
    HomeDiffRow.Parent = RightCard

    UI.HomeDiffBtns = {}
    for idx, d in ipairs({ { key = "Easy", label = "Dễ" }, { key = "Medium", label = "Vừa" }, { key = "Hard", label = "Khó" }, { key = "Master", label = "Siêu Khó" } }) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.238, 0, 1, 0)
        b.Position = UDim2.new((idx - 1) * 0.254, 0, 0, 0)
        b.BackgroundColor3 = UITheme.BgButton
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Text = d.label
        b.Font = FONT_MAIN
        b.TextSize = 12
        b.TextColor3 = UITheme.TextSecondary
        b.Parent = HomeDiffRow
        addCorner(b, 7)
        local st = addStroke(b, UITheme.StrokeSubtle, 1.2, 0.3)
        bindInstantTap(b, function()
            Config.Difficulty = d.key
            sfxClick()
            updateHomeUI()
        end)
        UI.HomeDiffBtns[d.key] = { btn = b, stroke = st }
    end

    makeHomeHeader("GIAO DIỆN BÀN CỜ", 5)

    local HomeThemeRow = Instance.new("Frame")
    HomeThemeRow.LayoutOrder = 6
    HomeThemeRow.Size = UDim2.new(1, 0, 0, 32)
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

    -- Đổi tên thành CHẾ ĐỘ CHƠI + Gộp thời gian chơi thành 1 ô duy nhất
    makeHomeHeader("CHẾ ĐỘ CHƠI", 7)

    local HomeModeRow = Instance.new("Frame")
    HomeModeRow.LayoutOrder = 8
    HomeModeRow.Size = UDim2.new(1, 0, 0, 34)
    HomeModeRow.BackgroundTransparency = 1
    HomeModeRow.Parent = RightCard

    local function makeHomeOptBtn(parent, xScale, wScale, text, onTap)
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
        b.Parent = parent
        addCorner(b, 7)
        local st = addStroke(b, UITheme.StrokeSubtle, 1.2, 0.3)
        bindInstantTap(b, onTap)
        return b, st
    end

    -- 1 ô gộp thời gian: chạm để đổi Không giới hạn -> 15s -> 30s -> 60s
    UI.HomeTimeSingleBtn, UI.HomeTimeSingleStroke = makeHomeOptBtn(HomeModeRow, 0, 0.36, "Thời gian: Không giới hạn", function()
        local curIdx = 1
        for i, v in ipairs(TIME_CYCLE) do
            if v == Config.TurnTimeLimit then curIdx = i; break end
        end
        Config.TurnTimeLimit = TIME_CYCLE[(curIdx % #TIME_CYCLE) + 1]
        sfxClick()
        updateHomeUI()
    end)

    UI.HomeSideBtn, UI.HomeSideStroke = makeHomeOptBtn(HomeModeRow, 0.38, 0.28, "Quân: X", function()
        Config.PlayerSide = (Config.PlayerSide == 1) and 2 or 1
        sfxClick()
        updateHomeUI()
    end)

    UI.HomeRuleBtn, UI.HomeRuleStroke = makeHomeOptBtn(HomeModeRow, 0.68, 0.32, "Chặn 2 đầu: Bật", function()
        Config.BlockTwoEnds = not Config.BlockTwoEnds
        sfxClick()
        updateHomeUI()
    end)
end

-- ========================================================================
-- [PHẦN 07] MÀN HÌNH CHƠI GAME (ĐỒ HỌA CYBER-NAVY + BỘ ICON VECTOR)
-- ========================================================================
local GameScreen = Instance.new("Frame")
GameScreen.Name = "GameScreen"
GameScreen.Size = UDim2.new(1, 0, 1, 0)
GameScreen.BackgroundColor3 = UITheme.BgMain
GameScreen.BorderSizePixel = 0
GameScreen.Visible = false
GameScreen.Parent = Root
addGradient(GameScreen, Color3.fromRGB(12, 21, 38), UITheme.BgMain, 135)
UI.GameScreen = GameScreen

do
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = UITheme.BgPanel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = GameScreen
    addGradient(TopBar, UITheme.BgPanelLight, UITheme.BgPanel, 90)
    addStroke(TopBar, UITheme.StrokeSubtle, 1, 0.25)

    -- Nút icon Home về Sảnh Chính (đồng bộ icon ngôi nhà cyan-teal)
    makeCyberIconBtn(TopBar, 34, UDim2.new(0, 12, 0.5, -17), UITheme.AccentCyan, Icons.drawHome, function()
        sfxClick()
        openHomeScreen()
    end)

    local StageInfoLabel = Instance.new("TextLabel")
    StageInfoLabel.Size = UDim2.new(0, 150, 0, 18)
    StageInfoLabel.Position = UDim2.new(0, 56, 0, 7)
    StageInfoLabel.BackgroundTransparency = 1
    StageInfoLabel.Text = "Màn 15x15"
    StageInfoLabel.Font = FONT_MAIN
    StageInfoLabel.TextSize = 13
    StageInfoLabel.TextColor3 = UITheme.TextPrimary
    StageInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    StageInfoLabel.Parent = TopBar
    UI.StageInfoLabel = StageInfoLabel

    local ClockLabel = Instance.new("TextLabel")
    ClockLabel.Size = UDim2.new(0, 175, 0, 16)
    ClockLabel.Position = UDim2.new(0, 56, 0, 27)
    ClockLabel.BackgroundTransparency = 1
    ClockLabel.Text = "00:00  |  X 0 - 0 O"
    ClockLabel.Font = FONT_BODY
    ClockLabel.TextSize = 11
    ClockLabel.TextColor3 = UITheme.TextSecondary
    ClockLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClockLabel.Parent = TopBar
    UI.ClockLabel = ClockLabel

    local TurnPill = Instance.new("Frame")
    TurnPill.Size = UDim2.new(0, 224, 0, 34)
    TurnPill.AnchorPoint = Vector2.new(0.5, 0.5)
    TurnPill.Position = UDim2.new(0.5, 0, 0.5, 0)
    TurnPill.BackgroundColor3 = UITheme.BgCard
    TurnPill.BorderSizePixel = 0
    TurnPill.ClipsDescendants = true
    TurnPill.Parent = TopBar
    addCorner(TurnPill, 8)
    addGradient(TurnPill, UITheme.BgButton, UITheme.BgPanel, 90)
    UI.TurnStroke = addStroke(TurnPill, UITheme.ColorX, 1.5, 0.15)

    local TurnLabel = Instance.new("TextLabel")
    TurnLabel.Size = UDim2.new(1, -12, 1, -4)
    TurnLabel.Position = UDim2.new(0, 6, 0, 0)
    TurnLabel.BackgroundTransparency = 1
    TurnLabel.Text = "Lượt: X  |  Nước: 0"
    TurnLabel.Font = FONT_MAIN
    TurnLabel.TextSize = 13
    TurnLabel.TextColor3 = UITheme.TextPrimary
    TurnLabel.Parent = TurnPill
    UI.TurnLabel = TurnLabel

    local TimerBarBg = Instance.new("Frame")
    TimerBarBg.Size = UDim2.new(1, 0, 0, 3)
    TimerBarBg.Position = UDim2.new(0, 0, 1, -3)
    TimerBarBg.BackgroundColor3 = UITheme.BgMain
    TimerBarBg.BorderSizePixel = 0
    TimerBarBg.Visible = false
    TimerBarBg.Parent = TurnPill
    UI.TimerBarBg = TimerBarBg

    local TimerBarFill = Instance.new("Frame")
    TimerBarFill.Size = UDim2.new(1, 0, 1, 0)
    TimerBarFill.BackgroundColor3 = UITheme.ColorGold
    TimerBarFill.BorderSizePixel = 0
    TimerBarFill.Parent = TimerBarBg
    UI.TimerBarFill = TimerBarFill

    -- 2 nút icon cyber-teal bên phải: Thu gọn (-) & Đóng (X)
    makeCyberIconBtn(TopBar, 34, UDim2.new(1, -86, 0.5, -17), UITheme.AccentCyan, Icons.drawMinus, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    makeCyberIconBtn(TopBar, 34, UDim2.new(1, -44, 0.5, -17), UITheme.ColorX, Icons.drawCloseX, function()
        if _G.CoCaroProCleanup then _G.CoCaroProCleanup() end
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
AlertStrip.Size = UDim2.new(0, 260, 0, 22)
AlertStrip.AnchorPoint = Vector2.new(0.5, 0)
AlertStrip.Position = UDim2.new(0.5, 0, 0, 6)
AlertStrip.BackgroundColor3 = UITheme.BgPanel
AlertStrip.BackgroundTransparency = 0.08
AlertStrip.BorderSizePixel = 0
AlertStrip.Text = ""
AlertStrip.Font = FONT_MAIN
AlertStrip.TextSize = 11
AlertStrip.TextColor3 = UITheme.ColorGold
AlertStrip.Visible = false
AlertStrip.ZIndex = 25
AlertStrip.Parent = BoardContainer
addCorner(AlertStrip, 6)
addStroke(AlertStrip, UITheme.ColorGold, 1.2, 0.25)
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
BoardScroll.CanvasSize = UDim2.new(0, 500, 0, 500)
BoardScroll.Parent = BoardContainer
UI.BoardScroll = BoardScroll

local BoardFrame = Instance.new("Frame")
BoardFrame.Size = UDim2.new(0, 450, 0, 450)
BoardFrame.BackgroundColor3 = getTheme().BoardBg
BoardFrame.BorderSizePixel = 0
BoardFrame.ClipsDescendants = true
BoardFrame.Parent = BoardScroll
addCorner(BoardFrame, 4)
addStroke(BoardFrame, UITheme.StrokeStrong, 1.5, 0.2)
UI.BoardFrame = BoardFrame

local GridLayer = Instance.new("Frame")
GridLayer.Size = UDim2.new(1, 0, 1, 0)
GridLayer.BackgroundTransparency = 1
GridLayer.ZIndex = 2
GridLayer.Parent = BoardFrame

local HighlightLayer = Instance.new("Frame")
HighlightLayer.Size = UDim2.new(1, 0, 1, 0)
HighlightLayer.BackgroundTransparency = 1
HighlightLayer.ZIndex = 3
HighlightLayer.Parent = BoardFrame

local PiecesLayer = Instance.new("Frame")
PiecesLayer.Size = UDim2.new(1, 0, 1, 0)
PiecesLayer.BackgroundTransparency = 1
PiecesLayer.ZIndex = 5
PiecesLayer.Parent = BoardFrame

local WinLineLayer = Instance.new("Frame")
WinLineLayer.Size = UDim2.new(1, 0, 1, 0)
WinLineLayer.BackgroundTransparency = 1
WinLineLayer.ZIndex = 12
WinLineLayer.Parent = BoardFrame

local InputOverlay = Instance.new("TextButton")
InputOverlay.Size = UDim2.new(1, 0, 1, 0)
InputOverlay.BackgroundTransparency = 1
InputOverlay.Text = ""
InputOverlay.AutoButtonColor = false
InputOverlay.ZIndex = 15
InputOverlay.Parent = BoardFrame

bindInstantTap(InputOverlay, function(screenPos)
    if State.GameOver or State.AIThinking then return end
    if Config.Mode == "AI" and State.CurrentTurn ~= Config.PlayerSide then return end

    local absPos = BoardFrame.AbsolutePosition
    local cs = Config.CellSize
    local c = math.floor((screenPos.X - absPos.X) / cs) + 1
    local r = math.floor((screenPos.Y - absPos.Y) / cs) + 1
    if not inBounds(r, c) or State.Grid[r][c] ~= 0 then return end

    if Config.ConfirmTwoTap then
        if State.PendingCell and State.PendingCell.r == r and State.PendingCell.c == c then
            State.PendingCell = nil
            performMove(r, c)
        else
            State.PendingCell = { r = r, c = c }
            sfxClick()
            refreshBoardVisuals()
        end
    else
        performMove(r, c)
    end
end)

do
    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(0, 304, 0, 152)
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
    BannerTitle.Size = UDim2.new(1, -20, 0, 36)
    BannerTitle.Position = UDim2.new(0, 10, 0, 16)
    BannerTitle.BackgroundTransparency = 1
    BannerTitle.Text = "BẠN ĐÃ THẮNG!"
    BannerTitle.Font = FONT_MAIN
    BannerTitle.TextSize = 20
    BannerTitle.TextColor3 = UITheme.ColorGold
    BannerTitle.ZIndex = 36
    BannerTitle.Parent = Banner
    UI.BannerTitle = BannerTitle

    local BannerSub = Instance.new("TextLabel")
    BannerSub.Size = UDim2.new(1, -20, 0, 36)
    BannerSub.Position = UDim2.new(0, 10, 0, 52)
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
    PlayAgainBtn.Size = UDim2.new(0, 134, 0, 36)
    PlayAgainBtn.Position = UDim2.new(0, 16, 1, -48)
    PlayAgainBtn.BackgroundColor3 = Color3.fromRGB(24, 68, 58)
    PlayAgainBtn.BorderSizePixel = 0
    PlayAgainBtn.AutoButtonColor = false
    PlayAgainBtn.Text = "Chơi ván mới"
    PlayAgainBtn.Font = FONT_MAIN
    PlayAgainBtn.TextSize = 13
    PlayAgainBtn.TextColor3 = UITheme.ColorGreen
    PlayAgainBtn.ZIndex = 36
    PlayAgainBtn.Parent = Banner
    addCorner(PlayAgainBtn, 8)
    addStroke(PlayAgainBtn, UITheme.ColorGreen, 1.3, 0.25)
    bindInstantTap(PlayAgainBtn, function()
        sfxClick()
        startNewGame()
    end)

    local ViewBoardBtn = Instance.new("TextButton")
    ViewBoardBtn.Size = UDim2.new(0, 124, 0, 36)
    ViewBoardBtn.Position = UDim2.new(1, -140, 1, -48)
    ViewBoardBtn.BackgroundColor3 = UITheme.BgButton
    ViewBoardBtn.BorderSizePixel = 0
    ViewBoardBtn.AutoButtonColor = false
    ViewBoardBtn.Text = "Xem bàn cờ"
    ViewBoardBtn.Font = FONT_BODY
    ViewBoardBtn.TextSize = 13
    ViewBoardBtn.TextColor3 = UITheme.TextPrimary
    ViewBoardBtn.ZIndex = 36
    ViewBoardBtn.Parent = Banner
    addCorner(ViewBoardBtn, 8)
    addStroke(ViewBoardBtn, UITheme.StrokeSubtle, 1.2, 0.25)
    bindInstantTap(ViewBoardBtn, function()
        sfxClick()
        hideWinBanner()
    end)
end

-- ========================================================================
-- [PHẦN 08] BẢNG ĐIỀU KHIỂN PHẢI (THAO TÁC NHANH + TIỆN ÍCH + THU PHÓNG)
-- ========================================================================
do
    local SidePanel = Instance.new("ScrollingFrame")
    SidePanel.Name = "SidePanel"
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

    local function makeSectionLabel(text, order)
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

    makeSectionLabel("THAO TÁC NHANH", 1)

    local QuickRow1 = Instance.new("Frame")
    QuickRow1.LayoutOrder = 2
    QuickRow1.Size = UDim2.new(1, 0, 0, 34)
    QuickRow1.BackgroundTransparency = 1
    QuickRow1.Parent = SidePanel

    makeBtn(QuickRow1, "Ván mới", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(24, 68, 58), UITheme.ColorGreen, UITheme.ColorGreen, function()
        sfxClick()
        startNewGame()
    end)

    makeBtn(QuickRow1, "Đi lại", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), UITheme.BgButton, UITheme.AccentCyan, UITheme.StrokeStrong, function()
        sfxClick()
        undoMove()
    end)

    local QuickRow2 = Instance.new("Frame")
    QuickRow2.LayoutOrder = 3
    QuickRow2.Size = UDim2.new(1, 0, 0, 34)
    QuickRow2.BackgroundTransparency = 1
    QuickRow2.Parent = SidePanel

    makeBtn(QuickRow2, "Gợi ý", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(54, 48, 28), UITheme.ColorGold, UITheme.ColorGold, function()
        sfxClick()
        showHint()
    end)

    makeBtn(QuickRow2, "Đầu hàng", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(62, 30, 36), UITheme.ColorX, UITheme.ColorDanger, function()
        sfxClick()
        surrenderGame()
    end)

    makeSectionLabel("TIỆN ÍCH", 4)

    local function makeToggle(order, initText, onTap)
        local b, s = makeBtn(SidePanel, initText, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), UITheme.BgButton, UITheme.TextPrimary, UITheme.StrokeSubtle, onTap)
        b.LayoutOrder = order
        b.TextSize = 11
        return b, s
    end

    UI.TwoTapBtn, UI.TwoTapStroke = makeToggle(5, "2 chạm xác nhận: Tắt", function()
        Config.ConfirmTwoTap = not Config.ConfirmTwoTap
        State.PendingCell = nil
        sfxClick()
        updateControlsUI()
        refreshBoardVisuals()
    end)

    UI.NumBtn, UI.NumStroke = makeToggle(6, "Số thứ tự nước đi: Tắt", function()
        Config.ShowMoveNumbers = not Config.ShowMoveNumbers
        sfxClick()
        updateControlsUI()
        refreshBoardVisuals()
    end)

    UI.SoundBtn, UI.SoundStroke = makeToggle(7, "Âm thanh: Bật", function()
        Config.SoundEnabled = not Config.SoundEnabled
        if Config.SoundEnabled then sfxClick() end
        updateControlsUI()
    end)

    UI.ResetStatsBtn, UI.ResetStatsStroke = makeToggle(8, "Đặt lại thống kê", function()
        local now = os.clock()
        if (now - State.ResetConfirmAt) <= 3.0 then
            State.ResetConfirmAt = 0
            Stats.Wins, Stats.Losses, Stats.Draws, Stats.Streak, Stats.BestStreak, Stats.Xu = 0, 0, 0, 0, 0, 0
            State.SessionX, State.SessionO = 0, 0
            saveStats()
            sfxClick()
            UI.ResetStatsBtn.Text = "Đặt lại thống kê"
            updateTopStatus()
        else
            State.ResetConfirmAt = now
            sfxWarn()
            UI.ResetStatsBtn.Text = "Chạm lần nữa để xóa!"
            task.delay(3.1, function()
                if not State.Destroyed and State.ResetConfirmAt == now then
                    UI.ResetStatsBtn.Text = "Đặt lại thống kê"
                end
            end)
        end
    end)
    UI.ResetStatsBtn.BackgroundColor3 = Color3.fromRGB(54, 28, 34)
    UI.ResetStatsBtn.TextColor3 = UITheme.ColorX
    UI.ResetStatsStroke.Color = UITheme.ColorDanger

    -- Thanh Phóng to / Thu nhỏ ở chỗ trống bên dưới (dùng icon - và + chuẩn cyber-teal)
    makeSectionLabel("PHÓNG TO / THU NHỎ", 9)

    local ZoomRow = Instance.new("Frame")
    ZoomRow.LayoutOrder = 10
    ZoomRow.Size = UDim2.new(1, 0, 0, 34)
    ZoomRow.BackgroundTransparency = 1
    ZoomRow.Parent = SidePanel

    local ZoomOutBtn = makeBtn(ZoomRow, "", UDim2.new(0.28, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BgCard, UITheme.AccentCyan, UITheme.AccentCyan, function()
        Config.CellSize = math.max(16, Config.CellSize - 4)
        sfxClick()
        rebuildBoard(true)
    end)
    Icons.drawMinus(ZoomOutBtn, UITheme.AccentCyan)

    makeBtn(ZoomRow, "Vừa màn", UDim2.new(0.40, 0, 1, 0), UDim2.new(0.30, 0, 0, 0), UITheme.BgActive, UITheme.TextPrimary, UITheme.StrokeStrong, function()
        local availW = math.max(180, BoardScroll.AbsoluteSize.X - 18)
        local availH = math.max(180, BoardScroll.AbsoluteSize.Y - 18)
        local maxFit = (Config.BoardSize <= 3 and 92) or 44
        local minFit = (Config.BoardSize >= 35 and 24) or 20
        local fit = math.floor(math.min(availW, availH) / Config.BoardSize)
        Config.CellSize = math.clamp(fit, minFit, maxFit)
        sfxClick()
        rebuildBoard(false)
    end).TextSize = 11

    local ZoomInBtn = makeBtn(ZoomRow, "", UDim2.new(0.28, 0, 1, 0), UDim2.new(0.72, 0, 0, 0), UITheme.BgCard, UITheme.AccentCyan, UITheme.AccentCyan, function()
        local maxZoom = (Config.BoardSize <= 3) and 96 or 48
        Config.CellSize = math.min(maxZoom, Config.CellSize + 4)
        sfxClick()
        rebuildBoard(true)
    end)
    Icons.drawPlus(ZoomInBtn, UITheme.AccentCyan)
end

-- ========================================================================
-- [PHẦN 09] VẼ BÀN CỜ TỐI ƯU (LƯỚI SIÊU NHẸ CHO ĐẾN 100x100)
-- ========================================================================
local function createPieceNode(r, c, side, animate)
    local th = getTheme()
    local cs = Config.CellSize
    local holder = Instance.new("Frame")
    holder.Name = "P_" .. r .. "_" .. c
    holder.Size = UDim2.new(0, cs, 0, cs)
    holder.Position = UDim2.new(0, (c - 1) * cs, 0, (r - 1) * cs)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 6
    holder.Parent = PiecesLayer

    local targetVisual
    if side == 1 then
        local xWrap = Instance.new("Frame")
        xWrap.Size = UDim2.new(0.68, 0, 0.68, 0)
        xWrap.AnchorPoint = Vector2.new(0.5, 0.5)
        xWrap.Position = UDim2.new(0.5, 0, 0.5, 0)
        xWrap.BackgroundTransparency = 1
        xWrap.ZIndex = 6
        xWrap.Parent = holder

        for _, rot in ipairs({ 45, -45 }) do
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0.95, 0, 0.19, 0)
            bar.AnchorPoint = Vector2.new(0.5, 0.5)
            bar.Position = UDim2.new(0.5, 0, 0.5, 0)
            bar.Rotation = rot
            bar.BackgroundColor3 = th.PieceX
            bar.BorderSizePixel = 0
            bar.ZIndex = 6
            bar.Parent = xWrap
            addCorner(bar, 4)
        end
        targetVisual = xWrap
    else
        local ring = Instance.new("Frame")
        ring.Size = UDim2.new(0.60, 0, 0.60, 0)
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.new(0.5, 0, 0.5, 0)
        ring.BackgroundTransparency = 1
        ring.ZIndex = 6
        ring.Parent = holder
        addCorner(ring, 40)
        addStroke(ring, th.PieceO, math.clamp(cs * 0.085, 2.2, 5), 0)
        targetVisual = ring
    end

    local numLbl = Instance.new("TextLabel")
    numLbl.Size = UDim2.new(1, -2, 0, 10)
    numLbl.Position = UDim2.new(0, 1, 1, -10)
    numLbl.BackgroundTransparency = 1
    numLbl.Text = ""
    numLbl.Font = FONT_BODY
    numLbl.TextSize = 8
    numLbl.TextColor3 = th.NumText
    numLbl.TextXAlignment = Enum.TextXAlignment.Right
    numLbl.Visible = false
    numLbl.ZIndex = 8
    numLbl.Parent = holder

    if animate and targetVisual then
        local finalSize = targetVisual.Size
        targetVisual.Size = UDim2.new(0.24, 0, 0.24, 0)
        TweenService:Create(
            targetVisual,
            TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = finalSize }
        ):Play()
    end

    return { holder = holder, numLbl = numLbl }
end

drawWinLine = function()
    for _, child in ipairs(WinLineLayer:GetChildren()) do child:Destroy() end
    if #State.WinCells < 2 then return end

    local first, last = State.WinCells[1], State.WinCells[#State.WinCells]
    local cs = Config.CellSize
    local x1, y1 = (first[2] - 0.5) * cs, (first[1] - 0.5) * cs
    local x2, y2 = (last[2] - 0.5) * cs, (last[1] - 0.5) * cs
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy) + cs * 0.45

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 0, 0, math.clamp(cs * 0.12, 3.5, 6))
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(0, (x1 + x2) / 2, 0, (y1 + y2) / 2)
    line.Rotation = math.deg(math.atan2(dy, dx))
    line.BackgroundColor3 = getTheme().WinLine
    line.BorderSizePixel = 0
    line.ZIndex = 13
    line.Parent = WinLineLayer
    addCorner(line, 4)

    TweenService:Create(
        line,
        TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, len, 0, line.Size.Y.Offset) }
    ):Play()
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
    BoardContainer.BackgroundColor3 = th.BoardOuter
    BoardFrame.BackgroundColor3 = th.BoardBg

    for _, child in ipairs(GridLayer:GetChildren()) do child:Destroy() end
    for _, child in ipairs(HighlightLayer:GetChildren()) do child:Destroy() end
    for _, child in ipairs(PiecesLayer:GetChildren()) do child:Destroy() end
    for _, child in ipairs(WinLineLayer:GetChildren()) do child:Destroy() end
    UI.PieceNodes = {}

    local n, cs = Config.BoardSize, Config.CellSize
    local totalPx = n * cs

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
        vLine.ZIndex = 2
        vLine.Parent = GridLayer

        local hLine = Instance.new("Frame")
        hLine.Size = UDim2.new(1, 0, 0, 1)
        hLine.Position = UDim2.new(0, 0, 0, i * cs)
        hLine.BackgroundColor3 = th.GridLine
        hLine.BorderSizePixel = 0
        hLine.ZIndex = 2
        hLine.Parent = GridLayer
    end

    if n >= 12 then
        local mid = math.floor((n + 1) / 2)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0, (mid - 0.5) * cs, 0, (mid - 0.5) * cs)
        dot.BackgroundColor3 = th.CenterDot
        dot.BorderSizePixel = 0
        dot.ZIndex = 2
        dot.Parent = GridLayer
        addCorner(dot, 4)
    end

    for _, mv in ipairs(State.History) do
        UI.PieceNodes[cellKey(mv.r, mv.c)] = createPieceNode(mv.r, mv.c, mv.p, false)
    end

    refreshBoardVisuals()
    if State.GameOver and #State.WinCells >= 2 then drawWinLine() end
    if not preserveScroll then centerBoardScroll() end
end

refreshBoardVisuals = function()
    local th, cs = getTheme(), Config.CellSize
    for _, child in ipairs(HighlightLayer:GetChildren()) do child:Destroy() end

    local function placeHighlight(r, c, color, borderStroke)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, cs - 1, 0, cs - 1)
        f.Position = UDim2.new(0, (c - 1) * cs + 1, 0, (r - 1) * cs + 1)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.ZIndex = 3
        f.Parent = HighlightLayer
        if borderStroke then addStroke(f, borderStroke, 1.8, 0.05) end
    end

    if State.HintCell and State.Grid[State.HintCell.r] and State.Grid[State.HintCell.r][State.HintCell.c] == 0 then
        placeHighlight(State.HintCell.r, State.HintCell.c, th.CellHint, UITheme.ColorGreen)
    end
    if State.PendingCell and State.Grid[State.PendingCell.r] and State.Grid[State.PendingCell.r][State.PendingCell.c] == 0 then
        placeHighlight(State.PendingCell.r, State.PendingCell.c, th.CellPending, UITheme.ColorGold)
    end
    local lastMove = State.History[#State.History]
    if lastMove and not State.GameOver then
        placeHighlight(lastMove.r, lastMove.c, th.CellLast, th.WinLine)
    end
    for _, cell in ipairs(State.WinCells) do
        placeHighlight(cell[1], cell[2], th.CellWin, nil)
    end

    for idx, mv in ipairs(State.History) do
        local node = UI.PieceNodes[cellKey(mv.r, mv.c)]
        if node then
            node.numLbl.Text = Config.ShowMoveNumbers and tostring(idx) or ""
            node.numLbl.Visible = Config.ShowMoveNumbers
        end
    end
end

-- ========================================================================
-- [PHẦN 10] CẬP NHẬT SẢNH CHÍNH, TRẠNG THÁI TRONG TRẬN & CHUYỂN MÀN HÌNH
-- ========================================================================
updateHomeUI = function()
    for sz, pack in pairs(UI.HomeStageBtns) do
        local active = (Config.BoardSize == sz)
        pack.card.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgCard
        pack.stroke.Color = active and UITheme.AccentCyan or UITheme.StrokeSubtle
        pack.t1.TextColor3 = active and UITheme.AccentCyan or UITheme.TextPrimary
    end

    for key, pack in pairs(UI.HomeDiffBtns) do
        local active = (Config.Difficulty == key)
        pack.btn.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.ColorGold or UITheme.StrokeSubtle
    end

    for key, pack in pairs(UI.HomeThemeBtns) do
        local active = (Config.ThemeKey == key)
        pack.btn.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.ColorGreen or UITheme.StrokeSubtle
    end

    if Config.TurnTimeLimit == 0 then
        UI.HomeTimeSingleBtn.Text = "Thời gian: Không giới hạn"
        UI.HomeTimeSingleBtn.TextColor3 = UITheme.TextPrimary
        UI.HomeTimeSingleStroke.Color = UITheme.StrokeStrong
    else
        UI.HomeTimeSingleBtn.Text = "Thời gian: " .. Config.TurnTimeLimit .. "s"
        UI.HomeTimeSingleBtn.TextColor3 = UITheme.AccentCyan
        UI.HomeTimeSingleStroke.Color = UITheme.AccentCyan
    end

    UI.HomeSideBtn.Text = (Config.PlayerSide == 1) and "Quân: X" or "Quân: O"
    UI.HomeSideBtn.TextColor3 = (Config.PlayerSide == 1) and UITheme.ColorX or UITheme.AccentCyan
    UI.HomeSideStroke.Color = (Config.PlayerSide == 1) and UITheme.ColorX or UITheme.AccentCyan

    local ruleAllowed = getWinLength(Config.BoardSize) >= 5
    if ruleAllowed then
        UI.HomeRuleBtn.Text = Config.BlockTwoEnds and "Chặn 2 đầu: Bật" or "Chặn 2 đầu: Tắt"
        UI.HomeRuleBtn.TextColor3 = Config.BlockTwoEnds and UITheme.ColorGold or UITheme.TextSecondary
        UI.HomeRuleStroke.Color = Config.BlockTwoEnds and UITheme.ColorGold or UITheme.StrokeSubtle
    else
        UI.HomeRuleBtn.Text = "3x3: Tự do"
        UI.HomeRuleBtn.TextColor3 = UITheme.TextMuted
        UI.HomeRuleStroke.Color = UITheme.StrokeSubtle
    end
end

openHomeScreen = function()
    State.Screen = "HOME"
    State.ActiveMatchId = State.ActiveMatchId + 1
    State.AIThinking = false
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

updateTopStatus = function()
    local moves = #State.History
    UI.StageInfoLabel.Text = string.format("Màn %dx%d", Config.BoardSize, Config.BoardSize)

    if State.GameOver then
        if State.IsDraw then
            UI.TurnLabel.Text = "HÒA CỜ!  |  Nước: " .. moves
            UI.TurnStroke.Color = UITheme.ColorGold
        elseif State.Winner == 1 then
            UI.TurnLabel.Text = "QUÂN X THẮNG!  |  Nước: " .. moves
            UI.TurnStroke.Color = UITheme.ColorX
        else
            UI.TurnLabel.Text = "QUÂN O THẮNG!  |  Nước: " .. moves
            UI.TurnStroke.Color = UITheme.AccentCyan
        end
    elseif State.AIThinking then
        UI.TurnLabel.Text = "Máy đang suy nghĩ...  |  Nước: " .. moves
        UI.TurnStroke.Color = UITheme.ColorGold
    else
        local sym = (State.CurrentTurn == 1) and "X" or "O"
        local timeSuffix = (Config.TurnTimeLimit > 0) and string.format("  |  %ds", math.ceil(State.TurnTimeLeft)) or ("  |  Nước: " .. moves)
        UI.TurnLabel.Text = "Lượt: " .. sym .. timeSuffix
        UI.TurnStroke.Color = (State.CurrentTurn == 1) and UITheme.ColorX or UITheme.AccentCyan
    end

    UI.ClockLabel.Text = string.format("%s  |  X %d - %d O", formatTime(State.MatchElapsed), State.SessionX, State.SessionO)

    if State.ThreatAlert ~= "" and not State.GameOver then
        UI.AlertStrip.Text = State.ThreatAlert
        UI.AlertStrip.Visible = true
    else
        UI.AlertStrip.Visible = false
    end
end

updateControlsUI = function()
    UI.TimerBarBg.Visible = (Config.TurnTimeLimit > 0 and not State.GameOver)

    UI.TwoTapBtn.Text = Config.ConfirmTwoTap and "2 chạm xác nhận: Bật" or "2 chạm xác nhận: Tắt"
    UI.TwoTapBtn.TextColor3 = Config.ConfirmTwoTap and UITheme.ColorGreen or UITheme.TextSecondary
    UI.TwoTapStroke.Color = Config.ConfirmTwoTap and UITheme.ColorGreen or UITheme.StrokeSubtle

    UI.NumBtn.Text = Config.ShowMoveNumbers and "Số thứ tự nước đi: Bật" or "Số thứ tự nước đi: Tắt"
    UI.NumBtn.TextColor3 = Config.ShowMoveNumbers and UITheme.AccentCyan or UITheme.TextSecondary
    UI.NumStroke.Color = Config.ShowMoveNumbers and UITheme.AccentCyan or UITheme.StrokeSubtle

    UI.SoundBtn.Text = Config.SoundEnabled and "Âm thanh: Bật" or "Âm thanh: Tắt"
    UI.SoundBtn.TextColor3 = Config.SoundEnabled and UITheme.AccentCyan or UITheme.TextSecondary
    UI.SoundStroke.Color = Config.SoundEnabled and UITheme.StrokeStrong or UITheme.StrokeSubtle

    -- Vẽ lại icon loa tương ứng bật/tắt trên nút Âm thanh
    local oldIcon = UI.SoundBtn:FindFirstChild("SpeakerIcon")
    if oldIcon then oldIcon:Destroy() end
    Icons.drawSpeaker(UI.SoundBtn, not Config.SoundEnabled, Config.SoundEnabled and UITheme.AccentCyan or UITheme.TextMuted)
end

showWinBanner = function(titleText, subText, accentColor)
    UI.BannerTitle.Text = titleText
    UI.BannerTitle.TextColor3 = accentColor or UITheme.ColorGold
    UI.BannerStroke.Color = accentColor or UITheme.ColorGold
    UI.BannerSub.Text = subText
    UI.WinBanner.Visible = true
end

hideWinBanner = function()
    UI.WinBanner.Visible = false
end

-- ========================================================================
-- [PHẦN 11] LUỒNG NƯỚC ĐI, AI, ĐẦU HÀNG, ĐI LẠI & ĐỒNG HỒ LƯỢT
-- ========================================================================
local function finishMatch(winnerSide, reasonText)
    State.GameOver = true
    State.Winner = winnerSide
    State.ThreatAlert = ""
    UI.TimerBarBg.Visible = false

    if winnerSide == 1 then State.SessionX = State.SessionX + 1
    elseif winnerSide == 2 then State.SessionO = State.SessionO + 1 end

    local titleText, subText, accent
    if Config.Mode == "AI" then
        if winnerSide == Config.PlayerSide then
            local reward = (Config.Difficulty == "Master" and 180)
                or (Config.Difficulty == "Hard" and 100)
                or (Config.Difficulty == "Medium" and 50)
                or 20
            Stats.Wins = Stats.Wins + 1
            Stats.Streak = Stats.Streak + 1
            if Stats.Streak > Stats.BestStreak then Stats.BestStreak = Stats.Streak end
            Stats.Xu = Stats.Xu + reward
            saveStats()
            titleText = "BẠN ĐÃ THẮNG!"
            subText = string.format("+%d Xu  |  Chuỗi thắng: %d", reward, Stats.Streak)
            accent = UITheme.ColorGreen
        else
            Stats.Losses = Stats.Losses + 1
            Stats.Streak = 0
            saveStats()
            titleText = "MÁY ĐÃ THẮNG!"
            subText = reasonText or "Thử lại ván mới hoặc bật Gợi ý nhé"
            accent = UITheme.ColorX
        end
    else
        local sym = (winnerSide == 1) and "QUÂN X" or "QUÂN O"
        titleText = sym .. " THẮNG!"
        subText = reasonText or string.format("Hoàn thành sau %d nước đi", #State.History)
        accent = (winnerSide == 1) and UITheme.ColorX or UITheme.AccentCyan
    end

    refreshBoardVisuals()
    if #State.WinCells >= 2 then drawWinLine() end
    updateTopStatus()
    showWinBanner(titleText, subText, accent)
end

local function triggerAITurn()
    if State.GameOver or State.Destroyed or State.Screen ~= "GAME" or Config.Mode ~= "AI" then return end
    local aiSide = (Config.PlayerSide == 1) and 2 or 1
    if State.CurrentTurn ~= aiSide then return end

    State.AIThinking = true
    updateTopStatus()
    local matchId = State.ActiveMatchId

    task.delay(0.18, function()
        if State.Destroyed or State.GameOver or State.ActiveMatchId ~= matchId then return end
        local r, c = AI.chooseMove(aiSide, Config.Difficulty)
        State.AIThinking = false
        if r and c and State.Grid[r][c] == 0 then
            performMove(r, c)
        else
            updateTopStatus()
        end
    end)
end

performMove = function(r, c)
    if State.GameOver or not inBounds(r, c) or State.Grid[r][c] ~= 0 then return end

    local p = State.CurrentTurn
    State.Grid[r][c] = p
    table.insert(State.History, { r = r, c = c, p = p })
    State.HintCell = nil
    State.PendingCell = nil
    State.TurnTimeLeft = Config.TurnTimeLimit
    UI.TimerBarFill.Size = UDim2.new(1, 0, 1, 0)
    sfxPlace(p)

    UI.PieceNodes[cellKey(r, c)] = createPieceNode(r, c, p, true)

    local winLine = checkWinAt(r, c, p)
    if winLine then
        State.WinCells = winLine
        sfxWin()
        finishMatch(p)
        return
    end

    if isBoardFull() then
        State.GameOver = true
        State.IsDraw = true
        State.ThreatAlert = ""
        UI.TimerBarBg.Visible = false
        if Config.Mode == "AI" then
            Stats.Draws = Stats.Draws + 1
            saveStats()
        end
        refreshBoardVisuals()
        updateTopStatus()
        showWinBanner("HÒA CỜ!", "Bàn cờ đã kín không còn nước đi", UITheme.ColorGold)
        return
    end

    State.ThreatAlert = detectThreatAfterMove(r, c, p)
    if State.ThreatAlert ~= "" then sfxWarn() end

    State.CurrentTurn = (p == 1) and 2 or 1
    refreshBoardVisuals()
    updateTopStatus()

    if Config.Mode == "AI" and State.CurrentTurn ~= Config.PlayerSide then
        triggerAITurn()
    end
end

surrenderGame = function()
    if State.GameOver or State.AIThinking or #State.History == 0 then return end
    local loser = (Config.Mode == "AI") and Config.PlayerSide or State.CurrentTurn
    local winner = (loser == 1) and 2 or 1
    sfxWarn()
    finishMatch(winner, "Đối thủ đã đầu hàng")
end

undoMove = function()
    if State.AIThinking or #State.History == 0 then return end

    local steps = 1
    if Config.Mode == "AI" then
        if not State.GameOver and State.CurrentTurn == Config.PlayerSide and #State.History >= 2 then
            steps = 2
        elseif State.GameOver and State.Winner ~= Config.PlayerSide and #State.History >= 2 then
            steps = 2
        end
    end

    for _ = 1, steps do
        local last = table.remove(State.History)
        if last then
            State.Grid[last.r][last.c] = 0
            State.CurrentTurn = last.p
            local key = cellKey(last.r, last.c)
            if UI.PieceNodes[key] then
                UI.PieceNodes[key].holder:Destroy()
                UI.PieceNodes[key] = nil
            end
        end
    end

    State.GameOver = false
    State.Winner = 0
    State.IsDraw = false
    State.WinCells = {}
    State.HintCell = nil
    State.PendingCell = nil
    State.ThreatAlert = ""
    State.TurnTimeLeft = Config.TurnTimeLimit
    UI.TimerBarFill.Size = UDim2.new(1, 0, 1, 0)
    for _, child in ipairs(WinLineLayer:GetChildren()) do child:Destroy() end
    hideWinBanner()

    refreshBoardVisuals()
    updateControlsUI()
    updateTopStatus()
end

showHint = function()
    if State.GameOver or State.AIThinking then return end
    local r, c = AI.chooseMove(State.CurrentTurn, "Master")
    if r and c then
        State.HintCell = { r = r, c = c }
        refreshBoardVisuals()
    end
end

startNewGame = function(forceRebuild)
    State.ActiveMatchId = State.ActiveMatchId + 1
    State.CurrentTurn = 1
    State.GameOver = false
    State.Winner = 0
    State.IsDraw = false
    State.AIThinking = false
    State.History = {}
    State.WinCells = {}
    State.HintCell = nil
    State.PendingCell = nil
    State.ThreatAlert = ""
    State.MatchElapsed = 0
    State.TurnTimeLeft = Config.TurnTimeLimit
    UI.TimerBarFill.Size = UDim2.new(1, 0, 1, 0)
    hideWinBanner()

    initGrid()

    local availW = math.max(180, BoardScroll.AbsoluteSize.X - 20)
    local availH = math.max(180, BoardScroll.AbsoluteSize.Y - 20)
    if Config.BoardSize <= 3 then
        Config.CellSize = math.clamp(math.floor(math.min(availW, availH) / 3.4), 56, 92)
    elseif Config.BoardSize <= 15 then
        Config.CellSize = math.clamp(math.floor(math.min(availW, availH) / Config.BoardSize), 22, 38)
    else
        Config.CellSize = 26
    end

    rebuildBoard(not forceRebuild)
    updateControlsUI()
    updateTopStatus()

    if Config.Mode == "AI" and Config.PlayerSide == 2 then
        triggerAITurn()
    end
end

task.spawn(function()
    while not State.Destroyed do
        task.wait(0.25)
        if not State.Destroyed and State.Screen == "GAME" and not State.GameOver and not State.Minimized and #State.History > 0 then
            State.MatchElapsed = State.MatchElapsed + 0.25
            if Config.TurnTimeLimit > 0 and not State.AIThinking then
                State.TurnTimeLeft = math.max(0, State.TurnTimeLeft - 0.25)
                local ratio = math.clamp(State.TurnTimeLeft / Config.TurnTimeLimit, 0, 1)
                UI.TimerBarFill.Size = UDim2.new(ratio, 0, 1, 0)
                UI.TimerBarFill.BackgroundColor3 = (ratio <= 0.3) and UITheme.ColorX or UITheme.ColorGold

                if State.TurnTimeLeft <= 0 then
                    local winner = (State.CurrentTurn == 1) and 2 or 1
                    sfxWarn()
                    finishMatch(winner, string.format("Hết %d giây suy nghĩ!", Config.TurnTimeLimit))
                else
                    updateTopStatus()
                end
            else
                UI.ClockLabel.Text = string.format("%s  |  X %d - %d O", formatTime(State.MatchElapsed), State.SessionX, State.SessionO)
            end
        end
    end
end)

-- ========================================================================
-- [PHẦN 12] PHÍM TẮT PC & DỌN DẸP TOÀN BỘ SCRIPT
-- ========================================================================
trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or State.Destroyed then return end
    if State.Screen == "GAME" and Root.Visible then
        if input.KeyCode == Enum.KeyCode.Z then
            undoMove()
        elseif input.KeyCode == Enum.KeyCode.R then
            startNewGame()
        elseif input.KeyCode == Enum.KeyCode.H then
            showHint()
        end
    end
    if input.KeyCode == Enum.KeyCode.M then
        State.Minimized = not State.Minimized
        Root.Visible = not State.Minimized
        FloatBtn.Visible = State.Minimized
    end
end))

_G.CoCaroProCleanup = function()
    State.Destroyed = true
    State.ActiveMatchId = State.ActiveMatchId + 1
    for _, conn in ipairs(UI.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    UI.Connections = {}
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    _G.CoCaroProCleanup = nil
end

openHomeScreen()
