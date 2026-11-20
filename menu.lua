-- ============================================================
-- SNAKE ARCADE PRO v5.0 - 27 SKIN + COMBO + LỌC SHOP + TỐI ƯU MOBILE
-- Đã dọn sạch lỗi cú pháp, giữ nguyên file lưu cũ, chữ lì chống lóa
-- Phím tắt ẩn/hiện nhanh trên PC: RightShift
-- ============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local GUI_NAME = "SnakeArcadePro_Standalone"
local SAVE_FILE = "SnakeArcadePro_Save_" .. tostring(player.UserId) .. ".json"
local VERSION_TEXT = "v5.0"

-- Bảng màu chữ lì (Matte, RGB <= 212) chống lóa trên màn hình mobile
local THEME = {
	TextMain   = Color3.fromRGB(206, 210, 214),
	TextMuted  = Color3.fromRGB(154, 164, 182),
	TextGold   = Color3.fromRGB(210, 178, 74),
	TextGem    = Color3.fromRGB(104, 186, 204),
	TextGreen  = Color3.fromRGB(102, 192, 132),
	TextRed    = Color3.fromRGB(206, 104, 108),
	TextPurple = Color3.fromRGB(178, 132, 210),
	TextBlue   = Color3.fromRGB(96, 168, 210),
	FontHead   = Enum.Font.GothamSemibold,
	FontBody   = Enum.Font.GothamMedium,
}

-- Chọn nơi gắn GUI an toàn (chạy được cả Executor lẫn Roblox Studio)
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
-- BẬC HIẾM & 27 SKIN RẮN (GIỮ NGUYÊN 22 ID CŨ + 5 SKIN MỚI)
-- ============================================================
local RARITY_ORDER = { "All", "Common", "Rare", "Epic", "Legendary", "Mythic" }

local RARITIES = {
	All       = { Label = "Tất cả",      Color = Color3.fromRGB(180, 188, 202), BonusText = "" },
	Common    = { Label = "Thường",      Color = Color3.fromRGB(156, 168, 184), BonusText = "" },
	Rare      = { Label = "Hiếm",        Color = Color3.fromRGB(96, 168, 210),  BonusText = "+15% Xu" },
	Epic      = { Label = "Sử Thi",      Color = Color3.fromRGB(178, 132, 210), BonusText = "+35% Xu" },
	Legendary = { Label = "Huyền Thoại", Color = Color3.fromRGB(210, 178, 74),  BonusText = "+60% Xu" },
	Mythic    = { Label = "Thần Thoại",  Color = Color3.fromRGB(208, 96, 118),  BonusText = "+100% Xu & +1💎/150đ" },
}

local SKINS = {
	-- BẬC THƯỜNG & HIẾM (MUA BẰNG XU)
	{
		Id = "classic_green", Name = "Rắn Xanh Lá", Rarity = "Common", CoinMult = 1.0,
		Price = 0, Currency = "Coins",
		HeadColor = Color3.fromRGB(52, 198, 66), Body1 = Color3.fromRGB(36, 178, 56), Body2 = Color3.fromRGB(118, 210, 92),
	},
	{
		Id = "classic_red", Name = "Rắn Ác Quỷ Đỏ", Rarity = "Common", CoinMult = 1.0,
		Price = 500, Currency = "Coins",
		HeadColor = Color3.fromRGB(210, 52, 58), Body1 = Color3.fromRGB(192, 42, 46), Body2 = Color3.fromRGB(216, 204, 204),
		Style = "Devil", EyeColor = Color3.fromRGB(22, 12, 16),
	},
	{
		Id = "classic_blue", Name = "Rắn Băng Tuyết", Rarity = "Common", CoinMult = 1.0,
		Price = 1000, Currency = "Coins",
		HeadColor = Color3.fromRGB(48, 152, 215), Body1 = Color3.fromRGB(34, 124, 200), Body2 = Color3.fromRGB(122, 192, 218),
		Accessory = "❄️",
	},
	{
		Id = "classic_gold", Name = "Rắn Ong Vàng", Rarity = "Rare", CoinMult = 1.15,
		Price = 1800, Currency = "Coins",
		HeadColor = Color3.fromRGB(214, 178, 42), Body1 = Color3.fromRGB(205, 162, 28), Body2 = Color3.fromRGB(36, 32, 30),
	},
	{
		Id = "classic_purple", Name = "Rắn Hắc Long Tím", Rarity = "Rare", CoinMult = 1.15,
		Price = 2800, Currency = "Coins",
		HeadColor = Color3.fromRGB(152, 74, 215), Body1 = Color3.fromRGB(132, 54, 198), Body2 = Color3.fromRGB(186, 128, 216),
		Style = "DarkHorn",
	},
	{
		Id = "watermelon", Name = "Rắn Dưa Hấu", Rarity = "Rare", CoinMult = 1.15,
		Price = 4000, Currency = "Coins",
		HeadColor = Color3.fromRGB(208, 68, 82), Body1 = Color3.fromRGB(208, 68, 82), Body2 = Color3.fromRGB(42, 178, 88),
		Body3 = Color3.fromRGB(26, 26, 32),
	},
	{
		Id = "koi_fish", Name = "Rắn Cá Koi", Rarity = "Rare", CoinMult = 1.15,
		Price = 5000, Currency = "Coins",
		HeadColor = Color3.fromRGB(216, 212, 206), Body1 = Color3.fromRGB(214, 108, 42), Body2 = Color3.fromRGB(214, 210, 205),
		Body3 = Color3.fromRGB(198, 52, 46), Style = "Koi",
	},
	{
		Id = "panda", Name = "Rắn Gấu Trúc", Rarity = "Rare", CoinMult = 1.15,
		Price = 6000, Currency = "Coins",
		HeadColor = Color3.fromRGB(214, 216, 222), Body1 = Color3.fromRGB(214, 216, 222), Body2 = Color3.fromRGB(32, 34, 44),
		Style = "Panda",
	},
	{
		Id = "kitty", Name = "Rắn Mèo Nơ Hồng", Rarity = "Epic", CoinMult = 1.35,
		Price = 8500, Currency = "Coins",
		HeadColor = Color3.fromRGB(220, 202, 212), Body1 = Color3.fromRGB(208, 104, 158), Body2 = Color3.fromRGB(222, 194, 208),
		Style = "Kitty", Accessory = "🎀",
	},
	{
		Id = "zombie", Name = "Rắn Zombie", Rarity = "Epic", CoinMult = 1.35,
		Price = 12000, Currency = "Coins",
		HeadColor = Color3.fromRGB(96, 168, 90), Body1 = Color3.fromRGB(76, 152, 70), Body2 = Color3.fromRGB(148, 198, 62),
		Body3 = Color3.fromRGB(112, 72, 66), Style = "Zombie",
	},
	{
		Id = "pumpkin", Name = "Rắn Bí Ngô", Rarity = "Epic", CoinMult = 1.35,
		Price = 16000, Currency = "Coins",
		HeadColor = Color3.fromRGB(212, 108, 32), Body1 = Color3.fromRGB(196, 86, 22), Body2 = Color3.fromRGB(138, 52, 20),
		Style = "Pumpkin", EyeColor = Color3.fromRGB(214, 196, 110),
	},
	{
		Id = "king_snake", Name = "Vua Rắn Hoàng Kim", Rarity = "Legendary", CoinMult = 1.6,
		Price = 25000, Currency = "Coins",
		HeadColor = Color3.fromRGB(214, 174, 42), Body1 = Color3.fromRGB(202, 152, 26), Body2 = Color3.fromRGB(216, 200, 118),
		GlowColor = Color3.fromRGB(206, 172, 46), Accessory = "👑",
	},

	-- BẬC SỬ THI, HUYỀN THOẠI & THẦN THOẠI (MUA BẰNG KIM CƯƠNG)
	{
		Id = "deer_dragon", Name = "Thanh Long Hươu", Rarity = "Epic", CoinMult = 1.35,
		Price = 35, Currency = "Gems",
		HeadColor = Color3.fromRGB(30, 176, 192), Body1 = Color3.fromRGB(22, 148, 176), Body2 = Color3.fromRGB(20, 52, 76),
		Style = "Antlers", GlowColor = Color3.fromRGB(56, 182, 204),
	},
	{
		Id = "unicorn", Name = "Rắn Kỳ Lân", Rarity = "Epic", CoinMult = 1.35,
		Price = 55, Currency = "Gems",
		HeadColor = Color3.fromRGB(218, 204, 222), Body1 = Color3.fromRGB(206, 142, 214), Body2 = Color3.fromRGB(142, 206, 214),
		Body3 = Color3.fromRGB(216, 204, 126), Style = "Unicorn", GlowColor = Color3.fromRGB(196, 118, 212),
	},
	{
		Id = "skull", Name = "Rắn Đầu Lâu", Rarity = "Legendary", CoinMult = 1.6,
		Price = 80, Currency = "Gems",
		HeadColor = Color3.fromRGB(210, 210, 216), Body1 = Color3.fromRGB(28, 28, 38), Body2 = Color3.fromRGB(206, 206, 214),
		Style = "Skull", EyeColor = Color3.fromRGB(206, 54, 54),
	},
	{
		Id = "fire_dragon", Name = "Rồng Dung Nham", Rarity = "Legendary", CoinMult = 1.6,
		Price = 110, Currency = "Gems",
		HeadColor = Color3.fromRGB(48, 36, 44), Body1 = Color3.fromRGB(36, 26, 30), Body2 = Color3.fromRGB(212, 108, 32),
		Body3 = Color3.fromRGB(202, 68, 48), EyeColor = Color3.fromRGB(218, 122, 34),
		GlowColor = Color3.fromRGB(210, 132, 62), Accessory = "🔥",
	},
	{
		Id = "ice_dragon", Name = "Rồng Pha Lê Băng", Rarity = "Legendary", CoinMult = 1.6,
		Price = 140, Currency = "Gems",
		HeadColor = Color3.fromRGB(64, 182, 218), Body1 = Color3.fromRGB(26, 148, 204), Body2 = Color3.fromRGB(184, 214, 222),
		GlowColor = Color3.fromRGB(112, 188, 216), Accessory = "❄️",
	},
	{
		Id = "ghost_snake", Name = "Rắn Bóng Ma", Rarity = "Legendary", CoinMult = 1.6,
		Price = 180, Currency = "Gems",
		HeadColor = Color3.fromRGB(196, 212, 222), Body1 = Color3.fromRGB(162, 198, 216), Body2 = Color3.fromRGB(206, 216, 224),
		BodyAlpha = 0.34, GlowColor = Color3.fromRGB(126, 174, 212), EyeColor = Color3.fromRGB(62, 166, 210),
	},
	{
		Id = "dj_rainbow", Name = "Rắn Cầu Vồng RGB", Rarity = "Legendary", CoinMult = 1.6,
		Price = 220, Currency = "Gems",
		HeadColor = Color3.fromRGB(202, 78, 142), Body1 = Color3.fromRGB(202, 78, 142), Body2 = Color3.fromRGB(62, 166, 210),
		Rainbow = true, GlowColor = Color3.fromRGB(196, 202, 212), Accessory = "🎧",
	},
	{
		Id = "cyber_glitch", Name = "Rắn Lỗi Cyber", Rarity = "Legendary", CoinMult = 1.6,
		Price = 260, Currency = "Gems",
		HeadColor = Color3.fromRGB(24, 30, 44), Body1 = Color3.fromRGB(48, 192, 204), Body2 = Color3.fromRGB(198, 62, 148),
		Body3 = Color3.fromRGB(28, 34, 52), Glitch = true, Style = "Cyber",
		EyeColor = Color3.fromRGB(76, 208, 214), GlowColor = Color3.fromRGB(56, 192, 206),
	},
	{
		Id = "samurai", Name = "Rắn Samurai Đỏ", Rarity = "Legendary", CoinMult = 1.6,
		Price = 320, Currency = "Gems",
		HeadColor = Color3.fromRGB(178, 36, 44), Body1 = Color3.fromRGB(152, 32, 38), Body2 = Color3.fromRGB(44, 38, 46),
		Body3 = Color3.fromRGB(206, 172, 54), Style = "Samurai",
		EyeColor = Color3.fromRGB(214, 186, 68), GlowColor = Color3.fromRGB(204, 168, 52),
	},
	{
		Id = "galaxy", Name = "Rắn Ngân Hà", Rarity = "Mythic", CoinMult = 2.0, GemBonus = true,
		Price = 380, Currency = "Gems",
		HeadColor = Color3.fromRGB(52, 30, 114), Body1 = Color3.fromRGB(42, 24, 98), Body2 = Color3.fromRGB(124, 64, 204),
		Body3 = Color3.fromRGB(64, 168, 212), EyeColor = Color3.fromRGB(112, 204, 216),
		GlowColor = Color3.fromRGB(158, 92, 212), Accessory = "✨",
	},
	{
		Id = "golden_dragon", Name = "Rồng Vàng Hoàng Đế", Rarity = "Mythic", CoinMult = 2.0, GemBonus = true,
		Price = 500, Currency = "Gems",
		HeadColor = Color3.fromRGB(216, 172, 34), Body1 = Color3.fromRGB(204, 146, 24), Body2 = Color3.fromRGB(218, 204, 118),
		GlowColor = Color3.fromRGB(212, 192, 108), Accessory = "👑",
	},
	{
		Id = "angel", Name = "Rắn Thiên Thần", Rarity = "Mythic", CoinMult = 2.0, GemBonus = true,
		Price = 650, Currency = "Gems",
		HeadColor = Color3.fromRGB(218, 214, 204), Body1 = Color3.fromRGB(214, 214, 218), Body2 = Color3.fromRGB(208, 176, 52),
		Style = "Angel", GlowColor = Color3.fromRGB(212, 194, 114),
	},
	{
		Id = "phoenix", Name = "Phượng Hoàng Lửa", Rarity = "Mythic", CoinMult = 2.0, GemBonus = true,
		Price = 800, Currency = "Gems",
		HeadColor = Color3.fromRGB(208, 72, 34), Body1 = Color3.fromRGB(196, 52, 34), Body2 = Color3.fromRGB(214, 142, 34),
		Body3 = Color3.fromRGB(216, 188, 66), Style = "Phoenix",
		EyeColor = Color3.fromRGB(218, 204, 92), GlowColor = Color3.fromRGB(212, 134, 46),
	},
	{
		Id = "cosmic_god", Name = "Thần Vũ Trụ", Rarity = "Mythic", CoinMult = 2.0, GemBonus = true,
		Price = 1000, Currency = "Gems",
		HeadColor = Color3.fromRGB(28, 16, 68), Body1 = Color3.fromRGB(34, 18, 86), Body2 = Color3.fromRGB(208, 176, 48),
		Body3 = Color3.fromRGB(154, 86, 206), EyeColor = Color3.fromRGB(214, 196, 110),
		Style = "Cosmic", GlowColor = Color3.fromRGB(206, 174, 52),
	},
	{
		Id = "void_emperor", Name = "Đế Vương Hư Không", Rarity = "Mythic", CoinMult = 2.0, GemBonus = true,
		Price = 1250, Currency = "Gems",
		HeadColor = Color3.fromRGB(20, 14, 34), Body1 = Color3.fromRGB(28, 18, 48), Body2 = Color3.fromRGB(132, 54, 196),
		Body3 = Color3.fromRGB(76, 32, 132), Style = "Void",
		EyeColor = Color3.fromRGB(192, 116, 216), GlowColor = Color3.fromRGB(154, 78, 212),
	},
}

local function getSkinById(id)
	for _, s in ipairs(SKINS) do
		if s.Id == id then return s end
	end
	return SKINS[1]
end

local FOODS = {
	{ Icon = "🍎", Score = 10, Coins = 5 },
	{ Icon = "🍓", Score = 10, Coins = 5 },
	{ Icon = "🍇", Score = 12, Coins = 6 },
	{ Icon = "🍉", Score = 12, Coins = 6 },
	{ Icon = "🍄", Score = 15, Coins = 8 },
	{ Icon = "🧀", Score = 15, Coins = 8 },
	{ Icon = "🍔", Score = 20, Coins = 10 },
	{ Icon = "🍕", Score = 20, Coins = 10 },
	{ Icon = "🍩", Score = 22, Coins = 12 },
	{ Icon = "🍰", Score = 25, Coins = 15 },
}

local POWERUPS = {
	{ Id = "Double", Icon = "⭐", Color = Color3.fromRGB(208, 176, 52), Name = "2x Điểm" },
	{ Id = "Ghost",  Icon = "👻", Color = Color3.fromRGB(172, 152, 210), Name = "Bóng Ma" },
	{ Id = "Shield", Icon = "🛡️", Color = Color3.fromRGB(82, 168, 210),  Name = "Khiên" },
	{ Id = "Magnet", Icon = "🧲", Color = Color3.fromRGB(204, 102, 104), Name = "Nam Châm" },
	{ Id = "Speed",  Icon = "⚡", Color = Color3.fromRGB(210, 190, 74),  Name = "Tăng Tốc" },
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

local function createDefaultQuests()
	return {
		{ Id = "eat",   Title = "Ăn 15 món ăn bất kỳ",     Goal = 15,  Progress = 0, Reward = 180, Currency = "Coins", Claimed = false },
		{ Id = "score", Title = "Đạt 150 điểm trong 1 ván", Goal = 150, Progress = 0, Reward = 12,  Currency = "Gems",  Claimed = false },
		{ Id = "power", Title = "Nhặt 3 vật phẩm kỹ năng",  Goal = 3,   Progress = 0, Reward = 15,  Currency = "Gems",  Claimed = false },
		{ Id = "games", Title = "Chơi hoàn thành 3 ván",    Goal = 3,   Progress = 0, Reward = 350, Currency = "Coins", Claimed = false },
	}
end

local function createDefaultState()
	return {
		Coins = 250,
		Gems = 12,
		Level = 1,
		Exp = 0,
		ExpNeed = 100,
		HighScore = 0,
		OwnedSkins = { classic_green = true },
		EquippedSkin = "classic_green",
		NextGiftUnix = 0,
		Settings = {
			WallPass = false,
			SpeedMode = 2,
			SmoothMove = true,
			BombsEnabled = true,
			ShowDpad = true,
		},
		Quests = createDefaultQuests(),
	}
end

local state = createDefaultState()

-- ============================================================
-- HỆ THỐNG LƯU & TẢI DỮ LIỆU TỰ ĐỘNG (FILE JSON + RAM)
-- ============================================================
local canWriteFile = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local saveModeName = canWriteFile and "File lưu vĩnh viễn" or "Bộ nhớ tạm (RAM)"
local UI = {}

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
		Level = state.Level,
		Exp = state.Exp,
		ExpNeed = state.ExpNeed,
		HighScore = state.HighScore,
		OwnedSkins = state.OwnedSkins,
		EquippedSkin = state.EquippedSkin,
		NextGiftUnix = state.NextGiftUnix,
		Settings = state.Settings,
		QuestProgress = questProgress,
	}
end

local function applyLoadedData(raw)
	if type(raw) ~= "table" then return end
	if type(raw.Coins) == "number" then state.Coins = raw.Coins end
	if type(raw.Gems) == "number" then state.Gems = raw.Gems end
	if type(raw.Level) == "number" then state.Level = math.max(1, raw.Level) end
	if type(raw.Exp) == "number" then state.Exp = math.max(0, raw.Exp) end
	if type(raw.ExpNeed) == "number" then state.ExpNeed = math.max(50, raw.ExpNeed) end
	if type(raw.HighScore) == "number" then state.HighScore = math.max(0, raw.HighScore) end
	if type(raw.NextGiftUnix) == "number" then state.NextGiftUnix = raw.NextGiftUnix end

	if type(raw.OwnedSkins) == "table" then
		state.OwnedSkins = { classic_green = true }
		for k, v in pairs(raw.OwnedSkins) do
			if v == true then state.OwnedSkins[k] = true end
		end
	end
	if type(raw.EquippedSkin) == "string" and state.OwnedSkins[raw.EquippedSkin] then
		state.EquippedSkin = raw.EquippedSkin
	end
	if type(raw.Settings) == "table" then
		if type(raw.Settings.WallPass) == "boolean" then state.Settings.WallPass = raw.Settings.WallPass end
		if type(raw.Settings.SpeedMode) == "number" then state.Settings.SpeedMode = math.clamp(raw.Settings.SpeedMode, 1, 3) end
		if type(raw.Settings.SmoothMove) == "boolean" then state.Settings.SmoothMove = raw.Settings.SmoothMove end
		if type(raw.Settings.BombsEnabled) == "boolean" then state.Settings.BombsEnabled = raw.Settings.BombsEnabled end
		if type(raw.Settings.ShowDpad) == "boolean" then state.Settings.ShowDpad = raw.Settings.ShowDpad end
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

local function flashSaveBadge(text, color)
	local lbl = UI.saveStatusLbl
	if not lbl then return end
	lbl.Text = text
	lbl.TextColor3 = color
	task.delay(1.6, function()
		if lbl and lbl.Parent then
			lbl.Text = "💾 Tự động lưu"
			lbl.TextColor3 = THEME.TextGreen
		end
	end)
end

local function saveData()
	local payload = packSaveData()
	local okEnc, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
	if not okEnc then return false end

	local cache = getCacheRoot()
	cache["SnakeArcadePro_JSON_" .. tostring(player.UserId)] = encoded

	if canWriteFile then
		local okWrite = pcall(writefile, SAVE_FILE, encoded)
		if okWrite then
			flashSaveBadge("✔ Đã lưu file", THEME.TextGreen)
			return true
		end
	end
	flashSaveBadge("✔ Đã lưu RAM", THEME.TextGem)
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
-- HÀM DỰNG UI & ĐẦU RẮN ĐẶC TRƯNG CHO 27 SKIN
-- ============================================================
local function addCorner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(14, 17, 26)
	s.Thickness = thickness or 1.6
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function addGradient(parent, topColor, botColor, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(topColor, botColor)
	g.Rotation = rot or 90
	g.Parent = parent
	return g
end

local function makeCoinIcon(parent, sizePx, pos)
	local coin = Instance.new("Frame")
	coin.Size = UDim2.fromOffset(sizePx, sizePx)
	coin.Position = pos
	coin.AnchorPoint = Vector2.new(0, 0.5)
	coin.BackgroundColor3 = Color3.fromRGB(206, 172, 46)
	coin.BorderSizePixel = 0
	coin.Parent = parent
	addCorner(coin, 99)
	addStroke(coin, Color3.fromRGB(132, 82, 16), 1.4)
	addGradient(coin, Color3.fromRGB(214, 196, 110), Color3.fromRGB(192, 146, 22), 90)

	local dollar = Instance.new("TextLabel")
	dollar.Size = UDim2.fromScale(1, 1)
	dollar.BackgroundTransparency = 1
	dollar.Text = "$"
	dollar.TextColor3 = Color3.fromRGB(108, 52, 14)
	dollar.Font = THEME.FontHead
	dollar.TextSize = math.max(10, math.floor(sizePx * 0.7))
	dollar.Parent = coin
	return coin
end

local function makeGlossyBtn(parent, text, size, pos, topColor, botColor, cornerRadius)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos or UDim2.new()
	b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	b.TextColor3 = THEME.TextMain
	b.TextStrokeTransparency = 1
	b.Font = THEME.FontHead
	b.TextSize = 13
	b.Text = text
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.Parent = parent
	addCorner(b, cornerRadius or 10)
	addStroke(b, Color3.fromRGB(16, 20, 32), 1.6)
	addGradient(b, topColor, botColor or topColor, 90)
	return b
end

local function makeNotifDot(parent)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(11, 11)
	dot.Position = UDim2.new(1, -13, 0, 4)
	dot.BackgroundColor3 = Color3.fromRGB(208, 66, 66)
	dot.BorderSizePixel = 0
	dot.Visible = false
	dot.ZIndex = 10
	dot.Parent = parent
	addCorner(dot, 99)
	addStroke(dot, Color3.fromRGB(200, 206, 212), 1.3)
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

local function buildCartoonHead(parent, sizePx, skin)
	local head = Instance.new("Frame")
	head.Size = UDim2.fromOffset(sizePx, sizePx)
	head.AnchorPoint = Vector2.new(0.5, 0.5)
	head.BackgroundColor3 = skin.HeadColor
	head.BackgroundTransparency = skin.BodyAlpha or 0
	head.BorderSizePixel = 0
	head.ZIndex = 6
	head.Parent = parent
	addCorner(head, math.floor(sizePx * 0.48))
	addStroke(head, skin.GlowColor or Color3.fromRGB(14, 16, 24), math.max(1.6, sizePx * 0.07))

	local shine = Instance.new("Frame")
	shine.Size = UDim2.fromScale(0.4, 0.2)
	shine.Position = UDim2.fromScale(0.16, 0.12)
	shine.BackgroundColor3 = Color3.fromRGB(220, 224, 230)
	shine.BackgroundTransparency = 0.72
	shine.BorderSizePixel = 0
	shine.ZIndex = 7
	shine.Parent = head
	addCorner(shine, 99)

	local tongue = Instance.new("Frame")
	tongue.Size = UDim2.fromScale(0.36, 0.16)
	tongue.Position = UDim2.fromScale(0.92, 0.42)
	tongue.BackgroundColor3 = Color3.fromRGB(206, 52, 62)
	tongue.BorderSizePixel = 0
	tongue.ZIndex = 5
	tongue.Parent = head
	addCorner(tongue, 4)
	addStroke(tongue, Color3.fromRGB(20, 10, 12), 1.1)

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
			addStroke(ear, Color3.fromRGB(16, 18, 26), 1.3)
		end
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
			addStroke(horn, Color3.fromRGB(16, 16, 24), 1.2)
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
		addStroke(stem, Color3.fromRGB(16, 30, 16), 1.1)
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
		eyeWhite.BackgroundColor3 = (st == "Skull" or st == "Pumpkin" or st == "Void") and Color3.fromRGB(22, 18, 28) or Color3.fromRGB(218, 220, 226)
		eyeWhite.BorderSizePixel = 0
		eyeWhite.ZIndex = 8
		eyeWhite.Parent = head
		addCorner(eyeWhite, 99)
		addStroke(eyeWhite, Color3.fromRGB(16, 16, 24), 1.1)

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
		glint.BackgroundColor3 = Color3.fromRGB(218, 222, 228)
		glint.BorderSizePixel = 0
		glint.ZIndex = 10
		glint.Parent = pupil
		addCorner(glint, 99)
	end

	if skin.Accessory then
		local acc = Instance.new("TextLabel")
		acc.BackgroundTransparency = 1
		acc.Size = UDim2.fromScale(0.62, 0.62)
		acc.Position = UDim2.fromScale(-0.14, 0.19)
		acc.ZIndex = 11
		acc.TextScaled = true
		acc.Font = THEME.FontHead
		acc.Text = skin.Accessory
		acc.Parent = head
	end

	return head
end

-- ============================================================
-- CỬA SỔ CHÍNH & THANH ĐẦU TRANG
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local floatBtn = makeGlossyBtn(
	screenGui, "🐍",
	UDim2.fromOffset(48, 48),
	UDim2.new(0, 16, 0.5, -24),
	Color3.fromRGB(58, 178, 98), Color3.fromRGB(28, 128, 66), 24
)
floatBtn.TextSize = 22
floatBtn.Visible = false
local floatDragged = false
makeDraggable(floatBtn, floatBtn, function(v) floatDragged = v end)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(620, 404)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 18)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 34)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
addCorner(mainFrame, 16)
addStroke(mainFrame, Color3.fromRGB(96, 78, 182), 2)
addGradient(mainFrame, Color3.fromRGB(24, 26, 46), Color3.fromRGB(14, 16, 28), 90)

local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame

local function calcScale()
	local cam = workspace.CurrentCamera
	if not cam then return 1 end
	local vp = cam.ViewportSize
	local scaleX = (vp.X - 24) / 620
	local scaleY = (vp.Y - 68) / 404
	return math.clamp(math.min(1, scaleX, scaleY), 0.48, 1)
end
uiScale.Scale = calcScale()

-- Dựng thanh Top Bar trong khối do..end để tiết kiệm biến local
do
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 48)
	topBar.BackgroundColor3 = Color3.fromRGB(28, 30, 52)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame
	addGradient(topBar, Color3.fromRGB(38, 36, 72), Color3.fromRGB(22, 24, 42), 90)
	makeDraggable(topBar, mainFrame)

	local profileBox = Instance.new("Frame")
	profileBox.Size = UDim2.fromOffset(176, 36)
	profileBox.Position = UDim2.fromOffset(10, 6)
	profileBox.BackgroundColor3 = Color3.fromRGB(18, 20, 34)
	profileBox.BorderSizePixel = 0
	profileBox.Parent = topBar
	addCorner(profileBox, 18)
	addStroke(profileBox, Color3.fromRGB(92, 76, 174), 1.4)

	local avatarIconHolder = Instance.new("Frame")
	avatarIconHolder.Size = UDim2.fromOffset(28, 28)
	avatarIconHolder.Position = UDim2.fromOffset(6, 4)
	avatarIconHolder.BackgroundTransparency = 1
	avatarIconHolder.Parent = profileBox
	UI.avatarIconHolder = avatarIconHolder

	local profileName = Instance.new("TextLabel")
	profileName.Size = UDim2.fromOffset(124, 16)
	profileName.Position = UDim2.fromOffset(42, 3)
	profileName.BackgroundTransparency = 1
	profileName.Text = player.DisplayName
	profileName.TextColor3 = THEME.TextMain
	profileName.Font = THEME.FontHead
	profileName.TextSize = 12
	profileName.TextXAlignment = Enum.TextXAlignment.Left
	profileName.TextTruncate = Enum.TextTruncate.AtEnd
	profileName.Parent = profileBox

	local lvLabel = Instance.new("TextLabel")
	lvLabel.Size = UDim2.fromOffset(42, 12)
	lvLabel.Position = UDim2.fromOffset(42, 20)
	lvLabel.BackgroundTransparency = 1
	lvLabel.Text = "Lv. 1"
	lvLabel.TextColor3 = THEME.TextGold
	lvLabel.Font = THEME.FontHead
	lvLabel.TextSize = 11
	lvLabel.TextXAlignment = Enum.TextXAlignment.Left
	lvLabel.Parent = profileBox
	UI.lvLabel = lvLabel

	local expBg = Instance.new("Frame")
	expBg.Size = UDim2.fromOffset(78, 8)
	expBg.Position = UDim2.fromOffset(86, 22)
	expBg.BackgroundColor3 = Color3.fromRGB(36, 40, 62)
	expBg.BorderSizePixel = 0
	expBg.Parent = profileBox
	addCorner(expBg, 4)

	local expFill = Instance.new("Frame")
	expFill.Size = UDim2.fromScale(0.1, 1)
	expFill.BackgroundColor3 = Color3.fromRGB(72, 186, 112)
	expFill.BorderSizePixel = 0
	expFill.Parent = expBg
	addCorner(expFill, 4)
	UI.expFill = expFill

	local coinPill = Instance.new("Frame")
	coinPill.Size = UDim2.fromOffset(118, 32)
	coinPill.Position = UDim2.fromOffset(194, 8)
	coinPill.BackgroundColor3 = Color3.fromRGB(18, 20, 34)
	coinPill.BorderSizePixel = 0
	coinPill.Parent = topBar
	addCorner(coinPill, 16)
	addStroke(coinPill, Color3.fromRGB(82, 70, 150), 1.4)
	makeCoinIcon(coinPill, 20, UDim2.new(0, 7, 0.5, 0))

	local coinsLbl = Instance.new("TextLabel")
	coinsLbl.Size = UDim2.new(1, -32, 1, 0)
	coinsLbl.Position = UDim2.fromOffset(30, 0)
	coinsLbl.BackgroundTransparency = 1
	coinsLbl.Text = formatNum(state.Coins)
	coinsLbl.TextColor3 = THEME.TextGold
	coinsLbl.Font = THEME.FontHead
	coinsLbl.TextSize = 13
	coinsLbl.TextXAlignment = Enum.TextXAlignment.Left
	coinsLbl.Parent = coinPill
	UI.coinsLbl = coinsLbl

	local gemPill = Instance.new("Frame")
	gemPill.Size = UDim2.fromOffset(106, 32)
	gemPill.Position = UDim2.fromOffset(318, 8)
	gemPill.BackgroundColor3 = Color3.fromRGB(18, 20, 34)
	gemPill.BorderSizePixel = 0
	gemPill.Parent = topBar
	addCorner(gemPill, 16)
	addStroke(gemPill, Color3.fromRGB(82, 70, 150), 1.4)

	local gemsLbl = Instance.new("TextLabel")
	gemsLbl.Size = UDim2.new(1, -8, 1, 0)
	gemsLbl.Position = UDim2.fromOffset(4, 0)
	gemsLbl.BackgroundTransparency = 1
	gemsLbl.Text = "💎 " .. formatNum(state.Gems)
	gemsLbl.TextColor3 = THEME.TextGem
	gemsLbl.Font = THEME.FontHead
	gemsLbl.TextSize = 13
	gemsLbl.Parent = gemPill
	UI.gemsLbl = gemsLbl

	local saveStatusLbl = Instance.new("TextLabel")
	saveStatusLbl.Size = UDim2.fromOffset(108, 32)
	saveStatusLbl.Position = UDim2.fromOffset(430, 8)
	saveStatusLbl.BackgroundTransparency = 1
	saveStatusLbl.Text = hadSavedData and "✔ Đã tải dữ liệu" or "💾 Tự động lưu"
	saveStatusLbl.TextColor3 = THEME.TextGreen
	saveStatusLbl.Font = THEME.FontBody
	saveStatusLbl.TextSize = 11
	saveStatusLbl.Parent = topBar
	UI.saveStatusLbl = saveStatusLbl

	UI.minBtn = makeGlossyBtn(topBar, "-", UDim2.fromOffset(30, 30), UDim2.new(1, -72, 0, 9), Color3.fromRGB(76, 84, 110), Color3.fromRGB(48, 54, 74), 8)
	UI.closeBtn = makeGlossyBtn(topBar, "X", UDim2.fromOffset(30, 30), UDim2.new(1, -36, 0, 9), Color3.fromRGB(192, 62, 64), Color3.fromRGB(142, 34, 38), 8)
	UI.minBtn.TextSize = 16
	UI.closeBtn.TextSize = 14
end

-- ============================================================
-- VÙNG NỘI DUNG: SẢNH CHỜ & MÀN CHƠI
-- ============================================================
local container = Instance.new("Frame")
container.Size = UDim2.fromOffset(600, 342)
container.Position = UDim2.fromOffset(10, 54)
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
-- 1. SẢNH CHỜ (LOBBY)
-- ============================================================
do
	local showcaseCard = Instance.new("Frame")
	showcaseCard.Size = UDim2.fromOffset(362, 270)
	showcaseCard.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
	showcaseCard.BorderSizePixel = 0
	showcaseCard.Parent = lobbyPage
	addCorner(showcaseCard, 14)
	addStroke(showcaseCard, Color3.fromRGB(66, 60, 122), 1.6)
	addGradient(showcaseCard, Color3.fromRGB(30, 34, 60), Color3.fromRGB(16, 19, 32), 90)

	local showcaseTitle = Instance.new("TextLabel")
	showcaseTitle.Size = UDim2.new(1, 0, 0, 32)
	showcaseTitle.Position = UDim2.fromOffset(0, 6)
	showcaseTitle.BackgroundTransparency = 1
	showcaseTitle.Text = "🐍 RẮN SĂN MỒI PRO " .. VERSION_TEXT
	showcaseTitle.TextColor3 = THEME.TextGold
	showcaseTitle.Font = THEME.FontHead
	showcaseTitle.TextSize = 18
	showcaseTitle.Parent = showcaseCard

	local previewStage = Instance.new("Frame")
	previewStage.Size = UDim2.fromOffset(330, 96)
	previewStage.Position = UDim2.fromOffset(16, 42)
	previewStage.BackgroundColor3 = Color3.fromRGB(14, 17, 30)
	previewStage.BorderSizePixel = 0
	previewStage.ClipsDescendants = true
	previewStage.Parent = showcaseCard
	addCorner(previewStage, 12)
	addStroke(previewStage, Color3.fromRGB(54, 62, 96), 1.4)
	UI.previewStage = previewStage

	local equippedSkinLbl = Instance.new("TextLabel")
	equippedSkinLbl.Size = UDim2.new(1, -12, 0, 24)
	equippedSkinLbl.Position = UDim2.fromOffset(6, 142)
	equippedSkinLbl.BackgroundTransparency = 1
	equippedSkinLbl.Text = "Skin: Rắn Xanh Lá"
	equippedSkinLbl.TextColor3 = THEME.TextGem
	equippedSkinLbl.Font = THEME.FontBody
	equippedSkinLbl.TextSize = 12
	equippedSkinLbl.Parent = showcaseCard
	UI.equippedSkinLbl = equippedSkinLbl

	UI.playBtn = makeGlossyBtn(
		showcaseCard, "▶  CHƠI NGAY",
		UDim2.fromOffset(230, 54),
		UDim2.fromOffset(66, 174),
		Color3.fromRGB(56, 184, 96), Color3.fromRGB(26, 134, 66), 24
	)
	UI.playBtn.TextSize = 19

	local bestScoreTip = Instance.new("TextLabel")
	bestScoreTip.Size = UDim2.new(1, 0, 0, 24)
	bestScoreTip.Position = UDim2.fromOffset(0, 236)
	bestScoreTip.BackgroundTransparency = 1
	bestScoreTip.Text = "🏆 Kỷ lục của bạn: 0 điểm"
	bestScoreTip.TextColor3 = THEME.TextMuted
	bestScoreTip.Font = THEME.FontBody
	bestScoreTip.TextSize = 12
	bestScoreTip.Parent = showcaseCard
	UI.bestScoreTip = bestScoreTip

	-- Bảng Xếp Hạng Top 10
	local lbCard = Instance.new("Frame")
	lbCard.Size = UDim2.fromOffset(228, 270)
	lbCard.Position = UDim2.fromOffset(372, 0)
	lbCard.BackgroundColor3 = Color3.fromRGB(20, 22, 38)
	lbCard.BorderSizePixel = 0
	lbCard.Parent = lobbyPage
	addCorner(lbCard, 14)
	addStroke(lbCard, Color3.fromRGB(116, 58, 184), 1.8)

	local lbHeader = Instance.new("Frame")
	lbHeader.Size = UDim2.new(1, 0, 0, 34)
	lbHeader.BackgroundColor3 = Color3.fromRGB(116, 52, 184)
	lbHeader.BorderSizePixel = 0
	lbHeader.Parent = lbCard
	addCorner(lbHeader, 12)
	addGradient(lbHeader, Color3.fromRGB(132, 68, 198), Color3.fromRGB(88, 36, 168), 90)

	local lbTitle = Instance.new("TextLabel")
	lbTitle.Size = UDim2.fromScale(1, 1)
	lbTitle.BackgroundTransparency = 1
	lbTitle.Text = "🏆 BẢNG XẾP HẠNG"
	lbTitle.TextColor3 = THEME.TextGold
	lbTitle.Font = THEME.FontHead
	lbTitle.TextSize = 13
	lbTitle.Parent = lbHeader

	local lbList = Instance.new("Frame")
	lbList.Size = UDim2.new(1, -12, 1, -42)
	lbList.Position = UDim2.fromOffset(6, 38)
	lbList.BackgroundTransparency = 1
	lbList.Parent = lbCard
	UI.lbList = lbList

	local lbLayout = Instance.new("UIListLayout")
	lbLayout.Padding = UDim.new(0, 2)
	lbLayout.Parent = lbList

	local bottomBar = Instance.new("Frame")
	bottomBar.Size = UDim2.fromOffset(600, 56)
	bottomBar.Position = UDim2.fromOffset(0, 280)
	bottomBar.BackgroundTransparency = 1
	bottomBar.Parent = lobbyPage

	local bLayout = Instance.new("UIListLayout")
	bLayout.FillDirection = Enum.FillDirection.Horizontal
	bLayout.Padding = UDim.new(0, 8)
	bLayout.Parent = bottomBar

	UI.shopBtn     = makeGlossyBtn(bottomBar, "🏪 SHOP (27)", UDim2.fromOffset(113, 50), nil, Color3.fromRGB(196, 112, 48), Color3.fromRGB(168, 48, 44), 12)
	UI.giftBtn     = makeGlossyBtn(bottomBar, "🎁 QUÀ TẶNG",  UDim2.fromOffset(114, 50), nil, Color3.fromRGB(146, 86, 198), Color3.fromRGB(98, 40, 164), 12)
	UI.questBtn    = makeGlossyBtn(bottomBar, "📋 NHIỆM VỤ",  UDim2.fromOffset(114, 50), nil, Color3.fromRGB(48, 146, 198), Color3.fromRGB(30, 82, 168), 12)
	UI.settingsBtn = makeGlossyBtn(bottomBar, "⚙️ CÀI ĐẶT",   UDim2.fromOffset(114, 50), nil, Color3.fromRGB(186, 148, 36), Color3.fromRGB(156, 94, 18), 12)
	UI.exitBtn     = makeGlossyBtn(bottomBar, "X THOÁT",      UDim2.fromOffset(113, 50), nil, Color3.fromRGB(194, 72, 74),  Color3.fromRGB(142, 34, 38), 12)
	UI.shopBtn.TextSize = 12

	UI.giftDot  = makeNotifDot(UI.giftBtn)
	UI.questDot = makeNotifDot(UI.questBtn)
end

local previewSegs = {}
local previewHead = nil

local function refreshLeaderboard()
	for _, ch in ipairs(UI.lbList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	local entries = {}
	for _, b in ipairs(BOT_SCORES) do
		table.insert(entries, { Name = b.Name, Score = b.Score, IsYou = false })
	end
	table.insert(entries, { Name = "Bạn (" .. player.DisplayName .. ")", Score = state.HighScore, IsYou = true })
	table.sort(entries, function(a, b) return a.Score > b.Score end)

	for i = 1, math.min(10, #entries) do
		local e = entries[i]
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 20)
		row.BackgroundColor3 = e.IsYou and Color3.fromRGB(96, 68, 22) or Color3.fromRGB(28, 31, 52)
		row.BackgroundTransparency = e.IsYou and 0.2 or 0.55
		row.BorderSizePixel = 0
		row.Parent = UI.lbList
		addCorner(row, 5)

		local medal = (i == 1 and "👑") or (i == 2 and "🥈") or (i == 3 and "🥉") or tostring(i)
		local rankLbl = Instance.new("TextLabel")
		rankLbl.Size = UDim2.fromOffset(24, 20)
		rankLbl.Position = UDim2.fromOffset(4, 0)
		rankLbl.BackgroundTransparency = 1
		rankLbl.Text = medal
		rankLbl.TextColor3 = THEME.TextGold
		rankLbl.Font = THEME.FontHead
		rankLbl.TextSize = 11
		rankLbl.Parent = row

		local nLbl = Instance.new("TextLabel")
		nLbl.Size = UDim2.fromOffset(126, 20)
		nLbl.Position = UDim2.fromOffset(28, 0)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = e.Name
		nLbl.TextColor3 = e.IsYou and THEME.TextGold or THEME.TextMain
		nLbl.Font = e.IsYou and THEME.FontHead or THEME.FontBody
		nLbl.TextSize = 11
		nLbl.TextXAlignment = Enum.TextXAlignment.Left
		nLbl.TextTruncate = Enum.TextTruncate.AtEnd
		nLbl.Parent = row

		local sLbl = Instance.new("TextLabel")
		sLbl.Size = UDim2.fromOffset(54, 20)
		sLbl.Position = UDim2.new(1, -58, 0, 0)
		sLbl.BackgroundTransparency = 1
		sLbl.Text = formatNum(e.Score)
		sLbl.TextColor3 = THEME.TextGold
		sLbl.Font = THEME.FontHead
		sLbl.TextSize = 11
		sLbl.TextXAlignment = Enum.TextXAlignment.Right
		sLbl.Parent = row
	end
end

local function rebuildLobbyPreview()
	for _, ch in ipairs(UI.previewStage:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.avatarIconHolder:GetChildren()) do ch:Destroy() end
	previewSegs = {}

	local skin = getSkinById(state.EquippedSkin)
	local rar = RARITIES[skin.Rarity] or RARITIES.Common
	local bonusStr = (rar.BonusText ~= "") and (" • " .. rar.BonusText) or ""
	UI.equippedSkinLbl.Text = skin.Name .. "  [" .. rar.Label .. "]" .. bonusStr
	UI.equippedSkinLbl.TextColor3 = rar.Color

	local miniAvatar = buildCartoonHead(UI.avatarIconHolder, 24, skin)
	miniAvatar.Position = UDim2.fromScale(0.5, 0.5)

	for i = 10, 1, -1 do
		local sz = math.max(16, 31 - (i * 1.25))
		local seg = Instance.new("Frame")
		seg.Size = UDim2.fromOffset(sz, sz)
		seg.AnchorPoint = Vector2.new(0.5, 0.5)
		seg.BackgroundColor3 = getSegmentColor(skin, i)
		seg.BackgroundTransparency = skin.BodyAlpha or 0
		seg.BorderSizePixel = 0
		seg.ZIndex = 5 - math.floor(i / 4)
		seg.Parent = UI.previewStage
		addCorner(seg, 99)
		addStroke(seg, skin.GlowColor or Color3.fromRGB(14, 16, 24), 1.8)
		previewSegs[i] = seg
	end
	previewHead = buildCartoonHead(UI.previewStage, 35, skin)
end

-- ============================================================
-- CẬP NHẬT CHỈ SỐ & CÁC BẢNG POPUP (SHOP CÓ LỌC BẬC HIẾM)
-- ============================================================
local function refreshNotifDots()
	UI.giftDot.Visible = (os.time() >= state.NextGiftUnix)
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
	UI.coinsLbl.Text = formatNum(state.Coins)
	UI.gemsLbl.Text  = "💎 " .. formatNum(state.Gems)
	UI.lvLabel.Text  = "Lv. " .. tostring(state.Level)
	UI.expFill.Size  = UDim2.fromScale(math.clamp(state.Exp / state.ExpNeed, 0.06, 1), 1)
	UI.bestScoreTip.Text = "🏆 Kỷ lục của bạn: " .. formatNum(state.HighScore) .. " điểm"
	refreshLeaderboard()
	refreshNotifDots()
end

local function addExp(amount)
	state.Exp += amount
	while state.Exp >= state.ExpNeed do
		state.Exp -= state.ExpNeed
		state.Level += 1
		state.ExpNeed = math.floor(state.ExpNeed * 1.35)
		state.Gems += 3
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

local activeModalTag = nil
local liveGiftBtn = nil
local shopFilter = "All"

do
	local modalOverlay = Instance.new("Frame")
	modalOverlay.Size = UDim2.fromScale(1, 1)
	modalOverlay.BackgroundColor3 = Color3.fromRGB(6, 8, 14)
	modalOverlay.BackgroundTransparency = 0.28
	modalOverlay.Visible = false
	modalOverlay.ZIndex = 30
	modalOverlay.Parent = mainFrame
	UI.modalOverlay = modalOverlay

	local modalBox = Instance.new("Frame")
	modalBox.Size = UDim2.fromOffset(500, 342)
	modalBox.Position = UDim2.fromScale(0.5, 0.5)
	modalBox.AnchorPoint = Vector2.new(0.5, 0.5)
	modalBox.BackgroundColor3 = Color3.fromRGB(22, 25, 42)
	modalBox.BorderSizePixel = 0
	modalBox.ZIndex = 31
	modalBox.Parent = modalOverlay
	addCorner(modalBox, 14)
	addStroke(modalBox, Color3.fromRGB(116, 82, 198), 2)

	local modalTitle = Instance.new("TextLabel")
	modalTitle.Size = UDim2.new(1, -55, 0, 36)
	modalTitle.Position = UDim2.fromOffset(14, 4)
	modalTitle.BackgroundTransparency = 1
	modalTitle.TextColor3 = THEME.TextGold
	modalTitle.Font = THEME.FontHead
	modalTitle.TextSize = 15
	modalTitle.TextXAlignment = Enum.TextXAlignment.Left
	modalTitle.ZIndex = 32
	modalTitle.Parent = modalBox
	UI.modalTitle = modalTitle

	local modalClose = makeGlossyBtn(modalBox, "X", UDim2.fromOffset(28, 28), UDim2.new(1, -36, 0, 8), Color3.fromRGB(194, 62, 64), Color3.fromRGB(142, 34, 38), 8)
	modalClose.TextSize = 14
	modalClose.ZIndex = 33
	modalClose.MouseButton1Click:Connect(function()
		modalOverlay.Visible = false
		activeModalTag = nil
		liveGiftBtn = nil
	end)

	local modalFilterBar = Instance.new("Frame")
	modalFilterBar.Size = UDim2.new(1, -20, 0, 28)
	modalFilterBar.Position = UDim2.fromOffset(10, 42)
	modalFilterBar.BackgroundTransparency = 1
	modalFilterBar.Visible = false
	modalFilterBar.ZIndex = 32
	modalFilterBar.Parent = modalBox
	UI.modalFilterBar = modalFilterBar

	local fLayout = Instance.new("UIListLayout")
	fLayout.FillDirection = Enum.FillDirection.Horizontal
	fLayout.Padding = UDim.new(0, 5)
	fLayout.Parent = modalFilterBar

	local modalBody = Instance.new("ScrollingFrame")
	modalBody.Size = UDim2.new(1, -18, 1, -52)
	modalBody.Position = UDim2.fromOffset(9, 44)
	modalBody.BackgroundTransparency = 1
	modalBody.ScrollBarThickness = 5
	modalBody.CanvasSize = UDim2.new(0, 0, 0, 0)
	modalBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
	modalBody.ZIndex = 32
	modalBody.Parent = modalBox
	UI.modalBody = modalBody
end

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
		UI.modalBody.Position = UDim2.fromOffset(9, 76)
		UI.modalBody.Size = UDim2.new(1, -18, 1, -84)
	else
		UI.modalBody.Position = UDim2.fromOffset(9, 44)
		UI.modalBody.Size = UDim2.new(1, -18, 1, -52)
	end

	activeModalTag = tag
	liveGiftBtn = nil
	UI.modalTitle.Text = titleText
	UI.modalOverlay.Visible = true
end

-- POPUP SHOP 27 SKIN + BỘ LỌC BẬC HIẾM
local function openShop()
	local ownedCount = 0
	for _, s in ipairs(SKINS) do
		if state.OwnedSkins[s.Id] then ownedCount += 1 end
	end
	openModal("Shop", "🏪 CỬA HÀNG RẮN (" .. ownedCount .. "/" .. #SKINS .. " SKIN)", true)

	for _, ch in ipairs(UI.modalFilterBar:GetChildren()) do
		if ch:IsA("TextButton") then ch:Destroy() end
	end
	for _, key in ipairs(RARITY_ORDER) do
		local rInfo = RARITIES[key]
		local isSel = (shopFilter == key)
		local fBtn = makeGlossyBtn(
			UI.modalFilterBar, rInfo.Label,
			UDim2.fromOffset(75, 26), nil,
			isSel and Color3.fromRGB(92, 68, 178) or Color3.fromRGB(36, 40, 66),
			isSel and Color3.fromRGB(64, 46, 134) or Color3.fromRGB(26, 30, 50),
			7
		)
		fBtn.TextSize = 10
		fBtn.TextColor3 = isSel and THEME.TextMain or rInfo.Color
		fBtn.ZIndex = 34
		fBtn.MouseButton1Click:Connect(function()
			shopFilter = key
			openShop()
		end)
	end

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(224, 86)
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
			card.BackgroundColor3 = Color3.fromRGB(28, 32, 54)
			card.BorderSizePixel = 0
			card.ZIndex = 33
			card.Parent = UI.modalBody
			addCorner(card, 10)
			addStroke(card, equipped and THEME.TextGreen or rar.Color, equipped and 2 or 1.4)

			local headBox = Instance.new("Frame")
			headBox.Size = UDim2.fromOffset(44, 44)
			headBox.Position = UDim2.fromOffset(10, 21)
			headBox.BackgroundTransparency = 1
			headBox.ZIndex = 34
			headBox.Parent = card
			local h = buildCartoonHead(headBox, 32, skin)
			h.Position = UDim2.fromScale(0.5, 0.5)
			h.ZIndex = 35
			for _, d in ipairs(h:GetDescendants()) do
				if d:IsA("GuiObject") then d.ZIndex += 30 end
			end

			local nLbl = Instance.new("TextLabel")
			nLbl.Size = UDim2.fromOffset(158, 18)
			nLbl.Position = UDim2.fromOffset(60, 6)
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
			rarLbl.Size = UDim2.fromOffset(158, 15)
			rarLbl.Position = UDim2.fromOffset(60, 24)
			rarLbl.BackgroundTransparency = 1
			rarLbl.Text = rar.Label .. (rar.BonusText ~= "" and (" • " .. rar.BonusText) or "")
			rarLbl.TextColor3 = rar.Color
			rarLbl.Font = THEME.FontBody
			rarLbl.TextSize = 10
			rarLbl.TextXAlignment = Enum.TextXAlignment.Left
			rarLbl.TextTruncate = Enum.TextTruncate.AtEnd
			rarLbl.ZIndex = 34
			rarLbl.Parent = card

			local btnText, c1, c2
			if equipped then
				btnText = "✔ ĐANG DÙNG"
				c1, c2 = Color3.fromRGB(54, 174, 94), Color3.fromRGB(28, 126, 62)
			elseif owned then
				btnText = "TRANG BỊ"
				c1, c2 = Color3.fromRGB(48, 148, 198), Color3.fromRGB(32, 86, 172)
			else
				local curLabel = (skin.Currency == "Gems") and ("💎 " .. formatNum(skin.Price)) or (formatNum(skin.Price) .. " Xu")
				btnText = "MUA " .. curLabel
				if skin.Currency == "Gems" then
					c1, c2 = Color3.fromRGB(146, 86, 198), Color3.fromRGB(98, 40, 164)
				else
					c1, c2 = Color3.fromRGB(186, 148, 34), Color3.fromRGB(152, 92, 18)
				end
			end

			local actBtn = makeGlossyBtn(card, btnText, UDim2.fromOffset(152, 30), UDim2.fromOffset(60, 46), c1, c2, 8)
			actBtn.TextSize = 11
			actBtn.ZIndex = 35
			actBtn.MouseButton1Click:Connect(function()
				if state.OwnedSkins[skin.Id] then
					state.EquippedSkin = skin.Id
					saveData()
					rebuildLobbyPreview()
					openShop()
				else
					if skin.Currency == "Coins" and state.Coins >= skin.Price then
						state.Coins -= skin.Price
						state.OwnedSkins[skin.Id] = true
						state.EquippedSkin = skin.Id
						updateTopStats()
						saveData()
						rebuildLobbyPreview()
						openShop()
					elseif skin.Currency == "Gems" and state.Gems >= skin.Price then
						state.Gems -= skin.Price
						state.OwnedSkins[skin.Id] = true
						state.EquippedSkin = skin.Id
						updateTopStats()
						saveData()
						rebuildLobbyPreview()
						openShop()
					else
						actBtn.Text = "KHÔNG ĐỦ TIỀN!"
						task.delay(0.8, function()
							if actBtn.Parent then actBtn.Text = btnText end
						end)
					end
				end
			end)
		end
	end
end

local function openGift()
	openModal("Gift", "🎁 QUÀ TẶNG MIỄN PHÍ", false)
	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, 0, 0, 96)
	desc.Position = UDim2.fromOffset(0, 14)
	desc.BackgroundTransparency = 1
	desc.Text = "🎁 HỘP QUÀ MAY MẮN\nNhận ngay +220 Xu và +6 💎 Kim Cương\n(Hồi lại sau mỗi 60 giây - tự động lưu)"
	desc.TextColor3 = THEME.TextMain
	desc.Font = THEME.FontBody
	desc.TextSize = 14
	desc.ZIndex = 33
	desc.Parent = UI.modalBody

	local remain = math.max(0, state.NextGiftUnix - os.time())
	local ready = (remain <= 0)
	local claimBtn = makeGlossyBtn(
		UI.modalBody,
		ready and "🎉 NHẬN QUÀ NGAY!" or ("⏳ CHỜ " .. remain .. " GIÂY"),
		UDim2.fromOffset(236, 50),
		UDim2.fromOffset(116, 128),
		ready and Color3.fromRGB(54, 174, 94) or Color3.fromRGB(78, 86, 114),
		ready and Color3.fromRGB(28, 126, 62) or Color3.fromRGB(54, 60, 82),
		14
	)
	claimBtn.TextSize = 15
	claimBtn.ZIndex = 34
	liveGiftBtn = claimBtn

	claimBtn.MouseButton1Click:Connect(function()
		if os.time() < state.NextGiftUnix then return end
		state.NextGiftUnix = os.time() + 60
		state.Coins += 220
		state.Gems += 6
		updateTopStats()
		saveData()
		openGift()
	end)
end

local function openQuests()
	openModal("Quests", "📋 NHIỆM VỤ NHẬN THƯỞNG", false)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = UI.modalBody

	local allClaimed = true
	for _, q in ipairs(state.Quests) do
		if not q.Claimed then allClaimed = false end
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 56)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 54)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = UI.modalBody
		addCorner(row, 10)
		addStroke(row, Color3.fromRGB(62, 70, 104), 1.4)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.fromOffset(304, 24)
		title.Position = UDim2.fromOffset(12, 6)
		title.BackgroundTransparency = 1
		title.Text = q.Title .. " (" .. math.min(q.Progress, q.Goal) .. "/" .. q.Goal .. ")"
		title.TextColor3 = THEME.TextMain
		title.Font = THEME.FontBody
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 34
		title.Parent = row

		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.fromOffset(286, 10)
		barBg.Position = UDim2.fromOffset(12, 34)
		barBg.BackgroundColor3 = Color3.fromRGB(18, 20, 34)
		barBg.BorderSizePixel = 0
		barBg.ZIndex = 34
		barBg.Parent = row
		addCorner(barBg, 5)

		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.fromScale(math.clamp(q.Progress / q.Goal, 0, 1), 1)
		barFill.BackgroundColor3 = Color3.fromRGB(64, 178, 104)
		barFill.BorderSizePixel = 0
		barFill.ZIndex = 35
		barFill.Parent = barBg
		addCorner(barFill, 5)

		local rewardTxt = (q.Currency == "Gems") and (formatNum(q.Reward) .. " 💎") or (formatNum(q.Reward) .. " Xu")
		local canClaim = (q.Progress >= q.Goal) and not q.Claimed
		local btnText = q.Claimed and "✔ ĐÃ NHẬN" or (canClaim and ("NHẬN +" .. rewardTxt) or rewardTxt)
		local cBtn = makeGlossyBtn(
			row, btnText,
			UDim2.fromOffset(132, 34), UDim2.new(1, -142, 0, 11),
			canClaim and Color3.fromRGB(54, 174, 94) or Color3.fromRGB(72, 80, 108),
			canClaim and Color3.fromRGB(28, 126, 62) or Color3.fromRGB(50, 56, 78),
			8
		)
		cBtn.TextSize = 11
		cBtn.ZIndex = 35
		cBtn.MouseButton1Click:Connect(function()
			if not canClaim then return end
			q.Claimed = true
			if q.Currency == "Gems" then state.Gems += q.Reward else state.Coins += q.Reward end
			addExp(35)
			openQuests()
		end)
	end

	-- Cho phép làm mới bộ nhiệm vụ sau khi đã hoàn thành toàn bộ 4/4
	if allClaimed then
		local refreshRow = Instance.new("Frame")
		refreshRow.Size = UDim2.new(1, -2, 0, 48)
		refreshRow.BackgroundColor3 = Color3.fromRGB(28, 34, 58)
		refreshRow.BorderSizePixel = 0
		refreshRow.ZIndex = 33
		refreshRow.Parent = UI.modalBody
		addCorner(refreshRow, 10)

		local rBtn = makeGlossyBtn(
			refreshRow, "🔄 LÀM MỚI BỘ NHIỆM VỤ (CÀY TIẾP)",
			UDim2.fromOffset(290, 34), UDim2.new(0.5, -145, 0.5, -17),
			Color3.fromRGB(146, 86, 198), Color3.fromRGB(98, 40, 164), 9
		)
		rBtn.TextSize = 12
		rBtn.ZIndex = 35
		rBtn.MouseButton1Click:Connect(function()
			state.Quests = createDefaultQuests()
			saveData()
			refreshNotifDots()
			openQuests()
		end)
	end
end

local function openSettings()
	openModal("Settings", "⚙️ CÀI ĐẶT & LƯU DỮ LIỆU", false)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = UI.modalBody

	local function addSettingRow(labelTxt, getText, onToggle, c1, c2)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 46)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 54)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = UI.modalBody
		addCorner(row, 10)

		local l = Instance.new("TextLabel")
		l.Size = UDim2.fromOffset(275, 46)
		l.Position = UDim2.fromOffset(12, 0)
		l.BackgroundTransparency = 1
		l.Text = labelTxt
		l.TextColor3 = THEME.TextMain
		l.Font = THEME.FontBody
		l.TextSize = 13
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = 34
		l.Parent = row

		local b = makeGlossyBtn(row, getText(), UDim2.fromOffset(150, 32), UDim2.new(1, -160, 0, 7), c1 or Color3.fromRGB(48, 146, 198), c2 or Color3.fromRGB(30, 84, 168), 8)
		b.TextSize = 11
		b.ZIndex = 35
		b.MouseButton1Click:Connect(function()
			onToggle(b)
			b.Text = getText()
		end)
	end

	addSettingRow("🧱 Chế độ Xuyên Tường", function()
		return state.Settings.WallPass and "BẬT (Xuyên tường)" or "TẮT (Cổ điển)"
	end, function()
		state.Settings.WallPass = not state.Settings.WallPass
		saveData()
	end)

	local speedNames = { "Chậm (Dễ cua)", "Vừa", "Nhanh" }
	addSettingRow("⚡ Tốc độ Rắn", function()
		return speedNames[state.Settings.SpeedMode]
	end, function()
		state.Settings.SpeedMode = (state.Settings.SpeedMode % 3) + 1
		saveData()
	end)

	addSettingRow("🎯 Kiểu di chuyển", function()
		return state.Settings.SmoothMove and "Trượt mượt" or "Từng ô (Chuẩn 1 ô)"
	end, function()
		state.Settings.SmoothMove = not state.Settings.SmoothMove
		saveData()
	end)

	addSettingRow("💣 Xuất hiện Bom né tránh", function()
		return state.Settings.BombsEnabled and "BẬT" or "TẮT"
	end, function()
		state.Settings.BombsEnabled = not state.Settings.BombsEnabled
		saveData()
	end)

	addSettingRow("🎮 Cụm phím cảm ứng D-Pad", function()
		return state.Settings.ShowDpad and "HIỆN" or "ẨN"
	end, function()
		state.Settings.ShowDpad = not state.Settings.ShowDpad
		saveData()
	end)

	addSettingRow("💾 Lưu dữ liệu (" .. saveModeName .. ")", function()
		return "LƯU NGAY"
	end, function(btn)
		saveData()
		btn.Text = "✔ ĐÃ LƯU!"
		task.delay(0.9, function()
			if btn.Parent then btn.Text = "LƯU NGAY" end
		end)
	end, Color3.fromRGB(54, 174, 94), Color3.fromRGB(28, 126, 62))

	local confirmReset = false
	addSettingRow("🗑️ Xóa toàn bộ dữ liệu đã lưu", function()
		return confirmReset and "BẤM LẠI ĐỂ XÓA!" or "RESET DỮ LIỆU"
	end, function()
		if not confirmReset then
			confirmReset = true
			return
		end
		confirmReset = false
		state = createDefaultState()
		saveData()
		rebuildLobbyPreview()
		updateTopStats()
		openSettings()
	end, Color3.fromRGB(194, 72, 74), Color3.fromRGB(142, 34, 38))
end

UI.shopBtn.MouseButton1Click:Connect(openShop)
UI.giftBtn.MouseButton1Click:Connect(openGift)
UI.questBtn.MouseButton1Click:Connect(openQuests)
UI.settingsBtn.MouseButton1Click:Connect(openSettings)

-- ============================================================
-- 2. MÀN HÌNH CHƠI GAME RẮN SĂN MỒI
-- ============================================================
local COLS, ROWS, CELL = 16, 12, 24

do
	local hudBar = Instance.new("Frame")
	hudBar.Size = UDim2.fromOffset(600, 36)
	hudBar.BackgroundColor3 = Color3.fromRGB(24, 28, 46)
	hudBar.BorderSizePixel = 0
	hudBar.Parent = gamePage
	addCorner(hudBar, 10)
	addStroke(hudBar, Color3.fromRGB(62, 70, 108), 1.4)

	local liveScoreLbl = Instance.new("TextLabel")
	liveScoreLbl.Size = UDim2.fromOffset(374, 36)
	liveScoreLbl.Position = UDim2.fromOffset(12, 0)
	liveScoreLbl.BackgroundTransparency = 1
	liveScoreLbl.Text = "Điểm: 0  |  +0 Xu  |  +0 💎"
	liveScoreLbl.TextColor3 = THEME.TextGold
	liveScoreLbl.Font = THEME.FontHead
	liveScoreLbl.TextSize = 12
	liveScoreLbl.TextXAlignment = Enum.TextXAlignment.Left
	liveScoreLbl.Parent = hudBar
	UI.liveScoreLbl = liveScoreLbl

	UI.pauseBtn   = makeGlossyBtn(hudBar, "II", UDim2.fromOffset(38, 28), UDim2.new(1, -206, 0, 4), Color3.fromRGB(48, 146, 198), Color3.fromRGB(30, 84, 168), 8)
	UI.restartBtn = makeGlossyBtn(hudBar, "🔄 Lại", UDim2.fromOffset(72, 28), UDim2.new(1, -162, 0, 4), Color3.fromRGB(54, 174, 94), Color3.fromRGB(28, 126, 62), 8)
	UI.lobbyBtn   = makeGlossyBtn(hudBar, "🏠 Sảnh", UDim2.fromOffset(78, 28), UDim2.new(1, -84, 0, 4), Color3.fromRGB(142, 78, 196), Color3.fromRGB(94, 38, 164), 8)
	UI.restartBtn.TextSize = 11
	UI.lobbyBtn.TextSize = 11

	local board = Instance.new("Frame")
	board.Size = UDim2.fromOffset(COLS * CELL, ROWS * CELL)
	board.Position = UDim2.fromOffset(0, 44)
	board.BackgroundColor3 = Color3.fromRGB(13, 17, 30)
	board.BorderSizePixel = 0
	board.ClipsDescendants = true
	board.Active = true
	board.Parent = gamePage
	addCorner(board, 10)
	addStroke(board, Color3.fromRGB(72, 82, 128), 1.8)
	UI.board = board

	for x = 1, COLS do
		for y = 1, ROWS do
			if (x + y) % 2 == 0 then
				local tile = Instance.new("Frame")
				tile.Size = UDim2.fromOffset(CELL, CELL)
				tile.Position = UDim2.fromOffset((x - 1) * CELL, (y - 1) * CELL)
				tile.BackgroundColor3 = Color3.fromRGB(19, 24, 40)
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
	gameOverCard.Size = UDim2.fromOffset(296, 178)
	gameOverCard.Position = UDim2.fromScale(0.5, 0.5)
	gameOverCard.AnchorPoint = Vector2.new(0.5, 0.5)
	gameOverCard.BackgroundColor3 = Color3.fromRGB(20, 22, 38)
	gameOverCard.BorderSizePixel = 0
	gameOverCard.Visible = false
	gameOverCard.ZIndex = 20
	gameOverCard.Parent = board
	addCorner(gameOverCard, 14)
	addStroke(gameOverCard, Color3.fromRGB(194, 78, 82), 2)
	UI.gameOverCard = gameOverCard

	local goTitle = Instance.new("TextLabel")
	goTitle.Size = UDim2.new(1, 0, 0, 34)
	goTitle.Position = UDim2.fromOffset(0, 10)
	goTitle.BackgroundTransparency = 1
	goTitle.Text = "💀 KẾT THÚC!"
	goTitle.TextColor3 = THEME.TextRed
	goTitle.Font = THEME.FontHead
	goTitle.TextSize = 18
	goTitle.ZIndex = 21
	goTitle.Parent = gameOverCard
	UI.goTitle = goTitle

	local goStats = Instance.new("TextLabel")
	goStats.Size = UDim2.new(1, -20, 0, 62)
	goStats.Position = UDim2.fromOffset(10, 48)
	goStats.BackgroundTransparency = 1
	goStats.Text = ""
	goStats.TextColor3 = THEME.TextMain
	goStats.Font = THEME.FontBody
	goStats.TextSize = 12
	goStats.ZIndex = 21
	goStats.Parent = gameOverCard
	UI.goStats = goStats

	UI.goReplayBtn = makeGlossyBtn(gameOverCard, "🔄 CHƠI LẠI", UDim2.fromOffset(124, 38), UDim2.fromOffset(18, 124), Color3.fromRGB(54, 174, 94), Color3.fromRGB(28, 126, 62), 10)
	UI.goLobbyBtn  = makeGlossyBtn(gameOverCard, "🏠 VỀ SẢNH", UDim2.fromOffset(124, 38), UDim2.fromOffset(154, 124), Color3.fromRGB(142, 78, 196), Color3.fromRGB(94, 38, 164), 10)
	UI.goReplayBtn.ZIndex = 22
	UI.goLobbyBtn.ZIndex  = 22

	local rightPanel = Instance.new("Frame")
	rightPanel.Size = UDim2.fromOffset(204, 288)
	rightPanel.Position = UDim2.fromOffset(396, 44)
	rightPanel.BackgroundTransparency = 1
	rightPanel.Parent = gamePage

	local buffBox = Instance.new("Frame")
	buffBox.Size = UDim2.fromOffset(204, 106)
	buffBox.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
	buffBox.BorderSizePixel = 0
	buffBox.Parent = rightPanel
	addCorner(buffBox, 12)
	addStroke(buffBox, Color3.fromRGB(62, 70, 104), 1.4)

	local buffHeader = Instance.new("TextLabel")
	buffHeader.Size = UDim2.new(1, 0, 0, 20)
	buffHeader.Position = UDim2.fromOffset(0, 4)
	buffHeader.BackgroundTransparency = 1
	buffHeader.Text = "✨ KỸ NĂNG & COMBO"
	buffHeader.TextColor3 = THEME.TextGem
	buffHeader.Font = THEME.FontHead
	buffHeader.TextSize = 11
	buffHeader.Parent = buffBox

	local comboBarBg = Instance.new("Frame")
	comboBarBg.Size = UDim2.new(1, -16, 0, 6)
	comboBarBg.Position = UDim2.fromOffset(8, 25)
	comboBarBg.BackgroundColor3 = Color3.fromRGB(32, 36, 56)
	comboBarBg.BorderSizePixel = 0
	comboBarBg.Visible = false
	comboBarBg.Parent = buffBox
	addCorner(comboBarBg, 4)
	UI.comboBarBg = comboBarBg

	local comboBarFill = Instance.new("Frame")
	comboBarFill.Size = UDim2.fromScale(1, 1)
	comboBarFill.BackgroundColor3 = Color3.fromRGB(206, 162, 42)
	comboBarFill.BorderSizePixel = 0
	comboBarFill.Parent = comboBarBg
	addCorner(comboBarFill, 4)
	UI.comboBarFill = comboBarFill

	local buffStatusLbl = Instance.new("TextLabel")
	buffStatusLbl.Size = UDim2.new(1, -12, 1, -34)
	buffStatusLbl.Position = UDim2.fromOffset(6, 33)
	buffStatusLbl.BackgroundTransparency = 1
	buffStatusLbl.Text = "Vuốt trên bàn cờ hoặc lướt\nD-Pad để cua chuẩn từng ô!"
	buffStatusLbl.TextColor3 = THEME.TextMuted
	buffStatusLbl.Font = THEME.FontBody
	buffStatusLbl.TextSize = 11
	buffStatusLbl.TextWrapped = true
	buffStatusLbl.Parent = buffBox
	UI.buffStatusLbl = buffStatusLbl

	local dpadFrame = Instance.new("Frame")
	dpadFrame.Size = UDim2.fromOffset(204, 174)
	dpadFrame.Position = UDim2.fromOffset(0, 114)
	dpadFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
	dpadFrame.BorderSizePixel = 0
	dpadFrame.Active = true
	dpadFrame.Parent = rightPanel
	addCorner(dpadFrame, 12)
	addStroke(dpadFrame, Color3.fromRGB(62, 70, 104), 1.4)
	UI.dpadFrame = dpadFrame

	UI.dUp    = makeGlossyBtn(dpadFrame, "▲", UDim2.fromOffset(56, 54), UDim2.fromOffset(74, 4),   Color3.fromRGB(48, 146, 198), Color3.fromRGB(28, 76, 164), 16)
	UI.dLeft  = makeGlossyBtn(dpadFrame, "◄", UDim2.fromOffset(56, 54), UDim2.fromOffset(16, 60),  Color3.fromRGB(48, 146, 198), Color3.fromRGB(28, 76, 164), 16)
	UI.dRight = makeGlossyBtn(dpadFrame, "►", UDim2.fromOffset(56, 54), UDim2.fromOffset(132, 60), Color3.fromRGB(48, 146, 198), Color3.fromRGB(28, 76, 164), 16)
	UI.dDown  = makeGlossyBtn(dpadFrame, "▼", UDim2.fromOffset(56, 54), UDim2.fromOffset(74, 116), Color3.fromRGB(48, 146, 198), Color3.fromRGB(28, 76, 164), 16)
	UI.dUp.TextSize, UI.dLeft.TextSize, UI.dRight.TextSize, UI.dDown.TextSize = 18, 18, 18, 18

	local dCenterDot = Instance.new("Frame")
	dCenterDot.Size = UDim2.fromOffset(36, 36)
	dCenterDot.Position = UDim2.fromOffset(84, 69)
	dCenterDot.BackgroundColor3 = Color3.fromRGB(32, 38, 66)
	dCenterDot.BorderSizePixel = 0
	dCenterDot.Parent = dpadFrame
	addCorner(dCenterDot, 18)
end

local function flashDpadBtn(btn)
	if not btn then return end
	local stroke = btn:FindFirstChildOfClass("UIStroke")
	if not stroke then return end
	stroke.Color = THEME.TextGold
	stroke.Thickness = 2.6
	task.delay(0.14, function()
		if stroke and stroke.Parent then
			stroke.Color = Color3.fromRGB(16, 20, 32)
			stroke.Thickness = 1.6
		end
	end)
end

-- ============================================================
-- LOGIC GAME RẮN SĂN MỒI (CUA 1 Ô + COMBO + NỘI TẠI THẦN THOẠI)
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
	comboCount = 0,
	comboTimer = 0,
	mythicGemStep = 0,
	stepTimer = 0,
	stepDuration = 0.23,
	powerSpawnTimer = 0,
	bombSpawnTimer = 0,
	buffs = { Double = 0, Ghost = 0, Magnet = 0, Speed = 0, Shield = false, Invuln = 0 },
	boardItems = {},
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
end

local function clearSnakeVisuals()
	for _, ch in ipairs(UI.snakeLayer:GetChildren()) do ch:Destroy() end
	Game.bodyFrames = {}
	Game.activeHeadNode = nil
	Game.shieldRing = nil
end

local function findFreeCell(avoidNearHead)
	local free = {}
	local head = Game.snake[1]
	for x = 1, COLS do
		for y = 1, ROWS do
			local busy = false
			for _, seg in ipairs(Game.snake) do
				if seg.x == x and seg.y == y then busy = true break end
			end
			if not busy then
				for _, it in ipairs(Game.boardItems) do
					if it.X == x and it.Y == y then busy = true break end
				end
			end
			if not busy and avoidNearHead and head then
				if math.abs(x - head.x) + math.abs(y - head.y) <= 3 then busy = true end
			end
			if not busy then table.insert(free, { x = x, y = y }) end
		end
	end
	return #free > 0 and free[math.random(1, #free)] or nil
end

local function spawnItem(itemType, customData, lifeTime)
	local pos = findFreeCell(itemType == "Bomb")
	if not pos then return end

	local cx, cy = cellToCenter(pos.x, pos.y)
	local node

	if itemType == "Coin" then
		node = Instance.new("Frame")
		node.Size = UDim2.fromOffset(CELL - 4, CELL - 4)
		node.AnchorPoint = Vector2.new(0.5, 0.5)
		node.Position = UDim2.fromOffset(cx, cy)
		node.BackgroundColor3 = Color3.fromRGB(208, 174, 46)
		node.BorderSizePixel = 0
		node.ZIndex = 3
		node.Parent = UI.itemLayer
		addCorner(node, 99)
		addStroke(node, Color3.fromRGB(132, 82, 16), 1.6)

		local sym = Instance.new("TextLabel")
		sym.Size = UDim2.fromScale(1, 1)
		sym.BackgroundTransparency = 1
		sym.Text = "$"
		sym.TextColor3 = Color3.fromRGB(108, 52, 14)
		sym.Font = THEME.FontHead
		sym.TextSize = 13
		sym.ZIndex = 4
		sym.Parent = node
	else
		node = Instance.new("TextLabel")
		node.Size = UDim2.fromOffset(CELL, CELL)
		node.AnchorPoint = Vector2.new(0.5, 0.5)
		node.Position = UDim2.fromOffset(cx, cy)
		node.BackgroundTransparency = (itemType == "Power") and 0.72 or 1
		node.BackgroundColor3 = (customData and customData.Color) or Color3.fromRGB(200, 204, 210)
		node.Font = THEME.FontHead
		node.TextScaled = true
		node.ZIndex = 3
		if itemType == "Food" then node.Text = customData.Icon
		elseif itemType == "Gem" then node.Text = "💎"
		elseif itemType == "Power" then
			node.Text = customData.Icon
			addCorner(node, 99)
			addStroke(node, customData.Color, 1.4)
		elseif itemType == "Bomb" then node.Text = "💣" end
		node.Parent = UI.itemLayer
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
	local comboTxt = (Game.comboCount >= 2) and ("  |  🔥x" .. Game.comboCount) or ""
	UI.liveScoreLbl.Text = string.format(
		"Điểm: %s  |  +%s Xu  |  +%s 💎%s",
		formatNum(Game.runScore), formatNum(Game.runCoins), formatNum(Game.runGems), comboTxt
	)

	UI.comboBarBg.Visible = (Game.comboTimer > 0 and Game.comboCount >= 1)
	if UI.comboBarBg.Visible then
		UI.comboBarFill.Size = UDim2.fromScale(math.clamp(Game.comboTimer / 3.5, 0, 1), 1)
	end

	local lines = {}
	if Game.comboCount >= 2 then
		table.insert(lines, string.format("🔥 Combo x%d (+%d%% điểm)", Game.comboCount, (Game.comboCount - 1) * 20))
	end
	if Game.buffs.Double > 0 then table.insert(lines, string.format("⭐ 2x Điểm: %.1fs", Game.buffs.Double)) end
	if Game.buffs.Ghost  > 0 then table.insert(lines, string.format("👻 Bóng Ma: %.1fs", Game.buffs.Ghost)) end
	if Game.buffs.Magnet > 0 then table.insert(lines, string.format("🧲 Nam Châm: %.1fs", Game.buffs.Magnet)) end
	if Game.buffs.Speed  > 0 then table.insert(lines, string.format("⚡ Tăng Tốc: %.1fs", Game.buffs.Speed)) end
	if Game.buffs.Shield then table.insert(lines, "🛡️ Khiên: Đỡ 1 đòn") end

	if #lines == 0 then
		local skin = getSkinById(state.EquippedSkin)
		local rar = RARITIES[skin.Rarity] or RARITIES.Common
		local bonusInfo = (rar.BonusText ~= "") and ("\nSkin: " .. rar.BonusText) or ""
		UI.buffStatusLbl.Text = "Vuốt bàn cờ hoặc lướt D-Pad\nđể cua chuẩn từng ô!" .. bonusInfo
		UI.buffStatusLbl.TextColor3 = THEME.TextMuted
	else
		UI.buffStatusLbl.Text = table.concat(lines, "\n")
		UI.buffStatusLbl.TextColor3 = THEME.TextGold
	end
end

local function syncSnakeNodes()
	local skin = getSkinById(state.EquippedSkin)
	if not Game.activeHeadNode then
		Game.activeHeadNode = buildCartoonHead(UI.snakeLayer, CELL + 4, skin)
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
		addStroke(seg, skin.GlowColor or Color3.fromRGB(14, 16, 24), 1.6)
		table.insert(Game.bodyFrames, seg)
	end
	for i = 1, #Game.bodyFrames do
		Game.bodyFrames[i].Visible = (i <= needBody)
		if i <= needBody then
			local taper = (i > needBody - 3) and (CELL - 1 - (3 - (needBody - i)) * 2) or CELL
			taper = math.max(14, taper)
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

local function endRun(reasonText)
	Game.playing = false
	local isRecord = false
	if Game.runScore > state.HighScore then
		state.HighScore = Game.runScore
		isRecord = true
	end
	state.Coins += Game.runCoins
	state.Gems  += Game.runGems
	addQuestProgress("games", 1, false)
	addQuestProgress("score", Game.runScore, true)
	addExp(math.floor(Game.runScore * 0.4) + 10)

	UI.goTitle.Text = "💀 " .. reasonText
	UI.goStats.Text = string.format(
		"Điểm ván này: %s %s\nNhận: +%s Xu  |  +%s 💎  (Đã tự lưu!)",
		formatNum(Game.runScore), isRecord and "🏆(KỶ LỤC!)" or "", formatNum(Game.runCoins), formatNum(Game.runGems)
	)
	UI.gameOverCard.Visible = true
end

local function startNewRun()
	clearItems()
	clearSnakeVisuals()
	UI.gameOverCard.Visible = false
	UI.dpadFrame.Visible = state.Settings.ShowDpad

	Game.snake = { { x = 6, y = 6 }, { x = 5, y = 6 }, { x = 4, y = 6 }, { x = 3, y = 6 } }
	Game.prevSnake = {}
	for i, s in ipairs(Game.snake) do Game.prevSnake[i] = { x = s.x, y = s.y } end

	Game.dir = { x = 1, y = 0 }
	Game.turnQueue = {}
	Game.runScore, Game.runCoins, Game.runGems = 0, 0, 0
	Game.comboCount, Game.comboTimer, Game.mythicGemStep = 0, 0, 0
	Game.buffs = { Double = 0, Ghost = 0, Magnet = 0, Speed = 0, Shield = false, Invuln = 0 }
	Game.stepTimer, Game.powerSpawnTimer, Game.bombSpawnTimer = 0, 4, 6
	Game.paused = false
	UI.pauseBtn.Text = "II"
	Game.playing = true

	syncSnakeNodes()
	ensureFoodExists()
	spawnItem("Coin", nil, 15)
	updateHUD()
	renderSnakeSmooth(1)
end

local function openLobby()
	if Game.playing and (Game.runCoins > 0 or Game.runGems > 0 or Game.runScore > 0) then
		state.Coins += Game.runCoins
		state.Gems  += Game.runGems
		if Game.runScore > state.HighScore then state.HighScore = Game.runScore end
		Game.runScore, Game.runCoins, Game.runGems = 0, 0, 0
		saveData()
	end
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
	liveGiftBtn = nil
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

	local canWrap = state.Settings.WallPass or Game.buffs.Ghost > 0 or Game.buffs.Invuln > 0
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

	if Game.buffs.Magnet > 0 then
		for _, it in ipairs(Game.boardItems) do
			if it.Type == "Food" or it.Type == "Coin" or it.Type == "Gem" then
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
			local mult = (Game.buffs.Double > 0 and 2 or 1) * (Game.buffs.Speed > 0 and 1.5 or 1)
			if it.Type == "Food" then
				grew = true
				Game.comboCount = math.min(5, Game.comboCount + 1)
				Game.comboTimer = 3.5
				local comboMult = 1 + ((Game.comboCount - 1) * 0.2)
				Game.runScore += math.floor(it.Data.Score * mult * comboMult)
				Game.runCoins += math.floor(it.Data.Coins * mult * skinCoinMult * comboMult)
				addQuestProgress("eat", 1, false)
				addQuestProgress("score", Game.runScore, true)
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			elseif it.Type == "Coin" then
				Game.runCoins += math.floor(25 * mult * skinCoinMult)
				Game.runScore += math.floor(15 * mult)
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
			elseif it.Type == "Gem" then
				Game.runGems += 2
				Game.runScore += math.floor(30 * mult)
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
			elseif it.Type == "Bomb" then
				it.Node:Destroy()
				table.remove(Game.boardItems, i)
				if Game.buffs.Ghost <= 0 and Game.buffs.Invuln <= 0 then
					if Game.buffs.Shield then
						Game.buffs.Shield = false
						Game.buffs.Invuln = 1.6
					else
						endRun("TRÚNG BOM!")
						return
					end
				end
			end
		end
	end

	-- Nội tại bậc Thần Thoại: thưởng thêm +1 💎 mỗi mốc 150 điểm
	if skin.GemBonus then
		local curStep = math.floor(Game.runScore / 150)
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
		if roll <= 22 then spawnItem("Coin", nil, 14)
		elseif roll <= 30 then spawnItem("Gem", nil, 12) end
	end
	updateHUD()
end

-- ============================================================
-- ĐIỀU KHIỂN CẢM ỨNG NHẠY (CHẠM TỨC THÌ + LƯỚT D-PAD + VUỐT)
-- ============================================================
do
	local dpadSliding = false
	local lastSlideDir = nil
	local swipeActive = false
	local swipeOrigin = nil

	local function triggerDpadDir(dx, dy, btn)
		local key = dx .. "," .. dy
		if lastSlideDir == key then return end
		lastSlideDir = key
		queueTurn(dx, dy)
		flashDpadBtn(btn)
	end

	local function handleDpadPoint(pos)
		if not Game.playing or Game.paused then return end
		local center = UI.dpadFrame.AbsolutePosition + (UI.dpadFrame.AbsoluteSize * 0.5)
		local diff = Vector2.new(pos.X - center.X, pos.Y - center.Y)
		if diff.Magnitude < 14 then return end
		if math.abs(diff.X) > math.abs(diff.Y) then
			if diff.X > 0 then triggerDpadDir(1, 0, UI.dRight) else triggerDpadDir(-1, 0, UI.dLeft) end
		else
			if diff.Y > 0 then triggerDpadDir(0, 1, UI.dDown) else triggerDpadDir(0, -1, UI.dUp) end
		end
	end

	local function bindInstantDpad(btn, dx, dy)
		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dpadSliding = true
				lastSlideDir = nil
				triggerDpadDir(dx, dy, btn)
			end
		end)
	end

	bindInstantDpad(UI.dUp,    0, -1)
	bindInstantDpad(UI.dDown,  0,  1)
	bindInstantDpad(UI.dLeft, -1,  0)
	bindInstantDpad(UI.dRight, 1,  0)

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
					if delta.X > 0 then queueTurn(1, 0) flashDpadBtn(UI.dRight)
					else queueTurn(-1, 0) flashDpadBtn(UI.dLeft) end
				else
					if delta.Y > 0 then queueTurn(0, 1) flashDpadBtn(UI.dDown)
					else queueTurn(0, -1) flashDpadBtn(UI.dUp) end
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

-- ============================================================
-- VÒNG LẶP CHÍNH
-- ============================================================
local lastSecondCheck = 0
track(RunService.RenderStepped:Connect(function(dt)
	dt = math.min(dt, 0.05)

	local nowSec = os.time()
	if nowSec ~= lastSecondCheck then
		lastSecondCheck = nowSec
		refreshNotifDots()
		if UI.modalOverlay.Visible and activeModalTag == "Gift" and liveGiftBtn and liveGiftBtn.Parent then
			local remain = math.max(0, state.NextGiftUnix - nowSec)
			if remain <= 0 then
				if liveGiftBtn.Text ~= "🎉 NHẬN QUÀ NGAY!" then openGift() end
			else
				liveGiftBtn.Text = "⏳ CHỜ " .. remain .. " GIÂY"
			end
		end
	end

	if mainFrame.Visible and lobbyPage.Visible and previewHead then
		local t = os.clock() * 3.2
		local skin = getSkinById(state.EquippedSkin)
		local hx = 246
		local hy = 48 + math.sin(t) * 14
		previewHead.Position = UDim2.fromOffset(hx, hy)
		previewHead.Rotation = math.cos(t) * 14
		if skin.Rainbow then
			previewHead.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.4) % 1, 0.72, 0.85)
		end
		local gTick = skin.Glitch and math.floor(os.clock() * 10) or 0
		for i, seg in ipairs(previewSegs) do
			local sx = hx - (i * 16.5)
			local sy = 48 + math.sin(t - i * 0.42) * 14
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
				if it.Node:IsA("TextLabel") then
					it.Node.TextTransparency = blink and 0.6 or 0
				else
					it.Node.BackgroundTransparency = blink and 0.6 or 0
				end
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

	if state.Settings.BombsEnabled then
		Game.bombSpawnTimer -= dt
		if Game.bombSpawnTimer <= 0 then
			Game.bombSpawnTimer = math.random(9, 14)
			spawnItem("Bomb", nil, 11)
		end
	end

	local baseSpeeds = { 0.30, 0.23, 0.15 }
	local speed = baseSpeeds[state.Settings.SpeedMode] or 0.23
	speed = math.max(0.11, speed - math.min(0.035, Game.runScore * 0.00008))
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
-- KẾT NỐI NÚT BẤM, PHÍM TẮT & LƯU KHI ĐÓNG
-- ============================================================
UI.playBtn.MouseButton1Click:Connect(openGame)
UI.restartBtn.MouseButton1Click:Connect(startNewRun)
UI.goReplayBtn.MouseButton1Click:Connect(startNewRun)
UI.lobbyBtn.MouseButton1Click:Connect(openLobby)
UI.goLobbyBtn.MouseButton1Click:Connect(openLobby)

UI.pauseBtn.MouseButton1Click:Connect(function()
	if not Game.playing then return end
	Game.paused = not Game.paused
	UI.pauseBtn.Text = Game.paused and "▶" or "II"
end)

local function minimizeMenu()
	if Game.playing then Game.paused = true UI.pauseBtn.Text = "▶" end
	local tw = TweenService:Create(uiScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.05 })
	tw:Play()
	tw.Completed:Connect(function()
		if uiScale.Scale < 0.1 then
			mainFrame.Visible = false
			floatBtn.Visible = true
		end
	end)
end

local function restoreMenu()
	floatBtn.Visible = false
	mainFrame.Visible = true
	uiScale.Scale = 0.1
	TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = calcScale() }):Play()
end

UI.minBtn.MouseButton1Click:Connect(minimizeMenu)
floatBtn.MouseButton1Click:Connect(function()
	if not floatDragged then restoreMenu() end
end)

local function destroyMenu()
	if Game.playing and (Game.runCoins > 0 or Game.runGems > 0 or Game.runScore > 0) then
		state.Coins += Game.runCoins
		state.Gems  += Game.runGems
		if Game.runScore > state.HighScore then state.HighScore = Game.runScore end
	end
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
		queueTurn(0, -1) flashDpadBtn(UI.dUp)
	elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then
		queueTurn(0, 1) flashDpadBtn(UI.dDown)
	elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then
		queueTurn(-1, 0) flashDpadBtn(UI.dLeft)
	elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then
		queueTurn(1, 0) flashDpadBtn(UI.dRight)
	elseif input.KeyCode == Enum.KeyCode.Space and Game.playing then
		Game.paused = not Game.paused
		UI.pauseBtn.Text = Game.paused and "▶" or "II"
	end
end))

local cam = workspace.CurrentCamera
if cam then
	track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if mainFrame.Visible then uiScale.Scale = calcScale() end
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
