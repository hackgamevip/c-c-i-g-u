-- ============================================================================
-- DAU TRUONG CHIEN DAU PRO (v1.0) - Standalone Combat Mini-Game (Mobile & PC)
-- Code doc lap 100%, khong dung chung bat ky script nao khac.
-- Tuong thich: Executor (gethui / CoreGui) & Roblox Studio (PlayerGui)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local RNG = Random.new()

-- Don dep phien ban cu neu chay lai script
if _G.ArenaChienDau_Cleanup then
    pcall(_G.ArenaChienDau_Cleanup)
    _G.ArenaChienDau_Cleanup = nil
end

-- ============================================================================
-- 1. BANG MAU MATTE (KHONG CHOI / KHONG NEON TREN DIEN THOAI) & FONT AN TOAN
-- ============================================================================
local C = {
    BG_MAIN      = Color3.fromRGB(18, 21, 27),
    BG_PANEL     = Color3.fromRGB(26, 30, 38),
    BG_CARD      = Color3.fromRGB(34, 39, 49),
    BG_CARD_ALT  = Color3.fromRGB(42, 48, 60),
    BG_ARENA     = Color3.fromRGB(22, 26, 33),
    BG_ARENA_G   = Color3.fromRGB(30, 35, 44),
    BORDER       = Color3.fromRGB(58, 66, 80),
    BORDER_ACT   = Color3.fromRGB(112, 152, 186),

    -- Mau chu matte (tat ca kenh RGB <= 210 de tranh loe sang tren mobile)
    TXT_MAIN     = Color3.fromRGB(204, 209, 214),
    TXT_SUB      = Color3.fromRGB(148, 156, 168),
    TXT_GOLD     = Color3.fromRGB(204, 174, 98),
    TXT_GEM      = Color3.fromRGB(112, 178, 198),
    TXT_RED      = Color3.fromRGB(202, 108, 108),
    TXT_GREEN    = Color3.fromRGB(112, 186, 134),
    TXT_PURPLE   = Color3.fromRGB(168, 136, 202),
    TXT_DARK     = Color3.fromRGB(20, 24, 30),

    -- Mau nut & thanh trang thai (diu mat, de nhin)
    BTN_PRIMARY  = Color3.fromRGB(54, 108, 150),
    BTN_SUCCESS  = Color3.fromRGB(48, 122, 82),
    BTN_DANGER   = Color3.fromRGB(148, 56, 56),
    BTN_WARN     = Color3.fromRGB(154, 118, 48),
    BTN_PURPLE   = Color3.fromRGB(106, 72, 146),
    BTN_NEUTRAL  = Color3.fromRGB(46, 52, 64),

    -- Mau thuc the trong dau truong
    HP_FILL      = Color3.fromRGB(64, 166, 98),
    HP_ENEMY     = Color3.fromRGB(184, 72, 72),
    HP_BOSS      = Color3.fromRGB(162, 62, 142),
    FURY_FILL    = Color3.fromRGB(196, 142, 54),
    WARN_ZONE    = Color3.fromRGB(178, 64, 64),
    SLASH_FX     = Color3.fromRGB(186, 198, 208),
}

local FONT_TITLE = Enum.Font.GothamSemibold
local FONT_BODY  = Enum.Font.GothamMedium

-- ============================================================================
-- 2. DU LIEU GAME (TUONG, CHE DO, NANG CAP, MA QUA)
-- ============================================================================
local CFG = {
    VERSION = "v1.0",
    GUI_NAME = "ArenaChienDau_Standalone",
    SAVE_PREFIX = "arena_chien_dau_v1_",
    ARENA_W = 1000,
    ARENA_H = 620,
    PLAYER_R = 19,
}

CFG.MODES = {
    {
        id = "wave",
        name = "Vượt Ải",
        desc = "Đánh theo đợt, Boss xuất hiện mỗi 5 ải",
        rewardMult = 1.0,
        accent = C.BTN_PRIMARY,
    },
    {
        id = "boss",
        name = "Săn Boss",
        desc = "Đấu trực diện các Boss mạnh, thưởng lớn",
        rewardMult = 1.45,
        accent = C.BTN_DANGER,
    },
    {
        id = "endless",
        name = "Sinh Tồn",
        desc = "Quái ra liên tục, đua điểm và chuỗi combo",
        rewardMult = 1.2,
        accent = C.BTN_PURPLE,
    },
}

CFG.HEROES = {
    {
        id = "kiemsi",
        name = "Kiếm Sĩ",
        role = "Cận chiến cân bằng",
        costCoin = 0,
        costGem = 0,
        color = Color3.fromRGB(82, 146, 196),
        hp = 140,
        atk = 26,
        spd = 255,
        crit = 0.14,
        attackType = "melee",
        attackRange = 98,
        attackCd = 0.30,
        skillName = "Xoáy Kiếm",
        skillCd = 5.0,
        ultName = "Thiên Kiếm Trảm",
        desc = "Chém rộng cận chiến, Xoáy Kiếm 360 độ đẩy lùi quái.",
    },
    {
        id = "satthu",
        name = "Sát Thủ",
        role = "Tốc độ & Chí mạng",
        costCoin = 400,
        costGem = 0,
        color = Color3.fromRGB(134, 92, 182),
        hp = 112,
        atk = 24,
        spd = 315,
        crit = 0.28,
        attackType = "melee",
        attackRange = 86,
        attackCd = 0.20,
        skillName = "Ảnh Bộ Đột Kích",
        skillCd = 4.2,
        ultName = "Bão Dao Bóng Đêm",
        desc = "Đánh cực nhanh, chí mạng cao, lướt xuyên mục tiêu.",
    },
    {
        id = "xathu",
        name = "Xạ Thủ",
        role = "Tầm xa xuyên thấu",
        costCoin = 800,
        costGem = 0,
        color = Color3.fromRGB(72, 158, 118),
        hp = 105,
        atk = 22,
        spd = 265,
        crit = 0.20,
        attackType = "ranged",
        attackRange = 360,
        attackCd = 0.26,
        skillName = "Loạt Đạn Chùm",
        skillCd = 4.8,
        ultName = "Pháo Kích Hủy Diệt",
        desc = "Bắn đạn năng lượng từ xa, thả chùm 5 tia xuyên quái.",
    },
    {
        id = "chienthan",
        name = "Chiến Thần",
        role = "Máu trâu & Sát thương diện rộng",
        costCoin = 1500,
        costGem = 20,
        color = Color3.fromRGB(184, 126, 60),
        hp = 205,
        atk = 34,
        spd = 235,
        crit = 0.16,
        attackType = "melee",
        attackRange = 116,
        attackCd = 0.36,
        skillName = "Chấn Động Đất",
        skillCd = 5.5,
        ultName = "Lôi Đình Giáng Thế",
        desc = "Đòn đánh diện rộng mạnh mẽ, giáp dày và choáng kẻ địch.",
    },
}

CFG.UPGRADES = {
    { id = "atk",  name = "Sức Mạnh",  stat = "+15% Sát thương", baseCost = 100, step = 85,  maxLv = 15 },
    { id = "hp",   name = "Sinh Lực",  stat = "+20% Máu tối đa", baseCost = 90,  step = 75,  maxLv = 15 },
    { id = "spd",  name = "Tốc Độ",    stat = "+5% Di chuyển",   baseCost = 110, step = 90,  maxLv = 10 },
    { id = "crit", name = "Chí Mạng",  stat = "+3% Tỷ lệ Crit",  baseCost = 120, step = 100, maxLv = 12 },
    { id = "cdr",  name = "Hồi Chiêu", stat = "-4% Thời gian hồi", baseCost = 130, step = 110, maxLv = 10 },
}

CFG.CODES = {
    ["CHIENDAU2026"] = { coins = 500, gems = 15, msg = "Nhận 500 Xu + 15 KC" },
    ["TANTHU500"]    = { coins = 350, gems = 5,  msg = "Nhận 350 Xu + 5 KC" },
    ["SANBOSSPRO"]   = { coins = 250, gems = 25, msg = "Nhận 250 Xu + 25 KC" },
}

-- ============================================================================
-- 3. HE THONG LUU TRU 2 LOP (FILE JSON THEO USERID + FALLBACK _G)
-- ============================================================================
local SAVE = {}
local DATA = nil

local function getDefaultData()
    return {
        coins = 150,
        gems = 10,
        bestScore = 0,
        bestWave = 0,
        totalKills = 0,
        bossKills = 0,
        selectedHero = "kiemsi",
        selectedMode = "wave",
        unlockedHeroes = { kiemsi = true },
        upgrades = { atk = 0, hp = 0, spd = 0, crit = 0, cdr = 0 },
        usedCodes = {},
    }
end

local function getSaveFileName()
    local uid = LocalPlayer and tostring(LocalPlayer.UserId) or "guest"
    return CFG.SAVE_PREFIX .. uid .. ".json"
end

function SAVE.Load()
    local def = getDefaultData()
    local loaded = nil

    -- Lop 1: Doc file tren Executor
    if type(isfile) == "function" and type(readfile) == "function" then
        local ok, raw = pcall(function()
            local fname = getSaveFileName()
            if isfile(fname) then
                return readfile(fname)
            end
            return nil
        end)
        if ok and type(raw) == "string" and #raw > 2 then
            local okDec, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if okDec and type(decoded) == "table" then
                loaded = decoded
            end
        end
    end

    -- Lop 2: Fallback _G / getgenv
    if not loaded then
        local env = (type(getgenv) == "function" and getgenv()) or _G
        if type(env.ArenaChienDau_SaveData) == "table" then
            loaded = env.ArenaChienDau_SaveData
        end
    end

    if type(loaded) == "table" then
        for k, v in pairs(def) do
            if loaded[k] == nil then
                loaded[k] = v
            end
        end
        if type(loaded.unlockedHeroes) ~= "table" then loaded.unlockedHeroes = { kiemsi = true } end
        loaded.unlockedHeroes.kiemsi = true
        if type(loaded.upgrades) ~= "table" then loaded.upgrades = def.upgrades end
        for k, v in pairs(def.upgrades) do
            if loaded.upgrades[k] == nil then loaded.upgrades[k] = v end
        end
        if type(loaded.usedCodes) ~= "table" then loaded.usedCodes = {} end
        DATA = loaded
    else
        DATA = def
    end
end

function SAVE.Write()
    if not DATA then return end
    local env = (type(getgenv) == "function" and getgenv()) or _G
    env.ArenaChienDau_SaveData = DATA

    if type(writefile) == "function" then
        pcall(function()
            local encoded = HttpService:JSONEncode(DATA)
            writefile(getSaveFileName(), encoded)
        end)
    end
end

SAVE.Load()

-- ============================================================================
-- 4. TIEN ICH TAO UI & TOAN HOC
-- ============================================================================
local UI = {}
local CONNS = {}

local function trackConn(conn)
    table.insert(CONNS, conn)
    return conn
end

local function getHeroById(id)
    for _, h in ipairs(CFG.HEROES) do
        if h.id == id then return h end
    end
    return CFG.HEROES[1]
end

local function getModeById(id)
    for _, m in ipairs(CFG.MODES) do
        if m.id == id then return m end
    end
    return CFG.MODES[1]
end

local function getUpgradeCost(upg)
    local lv = DATA.upgrades[upg.id] or 0
    return upg.baseCost + lv * upg.step
end

local function computePlayerStats()
    local h = getHeroById(DATA.selectedHero)
    local u = DATA.upgrades
    local maxHp = math.floor(h.hp * (1 + (u.hp or 0) * 0.20))
    local atk = math.floor(h.atk * (1 + (u.atk or 0) * 0.15))
    local spd = math.floor(h.spd * (1 + (u.spd or 0) * 0.05))
    local crit = math.min(0.75, h.crit + (u.crit or 0) * 0.03)
    local cdr = math.max(0.55, 1 - (u.cdr or 0) * 0.04)
    return {
        hero = h,
        maxHp = maxHp,
        atk = atk,
        spd = spd,
        crit = crit,
        cdr = cdr,
    }
end

local function addCorner(inst, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or 8)
    c.Parent = inst
    return c
end

local function addStroke(inst, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.BORDER
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function makeLabel(parent, props)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = props.font or FONT_BODY
    lbl.TextColor3 = props.color or C.TXT_MAIN
    lbl.TextSize = props.size or 14
    lbl.Text = props.text or ""
    lbl.TextXAlignment = props.xAlign or Enum.TextXAlignment.Left
    lbl.TextYAlignment = props.yAlign or Enum.TextYAlignment.Center
    lbl.TextWrapped = props.wrap or false
    lbl.Size = props.dim or UDim2.new(1, 0, 0, 20)
    lbl.Position = props.pos or UDim2.new(0, 0, 0, 0)
    lbl.ZIndex = props.z or 2
    lbl.Parent = parent
    return lbl
end

local function makeBtn(parent, props)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = props.bg or C.BTN_NEUTRAL
    btn.Font = props.font or FONT_TITLE
    btn.TextColor3 = props.color or C.TXT_MAIN
    btn.TextSize = props.size or 14
    btn.Text = props.text or ""
    btn.Size = props.dim or UDim2.new(0, 100, 0, 34)
    btn.Position = props.pos or UDim2.new(0, 0, 0, 0)
    btn.AnchorPoint = props.anchor or Vector2.new(0, 0)
    btn.ZIndex = props.z or 3
    btn.Parent = parent
    addCorner(btn, props.radius or 8)
    if props.stroke ~= false then
        addStroke(btn, props.strokeColor or C.BORDER, props.strokeWidth or 1)
    end
    return btn
end

-- Helper kich hoat tuc thi cho nut bam (khong bi tre khi bam tren dien thoai)
local function bindTap(btn, callback)
    local lastFire = 0
    trackConn(btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            local now = os.clock()
            if now - lastFire < 0.12 then return end
            lastFire = now
            callback()
        end
    end))
end

local function mountScreenGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = CFG.GUI_NAME
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Uu tien gethui (Executor) -> CoreGui -> PlayerGui (Studio)
    local parented = false
    if type(gethui) == "function" then
        local ok = pcall(function()
            local h = gethui()
            local old = h:FindFirstChild(CFG.GUI_NAME)
            if old then old:Destroy() end
            gui.Parent = h
            parented = true
        end)
        if not ok then parented = false end
    end
    if not parented then
        local ok = pcall(function()
            local old = CoreGui:FindFirstChild(CFG.GUI_NAME)
            if old then old:Destroy() end
            gui.Parent = CoreGui
            parented = true
        end)
        if not ok then parented = false end
    end
    if not parented and LocalPlayer then
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        local old = pg:FindFirstChild(CFG.GUI_NAME)
        if old then old:Destroy() end
        gui.Parent = pg
    end
    return gui
end

-- ============================================================================
-- 5. TRANG THAI TRONG TRAN DAU (COMBAT ENGINE STATE)
-- ============================================================================
local GAME = {}
local S = {
    inMatch = false,
    paused = false,
    gameOver = false,
    mode = "wave",
    wave = 1,
    score = 0,
    kills = 0,
    coinsEarned = 0,
    gemsEarned = 0,
    combo = 0,
    comboTimer = 0,
    maxCombo = 0,
    matchTime = 0,
    shakeTimer = 0,
    shakePower = 0,
    waveBannerTimer = 0,
    nextWaveTimer = 0,
    spawnTimer = 0,
    enemiesToSpawn = 0,
    bossActive = false,

    -- Nguoi choi
    px = CFG.ARENA_W * 0.5,
    py = CFG.ARENA_H * 0.5,
    dirX = 1,
    dirY = 0,
    hp = 100,
    maxHp = 100,
    atk = 25,
    spd = 250,
    crit = 0.15,
    cdr = 1.0,
    fury = 0,
    attackCd = 0,
    comboStep = 0,
    comboResetT = 0,
    dashCd = 0,
    dashTime = 0,
    dashVx = 0,
    dashVy = 0,
    invulnTime = 0,
    skillCd = 0,
    skillMaxCd = 5.0,
    buffAtkTime = 0,
    hero = CFG.HEROES[1],

    -- Input trang thai
    keys = { W = false, A = false, S = false, D = false },
    joyActive = false,
    joyId = nil,
    joyX = 0,
    joyY = 0,
    holdAttack = false,

    -- Thuc the dong
    enemies = {},
    projs = {},
    pickups = {},
    effects = {},
    hazards = {},
    floatTexts = {},
}

-- ============================================================================
-- 6. XAY DUNG GIAO DIEN CHINH (LOBBY + CUA HANG + DAU TRUONG)
-- ============================================================================
local ScreenGui = mountScreenGui()
UI.ScreenGui = ScreenGui

-- Nut thu gon / mo lai (dat goc phai tren, tranh bieu tuong chat/mic goc trai)
do
    local toggleBtn = makeBtn(ScreenGui, {
        text = "CHIẾN ĐẤU",
        bg = C.BG_PANEL,
        color = C.TXT_GOLD,
        size = 13,
        dim = UDim2.new(0, 108, 0, 34),
        pos = UDim2.new(1, -120, 0, 52),
        radius = 10,
        strokeColor = C.BORDER_ACT,
        strokeWidth = 1.5,
        z = 50,
    })
    UI.ToggleBtn = toggleBtn

    -- Ho tro keo tha nut mo nhanh neu can
    local dragging, dragStart, startPos = false, nil, nil
    local moved = false
    trackConn(toggleBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = inp.Position
            startPos = toggleBtn.Position
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            if delta.Magnitude > 8 then
                moved = true
                toggleBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved and UI.MainFrame then
                UI.MainFrame.Visible = not UI.MainFrame.Visible
                if not UI.MainFrame.Visible and S.inMatch and not S.gameOver then
                    S.paused = true
                end
            end
        end
    end))
end

-- Khung cua so chinh
do
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.52, 0)
    main.Size = UDim2.new(0.92, 0, 0.84, 0)
    main.BackgroundColor3 = C.BG_MAIN
    main.ClipsDescendants = true
    main.ZIndex = 1
    main.Parent = ScreenGui
    addCorner(main, 12)
    addStroke(main, C.BORDER, 1.5)

    local sc = Instance.new("UISizeConstraint")
    sc.MinSize = Vector2.new(540, 340)
    sc.MaxSize = Vector2.new(920, 560)
    sc.Parent = main

    UI.MainFrame = main

    -- Thanh tieu de (Header)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = C.BG_PANEL
    header.BorderSizePixel = 0
    header.ZIndex = 5
    header.Parent = main
    UI.Header = header

    makeLabel(header, {
        text = "ĐẤU TRƯỜNG CHIẾN ĐẤU PRO  " .. CFG.VERSION,
        font = FONT_TITLE,
        color = C.TXT_MAIN,
        size = 15,
        dim = UDim2.new(0, 290, 1, 0),
        pos = UDim2.new(0, 14, 0, 0),
        z = 6,
    })

    UI.HeaderCoin = makeLabel(header, {
        text = "Xu: 0",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 13,
        xAlign = Enum.TextXAlignment.Right,
        dim = UDim2.new(0, 110, 1, 0),
        pos = UDim2.new(1, -295, 0, 0),
        z = 6,
    })

    UI.HeaderGem = makeLabel(header, {
        text = "KC: 0",
        font = FONT_TITLE,
        color = C.TXT_GEM,
        size = 13,
        xAlign = Enum.TextXAlignment.Right,
        dim = UDim2.new(0, 90, 1, 0),
        pos = UDim2.new(1, -180, 0, 0),
        z = 6,
    })

    local minBtn = makeBtn(header, {
        text = "-",
        bg = C.BTN_NEUTRAL,
        color = C.TXT_MAIN,
        size = 16,
        dim = UDim2.new(0, 32, 0, 28),
        pos = UDim2.new(1, -76, 0.5, -14),
        radius = 6,
        z = 6,
    })
    bindTap(minBtn, function()
        main.Visible = false
        if S.inMatch and not S.gameOver then
            S.paused = true
        end
    end)

    local closeBtn = makeBtn(header, {
        text = "X",
        bg = C.BTN_DANGER,
        color = C.TXT_MAIN,
        size = 14,
        dim = UDim2.new(0, 32, 0, 28),
        pos = UDim2.new(1, -38, 0.5, -14),
        radius = 6,
        z = 6,
    })
    bindTap(closeBtn, function()
        if _G.ArenaChienDau_Cleanup then
            _G.ArenaChienDau_Cleanup()
        end
    end)

    -- Thanh thong bao noi (Toast)
    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0, 50)
    toast.Size = UDim2.new(0, 340, 0, 32)
    toast.BackgroundColor3 = C.BG_CARD_ALT
    toast.Visible = false
    toast.ZIndex = 40
    toast.Parent = main
    addCorner(toast, 8)
    addStroke(toast, C.BORDER_ACT, 1)

    local toastLbl = makeLabel(toast, {
        text = "",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 13,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, -16, 1, 0),
        pos = UDim2.new(0, 8, 0, 0),
        z = 41,
    })

    UI.Toast = toast
    UI.ToastLbl = toastLbl
    UI.ToastToken = 0
end

local function showToast(msg, color)
    UI.ToastToken = UI.ToastToken + 1
    local myToken = UI.ToastToken
    UI.ToastLbl.Text = msg
    UI.ToastLbl.TextColor3 = color or C.TXT_GOLD
    UI.Toast.Visible = true
    task.delay(2.2, function()
        if UI.ToastToken == myToken and UI.Toast then
            UI.Toast.Visible = false
        end
    end)
end

-- ============================================================================
-- 7. MAN HINH SANH CHO (LOBBY: CHON CHE DO, TUONG, NANG CAP, MA QUA)
-- ============================================================================
local refreshLobbyUI

do
    local lobby = Instance.new("Frame")
    lobby.Name = "LobbyView"
    lobby.Position = UDim2.new(0, 0, 0, 44)
    lobby.Size = UDim2.new(1, 0, 1, -44)
    lobby.BackgroundTransparency = 1
    lobby.ZIndex = 2
    lobby.Parent = UI.MainFrame
    UI.LobbyView = lobby

    -- Thanh Tab tren cung cua Lobby
    local tabBar = Instance.new("Frame")
    tabBar.Position = UDim2.new(0, 12, 0, 10)
    tabBar.Size = UDim2.new(1, -24, 0, 36)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 3
    tabBar.Parent = lobby

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.Padding = UDim.new(0, 8)
    tabList.Parent = tabBar

    local tabDefs = {
        { id = "play",    label = "VÀO TRẬN" },
        { id = "heroes",  label = "TƯỚNG (4)" },
        { id = "upgrade", label = "NÂNG CẤP" },
        { id = "code",    label = "MÃ QUÀ & KỶ LỤC" },
    }
    UI.TabButtons = {}
    UI.TabPages = {}

    local contentHolder = Instance.new("Frame")
    contentHolder.Position = UDim2.new(0, 12, 0, 54)
    contentHolder.Size = UDim2.new(1, -24, 1, -66)
    contentHolder.BackgroundTransparency = 1
    contentHolder.ZIndex = 3
    contentHolder.Parent = lobby

    local function switchLobbyTab(tabId)
        for id, btn in pairs(UI.TabButtons) do
            local active = (id == tabId)
            btn.BackgroundColor3 = active and C.BTN_PRIMARY or C.BG_CARD
            btn.TextColor3 = active and C.TXT_MAIN or C.TXT_SUB
        end
        for id, page in pairs(UI.TabPages) do
            page.Visible = (id == tabId)
        end
    end

    for _, td in ipairs(tabDefs) do
        local b = makeBtn(tabBar, {
            text = td.label,
            bg = C.BG_CARD,
            color = C.TXT_SUB,
            size = 13,
            dim = UDim2.new(0.24, -4, 1, 0),
            radius = 8,
            z = 4,
        })
        UI.TabButtons[td.id] = b

        local p = Instance.new("Frame")
        p.Name = "Page_" .. td.id
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ZIndex = 3
        p.Parent = contentHolder
        UI.TabPages[td.id] = p

        bindTap(b, function()
            switchLobbyTab(td.id)
        end)
    end

    -- ---- TAB 1: VAO TRAN (CHON CHE DO + TOM TAT TUONG + NUT BAT DAU) ----
    do
        local p = UI.TabPages.play
        makeLabel(p, {
            text = "CHỌN CHẾ ĐỘ CHIẾN ĐẤU",
            font = FONT_TITLE,
            color = C.TXT_SUB,
            size = 12,
            dim = UDim2.new(1, 0, 0, 20),
            pos = UDim2.new(0, 0, 0, 0),
        })

        UI.ModeCards = {}
        local modeRow = Instance.new("Frame")
        modeRow.Position = UDim2.new(0, 0, 0, 24)
        modeRow.Size = UDim2.new(1, 0, 0, 118)
        modeRow.BackgroundTransparency = 1
        modeRow.Parent = p

        local ml = Instance.new("UIListLayout")
        ml.FillDirection = Enum.FillDirection.Horizontal
        ml.Padding = UDim.new(0, 10)
        ml.Parent = modeRow

        for _, m in ipairs(CFG.MODES) do
            local card = makeBtn(modeRow, {
                text = "",
                bg = C.BG_CARD,
                dim = UDim2.new(0.333, -7, 1, 0),
                radius = 10,
                z = 4,
            })
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 5)
            bar.BackgroundColor3 = m.accent
            bar.BorderSizePixel = 0
            bar.ZIndex = 5
            bar.Parent = card
            addCorner(bar, 4)

            makeLabel(card, {
                text = m.name,
                font = FONT_TITLE,
                color = C.TXT_MAIN,
                size = 15,
                dim = UDim2.new(1, -18, 0, 24),
                pos = UDim2.new(0, 10, 0, 14),
                z = 5,
            })
            makeLabel(card, {
                text = m.desc,
                font = FONT_BODY,
                color = C.TXT_SUB,
                size = 12,
                wrap = true,
                dim = UDim2.new(1, -18, 0, 44),
                pos = UDim2.new(0, 10, 0, 38),
                z = 5,
            })
            makeLabel(card, {
                text = string.format("Thưởng: x%.2f Xu", m.rewardMult),
                font = FONT_TITLE,
                color = C.TXT_GOLD,
                size = 12,
                dim = UDim2.new(1, -18, 0, 20),
                pos = UDim2.new(0, 10, 1, -26),
                z = 5,
            })

            local stroke = card:FindFirstChildOfClass("UIStroke")
            UI.ModeCards[m.id] = { card = card, stroke = stroke }
            bindTap(card, function()
                DATA.selectedMode = m.id
                SAVE.Write()
                refreshLobbyUI()
            end)
        end

        -- Hop thong tin tuong dang chon
        local infoBox = Instance.new("Frame")
        infoBox.Position = UDim2.new(0, 0, 0, 154)
        infoBox.Size = UDim2.new(1, 0, 1, -220)
        infoBox.BackgroundColor3 = C.BG_CARD
        infoBox.ZIndex = 4
        infoBox.Parent = p
        addCorner(infoBox, 10)
        addStroke(infoBox, C.BORDER, 1)

        UI.PlayHeroSwatch = Instance.new("Frame")
        UI.PlayHeroSwatch.Position = UDim2.new(0, 14, 0.5, -24)
        UI.PlayHeroSwatch.Size = UDim2.new(0, 48, 0, 48)
        UI.PlayHeroSwatch.BackgroundColor3 = C.BTN_PRIMARY
        UI.PlayHeroSwatch.ZIndex = 5
        UI.PlayHeroSwatch.Parent = infoBox
        addCorner(UI.PlayHeroSwatch, 24)
        addStroke(UI.PlayHeroSwatch, C.TXT_MAIN, 1.5)

        UI.PlayHeroName = makeLabel(infoBox, {
            text = "Tướng: Kiếm Sĩ",
            font = FONT_TITLE,
            color = C.TXT_MAIN,
            size = 15,
            dim = UDim2.new(1, -84, 0, 22),
            pos = UDim2.new(0, 74, 0, 12),
            z = 5,
        })
        UI.PlayHeroStats = makeLabel(infoBox, {
            text = "HP: 140 | ATK: 26 | SPD: 255 | CRIT: 14%",
            font = FONT_BODY,
            color = C.TXT_GEM,
            size = 12,
            dim = UDim2.new(1, -84, 0, 20),
            pos = UDim2.new(0, 74, 0, 36),
            z = 5,
        })
        UI.PlayHeroSkills = makeLabel(infoBox, {
            text = "Kỹ năng: Xoáy Kiếm  |  Tuyệt chiêu: Thiên Kiếm Trảm",
            font = FONT_BODY,
            color = C.TXT_SUB,
            size = 12,
            wrap = true,
            dim = UDim2.new(1, -84, 0, 26),
            pos = UDim2.new(0, 74, 0, 58),
            z = 5,
        })

        -- Nut BAT DAU CHIEN DAU lon o duoi
        local startBtn = makeBtn(p, {
            text = "BẮT ĐẦU CHIẾN ĐẤU",
            bg = C.BTN_SUCCESS,
            color = C.TXT_MAIN,
            size = 16,
            dim = UDim2.new(1, 0, 0, 50),
            pos = UDim2.new(0, 0, 1, -52),
            radius = 10,
            strokeColor = C.TXT_GREEN,
            strokeWidth = 1.5,
            z = 5,
        })
        bindTap(startBtn, function()
            GAME.StartMatch()
        end)
    end

    -- ---- TAB 2: TUONG (CHON / MO KHOA 4 CLASS) ----
    do
        local p = UI.TabPages.heroes
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ZIndex = 3
        scroll.Parent = p

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0.49, -4, 0, 142)
        grid.CellPadding = UDim2.new(0, 10, 0, 10)
        grid.Parent = scroll

        UI.HeroCards = {}
        for _, h in ipairs(CFG.HEROES) do
            local card = Instance.new("Frame")
            card.BackgroundColor3 = C.BG_CARD
            card.ZIndex = 4
            card.Parent = scroll
            addCorner(card, 10)
            local st = addStroke(card, C.BORDER, 1)

            local dot = Instance.new("Frame")
            dot.Position = UDim2.new(0, 12, 0, 14)
            dot.Size = UDim2.new(0, 32, 0, 32)
            dot.BackgroundColor3 = h.color
            dot.ZIndex = 5
            dot.Parent = card
            addCorner(dot, 16)

            makeLabel(card, {
                text = h.name .. " - " .. h.role,
                font = FONT_TITLE,
                color = C.TXT_MAIN,
                size = 13,
                dim = UDim2.new(1, -60, 0, 20),
                pos = UDim2.new(0, 52, 0, 10),
                z = 5,
            })
            makeLabel(card, {
                text = string.format("HP %d | ATK %d | SPD %d | CRIT %d%%", h.hp, h.atk, h.spd, math.floor(h.crit * 100)),
                font = FONT_BODY,
                color = C.TXT_GEM,
                size = 11,
                dim = UDim2.new(1, -60, 0, 18),
                pos = UDim2.new(0, 52, 0, 30),
                z = 5,
            })
            makeLabel(card, {
                text = h.desc,
                font = FONT_BODY,
                color = C.TXT_SUB,
                size = 11,
                wrap = true,
                dim = UDim2.new(1, -24, 0, 36),
                pos = UDim2.new(0, 12, 0, 54),
                z = 5,
            })

            local actBtn = makeBtn(card, {
                text = "CHỌN",
                bg = C.BTN_PRIMARY,
                color = C.TXT_MAIN,
                size = 12,
                dim = UDim2.new(1, -24, 0, 32),
                pos = UDim2.new(0, 12, 1, -42),
                radius = 7,
                z = 5,
            })

            UI.HeroCards[h.id] = { stroke = st, btn = actBtn }
            bindTap(actBtn, function()
                if DATA.unlockedHeroes[h.id] then
                    DATA.selectedHero = h.id
                    SAVE.Write()
                    refreshLobbyUI()
                    showToast("Đã trang bị tướng " .. h.name, C.TXT_GREEN)
                else
                    if DATA.coins >= h.costCoin and DATA.gems >= h.costGem then
                        DATA.coins = DATA.coins - h.costCoin
                        DATA.gems = DATA.gems - h.costGem
                        DATA.unlockedHeroes[h.id] = true
                        DATA.selectedHero = h.id
                        SAVE.Write()
                        refreshLobbyUI()
                        showToast("Mở khóa thành công: " .. h.name, C.TXT_GOLD)
                    else
                        showToast("Chưa đủ Xu hoặc KC để mở khóa!", C.TXT_RED)
                    end
                end
            end)
        end
    end

    -- ---- TAB 3: NANG CAP VINH VIEN ----
    do
        local p = UI.TabPages.upgrade
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ZIndex = 3
        scroll.Parent = p

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 8)
        list.Parent = scroll

        UI.UpgradeRows = {}
        for _, upg in ipairs(CFG.UPGRADES) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -6, 0, 56)
            row.BackgroundColor3 = C.BG_CARD
            row.ZIndex = 4
            row.Parent = scroll
            addCorner(row, 8)
            addStroke(row, C.BORDER, 1)

            local titleLbl = makeLabel(row, {
                text = upg.name .. " (Lv.0/" .. upg.maxLv .. ")",
                font = FONT_TITLE,
                color = C.TXT_MAIN,
                size = 14,
                dim = UDim2.new(0.6, 0, 0, 22),
                pos = UDim2.new(0, 14, 0, 8),
                z = 5,
            })
            makeLabel(row, {
                text = upg.stat .. " mỗi cấp",
                font = FONT_BODY,
                color = C.TXT_SUB,
                size = 12,
                dim = UDim2.new(0.6, 0, 0, 18),
                pos = UDim2.new(0, 14, 0, 30),
                z = 5,
            })

            local buyBtn = makeBtn(row, {
                text = "NÂNG (100 Xu)",
                bg = C.BTN_WARN,
                color = C.TXT_MAIN,
                size = 12,
                dim = UDim2.new(0, 138, 0, 34),
                pos = UDim2.new(1, -150, 0.5, -17),
                radius = 7,
                z = 5,
            })

            UI.UpgradeRows[upg.id] = { title = titleLbl, btn = buyBtn }
            bindTap(buyBtn, function()
                local lv = DATA.upgrades[upg.id] or 0
                if lv >= upg.maxLv then
                    showToast(upg.name .. " đã đạt cấp tối đa!", C.TXT_GOLD)
                    return
                end
                local cost = getUpgradeCost(upg)
                if DATA.coins >= cost then
                    DATA.coins = DATA.coins - cost
                    DATA.upgrades[upg.id] = lv + 1
                    SAVE.Write()
                    refreshLobbyUI()
                    showToast("Đã nâng " .. upg.name .. " lên Lv." .. tostring(lv + 1), C.TXT_GREEN)
                else
                    showToast("Cần " .. tostring(cost) .. " Xu để nâng cấp!", C.TXT_RED)
                end
            end)
        end
    end

    -- ---- TAB 4: MA QUA & KY LUC ----
    do
        local p = UI.TabPages.code

        local statsCard = Instance.new("Frame")
        statsCard.Position = UDim2.new(0, 0, 0, 0)
        statsCard.Size = UDim2.new(1, 0, 0, 118)
        statsCard.BackgroundColor3 = C.BG_CARD
        statsCard.ZIndex = 4
        statsCard.Parent = p
        addCorner(statsCard, 10)
        addStroke(statsCard, C.BORDER, 1)

        makeLabel(statsCard, {
            text = "THÀNH TÍCH CHIẾN ĐẤU",
            font = FONT_TITLE,
            color = C.TXT_GOLD,
            size = 13,
            dim = UDim2.new(1, -24, 0, 22),
            pos = UDim2.new(0, 14, 0, 10),
            z = 5,
        })

        UI.RecordLbl = makeLabel(statsCard, {
            text = "",
            font = FONT_BODY,
            color = C.TXT_MAIN,
            size = 13,
            wrap = true,
            dim = UDim2.new(1, -28, 0, 74),
            pos = UDim2.new(0, 14, 0, 36),
            z = 5,
        })

        local codeCard = Instance.new("Frame")
        codeCard.Position = UDim2.new(0, 0, 0, 130)
        codeCard.Size = UDim2.new(1, 0, 0, 120)
        codeCard.BackgroundColor3 = C.BG_CARD
        codeCard.ZIndex = 4
        codeCard.Parent = p
        addCorner(codeCard, 10)
        addStroke(codeCard, C.BORDER, 1)

        makeLabel(codeCard, {
            text = "NHẬP MÃ QUÀ TẶNG (Thử: CHIENDAU2026, TANTHU500, SANBOSSPRO)",
            font = FONT_TITLE,
            color = C.TXT_SUB,
            size = 12,
            wrap = true,
            dim = UDim2.new(1, -28, 0, 26),
            pos = UDim2.new(0, 14, 0, 10),
            z = 5,
        })

        local box = Instance.new("TextBox")
        box.Position = UDim2.new(0, 14, 0, 46)
        box.Size = UDim2.new(1, -156, 0, 38)
        box.BackgroundColor3 = C.BG_MAIN
        box.Font = FONT_TITLE
        box.TextColor3 = C.TXT_MAIN
        box.PlaceholderColor3 = C.TXT_SUB
        box.PlaceholderText = "Nhập mã quà..."
        box.Text = ""
        box.TextSize = 14
        box.ClearTextOnFocus = false
        box.ZIndex = 5
        box.Parent = codeCard
        addCorner(box, 8)
        addStroke(box, C.BORDER, 1)

        local redeemBtn = makeBtn(codeCard, {
            text = "NHẬN QUÀ",
            bg = C.BTN_SUCCESS,
            color = C.TXT_MAIN,
            size = 13,
            dim = UDim2.new(0, 126, 0, 38),
            pos = UDim2.new(1, -140, 0, 46),
            radius = 8,
            z = 5,
        })

        bindTap(redeemBtn, function()
            local code = string.upper(string.gsub(box.Text or "", "%s+", ""))
            if code == "" then
                showToast("Hãy nhập mã quà trước!", C.TXT_RED)
                return
            end
            local reward = CFG.CODES[code]
            if not reward then
                showToast("Mã quà không hợp lệ!", C.TXT_RED)
                return
            end
            if DATA.usedCodes[code] then
                showToast("Bạn đã dùng mã này rồi!", C.TXT_RED)
                return
            end
            DATA.usedCodes[code] = true
            DATA.coins = DATA.coins + reward.coins
            DATA.gems = DATA.gems + reward.gems
            box.Text = ""
            SAVE.Write()
            refreshLobbyUI()
            showToast("Thành công: " .. reward.msg, C.TXT_GREEN)
        end)

        makeLabel(codeCard, {
            text = "Phím PC: WASD/Mũi tên di chuyển | J/Space Đánh | K/Shift Lướt | L/Q Kỹ năng | U/E Tuyệt chiêu",
            font = FONT_BODY,
            color = C.TXT_SUB,
            size = 11,
            wrap = true,
            dim = UDim2.new(1, -28, 0, 24),
            pos = UDim2.new(0, 14, 1, -28),
            z = 5,
        })
    end

    switchLobbyTab("play")
end

refreshLobbyUI = function()
    UI.HeaderCoin.Text = "Xu: " .. tostring(DATA.coins)
    UI.HeaderGem.Text = "KC: " .. tostring(DATA.gems)

    for id, pack in pairs(UI.ModeCards) do
        local sel = (DATA.selectedMode == id)
        pack.card.BackgroundColor3 = sel and C.BG_CARD_ALT or C.BG_CARD
        if pack.stroke then
            pack.stroke.Color = sel and C.BORDER_ACT or C.BORDER
            pack.stroke.Thickness = sel and 2 or 1
        end
    end

    local st = computePlayerStats()
    UI.PlayHeroSwatch.BackgroundColor3 = st.hero.color
    UI.PlayHeroName.Text = "Tướng đang chọn: " .. st.hero.name .. " (" .. st.hero.role .. ")"
    UI.PlayHeroStats.Text = string.format(
        "HP: %d  |  ATK: %d  |  SPD: %d  |  CRIT: %d%%  |  Hồi chiêu: -%d%%",
        st.maxHp, st.atk, st.spd, math.floor(st.crit * 100), math.floor((1 - st.cdr) * 100)
    )
    UI.PlayHeroSkills.Text = "Kỹ năng: " .. st.hero.skillName .. "  |  Tuyệt chiêu: " .. st.hero.ultName

    for _, h in ipairs(CFG.HEROES) do
        local pack = UI.HeroCards[h.id]
        local unlocked = DATA.unlockedHeroes[h.id] == true
        local equipped = (DATA.selectedHero == h.id)
        if equipped then
            pack.btn.Text = "ĐANG DÙNG"
            pack.btn.BackgroundColor3 = C.BTN_SUCCESS
            pack.stroke.Color = C.TXT_GREEN
            pack.stroke.Thickness = 2
        elseif unlocked then
            pack.btn.Text = "CHỌN TƯỚNG"
            pack.btn.BackgroundColor3 = C.BTN_PRIMARY
            pack.stroke.Color = C.BORDER
            pack.stroke.Thickness = 1
        else
            local costTxt = tostring(h.costCoin) .. " Xu"
            if h.costGem > 0 then
                costTxt = costTxt .. " + " .. tostring(h.costGem) .. " KC"
            end
            pack.btn.Text = "MỞ KHÓA (" .. costTxt .. ")"
            pack.btn.BackgroundColor3 = C.BTN_WARN
            pack.stroke.Color = C.BORDER
            pack.stroke.Thickness = 1
        end
    end

    for _, upg in ipairs(CFG.UPGRADES) do
        local pack = UI.UpgradeRows[upg.id]
        local lv = DATA.upgrades[upg.id] or 0
        pack.title.Text = string.format("%s (Lv.%d/%d)", upg.name, lv, upg.maxLv)
        if lv >= upg.maxLv then
            pack.btn.Text = "TỐI ĐA"
            pack.btn.BackgroundColor3 = C.BTN_NEUTRAL
        else
            pack.btn.Text = "NÂNG (" .. tostring(getUpgradeCost(upg)) .. " Xu)"
            pack.btn.BackgroundColor3 = C.BTN_WARN
        end
    end

    UI.RecordLbl.Text = string.format(
        "Điểm cao nhất: %d   |   Ải cao nhất: %d\nTổng quái đã hạ: %d   |   Boss đã hạ: %d",
        DATA.bestScore, DATA.bestWave, DATA.totalKills, DATA.bossKills
    )
end

-- ============================================================================
-- 8. MAN HINH DAU TRUONG (ARENA + HUD + JOYSTICK + 4 NUT CHIEN DAU)
-- ============================================================================
do
    local combat = Instance.new("Frame")
    combat.Name = "CombatView"
    combat.Position = UDim2.new(0, 0, 0, 44)
    combat.Size = UDim2.new(1, 0, 1, -44)
    combat.BackgroundColor3 = C.BG_MAIN
    combat.Visible = false
    combat.ClipsDescendants = true
    combat.ZIndex = 2
    combat.Parent = UI.MainFrame
    UI.CombatView = combat

    -- San dau (Arena Canvas)
    local arena = Instance.new("Frame")
    arena.Name = "ArenaCanvas"
    arena.Position = UDim2.new(0, 8, 0, 44)
    arena.Size = UDim2.new(1, -16, 1, -52)
    arena.BackgroundColor3 = C.BG_ARENA
    arena.ClipsDescendants = true
    arena.ZIndex = 2
    arena.Parent = combat
    addCorner(arena, 10)
    addStroke(arena, C.BORDER, 1.5)
    UI.Arena = arena

    -- Luoi nen tinh te trong san dau
    for i = 1, 7 do
        local vline = Instance.new("Frame")
        vline.Position = UDim2.new(i / 8, 0, 0, 0)
        vline.Size = UDim2.new(0, 1, 1, 0)
        vline.BackgroundColor3 = C.BG_ARENA_G
        vline.BorderSizePixel = 0
        vline.ZIndex = 2
        vline.Parent = arena
    end
    for i = 1, 4 do
        local hline = Instance.new("Frame")
        hline.Position = UDim2.new(0, 0, i / 5, 0)
        hline.Size = UDim2.new(1, 0, 0, 1)
        hline.BackgroundColor3 = C.BG_ARENA_G
        hline.BorderSizePixel = 0
        hline.ZIndex = 2
        hline.Parent = arena
    end

    -- Layer chua thuc the de de don dep
    local entityLayer = Instance.new("Frame")
    entityLayer.Name = "EntityLayer"
    entityLayer.Size = UDim2.new(1, 0, 1, 0)
    entityLayer.BackgroundTransparency = 1
    entityLayer.ZIndex = 5
    entityLayer.Parent = arena
    UI.EntityLayer = entityLayer

    -- Nhan vat nguoi choi
    local pNode = Instance.new("Frame")
    pNode.Name = "Player"
    pNode.AnchorPoint = Vector2.new(0.5, 0.5)
    pNode.Size = UDim2.new(0, 28, 0, 28)
    pNode.BackgroundColor3 = C.BTN_PRIMARY
    pNode.ZIndex = 10
    pNode.Parent = arena
    addCorner(pNode, 14)
    addStroke(pNode, C.TXT_MAIN, 2)
    UI.PlayerNode = pNode

    -- Mui ten chi huong truoc mat nguoi choi
    local pDir = Instance.new("Frame")
    pDir.AnchorPoint = Vector2.new(0.5, 0.5)
    pDir.Position = UDim2.new(0.85, 0, 0.5, 0)
    pDir.Size = UDim2.new(0, 9, 0, 9)
    pDir.BackgroundColor3 = C.TXT_GOLD
    pDir.ZIndex = 11
    pDir.Parent = pNode
    addCorner(pDir, 5)
    UI.PlayerDir = pDir

    -- Thanh HUD phia tren san dau
    local hud = Instance.new("Frame")
    hud.Position = UDim2.new(0, 8, 0, 4)
    hud.Size = UDim2.new(1, -16, 0, 36)
    hud.BackgroundColor3 = C.BG_PANEL
    hud.ZIndex = 8
    hud.Parent = combat
    addCorner(hud, 8)
    addStroke(hud, C.BORDER, 1)

    -- Thanh HP
    local hpBg = Instance.new("Frame")
    hpBg.Position = UDim2.new(0, 10, 0, 6)
    hpBg.Size = UDim2.new(0, 160, 0, 12)
    hpBg.BackgroundColor3 = C.BG_MAIN
    hpBg.ZIndex = 9
    hpBg.Parent = hud
    addCorner(hpBg, 4)

    UI.HpFill = Instance.new("Frame")
    UI.HpFill.Size = UDim2.new(1, 0, 1, 0)
    UI.HpFill.BackgroundColor3 = C.HP_FILL
    UI.HpFill.BorderSizePixel = 0
    UI.HpFill.ZIndex = 10
    UI.HpFill.Parent = hpBg
    addCorner(UI.HpFill, 4)

    UI.HpText = makeLabel(hpBg, {
        text = "HP 140/140",
        font = FONT_TITLE,
        color = C.TXT_MAIN,
        size = 10,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, 0, 1, 0),
        z = 11,
    })

    -- Thanh No (Fury)
    local furyBg = Instance.new("Frame")
    furyBg.Position = UDim2.new(0, 10, 0, 21)
    furyBg.Size = UDim2.new(0, 160, 0, 9)
    furyBg.BackgroundColor3 = C.BG_MAIN
    furyBg.ZIndex = 9
    furyBg.Parent = hud
    addCorner(furyBg, 4)

    UI.FuryFill = Instance.new("Frame")
    UI.FuryFill.Size = UDim2.new(0, 0, 1, 0)
    UI.FuryFill.BackgroundColor3 = C.FURY_FILL
    UI.FuryFill.BorderSizePixel = 0
    UI.FuryFill.ZIndex = 10
    UI.FuryFill.Parent = furyBg
    addCorner(UI.FuryFill, 4)

    UI.HudWave = makeLabel(hud, {
        text = "Ải 1",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 13,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(0, 110, 1, 0),
        pos = UDim2.new(0.5, -110, 0, 0),
        z = 9,
    })
    UI.HudScore = makeLabel(hud, {
        text = "Điểm: 0",
        font = FONT_TITLE,
        color = C.TXT_MAIN,
        size = 13,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(0, 110, 1, 0),
        pos = UDim2.new(0.5, 4, 0, 0),
        z = 9,
    })
    UI.HudCombo = makeLabel(hud, {
        text = "",
        font = FONT_TITLE,
        color = C.TXT_PURPLE,
        size = 13,
        xAlign = Enum.TextXAlignment.Right,
        dim = UDim2.new(0, 100, 1, 0),
        pos = UDim2.new(1, -182, 0, 0),
        z = 9,
    })

    local pauseBtn = makeBtn(hud, {
        text = "TẠM DỪNG",
        bg = C.BTN_NEUTRAL,
        color = C.TXT_MAIN,
        size = 11,
        dim = UDim2.new(0, 74, 0, 26),
        pos = UDim2.new(1, -80, 0.5, -13),
        radius = 6,
        z = 9,
    })
    bindTap(pauseBtn, function()
        if S.gameOver then return end
        S.paused = not S.paused
        UI.PauseOverlay.Visible = S.paused
    end)

    -- Thanh mau Boss (hien khi co Boss)
    local bossBar = Instance.new("Frame")
    bossBar.AnchorPoint = Vector2.new(0.5, 0)
    bossBar.Position = UDim2.new(0.5, 0, 0, 8)
    bossBar.Size = UDim2.new(0, 300, 0, 24)
    bossBar.BackgroundColor3 = C.BG_PANEL
    bossBar.Visible = false
    bossBar.ZIndex = 15
    bossBar.Parent = arena
    addCorner(bossBar, 6)
    addStroke(bossBar, C.HP_BOSS, 1.5)

    UI.BossHpFill = Instance.new("Frame")
    UI.BossHpFill.Size = UDim2.new(1, 0, 1, 0)
    UI.BossHpFill.BackgroundColor3 = C.HP_BOSS
    UI.BossHpFill.BorderSizePixel = 0
    UI.BossHpFill.ZIndex = 16
    UI.BossHpFill.Parent = bossBar
    addCorner(UI.BossHpFill, 5)

    UI.BossHpText = makeLabel(bossBar, {
        text = "BOSS",
        font = FONT_TITLE,
        color = C.TXT_MAIN,
        size = 11,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, 0, 1, 0),
        z = 17,
    })
    UI.BossBar = bossBar

    -- Thong bao giua man hinh (Wave moi / Boss xuat hien)
    UI.WaveBanner = makeLabel(arena, {
        text = "",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 20,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, 0, 0, 34),
        pos = UDim2.new(0, 0, 0.22, 0),
        z = 18,
    })

    -- ---- JOYSTICK DI CHUYEN CAM UNG TUC THI (GOC TRAI DUOI) ----
    local joyBase = Instance.new("Frame")
    joyBase.Name = "JoyBase"
    joyBase.Position = UDim2.new(0, 18, 1, -124)
    joyBase.Size = UDim2.new(0, 106, 0, 106)
    joyBase.BackgroundColor3 = C.BG_PANEL
    joyBase.BackgroundTransparency = 0.35
    joyBase.ZIndex = 20
    joyBase.Parent = arena
    addCorner(joyBase, 53)
    addStroke(joyBase, C.BORDER_ACT, 1.5)

    local joyKnob = Instance.new("Frame")
    joyKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    joyKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
    joyKnob.Size = UDim2.new(0, 42, 0, 42)
    joyKnob.BackgroundColor3 = C.BTN_PRIMARY
    joyKnob.BackgroundTransparency = 0.2
    joyKnob.ZIndex = 21
    joyKnob.Parent = joyBase
    addCorner(joyKnob, 21)
    addStroke(joyKnob, C.TXT_MAIN, 1)

    local function updateJoystick(pos)
        local center = joyBase.AbsolutePosition + joyBase.AbsoluteSize * 0.5
        local dx = pos.X - center.X
        local dy = pos.Y - center.Y
        local maxR = 36
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > maxR then
            dx = dx / dist * maxR
            dy = dy / dist * maxR
        end
        joyKnob.Position = UDim2.new(0.5, dx, 0.5, dy)
        if dist > 5 then
            S.joyX = dx / maxR
            S.joyY = dy / maxR
        else
            S.joyX = 0
            S.joyY = 0
        end
    end

    trackConn(joyBase.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            S.joyActive = true
            S.joyId = inp
            updateJoystick(inp.Position)
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(inp)
        if S.joyActive then
            if inp == S.joyId or inp.UserInputType == Enum.UserInputType.MouseMovement then
                updateJoystick(inp.Position)
            end
        end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if S.joyActive and (inp == S.joyId or inp.UserInputType == Enum.UserInputType.MouseButton1) then
            S.joyActive = false
            S.joyId = nil
            S.joyX = 0
            S.joyY = 0
            joyKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end))

    -- ---- 4 NUT CHIEN DAU CAM UNG TUC THI (GOC PHAI DUOI) ----
    local atkBtn = makeBtn(arena, {
        text = "ĐÁNH",
        bg = C.BTN_DANGER,
        color = C.TXT_MAIN,
        size = 14,
        dim = UDim2.new(0, 74, 0, 74),
        pos = UDim2.new(1, -90, 1, -90),
        radius = 37,
        strokeColor = C.TXT_RED,
        strokeWidth = 2,
        z = 20,
    })
    atkBtn.BackgroundTransparency = 0.18
    trackConn(atkBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            S.holdAttack = true
            GAME.TryAttack()
        end
    end))
    trackConn(atkBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            S.holdAttack = false
        end
    end))

    local dashBtn = makeBtn(arena, {
        text = "LƯỚT",
        bg = C.BTN_PRIMARY,
        color = C.TXT_MAIN,
        size = 12,
        dim = UDim2.new(0, 56, 0, 56),
        pos = UDim2.new(1, -156, 1, -70),
        radius = 28,
        strokeColor = C.BORDER_ACT,
        z = 20,
    })
    dashBtn.BackgroundTransparency = 0.2
    UI.DashBtn = dashBtn
    bindTap(dashBtn, function() GAME.TryDash() end)

    local skillBtn = makeBtn(arena, {
        text = "KỸ NĂNG",
        bg = C.BTN_WARN,
        color = C.TXT_MAIN,
        size = 11,
        dim = UDim2.new(0, 62, 0, 62),
        pos = UDim2.new(1, -148, 1, -138),
        radius = 31,
        strokeColor = C.TXT_GOLD,
        z = 20,
    })
    skillBtn.BackgroundTransparency = 0.2
    UI.SkillBtn = skillBtn
    bindTap(skillBtn, function() GAME.TrySkill() end)

    local ultBtn = makeBtn(arena, {
        text = "NỘ 0%",
        bg = C.BTN_PURPLE,
        color = C.TXT_MAIN,
        size = 11,
        dim = UDim2.new(0, 62, 0, 62),
        pos = UDim2.new(1, -80, 1, -162),
        radius = 31,
        strokeColor = C.TXT_PURPLE,
        z = 20,
    })
    ultBtn.BackgroundTransparency = 0.2
    UI.UltBtn = ultBtn
    bindTap(ultBtn, function() GAME.TryUlt() end)

    -- ---- OVERLAY TAM DUNG ----
    local pauseOv = Instance.new("Frame")
    pauseOv.Size = UDim2.new(1, 0, 1, 0)
    pauseOv.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    pauseOv.BackgroundTransparency = 0.35
    pauseOv.Visible = false
    pauseOv.ZIndex = 30
    pauseOv.Parent = combat
    UI.PauseOverlay = pauseOv

    local pCard = Instance.new("Frame")
    pCard.AnchorPoint = Vector2.new(0.5, 0.5)
    pCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    pCard.Size = UDim2.new(0, 260, 0, 166)
    pCard.BackgroundColor3 = C.BG_PANEL
    pCard.ZIndex = 31
    pCard.Parent = pauseOv
    addCorner(pCard, 12)
    addStroke(pCard, C.BORDER_ACT, 1.5)

    makeLabel(pCard, {
        text = "ĐANG TẠM DỪNG",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 16,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, 0, 0, 32),
        pos = UDim2.new(0, 0, 0, 14),
        z = 32,
    })

    local resumeBtn = makeBtn(pCard, {
        text = "TIẾP TỤC CHIẾN ĐẤU",
        bg = C.BTN_SUCCESS,
        color = C.TXT_MAIN,
        size = 13,
        dim = UDim2.new(1, -36, 0, 38),
        pos = UDim2.new(0, 18, 0, 58),
        radius = 8,
        z = 32,
    })
    bindTap(resumeBtn, function()
        S.paused = false
        pauseOv.Visible = false
    end)

    local quitBtn = makeBtn(pCard, {
        text = "VỀ SẢNH CHỜ",
        bg = C.BTN_DANGER,
        color = C.TXT_MAIN,
        size = 13,
        dim = UDim2.new(1, -36, 0, 38),
        pos = UDim2.new(0, 18, 0, 108),
        radius = 8,
        z = 32,
    })
    bindTap(quitBtn, function()
        GAME.EndMatch(true)
    end)

    -- ---- OVERLAY KET THUC TRAN ----
    local endOv = Instance.new("Frame")
    endOv.Size = UDim2.new(1, 0, 1, 0)
    endOv.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    endOv.BackgroundTransparency = 0.25
    endOv.Visible = false
    endOv.ZIndex = 30
    endOv.Parent = combat
    UI.EndOverlay = endOv

    local eCard = Instance.new("Frame")
    eCard.AnchorPoint = Vector2.new(0.5, 0.5)
    eCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    eCard.Size = UDim2.new(0, 320, 0, 232)
    eCard.BackgroundColor3 = C.BG_PANEL
    eCard.ZIndex = 31
    eCard.Parent = endOv
    addCorner(eCard, 12)
    addStroke(eCard, C.BORDER_ACT, 1.5)

    UI.EndTitle = makeLabel(eCard, {
        text = "KẾT THÚC TRẬN ĐẤU",
        font = FONT_TITLE,
        color = C.TXT_RED,
        size = 17,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, 0, 0, 30),
        pos = UDim2.new(0, 0, 0, 14),
        z = 32,
    })

    UI.EndStats = makeLabel(eCard, {
        text = "",
        font = FONT_BODY,
        color = C.TXT_MAIN,
        size = 13,
        wrap = true,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, -28, 0, 104),
        pos = UDim2.new(0, 14, 0, 50),
        z = 32,
    })

    local retryBtn = makeBtn(eCard, {
        text = "CHƠI LẠI",
        bg = C.BTN_SUCCESS,
        color = C.TXT_MAIN,
        size = 13,
        dim = UDim2.new(0.46, 0, 0, 38),
        pos = UDim2.new(0.04, 0, 1, -52),
        radius = 8,
        z = 32,
    })
    bindTap(retryBtn, function()
        GAME.StartMatch()
    end)

    local backBtn = makeBtn(eCard, {
        text = "VỀ SẢNH",
        bg = C.BTN_PRIMARY,
        color = C.TXT_MAIN,
        size = 13,
        dim = UDim2.new(0.46, 0, 0, 38),
        pos = UDim2.new(0.50, 0, 1, -52),
        radius = 8,
        z = 32,
    })
    bindTap(backBtn, function()
        GAME.ReturnToLobby()
    end)
end

-- ============================================================================
-- 9. CO CHE CHIEN DAU (SPAWN, TAN CONG, KY NANG, AI QUAI & BOSS)
-- ============================================================================
do
    local function toScalePos(x, y)
        return UDim2.new(x / CFG.ARENA_W, 0, y / CFG.ARENA_H, 0)
    end

    local function clearEntities()
        for _, child in ipairs(UI.EntityLayer:GetChildren()) do
            child:Destroy()
        end
        S.enemies = {}
        S.projs = {}
        S.pickups = {}
        S.effects = {}
        S.hazards = {}
        S.floatTexts = {}
    end

    local function addShake(power, dur)
        S.shakePower = math.max(S.shakePower, power)
        S.shakeTimer = math.max(S.shakeTimer, dur)
    end

    local function spawnFloatText(x, y, text, color, size)
        local lbl = makeLabel(UI.EntityLayer, {
            text = text,
            font = FONT_TITLE,
            color = color or C.TXT_MAIN,
            size = size or 13,
            xAlign = Enum.TextXAlignment.Center,
            dim = UDim2.new(0, 90, 0, 20),
            pos = toScalePos(x, y),
            z = 16,
        })
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        table.insert(S.floatTexts, {
            ui = lbl,
            x = x,
            y = y,
            vy = -48,
            life = 0.65,
            maxLife = 0.65,
        })
    end

    local function spawnRingFX(x, y, radius, color, dur)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = toScalePos(x, y)
        f.Size = UDim2.new(0, 12, 0, 12)
        f.BackgroundColor3 = color
        f.BackgroundTransparency = 0.72
        f.ZIndex = 7
        f.Parent = UI.EntityLayer
        addCorner(f, 999)
        addStroke(f, color, 2)
        table.insert(S.effects, {
            ui = f,
            x = x,
            y = y,
            maxR = radius,
            life = dur or 0.25,
            maxLife = dur or 0.25,
        })
    end

    local function spawnPickup(x, y)
        local roll = RNG:NextNumber()
        local kind, col, txt
        if roll < 0.50 then
            kind, col, txt = "heal", C.TXT_GREEN, "+HP"
        elseif roll < 0.78 then
            kind, col, txt = "fury", C.TXT_GOLD, "+NỘ"
        else
            kind, col, txt = "atk", C.TXT_RED, "+ATK"
        end
        local node = Instance.new("Frame")
        node.AnchorPoint = Vector2.new(0.5, 0.5)
        node.Position = toScalePos(x, y)
        node.Size = UDim2.new(0, 26, 0, 26)
        node.BackgroundColor3 = C.BG_PANEL
        node.ZIndex = 6
        node.Parent = UI.EntityLayer
        addCorner(node, 13)
        addStroke(node, col, 1.5)
        makeLabel(node, {
            text = txt,
            font = FONT_TITLE,
            color = col,
            size = 9,
            xAlign = Enum.TextXAlignment.Center,
            dim = UDim2.new(1, 0, 1, 0),
            z = 7,
        })
        table.insert(S.pickups, {
            ui = node,
            x = x,
            y = y,
            kind = kind,
            life = 11.0,
        })
    end

    local function spawnProjectile(owner, x, y, vx, vy, dmg, radius, color, pierce)
        local node = Instance.new("Frame")
        node.AnchorPoint = Vector2.new(0.5, 0.5)
        node.Position = toScalePos(x, y)
        local px = math.max(8, math.floor(radius * 1.4))
        node.Size = UDim2.new(0, px, 0, px)
        node.BackgroundColor3 = color
        node.ZIndex = 9
        node.Parent = UI.EntityLayer
        addCorner(node, px)
        table.insert(S.projs, {
            ui = node,
            owner = owner,
            x = x,
            y = y,
            vx = vx,
            vy = vy,
            dmg = dmg,
            r = radius,
            pierce = pierce or 0,
            hitMap = {},
            life = 2.4,
        })
    end

    local function spawnHazard(x, y, radius, delay, dmg)
        local node = Instance.new("Frame")
        node.AnchorPoint = Vector2.new(0.5, 0.5)
        node.Position = toScalePos(x, y)
        local wScale = (radius * 2) / CFG.ARENA_W
        local hScale = (radius * 2) / CFG.ARENA_H
        node.Size = UDim2.new(wScale, 0, hScale, 0)
        node.BackgroundColor3 = C.WARN_ZONE
        node.BackgroundTransparency = 0.78
        node.ZIndex = 5
        node.Parent = UI.EntityLayer
        addCorner(node, 999)
        addStroke(node, C.TXT_RED, 1.5)
        table.insert(S.hazards, {
            ui = node,
            x = x,
            y = y,
            r = radius,
            dmg = dmg,
            timer = delay,
            maxTimer = delay,
        })
    end

    local function spawnEnemy(kind, waveNum)
        local side = RNG:NextInteger(1, 4)
        local x, y
        if side == 1 then
            x, y = RNG:NextNumber(40, CFG.ARENA_W - 40), 28
        elseif side == 2 then
            x, y = RNG:NextNumber(40, CFG.ARENA_W - 40), CFG.ARENA_H - 28
        elseif side == 3 then
            x, y = 28, RNG:NextNumber(40, CFG.ARENA_H - 40)
        else
            x, y = CFG.ARENA_W - 28, RNG:NextNumber(40, CFG.ARENA_H - 40)
        end

        local scale = 1 + (waveNum - 1) * 0.16
        local hp, spd, dmg, rad, col, scoreVal, coinVal, isBoss, title
        isBoss = false
        if kind == "runner" then
            hp, spd, dmg, rad = math.floor(42 * scale), 155, math.floor(11 * scale), 15
            col = Color3.fromRGB(186, 132, 62)
            scoreVal, coinVal = 25, 6
        elseif kind == "shooter" then
            hp, spd, dmg, rad = math.floor(54 * scale), 92, math.floor(13 * scale), 16
            col = Color3.fromRGB(142, 92, 178)
            scoreVal, coinVal = 35, 8
        elseif kind == "tank" then
            hp, spd, dmg, rad = math.floor(125 * scale), 72, math.floor(18 * scale), 23
            col = Color3.fromRGB(168, 72, 72)
            scoreVal, coinVal = 50, 12
        elseif kind == "boss" then
            isBoss = true
            local bossNames = { "HẮC KỴ SĨ", "HỎA MA VƯƠNG", "LÔI THẦN HỘ VỆ", "CHÚA TỂ BÓNG TỐI" }
            title = bossNames[((math.floor((waveNum - 1) / 5)) % #bossNames) + 1]
            hp = math.floor(420 * scale)
            spd = 104
            dmg = math.floor(24 * scale)
            rad = 32
            col = C.HP_BOSS
            scoreVal, coinVal = 300, 65
        else
            hp, spd, dmg, rad = math.floor(62 * scale), 112, math.floor(12 * scale), 17
            col = Color3.fromRGB(176, 86, 86)
            scoreVal, coinVal = 20, 5
        end

        local node = Instance.new("Frame")
        node.AnchorPoint = Vector2.new(0.5, 0.5)
        node.Position = toScalePos(x, y)
        local px = math.floor(rad * 1.45)
        node.Size = UDim2.new(0, px, 0, px)
        node.BackgroundColor3 = col
        node.ZIndex = isBoss and 9 or 8
        node.Parent = UI.EntityLayer
        addCorner(node, isBoss and 10 or px)
        addStroke(node, isBoss and C.TXT_GOLD or C.TXT_DARK, isBoss and 2 or 1)

        -- Thanh mau nho tren dau quai thuong
        local hpFill = nil
        if not isBoss then
            local hb = Instance.new("Frame")
            hb.AnchorPoint = Vector2.new(0.5, 1)
            hb.Position = UDim2.new(0.5, 0, 0, -4)
            hb.Size = UDim2.new(0, 28, 0, 4)
            hb.BackgroundColor3 = C.BG_MAIN
            hb.BorderSizePixel = 0
            hb.ZIndex = 9
            hb.Parent = node

            hpFill = Instance.new("Frame")
            hpFill.Size = UDim2.new(1, 0, 1, 0)
            hpFill.BackgroundColor3 = C.HP_ENEMY
            hpFill.BorderSizePixel = 0
            hpFill.ZIndex = 10
            hpFill.Parent = hb
        end

        local e = {
            ui = node,
            hpFill = hpFill,
            kind = kind,
            isBoss = isBoss,
            title = title,
            x = x,
            y = y,
            hp = hp,
            maxHp = hp,
            spd = spd,
            dmg = dmg,
            r = rad,
            baseCol = col,
            flashT = 0,
            stunT = 0,
            atkCd = RNG:NextNumber(0.6, 1.4),
            bossSkillCd = 3.2,
            scoreVal = scoreVal,
            coinVal = coinVal,
        }
        table.insert(S.enemies, e)
        if isBoss then
            S.bossActive = true
            UI.BossBar.Visible = true
            UI.BossHpText.Text = title .. " (" .. tostring(hp) .. " HP)"
            UI.BossHpFill.Size = UDim2.new(1, 0, 1, 0)
        end
    end

    local function damagePlayer(amount)
        if S.invulnTime > 0 or S.gameOver then return end
        S.hp = math.max(0, S.hp - amount)
        S.invulnTime = 0.45
        S.fury = math.min(100, S.fury + 8)
        S.combo = 0
        addShake(7, 0.16)
        spawnFloatText(S.px, S.py - 22, "-" .. tostring(amount), C.TXT_RED, 14)
        if S.hp <= 0 then
            GAME.EndMatch(false)
        end
    end

    local function damageEnemy(e, rawDmg, knockX, knockY, stunDur)
        if e.hp <= 0 then return end
        local isCrit = RNG:NextNumber() < S.crit
        local mult = (S.buffAtkTime > 0) and 1.35 or 1.0
        local dmg = math.max(1, math.floor(rawDmg * mult * (isCrit and 1.65 or 1.0)))
        e.hp = e.hp - dmg
        e.flashT = 0.10
        if stunDur and stunDur > 0 then
            e.stunT = math.max(e.stunT, e.isBoss and (stunDur * 0.35) or stunDur)
        end
        if knockX and knockY then
            local kMult = e.isBoss and 0.25 or 1.0
            e.x = math.clamp(e.x + knockX * kMult, 24, CFG.ARENA_W - 24)
            e.y = math.clamp(e.y + knockY * kMult, 24, CFG.ARENA_H - 24)
        end

        S.fury = math.min(100, S.fury + (e.isBoss and 4.5 or 3.5))
        spawnFloatText(
            e.x + RNG:NextNumber(-12, 12),
            e.y - 18,
            isCrit and ("CRIT " .. tostring(dmg)) or tostring(dmg),
            isCrit and C.TXT_GOLD or C.TXT_MAIN,
            isCrit and 15 or 12
        )

        if e.hp <= 0 then
            S.kills = S.kills + 1
            S.combo = S.combo + 1
            S.comboTimer = 3.2
            if S.combo > S.maxCombo then S.maxCombo = S.combo end

            local modeInfo = getModeById(S.mode)
            local comboBonus = 1 + math.min(1.5, S.combo * 0.04)
            S.score = S.score + math.floor(e.scoreVal * comboBonus)
            S.coinsEarned = S.coinsEarned + math.max(1, math.floor(e.coinVal * modeInfo.rewardMult))
            if e.isBoss then
                S.gemsEarned = S.gemsEarned + 3
                DATA.bossKills = DATA.bossKills + 1
                S.bossActive = false
                UI.BossBar.Visible = false
                addShake(12, 0.30)
                spawnRingFX(e.x, e.y, 130, C.TXT_GOLD, 0.40)
            else
                spawnRingFX(e.x, e.y, 44, e.baseCol, 0.20)
            end
            if RNG:NextNumber() < (e.isBoss and 0.90 or 0.14) then
                spawnPickup(e.x, e.y)
            end
            e.ui:Destroy()
        else
            if e.hpFill then
                e.hpFill.Size = UDim2.new(math.clamp(e.hp / e.maxHp, 0, 1), 0, 1, 0)
            end
            if e.isBoss then
                UI.BossHpFill.Size = UDim2.new(math.clamp(e.hp / e.maxHp, 0, 1), 0, 1, 0)
                UI.BossHpText.Text = e.title .. " (" .. tostring(math.max(0, e.hp)) .. " HP)"
            end
        end
    end

    local function findNearestEnemy(maxDist)
        local best, bestD = nil, maxDist or 9999
        for _, e in ipairs(S.enemies) do
            if e.hp > 0 then
                local d = math.sqrt((e.x - S.px) ^ 2 + (e.y - S.py) ^ 2)
                if d < bestD then
                    bestD = d
                    best = e
                end
            end
        end
        return best, bestD
    end

    function GAME.StartWave(waveNum)
        S.wave = waveNum
        S.waveBannerTimer = 2.0
        if S.mode == "boss" then
            UI.WaveBanner.Text = "SĂN BOSS - CẤP " .. tostring(waveNum)
            S.enemiesToSpawn = 2 + math.min(5, waveNum)
            spawnEnemy("boss", waveNum * 2)
        elseif S.mode == "endless" then
            UI.WaveBanner.Text = "SINH TỒN - ĐỢT " .. tostring(waveNum)
            S.enemiesToSpawn = 8 + waveNum * 3
        else
            local isBossWave = (waveNum % 5 == 0)
            UI.WaveBanner.Text = isBossWave and ("CẢNH BÁO BOSS - ẢI " .. tostring(waveNum)) or ("ẢI " .. tostring(waveNum))
            S.enemiesToSpawn = isBossWave and (4 + math.floor(waveNum * 0.5)) or (5 + waveNum * 2)
            if isBossWave then
                spawnEnemy("boss", waveNum)
            end
        end
        S.spawnTimer = 0.4
    end

    function GAME.TryAttack()
        if not S.inMatch or S.paused or S.gameOver then return end
        if S.attackCd > 0 then return end

        local h = S.hero
        S.attackCd = h.attackCd * S.cdr
        S.comboStep = (S.comboStep % 3) + 1
        S.comboResetT = 1.1

        local ax, ay = S.dirX, S.dirY
        local near = findNearestEnemy(h.attackType == "ranged" and 420 or 160)
        if near then
            local dx, dy = near.x - S.px, near.y - S.py
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist > 1 then
                ax, ay = dx / dist, dy / dist
                S.dirX, S.dirY = ax, ay
            end
        end

        local dmgMult = (S.comboStep == 3) and 1.35 or 1.0
        local finalDmg = math.floor(S.atk * dmgMult)

        if h.attackType == "ranged" then
            spawnProjectile("player", S.px + ax * 18, S.py + ay * 18, ax * 560, ay * 560, finalDmg, 8, h.color, (S.comboStep == 3) and 2 or 0)
            spawnRingFX(S.px + ax * 18, S.py + ay * 18, 22, h.color, 0.14)
        else
            local hitX = S.px + ax * (h.attackRange * 0.45)
            local hitY = S.py + ay * (h.attackRange * 0.45)
            local hitR = h.attackRange * (S.comboStep == 3 and 0.72 or 0.58)
            spawnRingFX(hitX, hitY, hitR, S.comboStep == 3 and C.TXT_GOLD or C.SLASH_FX, 0.16)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - hitX, e.y - hitY
                    if math.sqrt(dx * dx + dy * dy) <= (hitR + e.r) then
                        local push = (S.comboStep == 3) and 34 or 16
                        damageEnemy(e, finalDmg, ax * push, ay * push, S.comboStep == 3 and 0.18 or 0)
                    end
                end
            end
            if S.comboStep == 3 then addShake(3.5, 0.08) end
        end
    end

    function GAME.TryDash()
        if not S.inMatch or S.paused or S.gameOver then return end
        if S.dashCd > 0 then return end
        S.dashCd = 1.6 * S.cdr
        S.dashTime = 0.16
        S.invulnTime = math.max(S.invulnTime, 0.24)
        S.dashVx = S.dirX * 760
        S.dashVy = S.dirY * 760
        spawnRingFX(S.px, S.py, 36, C.TXT_GEM, 0.20)
    end

    function GAME.TrySkill()
        if not S.inMatch or S.paused or S.gameOver then return end
        if S.skillCd > 0 then return end

        local h = S.hero
        S.skillCd = h.skillCd * S.cdr
        S.skillMaxCd = S.skillCd
        addShake(6, 0.15)

        if h.id == "kiemsi" then
            -- Xoay Kiem 360
            spawnRingFX(S.px, S.py, 145, h.color, 0.30)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - S.px, e.y - S.py
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d <= 145 + e.r then
                        local nx, ny = (d > 1 and dx / d or 1), (d > 1 and dy / d or 0)
                        damageEnemy(e, math.floor(S.atk * 2.2), nx * 65, ny * 65, 0.35)
                    end
                end
            end
        elseif h.id == "satthu" then
            -- Anh Bo Dot Kich (luot nhanh va chem xuyen)
            S.dashTime = 0.20
            S.invulnTime = math.max(S.invulnTime, 0.35)
            S.dashVx = S.dirX * 880
            S.dashVy = S.dirY * 880
            spawnRingFX(S.px + S.dirX * 60, S.py + S.dirY * 60, 120, h.color, 0.26)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - (S.px + S.dirX * 65), e.y - (S.py + S.dirY * 65)
                    if math.sqrt(dx * dx + dy * dy) <= 125 + e.r then
                        damageEnemy(e, math.floor(S.atk * 2.5), S.dirX * 25, S.dirY * 25, 0.25)
                    end
                end
            end
        elseif h.id == "xathu" then
            -- Loat Dan Chum 5 tia xuyen thau
            local baseAngle = math.atan2(S.dirY, S.dirX)
            for i = -2, 2 do
                local ang = baseAngle + i * 0.18
                spawnProjectile("player", S.px, S.py, math.cos(ang) * 600, math.sin(ang) * 600, math.floor(S.atk * 1.45), 9, C.TXT_GREEN, 3)
            end
        else
            -- Chien Than: Chan Dong Mat Dat
            spawnRingFX(S.px, S.py, 175, h.color, 0.35)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - S.px, e.y - S.py
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d <= 175 + e.r then
                        local nx, ny = (d > 1 and dx / d or 1), (d > 1 and dy / d or 0)
                        damageEnemy(e, math.floor(S.atk * 2.4), nx * 45, ny * 45, 0.90)
                    end
                end
            end
        end
    end

    function GAME.TryUlt()
        if not S.inMatch or S.paused or S.gameOver then return end
        if S.fury < 100 then
            showToast("Chưa đủ 100% Nộ!", C.TXT_PURPLE)
            return
        end
        S.fury = 0
        S.invulnTime = math.max(S.invulnTime, 0.75)
        addShake(13, 0.35)
        spawnRingFX(S.px, S.py, 260, C.TXT_PURPLE, 0.45)
        spawnFloatText(S.px, S.py - 34, S.hero.ultName, C.TXT_GOLD, 16)

        -- Sat thuong bung no dien rong + ban 12 tia xung quanh
        for _, e in ipairs(S.enemies) do
            if e.hp > 0 then
                local dx, dy = e.x - S.px, e.y - S.py
                local d = math.sqrt(dx * dx + dy * dy)
                if d <= 265 + e.r then
                    local nx, ny = (d > 1 and dx / d or 1), (d > 1 and dy / d or 0)
                    damageEnemy(e, math.floor(S.atk * 4.2), nx * 70, ny * 70, 0.85)
                end
            end
        end
        for i = 1, 12 do
            local ang = (i / 12) * math.pi * 2
            spawnProjectile("player", S.px, S.py, math.cos(ang) * 520, math.sin(ang) * 520, math.floor(S.atk * 1.5), 10, C.TXT_GOLD, 2)
        end
    end

    function GAME.StartMatch()
        clearEntities()
        local st = computePlayerStats()
        S.inMatch = true
        S.paused = false
        S.gameOver = false
        S.mode = DATA.selectedMode
        S.hero = st.hero
        S.maxHp = st.maxHp
        S.hp = st.maxHp
        S.atk = st.atk
        S.spd = st.spd
        S.crit = st.crit
        S.cdr = st.cdr
        S.fury = 0
        S.px = CFG.ARENA_W * 0.5
        S.py = CFG.ARENA_H * 0.5
        S.dirX, S.dirY = 1, 0
        S.score = 0
        S.kills = 0
        S.coinsEarned = 0
        S.gemsEarned = 0
        S.combo = 0
        S.maxCombo = 0
        S.comboTimer = 0
        S.matchTime = 0
        S.attackCd = 0
        S.dashCd = 0
        S.dashTime = 0
        S.invulnTime = 0.5
        S.skillCd = 0
        S.skillMaxCd = st.hero.skillCd * st.cdr
        S.buffAtkTime = 0
        S.bossActive = false
        S.holdAttack = false

        UI.PlayerNode.BackgroundColor3 = st.hero.color
        UI.BossBar.Visible = false
        UI.PauseOverlay.Visible = false
        UI.EndOverlay.Visible = false
        UI.LobbyView.Visible = false
        UI.CombatView.Visible = true

        GAME.StartWave(1)
    end

    function GAME.EndMatch(isManualQuit)
        S.gameOver = true
        S.paused = false
        S.holdAttack = false
        UI.PauseOverlay.Visible = false

        DATA.coins = DATA.coins + S.coinsEarned
        DATA.gems = DATA.gems + S.gemsEarned
        DATA.totalKills = DATA.totalKills + S.kills
        if S.score > DATA.bestScore then DATA.bestScore = S.score end
        if S.wave > DATA.bestWave then DATA.bestWave = S.wave end
        SAVE.Write()
        refreshLobbyUI()

        if isManualQuit then
            GAME.ReturnToLobby()
            return
        end

        UI.EndTitle.Text = "TRẬN ĐẤU KẾT THÚC"
        UI.EndStats.Text = string.format(
            "Chế độ: %s  |  Đạt Ải: %d\nĐiểm số: %d  |  Combo tối đa: %d\nQuái đã hạ: %d\nThưởng nhận: +%d Xu  |  +%d KC",
            getModeById(S.mode).name, S.wave, S.score, S.maxCombo, S.kills, S.coinsEarned, S.gemsEarned
        )
        UI.EndOverlay.Visible = true
    end

    function GAME.ReturnToLobby()
        S.inMatch = false
        S.paused = false
        S.gameOver = false
        clearEntities()
        UI.CombatView.Visible = false
        UI.LobbyView.Visible = true
        refreshLobbyUI()
    end

    -- Vong lap cap nhat chinh (60 FPS, dt gioi han 0.05s)
    trackConn(RunService.RenderStepped:Connect(function(dt)
        if not S.inMatch or S.paused or S.gameOver then return end
        dt = math.min(dt, 0.05)
        S.matchTime = S.matchTime + dt

        -- Cooldowns
        if S.attackCd > 0 then S.attackCd = math.max(0, S.attackCd - dt) end
        if S.dashCd > 0 then S.dashCd = math.max(0, S.dashCd - dt) end
        if S.skillCd > 0 then S.skillCd = math.max(0, S.skillCd - dt) end
        if S.invulnTime > 0 then S.invulnTime = math.max(0, S.invulnTime - dt) end
        if S.buffAtkTime > 0 then S.buffAtkTime = math.max(0, S.buffAtkTime - dt) end
        if S.comboResetT > 0 then
            S.comboResetT = S.comboResetT - dt
            if S.comboResetT <= 0 then S.comboStep = 0 end
        end
        if S.combo > 0 then
            S.comboTimer = S.comboTimer - dt
            if S.comboTimer <= 0 then S.combo = 0 end
        end
        if S.waveBannerTimer > 0 then
            S.waveBannerTimer = S.waveBannerTimer - dt
            UI.WaveBanner.Visible = (S.waveBannerTimer > 0)
        end

        -- Giu nut danh de auto-combo
        if S.holdAttack and S.attackCd <= 0 then
            GAME.TryAttack()
        end

        -- Di chuyen nguoi choi
        if S.dashTime > 0 then
            S.dashTime = S.dashTime - dt
            S.px = math.clamp(S.px + S.dashVx * dt, CFG.PLAYER_R, CFG.ARENA_W - CFG.PLAYER_R)
            S.py = math.clamp(S.py + S.dashVy * dt, CFG.PLAYER_R, CFG.ARENA_H - CFG.PLAYER_R)
        else
            local mx, my = 0, 0
            if S.keys.A then mx = mx - 1 end
            if S.keys.D then mx = mx + 1 end
            if S.keys.W then my = my - 1 end
            if S.keys.S then my = my + 1 end
            if S.joyActive then
                mx = S.joyX
                my = S.joyY
            end
            local len = math.sqrt(mx * mx + my * my)
            if len > 0.05 then
                local nx, ny = mx / math.max(1, len), my / math.max(1, len)
                S.px = math.clamp(S.px + nx * S.spd * dt, CFG.PLAYER_R, CFG.ARENA_W - CFG.PLAYER_R)
                S.py = math.clamp(S.py + ny * S.spd * dt, CFG.PLAYER_R, CFG.ARENA_H - CFG.PLAYER_R)
                S.dirX, S.dirY = mx / len, my / len
            end
        end

        -- Spawn quai theo dot
        if S.enemiesToSpawn > 0 then
            S.spawnTimer = S.spawnTimer - dt
            if S.spawnTimer <= 0 then
                S.enemiesToSpawn = S.enemiesToSpawn - 1
                S.spawnTimer = math.max(0.32, 1.15 - S.wave * 0.04)
                local roll = RNG:NextNumber()
                local kind = "grunt"
                if S.wave >= 2 and roll < 0.25 then
                    kind = "runner"
                elseif S.wave >= 3 and roll < 0.48 then
                    kind = "shooter"
                elseif S.wave >= 4 and roll < 0.66 then
                    kind = "tank"
                end
                spawnEnemy(kind, S.wave)
            end
        end

        -- Cap nhat quai & Boss AI
        local aliveCount = 0
        for i = #S.enemies, 1, -1 do
            local e = S.enemies[i]
            if e.hp <= 0 then
                table.remove(S.enemies, i)
            else
                aliveCount = aliveCount + 1
                if e.flashT > 0 then
                    e.flashT = e.flashT - dt
                    e.ui.BackgroundColor3 = (e.flashT > 0) and C.TXT_MAIN or e.baseCol
                end
                if e.stunT > 0 then
                    e.stunT = e.stunT - dt
                else
                    local dx, dy = S.px - e.x, S.py - e.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local nx, ny = (dist > 1 and dx / dist or 0), (dist > 1 and dy / dist or 0)

                    if e.kind == "shooter" and dist < 210 then
                        -- Xa thu giu khoang cach va ban dan
                        e.x = math.clamp(e.x - nx * e.spd * 0.4 * dt, 24, CFG.ARENA_W - 24)
                        e.y = math.clamp(e.y - ny * e.spd * 0.4 * dt, 24, CFG.ARENA_H - 24)
                    else
                        e.x = math.clamp(e.x + nx * e.spd * dt, 24, CFG.ARENA_W - 24)
                        e.y = math.clamp(e.y + ny * e.spd * dt, 24, CFG.ARENA_H - 24)
                    end

                    -- Tan cong xa thu
                    if e.kind == "shooter" then
                        e.atkCd = e.atkCd - dt
                        if e.atkCd <= 0 then
                            e.atkCd = 1.9
                            spawnProjectile("enemy", e.x, e.y, nx * 290, ny * 290, e.dmg, 7, C.TXT_PURPLE, 0)
                        end
                    end

                    -- Ky nang dac biet cua Boss
                    if e.isBoss then
                        e.bossSkillCd = e.bossSkillCd - dt
                        if e.bossSkillCd <= 0 then
                            e.bossSkillCd = 3.6
                            if RNG:NextNumber() < 0.5 then
                                -- Ban vong dan 8 huong
                                for k = 1, 8 do
                                    local a = (k / 8) * math.pi * 2 + S.matchTime
                                    spawnProjectile("enemy", e.x, e.y, math.cos(a) * 260, math.sin(a) * 260, e.dmg, 8, C.TXT_RED, 0)
                                end
                            else
                                -- Tha 2 vung no canh bao duoi chan nguoi choi
                                spawnHazard(S.px, S.py, 78, 1.05, math.floor(e.dmg * 1.35))
                                spawnHazard(
                                    math.clamp(S.px + RNG:NextNumber(-120, 120), 80, CFG.ARENA_W - 80),
                                    math.clamp(S.py + RNG:NextNumber(-90, 90), 80, CFG.ARENA_H - 80),
                                    72, 1.15, math.floor(e.dmg * 1.2)
                                )
                            end
                        end
                    end

                    -- Va cham gay sat thuong nguoi choi
                    if dist < (e.r + CFG.PLAYER_R - 4) then
                        damagePlayer(e.dmg)
                    end
                end
                e.ui.Position = toScalePos(e.x, e.y)
            end
        end

        -- Chuyen ai khi het quai
        if S.enemiesToSpawn <= 0 and aliveCount == 0 then
            S.nextWaveTimer = S.nextWaveTimer + dt
            if S.nextWaveTimer >= 1.1 then
                S.nextWaveTimer = 0
                S.hp = math.min(S.maxHp, S.hp + math.floor(S.maxHp * 0.15))
                GAME.StartWave(S.wave + 1)
            end
        end

        -- Cap nhat dan bay
        for i = #S.projs, 1, -1 do
            local p = S.projs[i]
            p.life = p.life - dt
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            local dead = (p.life <= 0) or (p.x < 0) or (p.x > CFG.ARENA_W) or (p.y < 0) or (p.y > CFG.ARENA_H)

            if not dead then
                if p.owner == "player" then
                    for _, e in ipairs(S.enemies) do
                        if e.hp > 0 and not p.hitMap[e] then
                            local d = math.sqrt((e.x - p.x) ^ 2 + (e.y - p.y) ^ 2)
                            if d <= (p.r + e.r) then
                                p.hitMap[e] = true
                                damageEnemy(e, p.dmg, p.vx * 0.02, p.vy * 0.02, 0)
                                if p.pierce > 0 then
                                    p.pierce = p.pierce - 1
                                else
                                    dead = true
                                    break
                                end
                            end
                        end
                    end
                else
                    local d = math.sqrt((S.px - p.x) ^ 2 + (S.py - p.y) ^ 2)
                    if d <= (p.r + CFG.PLAYER_R - 2) then
                        damagePlayer(p.dmg)
                        dead = true
                    end
                end
            end

            if dead then
                p.ui:Destroy()
                table.remove(S.projs, i)
            else
                p.ui.Position = toScalePos(p.x, p.y)
            end
        end

        -- Cap nhat vung no Boss
        for i = #S.hazards, 1, -1 do
            local h = S.hazards[i]
            h.timer = h.timer - dt
            local ratio = 1 - math.clamp(h.timer / h.maxTimer, 0, 1)
            h.ui.BackgroundTransparency = 0.82 - ratio * 0.45
            if h.timer <= 0 then
                spawnRingFX(h.x, h.y, h.r, C.TXT_RED, 0.24)
                local d = math.sqrt((S.px - h.x) ^ 2 + (S.py - h.y) ^ 2)
                if d <= h.r + CFG.PLAYER_R * 0.5 then
                    damagePlayer(h.dmg)
                end
                h.ui:Destroy()
                table.remove(S.hazards, i)
            end
        end

        -- Cap nhat vat pham nhat tren san
        for i = #S.pickups, 1, -1 do
            local pk = S.pickups[i]
            pk.life = pk.life - dt
            local d = math.sqrt((S.px - pk.x) ^ 2 + (S.py - pk.y) ^ 2)
            if d <= CFG.PLAYER_R + 18 then
                if pk.kind == "heal" then
                    local heal = math.floor(S.maxHp * 0.25)
                    S.hp = math.min(S.maxHp, S.hp + heal)
                    spawnFloatText(S.px, S.py - 20, "+" .. tostring(heal) .. " HP", C.TXT_GREEN, 13)
                elseif pk.kind == "fury" then
                    S.fury = math.min(100, S.fury + 40)
                    spawnFloatText(S.px, S.py - 20, "+40% NỘ", C.TXT_GOLD, 13)
                else
                    S.buffAtkTime = 8.0
                    spawnFloatText(S.px, S.py - 20, "+35% ATK (8s)", C.TXT_RED, 13)
                end
                pk.ui:Destroy()
                table.remove(S.pickups, i)
            elseif pk.life <= 0 then
                pk.ui:Destroy()
                table.remove(S.pickups, i)
            end
        end

        -- Cap nhat hieu ung vong no & chu bay
        for i = #S.effects, 1, -1 do
            local fx = S.effects[i]
            fx.life = fx.life - dt
            if fx.life <= 0 then
                fx.ui:Destroy()
                table.remove(S.effects, i)
            else
                local prog = 1 - (fx.life / fx.maxLife)
                local curR = fx.maxR * (0.35 + prog * 0.65)
                fx.ui.Size = UDim2.new((curR * 2) / CFG.ARENA_W, 0, (curR * 2) / CFG.ARENA_H, 0)
                fx.ui.BackgroundTransparency = 0.65 + prog * 0.35
            end
        end

        for i = #S.floatTexts, 1, -1 do
            local ft = S.floatTexts[i]
            ft.life = ft.life - dt
            if ft.life <= 0 then
                ft.ui:Destroy()
                table.remove(S.floatTexts, i)
            else
                ft.y = ft.y + ft.vy * dt
                ft.ui.Position = toScalePos(ft.x, ft.y)
                ft.ui.TextTransparency = 1 - (ft.life / ft.maxLife)
            end
        end

        -- Rung man hinh khi ra chieu manh
        if S.shakeTimer > 0 then
            S.shakeTimer = S.shakeTimer - dt
            local ox = RNG:NextNumber(-S.shakePower, S.shakePower)
            local oy = RNG:NextNumber(-S.shakePower, S.shakePower)
            UI.Arena.Position = UDim2.new(0, 8 + ox, 0, 44 + oy)
            if S.shakeTimer <= 0 then
                S.shakePower = 0
                UI.Arena.Position = UDim2.new(0, 8, 0, 44)
            end
        end

        -- Cap nhat vi tri nguoi choi & HUD
        UI.PlayerNode.Position = toScalePos(S.px, S.py)
        UI.PlayerNode.BackgroundTransparency = (S.invulnTime > 0) and 0.45 or 0
        UI.PlayerDir.Position = UDim2.new(0.5 + S.dirX * 0.42, 0, 0.5 + S.dirY * 0.42, 0)

        UI.HpFill.Size = UDim2.new(math.clamp(S.hp / math.max(1, S.maxHp), 0, 1), 0, 1, 0)
        UI.HpText.Text = string.format("HP %d/%d", math.floor(S.hp), S.maxHp)
        UI.FuryFill.Size = UDim2.new(math.clamp(S.fury / 100, 0, 1), 0, 1, 0)
        UI.HudWave.Text = "Ải " .. tostring(S.wave)
        UI.HudScore.Text = "Điểm: " .. tostring(S.score)
        UI.HudCombo.Text = (S.combo >= 2) and ("COMBO x" .. tostring(S.combo)) or ""

        UI.DashBtn.Text = (S.dashCd > 0) and string.format("%.1fs", S.dashCd) or "LƯỚT"
        UI.SkillBtn.Text = (S.skillCd > 0) and string.format("%.1fs", S.skillCd) or "KỸ NĂNG"
        UI.UltBtn.Text = (S.fury >= 100) and "TUYỆT CHIÊU" or (tostring(math.floor(S.fury)) .. "% NỘ")
    end))
end

-- ============================================================================
-- 10. HO TRO PHIM PC (WASD / MUI TEN / J / K / L / U)
-- ============================================================================
do
    trackConn(UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or not S.inMatch or S.paused or S.gameOver then return end
        local kc = inp.KeyCode
        if kc == Enum.KeyCode.W or kc == Enum.KeyCode.Up then S.keys.W = true
        elseif kc == Enum.KeyCode.S or kc == Enum.KeyCode.Down then S.keys.S = true
        elseif kc == Enum.KeyCode.A or kc == Enum.KeyCode.Left then S.keys.A = true
        elseif kc == Enum.KeyCode.D or kc == Enum.KeyCode.Right then S.keys.D = true
        elseif kc == Enum.KeyCode.J or kc == Enum.KeyCode.Space then
            S.holdAttack = true
            GAME.TryAttack()
        elseif kc == Enum.KeyCode.K or kc == Enum.KeyCode.LeftShift then
            GAME.TryDash()
        elseif kc == Enum.KeyCode.L or kc == Enum.KeyCode.Q then
            GAME.TrySkill()
        elseif kc == Enum.KeyCode.U or kc == Enum.KeyCode.E then
            GAME.TryUlt()
        end
    end))

    trackConn(UserInputService.InputEnded:Connect(function(inp)
        local kc = inp.KeyCode
        if kc == Enum.KeyCode.W or kc == Enum.KeyCode.Up then S.keys.W = false
        elseif kc == Enum.KeyCode.S or kc == Enum.KeyCode.Down then S.keys.S = false
        elseif kc == Enum.KeyCode.A or kc == Enum.KeyCode.Left then S.keys.A = false
        elseif kc == Enum.KeyCode.D or kc == Enum.KeyCode.Right then S.keys.D = false
        elseif kc == Enum.KeyCode.J or kc == Enum.KeyCode.Space then
            S.holdAttack = false
        end
    end))
end

-- ============================================================================
-- 11. HAM DON DEP & KHOI TAO BAN DAU
-- ============================================================================
_G.ArenaChienDau_Cleanup = function()
    S.inMatch = false
    for _, conn in ipairs(CONNS) do
        pcall(function() conn:Disconnect() end)
    end
    CONNS = {}
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

refreshLobbyUI()
showToast("Chào mừng đến Đấu Trường Chiến Đấu Pro " .. CFG.VERSION, C.TXT_GOLD)
