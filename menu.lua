--[[
    ========================================================================
    CỜ CARO PRO - STANDALONE v1.0
    Game Co Caro (Gomoku) 2D Toan Man Hinh cho Roblox Mobile & PC
    - Ho tro 2 che do: Dau May (AI: De / Trung Binh / Kho) & 2 Nguoi
    - Ho tro luat Chan 2 Dau (Chuan Caro Viet Nam) & Tu Do 5 O
    - Ho tro ban co 13x13, 15x15, 19x19 + Phong to/Thu nho + Keo ban co
    - Giao dien toi gian, mau chu matte de doc tren dien thoai, cam ung muot
    ========================================================================
]]

-- Don dep phien ban cu neu chay lai script
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
-- [PHAN 01] CAU HINH, BANG MAU MATTE AN TOAN CHO MOBILE & TRANG THAI
-- ========================================================================
local VERSION = "v1.0"
local SAVE_FILE = "CoCaroPro_Stats_v1.json"

-- Bang mau matte/diu mat (moi kenh RGB cua chu deu <= 215 de tranh loa)
local Theme = {
    BgMain        = Color3.fromRGB(18, 22, 30),
    BgPanel       = Color3.fromRGB(26, 31, 42),
    BgCard        = Color3.fromRGB(33, 40, 54),
    BgButton      = Color3.fromRGB(40, 48, 64),
    BgButtonHover = Color3.fromRGB(50, 60, 80),
    BgActive      = Color3.fromRGB(52, 74, 98),
    BoardOuter    = Color3.fromRGB(22, 26, 35),
    CellEven      = Color3.fromRGB(34, 41, 54),
    CellOdd       = Color3.fromRGB(31, 37, 49),
    CellLast      = Color3.fromRGB(52, 60, 76),
    CellWin       = Color3.fromRGB(68, 62, 40),
    CellHint      = Color3.fromRGB(48, 66, 56),
    CellPending   = Color3.fromRGB(60, 52, 42),
    StrokeSubtle  = Color3.fromRGB(56, 66, 86),
    StrokeStrong  = Color3.fromRGB(84, 98, 124),

    -- Mau chu matte (tat ca <= 215)
    TextPrimary   = Color3.fromRGB(210, 212, 215),
    TextSecondary = Color3.fromRGB(156, 166, 182),
    TextMuted     = Color3.fromRGB(118, 128, 145),

    -- Mau quan co & nhan (matte)
    ColorX        = Color3.fromRGB(204, 94, 94),   -- Do san ho diu
    ColorO        = Color3.fromRGB(86, 174, 198),  -- Xanh ngoc lam diu
    ColorGold     = Color3.fromRGB(204, 168, 86),  -- Vang dong diu
    ColorGreen    = Color3.fromRGB(96, 180, 124),  -- Xanh la diu
    ColorDanger   = Color3.fromRGB(186, 84, 84),   -- Do canh bao diu
}

local FONT_MAIN = Enum.Font.GothamSemibold
local FONT_BODY = Enum.Font.GothamMedium

local Config = {
    BoardSize      = 15,         -- 13, 15, 19
    Mode           = "AI",       -- "AI" hoac "PVP"
    Difficulty     = "Medium",   -- "Easy", "Medium", "Hard"
    BlockTwoEnds   = true,       -- Luat chan 2 dau (Caro Viet Nam)
    PlayerSide     = 1,          -- 1 = X (di truoc), 2 = O (di sau) khi dau AI
    ConfirmTwoTap  = false,      -- Tuy chon 2 cham de tranh bam nham tren man nho
    SoundEnabled   = true,       -- Am thanh nhe khi danh co
    CellSize       = 30,         -- Kich thuoc o (22..44)
}

local State = {
    Grid           = {},         -- Grid[r][c] = 0 (trong), 1 (X), 2 (O)
    CurrentTurn    = 1,          -- 1 = X, 2 = O
    GameOver       = false,
    Winner         = 0,          -- 0 = chua/hoa, 1 = X, 2 = O
    IsDraw         = false,
    AIThinking     = false,
    History        = {},         -- Danh sach {r, c, p}
    WinCells       = {},         -- Danh sach {r, c} cua duong thang
    HintCell       = nil,        -- {r, c} goi y hien tai
    PendingCell    = nil,        -- {r, c} cho xac nhan 2 cham
    Minimized      = false,
    Destroyed      = false,
    ActiveMatchId  = 0,          -- Huy callback AI cu khi reset van
}

local Stats = {
    Wins   = 0,
    Losses = 0,
    Draws  = 0,
    Streak = 0,
    Xu     = 0,
}

local UI = {
    Cells = {},
    Connections = {},
}

-- ========================================================================
-- [PHAN 02] TIEN ICH LUU DU LIEU, AM THANH & TAO GUI AN TOAN
-- ========================================================================
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
                    Stats.Wins   = tonumber(data.Wins) or 0
                    Stats.Losses = tonumber(data.Losses) or 0
                    Stats.Draws  = tonumber(data.Draws) or 0
                    Stats.Streak = tonumber(data.Streak) or 0
                    Stats.Xu     = tonumber(data.Xu) or 0
                end
            end
        end
    end
end

local function saveStats()
    if type(writefile) == "function" then
        pcall(function()
            local encoded = HttpService:JSONEncode(Stats)
            writefile(SAVE_FILE, encoded)
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
    s.Color = color or Theme.StrokeSubtle
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- Bat su kien cham/click tuc thi (InputBegan thay cho MouseButton1Click de khong bi tre tren mobile)
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

-- Phat am thanh nhe bang Sound (co pcall an toan)
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
    if player == 1 then
        playSfx("rbxassetid://421058925", 0.35, 1.15)
    else
        playSfx("rbxassetid://421058925", 0.35, 0.92)
    end
end

local function sfxWin()
    playSfx("rbxassetid://4590662766", 0.45, 1.0)
end

local function sfxClick()
    playSfx("rbxassetid://421058925", 0.22, 1.35)
end

-- ========================================================================
-- [PHAN 03] LOGIC BAN CO & KIEM TRA THANG (HO TRO LUAT CHAN 2 DAU)
-- ========================================================================
local DIRS = {
    { 0, 1 },   -- Ngang
    { 1, 0 },   -- Doc
    { 1, 1 },   -- Cheo xuong phai
    { 1, -1 },  -- Cheo xuong trai
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

-- Kiem tra nuoc (r, c) cua nguoi choi p co tao thanh chuoi thang hay khong
-- Tra ve mang cac o thang neu thang, nguoc lai tra ve nil
local function checkWinAt(r, c, p)
    local grid = State.Grid
    local opp = (p == 1) and 2 or 1

    for _, d in ipairs(DIRS) do
        local dr, dc = d[1], d[2]
        local line = { { r, c } }

        -- Dem ve phia duong
        local nr, nc = r + dr, c + dc
        while inBounds(nr, nc) and grid[nr][nc] == p do
            table.insert(line, { nr, nc })
            nr = nr + dr
            nc = nc + dc
        end
        local blockedPos = inBounds(nr, nc) and grid[nr][nc] == opp

        -- Dem ve phia am
        local pr, pc = r - dr, c - dc
        while inBounds(pr, pc) and grid[pr][pc] == p do
            table.insert(line, { pr, pc })
            pr = pr - dr
            pc = pc - dc
        end
        local blockedNeg = inBounds(pr, pc) and grid[pr][pc] == opp

        local count = #line
        if count >= 5 then
            if Config.BlockTwoEnds then
                -- Luat Caro VN: 5 quan bi chan ca 2 dau boi quan doi phuong thi khong thang
                -- (6 quan tro len hoac it nhat 1 dau khong bi doi phuong chan la thang)
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

local function isBoardFull()
    return #State.History >= (Config.BoardSize * Config.BoardSize)
end

-- ========================================================================
-- [PHAN 04] TRI TUE NHAN TAO (AI: DE / TRUNG BINH / KHO)
-- ========================================================================
local AI = {}

-- Tinh diem 1 huong cho quan p dat tai (r, c) (ho tro ca mau co khe ho 1 o nhu XX_XX)
function AI.scoreLine(r, c, dr, dc, p)
    local grid = State.Grid
    local opp = (p == 1) and 2 or 1

    local count = 1
    local openEnds = 0
    local blockedByOpp = 0

    -- Huong duong
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
            -- Kiem tra co quan cung mau sau 1 o trong khong (mau chia tach)
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

    -- Huong am
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

    -- Thang ngay lap tuc
    if count >= 5 then
        if not Config.BlockTwoEnds or count > 5 or blockedByOpp < 2 then
            return 10000000, "WIN"
        else
            return 50, "BLOCKED5"
        end
    end

    local score = 0
    local tag = "NONE"

    if count == 4 then
        if openEnds == 2 then
            score = 1200000
            tag = "OPEN4"
        elseif openEnds == 1 then
            if Config.BlockTwoEnds and blockedByOpp == 1 then
                -- Neu bi chan 1 dau, nuoc tiep theo tao 5 se khong bi chan 2 dau tru khi dau kia bi chan
                score = 130000
                tag = "HALF4"
            else
                score = 150000
                tag = "HALF4"
            end
        end
    elseif count == 3 then
        if openEnds == 2 then
            score = 50000
            tag = "OPEN3"
        elseif openEnds == 1 then
            score = 4500
            tag = "HALF3"
        end
    elseif count == 2 then
        if openEnds == 2 then
            score = 1400
            tag = "OPEN2"
        elseif openEnds == 1 then
            score = 220
        end
    elseif count == 1 then
        if openEnds == 2 then
            score = 60
        elseif openEnds == 1 then
            score = 15
        end
    end

    -- Cong them diem cho mau chia tach (vi du: XX_XX, X_XXX, _XX_X_)
    local bestGap = math.max(gapPosCount, gapNegCount)
    if bestGap > 0 then
        local totalSpan = count + bestGap
        local spanOpen = (bestGap == gapPosCount and gapPosOpen) or (bestGap == gapNegCount and gapNegOpen)
        if totalSpan >= 4 then
            local gapScore = 115000
            if gapScore > score then
                score = gapScore
                tag = "HALF4"
            end
        elseif totalSpan == 3 and openEnds >= 1 and spanOpen then
            local gapScore = 36000
            if gapScore > score then
                score = gapScore
                tag = "OPEN3"
            end
        elseif totalSpan == 2 and openEnds >= 1 and spanOpen then
            score = score + 750
        end
    end

    return score, tag
end

-- Danh gia tong diem tan cong cua 1 o cho nguoi choi p
function AI.evaluatePointFor(r, c, p)
    local total = 0
    local open4Count = 0
    local half4Count = 0
    local open3Count = 0

    for _, d in ipairs(DIRS) do
        local s, tag = AI.scoreLine(r, c, d[1], d[2], p)
        total = total + s
        if tag == "WIN" then
            return 10000000
        elseif tag == "OPEN4" then
            open4Count = open4Count + 1
        elseif tag == "HALF4" then
            half4Count = half4Count + 1
        elseif tag == "OPEN3" then
            open3Count = open3Count + 1
        end
    end

    -- Thuong cho the doi (Fork: 2 duong 4, hoac 4 + 3 mo, hoac 2 duong 3 mo)
    if half4Count >= 2 then
        total = total + 900000
    elseif half4Count >= 1 and open3Count >= 1 then
        total = total + 750000
    elseif open3Count >= 2 then
        total = total + 520000
    end

    return total
end

-- Lay danh sach cac o ung vien trong pham vi ban kinh 2 o quanh cac quan da danh
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

-- Chon nuoc di toi uu cho side (1 = X, 2 = O) theo do kho
function AI.chooseMove(side, difficulty)
    local opp = (side == 1) and 2 or 1
    local n = Config.BoardSize
    local mid = (n + 1) / 2
    local candidates = AI.getCandidates()

    if #candidates == 0 then
        return nil
    end
    if #candidates == 1 then
        return candidates[1].r, candidates[1].c
    end

    local defWeight = 1.06
    if difficulty == "Easy" then
        defWeight = 0.78
    elseif difficulty == "Hard" then
        defWeight = 1.12
    end

    local scored = {}
    for _, cand in ipairs(candidates) do
        local r, c = cand.r, cand.c
        local atk = AI.evaluatePointFor(r, c, side)
        local def = AI.evaluatePointFor(r, c, opp)

        -- Uu tien tuyet doi: Thang ngay -> Chan thang ngay
        local combined
        if atk >= 10000000 then
            combined = 50000000
        elseif def >= 10000000 then
            if difficulty == "Easy" and math.random() < 0.25 then
                combined = def * 0.4 + atk
            else
                combined = 30000000 + atk
            end
        else
            local dist = math.abs(r - mid) + math.abs(c - mid)
            local centerBonus = math.max(0, (n - dist)) * 6
            combined = atk + def * defWeight + centerBonus
        end

        table.insert(scored, {
            r = r,
            c = c,
            score = combined,
            atk = atk,
            def = def,
        })
    end

    table.sort(scored, function(a, b)
        return a.score > b.score
    end)

    -- Neu da co nuoc thang ngay hoac chan thang ngay thi di luon
    if scored[1].score >= 25000000 then
        return scored[1].r, scored[1].c
    end

    -- Muc De: chon ngau nhien trong top 4 nuoc kha di
    if difficulty == "Easy" then
        local limit = math.min(4, #scored)
        local pick = scored[math.random(1, limit)]
        return pick.r, pick.c
    end

    -- Muc Trung Binh: chon trong nhom top sat diem nhau
    if difficulty == "Medium" then
        local topScore = scored[1].score
        local pool = { scored[1] }
        for i = 2, math.min(3, #scored) do
            if scored[i].score >= topScore * 0.92 then
                table.insert(pool, scored[i])
            end
        end
        local pick = pool[math.random(1, #pool)]
        return pick.r, pick.c
    end

    -- Muc Kho (Hard): Kiem tra 2 buoc (2-ply) tren top 8 ung vien de tranh lo so & tim the ep thang
    local bestMove = scored[1]
    local bestEval = -1e15
    local topK = math.min(8, #scored)
    local grid = State.Grid

    for i = 1, topK do
        local mv = scored[i]
        grid[mv.r][mv.c] = side

        -- Kiem tra phan cong manh nhat cua doi phuong sau nuoc di nay
        local oppBest = 0
        local sideFollowUp = 0
        for j = 1, math.min(12, #scored) do
            if j ~= i then
                local c2 = scored[j]
                if grid[c2.r][c2.c] == 0 then
                    local oScore = AI.evaluatePointFor(c2.r, c2.c, opp)
                    if oScore > oppBest then
                        oppBest = oScore
                    end
                    local sScore = AI.evaluatePointFor(c2.r, c2.c, side)
                    if sScore > sideFollowUp then
                        sideFollowUp = sScore
                    end
                end
            end
        end

        grid[mv.r][mv.c] = 0

        local evalVal = mv.score + sideFollowUp * 0.28 - oppBest * 0.42
        if oppBest >= 10000000 then
            evalVal = evalVal - 15000000
        elseif oppBest >= 1000000 and mv.atk < 1000000 then
            evalVal = evalVal - 2500000
        end

        if evalVal > bestEval then
            bestEval = evalVal
            bestMove = mv
        end
    end

    return bestMove.r, bestMove.c
end

-- ========================================================================
-- [PHAN 05] XAY DUNG GIAO DIEN TOAN MAN HINH (MOBILE & PC)
-- ========================================================================
loadStats()

-- Xoa GUI cu neu ton tai
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

-- Khung nen toan man hinh
local Root = Instance.new("Frame")
Root.Name = "Root"
Root.Size = UDim2.new(1, 0, 1, 0)
Root.Position = UDim2.new(0, 0, 0, 0)
Root.BackgroundColor3 = Theme.BgMain
Root.BorderSizePixel = 0
Root.Active = true
Root.Parent = ScreenGui

-- Nut noi khi thu gon (dat duoi topbar de khong bi che tren mobile)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatingReopen"
FloatBtn.Size = UDim2.new(0, 96, 0, 38)
FloatBtn.Position = UDim2.new(0, 16, 0, 74)
FloatBtn.BackgroundColor3 = Theme.BgPanel
FloatBtn.BorderSizePixel = 0
FloatBtn.AutoButtonColor = false
FloatBtn.Text = "CỜ CARO"
FloatBtn.Font = FONT_MAIN
FloatBtn.TextSize = 14
FloatBtn.TextColor3 = Theme.ColorGold
FloatBtn.Visible = false
FloatBtn.ZIndex = 50
FloatBtn.Parent = ScreenGui
addCorner(FloatBtn, 10)
addStroke(FloatBtn, Theme.ColorGold, 1.5, 0.25)

-- Cho phep keo nut noi tren mobile & PC
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
            if delta.Magnitude > 8 then
                moved = true
            end
            FloatBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
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

-- Khai bao ham cap nhat truoc de cac phan UI goi cheo nhau sach se
local rebuildBoard, refreshBoardVisuals, updateTopStatus, updateControlsUI, startNewGame, performMove, undoMove, showHint, showWinBanner, hideWinBanner

-- ========================================================================
-- [PHAN 06] THANH TIEU DE (TOP BAR) & THANH DIEU KHIEN PHU
-- ========================================================================
do
    -- Top Bar (chieu cao 48px)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Theme.BgPanel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Root
    addStroke(TopBar, Theme.StrokeSubtle, 1, 0.35)

    -- Tieu de game + phien ban
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 170, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "CỜ CARO PRO " .. VERSION
    TitleLabel.Font = FONT_MAIN
    TitleLabel.TextSize = 15
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Trang thai luot danh o giua TopBar
    local TurnPill = Instance.new("Frame")
    TurnPill.Name = "TurnPill"
    TurnPill.Size = UDim2.new(0, 210, 0, 30)
    TurnPill.AnchorPoint = Vector2.new(0.5, 0.5)
    TurnPill.Position = UDim2.new(0.5, 0, 0.5, 0)
    TurnPill.BackgroundColor3 = Theme.BgCard
    TurnPill.BorderSizePixel = 0
    TurnPill.Parent = TopBar
    addCorner(TurnPill, 8)
    UI.TurnStroke = addStroke(TurnPill, Theme.ColorX, 1.5, 0.15)

    local TurnLabel = Instance.new("TextLabel")
    TurnLabel.Name = "TurnLabel"
    TurnLabel.Size = UDim2.new(1, -12, 1, 0)
    TurnLabel.Position = UDim2.new(0, 6, 0, 0)
    TurnLabel.BackgroundTransparency = 1
    TurnLabel.Text = "Lượt: X (Bạn)  |  Nước: 0"
    TurnLabel.Font = FONT_MAIN
    TurnLabel.TextSize = 13
    TurnLabel.TextColor3 = Theme.TextPrimary
    TurnLabel.Parent = TurnPill
    UI.TurnLabel = TurnLabel

    -- Cum nut ben phai TopBar: Thu gon & Dong
    local RightGroup = Instance.new("Frame")
    RightGroup.Name = "RightGroup"
    RightGroup.Size = UDim2.new(0, 148, 0, 32)
    RightGroup.AnchorPoint = Vector2.new(1, 0.5)
    RightGroup.Position = UDim2.new(1, -10, 0.5, 0)
    RightGroup.BackgroundTransparency = 1
    RightGroup.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "MinBtn"
    MinBtn.Size = UDim2.new(0, 74, 1, 0)
    MinBtn.Position = UDim2.new(0, 0, 0, 0)
    MinBtn.BackgroundColor3 = Theme.BgButton
    MinBtn.BorderSizePixel = 0
    MinBtn.AutoButtonColor = false
    MinBtn.Text = "Thu gọn"
    MinBtn.Font = FONT_BODY
    MinBtn.TextSize = 12
    MinBtn.TextColor3 = Theme.TextPrimary
    MinBtn.Parent = RightGroup
    addCorner(MinBtn, 7)
    addStroke(MinBtn, Theme.StrokeSubtle, 1, 0.3)

    bindInstantTap(MinBtn, function()
        State.Minimized = true
        Root.Visible = false
        FloatBtn.Visible = true
        sfxClick()
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 66, 1, 0)
    CloseBtn.Position = UDim2.new(0, 82, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(68, 34, 38)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.AutoButtonColor = false
    CloseBtn.Text = "Đóng"
    CloseBtn.Font = FONT_MAIN
    CloseBtn.TextSize = 12
    CloseBtn.TextColor3 = Theme.ColorX
    CloseBtn.Parent = RightGroup
    addCorner(CloseBtn, 7)
    addStroke(CloseBtn, Theme.ColorDanger, 1, 0.35)

    bindInstantTap(CloseBtn, function()
        if _G.CoCaroProCleanup then
            _G.CoCaroProCleanup()
        end
    end)
end

-- ========================================================================
-- [PHAN 07] KHU VUC CHINH: BAN CO (TRAI) & BANG DIEU KHIEN (PHAI)
-- ========================================================================
local MainArea = Instance.new("Frame")
MainArea.Name = "MainArea"
MainArea.Size = UDim2.new(1, -16, 1, -58)
MainArea.Position = UDim2.new(0, 8, 0, 52)
MainArea.BackgroundTransparency = 1
MainArea.Parent = Root

-- Khung chua ban co (chiem ~70% chieu rong, co ScrollingFrame de keo/phong to tren mobile)
local BoardContainer = Instance.new("Frame")
BoardContainer.Name = "BoardContainer"
BoardContainer.Size = UDim2.new(1, -228, 1, 0)
BoardContainer.Position = UDim2.new(0, 0, 0, 0)
BoardContainer.BackgroundColor3 = Theme.BoardOuter
BoardContainer.BorderSizePixel = 0
BoardContainer.ClipsDescendants = true
BoardContainer.Parent = MainArea
addCorner(BoardContainer, 10)
addStroke(BoardContainer, Theme.StrokeSubtle, 1, 0.25)

local BoardScroll = Instance.new("ScrollingFrame")
BoardScroll.Name = "BoardScroll"
BoardScroll.Size = UDim2.new(1, -8, 1, -8)
BoardScroll.Position = UDim2.new(0, 4, 0, 4)
BoardScroll.BackgroundTransparency = 1
BoardScroll.BorderSizePixel = 0
BoardScroll.ScrollBarThickness = 5
BoardScroll.ScrollBarImageColor3 = Theme.StrokeStrong
BoardScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
BoardScroll.ScrollingDirection = Enum.ScrollingDirection.XY
BoardScroll.CanvasSize = UDim2.new(0, 500, 0, 500)
BoardScroll.Parent = BoardContainer
UI.BoardScroll = BoardScroll

local BoardFrame = Instance.new("Frame")
BoardFrame.Name = "BoardFrame"
BoardFrame.Size = UDim2.new(0, 450, 0, 450)
BoardFrame.Position = UDim2.new(0, 0, 0, 0)
BoardFrame.BackgroundColor3 = Theme.BgMain
BoardFrame.BorderSizePixel = 0
BoardFrame.Parent = BoardScroll
addCorner(BoardFrame, 6)
addStroke(BoardFrame, Theme.StrokeStrong, 1.5, 0.3)
UI.BoardFrame = BoardFrame

-- Thanh zoom nho goc duoi phai khung ban co
do
    local ZoomBar = Instance.new("Frame")
    ZoomBar.Name = "ZoomBar"
    ZoomBar.Size = UDim2.new(0, 128, 0, 30)
    ZoomBar.AnchorPoint = Vector2.new(1, 1)
    ZoomBar.Position = UDim2.new(1, -10, 1, -10)
    ZoomBar.BackgroundColor3 = Theme.BgPanel
    ZoomBar.BackgroundTransparency = 0.08
    ZoomBar.BorderSizePixel = 0
    ZoomBar.ZIndex = 20
    ZoomBar.Parent = BoardContainer
    addCorner(ZoomBar, 8)
    addStroke(ZoomBar, Theme.StrokeSubtle, 1, 0.2)

    local function makeZoomBtn(text, xPos, w, onTap)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, w, 0, 24)
        b.Position = UDim2.new(0, xPos, 0, 3)
        b.BackgroundColor3 = Theme.BgButton
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Text = text
        b.Font = FONT_MAIN
        b.TextSize = 13
        b.TextColor3 = Theme.TextPrimary
        b.ZIndex = 21
        b.Parent = ZoomBar
        addCorner(b, 6)
        bindInstantTap(b, onTap)
        return b
    end

    makeZoomBtn("-", 4, 30, function()
        Config.CellSize = math.max(22, Config.CellSize - 4)
        sfxClick()
        rebuildBoard(true)
    end)

    makeZoomBtn("Vừa", 38, 52, function()
        local availW = math.max(200, BoardScroll.AbsoluteSize.X - 16)
        local availH = math.max(200, BoardScroll.AbsoluteSize.Y - 16)
        local fit = math.floor(math.min(availW, availH) / Config.BoardSize)
        Config.CellSize = math.clamp(fit, 22, 44)
        sfxClick()
        rebuildBoard(true)
    end)

    makeZoomBtn("+", 94, 30, function()
        Config.CellSize = math.min(44, Config.CellSize + 4)
        sfxClick()
        rebuildBoard(true)
    end)
end

-- Banner ket qua tran dau (phu len tren ban co khi thang/thua/hoa)
do
    local Banner = Instance.new("Frame")
    Banner.Name = "WinBanner"
    Banner.Size = UDim2.new(0, 290, 0, 144)
    Banner.AnchorPoint = Vector2.new(0.5, 0.5)
    Banner.Position = UDim2.new(0.5, 0, 0.5, 0)
    Banner.BackgroundColor3 = Theme.BgPanel
    Banner.BorderSizePixel = 0
    Banner.Visible = false
    Banner.ZIndex = 35
    Banner.Parent = BoardContainer
    addCorner(Banner, 12)
    UI.BannerStroke = addStroke(Banner, Theme.ColorGold, 2, 0.1)
    UI.WinBanner = Banner

    local BannerTitle = Instance.new("TextLabel")
    BannerTitle.Name = "BannerTitle"
    BannerTitle.Size = UDim2.new(1, -20, 0, 36)
    BannerTitle.Position = UDim2.new(0, 10, 0, 14)
    BannerTitle.BackgroundTransparency = 1
    BannerTitle.Text = "BẠN ĐÃ THẮNG!"
    BannerTitle.Font = FONT_MAIN
    BannerTitle.TextSize = 20
    BannerTitle.TextColor3 = Theme.ColorGold
    BannerTitle.ZIndex = 36
    BannerTitle.Parent = Banner
    UI.BannerTitle = BannerTitle

    local BannerSub = Instance.new("TextLabel")
    BannerSub.Name = "BannerSub"
    BannerSub.Size = UDim2.new(1, -20, 0, 32)
    BannerSub.Position = UDim2.new(0, 10, 0, 50)
    BannerSub.BackgroundTransparency = 1
    BannerSub.Text = "+50 Xu  |  Chuỗi thắng: 1"
    BannerSub.Font = FONT_BODY
    BannerSub.TextSize = 13
    BannerSub.TextColor3 = Theme.TextSecondary
    BannerSub.TextWrapped = true
    BannerSub.ZIndex = 36
    BannerSub.Parent = Banner
    UI.BannerSub = BannerSub

    local PlayAgainBtn = Instance.new("TextButton")
    PlayAgainBtn.Size = UDim2.new(0, 130, 0, 34)
    PlayAgainBtn.Position = UDim2.new(0, 16, 1, -46)
    PlayAgainBtn.BackgroundColor3 = Color3.fromRGB(42, 74, 58)
    PlayAgainBtn.BorderSizePixel = 0
    PlayAgainBtn.AutoButtonColor = false
    PlayAgainBtn.Text = "Chơi ván mới"
    PlayAgainBtn.Font = FONT_MAIN
    PlayAgainBtn.TextSize = 13
    PlayAgainBtn.TextColor3 = Theme.ColorGreen
    PlayAgainBtn.ZIndex = 36
    PlayAgainBtn.Parent = Banner
    addCorner(PlayAgainBtn, 8)
    addStroke(PlayAgainBtn, Theme.ColorGreen, 1, 0.35)
    bindInstantTap(PlayAgainBtn, function()
        sfxClick()
        startNewGame()
    end)

    local ViewBoardBtn = Instance.new("TextButton")
    ViewBoardBtn.Size = UDim2.new(0, 118, 0, 34)
    ViewBoardBtn.Position = UDim2.new(1, -134, 1, -46)
    ViewBoardBtn.BackgroundColor3 = Theme.BgButton
    ViewBoardBtn.BorderSizePixel = 0
    ViewBoardBtn.AutoButtonColor = false
    ViewBoardBtn.Text = "Xem bàn cờ"
    ViewBoardBtn.Font = FONT_BODY
    ViewBoardBtn.TextSize = 13
    ViewBoardBtn.TextColor3 = Theme.TextPrimary
    ViewBoardBtn.ZIndex = 36
    ViewBoardBtn.Parent = Banner
    addCorner(ViewBoardBtn, 8)
    addStroke(ViewBoardBtn, Theme.StrokeSubtle, 1, 0.3)
    bindInstantTap(ViewBoardBtn, function()
        sfxClick()
        hideWinBanner()
    end)
end

-- ========================================================================
-- [PHAN 08] BANG DIEU KHIEN BEN PHAI (SIDE PANEL CUON DUOC)
-- ========================================================================
do
    local SidePanel = Instance.new("ScrollingFrame")
    SidePanel.Name = "SidePanel"
    SidePanel.Size = UDim2.new(0, 220, 1, 0)
    SidePanel.Position = UDim2.new(1, -220, 0, 0)
    SidePanel.BackgroundColor3 = Theme.BgPanel
    SidePanel.BorderSizePixel = 0
    SidePanel.ScrollBarThickness = 4
    SidePanel.ScrollBarImageColor3 = Theme.StrokeStrong
    SidePanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidePanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidePanel.Parent = MainArea
    addCorner(SidePanel, 10)
    addStroke(SidePanel, Theme.StrokeSubtle, 1, 0.25)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = SidePanel

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = SidePanel

    local function makeSectionLabel(text, order)
        local lbl = Instance.new("TextLabel")
        lbl.LayoutOrder = order
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = FONT_MAIN
        lbl.TextSize = 11
        lbl.TextColor3 = Theme.TextMuted
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = SidePanel
        return lbl
    end

    local function makeActionBtn(parent, text, size, pos, bgColor, textColor, onTap)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = bgColor or Theme.BgButton
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = text
        btn.Font = FONT_MAIN
        btn.TextSize = 12
        btn.TextColor3 = textColor or Theme.TextPrimary
        btn.Parent = parent
        addCorner(btn, 7)
        local st = addStroke(btn, Theme.StrokeSubtle, 1, 0.35)
        bindInstantTap(btn, onTap)
        return btn, st
    end

    -- 1. The thong ke thanh tich
    local StatsCard = Instance.new("Frame")
    StatsCard.LayoutOrder = 1
    StatsCard.Size = UDim2.new(1, 0, 0, 64)
    StatsCard.BackgroundColor3 = Theme.BgCard
    StatsCard.BorderSizePixel = 0
    StatsCard.Parent = SidePanel
    addCorner(StatsCard, 8)
    addStroke(StatsCard, Theme.StrokeSubtle, 1, 0.35)

    local StatsLine1 = Instance.new("TextLabel")
    StatsLine1.Size = UDim2.new(1, -14, 0, 26)
    StatsLine1.Position = UDim2.new(0, 7, 0, 6)
    StatsLine1.BackgroundTransparency = 1
    StatsLine1.Text = "Thắng: 0  |  Thua: 0  |  Hòa: 0"
    StatsLine1.Font = FONT_BODY
    StatsLine1.TextSize = 12
    StatsLine1.TextColor3 = Theme.TextPrimary
    StatsLine1.Parent = StatsCard
    UI.StatsLine1 = StatsLine1

    local StatsLine2 = Instance.new("TextLabel")
    StatsLine2.Size = UDim2.new(1, -14, 0, 24)
    StatsLine2.Position = UDim2.new(0, 7, 0, 34)
    StatsLine2.BackgroundTransparency = 1
    StatsLine2.Text = "Xu: 0 Xu  |  Chuỗi: 0"
    StatsLine2.Font = FONT_MAIN
    StatsLine2.TextSize = 12
    StatsLine2.TextColor3 = Theme.ColorGold
    StatsLine2.Parent = StatsCard
    UI.StatsLine2 = StatsLine2

    -- 2. Nut thao tac nhanh (Van moi / Di lai / Goi y)
    makeSectionLabel("THAO TÁC NHANH", 2)

    local QuickRow1 = Instance.new("Frame")
    QuickRow1.LayoutOrder = 3
    QuickRow1.Size = UDim2.new(1, 0, 0, 34)
    QuickRow1.BackgroundTransparency = 1
    QuickRow1.Parent = SidePanel

    makeActionBtn(QuickRow1, "Ván mới", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(40, 68, 54), Theme.ColorGreen, function()
        sfxClick()
        startNewGame()
    end)

    makeActionBtn(QuickRow1, "Đi lại", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Theme.BgButton, Theme.TextPrimary, function()
        sfxClick()
        undoMove()
    end)

    local QuickRow2 = Instance.new("Frame")
    QuickRow2.LayoutOrder = 4
    QuickRow2.Size = UDim2.new(1, 0, 0, 32)
    QuickRow2.BackgroundTransparency = 1
    QuickRow2.Parent = SidePanel

    makeActionBtn(QuickRow2, "Gợi ý nước đi", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(58, 52, 34), Theme.ColorGold, function()
        sfxClick()
        showHint()
    end)

    -- 3. Che do choi
    makeSectionLabel("CHẾ ĐỘ CHƠI", 5)

    local ModeRow = Instance.new("Frame")
    ModeRow.LayoutOrder = 6
    ModeRow.Size = UDim2.new(1, 0, 0, 32)
    ModeRow.BackgroundTransparency = 1
    ModeRow.Parent = SidePanel

    UI.BtnModeAI, UI.StrokeModeAI = makeActionBtn(ModeRow, "Đấu Máy", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.BgActive, Theme.TextPrimary, function()
        if Config.Mode ~= "AI" then
            Config.Mode = "AI"
            sfxClick()
            startNewGame()
        end
    end)

    UI.BtnModePVP, UI.StrokeModePVP = makeActionBtn(ModeRow, "2 Người", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Theme.BgButton, Theme.TextSecondary, function()
        if Config.Mode ~= "PVP" then
            Config.Mode = "PVP"
            sfxClick()
            startNewGame()
        end
    end)

    -- 4. Do kho AI
    makeSectionLabel("ĐỘ KHÓ MÁY (AI)", 7)

    local DiffRow = Instance.new("Frame")
    DiffRow.LayoutOrder = 8
    DiffRow.Size = UDim2.new(1, 0, 0, 30)
    DiffRow.BackgroundTransparency = 1
    DiffRow.Parent = SidePanel

    UI.DiffBtns = {}
    local diffs = {
        { key = "Easy",   label = "Dễ" },
        { key = "Medium", label = "Vừa" },
        { key = "Hard",   label = "Khó" },
    }
    for idx, d in ipairs(diffs) do
        local xScale = (idx - 1) * 0.34
        local btn, st = makeActionBtn(DiffRow, d.label, UDim2.new(0.31, 0, 1, 0), UDim2.new(xScale, 0, 0, 0), Theme.BgButton, Theme.TextSecondary, function()
            Config.Difficulty = d.key
            sfxClick()
            updateControlsUI()
        end)
        UI.DiffBtns[d.key] = { btn = btn, stroke = st }
    end

    -- 5. Chon quan (khi dau May)
    makeSectionLabel("QUÂN CỦA BẠN (ĐẤU MÁY)", 9)

    local SideRow = Instance.new("Frame")
    SideRow.LayoutOrder = 10
    SideRow.Size = UDim2.new(1, 0, 0, 30)
    SideRow.BackgroundTransparency = 1
    SideRow.Parent = SidePanel

    UI.BtnSideX, UI.StrokeSideX = makeActionBtn(SideRow, "Quân X (Trước)", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.BgActive, Theme.ColorX, function()
        if Config.PlayerSide ~= 1 then
            Config.PlayerSide = 1
            sfxClick()
            startNewGame()
        end
    end)

    UI.BtnSideO, UI.StrokeSideO = makeActionBtn(SideRow, "Quân O (Sau)", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Theme.BgButton, Theme.ColorO, function()
        if Config.PlayerSide ~= 2 then
            Config.PlayerSide = 2
            sfxClick()
            startNewGame()
        end
    end)

    -- 6. Kich thuoc ban co
    makeSectionLabel("KÍCH THƯỚC BÀN CỜ", 11)

    local SizeRow = Instance.new("Frame")
    SizeRow.LayoutOrder = 12
    SizeRow.Size = UDim2.new(1, 0, 0, 30)
    SizeRow.BackgroundTransparency = 1
    SizeRow.Parent = SidePanel

    UI.SizeBtns = {}
    local sizes = { 13, 15, 19 }
    for idx, sz in ipairs(sizes) do
        local xScale = (idx - 1) * 0.34
        local btn, st = makeActionBtn(SizeRow, sz .. "x" .. sz, UDim2.new(0.31, 0, 1, 0), UDim2.new(xScale, 0, 0, 0), Theme.BgButton, Theme.TextSecondary, function()
            if Config.BoardSize ~= sz then
                Config.BoardSize = sz
                sfxClick()
                startNewGame(true)
            end
        end)
        UI.SizeBtns[sz] = { btn = btn, stroke = st }
    end

    -- 7. Tuy chon luat & tien ich mobile
    makeSectionLabel("LUẬT & TIỆN ÍCH", 13)

    local RuleBtn, RuleStroke = makeActionBtn(SidePanel, "Luật: Chặn 2 đầu", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Theme.BgButton, Theme.TextPrimary, function()
        Config.BlockTwoEnds = not Config.BlockTwoEnds
        sfxClick()
        updateControlsUI()
    end)
    RuleBtn.LayoutOrder = 14
    UI.RuleBtn = RuleBtn
    UI.RuleStroke = RuleStroke

    local TwoTapBtn, TwoTapStroke = makeActionBtn(SidePanel, "2 chạm xác nhận: Tắt", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Theme.BgButton, Theme.TextSecondary, function()
        Config.ConfirmTwoTap = not Config.ConfirmTwoTap
        State.PendingCell = nil
        sfxClick()
        updateControlsUI()
        refreshBoardVisuals()
    end)
    TwoTapBtn.LayoutOrder = 15
    UI.TwoTapBtn = TwoTapBtn
    UI.TwoTapStroke = TwoTapStroke

    local SoundBtn, SoundStroke = makeActionBtn(SidePanel, "Âm thanh: Bật", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Theme.BgButton, Theme.TextPrimary, function()
        Config.SoundEnabled = not Config.SoundEnabled
        if Config.SoundEnabled then
            sfxClick()
        end
        updateControlsUI()
    end)
    SoundBtn.LayoutOrder = 16
    UI.SoundBtn = SoundBtn
    UI.SoundStroke = SoundStroke

    -- Huong dan phim tat PC nho gon
    local HelpLabel = Instance.new("TextLabel")
    HelpLabel.LayoutOrder = 17
    HelpLabel.Size = UDim2.new(1, 0, 0, 30)
    HelpLabel.BackgroundTransparency = 1
    HelpLabel.Text = "PC: Z (Đi lại) | H (Gợi ý) | R (Ván mới)"
    HelpLabel.Font = FONT_BODY
    HelpLabel.TextSize = 10
    HelpLabel.TextColor3 = Theme.TextMuted
    HelpLabel.TextWrapped = true
    HelpLabel.Parent = SidePanel
end

-- ========================================================================
-- [PHAN 09] VE QUAN CO VECTOR (X & O) VA XAY DUNG O BAN CO
-- ========================================================================
local function createPieceX(parent)
    local holder = Instance.new("Frame")
    holder.Name = "PieceX"
    holder.Size = UDim2.new(0.72, 0, 0.72, 0)
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.BackgroundTransparency = 1
    holder.Visible = false
    holder.ZIndex = 4
    holder.Parent = parent

    local bar1 = Instance.new("Frame")
    bar1.Size = UDim2.new(0.95, 0, 0.18, 0)
    bar1.AnchorPoint = Vector2.new(0.5, 0.5)
    bar1.Position = UDim2.new(0.5, 0, 0.5, 0)
    bar1.Rotation = 45
    bar1.BackgroundColor3 = Theme.ColorX
    bar1.BorderSizePixel = 0
    bar1.ZIndex = 4
    bar1.Parent = holder
    addCorner(bar1, 4)

    local bar2 = Instance.new("Frame")
    bar2.Size = UDim2.new(0.95, 0, 0.18, 0)
    bar2.AnchorPoint = Vector2.new(0.5, 0.5)
    bar2.Position = UDim2.new(0.5, 0, 0.5, 0)
    bar2.Rotation = -45
    bar2.BackgroundColor3 = Theme.ColorX
    bar2.BorderSizePixel = 0
    bar2.ZIndex = 4
    bar2.Parent = holder
    addCorner(bar2, 4)

    return holder
end

local function createPieceO(parent)
    local ring = Instance.new("Frame")
    ring.Name = "PieceO"
    ring.Size = UDim2.new(0.64, 0, 0.64, 0)
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
    st.Color = Theme.ColorO
    st.Thickness = 2.6
    st.Parent = ring

    return ring
end

local function centerBoardScroll()
    task.defer(function()
        if State.Destroyed then return end
        local cw = BoardScroll.CanvasSize.X.Offset
        local ch = BoardScroll.CanvasSize.Y.Offset
        local vw = BoardScroll.AbsoluteSize.X
        local vh = BoardScroll.AbsoluteSize.Y
        local px = math.max(0, math.floor((cw - vw) / 2))
        local py = math.max(0, math.floor((ch - vh) / 2))
        BoardScroll.CanvasPosition = Vector2.new(px, py)
    end)
end

rebuildBoard = function(preserveScroll)
    -- Xoa cac o cu
    for _, child in ipairs(BoardFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    UI.Cells = {}

    local n = Config.BoardSize
    local cs = Config.CellSize
    local totalPx = n * cs

    BoardFrame.Size = UDim2.new(0, totalPx, 0, totalPx)

    -- Can giua ban co neu nho hon khung nhin
    local vw = math.max(200, BoardScroll.AbsoluteSize.X)
    local vh = math.max(200, BoardScroll.AbsoluteSize.Y)
    local padX = math.max(12, math.floor((vw - totalPx) / 2))
    local padY = math.max(12, math.floor((vh - totalPx) / 2))

    BoardFrame.Position = UDim2.new(0, padX, 0, padY)
    BoardScroll.CanvasSize = UDim2.new(0, totalPx + padX * 2, 0, totalPx + padY * 2)

    local mid = math.floor((n + 1) / 2)

    for r = 1, n do
        UI.Cells[r] = {}
        for c = 1, n do
            local btn = Instance.new("TextButton")
            btn.Name = "C_" .. r .. "_" .. c
            btn.Size = UDim2.new(0, cs, 0, cs)
            btn.Position = UDim2.new(0, (c - 1) * cs, 0, (r - 1) * cs)
            btn.BackgroundColor3 = ((r + c) % 2 == 0) and Theme.CellEven or Theme.CellOdd
            btn.BorderColor3 = Color3.fromRGB(45, 53, 68)
            btn.BorderSizePixel = 1
            btn.AutoButtonColor = false
            btn.Text = ""
            btn.ZIndex = 2
            btn.Parent = BoardFrame

            -- Cham nho danh dau tam ban co (o giua)
            local centerDot = nil
            if r == mid and c == mid then
                centerDot = Instance.new("Frame")
                centerDot.Size = UDim2.new(0, 5, 0, 5)
                centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
                centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
                centerDot.BackgroundColor3 = Theme.StrokeStrong
                centerDot.BorderSizePixel = 0
                centerDot.ZIndex = 3
                centerDot.Parent = btn
                addCorner(centerDot, 4)
            end

            -- Cham danh dau nuoc vua danh (goc tren phai)
            local lastDot = Instance.new("Frame")
            lastDot.Name = "LastDot"
            lastDot.Size = UDim2.new(0, 6, 0, 6)
            lastDot.AnchorPoint = Vector2.new(1, 0)
            lastDot.Position = UDim2.new(1, -3, 0, 3)
            lastDot.BackgroundColor3 = Theme.ColorGold
            lastDot.BorderSizePixel = 0
            lastDot.Visible = false
            lastDot.ZIndex = 6
            lastDot.Parent = btn
            addCorner(lastDot, 4)

            local pieceX = createPieceX(btn)
            local pieceO = createPieceO(btn)

            UI.Cells[r][c] = {
                btn = btn,
                pieceX = pieceX,
                pieceO = pieceO,
                lastDot = lastDot,
                centerDot = centerDot,
            }

            local rowIdx, colIdx = r, c
            bindInstantTap(btn, function()
                if State.GameOver or State.AIThinking then
                    return
                end
                if Config.Mode == "AI" and State.CurrentTurn ~= Config.PlayerSide then
                    return
                end
                if State.Grid[rowIdx][colIdx] ~= 0 then
                    return
                end

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
    if not preserveScroll then
        centerBoardScroll()
    end
end

-- ========================================================================
-- [PHAN 10] CAP NHAT HIEN THI BAN CO, TRANG THAI & DIEU KHIEN
-- ========================================================================
refreshBoardVisuals = function()
    local n = Config.BoardSize
    local lastMove = State.History[#State.History]

    local winMap = {}
    for _, cell in ipairs(State.WinCells) do
        winMap[cell[1] * 100 + cell[2]] = true
    end

    for r = 1, n do
        local rowUI = UI.Cells[r]
        local rowGrid = State.Grid[r]
        if rowUI and rowGrid then
            for c = 1, n do
                local cell = rowUI[c]
                local val = rowGrid[c]
                local isLast = lastMove and lastMove.r == r and lastMove.c == c
                local isWin = winMap[r * 100 + c] == true
                local isHint = State.HintCell and State.HintCell.r == r and State.HintCell.c == c and val == 0
                local isPending = State.PendingCell and State.PendingCell.r == r and State.PendingCell.c == c and val == 0

                cell.pieceX.Visible = (val == 1)
                cell.pieceO.Visible = (val == 2)
                cell.lastDot.Visible = isLast and not isWin
                if cell.centerDot then
                    cell.centerDot.Visible = (val == 0)
                end

                if isWin then
                    cell.btn.BackgroundColor3 = Theme.CellWin
                elseif isPending then
                    cell.btn.BackgroundColor3 = Theme.CellPending
                elseif isHint then
                    cell.btn.BackgroundColor3 = Theme.CellHint
                elseif isLast then
                    cell.btn.BackgroundColor3 = Theme.CellLast
                else
                    cell.btn.BackgroundColor3 = ((r + c) % 2 == 0) and Theme.CellEven or Theme.CellOdd
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
            UI.TurnStroke.Color = Theme.ColorGold
        elseif State.Winner == 1 then
            UI.TurnLabel.Text = "QUÂN X THẮNG!  |  Nước: " .. moves
            UI.TurnStroke.Color = Theme.ColorX
        else
            UI.TurnLabel.Text = "QUÂN O THẮNG!  |  Nước: " .. moves
            UI.TurnStroke.Color = Theme.ColorO
        end
    elseif State.AIThinking then
        UI.TurnLabel.Text = "Máy đang suy nghĩ...  |  Nước: " .. moves
        UI.TurnStroke.Color = Theme.ColorGold
    else
        local who
        if Config.Mode == "AI" then
            who = (State.CurrentTurn == Config.PlayerSide) and "Bạn" or "Máy"
        else
            who = (State.CurrentTurn == 1) and "Người 1" or "Người 2"
        end
        local sym = (State.CurrentTurn == 1) and "X" or "O"
        UI.TurnLabel.Text = "Lượt: " .. sym .. " (" .. who .. ")  |  Nước: " .. moves
        UI.TurnStroke.Color = (State.CurrentTurn == 1) and Theme.ColorX or Theme.ColorO
    end

    UI.StatsLine1.Text = string.format("Thắng: %d  |  Thua: %d  |  Hòa: %d", Stats.Wins, Stats.Losses, Stats.Draws)
    UI.StatsLine2.Text = string.format("Xu: %d Xu  |  Chuỗi: %d", Stats.Xu, Stats.Streak)
end

updateControlsUI = function()
    -- Che do
    local isAI = (Config.Mode == "AI")
    UI.BtnModeAI.BackgroundColor3 = isAI and Theme.BgActive or Theme.BgButton
    UI.BtnModeAI.TextColor3 = isAI and Theme.TextPrimary or Theme.TextSecondary
    UI.StrokeModeAI.Color = isAI and Theme.ColorO or Theme.StrokeSubtle

    UI.BtnModePVP.BackgroundColor3 = (not isAI) and Theme.BgActive or Theme.BgButton
    UI.BtnModePVP.TextColor3 = (not isAI) and Theme.TextPrimary or Theme.TextSecondary
    UI.StrokeModePVP.Color = (not isAI) and Theme.ColorO or Theme.StrokeSubtle

    -- Do kho AI
    for key, pack in pairs(UI.DiffBtns) do
        local active = (Config.Difficulty == key)
        pack.btn.BackgroundColor3 = active and Theme.BgActive or Theme.BgButton
        pack.btn.TextColor3 = active and Theme.TextPrimary or Theme.TextSecondary
        pack.stroke.Color = active and Theme.ColorGold or Theme.StrokeSubtle
    end

    -- Quan cua ban
    local isX = (Config.PlayerSide == 1)
    UI.BtnSideX.BackgroundColor3 = isX and Theme.BgActive or Theme.BgButton
    UI.StrokeSideX.Color = isX and Theme.ColorX or Theme.StrokeSubtle

    UI.BtnSideO.BackgroundColor3 = (not isX) and Theme.BgActive or Theme.BgButton
    UI.StrokeSideO.Color = (not isX) and Theme.ColorO or Theme.StrokeSubtle

    -- Kich thuoc
    for sz, pack in pairs(UI.SizeBtns) do
        local active = (Config.BoardSize == sz)
        pack.btn.BackgroundColor3 = active and Theme.BgActive or Theme.BgButton
        pack.btn.TextColor3 = active and Theme.TextPrimary or Theme.TextSecondary
        pack.stroke.Color = active and Theme.ColorGreen or Theme.StrokeSubtle
    end

    -- Luat & tien ich
    UI.RuleBtn.Text = Config.BlockTwoEnds and "Luật: Chặn 2 đầu (VN)" or "Luật: Tự do 5 ô"
    UI.RuleStroke.Color = Config.BlockTwoEnds and Theme.ColorGold or Theme.StrokeSubtle

    UI.TwoTapBtn.Text = Config.ConfirmTwoTap and "2 chạm xác nhận: Bật" or "2 chạm xác nhận: Tắt"
    UI.TwoTapBtn.TextColor3 = Config.ConfirmTwoTap and Theme.ColorGreen or Theme.TextSecondary
    UI.TwoTapStroke.Color = Config.ConfirmTwoTap and Theme.ColorGreen or Theme.StrokeSubtle

    UI.SoundBtn.Text = Config.SoundEnabled and "Âm thanh: Bật" or "Âm thanh: Tắt"
    UI.SoundBtn.TextColor3 = Config.SoundEnabled and Theme.TextPrimary or Theme.TextSecondary
end

showWinBanner = function(titleText, subText, accentColor)
    UI.BannerTitle.Text = titleText
    UI.BannerTitle.TextColor3 = accentColor or Theme.ColorGold
    UI.BannerStroke.Color = accentColor or Theme.ColorGold
    UI.BannerSub.Text = subText
    UI.WinBanner.Visible = true
end

hideWinBanner = function()
    UI.WinBanner.Visible = false
end

-- ========================================================================
-- [PHAN 11] LUONG XU LY NUOC DI, AI, DI LAI & GOI Y
-- ========================================================================
local function triggerAITurn()
    if State.GameOver or State.Destroyed or Config.Mode ~= "AI" then
        return
    end
    local aiSide = (Config.PlayerSide == 1) and 2 or 1
    if State.CurrentTurn ~= aiSide then
        return
    end

    State.AIThinking = true
    updateTopStatus()
    local matchId = State.ActiveMatchId

    task.delay(0.18, function()
        if State.Destroyed or State.GameOver or State.ActiveMatchId ~= matchId then
            return
        end
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
    if State.GameOver or not inBounds(r, c) or State.Grid[r][c] ~= 0 then
        return
    end

    local p = State.CurrentTurn
    State.Grid[r][c] = p
    table.insert(State.History, { r = r, c = c, p = p })
    State.HintCell = nil
    State.PendingCell = nil
    sfxPlace(p)

    -- Hieu ung phong nhe quan vua dat
    local cellUI = UI.Cells[r] and UI.Cells[r][c]
    if cellUI then
        local targetPiece = (p == 1) and cellUI.pieceX or cellUI.pieceO
        targetPiece.Size = UDim2.new(0.3, 0, 0.3, 0)
        local finalScale = (p == 1) and 0.72 or 0.64
        TweenService:Create(
            targetPiece,
            TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(finalScale, 0, finalScale, 0) }
        ):Play()
    end

    -- Kiem tra thang / hoa
    local winLine = checkWinAt(r, c, p)
    if winLine then
        State.GameOver = true
        State.Winner = p
        State.WinCells = winLine
        sfxWin()

        local titleText, subText, accent
        if Config.Mode == "AI" then
            if p == Config.PlayerSide then
                local reward = (Config.Difficulty == "Hard" and 100) or (Config.Difficulty == "Medium" and 50) or 20
                Stats.Wins = Stats.Wins + 1
                Stats.Streak = Stats.Streak + 1
                Stats.Xu = Stats.Xu + reward
                saveStats()
                titleText = "BẠN ĐÃ THẮNG!"
                subText = string.format("+%d Xu  |  Chuỗi thắng: %d", reward, Stats.Streak)
                accent = Theme.ColorGreen
            else
                Stats.Losses = Stats.Losses + 1
                Stats.Streak = 0
                saveStats()
                titleText = "MÁY ĐÃ THẮNG!"
                subText = "Thử lại ván mới hoặc bật Gợi ý nhé"
                accent = Theme.ColorX
            end
        else
            local sym = (p == 1) and "QUÂN X" or "QUÂN O"
            titleText = sym .. " THẮNG!"
            subText = string.format("Hoàn thành sau %d nước đi", #State.History)
            accent = (p == 1) and Theme.ColorX or Theme.ColorO
        end

        refreshBoardVisuals()
        updateTopStatus()
        showWinBanner(titleText, subText, accent)
        return
    end

    if isBoardFull() then
        State.GameOver = true
        State.IsDraw = true
        if Config.Mode == "AI" then
            Stats.Draws = Stats.Draws + 1
            saveStats()
        end
        refreshBoardVisuals()
        updateTopStatus()
        showWinBanner("HÒA CỜ!", "Bàn cờ đã kín không còn nước đi", Theme.ColorGold)
        return
    end

    -- Chuyen luot
    State.CurrentTurn = (p == 1) and 2 or 1
    refreshBoardVisuals()
    updateTopStatus()

    if Config.Mode == "AI" and State.CurrentTurn ~= Config.PlayerSide then
        triggerAITurn()
    end
end

undoMove = function()
    if State.AIThinking or #State.History == 0 then
        return
    end

    local steps = 1
    if Config.Mode == "AI" then
        -- Neu dang den luot nguoi choi (hoac van ket thuc sau nuoc cua May) thi lui 2 nuoc
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
    hideWinBanner()

    refreshBoardVisuals()
    updateTopStatus()
end

showHint = function()
    if State.GameOver or State.AIThinking then
        return
    end
    local r, c = AI.chooseMove(State.CurrentTurn, "Hard")
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
    hideWinBanner()

    initGrid()
    if forceRebuild or #UI.Cells ~= Config.BoardSize then
        -- Tu dong can chinh CellSize vua man hinh khi doi kich thuoc ban co
        local availW = math.max(220, BoardScroll.AbsoluteSize.X - 20)
        local availH = math.max(220, BoardScroll.AbsoluteSize.Y - 20)
        if availW > 220 and availH > 220 then
            local fit = math.floor(math.min(availW, availH) / Config.BoardSize)
            Config.CellSize = math.clamp(fit, 24, 38)
        end
        rebuildBoard(false)
    else
        refreshBoardVisuals()
    end

    updateControlsUI()
    updateTopStatus()

    -- Neu nguoi choi chon quan O khi dau AI thi May (X) di truoc
    if Config.Mode == "AI" and Config.PlayerSide == 2 then
        triggerAITurn()
    end
end

-- ========================================================================
-- [PHAN 12] PHIM TAT PC & HAM DON DEP TOAN BO SCRIPT
-- ========================================================================
trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or State.Destroyed then
        return
    end
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

-- Khoi chay van co dau tien sau 1 frame de AbsoluteSize cua man hinh on dinh
task.defer(function()
    if not State.Destroyed then
        startNewGame(true)
    end
end)
