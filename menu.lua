--[[
    ========================================================================
    CỜ CARO PRO - STANDALONE v2.0
    Game Cờ Caro (Gomoku) 2D Toàn Màn Hình cho Roblox Mobile & PC
    Nâng cấp v2.0:
    - 4 chủ đề bàn cờ: Tối Hiện Đại / Gỗ Cổ Điển / Xanh Ngọc / Vở Ô Ly
    - 4 cấp độ AI: Dễ / Vừa / Khó / Siêu Khó (tính thế 2 bước + bắt bẫy 4-3)
    - Tọa độ bàn cờ (A-S, 1-19), đường gạch nối 5 quân thắng, tùy chọn số nước
    - Đồng hồ trận đấu & hẹn giờ mỗi lượt (Tắt / 15s / 30s) kèm thanh tiến trình
    - Bảng điều khiển 2 tab gọn gàng (CHƠI | CÀI ĐẶT), không che bàn cờ
    - Hệ thống Cấp bậc Kỳ thủ, Xu thưởng, Chuỗi thắng & Lưu dữ liệu tự động
    ========================================================================
]]

-- Dọn dẹp phiên bản cũ nếu chạy lại script
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
-- [PHẦN 01] CẤU HÌNH, 4 CHỦ ĐỀ BÀN CỜ MATTE & TRẠNG THÁI GAME
-- ========================================================================
local VERSION = "v2.0"
local SAVE_FILE = "CoCaroPro_Stats_v2.json"

-- Bảng màu giao diện chung (mọi kênh RGB của chữ đều <= 215 để chống chói mobile)
local UITheme = {
    BgMain        = Color3.fromRGB(16, 20, 28),
    BgPanel       = Color3.fromRGB(24, 29, 40),
    BgCard        = Color3.fromRGB(32, 39, 53),
    BgButton      = Color3.fromRGB(39, 47, 63),
    BgActive      = Color3.fromRGB(50, 72, 96),
    StrokeSubtle  = Color3.fromRGB(54, 64, 84),
    StrokeStrong  = Color3.fromRGB(82, 96, 122),

    TextPrimary   = Color3.fromRGB(208, 210, 214),
    TextSecondary = Color3.fromRGB(154, 164, 180),
    TextMuted     = Color3.fromRGB(116, 126, 144),

    ColorX        = Color3.fromRGB(202, 92, 92),
    ColorO        = Color3.fromRGB(84, 172, 196),
    ColorGold     = Color3.fromRGB(202, 166, 84),
    ColorGreen    = Color3.fromRGB(94, 178, 122),
    ColorDanger   = Color3.fromRGB(186, 84, 84),
}

-- 4 Chủ đề bàn cờ (tất cả màu chữ/tọa độ/quân cờ đều matte <= 215)
local BoardThemes = {
    Dark = {
        Name        = "Tối",
        BoardOuter  = Color3.fromRGB(20, 24, 33),
        BoardBg     = Color3.fromRGB(16, 20, 28),
        CellEven    = Color3.fromRGB(34, 41, 54),
        CellOdd     = Color3.fromRGB(30, 36, 48),
        CellBorder  = Color3.fromRGB(46, 55, 72),
        CellLast    = Color3.fromRGB(52, 60, 78),
        CellWin     = Color3.fromRGB(70, 62, 38),
        CellHint    = Color3.fromRGB(44, 68, 56),
        CellPending = Color3.fromRGB(64, 54, 40),
        CoordText   = Color3.fromRGB(134, 144, 162),
        PieceX      = Color3.fromRGB(204, 94, 94),
        PieceO      = Color3.fromRGB(86, 174, 198),
        WinLine     = Color3.fromRGB(206, 172, 86),
        NumText     = Color3.fromRGB(178, 184, 196),
    },
    Wood = {
        Name        = "Gỗ",
        BoardOuter  = Color3.fromRGB(42, 31, 23),
        BoardBg     = Color3.fromRGB(58, 43, 30),
        CellEven    = Color3.fromRGB(148, 118, 84),
        CellOdd     = Color3.fromRGB(140, 110, 77),
        CellBorder  = Color3.fromRGB(98, 74, 48),
        CellLast    = Color3.fromRGB(168, 138, 94),
        CellWin     = Color3.fromRGB(178, 152, 88),
        CellHint    = Color3.fromRGB(116, 142, 98),
        CellPending = Color3.fromRGB(166, 126, 82),
        CoordText   = Color3.fromRGB(192, 168, 134),
        PieceX      = Color3.fromRGB(152, 36, 36),
        PieceO      = Color3.fromRGB(26, 74, 118),
        WinLine     = Color3.fromRGB(196, 154, 52),
        NumText     = Color3.fromRGB(44, 34, 24),
    },
    Emerald = {
        Name        = "Ngọc",
        BoardOuter  = Color3.fromRGB(16, 32, 28),
        BoardBg     = Color3.fromRGB(14, 28, 24),
        CellEven    = Color3.fromRGB(28, 54, 46),
        CellOdd     = Color3.fromRGB(24, 48, 41),
        CellBorder  = Color3.fromRGB(42, 74, 64),
        CellLast    = Color3.fromRGB(44, 78, 66),
        CellWin     = Color3.fromRGB(76, 74, 38),
        CellHint    = Color3.fromRGB(48, 88, 68),
        CellPending = Color3.fromRGB(68, 62, 40),
        CoordText   = Color3.fromRGB(132, 168, 154),
        PieceX      = Color3.fromRGB(204, 102, 96),
        PieceO      = Color3.fromRGB(108, 188, 198),
        WinLine     = Color3.fromRGB(206, 176, 92),
        NumText     = Color3.fromRGB(176, 196, 186),
    },
    Paper = {
        Name        = "Vở Ô Ly",
        BoardOuter  = Color3.fromRGB(156, 152, 142),
        BoardBg     = Color3.fromRGB(170, 166, 156),
        CellEven    = Color3.fromRGB(198, 194, 184),
        CellOdd     = Color3.fromRGB(192, 188, 178),
        CellBorder  = Color3.fromRGB(142, 154, 168),
        CellLast    = Color3.fromRGB(182, 178, 154),
        CellWin     = Color3.fromRGB(196, 182, 128),
        CellHint    = Color3.fromRGB(158, 184, 160),
        CellPending = Color3.fromRGB(194, 172, 144),
        CoordText   = Color3.fromRGB(62, 68, 80),
        PieceX      = Color3.fromRGB(172, 48, 52),
        PieceO      = Color3.fromRGB(36, 92, 154),
        WinLine     = Color3.fromRGB(178, 128, 34),
        NumText     = Color3.fromRGB(54, 60, 72),
    },
}

local THEME_ORDER = { "Dark", "Wood", "Emerald", "Paper" }
local COL_LETTERS = { "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S" }

local FONT_MAIN = Enum.Font.GothamSemibold
local FONT_BODY = Enum.Font.GothamMedium

local Config = {
    BoardSize       = 15,         -- 13, 15, 19
    Mode            = "AI",       -- "AI" hoặc "PVP"
    Difficulty      = "Medium",   -- "Easy", "Medium", "Hard", "Master"
    BlockTwoEnds    = true,       -- Luật chặn 2 đầu (Caro VN)
    PlayerSide      = 1,          -- 1 = X (đi trước), 2 = O (đi sau)
    ThemeKey        = "Dark",     -- "Dark", "Wood", "Emerald", "Paper"
    TurnTimeLimit   = 0,          -- 0 = Tắt, 15 = 15s, 30 = 30s
    ConfirmTwoTap   = false,      -- 2 chạm xác nhận trên mobile
    ShowCoords      = true,       -- Hiện tọa độ A-O, 1-15
    ShowMoveNumbers = false,      -- Hiện số thứ tự trên từng quân cờ
    SoundEnabled    = true,       -- Âm thanh khi đánh cờ
    CellSize        = 30,         -- Kích thước ô (20..44)
}

local State = {
    Grid            = {},
    CurrentTurn     = 1,
    GameOver        = false,
    Winner          = 0,
    IsDraw          = false,
    AIThinking      = false,
    History         = {},         -- { r, c, p }
    WinCells        = {},         -- { {r, c}, ... }
    HintCell        = nil,
    PendingCell     = nil,
    Minimized       = false,
    Destroyed       = false,
    ActiveMatchId   = 0,
    ActiveTab       = "PLAY",     -- "PLAY" | "SETTINGS"
    MatchElapsed    = 0,
    TurnTimeLeft    = 0,
    SessionX        = 0,
    SessionO        = 0,
    ThreatAlert     = "",
    ResetConfirmAt  = 0,
}

local Stats = {
    Wins   = 0,
    Losses = 0,
    Draws  = 0,
    Streak = 0,
    BestStreak = 0,
    Xu     = 0,
}

local UI = {
    Cells = {},
    Connections = {},
}

-- ========================================================================
-- [PHẦN 02] LƯU DỮ LIỆU, CẤP BẬC KỲ THỦ, ÂM THANH & TIỆN ÍCH GUI
-- ========================================================================
local function getTheme()
    return BoardThemes[Config.ThemeKey] or BoardThemes.Dark
end

local function getRankInfo(wins)
    if wins >= 50 then
        return "Huyền Thoại", UITheme.ColorGold
    elseif wins >= 25 then
        return "Đại Kiện Tướng", UITheme.ColorX
    elseif wins >= 12 then
        return "Cao Thủ", UITheme.ColorO
    elseif wins >= 4 then
        return "Kỳ Thủ", UITheme.ColorGreen
    else
        return "Tập Sự", UITheme.TextSecondary
    end
end

local function loadStats()
    if type(isfile) == "function" and type(readfile) == "function" then
        local ok, exists = pcall(isfile, SAVE_FILE)
        if ok and exists then
            local okRead, raw = pcall(readfile, SAVE_FILE)
            if okRead and type(raw) == "string" and #raw > 0 then
                local okDec, data = pcall(function()
                    return HttpService:JSONDecode(raw)
                end)
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
            local payload = {
                Wins       = Stats.Wins,
                Losses     = Stats.Losses,
                Draws      = Stats.Draws,
                Streak     = Stats.Streak,
                BestStreak = Stats.BestStreak,
                Xu         = Stats.Xu,
                ThemeKey   = Config.ThemeKey,
            }
            writefile(SAVE_FILE, HttpService:JSONEncode(payload))
        end)
    end
end

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end
    local okCore = pcall(function()
        return CoreGui.Name
    end)
    if okCore then
        return CoreGui
    end
    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    return CoreGui
end

local function trackConn(conn)
    if conn then
        table.insert(UI.Connections, conn)
    end
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
    s.Color = color or UITheme.StrokeSubtle
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- Cảm ứng tức thì cho mobile & PC (lọc cử chỉ vuốt/cuộn > 14px để không bấm nhầm)
local function bindInstantTap(button, callback)
    local pressPos = nil
    local lastFire = 0

    trackConn(button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressPos = input.Position
        end
    end))

    trackConn(button.InputEnded:Connect(function(input)
        if not pressPos then
            return
        end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local delta = (input.Position - pressPos).Magnitude
            pressPos = nil
            local now = os.clock()
            if delta <= 14 and (now - lastFire) >= 0.08 then
                lastFire = now
                callback()
            end
        end
    end))
end

local SoundFolder = nil
local function playSfx(soundId, volume, pitch)
    if not Config.SoundEnabled or State.Destroyed or not SoundFolder then
        return
    end
    pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = soundId
        snd.Volume = volume or 0.35
        snd.PlaybackSpeed = pitch or 1.0
        snd.Parent = SoundFolder
        snd:Play()
        task.delay(1.2, function()
            if snd and snd.Parent then
                snd:Destroy()
            end
        end)
    end)
end

local function sfxPlace(player)
    playSfx("rbxassetid://421058925", 0.34, (player == 1) and 1.15 or 0.92)
end

local function sfxWin()
    playSfx("rbxassetid://4590662766", 0.45, 1.0)
end

local function sfxWarn()
    playSfx("rbxassetid://421058925", 0.38, 0.72)
end

local function sfxClick()
    playSfx("rbxassetid://421058925", 0.22, 1.35)
end

local function formatTime(sec)
    local s = math.max(0, math.floor(sec))
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end

-- ========================================================================
-- [PHẦN 03] LOGIC BÀN CỜ, KIỂM TRA THẮNG & CẢNH BÁO CHIẾU 4
-- ========================================================================
local DIRS = {
    { 0, 1 },
    { 1, 0 },
    { 1, 1 },
    { 1, -1 },
}

local function inBounds(r, c)
    local n = Config.BoardSize
    return r >= 1 and r <= n and c >= 1 and c <= n
end

local function initGrid()
    local n = Config.BoardSize
    State.Grid = {}
    for r = 1, n do
        local row = {}
        for c = 1, n do
            row[c] = 0
        end
        State.Grid[r] = row
    end
end

-- Kiểm tra nước (r, c) của p có thắng không (trả về danh sách ô thắng đã sắp xếp theo đường thẳng)
local function checkWinAt(r, c, p)
    local grid = State.Grid
    local opp = (p == 1) and 2 or 1

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
        for i = #negCells, 1, -1 do
            table.insert(line, negCells[i])
        end
        table.insert(line, { r, c })
        for i = 1, #posCells do
            table.insert(line, posCells[i])
        end

        local count = #line
        if count >= 5 then
            if Config.BlockTwoEnds then
                if count > 5 or not (blockedPos and blockedNeg) then
                    return line
                end
            else
                return line
            end
        end
    end

    return nil
end

-- Kiểm tra nước vừa đánh có tạo thế nguy hiểm (4 quân mở hoặc 4 quân 1 đầu) không
local function detectThreatAfterMove(r, c, p)
    local grid = State.Grid
    local opp = (p == 1) and 2 or 1
    local open3 = 0
    local open4 = 0
    local half4 = 0

    for _, d in ipairs(DIRS) do
        local dr, dc = d[1], d[2]
        local count = 1
        local openEnds = 0
        local oppBlocks = 0

        local nr, nc = r + dr, c + dc
        while inBounds(nr, nc) and grid[nr][nc] == p do
            count = count + 1
            nr = nr + dr
            nc = nc + dc
        end
        if inBounds(nr, nc) then
            if grid[nr][nc] == 0 then openEnds = openEnds + 1
            elseif grid[nr][nc] == opp then oppBlocks = oppBlocks + 1 end
        end

        local pr, pc = r - dr, c - dc
        while inBounds(pr, pc) and grid[pr][pc] == p do
            count = count + 1
            pr = pr - dr
            pc = pc - dc
        end
        if inBounds(pr, pc) then
            if grid[pr][pc] == 0 then openEnds = openEnds + 1
            elseif grid[pr][pc] == opp then oppBlocks = oppBlocks + 1 end
        end

        if count == 4 then
            if openEnds == 2 then
                open4 = open4 + 1
            elseif openEnds == 1 and (not Config.BlockTwoEnds or oppBlocks == 0) then
                half4 = half4 + 1
            elseif openEnds == 1 then
                half4 = half4 + 1
            end
        elseif count == 3 and openEnds == 2 then
            open3 = open3 + 1
        end
    end

    local sym = (p == 1) and "X" or "O"
    if open4 >= 1 then
        return "NGUY HIỂM: " .. sym .. " tạo 4 thoáng!"
    elseif half4 >= 1 and open3 >= 1 then
        return "THẾ 4-3: " .. sym .. " đang ép thắng!"
    elseif half4 >= 1 then
        return "CHIẾU 4: " .. sym .. " còn 1 nước!"
    elseif open3 >= 2 then
        return "THẾ 3 ĐÔI: " .. sym .. " rất mạnh!"
    end
    return ""
end

local function isBoardFull()
    return #State.History >= (Config.BoardSize * Config.BoardSize)
end

-- ========================================================================
-- [PHẦN 04] AI 4 CẤP ĐỘ (DỄ / VỪA / KHÓ / SIÊU KHÓ)
-- ========================================================================
local AI = {}

function AI.scoreLine(r, c, dr, dc, p)
    local grid = State.Grid
    local opp = (p == 1) and 2 or 1

    local count = 1
    local openEnds = 0
    local blockedByOpp = 0

    local nr, nc = r + dr, c + dc
    while inBounds(nr, nc) and grid[nr][nc] == p do
        count = count + 1
        nr = nr + dr
        nc = nc + dc
    end
    local gapPosCount = 0
    local gapPosOpen = false
    if inBounds(nr, nc) then
        if grid[nr][nc] == 0 then
            openEnds = openEnds + 1
            local gr, gc = nr + dr, nc + dc
            while inBounds(gr, gc) and grid[gr][gc] == p do
                gapPosCount = gapPosCount + 1
                gr = gr + dr
                gc = gc + dc
            end
            if gapPosCount > 0 and inBounds(gr, gc) and grid[gr][gc] == 0 then
                gapPosOpen = true
            end
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
    local gapNegCount = 0
    local gapNegOpen = false
    if inBounds(pr, pc) then
        if grid[pr][pc] == 0 then
            openEnds = openEnds + 1
            local gr, gc = pr - dr, pc - dc
            while inBounds(gr, gc) and grid[gr][gc] == p do
                gapNegCount = gapNegCount + 1
                gr = gr - dr
                gc = gc - dc
            end
            if gapNegCount > 0 and inBounds(gr, gc) and grid[gr][gc] == 0 then
                gapNegOpen = true
            end
        elseif grid[pr][pc] == opp then
            blockedByOpp = blockedByOpp + 1
        end
    end

    if count >= 5 then
        if not Config.BlockTwoEnds or count > 5 or blockedByOpp < 2 then
            return 10000000, "WIN"
        else
            return 60, "BLOCKED5"
        end
    end

    local score = 0
    local tag = "NONE"

    if count == 4 then
        if openEnds == 2 then
            score = 1350000
            tag = "OPEN4"
        elseif openEnds == 1 then
            -- Nếu bị chặn 1 đầu theo luật Chặn 2 đầu, đối phương chỉ cần chặn đầu kia là hết đường,
            -- nhưng vẫn phải chặn ngay nên giá trị vẫn là HALF4 ép buộc
            score = (Config.BlockTwoEnds and blockedByOpp == 1) and 135000 or 165000
            tag = "HALF4"
        end
    elseif count == 3 then
        if openEnds == 2 then
            score = 54000
            tag = "OPEN3"
        elseif openEnds == 1 then
            score = 4800
            tag = "HALF3"
        end
    elseif count == 2 then
        if openEnds == 2 then
            score = 1500
            tag = "OPEN2"
        elseif openEnds == 1 then
            score = 240
        end
    elseif count == 1 then
        if openEnds == 2 then
            score = 65
        elseif openEnds == 1 then
            score = 18
        end
    end

    local bestGap = math.max(gapPosCount, gapNegCount)
    if bestGap > 0 then
        local totalSpan = count + bestGap
        local spanOpen = (bestGap == gapPosCount and gapPosOpen) or (bestGap == gapNegCount and gapNegOpen)
        if totalSpan >= 4 then
            local gapScore = 125000
            if gapScore > score then
                score = gapScore
                tag = "HALF4"
            end
        elseif totalSpan == 3 and openEnds >= 1 and spanOpen then
            local gapScore = 40000
            if gapScore > score then
                score = gapScore
                tag = "OPEN3"
            end
        elseif totalSpan == 2 and openEnds >= 1 and spanOpen then
            score = score + 850
        end
    end

    return score, tag
end

function AI.evaluatePointFor(r, c, p)
    local total = 0
    local half4Count = 0
    local open3Count = 0

    for _, d in ipairs(DIRS) do
        local s, tag = AI.scoreLine(r, c, d[1], d[2], p)
        total = total + s
        if tag == "WIN" then
            return 10000000
        elseif tag == "HALF4" then
            half4Count = half4Count + 1
        elseif tag == "OPEN3" then
            open3Count = open3Count + 1
        end
    end

    if half4Count >= 2 then
        total = total + 1100000
    elseif half4Count >= 1 and open3Count >= 1 then
        total = total + 880000
    elseif open3Count >= 2 then
        total = total + 620000
    end

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

    local mark = {}
    for _, mv in ipairs(State.History) do
        local mr, mc = mv.r, mv.c
        for dr = -2, 2 do
            local r = mr + dr
            if r >= 1 and r <= n then
                for dc = -2, 2 do
                    local c = mc + dc
                    if c >= 1 and c <= n and grid[r][c] == 0 then
                        local key = r * 100 + c
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

    local defWeight = 1.06
    if difficulty == "Easy" then
        defWeight = 0.76
    elseif difficulty == "Hard" then
        defWeight = 1.12
    elseif difficulty == "Master" then
        defWeight = 1.16
    end

    local scored = {}
    for _, cand in ipairs(candidates) do
        local r, c = cand.r, cand.c
        local atk = AI.evaluatePointFor(r, c, side)
        local def = AI.evaluatePointFor(r, c, opp)

        local combined
        if atk >= 10000000 then
            combined = 60000000
        elseif def >= 10000000 then
            if difficulty == "Easy" and math.random() < 0.25 then
                combined = def * 0.4 + atk
            else
                combined = 35000000 + atk
            end
        else
            local dist = math.abs(r - mid) + math.abs(c - mid)
            local centerBonus = math.max(0, (n - dist)) * 7
            combined = atk + def * defWeight + centerBonus
        end

        table.insert(scored, { r = r, c = c, score = combined, atk = atk, def = def })
    end

    table.sort(scored, function(a, b)
        return a.score > b.score
    end)

    if scored[1].score >= 30000000 then
        return scored[1].r, scored[1].c
    end

    if difficulty == "Easy" then
        local pick = scored[math.random(1, math.min(4, #scored))]
        return pick.r, pick.c
    end

    if difficulty == "Medium" then
        local topScore = scored[1].score
        local pool = { scored[1] }
        for i = 2, math.min(3, #scored) do
            if scored[i].score >= topScore * 0.93 then
                table.insert(pool, scored[i])
            end
        end
        local pick = pool[math.random(1, #pool)]
        return pick.r, pick.c
    end

    -- Khó (top 8) & Siêu Khó (top 14, nhìn sâu 2 bước + kiểm tra phản công mạnh nhất)
    local topK = (difficulty == "Master") and math.min(14, #scored) or math.min(8, #scored)
    local checkPool = (difficulty == "Master") and math.min(18, #scored) or math.min(12, #scored)
    local bestMove = scored[1]
    local bestEval = -1e15
    local grid = State.Grid

    for i = 1, topK do
        local mv = scored[i]
        grid[mv.r][mv.c] = side

        local oppBest = 0
        local sideFollowUp = 0
        local sideThreats = 0

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
        if sideThreats >= 2 then
            evalVal = evalVal + 950000
        end
        if oppBest >= 10000000 then
            evalVal = evalVal - 20000000
        elseif oppBest >= 1000000 and mv.atk < 1000000 then
            evalVal = evalVal - 3500000
        end

        if evalVal > bestEval then
            bestEval = evalVal
            bestMove = mv
        end
    end

    return bestMove.r, bestMove.c
end

-- ========================================================================
-- [PHẦN 05] KHỞI TẠO GIAO DIỆN TOÀN MÀN HÌNH & NÚT THU GỌN NỔI
-- ========================================================================
loadStats()

local guiParent = getGuiParent()
do
    local old = guiParent:FindFirstChild("CoCaroPro_Standalone")
    if old then
        pcall(function() old:Destroy() end)
    end
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

-- Nút nổi khi thu gọn (đặt dưới topbar mobile để không bị che)
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
FloatBtn.TextColor3 = UITheme.ColorGold
FloatBtn.Visible = false
FloatBtn.ZIndex = 50
FloatBtn.Parent = ScreenGui
addCorner(FloatBtn, 10)
addStroke(FloatBtn, UITheme.ColorGold, 1.5, 0.25)

do
    local dragging = false
    local dragStart, startPos
    local moved = false

    trackConn(FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = FloatBtn.Position
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

-- Khai báo trước các hàm cốt lõi
local rebuildBoard, refreshBoardVisuals, updateTopStatus, updateControlsUI, switchSideTab
local startNewGame, performMove, undoMove, showHint, surrenderGame, showWinBanner, hideWinBanner, drawWinLine

-- ========================================================================
-- [PHẦN 06] THANH TIÊU ĐỀ (TOP BAR) KÈM ĐỒNG HỒ & THANH ĐẾM NGƯỢC
-- ========================================================================
do
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.BackgroundColor3 = UITheme.BgPanel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Root
    addStroke(TopBar, UITheme.StrokeSubtle, 1, 0.35)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 175, 0, 22)
    TitleLabel.Position = UDim2.new(0, 14, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "CỜ CARO PRO " .. VERSION
    TitleLabel.Font = FONT_MAIN
    TitleLabel.TextSize = 14
    TitleLabel.TextColor3 = UITheme.TextPrimary
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local ClockLabel = Instance.new("TextLabel")
    ClockLabel.Size = UDim2.new(0, 175, 0, 16)
    ClockLabel.Position = UDim2.new(0, 14, 0, 27)
    ClockLabel.BackgroundTransparency = 1
    ClockLabel.Text = "Thời gian: 00:00  |  Tỷ số 0 - 0"
    ClockLabel.Font = FONT_BODY
    ClockLabel.TextSize = 11
    ClockLabel.TextColor3 = UITheme.TextSecondary
    ClockLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClockLabel.Parent = TopBar
    UI.ClockLabel = ClockLabel

    -- Hộp trạng thái lượt ở giữa + thanh tiến trình đếm ngược lượt
    local TurnPill = Instance.new("Frame")
    TurnPill.Size = UDim2.new(0, 240, 0, 34)
    TurnPill.AnchorPoint = Vector2.new(0.5, 0.5)
    TurnPill.Position = UDim2.new(0.5, 0, 0.5, 0)
    TurnPill.BackgroundColor3 = UITheme.BgCard
    TurnPill.BorderSizePixel = 0
    TurnPill.ClipsDescendants = true
    TurnPill.Parent = TopBar
    addCorner(TurnPill, 8)
    UI.TurnStroke = addStroke(TurnPill, UITheme.ColorX, 1.5, 0.15)

    local TurnLabel = Instance.new("TextLabel")
    TurnLabel.Size = UDim2.new(1, -12, 1, -4)
    TurnLabel.Position = UDim2.new(0, 6, 0, 0)
    TurnLabel.BackgroundTransparency = 1
    TurnLabel.Text = "Lượt: X (Bạn)  |  Nước: 0"
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

    -- Cụm nút bên phải TopBar
    local RightGroup = Instance.new("Frame")
    RightGroup.Size = UDim2.new(0, 148, 0, 32)
    RightGroup.AnchorPoint = Vector2.new(1, 0.5)
    RightGroup.Position = UDim2.new(1, -10, 0.5, 0)
    RightGroup.BackgroundTransparency = 1
    RightGroup.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 74, 1, 0)
    MinBtn.BackgroundColor3 = UITheme.BgButton
    MinBtn.BorderSizePixel = 0
    MinBtn.AutoButtonColor = false
    MinBtn.Text = "Thu gọn"
    MinBtn.Font = FONT_BODY
    MinBtn.TextSize = 12
    MinBtn.TextColor3 = UITheme.TextPrimary
    MinBtn.Parent = RightGroup
    addCorner(MinBtn, 7)
    addStroke(MinBtn, UITheme.StrokeSubtle, 1, 0.3)
    bindInstantTap(MinBtn, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 66, 1, 0)
    CloseBtn.Position = UDim2.new(0, 82, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(68, 34, 38)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.AutoButtonColor = false
    CloseBtn.Text = "Đóng"
    CloseBtn.Font = FONT_MAIN
    CloseBtn.TextSize = 12
    CloseBtn.TextColor3 = UITheme.ColorX
    CloseBtn.Parent = RightGroup
    addCorner(CloseBtn, 7)
    addStroke(CloseBtn, UITheme.ColorDanger, 1, 0.35)
    bindInstantTap(CloseBtn, function()
        if _G.CoCaroProCleanup then
            _G.CoCaroProCleanup()
        end
    end)
end

-- ========================================================================
-- [PHẦN 07] KHU VỰC BÀN CỜ (TRÁI) - KHÔNG BỊ CHE BỞI THANH ZOOM
-- ========================================================================
local MainArea = Instance.new("Frame")
MainArea.Name = "MainArea"
MainArea.Size = UDim2.new(1, -16, 1, -56)
MainArea.Position = UDim2.new(0, 8, 0, 52)
MainArea.BackgroundTransparency = 1
MainArea.Parent = Root

local BoardContainer = Instance.new("Frame")
BoardContainer.Name = "BoardContainer"
BoardContainer.Size = UDim2.new(1, -244, 1, 0)
BoardContainer.BackgroundColor3 = getTheme().BoardOuter
BoardContainer.BorderSizePixel = 0
BoardContainer.ClipsDescendants = true
BoardContainer.Parent = MainArea
addCorner(BoardContainer, 10)
addStroke(BoardContainer, UITheme.StrokeSubtle, 1, 0.25)
UI.BoardContainer = BoardContainer

-- Thanh cảnh báo chiếu 4 / thế 3 đôi mỏng ở đỉnh khung bàn cờ (tự ẩn khi không có)
local AlertStrip = Instance.new("TextLabel")
AlertStrip.Name = "AlertStrip"
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
addStroke(AlertStrip, UITheme.ColorGold, 1, 0.3)
UI.AlertStrip = AlertStrip

local BoardScroll = Instance.new("ScrollingFrame")
BoardScroll.Name = "BoardScroll"
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

-- Khung bao gồm cả tọa độ + bàn cờ
local BoardWrap = Instance.new("Frame")
BoardWrap.Name = "BoardWrap"
BoardWrap.Size = UDim2.new(0, 480, 0, 480)
BoardWrap.BackgroundTransparency = 1
BoardWrap.Parent = BoardScroll
UI.BoardWrap = BoardWrap

local BoardFrame = Instance.new("Frame")
BoardFrame.Name = "BoardFrame"
BoardFrame.Size = UDim2.new(0, 450, 0, 450)
BoardFrame.Position = UDim2.new(0, 20, 0, 20)
BoardFrame.BackgroundColor3 = getTheme().BoardBg
BoardFrame.BorderSizePixel = 0
BoardFrame.Parent = BoardWrap
addCorner(BoardFrame, 4)
addStroke(BoardFrame, UITheme.StrokeStrong, 1.5, 0.25)
UI.BoardFrame = BoardFrame

-- Lớp phủ vẽ đường gạch thắng 5 quân
local WinLineLayer = Instance.new("Frame")
WinLineLayer.Name = "WinLineLayer"
WinLineLayer.Size = UDim2.new(1, 0, 1, 0)
WinLineLayer.BackgroundTransparency = 1
WinLineLayer.ZIndex = 12
WinLineLayer.Parent = BoardFrame
UI.WinLineLayer = WinLineLayer

-- Banner kết quả trận đấu
do
    local Banner = Instance.new("Frame")
    Banner.Name = "WinBanner"
    Banner.Size = UDim2.new(0, 304, 0, 152)
    Banner.AnchorPoint = Vector2.new(0.5, 0.5)
    Banner.Position = UDim2.new(0.5, 0, 0.5, 0)
    Banner.BackgroundColor3 = UITheme.BgPanel
    Banner.BorderSizePixel = 0
    Banner.Visible = false
    Banner.ZIndex = 35
    Banner.Parent = BoardContainer
    addCorner(Banner, 12)
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
    BannerSub.Text = "+50 Xu  |  Chuỗi thắng: 1"
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
    PlayAgainBtn.BackgroundColor3 = Color3.fromRGB(40, 72, 56)
    PlayAgainBtn.BorderSizePixel = 0
    PlayAgainBtn.AutoButtonColor = false
    PlayAgainBtn.Text = "Chơi ván mới"
    PlayAgainBtn.Font = FONT_MAIN
    PlayAgainBtn.TextSize = 13
    PlayAgainBtn.TextColor3 = UITheme.ColorGreen
    PlayAgainBtn.ZIndex = 36
    PlayAgainBtn.Parent = Banner
    addCorner(PlayAgainBtn, 8)
    addStroke(PlayAgainBtn, UITheme.ColorGreen, 1, 0.35)
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
    addStroke(ViewBoardBtn, UITheme.StrokeSubtle, 1, 0.3)
    bindInstantTap(ViewBoardBtn, function()
        sfxClick()
        hideWinBanner()
    end)
end

-- ========================================================================
-- [PHẦN 08] BẢNG ĐIỀU KHIỂN 2 TAB (CHƠI | CÀI ĐẶT) - KHÔNG BỊ CẮT NÚT
-- ========================================================================
do
    local SideContainer = Instance.new("Frame")
    SideContainer.Name = "SideContainer"
    SideContainer.Size = UDim2.new(0, 236, 1, 0)
    SideContainer.Position = UDim2.new(1, -236, 0, 0)
    SideContainer.BackgroundColor3 = UITheme.BgPanel
    SideContainer.BorderSizePixel = 0
    SideContainer.Parent = MainArea
    addCorner(SideContainer, 10)
    addStroke(SideContainer, UITheme.StrokeSubtle, 1, 0.25)

    -- Thanh chuyển 2 Tab ở đầu SideContainer
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -16, 0, 32)
    TabBar.Position = UDim2.new(0, 8, 0, 8)
    TabBar.BackgroundColor3 = UITheme.BgMain
    TabBar.BorderSizePixel = 0
    TabBar.Parent = SideContainer
    addCorner(TabBar, 8)

    local function makeTabBtn(text, xScale, tabKey)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.5, -4, 1, -4)
        b.Position = UDim2.new(xScale, 2, 0, 2)
        b.BackgroundColor3 = UITheme.BgActive
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Text = text
        b.Font = FONT_MAIN
        b.TextSize = 12
        b.TextColor3 = UITheme.TextPrimary
        b.Parent = TabBar
        addCorner(b, 6)
        bindInstantTap(b, function()
            sfxClick()
            switchSideTab(tabKey)
        end)
        return b
    end

    UI.TabPlayBtn = makeTabBtn("CHƠI", 0, "PLAY")
    UI.TabSetBtn  = makeTabBtn("CÀI ĐẶT", 0.5, "SETTINGS")

    local function makeTabScroll(name)
        local sf = Instance.new("ScrollingFrame")
        sf.Name = name
        sf.Size = UDim2.new(1, 0, 1, -46)
        sf.Position = UDim2.new(0, 0, 0, 46)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 4
        sf.ScrollBarImageColor3 = UITheme.StrokeStrong
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.Parent = SideContainer

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 2)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = sf

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 7)
        layout.Parent = sf

        return sf
    end

    local PlayPage = makeTabScroll("PlayPage")
    local SettingsPage = makeTabScroll("SettingsPage")
    SettingsPage.Visible = false
    UI.PlayPage = PlayPage
    UI.SettingsPage = SettingsPage

    local function makeSectionLabel(parent, text, order)
        local lbl = Instance.new("TextLabel")
        lbl.LayoutOrder = order
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = FONT_MAIN
        lbl.TextSize = 11
        lbl.TextColor3 = UITheme.TextMuted
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        return lbl
    end

    local function makeBtn(parent, text, size, pos, bgColor, textColor, onTap)
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
        local st = addStroke(btn, UITheme.StrokeSubtle, 1, 0.35)
        bindInstantTap(btn, onTap)
        return btn, st
    end

    -- ==================== TAB 1: CHƠI ====================
    local StatsCard = Instance.new("Frame")
    StatsCard.LayoutOrder = 1
    StatsCard.Size = UDim2.new(1, 0, 0, 76)
    StatsCard.BackgroundColor3 = UITheme.BgCard
    StatsCard.BorderSizePixel = 0
    StatsCard.Parent = PlayPage
    addCorner(StatsCard, 8)
    addStroke(StatsCard, UITheme.StrokeSubtle, 1, 0.35)

    local RankLabel = Instance.new("TextLabel")
    RankLabel.Size = UDim2.new(1, -14, 0, 22)
    RankLabel.Position = UDim2.new(0, 7, 0, 5)
    RankLabel.BackgroundTransparency = 1
    RankLabel.Text = "Cấp bậc: Tập Sự"
    RankLabel.Font = FONT_MAIN
    RankLabel.TextSize = 12
    RankLabel.TextColor3 = UITheme.ColorGold
    RankLabel.Parent = StatsCard
    UI.RankLabel = RankLabel

    local StatsLine1 = Instance.new("TextLabel")
    StatsLine1.Size = UDim2.new(1, -14, 0, 20)
    StatsLine1.Position = UDim2.new(0, 7, 0, 28)
    StatsLine1.BackgroundTransparency = 1
    StatsLine1.Text = "Thắng: 0  |  Thua: 0  |  Hòa: 0"
    StatsLine1.Font = FONT_BODY
    StatsLine1.TextSize = 12
    StatsLine1.TextColor3 = UITheme.TextPrimary
    StatsLine1.Parent = StatsCard
    UI.StatsLine1 = StatsLine1

    local StatsLine2 = Instance.new("TextLabel")
    StatsLine2.Size = UDim2.new(1, -14, 0, 20)
    StatsLine2.Position = UDim2.new(0, 7, 0, 50)
    StatsLine2.BackgroundTransparency = 1
    StatsLine2.Text = "Xu: 0 Xu  |  Chuỗi: 0"
    StatsLine2.Font = FONT_MAIN
    StatsLine2.TextSize = 12
    StatsLine2.TextColor3 = UITheme.ColorGold
    StatsLine2.Parent = StatsCard
    UI.StatsLine2 = StatsLine2

    makeSectionLabel(PlayPage, "THAO TÁC NHANH", 2)

    local QuickRow1 = Instance.new("Frame")
    QuickRow1.LayoutOrder = 3
    QuickRow1.Size = UDim2.new(1, 0, 0, 32)
    QuickRow1.BackgroundTransparency = 1
    QuickRow1.Parent = PlayPage

    makeBtn(QuickRow1, "Ván mới", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(38, 68, 52), UITheme.ColorGreen, function()
        sfxClick()
        startNewGame()
    end)

    makeBtn(QuickRow1, "Đi lại", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), UITheme.BgButton, UITheme.TextPrimary, function()
        sfxClick()
        undoMove()
    end)

    local QuickRow2 = Instance.new("Frame")
    QuickRow2.LayoutOrder = 4
    QuickRow2.Size = UDim2.new(1, 0, 0, 32)
    QuickRow2.BackgroundTransparency = 1
    QuickRow2.Parent = PlayPage

    makeBtn(QuickRow2, "Gợi ý", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(58, 50, 32), UITheme.ColorGold, function()
        sfxClick()
        showHint()
    end)

    makeBtn(QuickRow2, "Đầu hàng", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(64, 34, 38), UITheme.ColorX, function()
        sfxClick()
        surrenderGame()
    end)

    makeSectionLabel(PlayPage, "CHẾ ĐỘ CHƠI", 5)

    local ModeRow = Instance.new("Frame")
    ModeRow.LayoutOrder = 6
    ModeRow.Size = UDim2.new(1, 0, 0, 30)
    ModeRow.BackgroundTransparency = 1
    ModeRow.Parent = PlayPage

    UI.BtnModeAI, UI.StrokeModeAI = makeBtn(ModeRow, "Đấu Máy", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BgActive, UITheme.TextPrimary, function()
        if Config.Mode ~= "AI" then
            Config.Mode = "AI"
            sfxClick()
            startNewGame()
        end
    end)

    UI.BtnModePVP, UI.StrokeModePVP = makeBtn(ModeRow, "2 Người", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), UITheme.BgButton, UITheme.TextSecondary, function()
        if Config.Mode ~= "PVP" then
            Config.Mode = "PVP"
            sfxClick()
            startNewGame()
        end
    end)

    makeSectionLabel(PlayPage, "ĐỘ KHÓ MÁY (AI)", 7)

    local DiffRow1 = Instance.new("Frame")
    DiffRow1.LayoutOrder = 8
    DiffRow1.Size = UDim2.new(1, 0, 0, 28)
    DiffRow1.BackgroundTransparency = 1
    DiffRow1.Parent = PlayPage

    local DiffRow2 = Instance.new("Frame")
    DiffRow2.LayoutOrder = 9
    DiffRow2.Size = UDim2.new(1, 0, 0, 28)
    DiffRow2.BackgroundTransparency = 1
    DiffRow2.Parent = PlayPage

    UI.DiffBtns = {}
    local diffList = {
        { key = "Easy",   label = "Dễ (+20)",        row = DiffRow1, x = 0 },
        { key = "Medium", label = "Vừa (+50)",       row = DiffRow1, x = 0.52 },
        { key = "Hard",   label = "Khó (+100)",      row = DiffRow2, x = 0 },
        { key = "Master", label = "Siêu Khó (+180)", row = DiffRow2, x = 0.52 },
    }
    for _, d in ipairs(diffList) do
        local btn, st = makeBtn(d.row, d.label, UDim2.new(0.48, 0, 1, 0), UDim2.new(d.x, 0, 0, 0), UITheme.BgButton, UITheme.TextSecondary, function()
            Config.Difficulty = d.key
            sfxClick()
            updateControlsUI()
        end)
        btn.TextSize = 11
        UI.DiffBtns[d.key] = { btn = btn, stroke = st }
    end

    -- Thanh thu phóng bàn cờ đặt gọn trong bảng điều khiển (không bao giờ đè lên bàn cờ)
    makeSectionLabel(PlayPage, "THU PHÓNG BÀN CỜ", 10)

    local ZoomRow = Instance.new("Frame")
    ZoomRow.LayoutOrder = 11
    ZoomRow.Size = UDim2.new(1, 0, 0, 28)
    ZoomRow.BackgroundTransparency = 1
    ZoomRow.Parent = PlayPage

    makeBtn(ZoomRow, "Thu nhỏ (-)", UDim2.new(0.32, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BgButton, UITheme.TextPrimary, function()
        Config.CellSize = math.max(20, Config.CellSize - 4)
        sfxClick()
        rebuildBoard(true)
    end).TextSize = 11

    makeBtn(ZoomRow, "Vừa màn", UDim2.new(0.32, 0, 1, 0), UDim2.new(0.34, 0, 0, 0), UITheme.BgButton, UITheme.ColorO, function()
        local coordPad = Config.ShowCoords and 24 or 4
        local availW = math.max(180, BoardScroll.AbsoluteSize.X - coordPad - 16)
        local availH = math.max(180, BoardScroll.AbsoluteSize.Y - coordPad - 16)
        local fit = math.floor(math.min(availW, availH) / Config.BoardSize)
        Config.CellSize = math.clamp(fit, 20, 44)
        sfxClick()
        rebuildBoard(false)
    end).TextSize = 11

    makeBtn(ZoomRow, "Phóng (+)", UDim2.new(0.32, 0, 1, 0), UDim2.new(0.68, 0, 0, 0), UITheme.BgButton, UITheme.TextPrimary, function()
        Config.CellSize = math.min(44, Config.CellSize + 4)
        sfxClick()
        rebuildBoard(true)
    end).TextSize = 11

    -- ==================== TAB 2: CÀI ĐẶT ====================
    makeSectionLabel(SettingsPage, "GIAO DIỆN BÀN CỜ", 1)

    local ThemeRow1 = Instance.new("Frame")
    ThemeRow1.LayoutOrder = 2
    ThemeRow1.Size = UDim2.new(1, 0, 0, 28)
    ThemeRow1.BackgroundTransparency = 1
    ThemeRow1.Parent = SettingsPage

    local ThemeRow2 = Instance.new("Frame")
    ThemeRow2.LayoutOrder = 3
    ThemeRow2.Size = UDim2.new(1, 0, 0, 28)
    ThemeRow2.BackgroundTransparency = 1
    ThemeRow2.Parent = SettingsPage

    UI.ThemeBtns = {}
    for idx, key in ipairs(THEME_ORDER) do
        local row = (idx <= 2) and ThemeRow1 or ThemeRow2
        local xScale = ((idx - 1) % 2 == 0) and 0 or 0.52
        local btn, st = makeBtn(row, BoardThemes[key].Name, UDim2.new(0.48, 0, 1, 0), UDim2.new(xScale, 0, 0, 0), UITheme.BgButton, UITheme.TextSecondary, function()
            Config.ThemeKey = key
            saveStats()
            sfxClick()
            updateControlsUI()
            rebuildBoard(true)
        end)
        UI.ThemeBtns[key] = { btn = btn, stroke = st }
    end

    makeSectionLabel(SettingsPage, "QUÂN CỦA BẠN (ĐẤU MÁY)", 4)

    local SideRow = Instance.new("Frame")
    SideRow.LayoutOrder = 5
    SideRow.Size = UDim2.new(1, 0, 0, 28)
    SideRow.BackgroundTransparency = 1
    SideRow.Parent = SettingsPage

    UI.BtnSideX, UI.StrokeSideX = makeBtn(SideRow, "Quân X (Trước)", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), UITheme.BgActive, UITheme.ColorX, function()
        if Config.PlayerSide ~= 1 then
            Config.PlayerSide = 1
            sfxClick()
            startNewGame()
        end
    end)
    UI.BtnSideX.TextSize = 11

    UI.BtnSideO, UI.StrokeSideO = makeBtn(SideRow, "Quân O (Sau)", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), UITheme.BgButton, UITheme.ColorO, function()
        if Config.PlayerSide ~= 2 then
            Config.PlayerSide = 2
            sfxClick()
            startNewGame()
        end
    end)
    UI.BtnSideO.TextSize = 11

    makeSectionLabel(SettingsPage, "KÍCH THƯỚC BÀN CỜ", 6)

    local SizeRow = Instance.new("Frame")
    SizeRow.LayoutOrder = 7
    SizeRow.Size = UDim2.new(1, 0, 0, 28)
    SizeRow.BackgroundTransparency = 1
    SizeRow.Parent = SettingsPage

    UI.SizeBtns = {}
    for idx, sz in ipairs({ 13, 15, 19 }) do
        local btn, st = makeBtn(SizeRow, sz .. "x" .. sz, UDim2.new(0.31, 0, 1, 0), UDim2.new((idx - 1) * 0.345, 0, 0, 0), UITheme.BgButton, UITheme.TextSecondary, function()
            if Config.BoardSize ~= sz then
                Config.BoardSize = sz
                sfxClick()
                startNewGame(true)
            end
        end)
        UI.SizeBtns[sz] = { btn = btn, stroke = st }
    end

    makeSectionLabel(SettingsPage, "GIỚI HẠN MỖI LƯỢT", 8)

    local TimeRow = Instance.new("Frame")
    TimeRow.LayoutOrder = 9
    TimeRow.Size = UDim2.new(1, 0, 0, 28)
    TimeRow.BackgroundTransparency = 1
    TimeRow.Parent = SettingsPage

    UI.TimeBtns = {}
    local timeOpts = {
        { val = 0,  label = "Tắt" },
        { val = 15, label = "15 giây" },
        { val = 30, label = "30 giây" },
    }
    for idx, t in ipairs(timeOpts) do
        local btn, st = makeBtn(TimeRow, t.label, UDim2.new(0.31, 0, 1, 0), UDim2.new((idx - 1) * 0.345, 0, 0, 0), UITheme.BgButton, UITheme.TextSecondary, function()
            Config.TurnTimeLimit = t.val
            State.TurnTimeLeft = t.val
            sfxClick()
            updateControlsUI()
        end)
        btn.TextSize = 11
        UI.TimeBtns[t.val] = { btn = btn, stroke = st }
    end

    makeSectionLabel(SettingsPage, "LUẬT & TIỆN ÍCH", 10)

    local function makeToggle(order, initText, onTap)
        local b, s = makeBtn(SettingsPage, initText, UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 0), UITheme.BgButton, UITheme.TextPrimary, onTap)
        b.LayoutOrder = order
        b.TextSize = 11
        return b, s
    end

    UI.RuleBtn, UI.RuleStroke = makeToggle(11, "Luật: Chặn 2 đầu (VN)", function()
        Config.BlockTwoEnds = not Config.BlockTwoEnds
        sfxClick()
        updateControlsUI()
    end)

    UI.TwoTapBtn, UI.TwoTapStroke = makeToggle(12, "2 chạm xác nhận: Tắt", function()
        Config.ConfirmTwoTap = not Config.ConfirmTwoTap
        State.PendingCell = nil
        sfxClick()
        updateControlsUI()
        refreshBoardVisuals()
    end)

    UI.CoordsBtn, UI.CoordsStroke = makeToggle(13, "Tọa độ (A-O / 1-15): Bật", function()
        Config.ShowCoords = not Config.ShowCoords
        sfxClick()
        updateControlsUI()
        rebuildBoard(true)
    end)

    UI.NumBtn, UI.NumStroke = makeToggle(14, "Số thứ tự nước đi: Tắt", function()
        Config.ShowMoveNumbers = not Config.ShowMoveNumbers
        sfxClick()
        updateControlsUI()
        refreshBoardVisuals()
    end)

    UI.SoundBtn, UI.SoundStroke = makeToggle(15, "Âm thanh: Bật", function()
        Config.SoundEnabled = not Config.SoundEnabled
        if Config.SoundEnabled then sfxClick() end
        updateControlsUI()
    end)

    UI.ResetStatsBtn, UI.ResetStatsStroke = makeToggle(16, "Đặt lại thống kê", function()
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
    UI.ResetStatsBtn.BackgroundColor3 = Color3.fromRGB(56, 32, 36)
    UI.ResetStatsBtn.TextColor3 = UITheme.ColorX
end

switchSideTab = function(tabKey)
    State.ActiveTab = tabKey
    local isPlay = (tabKey == "PLAY")
    UI.PlayPage.Visible = isPlay
    UI.SettingsPage.Visible = not isPlay

    UI.TabPlayBtn.BackgroundColor3 = isPlay and UITheme.BgActive or UITheme.BgMain
    UI.TabPlayBtn.TextColor3 = isPlay and UITheme.TextPrimary or UITheme.TextSecondary

    UI.TabSetBtn.BackgroundColor3 = (not isPlay) and UITheme.BgActive or UITheme.BgMain
    UI.TabSetBtn.TextColor3 = (not isPlay) and UITheme.TextPrimary or UITheme.TextSecondary
end

-- ========================================================================
-- [PHẦN 09] VẼ QUÂN CỜ VECTOR, TỌA ĐỘ, ĐƯỜNG THẮNG & XÂY DỰNG BÀN CỜ
-- ========================================================================
local function createPieceX(parent, color)
    local holder = Instance.new("Frame")
    holder.Name = "PieceX"
    holder.Size = UDim2.new(0.70, 0, 0.70, 0)
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.BackgroundTransparency = 1
    holder.Visible = false
    holder.ZIndex = 4
    holder.Parent = parent

    local bar1 = Instance.new("Frame")
    bar1.Size = UDim2.new(0.95, 0, 0.19, 0)
    bar1.AnchorPoint = Vector2.new(0.5, 0.5)
    bar1.Position = UDim2.new(0.5, 0, 0.5, 0)
    bar1.Rotation = 45
    bar1.BackgroundColor3 = color
    bar1.BorderSizePixel = 0
    bar1.ZIndex = 4
    bar1.Parent = holder
    addCorner(bar1, 4)

    local bar2 = Instance.new("Frame")
    bar2.Size = UDim2.new(0.95, 0, 0.19, 0)
    bar2.AnchorPoint = Vector2.new(0.5, 0.5)
    bar2.Position = UDim2.new(0.5, 0, 0.5, 0)
    bar2.Rotation = -45
    bar2.BackgroundColor3 = color
    bar2.BorderSizePixel = 0
    bar2.ZIndex = 4
    bar2.Parent = holder
    addCorner(bar2, 4)

    return holder
end

local function createPieceO(parent, color)
    local ring = Instance.new("Frame")
    ring.Name = "PieceO"
    ring.Size = UDim2.new(0.62, 0, 0.62, 0)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.BackgroundTransparency = 1
    ring.Visible = false
    ring.ZIndex = 4
    ring.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = ring

    local st = Instance.new("UIStroke")
    st.Color = color
    st.Thickness = 2.6
    st.Parent = ring

    return ring
end

drawWinLine = function()
    for _, child in ipairs(WinLineLayer:GetChildren()) do
        child:Destroy()
    end
    if #State.WinCells < 2 then
        return
    end
    local first = State.WinCells[1]
    local last = State.WinCells[#State.WinCells]
    local cs = Config.CellSize

    local x1 = (first[2] - 0.5) * cs
    local y1 = (first[1] - 0.5) * cs
    local x2 = (last[2] - 0.5) * cs
    local y2 = (last[1] - 0.5) * cs

    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy) + cs * 0.45
    local angle = math.deg(math.atan2(dy, dx))

    local line = Instance.new("Frame")
    line.Name = "WinStrike"
    line.Size = UDim2.new(0, 0, 0, 4)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(0, (x1 + x2) / 2, 0, (y1 + y2) / 2)
    line.Rotation = angle
    line.BackgroundColor3 = getTheme().WinLine
    line.BorderSizePixel = 0
    line.ZIndex = 13
    line.Parent = WinLineLayer
    addCorner(line, 4)

    TweenService:Create(
        line,
        TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, len, 0, 4) }
    ):Play()
end

local function centerBoardScroll()
    task.defer(function()
        if State.Destroyed then return end
        local cw = BoardScroll.CanvasSize.X.Offset
        local ch = BoardScroll.CanvasSize.Y.Offset
        local vw = BoardScroll.AbsoluteSize.X
        local vh = BoardScroll.AbsoluteSize.Y
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

    -- Xóa tọa độ cũ & ô cũ
    for _, child in ipairs(BoardWrap:GetChildren()) do
        if child ~= BoardFrame then
            child:Destroy()
        end
    end
    for _, child in ipairs(BoardFrame:GetChildren()) do
        if child ~= WinLineLayer then
            child:Destroy()
        end
    end
    for _, child in ipairs(WinLineLayer:GetChildren()) do
        child:Destroy()
    end
    UI.Cells = {}

    local n = Config.BoardSize
    local cs = Config.CellSize
    local totalPx = n * cs
    local coordOffset = Config.ShowCoords and 20 or 0

    BoardWrap.Size = UDim2.new(0, totalPx + coordOffset, 0, totalPx + coordOffset)
    BoardFrame.Size = UDim2.new(0, totalPx, 0, totalPx)
    BoardFrame.Position = UDim2.new(0, coordOffset, 0, coordOffset)

    local vw = math.max(180, BoardScroll.AbsoluteSize.X)
    local vh = math.max(180, BoardScroll.AbsoluteSize.Y)
    local padX = math.max(12, math.floor((vw - (totalPx + coordOffset)) / 2))
    local padY = math.max(12, math.floor((vh - (totalPx + coordOffset)) / 2))

    BoardWrap.Position = UDim2.new(0, padX, 0, padY)
    BoardScroll.CanvasSize = UDim2.new(0, totalPx + coordOffset + padX * 2, 0, totalPx + coordOffset + padY * 2)

    -- Vẽ nhãn tọa độ A-S & 1-19
    if Config.ShowCoords then
        for i = 1, n do
            local colLbl = Instance.new("TextLabel")
            colLbl.Size = UDim2.new(0, cs, 0, 18)
            colLbl.Position = UDim2.new(0, coordOffset + (i - 1) * cs, 0, 0)
            colLbl.BackgroundTransparency = 1
            colLbl.Text = COL_LETTERS[i] or tostring(i)
            colLbl.Font = FONT_BODY
            colLbl.TextSize = 10
            colLbl.TextColor3 = th.CoordText
            colLbl.Parent = BoardWrap

            local rowLbl = Instance.new("TextLabel")
            rowLbl.Size = UDim2.new(0, 18, 0, cs)
            rowLbl.Position = UDim2.new(0, 0, 0, coordOffset + (i - 1) * cs)
            rowLbl.BackgroundTransparency = 1
            rowLbl.Text = tostring(i)
            rowLbl.Font = FONT_BODY
            rowLbl.TextSize = 10
            rowLbl.TextColor3 = th.CoordText
            rowLbl.Parent = BoardWrap
        end
    end

    local mid = math.floor((n + 1) / 2)

    for r = 1, n do
        UI.Cells[r] = {}
        for c = 1, n do
            local btn = Instance.new("TextButton")
            btn.Name = "C_" .. r .. "_" .. c
            btn.Size = UDim2.new(0, cs, 0, cs)
            btn.Position = UDim2.new(0, (c - 1) * cs, 0, (r - 1) * cs)
            btn.BackgroundColor3 = ((r + c) % 2 == 0) and th.CellEven or th.CellOdd
            btn.BorderColor3 = th.CellBorder
            btn.BorderSizePixel = 1
            btn.AutoButtonColor = false
            btn.Text = ""
            btn.ZIndex = 2
            btn.Parent = BoardFrame

            local centerDot = nil
            if r == mid and c == mid then
                centerDot = Instance.new("Frame")
                centerDot.Size = UDim2.new(0, 5, 0, 5)
                centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
                centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
                centerDot.BackgroundColor3 = th.CoordText
                centerDot.BorderSizePixel = 0
                centerDot.ZIndex = 3
                centerDot.Parent = btn
                addCorner(centerDot, 4)
            end

            -- Khung viền đánh dấu nước vừa đi (gọn gàng không đè lên vòng O)
            local lastFrame = Instance.new("Frame")
            lastFrame.Size = UDim2.new(1, -2, 1, -2)
            lastFrame.Position = UDim2.new(0, 1, 0, 1)
            lastFrame.BackgroundTransparency = 1
            lastFrame.Visible = false
            lastFrame.ZIndex = 6
            lastFrame.Parent = btn
            addStroke(lastFrame, th.WinLine, 1.8, 0.05)

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
            numLbl.ZIndex = 7
            numLbl.Parent = btn

            local pieceX = createPieceX(btn, th.PieceX)
            local pieceO = createPieceO(btn, th.PieceO)

            UI.Cells[r][c] = {
                btn = btn,
                pieceX = pieceX,
                pieceO = pieceO,
                lastFrame = lastFrame,
                numLbl = numLbl,
                centerDot = centerDot,
            }

            local rowIdx, colIdx = r, c
            bindInstantTap(btn, function()
                if State.GameOver or State.AIThinking then return end
                if Config.Mode == "AI" and State.CurrentTurn ~= Config.PlayerSide then return end
                if State.Grid[rowIdx][colIdx] ~= 0 then return end

                if Config.ConfirmTwoTap then
                    if State.PendingCell and State.PendingCell.r == rowIdx and State.PendingCell.c == colIdx then
                        State.PendingCell = nil
                        performMove(rowIdx, colIdx)
                    else
                        State.PendingCell = { r = rowIdx, c = colIdx }
                        sfxClick()
                        refreshBoardVisuals()
                    end
                else
                    performMove(rowIdx, colIdx)
                end
            end)
        end
    end

    refreshBoardVisuals()
    if State.GameOver and #State.WinCells >= 5 then
        drawWinLine()
    end
    if not preserveScroll then
        centerBoardScroll()
    end
end

-- ========================================================================
-- [PHẦN 10] CẬP NHẬT GIAO DIỆN, TRẠNG THÁI & BỘ ĐẾM THỜI GIAN
-- ========================================================================
refreshBoardVisuals = function()
    local th = getTheme()
    local n = Config.BoardSize
    local lastMove = State.History[#State.History]

    local winMap = {}
    for _, cell in ipairs(State.WinCells) do
        winMap[cell[1] * 100 + cell[2]] = true
    end

    local moveNumMap = {}
    if Config.ShowMoveNumbers then
        for idx, mv in ipairs(State.History) do
            moveNumMap[mv.r * 100 + mv.c] = idx
        end
    end

    for r = 1, n do
        local rowUI = UI.Cells[r]
        local rowGrid = State.Grid[r]
        if rowUI and rowGrid then
            for c = 1, n do
                local cell = rowUI[c]
                local val = rowGrid[c]
                local key = r * 100 + c
                local isLast = lastMove and lastMove.r == r and lastMove.c == c
                local isWin = winMap[key] == true
                local isHint = State.HintCell and State.HintCell.r == r and State.HintCell.c == c and val == 0
                local isPending = State.PendingCell and State.PendingCell.r == r and State.PendingCell.c == c and val == 0

                cell.pieceX.Visible = (val == 1)
                cell.pieceO.Visible = (val == 2)
                cell.lastFrame.Visible = isLast and not isWin

                if cell.centerDot then
                    cell.centerDot.Visible = (val == 0)
                end

                local mNum = moveNumMap[key]
                if mNum then
                    cell.numLbl.Text = tostring(mNum)
                    cell.numLbl.Visible = true
                else
                    cell.numLbl.Visible = false
                end

                if isWin then
                    cell.btn.BackgroundColor3 = th.CellWin
                elseif isPending then
                    cell.btn.BackgroundColor3 = th.CellPending
                elseif isHint then
                    cell.btn.BackgroundColor3 = th.CellHint
                elseif isLast then
                    cell.btn.BackgroundColor3 = th.CellLast
                else
                    cell.btn.BackgroundColor3 = ((r + c) % 2 == 0) and th.CellEven or th.CellOdd
                end
            end
        end
    end
end

updateTopStatus = function()
    local moves = #State.History
    if State.GameOver then
        if State.IsDraw then
            UI.TurnLabel.Text = "HÒA CỜ!  |  Nước: " .. moves
            UI.TurnStroke.Color = UITheme.ColorGold
        elseif State.Winner == 1 then
            UI.TurnLabel.Text = "QUÂN X THẮNG!  |  Nước: " .. moves
            UI.TurnStroke.Color = UITheme.ColorX
        else
            UI.TurnLabel.Text = "QUÂN O THẮNG!  |  Nước: " .. moves
            UI.TurnStroke.Color = UITheme.ColorO
        end
    elseif State.AIThinking then
        UI.TurnLabel.Text = "Máy đang suy nghĩ...  |  Nước: " .. moves
        UI.TurnStroke.Color = UITheme.ColorGold
    else
        local who
        if Config.Mode == "AI" then
            who = (State.CurrentTurn == Config.PlayerSide) and "Bạn" or "Máy"
        else
            who = (State.CurrentTurn == 1) and "Người 1" or "Người 2"
        end
        local sym = (State.CurrentTurn == 1) and "X" or "O"
        local timeSuffix = (Config.TurnTimeLimit > 0) and string.format("  |  %ds", math.ceil(State.TurnTimeLeft)) or ("  |  Nước: " .. moves)
        UI.TurnLabel.Text = "Lượt: " .. sym .. " (" .. who .. ")" .. timeSuffix
        UI.TurnStroke.Color = (State.CurrentTurn == 1) and UITheme.ColorX or UITheme.ColorO
    end

    UI.ClockLabel.Text = string.format("Thời gian: %s  |  Tỷ số X %d - %d O", formatTime(State.MatchElapsed), State.SessionX, State.SessionO)

    local rankName, rankColor = getRankInfo(Stats.Wins)
    UI.RankLabel.Text = "Cấp bậc: " .. rankName
    UI.RankLabel.TextColor3 = rankColor
    UI.StatsLine1.Text = string.format("Thắng: %d  |  Thua: %d  |  Hòa: %d", Stats.Wins, Stats.Losses, Stats.Draws)
    UI.StatsLine2.Text = string.format("Xu: %d Xu  |  Chuỗi: %d", Stats.Xu, Stats.Streak)

    if State.ThreatAlert ~= "" and not State.GameOver then
        UI.AlertStrip.Text = State.ThreatAlert
        UI.AlertStrip.Visible = true
    else
        UI.AlertStrip.Visible = false
    end
end

updateControlsUI = function()
    local isAI = (Config.Mode == "AI")
    UI.BtnModeAI.BackgroundColor3 = isAI and UITheme.BgActive or UITheme.BgButton
    UI.BtnModeAI.TextColor3 = isAI and UITheme.TextPrimary or UITheme.TextSecondary
    UI.StrokeModeAI.Color = isAI and UITheme.ColorO or UITheme.StrokeSubtle

    UI.BtnModePVP.BackgroundColor3 = (not isAI) and UITheme.BgActive or UITheme.BgButton
    UI.BtnModePVP.TextColor3 = (not isAI) and UITheme.TextPrimary or UITheme.TextSecondary
    UI.StrokeModePVP.Color = (not isAI) and UITheme.ColorO or UITheme.StrokeSubtle

    for key, pack in pairs(UI.DiffBtns) do
        local active = (Config.Difficulty == key)
        pack.btn.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.ColorGold or UITheme.StrokeSubtle
    end

    for key, pack in pairs(UI.ThemeBtns) do
        local active = (Config.ThemeKey == key)
        pack.btn.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.ColorGold or UITheme.StrokeSubtle
    end

    local isX = (Config.PlayerSide == 1)
    UI.BtnSideX.BackgroundColor3 = isX and UITheme.BgActive or UITheme.BgButton
    UI.StrokeSideX.Color = isX and UITheme.ColorX or UITheme.StrokeSubtle

    UI.BtnSideO.BackgroundColor3 = (not isX) and UITheme.BgActive or UITheme.BgButton
    UI.StrokeSideO.Color = (not isX) and UITheme.ColorO or UITheme.StrokeSubtle

    for sz, pack in pairs(UI.SizeBtns) do
        local active = (Config.BoardSize == sz)
        pack.btn.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.ColorGreen or UITheme.StrokeSubtle
    end

    for val, pack in pairs(UI.TimeBtns) do
        local active = (Config.TurnTimeLimit == val)
        pack.btn.BackgroundColor3 = active and UITheme.BgActive or UITheme.BgButton
        pack.btn.TextColor3 = active and UITheme.TextPrimary or UITheme.TextSecondary
        pack.stroke.Color = active and UITheme.ColorO or UITheme.StrokeSubtle
    end
    UI.TimerBarBg.Visible = (Config.TurnTimeLimit > 0 and not State.GameOver)

    UI.RuleBtn.Text = Config.BlockTwoEnds and "Luật: Chặn 2 đầu (VN)" or "Luật: Tự do 5 ô"
    UI.RuleStroke.Color = Config.BlockTwoEnds and UITheme.ColorGold or UITheme.StrokeSubtle

    UI.TwoTapBtn.Text = Config.ConfirmTwoTap and "2 chạm xác nhận: Bật" or "2 chạm xác nhận: Tắt"
    UI.TwoTapBtn.TextColor3 = Config.ConfirmTwoTap and UITheme.ColorGreen or UITheme.TextSecondary
    UI.TwoTapStroke.Color = Config.ConfirmTwoTap and UITheme.ColorGreen or UITheme.StrokeSubtle

    UI.CoordsBtn.Text = Config.ShowCoords and "Tọa độ (A-O / 1-15): Bật" or "Tọa độ (A-O / 1-15): Tắt"
    UI.CoordsBtn.TextColor3 = Config.ShowCoords and UITheme.TextPrimary or UITheme.TextSecondary

    UI.NumBtn.Text = Config.ShowMoveNumbers and "Số thứ tự nước đi: Bật" or "Số thứ tự nước đi: Tắt"
    UI.NumBtn.TextColor3 = Config.ShowMoveNumbers and UITheme.ColorO or UITheme.TextSecondary

    UI.SoundBtn.Text = Config.SoundEnabled and "Âm thanh: Bật" or "Âm thanh: Tắt"
    UI.SoundBtn.TextColor3 = Config.SoundEnabled and UITheme.TextPrimary or UITheme.TextSecondary
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

    if winnerSide == 1 then
        State.SessionX = State.SessionX + 1
    elseif winnerSide == 2 then
        State.SessionO = State.SessionO + 1
    end

    local titleText, subText, accent
    if Config.Mode == "AI" then
        if winnerSide == Config.PlayerSide then
            local reward = (Config.Difficulty == "Master" and 180)
                or (Config.Difficulty == "Hard" and 100)
                or (Config.Difficulty == "Medium" and 50)
                or 20
            Stats.Wins = Stats.Wins + 1
            Stats.Streak = Stats.Streak + 1
            if Stats.Streak > Stats.BestStreak then
                Stats.BestStreak = Stats.Streak
            end
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
        accent = (winnerSide == 1) and UITheme.ColorX or UITheme.ColorO
    end

    refreshBoardVisuals()
    if #State.WinCells >= 5 then
        drawWinLine()
    end
    updateTopStatus()
    showWinBanner(titleText, subText, accent)
end

local function triggerAITurn()
    if State.GameOver or State.Destroyed or Config.Mode ~= "AI" then return end
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
    sfxPlace(p)

    local cellUI = UI.Cells[r] and UI.Cells[r][c]
    if cellUI then
        local targetPiece = (p == 1) and cellUI.pieceX or cellUI.pieceO
        targetPiece.Size = UDim2.new(0.28, 0, 0.28, 0)
        local finalScale = (p == 1) and 0.70 or 0.62
        TweenService:Create(
            targetPiece,
            TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(finalScale, 0, finalScale, 0) }
        ):Play()
    end

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
    if State.ThreatAlert ~= "" then
        sfxWarn()
    end

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
    for _, child in ipairs(WinLineLayer:GetChildren()) do
        child:Destroy()
    end
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
    for _, child in ipairs(WinLineLayer:GetChildren()) do
        child:Destroy()
    end
    hideWinBanner()

    initGrid()
    if forceRebuild or #UI.Cells ~= Config.BoardSize then
        local coordPad = Config.ShowCoords and 24 or 4
        local availW = math.max(180, BoardScroll.AbsoluteSize.X - coordPad - 16)
        local availH = math.max(180, BoardScroll.AbsoluteSize.Y - coordPad - 16)
        if availW > 180 and availH > 180 then
            local fit = math.floor(math.min(availW, availH) / Config.BoardSize)
            Config.CellSize = math.clamp(fit, 20, 38)
        end
        rebuildBoard(false)
    else
        refreshBoardVisuals()
    end

    updateControlsUI()
    updateTopStatus()

    if Config.Mode == "AI" and Config.PlayerSide == 2 then
        triggerAITurn()
    end
end

-- Vòng lặp đồng hồ trận đấu & giới hạn thời gian mỗi lượt (0.25s/lần, rất nhẹ)
task.spawn(function()
    while not State.Destroyed do
        task.wait(0.25)
        if not State.Destroyed and not State.GameOver and not State.Minimized and #State.History > 0 then
            State.MatchElapsed = State.MatchElapsed + 0.25
            if Config.TurnTimeLimit > 0 and not State.AIThinking then
                State.TurnTimeLeft = math.max(0, State.TurnTimeLeft - 0.25)
                local ratio = math.clamp(State.TurnTimeLeft / Config.TurnTimeLimit, 0, 1)
                UI.TimerBarFill.Size = UDim2.new(ratio, 0, 1, 0)
                UI.TimerBarFill.BackgroundColor3 = (ratio <= 0.3) and UITheme.ColorX or UITheme.ColorGold

                if State.TurnTimeLeft <= 0 then
                    local winner = (State.CurrentTurn == 1) and 2 or 1
                    sfxWarn()
                    finishMatch(winner, "Hết thời gian suy nghĩ!")
                else
                    updateTopStatus()
                end
            else
                UI.ClockLabel.Text = string.format("Thời gian: %s  |  Tỷ số X %d - %d O", formatTime(State.MatchElapsed), State.SessionX, State.SessionO)
            end
        end
    end
end)

-- ========================================================================
-- [PHẦN 12] PHÍM TẮT PC & DỌN DẸP TOÀN BỘ SCRIPT
-- ========================================================================
trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or State.Destroyed then return end
    if input.KeyCode == Enum.KeyCode.Z and Root.Visible then
        undoMove()
    elseif input.KeyCode == Enum.KeyCode.R and Root.Visible then
        startNewGame()
    elseif input.KeyCode == Enum.KeyCode.H and Root.Visible then
        showHint()
    elseif input.KeyCode == Enum.KeyCode.M then
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

task.defer(function()
    if not State.Destroyed then
        switchSideTab("PLAY")
        startNewGame(true)
    end
end)
