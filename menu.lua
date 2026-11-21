-- ============================================================================
-- DAU TRUONG CHIEN DAU PRO (v2.9) - Full-Screen Action RPG Combat Game
-- Menu Full Man Hinh 100% | 8 Tuong | 5 Boss | 6 Loai Quai | Minimap Radar
-- Chon Nang Cap Trong Tran | Nhiem Vu | Len Cap | Trang Thai | Cai Dat
-- Code doc lap 100%, toi uu cho Mobile (cam ung tuc thi, chu matte) & PC.
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
-- 1. BANG MAU MATTE (KHONG CHOI TREN DIEN THOAI) & FONT AN TOAN
-- ============================================================================
local C = {
    -- Nen toi phong cach RPG huyen ao (xanh tim than + da ham nguc)
    BG_FULL      = Color3.fromRGB(15, 17, 26),
    BG_TOPBAR    = Color3.fromRGB(22, 25, 38),
    BG_PANEL     = Color3.fromRGB(24, 28, 42),
    BG_PANEL_HI  = Color3.fromRGB(34, 39, 58),
    BG_CARD      = Color3.fromRGB(30, 35, 52),
    BG_CARD_ALT  = Color3.fromRGB(40, 46, 68),
    BG_ARENA     = Color3.fromRGB(38, 46, 62),
    BG_ARENA_MID = Color3.fromRGB(46, 55, 74),
    BG_ARENA_G   = Color3.fromRGB(58, 68, 90),
    GRASS_DARK   = Color3.fromRGB(32, 68, 46),
    GRASS_LIGHT  = Color3.fromRGB(44, 92, 58),
    STONE_DARK   = Color3.fromRGB(46, 52, 68),
    STONE_LIGHT  = Color3.fromRGB(68, 76, 98),
    BORDER       = Color3.fromRGB(66, 74, 102),
    BORDER_ACT   = Color3.fromRGB(128, 108, 186),
    BORDER_GOLD  = Color3.fromRGB(178, 144, 72),
    SHADOW       = Color3.fromRGB(8, 9, 14),

    -- Mau chu MATTE tuyet doi (tat ca RGB <= 210 de khong bi loe tren mobile)
    TXT_MAIN     = Color3.fromRGB(205, 208, 212),
    TXT_SUB      = Color3.fromRGB(148, 156, 174),
    TXT_GOLD     = Color3.fromRGB(206, 174, 94),
    TXT_GEM      = Color3.fromRGB(158, 128, 206),
    TXT_CYAN     = Color3.fromRGB(108, 176, 198),
    TXT_RED      = Color3.fromRGB(204, 104, 104),
    TXT_GREEN    = Color3.fromRGB(108, 188, 128),
    TXT_ORANGE   = Color3.fromRGB(202, 142, 78),
    TXT_DARK     = Color3.fromRGB(20, 22, 30),

    -- Mau nut & thanh trang thai
    BTN_PURPLE   = Color3.fromRGB(98, 66, 156),
    BTN_BLUE     = Color3.fromRGB(48, 104, 158),
    BTN_GREEN    = Color3.fromRGB(46, 128, 82),
    BTN_GOLD     = Color3.fromRGB(162, 118, 42),
    BTN_RED      = Color3.fromRGB(152, 54, 58),
    BTN_DARK     = Color3.fromRGB(42, 47, 64),

    HP_BAR       = Color3.fromRGB(186, 62, 66),
    MP_BAR       = Color3.fromRGB(54, 126, 188),
    EXP_BAR      = Color3.fromRGB(194, 152, 52),
    SHIELD_BAR   = Color3.fromRGB(96, 168, 194),
    HP_ENEMY     = Color3.fromRGB(184, 68, 72),
    HP_BOSS      = Color3.fromRGB(156, 58, 146),
    WARN_ZONE    = Color3.fromRGB(178, 58, 62),
    METAL        = Color3.fromRGB(176, 184, 196),
}

local FONT_TITLE = Enum.Font.GothamSemibold
local FONT_BODY  = Enum.Font.GothamMedium

-- ============================================================================
-- 2. DU LIEU GAME (8 TUONG, 5 MAN CHOI, 3 DO KHO, 5 BOSS, 6 QUAI, NHIEM VU)
-- ============================================================================
local CFG = {
    VERSION = "v2.9",
    GUI_NAME = "ArenaChienDau_Standalone",
    SAVE_PREFIX = "arena_chien_dau_v2_",
    ARENA_W = 1100,
    ARENA_H = 660,
    PLAYER_R = 20,
    -- Tuy chon: Dan rbxassetid:// vao day neu ban tai anh sprite len Roblox (de trong = dung do hoa chibi tich hop san)
    CUSTOM_SPRITE_IDS = {
        chienbinh = "", satthu = "", phapsu = "", cungthu = "",
        thankiem = "", dausi = "", kiemsu = "", maphapsu = "",
    },
}

-- 8 Nhan Vat tham khao tu bang Sprite
CFG.HEROES = {
    {
        id = "chienbinh", name = "Chiến Binh", role = "Cận chiến Hỏa Kiếm",
        costCoin = 0, costGem = 0,
        hair = Color3.fromRGB(40, 38, 46), armor = Color3.fromRGB(58, 52, 62),
        cape = Color3.fromRGB(186, 46, 48), trim = Color3.fromRGB(196, 152, 68), fx = Color3.fromRGB(204, 68, 68),
        weapon = "sword", attackType = "melee", status = "burn",
        hp = 160, mp = 100, atk = 28, spd = 250, crit = 0.14, range = 104, cd = 0.28,
        s1Name = "Hỏa Trảm", s1Cost = 20, s1Cd = 4.2,
        s2Name = "Xoáy Lửa", s2Cost = 35, s2Cd = 6.5,
        ultName = "Liệt Hỏa Kiếm Trận",
        desc = "Kiếm sĩ tóc đỏ thiêu đốt kẻ địch bằng những nhát chém lửa rộng.",
    },
    {
        id = "satthu", name = "Sát Thủ", role = "Tốc độ & Bóng Đêm",
        costCoin = 350, costGem = 0,
        hair = Color3.fromRGB(56, 44, 78), armor = Color3.fromRGB(46, 36, 68),
        hood = true, cape = Color3.fromRGB(128, 72, 186), trim = Color3.fromRGB(154, 102, 198), fx = Color3.fromRGB(154, 88, 202),
        weapon = "daggers", attackType = "melee", status = "poison",
        hp = 122, mp = 110, atk = 26, spd = 315, crit = 0.28, range = 90, cd = 0.19,
        s1Name = "Ảnh Kích", s1Cost = 18, s1Cd = 3.5,
        s2Name = "Độc Vũ", s2Cost = 30, s2Cd = 5.5,
        ultName = "Bão Dao Bóng Đêm",
        desc = "Mũ trùm tím ẩn thân, đánh cực nhanh kèm độc và tỷ lệ chí mạng cao.",
    },
    {
        id = "phapsu", name = "Pháp Sư", role = "Băng Thuật Khống Chế",
        costCoin = 550, costGem = 0,
        hair = Color3.fromRGB(134, 186, 208), armor = Color3.fromRGB(42, 82, 158),
        cape = Color3.fromRGB(34, 64, 132), trim = Color3.fromRGB(198, 168, 78), fx = Color3.fromRGB(86, 172, 208),
        weapon = "staff", attackType = "ranged", status = "freeze",
        hp = 115, mp = 150, atk = 25, spd = 255, crit = 0.18, range = 380, cd = 0.26,
        s1Name = "Cầu Băng", s1Cost = 22, s1Cd = 4.0,
        s2Name = "Vòng Băng Giá", s2Cost = 38, s2Cd = 6.2,
        ultName = "Bão Tuyết Vĩnh Cửu",
        desc = "Trượng băng bắn cầu năng lượng làm chậm và đóng băng diện rộng.",
    },
    {
        id = "cungthu", name = "Cung Thủ", role = "Xạ kích Xuyên Thấu",
        costCoin = 750, costGem = 0,
        hair = Color3.fromRGB(46, 118, 64), armor = Color3.fromRGB(44, 104, 62),
        hood = true, cape = Color3.fromRGB(38, 92, 52), trim = Color3.fromRGB(168, 126, 68), fx = Color3.fromRGB(84, 192, 112),
        weapon = "bow", attackType = "ranged", status = "poison",
        hp = 118, mp = 120, atk = 24, spd = 278, crit = 0.24, range = 410, cd = 0.22,
        s1Name = "Mưa Tên", s1Cost = 20, s1Cd = 3.8,
        s2Name = "Tiễn Xuyên", s2Cost = 32, s2Cd = 5.8,
        ultName = "Vạn Tiễn Quy Tông",
        desc = "Mũ trùm xanh lá bắn tên liên hoàn xuyên nhiều mục tiêu cùng lúc.",
    },
    {
        id = "thankiem", name = "Thần Kiếm", role = "Kiếm Khí Băng Thanh",
        costCoin = 1000, costGem = 15,
        hair = Color3.fromRGB(196, 202, 210), armor = Color3.fromRGB(52, 78, 132),
        trim = Color3.fromRGB(116, 178, 206), fx = Color3.fromRGB(98, 174, 206),
        weapon = "katana", attackType = "melee", status = "freeze",
        hp = 152, mp = 125, atk = 32, spd = 285, crit = 0.22, range = 114, cd = 0.24,
        s1Name = "Kiếm Khí", s1Cost = 22, s1Cd = 3.8,
        s2Name = "Liên Hoàn Trảm", s2Cost = 35, s2Cd = 6.0,
        ultName = "Thiên Kiếm Hàng Lâm",
        desc = "Tóc trắng vung trường kiếm phóng sóng kiếm khí xanh lam tầm trung.",
    },
    {
        id = "dausi", name = "Đấu Sĩ", role = "Quyền Cước Hỏa Lực",
        costCoin = 1200, costGem = 20,
        hair = Color3.fromRGB(114, 72, 48), armor = Color3.fromRGB(52, 46, 54),
        trim = Color3.fromRGB(202, 82, 48), fx = Color3.fromRGB(204, 128, 52),
        weapon = "gauntlets", attackType = "melee", status = "stun",
        hp = 200, mp = 100, atk = 34, spd = 265, crit = 0.18, range = 94, cd = 0.24,
        s1Name = "Hỏa Quyền", s1Cost = 20, s1Cd = 3.8,
        s2Name = "Chấn Động", s2Cost = 32, s2Cd = 5.8,
        ultName = "Nộ Long Quyền Pháp",
        desc = "Găng tay lửa cực trâu bò, đấm choáng kẻ địch và đẩy lùi cực mạnh.",
    },
    {
        id = "kiemsu", name = "Kiếm Sư", role = "Thương Kiếm Lôi Điện",
        costCoin = 1500, costGem = 30,
        hair = Color3.fromRGB(38, 46, 68), armor = Color3.fromRGB(56, 68, 96),
        cape = Color3.fromRGB(42, 62, 112), trim = Color3.fromRGB(158, 176, 198), fx = Color3.fromRGB(76, 182, 208),
        weapon = "spear", attackType = "melee", status = "stun",
        hp = 165, mp = 130, atk = 35, spd = 280, crit = 0.24, range = 124, cd = 0.25,
        s1Name = "Lôi Thương", s1Cost = 24, s1Cd = 4.0,
        s2Name = "Xoáy Lam", s2Cost = 36, s2Cd = 6.0,
        ultName = "Thương Long Xuất Hải",
        desc = "Đòn đánh tầm dài kèm hiệu ứng choáng, cân bằng công thủ hoàn hảo.",
    },
    {
        id = "maphapsu", name = "Ma Pháp Sư", role = "Hắc Ám Hủy Diệt",
        costCoin = 2000, costGem = 45,
        hair = Color3.fromRGB(186, 88, 166), armor = Color3.fromRGB(72, 42, 92),
        trim = Color3.fromRGB(194, 108, 186), fx = Color3.fromRGB(182, 92, 188),
        weapon = "orb", attackType = "ranged", status = "burn",
        hp = 135, mp = 175, atk = 38, spd = 270, crit = 0.26, range = 400, cd = 0.23,
        s1Name = "Tia Ma Lực", s1Cost = 24, s1Cd = 3.6,
        s2Name = "Hắc Động", s2Cost = 42, s2Cd = 6.5,
        ultName = "Thiên Phạt Ma Pháp",
        desc = "Tóc hồng cầm trượng ma pháp, dồn sát thương nổ diện rộng khủng khiếp.",
    },
}

-- 5 Man choi (Stages) + 5 Boss rieng biet
CFG.STAGES = {
    { id = 1, name = "Màn 1 - Cánh Đồng Quái Vật", waves = 3, boss = "golem",  bossName = "GOLEM DUNG NHAM",  rewardCoin = 180, rewardGem = 8,  rewardExp = 120, theme = "grass" },
    { id = 2, name = "Màn 2 - Hầm Ngục Xương Khô",  waves = 4, boss = "lich",   bossName = "TỬ THẦN HÀI CỐT",  rewardCoin = 280, rewardGem = 12, rewardExp = 180, theme = "crypt" },
    { id = 3, name = "Màn 3 - Pháo Đài Băng Giá",   waves = 4, boss = "icedrag", bossName = "BĂNG LONG VƯƠNG",  rewardCoin = 400, rewardGem = 18, rewardExp = 260, theme = "ice" },
    { id = 4, name = "Màn 4 - Hang Ổ Rồng Lửa",     waves = 5, boss = "firedrag", bossName = "HỎA LONG VƯƠNG",   rewardCoin = 560, rewardGem = 25, rewardExp = 360, theme = "lava" },
    { id = 5, name = "Màn 5 - Đấu Trường Vô Tận",   waves = 999, boss = "darkknight", bossName = "HẮC MA KỴ SĨ", rewardCoin = 120, rewardGem = 6,  rewardExp = 100, theme = "void", endless = true },
}

CFG.DIFFS = {
    { id = "normal", name = "Thường",   color = C.TXT_GREEN,  hpMult = 1.0, dmgMult = 1.0, rewardMult = 1.0 },
    { id = "hard",   name = "Khó",      color = C.TXT_ORANGE, hpMult = 1.5, dmgMult = 1.35, rewardMult = 1.45 },
    { id = "hell",   name = "Ác Mộng",  color = C.TXT_RED,    hpMult = 2.2, dmgMult = 1.8, rewardMult = 2.0 },
}

-- Nang cap vinh vien ngoai sanh
CFG.UPGRADES = {
    { id = "atk",  name = "Sức Mạnh",   stat = "+12% Sát thương", baseCost = 100, step = 80,  maxLv = 20 },
    { id = "hp",   name = "Thể Lực",    stat = "+16% Máu tối đa", baseCost = 90,  step = 75,  maxLv = 20 },
    { id = "mp",   name = "Ma Lực",     stat = "+15% MP & Hồi MP", baseCost = 95, step = 75,  maxLv = 15 },
    { id = "spd",  name = "Thân Pháp",  stat = "+4% Tốc độ chạy", baseCost = 110, step = 90,  maxLv = 12 },
    { id = "crit", name = "Bạo Kích",   stat = "+3% Tỷ lệ Crit",  baseCost = 120, step = 100, maxLv = 15 },
}

-- Nang cap chon 1 trong 3 trong tran (Roguelike nhu anh 3)
CFG.INMATCH_BUFFS = {
    { id = "atk30",   name = "Tăng Sát Thương", desc = "Sát thương +30% trong trận",  color = C.TXT_RED,    apply = function(s) s.atk = math.floor(s.atk * 1.30) end },
    { id = "hp30",    name = "Tăng Máu",        desc = "HP tối đa +30% & hồi 40% HP", color = C.TXT_GREEN,  apply = function(s) s.maxHp = math.floor(s.maxHp * 1.30); s.hp = math.min(s.maxHp, s.hp + math.floor(s.maxHp * 0.4)) end },
    { id = "spd25",   name = "Tăng Tốc Độ",     desc = "Tốc độ di chuyển +25%",       color = C.TXT_GOLD,   apply = function(s) s.spd = math.floor(s.spd * 1.25) end },
    { id = "crit15",  name = "Bạo Kích Đỉnh",   desc = "Tỷ lệ chí mạng +15%",         color = C.TXT_ORANGE, apply = function(s) s.crit = math.min(0.85, s.crit + 0.15) end },
    { id = "lifesteal", name = "Hút Máu",       desc = "Hồi 6% sát thương gây ra",    color = C.TXT_GEM,    apply = function(s) s.lifesteal = (s.lifesteal or 0) + 0.06 end },
    { id = "mpboost", name = "Suối Ma Lực",     desc = "MP tối đa +40 & hồi nhanh",   color = C.TXT_CYAN,   apply = function(s) s.maxMp = s.maxMp + 40; s.mp = s.maxMp; s.mpRegen = s.mpRegen + 5 end },
    { id = "shield",  name = "Khiên Hộ Mệnh",   desc = "Nhận giáp ảo +80 HP",         color = C.SHIELD_BAR, apply = function(s) s.shield = (s.shield or 0) + 80 end },
}

CFG.QUESTS = {
    { id = "q_kill50",  title = "Tiêu Diệt 50 Quái",   target = 50, statKey = "totalKills", rewardCoin = 300, rewardGem = 15 },
    { id = "q_win3",    title = "Thắng 3 Trận Đấu",    target = 3,  statKey = "totalWins",  rewardCoin = 450, rewardGem = 20 },
    { id = "q_boss2",   title = "Hạ Gục 2 Boss",       target = 2,  statKey = "bossKills",  rewardCoin = 500, rewardGem = 30 },
    { id = "q_upg3",    title = "Nâng Cấp 3 Lần",      target = 3,  statKey = "totalUpgrades", rewardCoin = 250, rewardGem = 15 },
}

CFG.CODES = {
    ["CHIENDAU2026"] = { coins = 800,  gems = 25, msg = "Nhận 800 Xu + 25 KC" },
    ["TANTHU500"]    = { coins = 500,  gems = 15, msg = "Nhận 500 Xu + 15 KC" },
    ["FULLSCREEN"]   = { coins = 600,  gems = 30, msg = "Nhận 600 Xu + 30 KC" },
    ["TRANGVIP2026"] = { coins = 1000, gems = 30, gear = "epic", msg = "Nhận 1000 Xu + 30 KC + 1 Trang Bị Sử Thi+" },
    ["RUONGVANG"]    = { coins = 1200, gems = 20, msg = "Nhận 1200 Xu + 20 KC" },
    ["TUONGMOI"]     = { coins = 1500, gems = 40, msg = "Nhận 1500 Xu + 40 KC" },
    ["SANBOSS2026"]  = { coins = 800,  gems = 50, msg = "Nhận 800 Xu + 50 KC" },
}
CFG.ADMIN_CODE = "ADMINFULLALL21112026" 

-- He thong Do Hiem & Kho Trang Bi (6 O: Vu Khi, Mu, Giay, Ao Giap, Phu Kien, Canh)
CFG.RARITIES = {
    common = { name = "Thường",     color = Color3.fromRGB(152, 160, 174), mult = 1.0, sell = 45 },
    rare   = { name = "Hiếm",       color = Color3.fromRGB(86, 154, 204),  mult = 1.45, sell = 95 },
    epic   = { name = "Sử Thi",     color = Color3.fromRGB(156, 102, 202), mult = 2.0, sell = 180 },
    legend = { name = "Huyền Thoại", color = Color3.fromRGB(204, 168, 76),  mult = 2.8, sell = 340 },
    mythic = { name = "Thần Thoại", color = Color3.fromRGB(198, 86, 118),  mult = 3.8, sell = 600 },
}

CFG.GEAR_SLOTS = {
    { id = "weapon", label = "Vũ Khí",   cat = "weapon" },
    { id = "helm",   label = "Mũ / Nón", cat = "armor"  },
    { id = "boots",  label = "Giày",     cat = "armor"  },
    { id = "armor",  label = "Áo Giáp",  cat = "armor"  },
    { id = "neck",   label = "Phụ Kiện", cat = "acc"    },
    { id = "wings",  label = "Cánh",     cat = "wings"  },
}

CFG.GEAR_POOL = {
    -- Vu Khi
    { id = "w_iron",   slot = "weapon", name = "Kiếm Sắt",         rarity = "common", atk = 10, hp = 0,   def = 0,  spd = 0,  col = Color3.fromRGB(162, 170, 182) },
    { id = "w_frost",  slot = "weapon", name = "Băng Kiếm",        rarity = "rare",   atk = 20, hp = 15,  def = 0,  spd = 4,  col = Color3.fromRGB(84, 162, 204) },
    { id = "w_flame",  slot = "weapon", name = "Hỏa Long Kiếm",    rarity = "epic",   atk = 34, hp = 25,  def = 4,  spd = 6,  col = Color3.fromRGB(198, 78, 62) },
    { id = "w_gold",   slot = "weapon", name = "Thánh Kiếm Hoàng Kim", rarity = "legend", atk = 52, hp = 40, def = 8, spd = 10, col = Color3.fromRGB(204, 168, 72) },
    { id = "w_void",   slot = "weapon", name = "Ma Kiếm Hư Không", rarity = "mythic", atk = 78, hp = 60,  def = 12, spd = 14, col = Color3.fromRGB(168, 86, 202) },
    -- Ao Giap
    { id = "a_iron",   slot = "armor",  name = "Giáp Tân Thủ",     rarity = "common", atk = 0,  hp = 35,  def = 8,  spd = 0,  col = Color3.fromRGB(142, 148, 162) },
    { id = "a_frost",  slot = "armor",  name = "Giáp Băng Lam",    rarity = "rare",   atk = 4,  hp = 75,  def = 16, spd = 2,  col = Color3.fromRGB(72, 134, 192) },
    { id = "a_flame",  slot = "armor",  name = "Giáp Huyết Long",  rarity = "epic",   atk = 8,  hp = 130, def = 26, spd = 4,  col = Color3.fromRGB(182, 64, 62) },
    { id = "a_gold",   slot = "armor",  name = "Giáp Hoàng Đế",    rarity = "legend", atk = 14, hp = 210, def = 40, spd = 6,  col = Color3.fromRGB(198, 158, 66) },
    { id = "a_void",   slot = "armor",  name = "Giáp Hắc Ám",      rarity = "mythic", atk = 22, hp = 320, def = 58, spd = 10, col = Color3.fromRGB(132, 74, 186) },
    -- Mu / Non
    { id = "h_iron",   slot = "helm",   name = "Mũ Hiệp Sĩ",       rarity = "common", atk = 2,  hp = 25,  def = 6,  spd = 0,  col = Color3.fromRGB(148, 156, 168) },
    { id = "h_frost",  slot = "helm",   name = "Mũ Băng Giá",      rarity = "rare",   atk = 5,  hp = 55,  def = 12, spd = 3,  col = Color3.fromRGB(78, 148, 196) },
    { id = "h_horn",   slot = "helm",   name = "Mũ Sừng Ma Vương", rarity = "epic",   atk = 12, hp = 90,  def = 20, spd = 5,  col = Color3.fromRGB(178, 62, 66) },
    { id = "h_crown",  slot = "helm",   name = "Vương Miện Vàng",  rarity = "legend", atk = 20, hp = 150, def = 30, spd = 8,  col = Color3.fromRGB(204, 170, 74) },
    -- Giay
    { id = "b_leather", slot = "boots", name = "Giày Da Chiến",    rarity = "common", atk = 0,  hp = 18,  def = 4,  spd = 12, col = Color3.fromRGB(138, 96, 68) },
    { id = "b_wind",    slot = "boots", name = "Giày Phong Hành",  rarity = "rare",   atk = 4,  hp = 36,  def = 8,  spd = 24, col = Color3.fromRGB(76, 146, 196) },
    { id = "b_flame",   slot = "boots", name = "Giày Hỏa Tốc",     rarity = "epic",   atk = 8,  hp = 65,  def = 14, spd = 38, col = Color3.fromRGB(186, 72, 64) },
    { id = "b_void",    slot = "boots", name = "Giày Ảnh Bộ",      rarity = "legend", atk = 14, hp = 110, def = 22, spd = 52, col = Color3.fromRGB(148, 86, 194) },
    -- Phu Kien (Day chuyen / Nhan)
    { id = "n_ring",   slot = "neck",   name = "Nhẫn Bạc",         rarity = "common", atk = 6,  hp = 20,  def = 4,  spd = 4,  col = Color3.fromRGB(168, 174, 184) },
    { id = "n_sapph",  slot = "neck",   name = "Dây Chuyền Lam Ngọc", rarity = "rare", atk = 12, hp = 45,  def = 10, spd = 8,  col = Color3.fromRGB(82, 158, 204) },
    { id = "n_ruby",   slot = "neck",   name = "Dây Chuyền Hồng Ngọc", rarity = "epic", atk = 22, hp = 80, def = 16, spd = 12, col = Color3.fromRGB(194, 74, 78) },
    { id = "n_void",   slot = "neck",   name = "Hồn Ngọc Tối Thượng", rarity = "mythic", atk = 40, hp = 145, def = 28, spd = 20, col = Color3.fromRGB(166, 92, 204) },
    -- Canh / Ao Choang (Hien thi truc tiep tren nhan vat!)
    { id = "c_cape",   slot = "wings",  name = "Áo Choàng Đỏ",     rarity = "common", atk = 4,  hp = 30,  def = 6,  spd = 8,  col = Color3.fromRGB(178, 56, 56) },
    { id = "c_angel",  slot = "wings",  name = "Cánh Thiên Thần",  rarity = "rare",   atk = 10, hp = 70,  def = 14, spd = 16, col = Color3.fromRGB(192, 198, 206) },
    { id = "c_bat",    slot = "wings",  name = "Cánh Dơi Huyết Nguyệt", rarity = "epic", atk = 20, hp = 115, def = 22, spd = 24, col = Color3.fromRGB(176, 54, 62) },
    { id = "c_ice",    slot = "wings",  name = "Cánh Băng Tinh",   rarity = "legend", atk = 32, hp = 180, def = 34, spd = 32, col = Color3.fromRGB(88, 172, 206) },
    { id = "c_shadow", slot = "wings",  name = "Cánh Bóng Đêm Thần Thoại", rarity = "mythic", atk = 48, hp = 260, def = 46, spd = 42, col = Color3.fromRGB(142, 78, 198) },
}


-- ============================================================================
-- 3. LUU TRU 2 LOP (FILE JSON + _G FALLBACK)
-- ============================================================================
local SAVE = {}
local DATA = nil

local function getDefaultData()
    return {
        level = 1,
        exp = 0,
        coins = 300,
        gems = 20,
        bestScore = 0,
        totalKills = 0,
        totalWins = 0,
        bossKills = 0,
        totalUpgrades = 0,
        selectedHero = "chienbinh",
        selectedStage = 1,
        selectedDiff = "normal",
        unlockedHeroes = { chienbinh = true },
        upgrades = { atk = 0, hp = 0, mp = 0, spd = 0, crit = 0 },
        claimedQuests = {},
        usedCodes = {},
        settings = {
            shake = true,
            particles = true,
            minimap = true,
            autoAim = true,
        },
        nextUid = 5,
        inventory = {
            { uid = 1, id = "w_iron",   lv = 0 },
            { uid = 2, id = "a_iron",   lv = 0 },
            { uid = 3, id = "c_cape",   lv = 0 },
            { uid = 4, id = "n_ring",   lv = 0 },
        },
        equipped = {
            weapon = 1,
            armor = 2,
            wings = 3,
        },
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
            local fn = getSaveFileName()
            return isfile(fn) and readfile(fn) or nil
        end)
        if ok and type(raw) == "string" and #raw > 2 then
            local okD, dec = pcall(function() return HttpService:JSONDecode(raw) end)
            if okD and type(dec) == "table" then loaded = dec end
        end
    end
    if not loaded then
        local env = (type(getgenv) == "function" and getgenv()) or _G
        if type(env.ArenaChienDauV2_Save) == "table" then loaded = env.ArenaChienDauV2_Save end
    end
    if type(loaded) == "table" then
        for k, v in pairs(def) do
            if loaded[k] == nil then loaded[k] = v end
        end
        if type(loaded.unlockedHeroes) ~= "table" then loaded.unlockedHeroes = { chienbinh = true } end
        loaded.unlockedHeroes.chienbinh = true
        if type(loaded.upgrades) ~= "table" then loaded.upgrades = def.upgrades end
        for k, v in pairs(def.upgrades) do if loaded.upgrades[k] == nil then loaded.upgrades[k] = v end end
        if type(loaded.settings) ~= "table" then loaded.settings = def.settings end
        for k, v in pairs(def.settings) do if loaded.settings[k] == nil then loaded.settings[k] = v end end
        if type(loaded.claimedQuests) ~= "table" then loaded.claimedQuests = {} end
        if type(loaded.usedCodes) ~= "table" then loaded.usedCodes = {} end
        if type(loaded.inventory) ~= "table" then loaded.inventory = def.inventory end
        if type(loaded.equipped) ~= "table" then loaded.equipped = def.equipped end
        if type(loaded.nextUid) ~= "number" then loaded.nextUid = 10 end
        DATA = loaded
    else
        DATA = def
    end
end

function SAVE.Write()
    if not DATA then return end
    local env = (type(getgenv) == "function" and getgenv()) or _G
    env.ArenaChienDauV2_Save = DATA
    if type(writefile) == "function" then
        pcall(function() writefile(getSaveFileName(), HttpService:JSONEncode(DATA)) end)
    end
end

function SAVE.Reset()
    DATA = getDefaultData()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    env.ArenaChienDauV2_Save = DATA
    if type(delfile) == "function" and type(isfile) == "function" then
        pcall(function()
            local fn = getSaveFileName()
            if isfile(fn) then delfile(fn) end
        end)
    end
    SAVE.Write()
end

SAVE.Load()

-- ============================================================================
-- 4. TIEN ICH UI, TINH CHI SO, VA DO HOA CHIBI / BOSS / MOB TU VE
-- ============================================================================
local UI = {}
local CONNS = {}
local GAME = {}

local function trackConn(c) table.insert(CONNS, c); return c end

local function getHeroById(id)
    for _, h in ipairs(CFG.HEROES) do if h.id == id then return h end end
    return CFG.HEROES[1]
end

local function getStageById(id)
    for _, st in ipairs(CFG.STAGES) do if st.id == id then return st end end
    return CFG.STAGES[1]
end

local function getDiffById(id)
    for _, df in ipairs(CFG.DIFFS) do if df.id == id then return df end end
    return CFG.DIFFS[1]
end

local function getExpNeeded(lv)
    return 100 + (lv - 1) * 65
end

local GEAR = {}
function GEAR.GetDef(id)
    for _, g in ipairs(CFG.GEAR_POOL) do if g.id == id then return g end end
    return CFG.GEAR_POOL[1]
end
function GEAR.FindByUid(uid)
    if not uid then return nil, nil end
    for idx, it in ipairs(DATA.inventory) do
        if it.uid == uid then return it, idx end
    end
    return nil, nil
end
function GEAR.IsEquipped(uid)
    for _, eqUid in pairs(DATA.equipped) do
        if eqUid == uid then return true end
    end
    return false
end
function GEAR.GetItemStats(it)
    local d = GEAR.GetDef(it.id)
    local mult = 1 + (it.lv or 0) * 0.15
    return {
        def = d,
        atk = math.floor(d.atk * mult),
        hp  = math.floor(d.hp * mult),
        arm = math.floor(d.def * mult),
        spd = math.floor(d.spd * mult),
    }
end
function GEAR.AddRandom(minRarity)
    local pool = {}
    local rank = { common = 1, rare = 2, epic = 3, legend = 4, mythic = 5 }
    local minR = rank[minRarity or "common"] or 1
    for _, g in ipairs(CFG.GEAR_POOL) do
        if (rank[g.rarity] or 1) >= minR then table.insert(pool, g) end
    end
    local pick = pool[RNG:NextInteger(1, #pool)]
    DATA.nextUid = (DATA.nextUid or 10) + 1
    local newItem = { uid = DATA.nextUid, id = pick.id, lv = 0 }
    table.insert(DATA.inventory, newItem)
    return newItem, pick
end


local function computeStats()
    local h = getHeroById(DATA.selectedHero)
    local u = DATA.upgrades
    local lvBonus = 1 + (DATA.level - 1) * 0.08
    local gHp, gAtk, gDef, gSpd = 0, 0, 0, 0
    local wingCol, weapCol = nil, nil
    for slot, uid in pairs(DATA.equipped or {}) do
        local it = GEAR.FindByUid(uid)
        if it then
            local st = GEAR.GetItemStats(it)
            gHp = gHp + st.hp
            gAtk = gAtk + st.atk
            gDef = gDef + st.arm
            gSpd = gSpd + st.spd
            if slot == "wings" then wingCol = st.def.col end
            if slot == "weapon" then weapCol = st.def.col end
        end
    end
    local maxHp = math.floor(h.hp * lvBonus * (1 + (u.hp or 0) * 0.16)) + gHp
    local maxMp = math.floor(h.mp * (1 + (u.mp or 0) * 0.15))
    local atk   = math.floor(h.atk * lvBonus * (1 + (u.atk or 0) * 0.12)) + gAtk
    local def   = math.floor(10 + (DATA.level - 1) * 2) + gDef
    local spd   = math.floor(h.spd * (1 + (u.spd or 0) * 0.04)) + gSpd
    local crit  = math.min(0.75, h.crit + (u.crit or 0) * 0.03)
    local mpReg = 8 + (u.mp or 0) * 1.5
    local power = math.floor(maxHp * 0.8 + atk * 18 + def * 12 + spd * 0.6 + crit * 500 + maxMp * 1.2)
    return {
        hero = h, maxHp = maxHp, maxMp = maxMp, atk = atk, def = def, spd = spd,
        crit = crit, mpRegen = mpReg, power = power, wingCol = wingCol, weapCol = weapCol,
    }
end

local function addCorner(inst, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or 8)
    c.Parent = inst
    return c
end

local function addStroke(inst, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or C.BORDER
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function addGrad(inst, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2) })
    g.Rotation = rot or 90
    g.Parent = inst
    return g
end

-- Ve bieu tuong do hoa cho tung loai trang bi (Vu Khi, Ao Giap, Mu, Giay, Phu Kien, Canh)
local function buildGearIcon(parent, d, zBase)
    for _, ch in ipairs(parent:GetChildren()) do
        if ch.Name == "GearIcon" then ch:Destroy() end
    end
    local box = Instance.new("Frame")
    box.Name = "GearIcon"
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Position = UDim2.new(0.5, 0, 0.5, 0)
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    box.ZIndex = zBase
    box.Parent = parent

    local col = (d and d.col) or C.METAL
    local slot = d and d.slot or "weapon"

    if slot == "weapon" then
        -- Kiem cheo co luoi sac, song kiem sang, chan kiem vang va chuoi kiem
        local pivot = Instance.new("Frame")
        pivot.AnchorPoint = Vector2.new(0.5, 0.5)
        pivot.Position = UDim2.new(0.5, 0, 0.5, 0)
        pivot.Size = UDim2.new(1, 0, 1, 0)
        pivot.Rotation = -42
        pivot.BackgroundTransparency = 1
        pivot.ZIndex = zBase
        pivot.Parent = box

        local blade = Instance.new("Frame")
        blade.AnchorPoint = Vector2.new(0.5, 1)
        blade.Position = UDim2.new(0.5, 0, 0.66, 0)
        blade.Size = UDim2.new(0.24, 0, 0.62, 0)
        blade.BackgroundColor3 = col
        blade.BorderSizePixel = 0
        blade.ZIndex = zBase + 1
        blade.Parent = pivot
        addCorner(blade, 4)
        addStroke(blade, C.TXT_DARK, 1.2)

        local edge = Instance.new("Frame")
        edge.AnchorPoint = Vector2.new(0.5, 0.5)
        edge.Position = UDim2.new(0.5, 0, 0.48, 0)
        edge.Size = UDim2.new(0.38, 0, 0.78, 0)
        edge.BackgroundColor3 = C.TXT_MAIN
        edge.BackgroundTransparency = 0.45
        edge.BorderSizePixel = 0
        edge.ZIndex = zBase + 2
        edge.Parent = blade
        addCorner(edge, 2)

        local guard = Instance.new("Frame")
        guard.AnchorPoint = Vector2.new(0.5, 0.5)
        guard.Position = UDim2.new(0.5, 0, 0.68, 0)
        guard.Size = UDim2.new(0.58, 0, 0.13, 0)
        guard.BackgroundColor3 = C.BORDER_GOLD
        guard.BorderSizePixel = 0
        guard.ZIndex = zBase + 2
        guard.Parent = pivot
        addCorner(guard, 3)
        addStroke(guard, C.TXT_DARK, 1)

        local hilt = Instance.new("Frame")
        hilt.AnchorPoint = Vector2.new(0.5, 0)
        hilt.Position = UDim2.new(0.5, 0, 0.72, 0)
        hilt.Size = UDim2.new(0.16, 0, 0.24, 0)
        hilt.BackgroundColor3 = Color3.fromRGB(92, 62, 46)
        hilt.BorderSizePixel = 0
        hilt.ZIndex = zBase + 1
        hilt.Parent = pivot
        addCorner(hilt, 3)
    elseif slot == "armor" then
        -- Ao giap: vai giap + than giap + vien ngoc giua nguc + that lung
        local sh = Instance.new("Frame")
        sh.AnchorPoint = Vector2.new(0.5, 0)
        sh.Position = UDim2.new(0.5, 0, 0.14, 0)
        sh.Size = UDim2.new(0.84, 0, 0.34, 0)
        sh.BackgroundColor3 = col
        sh.BorderSizePixel = 0
        sh.ZIndex = zBase + 1
        sh.Parent = box
        addCorner(sh, 6)
        addStroke(sh, C.TXT_DARK, 1.2)

        local torso = Instance.new("Frame")
        torso.AnchorPoint = Vector2.new(0.5, 0)
        torso.Position = UDim2.new(0.5, 0, 0.28, 0)
        torso.Size = UDim2.new(0.58, 0, 0.56, 0)
        torso.BackgroundColor3 = col
        torso.BorderSizePixel = 0
        torso.ZIndex = zBase + 2
        torso.Parent = box
        addCorner(torso, 5)
        addStroke(torso, C.TXT_DARK, 1.2)

        local belt = Instance.new("Frame")
        belt.AnchorPoint = Vector2.new(0.5, 0.5)
        belt.Position = UDim2.new(0.5, 0, 0.70, 0)
        belt.Size = UDim2.new(0.60, 0, 0.14, 0)
        belt.BackgroundColor3 = C.BORDER_GOLD
        belt.BorderSizePixel = 0
        belt.ZIndex = zBase + 3
        belt.Parent = box
        addCorner(belt, 2)

        local gem = Instance.new("Frame")
        gem.AnchorPoint = Vector2.new(0.5, 0.5)
        gem.Position = UDim2.new(0.5, 0, 0.44, 0)
        gem.Size = UDim2.new(0.20, 0, 0.20, 0)
        gem.Rotation = 45
        gem.BackgroundColor3 = C.TXT_MAIN
        gem.BorderSizePixel = 0
        gem.ZIndex = zBase + 3
        gem.Parent = box
        addCorner(gem, 2)
    elseif slot == "helm" then
        -- Mu giap / Vuong mien
        local dome = Instance.new("Frame")
        dome.AnchorPoint = Vector2.new(0.5, 0.5)
        dome.Position = UDim2.new(0.5, 0, 0.54, 0)
        dome.Size = UDim2.new(0.68, 0, 0.62, 0)
        dome.BackgroundColor3 = col
        dome.BorderSizePixel = 0
        dome.ZIndex = zBase + 1
        dome.Parent = box
        addCorner(dome, 9)
        addStroke(dome, C.TXT_DARK, 1.2)

        local visor = Instance.new("Frame")
        visor.AnchorPoint = Vector2.new(0.5, 0.5)
        visor.Position = UDim2.new(0.5, 0, 0.60, 0)
        visor.Size = UDim2.new(0.46, 0, 0.18, 0)
        visor.BackgroundColor3 = C.TXT_DARK
        visor.BorderSizePixel = 0
        visor.ZIndex = zBase + 2
        visor.Parent = box
        addCorner(visor, 2)

        if d and (d.id == "h_horn" or d.id == "h_crown") then
            for _, sx in ipairs({ 0.22, 0.78 }) do
                local horn = Instance.new("Frame")
                horn.AnchorPoint = Vector2.new(0.5, 1)
                horn.Position = UDim2.new(sx, 0, 0.30, 0)
                horn.Size = UDim2.new(0.18, 0, 0.28, 0)
                horn.Rotation = (sx < 0.5) and -20 or 20
                horn.BackgroundColor3 = C.TXT_GOLD
                horn.BorderSizePixel = 0
                horn.ZIndex = zBase + 2
                horn.Parent = box
                addCorner(horn, 2)
            end
        end
    elseif slot == "boots" then
        -- Doi giay chien
        for _, bx in ipairs({ 0.34, 0.68 }) do
            local leg = Instance.new("Frame")
            leg.AnchorPoint = Vector2.new(0.5, 0.5)
            leg.Position = UDim2.new(bx, 0, 0.50, 0)
            leg.Size = UDim2.new(0.28, 0, 0.56, 0)
            leg.BackgroundColor3 = col
            leg.BorderSizePixel = 0
            leg.ZIndex = zBase + 1
            leg.Parent = box
            addCorner(leg, 4)
            addStroke(leg, C.TXT_DARK, 1.1)

            local foot = Instance.new("Frame")
            foot.AnchorPoint = Vector2.new(0.5, 1)
            foot.Position = UDim2.new(bx + 0.05, 0, 0.84, 0)
            foot.Size = UDim2.new(0.36, 0, 0.24, 0)
            foot.BackgroundColor3 = col
            foot.BorderSizePixel = 0
            foot.ZIndex = zBase + 2
            foot.Parent = box
            addCorner(foot, 4)
            addStroke(foot, C.TXT_DARK, 1.1)
        end
    elseif slot == "neck" then
        -- Day chuyen / Nhan co vien ngoc
        local ring = Instance.new("Frame")
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.new(0.5, 0, 0.44, 0)
        ring.Size = UDim2.new(0.58, 0, 0.58, 0)
        ring.BackgroundTransparency = 1
        ring.ZIndex = zBase + 1
        ring.Parent = box
        addCorner(ring, 99)
        addStroke(ring, C.BORDER_GOLD, 2.2)

        local gem = Instance.new("Frame")
        gem.AnchorPoint = Vector2.new(0.5, 0.5)
        gem.Position = UDim2.new(0.5, 0, 0.72, 0)
        gem.Size = UDim2.new(0.30, 0, 0.30, 0)
        gem.Rotation = 45
        gem.BackgroundColor3 = col
        gem.BorderSizePixel = 0
        gem.ZIndex = zBase + 2
        gem.Parent = box
        addCorner(gem, 3)
        addStroke(gem, C.TXT_MAIN, 1.1)
    else
        -- Canh / Ao choang 2 ben doi xung
        for _, side in ipairs({ -1, 1 }) do
            local w1 = Instance.new("Frame")
            w1.AnchorPoint = Vector2.new(0.5, 0.5)
            w1.Position = UDim2.new(0.5 + side * 0.24, 0, 0.48, 0)
            w1.Size = UDim2.new(0.40, 0, 0.64, 0)
            w1.Rotation = side * 24
            w1.BackgroundColor3 = col
            w1.BorderSizePixel = 0
            w1.ZIndex = zBase + 1
            w1.Parent = box
            addCorner(w1, 7)
            addStroke(w1, C.TXT_DARK, 1.1)

            local w2 = Instance.new("Frame")
            w2.AnchorPoint = Vector2.new(0.5, 0.5)
            w2.Position = UDim2.new(0.5 + side * 0.16, 0, 0.62, 0)
            w2.Size = UDim2.new(0.28, 0, 0.38, 0)
            w2.Rotation = side * 14
            w2.BackgroundColor3 = C.TXT_MAIN
            w2.BackgroundTransparency = 0.55
            w2.BorderSizePixel = 0
            w2.ZIndex = zBase + 2
            w2.Parent = box
            addCorner(w2, 5)
        end
    end
    return box
end


local function makeLabel(parent, p)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = p.font or FONT_BODY
    l.TextColor3 = p.color or C.TXT_MAIN
    l.TextSize = p.size or 14
    l.Text = p.text or ""
    l.TextXAlignment = p.xAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = p.yAlign or Enum.TextYAlignment.Center
    l.TextWrapped = p.wrap or false
    l.Size = p.dim or UDim2.new(1, 0, 0, 20)
    l.Position = p.pos or UDim2.new(0, 0, 0, 0)
    l.AnchorPoint = p.anchor or Vector2.new(0, 0)
    l.ZIndex = p.z or 2
    l.Parent = parent
    return l
end

local function makeBtn(parent, p)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = p.bg or C.BTN_DARK
    b.Font = p.font or FONT_TITLE
    b.TextColor3 = p.color or C.TXT_MAIN
    b.TextSize = p.size or 13
    b.Text = p.text or ""
    b.Size = p.dim or UDim2.new(0, 100, 0, 34)
    b.Position = p.pos or UDim2.new(0, 0, 0, 0)
    b.AnchorPoint = p.anchor or Vector2.new(0, 0)
    b.ZIndex = p.z or 3
    b.Parent = parent
    addCorner(b, p.radius or 8)
    if p.stroke ~= false then
        addStroke(b, p.strokeColor or C.BORDER, p.strokeWidth or 1)
    end
    return b
end

local function bindTap(btn, cb)
    local last = 0
    trackConn(btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            local now = os.clock()
            if now - last < 0.12 then return end
            last = now
            cb()
        end
    end))
end

-- Ve nhan vat full-body da lop (theo mau WarriorSkin: bong, chan, giay, ao choang, giap gradient, dai lung, vai, tay, gang, co, dau, toc, mat, mu, vu khi)
local function buildChibiHero(container, hero, zBase, hideWeapon)
    for _, ch in ipairs(container:GetChildren()) do
        if ch.Name == "HeroArt" then ch:Destroy() end
    end

    local root = Instance.new("Frame")
    root.Name = "HeroArt"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.Size = UDim2.new(1, 0, 1, 0)
    root.BackgroundTransparency = 1
    root.ZIndex = zBase
    root.Parent = container

    -- Neu nguoi dung dan rbxassetid rieng cho tuong -> hien thi truc tiep
    local customId = CFG.CUSTOM_SPRITE_IDS and CFG.CUSTOM_SPRITE_IDS[hero.id]
    if type(customId) == "string" and #customId > 5 then
        local img = Instance.new("ImageLabel")
        img.Name = "CustomSprite"
        img.Size = UDim2.new(1.15, 0, 1.15, 0)
        img.Position = UDim2.new(0.5, 0, 0.5, 0)
        img.AnchorPoint = Vector2.new(0.5, 0.5)
        img.BackgroundTransparency = 1
        img.Image = customId
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = zBase + 2
        img.Parent = root
        return root, nil
    end

    -- Helper tao tung bo phan theo ty le chuan 300x340 tu mau WarriorSkin
    local outlineCol = Color3.fromRGB(24, 20, 26)
    local function part(name, sx, sy, px, py, col, rad, rot, zOff)
        local f = Instance.new("Frame")
        f.Name = name
        f.Size = UDim2.new(sx / 300, 0, sy / 340, 0)
        f.Position = UDim2.new(px / 300, 0, py / 340, 0)
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BackgroundColor3 = col
        f.BorderSizePixel = 0
        f.Rotation = rot or 0
        f.ZIndex = zBase + (zOff or 1)
        f.Parent = root
        addCorner(f, rad or 3)
        addStroke(f, outlineCol, 1.1)
        return f
    end

    -- Bang mau rieng theo tung tuong (Chien Binh dung chuan bang mau WarriorSkin cua ban)
    local black   = Color3.fromRGB(30, 25, 32)
    local skinCol = Color3.fromRGB(208, 174, 138)
    local steel   = Color3.fromRGB(178, 188, 202)
    local mainCol = (hero.id == "chienbinh") and Color3.fromRGB(184, 42, 46) or hero.armor
    local darkCol = (hero.id == "chienbinh") and Color3.fromRGB(112, 24, 30) or (hero.cape or hero.armor)
    local trimCol = (hero.id == "chienbinh") and Color3.fromRGB(204, 162, 56) or hero.trim
    local hairCol = (hero.id == "chienbinh") and black or hero.hair

    -- Canh trang bi (hien sau lung neu da mac Canh trong tab Trang Bi)
    if not hideWeapon and DATA and DATA.equipped and DATA.equipped.wings then
        local wIt = GEAR.FindByUid(DATA.equipped.wings)
        if wIt then
            local wd = GEAR.GetDef(wIt.id)
            part("WingL", 88, 108, 66, 172, wd.col, 8, -22, 0)
            part("WingR", 88, 108, 234, 172, wd.col, 8, 22, 0)
        end
    end

    -- Bong duoi chan
    local sh = part("Shadow", 104, 24, 150, 286, Color3.fromRGB(20, 18, 26), 10, 0, 0)
    sh.BackgroundTransparency = 0.45

    -- Chan & Giay
    part("LeftLeg",   26, 50, 128, 242, darkCol, 3, 0, 1)
    part("RightLeg",  26, 50, 172, 242, darkCol, 3, 0, 1)
    part("LeftBoot",  32, 20, 124, 268, black,   3, 0, 2)
    part("RightBoot", 32, 20, 176, 268, black,   3, 0, 2)

    -- Ao choang sau lung
    if not hideWeapon then
        part("Cape", 96, 106, 150, 182, darkCol, 6, 0, 1)
    end

    -- Than giap + UIGradient chieu sau
    local body = part("ArmorBody", 68, 86, 150, 186, mainCol, 5, 0, 2)
    local topTone = Color3.new(
        math.min(1, mainCol.R * 1.25),
        math.min(1, mainCol.G * 1.25),
        math.min(1, mainCol.B * 1.25)
    )
    local botTone = Color3.new(mainCol.R * 0.62, mainCol.G * 0.62, mainCol.B * 0.62)
    addGrad(body, topTone, botTone, 90)

    -- Dai lung & Khoa vang
    part("Belt",       70, 14, 150, 216, black,   2, 0, 3)
    part("BeltBuckle", 18, 18, 150, 216, trimCol, 2, 0, 4)

    -- Vai giap & Tay & Gang tay
    part("LeftShoulder",  32, 36, 108, 156, trimCol, 5, 0, 4)
    part("RightShoulder", 32, 36, 192, 156, trimCol, 5, 0, 4)
    part("LeftArm",       24, 54, 104, 192, mainCol, 4, 0, 3)
    part("RightArm",      24, 54, 196, 192, mainCol, 4, 0, 3)
    local gloveCol = (hero.id == "dausi") and trimCol or black
    local gloveSz  = (hero.id == "dausi") and 34 or 26
    part("LeftGlove",  gloveSz, gloveSz, 104, 222, gloveCol, 5, 0, 4)
    part("RightGlove", gloveSz, gloveSz, 196, 222, gloveCol, 5, 0, 4)

    -- Co, Dau, Toc, Mat
    part("Neck",     26, 20, 150, 126, skinCol, 3, 0, 3)
    part("Head",     74, 76, 150, 100, skinCol, 9, 0, 4)
    part("Hair",     80, 34, 150, 70,  hairCol, 6, 0, 5)
    part("LeftEye",  10, 11, 134, 106, black,   4, 0, 5)
    part("RightEye", 10, 11, 166, 106, black,   4, 0, 5)

    -- Mu giap / Mu trum tuy class
    if hero.id == "chienbinh" or hero.id == "kiemsu" or hero.id == "thankiem" then
        part("Helmet",       88, 28, 150, 56, steel,   5, 0, 6)
        part("HelmetCenter", 16, 32, 150, 56, trimCol, 3, 0, 7)
    elseif hero.hood then
        part("HoodTop", 90, 38, 150, 60, mainCol, 8, 0, 6)
    end

    if hideWeapon then return root, nil end

    -- Mau luoi vu khi theo trang bi dang mac (neu co)
    local weapCol = steel
    if DATA and DATA.equipped and DATA.equipped.weapon then
        local eqW = GEAR.FindByUid(DATA.equipped.weapon)
        if eqW then weapCol = GEAR.GetDef(eqW.id).col end
    end

    -- Khop vu khi (xoay & vung trong chien dau)
    local wp = Instance.new("Frame")
    wp.Name = "WeaponPivot"
    wp.AnchorPoint = Vector2.new(0.5, 0.5)
    wp.Position = UDim2.new(196 / 300, 0, 195 / 340, 0)
    wp.Size = UDim2.new(1, 0, 1, 0)
    wp.BackgroundTransparency = 1
    wp.ZIndex = zBase + 6
    wp.Parent = root

    local function wPart(name, sx, sy, px, py, col, rad, rot, zOff)
        local f = Instance.new("Frame")
        f.Name = name
        f.Size = UDim2.new(sx / 300, 0, sy / 340, 0)
        f.Position = UDim2.new(px / 300, 0, py / 340, 0)
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BackgroundColor3 = col
        f.BorderSizePixel = 0
        f.Rotation = rot or 0
        f.ZIndex = zBase + (zOff or 6)
        f.Parent = wp
        addCorner(f, rad or 3)
        addStroke(f, outlineCol, 1.1)
        return f
    end

    if hero.weapon == "sword" or hero.weapon == "katana" or hero.weapon == "spear" then
        local len = (hero.weapon == "spear") and 126 or 108
        wPart("SwordBlade",  18, len, 185, 118, weapCol, 3, 35, 6)
        wPart("SwordGuard",  40, 12,  156, 160, trimCol, 2, 35, 7)
        wPart("SwordHandle", 13, 34,  144, 178, darkCol, 2, 35, 6)
    elseif hero.weapon == "daggers" then
        wPart("DaggerBlade", 14, 72, 178, 134, hero.fx, 3, 38, 6)
        wPart("DaggerGuard", 28, 10, 156, 164, trimCol, 2, 38, 7)
    elseif hero.weapon == "staff" or hero.weapon == "orb" then
        wPart("StaffRod", 12, 118, 176, 126, steel,   2, 26, 6)
        wPart("StaffOrb", 30, 30,  200, 74,  hero.fx, 15, 0, 7)
    elseif hero.weapon == "bow" then
        wPart("BowArc", 26, 98, 184, 146, trimCol, 12, 10, 6)
        wPart("BowGem", 16, 16, 196, 146, hero.fx, 8,  0,  7)
    end

    return root, wp
end

-- Ve quai phu & 5 Boss dac trung theo hinh anh tham khao
local function decorateEnemySprite(node, kind, isBoss, zBase)
    local sh = Instance.new("Frame")
    sh.AnchorPoint = Vector2.new(0.5, 0.5)
    sh.Position = UDim2.new(0.5, 0, 0.94, 0)
    sh.Size = UDim2.new(0.95, 0, 0.34, 0)
    sh.BackgroundColor3 = C.SHADOW
    sh.BackgroundTransparency = 0.45
    sh.BorderSizePixel = 0
    sh.ZIndex = zBase - 1
    sh.Parent = node
    addCorner(sh, 99)

    if isBoss then
        local aura = Instance.new("Frame")
        aura.AnchorPoint = Vector2.new(0.5, 0.5)
        aura.Position = UDim2.new(0.5, 0, 0.5, 0)
        aura.Size = UDim2.new(1.45, 0, 1.45, 0)
        aura.BackgroundColor3 = node.BackgroundColor3
        aura.BackgroundTransparency = 0.84
        aura.BorderSizePixel = 0
        aura.ZIndex = zBase - 1
        aura.Parent = node
        addCorner(aura, 999)
        addStroke(aura, C.TXT_GOLD, 1.8)

        -- Canh rong cho Hoa Long / Bang Long
        if kind == "firedrag" or kind == "icedrag" then
            for _, side in ipairs({ -1, 1 }) do
                local wing = Instance.new("Frame")
                wing.AnchorPoint = Vector2.new(0.5, 0.5)
                wing.Position = UDim2.new(0.5 + side * 0.72, 0, 0.42, 0)
                wing.Size = UDim2.new(0.65, 0, 0.76, 0)
                wing.Rotation = side * 18
                wing.BackgroundColor3 = (kind == "firedrag") and Color3.fromRGB(178, 64, 48) or Color3.fromRGB(72, 134, 188)
                wing.BorderSizePixel = 0
                wing.ZIndex = zBase - 1
                wing.Parent = node
                addCorner(wing, 8)
                addStroke(wing, C.TXT_DARK, 1.2)
            end
        end

        -- Cap sung Boss
        for _, sx in ipairs({ 0.22, 0.78 }) do
            local horn = Instance.new("Frame")
            horn.AnchorPoint = Vector2.new(0.5, 1)
            horn.Position = UDim2.new(sx, 0, 0.08, 0)
            horn.Size = UDim2.new(0.20, 0, 0.36, 0)
            horn.Rotation = (sx < 0.5) and -24 or 24
            horn.BackgroundColor3 = C.TXT_GOLD
            horn.BorderSizePixel = 0
            horn.ZIndex = zBase + 2
            horn.Parent = node
            addCorner(horn, 3)
        end

        -- Doi mat Boss phat sang matte
        for _, ex in ipairs({ 0.34, 0.66 }) do
            local eye = Instance.new("Frame")
            eye.AnchorPoint = Vector2.new(0.5, 0.5)
            eye.Position = UDim2.new(ex, 0, 0.44, 0)
            eye.Size = UDim2.new(0.18, 0, 0.14, 0)
            eye.BackgroundColor3 = C.TXT_GOLD
            eye.BorderSizePixel = 0
            eye.ZIndex = zBase + 2
            eye.Parent = node
            addCorner(eye, 3)
        end
    elseif kind == "slime" then
        -- Slime tron mem co 2 mat sang
        for _, ex in ipairs({ 0.34, 0.66 }) do
            local eye = Instance.new("Frame")
            eye.AnchorPoint = Vector2.new(0.5, 0.5)
            eye.Position = UDim2.new(ex, 0, 0.48, 0)
            eye.Size = UDim2.new(0.18, 0, 0.22, 0)
            eye.BackgroundColor3 = C.TXT_DARK
            eye.BorderSizePixel = 0
            eye.ZIndex = zBase + 1
            eye.Parent = node
            addCorner(eye, 99)
        end
    elseif kind == "bat" then
        -- Doi tim co 2 canh ngang
        for _, side in ipairs({ -1, 1 }) do
            local w = Instance.new("Frame")
            w.AnchorPoint = Vector2.new(0.5, 0.5)
            w.Position = UDim2.new(0.5 + side * 0.68, 0, 0.45, 0)
            w.Size = UDim2.new(0.62, 0, 0.44, 0)
            w.Rotation = side * -15
            w.BackgroundColor3 = Color3.fromRGB(116, 68, 158)
            w.BorderSizePixel = 0
            w.ZIndex = zBase - 1
            w.Parent = node
            addCorner(w, 6)
        end
    elseif kind == "skeleton" then
        -- Bo xuong dau trang co hoc mat den
        for _, ex in ipairs({ 0.34, 0.66 }) do
            local eye = Instance.new("Frame")
            eye.AnchorPoint = Vector2.new(0.5, 0.5)
            eye.Position = UDim2.new(ex, 0, 0.45, 0)
            eye.Size = UDim2.new(0.20, 0, 0.22, 0)
            eye.BackgroundColor3 = C.TXT_DARK
            eye.BorderSizePixel = 0
            eye.ZIndex = zBase + 1
            eye.Parent = node
            addCorner(eye, 99)
        end
    elseif kind == "mushroom" then
        -- Nam doc co mu do cham trang
        local cap = Instance.new("Frame")
        cap.AnchorPoint = Vector2.new(0.5, 0.5)
        cap.Position = UDim2.new(0.5, 0, 0.26, 0)
        cap.Size = UDim2.new(1.25, 0, 0.62, 0)
        cap.BackgroundColor3 = Color3.fromRGB(178, 56, 56)
        cap.BorderSizePixel = 0
        cap.ZIndex = zBase + 1
        cap.Parent = node
        addCorner(cap, 99)
        addStroke(cap, C.TXT_DARK, 1)
    elseif kind == "ghost" then
        for _, ex in ipairs({ 0.36, 0.64 }) do
            local eye = Instance.new("Frame")
            eye.AnchorPoint = Vector2.new(0.5, 0.5)
            eye.Position = UDim2.new(ex, 0, 0.42, 0)
            eye.Size = UDim2.new(0.18, 0, 0.24, 0)
            eye.BackgroundColor3 = C.TXT_GEM
            eye.BorderSizePixel = 0
            eye.ZIndex = zBase + 1
            eye.Parent = node
            addCorner(eye, 99)
        end
    else
        -- Goblin / Nhen: mat do
        for _, ex in ipairs({ 0.34, 0.66 }) do
            local eye = Instance.new("Frame")
            eye.AnchorPoint = Vector2.new(0.5, 0.5)
            eye.Position = UDim2.new(ex, 0, 0.44, 0)
            eye.Size = UDim2.new(0.18, 0, 0.16, 0)
            eye.BackgroundColor3 = C.TXT_RED
            eye.BorderSizePixel = 0
            eye.ZIndex = zBase + 1
            eye.Parent = node
            addCorner(eye, 2)
        end
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
-- 5. TRANG THAI TRAN DAU (COMBAT STATE)
-- ============================================================================
local S = {
    inMatch = false,
    paused = false,
    pickingBuff = false,
    gameOver = false,
    stage = CFG.STAGES[1],
    diff = CFG.DIFFS[1],
    hero = CFG.HEROES[1],
    wave = 1,
    totalWaves = 3,
    score = 0,
    kills = 0,
    coinsEarned = 0,
    gemsEarned = 0,
    expEarned = 0,
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
    bossSpawned = false,

    -- Nguoi choi
    px = CFG.ARENA_W * 0.5,
    py = CFG.ARENA_H * 0.5,
    dirX = 1,
    dirY = 0,
    hp = 160,
    maxHp = 160,
    mp = 100,
    maxMp = 100,
    mpRegen = 8,
    shield = 0,
    atk = 28,
    def = 10,
    spd = 250,
    crit = 0.14,
    lifesteal = 0,
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
    s1Cd = 0,
    s2Cd = 0,
    buffAtkTime = 0,

    -- Input
    keys = { W = false, A = false, S = false, D = false },
    joyActive = false,
    joyId = nil,
    joyX = 0,
    joyY = 0,
    holdAttack = false,
    autoBattle = false,
    dustT = 0,

    -- Thuc the dong
    enemies = {},
    projs = {},
    pickups = {},
    effects = {},
    sparks = {},
    hazards = {},
    floatTexts = {},
    braziers = {},
    miniDots = {},
}

-- ============================================================================
-- 6. GIAO DIEN FULL MAN HINH 100% + TOPBAR RPG + NUT MO LAI KHI THU GON
-- ============================================================================
local ScreenGui = mountScreenGui()
UI.ScreenGui = ScreenGui

-- Nut noi chi hien khi thu gon game
do
    local reopenBtn = makeBtn(ScreenGui, {
        text = "MỞ GAME",
        bg = C.BTN_PURPLE,
        color = C.TXT_GOLD,
        size = 13,
        dim = UDim2.new(0, 106, 0, 36),
        pos = UDim2.new(1, -118, 0, 52),
        radius = 10,
        strokeColor = C.BORDER_GOLD,
        strokeWidth = 1.5,
        z = 80,
    })
    reopenBtn.Visible = false
    UI.ReopenBtn = reopenBtn

    local dragging, dragStart, startPos, moved = false, nil, nil, false
    trackConn(reopenBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, dragStart, startPos = true, false, inp.Position, reopenBtn.Position
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            if d.Magnitude > 8 then
                moved = true
                reopenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved then
                UI.MainFrame.Visible = true
                reopenBtn.Visible = false
            end
        end
    end))
end

-- Khung FULL MAN HINH 100%
local refreshAllUI
do
    local main = Instance.new("Frame")
    main.Name = "FullScreenRoot"
    main.Position = UDim2.new(0, 0, 0, 0)
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = C.BG_FULL
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.ZIndex = 1
    main.Parent = ScreenGui
    addGrad(main, C.BG_TOPBAR, C.BG_FULL, 135)
    UI.MainFrame = main

    -- ---- TOPBAR RPG (CAO 58PX TREN CUNG FULL MAN HINH) ----
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.Size = UDim2.new(1, 0, 0, 58)
    topBar.BackgroundColor3 = C.BG_TOPBAR
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 10
    topBar.Parent = main
    addGrad(topBar, C.BG_PANEL_HI, C.BG_TOPBAR, 90)

    local tbBorder = Instance.new("Frame")
    tbBorder.Position = UDim2.new(0, 0, 1, -2)
    tbBorder.Size = UDim2.new(1, 0, 0, 2)
    tbBorder.BackgroundColor3 = C.BORDER_ACT
    tbBorder.BorderSizePixel = 0
    tbBorder.ZIndex = 11
    tbBorder.Parent = topBar

    -- Khung Avatar + Lv + HP/MP/Luc Chien (goc trai tren)
    local avaBox = Instance.new("Frame")
    avaBox.Position = UDim2.new(0, 12, 0.5, -23)
    avaBox.Size = UDim2.new(0, 46, 0, 46)
    avaBox.BackgroundColor3 = C.BG_ARENA
    avaBox.ClipsDescendants = true
    avaBox.ZIndex = 11
    avaBox.Parent = topBar
    addCorner(avaBox, 23)
    addStroke(avaBox, C.BORDER_GOLD, 2)

    UI.TopAvatarHolder = Instance.new("Frame")
    UI.TopAvatarHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.TopAvatarHolder.Position = UDim2.new(0.5, 0, 0.52, 0)
    UI.TopAvatarHolder.Size = UDim2.new(0, 28, 0, 28)
    UI.TopAvatarHolder.BackgroundTransparency = 1
    UI.TopAvatarHolder.ZIndex = 12
    UI.TopAvatarHolder.Parent = avaBox

    local lvTag = Instance.new("Frame")
    lvTag.AnchorPoint = Vector2.new(0.5, 1)
    lvTag.Position = UDim2.new(0.5, 0, 1, 3)
    lvTag.Size = UDim2.new(0, 40, 0, 14)
    lvTag.BackgroundColor3 = C.BTN_PURPLE
    lvTag.ZIndex = 14
    lvTag.Parent = avaBox
    addCorner(lvTag, 6)
    addStroke(lvTag, C.BORDER_GOLD, 1)

    UI.TopLvLbl = makeLabel(lvTag, {
        text = "Lv.1", font = FONT_TITLE, color = C.TXT_GOLD, size = 10,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 1, 0), z = 15,
    })

    -- Thanh HP & MP & Luc Chien canh Avatar
    local hpWrap = Instance.new("Frame")
    hpWrap.Position = UDim2.new(0, 66, 0, 6)
    hpWrap.Size = UDim2.new(0, 152, 0, 14)
    hpWrap.BackgroundColor3 = C.BG_FULL
    hpWrap.ZIndex = 11
    hpWrap.Parent = topBar
    addCorner(hpWrap, 5)
    addStroke(hpWrap, C.BORDER, 1)

    UI.TopHpFill = Instance.new("Frame")
    UI.TopHpFill.Size = UDim2.new(1, 0, 1, 0)
    UI.TopHpFill.BackgroundColor3 = C.HP_BAR
    UI.TopHpFill.BorderSizePixel = 0
    UI.TopHpFill.ZIndex = 12
    UI.TopHpFill.Parent = hpWrap
    addCorner(UI.TopHpFill, 5)

    UI.TopHpLbl = makeLabel(hpWrap, {
        text = "HP 160/160", font = FONT_TITLE, color = C.TXT_MAIN, size = 10,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 1, 0), z = 13,
    })

    local mpWrap = Instance.new("Frame")
    mpWrap.Position = UDim2.new(0, 66, 0, 23)
    mpWrap.Size = UDim2.new(0, 152, 0, 12)
    mpWrap.BackgroundColor3 = C.BG_FULL
    mpWrap.ZIndex = 11
    mpWrap.Parent = topBar
    addCorner(mpWrap, 5)
    addStroke(mpWrap, C.BORDER, 1)

    UI.TopMpFill = Instance.new("Frame")
    UI.TopMpFill.Size = UDim2.new(1, 0, 1, 0)
    UI.TopMpFill.BackgroundColor3 = C.MP_BAR
    UI.TopMpFill.BorderSizePixel = 0
    UI.TopMpFill.ZIndex = 12
    UI.TopMpFill.Parent = mpWrap
    addCorner(UI.TopMpFill, 5)

    UI.TopMpLbl = makeLabel(mpWrap, {
        text = "MP 100/100", font = FONT_TITLE, color = C.TXT_MAIN, size = 9,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 1, 0), z = 13,
    })

    UI.TopPowerLbl = makeLabel(topBar, {
        text = "Lực Chiến: 0", font = FONT_TITLE, color = C.TXT_GOLD, size = 11,
        dim = UDim2.new(0, 165, 0, 14), pos = UDim2.new(0, 66, 0, 36), z = 12,
    })

    local expWrap = Instance.new("Frame")
    expWrap.Position = UDim2.new(0, 66, 0, 51)
    expWrap.Size = UDim2.new(0, 152, 0, 4)
    expWrap.BackgroundColor3 = C.BG_FULL
    expWrap.BorderSizePixel = 0
    expWrap.ZIndex = 12
    expWrap.Parent = topBar
    addCorner(expWrap, 2)

    UI.TopExpFill = Instance.new("Frame")
    UI.TopExpFill.Size = UDim2.new(0, 0, 1, 0)
    UI.TopExpFill.BackgroundColor3 = C.EXP_BAR
    UI.TopExpFill.BorderSizePixel = 0
    UI.TopExpFill.ZIndex = 13
    UI.TopExpFill.Parent = expWrap
    addCorner(UI.TopExpFill, 2)

    -- Vien thuoc Xu & KC o giua TopBar
    local coinPill = Instance.new("Frame")
    coinPill.Position = UDim2.new(0, 232, 0.5, -14)
    coinPill.Size = UDim2.new(0, 114, 0, 28)
    coinPill.BackgroundColor3 = C.BG_FULL
    coinPill.ZIndex = 11
    coinPill.Parent = topBar
    addCorner(coinPill, 14)
    addStroke(coinPill, C.BORDER_GOLD, 1.2)

    local coinDot = Instance.new("Frame")
    coinDot.Position = UDim2.new(0, 6, 0.5, -8)
    coinDot.Size = UDim2.new(0, 16, 0, 16)
    coinDot.BackgroundColor3 = C.BTN_GOLD
    coinDot.ZIndex = 12
    coinDot.Parent = coinPill
    addCorner(coinDot, 8)
    addStroke(coinDot, C.TXT_GOLD, 1.2)

    UI.TopCoinLbl = makeLabel(coinPill, {
        text = "300 Xu", font = FONT_TITLE, color = C.TXT_GOLD, size = 12,
        dim = UDim2.new(1, -28, 1, 0), pos = UDim2.new(0, 26, 0, 0), z = 12,
    })

    local gemPill = Instance.new("Frame")
    gemPill.Position = UDim2.new(0, 354, 0.5, -14)
    gemPill.Size = UDim2.new(0, 104, 0, 28)
    gemPill.BackgroundColor3 = C.BG_FULL
    gemPill.ZIndex = 11
    gemPill.Parent = topBar
    addCorner(gemPill, 14)
    addStroke(gemPill, C.BORDER_ACT, 1.2)

    local gemDot = Instance.new("Frame")
    gemDot.Position = UDim2.new(0, 8, 0.5, -7)
    gemDot.Size = UDim2.new(0, 13, 0, 13)
    gemDot.Rotation = 45
    gemDot.BackgroundColor3 = C.BTN_PURPLE
    gemDot.ZIndex = 12
    gemDot.Parent = gemPill
    addCorner(gemDot, 2)
    addStroke(gemDot, C.TXT_GEM, 1.2)

    UI.TopGemLbl = makeLabel(gemPill, {
        text = "20 KC", font = FONT_TITLE, color = C.TXT_GEM, size = 12,
        dim = UDim2.new(1, -28, 1, 0), pos = UDim2.new(0, 26, 0, 0), z = 12,
    })

    -- Nut chuc nang goc phai TopBar: Thu Gon & Dong
    local minBtn = makeBtn(topBar, {
        text = "-", bg = C.BTN_DARK, color = C.TXT_MAIN, size = 18,
        dim = UDim2.new(0, 36, 0, 32), pos = UDim2.new(1, -84, 0.5, -16), radius = 8, z = 12,
    })
    bindTap(minBtn, function()
        main.Visible = false
        UI.ReopenBtn.Visible = true
        if S.inMatch and not S.gameOver then
            S.paused = true
            UI.PauseOverlay.Visible = true
        end
    end)

    local closeBtn = makeBtn(topBar, {
        text = "X", bg = C.BTN_RED, color = C.TXT_MAIN, size = 14,
        dim = UDim2.new(0, 36, 0, 32), pos = UDim2.new(1, -42, 0.5, -16), radius = 8, z = 12,
    })
    bindTap(closeBtn, function()
        if _G.ArenaChienDau_Cleanup then _G.ArenaChienDau_Cleanup() end
    end)

    -- Toast thong bao noi
    local toast = Instance.new("Frame")
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0, 64)
    toast.Size = UDim2.new(0, 360, 0, 34)
    toast.BackgroundColor3 = C.BG_CARD_ALT
    toast.Visible = false
    toast.ZIndex = 70
    toast.Parent = main
    addCorner(toast, 10)
    addStroke(toast, C.BORDER_GOLD, 1.5)

    UI.Toast = toast
    UI.ToastLbl = makeLabel(toast, {
        text = "", font = FONT_TITLE, color = C.TXT_GOLD, size = 13,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, -16, 1, 0), pos = UDim2.new(0, 8, 0, 0), z = 71,
    })
    UI.ToastToken = 0
end

local function showToast(msg, col)
    UI.ToastToken = UI.ToastToken + 1
    local tk = UI.ToastToken
    UI.ToastLbl.Text = msg
    UI.ToastLbl.TextColor3 = col or C.TXT_GOLD
    UI.Toast.Visible = true
    task.delay(2.2, function()
        if UI.ToastToken == tk and UI.Toast then UI.Toast.Visible = false end
    end)
end

-- ============================================================================
-- 7. SANH CHO FULL MAN HINH (5 TAB: VAO TRAN | TUONG 8 | NANG CAP | NHIEM VU | CAI DAT)
-- ============================================================================
do
    local lobby = Instance.new("Frame")
    lobby.Name = "LobbyView"
    lobby.Position = UDim2.new(0, 0, 0, 58)
    lobby.Size = UDim2.new(1, 0, 1, -58)
    lobby.BackgroundTransparency = 1
    lobby.ZIndex = 2
    lobby.Parent = UI.MainFrame
    UI.LobbyView = lobby

    -- Thanh dieu huong ben trai (Sidebar RPG)
    local sideBar = Instance.new("Frame")
    sideBar.Position = UDim2.new(0, 10, 0, 10)
    sideBar.Size = UDim2.new(0, 146, 1, -20)
    sideBar.BackgroundColor3 = C.BG_PANEL
    sideBar.ZIndex = 3
    sideBar.Parent = lobby
    addCorner(sideBar, 12)
    addStroke(sideBar, C.BORDER, 1.2)

    local sList = Instance.new("UIListLayout")
    sList.Padding = UDim.new(0, 8)
    sList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sList.Parent = sideBar

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 10)
    sPad.PaddingLeft = UDim.new(0, 8)
    sPad.PaddingRight = UDim.new(0, 8)
    sPad.Parent = sideBar

    local contentArea = Instance.new("Frame")
    contentArea.Position = UDim2.new(0, 166, 0, 10)
    contentArea.Size = UDim2.new(1, -176, 1, -20)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 3
    contentArea.Parent = lobby

    local tabs = {
        { id = "play",     label = "VÀO TRẬN" },
        { id = "gear",     label = "TRANG BỊ" },
        { id = "heroes",   label = "TƯỚNG (8)" },
        { id = "upgrade",  label = "NÂNG CẤP" },
        { id = "quests",   label = "NHIỆM VỤ" },
        { id = "settings", label = "CÀI ĐẶT & CODE" },
    }
    UI.SideBtns = {}
    UI.LobbyPages = {}

    local function switchTab(tid)
        for id, b in pairs(UI.SideBtns) do
            local act = (id == tid)
            b.BackgroundColor3 = act and C.BTN_PURPLE or C.BG_CARD
            b.TextColor3 = act and C.TXT_MAIN or C.TXT_SUB
        end
        for id, pg in pairs(UI.LobbyPages) do pg.Visible = (id == tid) end
    end

    for _, t in ipairs(tabs) do
        local b = makeBtn(sideBar, {
            text = t.label, bg = C.BG_CARD, color = C.TXT_SUB, size = 13,
            dim = UDim2.new(1, 0, 0, 42), radius = 9, z = 4,
        })
        UI.SideBtns[t.id] = b
        if t.id == "quests" then
            local dot = Instance.new("Frame")
            dot.AnchorPoint = Vector2.new(1, 0.5)
            dot.Position = UDim2.new(1, -8, 0.5, 0)
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.BackgroundColor3 = C.TXT_RED
            dot.Visible = false
            dot.ZIndex = 5
            dot.Parent = b
            addCorner(dot, 5)
            UI.QuestBadge = dot
        end

        local pg = Instance.new("Frame")
        pg.Size = UDim2.new(1, 0, 1, 0)
        pg.BackgroundTransparency = 1
        pg.Visible = false
        pg.ZIndex = 3
        pg.Parent = contentArea
        UI.LobbyPages[t.id] = pg

        bindTap(b, function() switchTab(t.id) end)
    end

    -- ---- PAGE 1: VAO TRAN (CHON MAN + DO KHO + TUONG + BAT DAU) ----
    do
        local pg = UI.LobbyPages.play

        -- Cot trai: Danh sach 5 Man choi
        local leftCol = Instance.new("Frame")
        leftCol.Size = UDim2.new(0.56, -6, 1, 0)
        leftCol.BackgroundColor3 = C.BG_PANEL
        leftCol.ZIndex = 4
        leftCol.Parent = pg
        addCorner(leftCol, 12)
        addStroke(leftCol, C.BORDER, 1.2)

        makeLabel(leftCol, {
            text = "CHỌN BẢN ĐỒ CHIẾN ĐẤU", font = FONT_TITLE, color = C.TXT_GOLD, size = 13,
            dim = UDim2.new(1, -24, 0, 24), pos = UDim2.new(0, 14, 0, 10), z = 5,
        })

        local stScroll = Instance.new("ScrollingFrame")
        stScroll.Position = UDim2.new(0, 10, 0, 38)
        stScroll.Size = UDim2.new(1, -20, 1, -48)
        stScroll.BackgroundTransparency = 1
        stScroll.BorderSizePixel = 0
        stScroll.ScrollBarThickness = 4
        stScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        stScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        stScroll.ZIndex = 5
        stScroll.Parent = leftCol

        local stList = Instance.new("UIListLayout")
        stList.Padding = UDim.new(0, 8)
        stList.Parent = stScroll

        UI.StageCards = {}
        for _, st in ipairs(CFG.STAGES) do
            local card = makeBtn(stScroll, {
                text = "", bg = C.BG_CARD, dim = UDim2.new(1, -6, 0, 62), radius = 10, z = 5,
            })
            makeLabel(card, {
                text = st.name, font = FONT_TITLE, color = C.TXT_MAIN, size = 14,
                dim = UDim2.new(1, -20, 0, 22), pos = UDim2.new(0, 12, 0, 8), z = 6,
            })
            makeLabel(card, {
                text = string.format("Boss: %s  |  Thưởng: +%d Xu, +%d KC, +%d EXP", st.bossName, st.rewardCoin, st.rewardGem, st.rewardExp),
                font = FONT_BODY, color = C.TXT_SUB, size = 11,
                dim = UDim2.new(1, -20, 0, 20), pos = UDim2.new(0, 12, 0, 34), z = 6,
            })
            UI.StageCards[st.id] = { card = card, stroke = card:FindFirstChildOfClass("UIStroke") }
            bindTap(card, function()
                DATA.selectedStage = st.id
                SAVE.Write()
                refreshAllUI()
            end)
        end

        -- Cot phai: Do Kho + Xem truoc Tuong + Nut BAT DAU
        local rightCol = Instance.new("Frame")
        rightCol.Position = UDim2.new(0.56, 6, 0, 0)
        rightCol.Size = UDim2.new(0.44, -6, 1, 0)
        rightCol.BackgroundColor3 = C.BG_PANEL
        rightCol.ZIndex = 4
        rightCol.Parent = pg
        addCorner(rightCol, 12)
        addStroke(rightCol, C.BORDER, 1.2)

        makeLabel(rightCol, {
            text = "CHỌN ĐỘ KHÓ", font = FONT_TITLE, color = C.TXT_GOLD, size = 13,
            dim = UDim2.new(1, -24, 0, 22), pos = UDim2.new(0, 14, 0, 10), z = 5,
        })

        local diffRow = Instance.new("Frame")
        diffRow.Position = UDim2.new(0, 12, 0, 36)
        diffRow.Size = UDim2.new(1, -24, 0, 36)
        diffRow.BackgroundTransparency = 1
        diffRow.ZIndex = 5
        diffRow.Parent = rightCol
        local dl = Instance.new("UIListLayout")
        dl.FillDirection = Enum.FillDirection.Horizontal
        dl.Padding = UDim.new(0, 6)
        dl.Parent = diffRow

        UI.DiffBtns = {}
        for _, df in ipairs(CFG.DIFFS) do
            local db = makeBtn(diffRow, {
                text = df.name, bg = C.BG_CARD, color = df.color, size = 12,
                dim = UDim2.new(0.333, -4, 1, 0), radius = 8, z = 6,
            })
            UI.DiffBtns[df.id] = { btn = db, stroke = db:FindFirstChildOfClass("UIStroke") }
            bindTap(db, function()
                DATA.selectedDiff = df.id
                SAVE.Write()
                refreshAllUI()
            end)
        end

        -- Khung xem truoc Tuong & Ky nang
        local heroBox = Instance.new("Frame")
        heroBox.Position = UDim2.new(0, 12, 0, 82)
        heroBox.Size = UDim2.new(1, -24, 1, -158)
        heroBox.BackgroundColor3 = C.BG_CARD
        heroBox.ZIndex = 5
        heroBox.Parent = rightCol
        addCorner(heroBox, 10)
        addStroke(heroBox, C.BORDER, 1)

        local pBg = Instance.new("Frame")
        pBg.AnchorPoint = Vector2.new(0.5, 0)
        pBg.Position = UDim2.new(0.5, 0, 0, 12)
        pBg.Size = UDim2.new(0, 68, 0, 68)
        pBg.BackgroundColor3 = C.BG_ARENA
        pBg.ZIndex = 6
        pBg.Parent = heroBox
        addCorner(pBg, 34)
        addStroke(pBg, C.BORDER_GOLD, 1.5)

        UI.LobbyHeroPreview = Instance.new("Frame")
        UI.LobbyHeroPreview.AnchorPoint = Vector2.new(0.5, 0.5)
        UI.LobbyHeroPreview.Position = UDim2.new(0.5, 0, 0.52, 0)
        UI.LobbyHeroPreview.Size = UDim2.new(0, 56, 0, 64)
        UI.LobbyHeroPreview.BackgroundTransparency = 1
        UI.LobbyHeroPreview.ZIndex = 7
        UI.LobbyHeroPreview.Parent = pBg

        UI.LobbyHeroInfo = makeLabel(heroBox, {
            text = "", font = FONT_BODY, color = C.TXT_MAIN, size = 12, wrap = true,
            xAlign = Enum.TextXAlignment.Center, yAlign = Enum.TextYAlignment.Top,
            dim = UDim2.new(1, -18, 1, -90), pos = UDim2.new(0, 9, 0, 86), z = 6,
        })

        local startBtn = makeBtn(rightCol, {
            text = "BẮT ĐẦU CHIẾN ĐẤU", bg = C.BTN_GOLD, color = C.TXT_DARK, size = 16,
            dim = UDim2.new(1, -24, 0, 52), pos = UDim2.new(0, 12, 1, -64), radius = 10,
            strokeColor = C.TXT_GOLD, strokeWidth = 2, z = 6,
        })
        addGrad(startBtn, Color3.fromRGB(208, 168, 76), Color3.fromRGB(168, 118, 38), 90)
        bindTap(startBtn, function() GAME.StartMatch() end)
    end


    -- ---- PAGE GEAR: NHAN VAT (6 O TRANG BI) + TUI DO (LOC / TRANG BI / NANG CAP / GO / BAN / MO RUONG) ----
    do
        local pg = UI.LobbyPages.gear
        UI.SelectedGearUid = nil
        UI.GearFilter = "all"

        -- Cot trai: Khung Nhan Vat + 6 O Trang Bi + Chi So HP/ATK/DEF/SPD
        local left = Instance.new("Frame")
        left.Size = UDim2.new(0.42, -6, 1, 0)
        left.BackgroundColor3 = C.BG_PANEL
        left.ZIndex = 4
        left.Parent = pg
        addCorner(left, 12)
        addStroke(left, C.BORDER_ACT, 1.5)

        makeLabel(left, {
            text = "NHÂN VẬT & TRANG BỊ", font = FONT_TITLE, color = C.TXT_GOLD, size = 13,
            dim = UDim2.new(1, -24, 0, 22), pos = UDim2.new(0, 12, 0, 8), z = 5,
        })

        -- Vong phap tran & Chibi o giua
        local stageRing = Instance.new("Frame")
        stageRing.AnchorPoint = Vector2.new(0.5, 0.5)
        stageRing.Position = UDim2.new(0.5, 0, 0.44, 0)
        stageRing.Size = UDim2.new(0, 96, 0, 96)
        stageRing.BackgroundColor3 = C.BG_ARENA
        stageRing.ZIndex = 5
        stageRing.Parent = left
        addCorner(stageRing, 48)
        addStroke(stageRing, C.BORDER_ACT, 2)

        UI.GearHeroPreview = Instance.new("Frame")
        UI.GearHeroPreview.AnchorPoint = Vector2.new(0.5, 0.5)
        UI.GearHeroPreview.Position = UDim2.new(0.5, 0, 0.5, 0)
        UI.GearHeroPreview.Size = UDim2.new(0, 76, 0, 86)
        UI.GearHeroPreview.BackgroundTransparency = 1
        UI.GearHeroPreview.ZIndex = 6
        UI.GearHeroPreview.Parent = stageRing

        -- 6 O trang bi (3 ben trai, 3 ben phai giong anh tham khao)
        UI.GearSlotBtns = {}
        local slotCoords = {
            { id = "weapon", x = 0.04, y = 0.14 },
            { id = "helm",   x = 0.04, y = 0.36 },
            { id = "boots",  x = 0.04, y = 0.58 },
            { id = "armor",  x = 0.72, y = 0.14 },
            { id = "neck",   x = 0.72, y = 0.36 },
            { id = "wings",  x = 0.72, y = 0.58 },
        }
        for _, sc in ipairs(slotCoords) do
            local sb = makeBtn(left, {
                text = "", bg = C.BG_CARD, color = C.TXT_SUB, size = 9,
                dim = UDim2.new(0.24, 0, 0.19, 0), pos = UDim2.new(sc.x, 0, sc.y, 0), radius = 8, z = 6,
            })
            local icHolder = Instance.new("Frame")
            icHolder.AnchorPoint = Vector2.new(0.5, 0)
            icHolder.Position = UDim2.new(0.5, 0, 0, 4)
            icHolder.Size = UDim2.new(0, 30, 0, 30)
            icHolder.BackgroundTransparency = 1
            icHolder.ZIndex = 7
            icHolder.Parent = sb

            local slLbl = makeLabel(sb, {
                text = "", font = FONT_TITLE, color = C.TXT_SUB, size = 9, wrap = true,
                xAlign = Enum.TextXAlignment.Center, yAlign = Enum.TextYAlignment.Bottom,
                dim = UDim2.new(1, -4, 0, 22), pos = UDim2.new(0, 2, 1, -23), z = 8,
            })
            UI.GearSlotBtns[sc.id] = { btn = sb, icon = icHolder, lbl = slLbl, stroke = sb:FindFirstChildOfClass("UIStroke") }
            bindTap(sb, function()
                local eqUid = DATA.equipped[sc.id]
                if eqUid then
                    UI.SelectedGearUid = eqUid
                    refreshAllUI()
                else
                    showToast("Ô này chưa trang bị vật phẩm!", C.TXT_SUB)
                end
            end)
        end

        -- Hop chi so HP / ATK / DEF / SPD duoi cung cot trai
        local statBox = Instance.new("Frame")
        statBox.Position = UDim2.new(0, 10, 1, -68)
        statBox.Size = UDim2.new(1, -20, 0, 58)
        statBox.BackgroundColor3 = C.BG_CARD
        statBox.ZIndex = 5
        statBox.Parent = left
        addCorner(statBox, 9)
        addStroke(statBox, C.BORDER, 1)

        UI.GearStatsLbl = makeLabel(statBox, {
            text = "", font = FONT_TITLE, color = C.TXT_MAIN, size = 12, wrap = true,
            xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, -12, 1, -8), pos = UDim2.new(0, 6, 0, 4), z = 6,
        })

        -- Cot phai: Bo loc + Luoi Tui Do + Thong tin vat pham + 4 nut Hanh Dong + Mo Ruong
        local right = Instance.new("Frame")
        right.Position = UDim2.new(0.42, 6, 0, 0)
        right.Size = UDim2.new(0.58, -6, 1, 0)
        right.BackgroundColor3 = C.BG_PANEL
        right.ZIndex = 4
        right.Parent = pg
        addCorner(right, 12)
        addStroke(right, C.BORDER, 1.2)

        -- Thanh loc danh muc
        local fBar = Instance.new("Frame")
        fBar.Position = UDim2.new(0, 10, 0, 8)
        fBar.Size = UDim2.new(1, -20, 0, 30)
        fBar.BackgroundTransparency = 1
        fBar.ZIndex = 5
        fBar.Parent = right
        local fl = Instance.new("UIListLayout")
        fl.FillDirection = Enum.FillDirection.Horizontal
        fl.Padding = UDim.new(0, 5)
        fl.Parent = fBar

        local filters = {
            { id = "all",    label = "Tất cả" },
            { id = "weapon", label = "Vũ Khí" },
            { id = "armor",  label = "Áo Giáp" },
            { id = "acc",    label = "Phụ Kiện" },
            { id = "wings",  label = "Cánh" },
        }
        UI.GearFilterBtns = {}
        for _, f in ipairs(filters) do
            local fb = makeBtn(fBar, {
                text = f.label, bg = C.BG_CARD, color = C.TXT_SUB, size = 11,
                dim = UDim2.new(0.195, -2, 1, 0), radius = 7, z = 6,
            })
            UI.GearFilterBtns[f.id] = fb
            bindTap(fb, function()
                UI.GearFilter = f.id
                refreshAllUI()
            end)
        end

        -- Luoi vat pham trong tui
        local bagScroll = Instance.new("ScrollingFrame")
        bagScroll.Position = UDim2.new(0, 10, 0, 44)
        bagScroll.Size = UDim2.new(1, -20, 1, -148)
        bagScroll.BackgroundColor3 = C.BG_FULL
        bagScroll.BorderSizePixel = 0
        bagScroll.ScrollBarThickness = 4
        bagScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        bagScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        bagScroll.ZIndex = 5
        bagScroll.Parent = right
        addCorner(bagScroll, 8)
        addStroke(bagScroll, C.BORDER, 1)
        UI.BagScroll = bagScroll

        local bPad = Instance.new("UIPadding")
        bPad.PaddingTop = UDim.new(0, 6); bPad.PaddingLeft = UDim.new(0, 6)
        bPad.PaddingRight = UDim.new(0, 6); bPad.PaddingBottom = UDim.new(0, 6)
        bPad.Parent = bagScroll

        local bGrid = Instance.new("UIGridLayout")
        bGrid.CellSize = UDim2.new(0.32, -4, 0, 74)
        bGrid.CellPadding = UDim2.new(0, 6, 0, 6)
        bGrid.Parent = bagScroll

        -- Hop chi tiet vat pham dang chon
        UI.GearDetailLbl = makeLabel(right, {
            text = "Chọn 1 trang bị trong túi để xem chi tiết.",
            font = FONT_BODY, color = C.TXT_SUB, size = 11, wrap = true,
            dim = UDim2.new(1, -20, 0, 34), pos = UDim2.new(0, 10, 1, -98), z = 5,
        })

        -- Thanh 5 nut hanh dong: Trang Bi | Nang Cap | Go | Ban | Mo Ruong (150 Xu)
        local actRow = Instance.new("Frame")
        actRow.Position = UDim2.new(0, 10, 1, -56)
        actRow.Size = UDim2.new(1, -20, 0, 44)
        actRow.BackgroundTransparency = 1
        actRow.ZIndex = 5
        actRow.Parent = right
        local al = Instance.new("UIListLayout")
        al.FillDirection = Enum.FillDirection.Horizontal
        al.Padding = UDim.new(0, 6)
        al.Parent = actRow

        local eqBtn = makeBtn(actRow, { text = "Trang Bị", bg = C.BTN_BLUE, color = C.TXT_MAIN, size = 10, dim = UDim2.new(0.16, -3, 1, 0), radius = 8, z = 6 })
        local upBtn = makeBtn(actRow, { text = "Nâng Cấp", bg = C.BTN_GREEN, color = C.TXT_MAIN, size = 10, dim = UDim2.new(0.16, -3, 1, 0), radius = 8, z = 6 })
        local unBtn = makeBtn(actRow, { text = "Gỡ",       bg = C.BTN_RED, color = C.TXT_MAIN, size = 10, dim = UDim2.new(0.10, -3, 1, 0), radius = 8, z = 6 })
        local slBtn = makeBtn(actRow, { text = "Bán",      bg = C.BTN_GOLD, color = C.TXT_DARK, size = 10, dim = UDim2.new(0.11, -3, 1, 0), radius = 8, z = 6 })
        local qsBtn = makeBtn(actRow, { text = "Bán Nhanh", bg = C.BTN_DARK, color = C.TXT_GOLD, size = 10, dim = UDim2.new(0.20, -3, 1, 0), radius = 8, strokeColor = C.BORDER_GOLD, z = 6 })
        local chBtn = makeBtn(actRow, { text = "Rương 150Xu", bg = C.BTN_PURPLE, color = C.TXT_GOLD, size = 10, dim = UDim2.new(0.26, -3, 1, 0), radius = 8, z = 6 })

        bindTap(qsBtn, function()
            local sold, totalXu = 0, 0
            for i = #DATA.inventory, 1, -1 do
                local it = DATA.inventory[i]
                local d = GEAR.GetDef(it.id)
                if not GEAR.IsEquipped(it.uid) and (d.rarity == "common" or d.rarity == "rare") then
                    local r = CFG.RARITIES[d.rarity] or CFG.RARITIES.common
                    totalXu = totalXu + r.sell + (it.lv or 0) * 30
                    sold = sold + 1
                    if UI.SelectedGearUid == it.uid then UI.SelectedGearUid = nil end
                    table.remove(DATA.inventory, i)
                end
            end
            if sold > 0 then
                DATA.coins = DATA.coins + totalXu
                SAVE.Write(); refreshAllUI()
                showToast("Bán nhanh " .. sold .. " món nhận +" .. totalXu .. " Xu", C.TXT_GOLD)
            else
                showToast("Không có đồ Thường/Hiếm chưa mặc để bán!", C.TXT_SUB)
            end
        end)

        bindTap(eqBtn, function()
            local it = GEAR.FindByUid(UI.SelectedGearUid)
            if not it then showToast("Hãy chọn 1 món đồ trước!", C.TXT_RED); return end
            local d = GEAR.GetDef(it.id)
            DATA.equipped[d.slot] = it.uid
            SAVE.Write(); refreshAllUI()
            showToast("Đã trang bị: " .. d.name, C.TXT_GREEN)
        end)

        bindTap(upBtn, function()
            local it = GEAR.FindByUid(UI.SelectedGearUid)
            if not it then showToast("Hãy chọn 1 món đồ trước!", C.TXT_RED); return end
            if (it.lv or 0) >= 10 then showToast("Trang bị đã đạt cấp +10 tối đa!", C.TXT_GOLD); return end
            local cost = 80 + (it.lv or 0) * 65
            if DATA.coins < cost then showToast("Cần " .. cost .. " Xu để nâng cấp!", C.TXT_RED); return end
            DATA.coins = DATA.coins - cost
            it.lv = (it.lv or 0) + 1
            DATA.totalUpgrades = (DATA.totalUpgrades or 0) + 1
            SAVE.Write(); refreshAllUI()
            showToast("Nâng cấp thành công lên +" .. tostring(it.lv), C.TXT_GREEN)
        end)

        bindTap(unBtn, function()
            local it = GEAR.FindByUid(UI.SelectedGearUid)
            if not it then return end
            local d = GEAR.GetDef(it.id)
            if DATA.equipped[d.slot] == it.uid then
                DATA.equipped[d.slot] = nil
                SAVE.Write(); refreshAllUI()
                showToast("Đã gỡ: " .. d.name, C.TXT_SUB)
            else
                showToast("Món đồ này chưa được trang bị!", C.TXT_SUB)
            end
        end)

        bindTap(slBtn, function()
            local it, idx = GEAR.FindByUid(UI.SelectedGearUid)
            if not it then showToast("Hãy chọn món đồ để bán!", C.TXT_RED); return end
            if GEAR.IsEquipped(it.uid) then showToast("Hãy gỡ món đồ ra trước khi bán!", C.TXT_RED); return end
            local d = GEAR.GetDef(it.id)
            local r = CFG.RARITIES[d.rarity] or CFG.RARITIES.common
            local val = r.sell + (it.lv or 0) * 30
            table.remove(DATA.inventory, idx)
            DATA.coins = DATA.coins + val
            UI.SelectedGearUid = nil
            SAVE.Write(); refreshAllUI()
            showToast("Đã bán " .. d.name .. " nhận +" .. tostring(val) .. " Xu", C.TXT_GOLD)
        end)

        bindTap(chBtn, function()
            if #DATA.inventory >= 60 then showToast("Túi đồ đầy (tối đa 60 món)!", C.TXT_RED); return end
            if DATA.coins < 150 then showToast("Cần 150 Xu để mở Rương Trang Bị!", C.TXT_RED); return end
            DATA.coins = DATA.coins - 150
            local roll = RNG:NextNumber()
            local minR = (roll < 0.07) and "mythic" or ((roll < 0.22) and "legend" or ((roll < 0.50) and "epic" or "rare"))
            local it, d = GEAR.AddRandom(minR)
            UI.SelectedGearUid = it.uid
            SAVE.Write(); refreshAllUI()
            local r = CFG.RARITIES[d.rarity] or CFG.RARITIES.common
            showToast("Mở rương nhận: " .. d.name .. " [" .. r.name .. "]", r.color)
        end)
    end

    -- ---- PAGE 2: 8 TUONG (HERO ROSTER) ----
    do
        local pg = UI.LobbyPages.heroes
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 5
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.ZIndex = 4
        scroll.Parent = pg

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0.49, -4, 0, 148)
        grid.CellPadding = UDim2.new(0, 10, 0, 10)
        grid.Parent = scroll

        UI.HeroCards = {}
        for _, h in ipairs(CFG.HEROES) do
            local card = Instance.new("Frame")
            card.BackgroundColor3 = C.BG_PANEL
            card.ZIndex = 4
            card.Parent = scroll
            addCorner(card, 10)
            local st = addStroke(card, C.BORDER, 1.2)

            local ava = Instance.new("Frame")
            ava.Position = UDim2.new(0, 10, 0, 10)
            ava.Size = UDim2.new(0, 48, 0, 48)
            ava.BackgroundColor3 = C.BG_ARENA
            ava.ClipsDescendants = true
            ava.ZIndex = 5
            ava.Parent = card
            addCorner(ava, 24)
            addStroke(ava, h.fx, 1.5)

            local sp = Instance.new("Frame")
            sp.AnchorPoint = Vector2.new(0.5, 0.5)
            sp.Position = UDim2.new(0.5, 0, 0.52, 0)
            sp.Size = UDim2.new(0, 28, 0, 28)
            sp.BackgroundTransparency = 1
            sp.ZIndex = 6
            sp.Parent = ava
            buildChibiHero(sp, h, 6, true)

            makeLabel(card, {
                text = h.name .. " - " .. h.role, font = FONT_TITLE, color = C.TXT_MAIN, size = 13,
                dim = UDim2.new(1, -72, 0, 20), pos = UDim2.new(0, 66, 0, 10), z = 5,
            })
            makeLabel(card, {
                text = string.format("HP %d | MP %d | ATK %d | CRIT %d%%", h.hp, h.mp, h.atk, math.floor(h.crit * 100)),
                font = FONT_BODY, color = C.TXT_CYAN, size = 11,
                dim = UDim2.new(1, -72, 0, 18), pos = UDim2.new(0, 66, 0, 32), z = 5,
            })
            makeLabel(card, {
                text = h.desc, font = FONT_BODY, color = C.TXT_SUB, size = 11, wrap = true,
                dim = UDim2.new(1, -24, 0, 34), pos = UDim2.new(0, 12, 0, 64), z = 5,
            })

            local btn = makeBtn(card, {
                text = "CHỌN", bg = C.BTN_BLUE, color = C.TXT_MAIN, size = 12,
                dim = UDim2.new(1, -24, 0, 34), pos = UDim2.new(0, 12, 1, -44), radius = 8, z = 5,
            })
            UI.HeroCards[h.id] = { stroke = st, btn = btn }

            bindTap(btn, function()
                if DATA.unlockedHeroes[h.id] then
                    DATA.selectedHero = h.id
                    SAVE.Write()
                    refreshAllUI()
                    showToast("Đã trang bị: " .. h.name, C.TXT_GREEN)
                elseif DATA.coins >= h.costCoin and DATA.gems >= h.costGem then
                    DATA.coins = DATA.coins - h.costCoin
                    DATA.gems = DATA.gems - h.costGem
                    DATA.unlockedHeroes[h.id] = true
                    DATA.selectedHero = h.id
                    SAVE.Write()
                    refreshAllUI()
                    showToast("Mở khóa thành công: " .. h.name, C.TXT_GOLD)
                else
                    showToast("Chưa đủ Xu hoặc KC!", C.TXT_RED)
                end
            end)
        end
    end

    -- ---- PAGE 3: NANG CAP VINH VIEN ----
    do
        local pg = UI.LobbyPages.upgrade
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.ZIndex = 4
        scroll.Parent = pg

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 8)
        list.Parent = scroll

        UI.UpgradeRows = {}
        for _, upg in ipairs(CFG.UPGRADES) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -6, 0, 62)
            row.BackgroundColor3 = C.BG_PANEL
            row.ZIndex = 4
            row.Parent = scroll
            addCorner(row, 10)
            addStroke(row, C.BORDER, 1.2)

            local tLbl = makeLabel(row, {
                text = "", font = FONT_TITLE, color = C.TXT_MAIN, size = 14,
                dim = UDim2.new(0.6, 0, 0, 22), pos = UDim2.new(0, 14, 0, 10), z = 5,
            })
            makeLabel(row, {
                text = upg.stat .. " mỗi cấp", font = FONT_BODY, color = C.TXT_SUB, size = 12,
                dim = UDim2.new(0.6, 0, 0, 18), pos = UDim2.new(0, 14, 0, 34), z = 5,
            })

            local b = makeBtn(row, {
                text = "NÂNG", bg = C.BTN_PURPLE, color = C.TXT_MAIN, size = 12,
                dim = UDim2.new(0, 150, 0, 36), pos = UDim2.new(1, -164, 0.5, -18), radius = 8, z = 5,
            })
            UI.UpgradeRows[upg.id] = { title = tLbl, btn = b }

            bindTap(b, function()
                local lv = DATA.upgrades[upg.id] or 0
                if lv >= upg.maxLv then
                    showToast(upg.name .. " đã đạt cấp tối đa!", C.TXT_GOLD)
                    return
                end
                local cost = upg.baseCost + lv * upg.step
                if DATA.coins >= cost then
                    DATA.coins = DATA.coins - cost
                    DATA.upgrades[upg.id] = lv + 1
                    DATA.totalUpgrades = (DATA.totalUpgrades or 0) + 1
                    SAVE.Write()
                    refreshAllUI()
                    showToast("Đã nâng " .. upg.name .. " lên Lv." .. tostring(lv + 1), C.TXT_GREEN)
                else
                    showToast("Cần " .. tostring(cost) .. " Xu!", C.TXT_RED)
                end
            end)
        end
    end

    -- ---- PAGE 4: NHIEM VU & NHAN TAT CA ----
    do
        local pg = UI.LobbyPages.quests
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, -56)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.ZIndex = 4
        scroll.Parent = pg

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 8)
        list.Parent = scroll

        UI.QuestRows = {}
        for _, q in ipairs(CFG.QUESTS) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -6, 0, 68)
            row.BackgroundColor3 = C.BG_PANEL
            row.ZIndex = 4
            row.Parent = scroll
            addCorner(row, 10)
            addStroke(row, C.BORDER, 1.2)

            makeLabel(row, {
                text = q.title, font = FONT_TITLE, color = C.TXT_MAIN, size = 14,
                dim = UDim2.new(0.65, 0, 0, 22), pos = UDim2.new(0, 14, 0, 8), z = 5,
            })

            local pBg = Instance.new("Frame")
            pBg.Position = UDim2.new(0, 14, 0, 36)
            pBg.Size = UDim2.new(0.55, 0, 0, 14)
            pBg.BackgroundColor3 = C.BG_FULL
            pBg.ZIndex = 5
            pBg.Parent = row
            addCorner(pBg, 5)

            local pFill = Instance.new("Frame")
            pFill.Size = UDim2.new(0, 0, 1, 0)
            pFill.BackgroundColor3 = C.EXP_BAR
            pFill.BorderSizePixel = 0
            pFill.ZIndex = 6
            pFill.Parent = pBg
            addCorner(pFill, 5)

            local pLbl = makeLabel(pBg, {
                text = "0/0", font = FONT_TITLE, color = C.TXT_MAIN, size = 10,
                xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 1, 0), z = 7,
            })

            local cBtn = makeBtn(row, {
                text = string.format("+%d Xu, +%d KC", q.rewardCoin, q.rewardGem),
                bg = C.BTN_DARK, color = C.TXT_MAIN, size = 11,
                dim = UDim2.new(0, 152, 0, 36), pos = UDim2.new(1, -166, 0.5, -18), radius = 8, z = 5,
            })

            UI.QuestRows[q.id] = { fill = pFill, lbl = pLbl, btn = cBtn }
            bindTap(cBtn, function()
                if DATA.claimedQuests[q.id] then return end
                local cur = DATA[q.statKey] or 0
                if cur >= q.target then
                    DATA.claimedQuests[q.id] = true
                    DATA.coins = DATA.coins + q.rewardCoin
                    DATA.gems = DATA.gems + q.rewardGem
                    SAVE.Write()
                    refreshAllUI()
                    showToast("Nhận thưởng: +" .. q.rewardCoin .. " Xu, +" .. q.rewardGem .. " KC", C.TXT_GREEN)
                else
                    showToast("Chưa hoàn thành nhiệm vụ này!", C.TXT_SUB)
                end
            end)
        end

        local claimAllBtn = makeBtn(pg, {
            text = "NHẬN TẤT CẢ NHIỆM VỤ HOÀN THÀNH", bg = C.BTN_PURPLE, color = C.TXT_MAIN, size = 14,
            dim = UDim2.new(1, 0, 0, 44), pos = UDim2.new(0, 0, 1, -46), radius = 10, z = 5,
        })
        bindTap(claimAllBtn, function()
            local count, tc, tg = 0, 0, 0
            for _, q in ipairs(CFG.QUESTS) do
                if not DATA.claimedQuests[q.id] and (DATA[q.statKey] or 0) >= q.target then
                    DATA.claimedQuests[q.id] = true
                    DATA.coins = DATA.coins + q.rewardCoin
                    DATA.gems = DATA.gems + q.rewardGem
                    count = count + 1
                    tc = tc + q.rewardCoin
                    tg = tg + q.rewardGem
                end
            end
            if count > 0 then
                SAVE.Write()
                refreshAllUI()
                showToast(string.format("Đã nhận %d nhiệm vụ (+%d Xu, +%d KC)", count, tc, tg), C.TXT_GREEN)
            else
                showToast("Chưa có nhiệm vụ nào sẵn sàng nhận!", C.TXT_SUB)
            end
        end)
    end

    -- ---- PAGE 5: CAI DAT & MA QUA ----
    do
        local pg = UI.LobbyPages.settings

        local setCard = Instance.new("Frame")
        setCard.Size = UDim2.new(1, 0, 0, 206)
        setCard.BackgroundColor3 = C.BG_PANEL
        setCard.ZIndex = 4
        setCard.Parent = pg
        addCorner(setCard, 10)
        addStroke(setCard, C.BORDER, 1.2)

        makeLabel(setCard, {
            text = "CÀI ĐẶT HIỂN THỊ & ĐIỀU KHIỂN", font = FONT_TITLE, color = C.TXT_GOLD, size = 13,
            dim = UDim2.new(1, -24, 0, 22), pos = UDim2.new(0, 14, 0, 10), z = 5,
        })

        local setDefs = {
            { key = "shake",     label = "Rung màn hình khi đánh" },
            { key = "particles", label = "Hiệu ứng tia lửa & tàn ảnh" },
            { key = "minimap",   label = "Hiện Radar Minimap góc trái" },
            { key = "autoAim",   label = "Tự động khóa mục tiêu gần" },
        }
        UI.SettingBtns = {}
        for idx, sd in ipairs(setDefs) do
            local colIdx = (idx - 1) % 2
            local rowIdx = math.floor((idx - 1) / 2)
            local b = makeBtn(setCard, {
                text = sd.label .. ": BẬT", bg = C.BG_CARD, color = C.TXT_MAIN, size = 12,
                dim = UDim2.new(0.48, -6, 0, 42),
                pos = UDim2.new(colIdx * 0.50 + 0.02, 0, 0, 42 + rowIdx * 54),
                radius = 8, z = 5,
            })
            UI.SettingBtns[sd.key] = { btn = b, label = sd.label }
            bindTap(b, function()
                DATA.settings[sd.key] = not DATA.settings[sd.key]
                SAVE.Write()
                refreshAllUI()
            end)
        end

        -- Nut Xoa Het Du Lieu (Reset) co hop thoai xac nhan an toan
        local resetBtn = makeBtn(setCard, {
            text = "RESET DỮ LIỆU (XÓA HẾT DỮ LIỆU)", bg = C.BTN_RED, color = C.TXT_MAIN, size = 12,
            dim = UDim2.new(0.96, 0, 0, 36), pos = UDim2.new(0.02, 0, 0, 156), radius = 8,
            strokeColor = C.TXT_RED, strokeWidth = 1.4, z = 5,
        })

        local resetOv = Instance.new("Frame")
        resetOv.Size = UDim2.new(1, 0, 1, 0)
        resetOv.BackgroundColor3 = C.SHADOW
        resetOv.BackgroundTransparency = 0.25
        resetOv.Visible = false
        resetOv.ZIndex = 65
        resetOv.Parent = UI.MainFrame

        local rCard = Instance.new("Frame")
        rCard.AnchorPoint = Vector2.new(0.5, 0.5)
        rCard.Position = UDim2.new(0.5, 0, 0.5, 0)
        rCard.Size = UDim2.new(0, 340, 0, 176)
        rCard.BackgroundColor3 = C.BG_PANEL
        rCard.ZIndex = 66
        rCard.Parent = resetOv
        addCorner(rCard, 12)
        addStroke(rCard, C.TXT_RED, 2)

        makeLabel(rCard, {
            text = "XÁC NHẬN XÓA TOÀN BỘ DỮ LIỆU?", font = FONT_TITLE, color = C.TXT_RED, size = 15,
            xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, -20, 0, 28), pos = UDim2.new(0, 10, 0, 14), z = 67,
        })
        makeLabel(rCard, {
            text = "Toàn bộ Xu, KC, Cấp độ, Tướng, Trang Bị, Nhiệm Vụ và Mã Quà sẽ bị xóa sạch và đặt lại từ đầu!",
            font = FONT_BODY, color = C.TXT_MAIN, size = 12, wrap = true,
            xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, -28, 0, 56), pos = UDim2.new(0, 14, 0, 46), z = 67,
        })

        local cancelR = makeBtn(rCard, {
            text = "HỦY BỎ", bg = C.BTN_DARK, color = C.TXT_MAIN, size = 13,
            dim = UDim2.new(0.44, 0, 0, 38), pos = UDim2.new(0.05, 0, 1, -52), radius = 8, z = 67,
        })
        local confirmR = makeBtn(rCard, {
            text = "XÁC NHẬN XÓA", bg = C.BTN_RED, color = C.TXT_MAIN, size = 13,
            dim = UDim2.new(0.44, 0, 0, 38), pos = UDim2.new(0.51, 0, 1, -52), radius = 8, z = 67,
        })

        bindTap(resetBtn, function() resetOv.Visible = true end)
        bindTap(cancelR, function() resetOv.Visible = false end)
        bindTap(confirmR, function()
            resetOv.Visible = false
            UI.SelectedGearUid = nil
            SAVE.Reset()
            refreshAllUI()
            showToast("Đã xóa toàn bộ dữ liệu và đặt lại từ đầu!", C.TXT_GOLD)
        end)


        local codeCard = Instance.new("Frame")
        codeCard.Position = UDim2.new(0, 0, 0, 216)
        codeCard.Size = UDim2.new(1, 0, 0, 118)
        codeCard.BackgroundColor3 = C.BG_PANEL
        codeCard.ZIndex = 4
        codeCard.Parent = pg
        addCorner(codeCard, 10)
        addStroke(codeCard, C.BORDER, 1.2)

        makeLabel(codeCard, {
            text = "MÃ QUÀ TẶNG (Thử: CHIENDAU2026, TANTHU500, FULLSCREEN, TRANGVIP2026, RUONGVANG, TUONGMOI, SANBOSS2026)",
            font = FONT_TITLE, color = C.TXT_SUB, size = 11, wrap = true,
            dim = UDim2.new(1, -24, 0, 28), pos = UDim2.new(0, 14, 0, 8), z = 5,
        })

        local box = Instance.new("TextBox")
        box.Position = UDim2.new(0, 14, 0, 40)
        box.Size = UDim2.new(1, -158, 0, 38)
        box.BackgroundColor3 = C.BG_FULL
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

        local rBtn = makeBtn(codeCard, {
            text = "NHẬN QUÀ", bg = C.BTN_GREEN, color = C.TXT_MAIN, size = 13,
            dim = UDim2.new(0, 128, 0, 38), pos = UDim2.new(1, -142, 0, 40), radius = 8, z = 5,
        })
        bindTap(rBtn, function()
            local code = string.upper(string.gsub(box.Text or "", "%s+", ""))
            if code == "" then showToast("Hãy nhập mã quà!", C.TXT_RED); return end

            -- Xu ly Ma Admin an (mo khoa full moi thu)
            if code == CFG.ADMIN_CODE then
                DATA.level = 100
                DATA.exp = 0
                DATA.coins = math.max(DATA.coins, 999999)
                DATA.gems = math.max(DATA.gems, 99999)
                for _, h in ipairs(CFG.HEROES) do
                    DATA.unlockedHeroes[h.id] = true
                end
                for _, upg in ipairs(CFG.UPGRADES) do
                    DATA.upgrades[upg.id] = upg.maxLv
                end
                -- Mo khoa full toan bo 27 trang bi (+10) va tu trang bi bo manh nhat
                local ownedById = {}
                for _, it in ipairs(DATA.inventory) do
                    ownedById[it.id] = it
                    it.lv = 10
                end
                for _, g in ipairs(CFG.GEAR_POOL) do
                    if not ownedById[g.id] then
                        DATA.nextUid = (DATA.nextUid or 10) + 1
                        local ni = { uid = DATA.nextUid, id = g.id, lv = 10 }
                        table.insert(DATA.inventory, ni)
                        ownedById[g.id] = ni
                    end
                end
                local bestSet = {
                    weapon = "w_void",
                    armor  = "a_void",
                    helm   = "h_crown",
                    boots  = "b_void",
                    neck   = "n_void",
                    wings  = "c_shadow",
                }
                for slot, gid in pairs(bestSet) do
                    if ownedById[gid] then
                        DATA.equipped[slot] = ownedById[gid].uid
                    end
                end
                box.Text = ""
                SAVE.Write()
                refreshAllUI()
                showToast("ADMIN FULL ALL: Lv.100, Full Tướng, Full Trang Bị +10!", C.TXT_GOLD)
                return
            end

            local rw = CFG.CODES[code]
            if not rw then showToast("Mã quà không hợp lệ!", C.TXT_RED); return end
            if DATA.usedCodes[code] then showToast("Mã này đã được dùng!", C.TXT_RED); return end
            DATA.usedCodes[code] = true
            DATA.coins = DATA.coins + (rw.coins or 0)
            DATA.gems = DATA.gems + (rw.gems or 0)
            if rw.gear and #DATA.inventory < 60 then
                GEAR.AddRandom(rw.gear)
            end
            box.Text = ""
            SAVE.Write()
            refreshAllUI()
            showToast("Thành công: " .. rw.msg, C.TXT_GREEN)
        end)

        makeLabel(codeCard, {
            text = "Phím PC: WASD/Mũi tên di chuyển | J/Space Đánh | K/Shift Lướt | L/Q Chiêu 1 | I/R Chiêu 2 | U/E Tuyệt Chiêu",
            font = FONT_BODY, color = C.TXT_SUB, size = 11, wrap = true,
            dim = UDim2.new(1, -24, 0, 24), pos = UDim2.new(0, 14, 1, -28), z = 5,
        })
    end

    switchTab("play")
end

refreshAllUI = function()
    local st = computeStats()
    buildChibiHero(UI.TopAvatarHolder, st.hero, 12, true)
    UI.TopLvLbl.Text = "Lv." .. tostring(DATA.level)
    UI.TopHpLbl.Text = string.format("HP %d/%d", S.inMatch and math.floor(S.hp) or st.maxHp, S.inMatch and S.maxHp or st.maxHp)
    UI.TopMpLbl.Text = string.format("MP %d/%d", S.inMatch and math.floor(S.mp) or st.maxMp, S.inMatch and S.maxMp or st.maxMp)
    UI.TopPowerLbl.Text = "Lực Chiến: " .. tostring(st.power)
    if UI.TopExpFill then UI.TopExpFill.Size = UDim2.new(math.clamp((DATA.exp or 0) / math.max(1, getExpNeeded(DATA.level)), 0, 1), 0, 1, 0) end
    UI.TopCoinLbl.Text = tostring(DATA.coins) .. " Xu"
    UI.TopGemLbl.Text = tostring(DATA.gems) .. " KC"

    for id, pack in pairs(UI.StageCards) do
        local sel = (DATA.selectedStage == id)
        pack.card.BackgroundColor3 = sel and C.BG_CARD_ALT or C.BG_CARD
        pack.stroke.Color = sel and C.BORDER_GOLD or C.BORDER
        pack.stroke.Thickness = sel and 2 or 1
    end

    for id, pack in pairs(UI.DiffBtns) do
        local sel = (DATA.selectedDiff == id)
        pack.btn.BackgroundColor3 = sel and C.BG_CARD_ALT or C.BG_CARD
        pack.stroke.Color = sel and C.BORDER_ACT or C.BORDER
        pack.stroke.Thickness = sel and 2 or 1
    end

    buildChibiHero(UI.LobbyHeroPreview, st.hero, 7)
    UI.LobbyHeroInfo.Text = string.format(
        "%s (%s)\nHP %d  |  MP %d  |  ATK %d  |  CRIT %d%%\nChiêu 1: %s  |  Chiêu 2: %s\nTuyệt chiêu: %s",
        st.hero.name, st.hero.role, st.maxHp, st.maxMp, st.atk, math.floor(st.crit * 100),
        st.hero.s1Name, st.hero.s2Name, st.hero.ultName
    )

    for _, h in ipairs(CFG.HEROES) do
        local pack = UI.HeroCards[h.id]
        local unlocked = DATA.unlockedHeroes[h.id] == true
        local eq = (DATA.selectedHero == h.id)
        if eq then
            pack.btn.Text = "ĐANG TRANG BỊ"
            pack.btn.BackgroundColor3 = C.BTN_GREEN
            pack.stroke.Color = C.TXT_GREEN
            pack.stroke.Thickness = 2
        elseif unlocked then
            pack.btn.Text = "CHỌN TƯỚNG"
            pack.btn.BackgroundColor3 = C.BTN_BLUE
            pack.stroke.Color = C.BORDER
            pack.stroke.Thickness = 1.2
        else
            local ct = tostring(h.costCoin) .. " Xu"
            if h.costGem > 0 then ct = ct .. " + " .. tostring(h.costGem) .. " KC" end
            pack.btn.Text = "MỞ KHÓA (" .. ct .. ")"
            pack.btn.BackgroundColor3 = C.BTN_GOLD
            pack.stroke.Color = C.BORDER
            pack.stroke.Thickness = 1.2
        end
    end

    for _, upg in ipairs(CFG.UPGRADES) do
        local pack = UI.UpgradeRows[upg.id]
        local lv = DATA.upgrades[upg.id] or 0
        pack.title.Text = string.format("%s (Lv.%d/%d)", upg.name, lv, upg.maxLv)
        if lv >= upg.maxLv then
            pack.btn.Text = "TỐI ĐA"
            pack.btn.BackgroundColor3 = C.BTN_DARK
        else
            pack.btn.Text = "NÂNG (" .. tostring(upg.baseCost + lv * upg.step) .. " Xu)"
            pack.btn.BackgroundColor3 = C.BTN_PURPLE
        end
    end

    local anyClaimable = false
    for _, q in ipairs(CFG.QUESTS) do
        local pack = UI.QuestRows[q.id]
        local cur = math.min(q.target, DATA[q.statKey] or 0)
        pack.fill.Size = UDim2.new(cur / q.target, 0, 1, 0)
        pack.lbl.Text = string.format("%d / %d", cur, q.target)
        if DATA.claimedQuests[q.id] then
            pack.btn.Text = "ĐÃ NHẬN"
            pack.btn.BackgroundColor3 = C.BTN_DARK
        elseif cur >= q.target then
            anyClaimable = true
            pack.btn.Text = "NHẬN THƯỞNG"
            pack.btn.BackgroundColor3 = C.BTN_GREEN
        else
            pack.btn.Text = string.format("+%d Xu, +%d KC", q.rewardCoin, q.rewardGem)
            pack.btn.BackgroundColor3 = C.BG_CARD
        end
    end
    UI.QuestBadge.Visible = anyClaimable


    -- Cap nhat trang Trang Bi & Tui Do
    if UI.GearHeroPreview then
        buildChibiHero(UI.GearHeroPreview, st.hero, 6, false)
        UI.GearStatsLbl.Text = string.format(
            "HP: %d   |   ATK: %d\nDEF: %d   |   SPD: %d",
            st.maxHp, st.atk, st.def, st.spd
        )
        for _, sl in ipairs(CFG.GEAR_SLOTS) do
            local pack = UI.GearSlotBtns[sl.id]
            local eqIt = GEAR.FindByUid(DATA.equipped[sl.id])
            if eqIt then
                local d = GEAR.GetDef(eqIt.id)
                local rar = CFG.RARITIES[d.rarity] or CFG.RARITIES.common
                buildGearIcon(pack.icon, d, 7)
                pack.lbl.Text = d.name .. ((eqIt.lv or 0) > 0 and (" +" .. eqIt.lv) or "")
                pack.lbl.TextColor3 = C.TXT_MAIN
                pack.stroke.Color = rar.color
                pack.stroke.Thickness = 2
            else
                buildGearIcon(pack.icon, { slot = sl.id, col = C.STONE_LIGHT }, 7)
                pack.lbl.Text = sl.label
                pack.lbl.TextColor3 = C.TXT_SUB
                pack.stroke.Color = C.BORDER
                pack.stroke.Thickness = 1
            end
        end

        for fid, fb in pairs(UI.GearFilterBtns) do
            local act = (UI.GearFilter == fid)
            fb.BackgroundColor3 = act and C.BTN_PURPLE or C.BG_CARD
            fb.TextColor3 = act and C.TXT_MAIN or C.TXT_SUB
        end

        for _, ch in ipairs(UI.BagScroll:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end

        local slotCat = { weapon = "weapon", armor = "armor", helm = "armor", boots = "armor", neck = "acc", wings = "wings" }
        for _, it in ipairs(DATA.inventory) do
            local d = GEAR.GetDef(it.id)
            if UI.GearFilter == "all" or slotCat[d.slot] == UI.GearFilter then
                local rar = CFG.RARITIES[d.rarity] or CFG.RARITIES.common
                local isSel = (UI.SelectedGearUid == it.uid)
                local isEq = GEAR.IsEquipped(it.uid)
                local ib = makeBtn(UI.BagScroll, {
                    text = "",
                    bg = isSel and C.BG_CARD_ALT or C.BG_CARD,
                    color = C.TXT_MAIN,
                    size = 10,
                    dim = UDim2.new(0, 100, 0, 74),
                    radius = 8,
                    strokeColor = isSel and C.TXT_GOLD or rar.color,
                    strokeWidth = isSel and 2.2 or 1.5,
                    z = 6,
                })
                local icBox = Instance.new("Frame")
                icBox.AnchorPoint = Vector2.new(0.5, 0)
                icBox.Position = UDim2.new(0.5, 0, 0, 5)
                icBox.Size = UDim2.new(0, 32, 0, 32)
                icBox.BackgroundTransparency = 1
                icBox.ZIndex = 7
                icBox.Parent = ib
                buildGearIcon(icBox, d, 7)

                if (it.lv or 0) > 0 then
                    makeLabel(ib, {
                        text = "+" .. tostring(it.lv), font = FONT_TITLE, color = C.TXT_GOLD, size = 10,
                        xAlign = Enum.TextXAlignment.Right, dim = UDim2.new(0, 28, 0, 14),
                        pos = UDim2.new(1, -32, 0, 3), z = 8,
                    })
                end
                if isEq then
                    makeLabel(ib, {
                        text = "DÙNG", font = FONT_TITLE, color = C.TXT_GREEN, size = 9,
                        dim = UDim2.new(0, 36, 0, 14), pos = UDim2.new(0, 4, 0, 3), z = 8,
                    })
                end
                makeLabel(ib, {
                    text = d.name, font = FONT_TITLE, color = C.TXT_MAIN, size = 10, wrap = true,
                    xAlign = Enum.TextXAlignment.Center, yAlign = Enum.TextYAlignment.Bottom,
                    dim = UDim2.new(1, -6, 0, 28), pos = UDim2.new(0, 3, 1, -30), z = 8,
                })
                bindTap(ib, function()
                    UI.SelectedGearUid = it.uid
                    refreshAllUI()
                end)
            end
        end

        local selIt = GEAR.FindByUid(UI.SelectedGearUid)
        if selIt then
            local ist = GEAR.GetItemStats(selIt)
            local rar = CFG.RARITIES[ist.def.rarity] or CFG.RARITIES.common
            local upCost = 80 + (selIt.lv or 0) * 65
            UI.GearDetailLbl.Text = string.format(
                "%s +%d [%s] | ATK +%d, HP +%d, DEF +%d, SPD +%d  (Nâng: %d Xu)",
                ist.def.name, selIt.lv or 0, rar.name, ist.atk, ist.hp, ist.arm, ist.spd, upCost
            )
            UI.GearDetailLbl.TextColor3 = C.TXT_MAIN
        else
            UI.GearDetailLbl.Text = string.format("Túi đồ: %d/60 món. Chọn 1 món để Trang Bị, Nâng Cấp, Gỡ hoặc Bán.", #DATA.inventory)
            UI.GearDetailLbl.TextColor3 = C.TXT_SUB
        end
    end

    for key, pack in pairs(UI.SettingBtns) do
        local on = DATA.settings[key] == true
        pack.btn.Text = pack.label .. (on and ": BẬT" or ": TẮT")
        pack.btn.BackgroundColor3 = on and C.BTN_GREEN or C.BG_CARD
    end
end

-- ============================================================================
-- 8. MAN HINH CHIEN DAU FULL MAN HINH (ARENA + MINIMAP + JOYSTICK + 5 NUT)
-- ============================================================================
do
    local combat = Instance.new("Frame")
    combat.Name = "CombatView"
    combat.Position = UDim2.new(0, 0, 0, 58)
    combat.Size = UDim2.new(1, 0, 1, -58)
    combat.BackgroundColor3 = C.BG_FULL
    combat.Visible = false
    combat.ClipsDescendants = true
    combat.ZIndex = 2
    combat.Parent = UI.MainFrame
    UI.CombatView = combat

    -- San dau phu gan nhu toan man hinh
    local arena = Instance.new("Frame")
    arena.Name = "ArenaCanvas"
    arena.Position = UDim2.new(0, 6, 0, 6)
    arena.Size = UDim2.new(1, -12, 1, -12)
    arena.BackgroundColor3 = C.BG_ARENA
    arena.ClipsDescendants = true
    arena.ZIndex = 2
    arena.Parent = combat
    addCorner(arena, 12)
    addStroke(arena, C.BORDER_ACT, 2)
    addGrad(arena, C.BG_ARENA_MID, C.BG_ARENA, 135)
    UI.Arena = arena

    -- Nen gach da xen ke kieu ham nguc (sang ro, co chieu sau)
    local floorLayer = Instance.new("Frame")
    floorLayer.Name = "FloorLayer"
    floorLayer.Size = UDim2.new(1, 0, 1, 0)
    floorLayer.BackgroundTransparency = 1
    floorLayer.ZIndex = 2
    floorLayer.Parent = arena
    UI.FloorTiles = {}

    local cols, rows = 10, 6
    for r = 0, rows - 1 do
        for c = 0, cols - 1 do
            if (r + c) % 2 == 0 then
                local tile = Instance.new("Frame")
                tile.Position = UDim2.new(c / cols, 1, r / rows, 1)
                tile.Size = UDim2.new(1 / cols, -2, 1 / rows, -2)
                tile.BackgroundColor3 = C.BG_ARENA_G
                tile.BackgroundTransparency = 0.52
                tile.BorderSizePixel = 0
                tile.ZIndex = 2
                tile.Parent = floorLayer
                addCorner(tile, 4)
                table.insert(UI.FloorTiles, tile)
            end
        end
    end

    -- Bui co / tham reu trang tri o mep san dau (khong che nut)
    UI.EdgePatches = {}
    local patchPos = {
        { 0.18, 0.08, 72, 26 }, { 0.82, 0.08, 72, 26 },
        { 0.24, 0.92, 80, 26 }, { 0.62, 0.92, 74, 24 },
        { 0.04, 0.48, 30, 68 }, { 0.96, 0.44, 30, 68 },
    }
    for _, pp in ipairs(patchPos) do
        local pt = Instance.new("Frame")
        pt.AnchorPoint = Vector2.new(0.5, 0.5)
        pt.Position = UDim2.new(pp[1], 0, pp[2], 0)
        pt.Size = UDim2.new(0, pp[3], 0, pp[4])
        pt.BackgroundColor3 = C.GRASS_DARK
        pt.BackgroundTransparency = 0.25
        pt.BorderSizePixel = 0
        pt.ZIndex = 2
        pt.Parent = floorLayer
        addCorner(pt, 12)
        table.insert(UI.EdgePatches, pt)
    end

    -- Vong tron chien dau trung tam + hoa van chu thap
    local midRing = Instance.new("Frame")
    midRing.AnchorPoint = Vector2.new(0.5, 0.5)
    midRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    midRing.Size = UDim2.new(0, 226, 0, 226)
    midRing.BackgroundColor3 = C.BG_ARENA_MID
    midRing.BackgroundTransparency = 0.65
    midRing.ZIndex = 2
    midRing.Parent = arena
    addCorner(midRing, 113)
    addStroke(midRing, C.STONE_LIGHT, 2)

    local innerRing = Instance.new("Frame")
    innerRing.AnchorPoint = Vector2.new(0.5, 0.5)
    innerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerRing.Size = UDim2.new(0, 124, 0, 124)
    innerRing.BackgroundTransparency = 1
    innerRing.ZIndex = 2
    innerRing.Parent = arena
    addCorner(innerRing, 62)
    addStroke(innerRing, C.BORDER, 1.5)

    -- 4 Duoc lua dat gon quanh vong tron trung tam (hoan toan khong bi Minimap / Nut che)
    for _, cp in ipairs({ { 0.26, 0.24 }, { 0.74, 0.24 }, { 0.26, 0.76 }, { 0.74, 0.76 } }) do
        local pil = Instance.new("Frame")
        pil.AnchorPoint = Vector2.new(0.5, 0.5)
        pil.Position = UDim2.new(cp[1], 0, cp[2], 0)
        pil.Size = UDim2.new(0, 24, 0, 24)
        pil.BackgroundColor3 = C.STONE_DARK
        pil.ZIndex = 3
        pil.Parent = arena
        addCorner(pil, 12)
        addStroke(pil, C.STONE_LIGHT, 1.5)

        local glow = Instance.new("Frame")
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.Position = UDim2.new(0.5, 0, 0.5, 0)
        glow.Size = UDim2.new(0, 38, 0, 38)
        glow.BackgroundColor3 = C.TXT_ORANGE
        glow.BackgroundTransparency = 0.84
        glow.BorderSizePixel = 0
        glow.ZIndex = 2
        glow.Parent = pil
        addCorner(glow, 19)

        local emb = Instance.new("Frame")
        emb.AnchorPoint = Vector2.new(0.5, 0.5)
        emb.Position = UDim2.new(0.5, 0, 0.5, 0)
        emb.Size = UDim2.new(0, 11, 0, 11)
        emb.BackgroundColor3 = C.TXT_ORANGE
        emb.BorderSizePixel = 0
        emb.ZIndex = 4
        emb.Parent = pil
        addCorner(emb, 6)
        table.insert(S.braziers, emb)
    end

    local entityLayer = Instance.new("Frame")
    entityLayer.Size = UDim2.new(1, 0, 1, 0)
    entityLayer.BackgroundTransparency = 1
    entityLayer.ZIndex = 5
    entityLayer.Parent = arena
    UI.EntityLayer = entityLayer

    -- Nhan vat nguoi choi
    local pNode = Instance.new("Frame")
    pNode.AnchorPoint = Vector2.new(0.5, 0.5)
    pNode.Size = UDim2.new(0, 50, 0, 56)
    pNode.BackgroundTransparency = 1
    pNode.ZIndex = 10
    pNode.Parent = arena
    UI.PlayerNode = pNode

    -- Vong tron chan nguoi choi (giong anh 3)
    local pRing = Instance.new("Frame")
    pRing.AnchorPoint = Vector2.new(0.5, 0.5)
    pRing.Position = UDim2.new(0.5, 0, 0.78, 0)
    pRing.Size = UDim2.new(1.35, 0, 0.65, 0)
    pRing.BackgroundTransparency = 1
    pRing.ZIndex = 8
    pRing.Parent = pNode
    addCorner(pRing, 99)
    UI.PlayerRingStroke = addStroke(pRing, C.TXT_CYAN, 1.6)

    -- Thanh mau nho tren dau nguoi choi
    local pHpBg = Instance.new("Frame")
    pHpBg.AnchorPoint = Vector2.new(0.5, 1)
    pHpBg.Position = UDim2.new(0.5, 0, 0, -4)
    pHpBg.Size = UDim2.new(0, 38, 0, 5)
    pHpBg.BackgroundColor3 = C.BG_FULL
    pHpBg.BorderSizePixel = 0
    pHpBg.ZIndex = 14
    pHpBg.Parent = pNode
    addCorner(pHpBg, 2)

    UI.PlayerMiniHp = Instance.new("Frame")
    UI.PlayerMiniHp.Size = UDim2.new(1, 0, 1, 0)
    UI.PlayerMiniHp.BackgroundColor3 = C.TXT_GREEN
    UI.PlayerMiniHp.BorderSizePixel = 0
    UI.PlayerMiniHp.ZIndex = 15
    UI.PlayerMiniHp.Parent = pHpBg
    addCorner(UI.PlayerMiniHp, 2)

    UI.PlayerSprite = Instance.new("Frame")
    UI.PlayerSprite.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.PlayerSprite.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.PlayerSprite.Size = UDim2.new(1, 0, 1, 0)
    UI.PlayerSprite.BackgroundTransparency = 1
    UI.PlayerSprite.ZIndex = 10
    UI.PlayerSprite.Parent = pNode

    -- ---- MINIMAP RADAR (GOC TREN TRAI SAN DAU) ----
    local mini = Instance.new("Frame")
    mini.Position = UDim2.new(0, 12, 0, 12)
    mini.Size = UDim2.new(0, 96, 0, 68)
    mini.BackgroundColor3 = C.BG_FULL
    mini.BackgroundTransparency = 0.25
    mini.ZIndex = 22
    mini.Parent = arena
    addCorner(mini, 8)
    addStroke(mini, C.BORDER_ACT, 1.2)
    UI.Minimap = mini

    local miniP = Instance.new("Frame")
    miniP.AnchorPoint = Vector2.new(0.5, 0.5)
    miniP.Size = UDim2.new(0, 6, 0, 6)
    miniP.BackgroundColor3 = C.TXT_GREEN
    miniP.BorderSizePixel = 0
    miniP.ZIndex = 24
    miniP.Parent = mini
    addCorner(miniP, 3)
    UI.MiniPlayerDot = miniP

    -- ---- THANH TRANG THAI DOT & DONG HO (TREN GIUA) ----
    local wavePill = Instance.new("Frame")
    wavePill.AnchorPoint = Vector2.new(0.5, 0)
    wavePill.Position = UDim2.new(0.5, 0, 0, 10)
    wavePill.Size = UDim2.new(0, 230, 0, 30)
    wavePill.BackgroundColor3 = C.BG_TOPBAR
    wavePill.BackgroundTransparency = 0.15
    wavePill.ZIndex = 22
    wavePill.Parent = arena
    addCorner(wavePill, 15)
    addStroke(wavePill, C.BORDER_ACT, 1.2)

    UI.HudWaveLbl = makeLabel(wavePill, {
        text = "Đợt 1/3  |  00:00", font = FONT_TITLE, color = C.TXT_MAIN, size = 13,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 1, 0), z = 23,
    })

    UI.HudComboLbl = makeLabel(arena, {
        text = "", font = FONT_TITLE, color = C.TXT_GOLD, size = 15,
        xAlign = Enum.TextXAlignment.Right, dim = UDim2.new(0, 150, 0, 26),
        pos = UDim2.new(1, -296, 0, 12), z = 22,
    })

    UI.AutoBtn = makeBtn(arena, {
        text = "AUTO: TẮT", bg = C.BG_TOPBAR, color = C.TXT_SUB, size = 11,
        dim = UDim2.new(0, 82, 0, 34), pos = UDim2.new(1, -138, 0, 10), radius = 10,
        strokeColor = C.BORDER, z = 22,
    })
    bindTap(UI.AutoBtn, function()
        S.autoBattle = not S.autoBattle
        UI.AutoBtn.Text = S.autoBattle and "AUTO: BẬT" or "AUTO: TẮT"
        UI.AutoBtn.BackgroundColor3 = S.autoBattle and C.BTN_GREEN or C.BG_TOPBAR
        UI.AutoBtn.TextColor3 = S.autoBattle and C.TXT_MAIN or C.TXT_SUB
    end)

    local pauseBtn = makeBtn(arena, {
        text = "||", bg = C.BG_TOPBAR, color = C.TXT_MAIN, size = 14,
        dim = UDim2.new(0, 38, 0, 34), pos = UDim2.new(1, -50, 0, 10), radius = 10, z = 22,
    })
    bindTap(pauseBtn, function()
        if S.gameOver or S.pickingBuff then return end
        S.paused = not S.paused
        UI.PauseOverlay.Visible = S.paused
    end)

    -- Thanh mau Boss
    local bossBar = Instance.new("Frame")
    bossBar.AnchorPoint = Vector2.new(0.5, 0)
    bossBar.Position = UDim2.new(0.5, 0, 0, 46)
    bossBar.Size = UDim2.new(0, 320, 0, 24)
    bossBar.BackgroundColor3 = C.BG_PANEL
    bossBar.Visible = false
    bossBar.ZIndex = 22
    bossBar.Parent = arena
    addCorner(bossBar, 7)
    addStroke(bossBar, C.BORDER_GOLD, 1.5)

    UI.BossHpFill = Instance.new("Frame")
    UI.BossHpFill.Size = UDim2.new(1, 0, 1, 0)
    UI.BossHpFill.BackgroundColor3 = C.HP_BOSS
    UI.BossHpFill.BorderSizePixel = 0
    UI.BossHpFill.ZIndex = 23
    UI.BossHpFill.Parent = bossBar
    addCorner(UI.BossHpFill, 6)

    UI.BossHpText = makeLabel(bossBar, {
        text = "BOSS", font = FONT_TITLE, color = C.TXT_MAIN, size = 11,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 1, 0), z = 24,
    })
    UI.BossBar = bossBar

    UI.WaveBanner = makeLabel(arena, {
        text = "", font = FONT_TITLE, color = C.TXT_GOLD, size = 22,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 0, 36),
        pos = UDim2.new(0, 0, 0.24, 0), z = 24,
    })

    -- ---- JOYSTICK LON GOC TRAI DUOI ----
    local joyBase = Instance.new("Frame")
    joyBase.Position = UDim2.new(0, 22, 1, -138)
    joyBase.Size = UDim2.new(0, 118, 0, 118)
    joyBase.BackgroundColor3 = C.BG_TOPBAR
    joyBase.BackgroundTransparency = 0.35
    joyBase.ZIndex = 24
    joyBase.Parent = arena
    addCorner(joyBase, 59)
    addStroke(joyBase, C.BORDER_ACT, 1.8)

    local joyKnob = Instance.new("Frame")
    joyKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    joyKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
    joyKnob.Size = UDim2.new(0, 46, 0, 46)
    joyKnob.BackgroundColor3 = C.BTN_PURPLE
    joyKnob.BackgroundTransparency = 0.18
    joyKnob.ZIndex = 25
    joyKnob.Parent = joyBase
    addCorner(joyKnob, 23)
    addStroke(joyKnob, C.TXT_MAIN, 1.5)

    local function updateJoy(pos)
        local c = joyBase.AbsolutePosition + joyBase.AbsoluteSize * 0.5
        local dx, dy = pos.X - c.X, pos.Y - c.Y
        local maxR = 40
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > maxR then dx, dy = dx / dist * maxR, dy / dist * maxR end
        joyKnob.Position = UDim2.new(0.5, dx, 0.5, dy)
        if dist > 6 then S.joyX, S.joyY = dx / maxR, dy / maxR
        else S.joyX, S.joyY = 0, 0 end
    end

    trackConn(joyBase.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            S.joyActive, S.joyId = true, inp
            updateJoy(inp.Position)
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(inp)
        if S.joyActive and (inp == S.joyId or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            updateJoy(inp.Position)
        end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if S.joyActive and (inp == S.joyId or inp.UserInputType == Enum.UserInputType.MouseButton1) then
            S.joyActive, S.joyId, S.joyX, S.joyY = false, nil, 0, 0
            joyKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end))

    -- ---- 5 NUT CHIEN DAU VONG CUNG GOC PHAI DUOI (GIAN CACH DEU, KHONG DE NHAU) ----
    local atkBtn = makeBtn(arena, {
        text = "ĐÁNH", bg = C.BTN_PURPLE, color = C.TXT_MAIN, size = 14,
        dim = UDim2.new(0, 78, 0, 78), pos = UDim2.new(1, -94, 1, -94), radius = 39,
        strokeColor = C.TXT_GEM, strokeWidth = 2.2, z = 24,
    })
    atkBtn.BackgroundTransparency = 0.14
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

    UI.DashBtn = makeBtn(arena, {
        text = "LƯỚT", bg = C.BTN_BLUE, color = C.TXT_MAIN, size = 11,
        dim = UDim2.new(0, 54, 0, 54), pos = UDim2.new(1, -172, 1, -68), radius = 27,
        strokeColor = C.TXT_CYAN, strokeWidth = 1.5, z = 24,
    })
    UI.DashBtn.BackgroundTransparency = 0.16
    bindTap(UI.DashBtn, function() GAME.TryDash() end)

    UI.S1Btn = makeBtn(arena, {
        text = "CHIÊU 1", bg = C.BTN_GOLD, color = C.TXT_MAIN, size = 10,
        dim = UDim2.new(0, 56, 0, 56), pos = UDim2.new(1, -182, 1, -138), radius = 28,
        strokeColor = C.TXT_GOLD, strokeWidth = 1.5, z = 24,
    })
    UI.S1Btn.BackgroundTransparency = 0.16
    bindTap(UI.S1Btn, function() GAME.TrySkill1() end)

    UI.S2Btn = makeBtn(arena, {
        text = "CHIÊU 2", bg = C.BTN_RED, color = C.TXT_MAIN, size = 10,
        dim = UDim2.new(0, 56, 0, 56), pos = UDim2.new(1, -142, 1, -198), radius = 28,
        strokeColor = C.TXT_RED, strokeWidth = 1.5, z = 24,
    })
    UI.S2Btn.BackgroundTransparency = 0.16
    bindTap(UI.S2Btn, function() GAME.TrySkill2() end)

    UI.UltBtn = makeBtn(arena, {
        text = "0% NỘ", bg = C.BTN_PURPLE, color = C.TXT_GOLD, size = 10,
        dim = UDim2.new(0, 60, 0, 60), pos = UDim2.new(1, -74, 1, -196),
        radius = 30, strokeColor = C.BORDER_GOLD, strokeWidth = 1.8, z = 24,
    })
    UI.UltBtn.BackgroundTransparency = 0.14
    bindTap(UI.UltBtn, function() GAME.TryUlt() end)

    -- ---- POPUP CHON 1 TRONG 3 NANG CAP GIUA TRAN (ROGUELIKE NHU ANH 3) ----
    local buffOv = Instance.new("Frame")
    buffOv.Size = UDim2.new(1, 0, 1, 0)
    buffOv.BackgroundColor3 = C.SHADOW
    buffOv.BackgroundTransparency = 0.25
    buffOv.Visible = false
    buffOv.ZIndex = 40
    buffOv.Parent = combat
    UI.BuffOverlay = buffOv

    local bCard = Instance.new("Frame")
    bCard.AnchorPoint = Vector2.new(0.5, 0.5)
    bCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    bCard.Size = UDim2.new(0, 480, 0, 270)
    bCard.BackgroundColor3 = C.BG_PANEL
    bCard.ZIndex = 41
    bCard.Parent = buffOv
    addCorner(bCard, 14)
    addStroke(bCard, C.BORDER_ACT, 2)

    makeLabel(bCard, {
        text = "CHỌN MỘT NÂNG CẤP CHIẾN ĐẤU", font = FONT_TITLE, color = C.TXT_GOLD, size = 16,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 0, 32), pos = UDim2.new(0, 0, 0, 12), z = 42,
    })

    UI.BuffChoices = {}
    for i = 1, 3 do
        local ch = makeBtn(bCard, {
            text = "", bg = C.BG_CARD, dim = UDim2.new(1, -36, 0, 58),
            pos = UDim2.new(0, 18, 0, 52 + (i - 1) * 68), radius = 10, z = 42,
        })
        local t = makeLabel(ch, {
            text = "", font = FONT_TITLE, color = C.TXT_MAIN, size = 14,
            dim = UDim2.new(1, -24, 0, 22), pos = UDim2.new(0, 14, 0, 8), z = 43,
        })
        local d = makeLabel(ch, {
            text = "", font = FONT_BODY, color = C.TXT_SUB, size = 12,
            dim = UDim2.new(1, -24, 0, 20), pos = UDim2.new(0, 14, 0, 32), z = 43,
        })
        UI.BuffChoices[i] = { btn = ch, title = t, desc = d, buff = nil }
        bindTap(ch, function()
            local bf = UI.BuffChoices[i].buff
            if bf and S.pickingBuff then
                bf.apply(S)
                S.pickingBuff = false
                buffOv.Visible = false
                showToast("Đã nhận nâng cấp: " .. bf.name, bf.color)
            end
        end)
    end

    -- ---- OVERLAY TAM DUNG ----
    local pauseOv = Instance.new("Frame")
    pauseOv.Size = UDim2.new(1, 0, 1, 0)
    pauseOv.BackgroundColor3 = C.SHADOW
    pauseOv.BackgroundTransparency = 0.30
    pauseOv.Visible = false
    pauseOv.ZIndex = 45
    pauseOv.Parent = combat
    UI.PauseOverlay = pauseOv

    local pCard = Instance.new("Frame")
    pCard.AnchorPoint = Vector2.new(0.5, 0.5)
    pCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    pCard.Size = UDim2.new(0, 280, 0, 176)
    pCard.BackgroundColor3 = C.BG_PANEL
    pCard.ZIndex = 46
    pCard.Parent = pauseOv
    addCorner(pCard, 12)
    addStroke(pCard, C.BORDER_ACT, 1.8)

    makeLabel(pCard, {
        text = "ĐANG TẠM DỪNG", font = FONT_TITLE, color = C.TXT_GOLD, size = 17,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 0, 34), pos = UDim2.new(0, 0, 0, 14), z = 47,
    })
    local resBtn = makeBtn(pCard, {
        text = "TIẾP TỤC CHIẾN ĐẤU", bg = C.BTN_GREEN, color = C.TXT_MAIN, size = 13,
        dim = UDim2.new(1, -36, 0, 40), pos = UDim2.new(0, 18, 0, 60), radius = 8, z = 47,
    })
    bindTap(resBtn, function() S.paused = false; pauseOv.Visible = false end)

    local quitBtn = makeBtn(pCard, {
        text = "VỀ MENU CHÍNH", bg = C.BTN_RED, color = C.TXT_MAIN, size = 13,
        dim = UDim2.new(1, -36, 0, 40), pos = UDim2.new(0, 18, 0, 112), radius = 8, z = 47,
    })
    bindTap(quitBtn, function() GAME.EndMatch(false, true) end)

    -- ---- OVERLAY THANG TRAN / THUA TRAN ----
    local endOv = Instance.new("Frame")
    endOv.Size = UDim2.new(1, 0, 1, 0)
    endOv.BackgroundColor3 = C.SHADOW
    endOv.BackgroundTransparency = 0.22
    endOv.Visible = false
    endOv.ZIndex = 50
    endOv.Parent = combat
    UI.EndOverlay = endOv

    local eCard = Instance.new("Frame")
    eCard.AnchorPoint = Vector2.new(0.5, 0.5)
    eCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    eCard.Size = UDim2.new(0, 350, 0, 248)
    eCard.BackgroundColor3 = C.BG_PANEL
    eCard.ZIndex = 51
    eCard.Parent = endOv
    addCorner(eCard, 14)
    UI.EndCardStroke = addStroke(eCard, C.BORDER_GOLD, 2)

    UI.EndTitle = makeLabel(eCard, {
        text = "THẮNG TRẬN", font = FONT_TITLE, color = C.TXT_GOLD, size = 20,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 0, 34), pos = UDim2.new(0, 0, 0, 14), z = 52,
    })
    UI.EndStats = makeLabel(eCard, {
        text = "", font = FONT_BODY, color = C.TXT_MAIN, size = 13, wrap = true,
        xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, -28, 0, 114), pos = UDim2.new(0, 14, 0, 56), z = 52,
    })

    local menuBtn = makeBtn(eCard, {
        text = "VỀ MENU", bg = C.BTN_BLUE, color = C.TXT_MAIN, size = 13,
        dim = UDim2.new(0.45, 0, 0, 40), pos = UDim2.new(0.04, 0, 1, -54), radius = 8, z = 52,
    })
    bindTap(menuBtn, function() GAME.ReturnToLobby() end)

    UI.EndNextBtn = makeBtn(eCard, {
        text = "CHƠI LẠI", bg = C.BTN_GOLD, color = C.TXT_DARK, size = 13,
        dim = UDim2.new(0.45, 0, 0, 40), pos = UDim2.new(0.51, 0, 1, -54), radius = 8, z = 52,
    })
    bindTap(UI.EndNextBtn, function() GAME.StartMatch() end)
end

-- ============================================================================
-- 9. CO CHE CHIEN DAU, TRANG THAI, MINIMAP, CHON NANG CAP & AI QUAI/BOSS
-- ============================================================================
do
    local function toPos(x, y) return UDim2.new(x / CFG.ARENA_W, 0, y / CFG.ARENA_H, 0) end

    local function clearEntities()
        for _, ch in ipairs(UI.EntityLayer:GetChildren()) do ch:Destroy() end
        for _, d in ipairs(S.miniDots) do if d and d.Parent then d:Destroy() end end
        S.enemies, S.projs, S.pickups, S.effects, S.sparks, S.hazards, S.floatTexts, S.miniDots = {}, {}, {}, {}, {}, {}, {}, {}
    end

    local function addShake(pow, dur)
        if not DATA.settings.shake then return end
        S.shakePower = math.max(S.shakePower, pow)
        S.shakeTimer = math.max(S.shakeTimer, dur)
    end

    local function spawnFloat(x, y, txt, col, sz)
        local l = makeLabel(UI.EntityLayer, {
            text = txt, font = FONT_TITLE, color = col or C.TXT_MAIN, size = sz or 13,
            xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(0, 104, 0, 20),
            pos = toPos(x, y), anchor = Vector2.new(0.5, 0.5), z = 18,
        })
        table.insert(S.floatTexts, { ui = l, x = x, y = y, vy = -52, life = 0.65, maxLife = 0.65 })
    end

    local function spawnRing(x, y, rad, col, dur)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = toPos(x, y)
        f.Size = UDim2.new(0, 12, 0, 12)
        f.BackgroundColor3 = col
        f.BackgroundTransparency = 0.72
        f.ZIndex = 7
        f.Parent = UI.EntityLayer
        addCorner(f, 999)
        addStroke(f, col, 2)
        table.insert(S.effects, { ui = f, kind = "ring", maxR = rad, life = dur or 0.24, maxLife = dur or 0.24 })
    end

    -- Hieu ung vong cung chem sac ben da lop (luoi liem cong quet theo huong vung kiem)
    local function spawnSlash(cx, cy, deg, arcRadius, col, dur)
        local radCenter = math.rad(deg)
        local sweepDir = S.swingSign or 1
        local segCount = 9
        local halfSpan = math.rad(68)
        local totalDur = dur or 0.22
        local r = math.max(46, arcRadius * 0.72)

        for i = 1, segCount do
            local t = (i - 1) / (segCount - 1)
            local a = radCenter + sweepDir * (-halfSpan + t * halfSpan * 2)
            -- Do day thon nhon o 2 dau luoi liem, day nhat o giua
            local taper = math.sin(t * math.pi)
            local thick = math.max(3, math.floor(4 + taper * 12))
            local segLen = math.max(14, math.floor(14 + taper * 18))

            local sx = cx + math.cos(a) * r
            local sy = cy + math.sin(a) * r
            local tangentDeg = math.deg(a) + 90

            local seg = Instance.new("Frame")
            seg.AnchorPoint = Vector2.new(0.5, 0.5)
            seg.Position = toPos(sx, sy)
            seg.Size = UDim2.new(0, segLen, 0, thick)
            seg.Rotation = tangentDeg
            seg.BackgroundColor3 = col
            seg.BackgroundTransparency = 0.10
            seg.BorderSizePixel = 0
            seg.ZIndex = 13
            seg.Parent = UI.EntityLayer
            addCorner(seg, thick)

            -- Loi sang sac net ben trong luoi kiem
            if taper > 0.35 then
                local core = Instance.new("Frame")
                core.AnchorPoint = Vector2.new(0.5, 0.5)
                core.Position = UDim2.new(0.5, 0, 0.5, 0)
                core.Size = UDim2.new(0.78, 0, 0.42, 0)
                core.BackgroundColor3 = C.TXT_MAIN
                core.BackgroundTransparency = 0.18
                core.BorderSizePixel = 0
                core.ZIndex = 14
                core.Parent = seg
                addCorner(core, 4)
            end

            -- Do tre quet tuan tu tao cam giac chem xet gio
            local segLife = totalDur * (0.55 + t * 0.45)
            table.insert(S.effects, {
                ui = seg, kind = "crescent",
                x = sx, y = sy,
                vx = math.cos(a) * (45 + taper * 55),
                vy = math.sin(a) * (45 + taper * 55),
                life = segLife, maxLife = segLife,
            })
        end

        -- Them 4 tia kiem khi ban ra doc theo mep vong cung
        if DATA.settings.particles then
            for k = 1, 4 do
                local a = radCenter + RNG:NextNumber(-halfSpan * 0.85, halfSpan * 0.85)
                local sx = cx + math.cos(a) * (r * 0.95)
                local sy = cy + math.sin(a) * (r * 0.95)
                local sp = Instance.new("Frame")
                sp.AnchorPoint = Vector2.new(0.5, 0.5)
                sp.Position = toPos(sx, sy)
                sp.Size = UDim2.new(0, 12, 0, 3)
                sp.Rotation = math.deg(a)
                sp.BackgroundColor3 = C.TXT_MAIN
                sp.BorderSizePixel = 0
                sp.ZIndex = 14
                sp.Parent = UI.EntityLayer
                addCorner(sp, 2)
                table.insert(S.sparks, {
                    ui = sp, x = sx, y = sy,
                    vx = math.cos(a) * RNG:NextNumber(140, 240),
                    vy = math.sin(a) * RNG:NextNumber(140, 240),
                    life = 0.18, maxLife = 0.18,
                })
            end
        end
    end

    -- Vong xoay kiem khi 360 do cho Chieu 1 / Chieu 2 / Tuyet Chieu
    local function spawnWhirlSlash(cx, cy, radius, col, dur)
        for k = 1, 4 do
            spawnSlash(cx, cy, k * 90 + RNG:NextNumber(-15, 15), radius, col, dur or 0.28)
        end
    end

    local function spawnGhost(x, y, col)
        if not DATA.settings.particles then return end
        local g = Instance.new("Frame")
        g.AnchorPoint = Vector2.new(0.5, 0.5)
        g.Position = toPos(x, y)
        g.Size = UDim2.new(0, 28, 0, 28)
        g.BackgroundColor3 = col
        g.BackgroundTransparency = 0.45
        g.BorderSizePixel = 0
        g.ZIndex = 7
        g.Parent = UI.EntityLayer
        addCorner(g, 12)
        table.insert(S.effects, { ui = g, kind = "ghost", life = 0.20, maxLife = 0.20 })
    end

    local function spawnSparks(x, y, col, cnt)
        if not DATA.settings.particles then return end
        for _ = 1, (cnt or 4) do
            local a = RNG:NextNumber(0, math.pi * 2)
            local sp = RNG:NextNumber(90, 220)
            local f = Instance.new("Frame")
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Position = toPos(x, y)
            f.Size = UDim2.new(0, 6, 0, 6)
            f.Rotation = 45
            f.BackgroundColor3 = col
            f.BorderSizePixel = 0
            f.ZIndex = 14
            f.Parent = UI.EntityLayer
            table.insert(S.sparks, { ui = f, x = x, y = y, vx = math.cos(a) * sp, vy = math.sin(a) * sp, life = 0.22, maxLife = 0.22 })
        end
    end

    local function spawnPickup(x, y)
        local r = RNG:NextNumber()
        local kind, col, txt
        if r < 0.35 then kind, col, txt = "heal", C.TXT_GREEN, "+HP"
        elseif r < 0.62 then kind, col, txt = "mp", C.TXT_CYAN, "+MP"
        elseif r < 0.82 then kind, col, txt = "fury", C.TXT_GOLD, "+NỘ"
        else kind, col, txt = "atk", C.TXT_RED, "+ATK" end

        local n = Instance.new("Frame")
        n.AnchorPoint = Vector2.new(0.5, 0.5)
        n.Position = toPos(x, y)
        n.Size = UDim2.new(0, 26, 0, 26)
        n.BackgroundColor3 = C.BG_PANEL
        n.ZIndex = 6
        n.Parent = UI.EntityLayer
        addCorner(n, 13)
        addStroke(n, col, 1.5)
        makeLabel(n, { text = txt, font = FONT_TITLE, color = col, size = 9, xAlign = Enum.TextXAlignment.Center, dim = UDim2.new(1, 0, 1, 0), z = 7 })
        table.insert(S.pickups, { ui = n, x = x, y = y, kind = kind, life = 11 })
    end

    local function spawnProj(owner, x, y, vx, vy, dmg, rad, col, pierce, status)
        local n = Instance.new("Frame")
        n.AnchorPoint = Vector2.new(0.5, 0.5)
        n.Position = toPos(x, y)
        local px = math.max(10, math.floor(rad * 1.45))
        n.Size = UDim2.new(0, px, 0, px)
        n.BackgroundColor3 = col
        n.ZIndex = 10
        n.Parent = UI.EntityLayer
        addCorner(n, px)
        addStroke(n, C.TXT_MAIN, 1)
        table.insert(S.projs, {
            ui = n, owner = owner, x = x, y = y, vx = vx, vy = vy,
            dmg = dmg, r = rad, pierce = pierce or 0, status = status, hitMap = {}, life = 2.4,
        })
    end

    local function spawnHazard(x, y, rad, delay, dmg)
        local n = Instance.new("Frame")
        n.AnchorPoint = Vector2.new(0.5, 0.5)
        n.Position = toPos(x, y)
        n.Size = UDim2.new((rad * 2) / CFG.ARENA_W, 0, (rad * 2) / CFG.ARENA_H, 0)
        n.BackgroundColor3 = C.WARN_ZONE
        n.BackgroundTransparency = 0.80
        n.ZIndex = 5
        n.Parent = UI.EntityLayer
        addCorner(n, 999)
        addStroke(n, C.TXT_RED, 1.5)

        local ch = Instance.new("Frame")
        ch.AnchorPoint = Vector2.new(0.5, 0.5)
        ch.Position = UDim2.new(0.5, 0, 0.5, 0)
        ch.Size = UDim2.new(0.1, 0, 0.1, 0)
        ch.BackgroundColor3 = C.TXT_RED
        ch.BackgroundTransparency = 0.65
        ch.BorderSizePixel = 0
        ch.ZIndex = 5
        ch.Parent = n
        addCorner(ch, 999)
        table.insert(S.hazards, { ui = n, charge = ch, x = x, y = y, r = rad, dmg = dmg, timer = delay, maxTimer = delay })
    end

    local function openBuffPicker()
        S.pickingBuff = true
        local pool = {}
        for _, b in ipairs(CFG.INMATCH_BUFFS) do table.insert(pool, b) end
        for i = 1, 3 do
            local idx = RNG:NextInteger(1, #pool)
            local bf = table.remove(pool, idx)
            UI.BuffChoices[i].buff = bf
            UI.BuffChoices[i].title.Text = bf.name
            UI.BuffChoices[i].title.TextColor3 = bf.color
            UI.BuffChoices[i].desc.Text = bf.desc
        end
        UI.BuffOverlay.Visible = true
    end

    local function spawnEnemy(kind, waveNum, isBoss)
        local side = RNG:NextInteger(1, 4)
        local x, y
        if side == 1 then x, y = RNG:NextNumber(50, CFG.ARENA_W - 50), 34
        elseif side == 2 then x, y = RNG:NextNumber(50, CFG.ARENA_W - 50), CFG.ARENA_H - 34
        elseif side == 3 then x, y = 34, RNG:NextNumber(50, CFG.ARENA_H - 50)
        else x, y = CFG.ARENA_W - 34, RNG:NextNumber(50, CFG.ARENA_H - 50) end

        local stgScale = 1 + (S.stage.id - 1) * 0.35 + (waveNum - 1) * 0.16
        local hpM = stgScale * S.diff.hpMult
        local dmgM = stgScale * S.diff.dmgMult
        local hp, spd, dmg, rad, col, ranged, title = 64, 108, 12, 17, Color3.fromRGB(76, 168, 92), false, nil

        if isBoss then
            title = S.stage.bossName
            hp, spd, dmg, rad = math.floor(460 * hpM), 106, math.floor(24 * dmgM), 34
            if kind == "firedrag" then col = Color3.fromRGB(168, 52, 48)
            elseif kind == "icedrag" then col = Color3.fromRGB(56, 118, 178)
            elseif kind == "golem" then col = Color3.fromRGB(124, 92, 72)
            elseif kind == "lich" then col = Color3.fromRGB(108, 62, 152)
            else col = Color3.fromRGB(86, 48, 128) end
        elseif kind == "slime" then
            hp, spd, dmg, rad = math.floor(52 * hpM), 96, math.floor(10 * dmgM), 16
            col = Color3.fromRGB(68, 168, 92)
        elseif kind == "bat" then
            hp, spd, dmg, rad = math.floor(42 * hpM), 158, math.floor(11 * dmgM), 15
            col = Color3.fromRGB(122, 74, 166)
        elseif kind == "skeleton" then
            hp, spd, dmg, rad = math.floor(74 * hpM), 114, math.floor(14 * dmgM), 18
            col = Color3.fromRGB(178, 182, 190)
        elseif kind == "mushroom" then
            hp, spd, dmg, rad = math.floor(86 * hpM), 84, math.floor(13 * dmgM), 18
            col = Color3.fromRGB(186, 158, 134)
        elseif kind == "ghost" then
            hp, spd, dmg, rad, ranged = math.floor(58 * hpM), 98, math.floor(14 * dmgM), 16, true
            col = Color3.fromRGB(154, 164, 196)
        else
            hp, spd, dmg, rad = math.floor(68 * hpM), 132, math.floor(13 * dmgM), 17
            col = Color3.fromRGB(92, 148, 66)
        end

        local n = Instance.new("Frame")
        n.AnchorPoint = Vector2.new(0.5, 0.5)
        n.Position = toPos(x, y)
        local px = math.floor(rad * 1.55)
        n.Size = UDim2.new(0, px, 0, px)
        n.BackgroundColor3 = col
        n.ZIndex = isBoss and 10 or 8
        n.Parent = UI.EntityLayer
        addCorner(n, isBoss and 10 or px)
        addStroke(n, isBoss and C.BORDER_GOLD or C.TXT_DARK, isBoss and 2 or 1.2)
        decorateEnemySprite(n, kind, isBoss, isBoss and 10 or 8)

        local hpFill = nil
        if not isBoss then
            local hb = Instance.new("Frame")
            hb.AnchorPoint = Vector2.new(0.5, 1)
            hb.Position = UDim2.new(0.5, 0, 0, -5)
            hb.Size = UDim2.new(0, 30, 0, 4)
            hb.BackgroundColor3 = C.BG_FULL
            hb.BorderSizePixel = 0
            hb.ZIndex = 12
            hb.Parent = n
            hpFill = Instance.new("Frame")
            hpFill.Size = UDim2.new(1, 0, 1, 0)
            hpFill.BackgroundColor3 = C.HP_ENEMY
            hpFill.BorderSizePixel = 0
            hpFill.ZIndex = 13
            hpFill.Parent = hb
        end

        -- Cham tren Minimap
        local mdot = Instance.new("Frame")
        mdot.AnchorPoint = Vector2.new(0.5, 0.5)
        mdot.Size = UDim2.new(0, isBoss and 8 or 4, 0, isBoss and 8 or 4)
        mdot.BackgroundColor3 = isBoss and C.TXT_GEM or C.TXT_RED
        mdot.BorderSizePixel = 0
        mdot.ZIndex = 23
        mdot.Parent = UI.Minimap
        addCorner(mdot, 9)
        table.insert(S.miniDots, mdot)

        local e = {
            ui = n, hpFill = hpFill, mdot = mdot, kind = kind, isBoss = isBoss, title = title,
            x = x, y = y, hp = hp, maxHp = hp, spd = spd, dmg = dmg, r = rad, ranged = ranged,
            baseCol = col, flashT = 0, stunT = 0, slowT = 0, burnT = 0, burnTick = 0,
            atkCd = RNG:NextNumber(0.8, 1.5), bossSkillCd = 3.0,
        }
        table.insert(S.enemies, e)
        if isBoss then
            UI.BossBar.Visible = true
            UI.BossHpText.Text = title .. " (" .. tostring(hp) .. " HP)"
            UI.BossHpFill.Size = UDim2.new(1, 0, 1, 0)
        end
    end

    local function damagePlayer(amount)
        if S.invulnTime > 0 or S.gameOver then return end
        local reduced = math.max(1, math.floor(amount * (100 / (100 + (S.def or 0))))) 
        local rem = reduced
        if S.shield > 0 then
            local absorb = math.min(S.shield, rem)
            S.shield = S.shield - absorb
            rem = rem - absorb
        end
        if rem > 0 then S.hp = math.max(0, S.hp - rem) end
        S.invulnTime = 0.42
        S.fury = math.min(100, S.fury + 8)
        S.combo = 0
        addShake(7, 0.16)
        spawnSparks(S.px, S.py, C.TXT_RED, 5)
        spawnFloat(S.px, S.py - 24, "-" .. tostring(amount), C.TXT_RED, 14)
        if S.hp <= 0 then GAME.EndMatch(false, false) end
    end

    local function damageEnemy(e, rawDmg, kx, ky, status)
        if e.hp <= 0 then return end
        local isCrit = RNG:NextNumber() < S.crit
        local mult = (S.buffAtkTime > 0) and 1.35 or 1.0
        local dmg = math.max(1, math.floor(rawDmg * mult * (isCrit and 1.65 or 1.0)))
        e.hp = e.hp - dmg
        e.flashT = 0.10

        if S.lifesteal > 0 then
            S.hp = math.min(S.maxHp, S.hp + math.max(1, math.floor(dmg * S.lifesteal)))
        end
        if status == "burn" or status == "poison" then
            e.burnT = 3.0
        elseif status == "freeze" then
            e.slowT = 2.4
        elseif status == "stun" then
            e.stunT = math.max(e.stunT, e.isBoss and 0.25 or 0.65)
        end
        if kx and ky then
            local km = e.isBoss and 0.22 or 1.0
            e.x = math.clamp(e.x + kx * km, 28, CFG.ARENA_W - 28)
            e.y = math.clamp(e.y + ky * km, 28, CFG.ARENA_H - 28)
        end

        S.fury = math.min(100, S.fury + (e.isBoss and 4.5 or 3.5))
        spawnSparks(e.x, e.y, isCrit and C.TXT_GOLD or S.hero.fx, isCrit and 6 or 3)
        spawnFloat(
            e.x + RNG:NextNumber(-12, 12), e.y - 20,
            isCrit and ("-" .. tostring(dmg) .. "!") or ("-" .. tostring(dmg)),
            isCrit and C.TXT_GOLD or C.TXT_RED, isCrit and 15 or 12
        )

        if e.hp <= 0 then
            S.kills = S.kills + 1
            S.combo = S.combo + 1
            S.comboTimer = 3.2
            if S.combo > S.maxCombo then S.maxCombo = S.combo end
            S.score = S.score + math.floor((e.isBoss and 350 or 25) * (1 + math.min(1.5, S.combo * 0.04)))
            S.coinsEarned = S.coinsEarned + math.floor((e.isBoss and 75 or 7) * S.diff.rewardMult)
            S.expEarned = S.expEarned + (e.isBoss and 80 or 12)
            if e.isBoss then
                S.gemsEarned = S.gemsEarned + 4
                DATA.bossKills = (DATA.bossKills or 0) + 1
                UI.BossBar.Visible = false
                addShake(12, 0.30)
                spawnRing(e.x, e.y, 150, C.TXT_GOLD, 0.40)
            else
                spawnRing(e.x, e.y, 46, e.baseCol, 0.18)
            end
            if RNG:NextNumber() < (e.isBoss and 0.90 or 0.18) then spawnPickup(e.x, e.y) end
            e.ui:Destroy()
            if e.mdot then e.mdot:Destroy() end
        else
            if e.hpFill then e.hpFill.Size = UDim2.new(math.clamp(e.hp / e.maxHp, 0, 1), 0, 1, 0) end
            if e.isBoss then
                UI.BossHpFill.Size = UDim2.new(math.clamp(e.hp / e.maxHp, 0, 1), 0, 1, 0)
                UI.BossHpText.Text = e.title .. " (" .. tostring(math.max(0, e.hp)) .. " HP)"
            end
        end
    end

    local function findNearest(maxD)
        local best, bd = nil, maxD or 9999
        for _, e in ipairs(S.enemies) do
            if e.hp > 0 then
                local d = math.sqrt((e.x - S.px) ^ 2 + (e.y - S.py) ^ 2)
                if d < bd then bd, best = d, e end
            end
        end
        return best
    end

    function GAME.StartWave(w)
        S.wave = w
        S.waveBannerTimer = 2.0
        local isBossWave = (not S.stage.endless and w == S.totalWaves) or (S.stage.endless and w % 3 == 0)
        UI.WaveBanner.Text = isBossWave and ("CẢNH BÁO BOSS - " .. S.stage.bossName) or ("ĐỢT " .. tostring(w))
        S.enemiesToSpawn = isBossWave and (4 + w) or (6 + w * 2)
        if isBossWave then spawnEnemy(S.stage.boss, w, true) end
        S.spawnTimer = 0.45
    end

    function GAME.TryAttack()
        if not S.inMatch or S.paused or S.pickingBuff or S.gameOver or S.attackCd > 0 then return end
        local h = S.hero
        S.attackCd = h.cd
        S.comboStep = (S.comboStep % 3) + 1
        S.comboResetT = 1.1
        S.swingT = 0.16
        S.swingSign = -S.swingSign

        local ax, ay = S.dirX, S.dirY
        if DATA.settings.autoAim then
            local near = findNearest(h.attackType == "ranged" and 440 or 180)
            if near then
                local dx, dy = near.x - S.px, near.y - S.py
                local d = math.sqrt(dx * dx + dy * dy)
                if d > 1 then ax, ay = dx / d, dy / d; S.dirX, S.dirY = ax, ay end
            end
        end

        local dmg = math.floor(S.atk * ((S.comboStep == 3) and 1.35 or 1.0))
        local deg = math.deg(math.atan2(ay, ax))
        if h.attackType == "ranged" then
            spawnProj("player", S.px + ax * 22, S.py + ay * 22, ax * 600, ay * 600, dmg, 9, h.fx, (S.comboStep == 3) and 2 or 0, h.status)
            if h.id == "cungthu" then
                spawnSlash(S.px + ax * 26, S.py + ay * 26, deg, 44, h.fx, 0.12)
            elseif h.id == "phapsu" then
                spawnRing(S.px + ax * 24, S.py + ay * 24, 34, h.fx, 0.18)
                spawnSparks(S.px + ax * 24, S.py + ay * 24, C.TXT_CYAN, 4)
            else
                spawnRing(S.px + ax * 22, S.py + ay * 22, 24, h.fx, 0.12)
            end
        else
            local hx, hy = S.px + ax * (h.range * 0.48), S.py + ay * (h.range * 0.48)
            local hr = h.range * ((S.comboStep == 3) and 0.76 or 0.60)
            if h.id == "chienbinh" then
                -- Warrior: Wide crimson double-crescent slash
                spawnSlash(S.px, S.py, deg, math.floor(hr * 1.30), h.fx, 0.22)
                if S.comboStep == 3 then
                    spawnSlash(S.px, S.py, deg + 12, math.floor(hr * 1.55), C.TXT_GOLD, 0.26)
                end
            elseif h.id == "satthu" then
                -- Assassin: Twin rapid purple X-slashes
                spawnSlash(S.px, S.py, deg - 20, math.floor(hr * 1.15), h.fx, 0.18)
                spawnSlash(S.px, S.py, deg + 20, math.floor(hr * 1.32), C.TXT_GEM, 0.20)
            elseif h.id == "kiemsu" or h.id == "thankiem" then
                -- Swordsman: Fast cyan sword-energy slash + launches energy wave on 3rd hit
                spawnSlash(S.px, S.py, deg, math.floor(hr * 1.32), h.fx, 0.20)
                if S.comboStep == 3 then
                    spawnProj("player", hx, hy, ax * 520, ay * 520, math.floor(dmg * 0.85), 11, h.fx, 2, h.status)
                end
            elseif h.id == "dausi" then
                -- Fighter: Blazing orange fist burst & fiery kick arc on 3rd hit
                spawnRing(hx, hy, hr * 0.90, h.fx, 0.16)
                spawnSparks(hx, hy, C.TXT_GOLD, S.comboStep == 3 and 8 or 5)
                if S.comboStep == 3 then
                    spawnSlash(S.px, S.py, deg, math.floor(hr * 1.35), C.TXT_ORANGE, 0.22)
                end
            else
                spawnSlash(S.px, S.py, deg, math.floor(hr * 1.25), S.comboStep == 3 and C.TXT_GOLD or h.fx, 0.20)
            end
            spawnRing(hx, hy, hr * 0.80, h.fx, 0.14)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - hx, e.y - hy
                    if math.sqrt(dx * dx + dy * dy) <= (hr + e.r) then
                        local push = (S.comboStep == 3) and 38 or 16
                        damageEnemy(e, dmg, ax * push, ay * push, S.comboStep == 3 and h.status or nil)
                    end
                end
            end
            if S.comboStep == 3 then addShake(3.5, 0.08) end
        end
    end

    function GAME.TryDash()
        if not S.inMatch or S.paused or S.pickingBuff or S.gameOver or S.dashCd > 0 then return end
        S.dashCd = 1.5
        S.dashTime = 0.16
        S.dashGhostT = 0
        S.invulnTime = math.max(S.invulnTime, 0.26)
        S.dashVx, S.dashVy = S.dirX * 780, S.dirY * 780
        spawnRing(S.px, S.py, 38, C.TXT_CYAN, 0.18)
    end

    function GAME.TrySkill1()
        if not S.inMatch or S.paused or S.pickingBuff or S.gameOver or S.s1Cd > 0 then return end
        local h = S.hero
        if S.mp < h.s1Cost then showToast("Không đủ MP!", C.TXT_CYAN); return end
        S.mp = S.mp - h.s1Cost
        S.s1Cd = h.s1Cd
        S.swingT = 0.22
        addShake(5.5, 0.14)
        spawnFloat(S.px, S.py - 30, h.s1Name, h.fx, 13)

        if h.attackType == "ranged" then
            local ba = math.atan2(S.dirY, S.dirX)
            for i = -2, 2 do
                local a = ba + i * 0.16
                spawnProj("player", S.px, S.py, math.cos(a) * 600, math.sin(a) * 600, math.floor(S.atk * 1.55), 10, h.fx, 2, h.status)
            end
        else
            spawnRing(S.px, S.py, 155, h.fx, 0.28)
            spawnWhirlSlash(S.px, S.py, 155, h.fx, 0.28)
            for _, e in ipairs(S.enemies) do
                if e.hp > 0 then
                    local dx, dy = e.x - S.px, e.y - S.py
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d <= 155 + e.r then
                        local nx, ny = (d > 1 and dx / d or 1), (d > 1 and dy / d or 0)
                        damageEnemy(e, math.floor(S.atk * 2.1), nx * 58, ny * 58, h.status)
                    end
                end
            end
        end
    end

    function GAME.TrySkill2()
        if not S.inMatch or S.paused or S.pickingBuff or S.gameOver or S.s2Cd > 0 then return end
        local h = S.hero
        if S.mp < h.s2Cost then showToast("Không đủ MP!", C.TXT_CYAN); return end
        S.mp = S.mp - h.s2Cost
        S.s2Cd = h.s2Cd
        S.invulnTime = math.max(S.invulnTime, 0.35)
        addShake(7.5, 0.18)
        spawnFloat(S.px, S.py - 32, h.s2Name, C.TXT_GOLD, 14)
        spawnRing(S.px, S.py, 200, h.fx, 0.34)
        spawnWhirlSlash(S.px, S.py, 195, C.TXT_GOLD, 0.32)
        spawnRing(S.px, S.py, 135, C.TXT_GOLD, 0.24)
        for _, e in ipairs(S.enemies) do
            if e.hp > 0 then
                local dx, dy = e.x - S.px, e.y - S.py
                local d = math.sqrt(dx * dx + dy * dy)
                if d <= 200 + e.r then
                    local nx, ny = (d > 1 and dx / d or 1), (d > 1 and dy / d or 0)
                    damageEnemy(e, math.floor(S.atk * 2.7), nx * 65, ny * 65, h.status)
                end
            end
        end
    end

    function GAME.TryUlt()
        if not S.inMatch or S.paused or S.pickingBuff or S.gameOver then return end
        if S.fury < 100 then showToast("Chưa đủ 100% Nộ!", C.TXT_GEM); return end
        S.fury = 0
        S.invulnTime = math.max(S.invulnTime, 0.80)
        addShake(13, 0.36)
        spawnRing(S.px, S.py, 290, S.hero.fx, 0.46)
        spawnWhirlSlash(S.px, S.py, 250, S.hero.fx, 0.38)
        spawnWhirlSlash(S.px, S.py, 175, C.TXT_GOLD, 0.34)
        spawnRing(S.px, S.py, 195, C.TXT_GOLD, 0.34)
        spawnFloat(S.px, S.py - 36, S.hero.ultName, C.TXT_GOLD, 16)
        for _, e in ipairs(S.enemies) do
            if e.hp > 0 then
                local dx, dy = e.x - S.px, e.y - S.py
                local d = math.sqrt(dx * dx + dy * dy)
                if d <= 290 + e.r then
                    local nx, ny = (d > 1 and dx / d or 1), (d > 1 and dy / d or 0)
                    damageEnemy(e, math.floor(S.atk * 4.5), nx * 75, ny * 75, S.hero.status)
                end
            end
        end
        for i = 1, 12 do
            local a = (i / 12) * math.pi * 2
            spawnProj("player", S.px, S.py, math.cos(a) * 540, math.sin(a) * 540, math.floor(S.atk * 1.6), 10, C.TXT_GOLD, 2, S.hero.status)
        end
    end

    function GAME.StartMatch()
        clearEntities()
        local st = computeStats()
        S.inMatch, S.paused, S.pickingBuff, S.gameOver = true, false, false, false
        S.stage = getStageById(DATA.selectedStage)
        S.diff = getDiffById(DATA.selectedDiff)
        S.hero = st.hero
        S.totalWaves = S.stage.waves
        S.maxHp, S.hp = st.maxHp, st.maxHp
        S.maxMp, S.mp, S.mpRegen = st.maxMp, st.maxMp, st.mpRegen
        S.shield, S.lifesteal = 0, 0
        S.atk, S.def, S.spd, S.crit = st.atk, st.def, st.spd, st.crit
        S.fury = 0
        S.px, S.py = CFG.ARENA_W * 0.5, CFG.ARENA_H * 0.5
        S.dirX, S.dirY = 1, 0
        S.score, S.kills, S.coinsEarned, S.gemsEarned, S.expEarned = 0, 0, 0, 0, 0
        S.combo, S.maxCombo, S.comboTimer, S.matchTime = 0, 0, 0, 0
        S.attackCd, S.swingT, S.dashCd, S.dashTime, S.s1Cd, S.s2Cd = 0, 0, 0, 0, 0, 0
        S.invulnTime, S.buffAtkTime, S.holdAttack = 0.6, 0, false

        local _, wp = buildChibiHero(UI.PlayerSprite, st.hero, 10)
        UI.WeaponPivot = wp
        UI.PlayerRingStroke.Color = st.hero.fx
        UI.Minimap.Visible = DATA.settings.minimap == true
        local theme = S.stage.theme
        local patchCol = C.GRASS_DARK
        local tileCol = C.BG_ARENA_G
        if theme == "crypt" then patchCol = Color3.fromRGB(54, 42, 74); tileCol = Color3.fromRGB(50, 54, 72)
        elseif theme == "ice" then patchCol = Color3.fromRGB(48, 86, 114); tileCol = Color3.fromRGB(48, 68, 92)
        elseif theme == "lava" then patchCol = Color3.fromRGB(98, 44, 38); tileCol = Color3.fromRGB(64, 46, 48)
        elseif theme == "void" then patchCol = Color3.fromRGB(68, 42, 98); tileCol = Color3.fromRGB(54, 46, 82) end
        for _, pt in ipairs(UI.EdgePatches or {}) do pt.BackgroundColor3 = patchCol end
        for _, tl in ipairs(UI.FloorTiles or {}) do tl.BackgroundColor3 = tileCol end
        UI.BossBar.Visible = false
        UI.BuffOverlay.Visible = false
        UI.PauseOverlay.Visible = false
        UI.EndOverlay.Visible = false
        UI.LobbyView.Visible = false
        UI.CombatView.Visible = true

        GAME.StartWave(1)
    end

    function GAME.EndMatch(isVictory, isManualQuit)
        S.gameOver = true
        S.paused = false
        S.pickingBuff = false
        S.holdAttack = false
        UI.PauseOverlay.Visible = false
        UI.BuffOverlay.Visible = false

        local lootNote = ""
        if isVictory then
            DATA.totalWins = (DATA.totalWins or 0) + 1
            if #DATA.inventory < 60 then
                local minR = (S.diff.id == "hell") and "legend" or ((S.diff.id == "hard") and "epic" or "rare")
                local _, dropDef = GEAR.AddRandom(minR)
                lootNote = "\nNhặt trang bị: " .. dropDef.name
            end
            S.coinsEarned = S.coinsEarned + math.floor(S.stage.rewardCoin * S.diff.rewardMult)
            S.gemsEarned = S.gemsEarned + math.floor(S.stage.rewardGem * S.diff.rewardMult)
            S.expEarned = S.expEarned + math.floor(S.stage.rewardExp * S.diff.rewardMult)
        end

        DATA.coins = DATA.coins + S.coinsEarned
        DATA.gems = DATA.gems + S.gemsEarned
        DATA.totalKills = (DATA.totalKills or 0) + S.kills
        if S.score > DATA.bestScore then DATA.bestScore = S.score end

        -- Cong EXP & Kiem tra Len Cap
        DATA.exp = (DATA.exp or 0) + S.expEarned
        local leveledUp = false
        while DATA.exp >= getExpNeeded(DATA.level) do
            DATA.exp = DATA.exp - getExpNeeded(DATA.level)
            DATA.level = DATA.level + 1
            leveledUp = true
        end

        SAVE.Write()
        refreshAllUI()

        if isManualQuit then GAME.ReturnToLobby(); return end

        UI.EndTitle.Text = isVictory and "THẮNG TRẬN!" or "THUA TRẬN"
        UI.EndTitle.TextColor3 = isVictory and C.TXT_GOLD or C.TXT_RED
        UI.EndCardStroke.Color = isVictory and C.BORDER_GOLD or C.TXT_RED
        UI.EndNextBtn.Text = isVictory and "TIẾP TỤC" or "THỬ LẠI"
        local lvNote = leveledUp and ("\nLÊN CẤP MỚI: Lv." .. tostring(DATA.level) .. " (+HP & +ATK)") or ""
        UI.EndStats.Text = string.format(
            "%s (%s)\nQuái đã hạ: %d  |  Combo tối đa: %d\nThưởng: +%d Xu  |  +%d KC  |  +%d EXP%s",
            S.stage.name, S.diff.name, S.kills, S.maxCombo, S.coinsEarned, S.gemsEarned, S.expEarned, lvNote .. lootNote
        )
        UI.EndOverlay.Visible = true
    end

    function GAME.ReturnToLobby()
        S.inMatch, S.paused, S.pickingBuff, S.gameOver = false, false, false, false
        clearEntities()
        UI.CombatView.Visible = false
        UI.LobbyView.Visible = true
        refreshAllUI()
    end

    -- Vong lap cap nhat 60 FPS
    trackConn(RunService.RenderStepped:Connect(function(dt)
        if not S.inMatch or S.paused or S.pickingBuff or S.gameOver then return end
        dt = math.min(dt, 0.05)
        S.matchTime = S.matchTime + dt
        S.mp = math.min(S.maxMp, S.mp + S.mpRegen * dt)

        local pulse = 0.5 + 0.5 * math.sin(S.matchTime * 6)
        for idx, emb in ipairs(S.braziers) do
            local sz = 8 + math.floor((pulse + (idx % 2) * 0.25) * 3)
            emb.Size = UDim2.new(0, sz, 0, sz)
        end

        if S.attackCd > 0 then S.attackCd = math.max(0, S.attackCd - dt) end
        if S.swingT > 0 then S.swingT = math.max(0, S.swingT - dt) end
        if S.dashCd > 0 then S.dashCd = math.max(0, S.dashCd - dt) end
        if S.s1Cd > 0 then S.s1Cd = math.max(0, S.s1Cd - dt) end
        if S.s2Cd > 0 then S.s2Cd = math.max(0, S.s2Cd - dt) end
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
                spawnGhost(S.px, S.py, S.hero.fx)
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
            -- Tu dong chien dau (Auto-Battle) khi bat
            if S.autoBattle and not S.joyActive and mx == 0 and my == 0 then
                local tgt = findNearest(9999)
                if tgt then
                    local dx, dy = tgt.x - S.px, tgt.y - S.py
                    local d = math.sqrt(dx * dx + dy * dy)
                    local wantD = (S.hero.attackType == "ranged") and 220 or (S.hero.range * 0.65)
                    if d > wantD then
                        mx, my = dx / math.max(1, d), dy / math.max(1, d)
                    elseif S.hero.attackType == "ranged" and d < 130 then
                        mx, my = -dx / math.max(1, d), -dy / math.max(1, d)
                    end
                    if d <= (S.hero.attackType == "ranged" and 390 or (S.hero.range + tgt.r + 18)) then
                        if S.fury >= 100 then GAME.TryUlt()
                        elseif S.s2Cd <= 0 and S.mp >= S.hero.s2Cost then GAME.TrySkill2()
                        elseif S.s1Cd <= 0 and S.mp >= S.hero.s1Cost then GAME.TrySkill1()
                        elseif S.attackCd <= 0 then GAME.TryAttack() end
                    end
                end
            end

            local len = math.sqrt(mx * mx + my * my)
            if len > 0.05 then
                local nx, ny = mx / math.max(1, len), my / math.max(1, len)
                S.px = math.clamp(S.px + nx * S.spd * dt, CFG.PLAYER_R, CFG.ARENA_W - CFG.PLAYER_R)
                S.py = math.clamp(S.py + ny * S.spd * dt, CFG.PLAYER_R, CFG.ARENA_H - CFG.PLAYER_R)
                S.dirX, S.dirY = mx / len, my / len
                -- Bui buoc chan khi chay
                S.dustT = S.dustT - dt
                if S.dustT <= 0 and DATA.settings.particles then
                    S.dustT = 0.14
                    spawnGhost(S.px - nx * 10, S.py + 14, C.STONE_LIGHT)
                end
            end
        end

        -- Spawn quai
        if S.enemiesToSpawn > 0 then
            S.spawnTimer = S.spawnTimer - dt
            if S.spawnTimer <= 0 then
                S.enemiesToSpawn = S.enemiesToSpawn - 1
                S.spawnTimer = math.max(0.32, 1.05 - S.wave * 0.05)
                local kinds = { "slime", "bat", "skeleton", "goblin", "mushroom", "ghost" }
                local k = kinds[RNG:NextInteger(1, math.min(#kinds, 2 + S.stage.id))]
                spawnEnemy(k, S.wave, false)
            end
        end

        local alive = 0
        for i = #S.enemies, 1, -1 do
            local e = S.enemies[i]
            if e.hp <= 0 then
                table.remove(S.enemies, i)
            else
                alive = alive + 1
                if e.flashT > 0 then
                    e.flashT = e.flashT - dt
                    e.ui.BackgroundColor3 = (e.flashT > 0) and C.TXT_MAIN or ((e.slowT > 0) and C.TXT_CYAN or e.baseCol)
                end
                if e.burnT > 0 then
                    e.burnT = e.burnT - dt
                    e.burnTick = e.burnTick - dt
                    if e.burnTick <= 0 then
                        e.burnTick = 0.6
                        damageEnemy(e, math.max(4, math.floor(S.atk * 0.25)), 0, 0, nil)
                    end
                end
                if e.hp > 0 then
                    if e.stunT > 0 then
                        e.stunT = e.stunT - dt
                    else
                        local spMult = (e.slowT > 0) and 0.50 or 1.0
                        if e.slowT > 0 then e.slowT = e.slowT - dt end
                        local dx, dy = S.px - e.x, S.py - e.y
                        local dist = math.sqrt(dx * dx + dy * dy)
                        local nx, ny = (dist > 1 and dx / dist or 0), (dist > 1 and dy / dist or 0)
                        if e.ranged and dist < 210 then
                            e.x = math.clamp(e.x - nx * e.spd * 0.35 * spMult * dt, 28, CFG.ARENA_W - 28)
                            e.y = math.clamp(e.y - ny * e.spd * 0.35 * spMult * dt, 28, CFG.ARENA_H - 28)
                        else
                            e.x = math.clamp(e.x + nx * e.spd * spMult * dt, 28, CFG.ARENA_W - 28)
                            e.y = math.clamp(e.y + ny * e.spd * spMult * dt, 28, CFG.ARENA_H - 28)
                        end
                        if e.ranged then
                            e.atkCd = e.atkCd - dt
                            if e.atkCd <= 0 then
                                e.atkCd = 2.0
                                spawnProj("enemy", e.x, e.y, nx * 290, ny * 290, e.dmg, 7, C.TXT_GEM, 0, nil)
                            end
                        end
                        if e.isBoss then
                            e.bossSkillCd = e.bossSkillCd - dt
                            if e.bossSkillCd <= 0 then
                                e.bossSkillCd = 3.4
                                if RNG:NextNumber() < 0.5 then
                                    for k = 1, 8 do
                                        local a = (k / 8) * math.pi * 2 + S.matchTime
                                        spawnProj("enemy", e.x, e.y, math.cos(a) * 265, math.sin(a) * 265, e.dmg, 8, C.TXT_RED, 0, nil)
                                    end
                                else
                                    spawnHazard(S.px, S.py, 82, 1.05, math.floor(e.dmg * 1.35))
                                    spawnHazard(math.clamp(S.px + RNG:NextNumber(-130, 130), 80, CFG.ARENA_W - 80), math.clamp(S.py + RNG:NextNumber(-90, 90), 80, CFG.ARENA_H - 80), 74, 1.15, math.floor(e.dmg * 1.2))
                                end
                            end
                        end
                        if dist < (e.r + CFG.PLAYER_R - 4) then damagePlayer(e.dmg) end
                    end
                    e.ui.Position = toPos(e.x, e.y)
                    if e.mdot then e.mdot.Position = UDim2.new(e.x / CFG.ARENA_W, 0, e.y / CFG.ARENA_H, 0) end
                end
            end
        end

        -- Het dot -> Thang tran hoac chon Nang cap roi sang dot sau
        if S.enemiesToSpawn <= 0 and alive == 0 then
            S.nextWaveTimer = S.nextWaveTimer + dt
            if S.nextWaveTimer >= 0.9 then
                S.nextWaveTimer = 0
                if not S.stage.endless and S.wave >= S.totalWaves then
                    GAME.EndMatch(true, false)
                    return
                else
                    openBuffPicker()
                    GAME.StartWave(S.wave + 1)
                end
            end
        end

        -- Cap nhat dan, vung no, vat pham, hieu ung
        for i = #S.projs, 1, -1 do
            local p = S.projs[i]
            p.life = p.life - dt
            p.x, p.y = p.x + p.vx * dt, p.y + p.vy * dt
            local dead = (p.life <= 0) or (p.x < 0) or (p.x > CFG.ARENA_W) or (p.y < 0) or (p.y > CFG.ARENA_H)
            if not dead then
                if p.owner == "player" then
                    for _, e in ipairs(S.enemies) do
                        if e.hp > 0 and not p.hitMap[e] and math.sqrt((e.x - p.x) ^ 2 + (e.y - p.y) ^ 2) <= (p.r + e.r) then
                            p.hitMap[e] = true
                            damageEnemy(e, p.dmg, p.vx * 0.02, p.vy * 0.02, p.status)
                            if p.pierce > 0 then p.pierce = p.pierce - 1 else dead = true break end
                        end
                    end
                elseif math.sqrt((S.px - p.x) ^ 2 + (S.py - p.y) ^ 2) <= (p.r + CFG.PLAYER_R - 2) then
                    damagePlayer(p.dmg); dead = true
                end
            end
            if dead then p.ui:Destroy(); table.remove(S.projs, i) else p.ui.Position = toPos(p.x, p.y) end
        end

        for i = #S.hazards, 1, -1 do
            local h = S.hazards[i]
            h.timer = h.timer - dt
            local r = 1 - math.clamp(h.timer / h.maxTimer, 0, 1)
            h.charge.Size = UDim2.new(r, 0, r, 0)
            if h.timer <= 0 then
                spawnRing(h.x, h.y, h.r, C.TXT_RED, 0.24)
                if math.sqrt((S.px - h.x) ^ 2 + (S.py - h.y) ^ 2) <= h.r + CFG.PLAYER_R * 0.5 then damagePlayer(h.dmg) end
                h.ui:Destroy(); table.remove(S.hazards, i)
            end
        end

        for i = #S.pickups, 1, -1 do
            local pk = S.pickups[i]
            pk.life = pk.life - dt
            if math.sqrt((S.px - pk.x) ^ 2 + (S.py - pk.y) ^ 2) <= CFG.PLAYER_R + 20 then
                if pk.kind == "heal" then
                    local hl = math.floor(S.maxHp * 0.25)
                    S.hp = math.min(S.maxHp, S.hp + hl)
                    spawnFloat(S.px, S.py - 22, "+" .. hl .. " HP", C.TXT_GREEN, 13)
                elseif pk.kind == "mp" then
                    S.mp = math.min(S.maxMp, S.mp + 45)
                    spawnFloat(S.px, S.py - 22, "+45 MP", C.TXT_CYAN, 13)
                elseif pk.kind == "fury" then
                    S.fury = math.min(100, S.fury + 38)
                    spawnFloat(S.px, S.py - 22, "+38% NỘ", C.TXT_GOLD, 13)
                else
                    S.buffAtkTime = 8.0
                    spawnFloat(S.px, S.py - 22, "+35% ATK", C.TXT_RED, 13)
                end
                pk.ui:Destroy(); table.remove(S.pickups, i)
            elseif pk.life <= 0 then
                pk.ui:Destroy(); table.remove(S.pickups, i)
            end
        end

        for i = #S.effects, 1, -1 do
            local fx = S.effects[i]
            fx.life = fx.life - dt
            if fx.life <= 0 then fx.ui:Destroy(); table.remove(S.effects, i)
            else
                local prog = 1 - (fx.life / fx.maxLife)
                if fx.kind == "ring" then
                    local cr = fx.maxR * (0.35 + prog * 0.65)
                    fx.ui.Size = UDim2.new((cr * 2) / CFG.ARENA_W, 0, (cr * 2) / CFG.ARENA_H, 0)
                    fx.ui.BackgroundTransparency = 0.65 + prog * 0.35
                elseif fx.kind == "crescent" then
                    fx.x = fx.x + fx.vx * dt
                    fx.y = fx.y + fx.vy * dt
                    fx.ui.Position = toPos(fx.x, fx.y)
                    fx.ui.BackgroundTransparency = 0.10 + prog * 0.90
                else
                    fx.ui.BackgroundTransparency = 0.25 + prog * 0.75
                end
            end
        end

        for i = #S.sparks, 1, -1 do
            local sp = S.sparks[i]
            sp.life = sp.life - dt
            if sp.life <= 0 then sp.ui:Destroy(); table.remove(S.sparks, i)
            else
                sp.x, sp.y = sp.x + sp.vx * dt, sp.y + sp.vy * dt
                sp.ui.Position = toPos(sp.x, sp.y)
                sp.ui.BackgroundTransparency = 1 - (sp.life / sp.maxLife)
            end
        end

        for i = #S.floatTexts, 1, -1 do
            local ft = S.floatTexts[i]
            ft.life = ft.life - dt
            if ft.life <= 0 then ft.ui:Destroy(); table.remove(S.floatTexts, i)
            else
                ft.y = ft.y + ft.vy * dt
                ft.ui.Position = toPos(ft.x, ft.y)
                ft.ui.TextTransparency = 1 - (ft.life / ft.maxLife)
            end
        end

        if S.shakeTimer > 0 then
            S.shakeTimer = S.shakeTimer - dt
            UI.Arena.Position = UDim2.new(0, 6 + RNG:NextNumber(-S.shakePower, S.shakePower), 0, 6 + RNG:NextNumber(-S.shakePower, S.shakePower))
            if S.shakeTimer <= 0 then S.shakePower = 0; UI.Arena.Position = UDim2.new(0, 6, 0, 6) end
        end

        -- Cap nhat vi tri nhan vat, chuyen dong buoc chan (walk bobbing), vu khi & Minimap
        local isMoving = S.joyActive or S.keys.W or S.keys.A or S.keys.S or S.keys.D or (S.dashTime > 0)
        local bobY = isMoving and (math.sin(S.matchTime * 18) * 2.6) or (math.sin(S.matchTime * 4) * 1.0)
        local tiltRot = isMoving and (math.sin(S.matchTime * 18) * 5) or 0
        UI.PlayerNode.Position = UDim2.new(S.px / CFG.ARENA_W, 0, S.py / CFG.ARENA_H, bobY)
        UI.PlayerSprite.Rotation = tiltRot
        UI.MiniPlayerDot.Position = UDim2.new(S.px / CFG.ARENA_W, 0, S.py / CFG.ARENA_H, 0)
        if UI.WeaponPivot then
            local baseDeg = math.deg(math.atan2(S.dirY, S.dirX))
            local swing = (S.swingT > 0) and (((0.5 - (S.swingT / 0.16)) * 150) * S.swingSign) or 0
            UI.WeaponPivot.Rotation = baseDeg + swing
        end

        local hpRatio = math.clamp(S.hp / math.max(1, S.maxHp), 0, 1)
        local mpRatio = math.clamp(S.mp / math.max(1, S.maxMp), 0, 1)
        UI.PlayerMiniHp.Size = UDim2.new(hpRatio, 0, 1, 0)
        UI.TopHpFill.Size = UDim2.new(hpRatio, 0, 1, 0)
        UI.TopMpFill.Size = UDim2.new(mpRatio, 0, 1, 0)
        UI.TopHpLbl.Text = string.format("HP %d/%d", math.floor(S.hp), S.maxHp)
        UI.TopMpLbl.Text = string.format("MP %d/%d", math.floor(S.mp), S.maxMp)

        local mins = math.floor(S.matchTime / 60)
        local secs = math.floor(S.matchTime % 60)
        local waveStr = S.stage.endless and ("Đợt " .. tostring(S.wave)) or string.format("Đợt %d/%d", S.wave, S.totalWaves)
        UI.HudWaveLbl.Text = string.format("%s  |  %02d:%02d", waveStr, mins, secs)
        UI.HudComboLbl.Text = (S.combo >= 2) and ("COMBO x" .. tostring(S.combo)) or ""

        UI.DashBtn.Text = (S.dashCd > 0) and string.format("%.1fs", S.dashCd) or "LƯỚT"
        UI.S1Btn.Text = (S.s1Cd > 0) and string.format("%.1fs", S.s1Cd) or "CHIÊU 1"
        UI.S2Btn.Text = (S.s2Cd > 0) and string.format("%.1fs", S.s2Cd) or "CHIÊU 2"
        UI.UltBtn.Text = (S.fury >= 100) and "TUYỆT CHIÊU" or (tostring(math.floor(S.fury)) .. "% NỘ")
    end))
end

-- ============================================================================
-- 10. HO TRO PHIM PC
-- ============================================================================
do
    trackConn(UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or not S.inMatch or S.paused or S.pickingBuff or S.gameOver then return end
        local kc = inp.KeyCode
        if kc == Enum.KeyCode.W or kc == Enum.KeyCode.Up then S.keys.W = true
        elseif kc == Enum.KeyCode.S or kc == Enum.KeyCode.Down then S.keys.S = true
        elseif kc == Enum.KeyCode.A or kc == Enum.KeyCode.Left then S.keys.A = true
        elseif kc == Enum.KeyCode.D or kc == Enum.KeyCode.Right then S.keys.D = true
        elseif kc == Enum.KeyCode.J or kc == Enum.KeyCode.Space then S.holdAttack = true; GAME.TryAttack()
        elseif kc == Enum.KeyCode.K or kc == Enum.KeyCode.LeftShift then GAME.TryDash()
        elseif kc == Enum.KeyCode.L or kc == Enum.KeyCode.Q then GAME.TrySkill1()
        elseif kc == Enum.KeyCode.I or kc == Enum.KeyCode.R then GAME.TrySkill2()
        elseif kc == Enum.KeyCode.U or kc == Enum.KeyCode.E then GAME.TryUlt() end
    end))

    trackConn(UserInputService.InputEnded:Connect(function(inp)
        local kc = inp.KeyCode
        if kc == Enum.KeyCode.W or kc == Enum.KeyCode.Up then S.keys.W = false
        elseif kc == Enum.KeyCode.S or kc == Enum.KeyCode.Down then S.keys.S = false
        elseif kc == Enum.KeyCode.A or kc == Enum.KeyCode.Left then S.keys.A = false
        elseif kc == Enum.KeyCode.D or kc == Enum.KeyCode.Right then S.keys.D = false
        elseif kc == Enum.KeyCode.J or kc == Enum.KeyCode.Space then S.holdAttack = false end
    end))
end

-- ============================================================================
-- 11. DON DEP & KHOI TAO
-- ============================================================================
_G.ArenaChienDau_Cleanup = function()
    S.inMatch = false
    for _, c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
    CONNS = {}
    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
end

refreshAllUI()
showToast("Đấu Trường Chiến Đấu Pro " .. CFG.VERSION .. " (Full Màn Hình)", C.TXT_GOLD)
