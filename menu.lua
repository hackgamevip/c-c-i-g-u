-- ============================================================================
-- DAU TRUONG CHIEN DAU PRO (v1.1) - Standalone Combat Mini-Game (Mobile & PC)
-- Ban cap nhat Do Hoa: Nhan vat co vu khi xoay/vung, Quai & Boss da lop,
-- San dau co dai, Tan anh luot, Tia lua va cham, VFX don danh & HUD nang cap.
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
    BG_MAIN      = Color3.fromRGB(16, 19, 25),
    BG_PANEL     = Color3.fromRGB(24, 28, 36),
    BG_PANEL_TOP = Color3.fromRGB(32, 37, 48),
    BG_CARD      = Color3.fromRGB(31, 36, 46),
    BG_CARD_ALT  = Color3.fromRGB(40, 47, 60),
    BG_ARENA     = Color3.fromRGB(23, 27, 35),
    BG_ARENA_IN  = Color3.fromRGB(29, 34, 44),
    BG_ARENA_G   = Color3.fromRGB(36, 42, 54),
    STONE_DARK   = Color3.fromRGB(44, 50, 62),
    STONE_LIGHT  = Color3.fromRGB(64, 72, 86),
    BORDER       = Color3.fromRGB(58, 66, 80),
    BORDER_ACT   = Color3.fromRGB(112, 154, 188),
    SHADOW       = Color3.fromRGB(8, 10, 14),

    -- Mau chu matte (tat ca kenh RGB <= 210 de tranh loe sang tren mobile)
    TXT_MAIN     = Color3.fromRGB(204, 209, 214),
    TXT_SUB      = Color3.fromRGB(148, 156, 168),
    TXT_GOLD     = Color3.fromRGB(204, 174, 98),
    TXT_GEM      = Color3.fromRGB(112, 178, 198),
    TXT_RED      = Color3.fromRGB(202, 108, 108),
    TXT_GREEN    = Color3.fromRGB(112, 186, 134),
    TXT_PURPLE   = Color3.fromRGB(168, 136, 202),
    TXT_DARK     = Color3.fromRGB(20, 24, 30),

    -- Mau nut & thanh trang thai
    BTN_PRIMARY  = Color3.fromRGB(52, 106, 148),
    BTN_SUCCESS  = Color3.fromRGB(46, 120, 80),
    BTN_DANGER   = Color3.fromRGB(148, 54, 54),
    BTN_WARN     = Color3.fromRGB(152, 114, 46),
    BTN_PURPLE   = Color3.fromRGB(104, 70, 146),
    BTN_NEUTRAL  = Color3.fromRGB(44, 50, 62),

    -- Mau thuc the & hieu ung trong dau truong
    HP_FILL      = Color3.fromRGB(62, 164, 96),
    HP_ENEMY     = Color3.fromRGB(182, 70, 70),
    HP_BOSS      = Color3.fromRGB(160, 62, 140),
    FURY_FILL    = Color3.fromRGB(194, 140, 52),
    WARN_ZONE    = Color3.fromRGB(176, 62, 62),
    SLASH_FX     = Color3.fromRGB(188, 200, 210),
    METAL_LIGHT  = Color3.fromRGB(174, 184, 196),
    METAL_DARK   = Color3.fromRGB(82, 92, 108),
    EMBER        = Color3.fromRGB(196, 118, 54),
}

local FONT_TITLE = Enum.Font.GothamSemibold
local FONT_BODY  = Enum.Font.GothamMedium

-- ============================================================================
-- 2. DU LIEU GAME (TUONG, CHE DO, NANG CAP, MA QUA)
-- ============================================================================
local CFG = {
    VERSION = "v1.1",
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
        color = Color3.fromRGB(78, 142, 192),
        trim = Color3.fromRGB(194, 166, 92),
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
        color = Color3.fromRGB(130, 88, 178),
        trim = Color3.fromRGB(186, 102, 134),
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
        color = Color3.fromRGB(68, 152, 114),
        trim = Color3.fromRGB(118, 182, 196),
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
        color = Color3.fromRGB(178, 118, 56),
        trim = Color3.fromRGB(204, 174, 98),
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
    { id = "atk",  name = "Sức Mạnh",  stat = "+15% Sát thương",  baseCost = 100, step = 85,  maxLv = 15 },
    { id = "hp",   name = "Sinh Lực",  stat = "+20% Máu tối đa",  baseCost = 90,  step = 75,  maxLv = 15 },
    { id = "spd",  name = "Tốc Độ",    stat = "+5% Di chuyển",    baseCost = 110, step = 90,  maxLv = 10 },
    { id = "crit", name = "Chí Mạng",  stat = "+3% Tỷ lệ Crit",   baseCost = 120, step = 100, maxLv = 12 },
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

    if type(isfile) == "function" and type(readfile) == "function" then
        local ok, raw = pcall(function()
            local fname = getSaveFileName()
            if isfile(fname) then return readfile(fname) end
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

    if not loaded then
        local env = (type(getgenv) == "function" and getgenv()) or _G
        if type(env.ArenaChienDau_SaveData) == "table" then
            loaded = env.ArenaChienDau_SaveData
        end
    end

    if type(loaded) == "table" then
        for k, v in pairs(def) do
            if loaded[k] == nil then loaded[k] = v end
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
            writefile(getSaveFileName(), HttpService:JSONEncode(DATA))
        end)
    end
end

SAVE.Load()

-- ============================================================================
-- 4. TIEN ICH TAO UI & DO HOA VECTOR (SPRITES TU VE BANG FRAME)
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
    return {
        hero = h,
        maxHp = math.floor(h.hp * (1 + (u.hp or 0) * 0.20)),
        atk = math.floor(h.atk * (1 + (u.atk or 0) * 0.15)),
        spd = math.floor(h.spd * (1 + (u.spd or 0) * 0.05)),
        crit = math.min(0.75, h.crit + (u.crit or 0) * 0.03),
        cdr = math.max(0.55, 1 - (u.cdr or 0) * 0.04),
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

local function addGradient(inst, topCol, botCol, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, topCol),
        ColorSequenceKeypoint.new(1, botCol),
    })
    g.Rotation = rot or 90
    g.Parent = inst
    return g
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

-- Ve nhan vat tuong (da lop: bong do, giap vai, mu/kinh, vu khi rieng theo class)
local function buildHeroAvatar(container, hero, zBase)
    for _, ch in ipairs(container:GetChildren()) do
        if ch.Name == "HeroArt" then ch:Destroy() end
    end

    local art = Instance.new("Frame")
    art.Name = "HeroArt"
    art.AnchorPoint = Vector2.new(0.5, 0.5)
    art.Position = UDim2.new(0.5, 0, 0.5, 0)
    art.Size = UDim2.new(1, 0, 1, 0)
    art.BackgroundTransparency = 1
    art.ZIndex = zBase
    art.Parent = container

    -- Bong do duoi chan
    local shadow = Instance.new("Frame")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 2, 0.62, 3)
    shadow.Size = UDim2.new(0.95, 0, 0.65, 0)
    shadow.BackgroundColor3 = C.SHADOW
    shadow.BackgroundTransparency = 0.45
    shadow.BorderSizePixel = 0
    shadow.ZIndex = zBase
    shadow.Parent = art
    addCorner(shadow, 999)

    -- Vai giap / Ao choang
    local shoulders = Instance.new("Frame")
    shoulders.AnchorPoint = Vector2.new(0.5, 0.5)
    shoulders.Position = UDim2.new(0.45, 0, 0.5, 0)
    shoulders.Size = UDim2.new(0.76, 0, 0.96, 0)
    shoulders.BackgroundColor3 = hero.color
    shoulders.BorderSizePixel = 0
    shoulders.ZIndex = zBase + 1
    shoulders.Parent = art
    addCorner(shoulders, 8)
    addStroke(shoulders, hero.trim, 1.5)

    -- Dau / Mu chien binh
    local head = Instance.new("Frame")
    head.AnchorPoint = Vector2.new(0.5, 0.5)
    head.Position = UDim2.new(0.52, 0, 0.5, 0)
    head.Size = UDim2.new(0.62, 0, 0.62, 0)
    head.BackgroundColor3 = C.STONE_DARK
    head.BorderSizePixel = 0
    head.ZIndex = zBase + 2
    head.Parent = art
    addCorner(head, 999)
    addStroke(head, hero.trim, 1.2)

    -- Kinh mu (chi huong nhin sang phai theo goc 0 do)
    local visor = Instance.new("Frame")
    visor.AnchorPoint = Vector2.new(0.5, 0.5)
    visor.Position = UDim2.new(0.76, 0, 0.5, 0)
    visor.Size = UDim2.new(0.28, 0, 0.50, 0)
    visor.BackgroundColor3 = hero.trim
    visor.BorderSizePixel = 0
    visor.ZIndex = zBase + 3
    visor.Parent = head
    addCorner(visor, 3)

    -- Khop vu khi (xoay khi vung danh)
    local weaponPivot = Instance.new("Frame")
    weaponPivot.Name = "WeaponPivot"
    weaponPivot.AnchorPoint = Vector2.new(0.5, 0.5)
    weaponPivot.Position = UDim2.new(0.55, 0, 0.5, 0)
    weaponPivot.Size = UDim2.new(1, 0, 1, 0)
    weaponPivot.BackgroundTransparency = 1
    weaponPivot.ZIndex = zBase + 3
    weaponPivot.Parent = art

    if hero.id == "kiemsi" then
        -- Dai kiem + chan kiem vang
        local guard = Instance.new("Frame")
        guard.AnchorPoint = Vector2.new(0.5, 0.5)
        guard.Position = UDim2.new(0.95, 0, 0.80, 0)
        guard.Size = UDim2.new(0.14, 0, 0.44, 0)
        guard.BackgroundColor3 = hero.trim
        guard.BorderSizePixel = 0
        guard.ZIndex = zBase + 4
        guard.Parent = weaponPivot
        addCorner(guard, 2)

        local blade = Instance.new("Frame")
        blade.AnchorPoint = Vector2.new(0, 0.5)
        blade.Position = UDim2.new(0.98, 0, 0.80, 0)
        blade.Size = UDim2.new(0.78, 0, 0.16, 0)
        blade.BackgroundColor3 = C.METAL_LIGHT
        blade.BorderSizePixel = 0
        blade.ZIndex = zBase + 3
        blade.Parent = weaponPivot
        addCorner(blade, 3)
        addStroke(blade, C.METAL_DARK, 1)
    elseif hero.id == "satthu" then
        -- Song dao sac ben hai ben tay
        for _, yOff in ipairs({ 0.14, 0.86 }) do
            local dagger = Instance.new("Frame")
            dagger.AnchorPoint = Vector2.new(0, 0.5)
            dagger.Position = UDim2.new(0.78, 0, yOff, 0)
            dagger.Size = UDim2.new(0.60, 0, 0.13, 0)
            dagger.BackgroundColor3 = C.METAL_LIGHT
            dagger.Rotation = (yOff < 0.5) and -12 or 12
            dagger.BorderSizePixel = 0
            dagger.ZIndex = zBase + 3
            dagger.Parent = weaponPivot
            addCorner(dagger, 2)
            addStroke(dagger, hero.trim, 1)
        end
    elseif hero.id == "xathu" then
        -- Sung nang luong co nong phat sang matte
        local barrel = Instance.new("Frame")
        barrel.AnchorPoint = Vector2.new(0, 0.5)
        barrel.Position = UDim2.new(0.72, 0, 0.5, 0)
        barrel.Size = UDim2.new(0.84, 0, 0.22, 0)
        barrel.BackgroundColor3 = C.METAL_DARK
        barrel.BorderSizePixel = 0
        barrel.ZIndex = zBase + 3
        barrel.Parent = weaponPivot
        addCorner(barrel, 3)
        addStroke(barrel, hero.trim, 1)

        local muzzle = Instance.new("Frame")
        muzzle.AnchorPoint = Vector2.new(0.5, 0.5)
        muzzle.Position = UDim2.new(0.95, 0, 0.5, 0)
        muzzle.Size = UDim2.new(0.20, 0, 0.60, 0)
        muzzle.BackgroundColor3 = hero.trim
        muzzle.BorderSizePixel = 0
        muzzle.ZIndex = zBase + 4
        muzzle.Parent = barrel
        addCorner(muzzle, 2)
    else
        -- Chien Than: Bua chien khong lo + sung giap
        local shaft = Instance.new("Frame")
        shaft.AnchorPoint = Vector2.new(0, 0.5)
        shaft.Position = UDim2.new(0.75, 0, 0.78, 0)
        shaft.Size = UDim2.new(0.72, 0, 0.14, 0)
        shaft.BackgroundColor3 = C.METAL_DARK
        shaft.BorderSizePixel = 0
        shaft.ZIndex = zBase + 3
        shaft.Parent = weaponPivot

        local hammer = Instance.new("Frame")
        hammer.AnchorPoint = Vector2.new(0.5, 0.5)
        hammer.Position = UDim2.new(1.42, 0, 0.78, 0)
        hammer.Size = UDim2.new(0.32, 0, 0.56, 0)
        hammer.BackgroundColor3 = hero.trim
        hammer.BorderSizePixel = 0
        hammer.ZIndex = zBase + 4
        hammer.Parent = weaponPivot
        addCorner(hammer, 4)
        addStroke(hammer, C.STONE_DARK, 1.2)
    end

    return art, weaponPivot
end

-- Ve quai & Boss phan biet theo chung loai
local function decorateEnemyNode(node, kind, col, isBoss, zBase)
    -- Bong do duoi chan
    local sh = Instance.new("Frame")
    sh.AnchorPoint = Vector2.new(0.5, 0.5)
    sh.Position = UDim2.new(0.5, 2, 0.65, 3)
    sh.Size = UDim2.new(1.02, 0, 0.68, 0)
    sh.BackgroundColor3 = C.SHADOW
    sh.BackgroundTransparency = 0.45
    sh.BorderSizePixel = 0
    sh.ZIndex = zBase - 1
    sh.Parent = node
    addCorner(sh, 999)

    if isBoss then
        -- Boss: Giap loi + Vuong mien sung + Vong hao quang
        local aura = Instance.new("Frame")
        aura.Name = "BossAura"
        aura.AnchorPoint = Vector2.new(0.5, 0.5)
        aura.Position = UDim2.new(0.5, 0, 0.5, 0)
        aura.Size = UDim2.new(1.42, 0, 1.42, 0)
        aura.BackgroundColor3 = C.HP_BOSS
        aura.BackgroundTransparency = 0.84
        aura.BorderSizePixel = 0
        aura.ZIndex = zBase - 1
        aura.Parent = node
        addCorner(aura, 999)
        addStroke(aura, C.TXT_GOLD, 1.5)

        local core = Instance.new("Frame")
        core.AnchorPoint = Vector2.new(0.5, 0.5)
        core.Position = UDim2.new(0.5, 0, 0.5, 0)
        core.Size = UDim2.new(0.46, 0, 0.46, 0)
        core.BackgroundColor3 = C.TXT_GOLD
        core.Rotation = 45
        core.BorderSizePixel = 0
        core.ZIndex = zBase + 2
        core.Parent = node
        addCorner(core, 4)

        for _, xPos in ipairs({ 0.20, 0.80 }) do
            local horn = Instance.new("Frame")
            horn.AnchorPoint = Vector2.new(0.5, 1)
            horn.Position = UDim2.new(xPos, 0, 0.08, 0)
            horn.Size = UDim2.new(0.18, 0, 0.34, 0)
            horn.BackgroundColor3 = C.TXT_GOLD
            horn.Rotation = (xPos < 0.5) and -24 or 24
            horn.BorderSizePixel = 0
            horn.ZIndex = zBase + 2
            horn.Parent = node
            addCorner(horn, 2)
        end
    elseif kind == "runner" then
        -- Quai sat thu: Hinh thoi nhon sac
        node.Rotation = 45
        local eye = Instance.new("Frame")
        eye.AnchorPoint = Vector2.new(0.5, 0.5)
        eye.Position = UDim2.new(0.5, 0, 0.5, 0)
        eye.Size = UDim2.new(0.42, 0, 0.42, 0)
        eye.BackgroundColor3 = C.TXT_GOLD
        eye.BorderSizePixel = 0
        eye.ZIndex = zBase + 1
        eye.Parent = node
        addCorner(eye, 3)
    elseif kind == "shooter" then
        -- Quai xa thu: Loi pha le tim + vien sang
        local orb = Instance.new("Frame")
        orb.AnchorPoint = Vector2.new(0.5, 0.5)
        orb.Position = UDim2.new(0.5, 0, 0.5, 0)
        orb.Size = UDim2.new(0.46, 0, 0.46, 0)
        orb.BackgroundColor3 = C.TXT_PURPLE
        orb.BorderSizePixel = 0
        orb.ZIndex = zBase + 1
        orb.Parent = node
        addCorner(orb, 999)
    elseif kind == "tank" then
        -- Quai khong lo: Tam giap thep day ben trong
        local plate = Instance.new("Frame")
        plate.AnchorPoint = Vector2.new(0.5, 0.5)
        plate.Position = UDim2.new(0.5, 0, 0.5, 0)
        plate.Size = UDim2.new(0.68, 0, 0.68, 0)
        plate.BackgroundColor3 = C.STONE_DARK
        plate.BorderSizePixel = 0
        plate.ZIndex = zBase + 1
        plate.Parent = node
        addCorner(plate, 5)
        addStroke(plate, C.METAL_LIGHT, 1.5)
    else
        -- Linh thuong: Mat do nhin ro
        local visor = Instance.new("Frame")
        visor.AnchorPoint = Vector2.new(0.5, 0.5)
        visor.Position = UDim2.new(0.5, 0, 0.45, 0)
        visor.Size = UDim2.new(0.55, 0, 0.22, 0)
        visor.BackgroundColor3 = C.TXT_DARK
        visor.BorderSizePixel = 0
        visor.ZIndex = zBase + 1
        visor.Parent = node
        addCorner(visor, 2)
    end
end

local function mountScreenGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = CFG.GUI_NAME
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
    swingT = 0,
    swingSign = 1,
    comboStep = 0,
    comboResetT = 0,
    dashCd = 0,
    dashTime = 0,
    dashGhostT = 0,
    dashVx = 0,
    dashVy = 0,
    invulnTime = 0,
    skillCd = 0,
    skillMaxCd = 5.0,
    buffAtkTime = 0,
    hero = CFG.HEROES[1],

    -- Input
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
    sparks = {},
    hazards = {},
    floatTexts = {},
    braziers = {},
}

-- ============================================================================
-- 6. XAY DUNG GIAO DIEN CHINH (HEADER + TOAST + NUT MO NHANH)
-- ============================================================================
local ScreenGui = mountScreenGui()
UI.ScreenGui = ScreenGui

do
    local toggleBtn = makeBtn(ScreenGui, {
        text = "CHIẾN ĐẤU",
        bg = C.BG_PANEL,
        color = C.TXT_GOLD,
        size = 13,
        dim = UDim2.new(0, 112, 0, 34),
        pos = UDim2.new(1, -124, 0, 52),
        radius = 10,
        strokeColor = C.BORDER_ACT,
        strokeWidth = 1.5,
        z = 50,
    })
    addGradient(toggleBtn, C.BG_PANEL_TOP, C.BG_MAIN, 90)
    UI.ToggleBtn = toggleBtn

    local dragging, dragStart, startPos, moved = false, nil, nil, false
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
                    UI.PauseOverlay.Visible = true
                end
            end
        end
    end))
end

do
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.52, 0)
    main.Size = UDim2.new(0.92, 0, 0.85, 0)
    main.BackgroundColor3 = C.BG_MAIN
    main.ClipsDescendants = true
    main.ZIndex = 1
    main.Parent = ScreenGui
    addCorner(main, 12)
    addStroke(main, C.BORDER_ACT, 1.5)

    local sc = Instance.new("UISizeConstraint")
    sc.MinSize = Vector2.new(540, 340)
    sc.MaxSize = Vector2.new(930, 565)
    sc.Parent = main
    UI.MainFrame = main

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = C.BG_PANEL
    header.BorderSizePixel = 0
    header.ZIndex = 5
    header.Parent = main
    addGradient(header, C.BG_PANEL_TOP, C.BG_PANEL, 90)

    local hLine = Instance.new("Frame")
    hLine.Position = UDim2.new(0, 0, 1, -1)
    hLine.Size = UDim2.new(1, 0, 0, 1)
    hLine.BackgroundColor3 = C.BORDER
    hLine.BorderSizePixel = 0
    hLine.ZIndex = 6
    hLine.Parent = header

    -- Huy hieu nho ben trai tieu de
    local badge = Instance.new("Frame")
    badge.Position = UDim2.new(0, 12, 0.5, -10)
    badge.Size = UDim2.new(0, 20, 0, 20)
    badge.BackgroundColor3 = C.BTN_DANGER
    badge.Rotation = 45
    badge.ZIndex = 6
    badge.Parent = header
    addCorner(badge, 4)
    addStroke(badge, C.TXT_GOLD, 1.5)

    makeLabel(header, {
        text = "ĐẤU TRƯỜNG CHIẾN ĐẤU PRO  " .. CFG.VERSION,
        font = FONT_TITLE,
        color = C.TXT_MAIN,
        size = 15,
        dim = UDim2.new(0, 300, 1, 0),
        pos = UDim2.new(0, 42, 0, 0),
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
            UI.PauseOverlay.Visible = true
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
        if _G.ArenaChienDau_Cleanup then _G.ArenaChienDau_Cleanup() end
    end)

    local toast = Instance.new("Frame")
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0, 50)
    toast.Size = UDim2.new(0, 350, 0, 32)
    toast.BackgroundColor3 = C.BG_CARD_ALT
    toast.Visible = false
    toast.ZIndex = 40
    toast.Parent = main
    addCorner(toast, 8)
    addStroke(toast, C.BORDER_ACT, 1.2)

    UI.Toast = toast
    UI.ToastLbl = makeLabel(toast, {
        text = "",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 13,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, -16, 1, 0),
        pos = UDim2.new(0, 8, 0, 0),
        z = 41,
    })
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
-- 7. MAN HINH SANH CHO (LOBBY NANG CAP DO HOA)
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
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ZIndex = 3
        p.Parent = contentHolder
        UI.TabPages[td.id] = p

        bindTap(b, function() switchLobbyTab(td.id) end)
    end

    -- TAB 1: VAO TRAN
    do
        local p = UI.TabPages.play
        makeLabel(p, {
            text = "CHỌN CHẾ ĐỘ CHIẾN ĐẤU",
            font = FONT_TITLE,
            color = C.TXT_SUB,
            size = 12,
            dim = UDim2.new(1, 0, 0, 20),
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
            addGradient(card, C.BG_CARD_ALT, C.BG_PANEL, 120)

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

            UI.ModeCards[m.id] = { card = card, stroke = card:FindFirstChildOfClass("UIStroke") }
            bindTap(card, function()
                DATA.selectedMode = m.id
                SAVE.Write()
                refreshLobbyUI()
            end)
        end

        local infoBox = Instance.new("Frame")
        infoBox.Position = UDim2.new(0, 0, 0, 152)
        infoBox.Size = UDim2.new(1, 0, 1, -216)
        infoBox.BackgroundColor3 = C.BG_CARD
        infoBox.ZIndex = 4
        infoBox.Parent = p
        addCorner(infoBox, 10)
        addStroke(infoBox, C.BORDER, 1)
        addGradient(infoBox, C.BG_CARD_ALT, C.BG_PANEL, 90)

        -- Khung xem truoc hinh tuong dang chon (ve bang Sprite that)
        local previewBg = Instance.new("Frame")
        previewBg.Position = UDim2.new(0, 14, 0.5, -28)
        previewBg.Size = UDim2.new(0, 56, 0, 56)
        previewBg.BackgroundColor3 = C.BG_ARENA
        previewBg.ZIndex = 5
        previewBg.Parent = infoBox
        addCorner(previewBg, 28)
        addStroke(previewBg, C.BORDER_ACT, 1.5)

        local previewHolder = Instance.new("Frame")
        previewHolder.AnchorPoint = Vector2.new(0.5, 0.5)
        previewHolder.Position = UDim2.new(0.46, 0, 0.5, 0)
        previewHolder.Size = UDim2.new(0, 30, 0, 30)
        previewHolder.BackgroundTransparency = 1
        previewHolder.ZIndex = 6
        previewHolder.Parent = previewBg
        UI.PlayHeroPreview = previewHolder

        UI.PlayHeroName = makeLabel(infoBox, {
            text = "",
            font = FONT_TITLE,
            color = C.TXT_MAIN,
            size = 15,
            dim = UDim2.new(1, -92, 0, 22),
            pos = UDim2.new(0, 82, 0, 12),
            z = 5,
        })
        UI.PlayHeroStats = makeLabel(infoBox, {
            text = "",
            font = FONT_BODY,
            color = C.TXT_GEM,
            size = 12,
            dim = UDim2.new(1, -92, 0, 20),
            pos = UDim2.new(0, 82, 0, 36),
            z = 5,
        })
        UI.PlayHeroSkills = makeLabel(infoBox, {
            text = "",
            font = FONT_BODY,
            color = C.TXT_SUB,
            size = 12,
            wrap = true,
            dim = UDim2.new(1, -92, 0, 26),
            pos = UDim2.new(0, 82, 0, 58),
            z = 5,
        })

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
        addGradient(startBtn, Color3.fromRGB(58, 144, 96), Color3.fromRGB(36, 94, 62), 90)
        bindTap(startBtn, function() GAME.StartMatch() end)
    end

    -- TAB 2: TUONG
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
        grid.CellSize = UDim2.new(0.49, -4, 0, 144)
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
            addGradient(card, C.BG_CARD_ALT, C.BG_PANEL, 110)

            local iconBg = Instance.new("Frame")
            iconBg.Position = UDim2.new(0, 10, 0, 10)
            iconBg.Size = UDim2.new(0, 42, 0, 42)
            iconBg.BackgroundColor3 = C.BG_ARENA
            iconBg.ZIndex = 5
            iconBg.Parent = card
            addCorner(iconBg, 21)
            addStroke(iconBg, h.trim, 1)

            local iconSprite = Instance.new("Frame")
            iconSprite.AnchorPoint = Vector2.new(0.5, 0.5)
            iconSprite.Position = UDim2.new(0.45, 0, 0.5, 0)
            iconSprite.Size = UDim2.new(0, 22, 0, 22)
            iconSprite.BackgroundTransparency = 1
            iconSprite.ZIndex = 6
            iconSprite.Parent = iconBg
            buildHeroAvatar(iconSprite, h, 6)

            makeLabel(card, {
                text = h.name .. " - " .. h.role,
                font = FONT_TITLE,
                color = C.TXT_MAIN,
                size = 13,
                dim = UDim2.new(1, -66, 0, 20),
                pos = UDim2.new(0, 58, 0, 10),
                z = 5,
            })
            makeLabel(card, {
                text = string.format("HP %d | ATK %d | SPD %d | CRIT %d%%", h.hp, h.atk, h.spd, math.floor(h.crit * 100)),
                font = FONT_BODY,
                color = C.TXT_GEM,
                size = 11,
                dim = UDim2.new(1, -66, 0, 18),
                pos = UDim2.new(0, 58, 0, 32),
                z = 5,
            })
            makeLabel(card, {
                text = h.desc,
                font = FONT_BODY,
                color = C.TXT_SUB,
                size = 11,
                wrap = true,
                dim = UDim2.new(1, -24, 0, 34),
                pos = UDim2.new(0, 12, 0, 58),
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
                elseif DATA.coins >= h.costCoin and DATA.gems >= h.costGem then
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
            end)
        end
    end

    -- TAB 3: NANG CAP
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
                text = "",
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
                text = "NÂNG",
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

    -- TAB 4: MA QUA & KY LUC
    do
        local p = UI.TabPages.code
        local statsCard = Instance.new("Frame")
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
    buildHeroAvatar(UI.PlayHeroPreview, st.hero, 6)
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
            if h.costGem > 0 then costTxt = costTxt .. " + " .. tostring(h.costGem) .. " KC" end
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
-- 8. MAN HINH DAU TRUONG (SAN DAU CO DAI + NHAN VAT DA LOP + HUD + NUT)
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

    -- San dau co dai (Gradient nen + Vong tron trung tam + 4 Tru lua 4 goc)
    local arena = Instance.new("Frame")
    arena.Name = "ArenaCanvas"
    arena.Position = UDim2.new(0, 8, 0, 44)
    arena.Size = UDim2.new(1, -16, 1, -52)
    arena.BackgroundColor3 = C.BG_ARENA
    arena.ClipsDescendants = true
    arena.ZIndex = 2
    arena.Parent = combat
    addCorner(arena, 10)
    addStroke(arena, C.STONE_LIGHT, 2)
    addGradient(arena, C.BG_ARENA_IN, C.BG_MAIN, 135)
    UI.Arena = arena

    -- Luoi gach da
    for i = 1, 9 do
        local vline = Instance.new("Frame")
        vline.Position = UDim2.new(i / 10, 0, 0, 0)
        vline.Size = UDim2.new(0, 1, 1, 0)
        vline.BackgroundColor3 = C.BG_ARENA_G
        vline.BackgroundTransparency = 0.45
        vline.BorderSizePixel = 0
        vline.ZIndex = 2
        vline.Parent = arena
    end
    for i = 1, 5 do
        local hline = Instance.new("Frame")
        hline.Position = UDim2.new(0, 0, i / 6, 0)
        hline.Size = UDim2.new(1, 0, 0, 1)
        hline.BackgroundColor3 = C.BG_ARENA_G
        hline.BackgroundTransparency = 0.45
        hline.BorderSizePixel = 0
        hline.ZIndex = 2
        hline.Parent = arena
    end

    -- Vong tron dau truong trung tam
    local midRing = Instance.new("Frame")
    midRing.AnchorPoint = Vector2.new(0.5, 0.5)
    midRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    midRing.Size = UDim2.new(0, 210, 0, 210)
    midRing.BackgroundColor3 = C.BG_ARENA_IN
    midRing.BackgroundTransparency = 0.72
    midRing.ZIndex = 2
    midRing.Parent = arena
    addCorner(midRing, 105)
    addStroke(midRing, C.STONE_LIGHT, 2)

    local innerRing = Instance.new("Frame")
    innerRing.AnchorPoint = Vector2.new(0.5, 0.5)
    innerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerRing.Size = UDim2.new(0, 118, 0, 118)
    innerRing.BackgroundTransparency = 1
    innerRing.ZIndex = 2
    innerRing.Parent = arena
    addCorner(innerRing, 59)
    addStroke(innerRing, C.STONE_DARK, 1.5)

    local emblem = Instance.new("Frame")
    emblem.AnchorPoint = Vector2.new(0.5, 0.5)
    emblem.Position = UDim2.new(0.5, 0, 0.5, 0)
    emblem.Size = UDim2.new(0, 28, 0, 28)
    emblem.BackgroundColor3 = C.STONE_DARK
    emblem.BackgroundTransparency = 0.45
    emblem.Rotation = 45
    emblem.BorderSizePixel = 0
    emblem.ZIndex = 2
    emblem.Parent = arena
    addCorner(emblem, 4)

    -- 4 Tru lua (Brazier) trang tri o 4 goc san dau
    local corners = {
        { 0.06, 0.12 }, { 0.94, 0.12 },
        { 0.06, 0.88 }, { 0.94, 0.88 },
    }
    for _, cp in ipairs(corners) do
        local pillar = Instance.new("Frame")
        pillar.AnchorPoint = Vector2.new(0.5, 0.5)
        pillar.Position = UDim2.new(cp[1], 0, cp[2], 0)
        pillar.Size = UDim2.new(0, 24, 0, 24)
        pillar.BackgroundColor3 = C.STONE_DARK
        pillar.ZIndex = 3
        pillar.Parent = arena
        addCorner(pillar, 12)
        addStroke(pillar, C.STONE_LIGHT, 1.5)

        local ember = Instance.new("Frame")
        ember.AnchorPoint = Vector2.new(0.5, 0.5)
        ember.Position = UDim2.new(0.5, 0, 0.5, 0)
        ember.Size = UDim2.new(0, 11, 0, 11)
        ember.BackgroundColor3 = C.EMBER
        ember.BorderSizePixel = 0
        ember.ZIndex = 4
        ember.Parent = pillar
        addCorner(ember, 6)
        table.insert(S.braziers, ember)
    end

    local entityLayer = Instance.new("Frame")
    entityLayer.Name = "EntityLayer"
    entityLayer.Size = UDim2.new(1, 0, 1, 0)
    entityLayer.BackgroundTransparency = 1
    entityLayer.ZIndex = 5
    entityLayer.Parent = arena
    UI.EntityLayer = entityLayer

    -- Nhan vat nguoi choi (khung xoay theo huong + vong buff/no)
    local pNode = Instance.new("Frame")
    pNode.Name = "Player"
    pNode.AnchorPoint = Vector2.new(0.5, 0.5)
    pNode.Size = UDim2.new(0, 32, 0, 32)
    pNode.BackgroundTransparency = 1
    pNode.ZIndex = 10
    pNode.Parent = arena
    UI.PlayerNode = pNode

    local pAura = Instance.new("Frame")
    pAura.AnchorPoint = Vector2.new(0.5, 0.5)
    pAura.Position = UDim2.new(0.5, 0, 0.5, 0)
    pAura.Size = UDim2.new(1.55, 0, 1.55, 0)
    pAura.BackgroundColor3 = C.TXT_GOLD
    pAura.BackgroundTransparency = 0.85
    pAura.Visible = false
    pAura.ZIndex = 9
    pAura.Parent = pNode
    addCorner(pAura, 999)
    UI.PlayerAuraStroke = addStroke(pAura, C.TXT_GOLD, 1.5)
    UI.PlayerAura = pAura

    local pSprite = Instance.new("Frame")
    pSprite.AnchorPoint = Vector2.new(0.5, 0.5)
    pSprite.Position = UDim2.new(0.5, 0, 0.5, 0)
    pSprite.Size = UDim2.new(1, 0, 1, 0)
    pSprite.BackgroundTransparency = 1
    pSprite.ZIndex = 10
    pSprite.Parent = pNode
    UI.PlayerSprite = pSprite

    -- Thanh HUD phia tren san dau
    local hud = Instance.new("Frame")
    hud.Position = UDim2.new(0, 8, 0, 4)
    hud.Size = UDim2.new(1, -16, 0, 36)
    hud.BackgroundColor3 = C.BG_PANEL
    hud.ZIndex = 8
    hud.Parent = combat
    addCorner(hud, 8)
    addStroke(hud, C.BORDER, 1)
    addGradient(hud, C.BG_PANEL_TOP, C.BG_PANEL, 90)

    local hpBg = Instance.new("Frame")
    hpBg.Position = UDim2.new(0, 10, 0, 6)
    hpBg.Size = UDim2.new(0, 168, 0, 13)
    hpBg.BackgroundColor3 = C.BG_MAIN
    hpBg.ZIndex = 9
    hpBg.Parent = hud
    addCorner(hpBg, 4)
    addStroke(hpBg, C.BORDER, 1)

    UI.HpFill = Instance.new("Frame")
    UI.HpFill.Size = UDim2.new(1, 0, 1, 0)
    UI.HpFill.BackgroundColor3 = C.HP_FILL
    UI.HpFill.BorderSizePixel = 0
    UI.HpFill.ZIndex = 10
    UI.HpFill.Parent = hpBg
    addCorner(UI.HpFill, 4)
    addGradient(UI.HpFill, Color3.fromRGB(82, 184, 114), Color3.fromRGB(44, 128, 72), 90)

    UI.HpText = makeLabel(hpBg, {
        text = "HP 140/140",
        font = FONT_TITLE,
        color = C.TXT_MAIN,
        size = 10,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, 0, 1, 0),
        z = 11,
    })

    local furyBg = Instance.new("Frame")
    furyBg.Position = UDim2.new(0, 10, 0, 22)
    furyBg.Size = UDim2.new(0, 168, 0, 8)
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
    addGradient(UI.FuryFill, Color3.fromRGB(204, 162, 74), Color3.fromRGB(162, 104, 38), 90)

    UI.HudWave = makeLabel(hud, {
        text = "Ải 1",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 13,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(0, 110, 1, 0),
        pos = UDim2.new(0.5, -108, 0, 0),
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
        dim = UDim2.new(0, 104, 1, 0),
        pos = UDim2.new(1, -188, 0, 0),
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

    local bossBar = Instance.new("Frame")
    bossBar.AnchorPoint = Vector2.new(0.5, 0)
    bossBar.Position = UDim2.new(0.5, 0, 0, 8)
    bossBar.Size = UDim2.new(0, 310, 0, 24)
    bossBar.BackgroundColor3 = C.BG_PANEL
    bossBar.Visible = false
    bossBar.ZIndex = 15
    bossBar.Parent = arena
    addCorner(bossBar, 6)
    addStroke(bossBar, C.TXT_GOLD, 1.5)

    UI.BossHpFill = Instance.new("Frame")
    UI.BossHpFill.Size = UDim2.new(1, 0, 1, 0)
    UI.BossHpFill.BackgroundColor3 = C.HP_BOSS
    UI.BossHpFill.BorderSizePixel = 0
    UI.BossHpFill.ZIndex = 16
    UI.BossHpFill.Parent = bossBar
    addCorner(UI.BossHpFill, 5)
    addGradient(UI.BossHpFill, Color3.fromRGB(178, 76, 158), Color3.fromRGB(118, 42, 106), 90)

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

    UI.WaveBanner = makeLabel(arena, {
        text = "",
        font = FONT_TITLE,
        color = C.TXT_GOLD,
        size = 20,
        xAlign = Enum.TextXAlignment.Center,
        dim = UDim2.new(1, 0, 0, 34),
        pos = UDim2.new(0, 0, 0.20, 0),
        z = 18,
    })

    -- JOYSTICK CAM UNG TUC THI (GOC TRAI DUOI)
    local joyBase = Instance.new("Frame")
    joyBase.Position = UDim2.new(0, 18, 1, -124)
    joyBase.Size = UDim2.new(0, 106, 0, 106)
    joyBase.BackgroundColor3 = C.BG_PANEL
    joyBase.BackgroundTransparency = 0.35
    joyBase.ZIndex = 20
    joyBase.Parent = arena
    addCorner(joyBase, 53)
    addStroke(joyBase, C.BORDER_ACT, 1.5)

    local joyInnerRing = Instance.new("Frame")
    joyInnerRing.AnchorPoint = Vector2.new(0.5, 0.5)
    joyInnerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    joyInnerRing.Size = UDim2.new(0, 62, 0, 62)
    joyInnerRing.BackgroundTransparency = 1
    joyInnerRing.ZIndex = 20
    joyInnerRing.Parent = joyBase
    addCorner(joyInnerRing, 31)
    addStroke(joyInnerRing, C.BORDER, 1)

    local joyKnob = Instance.new("Frame")
    joyKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    joyKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
    joyKnob.Size = UDim2.new(0, 42, 0, 42)
    joyKnob.BackgroundColor3 = C.BTN_PRIMARY
    joyKnob.BackgroundTransparency = 0.16
    joyKnob.ZIndex = 21
    joyKnob.Parent = joyBase
    addCorner(joyKnob, 21)
    addStroke(joyKnob, C.TXT_MAIN, 1.5)

    local function updateJoystick(pos)
        local center = joyBase.AbsolutePosition + joyBase.AbsoluteSize * 0.5
        local dx, dy = pos.X - center.X, pos.Y - center.Y
        local maxR = 36
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > maxR then
            dx, dy = dx / dist * maxR, dy / dist * maxR
        end
        joyKnob.Position = UDim2.new(0.5, dx, 0.5, dy)
        if dist > 5 then
            S.joyX, S.joyY = dx / maxR, dy / maxR
        else
            S.joyX, S.joyY = 0, 0
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
        if S.joyActive and (inp == S.joyId or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            updateJoystick(inp.Position)
        end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if S.joyActive and (inp == S.joyId or inp.UserInputType == Enum.UserInputType.MouseButton1) then
            S.joyActive = false
            S.joyId = nil
            S.joyX, S.joyY = 0, 0
            joyKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end))

    -- 4 NUT CHIEN DAU CAM UNG TUC THI (CO BIEU TUONG VECTOR TU VE)
    local atkBtn = makeBtn(arena, {
        text = "ĐÁNH",
        bg = C.BTN_DANGER,
        color = C.TXT_MAIN,
        size = 13,
        dim = UDim2.new(0, 74, 0, 74),
        pos = UDim2.new(1, -90, 1, -90),
        radius = 37,
        strokeColor = C.TXT_RED,
        strokeWidth = 2,
        z = 20,
    })
    atkBtn.BackgroundTransparency = 0.16
    addGradient(atkBtn, Color3.fromRGB(168, 66, 66), Color3.fromRGB(116, 40, 40), 120)
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
        size = 11,
        dim = UDim2.new(0, 56, 0, 56),
        pos = UDim2.new(1, -156, 1, -70),
        radius = 28,
        strokeColor = C.BORDER_ACT,
        z = 20,
    })
    dashBtn.BackgroundTransparency = 0.18
    UI.DashBtn = dashBtn
    bindTap(dashBtn, function() GAME.TryDash() end)

    local skillBtn = makeBtn(arena, {
        text = "KỸ NĂNG",
        bg = C.BTN_WARN,
        color = C.TXT_MAIN,
        size = 10,
        dim = UDim2.new(0, 62, 0, 62),
        pos = UDim2.new(1, -148, 1, -138),
        radius = 31,
        strokeColor = C.TXT_GOLD,
        z = 20,
    })
    skillBtn.BackgroundTransparency = 0.18
    UI.SkillBtn = skillBtn
    bindTap(skillBtn, function() GAME.TrySkill() end)

    local ultBtn = makeBtn(arena, {
        text = "0% NỘ",
        bg = C.BTN_PURPLE,
        color = C.TXT_MAIN,
        size = 10,
        dim = UDim2.new(0, 62, 0, 62),
        pos = UDim2.new(1, -80, 1, -162),
        radius = 31,
        strokeColor = C.TXT_PURPLE,
        z = 20,
    })
    ultBtn.BackgroundTransparency = 0.18
    UI.UltBtn = ultBtn
    bindTap(ultBtn, function() GAME.TryUlt() end)

    -- OVERLAY TAM DUNG
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
    bindTap(quitBtn, function() GAME.EndMatch(true) end)

    -- OVERLAY KET THUC TRAN
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
    eCard.Size = UDim2.new(0, 324, 0, 234)
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
    bindTap(retryBtn, function() GAME.StartMatch() end)

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
    bindTap(backBtn, function() GAME.ReturnToLobby() end)
end

-- ============================================================================
-- 9. CO CHE CHIEN DAU & HIEU UNG DO HOA (SLASH, SPARKS, AFTERIMAGE, AI)
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
        S.sparks = {}
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
            dim = UDim2.new(0, 96, 0, 20),
            pos = toScalePos(x, y),
            z = 16,
        })
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        table.insert(S.floatTexts, {
            ui = lbl, x = x, y = y, vy = -50, life = 0.65, maxLife = 0.65,
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
            ui = f, kind = "ring", x = x, y = y, maxR = radius, life = dur or 0.25, maxLife = dur or 0.25,
        })
    end

    -- Vet chem sac net xoay theo huong tan cong
    local function spawnSlashArc(x, y, angleDeg, lengthPx, color, dur)
        local slash = Instance.new("Frame")
        slash.AnchorPoint = Vector2.new(0.5, 0.5)
        slash.Position = toScalePos(x, y)
        slash.Size = UDim2.new(0, 12, 0, lengthPx)
        slash.Rotation = angleDeg
        slash.BackgroundColor3 = color
        slash.BackgroundTransparency = 0.15
        slash.BorderSizePixel = 0
        slash.ZIndex = 12
        slash.Parent = UI.EntityLayer
        addCorner(slash, 6)
        addStroke(slash, C.TXT_MAIN, 1)
        table.insert(S.effects, {
            ui = slash, kind = "slash", life = dur or 0.14, maxLife = dur or 0.14,
        })
    end

    -- Tan anh khi luot nhanh (Dash Afterimage)
    local function spawnAfterimage(x, y, rotDeg, col)
        local ghost = Instance.new("Frame")
        ghost.AnchorPoint = Vector2.new(0.5, 0.5)
        ghost.Position = toScalePos(x, y)
        ghost.Size = UDim2.new(0, 26, 0, 26)
        ghost.Rotation = rotDeg
        ghost.BackgroundColor3 = col
        ghost.BackgroundTransparency = 0.45
        ghost.BorderSizePixel = 0
        ghost.ZIndex = 7
        ghost.Parent = UI.EntityLayer
        addCorner(ghost, 10)
        table.insert(S.effects, {
            ui = ghost, kind = "ghost", life = 0.22, maxLife = 0.22,
        })
    end

    -- Tia lua va cham (Hit Sparks)
    local function spawnSparks(x, y, color, count)
        for _ = 1, (count or 5) do
            local ang = RNG:NextNumber(0, math.pi * 2)
            local spd = RNG:NextNumber(90, 220)
            local sp = Instance.new("Frame")
            sp.AnchorPoint = Vector2.new(0.5, 0.5)
            sp.Position = toScalePos(x, y)
            sp.Size = UDim2.new(0, 6, 0, 6)
            sp.Rotation = 45
            sp.BackgroundColor3 = color
            sp.BorderSizePixel = 0
            sp.ZIndex = 13
            sp.Parent = UI.EntityLayer
            table.insert(S.sparks, {
                ui = sp,
                x = x,
                y = y,
                vx = math.cos(ang) * spd,
                vy = math.sin(ang) * spd,
                life = RNG:NextNumber(0.16, 0.28),
                maxLife = 0.28,
            })
        end
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
        table.insert(S.pickups, { ui = node, x = x, y = y, kind = kind, life = 11.0 })
    end

    local function spawnProjectile(owner, x, y, vx, vy, dmg, radius, color, pierce)
        local node = Instance.new("Frame")
        node.AnchorPoint = Vector2.new(0.5, 0.5)
        node.Position = toScalePos(x, y)
        local px = math.max(9, math.floor(radius * 1.45))
        node.Size = UDim2.new(0, px, 0, px)
        node.BackgroundColor3 = color
        node.ZIndex = 9
        node.Parent = UI.EntityLayer
        addCorner(node, px)
        addStroke(node, C.TXT_MAIN, 1)

        local core = Instance.new("Frame")
        core.AnchorPoint = Vector2.new(0.5, 0.5)
        core.Position = UDim2.new(0.5, 0, 0.5, 0)
        core.Size = UDim2.new(0.45, 0, 0.45, 0)
        core.BackgroundColor3 = C.TXT_MAIN
        core.BorderSizePixel = 0
        core.ZIndex = 10
        core.Parent = node
        addCorner(core, 99)

        table.insert(S.projs, {
            ui = node, owner = owner, x = x, y = y, vx = vx, vy = vy,
            dmg = dmg, r = radius, pierce = pierce or 0, hitMap = {}, life = 2.4,
        })
    end

    local function spawnHazard(x, y, radius, delay, dmg)
        local node = Instance.new("Frame")
        node.AnchorPoint = Vector2.new(0.5, 0.5)
        node.Position = toScalePos(x, y)
        node.Size = UDim2.new((radius * 2) / CFG.ARENA_W, 0, (radius * 2) / CFG.ARENA_H, 0)
        node.BackgroundColor3 = C.WARN_ZONE
        node.BackgroundTransparency = 0.80
        node.ZIndex = 5
        node.Parent = UI.EntityLayer
        addCorner(node, 999)
        addStroke(node, C.TXT_RED, 1.5)

        -- Vong nap nang luong ben trong bao thoi gian no chinh xac
        local charge = Instance.new("Frame")
        charge.AnchorPoint = Vector2.new(0.5, 0.5)
        charge.Position = UDim2.new(0.5, 0, 0.5, 0)
        charge.Size = UDim2.new(0.1, 0, 0.1, 0)
        charge.BackgroundColor3 = C.TXT_RED
        charge.BackgroundTransparency = 0.65
        charge.BorderSizePixel = 0
        charge.ZIndex = 5
        charge.Parent = node
        addCorner(charge, 999)

        table.insert(S.hazards, {
            ui = node, charge = charge, x = x, y = y, r = radius, dmg = dmg, timer = delay, maxTimer = delay,
        })
    end

    local function spawnEnemy(kind, waveNum)
        local side = RNG:NextInteger(1, 4)
        local x, y
        if side == 1 then x, y = RNG:NextNumber(40, CFG.ARENA_W - 40), 28
        elseif side == 2 then x, y = RNG:NextNumber(40, CFG.ARENA_W - 40), CFG.ARENA_H - 28
        elseif side == 3 then x, y = 28, RNG:NextNumber(40, CFG.ARENA_H - 40)
        else x, y = CFG.ARENA_W - 28, RNG:NextNumber(40, CFG.ARENA_H - 40) end

        local scale = 1 + (waveNum - 1) * 0.16
        local hp, spd, dmg, rad, col, scoreVal, coinVal, isBoss, title = 62, 112, 12, 17, Color3.fromRGB(174, 82, 82), 20, 5, false, nil
        if kind == "runner" then
            hp, spd, dmg, rad = math.floor(42 * scale), 155, math.floor(11 * scale), 15
            col = Color3.fromRGB(184, 128, 58)
            scoreVal, coinVal = 25, 6
        elseif kind == "shooter" then
            hp, spd, dmg, rad = math.floor(54 * scale), 92, math.floor(13 * scale), 16
            col = Color3.fromRGB(136, 86, 174)
            scoreVal, coinVal = 35, 8
        elseif kind == "tank" then
            hp, spd, dmg, rad = math.floor(125 * scale), 72, math.floor(18 * scale), 23
            col = Color3.fromRGB(158, 66, 66)
            scoreVal, coinVal = 50, 12
        elseif kind == "boss" then
            isBoss = true
            local bossNames = { "HẮC KỴ SĨ", "HỎA MA VƯƠNG", "LÔI THẦN HỘ VỆ", "CHÚA TỂ BÓNG TỐI" }
            title = bossNames[((math.floor((waveNum - 1) / 5)) % #bossNames) + 1]
            hp, spd, dmg, rad = math.floor(420 * scale), 104, math.floor(24 * scale), 32
            col = C.HP_BOSS
            scoreVal, coinVal = 300, 65
        else
            hp, dmg = math.floor(62 * scale), math.floor(12 * scale)
        end

        local node = Instance.new("Frame")
        node.AnchorPoint = Vector2.new(0.5, 0.5)
        node.Position = toScalePos(x, y)
        local px = math.floor(rad * 1.48)
        node.Size = UDim2.new(0, px, 0, px)
        node.BackgroundColor3 = col
        node.ZIndex = isBoss and 9 or 8
        node.Parent = UI.EntityLayer
        addCorner(node, (kind == "tank" or isBoss) and 8 or (kind == "runner" and 4 or px))
        addStroke(node, isBoss and C.TXT_GOLD or C.TXT_DARK, isBoss and 2 or 1.2)
        decorateEnemyNode(node, kind, col, isBoss, isBoss and 9 or 8)

        local hpFill = nil
        if not isBoss then
            local hb = Instance.new("Frame")
            hb.AnchorPoint = Vector2.new(0.5, 1)
            hb.Position = UDim2.new(0.5, 0, 0, -5)
            hb.Size = UDim2.new(0, 30, 0, 4)
            hb.BackgroundColor3 = C.BG_MAIN
            hb.BorderSizePixel = 0
            hb.ZIndex = 11
            hb.Parent = node

            hpFill = Instance.new("Frame")
            hpFill.Size = UDim2.new(1, 0, 1, 0)
            hpFill.BackgroundColor3 = C.HP_ENEMY
            hpFill.BorderSizePixel = 0
            hpFill.ZIndex = 12
            hpFill.Parent = hb
        end

        local e = {
            ui = node, hpFill = hpFill, kind = kind, isBoss = isBoss, title = title,
            x = x, y = y, hp = hp, maxHp = hp, spd = spd, dmg = dmg, r = rad,
            baseCol = col, flashT = 0, stunT = 0, atkCd = RNG:NextNumber(0.6, 1.4),
            bossSkillCd = 3.2, scoreVal = scoreVal, coinVal = coinVal,
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
        spawnSparks(S.px, S.py, C.TXT_RED, 6)
        spawnFloatText(S.px, S.py - 22, "-" .. tostring(amount), C.TXT_RED, 14)
        if S.hp <= 0 then GAME.EndMatch(false) end
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
        spawnSparks(e.x, e.y, isCrit and C.TXT_GOLD or C.SLASH_FX, isCrit and 7 or 4)
        spawnFloatText(
            e.x + RNG:NextNumber(-12, 12), e.y - 18,
            isCrit and ("CRIT " .. tostring(dmg)) or tostring(dmg),
            isCrit and C.TXT_GOLD or C.TXT_MAIN, isCrit and 15 or 12
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
                spawnRingFX(e.x, e.y, 145, C.TXT_GOLD, 0.40)
                spawnSparks(e.x, e.y, C.TXT_GOLD, 14)
            else
                spawnRingFX(e.x, e.y, 46, e.baseCol, 0.20)
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
                if d < bestD then bestD, best = d, e end
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
            if isBossWave then spawnEnemy("boss", waveNum) end
        end
        S.spawnTimer = 0.4
    end

    function GAME.TryAttack()
        if not S.inMatch or S.paused or S.gameOver or S.attackCd > 0 then return end
        local h = S.hero
        S.attackCd = h.attackCd * S.cdr
        S.comboStep = (S.comboStep % 3) + 1
        S.comboResetT = 1.1
        S.swingT = 0.16
        S.swingSign = -S.swingSign

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
        local angDeg = math.deg(math.atan2(ay, ax))

        if h.attackType == "ranged" then
            spawnProjectile("player", S.px + ax * 20, S.py + ay * 20, ax * 560, ay * 560, finalDmg, 8, h.trim, (S.comboStep == 3) and 2 or 0)
            spawnRingFX(S.px + ax * 20, S.py + ay * 20, 20, h.trim, 0.12)
        else
            local hitX = S.px + ax * (h.attackRange * 0.48)
            local hitY = S.py + ay * (h.attackRange * 0.48)
            local hitR = h.attackRange * (S.comboStep == 3 and 0.72 or 0.58)
            spawnSlashArc(hitX, hitY, angDeg, math.floor(hitR * 1.15), S.comboStep == 3 and C.TXT_GOLD or C.SLASH_FX, 0.14)
            spawnRingFX(hitX, hitY, hitR * 0.85, S.comboStep == 3 and C.TXT_GOLD or h.color, 0.15)
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
        if not S.inMatch or S.paused or S.gameOver or S.dashCd > 0 then return end
        S.dashCd = 1.6 * S.cdr
        S.dashTime = 0.16
        S.dashGhostT = 0
        S.invulnTime = math.max(S.invulnTime, 0.24)
        S.dashVx = S.dirX * 760
        S.dashVy = S.dirY * 760
        spawnRingFX(S.px, S.py, 36, C.TXT_GEM, 0.20)
    end

    function GAME.TrySkill()
        if not S.inMatch or S.paused or S.gameOver or S.skillCd > 0 then return end
        local h = S.hero
        S.skillCd = h.skillCd * S.cdr
        S.skillMaxCd = S.skillCd
        S.swingT = 0.22
        addShake(6, 0.15)

        if h.id == "kiemsi" then
            spawnRingFX(S.px, S.py, 150, h.color, 0.30)
            spawnRingFX(S.px, S.py, 110, h.trim, 0.22)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - S.px, e.y - S.py
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d <= 148 + e.r then
                        local nx, ny = (d > 1 and dx / d or 1), (d > 1 and dy / d or 0)
                        damageEnemy(e, math.floor(S.atk * 2.2), nx * 65, ny * 65, 0.35)
                    end
                end
            end
        elseif h.id == "satthu" then
            S.dashTime = 0.20
            S.dashGhostT = 0
            S.invulnTime = math.max(S.invulnTime, 0.35)
            S.dashVx = S.dirX * 880
            S.dashVy = S.dirY * 880
            local angDeg = math.deg(math.atan2(S.dirY, S.dirX))
            spawnSlashArc(S.px + S.dirX * 65, S.py + S.dirY * 65, angDeg, 96, h.trim, 0.20)
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
            local baseAngle = math.atan2(S.dirY, S.dirX)
            for i = -2, 2 do
                local ang = baseAngle + i * 0.18
                spawnProjectile("player", S.px, S.py, math.cos(ang) * 600, math.sin(ang) * 600, math.floor(S.atk * 1.45), 9, C.TXT_GREEN, 3)
            end
        else
            spawnRingFX(S.px, S.py, 178, h.color, 0.35)
            spawnRingFX(S.px, S.py, 125, h.trim, 0.25)
            spawnSparks(S.px, S.py, h.trim, 12)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - S.px, e.y - S.py
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d <= 178 + e.r then
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
        spawnRingFX(S.px, S.py, 265, C.TXT_PURPLE, 0.45)
        spawnRingFX(S.px, S.py, 180, C.TXT_GOLD, 0.35)
        spawnSparks(S.px, S.py, C.TXT_GOLD, 16)
        spawnFloatText(S.px, S.py - 34, S.hero.ultName, C.TXT_GOLD, 16)

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
        S.maxHp, S.hp = st.maxHp, st.maxHp
        S.atk, S.spd, S.crit, S.cdr = st.atk, st.spd, st.crit, st.cdr
        S.fury = 0
        S.px, S.py = CFG.ARENA_W * 0.5, CFG.ARENA_H * 0.5
        S.dirX, S.dirY = 1, 0
        S.score, S.kills, S.coinsEarned, S.gemsEarned = 0, 0, 0, 0
        S.combo, S.maxCombo, S.comboTimer = 0, 0, 0
        S.matchTime = 0
        S.attackCd, S.swingT, S.dashCd, S.dashTime = 0, 0, 0, 0
        S.invulnTime = 0.5
        S.skillCd = 0
        S.skillMaxCd = st.hero.skillCd * st.cdr
        S.buffAtkTime = 0
        S.bossActive = false
        S.holdAttack = false

        local _, wp = buildHeroAvatar(UI.PlayerSprite, st.hero, 10)
        UI.WeaponPivot = wp
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

    -- Vong lap cap nhat 60 FPS
    trackConn(RunService.RenderStepped:Connect(function(dt)
        if not S.inMatch or S.paused or S.gameOver then return end
        dt = math.min(dt, 0.05)
        S.matchTime = S.matchTime + dt

        -- Hieu ung ngon lua 4 tru goc san dau
        local pulse = 0.5 + 0.5 * math.sin(S.matchTime * 6)
        for idx, ember in ipairs(S.braziers) do
            local sz = 9 + math.floor((pulse + (idx % 2) * 0.25) * 3)
            ember.Size = UDim2.new(0, sz, 0, sz)
        end

        if S.attackCd > 0 then S.attackCd = math.max(0, S.attackCd - dt) end
        if S.swingT > 0 then S.swingT = math.max(0, S.swingT - dt) end
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

        if S.holdAttack and S.attackCd <= 0 then GAME.TryAttack() end

        if S.dashTime > 0 then
            S.dashTime = S.dashTime - dt
            S.dashGhostT = S.dashGhostT - dt
            if S.dashGhostT <= 0 then
                S.dashGhostT = 0.035
                spawnAfterimage(S.px, S.py, math.deg(math.atan2(S.dirY, S.dirX)), S.hero.color)
            end
            S.px = math.clamp(S.px + S.dashVx * dt, CFG.PLAYER_R, CFG.ARENA_W - CFG.PLAYER_R)
            S.py = math.clamp(S.py + S.dashVy * dt, CFG.PLAYER_R, CFG.ARENA_H - CFG.PLAYER_R)
        else
            local mx, my = 0, 0
            if S.keys.A then mx = mx - 1 end
            if S.keys.D then mx = mx + 1 end
            if S.keys.W then my = my - 1 end
            if S.keys.S then my = my + 1 end
            if S.joyActive then mx, my = S.joyX, S.joyY end
            local len = math.sqrt(mx * mx + my * my)
            if len > 0.05 then
                local nx, ny = mx / math.max(1, len), my / math.max(1, len)
                S.px = math.clamp(S.px + nx * S.spd * dt, CFG.PLAYER_R, CFG.ARENA_W - CFG.PLAYER_R)
                S.py = math.clamp(S.py + ny * S.spd * dt, CFG.PLAYER_R, CFG.ARENA_H - CFG.PLAYER_R)
                S.dirX, S.dirY = mx / len, my / len
            end
        end

        if S.enemiesToSpawn > 0 then
            S.spawnTimer = S.spawnTimer - dt
            if S.spawnTimer <= 0 then
                S.enemiesToSpawn = S.enemiesToSpawn - 1
                S.spawnTimer = math.max(0.32, 1.15 - S.wave * 0.04)
                local roll = RNG:NextNumber()
                local kind = "grunt"
                if S.wave >= 2 and roll < 0.25 then kind = "runner"
                elseif S.wave >= 3 and roll < 0.48 then kind = "shooter"
                elseif S.wave >= 4 and roll < 0.66 then kind = "tank" end
                spawnEnemy(kind, S.wave)
            end
        end

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
                        e.x = math.clamp(e.x - nx * e.spd * 0.4 * dt, 24, CFG.ARENA_W - 24)
                        e.y = math.clamp(e.y - ny * e.spd * 0.4 * dt, 24, CFG.ARENA_H - 24)
                    else
                        e.x = math.clamp(e.x + nx * e.spd * dt, 24, CFG.ARENA_W - 24)
                        e.y = math.clamp(e.y + ny * e.spd * dt, 24, CFG.ARENA_H - 24)
                    end

                    if e.kind == "shooter" then
                        e.atkCd = e.atkCd - dt
                        if e.atkCd <= 0 then
                            e.atkCd = 1.9
                            spawnProjectile("enemy", e.x, e.y, nx * 290, ny * 290, e.dmg, 7, C.TXT_PURPLE, 0)
                        end
                    end

                    if e.isBoss then
                        e.bossSkillCd = e.bossSkillCd - dt
                        if e.bossSkillCd <= 0 then
                            e.bossSkillCd = 3.6
                            if RNG:NextNumber() < 0.5 then
                                for k = 1, 8 do
                                    local a = (k / 8) * math.pi * 2 + S.matchTime
                                    spawnProjectile("enemy", e.x, e.y, math.cos(a) * 260, math.sin(a) * 260, e.dmg, 8, C.TXT_RED, 0)
                                end
                            else
                                spawnHazard(S.px, S.py, 78, 1.05, math.floor(e.dmg * 1.35))
                                spawnHazard(
                                    math.clamp(S.px + RNG:NextNumber(-120, 120), 80, CFG.ARENA_W - 80),
                                    math.clamp(S.py + RNG:NextNumber(-90, 90), 80, CFG.ARENA_H - 80),
                                    72, 1.15, math.floor(e.dmg * 1.2)
                                )
                            end
                        end
                    end

                    if dist < (e.r + CFG.PLAYER_R - 4) then damagePlayer(e.dmg) end
                end
                e.ui.Position = toScalePos(e.x, e.y)
            end
        end

        if S.enemiesToSpawn <= 0 and aliveCount == 0 then
            S.nextWaveTimer = S.nextWaveTimer + dt
            if S.nextWaveTimer >= 1.1 then
                S.nextWaveTimer = 0
                S.hp = math.min(S.maxHp, S.hp + math.floor(S.maxHp * 0.15))
                GAME.StartWave(S.wave + 1)
            end
        end

        for i = #S.projs, 1, -1 do
            local p = S.projs[i]
            p.life = p.life - dt
            p.x, p.y = p.x + p.vx * dt, p.y + p.vy * dt
            local dead = (p.life <= 0) or (p.x < 0) or (p.x > CFG.ARENA_W) or (p.y < 0) or (p.y > CFG.ARENA_H)
            if not dead then
                if p.owner == "player" then
                    for _, e in ipairs(S.enemies) do
                        if e.hp > 0 and not p.hitMap[e] then
                            local d = math.sqrt((e.x - p.x) ^ 2 + (e.y - p.y) ^ 2)
                            if d <= (p.r + e.r) then
                                p.hitMap[e] = true
                                damageEnemy(e, p.dmg, p.vx * 0.02, p.vy * 0.02, 0)
                                if p.pierce > 0 then p.pierce = p.pierce - 1
                                else dead = true break end
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
            if dead then p.ui:Destroy(); table.remove(S.projs, i)
            else p.ui.Position = toScalePos(p.x, p.y) end
        end

        for i = #S.hazards, 1, -1 do
            local h = S.hazards[i]
            h.timer = h.timer - dt
            local ratio = 1 - math.clamp(h.timer / h.maxTimer, 0, 1)
            h.ui.BackgroundTransparency = 0.84 - ratio * 0.38
            h.charge.Size = UDim2.new(ratio, 0, ratio, 0)
            if h.timer <= 0 then
                spawnRingFX(h.x, h.y, h.r, C.TXT_RED, 0.24)
                spawnSparks(h.x, h.y, C.EMBER, 8)
                local d = math.sqrt((S.px - h.x) ^ 2 + (S.py - h.y) ^ 2)
                if d <= h.r + CFG.PLAYER_R * 0.5 then damagePlayer(h.dmg) end
                h.ui:Destroy()
                table.remove(S.hazards, i)
            end
        end

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

        for i = #S.effects, 1, -1 do
            local fx = S.effects[i]
            fx.life = fx.life - dt
            if fx.life <= 0 then
                fx.ui:Destroy()
                table.remove(S.effects, i)
            else
                local prog = 1 - (fx.life / fx.maxLife)
                if fx.kind == "ring" then
                    local curR = fx.maxR * (0.35 + prog * 0.65)
                    fx.ui.Size = UDim2.new((curR * 2) / CFG.ARENA_W, 0, (curR * 2) / CFG.ARENA_H, 0)
                    fx.ui.BackgroundTransparency = 0.65 + prog * 0.35
                elseif fx.kind == "slash" then
                    fx.ui.BackgroundTransparency = 0.15 + prog * 0.85
                else
                    fx.ui.BackgroundTransparency = 0.45 + prog * 0.55
                end
            end
        end

        for i = #S.sparks, 1, -1 do
            local sp = S.sparks[i]
            sp.life = sp.life - dt
            if sp.life <= 0 then
                sp.ui:Destroy()
                table.remove(S.sparks, i)
            else
                sp.x, sp.y = sp.x + sp.vx * dt, sp.y + sp.vy * dt
                sp.ui.Position = toScalePos(sp.x, sp.y)
                sp.ui.BackgroundTransparency = 1 - (sp.life / sp.maxLife)
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

        -- Cap nhat nhan vat (xoay theo huong + vung vu khi + vong hao quang)
        UI.PlayerNode.Position = toScalePos(S.px, S.py)
        UI.PlayerSprite.Rotation = math.deg(math.atan2(S.dirY, S.dirX))
        if UI.WeaponPivot then
            if S.swingT > 0 then
                local swingAngle = (S.swingT / 0.16) * 78 * S.swingSign
                UI.WeaponPivot.Rotation = swingAngle
            else
                UI.WeaponPivot.Rotation = 0
            end
        end

        if S.buffAtkTime > 0 then
            UI.PlayerAura.Visible = true
            UI.PlayerAura.BackgroundColor3 = C.TXT_RED
            UI.PlayerAuraStroke.Color = C.TXT_RED
        elseif S.fury >= 100 then
            UI.PlayerAura.Visible = true
            UI.PlayerAura.BackgroundColor3 = C.TXT_GOLD
            UI.PlayerAuraStroke.Color = C.TXT_GOLD
        else
            UI.PlayerAura.Visible = false
        end

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
    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
end

refreshLobbyUI()
showToast("Chào mừng đến Đấu Trường Chiến Đấu Pro " .. CFG.VERSION, C.TXT_GOLD)
