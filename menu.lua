-- ============================================================
-- SNAKE ARCADE v9.1 - ME CUNG DE NHIN + RAN ADMIN VIP + FULL LV/SKIN ADMIN + 3 RAN CODE BINH THUONG
-- Tu dong luu ngam (giu nguyen tien trinh cu) | Phim tat PC: RightShift
-- ============================================================
local _ok, _err = pcall(function()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local GUI_NAME = "SnakeArcadePro_Standalone"
local SAVE_FILE = "SnakeArcadePro_Save_" .. tostring(player.UserId) .. ".json"

local THEME = {
	Outline    = Color3.fromRGB(10, 12, 20),
	TextMain   = Color3.fromRGB(214, 218, 224),
	TextMuted  = Color3.fromRGB(156, 166, 186),
	TextGold   = Color3.fromRGB(214, 180, 64),
	TextGem    = Color3.fromRGB(108, 190, 210),
	TextRuby   = Color3.fromRGB(204, 118, 226),
	TextGreen  = Color3.fromRGB(104, 198, 134),
	TextRed    = Color3.fromRGB(210, 102, 108),
	TextPurple = Color3.fromRGB(182, 136, 214),
	TextBlue   = Color3.fromRGB(98, 172, 214),
	FontHead   = Enum.Font.GothamSemibold,
	FontBody   = Enum.Font.GothamMedium,
}

local function getGuiParent()
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then return hui end
	end
	local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
	if ok and coreGui then
		local canWrite = pcall(function()
			local f = Instance.new("Folder")
			f.Parent = coreGui
			f:Destroy()
		end)
		if canWrite then return coreGui end
	end
	return player:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
local oldGui = guiParent:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

local connections = {}
local function track(conn)
	table.insert(connections, conn)
	return conn
end

local function formatNum(n)
	local s = tostring(math.floor(n or 0))
	local k
	while true do
		s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return s
end

-- ============================================================
-- BAC HIEM & 27 SKIN RAN (HO TRO THEM SKIN BI MAT MUA BANG HONG NGOC SAU NAY)
-- ============================================================
local RARITY_ORDER = { "All", "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret" }

local RARITIES = {
	All       = { Label = "Tất cả",      Color = Color3.fromRGB(184, 192, 206), BonusText = "" },
	Common    = { Label = "Thường",      Color = Color3.fromRGB(158, 170, 188), BonusText = "" },
	Rare      = { Label = "Hiếm",        Color = Color3.fromRGB(96, 172, 214),  BonusText = "+15% Xu" },
	Epic      = { Label = "Sử Thi",      Color = Color3.fromRGB(180, 134, 212), BonusText = "+35% Xu" },
	Legendary = { Label = "Huyền Thoại", Color = Color3.fromRGB(214, 180, 66),  BonusText = "+60% Xu" },
	Mythic    = { Label = "Thần Thoại",  Color = Color3.fromRGB(212, 98, 122),  BonusText = "+100% Xu & +1 KC/150đ" },
	Secret    = { Label = "Bí Mật",      Color = Color3.fromRGB(214, 92, 232),  BonusText = "+150% Xu & +1 KC/100đ" },
}

local SKINS = {
	-- BAC THUONG (THIET KE DON GIAN, DE MUA DE LAM QUEN)
	{ Id = "classic_green",  Name = "Rắn Xanh Lá",       Rarity = "Common", CoinMult = 1.00, Price = 0,     Currency = "Coins", HeadColor = Color3.fromRGB(52, 198, 66),  Body1 = Color3.fromRGB(36, 178, 56),  Body2 = Color3.fromRGB(118, 210, 92) },
	{ Id = "classic_gold",   Name = "Rắn Ong Vàng",      Rarity = "Common", CoinMult = 1.05, Price = 800,   Currency = "Coins", HeadColor = Color3.fromRGB(214, 178, 42), Body1 = Color3.fromRGB(205, 162, 28), Body2 = Color3.fromRGB(36, 32, 30) },
	{ Id = "watermelon",     Name = "Rắn Dưa Hấu",       Rarity = "Common", CoinMult = 1.10, Price = 1500,  Currency = "Coins", HeadColor = Color3.fromRGB(208, 68, 82),  Body1 = Color3.fromRGB(208, 68, 82),  Body2 = Color3.fromRGB(42, 178, 88), Body3 = Color3.fromRGB(26, 26, 32) },
	{ Id = "classic_red",    Name = "Rắn Ác Quỷ Đỏ",     Rarity = "Common", CoinMult = 1.15, Price = 2500,  Currency = "Coins", HeadColor = Color3.fromRGB(210, 52, 58),  Body1 = Color3.fromRGB(192, 42, 46),  Body2 = Color3.fromRGB(216, 204, 204), Style = "Devil", EyeColor = Color3.fromRGB(22, 12, 16) },

	-- BAC HIEM (CO PHU KIEN DAU DEP, TAI THU, SUNG, VAY CA)
	{ Id = "classic_blue",   Name = "Rắn Băng Tuyết",    Rarity = "Rare",   CoinMult = 1.20, Price = 4500,  Currency = "Coins", HeadColor = Color3.fromRGB(48, 152, 215), Body1 = Color3.fromRGB(34, 124, 200), Body2 = Color3.fromRGB(122, 192, 218), Style = "Ice" },
	{ Id = "koi_fish",       Name = "Rắn Cá Koi",        Rarity = "Rare",   CoinMult = 1.25, Price = 6500,  Currency = "Coins", HeadColor = Color3.fromRGB(216, 212, 206),Body1 = Color3.fromRGB(214, 108, 42), Body2 = Color3.fromRGB(214, 210, 205), Body3 = Color3.fromRGB(198, 52, 46), Style = "Koi" },
	{ Id = "panda",          Name = "Rắn Gấu Trúc",      Rarity = "Rare",   CoinMult = 1.30, Price = 9000,  Currency = "Coins", HeadColor = Color3.fromRGB(214, 216, 222),Body1 = Color3.fromRGB(214, 216, 222),Body2 = Color3.fromRGB(32, 34, 44), Style = "Panda" },
	{ Id = "classic_purple", Name = "Rắn Hắc Long Tím",  Rarity = "Rare",   CoinMult = 1.35, Price = 12000, Currency = "Coins", HeadColor = Color3.fromRGB(152, 74, 215), Body1 = Color3.fromRGB(132, 54, 198), Body2 = Color3.fromRGB(186, 128, 216), Style = "DarkHorn" },
	{ Id = "zombie",         Name = "Rắn Zombie",        Rarity = "Rare",   CoinMult = 1.40, Price = 15000, Currency = "Coins", HeadColor = Color3.fromRGB(96, 168, 90),  Body1 = Color3.fromRGB(76, 152, 70),  Body2 = Color3.fromRGB(148, 198, 62), Body3 = Color3.fromRGB(112, 72, 66), Style = "Zombie" },
	{ Id = "free_emerald",   Name = "Ngọc Lục Bảo",      Rarity = "Rare",   CoinMult = 1.45, GemAdd = 1, FreeOnly = true, UnlockText = "ĐIỂM DANH NGÀY 7", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(32, 192, 126), Body1 = Color3.fromRGB(22, 156, 102), Body2 = Color3.fromRGB(112, 218, 164), Body3 = Color3.fromRGB(212, 188, 72), GlowColor = Color3.fromRGB(64, 206, 144), Style = "Ice" },
	{ Id = "code_neon",      Name = "Rắn Neon Code",     Rarity = "Rare",   CoinMult = 1.35, FreeOnly = true, UnlockText = "NHẬP GIFTCODE", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(38, 196, 214), Body1 = Color3.fromRGB(28, 148, 198), Body2 = Color3.fromRGB(102, 218, 224), Body3 = Color3.fromRGB(24, 34, 58), GlowColor = Color3.fromRGB(62, 204, 220), Style = "Cyber" },

	-- BAC SU THI (PHU KIEN DOC DAO, HIEU UNG PHAT SANG)
	{ Id = "kitty",          Name = "Rắn Mèo Nơ Hồng",   Rarity = "Epic",   CoinMult = 1.50, Price = 22000, Currency = "Coins", HeadColor = Color3.fromRGB(220, 202, 212),Body1 = Color3.fromRGB(208, 104, 158),Body2 = Color3.fromRGB(222, 194, 208), Style = "Kitty" },
	{ Id = "pumpkin",        Name = "Rắn Bí Ngô",        Rarity = "Epic",   CoinMult = 1.60, Price = 32000, Currency = "Coins", HeadColor = Color3.fromRGB(212, 108, 32), Body1 = Color3.fromRGB(196, 86, 22),  Body2 = Color3.fromRGB(138, 52, 20), Style = "Pumpkin", EyeColor = Color3.fromRGB(214, 196, 110) },
	{ Id = "deer_dragon",    Name = "Thanh Long Hươu",   Rarity = "Epic",   CoinMult = 1.65, GemAdd = 1, Price = 50,  Currency = "Gems",  HeadColor = Color3.fromRGB(30, 176, 192), Body1 = Color3.fromRGB(22, 148, 176), Body2 = Color3.fromRGB(20, 52, 76), Style = "Antlers", GlowColor = Color3.fromRGB(56, 182, 204) },
	{ Id = "unicorn",        Name = "Rắn Kỳ Lân",        Rarity = "Epic",   CoinMult = 1.75, GemAdd = 1, Price = 80,  Currency = "Gems",  HeadColor = Color3.fromRGB(218, 204, 222),Body1 = Color3.fromRGB(206, 142, 214),Body2 = Color3.fromRGB(142, 206, 214), Body3 = Color3.fromRGB(216, 204, 126), Style = "Unicorn", GlowColor = Color3.fromRGB(196, 118, 212) },
	{ Id = "skull",          Name = "Rắn Đầu Lâu",       Rarity = "Epic",   CoinMult = 1.85, GemAdd = 1, Price = 110, Currency = "Gems",  HeadColor = Color3.fromRGB(210, 210, 216),Body1 = Color3.fromRGB(28, 28, 38),   Body2 = Color3.fromRGB(206, 206, 214), Style = "Skull", EyeColor = Color3.fromRGB(206, 54, 54) },
	{ Id = "free_sunset",    Name = "Hỏa Hoàng Hôn",     Rarity = "Epic",   CoinMult = 1.90, GemAdd = 2, RubyChance = 1, FreeOnly = true, UnlockText = "ONLINE 60 PHÚT", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(218, 92, 68), Body1 = Color3.fromRGB(204, 64, 96), Body2 = Color3.fromRGB(222, 152, 54), Body3 = Color3.fromRGB(132, 46, 124), GlowColor = Color3.fromRGB(216, 118, 66), Style = "Flame" },
	{ Id = "code_royal",     Name = "Rắn Hoàng Gia",     Rarity = "Epic",   CoinMult = 1.65, GemAdd = 1, FreeOnly = true, UnlockText = "NHẬP GIFTCODE", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(118, 56, 204), Body1 = Color3.fromRGB(92, 42, 178), Body2 = Color3.fromRGB(214, 178, 54), Body3 = Color3.fromRGB(214, 216, 224), GlowColor = Color3.fromRGB(210, 176, 56), Style = "Crown" },
	{ Id = "ghost_snake",    Name = "Rắn Bóng Ma",       Rarity = "Epic",   CoinMult = 1.95, GemAdd = 2, Price = 150, Currency = "Gems",  HeadColor = Color3.fromRGB(196, 212, 222),Body1 = Color3.fromRGB(162, 198, 216),Body2 = Color3.fromRGB(206, 216, 224), BodyAlpha = 0.34, GlowColor = Color3.fromRGB(126, 174, 212), EyeColor = Color3.fromRGB(62, 166, 210) },

	-- BAC HUYEN THOAI (VUONG MIEN, RONG LUA/BANG, RGB, CYBER, SAMURAI)
	{ Id = "king_snake",     Name = "Vua Rắn Hoàng Kim", Rarity = "Legendary", CoinMult = 1.90, GemAdd = 1, Price = 45000, Currency = "Coins", HeadColor = Color3.fromRGB(214, 174, 42), Body1 = Color3.fromRGB(202, 152, 26), Body2 = Color3.fromRGB(216, 200, 118), GlowColor = Color3.fromRGB(206, 172, 46), Style = "Crown" },
	{ Id = "fire_dragon",    Name = "Rồng Dung Nham",    Rarity = "Legendary", CoinMult = 2.10, GemAdd = 2, RubyChance = 1, Price = 200, Currency = "Gems", HeadColor = Color3.fromRGB(48, 36, 44),   Body1 = Color3.fromRGB(36, 26, 30),   Body2 = Color3.fromRGB(212, 108, 32), Body3 = Color3.fromRGB(202, 68, 48), EyeColor = Color3.fromRGB(218, 122, 34), GlowColor = Color3.fromRGB(210, 132, 62), Style = "Flame" },
	{ Id = "ice_dragon",     Name = "Rồng Pha Lê Băng",  Rarity = "Legendary", CoinMult = 2.25, GemAdd = 2, RubyChance = 1, Price = 260, Currency = "Gems", HeadColor = Color3.fromRGB(64, 182, 218), Body1 = Color3.fromRGB(26, 148, 204), Body2 = Color3.fromRGB(184, 214, 222), GlowColor = Color3.fromRGB(112, 188, 216), Style = "Ice" },
	{ Id = "dj_rainbow",     Name = "Rắn Cầu Vồng RGB",  Rarity = "Legendary", CoinMult = 2.45, GemAdd = 3, RubyChance = 2, Price = 340, Currency = "Gems", HeadColor = Color3.fromRGB(202, 78, 142), Body1 = Color3.fromRGB(202, 78, 142), Body2 = Color3.fromRGB(62, 166, 210), Rainbow = true, GlowColor = Color3.fromRGB(196, 202, 212), Style = "Headphones" },
	{ Id = "free_aurora",    Name = "Cực Quang Băng",    Rarity = "Legendary", CoinMult = 2.55, GemAdd = 3, RubyChance = 2, FreeOnly = true, UnlockText = "ĐẠT CẤP 30", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(42, 186, 212), Body1 = Color3.fromRGB(54, 196, 156), Body2 = Color3.fromRGB(122, 96, 218), Body3 = Color3.fromRGB(186, 220, 228), EyeColor = Color3.fromRGB(196, 226, 232), GlowColor = Color3.fromRGB(72, 204, 186), Style = "Star" },
	{ Id = "cyber_glitch",   Name = "Rắn Lỗi Cyber",     Rarity = "Legendary", CoinMult = 2.65, GemAdd = 3, RubyChance = 2, Price = 420, Currency = "Gems", HeadColor = Color3.fromRGB(24, 30, 44),   Body1 = Color3.fromRGB(48, 192, 204), Body2 = Color3.fromRGB(198, 62, 148), Body3 = Color3.fromRGB(28, 34, 52), Glitch = true, Style = "Cyber", EyeColor = Color3.fromRGB(76, 208, 214), GlowColor = Color3.fromRGB(56, 192, 206) },
	{ Id = "code_shadow",    Name = "Rắn Bóng Tối",      Rarity = "Legendary", CoinMult = 2.00, GemAdd = 2, FreeOnly = true, UnlockText = "NHẬP GIFTCODE", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(34, 36, 52), Body1 = Color3.fromRGB(26, 28, 44), Body2 = Color3.fromRGB(118, 86, 206), Body3 = Color3.fromRGB(72, 56, 138), EyeColor = Color3.fromRGB(168, 118, 224), GlowColor = Color3.fromRGB(132, 92, 214), Style = "DarkHorn" },
	{ Id = "samurai",        Name = "Rắn Samurai Đỏ",    Rarity = "Legendary", CoinMult = 2.85, GemAdd = 4, RubyChance = 2, Price = 520, Currency = "Gems", HeadColor = Color3.fromRGB(178, 36, 44),  Body1 = Color3.fromRGB(152, 32, 38),  Body2 = Color3.fromRGB(44, 38, 46), Body3 = Color3.fromRGB(206, 172, 54), Style = "Samurai", EyeColor = Color3.fromRGB(214, 186, 68), GlowColor = Color3.fromRGB(204, 168, 52) },

	-- BAC THAN THOAI (CANH THIEN THAN, PHUONG HOANG, VONG QUY DAO VU TRU)
	{ Id = "galaxy",         Name = "Rắn Ngân Hà",       Rarity = "Mythic", CoinMult = 3.10, GemAdd = 4, GemBonus = true, RubyChance = 3, Price = 650,  Currency = "Gems", HeadColor = Color3.fromRGB(52, 30, 114),  Body1 = Color3.fromRGB(42, 24, 98),   Body2 = Color3.fromRGB(124, 64, 204), Body3 = Color3.fromRGB(64, 168, 212), EyeColor = Color3.fromRGB(112, 204, 216), GlowColor = Color3.fromRGB(158, 92, 212), Style = "Star" },
	{ Id = "golden_dragon",  Name = "Rồng Vàng Hoàng Đế",Rarity = "Mythic", CoinMult = 3.35, GemAdd = 5, GemBonus = true, RubyChance = 3, Price = 850,  Currency = "Gems", HeadColor = Color3.fromRGB(216, 172, 34), Body1 = Color3.fromRGB(204, 146, 24), Body2 = Color3.fromRGB(218, 204, 118), GlowColor = Color3.fromRGB(212, 192, 108), Style = "Crown" },
	{ Id = "angel",          Name = "Rắn Thiên Thần",    Rarity = "Mythic", CoinMult = 3.60, GemAdd = 5, GemBonus = true, RubyChance = 4, Price = 1100, Currency = "Gems", HeadColor = Color3.fromRGB(218, 214, 204),Body1 = Color3.fromRGB(214, 214, 218),Body2 = Color3.fromRGB(208, 176, 52), Style = "Angel", GlowColor = Color3.fromRGB(212, 194, 114) },
	{ Id = "phoenix",        Name = "Phượng Hoàng Lửa",  Rarity = "Mythic", CoinMult = 3.90, GemAdd = 6, GemBonus = true, RubyChance = 4, Price = 1400, Currency = "Gems", HeadColor = Color3.fromRGB(208, 72, 34),  Body1 = Color3.fromRGB(196, 52, 34),  Body2 = Color3.fromRGB(214, 142, 34), Body3 = Color3.fromRGB(216, 188, 66), Style = "Phoenix", EyeColor = Color3.fromRGB(218, 204, 92), GlowColor = Color3.fromRGB(212, 134, 46) },
	{ Id = "free_celestial", Name = "Thần Long Cực Hạn", Rarity = "Mythic", CoinMult = 4.10, GemAdd = 6, GemBonus = true, RubyChance = 5, RubyAdd = 1, FreeOnly = true, UnlockText = "KỶ LỤC 1,500Đ", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(32, 42, 92), Body1 = Color3.fromRGB(48, 156, 212), Body2 = Color3.fromRGB(218, 184, 56), Body3 = Color3.fromRGB(214, 222, 232), EyeColor = Color3.fromRGB(224, 204, 92), GlowColor = Color3.fromRGB(92, 198, 224), Style = "Cosmic" },
	{ Id = "cosmic_god",     Name = "Thần Vũ Trụ",       Rarity = "Mythic", CoinMult = 4.25, GemAdd = 7, GemBonus = true, RubyChance = 5, Price = 1800, Currency = "Gems", HeadColor = Color3.fromRGB(28, 16, 68),   Body1 = Color3.fromRGB(34, 18, 86),   Body2 = Color3.fromRGB(208, 176, 48), Body3 = Color3.fromRGB(154, 86, 206), EyeColor = Color3.fromRGB(214, 196, 110), GlowColor = Color3.fromRGB(206, 174, 52), Style = "Cosmic" },
	{ Id = "void_emperor",   Name = "Đế Vương Hư Không", Rarity = "Mythic", CoinMult = 4.60, GemAdd = 8, GemBonus = true, RubyChance = 6, Price = 2300, Currency = "Gems", HeadColor = Color3.fromRGB(20, 14, 34),   Body1 = Color3.fromRGB(28, 18, 48),   Body2 = Color3.fromRGB(132, 54, 196), Body3 = Color3.fromRGB(76, 32, 132), Style = "Void", EyeColor = Color3.fromRGB(192, 116, 216), GlowColor = Color3.fromRGB(154, 78, 212) },

	-- 12 PET BI MAT (HONG NGOC - SAP XEP THEO DO DEP) + 1 PET BI MAT FREE MAX CAP 100
	{ Id = "secret_shades",  Name = "Hắc Xà Ngầu Lòi",    Rarity = "Secret", CoinMult = 3.40, GemAdd = 5, GemBonus = true, GemStep = 100, RubyChance = 5,  RubyAdd = 0, Price = 8,   Currency = "Rubies", HeadColor = Color3.fromRGB(24, 24, 30),  Body1 = Color3.fromRGB(26, 26, 34), Body2 = Color3.fromRGB(204, 208, 218), Body3 = Color3.fromRGB(68, 72, 86),   EyeColor = Color3.fromRGB(220, 224, 232), GlowColor = Color3.fromRGB(186, 192, 208), Style = "SecretShades" },
	{ Id = "secret_toxic",   Name = "Hắc Xà Độc Ngọc",    Rarity = "Secret", CoinMult = 3.65, GemAdd = 5, GemBonus = true, GemStep = 100, RubyChance = 6,  RubyAdd = 0, Price = 12,  Currency = "Rubies", HeadColor = Color3.fromRGB(18, 26, 24),  Body1 = Color3.fromRGB(20, 28, 26), Body2 = Color3.fromRGB(48, 206, 122),  Body3 = Color3.fromRGB(26, 118, 74),  EyeColor = Color3.fromRGB(64, 218, 134),  GlowColor = Color3.fromRGB(52, 204, 124),  Style = "DarkHorn" },
	{ Id = "secret_panda",   Name = "Gấu Trúc Bóng Đêm",  Rarity = "Secret", CoinMult = 3.90, GemAdd = 6, GemBonus = true, GemStep = 100, RubyChance = 6,  RubyAdd = 0, Price = 16,  Currency = "Rubies", HeadColor = Color3.fromRGB(218, 222, 232),Body1 = Color3.fromRGB(24, 24, 34), Body2 = Color3.fromRGB(216, 220, 230), Body3 = Color3.fromRGB(156, 72, 216), EyeColor = Color3.fromRGB(178, 82, 228),  GlowColor = Color3.fromRGB(168, 78, 220),  Style = "Panda" },
	{ Id = "secret_magma",   Name = "Hắc Long Huyết Hỏa", Rarity = "Secret", CoinMult = 4.20, GemAdd = 6, GemBonus = true, GemStep = 100, RubyChance = 7,  RubyAdd = 0, Price = 20,  Currency = "Rubies", HeadColor = Color3.fromRGB(22, 18, 26),  Body1 = Color3.fromRGB(24, 18, 24), Body2 = Color3.fromRGB(212, 44, 38),   Body3 = Color3.fromRGB(132, 24, 24),  EyeColor = Color3.fromRGB(224, 52, 42),   GlowColor = Color3.fromRGB(214, 48, 42),   Style = "SecretMagma" },
	{ Id = "secret_cyber",   Name = "Bóng Đêm Mạch Xanh", Rarity = "Secret", CoinMult = 4.50, GemAdd = 7, GemBonus = true, GemStep = 100, RubyChance = 8,  RubyAdd = 1, Price = 25,  Currency = "Rubies", HeadColor = Color3.fromRGB(18, 24, 34),  Body1 = Color3.fromRGB(20, 26, 38), Body2 = Color3.fromRGB(48, 198, 224),  Body3 = Color3.fromRGB(28, 86, 134),  EyeColor = Color3.fromRGB(72, 214, 236),  GlowColor = Color3.fromRGB(56, 196, 224),  Style = "Cyber" },
	{ Id = "secret_amethyst",Name = "Hắc Long Tử Tinh",   Rarity = "Secret", CoinMult = 4.80, GemAdd = 8, GemBonus = true, GemStep = 100, RubyChance = 9,  RubyAdd = 1, Price = 30,  Currency = "Rubies", HeadColor = Color3.fromRGB(24, 18, 34),  Body1 = Color3.fromRGB(26, 18, 38), Body2 = Color3.fromRGB(174, 62, 226),  Body3 = Color3.fromRGB(92, 32, 152),  EyeColor = Color3.fromRGB(198, 92, 236),  GlowColor = Color3.fromRGB(176, 68, 228),  Style = "SecretCrystal" },
	{ Id = "secret_bat",     Name = "Ma Dơi Hắc Ám",      Rarity = "Secret", CoinMult = 5.15, GemAdd = 8, GemBonus = true, GemStep = 100, RubyChance = 10, RubyAdd = 1, Price = 38,  Currency = "Rubies", HeadColor = Color3.fromRGB(28, 22, 38),  Body1 = Color3.fromRGB(26, 20, 36), Body2 = Color3.fromRGB(142, 54, 212),  Body3 = Color3.fromRGB(44, 32, 64),   EyeColor = Color3.fromRGB(186, 86, 232),  GlowColor = Color3.fromRGB(154, 68, 218),  Style = "SecretBat" },
	{ Id = "secret_skull",   Name = "Tử Thần Hắc Sọ",     Rarity = "Secret", CoinMult = 5.50, GemAdd = 9, GemBonus = true, GemStep = 100, RubyChance = 11, RubyAdd = 2, Price = 46,  Currency = "Rubies", HeadColor = Color3.fromRGB(22, 20, 26),  Body1 = Color3.fromRGB(22, 20, 28), Body2 = Color3.fromRGB(216, 218, 224), Body3 = Color3.fromRGB(196, 44, 48),  EyeColor = Color3.fromRGB(220, 48, 52),   GlowColor = Color3.fromRGB(210, 56, 60),   Style = "Skull" },
	{ Id = "secret_witch",   Name = "Phù Thủy Hắc Ám",    Rarity = "Secret", CoinMult = 5.90, GemAdd = 10,GemBonus = true, GemStep = 100, RubyChance = 12, RubyAdd = 2, Price = 55,  Currency = "Rubies", HeadColor = Color3.fromRGB(26, 18, 38),  Body1 = Color3.fromRGB(30, 20, 48), Body2 = Color3.fromRGB(148, 56, 214),  Body3 = Color3.fromRGB(214, 174, 46), EyeColor = Color3.fromRGB(196, 88, 232),  GlowColor = Color3.fromRGB(168, 72, 224),  Style = "SecretWitch" },
	{ Id = "secret_visor",   Name = "Chiến Binh Neon Đen",Rarity = "Secret", CoinMult = 6.35, GemAdd = 11,GemBonus = true, GemStep = 100, RubyChance = 13, RubyAdd = 2, Price = 68,  Currency = "Rubies", HeadColor = Color3.fromRGB(20, 22, 30),  Body1 = Color3.fromRGB(24, 26, 38), Body2 = Color3.fromRGB(214, 62, 186),  Body3 = Color3.fromRGB(52, 186, 224), EyeColor = Color3.fromRGB(218, 74, 196),  GlowColor = Color3.fromRGB(204, 68, 196),  Style = "Cyber" },
	{ Id = "secret_angel",   Name = "Thiên Thần Sa Ngã",  Rarity = "Secret", CoinMult = 6.85, GemAdd = 12,GemBonus = true, GemStep = 100, RubyChance = 14, RubyAdd = 3, Price = 85,  Currency = "Rubies", HeadColor = Color3.fromRGB(24, 22, 28),  Body1 = Color3.fromRGB(26, 24, 32), Body2 = Color3.fromRGB(218, 220, 226), Body3 = Color3.fromRGB(218, 178, 48), EyeColor = Color3.fromRGB(224, 182, 54),  GlowColor = Color3.fromRGB(220, 184, 62),  Style = "Angel" },
	{ Id = "secret_emperor", Name = "Hắc Đế Vương",       Rarity = "Secret", CoinMult = 7.50, GemAdd = 14,GemBonus = true, GemStep = 100, RubyChance = 15, RubyAdd = 4, Price = 110, Currency = "Rubies", HeadColor = Color3.fromRGB(22, 18, 24),  Body1 = Color3.fromRGB(24, 20, 26), Body2 = Color3.fromRGB(224, 180, 42),  Body3 = Color3.fromRGB(168, 108, 20), EyeColor = Color3.fromRGB(230, 188, 52),  GlowColor = Color3.fromRGB(226, 184, 48),  Style = "Crown" },
	{ Id = "free_abyss",     Name = "Chúa Tể Vực Thẳm",   Rarity = "Secret", CoinMult = 7.80, GemAdd = 15,GemBonus = true, GemStep = 90,  RubyChance = 16, RubyAdd = 4, FreeOnly = true, UnlockText = "ĐẠT CẤP 100", Price = 0, Currency = "Free", HeadColor = Color3.fromRGB(16, 12, 28), Body1 = Color3.fromRGB(22, 14, 42), Body2 = Color3.fromRGB(204, 52, 214), Body3 = Color3.fromRGB(62, 198, 224), EyeColor = Color3.fromRGB(228, 72, 224), GlowColor = Color3.fromRGB(192, 64, 224), Style = "Void" },
	{ Id = "admin_supreme",  Name = "Thần Rắn Admin",     Rarity = "Secret", CoinMult = 15.0, GemAdd = 30,GemBonus = true, GemStep = 50,  RubyChance = 35, RubyAdd = 10, FreeOnly = true, AdminOnly = true, UnlockText = "CHỈ CODE ADMIN", Price = 0, Currency = "Free", Rainbow = true, HeadColor = Color3.fromRGB(224, 184, 48), Body1 = Color3.fromRGB(224, 184, 48), Body2 = Color3.fromRGB(196, 64, 224), Body3 = Color3.fromRGB(64, 206, 228), EyeColor = Color3.fromRGB(230, 212, 92), GlowColor = Color3.fromRGB(232, 196, 62), Style = "Crown" },
}

local function getSkinStatsText(skin)
	local parts = {}
	local coinPct = math.floor(((skin.CoinMult or 1.0) - 1.0) * 100 + 0.5)
	if coinPct > 0 then table.insert(parts, "+" .. coinPct .. "% Xu") end
	if skin.GemAdd and skin.GemAdd > 0 then table.insert(parts, "+" .. skin.GemAdd .. " KC") end
	if skin.RubyAdd and skin.RubyAdd > 0 then
		table.insert(parts, "+" .. skin.RubyAdd .. " HN")
	elseif skin.RubyChance and skin.RubyChance > 0 then
		table.insert(parts, "+" .. skin.RubyChance .. "% rơi HN")
	end
	return table.concat(parts, " • ")
end

local function getSkinById(id)
	for _, s in ipairs(SKINS) do
		if s.Id == id then return s end
	end
	return SKINS[1]
end

local FOODS = {
	{ Top = Color3.fromRGB(224, 58, 52),  Bot = Color3.fromRGB(172, 22, 34),  Leaf = Color3.fromRGB(68, 194, 62),  Score = 10, Coins = 6 },
	{ Top = Color3.fromRGB(216, 62, 128), Bot = Color3.fromRGB(158, 28, 82),  Leaf = Color3.fromRGB(68, 194, 62),  Score = 12, Coins = 8 },
	{ Top = Color3.fromRGB(228, 148, 36), Bot = Color3.fromRGB(186, 92, 18),  Leaf = Color3.fromRGB(76, 188, 58),  Score = 15, Coins = 10 },
	{ Top = Color3.fromRGB(158, 72, 216), Bot = Color3.fromRGB(102, 34, 168), Leaf = Color3.fromRGB(68, 194, 62),  Score = 18, Coins = 12 },
	{ Top = Color3.fromRGB(64, 196, 86),  Bot = Color3.fromRGB(28, 136, 54),  Leaf = Color3.fromRGB(216, 64, 74),  Score = 22, Coins = 15 },
	{ Top = Color3.fromRGB(228, 194, 48), Bot = Color3.fromRGB(186, 132, 18), Leaf = Color3.fromRGB(118, 212, 92), Score = 30, Coins = 20 },
}

-- 4 CHE DO CHOI / BAN DO (CAN BANG PHAN THUONG THEO DO KHO)
local GAME_MODES = {
	{ Id = "Classic", Name = "Cổ Điển",     Mult = 1.00, SpeedMult = 1.00, Desc = "Chuẩn 1.0x" },
	{ Id = "Portal",  Name = "Xuyên Tường", Mult = 0.85, SpeedMult = 1.00, Desc = "Xuyên cạnh 0.85x" },
	{ Id = "Maze",    Name = "Mê Cung",     Mult = 1.35, SpeedMult = 1.00, Desc = "Chướng ngại +35%" },
	{ Id = "Turbo",   Name = "Siêu Tốc",    Mult = 1.50, SpeedMult = 0.78, Desc = "Tốc độ cao +50%" },
}

local function getGameModeDef(id)
	for _, m in ipairs(GAME_MODES) do
		if m.Id == id then return m end
	end
	return GAME_MODES[1]
end

local POWERUPS = {
	{ Id = "Double", Icon = "⭐", Color = Color3.fromRGB(212, 178, 50), Name = "2x Điểm" },
	{ Id = "Ghost",  Icon = "👻", Color = Color3.fromRGB(174, 152, 214), Name = "Bóng Ma" },
	{ Id = "Shield", Icon = "🛡️", Color = Color3.fromRGB(84, 172, 214),  Name = "Khiên" },
	{ Id = "Magnet", Icon = "🧲", Color = Color3.fromRGB(208, 100, 104), Name = "Nam Châm" },
	{ Id = "Speed",  Icon = "⚡", Color = Color3.fromRGB(214, 192, 72),  Name = "Tăng Tốc" },
}

local BOT_SCORES = {
	{ Name = "PlayerPro", Score = 650 },
	{ Name = "SnakeKing", Score = 520 },
	{ Name = "GameMaster", Score = 430 },
	{ Name = "LuckySnake", Score = 350 },
	{ Name = "Speedy", Score = 280 },
	{ Name = "Dragon", Score = 220 },
	{ Name = "CoolSnake", Score = 160 },
	{ Name = "Hero", Score = 110 },
	{ Name = "Star", Score = 60 },
}

-- 8 O THUONG VONG QUAY MAY MAN (CAN BANG CHO QUAY x1 / x5 / x10)
local WHEEL_SLOTS = {
	{ Label = "350",   Kind = "Coins",  Amount = 350,  Weight = 26, Color = Color3.fromRGB(214, 168, 42) },
	{ Label = "15",    Kind = "Gems",   Amount = 15,   Weight = 22, Color = Color3.fromRGB(54, 152, 212) },
	{ Label = "900",   Kind = "Coins",  Amount = 900,  Weight = 16, Color = Color3.fromRGB(214, 118, 42) },
	{ Label = "35",    Kind = "Gems",   Amount = 35,   Weight = 13, Color = Color3.fromRGB(196, 68, 146) },
	{ Label = "1",     Kind = "Rubies", Amount = 1,    Weight = 7,  Color = Color3.fromRGB(152, 58, 212) },
	{ Label = "2,200", Kind = "Coins",  Amount = 2200, Weight = 8,  Color = Color3.fromRGB(64, 182, 86) },
	{ Label = "80",    Kind = "Gems",   Amount = 80,   Weight = 5,  Color = Color3.fromRGB(48, 112, 206) },
	{ Label = "2",     Kind = "Rubies", Amount = 2,    Weight = 3,  Color = Color3.fromRGB(186, 46, 178) },
}

local MAX_LEVEL = 100
local function expNeedForLevel(lv)
	return 100 + math.max(0, lv - 1) * 45
end

-- 18 MOC QUA TANG CAP CAN BANG TU CAP 2 DEN MAX CAP 100 (CO SKIN FREE DOC QUYEN)
local LEVEL_REWARDS = {
	{ Level = 2,   Desc = "400 Xu  +  1 Lượt quay",                      Coins = 400,   Gems = 0,   Rubies = 0,  Spins = 1 },
	{ Level = 5,   Desc = "20 Kim Cương  +  1 Lượt quay",                Coins = 0,     Gems = 20,  Rubies = 0,  Spins = 1 },
	{ Level = 8,   Desc = "1,000 Xu  +  1 Hồng Ngọc",                    Coins = 1000,  Gems = 0,   Rubies = 1,  Spins = 0 },
	{ Level = 10,  Desc = "Skin VIP: Vua Rắn Hoàng Kim  +  1 Quay",      SkinId = "king_snake", AltCoins = 20000, Spins = 1 },
	{ Level = 15,  Desc = "45 Kim Cương  +  1 Hồng Ngọc  +  2 Quay",     Coins = 0,     Gems = 45,  Rubies = 1,  Spins = 2 },
	{ Level = 20,  Desc = "Skin VIP: Rồng Dung Nham  +  2 Hồng Ngọc",    SkinId = "fire_dragon", AltGems = 120, Rubies = 2 },
	{ Level = 25,  Desc = "3,000 Xu  +  65 KC  +  2 Hồng Ngọc",          Coins = 3000,  Gems = 65,  Rubies = 2,  Spins = 1 },
	{ Level = 30,  Desc = "Skin Free Độc Quyền: Cực Quang Băng + 3 Quay",SkinId = "free_aurora", AltRubies = 4, Rubies = 2, Spins = 3 },
	{ Level = 35,  Desc = "Skin VIP: Rắn Cầu Vồng RGB  +  3 Hồng Ngọc",  SkinId = "dj_rainbow", AltGems = 200, Rubies = 3 },
	{ Level = 40,  Desc = "6,000 Xu  +  110 KC  +  3 Hồng Ngọc",         Coins = 6000,  Gems = 110, Rubies = 3,  Spins = 2 },
	{ Level = 50,  Desc = "Skin Thần Thoại: Rồng Vàng Hoàng Đế + 5 HN",  SkinId = "golden_dragon", AltGems = 400, Rubies = 5 },
	{ Level = 60,  Desc = "9,000 Xu  +  160 KC  +  5 HN  +  4 Quay",     Coins = 9000,  Gems = 160, Rubies = 5,  Spins = 4 },
	{ Level = 70,  Desc = "220 Kim Cương  +  6 Hồng Ngọc  +  5 Quay",    Coins = 0,     Gems = 220, Rubies = 6,  Spins = 5 },
	{ Level = 75,  Desc = "Pet Bí Mật: Hắc Long Huyết Hỏa  +  5 HN",     SkinId = "secret_magma", AltRubies = 10, Rubies = 5 },
	{ Level = 80,  Desc = "15,000 Xu  +  280 KC  +  8 Hồng Ngọc",        Coins = 15000, Gems = 280, Rubies = 8,  Spins = 4 },
	{ Level = 90,  Desc = "380 Kim Cương  +  10 Hồng Ngọc  +  6 Quay",   Coins = 0,     Gems = 380, Rubies = 10, Spins = 6 },
	{ Level = 95,  Desc = "25,000 Xu  +  480 KC  +  12 Hồng Ngọc",       Coins = 25000, Gems = 480, Rubies = 12, Spins = 6 },
	{ Level = 100, Desc = "MAX CẤP: Chúa Tể Vực Thẳm + 20 HN + 10 Quay", SkinId = "free_abyss", AltRubies = 40, Rubies = 20, Spins = 10 },
}

-- MA QUA TANG CAN BANG + MA MO SKIN CODE BINH THUONG + MA ADMIN FULL LV & FULL SKIN
local GIFT_CODES = {
	TANTHU       = { Coins = 300,  Gems = 8,  Rubies = 0, Spins = 1, Desc = "+300 Xu, +8 Kim Cương, +1 Lượt quay" },
	VONGQUAY     = { Coins = 0,    Gems = 0,  Rubies = 0, Spins = 2, Desc = "+2 Lượt quay may mắn" },
	HONGNGOC     = { Coins = 0,    Gems = 5,  Rubies = 1, Spins = 0, Desc = "+1 Hồng Ngọc, +5 Kim Cương" },
	RANSANMOI    = { Coins = 500,  Gems = 15, Rubies = 0, Spins = 1, Desc = "+500 Xu, +15 Kim Cương, +1 Lượt quay" },
	VIP2026      = { Coins = 800,  Gems = 25, Rubies = 1, Spins = 2, Desc = "+800 Xu, +25 Kim Cương, +1 Hồng Ngọc, +2 Quay" },
	MECUNG2026   = { Coins = 600,  Gems = 20, Rubies = 0, Spins = 2, Desc = "+600 Xu, +20 Kim Cương, +2 Lượt quay" },
	SIEUTOC      = { Coins = 450,  Gems = 15, Rubies = 0, Spins = 2, Desc = "+450 Xu, +15 Kim Cương, +2 Lượt quay" },
	QUATANG7NGAY = { Coins = 1000, Gems = 30, Rubies = 1, Spins = 1, Desc = "+1,000 Xu, +30 Kim Cương, +1 Hồng Ngọc, +1 Quay" },
	MAYMAN2026   = { Coins = 0,    Gems = 15, Rubies = 0, Spins = 3, Desc = "+3 Lượt quay may mắn, +15 Kim Cương" },
	RANCONGNGHE  = { Coins = 300,  Gems = 0,  Rubies = 0, Spins = 0, SkinId = "code_neon",   Desc = "Skin Rắn Neon Code (+35% Xu) + 300 Xu" },
	RANHOANGGIA  = { Coins = 0,    Gems = 10, Rubies = 0, Spins = 0, SkinId = "code_royal",  Desc = "Skin Rắn Hoàng Gia (+65% Xu, +1 KC) + 10 KC" },
	RANBONGTOI   = { Coins = 0,    Gems = 0,  Rubies = 0, Spins = 1, SkinId = "code_shadow", Desc = "Skin Rắn Bóng Tối (+100% Xu, +2 KC) + 1 Quay" },
	ADMINFULLVANGKCMGOCALL20112026 = {
		IsAdmin = true,
		MaxLevel = true,
		UnlockAllSkins = true,
		EquipSkin = "admin_supreme",
		Coins = 999999999, Gems = 999999, Rubies = 999999, Spins = 999,
		Desc = "ADMIN FULL: Max Lv.100, Full Skin + Thần Rắn Admin VIP, 999M Xu, 999K KC & HN!"
	},
}

-- 8 MOC QUA ONLINE THEO THOI GIAN (CHI TINH KHI DANG ONLINE TRONG GAME)
local ONLINE_REWARDS = {
	{ Id = "t1",  Secs = 60,   Label = "1 phút",  Desc = "200 Xu",                                           Coins = 200,  Gems = 0,  Rubies = 0, Spins = 0 },
	{ Id = "t3",  Secs = 180,  Label = "3 phút",  Desc = "10 Kim Cương",                                     Coins = 0,    Gems = 10, Rubies = 0, Spins = 0 },
	{ Id = "t5",  Secs = 300,  Label = "5 phút",  Desc = "450 Xu  +  1 Lượt quay",                           Coins = 450,  Gems = 0,  Rubies = 0, Spins = 1 },
	{ Id = "t10", Secs = 600,  Label = "10 phút", Desc = "20 Kim Cương",                                     Coins = 0,    Gems = 20, Rubies = 0, Spins = 0 },
	{ Id = "t15", Secs = 900,  Label = "15 phút", Desc = "900 Xu  +  1 Lượt quay",                           Coins = 900,  Gems = 0,  Rubies = 0, Spins = 1 },
	{ Id = "t25", Secs = 1500, Label = "25 phút", Desc = "35 Kim Cương  +  1 Hồng Ngọc",                     Coins = 0,    Gems = 35, Rubies = 1, Spins = 0 },
	{ Id = "t40", Secs = 2400, Label = "40 phút", Desc = "1,600 Xu  +  2 Lượt quay",                         Coins = 1600, Gems = 0,  Rubies = 0, Spins = 2 },
	{ Id = "t60", Secs = 3600, Label = "60 phút", Desc = "Skin Free: Hỏa Hoàng Hôn + 50 KC + 2 HN + 2 Quay", Coins = 0,    Gems = 50, Rubies = 2, Spins = 2, SkinId = "free_sunset", AltGems = 80 },
}

-- 7 NGAY DIEM DANH HANG NGAY (NGAY 7 TANG SKIN FREE DOC QUYEN NGOC LUC BAO)
local DAILY_REWARDS = {
	{ Day = 1, Desc = "500 Xu  +  1 Lượt quay",                              Coins = 500,  Gems = 0,   Rubies = 0, Spins = 1 },
	{ Day = 2, Desc = "25 Kim Cương  +  1 Lượt quay",                        Coins = 0,    Gems = 25,  Rubies = 0, Spins = 1 },
	{ Day = 3, Desc = "1,200 Xu  +  2 Lượt quay",                            Coins = 1200, Gems = 0,   Rubies = 0, Spins = 2 },
	{ Day = 4, Desc = "50 Kim Cương  +  1 Hồng Ngọc",                        Coins = 0,    Gems = 50,  Rubies = 1, Spins = 0 },
	{ Day = 5, Desc = "2,500 Xu  +  2 Lượt quay",                            Coins = 2500, Gems = 0,   Rubies = 0, Spins = 2 },
	{ Day = 6, Desc = "100 Kim Cương  +  2 Hồng Ngọc",                       Coins = 0,    Gems = 100, Rubies = 2, Spins = 0 },
	{ Day = 7, Desc = "Skin Free: Ngọc Lục Bảo + 120 KC + 4 HN + 3 Quay",    Coins = 3000, Gems = 120, Rubies = 4, Spins = 3, SkinId = "free_emerald", AltCoins = 10000 },
}

local FREE_SPIN_INTERVAL = 900 -- 15 phut = 900 giay
local FREE_SPIN_MAX = 15

-- 10 NHIEM VU CAN BANG (CO THUONG 1-5 HONG NGOC + LUOT QUAY)
local function createDefaultQuests()
	return {
		{ Id = "eat",       Title = "Ăn 20 quả bất kỳ",           Goal = 20,   Progress = 0, Reward = 400,  Currency = "Coins",  Spins = 1, Claimed = false },
		{ Id = "score",     Title = "Đạt 200 điểm trong 1 ván",   Goal = 200,  Progress = 0, Reward = 20,   Currency = "Gems",   Spins = 1, Claimed = false },
		{ Id = "power",     Title = "Nhặt 4 vật phẩm kỹ năng",    Goal = 4,    Progress = 0, Reward = 1,    Currency = "Rubies", Spins = 1, Claimed = false },
		{ Id = "games",     Title = "Chơi hoàn thành 3 ván",      Goal = 3,    Progress = 0, Reward = 700,  Currency = "Coins",  Spins = 1, Claimed = false },
		{ Id = "combo",     Title = "Đạt chuỗi Combo x4 trở lên", Goal = 1,    Progress = 0, Reward = 2,    Currency = "Rubies", Spins = 2, Claimed = false },
		{ Id = "coins_run", Title = "Thu thập tổng 600 Xu",       Goal = 600,  Progress = 0, Reward = 1000, Currency = "Coins",  Spins = 2, Claimed = false },
		{ Id = "score_pro", Title = "Đạt 500 điểm trong 1 ván",   Goal = 500,  Progress = 0, Reward = 3,    Currency = "Rubies", Spins = 2, Claimed = false },
		{ Id = "eat_pro",   Title = "Ăn tổng cộng 60 quả",        Goal = 60,   Progress = 0, Reward = 45,   Currency = "Gems",   Spins = 2, Claimed = false },
		{ Id = "score_god", Title = "Đạt 1,000 điểm trong 1 ván", Goal = 1000, Progress = 0, Reward = 4,    Currency = "Rubies", Spins = 3, Claimed = false },
		{ Id = "eat_god",   Title = "Ăn tổng cộng 120 quả",       Goal = 120,  Progress = 0, Reward = 5,    Currency = "Rubies", Spins = 3, Claimed = false },
	}
end

local function createDefaultState()
	return {
		Coins = 500,
		Gems = 20,
		Rubies = 0,
		Spins = 1,
		FreeSpins = 1,
		NextFreeSpinUnix = os.time() + FREE_SPIN_INTERVAL,
		OnlineSeconds = 0,
		ClaimedOnline = {},
		DailyDay = 0,
		LastDailyDate = "",
		GameMode = "Classic",
		Level = 1,
		Exp = 0,
		ExpNeed = 100,
		HighScore = 0,
		OwnedSkins = { classic_green = true },
		EquippedSkin = "classic_green",
		ClaimedLevels = {},
		UsedCodes = {},
		Settings = {
			WallPass = false,
			SpeedMode = 2,
			SmoothMove = true,
			ShowDpad = true,
			LeftHanded = false,
			FullScreen = false,
		},
		Quests = createDefaultQuests(),
	}
end

local state = createDefaultState()

-- ============================================================
-- LUU & TAI DU LIEU TU DONG NGAM (TUONG THICH SAVE CU)
-- ============================================================
local canWriteFile = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local UI = {}
local SEC = {}
local GFX = {}

local function getCacheRoot()
	if typeof(getgenv) == "function" then
		local ok, env = pcall(getgenv)
		if ok and type(env) == "table" then return env end
	end
	return _G
end

local function packSaveData()
	local questProgress = {}
	for _, q in ipairs(state.Quests) do
		questProgress[q.Id] = { Progress = q.Progress, Claimed = q.Claimed }
	end
	return {
		Coins = state.Coins,
		Gems = state.Gems,
		Rubies = state.Rubies,
		Spins = state.Spins,
		FreeSpins = state.FreeSpins,
		NextFreeSpinUnix = state.NextFreeSpinUnix,
		OnlineSeconds = math.floor(state.OnlineSeconds or 0),
		ClaimedOnline = state.ClaimedOnline,
		DailyDay = state.DailyDay or 0,
		LastDailyDate = state.LastDailyDate or "",
		GameMode = state.GameMode or "Classic",
		Level = state.Level,
		Exp = state.Exp,
		ExpNeed = state.ExpNeed,
		HighScore = state.HighScore,
		OwnedSkins = state.OwnedSkins,
		EquippedSkin = state.EquippedSkin,
		ClaimedLevels = state.ClaimedLevels,
		UsedCodes = state.UsedCodes,
		Settings = state.Settings,
		QuestProgress = questProgress,
	}
end

local function applyLoadedData(raw)
	if type(raw) ~= "table" then return end
	if type(raw.Coins) == "number" then state.Coins = raw.Coins end
	if type(raw.Gems) == "number" then state.Gems = raw.Gems end
	if type(raw.Rubies) == "number" then state.Rubies = math.max(0, raw.Rubies) end
	if type(raw.Spins) == "number" then state.Spins = math.max(0, raw.Spins) end
	if type(raw.FreeSpins) == "number" then state.FreeSpins = math.clamp(math.floor(raw.FreeSpins), 0, FREE_SPIN_MAX) end
	if type(raw.NextFreeSpinUnix) == "number" then state.NextFreeSpinUnix = raw.NextFreeSpinUnix end
	if type(raw.OnlineSeconds) == "number" then state.OnlineSeconds = math.max(0, raw.OnlineSeconds) end
	if type(raw.ClaimedOnline) == "table" then
		state.ClaimedOnline = {}
		for k, v in pairs(raw.ClaimedOnline) do
			if v == true then state.ClaimedOnline[tostring(k)] = true end
		end
	end
	if type(raw.DailyDay) == "number" then state.DailyDay = math.clamp(math.floor(raw.DailyDay), 0, 7) end
	if type(raw.LastDailyDate) == "string" then state.LastDailyDate = raw.LastDailyDate end
	if type(raw.GameMode) == "string" then state.GameMode = raw.GameMode end
	if type(raw.Level) == "number" then state.Level = math.clamp(math.floor(raw.Level), 1, MAX_LEVEL) end
	state.ExpNeed = expNeedForLevel(state.Level)
	if type(raw.Exp) == "number" then state.Exp = math.clamp(raw.Exp, 0, state.ExpNeed) end
	if type(raw.HighScore) == "number" then state.HighScore = math.max(0, raw.HighScore) end

	if type(raw.OwnedSkins) == "table" then
		state.OwnedSkins = { classic_green = true }
		for k, v in pairs(raw.OwnedSkins) do
			if v == true then state.OwnedSkins[k] = true end
		end
	end
	if type(raw.EquippedSkin) == "string" and state.OwnedSkins[raw.EquippedSkin] then
		state.EquippedSkin = raw.EquippedSkin
	end
	if type(raw.ClaimedLevels) == "table" then
		state.ClaimedLevels = {}
		for k, v in pairs(raw.ClaimedLevels) do
			if v == true then state.ClaimedLevels[tostring(k)] = true end
		end
	end
	if type(raw.UsedCodes) == "table" then
		state.UsedCodes = {}
		for k, v in pairs(raw.UsedCodes) do
			if v == true then state.UsedCodes[tostring(k)] = true end
		end
	end
	if type(raw.Settings) == "table" then
		if type(raw.Settings.WallPass) == "boolean" then state.Settings.WallPass = raw.Settings.WallPass end
		if type(raw.Settings.SpeedMode) == "number" then state.Settings.SpeedMode = math.clamp(raw.Settings.SpeedMode, 1, 3) end
		if type(raw.Settings.SmoothMove) == "boolean" then state.Settings.SmoothMove = raw.Settings.SmoothMove end
		if type(raw.Settings.ShowDpad) == "boolean" then state.Settings.ShowDpad = raw.Settings.ShowDpad end
		if type(raw.Settings.LeftHanded) == "boolean" then state.Settings.LeftHanded = raw.Settings.LeftHanded end
		if type(raw.Settings.FullScreen) == "boolean" then state.Settings.FullScreen = raw.Settings.FullScreen end
	end
	if type(raw.QuestProgress) == "table" then
		for _, q in ipairs(state.Quests) do
			local savedQ = raw.QuestProgress[q.Id]
			if type(savedQ) == "table" then
				if type(savedQ.Progress) == "number" then q.Progress = savedQ.Progress end
				if type(savedQ.Claimed) == "boolean" then q.Claimed = savedQ.Claimed end
			end
		end
	end
end

local function saveData()
	local payload = packSaveData()
	local okEnc, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
	if not okEnc then return false end
	local cache = getCacheRoot()
	cache["SnakeArcadePro_JSON_" .. tostring(player.UserId)] = encoded
	if canWriteFile then
		pcall(writefile, SAVE_FILE, encoded)
	end
	return true
end

local function loadData()
	local loadedJson = nil
	if canWriteFile then
		local hasFile = false
		if typeof(isfile) == "function" then
			local okCheck, exists = pcall(isfile, SAVE_FILE)
			hasFile = okCheck and exists
		else
			hasFile = true
		end
		if hasFile then
			local okRead, content = pcall(readfile, SAVE_FILE)
			if okRead and type(content) == "string" and #content > 2 then
				loadedJson = content
			end
		end
	end
	if not loadedJson then
		local cache = getCacheRoot()
		local mem = cache["SnakeArcadePro_JSON_" .. tostring(player.UserId)]
		if type(mem) == "string" and #mem > 2 then
			loadedJson = mem
		end
	end
	if loadedJson then
		local okDec, decoded = pcall(function() return HttpService:JSONDecode(loadedJson) end)
		if okDec and type(decoded) == "table" then
			applyLoadedData(decoded)
			return true
		end
	end
	return false
end

local hadSavedData = loadData()

-- ============================================================
-- HAM DUNG UI CARTOON ARCADE 3D & BIEU TUONG VECTOR (KHONG EMOJI)
-- ============================================================
local function addCorner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or THEME.Outline
	s.Thickness = thickness or 2
	pcall(function() s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	s.Parent = parent
	return s
end

local function addTextOutline(label, thickness, color)
	local s = Instance.new("UIStroke")
	s.Color = color or THEME.Outline
	s.Thickness = thickness or 1.8
	pcall(function() s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual end)
	s.Parent = label
	return s
end

local function addGradient(parent, topColor, botColor, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(topColor, botColor)
	g.Rotation = rot or 90
	g.Parent = parent
	return g
end

-- Xu vang vector
function GFX.makeCartoonCoin(parent, sizePx, pos, anchor, z)
	local coin = Instance.new("Frame")
	coin.Size = UDim2.fromOffset(sizePx, sizePx)
	coin.Position = pos or UDim2.fromScale(0.5, 0.5)
	coin.AnchorPoint = anchor or Vector2.new(0, 0.5)
	coin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	coin.BorderSizePixel = 0
	coin.ZIndex = z or 4
	coin.Parent = parent
	addCorner(coin, 99)
	addStroke(coin, THEME.Outline, math.max(1.5, sizePx * 0.1))
	addGradient(coin, Color3.fromRGB(230, 198, 52), Color3.fromRGB(204, 134, 18), 90)

	local inner = Instance.new("Frame")
	inner.Size = UDim2.fromScale(0.74, 0.74)
	inner.Position = UDim2.fromScale(0.5, 0.5)
	inner.AnchorPoint = Vector2.new(0.5, 0.5)
	inner.BackgroundColor3 = Color3.fromRGB(218, 162, 24)
	inner.BorderSizePixel = 0
	inner.ZIndex = (z or 4) + 1
	inner.Parent = coin
	addCorner(inner, 99)
	addStroke(inner, Color3.fromRGB(148, 86, 12), 1.1)

	local dollar = Instance.new("TextLabel")
	dollar.Size = UDim2.fromScale(1, 1)
	dollar.BackgroundTransparency = 1
	dollar.Text = "$"
	dollar.TextColor3 = Color3.fromRGB(228, 206, 94)
	dollar.Font = THEME.FontHead
	dollar.TextSize = math.max(9, math.floor(sizePx * 0.62))
	dollar.ZIndex = (z or 4) + 2
	dollar.Parent = inner
	addTextOutline(dollar, 1.2, Color3.fromRGB(110, 56, 10))
	return coin
end

-- Kim cuong xanh vector
function GFX.makeCartoonGem(parent, sizePx, pos, anchor, z)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromOffset(sizePx, sizePx)
	wrap.Position = pos or UDim2.fromScale(0.5, 0.5)
	wrap.AnchorPoint = anchor or Vector2.new(0, 0.5)
	wrap.BackgroundTransparency = 1
	wrap.ZIndex = z or 4
	wrap.Parent = parent

	local dia = Instance.new("Frame")
	dia.Size = UDim2.fromScale(0.68, 0.68)
	dia.Position = UDim2.fromScale(0.5, 0.5)
	dia.AnchorPoint = Vector2.new(0.5, 0.5)
	dia.Rotation = 45
	dia.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dia.BorderSizePixel = 0
	dia.ZIndex = (z or 4) + 1
	dia.Parent = wrap
	addCorner(dia, 3)
	addStroke(dia, THEME.Outline, math.max(1.5, sizePx * 0.09))
	addGradient(dia, Color3.fromRGB(118, 218, 238), Color3.fromRGB(42, 134, 214), 135)

	local facet = Instance.new("Frame")
	facet.Size = UDim2.fromScale(0.45, 0.45)
	facet.Position = UDim2.fromScale(0.28, 0.28)
	facet.BackgroundColor3 = Color3.fromRGB(218, 240, 248)
	facet.BackgroundTransparency = 0.45
	facet.BorderSizePixel = 0
	facet.ZIndex = (z or 4) + 2
	facet.Parent = dia
	addCorner(facet, 2)
	return wrap
end

-- Hong Ngoc tim vector (Ngoc tim quy hiem)
function GFX.makeCartoonRuby(parent, sizePx, pos, anchor, z)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromOffset(sizePx, sizePx)
	wrap.Position = pos or UDim2.fromScale(0.5, 0.5)
	wrap.AnchorPoint = anchor or Vector2.new(0, 0.5)
	wrap.BackgroundTransparency = 1
	wrap.ZIndex = z or 4
	wrap.Parent = parent

	local dia = Instance.new("Frame")
	dia.Size = UDim2.fromScale(0.7, 0.7)
	dia.Position = UDim2.fromScale(0.5, 0.5)
	dia.AnchorPoint = Vector2.new(0.5, 0.5)
	dia.Rotation = 45
	dia.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dia.BorderSizePixel = 0
	dia.ZIndex = (z or 4) + 1
	dia.Parent = wrap
	addCorner(dia, 3)
	addStroke(dia, THEME.Outline, math.max(1.5, sizePx * 0.09))
	addGradient(dia, Color3.fromRGB(232, 92, 238), Color3.fromRGB(118, 26, 206), 135)

	local facet = Instance.new("Frame")
	facet.Size = UDim2.fromScale(0.46, 0.46)
	facet.Position = UDim2.fromScale(0.27, 0.27)
	facet.BackgroundColor3 = Color3.fromRGB(244, 192, 248)
	facet.BackgroundTransparency = 0.4
	facet.BorderSizePixel = 0
	facet.ZIndex = (z or 4) + 2
	facet.Parent = dia
	addCorner(facet, 2)
	return wrap
end

-- Bieu tuong tien te tu dong theo loai ("Coins" / "Gems" / "Rubies")
function GFX.makeCurrencyIcon(parent, kind, sizePx, pos, anchor, z)
	if kind == "Gems" then
		return GFX.makeCartoonGem(parent, sizePx, pos, anchor, z)
	elseif kind == "Rubies" then
		return GFX.makeCartoonRuby(parent, sizePx, pos, anchor, z)
	end
	return GFX.makeCartoonCoin(parent, sizePx, pos, anchor, z)
end

function GFX.makeVectorCrown(parent, sizePx, pos, topCol, botCol, z)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromOffset(sizePx, sizePx)
	wrap.Position = pos or UDim2.fromScale(0.5, 0.5)
	wrap.AnchorPoint = Vector2.new(0.5, 0.5)
	wrap.BackgroundTransparency = 1
	wrap.ZIndex = z or 6
	wrap.Parent = parent

	local base = Instance.new("Frame")
	base.Size = UDim2.fromScale(0.86, 0.44)
	base.Position = UDim2.fromScale(0.07, 0.46)
	base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	base.BorderSizePixel = 0
	base.ZIndex = (z or 6) + 1
	base.Parent = wrap
	addCorner(base, 3)
	addStroke(base, THEME.Outline, 1.5)
	addGradient(base, topCol or Color3.fromRGB(228, 194, 52), botCol or Color3.fromRGB(186, 128, 18), 90)

	for _, xP in ipairs({ 0.1, 0.39, 0.68 }) do
		local tip = Instance.new("Frame")
		tip.Size = UDim2.fromScale(0.22, 0.34)
		tip.Position = UDim2.fromScale(xP, (xP == 0.39) and 0.14 or 0.24)
		tip.BackgroundColor3 = topCol or Color3.fromRGB(228, 194, 52)
		tip.BorderSizePixel = 0
		tip.ZIndex = z or 6
		tip.Parent = wrap
		addCorner(tip, 3)
		addStroke(tip, THEME.Outline, 1.4)
	end
	return wrap
end

function GFX.makeCartoonFruit(parent, sizePx, pos, data)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromOffset(sizePx, sizePx)
	wrap.Position = pos or UDim2.fromScale(0.5, 0.5)
	wrap.AnchorPoint = Vector2.new(0.5, 0.5)
	wrap.BackgroundTransparency = 1
	wrap.ZIndex = 3
	wrap.Parent = parent

	local body = Instance.new("Frame")
	body.Size = UDim2.fromScale(0.82, 0.78)
	body.Position = UDim2.fromScale(0.5, 0.58)
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	body.BorderSizePixel = 0
	body.ZIndex = 3
	body.Parent = wrap
	addCorner(body, 99)
	addStroke(body, THEME.Outline, 1.8)
	addGradient(body, data.Top, data.Bot, 90)

	local shine = Instance.new("Frame")
	shine.Size = UDim2.fromScale(0.28, 0.22)
	shine.Position = UDim2.fromScale(0.18, 0.16)
	shine.Rotation = -22
	shine.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
	shine.BackgroundTransparency = 0.35
	shine.BorderSizePixel = 0
	shine.ZIndex = 4
	shine.Parent = body
	addCorner(shine, 99)

	local leaf = Instance.new("Frame")
	leaf.Size = UDim2.fromScale(0.36, 0.22)
	leaf.Position = UDim2.fromScale(0.52, 0.06)
	leaf.Rotation = -26
	leaf.BackgroundColor3 = data.Leaf or Color3.fromRGB(68, 194, 62)
	leaf.BorderSizePixel = 0
	leaf.ZIndex = 5
	leaf.Parent = wrap
	addCorner(leaf, 99)
	addStroke(leaf, THEME.Outline, 1.4)
	return wrap
end

-- Vat pham bo tro tren ban choi: huy hieu phat sang + icon sac net (chi trong phan choi)
function GFX.makePowerupGraphic(parent, sizePx, pos, data)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromOffset(sizePx, sizePx)
	wrap.Position = pos or UDim2.fromScale(0.5, 0.5)
	wrap.AnchorPoint = Vector2.new(0.5, 0.5)
	wrap.BackgroundColor3 = data.Color
	wrap.BackgroundTransparency = 0.55
	wrap.BorderSizePixel = 0
	wrap.ZIndex = 3
	wrap.Parent = parent
	addCorner(wrap, 99)
	addStroke(wrap, data.Color, 1.8)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromScale(0.92, 0.92)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.BackgroundTransparency = 1
	icon.Text = data.Icon or "*"
	icon.TextScaled = true
	icon.Font = THEME.FontHead
	icon.ZIndex = 4
	icon.Parent = wrap
	return wrap
end

local function makeArcadeBtn(parent, text, size, pos, topColor, botColor, cornerRadius, opts)
	opts = opts or {}
	local r = cornerRadius or 12
	local depth = opts.Depth or 3

	local btn = Instance.new("TextButton")
	btn.Size = size
	btn.Position = pos or UDim2.new()
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = opts.ZIndex or 4
	btn.Parent = parent

	local shadow = Instance.new("Frame")
	shadow.Size = UDim2.new(1, 0, 1, -depth)
	shadow.Position = UDim2.fromOffset(0, depth)
	shadow.BackgroundColor3 = THEME.Outline
	shadow.BorderSizePixel = 0
	shadow.ZIndex = btn.ZIndex
	shadow.Parent = btn
	addCorner(shadow, r)

	local face = Instance.new("Frame")
	face.Name = "Face"
	face.Size = UDim2.new(1, 0, 1, -depth)
	face.Position = UDim2.fromOffset(0, 0)
	face.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	face.BorderSizePixel = 0
	face.ClipsDescendants = true
	face.ZIndex = btn.ZIndex + 1
	face.Parent = btn
	addCorner(face, r)
	local faceStroke = addStroke(face, THEME.Outline, opts.Stroke or 2.2)
	addGradient(face, topColor, botColor or topColor, 90)

	local gloss = Instance.new("Frame")
	gloss.Size = UDim2.new(0.88, 0, 0.34, 0)
	gloss.Position = UDim2.new(0.06, 0, 0.06, 0)
	gloss.BackgroundColor3 = Color3.fromRGB(235, 240, 248)
	gloss.BackgroundTransparency = 0.78
	gloss.BorderSizePixel = 0
	gloss.ZIndex = btn.ZIndex + 2
	gloss.Parent = face
	addCorner(gloss, math.max(4, r - 3))

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = opts.LabelSize or UDim2.fromScale(1, 1)
	label.Position = opts.LabelPos or UDim2.new()
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = opts.TextColor or THEME.TextMain
	label.Font = THEME.FontHead
	label.TextSize = opts.TextSize or 13
	label.TextXAlignment = opts.TextAlign or Enum.TextXAlignment.Center
	label.ZIndex = btn.ZIndex + 4
	label.Parent = face
	addTextOutline(label, opts.TextStroke or 1.8, THEME.Outline)

	btn.MouseButton1Down:Connect(function()
		face.Position = UDim2.fromOffset(0, math.max(1, depth - 1))
	end)
	local function release()
		face.Position = UDim2.fromOffset(0, 0)
	end
	btn.MouseButton1Up:Connect(release)
	btn.MouseLeave:Connect(release)

	return btn, label, face, faceStroke
end

-- Bo 6 bieu tuong vector cho thanh nut duoi (Shop, Vong Quay, Qua Tang, Nhiem Vu, Cai Dat, Thoat)
function GFX.buildShopIcon(parent, z)
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(30, 26)
	box.Position = UDim2.new(0.5, -15, 0, 6)
	box.BackgroundTransparency = 1
	box.ZIndex = z
	box.Parent = parent

	local base = Instance.new("Frame")
	base.Size = UDim2.fromOffset(24, 13)
	base.Position = UDim2.fromOffset(3, 11)
	base.BackgroundColor3 = Color3.fromRGB(218, 212, 206)
	base.BorderSizePixel = 0
	base.ZIndex = z
	base.Parent = box
	addCorner(base, 3)
	addStroke(base, THEME.Outline, 1.6)

	local door = Instance.new("Frame")
	door.Size = UDim2.fromOffset(8, 9)
	door.Position = UDim2.fromOffset(8, 4)
	door.BackgroundColor3 = Color3.fromRGB(74, 162, 214)
	door.BorderSizePixel = 0
	door.ZIndex = z + 1
	door.Parent = base
	addCorner(door, 2)

	local roof = Instance.new("Frame")
	roof.Size = UDim2.fromOffset(28, 10)
	roof.Position = UDim2.fromOffset(1, 3)
	roof.BackgroundColor3 = Color3.fromRGB(212, 46, 52)
	roof.BorderSizePixel = 0
	roof.ClipsDescendants = true
	roof.ZIndex = z + 2
	roof.Parent = box
	addCorner(roof, 4)
	addStroke(roof, THEME.Outline, 1.6)

	for i = 0, 3 do
		local stripe = Instance.new("Frame")
		stripe.Size = UDim2.fromOffset(4, 10)
		stripe.Position = UDim2.fromOffset(3 + i * 7, 0)
		stripe.BackgroundColor3 = Color3.fromRGB(224, 224, 230)
		stripe.BorderSizePixel = 0
		stripe.ZIndex = z + 3
		stripe.Parent = roof
	end
end

function GFX.buildWheelIcon(parent, z)
	local rim = Instance.new("Frame")
	rim.Size = UDim2.fromOffset(28, 28)
	rim.Position = UDim2.new(0.5, -14, 0, 5)
	rim.BackgroundColor3 = Color3.fromRGB(226, 186, 46)
	rim.BorderSizePixel = 0
	rim.ZIndex = z
	rim.Parent = parent
	addCorner(rim, 99)
	addStroke(rim, THEME.Outline, 1.8)

	local disc = Instance.new("Frame")
	disc.Size = UDim2.fromOffset(20, 20)
	disc.Position = UDim2.fromScale(0.5, 0.5)
	disc.AnchorPoint = Vector2.new(0.5, 0.5)
	disc.BackgroundColor3 = Color3.fromRGB(168, 72, 218)
	disc.BorderSizePixel = 0
	disc.ClipsDescendants = true
	disc.ZIndex = z + 1
	disc.Parent = rim
	addCorner(disc, 99)
	addStroke(disc, THEME.Outline, 1.2)

	local q1 = Instance.new("Frame")
	q1.Size = UDim2.fromScale(0.5, 0.5)
	q1.BackgroundColor3 = Color3.fromRGB(58, 174, 224)
	q1.BorderSizePixel = 0
	q1.ZIndex = z + 1
	q1.Parent = disc

	local q2 = Instance.new("Frame")
	q2.Size = UDim2.fromScale(0.5, 0.5)
	q2.Position = UDim2.fromScale(0.5, 0.5)
	q2.BackgroundColor3 = Color3.fromRGB(224, 92, 162)
	q2.BorderSizePixel = 0
	q2.ZIndex = z + 1
	q2.Parent = disc

	local hub = Instance.new("Frame")
	hub.Size = UDim2.fromOffset(8, 8)
	hub.Position = UDim2.fromScale(0.5, 0.5)
	hub.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.BackgroundColor3 = Color3.fromRGB(230, 198, 56)
	hub.BorderSizePixel = 0
	hub.ZIndex = z + 2
	hub.Parent = rim
	addCorner(hub, 99)
	addStroke(hub, THEME.Outline, 1.2)

	local pin = Instance.new("Frame")
	pin.Size = UDim2.fromOffset(7, 7)
	pin.Position = UDim2.new(0.5, -3, 0, -3)
	pin.Rotation = 45
	pin.BackgroundColor3 = Color3.fromRGB(216, 48, 52)
	pin.BorderSizePixel = 0
	pin.ZIndex = z + 3
	pin.Parent = rim
	addStroke(pin, THEME.Outline, 1.1)
end

function GFX.buildGiftIcon(parent, z)
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(26, 26)
	box.Position = UDim2.new(0.5, -13, 0, 6)
	box.BackgroundTransparency = 1
	box.ZIndex = z
	box.Parent = parent

	local body = Instance.new("Frame")
	body.Size = UDim2.fromOffset(20, 16)
	body.Position = UDim2.fromOffset(3, 8)
	body.BackgroundColor3 = Color3.fromRGB(220, 178, 72)
	body.BorderSizePixel = 0
	body.ZIndex = z
	body.Parent = box
	addCorner(body, 4)
	addStroke(body, THEME.Outline, 1.6)

	local lid = Instance.new("Frame")
	lid.Size = UDim2.fromOffset(24, 7)
	lid.Position = UDim2.fromOffset(1, 5)
	lid.BackgroundColor3 = Color3.fromRGB(224, 192, 92)
	lid.BorderSizePixel = 0
	lid.ZIndex = z + 1
	lid.Parent = box
	addCorner(lid, 3)
	addStroke(lid, THEME.Outline, 1.5)

	local ribV = Instance.new("Frame")
	ribV.Size = UDim2.fromOffset(5, 19)
	ribV.Position = UDim2.fromOffset(10, 5)
	ribV.BackgroundColor3 = Color3.fromRGB(214, 58, 78)
	ribV.BorderSizePixel = 0
	ribV.ZIndex = z + 2
	ribV.Parent = box

	for _, xBow in ipairs({ 5, 13 }) do
		local bow = Instance.new("Frame")
		bow.Size = UDim2.fromOffset(8, 6)
		bow.Position = UDim2.fromOffset(xBow, 1)
		bow.BackgroundColor3 = Color3.fromRGB(218, 64, 86)
		bow.BorderSizePixel = 0
		bow.ZIndex = z + 3
		bow.Parent = box
		addCorner(bow, 99)
		addStroke(bow, THEME.Outline, 1.3)
	end
end

function GFX.buildChestIcon(parent, z)
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(28, 22)
	box.Position = UDim2.new(0.5, -14, 0, 8)
	box.BackgroundColor3 = Color3.fromRGB(154, 74, 34)
	box.BorderSizePixel = 0
	box.ZIndex = z
	box.Parent = parent
	addCorner(box, 5)
	addStroke(box, THEME.Outline, 1.7)

	local band = Instance.new("Frame")
	band.Size = UDim2.new(1, 0, 0, 4)
	band.Position = UDim2.fromOffset(0, 8)
	band.BackgroundColor3 = Color3.fromRGB(218, 178, 46)
	band.BorderSizePixel = 0
	band.ZIndex = z + 1
	band.Parent = box

	local lock = Instance.new("Frame")
	lock.Size = UDim2.fromOffset(7, 8)
	lock.Position = UDim2.fromOffset(10, 7)
	lock.BackgroundColor3 = Color3.fromRGB(224, 192, 62)
	lock.BorderSizePixel = 0
	lock.ZIndex = z + 2
	lock.Parent = box
	addCorner(lock, 2)
	addStroke(lock, THEME.Outline, 1.3)
end

function GFX.buildGearIcon(parent, z)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromOffset(24, 24)
	wrap.Position = UDim2.new(0.5, -12, 0, 7)
	wrap.BackgroundTransparency = 1
	wrap.ZIndex = z
	wrap.Parent = parent

	for _, rot in ipairs({ 0, 45 }) do
		local teeth = Instance.new("Frame")
		teeth.Size = UDim2.fromOffset(18, 18)
		teeth.Position = UDim2.fromScale(0.5, 0.5)
		teeth.AnchorPoint = Vector2.new(0.5, 0.5)
		teeth.Rotation = rot
		teeth.BackgroundColor3 = Color3.fromRGB(204, 214, 228)
		teeth.BorderSizePixel = 0
		teeth.ZIndex = z
		teeth.Parent = wrap
		addCorner(teeth, 4)
		addStroke(teeth, THEME.Outline, 1.6)
	end

	local ring = Instance.new("Frame")
	ring.Size = UDim2.fromOffset(18, 18)
	ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.BackgroundColor3 = Color3.fromRGB(210, 218, 230)
	ring.BorderSizePixel = 0
	ring.ZIndex = z + 1
	ring.Parent = wrap
	addCorner(ring, 99)

	local hole = Instance.new("Frame")
	hole.Size = UDim2.fromOffset(8, 8)
	hole.Position = UDim2.fromScale(0.5, 0.5)
	hole.AnchorPoint = Vector2.new(0.5, 0.5)
	hole.BackgroundColor3 = Color3.fromRGB(110, 48, 186)
	hole.BorderSizePixel = 0
	hole.ZIndex = z + 2
	hole.Parent = ring
	addCorner(hole, 99)
	addStroke(hole, THEME.Outline, 1.4)
end

function GFX.buildExitDoorIcon(parent, z)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.fromOffset(28, 24)
	wrap.Position = UDim2.new(0.5, -14, 0, 7)
	wrap.BackgroundTransparency = 1
	wrap.ZIndex = z
	wrap.Parent = parent

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(16, 20)
	frame.Position = UDim2.fromOffset(1, 2)
	frame.BackgroundColor3 = Color3.fromRGB(36, 134, 48)
	frame.BorderSizePixel = 0
	frame.ZIndex = z
	frame.Parent = wrap
	addCorner(frame, 3)
	addStroke(frame, THEME.Outline, 1.6)

	local door = Instance.new("Frame")
	door.Size = UDim2.fromOffset(10, 18)
	door.Position = UDim2.fromOffset(2, 3)
	door.BackgroundColor3 = Color3.fromRGB(216, 222, 232)
	door.BorderSizePixel = 0
	door.ZIndex = z + 1
	door.Parent = wrap
	addCorner(door, 2)
	addStroke(door, THEME.Outline, 1.4)

	local shaft = Instance.new("Frame")
	shaft.Size = UDim2.fromOffset(10, 5)
	shaft.Position = UDim2.fromOffset(12, 10)
	shaft.BackgroundColor3 = THEME.TextMain
	shaft.BorderSizePixel = 0
	shaft.ZIndex = z + 2
	shaft.Parent = wrap
	addCorner(shaft, 2)
	addStroke(shaft, THEME.Outline, 1.4)

	local tip = Instance.new("Frame")
	tip.Size = UDim2.fromOffset(8, 8)
	tip.Position = UDim2.fromOffset(17, 8)
	tip.Rotation = 45
	tip.BackgroundColor3 = THEME.TextMain
	tip.BorderSizePixel = 0
	tip.ZIndex = z + 2
	tip.Parent = wrap
	addCorner(tip, 2)
	addStroke(tip, THEME.Outline, 1.4)
end

local function makeNotifDot(parent, z)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(12, 12)
	dot.Position = UDim2.new(1, -13, 0, 2)
	dot.BackgroundColor3 = Color3.fromRGB(216, 54, 58)
	dot.BorderSizePixel = 0
	dot.Visible = false
	dot.ZIndex = z or 12
	dot.Parent = parent
	addCorner(dot, 99)
	addStroke(dot, THEME.TextMain, 1.4)
	return dot
end

local function makeDraggable(handle, target, onMovedFlag)
	local dragging, dragStart, startPos
	track(handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			if onMovedFlag then onMovedFlag(false) end
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if onMovedFlag and delta.Magnitude > 6 then onMovedFlag(true) end
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end))
end

local function getSegmentColor(skin, idx)
	if skin.Body3 then
		local m = idx % 3
		if m == 1 then return skin.Body1
		elseif m == 2 then return skin.Body2
		else return skin.Body3 end
	end
	return (idx % 2 == 0) and skin.Body1 or skin.Body2
end

function GFX.buildCartoonHead(parent, sizePx, skin)
	local head = Instance.new("Frame")
	head.Size = UDim2.fromOffset(sizePx, sizePx)
	head.AnchorPoint = Vector2.new(0.5, 0.5)
	head.BackgroundColor3 = skin.HeadColor
	head.BackgroundTransparency = skin.BodyAlpha or 0
	head.BorderSizePixel = 0
	head.ZIndex = 6
	head.Parent = parent
	addCorner(head, math.floor(sizePx * 0.48))
	addStroke(head, skin.GlowColor or THEME.Outline, math.max(1.8, sizePx * 0.075))

	local shine = Instance.new("Frame")
	shine.Size = UDim2.fromScale(0.4, 0.2)
	shine.Position = UDim2.fromScale(0.16, 0.12)
	shine.BackgroundColor3 = Color3.fromRGB(224, 228, 234)
	shine.BackgroundTransparency = 0.68
	shine.BorderSizePixel = 0
	shine.ZIndex = 7
	shine.Parent = head
	addCorner(shine, 99)

	local tongue = Instance.new("Frame")
	tongue.Size = UDim2.fromScale(0.36, 0.16)
	tongue.Position = UDim2.fromScale(0.92, 0.42)
	tongue.BackgroundColor3 = Color3.fromRGB(210, 52, 62)
	tongue.BorderSizePixel = 0
	tongue.ZIndex = 5
	tongue.Parent = head
	addCorner(tongue, 4)
	addStroke(tongue, THEME.Outline, 1.2)

	local st = skin.Style
	if st == "Panda" or st == "Kitty" then
		local earColor = (st == "Panda") and Color3.fromRGB(26, 28, 36) or Color3.fromRGB(220, 198, 210)
		for _, yE in ipairs({ -0.06, 0.72 }) do
			local ear = Instance.new("Frame")
			ear.Size = UDim2.fromScale(0.34, 0.34)
			ear.Position = UDim2.fromScale(0.06, yE)
			ear.BackgroundColor3 = earColor
			ear.BorderSizePixel = 0
			ear.ZIndex = 5
			ear.Parent = head
			addCorner(ear, (st == "Panda") and 99 or 6)
			addStroke(ear, THEME.Outline, 1.3)
		end
		if st == "Kitty" then
			local bow = Instance.new("Frame")
			bow.Size = UDim2.fromScale(0.28, 0.38)
			bow.Position = UDim2.fromScale(-0.08, 0.31)
			bow.BackgroundColor3 = Color3.fromRGB(218, 76, 146)
			bow.BorderSizePixel = 0
			bow.ZIndex = 10
			bow.Parent = head
			addCorner(bow, 99)
			addStroke(bow, THEME.Outline, 1.2)
		end
	elseif st == "Crown" then
		local cr = GFX.makeVectorCrown(head, math.max(12, math.floor(sizePx * 0.52)), UDim2.fromScale(0.05, 0.5), nil, nil, 11)
		cr.Rotation = -90
	elseif st == "Ice" then
		for _, yI in ipairs({ 0.08, 0.64 }) do
			local spike = Instance.new("Frame")
			spike.Size = UDim2.fromScale(0.28, 0.28)
			spike.Position = UDim2.fromScale(-0.1, yI)
			spike.Rotation = 45
			spike.BackgroundColor3 = Color3.fromRGB(168, 224, 240)
			spike.BorderSizePixel = 0
			spike.ZIndex = 10
			spike.Parent = head
			addCorner(spike, 3)
			addStroke(spike, THEME.Outline, 1.1)
		end
	elseif st == "Flame" then
		for _, yF in ipairs({ 0.1, 0.38, 0.66 }) do
			local fl = Instance.new("Frame")
			fl.Size = UDim2.fromScale(0.34, 0.24)
			fl.Position = UDim2.fromScale(-0.18, yF)
			fl.BackgroundColor3 = Color3.fromRGB(218, 116, 32)
			fl.BorderSizePixel = 0
			fl.ZIndex = 10
			fl.Parent = head
			addCorner(fl, 99)
		end
	elseif st == "Headphones" then
		for _, yH in ipairs({ -0.1, 0.78 }) do
			local cup = Instance.new("Frame")
			cup.Size = UDim2.fromScale(0.32, 0.32)
			cup.Position = UDim2.fromScale(0.18, yH)
			cup.BackgroundColor3 = Color3.fromRGB(34, 38, 52)
			cup.BorderSizePixel = 0
			cup.ZIndex = 10
			cup.Parent = head
			addCorner(cup, 99)
			addStroke(cup, Color3.fromRGB(86, 198, 218), 1.4)
		end
	elseif st == "Star" then
		local stDot = Instance.new("Frame")
		stDot.Size = UDim2.fromScale(0.3, 0.3)
		stDot.Position = UDim2.fromScale(0.1, 0.35)
		stDot.Rotation = 45
		stDot.BackgroundColor3 = Color3.fromRGB(142, 212, 232)
		stDot.BorderSizePixel = 0
		stDot.ZIndex = 10
		stDot.Parent = head
		addCorner(stDot, 3)
	elseif st == "Koi" then
		for _, yF in ipairs({ -0.14, 0.84 }) do
			local fin = Instance.new("Frame")
			fin.Size = UDim2.fromScale(0.36, 0.28)
			fin.Position = UDim2.fromScale(0.16, yF)
			fin.BackgroundColor3 = Color3.fromRGB(214, 112, 46)
			fin.BorderSizePixel = 0
			fin.ZIndex = 5
			fin.Parent = head
			addCorner(fin, 99)
			addStroke(fin, Color3.fromRGB(140, 56, 24), 1.1)
		end
	elseif st == "Devil" or st == "DarkHorn" or st == "Antlers" then
		local hColor = (st == "Devil") and Color3.fromRGB(178, 26, 36)
			or (st == "DarkHorn" and Color3.fromRGB(92, 32, 158) or Color3.fromRGB(158, 114, 66))
		for _, yH in ipairs({ -0.08, 0.78 }) do
			local horn = Instance.new("Frame")
			horn.Size = UDim2.fromScale(0.34, 0.26)
			horn.Position = UDim2.fromScale(-0.04, yH)
			horn.BackgroundColor3 = hColor
			horn.BorderSizePixel = 0
			horn.ZIndex = 5
			horn.Parent = head
			addCorner(horn, 6)
			addStroke(horn, THEME.Outline, 1.2)
		end
	elseif st == "Unicorn" then
		local uHorn = Instance.new("Frame")
		uHorn.Size = UDim2.fromScale(0.46, 0.2)
		uHorn.Position = UDim2.fromScale(-0.24, 0.4)
		uHorn.BackgroundColor3 = Color3.fromRGB(210, 210, 220)
		uHorn.BorderSizePixel = 0
		uHorn.ZIndex = 10
		uHorn.Parent = head
		addCorner(uHorn, 5)
		addStroke(uHorn, Color3.fromRGB(88, 32, 132), 1.1)
		addGradient(uHorn, Color3.fromRGB(82, 178, 214), Color3.fromRGB(208, 108, 166), 0)
	elseif st == "Pumpkin" then
		local stem = Instance.new("Frame")
		stem.Size = UDim2.fromScale(0.28, 0.22)
		stem.Position = UDim2.fromScale(-0.18, 0.39)
		stem.BackgroundColor3 = Color3.fromRGB(40, 148, 56)
		stem.BorderSizePixel = 0
		stem.ZIndex = 10
		stem.Parent = head
		addCorner(stem, 4)
		addStroke(stem, THEME.Outline, 1.1)
	elseif st == "SecretMagma" then
		local mark = Instance.new("Frame")
		mark.Size = UDim2.fromScale(0.32, 0.42)
		mark.Position = UDim2.fromScale(0.14, 0.29)
		mark.Rotation = 45
		mark.BackgroundColor3 = Color3.fromRGB(224, 48, 38)
		mark.BorderSizePixel = 0
		mark.ZIndex = 10
		mark.Parent = head
		addCorner(mark, 4)
	elseif st == "SecretCrystal" then
		for _, yC in ipairs({ -0.1, 0.36, 0.8 }) do
			local cry = Instance.new("Frame")
			cry.Size = UDim2.fromScale(0.3, 0.28)
			cry.Position = UDim2.fromScale(-0.1, yC)
			cry.Rotation = 45
			cry.BackgroundColor3 = Color3.fromRGB(192, 74, 236)
			cry.BorderSizePixel = 0
			cry.ZIndex = 10
			cry.Parent = head
			addCorner(cry, 3)
			addStroke(cry, THEME.Outline, 1.2)
		end
	elseif st == "SecretBat" then
		for _, yB in ipairs({ -0.22, 0.84 }) do
			local wing = Instance.new("Frame")
			wing.Size = UDim2.fromScale(0.44, 0.36)
			wing.Position = UDim2.fromScale(0.06, yB)
			wing.BackgroundColor3 = Color3.fromRGB(48, 34, 68)
			wing.BorderSizePixel = 0
			wing.ZIndex = 5
			wing.Parent = head
			addCorner(wing, 6)
			addStroke(wing, Color3.fromRGB(154, 68, 218), 1.3)
		end
	elseif st == "SecretWitch" then
		local brim = Instance.new("Frame")
		brim.Size = UDim2.fromScale(0.24, 0.96)
		brim.Position = UDim2.fromScale(-0.1, 0.02)
		brim.BackgroundColor3 = Color3.fromRGB(122, 42, 186)
		brim.BorderSizePixel = 0
		brim.ZIndex = 10
		brim.Parent = head
		addCorner(brim, 6)
		addStroke(brim, Color3.fromRGB(214, 174, 46), 1.3)
	elseif st == "SecretShades" then
		local glass = Instance.new("Frame")
		glass.Size = UDim2.fromScale(0.26, 0.82)
		glass.Position = UDim2.fromScale(0.54, 0.09)
		glass.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
		glass.BorderSizePixel = 0
		glass.ZIndex = 11
		glass.Parent = head
		addCorner(glass, 3)
		addStroke(glass, Color3.fromRGB(218, 222, 232), 1.2)
	elseif st == "Cyber" then
		local visor = Instance.new("Frame")
		visor.Size = UDim2.fromScale(0.24, 0.76)
		visor.Position = UDim2.fromScale(0.56, 0.12)
		visor.BackgroundColor3 = Color3.fromRGB(56, 194, 206)
		visor.BackgroundTransparency = 0.25
		visor.BorderSizePixel = 0
		visor.ZIndex = 10
		visor.Parent = head
		addCorner(visor, 4)
		addStroke(visor, Color3.fromRGB(196, 62, 146), 1.1)
	elseif st == "Samurai" then
		local crest = Instance.new("Frame")
		crest.Size = UDim2.fromScale(0.22, 0.86)
		crest.Position = UDim2.fromScale(-0.14, 0.07)
		crest.BackgroundColor3 = Color3.fromRGB(208, 174, 52)
		crest.BorderSizePixel = 0
		crest.ZIndex = 10
		crest.Parent = head
		addCorner(crest, 6)
		addStroke(crest, Color3.fromRGB(108, 72, 18), 1.2)
	elseif st == "Angel" or st == "Phoenix" then
		local isPhx = (st == "Phoenix")
		if not isPhx then
			local halo = Instance.new("Frame")
			halo.Size = UDim2.fromScale(0.22, 0.62)
			halo.Position = UDim2.fromScale(-0.22, 0.19)
			halo.BackgroundTransparency = 1
			halo.ZIndex = 11
			halo.Parent = head
			addCorner(halo, 99)
			addStroke(halo, Color3.fromRGB(208, 176, 48), 2)
		else
			local crest = Instance.new("Frame")
			crest.Size = UDim2.fromScale(0.4, 0.28)
			crest.Position = UDim2.fromScale(-0.22, 0.36)
			crest.BackgroundColor3 = Color3.fromRGB(214, 152, 36)
			crest.BorderSizePixel = 0
			crest.ZIndex = 10
			crest.Parent = head
			addCorner(crest, 99)
		end
		for _, yW in ipairs({ -0.22, 0.88 }) do
			local wing = Instance.new("Frame")
			wing.Size = UDim2.fromScale(0.42, 0.32)
			wing.Position = UDim2.fromScale(0.08, yW)
			wing.BackgroundColor3 = isPhx and Color3.fromRGB(214, 126, 36) or Color3.fromRGB(214, 216, 222)
			wing.BorderSizePixel = 0
			wing.ZIndex = 5
			wing.Parent = head
			addCorner(wing, 99)
			addStroke(wing, isPhx and Color3.fromRGB(186, 56, 28) or Color3.fromRGB(204, 174, 52), 1.3)
		end
	elseif st == "Cosmic" or st == "Void" then
		local orbit = Instance.new("Frame")
		orbit.Size = UDim2.fromScale(1.42, 0.42)
		orbit.Position = UDim2.fromScale(0.5, 0.5)
		orbit.AnchorPoint = Vector2.new(0.5, 0.5)
		orbit.Rotation = (st == "Void") and 28 or -28
		orbit.BackgroundTransparency = 1
		orbit.ZIndex = 11
		orbit.Parent = head
		addCorner(orbit, 99)
		addStroke(orbit, (st == "Void") and Color3.fromRGB(162, 82, 212) or Color3.fromRGB(208, 176, 50), 1.8)
	end

	for idxEye, yPos in ipairs({ 0.14, 0.54 }) do
		if st == "Panda" then
			local patch = Instance.new("Frame")
			patch.Size = UDim2.fromScale(0.44, 0.42)
			patch.Position = UDim2.fromScale(0.43, yPos - 0.04)
			patch.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
			patch.BorderSizePixel = 0
			patch.ZIndex = 7
			patch.Parent = head
			addCorner(patch, 99)
		end

		local eyeWhite = Instance.new("Frame")
		eyeWhite.Size = UDim2.fromScale(0.32, 0.32)
		eyeWhite.Position = UDim2.fromScale(0.49, yPos)
		eyeWhite.BackgroundColor3 = (st == "Skull" or st == "Pumpkin" or st == "Void") and Color3.fromRGB(22, 18, 28) or Color3.fromRGB(222, 224, 230)
		eyeWhite.BorderSizePixel = 0
		eyeWhite.ZIndex = 8
		eyeWhite.Parent = head
		addCorner(eyeWhite, 99)
		addStroke(eyeWhite, THEME.Outline, 1.1)

		local pupilColor = skin.EyeColor or Color3.fromRGB(22, 18, 28)
		if st == "Zombie" then
			pupilColor = (idxEye == 1) and Color3.fromRGB(204, 52, 54) or Color3.fromRGB(208, 178, 52)
		end

		local pupil = Instance.new("Frame")
		pupil.Size = UDim2.fromScale(0.6, 0.6)
		pupil.Position = UDim2.fromScale(0.28, 0.2)
		pupil.BackgroundColor3 = pupilColor
		pupil.BorderSizePixel = 0
		pupil.ZIndex = 9
		pupil.Parent = eyeWhite
		addCorner(pupil, 99)

		local glint = Instance.new("Frame")
		glint.Size = UDim2.fromScale(0.32, 0.32)
		glint.Position = UDim2.fromScale(0.16, 0.14)
		glint.BackgroundColor3 = Color3.fromRGB(224, 228, 234)
		glint.BorderSizePixel = 0
		glint.ZIndex = 10
		glint.Parent = pupil
		addCorner(glint, 99)
	end
	return head
end

-- ============================================================
-- CUA SO CHINH LON HON (720x460) + CHE DO FULL MAN HINH
-- ============================================================
local BASE_W, BASE_H = 720, 460

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2147483647
pcall(function() screenGui.ScreenInsets = Enum.ScreenInsets.None end)
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local floatBtn, _, floatFace = makeArcadeBtn(
	screenGui, "",
	UDim2.fromOffset(52, 54),
	UDim2.new(0, 16, 0.5, -27),
	Color3.fromRGB(66, 202, 78), Color3.fromRGB(28, 146, 52), 26,
	{ Stroke = 2.6, Depth = 4 }
)
floatBtn.Visible = false
function SEC.run1()
	local mini = GFX.buildCartoonHead(floatFace, 30, { HeadColor = Color3.fromRGB(72, 210, 68), Style = "Crown" })
	mini.Position = UDim2.fromScale(0.5, 0.5)
	mini.ZIndex = 8
	for _, d in ipairs(mini:GetDescendants()) do
		if d:IsA("GuiObject") then d.ZIndex += 4 end
	end
end
SEC.run1()
local floatDragged = false
makeDraggable(floatBtn, floatBtn, function(v) floatDragged = v end)

-- Nen tran vien toan man hinh khi bat che do FullScreen (che kin 100% man hinh dien thoai)
local fullBackdrop = Instance.new("Frame")
fullBackdrop.Size = UDim2.fromScale(1, 1)
fullBackdrop.Position = UDim2.fromScale(0, 0)
fullBackdrop.BackgroundColor3 = Color3.fromRGB(14, 16, 30)
fullBackdrop.BorderSizePixel = 0
fullBackdrop.Visible = false
fullBackdrop.ZIndex = 1
fullBackdrop.Parent = screenGui
addGradient(fullBackdrop, Color3.fromRGB(24, 26, 52), Color3.fromRGB(10, 12, 24), 90)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(BASE_W, BASE_H)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 16)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 19, 34)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 2
mainFrame.Parent = screenGui
local mainCorner = addCorner(mainFrame, 18)
local mainStroke = addStroke(mainFrame, Color3.fromRGB(116, 72, 210), 2.8)
addGradient(mainFrame, Color3.fromRGB(26, 28, 54), Color3.fromRGB(13, 15, 28), 90)

local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame

local function calcScale()
	local cam = workspace.CurrentCamera
	if not cam then return 1 end
	local vp = cam.ViewportSize
	if state.Settings.FullScreen then
		local sx = vp.X / BASE_W
		local sy = vp.Y / BASE_H
		return math.clamp(math.min(sx, sy), 0.5, 2.2)
	else
		local sx = (vp.X - 24) / BASE_W
		local sy = (vp.Y - 62) / BASE_H
		return math.clamp(math.min(1.12, sx, sy), 0.48, 1.12)
	end
end

local function applyWindowScale()
	local isFull = (state.Settings.FullScreen == true)
	screenGui.DisplayOrder = 2147483647
	screenGui.IgnoreGuiInset = true
	fullBackdrop.Visible = isFull and mainFrame.Visible
	uiScale.Scale = calcScale()
	if isFull then
		mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		mainCorner.CornerRadius = UDim.new(0, 0)
		mainStroke.Thickness = 0
	else
		mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		mainCorner.CornerRadius = UDim.new(0, 18)
		mainStroke.Thickness = 2.8
	end
end
applyWindowScale()

-- THONG BAO NOI (TOAST BANNER) HIEN DE LEN TREN CUNG KHI NHAP CODE, QUAY SO, MO SKIN FREE
local toastToken = 0
local function showToast(msg, accentColor, duration)
	toastToken += 1
	local myToken = toastToken
	if not UI.toastFrame then
		local tf = Instance.new("Frame")
		tf.Size = UDim2.fromOffset(440, 44)
		tf.Position = UDim2.new(0.5, 0, 0, -56)
		tf.AnchorPoint = Vector2.new(0.5, 0)
		tf.BackgroundColor3 = Color3.fromRGB(20, 24, 46)
		tf.BorderSizePixel = 0
		tf.ZIndex = 95
		tf.Visible = false
		tf.Parent = mainFrame
		addCorner(tf, 12)
		UI.toastStroke = addStroke(tf, THEME.TextGreen, 2.2)
		addGradient(tf, Color3.fromRGB(38, 42, 78), Color3.fromRGB(18, 20, 40), 90)
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.new(1, -20, 1, -4)
		tl.Position = UDim2.fromOffset(10, 2)
		tl.BackgroundTransparency = 1
		tl.Text = ""
		tl.TextColor3 = THEME.TextMain
		tl.Font = THEME.FontHead
		tl.TextSize = 12
		tl.TextWrapped = true
		tl.ZIndex = 96
		tl.Parent = tf
		addTextOutline(tl, 1.4, THEME.Outline)
		UI.toastFrame = tf
		UI.toastLbl = tl
	end
	UI.toastLbl.Text = tostring(msg or "")
	UI.toastLbl.TextColor3 = accentColor or THEME.TextGreen
	UI.toastStroke.Color = accentColor or THEME.TextGreen
	UI.toastFrame.Visible = true
	UI.toastFrame.Position = UDim2.new(0.5, 0, 0, -48)
	TweenService:Create(UI.toastFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 10)
	}):Play()
	task.delay(duration or 3.2, function()
		if toastToken == myToken and UI.toastFrame and UI.toastFrame.Parent then
			local tw = TweenService:Create(UI.toastFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, 0, -56)
			})
			tw:Play()
			tw.Completed:Connect(function()
				if toastToken == myToken and UI.toastFrame and UI.toastFrame.Parent then
					UI.toastFrame.Visible = false
				end
			end)
		end
	end)
end

-- ============================================================
-- THANH DAU TRANG (HO SO BAM NHAN QUA CAP + XU + KIM CUONG + HONG NGOC + FULLSCREEN)
-- ============================================================
function SEC.run2()
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 54)
	topBar.BackgroundColor3 = Color3.fromRGB(28, 30, 56)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame
	addGradient(topBar, Color3.fromRGB(54, 40, 102), Color3.fromRGB(24, 24, 50), 90)
	makeDraggable(topBar, mainFrame)

	local topDivider = Instance.new("Frame")
	topDivider.Size = UDim2.new(1, 0, 0, 2)
	topDivider.Position = UDim2.new(0, 0, 1, -2)
	topDivider.BackgroundColor3 = Color3.fromRGB(118, 74, 208)
	topDivider.BorderSizePixel = 0
	topDivider.Parent = topBar

	-- Nut Ho So & Cap Do: bam vao de mo bang Qua Tang Cap
	local profileBtn = Instance.new("TextButton")
	profileBtn.Size = UDim2.fromOffset(216, 40)
	profileBtn.Position = UDim2.fromOffset(10, 6)
	profileBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 36)
	profileBtn.Text = ""
	profileBtn.AutoButtonColor = false
	profileBtn.BorderSizePixel = 0
	profileBtn.Parent = topBar
	addCorner(profileBtn, 20)
	addStroke(profileBtn, Color3.fromRGB(122, 82, 212), 1.8)
	UI.profileBtn = profileBtn
	UI.levelDot = makeNotifDot(profileBtn, 12)

	local avatarIconHolder = Instance.new("Frame")
	avatarIconHolder.Size = UDim2.fromOffset(30, 30)
	avatarIconHolder.Position = UDim2.fromOffset(6, 5)
	avatarIconHolder.BackgroundTransparency = 1
	avatarIconHolder.Parent = profileBtn
	UI.avatarIconHolder = avatarIconHolder

	local profileName = Instance.new("TextLabel")
	profileName.Size = UDim2.fromOffset(162, 16)
	profileName.Position = UDim2.fromOffset(44, 4)
	profileName.BackgroundTransparency = 1
	profileName.Text = player.DisplayName
	profileName.TextColor3 = THEME.TextMain
	profileName.Font = THEME.FontHead
	profileName.TextSize = 12
	profileName.TextXAlignment = Enum.TextXAlignment.Left
	profileName.TextTruncate = Enum.TextTruncate.AtEnd
	profileName.Parent = profileBtn

	local lvLabel = Instance.new("TextLabel")
	lvLabel.Size = UDim2.fromOffset(44, 13)
	lvLabel.Position = UDim2.fromOffset(44, 22)
	lvLabel.BackgroundTransparency = 1
	lvLabel.Text = "Lv. 1"
	lvLabel.TextColor3 = THEME.TextGold
	lvLabel.Font = THEME.FontHead
	lvLabel.TextSize = 11
	lvLabel.TextXAlignment = Enum.TextXAlignment.Left
	lvLabel.Parent = profileBtn
	UI.lvLabel = lvLabel

	local expBg = Instance.new("Frame")
	expBg.Size = UDim2.fromOffset(116, 9)
	expBg.Position = UDim2.fromOffset(90, 24)
	expBg.BackgroundColor3 = Color3.fromRGB(34, 38, 62)
	expBg.BorderSizePixel = 0
	expBg.Parent = profileBtn
	addCorner(expBg, 5)
	addStroke(expBg, THEME.Outline, 1.3)

	local expFill = Instance.new("Frame")
	expFill.Size = UDim2.fromScale(0.1, 1)
	expFill.BackgroundColor3 = Color3.fromRGB(64, 198, 102)
	expFill.BorderSizePixel = 0
	expFill.Parent = expBg
	addCorner(expFill, 5)
	UI.expFill = expFill

	-- The Xu
	local coinPill = Instance.new("Frame")
	coinPill.Size = UDim2.fromOffset(118, 36)
	coinPill.Position = UDim2.fromOffset(234, 8)
	coinPill.BackgroundColor3 = Color3.fromRGB(16, 18, 36)
	coinPill.BorderSizePixel = 0
	coinPill.Parent = topBar
	addCorner(coinPill, 18)
	addStroke(coinPill, Color3.fromRGB(184, 142, 40), 1.8)
	GFX.makeCartoonCoin(coinPill, 22, UDim2.new(0, 6, 0.5, 0), Vector2.new(0, 0.5), 4)

	local coinsLbl = Instance.new("TextLabel")
	coinsLbl.Size = UDim2.new(1, -34, 1, 0)
	coinsLbl.Position = UDim2.fromOffset(32, 0)
	coinsLbl.BackgroundTransparency = 1
	coinsLbl.Text = formatNum(state.Coins)
	coinsLbl.TextColor3 = THEME.TextGold
	coinsLbl.Font = THEME.FontHead
	coinsLbl.TextSize = 13
	coinsLbl.TextXAlignment = Enum.TextXAlignment.Left
	coinsLbl.Parent = coinPill
	addTextOutline(coinsLbl, 1.3, THEME.Outline)
	UI.coinsLbl = coinsLbl

	-- The Kim Cuong
	local gemPill = Instance.new("Frame")
	gemPill.Size = UDim2.fromOffset(108, 36)
	gemPill.Position = UDim2.fromOffset(358, 8)
	gemPill.BackgroundColor3 = Color3.fromRGB(16, 18, 36)
	gemPill.BorderSizePixel = 0
	gemPill.Parent = topBar
	addCorner(gemPill, 18)
	addStroke(gemPill, Color3.fromRGB(68, 158, 202), 1.8)
	GFX.makeCartoonGem(gemPill, 22, UDim2.new(0, 6, 0.5, 0), Vector2.new(0, 0.5), 4)

	local gemsLbl = Instance.new("TextLabel")
	gemsLbl.Size = UDim2.new(1, -34, 1, 0)
	gemsLbl.Position = UDim2.fromOffset(32, 0)
	gemsLbl.BackgroundTransparency = 1
	gemsLbl.Text = formatNum(state.Gems)
	gemsLbl.TextColor3 = THEME.TextGem
	gemsLbl.Font = THEME.FontHead
	gemsLbl.TextSize = 13
	gemsLbl.TextXAlignment = Enum.TextXAlignment.Left
	gemsLbl.Parent = gemPill
	addTextOutline(gemsLbl, 1.3, THEME.Outline)
	UI.gemsLbl = gemsLbl

	-- The Hong Ngoc (Ngoc tim hiem)
	local rubyPill = Instance.new("Frame")
	rubyPill.Size = UDim2.fromOffset(106, 36)
	rubyPill.Position = UDim2.fromOffset(472, 8)
	rubyPill.BackgroundColor3 = Color3.fromRGB(16, 18, 36)
	rubyPill.BorderSizePixel = 0
	rubyPill.Parent = topBar
	addCorner(rubyPill, 18)
	addStroke(rubyPill, Color3.fromRGB(178, 76, 216), 1.8)
	GFX.makeCartoonRuby(rubyPill, 22, UDim2.new(0, 6, 0.5, 0), Vector2.new(0, 0.5), 4)

	local rubiesLbl = Instance.new("TextLabel")
	rubiesLbl.Size = UDim2.new(1, -34, 1, 0)
	rubiesLbl.Position = UDim2.fromOffset(32, 0)
	rubiesLbl.BackgroundTransparency = 1
	rubiesLbl.Text = formatNum(state.Rubies)
	rubiesLbl.TextColor3 = THEME.TextRuby
	rubiesLbl.Font = THEME.FontHead
	rubiesLbl.TextSize = 13
	rubiesLbl.TextXAlignment = Enum.TextXAlignment.Left
	rubiesLbl.Parent = rubyPill
	addTextOutline(rubiesLbl, 1.3, THEME.Outline)
	UI.rubiesLbl = rubiesLbl

	-- Nut Phong to Full Man Hinh, Thu nho, Dong
	local fullBtn, fullLbl = makeArcadeBtn(topBar, state.Settings.FullScreen and "><" or "[ ]", UDim2.fromOffset(36, 34), UDim2.new(1, -124, 0, 9), Color3.fromRGB(64, 146, 206), Color3.fromRGB(36, 86, 162), 10, { TextSize = 12, Depth = 3 })
	UI.fullBtn = fullBtn
	UI.fullLbl = fullLbl
	UI.minBtn = makeArcadeBtn(topBar, "-", UDim2.fromOffset(36, 34), UDim2.new(1, -83, 0, 9), Color3.fromRGB(86, 98, 134), Color3.fromRGB(52, 60, 86), 10, { TextSize = 18, Depth = 3 })
	UI.closeBtn = makeArcadeBtn(topBar, "X", UDim2.fromOffset(36, 34), UDim2.new(1, -42, 0, 9), Color3.fromRGB(214, 62, 68), Color3.fromRGB(154, 28, 36), 10, { TextSize = 14, Depth = 3 })
end
SEC.run2()

-- ============================================================
-- VUNG NOI DUNG CHINH (700x390)
-- ============================================================
local container = Instance.new("Frame")
container.Size = UDim2.fromOffset(700, 390)
container.Position = UDim2.fromOffset(10, 60)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local lobbyPage = Instance.new("Frame")
lobbyPage.Size = UDim2.fromScale(1, 1)
lobbyPage.BackgroundTransparency = 1
lobbyPage.Parent = container

local gamePage = Instance.new("Frame")
gamePage.Size = UDim2.fromScale(1, 1)
gamePage.BackgroundTransparency = 1
gamePage.Visible = false
gamePage.Parent = container

-- ============================================================
-- 1. SANH CHO (6 NUT DUOI CO THEM VONG QUAY)
-- ============================================================
function SEC.run3()
	local showcaseCard = Instance.new("Frame")
	showcaseCard.Size = UDim2.fromOffset(424, 304)
	showcaseCard.BackgroundColor3 = Color3.fromRGB(20, 24, 46)
	showcaseCard.BorderSizePixel = 0
	showcaseCard.Parent = lobbyPage
	addCorner(showcaseCard, 16)
	addStroke(showcaseCard, Color3.fromRGB(108, 78, 194), 2.4)
	addGradient(showcaseCard, Color3.fromRGB(32, 36, 68), Color3.fromRGB(15, 18, 36), 90)

	local titleBanner = Instance.new("Frame")
	titleBanner.Size = UDim2.fromOffset(240, 32)
	titleBanner.Position = UDim2.new(0.5, -120, 0, 10)
	titleBanner.BackgroundColor3 = Color3.fromRGB(22, 26, 50)
	titleBanner.BorderSizePixel = 0
	titleBanner.Parent = showcaseCard
	addCorner(titleBanner, 16)
	addStroke(titleBanner, Color3.fromRGB(122, 86, 206), 1.6)
	addGradient(titleBanner, Color3.fromRGB(44, 38, 86), Color3.fromRGB(22, 24, 48), 90)

	local showcaseTitle = Instance.new("TextLabel")
	showcaseTitle.Size = UDim2.fromScale(1, 1)
	showcaseTitle.BackgroundTransparency = 1
	showcaseTitle.Text = "RẮN SĂN MỒI"
	showcaseTitle.TextColor3 = THEME.TextGold
	showcaseTitle.Font = THEME.FontHead
	showcaseTitle.TextSize = 18
	showcaseTitle.Parent = titleBanner
	addTextOutline(showcaseTitle, 2, THEME.Outline)

	local previewStage = Instance.new("Frame")
	previewStage.Size = UDim2.fromOffset(396, 86)
	previewStage.Position = UDim2.fromOffset(14, 46)
	previewStage.BackgroundColor3 = Color3.fromRGB(13, 17, 34)
	previewStage.BorderSizePixel = 0
	previewStage.ClipsDescendants = true
	previewStage.Parent = showcaseCard
	addCorner(previewStage, 12)
	addStroke(previewStage, Color3.fromRGB(72, 84, 138), 1.8)
	UI.previewStage = previewStage

	local skinPill = Instance.new("Frame")
	skinPill.Size = UDim2.fromOffset(396, 24)
	skinPill.Position = UDim2.fromOffset(14, 136)
	skinPill.BackgroundColor3 = Color3.fromRGB(16, 20, 38)
	skinPill.BorderSizePixel = 0
	skinPill.Parent = showcaseCard
	addCorner(skinPill, 8)
	addStroke(skinPill, Color3.fromRGB(64, 72, 114), 1.4)

	local equippedSkinLbl = Instance.new("TextLabel")
	equippedSkinLbl.Size = UDim2.new(1, -12, 1, 0)
	equippedSkinLbl.Position = UDim2.fromOffset(6, 0)
	equippedSkinLbl.BackgroundTransparency = 1
	equippedSkinLbl.Text = "Rắn Xanh Lá  •  Thường"
	equippedSkinLbl.TextColor3 = THEME.TextGem
	equippedSkinLbl.Font = THEME.FontHead
	equippedSkinLbl.TextSize = 11
	equippedSkinLbl.Parent = skinPill
	addTextOutline(equippedSkinLbl, 1.2, THEME.Outline)
	UI.equippedSkinLbl = equippedSkinLbl

	-- CHON 4 CHE DO CHOI (CO DIEN, XUYEN TUONG, ME CUNG, SIEU TOC)
	local modeBar = Instance.new("Frame")
	modeBar.Size = UDim2.fromOffset(396, 30)
	modeBar.Position = UDim2.fromOffset(14, 165)
	modeBar.BackgroundTransparency = 1
	modeBar.Parent = showcaseCard
	local modeLayout = Instance.new("UIListLayout")
	modeLayout.FillDirection = Enum.FillDirection.Horizontal
	modeLayout.Padding = UDim.new(0, 6)
	modeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	modeLayout.Parent = modeBar

	UI.modeBtns = {}
	local function refreshModeBtns()
		for _, item in ipairs(UI.modeBtns) do
			local active = (state.GameMode == item.Id)
			item.Face.BackgroundColor3 = active and Color3.fromRGB(134, 62, 212) or Color3.fromRGB(28, 34, 60)
			item.Stroke.Color = active and THEME.TextGold or Color3.fromRGB(72, 82, 128)
			item.Lbl.TextColor3 = active and THEME.TextGold or THEME.TextMuted
		end
	end
	UI.refreshModeBtns = refreshModeBtns

	for _, md in ipairs(GAME_MODES) do
		local mBtn = Instance.new("TextButton")
		mBtn.Size = UDim2.fromOffset(94, 28)
		mBtn.BackgroundColor3 = Color3.fromRGB(28, 34, 60)
		mBtn.Text = ""
		mBtn.AutoButtonColor = false
		mBtn.BorderSizePixel = 0
		mBtn.Parent = modeBar
		addCorner(mBtn, 9)
		local mStroke = addStroke(mBtn, Color3.fromRGB(72, 82, 128), 1.6)
		local mLbl = Instance.new("TextLabel")
		mLbl.Size = UDim2.fromScale(1, 1)
		mLbl.BackgroundTransparency = 1
		mLbl.Text = md.Name
		mLbl.TextColor3 = THEME.TextMuted
		mLbl.Font = THEME.FontHead
		mLbl.TextSize = 11
		mLbl.Parent = mBtn
		addTextOutline(mLbl, 1.2, THEME.Outline)
		table.insert(UI.modeBtns, { Id = md.Id, Face = mBtn, Stroke = mStroke, Lbl = mLbl })
		mBtn.MouseButton1Click:Connect(function()
			state.GameMode = md.Id
			refreshModeBtns()
			saveData()
			showToast("Chế độ " .. md.Name .. "  •  " .. md.Desc, THEME.TextGold, 2.0)
		end)
	end
	refreshModeBtns()

	local playBtn, _, playFace = makeArcadeBtn(
		showcaseCard, "▶  Chơi Ngay",
		UDim2.fromOffset(272, 58),
		UDim2.fromOffset(76, 202),
		Color3.fromRGB(76, 210, 62), Color3.fromRGB(28, 148, 44), 20,
		{
			TextSize = 21,
			TextStroke = 2.4,
			Stroke = 2.8,
			Depth = 5,
			LabelPos = UDim2.fromOffset(24, 0),
			LabelSize = UDim2.new(1, -28, 1, 0),
		}
	)
	UI.playBtn = playBtn

	local badgeHolder = Instance.new("Frame")
	badgeHolder.Size = UDim2.fromOffset(40, 40)
	badgeHolder.Position = UDim2.fromOffset(16, 10)
	badgeHolder.BackgroundTransparency = 1
	badgeHolder.ZIndex = 9
	badgeHolder.Parent = playFace
	local mascot = GFX.buildCartoonHead(badgeHolder, 34, { HeadColor = Color3.fromRGB(68, 206, 62), Style = "Crown" })
	mascot.Position = UDim2.fromScale(0.5, 0.5)
	mascot.ZIndex = 9
	for _, d in ipairs(mascot:GetDescendants()) do
		if d:IsA("GuiObject") then d.ZIndex += 5 end
	end

	local bestBar = Instance.new("Frame")
	bestBar.Size = UDim2.fromOffset(272, 26)
	bestBar.Position = UDim2.fromOffset(76, 266)
	bestBar.BackgroundColor3 = Color3.fromRGB(16, 20, 38)
	bestBar.BorderSizePixel = 0
	bestBar.Parent = showcaseCard
	addCorner(bestBar, 13)
	addStroke(bestBar, Color3.fromRGB(78, 66, 134), 1.4)

	local bestScoreTip = Instance.new("TextLabel")
	bestScoreTip.Size = UDim2.fromScale(1, 1)
	bestScoreTip.BackgroundTransparency = 1
	bestScoreTip.Text = "Kỷ lục của bạn: 0 điểm"
	bestScoreTip.TextColor3 = THEME.TextGold
	bestScoreTip.Font = THEME.FontBody
	bestScoreTip.TextSize = 12
	bestScoreTip.Parent = bestBar
	UI.bestScoreTip = bestScoreTip

	-- BANG XEP HANG TIM BEN PHAI
	local lbOuter = Instance.new("Frame")
	lbOuter.Size = UDim2.fromOffset(266, 304)
	lbOuter.Position = UDim2.fromOffset(434, 0)
	lbOuter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	lbOuter.BorderSizePixel = 0
	lbOuter.Parent = lobbyPage
	addCorner(lbOuter, 16)
	addStroke(lbOuter, THEME.Outline, 2.8)
	addGradient(lbOuter, Color3.fromRGB(152, 66, 224), Color3.fromRGB(98, 32, 182), 90)

	local lbHeader = Instance.new("Frame")
	lbHeader.Size = UDim2.new(1, -8, 0, 40)
	lbHeader.Position = UDim2.fromOffset(4, 4)
	lbHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	lbHeader.BorderSizePixel = 0
	lbHeader.Parent = lbOuter
	addCorner(lbHeader, 12)
	addStroke(lbHeader, THEME.Outline, 2)
	addGradient(lbHeader, Color3.fromRGB(168, 84, 234), Color3.fromRGB(112, 42, 198), 90)

	GFX.makeVectorCrown(lbHeader, 24, UDim2.fromOffset(22, 20), nil, nil, 6)

	local lbTitle = Instance.new("TextLabel")
	lbTitle.Size = UDim2.new(1, -44, 1, 0)
	lbTitle.Position = UDim2.fromOffset(40, 0)
	lbTitle.BackgroundTransparency = 1
	lbTitle.Text = "Bảng Xếp Hạng"
	lbTitle.TextColor3 = THEME.TextGold
	lbTitle.Font = THEME.FontHead
	lbTitle.TextSize = 16
	lbTitle.TextXAlignment = Enum.TextXAlignment.Left
	lbTitle.Parent = lbHeader
	addTextOutline(lbTitle, 2.2, THEME.Outline)

	local lbInner = Instance.new("Frame")
	lbInner.Size = UDim2.new(1, -12, 1, -90)
	lbInner.Position = UDim2.fromOffset(6, 48)
	lbInner.BackgroundColor3 = Color3.fromRGB(18, 22, 42)
	lbInner.BorderSizePixel = 0
	lbInner.Parent = lbOuter
	addCorner(lbInner, 10)
	addStroke(lbInner, THEME.Outline, 2)

	local lbList = Instance.new("Frame")
	lbList.Size = UDim2.new(1, -10, 1, -8)
	lbList.Position = UDim2.fromOffset(5, 4)
	lbList.BackgroundTransparency = 1
	lbList.Parent = lbInner
	UI.lbList = lbList

	local lbLayout = Instance.new("UIListLayout")
	lbLayout.Padding = UDim.new(0, 4)
	lbLayout.Parent = lbList

	UI.lbMoreBtn = makeArcadeBtn(
		lbOuter, "Xem Thêm >>",
		UDim2.new(1, -16, 0, 32),
		UDim2.new(0, 8, 1, -36),
		Color3.fromRGB(142, 68, 218), Color3.fromRGB(92, 34, 168), 10,
		{ TextSize = 13, TextStroke = 1.8, Depth = 3, Stroke = 2 }
	)

	-- THANH 6 NUT DUOI (SHOP, VONG QUAY, QUA TANG, NHIEM VU, CAI DAT, THOAT)
	local bottomBar = Instance.new("Frame")
	bottomBar.Size = UDim2.fromOffset(700, 74)
	bottomBar.Position = UDim2.fromOffset(0, 314)
	bottomBar.BackgroundTransparency = 1
	bottomBar.Parent = lobbyPage

	local bLayout = Instance.new("UIListLayout")
	bLayout.FillDirection = Enum.FillDirection.Horizontal
	bLayout.Padding = UDim.new(0, 8)
	bLayout.Parent = bottomBar

	local navOpts = {
		TextSize = 12,
		TextStroke = 2,
		Stroke = 2.4,
		Depth = 4,
		LabelSize = UDim2.new(1, -4, 0, 20),
		LabelPos = UDim2.new(0, 2, 1, -24),
	}

	local shopBtn, _, shopFace = makeArcadeBtn(bottomBar, "Shop", UDim2.fromOffset(110, 70), nil, Color3.fromRGB(224, 62, 54), Color3.fromRGB(168, 24, 28), 14, navOpts)
	GFX.buildShopIcon(shopFace, 7)
	UI.shopBtn = shopBtn

	local wheelBtn, _, wheelFace = makeArcadeBtn(bottomBar, "Vòng Quay", UDim2.fromOffset(110, 70), nil, Color3.fromRGB(54, 158, 224), Color3.fromRGB(28, 86, 178), 14, navOpts)
	GFX.buildWheelIcon(wheelFace, 7)
	UI.wheelBtn = wheelBtn
	UI.wheelDot = makeNotifDot(wheelBtn, 12)

	local giftBtn, _, giftFace = makeArcadeBtn(bottomBar, "Quà Tặng", UDim2.fromOffset(110, 70), nil, Color3.fromRGB(216, 64, 152), Color3.fromRGB(154, 28, 108), 14, navOpts)
	GFX.buildGiftIcon(giftFace, 7)
	UI.giftBtn = giftBtn
	UI.giftDot = makeNotifDot(giftBtn, 12)

	local questBtn, _, questFace = makeArcadeBtn(bottomBar, "Nhiệm Vụ", UDim2.fromOffset(110, 70), nil, Color3.fromRGB(224, 156, 36), Color3.fromRGB(184, 92, 18), 14, navOpts)
	GFX.buildChestIcon(questFace, 7)
	UI.questBtn = questBtn
	UI.questDot = makeNotifDot(questBtn, 12)

	local settingsBtn, _, setFace = makeArcadeBtn(bottomBar, "Cài Đặt", UDim2.fromOffset(110, 70), nil, Color3.fromRGB(162, 74, 224), Color3.fromRGB(106, 36, 178), 14, navOpts)
	GFX.buildGearIcon(setFace, 7)
	UI.settingsBtn = settingsBtn

	local exitBtn, _, exitFace = makeArcadeBtn(bottomBar, "Thoát", UDim2.fromOffset(110, 70), nil, Color3.fromRGB(82, 206, 56), Color3.fromRGB(32, 146, 38), 14, navOpts)
	GFX.buildExitDoorIcon(exitFace, 7)
	UI.exitBtn = exitBtn
end
SEC.run3()

local previewSegs = {}
local previewHead = nil

local function getSortedLeaderboard()
	local entries = {}
	for _, b in ipairs(BOT_SCORES) do
		table.insert(entries, { Name = b.Name, Score = b.Score, IsYou = false })
	end
	table.insert(entries, { Name = player.DisplayName, Score = state.HighScore, IsYou = true })
	table.sort(entries, function(a, b) return a.Score > b.Score end)
	return entries
end

local function makeLeaderboardRow(parent, rank, entry, rowHeight)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, rowHeight)
	row.BackgroundColor3 = entry.IsYou and Color3.fromRGB(86, 62, 22) or Color3.fromRGB(24, 30, 54)
	row.BackgroundTransparency = entry.IsYou and 0.15 or 0.45
	row.BorderSizePixel = 0
	row.Parent = parent
	addCorner(row, 7)

	if rank == 1 then
		GFX.makeVectorCrown(row, 16, UDim2.new(0, 13, 0.5, 0), Color3.fromRGB(232, 196, 52), Color3.fromRGB(186, 128, 18), 4)
	elseif rank == 2 then
		GFX.makeVectorCrown(row, 16, UDim2.new(0, 13, 0.5, 0), Color3.fromRGB(208, 216, 228), Color3.fromRGB(134, 146, 168), 4)
	elseif rank == 3 then
		GFX.makeVectorCrown(row, 16, UDim2.new(0, 13, 0.5, 0), Color3.fromRGB(214, 136, 64), Color3.fromRGB(152, 78, 32), 4)
	end

	local badge = Instance.new("Frame")
	badge.Size = UDim2.fromOffset(18, 18)
	badge.Position = UDim2.new(0, 26, 0.5, -9)
	badge.BorderSizePixel = 0
	badge.Parent = row
	addCorner(badge, 99)

	if rank == 1 then
		badge.BackgroundColor3 = Color3.fromRGB(162, 114, 22)
		addStroke(badge, Color3.fromRGB(218, 182, 54), 1.4)
	elseif rank == 2 then
		badge.BackgroundColor3 = Color3.fromRGB(118, 56, 198)
		addStroke(badge, Color3.fromRGB(182, 146, 222), 1.4)
	elseif rank == 3 then
		badge.BackgroundColor3 = Color3.fromRGB(186, 44, 48)
		addStroke(badge, Color3.fromRGB(218, 134, 92), 1.4)
	else
		badge.BackgroundTransparency = 1
	end

	local rLbl = Instance.new("TextLabel")
	rLbl.Size = UDim2.fromScale(1, 1)
	rLbl.BackgroundTransparency = 1
	rLbl.Text = tostring(rank)
	rLbl.TextColor3 = (rank == 1) and THEME.TextGold or THEME.TextMain
	rLbl.Font = THEME.FontHead
	rLbl.TextSize = 11
	rLbl.Parent = badge

	local nLbl = Instance.new("TextLabel")
	nLbl.Size = UDim2.new(1, -108, 1, 0)
	nLbl.Position = UDim2.fromOffset(50, 0)
	nLbl.BackgroundTransparency = 1
	nLbl.Text = entry.Name
	nLbl.TextColor3 = entry.IsYou and THEME.TextGold or THEME.TextMain
	nLbl.Font = entry.IsYou and THEME.FontHead or THEME.FontBody
	nLbl.TextSize = 12
	nLbl.TextXAlignment = Enum.TextXAlignment.Left
	nLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nLbl.Parent = row

	local sLbl = Instance.new("TextLabel")
	sLbl.Size = UDim2.fromOffset(52, rowHeight)
	sLbl.Position = UDim2.new(1, -56, 0, 0)
	sLbl.BackgroundTransparency = 1
	sLbl.Text = formatNum(entry.Score)
	sLbl.TextColor3 = (rank == 1 or entry.IsYou) and THEME.TextGold or THEME.TextMain
	sLbl.Font = THEME.FontHead
	sLbl.TextSize = 12
	sLbl.TextXAlignment = Enum.TextXAlignment.Right
	sLbl.Parent = row
	return row
end

local function refreshLeaderboard()
	for _, ch in ipairs(UI.lbList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	local entries = getSortedLeaderboard()
	local youRank, youEntry = nil, nil
	for i, e in ipairs(entries) do
		if e.IsYou then youRank, youEntry = i, e break end
	end
	local showCount = (youRank and youRank > 5) and 4 or math.min(5, #entries)
	for i = 1, showCount do
		makeLeaderboardRow(UI.lbList, i, entries[i], 36)
	end
	if youRank and youRank > 5 and youEntry then
		makeLeaderboardRow(UI.lbList, youRank, youEntry, 36)
	end
end

local function rebuildLobbyPreview()
	for _, ch in ipairs(UI.previewStage:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.avatarIconHolder:GetChildren()) do ch:Destroy() end
	previewSegs = {}

	for x = 0, 16 do
		for y = 0, 4 do
			if (x + y) % 2 == 0 then
				local sq = Instance.new("Frame")
				sq.Size = UDim2.fromOffset(24, 22)
				sq.Position = UDim2.fromOffset(x * 24, y * 22)
				sq.BackgroundColor3 = Color3.fromRGB(18, 24, 46)
				sq.BorderSizePixel = 0
				sq.ZIndex = 1
				sq.Parent = UI.previewStage
			end
		end
	end

	local skin = getSkinById(state.EquippedSkin)
	local rar = RARITIES[skin.Rarity] or RARITIES.Common
	local stTxt = getSkinStatsText(skin)
	local bonusStr = (stTxt ~= "") and ("  •  " .. stTxt) or ""
	UI.equippedSkinLbl.Text = skin.Name .. "  •  " .. rar.Label .. bonusStr
	UI.equippedSkinLbl.TextColor3 = rar.Color

	local miniAvatar = GFX.buildCartoonHead(UI.avatarIconHolder, 24, skin)
	miniAvatar.Position = UDim2.fromScale(0.5, 0.5)

	for i = 10, 1, -1 do
		local sz = math.max(17, 32 - (i * 1.2))
		local seg = Instance.new("Frame")
		seg.Size = UDim2.fromOffset(sz, sz)
		seg.AnchorPoint = Vector2.new(0.5, 0.5)
		seg.BackgroundColor3 = getSegmentColor(skin, i)
		seg.BackgroundTransparency = skin.BodyAlpha or 0
		seg.BorderSizePixel = 0
		seg.ZIndex = 5 - math.floor(i / 4)
		seg.Parent = UI.previewStage
		addCorner(seg, 99)
		addStroke(seg, skin.GlowColor or THEME.Outline, 2)
		previewSegs[i] = seg
	end
	previewHead = GFX.buildCartoonHead(UI.previewStage, 36, skin)
end

-- ============================================================
-- CAP NHAT CHI SO & CHAM DO THONG BAO
-- ============================================================
local function updateFreeSpinsTick()
	local now = os.time()
	if state.FreeSpins >= FREE_SPIN_MAX then
		state.NextFreeSpinUnix = now + FREE_SPIN_INTERVAL
		return false
	end
	if state.NextFreeSpinUnix <= 0 then
		state.NextFreeSpinUnix = now + FREE_SPIN_INTERVAL
		return false
	end
	if now >= state.NextFreeSpinUnix then
		local gained = math.floor((now - state.NextFreeSpinUnix) / FREE_SPIN_INTERVAL) + 1
		state.FreeSpins = math.min(FREE_SPIN_MAX, state.FreeSpins + gained)
		if state.FreeSpins >= FREE_SPIN_MAX then
			state.NextFreeSpinUnix = now + FREE_SPIN_INTERVAL
		else
			state.NextFreeSpinUnix = state.NextFreeSpinUnix + (gained * FREE_SPIN_INTERVAL)
		end
		saveData()
		return true
	end
	return false
end
updateFreeSpinsTick()

local function formatMMSS(secs)
	local s = math.max(0, math.floor(secs))
	return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end

local function getTodayKey()
	local ok, d = pcall(function() return os.date("%Y-%m-%d") end)
	return (ok and type(d) == "string") and d or tostring(math.floor(os.time() / 86400))
end

local function canClaimDailyToday()
	return (state.LastDailyDate ~= getTodayKey())
end

local function hasUnclaimedOnlineReward()
	for _, r in ipairs(ONLINE_REWARDS) do
		if state.OnlineSeconds >= r.Secs and not state.ClaimedOnline[r.Id] then
			return true
		end
	end
	return false
end

local function hasUnclaimedLevelReward()
	for _, m in ipairs(LEVEL_REWARDS) do
		if state.Level >= m.Level and not state.ClaimedLevels[tostring(m.Level)] then
			return true
		end
	end
	return false
end

local function refreshNotifDots()
	UI.giftDot.Visible = hasUnclaimedOnlineReward() or canClaimDailyToday()
	UI.wheelDot.Visible = ((state.Spins + state.FreeSpins) > 0)
	UI.levelDot.Visible = hasUnclaimedLevelReward()
	local hasQuest = false
	for _, q in ipairs(state.Quests) do
		if q.Progress >= q.Goal and not q.Claimed then
			hasQuest = true
			break
		end
	end
	UI.questDot.Visible = hasQuest
end

local function updateTopStats()
	UI.coinsLbl.Text  = formatNum(state.Coins)
	UI.gemsLbl.Text   = formatNum(state.Gems)
	UI.rubiesLbl.Text = formatNum(state.Rubies)
	UI.lvLabel.Text   = (state.Level >= MAX_LEVEL) and "Lv.100" or ("Lv. " .. tostring(state.Level))
	local expRatio = (state.Level >= MAX_LEVEL) and 1 or math.clamp(state.Exp / math.max(1, state.ExpNeed), 0.06, 1)
	UI.expFill.Size   = UDim2.fromScale(expRatio, 1)
	UI.bestScoreTip.Text = "Kỷ lục của bạn: " .. formatNum(state.HighScore) .. " điểm"
	refreshLeaderboard()
	refreshNotifDots()
end

local function addExp(amount)
	if state.Level >= MAX_LEVEL then
		state.Exp = state.ExpNeed
		updateTopStats()
		saveData()
		return
	end
	state.Exp += amount
	while state.Level < MAX_LEVEL and state.Exp >= state.ExpNeed do
		state.Exp -= state.ExpNeed
		state.Level += 1
		state.ExpNeed = expNeedForLevel(state.Level)
		state.Gems += 3
		state.Coins += 150
	end
	if state.Level >= MAX_LEVEL then
		state.Level = MAX_LEVEL
		state.Exp = state.ExpNeed
	end
	updateTopStats()
	saveData()
end

local function addQuestProgress(id, amount, isMax)
	for _, q in ipairs(state.Quests) do
		if q.Id == id and not q.Claimed then
			if isMax then
				q.Progress = math.max(q.Progress, amount)
			else
				q.Progress = math.min(q.Goal, q.Progress + amount)
			end
		end
	end
	refreshNotifDots()
end

-- ============================================================
-- HE THONG MODAL (SHOP, VONG QUAY, QUA CAP DO, QUA TANG, NHIEM VU, CAI DAT)
-- ============================================================
local activeModalTag = nil
local shopFilter = "All"
local wheelSpinning = false

function SEC.run4()
	local modalOverlay = Instance.new("Frame")
	modalOverlay.Size = UDim2.fromScale(1, 1)
	modalOverlay.BackgroundColor3 = Color3.fromRGB(6, 8, 14)
	modalOverlay.BackgroundTransparency = 0.25
	modalOverlay.Visible = false
	modalOverlay.ZIndex = 30
	modalOverlay.Parent = mainFrame
	UI.modalOverlay = modalOverlay

	local modalBox = Instance.new("Frame")
	modalBox.Size = UDim2.fromOffset(588, 398)
	modalBox.Position = UDim2.fromScale(0.5, 0.5)
	modalBox.AnchorPoint = Vector2.new(0.5, 0.5)
	modalBox.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	modalBox.BorderSizePixel = 0
	modalBox.ZIndex = 31
	modalBox.Parent = modalOverlay
	addCorner(modalBox, 16)
	addStroke(modalBox, Color3.fromRGB(132, 76, 214), 2.6)

	local modalHeader = Instance.new("Frame")
	modalHeader.Size = UDim2.new(1, -8, 0, 40)
	modalHeader.Position = UDim2.fromOffset(4, 4)
	modalHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	modalHeader.BorderSizePixel = 0
	modalHeader.ZIndex = 32
	modalHeader.Parent = modalBox
	addCorner(modalHeader, 12)
	addStroke(modalHeader, THEME.Outline, 2)
	addGradient(modalHeader, Color3.fromRGB(142, 74, 218), Color3.fromRGB(88, 36, 168), 90)

	local modalTitle = Instance.new("TextLabel")
	modalTitle.Size = UDim2.new(1, -55, 1, 0)
	modalTitle.Position = UDim2.fromOffset(14, 0)
	modalTitle.BackgroundTransparency = 1
	modalTitle.TextColor3 = THEME.TextGold
	modalTitle.Font = THEME.FontHead
	modalTitle.TextSize = 15
	modalTitle.TextXAlignment = Enum.TextXAlignment.Left
	modalTitle.ZIndex = 33
	modalTitle.Parent = modalHeader
	addTextOutline(modalTitle, 2, THEME.Outline)
	UI.modalTitle = modalTitle

	local modalClose = makeArcadeBtn(modalBox, "X", UDim2.fromOffset(32, 32), UDim2.new(1, -40, 0, 8), Color3.fromRGB(214, 62, 68), Color3.fromRGB(154, 28, 36), 8, { TextSize = 14, ZIndex = 35, Depth = 3 })
	modalClose.MouseButton1Click:Connect(function()
		if wheelSpinning then return end
		modalOverlay.Visible = false
		activeModalTag = nil
	end)

	local modalFilterBar = Instance.new("Frame")
	modalFilterBar.Size = UDim2.new(1, -20, 0, 30)
	modalFilterBar.Position = UDim2.fromOffset(10, 50)
	modalFilterBar.BackgroundTransparency = 1
	modalFilterBar.Visible = false
	modalFilterBar.ZIndex = 32
	modalFilterBar.Parent = modalBox
	UI.modalFilterBar = modalFilterBar

	local fLayout = Instance.new("UIListLayout")
	fLayout.FillDirection = Enum.FillDirection.Horizontal
	fLayout.Padding = UDim.new(0, 6)
	fLayout.Parent = modalFilterBar

	local modalBody = Instance.new("ScrollingFrame")
	modalBody.Size = UDim2.new(1, -18, 1, -58)
	modalBody.Position = UDim2.fromOffset(9, 50)
	modalBody.BackgroundTransparency = 1
	modalBody.ScrollBarThickness = 5
	modalBody.CanvasSize = UDim2.new(0, 0, 0, 0)
	modalBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
	modalBody.ZIndex = 32
	modalBody.Parent = modalBox
	UI.modalBody = modalBody
end
SEC.run4()

local function openModal(tag, titleText, showFilterBar)
	for _, ch in ipairs(UI.modalBody:GetChildren()) do ch:Destroy() end
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = UI.modalBody

	UI.modalFilterBar.Visible = (showFilterBar == true)
	if showFilterBar then
		UI.modalBody.Position = UDim2.fromOffset(9, 86)
		UI.modalBody.Size = UDim2.new(1, -18, 1, -94)
	else
		UI.modalBody.Position = UDim2.fromOffset(9, 50)
		UI.modalBody.Size = UDim2.new(1, -18, 1, -58)
	end

	activeModalTag = tag
	UI.modalTitle.Text = titleText
	UI.modalOverlay.Visible = true
end

local function openFullLeaderboard()
	openModal("Leaderboard", "BẢNG XẾP HẠNG TOP 10", false)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 5)
	list.Parent = UI.modalBody

	local entries = getSortedLeaderboard()
	for i = 1, math.min(10, #entries) do
		local row = makeLeaderboardRow(UI.modalBody, i, entries[i], 32)
		row.ZIndex = 33
		for _, d in ipairs(row:GetDescendants()) do
			if d:IsA("GuiObject") then d.ZIndex += 33 end
		end
	end
end

-- POPUP CUA HANG RAN (HIEN BIEU TUONG XU / KIM CUONG / HONG NGOC TREN NUT MUA)
local function openShop()
	local ownedCount = 0
	for _, s in ipairs(SKINS) do
		if state.OwnedSkins[s.Id] then ownedCount += 1 end
	end
	openModal("Shop", "CỬA HÀNG RẮN  •  " .. ownedCount .. "/" .. #SKINS, true)

	for _, ch in ipairs(UI.modalFilterBar:GetChildren()) do
		if ch:IsA("TextButton") then ch:Destroy() end
	end
	for _, key in ipairs(RARITY_ORDER) do
		local rInfo = RARITIES[key]
		local isSel = (shopFilter == key)
		local fBtn = makeArcadeBtn(
			UI.modalFilterBar, rInfo.Label,
			UDim2.fromOffset(75, 28), nil,
			isSel and Color3.fromRGB(134, 72, 214) or Color3.fromRGB(40, 46, 76),
			isSel and Color3.fromRGB(86, 38, 162) or Color3.fromRGB(26, 30, 54),
			8,
			{ TextSize = 11, TextColor = isSel and THEME.TextMain or rInfo.Color, ZIndex = 34, Depth = 2, Stroke = 1.6 }
		)
		fBtn.MouseButton1Click:Connect(function()
			shopFilter = key
			openShop()
		end)
	end

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(268, 90)
	grid.CellPadding = UDim2.fromOffset(10, 10)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = UI.modalBody

	for idx, skin in ipairs(SKINS) do
		if shopFilter == "All" or skin.Rarity == shopFilter then
			local rar = RARITIES[skin.Rarity] or RARITIES.Common
			local equipped = (state.EquippedSkin == skin.Id)
			local owned = state.OwnedSkins[skin.Id]

			local card = Instance.new("Frame")
			card.LayoutOrder = idx
			card.BackgroundColor3 = Color3.fromRGB(26, 30, 54)
			card.BorderSizePixel = 0
			card.ZIndex = 33
			card.Parent = UI.modalBody
			addCorner(card, 12)
			addStroke(card, equipped and THEME.TextGreen or rar.Color, equipped and 2.2 or 1.6)

			local headBox = Instance.new("Frame")
			headBox.Size = UDim2.fromOffset(48, 48)
			headBox.Position = UDim2.fromOffset(10, 21)
			headBox.BackgroundTransparency = 1
			headBox.ZIndex = 34
			headBox.Parent = card
			local h = GFX.buildCartoonHead(headBox, 34, skin)
			h.Position = UDim2.fromScale(0.5, 0.5)
			h.ZIndex = 35
			for _, d in ipairs(h:GetDescendants()) do
				if d:IsA("GuiObject") then d.ZIndex += 30 end
			end

			local nLbl = Instance.new("TextLabel")
			nLbl.Size = UDim2.fromOffset(194, 18)
			nLbl.Position = UDim2.fromOffset(64, 7)
			nLbl.BackgroundTransparency = 1
			nLbl.Text = skin.Name
			nLbl.TextColor3 = THEME.TextMain
			nLbl.Font = THEME.FontHead
			nLbl.TextSize = 12
			nLbl.TextXAlignment = Enum.TextXAlignment.Left
			nLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nLbl.ZIndex = 34
			nLbl.Parent = card

			local rarLbl = Instance.new("TextLabel")
			rarLbl.Size = UDim2.fromOffset(194, 15)
			rarLbl.Position = UDim2.fromOffset(64, 25)
			rarLbl.BackgroundTransparency = 1
			local stTxt = getSkinStatsText(skin)
			rarLbl.Text = rar.Label .. (stTxt ~= "" and (" • " .. stTxt) or "")
			rarLbl.TextColor3 = rar.Color
			rarLbl.Font = THEME.FontBody
			rarLbl.TextSize = 10
			rarLbl.TextXAlignment = Enum.TextXAlignment.Left
			rarLbl.TextTruncate = Enum.TextTruncate.AtEnd
			rarLbl.ZIndex = 34
			rarLbl.Parent = card

			local btnText, c1, c2
			local showPriceIcon = false
			if equipped then
				btnText = "ĐANG DÙNG"
				c1, c2 = Color3.fromRGB(64, 194, 96), Color3.fromRGB(28, 134, 58)
			elseif owned then
				btnText = "TRANG BỊ"
				c1, c2 = Color3.fromRGB(56, 158, 212), Color3.fromRGB(32, 92, 178)
			elseif skin.FreeOnly then
				btnText = skin.UnlockText or "NHẬN MIỄN PHÍ"
				c1, c2 = Color3.fromRGB(92, 74, 148), Color3.fromRGB(54, 42, 98)
			else
				showPriceIcon = true
				btnText = formatNum(skin.Price)
				if skin.Currency == "Gems" then
					c1, c2 = Color3.fromRGB(56, 148, 216), Color3.fromRGB(30, 86, 178)
				elseif skin.Currency == "Rubies" then
					c1, c2 = Color3.fromRGB(178, 68, 216), Color3.fromRGB(112, 32, 168)
				else
					c1, c2 = Color3.fromRGB(214, 168, 36), Color3.fromRGB(168, 98, 18)
				end
			end

			local btnOpts = { TextSize = 12, ZIndex = 35, Depth = 3, Stroke = 1.8 }
			if showPriceIcon then
				btnOpts.LabelPos = UDim2.fromOffset(14, 0)
				btnOpts.LabelSize = UDim2.new(1, -18, 1, 0)
			end
			local actBtn, actLbl, actFace = makeArcadeBtn(card, btnText, UDim2.fromOffset(186, 34), UDim2.fromOffset(64, 46), c1, c2, 9, btnOpts)

			if showPriceIcon then
				GFX.makeCurrencyIcon(actFace, skin.Currency, 18, UDim2.new(0, 38, 0.5, 0), Vector2.new(0, 0.5), 38)
			end

			actBtn.MouseButton1Click:Connect(function()
				if state.OwnedSkins[skin.Id] then
					state.EquippedSkin = skin.Id
					saveData()
					rebuildLobbyPreview()
					openShop()
				elseif skin.FreeOnly then
					showToast("Skin miễn phí độc quyền! Cách mở: " .. (skin.UnlockText or "Sự kiện"), THEME.TextGold, 3.0)
				else
					local bought = false
					if skin.Currency == "Coins" and state.Coins >= skin.Price then
						state.Coins -= skin.Price
						bought = true
					elseif skin.Currency == "Gems" and state.Gems >= skin.Price then
						state.Gems -= skin.Price
						bought = true
					elseif skin.Currency == "Rubies" and state.Rubies >= skin.Price then
						state.Rubies -= skin.Price
						bought = true
					end
					if bought then
						state.OwnedSkins[skin.Id] = true
						state.EquippedSkin = skin.Id
						updateTopStats()
						saveData()
						rebuildLobbyPreview()
						openShop()
					else
						actLbl.Text = "KHÔNG ĐỦ!"
						task.delay(0.8, function()
							if actLbl.Parent then actLbl.Text = btnText end
						end)
					end
				end
			end)
		end
	end
end

-- POPUP VONG QUAY MAY MAN (DO HOA CARTOON ARCADE 3D + DE VONG QUAY + DEN NHAP NHAY)
local wheelBulbs = {}
local function openWheel()
	openModal("Wheel", "VÒNG QUAY MAY MẮN", false)
	wheelBulbs = {}

	local stage = Instance.new("Frame")
	stage.Size = UDim2.new(1, 0, 0, 326)
	stage.BackgroundTransparency = 1
	stage.ZIndex = 33
	stage.Parent = UI.modalBody

	-- Hieu ung vong sang nen phia sau banh xe
	local aura = Instance.new("Frame")
	aura.Size = UDim2.fromOffset(274, 274)
	aura.Position = UDim2.fromOffset(8, 12)
	aura.BackgroundColor3 = Color3.fromRGB(168, 76, 224)
	aura.BackgroundTransparency = 0.78
	aura.BorderSizePixel = 0
	aura.ZIndex = 33
	aura.Parent = stage
	addCorner(aura, 999)

	-- De dung Vong Quay tim-vang 3D (giong mau)
	local standBase = Instance.new("Frame")
	standBase.Size = UDim2.fromOffset(172, 34)
	standBase.Position = UDim2.fromOffset(59, 266)
	standBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	standBase.BorderSizePixel = 0
	standBase.ZIndex = 34
	standBase.Parent = stage
	addCorner(standBase, 10)
	addStroke(standBase, THEME.Outline, 2.6)
	addGradient(standBase, Color3.fromRGB(152, 62, 224), Color3.fromRGB(82, 28, 158), 90)

	local standTrim = Instance.new("Frame")
	standTrim.Size = UDim2.new(1, -12, 0, 6)
	standTrim.Position = UDim2.fromOffset(6, 5)
	standTrim.BackgroundColor3 = Color3.fromRGB(228, 186, 48)
	standTrim.BorderSizePixel = 0
	standTrim.ZIndex = 35
	standTrim.Parent = standBase
	addCorner(standTrim, 4)

	local standFoot = Instance.new("Frame")
	standFoot.Size = UDim2.fromOffset(198, 14)
	standFoot.Position = UDim2.fromOffset(46, 294)
	standFoot.BackgroundColor3 = Color3.fromRGB(224, 174, 38)
	standFoot.BorderSizePixel = 0
	standFoot.ZIndex = 34
	standFoot.Parent = stage
	addCorner(standFoot, 7)
	addStroke(standFoot, THEME.Outline, 2.4)

	-- Vien vang kep ngoai cung
	local wheelBase = Instance.new("Frame")
	wheelBase.Size = UDim2.fromOffset(256, 256)
	wheelBase.Position = UDim2.fromOffset(17, 20)
	wheelBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	wheelBase.BorderSizePixel = 0
	wheelBase.ZIndex = 35
	wheelBase.Parent = stage
	addCorner(wheelBase, 999)
	addStroke(wheelBase, THEME.Outline, 3.2)
	addGradient(wheelBase, Color3.fromRGB(242, 208, 68), Color3.fromRGB(196, 122, 18), 90)

	local innerBezel = Instance.new("Frame")
	innerBezel.Size = UDim2.fromOffset(224, 224)
	innerBezel.Position = UDim2.fromScale(0.5, 0.5)
	innerBezel.AnchorPoint = Vector2.new(0.5, 0.5)
	innerBezel.BackgroundColor3 = Color3.fromRGB(152, 86, 16)
	innerBezel.BorderSizePixel = 0
	innerBezel.ZIndex = 35
	innerBezel.Parent = wheelBase
	addCorner(innerBezel, 999)
	addStroke(innerBezel, THEME.Outline, 2)

	-- 16 bong den led nhap nhay quanh vanh vang
	for i = 0, 15 do
		local ang = math.rad(i * 22.5)
		local lx = 128 + math.cos(ang) * 119
		local ly = 128 + math.sin(ang) * 119
		local bulb = Instance.new("Frame")
		bulb.Size = UDim2.fromOffset(9, 9)
		bulb.Position = UDim2.fromOffset(lx, ly)
		bulb.AnchorPoint = Vector2.new(0.5, 0.5)
		bulb.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(248, 240, 178) or Color3.fromRGB(224, 148, 42)
		bulb.BorderSizePixel = 0
		bulb.ZIndex = 36
		bulb.Parent = wheelBase
		addCorner(bulb, 99)
		addStroke(bulb, Color3.fromRGB(122, 68, 12), 1)
		table.insert(wheelBulbs, bulb)
	end

	-- Dia quay ben trong
	local disc = Instance.new("Frame")
	disc.Size = UDim2.fromOffset(214, 214)
	disc.Position = UDim2.fromScale(0.5, 0.5)
	disc.AnchorPoint = Vector2.new(0.5, 0.5)
	disc.BackgroundColor3 = Color3.fromRGB(36, 30, 74)
	disc.BorderSizePixel = 0
	disc.ClipsDescendants = true
	disc.ZIndex = 36
	disc.Parent = wheelBase
	addCorner(disc, 999)
	addStroke(disc, THEME.Outline, 2.4)

	-- 8 nan hoa vang chia deu 8 o thuong
	for i = 0, 3 do
		local spoke = Instance.new("Frame")
		spoke.Size = UDim2.fromOffset(3, 214)
		spoke.Position = UDim2.fromScale(0.5, 0.5)
		spoke.AnchorPoint = Vector2.new(0.5, 0.5)
		spoke.Rotation = 22.5 + (i * 45)
		spoke.BackgroundColor3 = Color3.fromRGB(226, 188, 56)
		spoke.BorderSizePixel = 0
		spoke.ZIndex = 38
		spoke.Parent = disc
	end

	-- 8 o thuong lon, mau ruc ro va icon tien te sac net
	for idx, slot in ipairs(WHEEL_SLOTS) do
		local deg = (idx - 1) * 45
		local rad = math.rad(deg - 90)
		local rDist = 66
		local sx = 107 + math.cos(rad) * rDist
		local sy = 107 + math.sin(rad) * rDist

		local pill = Instance.new("Frame")
		pill.Size = UDim2.fromOffset(62, 56)
		pill.Position = UDim2.fromOffset(sx, sy)
		pill.AnchorPoint = Vector2.new(0.5, 0.5)
		pill.Rotation = deg
		pill.BackgroundColor3 = slot.Color
		pill.BorderSizePixel = 0
		pill.ZIndex = 37
		pill.Parent = disc
		addCorner(pill, 12)
		addStroke(pill, THEME.Outline, 1.8)

		local pGloss = Instance.new("Frame")
		pGloss.Size = UDim2.new(0.84, 0, 0.34, 0)
		pGloss.Position = UDim2.new(0.08, 0, 0.06, 0)
		pGloss.BackgroundColor3 = Color3.fromRGB(240, 244, 250)
		pGloss.BackgroundTransparency = 0.72
		pGloss.BorderSizePixel = 0
		pGloss.ZIndex = 38
		pGloss.Parent = pill
		addCorner(pGloss, 6)

		GFX.makeCurrencyIcon(pill, slot.Kind, 20, UDim2.new(0.5, 0, 0, 16), Vector2.new(0.5, 0.5), 39)

		local vLbl = Instance.new("TextLabel")
		vLbl.Size = UDim2.new(1, -4, 0, 18)
		vLbl.Position = UDim2.new(0, 2, 1, -22)
		vLbl.BackgroundTransparency = 1
		vLbl.Text = slot.Label
		vLbl.TextColor3 = THEME.TextMain
		vLbl.Font = THEME.FontHead
		vLbl.TextSize = 11
		vLbl.ZIndex = 40
		vLbl.Parent = pill
		addTextOutline(vLbl, 1.5, THEME.Outline)
	end

	-- Tam giua ngoi sao vang 3D (giong anh mau)
	local hub = Instance.new("Frame")
	hub.Size = UDim2.fromOffset(52, 52)
	hub.Position = UDim2.fromScale(0.5, 0.5)
	hub.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hub.BorderSizePixel = 0
	hub.ZIndex = 42
	hub.Parent = wheelBase
	addCorner(hub, 99)
	addStroke(hub, THEME.Outline, 2.6)
	addGradient(hub, Color3.fromRGB(244, 212, 72), Color3.fromRGB(196, 128, 22), 90)

	for _, rot in ipairs({ 0, 45 }) do
		local st = Instance.new("Frame")
		st.Size = UDim2.fromOffset(22, 22)
		st.Position = UDim2.fromScale(0.5, 0.5)
		st.AnchorPoint = Vector2.new(0.5, 0.5)
		st.Rotation = rot
		st.BackgroundColor3 = Color3.fromRGB(246, 224, 96)
		st.BorderSizePixel = 0
		st.ZIndex = 43
		st.Parent = hub
		addCorner(st, 4)
		addStroke(st, Color3.fromRGB(132, 74, 14), 1.4)
	end

	-- Mui ten do-vang chi xuong o trung thuong
	local pointer = Instance.new("Frame")
	pointer.Size = UDim2.fromOffset(28, 28)
	pointer.Position = UDim2.new(0.5, 0, 0, -4)
	pointer.AnchorPoint = Vector2.new(0.5, 0.5)
	pointer.Rotation = 45
	pointer.BackgroundColor3 = Color3.fromRGB(224, 46, 52)
	pointer.BorderSizePixel = 0
	pointer.ZIndex = 44
	pointer.Parent = wheelBase
	addCorner(pointer, 5)
	addStroke(pointer, THEME.Outline, 2.6)

	local pDot = Instance.new("Frame")
	pDot.Size = UDim2.fromOffset(10, 10)
	pDot.Position = UDim2.fromScale(0.5, 0.5)
	pDot.AnchorPoint = Vector2.new(0.5, 0.5)
	pDot.BackgroundColor3 = Color3.fromRGB(242, 206, 62)
	pDot.BorderSizePixel = 0
	pDot.ZIndex = 45
	pDot.Parent = pointer
	addCorner(pDot, 99)

	-- Bang thong tin & nut Quay ben phai
	local infoPanel = Instance.new("Frame")
	infoPanel.Size = UDim2.fromOffset(252, 286)
	infoPanel.Position = UDim2.fromOffset(296, 18)
	infoPanel.BackgroundColor3 = Color3.fromRGB(24, 28, 52)
	infoPanel.BorderSizePixel = 0
	infoPanel.ZIndex = 34
	infoPanel.Parent = stage
	addCorner(infoPanel, 14)
	addStroke(infoPanel, Color3.fromRGB(118, 76, 206), 2.2)
	addGradient(infoPanel, Color3.fromRGB(32, 34, 68), Color3.fromRGB(18, 20, 40), 90)

	local spinsPill = Instance.new("Frame")
	spinsPill.Size = UDim2.new(1, -24, 0, 38)
	spinsPill.Position = UDim2.fromOffset(12, 14)
	spinsPill.BackgroundColor3 = Color3.fromRGB(16, 20, 38)
	spinsPill.BorderSizePixel = 0
	spinsPill.ZIndex = 35
	spinsPill.Parent = infoPanel
	addCorner(spinsPill, 12)
	addStroke(spinsPill, Color3.fromRGB(186, 144, 42), 1.8)

	local spinsLbl = Instance.new("TextLabel")
	spinsLbl.Size = UDim2.fromScale(1, 1)
	spinsLbl.BackgroundTransparency = 1
	spinsLbl.Text = "Lượt quay: " .. formatNum(state.Spins + state.FreeSpins)
	spinsLbl.TextColor3 = THEME.TextGold
	spinsLbl.Font = THEME.FontHead
	spinsLbl.TextSize = 15
	spinsLbl.ZIndex = 36
	spinsLbl.Parent = spinsPill
	addTextOutline(spinsLbl, 1.6, THEME.Outline)
	UI.liveWheelSpinsLbl = spinsLbl

	local tipLbl = Instance.new("TextLabel")
	tipLbl.Size = UDim2.new(1, -20, 0, 58)
	tipLbl.Position = UDim2.fromOffset(10, 58)
	tipLbl.BackgroundTransparency = 1
	local remFree = math.max(0, state.NextFreeSpinUnix - os.time())
	local freeStr = (state.FreeSpins >= FREE_SPIN_MAX)
		and ("Miễn phí: " .. state.FreeSpins .. "/15  •  Đã đầy")
		or ("Miễn phí: " .. state.FreeSpins .. "/15  •  Hồi sau " .. formatMMSS(remFree))
	tipLbl.Text = freeStr .. "\n15 phút tặng 1 lượt, cộng dồn tối đa 15\nCó cơ hội trúng Hồng Ngọc cực hiếm"
	tipLbl.TextColor3 = THEME.TextMuted
	tipLbl.Font = THEME.FontBody
	tipLbl.TextSize = 11
	tipLbl.TextWrapped = true
	tipLbl.ZIndex = 35
	tipLbl.Parent = infoPanel
	UI.liveWheelTimerLbl = tipLbl

	local resultBox = Instance.new("Frame")
	resultBox.Size = UDim2.new(1, -24, 0, 62)
	resultBox.Position = UDim2.fromOffset(12, 114)
	resultBox.BackgroundColor3 = Color3.fromRGB(15, 18, 36)
	resultBox.BorderSizePixel = 0
	resultBox.ZIndex = 35
	resultBox.Parent = infoPanel
	addCorner(resultBox, 12)
	addStroke(resultBox, Color3.fromRGB(78, 88, 142), 1.8)

	local resultLbl = Instance.new("TextLabel")
	resultLbl.Size = UDim2.new(1, -12, 1, 0)
	resultLbl.Position = UDim2.fromOffset(6, 0)
	resultLbl.BackgroundTransparency = 1
	resultLbl.Text = "Chọn QUAY x1, x5 hoặc x10 để thử vận may"
	resultLbl.TextColor3 = THEME.TextMain
	resultLbl.Font = THEME.FontHead
	resultLbl.TextSize = 11
	resultLbl.TextWrapped = true
	resultLbl.ZIndex = 36
	resultLbl.Parent = resultBox

	local spin1Btn, spin1Lbl = makeArcadeBtn(
		infoPanel, "QUAY x1",
		UDim2.new(1, -24, 0, 44), UDim2.fromOffset(12, 184),
		Color3.fromRGB(74, 210, 66), Color3.fromRGB(28, 144, 44), 13,
		{ TextSize = 15, ZIndex = 36, Depth = 4, Stroke = 2.2 }
	)
	local spin5Btn, spin5Lbl = makeArcadeBtn(
		infoPanel, "QUAY x5",
		UDim2.fromOffset(110, 42), UDim2.fromOffset(12, 234),
		Color3.fromRGB(218, 152, 38), Color3.fromRGB(168, 88, 18), 12,
		{ TextSize = 13, ZIndex = 36, Depth = 4, Stroke = 2.0 }
	)
	local spin10Btn, spin10Lbl = makeArcadeBtn(
		infoPanel, "QUAY x10",
		UDim2.fromOffset(110, 42), UDim2.fromOffset(130, 234),
		Color3.fromRGB(186, 68, 218), Color3.fromRGB(118, 32, 174), 12,
		{ TextSize = 13, ZIndex = 36, Depth = 4, Stroke = 2.0 }
	)

	local function runSpin(times)
		if wheelSpinning then return end
		updateFreeSpinsTick()
		local avail = state.Spins + state.FreeSpins
		if avail < times then
			resultLbl.Text = "Cần ít nhất " .. tostring(times) .. " lượt quay! Hiện có: " .. formatNum(avail)
			resultLbl.TextColor3 = THEME.TextRed
			return
		end
		wheelSpinning = true
		local useFree = math.min(state.FreeSpins, times)
		if useFree > 0 then
			local wasFull = (state.FreeSpins >= FREE_SPIN_MAX)
			state.FreeSpins -= useFree
			if wasFull and state.FreeSpins < FREE_SPIN_MAX then
				state.NextFreeSpinUnix = os.time() + FREE_SPIN_INTERVAL
			end
		end
		local usePaid = times - useFree
		if usePaid > 0 then
			state.Spins = math.max(0, state.Spins - usePaid)
		end

		spinsLbl.Text = "Lượt quay: " .. formatNum(state.Spins + state.FreeSpins)
		spin1Lbl.Text = "ĐANG QUAY..."
		spin5Lbl.Text = "..."
		spin10Lbl.Text = "..."
		resultLbl.Text = (times > 1) and ("Đang quay x" .. tostring(times) .. "...") or "Chúc may mắn..."
		resultLbl.TextColor3 = THEME.TextGold
		refreshNotifDots()
		saveData()

		local totalW = 0
		for _, s in ipairs(WHEEL_SLOTS) do totalW += s.Weight end
		local sumC, sumG, sumR = 0, 0, 0
		local bestIdx, bestRank = 1, 0
		for _ = 1, times do
			local roll = math.random(1, totalW)
			local acc, pIdx = 0, 1
			for idx, s in ipairs(WHEEL_SLOTS) do
				acc += s.Weight
				if roll <= acc then pIdx = idx break end
			end
			local pr = WHEEL_SLOTS[pIdx]
			local rank = (pr.Kind == "Rubies" and (1000 + pr.Amount)) or (pr.Kind == "Gems" and (100 + pr.Amount)) or pr.Amount
			if rank >= bestRank then
				bestRank = rank
				bestIdx = pIdx
			end
			if pr.Kind == "Coins" then sumC += pr.Amount
			elseif pr.Kind == "Gems" then sumG += pr.Amount
			elseif pr.Kind == "Rubies" then sumR += pr.Amount end
		end

		local targetAngle = -((bestIdx - 1) * 45)
		local finalRot = (math.floor(disc.Rotation / 360) * 360) + (360 * (times > 1 and 6 or 5)) + targetAngle
		local dur = (times > 1) and 2.6 or 3.1

		local tw = TweenService:Create(
			disc,
			TweenInfo.new(dur, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{ Rotation = finalRot }
		)
		tw:Play()
		tw.Completed:Connect(function()
			wheelSpinning = false
			state.Coins  += sumC
			state.Gems   += sumG
			state.Rubies += sumR
			updateTopStats()
			saveData()
			local parts = {}
			if sumC > 0 then table.insert(parts, "+" .. formatNum(sumC) .. " Xu") end
			if sumG > 0 then table.insert(parts, "+" .. formatNum(sumG) .. " KC") end
			if sumR > 0 then table.insert(parts, "+" .. formatNum(sumR) .. " Hồng Ngọc") end
			local summary = table.concat(parts, " • ")
			if resultLbl.Parent then
				resultLbl.Text = ((times > 1) and ("QUAY x" .. tostring(times) .. " TRÚNG:\n") or "TRÚNG THƯỞNG:\n") .. summary
				resultLbl.TextColor3 = (sumR > 0) and THEME.TextRuby or THEME.TextGreen
			end
			showToast("Vòng quay x" .. tostring(times) .. ": " .. summary, (sumR > 0) and THEME.TextRuby or THEME.TextGreen, 3.0)
			if spin1Lbl.Parent then spin1Lbl.Text = "QUAY x1" end
			if spin5Lbl.Parent then spin5Lbl.Text = "QUAY x5" end
			if spin10Lbl.Parent then spin10Lbl.Text = "QUAY x10" end
		end)
	end

	spin1Btn.MouseButton1Click:Connect(function() runSpin(1) end)
	spin5Btn.MouseButton1Click:Connect(function() runSpin(5) end)
	spin10Btn.MouseButton1Click:Connect(function() runSpin(10) end)
end

-- POPUP QUA TANG CAP DO (BAM VAO KHUNG LV TREN THANH DAU TRANG)
local function openLevelRewards()
	openModal("Levels", "QUÀ TĂNG CẤP  •  CẤP " .. tostring(state.Level) .. "/" .. tostring(MAX_LEVEL), false)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = UI.modalBody

	for _, m in ipairs(LEVEL_REWARDS) do
		local key = tostring(m.Level)
		local claimed = (state.ClaimedLevels[key] == true)
		local unlocked = (state.Level >= m.Level)
		local canClaim = unlocked and not claimed

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 56)
		row.BackgroundColor3 = Color3.fromRGB(26, 30, 54)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = UI.modalBody
		addCorner(row, 10)
		addStroke(row, canClaim and THEME.TextGreen or Color3.fromRGB(68, 76, 118), canClaim and 2 or 1.5)

		local lvPill = Instance.new("Frame")
		lvPill.Size = UDim2.fromOffset(66, 34)
		lvPill.Position = UDim2.fromOffset(10, 11)
		lvPill.BackgroundColor3 = unlocked and Color3.fromRGB(116, 62, 198) or Color3.fromRGB(36, 40, 66)
		lvPill.BorderSizePixel = 0
		lvPill.ZIndex = 34
		lvPill.Parent = row
		addCorner(lvPill, 8)
		addStroke(lvPill, THEME.Outline, 1.5)

		local lvTxt = Instance.new("TextLabel")
		lvTxt.Size = UDim2.fromScale(1, 1)
		lvTxt.BackgroundTransparency = 1
		lvTxt.Text = "Cấp " .. tostring(m.Level)
		lvTxt.TextColor3 = THEME.TextGold
		lvTxt.Font = THEME.FontHead
		lvTxt.TextSize = 12
		lvTxt.ZIndex = 35
		lvTxt.Parent = lvPill

		local dLbl = Instance.new("TextLabel")
		dLbl.Size = UDim2.fromOffset(320, 44)
		dLbl.Position = UDim2.fromOffset(86, 6)
		dLbl.BackgroundTransparency = 1
		dLbl.Text = m.Desc
		dLbl.TextColor3 = m.SkinId and THEME.TextGold or THEME.TextMain
		dLbl.Font = m.SkinId and THEME.FontHead or THEME.FontBody
		dLbl.TextSize = 13
		dLbl.TextXAlignment = Enum.TextXAlignment.Left
		dLbl.TextWrapped = true
		dLbl.ZIndex = 34
		dLbl.Parent = row

		local btnText = claimed and "ĐÃ NHẬN" or (canClaim and "NHẬN QUÀ" or "CHƯA ĐẠT")
		local cBtn = makeArcadeBtn(
			row, btnText,
			UDim2.fromOffset(124, 36), UDim2.new(1, -134, 0, 10),
			canClaim and Color3.fromRGB(64, 194, 92) or Color3.fromRGB(76, 86, 116),
			canClaim and Color3.fromRGB(28, 134, 58) or Color3.fromRGB(52, 58, 82),
			9,
			{ TextSize = 11, ZIndex = 35, Depth = 3, Stroke = 1.8 }
		)
		cBtn.MouseButton1Click:Connect(function()
			if not canClaim then return end
			state.ClaimedLevels[key] = true
			if m.Coins then state.Coins += m.Coins end
			if m.Gems then state.Gems += m.Gems end
			if m.Rubies then state.Rubies += m.Rubies end
			if m.Spins then state.Spins += m.Spins end
			if m.SkinId then
				if state.OwnedSkins[m.SkinId] then
					if m.AltCoins then state.Coins += m.AltCoins end
					if m.AltGems then state.Gems += m.AltGems end
					if m.AltRubies then state.Rubies += m.AltRubies end
				else
					state.OwnedSkins[m.SkinId] = true
				end
			end
			updateTopStats()
			saveData()
			openLevelRewards()
		end)
	end
end

local activeGiftTab = "Online"

local function openGift()
	local titleStr = (activeGiftTab == "Daily")
		and ("ĐIỂM DANH 7 NGÀY  •  NGÀY " .. tostring(state.DailyDay) .. "/7")
		or ("QUÀ ONLINE  •  " .. formatMMSS(state.OnlineSeconds))
	openModal("Gift", titleStr, false)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = UI.modalBody

	-- THANH CHUYEN TAB: QUA ONLINE / DIEM DANH 7 NGAY
	local tabRow = Instance.new("Frame")
	tabRow.Size = UDim2.new(1, -2, 0, 38)
	tabRow.BackgroundTransparency = 1
	tabRow.ZIndex = 33
	tabRow.Parent = UI.modalBody

	local onlineTabBtn = makeArcadeBtn(
		tabRow, "QUÀ ONLINE",
		UDim2.new(0.49, 0, 0, 34), UDim2.fromOffset(0, 2),
		(activeGiftTab == "Online") and Color3.fromRGB(168, 62, 214) or Color3.fromRGB(48, 54, 86),
		(activeGiftTab == "Online") and Color3.fromRGB(108, 32, 168) or Color3.fromRGB(30, 34, 58),
		10, { TextSize = 12, ZIndex = 35, Depth = 3, Stroke = 1.8 }
	)
	local dailyTabBtn = makeArcadeBtn(
		tabRow, canClaimDailyToday() and "ĐIỂM DANH 7 NGÀY • MỚI" or "ĐIỂM DANH 7 NGÀY",
		UDim2.new(0.49, 0, 0, 34), UDim2.new(0.51, 0, 0, 2),
		(activeGiftTab == "Daily") and Color3.fromRGB(168, 62, 214) or Color3.fromRGB(48, 54, 86),
		(activeGiftTab == "Daily") and Color3.fromRGB(108, 32, 168) or Color3.fromRGB(30, 34, 58),
		10, { TextSize = 12, ZIndex = 35, Depth = 3, Stroke = 1.8 }
	)
	onlineTabBtn.MouseButton1Click:Connect(function()
		activeGiftTab = "Online"
		openGift()
	end)
	dailyTabBtn.MouseButton1Click:Connect(function()
		activeGiftTab = "Daily"
		openGift()
	end)

	if activeGiftTab == "Daily" then
		local today = getTodayKey()
		local claimedToday = (state.LastDailyDate == today)
		local nextDay = (state.DailyDay % 7) + 1

		for _, d in ipairs(DAILY_REWARDS) do
			local isDone = (state.DailyDay >= d.Day) and not (state.DailyDay == 7 and not claimedToday)
			local canClaim = (not claimedToday) and (d.Day == nextDay)

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -2, 0, 56)
			row.BackgroundColor3 = Color3.fromRGB(26, 30, 54)
			row.BorderSizePixel = 0
			row.ZIndex = 33
			row.Parent = UI.modalBody
			addCorner(row, 10)
			addStroke(row, canClaim and THEME.TextGreen or (d.SkinId and THEME.TextGold or Color3.fromRGB(68, 76, 118)), canClaim and 2.2 or 1.5)

			local dPill = Instance.new("Frame")
			dPill.Size = UDim2.fromOffset(74, 34)
			dPill.Position = UDim2.fromOffset(10, 11)
			dPill.BackgroundColor3 = isDone and Color3.fromRGB(42, 148, 76) or (canClaim and Color3.fromRGB(178, 126, 32) or Color3.fromRGB(36, 40, 66))
			dPill.BorderSizePixel = 0
			dPill.ZIndex = 34
			dPill.Parent = row
			addCorner(dPill, 8)
			addStroke(dPill, THEME.Outline, 1.5)

			local dTxt = Instance.new("TextLabel")
			dTxt.Size = UDim2.fromScale(1, 1)
			dTxt.BackgroundTransparency = 1
			dTxt.Text = "Ngày " .. tostring(d.Day)
			dTxt.TextColor3 = THEME.TextGold
			dTxt.Font = THEME.FontHead
			dTxt.TextSize = 12
			dTxt.ZIndex = 35
			dTxt.Parent = dPill

			local descLbl = Instance.new("TextLabel")
			descLbl.Size = UDim2.fromOffset(312, 44)
			descLbl.Position = UDim2.fromOffset(92, 6)
			descLbl.BackgroundTransparency = 1
			descLbl.Text = d.Desc
			descLbl.TextColor3 = d.SkinId and THEME.TextGold or ((d.Rubies > 0) and THEME.TextRuby or THEME.TextMain)
			descLbl.Font = THEME.FontHead
			descLbl.TextSize = 12
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.TextWrapped = true
			descLbl.ZIndex = 34
			descLbl.Parent = row

			local btnText = isDone and "ĐÃ NHẬN" or (canClaim and "ĐIỂM DANH" or "CHƯA TỚI")
			local cBtn = makeArcadeBtn(
				row, btnText,
				UDim2.fromOffset(124, 36), UDim2.new(1, -134, 0, 10),
				canClaim and Color3.fromRGB(64, 194, 92) or Color3.fromRGB(76, 86, 116),
				canClaim and Color3.fromRGB(28, 134, 58) or Color3.fromRGB(52, 58, 82),
				9, { TextSize = 11, ZIndex = 35, Depth = 3, Stroke = 1.8 }
			)
			cBtn.MouseButton1Click:Connect(function()
				if not canClaim then return end
				state.DailyDay = d.Day
				state.LastDailyDate = today
				state.Coins  += (d.Coins or 0)
				state.Gems   += (d.Gems or 0)
				state.Rubies += (d.Rubies or 0)
				state.Spins  += (d.Spins or 0)
				if d.SkinId then
					if state.OwnedSkins[d.SkinId] then
						state.Coins += (d.AltCoins or 0)
					else
						state.OwnedSkins[d.SkinId] = true
					end
				end
				updateTopStats()
				saveData()
				showToast("Điểm danh Ngày " .. tostring(d.Day) .. ": " .. d.Desc, THEME.TextGreen, 3.2)
				openGift()
			end)
		end
		return
	end

	local allClaimed = true
	for _, r in ipairs(ONLINE_REWARDS) do
		local claimed = (state.ClaimedOnline[r.Id] == true)
		if not claimed then allClaimed = false end
		local ready = (state.OnlineSeconds >= r.Secs)
		local canClaim = ready and not claimed

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 56)
		row.BackgroundColor3 = Color3.fromRGB(26, 30, 54)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = UI.modalBody
		addCorner(row, 10)
		addStroke(row, canClaim and THEME.TextGreen or Color3.fromRGB(68, 76, 118), canClaim and 2 or 1.5)

		local tPill = Instance.new("Frame")
		tPill.Size = UDim2.fromOffset(74, 34)
		tPill.Position = UDim2.fromOffset(10, 11)
		tPill.BackgroundColor3 = ready and Color3.fromRGB(168, 56, 132) or Color3.fromRGB(36, 40, 66)
		tPill.BorderSizePixel = 0
		tPill.ZIndex = 34
		tPill.Parent = row
		addCorner(tPill, 8)
		addStroke(tPill, THEME.Outline, 1.5)

		local tTxt = Instance.new("TextLabel")
		tTxt.Size = UDim2.fromScale(1, 1)
		tTxt.BackgroundTransparency = 1
		tTxt.Text = r.Label
		tTxt.TextColor3 = THEME.TextGold
		tTxt.Font = THEME.FontHead
		tTxt.TextSize = 12
		tTxt.ZIndex = 35
		tTxt.Parent = tPill

		local dLbl = Instance.new("TextLabel")
		dLbl.Size = UDim2.fromOffset(312, 44)
		dLbl.Position = UDim2.fromOffset(92, 6)
		dLbl.BackgroundTransparency = 1
		dLbl.Text = r.Desc
		dLbl.TextColor3 = r.SkinId and THEME.TextGold or ((r.Rubies > 0) and THEME.TextRuby or THEME.TextMain)
		dLbl.Font = THEME.FontHead
		dLbl.TextSize = 12
		dLbl.TextXAlignment = Enum.TextXAlignment.Left
		dLbl.TextWrapped = true
		dLbl.ZIndex = 34
		dLbl.Parent = row

		local remain = math.max(0, r.Secs - state.OnlineSeconds)
		local btnText = claimed and "ĐÃ NHẬN" or (canClaim and "NHẬN QUÀ" or formatMMSS(remain))
		local cBtn = makeArcadeBtn(
			row, btnText,
			UDim2.fromOffset(124, 36), UDim2.new(1, -134, 0, 10),
			canClaim and Color3.fromRGB(64, 194, 92) or Color3.fromRGB(76, 86, 116),
			canClaim and Color3.fromRGB(28, 134, 58) or Color3.fromRGB(52, 58, 82),
			9,
			{ TextSize = 11, ZIndex = 35, Depth = 3, Stroke = 1.8 }
		)
		cBtn.MouseButton1Click:Connect(function()
			if not canClaim then return end
			state.ClaimedOnline[r.Id] = true
			state.Coins  += r.Coins
			state.Gems   += r.Gems
			state.Rubies += r.Rubies
			state.Spins  += r.Spins
			if r.SkinId then
				if state.OwnedSkins[r.SkinId] then
					state.Gems += (r.AltGems or 0)
				else
					state.OwnedSkins[r.SkinId] = true
				end
			end
			updateTopStats()
			saveData()
			showToast("Nhận quà Online " .. r.Label .. ": " .. r.Desc, THEME.TextGreen, 3.0)
			openGift()
		end)
	end

	if allClaimed then
		local refRow = Instance.new("Frame")
		refRow.Size = UDim2.new(1, -2, 0, 50)
		refRow.BackgroundColor3 = Color3.fromRGB(26, 32, 58)
		refRow.BorderSizePixel = 0
		refRow.ZIndex = 33
		refRow.Parent = UI.modalBody
		addCorner(refRow, 10)

		local rBtn = makeArcadeBtn(
			refRow, "LÀM MỚI CHUỖI QUÀ ONLINE",
			UDim2.fromOffset(260, 36), UDim2.new(0.5, -130, 0.5, -18),
			Color3.fromRGB(196, 62, 146), Color3.fromRGB(132, 30, 96), 10,
			{ TextSize = 12, ZIndex = 35, Depth = 3 }
		)
		rBtn.MouseButton1Click:Connect(function()
			state.OnlineSeconds = 0
			state.ClaimedOnline = {}
			saveData()
			refreshNotifDots()
			openGift()
		end)
	end
end

-- POPUP 8 NHIEM VU (CO THUONG LUOT QUAY + BIEU TUONG TIEN TE VECTOR)
local function openQuests()
	openModal("Quests", "NHIỆM VỤ NHẬN THƯỞNG", false)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = UI.modalBody

	local allClaimed = true
	for _, q in ipairs(state.Quests) do
		if not q.Claimed then allClaimed = false end
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 58)
		row.BackgroundColor3 = Color3.fromRGB(26, 30, 54)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = UI.modalBody
		addCorner(row, 10)
		addStroke(row, Color3.fromRGB(68, 76, 118), 1.6)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.fromOffset(370, 22)
		title.Position = UDim2.fromOffset(12, 6)
		title.BackgroundTransparency = 1
		title.Text = q.Title .. "  •  " .. math.min(q.Progress, q.Goal) .. "/" .. q.Goal .. "  •  +" .. tostring(q.Spins or 1) .. " Quay"
		title.TextColor3 = THEME.TextMain
		title.Font = THEME.FontBody
		title.TextSize = 12
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 34
		title.Parent = row

		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.fromOffset(356, 10)
		barBg.Position = UDim2.fromOffset(12, 36)
		barBg.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
		barBg.BorderSizePixel = 0
		barBg.ZIndex = 34
		barBg.Parent = row
		addCorner(barBg, 5)
		addStroke(barBg, THEME.Outline, 1.2)

		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.fromScale(math.clamp(q.Progress / q.Goal, 0, 1), 1)
		barFill.BackgroundColor3 = Color3.fromRGB(64, 190, 102)
		barFill.BorderSizePixel = 0
		barFill.ZIndex = 35
		barFill.Parent = barBg
		addCorner(barFill, 5)

		local canClaim = (q.Progress >= q.Goal) and not q.Claimed
		local btnText = q.Claimed and "ĐÃ NHẬN" or (canClaim and ("+" .. formatNum(q.Reward)) or formatNum(q.Reward))
		local btnOpts = { TextSize = 12, ZIndex = 35, Depth = 3, Stroke = 1.8 }
		if not q.Claimed then
			btnOpts.LabelPos = UDim2.fromOffset(14, 0)
			btnOpts.LabelSize = UDim2.new(1, -18, 1, 0)
		end
		local cBtn, _, cFace = makeArcadeBtn(
			row, btnText,
			UDim2.fromOffset(148, 38), UDim2.new(1, -158, 0, 10),
			canClaim and Color3.fromRGB(64, 194, 92) or Color3.fromRGB(76, 86, 116),
			canClaim and Color3.fromRGB(28, 134, 58) or Color3.fromRGB(52, 58, 82),
			9, btnOpts
		)
		if not q.Claimed then
			GFX.makeCurrencyIcon(cFace, q.Currency, 17, UDim2.new(0, 22, 0.5, 0), Vector2.new(0, 0.5), 38)
		end

		cBtn.MouseButton1Click:Connect(function()
			if not canClaim then return end
			q.Claimed = true
			if q.Currency == "Gems" then
				state.Gems += q.Reward
			elseif q.Currency == "Rubies" then
				state.Rubies += q.Reward
			else
				state.Coins += q.Reward
			end
			state.Spins += (q.Spins or 1)
			addExp(45)
			openQuests()
		end)
	end

	if allClaimed then
		local refreshRow = Instance.new("Frame")
		refreshRow.Size = UDim2.new(1, -2, 0, 50)
		refreshRow.BackgroundColor3 = Color3.fromRGB(26, 32, 58)
		refreshRow.BorderSizePixel = 0
		refreshRow.ZIndex = 33
		refreshRow.Parent = UI.modalBody
		addCorner(refreshRow, 10)

		local rBtn = makeArcadeBtn(
			refreshRow, "LÀM MỚI BỘ NHIỆM VỤ",
			UDim2.fromOffset(260, 36), UDim2.new(0.5, -130, 0.5, -18),
			Color3.fromRGB(154, 82, 214), Color3.fromRGB(100, 38, 172), 10,
			{ TextSize = 12, ZIndex = 35, Depth = 3 }
		)
		rBtn.MouseButton1Click:Connect(function()
			state.Quests = createDefaultQuests()
			saveData()
			refreshNotifDots()
			openQuests()
		end)
	end
end

-- Forward declaration for layout updater
local applyGameLayout = nil

-- POPUP CAI DAT (CO NHAP GIFTCODE + CHE DO TAY TRAI / TAY PHAI + FULL MAN HINH)
local function openSettings()
	openModal("Settings", "CÀI ĐẶT", false)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = UI.modalBody

	-- O NHAP GIFTCODE
	local codeCard = Instance.new("Frame")
	codeCard.Size = UDim2.new(1, -2, 0, 96)
	codeCard.BackgroundColor3 = Color3.fromRGB(28, 32, 60)
	codeCard.BorderSizePixel = 0
	codeCard.ZIndex = 33
	codeCard.Parent = UI.modalBody
	addCorner(codeCard, 10)
	addStroke(codeCard, Color3.fromRGB(118, 76, 206), 1.6)

	local codeTitle = Instance.new("TextLabel")
	codeTitle.Size = UDim2.new(1, -20, 0, 18)
	codeTitle.Position = UDim2.fromOffset(12, 6)
	codeTitle.BackgroundTransparency = 1
	codeTitle.Text = "Nhập mã quà tặng"
	codeTitle.TextColor3 = THEME.TextGold
	codeTitle.Font = THEME.FontHead
	codeTitle.TextSize = 12
	codeTitle.TextXAlignment = Enum.TextXAlignment.Left
	codeTitle.ZIndex = 34
	codeTitle.Parent = codeCard

	local codeBox = Instance.new("TextBox")
	codeBox.Size = UDim2.new(1, -156, 0, 34)
	codeBox.Position = UDim2.fromOffset(12, 28)
	codeBox.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
	codeBox.BorderSizePixel = 0
	codeBox.PlaceholderText = "Nhập mã tại đây..."
	codeBox.PlaceholderColor3 = THEME.TextMuted
	codeBox.Text = ""
	codeBox.TextColor3 = THEME.TextMain
	codeBox.Font = THEME.FontHead
	codeBox.TextSize = 13
	codeBox.ClearTextOnFocus = false
	codeBox.ZIndex = 34
	codeBox.Parent = codeCard
	addCorner(codeBox, 8)
	addStroke(codeBox, Color3.fromRGB(72, 82, 128), 1.4)

	local codeStatusLbl = Instance.new("TextLabel")
	codeStatusLbl.Size = UDim2.new(1, -24, 0, 26)
	codeStatusLbl.Position = UDim2.fromOffset(12, 66)
	codeStatusLbl.BackgroundTransparency = 1
	codeStatusLbl.Text = "Nhập code rồi bấm NHẬN CODE để xem phần thưởng"
	codeStatusLbl.TextColor3 = THEME.TextMuted
	codeStatusLbl.Font = THEME.FontBody
	codeStatusLbl.TextSize = 11
	codeStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
	codeStatusLbl.TextWrapped = true
	codeStatusLbl.ZIndex = 34
	codeStatusLbl.Parent = codeCard

	local redeemBtn = makeArcadeBtn(
		codeCard, "NHẬN CODE",
		UDim2.fromOffset(124, 36), UDim2.new(1, -136, 0, 27),
		Color3.fromRGB(64, 194, 92), Color3.fromRGB(28, 134, 58), 9,
		{ TextSize = 12, ZIndex = 35, Depth = 3, Stroke = 1.8 }
	)
	redeemBtn.MouseButton1Click:Connect(function()
		local rawCode = string.upper(string.gsub(codeBox.Text or "", "%s+", ""))
		if rawCode == "" then
			codeStatusLbl.Text = "Vui lòng nhập mã quà tặng"
			codeStatusLbl.TextColor3 = THEME.TextRed
			showToast("Vui lòng nhập mã quà tặng!", THEME.TextRed, 2.5)
			return
		end
		local reward = GIFT_CODES[rawCode]
		if not reward then
			codeStatusLbl.Text = "Mã không tồn tại hoặc sai chính tả"
			codeStatusLbl.TextColor3 = THEME.TextRed
			showToast("Mã không hợp lệ: " .. rawCode, THEME.TextRed, 2.5)
			return
		end
		if state.UsedCodes[rawCode] then
			codeStatusLbl.Text = "Bạn đã sử dụng mã này rồi"
			codeStatusLbl.TextColor3 = THEME.TextRed
			showToast("Bạn đã dùng mã " .. rawCode .. " rồi!", THEME.TextRed, 2.5)
			return
		end
		if reward.IsAdmin then
			state.Coins  = math.max(state.Coins, reward.Coins)
			state.Gems   = math.max(state.Gems, reward.Gems)
			state.Rubies = math.max(state.Rubies, reward.Rubies)
			state.Spins  = math.max(state.Spins, reward.Spins)
			if reward.MaxLevel then
				state.Level = MAX_LEVEL
				state.ExpNeed = expNeedForLevel(MAX_LEVEL)
				state.Exp = state.ExpNeed
			end
			if reward.UnlockAllSkins then
				for _, sk in ipairs(SKINS) do
					state.OwnedSkins[sk.Id] = true
				end
			end
			if reward.EquipSkin then
				state.OwnedSkins[reward.EquipSkin] = true
				state.EquippedSkin = reward.EquipSkin
			end
			rebuildLobbyPreview()
		else
			state.UsedCodes[rawCode] = true
			state.Coins  += (reward.Coins or 0)
			state.Gems   += (reward.Gems or 0)
			state.Rubies += (reward.Rubies or 0)
			state.Spins  += (reward.Spins or 0)
			if reward.SkinId then
				state.OwnedSkins[reward.SkinId] = true
				state.EquippedSkin = reward.SkinId
				rebuildLobbyPreview()
			end
		end
		codeBox.Text = ""
		codeStatusLbl.Text = "Đã nhận: " .. reward.Desc
		codeStatusLbl.TextColor3 = THEME.TextGreen
		showToast("Nhận code thành công: " .. reward.Desc, THEME.TextGreen, 4.0)
		updateTopStats()
		saveData()
	end)

	local function addSettingRow(labelTxt, getText, onToggle, c1, c2)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 48)
		row.BackgroundColor3 = Color3.fromRGB(26, 30, 54)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = UI.modalBody
		addCorner(row, 10)
		addStroke(row, Color3.fromRGB(64, 72, 112), 1.4)

		local l = Instance.new("TextLabel")
		l.Size = UDim2.fromOffset(350, 48)
		l.Position = UDim2.fromOffset(12, 0)
		l.BackgroundTransparency = 1
		l.Text = labelTxt
		l.TextColor3 = THEME.TextMain
		l.Font = THEME.FontBody
		l.TextSize = 13
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = 34
		l.Parent = row

		local b, bLbl = makeArcadeBtn(
			row, getText(),
			UDim2.fromOffset(154, 34), UDim2.new(1, -164, 0, 7),
			c1 or Color3.fromRGB(54, 156, 210), c2 or Color3.fromRGB(32, 92, 178), 9,
			{ TextSize = 11, ZIndex = 35, Depth = 3, Stroke = 1.8 }
		)
		b.MouseButton1Click:Connect(function()
			onToggle(bLbl)
			bLbl.Text = getText()
		end)
	end

	addSettingRow("Vị trí cụm nút điều khiển", function()
		return state.Settings.LeftHanded and "Tay trái" or "Tay phải"
	end, function()
		state.Settings.LeftHanded = not state.Settings.LeftHanded
		if applyGameLayout then applyGameLayout() end
		saveData()
	end)

	addSettingRow("Chế độ màn hình", function()
		return state.Settings.FullScreen and "Toàn màn hình" or "Cửa sổ lớn"
	end, function()
		state.Settings.FullScreen = not state.Settings.FullScreen
		UI.fullLbl.Text = state.Settings.FullScreen and "><" or "[ ]"
		applyWindowScale()
		saveData()
	end)

	addSettingRow("Chế độ Xuyên Tường", function()
		return state.Settings.WallPass and "BẬT" or "TẮT"
	end, function()
		state.Settings.WallPass = not state.Settings.WallPass
		saveData()
	end)

	local speedNames = { "Chậm", "Vừa", "Nhanh" }
	addSettingRow("Tốc độ Rắn", function()
		return speedNames[state.Settings.SpeedMode]
	end, function()
		state.Settings.SpeedMode = (state.Settings.SpeedMode % 3) + 1
		saveData()
	end)

	addSettingRow("Kiểu di chuyển", function()
		return state.Settings.SmoothMove and "Trượt mượt" or "Từng ô"
	end, function()
		state.Settings.SmoothMove = not state.Settings.SmoothMove
		saveData()
	end)

	addSettingRow("Cụm phím cảm ứng D-Pad", function()
		return state.Settings.ShowDpad and "HIỆN" or "ẨN"
	end, function()
		state.Settings.ShowDpad = not state.Settings.ShowDpad
		saveData()
	end)

	local confirmReset = false
	addSettingRow("Xóa toàn bộ dữ liệu đã lưu", function()
		return confirmReset and "BẤM LẠI ĐỂ XÓA!" or "RESET DỮ LIỆU"
	end, function()
		if not confirmReset then
			confirmReset = true
			return
		end
		confirmReset = false
		state = createDefaultState()
		saveData()
		applyWindowScale()
		if applyGameLayout then applyGameLayout() end
		rebuildLobbyPreview()
		updateTopStats()
		openSettings()
	end, Color3.fromRGB(210, 68, 72), Color3.fromRGB(152, 30, 36))
end

UI.shopBtn.MouseButton1Click:Connect(openShop)
UI.wheelBtn.MouseButton1Click:Connect(openWheel)
UI.giftBtn.MouseButton1Click:Connect(openGift)
UI.questBtn.MouseButton1Click:Connect(openQuests)
UI.settingsBtn.MouseButton1Click:Connect(openSettings)
UI.lbMoreBtn.MouseButton1Click:Connect(openFullLeaderboard)
UI.profileBtn.MouseButton1Click:Connect(openLevelRewards)

UI.fullBtn.MouseButton1Click:Connect(function()
	state.Settings.FullScreen = not state.Settings.FullScreen
	UI.fullLbl.Text = state.Settings.FullScreen and "><" or "[ ]"
	applyWindowScale()
	saveData()
end)

-- ============================================================
-- 2. MAN HINH CHOI GAME TO HON (17x13, CELL=26) + HO TRO TAY TRAI / PHAI
-- ============================================================
local COLS, ROWS, CELL = 17, 13, 26

function SEC.run5()
	local hudBar = Instance.new("Frame")
	hudBar.Size = UDim2.fromOffset(700, 38)
	hudBar.BackgroundColor3 = Color3.fromRGB(22, 26, 46)
	hudBar.BorderSizePixel = 0
	hudBar.Parent = gamePage
	addCorner(hudBar, 12)
	addStroke(hudBar, Color3.fromRGB(84, 70, 158), 1.8)

	local liveScoreLbl = Instance.new("TextLabel")
	liveScoreLbl.Size = UDim2.fromOffset(462, 38)
	liveScoreLbl.Position = UDim2.fromOffset(12, 0)
	liveScoreLbl.BackgroundTransparency = 1
	liveScoreLbl.Text = "Điểm: 0  |  +0 Xu  |  +0 KC"
	liveScoreLbl.TextColor3 = THEME.TextGold
	liveScoreLbl.Font = THEME.FontHead
	liveScoreLbl.TextSize = 13
	liveScoreLbl.TextXAlignment = Enum.TextXAlignment.Left
	liveScoreLbl.Parent = hudBar
	addTextOutline(liveScoreLbl, 1.4, THEME.Outline)
	UI.liveScoreLbl = liveScoreLbl

	local pauseBtn, pauseLbl = makeArcadeBtn(hudBar, "II", UDim2.fromOffset(42, 30), UDim2.new(1, -214, 0, 4), Color3.fromRGB(54, 156, 210), Color3.fromRGB(32, 92, 178), 8, { TextSize = 12, Depth = 3, Stroke = 1.8 })
	UI.pauseBtn = pauseBtn
	UI.pauseLbl = pauseLbl

	UI.restartBtn = makeArcadeBtn(hudBar, "Lại", UDim2.fromOffset(74, 30), UDim2.new(1, -168, 0, 4), Color3.fromRGB(64, 194, 92), Color3.fromRGB(28, 134, 58), 8, { TextSize = 12, Depth = 3, Stroke = 1.8 })
	UI.lobbyBtn   = makeArcadeBtn(hudBar, "Sảnh", UDim2.fromOffset(82, 30), UDim2.new(1, -88, 0, 4), Color3.fromRGB(154, 82, 214), Color3.fromRGB(100, 38, 172), 8, { TextSize = 12, Depth = 3, Stroke = 1.8 })

	local board = Instance.new("Frame")
	board.Size = UDim2.fromOffset(COLS * CELL, ROWS * CELL)
	board.Position = UDim2.fromOffset(0, 46)
	board.BackgroundColor3 = Color3.fromRGB(13, 17, 30)
	board.BorderSizePixel = 0
	board.ClipsDescendants = true
	board.Active = true
	board.Parent = gamePage
	addCorner(board, 12)
	addStroke(board, Color3.fromRGB(88, 76, 158), 2.2)
	UI.board = board

	for x = 1, COLS do
		for y = 1, ROWS do
			if (x + y) % 2 == 0 then
				local tile = Instance.new("Frame")
				tile.Size = UDim2.fromOffset(CELL, CELL)
				tile.Position = UDim2.fromOffset((x - 1) * CELL, (y - 1) * CELL)
				tile.BackgroundColor3 = Color3.fromRGB(19, 24, 42)
				tile.BorderSizePixel = 0
				tile.ZIndex = 1
				tile.Parent = board
			end
		end
	end

	local itemLayer = Instance.new("Frame")
	itemLayer.Size = UDim2.fromScale(1, 1)
	itemLayer.BackgroundTransparency = 1
	itemLayer.ZIndex = 2
	itemLayer.Parent = board
	UI.itemLayer = itemLayer

	local snakeLayer = Instance.new("Frame")
	snakeLayer.Size = UDim2.fromScale(1, 1)
	snakeLayer.BackgroundTransparency = 1
	snakeLayer.ZIndex = 4
	snakeLayer.Parent = board
	UI.snakeLayer = snakeLayer

	local gameOverCard = Instance.new("Frame")
	gameOverCard.Size = UDim2.fromOffset(346, 236)
	gameOverCard.Position = UDim2.fromScale(0.5, 0.5)
	gameOverCard.AnchorPoint = Vector2.new(0.5, 0.5)
	gameOverCard.BackgroundColor3 = Color3.fromRGB(20, 22, 40)
	gameOverCard.BorderSizePixel = 0
	gameOverCard.Visible = false
	gameOverCard.ZIndex = 20
	gameOverCard.Parent = board
	addCorner(gameOverCard, 16)
	addStroke(gameOverCard, Color3.fromRGB(208, 74, 80), 2.6)
	UI.gameOverCard = gameOverCard

	local goTitle = Instance.new("TextLabel")
	goTitle.Size = UDim2.new(1, 0, 0, 32)
	goTitle.Position = UDim2.fromOffset(0, 10)
	goTitle.BackgroundTransparency = 1
	goTitle.Text = "KẾT THÚC!"
	goTitle.TextColor3 = THEME.TextRed
	goTitle.Font = THEME.FontHead
	goTitle.TextSize = 19
	goTitle.ZIndex = 21
	goTitle.Parent = gameOverCard
	addTextOutline(goTitle, 2, THEME.Outline)
	UI.goTitle = goTitle

	local goStats = Instance.new("TextLabel")
	goStats.Size = UDim2.new(1, -20, 0, 56)
	goStats.Position = UDim2.fromOffset(10, 44)
	goStats.BackgroundTransparency = 1
	goStats.Text = ""
	goStats.TextColor3 = THEME.TextMain
	goStats.Font = THEME.FontBody
	goStats.TextSize = 12
	goStats.ZIndex = 21
	goStats.Parent = gameOverCard
	UI.goStats = goStats

	local revCoinBtn, revCoinLbl, revCoinFace = makeArcadeBtn(
		gameOverCard, "HỒI SINH 300",
		UDim2.fromOffset(152, 42), UDim2.fromOffset(16, 110),
		Color3.fromRGB(218, 172, 36), Color3.fromRGB(168, 98, 18), 11,
		{ TextSize = 12, ZIndex = 22, Depth = 4, LabelPos = UDim2.fromOffset(14, 0), LabelSize = UDim2.new(1, -18, 1, 0) }
	)
	GFX.makeCartoonCoin(revCoinFace, 17, UDim2.new(0, 12, 0.5, 0), Vector2.new(0, 0.5), 25)
	UI.revCoinBtn = revCoinBtn
	UI.revCoinLbl = revCoinLbl

	local revGemBtn, revGemLbl, revGemFace = makeArcadeBtn(
		gameOverCard, "HỒI SINH 10",
		UDim2.fromOffset(152, 42), UDim2.fromOffset(178, 110),
		Color3.fromRGB(56, 158, 216), Color3.fromRGB(30, 88, 178), 11,
		{ TextSize = 12, ZIndex = 22, Depth = 4, LabelPos = UDim2.fromOffset(14, 0), LabelSize = UDim2.new(1, -18, 1, 0) }
	)
	GFX.makeCartoonGem(revGemFace, 17, UDim2.new(0, 14, 0.5, 0), Vector2.new(0, 0.5), 25)
	UI.revGemBtn = revGemBtn
	UI.revGemLbl = revGemLbl

	UI.goReplayBtn = makeArcadeBtn(gameOverCard, "CHƠI LẠI", UDim2.fromOffset(152, 40), UDim2.fromOffset(16, 170), Color3.fromRGB(64, 194, 92), Color3.fromRGB(28, 134, 58), 11, { TextSize = 13, ZIndex = 22, Depth = 4 })
	UI.goLobbyBtn  = makeArcadeBtn(gameOverCard, "VỀ SẢNH", UDim2.fromOffset(152, 40), UDim2.fromOffset(178, 170), Color3.fromRGB(154, 82, 214), Color3.fromRGB(100, 38, 172), 11, { TextSize = 13, ZIndex = 22, Depth = 4 })

	local sidePanel = Instance.new("Frame")
	sidePanel.Size = UDim2.fromOffset(248, 338)
	sidePanel.Position = UDim2.fromOffset(452, 46)
	sidePanel.BackgroundTransparency = 1
	sidePanel.Parent = gamePage
	UI.sidePanel = sidePanel

	local buffBox = Instance.new("Frame")
	buffBox.Size = UDim2.fromOffset(248, 114)
	buffBox.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	buffBox.BorderSizePixel = 0
	buffBox.Parent = sidePanel
	addCorner(buffBox, 12)
	addStroke(buffBox, Color3.fromRGB(84, 70, 158), 1.8)

	local buffHeader = Instance.new("TextLabel")
	buffHeader.Size = UDim2.new(1, 0, 0, 22)
	buffHeader.Position = UDim2.fromOffset(0, 4)
	buffHeader.BackgroundTransparency = 1
	buffHeader.Text = "KỸ NĂNG & COMBO"
	buffHeader.TextColor3 = THEME.TextGem
	buffHeader.Font = THEME.FontHead
	buffHeader.TextSize = 12
	buffHeader.Parent = buffBox
	addTextOutline(buffHeader, 1.3, THEME.Outline)

	local comboBarBg = Instance.new("Frame")
	comboBarBg.Size = UDim2.new(1, -16, 0, 6)
	comboBarBg.Position = UDim2.fromOffset(8, 28)
	comboBarBg.BackgroundColor3 = Color3.fromRGB(30, 34, 56)
	comboBarBg.BorderSizePixel = 0
	comboBarBg.Visible = false
	comboBarBg.Parent = buffBox
	addCorner(comboBarBg, 4)
	UI.comboBarBg = comboBarBg

	local comboBarFill = Instance.new("Frame")
	comboBarFill.Size = UDim2.fromScale(1, 1)
	comboBarFill.BackgroundColor3 = Color3.fromRGB(214, 170, 42)
	comboBarFill.BorderSizePixel = 0
	comboBarFill.Parent = comboBarBg
	addCorner(comboBarFill, 4)
	UI.comboBarFill = comboBarFill

	local buffStatusLbl = Instance.new("TextLabel")
	buffStatusLbl.Size = UDim2.new(1, -12, 1, -38)
	buffStatusLbl.Position = UDim2.fromOffset(6, 36)
	buffStatusLbl.BackgroundTransparency = 1
	buffStatusLbl.Text = "Vuốt bàn cờ hoặc lướt D-Pad\nđể cua chuẩn từng ô"
	buffStatusLbl.TextColor3 = THEME.TextMuted
	buffStatusLbl.Font = THEME.FontBody
	buffStatusLbl.TextSize = 11
	buffStatusLbl.TextWrapped = true
	buffStatusLbl.Parent = buffBox
	UI.buffStatusLbl = buffStatusLbl

	local dpadFrame = Instance.new("Frame")
	dpadFrame.Size = UDim2.fromOffset(248, 214)
	dpadFrame.Position = UDim2.fromOffset(0, 124)
	dpadFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	dpadFrame.BorderSizePixel = 0
	dpadFrame.Active = true
	dpadFrame.Parent = sidePanel
	addCorner(dpadFrame, 12)
	addStroke(dpadFrame, Color3.fromRGB(84, 70, 158), 1.8)
	UI.dpadFrame = dpadFrame

	local dOpts = { TextSize = 20, Depth = 4, Stroke = 2.2 }
	local function addDpad(sym, x, y)
		local b, _, _, st = makeArcadeBtn(dpadFrame, sym, UDim2.fromOffset(68, 64), UDim2.fromOffset(x, y), Color3.fromRGB(56, 162, 218), Color3.fromRGB(28, 86, 176), 18, dOpts)
		return b, st
	end
	UI.dUp, UI.dUpStroke       = addDpad("▲", 90, 8)
	UI.dLeft, UI.dLeftStroke   = addDpad("◄", 18, 75)
	UI.dRight, UI.dRightStroke = addDpad("►", 162, 75)
	UI.dDown, UI.dDownStroke   = addDpad("▼", 90, 142)

	local dCenterDot = Instance.new("Frame")
	dCenterDot.Size = UDim2.fromOffset(42, 42)
	dCenterDot.Position = UDim2.fromOffset(103, 86)
	dCenterDot.BackgroundColor3 = Color3.fromRGB(30, 36, 66)
	dCenterDot.BorderSizePixel = 0
	dCenterDot.Parent = dpadFrame
	addCorner(dCenterDot, 21)
	addStroke(dCenterDot, THEME.Outline, 1.6)
end
SEC.run5()

applyGameLayout = function()
	if state.Settings.LeftHanded then
		UI.sidePanel.Position = UDim2.fromOffset(0, 46)
		UI.board.Position = UDim2.fromOffset(258, 46)
	else
		UI.board.Position = UDim2.fromOffset(0, 46)
		UI.sidePanel.Position = UDim2.fromOffset(452, 46)
	end
end
applyGameLayout()

local function flashDpadStroke(stroke)
	if not stroke then return end
	stroke.Color = THEME.TextGold
	stroke.Thickness = 2.8
	task.delay(0.14, function()
		if stroke and stroke.Parent then
			stroke.Color = THEME.Outline
			stroke.Thickness = 2.2
		end
	end)
end

-- ============================================================
-- LOGIC GAME RAN SAN MOI (CUA 1 O + COMBO + ROI HONG NGOC HIEM)
-- ============================================================
local Game = {
	playing = false,
	paused = false,
	snake = {},
	prevSnake = {},
	turnQueue = {},
	dir = { x = 1, y = 0 },
	runScore = 0,
	runCoins = 0,
	runGems = 0,
	runRubies = 0,
	runSettled = true,
	comboCount = 0,
	comboTimer = 0,
	mythicGemStep = 0,
	stepTimer = 0,
	stepDuration = 0.23,
	powerSpawnTimer = 0,
	buffs = { Double = 0, Ghost = 0, Magnet = 0, Speed = 0, Shield = false, Invuln = 0 },
	boardItems = {},
	obstacles = {},
	obstacleNodes = {},
	bodyFrames = {},
	activeHeadNode = nil,
	shieldRing = nil,
}

local function cellToCenter(gx, gy)
	return (gx - 0.5) * CELL, (gy - 0.5) * CELL
end

local function dirToAngle(d)
	if d.x == 1 then return 0
	elseif d.x == -1 then return 180
	elseif d.y == 1 then return 90
	else return -90 end
end

local function clearItems()
	for _, it in ipairs(Game.boardItems) do
		if it.Node then it.Node:Destroy() end
	end
	Game.boardItems = {}
	for _, n in ipairs(Game.obstacleNodes) do
		if n then n:Destroy() end
	end
	Game.obstacleNodes = {}
	Game.obstacles = {}
end

local function isObstacleCell(x, y)
	for _, ob in ipairs(Game.obstacles) do
		if ob.x == x and ob.y == y then return true end
	end
	return false
end

local function buildMazeObstacles()
	if state.GameMode ~= "Maze" then return end
	local coords = {
		{4, 3}, {5, 3}, {13, 3}, {14, 3},
		{4, 11}, {5, 11}, {13, 11}, {14, 11},
		{9, 4}, {9, 10},
	}
	for _, c in ipairs(coords) do
		local ox, oy = c[1], c[2]
		table.insert(Game.obstacles, { x = ox, y = oy })
		local cx, cy = cellToCenter(ox, oy)
		local blk = Instance.new("Frame")
		blk.Size = UDim2.fromOffset(CELL - 2, CELL - 2)
		blk.Position = UDim2.fromOffset(cx, cy)
		blk.AnchorPoint = Vector2.new(0.5, 0.5)
		blk.BackgroundColor3 = Color3.fromRGB(214, 72, 62)
		blk.BorderSizePixel = 0
		blk.ZIndex = 3
		blk.Parent = UI.itemLayer
		addCorner(blk, 6)
		addStroke(blk, Color3.fromRGB(238, 178, 72), 2.2)
		addGradient(blk, Color3.fromRGB(228, 96, 68), Color3.fromRGB(154, 34, 42), 90)

		-- Vien gach noi bat giua khoi tuong de nhin ro ngay lap tuc
		local inner = Instance.new("Frame")
		inner.Size = UDim2.new(1, -8, 1, -8)
		inner.Position = UDim2.fromScale(0.5, 0.5)
		inner.AnchorPoint = Vector2.new(0.5, 0.5)
		inner.BackgroundColor3 = Color3.fromRGB(122, 26, 36)
		inner.BorderSizePixel = 0
		inner.ZIndex = 4
		inner.Parent = blk
		addCorner(inner, 3)

		local cross1 = Instance.new("Frame")
		cross1.Size = UDim2.fromOffset(10, 2)
		cross1.Position = UDim2.fromScale(0.5, 0.5)
		cross1.AnchorPoint = Vector2.new(0.5, 0.5)
		cross1.Rotation = 45
		cross1.BackgroundColor3 = Color3.fromRGB(238, 198, 92)
		cross1.BorderSizePixel = 0
		cross1.ZIndex = 5
		cross1.Parent = inner
		addCorner(cross1, 2)

		local cross2 = Instance.new("Frame")
		cross2.Size = UDim2.fromOffset(10, 2)
		cross2.Position = UDim2.fromScale(0.5, 0.5)
		cross2.AnchorPoint = Vector2.new(0.5, 0.5)
		cross2.Rotation = -45
		cross2.BackgroundColor3 = Color3.fromRGB(238, 198, 92)
		cross2.BorderSizePixel = 0
		cross2.ZIndex = 5
		cross2.Parent = inner
		addCorner(cross2, 2)

		table.insert(Game.obstacleNodes, blk)
	end
end

local function clearSnakeVisuals()
	for _, ch in ipairs(UI.snakeLayer:GetChildren()) do ch:Destroy() end
	Game.bodyFrames = {}
	Game.activeHeadNode = nil
	Game.shieldRing = nil
end

local function findFreeCell()
	local free = {}
	for x = 1, COLS do
		for y = 1, ROWS do
			local busy = false
			for _, seg in ipairs(Game.snake) do
				if seg.x == x and seg.y == y then busy = true break end
			end
			if not busy and isObstacleCell(x, y) then busy = true end
			if not busy then
				for _, it in ipairs(Game.boardItems) do
					if it.X == x and it.Y == y then busy = true break end
				end
			end
			if not busy then table.insert(free, { x = x, y = y }) end
		end
	end
	return #free > 0 and free[math.random(1, #free)] or nil
end

local function spawnItem(itemType, customData, lifeTime)
	local pos = findFreeCell()
	if not pos then return end
	local cx, cy = cellToCenter(pos.x, pos.y)
	local node

	if itemType == "Coin" then
		node = GFX.makeCartoonCoin(UI.itemLayer, CELL - 2, UDim2.fromOffset(cx, cy), Vector2.new(0.5, 0.5), 3)
	elseif itemType == "Gem" then
		node = GFX.makeCartoonGem(UI.itemLayer, CELL - 2, UDim2.fromOffset(cx, cy), Vector2.new(0.5, 0.5), 3)
	elseif itemType == "Ruby" then
		node = GFX.makeCartoonRuby(UI.itemLayer, CELL - 2, UDim2.fromOffset(cx, cy), Vector2.new(0.5, 0.5), 3)
	elseif itemType == "Food" then
		node = GFX.makeCartoonFruit(UI.itemLayer, CELL, UDim2.fromOffset(cx, cy), customData)
	else
		node = GFX.makePowerupGraphic(UI.itemLayer, CELL, UDim2.fromOffset(cx, cy), customData)
	end

	table.insert(Game.boardItems, {
		Type = itemType, X = pos.x, Y = pos.y,
		Data = customData, Node = node, Life = lifeTime
	})
end

local function ensureFoodExists()
	local count = 0
	for _, it in ipairs(Game.boardItems) do
		if it.Type == "Food" then count += 1 end
	end
	while count < 2 do
		spawnItem("Food", FOODS[math.random(1, #FOODS)], nil)
		count += 1
	end
end

local function updateHUD()
	local rubyTxt = (Game.runRubies > 0) and ("  |  +" .. formatNum(Game.runRubies) .. " HN") or ""
	local comboTxt = (Game.comboCount >= 2) and ("  |  Combo x" .. Game.comboCount) or ""
	UI.liveScoreLbl.Text = string.format(
		"Điểm: %s  |  +%s Xu  |  +%s KC%s%s",
		formatNum(Game.runScore), formatNum(Game.runCoins), formatNum(Game.runGems), rubyTxt, comboTxt
	)

	UI.comboBarBg.Visible = (Game.comboTimer > 0 and Game.comboCount >= 1)
	if UI.comboBarBg.Visible then
		UI.comboBarFill.Size = UDim2.fromScale(math.clamp(Game.comboTimer / 3.5, 0, 1), 1)
	end

	local lines = {}
	if Game.comboCount >= 2 then
		table.insert(lines, string.format("Combo x%d: +%d%% điểm", Game.comboCount, (Game.comboCount - 1) * 20))
	end
	if Game.buffs.Double > 0 then table.insert(lines, string.format("2x Điểm: %.1fs", Game.buffs.Double)) end
	if Game.buffs.Ghost  > 0 then table.insert(lines, string.format("Bóng Ma: %.1fs", Game.buffs.Ghost)) end
	if Game.buffs.Magnet > 0 then table.insert(lines, string.format("Nam Châm: %.1fs", Game.buffs.Magnet)) end
	if Game.buffs.Speed  > 0 then table.insert(lines, string.format("Tăng Tốc: %.1fs", Game.buffs.Speed)) end
	if Game.buffs.Shield then table.insert(lines, "Khiên: Đỡ 1 đòn") end

	if #lines == 0 then
		local skin = getSkinById(state.EquippedSkin)
		local stTxt = getSkinStatsText(skin)
		local bonusInfo = (stTxt ~= "") and ("\nSkin: " .. stTxt) or ""
		UI.buffStatusLbl.Text = "Vuốt bàn cờ hoặc lướt D-Pad\nđể cua chuẩn từng ô" .. bonusInfo
		UI.buffStatusLbl.TextColor3 = THEME.TextMuted
	else
		UI.buffStatusLbl.Text = table.concat(lines, "\n")
		UI.buffStatusLbl.TextColor3 = THEME.TextGold
	end
end

local function syncSnakeNodes()
	local skin = getSkinById(state.EquippedSkin)
	if not Game.activeHeadNode then
		Game.activeHeadNode = GFX.buildCartoonHead(UI.snakeLayer, CELL + 4, skin)
		Game.shieldRing = Instance.new("Frame")
		Game.shieldRing.Size = UDim2.fromScale(1.38, 1.38)
		Game.shieldRing.Position = UDim2.fromScale(0.5, 0.5)
		Game.shieldRing.AnchorPoint = Vector2.new(0.5, 0.5)
		Game.shieldRing.BackgroundTransparency = 1
		Game.shieldRing.Visible = false
		Game.shieldRing.ZIndex = 12
		Game.shieldRing.Parent = Game.activeHeadNode
		addCorner(Game.shieldRing, 99)
		addStroke(Game.shieldRing, Color3.fromRGB(82, 168, 210), 2.2)
	end

	local needBody = #Game.snake - 1
	while #Game.bodyFrames < needBody do
		local idx = #Game.bodyFrames + 1
		local seg = Instance.new("Frame")
		seg.AnchorPoint = Vector2.new(0.5, 0.5)
		seg.BackgroundColor3 = getSegmentColor(skin, idx)
		seg.BackgroundTransparency = skin.BodyAlpha or 0
		seg.BorderSizePixel = 0
		seg.ZIndex = 5
		seg.Parent = UI.snakeLayer
		addCorner(seg, 99)
		addStroke(seg, skin.GlowColor or THEME.Outline, 1.8)
		table.insert(Game.bodyFrames, seg)
	end
	for i = 1, #Game.bodyFrames do
		Game.bodyFrames[i].Visible = (i <= needBody)
		if i <= needBody then
			local taper = (i > needBody - 3) and (CELL - 1 - (3 - (needBody - i)) * 2) or CELL
			taper = math.max(15, taper)
			Game.bodyFrames[i].Size = UDim2.fromOffset(taper, taper)
		end
	end
end

local function renderSnakeSmooth(alpha)
	if #Game.snake == 0 or not Game.activeHeadNode then return end
	local skin = getSkinById(state.EquippedSkin)
	local baseAlpha = skin.BodyAlpha or 0
	local ghostTrans = (Game.buffs.Ghost > 0 or Game.buffs.Invuln > 0) and math.max(baseAlpha, 0.45) or baseAlpha
	local glitchTick = skin.Glitch and math.floor(os.clock() * 10) or 0

	for i = 1, #Game.snake do
		local curr = Game.snake[i]
		local prev = Game.prevSnake[i] or curr
		local gx, gy
		if alpha >= 1 or math.abs(curr.x - prev.x) > 1 or math.abs(curr.y - prev.y) > 1 then
			gx, gy = curr.x, curr.y
		else
			gx = prev.x + (curr.x - prev.x) * alpha
			gy = prev.y + (curr.y - prev.y) * alpha
		end
		local px, py = cellToCenter(gx, gy)

		if i == 1 then
			Game.activeHeadNode.Position = UDim2.fromOffset(px, py)
			Game.activeHeadNode.Rotation = dirToAngle(Game.dir)
			Game.activeHeadNode.BackgroundTransparency = ghostTrans
			if Game.shieldRing then Game.shieldRing.Visible = Game.buffs.Shield end
			if skin.Rainbow then
				Game.activeHeadNode.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.45) % 1, 0.72, 0.85)
			end
		else
			local node = Game.bodyFrames[i - 1]
			if node then
				node.Position = UDim2.fromOffset(px, py)
				node.BackgroundTransparency = ghostTrans
				if skin.Rainbow then
					node.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.45 + i * 0.06) % 1, 0.72, 0.85)
				elseif skin.Glitch then
					local m = (glitchTick + i) % 3
					node.BackgroundColor3 = (m == 0) and skin.Body1 or ((m == 1) and skin.Body2 or skin.Body3)
				end
			end
		end
	end
end

local function queueTurn(dx, dy)
	if not Game.playing or Game.paused then return end
	local last = (#Game.turnQueue > 0) and Game.turnQueue[#Game.turnQueue] or Game.dir
	if dx == last.x and dy == last.y then return end
	if #Game.turnQueue == 1 and dx == -last.x and dy == -last.y then
		if not (dx == -Game.dir.x and dy == -Game.dir.y) then
			Game.turnQueue[1] = { x = dx, y = dy }
		end
		return
	end
	if dx == -last.x and dy == -last.y then return end
	if #Game.turnQueue < 3 then
		table.insert(Game.turnQueue, { x = dx, y = dy })
	end
end

local function settleRun()
	if Game.runSettled then return end
	Game.runSettled = true
	if Game.runScore > state.HighScore then
		state.HighScore = Game.runScore
	end
	if state.HighScore >= 1500 and not state.OwnedSkins["free_celestial"] then
		state.OwnedSkins["free_celestial"] = true
		showToast("Mở khóa Skin Miễn Phí: Thần Long Cực Hạn!", THEME.TextGold, 4.0)
	end
	state.Coins  += Game.runCoins
	state.Gems   += Game.runGems
	state.Rubies += Game.runRubies
	addQuestProgress("games", 1, false)
	addQuestProgress("score", Game.runScore, true)
	addQuestProgress("score_pro", Game.runScore, true)
	addQuestProgress("score_god", Game.runScore, true)
	addQuestProgress("coins_run", Game.runCoins, false)
	addExp(math.floor(Game.runScore * 0.45) + 15)
	Game.runScore, Game.runCoins, Game.runGems, Game.runRubies = 0, 0, 0, 0
end

local function endRun(reasonText)
	Game.playing = false
	local isRecord = (Game.runScore > state.HighScore)
	UI.goTitle.Text = reasonText
	local recStr = isRecord and "  •  KỶ LỤC MỚI" or ""
	local rubyStr = (Game.runRubies > 0) and ("  |  +" .. formatNum(Game.runRubies) .. " Hồng Ngọc") or ""
	UI.goStats.Text = string.format(
		"Điểm ván này: %s%s\nNhận: +%s Xu  |  +%s Kim Cương%s",
		formatNum(Game.runScore), recStr, formatNum(Game.runCoins), formatNum(Game.runGems), rubyStr
	)
	UI.revCoinLbl.Text = "HỒI SINH 300"
	UI.revGemLbl.Text  = "HỒI SINH 10"
	UI.gameOverCard.Visible = true
end

local function reviveRun(useGems)
	if Game.playing or Game.runSettled then return end
	if useGems then
		if state.Gems < 10 then
			UI.revGemLbl.Text = "KHÔNG ĐỦ!"
			task.delay(0.8, function() if UI.revGemLbl.Parent then UI.revGemLbl.Text = "HỒI SINH 10" end end)
			return
		end
		state.Gems -= 10
	else
		if state.Coins < 300 then
			UI.revCoinLbl.Text = "KHÔNG ĐỦ!"
			task.delay(0.8, function() if UI.revCoinLbl.Parent then UI.revCoinLbl.Text = "HỒI SINH 300" end end)
			return
		end
		state.Coins -= 300
	end
	updateTopStats()
	saveData()

	local keepLen = math.max(4, #Game.snake)
	Game.snake = {}
	Game.prevSnake = {}
	local startX = math.clamp(math.floor(COLS / 2), 4, COLS - 2)
	local startY = math.floor(ROWS / 2)
	for i = 1, keepLen do
		local sx = math.max(1, startX - (i - 1))
		Game.snake[i] = { x = sx, y = startY }
		Game.prevSnake[i] = { x = sx, y = startY }
	end
	Game.dir = { x = 1, y = 0 }
	Game.turnQueue = {}
	Game.buffs.Invuln = 3.0
	Game.stepTimer = 0
	Game.paused = false
	UI.pauseLbl.Text = "II"
	UI.gameOverCard.Visible = false
	Game.playing = true
	syncSnakeNodes()
	updateHUD()
	renderSnakeSmooth(1)
end

local function startNewRun()
	settleRun()
	clearItems()
	clearSnakeVisuals()
	applyGameLayout()
	UI.gameOverCard.Visible = false
	UI.dpadFrame.Visible = state.Settings.ShowDpad

	Game.snake = { { x = 6, y = 7 }, { x = 5, y = 7 }, { x = 4, y = 7 }, { x = 3, y = 7 } }
	Game.prevSnake = {}
	for i, s in ipairs(Game.snake) do Game.prevSnake[i] = { x = s.x, y = s.y } end

	Game.dir = { x = 1, y = 0 }
	Game.turnQueue = {}
	Game.runScore, Game.runCoins, Game.runGems, Game.runRubies = 0, 0, 0, 0
	Game.runSettled = false
	Game.comboCount, Game.comboTimer, Game.mythicGemStep = 0, 0, 0
	Game.buffs = { Double = 0, Ghost = 0, Magnet = 0, Speed = 0, Shield = false, Invuln = 0 }
	Game.stepTimer, Game.powerSpawnTimer = 0, 4
	Game.paused = false
	UI.pauseLbl.Text = "II"
	Game.playing = true

	buildMazeObstacles()
	syncSnakeNodes()
	ensureFoodExists()
	spawnItem("Coin", nil, 15)
	updateHUD()
	renderSnakeSmooth(1)
end

local function openLobby()
	settleRun()
	Game.playing = false
	Game.paused = false
	gamePage.Visible = false
	lobbyPage.Visible = true
	rebuildLobbyPreview()
	updateTopStats()
end

local function openGame()
	UI.modalOverlay.Visible = false
	activeModalTag = nil
	lobbyPage.Visible = false
	gamePage.Visible = true
	startNewRun()
end

local function stepSnakeLogic()
	if #Game.snake == 0 then return end
	if #Game.turnQueue > 0 then Game.dir = table.remove(Game.turnQueue, 1) end
	Game.prevSnake = {}
	for i, s in ipairs(Game.snake) do Game.prevSnake[i] = { x = s.x, y = s.y } end

	local head = Game.snake[1]
	local nx, ny = head.x + Game.dir.x, head.y + Game.dir.y

	local modeDef = getGameModeDef(state.GameMode)
	local canWrap = state.Settings.WallPass or (state.GameMode == "Portal") or Game.buffs.Ghost > 0 or Game.buffs.Invuln > 0
	if nx < 1 or nx > COLS or ny < 1 or ny > ROWS then
		if canWrap then
			if nx < 1 then nx = COLS elseif nx > COLS then nx = 1 end
			if ny < 1 then ny = ROWS elseif ny > ROWS then ny = 1 end
		elseif Game.buffs.Shield then
			Game.buffs.Shield = false
			Game.buffs.Invuln = 1.6
			if nx < 1 then nx = COLS elseif nx > COLS then nx = 1 end
			if ny < 1 then ny = ROWS elseif ny > ROWS then ny = 1 end
		else
			endRun("ĐỤNG TƯỜNG!")
			return
		end
	end

	if isObstacleCell(nx, ny) and Game.buffs.Ghost <= 0 and Game.buffs.Invuln <= 0 then
		if Game.buffs.Shield then
			Game.buffs.Shield = false
			Game.buffs.Invuln = 1.6
		else
			endRun("ĐỤNG CHƯỚNG NGẠI!")
			return
		end
	end

	if Game.buffs.Magnet > 0 then
		for _, it in ipairs(Game.boardItems) do
			if it.Type == "Food" or it.Type == "Coin" or it.Type == "Gem" or it.Type == "Ruby" then
				local dist = math.abs(it.X - nx) + math.abs(it.Y - ny)
				if dist > 0 and dist <= 3 then
					if it.X < nx then it.X += 1 elseif it.X > nx then it.X -= 1 end
					if it.Y < ny then it.Y += 1 elseif it.Y > ny then it.Y -= 1 end
					local cx, cy = cellToCenter(it.X, it.Y)
					it.Node.Position = UDim2.fromOffset(cx, cy)
				end
			end
		end
	end

	local skin = getSkinById(state.EquippedSkin)
	local skinCoinMult = skin.CoinMult or 1.0
	local grew = false

	for i = #Game.boardItems, 1, -1 do
		local it = Game.boardItems[i]
		if it.X == nx and it.Y == ny then
			local modeMult = modeDef.Mult or 1.0
			local mult = (Game.buffs.Double > 0 and 2 or 1) * (Game.buffs.Speed > 0 and 1.5 or 1) * modeMult
			if it.Type == "Food" then
				grew = true
				Game.comboCount = math.min(5, Game.comboCount + 1)
				Game.comboTimer = 3.5
				if Game.comboCount >= 4 then addQuestProgress("combo", 1, true) end
				local comboMult = 1 + ((Game.comboCount - 1) * 0.2)
				Game.runScore += math.floor(it.Data.Score * mult * comboMult)
				Game.runCoins += math.floor(it.Data.Coins * mult * skinCoinMult * comboMult)
				if Game.runScore >= 1500 and not state.OwnedSkins["free_celestial"] then
					state.OwnedSkins["free_celestial"] = true
					saveData()
					showToast("Mở khóa Skin Miễn Phí: Thần Long Cực Hạn!", THEME.TextGold, 4.0)
				end
				addQuestProgress("eat", 1, false)
				addQuestProgress("eat_pro", 1, false)
				addQuestProgress("eat_god", 1, false)
				addQuestProgress("score", Game.runScore, true)
				addQuestProgress("score_pro", Game.runScore, true)
				addQuestProgress("score_god", Game.runScore, true)
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			elseif it.Type == "Coin" then
				Game.runCoins += math.floor(30 * mult * skinCoinMult)
				Game.runScore += math.floor(15 * mult)
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			elseif it.Type == "Gem" then
				Game.runGems += math.max(1, math.floor((2 + (skin.GemAdd or 0)) * modeMult + 0.5))
				Game.runScore += math.floor(30 * mult)
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			elseif it.Type == "Ruby" then
				Game.runRubies += (1 + (skin.RubyAdd or 0))
				Game.runScore += math.floor(60 * mult)
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			elseif it.Type == "Power" then
				local pId = it.Data.Id
				if pId == "Double" then Game.buffs.Double = 10
				elseif pId == "Ghost" then Game.buffs.Ghost = 8
				elseif pId == "Magnet" then Game.buffs.Magnet = 10
				elseif pId == "Speed" then Game.buffs.Speed = 7
				elseif pId == "Shield" then Game.buffs.Shield = true end
				addQuestProgress("power", 1, false)
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			end
		end
	end

	if skin.GemBonus then
		local stepUnit = skin.GemStep or 150
		local curStep = math.floor(Game.runScore / stepUnit)
		if curStep > Game.mythicGemStep then
			Game.runGems += (curStep - Game.mythicGemStep)
			Game.mythicGemStep = curStep
		end
	end

	if not grew then
		table.remove(Game.snake)
	else
		table.insert(Game.prevSnake, Game.prevSnake[#Game.prevSnake])
	end

	if Game.buffs.Ghost <= 0 and Game.buffs.Invuln <= 0 then
		for _, seg in ipairs(Game.snake) do
			if seg.x == nx and seg.y == ny then
				if Game.buffs.Shield then
					Game.buffs.Shield = false
					Game.buffs.Invuln = 1.6
					break
				else
					endRun("TỰ CẮN THÂN!")
					return
				end
			end
		end
	end

	table.insert(Game.snake, 1, { x = nx, y = ny })
	syncSnakeNodes()
	ensureFoodExists()

	if grew then
		local roll = math.random(1, 100)
		local rubyCutoff = 35 + (skin.RubyChance or 0)
		if roll <= 24 then spawnItem("Coin", nil, 14)
		elseif roll <= 33 then spawnItem("Gem", nil, 12)
		elseif roll <= rubyCutoff then spawnItem("Ruby", nil, 10) end
	end
	updateHUD()
end

-- ============================================================
-- DIEU KHIEN CAM UNG NHAY (CHAM TUC THI + LUOT D-PAD + VUOT)
-- ============================================================
function SEC.run6()
	local dpadSliding = false
	local lastSlideDir = nil
	local swipeActive = false
	local swipeOrigin = nil

	local function triggerDpadDir(dx, dy, stroke)
		local key = dx .. "," .. dy
		if lastSlideDir == key then return end
		lastSlideDir = key
		queueTurn(dx, dy)
		flashDpadStroke(stroke)
	end

	local function handleDpadPoint(pos)
		if not Game.playing or Game.paused then return end
		local center = UI.dpadFrame.AbsolutePosition + (UI.dpadFrame.AbsoluteSize * 0.5)
		local diff = Vector2.new(pos.X - center.X, pos.Y - center.Y)
		if diff.Magnitude < 14 then return end
		if math.abs(diff.X) > math.abs(diff.Y) then
			if diff.X > 0 then triggerDpadDir(1, 0, UI.dRightStroke) else triggerDpadDir(-1, 0, UI.dLeftStroke) end
		else
			if diff.Y > 0 then triggerDpadDir(0, 1, UI.dDownStroke) else triggerDpadDir(0, -1, UI.dUpStroke) end
		end
	end

	local function bindInstantDpad(btn, dx, dy, stroke)
		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dpadSliding = true
				lastSlideDir = nil
				triggerDpadDir(dx, dy, stroke)
			end
		end)
	end

	bindInstantDpad(UI.dUp,    0, -1, UI.dUpStroke)
	bindInstantDpad(UI.dDown,  0,  1, UI.dDownStroke)
	bindInstantDpad(UI.dLeft, -1,  0, UI.dLeftStroke)
	bindInstantDpad(UI.dRight, 1,  0, UI.dRightStroke)

	UI.dpadFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dpadSliding = true
			lastSlideDir = nil
			handleDpadPoint(input.Position)
		end
	end)

	UI.board.InputBegan:Connect(function(input)
		if not Game.playing or Game.paused then return end
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			swipeActive = true
			swipeOrigin = input.Position
		end
	end)

	track(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		if dpadSliding and mainFrame.Visible and gamePage.Visible then
			handleDpadPoint(input.Position)
		end
		if swipeActive and swipeOrigin and Game.playing and not Game.paused then
			local delta = input.Position - swipeOrigin
			if delta.Magnitude >= 18 then
				if math.abs(delta.X) > math.abs(delta.Y) then
					if delta.X > 0 then queueTurn(1, 0) flashDpadStroke(UI.dRightStroke)
					else queueTurn(-1, 0) flashDpadStroke(UI.dLeftStroke) end
				else
					if delta.Y > 0 then queueTurn(0, 1) flashDpadStroke(UI.dDownStroke)
					else queueTurn(0, -1) flashDpadStroke(UI.dUpStroke) end
				end
				swipeOrigin = input.Position
			end
		end
	end))

	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dpadSliding = false
			lastSlideDir = nil
			swipeActive = false
			swipeOrigin = nil
		end
	end))
end
SEC.run6()

-- ============================================================
-- VONG LAP CHINH
-- ============================================================
local lastSecondCheck = 0
track(RunService.RenderStepped:Connect(function(dt)
	dt = math.min(dt, 0.05)

	local nowSec = os.time()
	if UI.modalOverlay.Visible and activeModalTag == "Wheel" and #wheelBulbs > 0 then
		local phase = math.floor(os.clock() * (wheelSpinning and 10 or 3)) % 2
		for idxB, b in ipairs(wheelBulbs) do
			if b and b.Parent then
				b.BackgroundColor3 = ((idxB + phase) % 2 == 0) and Color3.fromRGB(248, 240, 178) or Color3.fromRGB(218, 134, 34)
			end
		end
	end

	if nowSec ~= lastSecondCheck then
		lastSecondCheck = nowSec
		state.OnlineSeconds += 1
		updateFreeSpinsTick()
		refreshNotifDots()
		if state.OnlineSeconds % 30 == 0 then saveData() end
		if UI.modalOverlay.Visible and activeModalTag == "Gift" then
			UI.modalTitle.Text = "QUÀ ONLINE THEO THỜI GIAN  •  " .. formatMMSS(state.OnlineSeconds)
			if state.OnlineSeconds % 5 == 0 then openGift() end
		elseif UI.modalOverlay.Visible and activeModalTag == "Wheel" then
			if UI.liveWheelSpinsLbl and UI.liveWheelSpinsLbl.Parent then
				UI.liveWheelSpinsLbl.Text = "Lượt quay: " .. formatNum(state.Spins + state.FreeSpins)
			end
			if UI.liveWheelTimerLbl and UI.liveWheelTimerLbl.Parent then
				local remFree = math.max(0, state.NextFreeSpinUnix - nowSec)
				local freeStr = (state.FreeSpins >= FREE_SPIN_MAX)
					and ("Miễn phí: " .. state.FreeSpins .. "/15  •  Đã đầy")
					or ("Miễn phí: " .. state.FreeSpins .. "/15  •  Hồi sau " .. formatMMSS(remFree))
				UI.liveWheelTimerLbl.Text = freeStr .. "\n15 phút tặng 1 lượt, cộng dồn tối đa 15\nCó cơ hội trúng Hồng Ngọc cực hiếm"
			end
		end
	end

	if mainFrame.Visible and lobbyPage.Visible and previewHead then
		local t = os.clock() * 3.2
		local skin = getSkinById(state.EquippedSkin)
		local hx = 286
		local hy = 52 + math.sin(t) * 16
		previewHead.Position = UDim2.fromOffset(hx, hy)
		previewHead.Rotation = math.cos(t) * 14
		if skin.Rainbow then
			previewHead.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.4) % 1, 0.72, 0.85)
		end
		local gTick = skin.Glitch and math.floor(os.clock() * 10) or 0
		for i, seg in ipairs(previewSegs) do
			local sx = hx - (i * 18)
			local sy = 52 + math.sin(t - i * 0.42) * 16
			seg.Position = UDim2.fromOffset(sx, sy)
			if skin.Rainbow then
				seg.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.4 + i * 0.07) % 1, 0.72, 0.85)
			elseif skin.Glitch then
				local m = (gTick + i) % 3
				seg.BackgroundColor3 = (m == 0) and skin.Body1 or ((m == 1) and skin.Body2 or skin.Body3)
			end
		end
	end

	if not mainFrame.Visible or not gamePage.Visible or not Game.playing or Game.paused then return end

	local hudChanged = false
	for _, key in ipairs({ "Double", "Ghost", "Magnet", "Speed", "Invuln" }) do
		if Game.buffs[key] > 0 then
			Game.buffs[key] = math.max(0, Game.buffs[key] - dt)
			hudChanged = true
		end
	end

	if Game.comboTimer > 0 then
		Game.comboTimer = math.max(0, Game.comboTimer - dt)
		if Game.comboTimer == 0 then
			Game.comboCount = 0
		end
		hudChanged = true
	end

	for i = #Game.boardItems, 1, -1 do
		local it = Game.boardItems[i]
		if it.Life then
			it.Life -= dt
			if it.Life <= 2.5 then
				local blink = (math.floor(os.clock() * 8) % 2 == 0)
				it.Node.Visible = not blink
			end
			if it.Life <= 0 then
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			end
		end
	end

	Game.powerSpawnTimer -= dt
	if Game.powerSpawnTimer <= 0 then
		Game.powerSpawnTimer = math.random(8, 13)
		spawnItem("Power", POWERUPS[math.random(1, #POWERUPS)], 10)
	end

	local baseSpeeds = { 0.30, 0.23, 0.15 }
	local modeDef = getGameModeDef(state.GameMode)
	local speed = (baseSpeeds[state.Settings.SpeedMode] or 0.23) * (modeDef.SpeedMult or 1.0)
	speed = math.max(0.095, speed - math.min(0.035, Game.runScore * 0.00008))
	if Game.buffs.Speed > 0 then speed *= 0.78 end
	Game.stepDuration = speed

	Game.stepTimer += dt
	while Game.stepTimer >= Game.stepDuration and Game.playing do
		Game.stepTimer -= Game.stepDuration
		stepSnakeLogic()
	end

	if Game.playing then
		local alpha = state.Settings.SmoothMove and math.clamp(Game.stepTimer / Game.stepDuration, 0, 1) or 1
		renderSnakeSmooth(alpha)
		if hudChanged then updateHUD() end
	end
end))

-- ============================================================
-- KET NOI NUT BAM, PHIM TAT & LUU KHI DONG
-- ============================================================
UI.playBtn.MouseButton1Click:Connect(openGame)
UI.restartBtn.MouseButton1Click:Connect(startNewRun)
UI.goReplayBtn.MouseButton1Click:Connect(startNewRun)
UI.revCoinBtn.MouseButton1Click:Connect(function() reviveRun(false) end)
UI.revGemBtn.MouseButton1Click:Connect(function() reviveRun(true) end)
UI.lobbyBtn.MouseButton1Click:Connect(openLobby)
UI.goLobbyBtn.MouseButton1Click:Connect(openLobby)

UI.pauseBtn.MouseButton1Click:Connect(function()
	if not Game.playing then return end
	Game.paused = not Game.paused
	UI.pauseLbl.Text = Game.paused and "▶" or "II"
end)

local function minimizeMenu()
	if Game.playing then Game.paused = true UI.pauseLbl.Text = "▶" end
	local tw = TweenService:Create(uiScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.05 })
	tw:Play()
	tw.Completed:Connect(function()
		if uiScale.Scale < 0.1 then
			mainFrame.Visible = false
			fullBackdrop.Visible = false
			floatBtn.Visible = true
		end
	end)
end

local function restoreMenu()
	floatBtn.Visible = false
	mainFrame.Visible = true
	fullBackdrop.Visible = (state.Settings.FullScreen == true)
	uiScale.Scale = 0.1
	TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = calcScale() }):Play()
end

UI.minBtn.MouseButton1Click:Connect(minimizeMenu)
floatBtn.MouseButton1Click:Connect(function()
	if not floatDragged then restoreMenu() end
end)

local function destroyMenu()
	settleRun()
	saveData()
	screenGui:Destroy()
end
UI.closeBtn.MouseButton1Click:Connect(destroyMenu)
UI.exitBtn.MouseButton1Click:Connect(destroyMenu)

track(UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if mainFrame.Visible then minimizeMenu() else restoreMenu() end
		return
	end
	if not mainFrame.Visible or not gamePage.Visible then return end
	if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.W then
		queueTurn(0, -1) flashDpadStroke(UI.dUpStroke)
	elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then
		queueTurn(0, 1) flashDpadStroke(UI.dDownStroke)
	elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then
		queueTurn(-1, 0) flashDpadStroke(UI.dLeftStroke)
	elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then
		queueTurn(1, 0) flashDpadStroke(UI.dRightStroke)
	elseif input.KeyCode == Enum.KeyCode.Space and Game.playing then
		Game.paused = not Game.paused
		UI.pauseLbl.Text = Game.paused and "▶" or "II"
	end
end))

local cam = workspace.CurrentCamera
if cam then
	track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if mainFrame.Visible then applyWindowScale() end
	end))
end

screenGui.Destroying:Connect(function()
	Game.playing = false
	for _, c in ipairs(connections) do
		if c.Connected then c:Disconnect() end
	end
end)

rebuildLobbyPreview()
updateTopStats()
if not hadSavedData then saveData() end
end)
if not _ok then
	warn("[SnakeArcade v9.1 ERROR]: " .. tostring(_err))
end
