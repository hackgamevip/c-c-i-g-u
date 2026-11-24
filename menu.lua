-- ============================================================
-- THU THANH 2D (TOWER DEFENSE) v5.2 - KHO DO + NUT TRON 3D + HOI MAU THANH + 3 SAO MAP + TOGGLE + XAC NHAN THOAT
-- Full-Screen Mobile & PC | Tu dong luu ky luc | Phim tat PC: RightShift
-- ============================================================
local _ok, _err = pcall(function()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local GUI_NAME = "ThuThanh2D_Standalone"
local SAVE_FILE = "ThuThanh2D_Save_" .. tostring(player.UserId) .. ".json"

local THEME = {
	Outline    = Color3.fromRGB(10, 12, 20),
	TextMain   = Color3.fromRGB(214, 218, 224),
	TextMuted  = Color3.fromRGB(154, 164, 184),
	TextGold   = Color3.fromRGB(214, 180, 64),
	TextCyan   = Color3.fromRGB(98, 192, 212),
	TextGreen  = Color3.fromRGB(104, 198, 134),
	TextRed    = Color3.fromRGB(212, 98, 104),
	TextPurple = Color3.fromRGB(182, 132, 216),
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
-- CAU HINH BAN DO, THAP THU & QUAI VAT
-- ============================================================
local COLS, ROWS, CELL = 14, 9, 40
local BASE_W, BASE_H = 740, 464

local MAPS = {
	{
		Id = "meadow", Name = "Thảo Nguyên Xanh", Diff = "Dễ", Waves = 12, StartGold = 240, StartLives = 20,
		Grass1 = Color3.fromRGB(36, 98, 56), Grass2 = Color3.fromRGB(32, 88, 50),
		PathCol = Color3.fromRGB(164, 134, 88), PathBorder = Color3.fromRGB(118, 92, 58),
		Waypoints = {
			{1, 2}, {4, 2}, {4, 7}, {8, 7}, {8, 2}, {12, 2}, {12, 6}, {14, 6}
		},
	},
	{
		Id = "desert", Name = "Sa Mạc Lửa", Diff = "Trung Bình", Waves = 15, StartGold = 260, StartLives = 18,
		Grass1 = Color3.fromRGB(132, 98, 56), Grass2 = Color3.fromRGB(120, 88, 48),
		PathCol = Color3.fromRGB(88, 66, 48), PathBorder = Color3.fromRGB(62, 44, 34),
		Waypoints = {
			{1, 5}, {3, 5}, {3, 2}, {7, 2}, {7, 8}, {11, 8}, {11, 3}, {14, 3}
		},
	},
	{
		Id = "citadel", Name = "Thành Trì Hắc Ám", Diff = "Khó", Waves = 18, StartGold = 300, StartLives = 15,
		Grass1 = Color3.fromRGB(34, 32, 56), Grass2 = Color3.fromRGB(28, 26, 48),
		PathCol = Color3.fromRGB(64, 52, 88), PathBorder = Color3.fromRGB(44, 34, 66),
		Waypoints = {
			{1, 1}, {13, 1}, {13, 4}, {3, 4}, {3, 8}, {11, 8}, {11, 6}, {14, 6}
		},
	},
	{
		Id = "heroic_boss", Name = "Boss Anh Hùng", Diff = "Siêu Khó", Waves = 10, StartGold = 520, StartLives = 15,
		BossArena = true,
		Grass1 = Color3.fromRGB(58, 22, 36), Grass2 = Color3.fromRGB(48, 18, 30),
		PathCol = Color3.fromRGB(102, 44, 54), PathBorder = Color3.fromRGB(192, 138, 46),
		Waypoints = {
			{1, 2}, {12, 2}, {12, 5}, {2, 5}, {2, 8}, {13, 8}, {13, 6}, {14, 6}
		},
	},
	{
		Id = "endless", Name = "Vô Tận", Diff = "Vô Hạn", Waves = 999, StartGold = 320, StartLives = 20,
		Endless = true,
		Grass1 = Color3.fromRGB(26, 48, 66), Grass2 = Color3.fromRGB(22, 40, 56),
		PathCol = Color3.fromRGB(72, 82, 108), PathBorder = Color3.fromRGB(98, 186, 214),
		Waypoints = {
			{1, 3}, {5, 3}, {5, 7}, {9, 7}, {9, 2}, {13, 2}, {13, 6}, {14, 6}
		},
	},
}

local TOWERS = {
	{
		Id = "archer", Name = "Cung Thủ", Cost = 60, UpgradeCost = 55,
		Damage = 24, Range = 140, FireRate = 0.52, ProjSpeed = 440,
		Kind = "Arrow", BaseCol = Color3.fromRGB(64, 176, 92), TopCol = Color3.fromRGB(168, 118, 56),
		Accent = Color3.fromRGB(214, 186, 86), Desc = "Bắn nhanh, tầm rộng, giá rẻ"
	},
	{
		Id = "frost", Name = "Băng Giá", Cost = 95, UpgradeCost = 85,
		Damage = 16, Range = 132, FireRate = 0.80, ProjSpeed = 350, Slow = 0.45, SlowDur = 2.6,
		Kind = "Frost", BaseCol = Color3.fromRGB(54, 152, 212), TopCol = Color3.fromRGB(132, 206, 224),
		Accent = Color3.fromRGB(182, 222, 232), Desc = "Làm chậm quái 45% tầm xa"
	},
	{
		Id = "cannon", Name = "Đại Bác", Cost = 115, UpgradeCost = 95,
		Damage = 62, Range = 122, FireRate = 1.30, ProjSpeed = 290, Splash = 68,
		Kind = "Bomb", BaseCol = Color3.fromRGB(196, 82, 54), TopCol = Color3.fromRGB(58, 62, 76),
		Accent = Color3.fromRGB(218, 128, 48), Desc = "Nổ diện rộng dọn đàn quái"
	},
	{
		Id = "poison", Name = "Tháp Độc", Cost = 125, UpgradeCost = 105,
		Damage = 18, Range = 138, FireRate = 0.82, ProjSpeed = 360, PoisonDps = 22, PoisonDur = 4.0,
		Kind = "Poison", BaseCol = Color3.fromRGB(48, 168, 72), TopCol = Color3.fromRGB(32, 92, 46),
		Accent = Color3.fromRGB(118, 224, 72), Desc = "Trúng độc rút máu xuyên giáp"
	},
	{
		Id = "buff", Name = "Tháp Buff", Cost = 145, UpgradeCost = 130,
		Damage = 0, Range = 134, FireRate = 1.0, BuffDmg = 0.25, BuffRate = 0.18,
		Kind = "Buff", BaseCol = Color3.fromRGB(204, 156, 38), TopCol = Color3.fromRGB(226, 204, 102),
		Accent = Color3.fromRGB(232, 212, 84), Desc = "Tăng sát thương & tốc bắn quanh nó"
	},
	{
		Id = "tesla", Name = "Lôi Điện", Cost = 165, UpgradeCost = 140,
		Damage = 40, Range = 142, FireRate = 0.90, Chain = 4,
		Kind = "Lightning", BaseCol = Color3.fromRGB(142, 72, 212), TopCol = Color3.fromRGB(214, 192, 62),
		Accent = Color3.fromRGB(112, 204, 228), Desc = "Sét chuỗi giật lan 4 mục tiêu"
	},
	{
		Id = "laser", Name = "Laze Thần", Cost = 250, UpgradeCost = 215,
		Damage = 108, Range = 172, FireRate = 1.00,
		Kind = "Laser", BaseCol = Color3.fromRGB(204, 58, 118), TopCol = Color3.fromRGB(224, 184, 54),
		Accent = Color3.fromRGB(228, 92, 168), Desc = "Tia laze diệt Boss cực mạnh"
	},
}

-- 2 LOAI BAY DAT TREN DUONG DI
local TRAPS = {
	spike = { Id = "spike", Name = "Bẫy Gai", Cost = 45, Damage = 42, Uses = 6, Slow = 0.35, Color = Color3.fromRGB(168, 178, 196) },
	mine  = { Id = "mine",  Name = "Mìn Nổ",  Cost = 75, Damage = 185, Uses = 1, Splash = 68, Color = Color3.fromRGB(224, 68, 56) },
}

-- CUA HANG HIEU UNG THAP & VU NO (MUA BANG SAO)
local TD_SKINS = {
	{ Id = "default", Name = "Mặc Định",        Cost = 0,  Desc = "Hiệu ứng nguyên bản",               Aura = nil },
	{ Id = "golden",  Name = "Hoàng Kim Rực Rỡ", Cost = 15, Desc = "Hào quang & sóng nổ vàng kim rực rỡ", Aura = Color3.fromRGB(232, 196, 56) },
	{ Id = "cyber",   Name = "Cyber Neon",       Cost = 25, Desc = "Hiệu ứng năng lượng xanh lam Neon",   Aura = Color3.fromRGB(72, 218, 232) },
	{ Id = "void",    Name = "Hư Không Huyền Bí",Cost = 35, Desc = "Hào quang & sóng nổ tím Hư Không",    Aura = Color3.fromRGB(192, 82, 236) },
}

local function getTdSkin(id)
	for _, s in ipairs(TD_SKINS) do
		if s.Id == id then return s end
	end
	return TD_SKINS[1]
end

local DIFFICULTIES = {
	{ Id = "easy",   Name = "Dễ",          Lives = 50, HpMult = 0.75, SpdMult = 0.95, StarMult = 1.0, Color = Color3.fromRGB(76, 198, 102) },
	{ Id = "normal", Name = "Bình Thường", Lives = 30, HpMult = 1.00, SpdMult = 1.00, StarMult = 1.0, Color = Color3.fromRGB(72, 168, 224) },
	{ Id = "hard",   Name = "Khó",         Lives = 10, HpMult = 1.50, SpdMult = 1.04, StarMult = 1.5, Color = Color3.fromRGB(224, 168, 48) },
	{ Id = "insane", Name = "Siêu Khó",    Lives = 3,  HpMult = 2.25, SpdMult = 1.08, StarMult = 2.0, Color = Color3.fromRGB(224, 96, 52) },
	{ Id = "hell",   Name = "Địa Ngục",    Lives = 1,  HpMult = 3.50, SpdMult = 1.12, StarMult = 3.0, Color = Color3.fromRGB(214, 46, 118) },
}

local function getDiffDef(id)
	for _, d in ipairs(DIFFICULTIES) do
		if d.Id == id then return d end
	end
	return DIFFICULTIES[2]
end

local ENEMIES = {
	slime            = { Name = "Slime Xanh",        HP = 65,   Speed = 54, Reward = 12,  Size = 22, Color = Color3.fromRGB(72, 198, 96),   Eye = Color3.fromRGB(20, 26, 22),   Damage = 1 },
	goblin           = { Name = "Yêu Tinh Nhanh",    HP = 48,   Speed = 88, Reward = 14,  Size = 20, Color = Color3.fromRGB(214, 156, 48),  Eye = Color3.fromRGB(196, 46, 46),  Damage = 1 },
	spider           = { Name = "Nhện Bóng Đêm",     HP = 72,   Speed = 82, Reward = 16,  Size = 22, Color = Color3.fromRGB(46, 38, 56),    Eye = Color3.fromRGB(228, 48, 54),  Damage = 1 },
	bat              = { Name = "Dơi Ma Tím",        HP = 58,   Speed = 94, Reward = 16,  Size = 21, Color = Color3.fromRGB(118, 54, 178),  Eye = Color3.fromRGB(232, 92, 134), Damage = 1 },
	skeleton         = { Name = "Xương Khô",         HP = 105,  Speed = 58, Reward = 18,  Size = 23, Color = Color3.fromRGB(208, 212, 220), Eye = Color3.fromRGB(22, 24, 34),   Damage = 1 },
	knight           = { Name = "Hiệp Sĩ Giáp",      HP = 185,  Speed = 40, Reward = 24,  Size = 26, Color = Color3.fromRGB(122, 136, 162), Eye = Color3.fromRGB(76, 188, 216), Damage = 2 },
	scorpion         = { Name = "Bọ Cạp Sa Mạc",     HP = 210,  Speed = 52, Reward = 26,  Size = 26, Color = Color3.fromRGB(186, 128, 54),  Eye = Color3.fromRGB(64, 212, 86),  Damage = 2 },
	wraith           = { Name = "Ma Bóng Đêm",       HP = 120,  Speed = 72, Reward = 22,  Size = 24, Color = Color3.fromRGB(148, 86, 212),  Eye = Color3.fromRGB(220, 212, 228),Alpha = 0.25, Damage = 2 },
	orc              = { Name = "Chằn Tinh Orc",     HP = 310,  Speed = 38, Reward = 34,  Size = 28, Color = Color3.fromRGB(74, 132, 54),   Eye = Color3.fromRGB(224, 68, 48),  Damage = 2 },
	golem            = { Name = "Khổng Lồ Đá",       HP = 420,  Speed = 30, Reward = 45,  Size = 30, Color = Color3.fromRGB(156, 88, 62),   Eye = Color3.fromRGB(224, 182, 52), Damage = 3 },
	boss             = { Name = "Rồng Hắc Ám",       HP = 1250, Speed = 34, Reward = 150, Size = 36, Color = Color3.fromRGB(198, 42, 66),   Eye = Color3.fromRGB(232, 196, 56), Boss = true, Damage = 5 },
	cerberus         = { Name = "Chó Địa Ngục 3 Đầu",HP = 1900, Speed = 38, Reward = 210, Size = 38, Color = Color3.fromRGB(178, 36, 42),   Eye = Color3.fromRGB(234, 186, 48), Boss = true, Damage = 5 },
	lich_boss        = { Name = "Pháp Sư Xương",     HP = 2250, Speed = 32, Reward = 240, Size = 38, Color = Color3.fromRGB(54, 34, 78),    Eye = Color3.fromRGB(118, 232, 134),Boss = true, HeroBoss = true, Damage = 6 },
	titan_boss       = { Name = "Chúa Quỷ Dung Nham",HP = 2700, Speed = 30, Reward = 280, Size = 39, Color = Color3.fromRGB(142, 34, 28),   Eye = Color3.fromRGB(236, 152, 44), Boss = true, Damage = 6 },
	dark_knight_boss = { Name = "Hắc Kỵ Sĩ Đen",     HP = 3400, Speed = 34, Reward = 340, Size = 40, Color = Color3.fromRGB(36, 32, 46),    Eye = Color3.fromRGB(224, 48, 72),  Boss = true, Damage = 7 },
	phoenix_boss     = { Name = "Phượng Hoàng Lửa",  HP = 4200, Speed = 36, Reward = 420, Size = 41, Color = Color3.fromRGB(218, 86, 36),   Eye = Color3.fromRGB(238, 214, 72), Boss = true, HeroBoss = true, Damage = 8 },
	hero_boss        = { Name = "Đế Vương Hư Không", HP = 5400, Speed = 28, Reward = 520, Size = 42, Color = Color3.fromRGB(48, 22, 88),    Eye = Color3.fromRGB(236, 196, 64), Boss = true, HeroBoss = true, Damage = 10 },
}

-- ============================================================
-- LUU & TAI KY LUC TU DONG
-- ============================================================
local canWriteFile = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local saveState = {
	BestWave = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 },
	Wins = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 },
	TotalKills = 0,
	Stars = 15,
	Upgrades = { dmg = 0, gold = 0, lives = 0, skill = 0 },
	SfxOn = true,
	SfxVol = 0.7,
	LowFx = false,
	MapStars = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 },
	Bag = { potion = 2, goldbag = 1, scroll = 1 },
	SelectedMap = 1,
	Difficulty = "normal",
	OwnedSkins = { default = true },
	EquippedSkin = "default",
	Quests = nil,
}

local function createDefaultQuests()
	return {
		{ Id = "kills",  Title = "Tiêu diệt 50 quái vật",    Goal = 50, Progress = 0, Reward = 8,  Claimed = false },
		{ Id = "boss",   Title = "Hạ gục 3 Boss bất kỳ",     Goal = 3,  Progress = 0, Reward = 12, Claimed = false },
		{ Id = "build",  Title = "Xây dựng 10 tòa tháp",     Goal = 10, Progress = 0, Reward = 6,  Claimed = false },
		{ Id = "tier3",  Title = "Nâng 3 tháp lên Cấp 3",    Goal = 3,  Progress = 0, Reward = 10, Claimed = false },
		{ Id = "win",    Title = "Chiến thắng 1 bản đồ",     Goal = 1,  Progress = 0, Reward = 15, Claimed = false },
	}
end
saveState.Quests = createDefaultQuests()

local BAG_ITEMS = {
	{ Id = "potion",  Name = "Bình Máu Thành", Cost = 5, Desc = "Hồi ngay +5 HP Thành Trì trong trận",   Color = Color3.fromRGB(224, 62, 74) },
	{ Id = "goldbag", Name = "Túi Vàng Khẩn",  Cost = 6, Desc = "Nhận ngay +250 Vàng để xây/nâng tháp", Color = Color3.fromRGB(224, 182, 44) },
	{ Id = "scroll",  Name = "Cuộn Hồi Chiêu", Cost = 8, Desc = "Xóa hồi chiêu toàn bộ kỹ năng ngay",   Color = Color3.fromRGB(168, 86, 224) },
}

local PERM_UPGRADES = {
	{ Key = "dmg",   Name = "Sát Thương Tháp",   Desc = "+8% sát thương mọi tháp mỗi cấp",   Max = 5, BaseCost = 10 },
	{ Key = "gold",  Name = "Kho Bạc Khởi Đầu",  Desc = "+40 Vàng đầu trận mỗi cấp",         Max = 5, BaseCost = 10 },
	{ Key = "lives", Name = "Gia Cố Thành Trì",  Desc = "+3 Máu Thành mỗi cấp",              Max = 5, BaseCost = 10 },
	{ Key = "skill", Name = "Thiên Thạch Nhanh", Desc = "-2 giây hồi chiêu mỗi cấp",         Max = 5, BaseCost = 12 },
}

local function getCacheRoot()
	if typeof(getgenv) == "function" then
		local ok, env = pcall(getgenv)
		if ok and type(env) == "table" then return env end
	end
	return _G
end

local function saveData()
	local okEnc, encoded = pcall(function() return HttpService:JSONEncode(saveState) end)
	if not okEnc then return end
	getCacheRoot()["ThuThanh2D_JSON_" .. tostring(player.UserId)] = encoded
	if canWriteFile then pcall(writefile, SAVE_FILE, encoded) end
end

local function loadData()
	local rawJson = nil
	if canWriteFile then
		local okRead, content = pcall(readfile, SAVE_FILE)
		if okRead and type(content) == "string" and #content > 2 then rawJson = content end
	end
	if not rawJson then
		local mem = getCacheRoot()["ThuThanh2D_JSON_" .. tostring(player.UserId)]
		if type(mem) == "string" and #mem > 2 then rawJson = mem end
	end
	if rawJson then
		local okDec, tbl = pcall(function() return HttpService:JSONDecode(rawJson) end)
		if okDec and type(tbl) == "table" then
			if type(tbl.BestWave) == "table" then
				for k, v in pairs(tbl.BestWave) do
					if type(v) == "number" then saveState.BestWave[k] = v end
				end
			end
			if type(tbl.Wins) == "table" then
				for k, v in pairs(tbl.Wins) do
					if type(v) == "number" then saveState.Wins[k] = v end
				end
			end
			if type(tbl.TotalKills) == "number" then saveState.TotalKills = tbl.TotalKills end
			if type(tbl.Stars) == "number" then saveState.Stars = math.max(0, math.floor(tbl.Stars)) end
			if type(tbl.SfxOn) == "boolean" then saveState.SfxOn = tbl.SfxOn end
			if type(tbl.LowFx) == "boolean" then saveState.LowFx = tbl.LowFx end
			if type(tbl.SfxVol) == "number" then saveState.SfxVol = math.clamp(tbl.SfxVol, 0.2, 1.0) end
			if type(tbl.MapStars) == "table" then
				for k, v in pairs(tbl.MapStars) do if type(v) == "number" then saveState.MapStars[k] = math.clamp(math.floor(v), 0, 3) end end
			end
			if type(tbl.Bag) == "table" then
				for k, v in pairs(tbl.Bag) do if type(v) == "number" and saveState.Bag[k] ~= nil then saveState.Bag[k] = math.max(0, math.floor(v)) end end
			end
			if type(tbl.Upgrades) == "table" then
				for k, v in pairs(tbl.Upgrades) do
					if type(v) == "number" and saveState.Upgrades[k] ~= nil then saveState.Upgrades[k] = math.clamp(math.floor(v), 0, 5) end
				end
			end
			if type(tbl.SelectedMap) == "number" then saveState.SelectedMap = math.clamp(tbl.SelectedMap, 1, #MAPS) end
			if type(tbl.Difficulty) == "string" then saveState.Difficulty = tbl.Difficulty end
			if type(tbl.OwnedSkins) == "table" then
				saveState.OwnedSkins = { default = true }
				for k, v in pairs(tbl.OwnedSkins) do if v == true then saveState.OwnedSkins[tostring(k)] = true end end
			end
			if type(tbl.EquippedSkin) == "string" and saveState.OwnedSkins[tbl.EquippedSkin] then saveState.EquippedSkin = tbl.EquippedSkin end
			if type(tbl.Quests) == "table" then
				for _, q in ipairs(saveState.Quests) do
					for _, sq in ipairs(tbl.Quests) do
						if type(sq) == "table" and sq.Id == q.Id then
							if type(sq.Progress) == "number" then q.Progress = sq.Progress end
							if type(sq.Claimed) == "boolean" then q.Claimed = sq.Claimed end
						end
					end
				end
			end
		end
	end
end
loadData()

-- ============================================================
-- TIEN ICH GIAO DIEN 2D CARTOON ARCADE
-- ============================================================
local UI = {}
local SEC = {}
local GFX = {}

local function addCorner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = obj
	return c
end

local function addStroke(obj, col, thick)
	local s = Instance.new("UIStroke")
	s.Color = col or THEME.Outline
	s.Thickness = thick or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

local function addTextOutline(lbl, thick, col)
	local s = Instance.new("UIStroke")
	s.Color = col or THEME.Outline
	s.Thickness = thick or 1.6
	s.Parent = lbl
	return s
end

local function addGradient(obj, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rot or 90
	g.Parent = obj
	return g
end

local function makeArcadeBtn(parent, text, size, pos, c1, c2, radius, opts)
	opts = opts or {}
	local depth = opts.Depth or 4
	local z = opts.ZIndex or 4

	local btn = Instance.new("TextButton")
	btn.Size = size
	if pos then btn.Position = pos end
	btn.BackgroundColor3 = THEME.Outline
	btn.BackgroundTransparency = 0.22
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = z
	btn.Parent = parent
	addCorner(btn, radius or 10)
	local outerStroke = addStroke(btn, THEME.Outline, opts.Stroke or 2.2)

	local face = Instance.new("Frame")
	face.Size = UDim2.new(1, 0, 1, -depth)
	face.Position = UDim2.fromOffset(0, 0)
	face.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	face.BorderSizePixel = 0
	face.ZIndex = z + 1
	face.Parent = btn
	addCorner(face, radius or 10)
	addGradient(face, c1, c2, 90)

	local shine = Instance.new("Frame")
	shine.Size = UDim2.new(1, -10, 0.36, 0)
	shine.Position = UDim2.fromOffset(5, 3)
	shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shine.BackgroundTransparency = 0.80
	shine.BorderSizePixel = 0
	shine.ZIndex = z + 2
	shine.Parent = face
	addCorner(shine, math.max(4, (radius or 10) - 3))

	local lbl = Instance.new("TextLabel")
	lbl.Size = opts.LabelSize or UDim2.fromScale(1, 1)
	lbl.Position = opts.LabelPos or UDim2.fromOffset(0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = opts.TextColor or THEME.TextMain
	lbl.Font = THEME.FontHead
	lbl.TextSize = opts.TextSize or 13
	lbl.ZIndex = z + 3
	lbl.Parent = face
	addTextOutline(lbl, opts.TextStroke or 1.6, THEME.Outline)

	btn.MouseButton1Down:Connect(function()
		face.Position = UDim2.fromOffset(0, math.max(1, depth - 1))
	end)
	local function resetPress()
		face.Position = UDim2.fromOffset(0, 0)
	end
	btn.MouseButton1Up:Connect(resetPress)
	btn.MouseLeave:Connect(resetPress)

	return btn, lbl, face, outerStroke
end

local function makeDraggable(handle, target, onDragFlag)
	local dragging, dragStart, startPos, moved = false, nil, nil, false
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = inp.Position
			startPos = target.Position
			if onDragFlag then onDragFlag(false) end
		end
	end)
	track(UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local delta = inp.Position - dragStart
			if delta.Magnitude > 6 then
				moved = true
				if onDragFlag then onDragFlag(true) end
			end
			if moved then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end))
	track(UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

-- ============================================================
-- DO HOA VECTOR 2D CHO THAP, QUAI & HIEU UNG
-- ============================================================
function GFX.buildTowerSprite(parent, towerDef, size, zBase)
	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(size, size)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.BackgroundTransparency = 1
	root.ZIndex = zBase
	root.Parent = parent

	-- Bong do duoi chan thap
	local shad = Instance.new("Frame")
	shad.Size = UDim2.fromScale(0.92, 0.88)
	shad.Position = UDim2.fromScale(0.5, 0.56)
	shad.AnchorPoint = Vector2.new(0.5, 0.5)
	shad.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
	shad.BackgroundTransparency = 0.5
	shad.BorderSizePixel = 0
	shad.ZIndex = zBase
	shad.Parent = root
	addCorner(shad, 10)

	-- De thap theo tung chung loai
	local base = Instance.new("Frame")
	base.Size = UDim2.fromScale(0.84, 0.84)
	base.Position = UDim2.fromScale(0.5, 0.5)
	base.AnchorPoint = Vector2.new(0.5, 0.5)
	base.BackgroundColor3 = towerDef.BaseCol
	base.BorderSizePixel = 0
	base.ZIndex = zBase + 1
	base.Parent = root
	addCorner(base, (towerDef.Id == "tesla" or towerDef.Id == "frost") and 12 or 7)
	addStroke(base, THEME.Outline, 2.0)

	-- Chi tiet trang tri rieng cho tung loai thap
	if towerDef.Id == "archer" then
		-- Mai rom vang + go
		addGradient(base, Color3.fromRGB(168, 122, 62), Color3.fromRGB(108, 74, 38), 90)
		local roof = Instance.new("Frame")
		roof.Size = UDim2.fromScale(0.76, 0.76)
		roof.Position = UDim2.fromScale(0.5, 0.5)
		roof.AnchorPoint = Vector2.new(0.5, 0.5)
		roof.BackgroundColor3 = Color3.fromRGB(214, 178, 64)
		roof.BorderSizePixel = 0
		roof.ZIndex = zBase + 2
		roof.Parent = base
		addCorner(roof, 8)
		addStroke(roof, THEME.Outline, 1.5)
	elseif towerDef.Id == "cannon" then
		-- Be thep xam + 4 goc cam noi bat
		addGradient(base, Color3.fromRGB(82, 88, 108), Color3.fromRGB(46, 50, 66), 90)
		for _, pos in ipairs({{0.12,0.12},{0.88,0.12},{0.12,0.88},{0.88,0.88}}) do
			local bolt = Instance.new("Frame")
			bolt.Size = UDim2.fromScale(0.22, 0.22)
			bolt.Position = UDim2.fromScale(pos[1], pos[2])
			bolt.AnchorPoint = Vector2.new(0.5, 0.5)
			bolt.BackgroundColor3 = Color3.fromRGB(224, 112, 38)
			bolt.BorderSizePixel = 0
			bolt.ZIndex = zBase + 2
			bolt.Parent = base
			addCorner(bolt, 3)
			addStroke(bolt, THEME.Outline, 1.1)
		end
	elseif towerDef.Id == "frost" then
		-- 3 khoi tinh the bang xanh lam xep tang
		addGradient(base, Color3.fromRGB(92, 206, 228), Color3.fromRGB(34, 126, 198), 90)
		for _, ang in ipairs({-32, 32}) do
			local shard = Instance.new("Frame")
			shard.Size = UDim2.fromScale(0.32, 0.62)
			shard.Position = UDim2.fromScale(ang < 0 and 0.24 or 0.76, 0.42)
			shard.AnchorPoint = Vector2.new(0.5, 0.5)
			shard.Rotation = ang
			shard.BackgroundColor3 = Color3.fromRGB(168, 226, 236)
			shard.BorderSizePixel = 0
			shard.ZIndex = zBase + 2
			shard.Parent = base
			addCorner(shard, 4)
			addStroke(shard, THEME.Outline, 1.3)
		end
	elseif towerDef.Id == "tesla" then
		-- De tim cong nghe + 2 tru cuon day dong 2 ben
		addGradient(base, Color3.fromRGB(154, 72, 218), Color3.fromRGB(84, 34, 154), 90)
		for _, ox in ipairs({0.18, 0.82}) do
			local coil = Instance.new("Frame")
			coil.Size = UDim2.fromScale(0.24, 0.54)
			coil.Position = UDim2.fromScale(ox, 0.5)
			coil.AnchorPoint = Vector2.new(0.5, 0.5)
			coil.BackgroundColor3 = Color3.fromRGB(208, 128, 52)
			coil.BorderSizePixel = 0
			coil.ZIndex = zBase + 2
			coil.Parent = base
			addCorner(coil, 4)
			addStroke(coil, THEME.Outline, 1.3)
		end
	elseif towerDef.Id == "poison" then
		addGradient(base, Color3.fromRGB(64, 196, 86), Color3.fromRGB(28, 108, 46), 90)
		for _, pos in ipairs({{0.26,0.28},{0.74,0.28},{0.5,0.76}}) do
			local bub = Instance.new("Frame")
			bub.Size = UDim2.fromScale(0.24, 0.24)
			bub.Position = UDim2.fromScale(pos[1], pos[2])
			bub.AnchorPoint = Vector2.new(0.5, 0.5)
			bub.BackgroundColor3 = Color3.fromRGB(134, 232, 76)
			bub.BorderSizePixel = 0
			bub.ZIndex = zBase + 2
			bub.Parent = base
			addCorner(bub, 99)
			addStroke(bub, THEME.Outline, 1.1)
		end
	elseif towerDef.Id == "buff" then
		addGradient(base, Color3.fromRGB(224, 182, 48), Color3.fromRGB(154, 102, 22), 90)
		local halo = Instance.new("Frame")
		halo.Size = UDim2.fromScale(0.92, 0.92)
		halo.Position = UDim2.fromScale(0.5, 0.5)
		halo.AnchorPoint = Vector2.new(0.5, 0.5)
		halo.BackgroundTransparency = 1
		halo.ZIndex = zBase + 2
		halo.Parent = base
		addCorner(halo, 99)
		addStroke(halo, Color3.fromRGB(236, 218, 108), 1.8)
	elseif towerDef.Id == "laser" then
		-- Thap thanh hong tim vien vang + doi canh thien than 2 ben
		addGradient(base, Color3.fromRGB(214, 74, 152), Color3.fromRGB(136, 36, 108), 90)
		for _, side in ipairs({-1, 1}) do
			local wing = Instance.new("Frame")
			wing.Size = UDim2.fromScale(0.34, 0.66)
			wing.Position = UDim2.fromScale(side < 0 and 0.04 or 0.96, 0.42)
			wing.AnchorPoint = Vector2.new(0.5, 0.5)
			wing.Rotation = side * 22
			wing.BackgroundColor3 = Color3.fromRGB(224, 118, 186)
			wing.BorderSizePixel = 0
			wing.ZIndex = zBase + 2
			wing.Parent = base
			addCorner(wing, 6)
			addStroke(wing, Color3.fromRGB(224, 184, 54), 1.5)
		end
	end

	-- Khop xoay nong sung (Turret pivot)
	local turret = Instance.new("Frame")
	turret.Size = UDim2.fromScale(0.56, 0.56)
	turret.Position = UDim2.fromScale(0.5, 0.5)
	turret.AnchorPoint = Vector2.new(0.5, 0.5)
	turret.BackgroundColor3 = towerDef.TopCol
	turret.BorderSizePixel = 0
	turret.ZIndex = zBase + 4
	turret.Parent = root
	addCorner(turret, 99)
	addStroke(turret, THEME.Outline, 1.8)

	-- Nong sung / vu khi chi ve ben phai (0 do)
	local barrel = Instance.new("Frame")
	if towerDef.Id == "cannon" then
		barrel.Size = UDim2.fromScale(0.92, 0.54)
		barrel.BackgroundColor3 = Color3.fromRGB(48, 52, 66)
	elseif towerDef.Id == "archer" then
		barrel.Size = UDim2.fromScale(0.84, 0.24)
		barrel.BackgroundColor3 = Color3.fromRGB(214, 182, 68)
	elseif towerDef.Id == "laser" then
		barrel.Size = UDim2.fromScale(0.95, 0.30)
		barrel.BackgroundColor3 = Color3.fromRGB(228, 102, 188)
	else
		barrel.Size = UDim2.fromScale(0.78, 0.32)
		barrel.BackgroundColor3 = towerDef.Accent
	end
	barrel.Position = UDim2.fromScale(0.55, 0.5)
	barrel.AnchorPoint = Vector2.new(0.1, 0.5)
	barrel.BorderSizePixel = 0
	barrel.ZIndex = zBase + 3
	barrel.Parent = turret
	addCorner(barrel, 4)
	addStroke(barrel, THEME.Outline, 1.5)

	-- Vong canh cung cho thap Cung Thu hoac vien cam cho Dai Bac
	if towerDef.Id == "archer" then
		local bow = Instance.new("Frame")
		bow.Size = UDim2.fromScale(0.28, 1.15)
		bow.Position = UDim2.fromScale(0.68, 0.5)
		bow.AnchorPoint = Vector2.new(0.5, 0.5)
		bow.BackgroundColor3 = Color3.fromRGB(154, 96, 44)
		bow.BorderSizePixel = 0
		bow.ZIndex = zBase + 4
		bow.Parent = turret
		addCorner(bow, 6)
		addStroke(bow, THEME.Outline, 1.2)
	elseif towerDef.Id == "cannon" then
		local band = Instance.new("Frame")
		band.Size = UDim2.fromScale(0.24, 1.04)
		band.Position = UDim2.fromScale(0.55, 0.5)
		band.AnchorPoint = Vector2.new(0.5, 0.5)
		band.BackgroundColor3 = Color3.fromRGB(224, 118, 38)
		band.BorderSizePixel = 0
		band.ZIndex = zBase + 4
		band.Parent = barrel
		addCorner(band, 2)
	end

	-- Loi phat sang o dinh thap
	local core = Instance.new("Frame")
	core.Size = UDim2.fromScale(0.46, 0.46)
	core.Position = UDim2.fromScale(0.5, 0.5)
	core.AnchorPoint = Vector2.new(0.5, 0.5)
	core.BackgroundColor3 = towerDef.Accent
	core.BorderSizePixel = 0
	core.ZIndex = zBase + 5
	core.Parent = turret
	addCorner(core, 99)
	addStroke(core, THEME.Outline, 1.2)

	return root, turret, barrel, base
end

function GFX.buildEnemySprite(parent, def, kind, zBase)
	local sz = def.Size
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(sz, sz)
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.BackgroundTransparency = 1
	holder.ZIndex = zBase
	holder.Parent = parent

	-- Bong duoi chan
	local shadow = Instance.new("Frame")
	shadow.Size = UDim2.fromOffset(sz * 0.88, sz * 0.34)
	shadow.Position = UDim2.new(0.5, 0, 1, -1)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
	shadow.BackgroundTransparency = 0.45
	shadow.BorderSizePixel = 0
	shadow.ZIndex = zBase
	shadow.Parent = holder
	addCorner(shadow, 99)

	-- Than quai chinh
	local body = Instance.new("Frame")
	body.Size = UDim2.fromScale(1, 1)
	body.Position = UDim2.fromScale(0.5, 0.5)
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.BackgroundColor3 = def.Color
	body.BackgroundTransparency = def.Alpha or 0
	body.BorderSizePixel = 0
	body.ZIndex = zBase + 2
	body.Parent = holder
	addCorner(body, (kind == "golem" or kind == "knight") and 6 or (def.Boss and 9 or 99))
	local bodyStroke = addStroke(body, def.Boss and THEME.TextGold or THEME.Outline, def.Boss and 2.4 or 1.8)

	local wingL, wingR = nil, nil

	-- Chi tiet dac trung cho 6 loai quai (Monster Character Breakdown)
	if kind == "slime" then
		-- Dom sang thach bong + mieng cuoi
		local gloss = Instance.new("Frame")
		gloss.Size = UDim2.fromScale(0.32, 0.22)
		gloss.Position = UDim2.fromScale(0.28, 0.24)
		gloss.AnchorPoint = Vector2.new(0.5, 0.5)
		gloss.BackgroundColor3 = Color3.fromRGB(196, 232, 186)
		gloss.BackgroundTransparency = 0.3
		gloss.BorderSizePixel = 0
		gloss.ZIndex = zBase + 3
		gloss.Parent = body
		addCorner(gloss, 99)
	elseif kind == "goblin" then
		-- Tai nhon 2 ben + dao gam bac ben phai
		for _, side in ipairs({-1, 1}) do
			local ear = Instance.new("Frame")
			ear.Size = UDim2.fromScale(0.36, 0.22)
			ear.Position = UDim2.fromScale(side < 0 and -0.06 or 1.06, 0.36)
			ear.AnchorPoint = Vector2.new(0.5, 0.5)
			ear.Rotation = side * -24
			ear.BackgroundColor3 = def.Color
			ear.BorderSizePixel = 0
			ear.ZIndex = zBase + 1
			ear.Parent = body
			addCorner(ear, 3)
			addStroke(ear, THEME.Outline, 1.3)
		end
		local dagger = Instance.new("Frame")
		dagger.Size = UDim2.fromScale(0.46, 0.16)
		dagger.Position = UDim2.fromScale(1.12, 0.68)
		dagger.AnchorPoint = Vector2.new(0.5, 0.5)
		dagger.Rotation = -28
		dagger.BackgroundColor3 = Color3.fromRGB(204, 212, 224)
		dagger.BorderSizePixel = 0
		dagger.ZIndex = zBase + 3
		dagger.Parent = body
		addCorner(dagger, 2)
		addStroke(dagger, THEME.Outline, 1.2)
	elseif kind == "knight" then
		-- Khe mu tru chu T + khien ben trai + kiem ben phai
		local visor = Instance.new("Frame")
		visor.Size = UDim2.fromScale(0.62, 0.18)
		visor.Position = UDim2.fromScale(0.5, 0.44)
		visor.AnchorPoint = Vector2.new(0.5, 0.5)
		visor.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
		visor.BorderSizePixel = 0
		visor.ZIndex = zBase + 3
		visor.Parent = body
		addCorner(visor, 2)

		local shield = Instance.new("Frame")
		shield.Size = UDim2.fromScale(0.38, 0.64)
		shield.Position = UDim2.fromScale(-0.08, 0.56)
		shield.AnchorPoint = Vector2.new(0.5, 0.5)
		shield.BackgroundColor3 = Color3.fromRGB(96, 134, 186)
		shield.BorderSizePixel = 0
		shield.ZIndex = zBase + 3
		shield.Parent = body
		addCorner(shield, 4)
		addStroke(shield, THEME.Outline, 1.4)

		local sword = Instance.new("Frame")
		sword.Size = UDim2.fromScale(0.18, 0.72)
		sword.Position = UDim2.fromScale(1.08, 0.44)
		sword.AnchorPoint = Vector2.new(0.5, 0.5)
		sword.Rotation = 16
		sword.BackgroundColor3 = Color3.fromRGB(206, 214, 224)
		sword.BorderSizePixel = 0
		sword.ZIndex = zBase + 3
		sword.Parent = body
		addCorner(sword, 2)
		addStroke(sword, THEME.Outline, 1.2)
	elseif kind == "wraith" then
		-- Mu trum bong ma + duoi ma tim lo lung
		local tail = Instance.new("Frame")
		tail.Size = UDim2.fromScale(0.66, 0.42)
		tail.Position = UDim2.fromScale(0.5, 0.94)
		tail.AnchorPoint = Vector2.new(0.5, 0.5)
		tail.BackgroundColor3 = Color3.fromRGB(164, 108, 224)
		tail.BackgroundTransparency = 0.35
		tail.BorderSizePixel = 0
		tail.ZIndex = zBase + 1
		tail.Parent = body
		addCorner(tail, 99)
	elseif kind == "golem" then
		-- 2 canh tay da to 2 ben + khe nut dung nham cam ruc
		for _, side in ipairs({-1, 1}) do
			local arm = Instance.new("Frame")
			arm.Size = UDim2.fromScale(0.34, 0.56)
			arm.Position = UDim2.fromScale(side < 0 and -0.14 or 1.14, 0.55)
			arm.AnchorPoint = Vector2.new(0.5, 0.5)
			arm.BackgroundColor3 = Color3.fromRGB(122, 68, 48)
			arm.BorderSizePixel = 0
			arm.ZIndex = zBase + 1
			arm.Parent = body
			addCorner(arm, 4)
			addStroke(arm, THEME.Outline, 1.5)
		end
		local crack = Instance.new("Frame")
		crack.Size = UDim2.fromScale(0.54, 0.16)
		crack.Position = UDim2.fromScale(0.5, 0.72)
		crack.AnchorPoint = Vector2.new(0.5, 0.5)
		crack.BackgroundColor3 = Color3.fromRGB(228, 126, 38)
		crack.BorderSizePixel = 0
		crack.ZIndex = zBase + 3
		crack.Parent = body
		addCorner(crack, 3)
	elseif kind == "spider" or kind == "scorpion" then
		-- 4 chan nhen / cang bo cap 2 ben
		for _, side in ipairs({-1, 1}) do
			for _, oy in ipairs({0.32, 0.68}) do
				local leg = Instance.new("Frame")
				leg.Size = UDim2.fromScale(0.38, 0.14)
				leg.Position = UDim2.fromScale(side < 0 and -0.14 or 1.14, oy)
				leg.AnchorPoint = Vector2.new(0.5, 0.5)
				leg.Rotation = side * (oy < 0.5 and -22 or 22)
				leg.BackgroundColor3 = def.Color
				leg.BorderSizePixel = 0
				leg.ZIndex = zBase + 1
				leg.Parent = body
				addCorner(leg, 2)
				addStroke(leg, THEME.Outline, 1.1)
			end
		end
	elseif kind == "bat" then
		wingL = Instance.new("Frame")
		wingL.Size = UDim2.fromScale(0.54, 0.34)
		wingL.Position = UDim2.fromScale(-0.22, 0.45)
		wingL.AnchorPoint = Vector2.new(0.5, 0.5)
		wingL.Rotation = -18
		wingL.BackgroundColor3 = Color3.fromRGB(92, 42, 146)
		wingL.BorderSizePixel = 0
		wingL.ZIndex = zBase + 1
		wingL.Parent = body
		addCorner(wingL, 5)
		addStroke(wingL, THEME.Outline, 1.3)
		wingR = Instance.new("Frame")
		wingR.Size = UDim2.fromScale(0.54, 0.34)
		wingR.Position = UDim2.fromScale(1.22, 0.45)
		wingR.AnchorPoint = Vector2.new(0.5, 0.5)
		wingR.Rotation = 18
		wingR.BackgroundColor3 = Color3.fromRGB(92, 42, 146)
		wingR.BorderSizePixel = 0
		wingR.ZIndex = zBase + 1
		wingR.Parent = body
		addCorner(wingR, 5)
		addStroke(wingR, THEME.Outline, 1.3)
	elseif kind == "skeleton" or kind == "orc" then
		local wep = Instance.new("Frame")
		wep.Size = UDim2.fromScale(0.22, 0.68)
		wep.Position = UDim2.fromScale(1.08, 0.48)
		wep.AnchorPoint = Vector2.new(0.5, 0.5)
		wep.Rotation = 18
		wep.BackgroundColor3 = (kind == "orc") and Color3.fromRGB(118, 78, 44) or Color3.fromRGB(204, 212, 224)
		wep.BorderSizePixel = 0
		wep.ZIndex = zBase + 3
		wep.Parent = body
		addCorner(wep, 3)
		addStroke(wep, THEME.Outline, 1.3)
	elseif def.Boss then
		-- Doi canh rong do-den dap nhip nhang + vuong mien vang
		wingL = Instance.new("Frame")
		wingL.Size = UDim2.fromScale(0.58, 0.44)
		wingL.Position = UDim2.fromScale(-0.22, 0.42)
		wingL.AnchorPoint = Vector2.new(0.5, 0.5)
		wingL.Rotation = -18
		local wCol = (kind == "hero_boss" or kind == "lich_boss") and Color3.fromRGB(132, 46, 206) or ((kind == "phoenix_boss" or kind == "titan_boss" or kind == "cerberus") and Color3.fromRGB(224, 118, 36) or ((kind == "dark_knight_boss") and Color3.fromRGB(64, 54, 82) or Color3.fromRGB(154, 28, 46)))
		wingL.BackgroundColor3 = wCol
		wingL.BorderSizePixel = 0
		wingL.ZIndex = zBase + 1
		wingL.Parent = body
		addCorner(wingL, 6)
		addStroke(wingL, THEME.Outline, 1.8)

		wingR = Instance.new("Frame")
		wingR.Size = UDim2.fromScale(0.58, 0.44)
		wingR.Position = UDim2.fromScale(1.22, 0.42)
		wingR.AnchorPoint = Vector2.new(0.5, 0.5)
		wingR.Rotation = 18
		wingR.BackgroundColor3 = wCol
		wingR.BorderSizePixel = 0
		wingR.ZIndex = zBase + 1
		wingR.Parent = body
		addCorner(wingR, 6)
		addStroke(wingR, THEME.Outline, 1.8)

		local crown = Instance.new("Frame")
		crown.Size = UDim2.fromScale(0.56, 0.24)
		crown.Position = UDim2.fromScale(0.5, -0.08)
		crown.AnchorPoint = Vector2.new(0.5, 0.5)
		crown.BackgroundColor3 = THEME.TextGold
		crown.BorderSizePixel = 0
		crown.ZIndex = zBase + 4
		crown.Parent = body
		addCorner(crown, 4)
		addStroke(crown, THEME.Outline, 1.4)
	end

	-- 2 mat gian du (hoac mat sang)
	for _, ox in ipairs({0.33, 0.67}) do
		local eye = Instance.new("Frame")
		eye.Size = UDim2.fromScale(0.20, 0.20)
		eye.Position = UDim2.fromScale(ox, 0.42)
		eye.AnchorPoint = Vector2.new(0.5, 0.5)
		eye.BackgroundColor3 = def.Eye
		eye.BorderSizePixel = 0
		eye.ZIndex = zBase + 4
		eye.Parent = body
		addCorner(eye, 99)
	end

	-- Lop phu tinh the bang khi bi lam cham (Frozen state)
	local frostCoat = Instance.new("Frame")
	frostCoat.Size = UDim2.fromScale(1.16, 1.16)
	frostCoat.Position = UDim2.fromScale(0.5, 0.5)
	frostCoat.AnchorPoint = Vector2.new(0.5, 0.5)
	frostCoat.BackgroundColor3 = Color3.fromRGB(118, 212, 236)
	frostCoat.BackgroundTransparency = 0.55
	frostCoat.BorderSizePixel = 0
	frostCoat.Visible = false
	frostCoat.ZIndex = zBase + 5
	frostCoat.Parent = body
	addCorner(frostCoat, 8)
	addStroke(frostCoat, Color3.fromRGB(186, 232, 240), 1.6)

	-- Thanh mau tren dau
	local hpBg = Instance.new("Frame")
	hpBg.Size = UDim2.fromOffset(math.max(24, sz + 6), 5)
	hpBg.Position = UDim2.new(0.5, 0, 0, -10)
	hpBg.AnchorPoint = Vector2.new(0.5, 0.5)
	hpBg.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
	hpBg.BorderSizePixel = 0
	hpBg.ZIndex = zBase + 6
	hpBg.Parent = holder
	addCorner(hpBg, 3)
	addStroke(hpBg, THEME.Outline, 1)

	local hpFill = Instance.new("Frame")
	hpFill.Size = UDim2.fromScale(1, 1)
	hpFill.BackgroundColor3 = def.Boss and Color3.fromRGB(216, 62, 82) or Color3.fromRGB(76, 206, 98)
	hpFill.BorderSizePixel = 0
	hpFill.ZIndex = zBase + 7
	hpFill.Parent = hpBg
	addCorner(hpFill, 3)

	return holder, body, hpFill, frostCoat, wingL, wingR, bodyStroke
end

function GFX.buildObstacleSprite(parent, kind, zBase)
	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(CELL - 4, CELL - 4)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.BackgroundTransparency = 1
	root.ZIndex = zBase
	root.Parent = parent

	if kind == "tree" then
		-- Than cay nau + tan la xanh 2 tang
		local trunk = Instance.new("Frame")
		trunk.Size = UDim2.fromOffset(8, 12)
		trunk.Position = UDim2.fromScale(0.5, 0.78)
		trunk.AnchorPoint = Vector2.new(0.5, 0.5)
		trunk.BackgroundColor3 = Color3.fromRGB(118, 74, 42)
		trunk.BorderSizePixel = 0
		trunk.ZIndex = zBase
		trunk.Parent = root
		addCorner(trunk, 3)
		addStroke(trunk, THEME.Outline, 1.4)

		local leaf1 = Instance.new("Frame")
		leaf1.Size = UDim2.fromOffset(26, 22)
		leaf1.Position = UDim2.fromScale(0.5, 0.42)
		leaf1.AnchorPoint = Vector2.new(0.5, 0.5)
		leaf1.BackgroundColor3 = Color3.fromRGB(44, 148, 66)
		leaf1.BorderSizePixel = 0
		leaf1.ZIndex = zBase + 1
		leaf1.Parent = root
		addCorner(leaf1, 99)
		addStroke(leaf1, THEME.Outline, 1.6)

		local leaf2 = Instance.new("Frame")
		leaf2.Size = UDim2.fromOffset(16, 14)
		leaf2.Position = UDim2.fromScale(0.46, 0.34)
		leaf2.AnchorPoint = Vector2.new(0.5, 0.5)
		leaf2.BackgroundColor3 = Color3.fromRGB(78, 186, 86)
		leaf2.BorderSizePixel = 0
		leaf2.ZIndex = zBase + 2
		leaf2.Parent = root
		addCorner(leaf2, 99)
	elseif kind == "house" then
		-- Nha nho co tuong gach, mai ngoi do va cua so vang
		local wall = Instance.new("Frame")
		wall.Size = UDim2.fromOffset(24, 18)
		wall.Position = UDim2.fromScale(0.5, 0.66)
		wall.AnchorPoint = Vector2.new(0.5, 0.5)
		wall.BackgroundColor3 = Color3.fromRGB(196, 178, 148)
		wall.BorderSizePixel = 0
		wall.ZIndex = zBase
		wall.Parent = root
		addCorner(wall, 3)
		addStroke(wall, THEME.Outline, 1.5)

		local roof = Instance.new("Frame")
		roof.Size = UDim2.fromOffset(30, 14)
		roof.Position = UDim2.fromScale(0.5, 0.32)
		roof.AnchorPoint = Vector2.new(0.5, 0.5)
		roof.BackgroundColor3 = Color3.fromRGB(186, 62, 56)
		roof.BorderSizePixel = 0
		roof.ZIndex = zBase + 1
		roof.Parent = root
		addCorner(roof, 5)
		addStroke(roof, THEME.Outline, 1.6)

		local win = Instance.new("Frame")
		win.Size = UDim2.fromOffset(7, 7)
		win.Position = UDim2.fromScale(0.5, 0.68)
		win.AnchorPoint = Vector2.new(0.5, 0.5)
		win.BackgroundColor3 = Color3.fromRGB(224, 196, 82)
		win.BorderSizePixel = 0
		win.ZIndex = zBase + 2
		win.Parent = root
		addCorner(win, 2)
		addStroke(win, THEME.Outline, 1.1)
	elseif kind == "crystal" then
		-- Khoi tinh the dung nham / bang
		local c1 = Instance.new("Frame")
		c1.Size = UDim2.fromOffset(14, 24)
		c1.Position = UDim2.fromScale(0.5, 0.5)
		c1.AnchorPoint = Vector2.new(0.5, 0.5)
		c1.Rotation = 14
		c1.BackgroundColor3 = Color3.fromRGB(218, 84, 52)
		c1.BorderSizePixel = 0
		c1.ZIndex = zBase + 1
		c1.Parent = root
		addCorner(c1, 4)
		addStroke(c1, THEME.Outline, 1.5)

		local c2 = Instance.new("Frame")
		c2.Size = UDim2.fromOffset(10, 18)
		c2.Position = UDim2.fromScale(0.32, 0.58)
		c2.AnchorPoint = Vector2.new(0.5, 0.5)
		c2.Rotation = -22
		c2.BackgroundColor3 = Color3.fromRGB(232, 148, 56)
		c2.BorderSizePixel = 0
		c2.ZIndex = zBase
		c2.Parent = root
		addCorner(c2, 4)
		addStroke(c2, THEME.Outline, 1.4)
	else
		-- Hon da xam 3D
		local r1 = Instance.new("Frame")
		r1.Size = UDim2.fromOffset(26, 20)
		r1.Position = UDim2.fromScale(0.5, 0.56)
		r1.AnchorPoint = Vector2.new(0.5, 0.5)
		r1.BackgroundColor3 = Color3.fromRGB(108, 114, 128)
		r1.BorderSizePixel = 0
		r1.ZIndex = zBase
		r1.Parent = root
		addCorner(r1, 8)
		addStroke(r1, THEME.Outline, 1.6)

		local r2 = Instance.new("Frame")
		r2.Size = UDim2.fromOffset(14, 10)
		r2.Position = UDim2.fromScale(0.42, 0.44)
		r2.AnchorPoint = Vector2.new(0.5, 0.5)
		r2.BackgroundColor3 = Color3.fromRGB(148, 154, 168)
		r2.BorderSizePixel = 0
		r2.ZIndex = zBase + 1
		r2.Parent = root
		addCorner(r2, 5)
	end
	return root
end

function GFX.buildTrapSprite(parent, kind, zBase)
	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(26, 26)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.BackgroundColor3 = (kind == "mine") and Color3.fromRGB(54, 48, 56) or Color3.fromRGB(72, 78, 96)
	root.BorderSizePixel = 0
	root.ZIndex = zBase
	root.Parent = parent
	addCorner(root, (kind == "mine") and 99 or 6)
	addStroke(root, THEME.Outline, 1.8)

	if kind == "mine" then
		local core = Instance.new("Frame")
		core.Size = UDim2.fromOffset(12, 12)
		core.Position = UDim2.fromScale(0.5, 0.5)
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.BackgroundColor3 = Color3.fromRGB(228, 56, 56)
		core.BorderSizePixel = 0
		core.ZIndex = zBase + 1
		core.Parent = root
		addCorner(core, 99)
	else
		for _, pos in ipairs({{0.28,0.28},{0.72,0.28},{0.28,0.72},{0.72,0.72}}) do
			local sp = Instance.new("Frame")
			sp.Size = UDim2.fromOffset(6, 6)
			sp.Position = UDim2.fromScale(pos[1], pos[2])
			sp.AnchorPoint = Vector2.new(0.5, 0.5)
			sp.Rotation = 45
			sp.BackgroundColor3 = Color3.fromRGB(212, 218, 228)
			sp.BorderSizePixel = 0
			sp.ZIndex = zBase + 1
			sp.Parent = root
			addStroke(sp, THEME.Outline, 1)
		end
	end
	return root
end

-- BO LOGO / ICON VECTOR 2D CHO TAT CA NUT BAM & CHI SO (KHONG DUNG EMOJI)
function GFX.makeIcon(parent, kind, size, pos, anchor, z)
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(size, size)
	box.Position = pos
	box.AnchorPoint = anchor or Vector2.new(0.5, 0.5)
	box.BackgroundTransparency = 1
	box.ZIndex = z
	box.Parent = parent

	if kind == "heart" then
		local h = Instance.new("Frame")
		h.Size = UDim2.fromScale(0.68, 0.68)
		h.Position = UDim2.fromScale(0.5, 0.56)
		h.AnchorPoint = Vector2.new(0.5, 0.5)
		h.Rotation = 45
		h.BackgroundColor3 = Color3.fromRGB(224, 62, 74)
		h.BorderSizePixel = 0
		h.ZIndex = z + 1
		h.Parent = box
		addCorner(h, 3)
		addStroke(h, THEME.Outline, 1.4)
		for _, ox in ipairs({0.34, 0.66}) do
			local lobe = Instance.new("Frame")
			lobe.Size = UDim2.fromScale(0.46, 0.46)
			lobe.Position = UDim2.fromScale(ox, 0.36)
			lobe.AnchorPoint = Vector2.new(0.5, 0.5)
			lobe.BackgroundColor3 = Color3.fromRGB(224, 62, 74)
			lobe.BorderSizePixel = 0
			lobe.ZIndex = z + 2
			lobe.Parent = box
			addCorner(lobe, 99)
		end
	elseif kind == "coin" then
		local c = Instance.new("Frame")
		c.Size = UDim2.fromScale(0.86, 0.86)
		c.Position = UDim2.fromScale(0.5, 0.5)
		c.AnchorPoint = Vector2.new(0.5, 0.5)
		c.BackgroundColor3 = Color3.fromRGB(224, 182, 44)
		c.BorderSizePixel = 0
		c.ZIndex = z + 1
		c.Parent = box
		addCorner(c, 99)
		addStroke(c, THEME.Outline, 1.5)
		local s = Instance.new("TextLabel")
		s.Size = UDim2.fromScale(1, 1)
		s.BackgroundTransparency = 1
		s.Text = "$"
		s.TextColor3 = Color3.fromRGB(118, 66, 14)
		s.Font = THEME.FontHead
		s.TextSize = math.max(9, math.floor(size * 0.62))
		s.ZIndex = z + 2
		s.Parent = c
	elseif kind == "wave" then
		local sh = Instance.new("Frame")
		sh.Size = UDim2.fromScale(0.76, 0.84)
		sh.Position = UDim2.fromScale(0.5, 0.5)
		sh.AnchorPoint = Vector2.new(0.5, 0.5)
		sh.BackgroundColor3 = Color3.fromRGB(68, 178, 224)
		sh.BorderSizePixel = 0
		sh.ZIndex = z + 1
		sh.Parent = box
		addCorner(sh, 5)
		addStroke(sh, THEME.Outline, 1.4)
		local stripe = Instance.new("Frame")
		stripe.Size = UDim2.fromScale(0.28, 0.66)
		stripe.Position = UDim2.fromScale(0.5, 0.5)
		stripe.AnchorPoint = Vector2.new(0.5, 0.5)
		stripe.BackgroundColor3 = Color3.fromRGB(218, 228, 236)
		stripe.BorderSizePixel = 0
		stripe.ZIndex = z + 2
		stripe.Parent = sh
		addCorner(stripe, 2)
	elseif kind == "play" then
		local disc = Instance.new("Frame")
		disc.Size = UDim2.fromScale(0.88, 0.88)
		disc.Position = UDim2.fromScale(0.5, 0.5)
		disc.AnchorPoint = Vector2.new(0.5, 0.5)
		disc.BackgroundColor3 = Color3.fromRGB(224, 232, 224)
		disc.BorderSizePixel = 0
		disc.ZIndex = z + 1
		disc.Parent = box
		addCorner(disc, 99)
		addStroke(disc, THEME.Outline, 1.5)
		local tri = Instance.new("TextLabel")
		tri.Size = UDim2.fromScale(1, 1)
		tri.Position = UDim2.fromOffset(1, 0)
		tri.BackgroundTransparency = 1
		tri.Text = "▶"
		tri.TextColor3 = Color3.fromRGB(34, 154, 58)
		tri.Font = THEME.FontHead
		tri.TextSize = math.max(9, math.floor(size * 0.58))
		tri.ZIndex = z + 2
		tri.Parent = disc
	elseif kind == "star" then
		for _, rot in ipairs({0, 45}) do
			local sq = Instance.new("Frame")
			sq.Size = UDim2.fromScale(0.66, 0.66)
			sq.Position = UDim2.fromScale(0.5, 0.5)
			sq.AnchorPoint = Vector2.new(0.5, 0.5)
			sq.Rotation = rot
			sq.BackgroundColor3 = Color3.fromRGB(232, 192, 48)
			sq.BorderSizePixel = 0
			sq.ZIndex = z + 1
			sq.Parent = box
			addCorner(sq, 3)
			addStroke(sq, THEME.Outline, 1.3)
		end
	elseif kind == "quest" then
		local ch = Instance.new("Frame")
		ch.Size = UDim2.fromScale(0.84, 0.72)
		ch.Position = UDim2.fromScale(0.5, 0.54)
		ch.AnchorPoint = Vector2.new(0.5, 0.5)
		ch.BackgroundColor3 = Color3.fromRGB(168, 92, 34)
		ch.BorderSizePixel = 0
		ch.ZIndex = z + 1
		ch.Parent = box
		addCorner(ch, 4)
		addStroke(ch, THEME.Outline, 1.4)
		local band = Instance.new("Frame")
		band.Size = UDim2.fromScale(1, 0.24)
		band.Position = UDim2.fromScale(0.5, 0.44)
		band.AnchorPoint = Vector2.new(0.5, 0.5)
		band.BackgroundColor3 = Color3.fromRGB(232, 192, 52)
		band.BorderSizePixel = 0
		band.ZIndex = z + 2
		band.Parent = ch
		local lock = Instance.new("Frame")
		lock.Size = UDim2.fromScale(0.26, 0.34)
		lock.Position = UDim2.fromScale(0.5, 0.54)
		lock.AnchorPoint = Vector2.new(0.5, 0.5)
		lock.BackgroundColor3 = Color3.fromRGB(232, 192, 52)
		lock.BorderSizePixel = 0
		lock.ZIndex = z + 3
		lock.Parent = ch
		addCorner(lock, 2)
		addStroke(lock, THEME.Outline, 1.1)
	elseif kind == "gear" then
		for _, rot in ipairs({0, 45}) do
			local g = Instance.new("Frame")
			g.Size = UDim2.fromScale(0.76, 0.76)
			g.Position = UDim2.fromScale(0.5, 0.5)
			g.AnchorPoint = Vector2.new(0.5, 0.5)
			g.Rotation = rot
			g.BackgroundColor3 = Color3.fromRGB(214, 222, 232)
			g.BorderSizePixel = 0
			g.ZIndex = z + 1
			g.Parent = box
			addCorner(g, 4)
			addStroke(g, THEME.Outline, 1.3)
		end
		local hole = Instance.new("Frame")
		hole.Size = UDim2.fromScale(0.36, 0.36)
		hole.Position = UDim2.fromScale(0.5, 0.5)
		hole.AnchorPoint = Vector2.new(0.5, 0.5)
		hole.BackgroundColor3 = Color3.fromRGB(48, 62, 98)
		hole.BorderSizePixel = 0
		hole.ZIndex = z + 2
		hole.Parent = box
		addCorner(hole, 99)
		addStroke(hole, THEME.Outline, 1.2)
	elseif kind == "meteor" then
		local tail = Instance.new("Frame")
		tail.Size = UDim2.fromScale(0.76, 0.36)
		tail.Position = UDim2.fromScale(0.58, 0.38)
		tail.AnchorPoint = Vector2.new(0.5, 0.5)
		tail.Rotation = -42
		tail.BackgroundColor3 = Color3.fromRGB(232, 148, 42)
		tail.BorderSizePixel = 0
		tail.ZIndex = z + 1
		tail.Parent = box
		addCorner(tail, 99)
		local rock = Instance.new("Frame")
		rock.Size = UDim2.fromScale(0.62, 0.62)
		rock.Position = UDim2.fromScale(0.38, 0.64)
		rock.AnchorPoint = Vector2.new(0.5, 0.5)
		rock.BackgroundColor3 = Color3.fromRGB(214, 58, 42)
		rock.BorderSizePixel = 0
		rock.ZIndex = z + 2
		rock.Parent = box
		addCorner(rock, 99)
		addStroke(rock, THEME.Outline, 1.4)
	elseif kind == "snow" then
		for _, rot in ipairs({0, 60, 120}) do
			local bar = Instance.new("Frame")
			bar.Size = UDim2.fromScale(0.84, 0.20)
			bar.Position = UDim2.fromScale(0.5, 0.5)
			bar.AnchorPoint = Vector2.new(0.5, 0.5)
			bar.Rotation = rot
			bar.BackgroundColor3 = Color3.fromRGB(196, 232, 240)
			bar.BorderSizePixel = 0
			bar.ZIndex = z + 1
			bar.Parent = box
			addCorner(bar, 3)
			addStroke(bar, THEME.Outline, 1.1)
		end
	elseif kind == "castle_logo" then
		local b = Instance.new("Frame")
		b.Size = UDim2.fromScale(0.78, 0.72)
		b.Position = UDim2.fromScale(0.5, 0.62)
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.BackgroundColor3 = Color3.fromRGB(142, 86, 218)
		b.BorderSizePixel = 0
		b.ZIndex = z + 1
		b.Parent = box
		addCorner(b, 4)
		addStroke(b, THEME.Outline, 1.4)
		for _, ox in ipairs({0.22, 0.5, 0.78}) do
			local t = Instance.new("Frame")
			t.Size = UDim2.fromScale(0.24, 0.34)
			t.Position = UDim2.fromScale(ox, 0.24)
			t.AnchorPoint = Vector2.new(0.5, 0.5)
			t.BackgroundColor3 = Color3.fromRGB(168, 108, 232)
			t.BorderSizePixel = 0
			t.ZIndex = z + 2
			t.Parent = box
			addCorner(t, 2)
			addStroke(t, THEME.Outline, 1.2)
		end
	elseif kind == "bag" then
		local bg = Instance.new("Frame")
		bg.Size = UDim2.fromScale(0.78, 0.80)
		bg.Position = UDim2.fromScale(0.5, 0.56)
		bg.AnchorPoint = Vector2.new(0.5, 0.5)
		bg.BackgroundColor3 = Color3.fromRGB(196, 98, 42)
		bg.BorderSizePixel = 0
		bg.ZIndex = z + 1
		bg.Parent = box
		addCorner(bg, 6)
		addStroke(bg, THEME.Outline, 1.4)
		local flap = Instance.new("Frame")
		flap.Size = UDim2.fromScale(0.84, 0.38)
		flap.Position = UDim2.fromScale(0.5, 0.34)
		flap.AnchorPoint = Vector2.new(0.5, 0.5)
		flap.BackgroundColor3 = Color3.fromRGB(224, 152, 48)
		flap.BorderSizePixel = 0
		flap.ZIndex = z + 2
		flap.Parent = box
		addCorner(flap, 4)
		addStroke(flap, THEME.Outline, 1.2)
	elseif kind == "heal" then
		local h1 = Instance.new("Frame")
		h1.Size = UDim2.fromScale(0.76, 0.28)
		h1.Position = UDim2.fromScale(0.5, 0.5)
		h1.AnchorPoint = Vector2.new(0.5, 0.5)
		h1.BackgroundColor3 = Color3.fromRGB(218, 236, 224)
		h1.BorderSizePixel = 0
		h1.ZIndex = z + 1
		h1.Parent = box
		addCorner(h1, 3)
		addStroke(h1, THEME.Outline, 1.2)
		local h2 = Instance.new("Frame")
		h2.Size = UDim2.fromScale(0.28, 0.76)
		h2.Position = UDim2.fromScale(0.5, 0.5)
		h2.AnchorPoint = Vector2.new(0.5, 0.5)
		h2.BackgroundColor3 = Color3.fromRGB(218, 236, 224)
		h2.BorderSizePixel = 0
		h2.ZIndex = z + 2
		h2.Parent = box
		addCorner(h2, 3)
		addStroke(h2, THEME.Outline, 1.2)
	elseif kind == "trap" then
		local base = Instance.new("Frame")
		base.Size = UDim2.fromScale(0.78, 0.78)
		base.Position = UDim2.fromScale(0.5, 0.5)
		base.AnchorPoint = Vector2.new(0.5, 0.5)
		base.BackgroundColor3 = Color3.fromRGB(76, 82, 102)
		base.BorderSizePixel = 0
		base.ZIndex = z + 1
		base.Parent = box
		addCorner(base, 5)
		addStroke(base, THEME.Outline, 1.4)
		local dot = Instance.new("Frame")
		dot.Size = UDim2.fromScale(0.42, 0.42)
		dot.Position = UDim2.fromScale(0.5, 0.5)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.BackgroundColor3 = Color3.fromRGB(228, 62, 62)
		dot.BorderSizePixel = 0
		dot.ZIndex = z + 2
		dot.Parent = base
		addCorner(dot, 99)
	end
	return box
end

-- ============================================================
-- KHOI TAO SCREENGUI NOI DE LEN ROBLOX TOPBAR
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2147483647
pcall(function() screenGui.ScreenInsets = Enum.ScreenInsets.None end)
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

-- Hieu ung am thanh nhe (SFX) co nut bat/tat
local SFX_IDS = {
	shoot     = "rbxassetid://12222216",
	explosion = "rbxassetid://12222084",
	frost     = "rbxassetid://12222030",
	zap       = "rbxassetid://12222200",
	laser     = "rbxassetid://12222140",
	upgrade   = "rbxassetid://12222253",
	kill      = "rbxassetid://12221967",
}
local function playSfx(kind, pitch)
	if not saveState.SfxOn then return end
	local id = SFX_IDS[kind]
	if not id then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = ((kind == "explosion" or kind == "upgrade") and 0.34 or 0.22) * (saveState.SfxVol or 0.7)
		s.PlaybackSpeed = pitch or 1
		s.Parent = screenGui
		s:Play()
		task.delay(1.2, function() if s and s.Parent then s:Destroy() end end)
	end)
end

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(12, 14, 26)
backdrop.BorderSizePixel = 0
backdrop.ZIndex = 1
backdrop.Parent = screenGui
addGradient(backdrop, Color3.fromRGB(22, 24, 48), Color3.fromRGB(10, 12, 22), 90)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(BASE_W, BASE_H)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 19, 34)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 2
mainFrame.Parent = screenGui
addCorner(mainFrame, 14)
addStroke(mainFrame, Color3.fromRGB(106, 72, 198), 2.4)

local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame

local function applyScale()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	local sx = vp.X / BASE_W
	local sy = vp.Y / BASE_H
	uiScale.Scale = math.clamp(math.min(sx, sy), 0.45, 2.2)
end
applyScale()

local floatBtn = makeArcadeBtn(
	screenGui, "TD",
	UDim2.fromOffset(50, 50), UDim2.new(0, 16, 0.5, -25),
	Color3.fromRGB(132, 68, 214), Color3.fromRGB(78, 34, 158), 25,
	{ TextSize = 15, ZIndex = 40, Depth = 4 }
)
floatBtn.Visible = false
local floatDragged = false
makeDraggable(floatBtn, floatBtn, function(v) floatDragged = v end)

-- Toast thong bao noi
local toastToken = 0
local function showToast(msg, col, dur)
	toastToken += 1
	local myT = toastToken
	if not UI.toast then
		local tf = Instance.new("Frame")
		tf.Size = UDim2.fromOffset(390, 38)
		tf.Position = UDim2.new(0.5, 0, 0, -48)
		tf.AnchorPoint = Vector2.new(0.5, 0)
		tf.BackgroundColor3 = Color3.fromRGB(22, 26, 48)
		tf.BorderSizePixel = 0
		tf.ZIndex = 80
		tf.Visible = false
		tf.Parent = mainFrame
		addCorner(tf, 10)
		UI.toastStroke = addStroke(tf, THEME.TextGold, 2)
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.new(1, -16, 1, 0)
		tl.Position = UDim2.fromOffset(8, 0)
		tl.BackgroundTransparency = 1
		tl.Text = ""
		tl.TextColor3 = THEME.TextMain
		tl.Font = THEME.FontHead
		tl.TextSize = 12
		tl.ZIndex = 81
		tl.Parent = tf
		addTextOutline(tl, 1.4, THEME.Outline)
		UI.toast = tf
		UI.toastLbl = tl
	end
	UI.toastLbl.Text = msg
	UI.toastLbl.TextColor3 = col or THEME.TextGold
	UI.toastStroke.Color = col or THEME.TextGold
	UI.toast.Visible = true
	UI.toast.Position = UDim2.new(0.5, 0, 0, -42)
	TweenService:Create(UI.toast, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 56)
	}):Play()
	task.delay(dur or 2.6, function()
		if toastToken == myT and UI.toast and UI.toast.Parent then
			local tw = TweenService:Create(UI.toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, 0, -48)
			})
			tw:Play()
			tw.Completed:Connect(function()
				if toastToken == myT and UI.toast and UI.toast.Parent then UI.toast.Visible = false end
			end)
		end
	end)
end

-- ============================================================
-- THANH TOP BAR & CAC TRANG (SANH CHON BAN DO / MAN CHOI)
-- ============================================================
function SEC.buildTopBar()
	local top = Instance.new("Frame")
	top.Size = UDim2.new(1, 0, 0, 48)
	top.BackgroundColor3 = Color3.fromRGB(26, 28, 54)
	top.BorderSizePixel = 0
	top.ZIndex = 10
	top.Parent = mainFrame
	addGradient(top, Color3.fromRGB(50, 38, 96), Color3.fromRGB(22, 24, 48), 90)

	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, 0, 0, 2)
	div.Position = UDim2.new(0, 0, 1, -2)
	div.BackgroundColor3 = Color3.fromRGB(112, 74, 204)
	div.BorderSizePixel = 0
	div.ZIndex = 11
	div.Parent = top

	GFX.makeIcon(top, "castle_logo", 24, UDim2.fromOffset(20, 24), Vector2.new(0.5, 0.5), 12)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromOffset(102, 46)
	title.Position = UDim2.fromOffset(36, 0)
	title.BackgroundTransparency = 1
	title.Text = "THỦ THÀNH 2D"
	title.TextColor3 = THEME.TextGold
	title.Font = THEME.FontHead
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 12
	title.Parent = top
	addTextOutline(title, 1.8, THEME.Outline)
	UI.topTitle = title

	-- Cac chi so trong tran (an khi o sanh)
	local hudGroup = Instance.new("Frame")
	hudGroup.Size = UDim2.fromOffset(424, 40)
	hudGroup.Position = UDim2.fromOffset(132, 4)
	hudGroup.BackgroundTransparency = 1
	hudGroup.Visible = false
	hudGroup.ZIndex = 11
	hudGroup.Parent = top
	UI.hudGroup = hudGroup

	local function makeStatPill(x, w, strokeCol, txtCol, initTxt, iconKind)
		local p = Instance.new("Frame")
		p.Size = UDim2.fromOffset(w, 32)
		p.Position = UDim2.fromOffset(x, 4)
		p.BackgroundColor3 = Color3.fromRGB(16, 18, 36)
		p.BorderSizePixel = 0
		p.ZIndex = 12
		p.Parent = hudGroup
		addCorner(p, 10)
		addStroke(p, strokeCol, 1.6)
		GFX.makeIcon(p, iconKind, 18, UDim2.new(0, 14, 0.5, 0), Vector2.new(0.5, 0.5), 13)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -26, 1, 0)
		l.Position = UDim2.fromOffset(24, 0)
		l.BackgroundTransparency = 1
		l.Text = initTxt
		l.TextColor3 = txtCol
		l.Font = THEME.FontHead
		l.TextSize = 12
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = 13
		l.Parent = p
		addTextOutline(l, 1.3, THEME.Outline)
		return l
	end

	-- Thanh Mau Thanh Tri dang Progress Bar do co tim (giong anh mau)
	local hpPill = Instance.new("Frame")
	hpPill.Size = UDim2.fromOffset(82, 32)
	hpPill.Position = UDim2.fromOffset(0, 4)
	hpPill.BackgroundColor3 = Color3.fromRGB(28, 16, 26)
	hpPill.BorderSizePixel = 0
	hpPill.ClipsDescendants = true
	hpPill.ZIndex = 12
	hpPill.Parent = hudGroup
	addCorner(hpPill, 10)
	addStroke(hpPill, Color3.fromRGB(206, 68, 76), 1.6)
	local hpBar = Instance.new("Frame")
	hpBar.Size = UDim2.fromScale(1, 1)
	hpBar.BackgroundColor3 = Color3.fromRGB(186, 44, 56)
	hpBar.BorderSizePixel = 0
	hpBar.ZIndex = 12
	hpBar.Parent = hpPill
	addCorner(hpBar, 9)
	addGradient(hpBar, Color3.fromRGB(218, 62, 74), Color3.fromRGB(142, 26, 38), 90)
	UI.livesBarFill = hpBar
	GFX.makeIcon(hpPill, "heart", 18, UDim2.new(0, 14, 0.5, 0), Vector2.new(0.5, 0.5), 14)
	local hpTxt = Instance.new("TextLabel")
	hpTxt.Size = UDim2.new(1, -24, 1, 0)
	hpTxt.Position = UDim2.fromOffset(24, 0)
	hpTxt.BackgroundTransparency = 1
	hpTxt.Text = "30/30"
	hpTxt.TextColor3 = THEME.TextMain
	hpTxt.Font = THEME.FontHead
	hpTxt.TextSize = 11
	hpTxt.TextXAlignment = Enum.TextXAlignment.Left
	hpTxt.ZIndex = 15
	hpTxt.Parent = hpPill
	addTextOutline(hpTxt, 1.4, THEME.Outline)
	UI.livesLbl = hpTxt
	UI.goldLbl  = makeStatPill(84,  102, Color3.fromRGB(186, 146, 42), THEME.TextGold, "240",  "coin")
	UI.waveLbl  = makeStatPill(192, 98,  Color3.fromRGB(72, 158, 206), THEME.TextCyan, "0/12", "wave")

	local spdBtn, spdLbl = makeArcadeBtn(
		hudGroup, "1x",
		UDim2.fromOffset(44, 32), UDim2.fromOffset(298, 4),
		Color3.fromRGB(56, 148, 212), Color3.fromRGB(32, 86, 174), 9,
		{ TextSize = 12, ZIndex = 12, Depth = 3, Stroke = 1.6 }
	)
	UI.spdBtn = spdBtn
	UI.spdLbl = spdLbl

	local pauseBtn, pauseLbl = makeArcadeBtn(
		hudGroup, "II",
		UDim2.fromOffset(44, 32), UDim2.fromOffset(348, 4),
		Color3.fromRGB(204, 144, 44), Color3.fromRGB(152, 86, 22), 9,
		{ TextSize = 12, ZIndex = 12, Depth = 3, Stroke = 1.6 }
	)
	UI.pauseBtn = pauseBtn
	UI.pauseLbl = pauseLbl

	UI.sfxBtn, UI.sfxLbl = makeArcadeBtn(top, saveState.SfxOn and "Âm" or "Tắt", UDim2.fromOffset(40, 32), UDim2.new(1, -126, 0, 8), Color3.fromRGB(54, 152, 186), Color3.fromRGB(32, 92, 134), 9, { TextSize = 10, ZIndex = 12, Depth = 3, Stroke = 1.6 })
	UI.homeBtn = makeArcadeBtn(top, "Sảnh", UDim2.fromOffset(52, 32), UDim2.new(1, -138, 0, 8), Color3.fromRGB(142, 72, 208), Color3.fromRGB(88, 36, 162), 9, { TextSize = 11, ZIndex = 12, Depth = 3, Stroke = 1.6 })
	UI.homeBtn.Visible = false
	UI.minBtn   = makeArcadeBtn(top, "-", UDim2.fromOffset(36, 32), UDim2.new(1, -80, 0, 8), Color3.fromRGB(82, 94, 128), Color3.fromRGB(48, 56, 82), 9, { TextSize = 18, ZIndex = 12, Depth = 3, Stroke = 1.6 })
	UI.closeBtn = makeArcadeBtn(top, "X", UDim2.fromOffset(36, 32), UDim2.new(1, -40, 0, 8), Color3.fromRGB(212, 62, 68), Color3.fromRGB(152, 28, 36), 9, { TextSize = 13, ZIndex = 12, Depth = 3, Stroke = 1.6 })
end
SEC.buildTopBar()

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -56)
contentArea.Position = UDim2.fromOffset(8, 52)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 3
contentArea.Parent = mainFrame

-- TRANG SANH CHON BAN DO
local lobbyPage = Instance.new("Frame")
lobbyPage.Size = UDim2.fromScale(1, 1)
lobbyPage.BackgroundTransparency = 1
lobbyPage.ZIndex = 3
lobbyPage.Parent = contentArea

-- TRANG CHOI GAME
local gamePage = Instance.new("Frame")
gamePage.Size = UDim2.fromScale(1, 1)
gamePage.BackgroundTransparency = 1
gamePage.Visible = false
gamePage.ZIndex = 3
gamePage.Parent = contentArea

-- ============================================================
-- XAY DUNG SANH CHON 3 BAN DO
-- ============================================================
local mapCards = {}
function SEC.buildLobby()
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.Position = UDim2.fromOffset(0, 6)
	header.BackgroundTransparency = 1
	header.Text = "CHỌN CHIẾN TRƯỜNG ĐỂ BẮT ĐẦU PHÒNG THỦ"
	header.TextColor3 = THEME.TextMain
	header.Font = THEME.FontHead
	header.TextSize = 15
	header.ZIndex = 5
	header.Parent = lobbyPage
	addTextOutline(header, 1.6, THEME.Outline)

	local statsLbl = Instance.new("TextLabel")
	statsLbl.Size = UDim2.new(1, 0, 0, 20)
	statsLbl.Position = UDim2.fromOffset(0, 34)
	statsLbl.BackgroundTransparency = 1
	statsLbl.Text = "Tổng quái đã tiêu diệt: " .. formatNum(saveState.TotalKills)
	statsLbl.TextColor3 = THEME.TextGold
	statsLbl.Font = THEME.FontBody
	statsLbl.TextSize = 12
	statsLbl.ZIndex = 5
	statsLbl.Parent = lobbyPage
	UI.lobbyStatsLbl = statsLbl

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -16, 0, 228)
	row.Position = UDim2.fromOffset(8, 66)
	row.BackgroundTransparency = 1
	row.ZIndex = 4
	row.Parent = lobbyPage

	local lay = Instance.new("UIListLayout")
	lay.FillDirection = Enum.FillDirection.Horizontal
	lay.Padding = UDim.new(0, 6)
	lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lay.Parent = row

	for idx, mp in ipairs(MAPS) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.fromOffset(136, 224)
		addGradient(card, mp.BossArena and Color3.fromRGB(58, 24, 52) or Color3.fromRGB(34, 40, 74), Color3.fromRGB(18, 20, 40), 90)
		card.BackgroundColor3 = mp.BossArena and Color3.fromRGB(36, 20, 44) or Color3.fromRGB(24, 28, 52)
		card.Text = ""
		card.AutoButtonColor = false
		card.BorderSizePixel = 0
		card.ZIndex = 5
		card.Parent = row
		addCorner(card, 14)
		local st = addStroke(card, mp.BossArena and Color3.fromRGB(196, 72, 92) or Color3.fromRGB(76, 86, 134), 2.2)

		-- Mini preview ban do
		local prev = Instance.new("Frame")
		prev.Size = UDim2.fromOffset(118, 92)
		prev.Position = UDim2.fromOffset(9, 10)
		prev.BackgroundColor3 = mp.Grass1
		prev.BorderSizePixel = 0
		prev.ClipsDescendants = true
		prev.ZIndex = 6
		prev.Parent = card
		addCorner(prev, 10)
		addStroke(prev, THEME.Outline, 1.8)

		-- Ve duong di mini
		for w = 1, #mp.Waypoints - 1 do
			local a, b = mp.Waypoints[w], mp.Waypoints[w + 1]
			local x1, y1 = (a[1] - 0.5) * (118 / COLS), (a[2] - 0.5) * (92 / ROWS)
			local x2, y2 = (b[1] - 0.5) * (118 / COLS), (b[2] - 0.5) * (92 / ROWS)
			local seg = Instance.new("Frame")
			local minX, minY = math.min(x1, x2), math.min(y1, y2)
			local wPx = math.abs(x2 - x1) + 12
			local hPx = math.abs(y2 - y1) + 12
			seg.Size = UDim2.fromOffset(wPx, hPx)
			seg.Position = UDim2.fromOffset(minX - 6, minY - 6)
			seg.BackgroundColor3 = mp.PathCol
			seg.BorderSizePixel = 0
			seg.ZIndex = 7
			seg.Parent = prev
			addCorner(seg, 4)
		end

		local nLbl = Instance.new("TextLabel")
		nLbl.Size = UDim2.new(1, -16, 0, 22)
		nLbl.Position = UDim2.fromOffset(8, 114)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = mp.Name
		nLbl.TextColor3 = mp.BossArena and THEME.TextGold or THEME.TextMain
		nLbl.Font = THEME.FontHead
		nLbl.TextSize = 13
		nLbl.ZIndex = 6
		nLbl.Parent = card



		local recLbl = Instance.new("TextLabel")
		recLbl.Size = UDim2.new(1, -16, 0, 38)
		recLbl.Position = UDim2.fromOffset(8, 146)
		recLbl.BackgroundTransparency = 1
		recLbl.Text = "Kỷ lục: Đợt 0/" .. mp.Waves .. "\nChiến thắng: 0 lần"
		recLbl.TextColor3 = THEME.TextGold
		recLbl.Font = THEME.FontBody
		recLbl.TextSize = 11
		recLbl.ZIndex = 6
		recLbl.Parent = card

		local starRow = Instance.new("Frame")
		starRow.Size = UDim2.fromOffset(72, 18)
		starRow.Position = UDim2.new(0.5, -36, 1, -24)
		starRow.BackgroundTransparency = 1
		starRow.ZIndex = 7
		starRow.Parent = card
		local starIcons = {}
		for si = 1, 3 do
			local sf = Instance.new("Frame")
			sf.Size = UDim2.fromOffset(14, 14)
			sf.Position = UDim2.fromOffset(6 + (si - 1) * 22, 2)
			sf.Rotation = 45
			sf.BackgroundColor3 = Color3.fromRGB(64, 70, 96)
			sf.BorderSizePixel = 0
			sf.ZIndex = 7
			sf.Parent = starRow
			addCorner(sf, 3)
			addStroke(sf, THEME.Outline, 1.2)
			starIcons[si] = sf
		end
		mapCards[idx] = { Card = card, Stroke = st, RecLbl = recLbl, Stars = starIcons, Map = mp }
		card.MouseButton1Click:Connect(function()
			saveState.SelectedMap = idx
			saveData()
			for j, mc in ipairs(mapCards) do
				mc.Stroke.Color = (j == idx) and THEME.TextGold or Color3.fromRGB(76, 86, 134)
				mc.Stroke.Thickness = (j == idx) and 3.0 or 2.2
			end
			if UI.openDiffModal then UI.openDiffModal(mp) end
		end)
	end

	local playBtn, _, playFace = makeArcadeBtn(
		lobbyPage, "CHƠI NGAY",
		UDim2.fromOffset(148, 50), UDim2.new(0.5, -346, 1, -66),
		Color3.fromRGB(68, 206, 74), Color3.fromRGB(28, 144, 48), 14,
		{ TextSize = 13, ZIndex = 6, Depth = 5, Stroke = 2.4, LabelPos = UDim2.fromOffset(14, 0), LabelSize = UDim2.new(1, -18, 1, 0) }
	)
	GFX.makeIcon(playFace, "play", 20, UDim2.new(0, 19, 0.5, 0), Vector2.new(0.5, 0.5), 9)
	UI.playBtn = playBtn

	local permBtn, permLbl, permFace = makeArcadeBtn(
		lobbyPage, "KỸ NĂNG",
		UDim2.fromOffset(136, 50), UDim2.new(0.5, -190, 1, -66),
		Color3.fromRGB(154, 72, 218), Color3.fromRGB(94, 34, 168), 14,
		{ TextSize = 11, ZIndex = 6, Depth = 5, Stroke = 2.4, LabelPos = UDim2.fromOffset(14, 0), LabelSize = UDim2.new(1, -18, 1, 0) }
	)
	GFX.makeIcon(permFace, "star", 18, UDim2.new(0, 17, 0.5, 0), Vector2.new(0.5, 0.5), 9)
	UI.permUpgBtn = permBtn
	UI.permUpgLbl = permLbl

	local bagBtn, bagLbl, bagFace = makeArcadeBtn(
		lobbyPage, "KHO ĐỒ",
		UDim2.fromOffset(124, 50), UDim2.new(0.5, -46, 1, -66),
		Color3.fromRGB(218, 122, 42), Color3.fromRGB(164, 68, 22), 14,
		{ TextSize = 11, ZIndex = 6, Depth = 5, Stroke = 2.4, LabelPos = UDim2.fromOffset(14, 0), LabelSize = UDim2.new(1, -18, 1, 0) }
	)
	GFX.makeIcon(bagFace, "bag", 18, UDim2.new(0, 18, 0.5, 0), Vector2.new(0.5, 0.5), 9)
	UI.bagBtn = bagBtn
	UI.bagLbl = bagLbl

	local qBtn, qLbl, qFace = makeArcadeBtn(
		lobbyPage, "NHIỆM VỤ",
		UDim2.fromOffset(132, 50), UDim2.new(0.5, 86, 1, -66),
		Color3.fromRGB(214, 166, 38), Color3.fromRGB(162, 98, 18), 14,
		{ TextSize = 11, ZIndex = 6, Depth = 5, Stroke = 2.4, LabelPos = UDim2.fromOffset(14, 0), LabelSize = UDim2.new(1, -18, 1, 0) }
	)
	GFX.makeIcon(qFace, "quest", 18, UDim2.new(0, 18, 0.5, 0), Vector2.new(0.5, 0.5), 9)
	UI.questBtn = qBtn
	UI.questLbl = qLbl

	local setBtn, _, setFace = makeArcadeBtn(
		lobbyPage, "CÀI ĐẶT",
		UDim2.fromOffset(120, 50), UDim2.new(0.5, 226, 1, -66),
		Color3.fromRGB(58, 142, 206), Color3.fromRGB(32, 82, 158), 14,
		{ TextSize = 11, ZIndex = 6, Depth = 5, Stroke = 2.4, LabelPos = UDim2.fromOffset(14, 0), LabelSize = UDim2.new(1, -18, 1, 0) }
	)
	GFX.makeIcon(setFace, "gear", 18, UDim2.new(0, 18, 0.5, 0), Vector2.new(0.5, 0.5), 9)
	UI.settingsBtn = setBtn

	-- Modal Cay Ky Nang Vinh Vien ngoai sanh
	local pmOverlay = Instance.new("TextButton")
	pmOverlay.Size = UDim2.fromScale(1, 1)
	pmOverlay.BackgroundColor3 = Color3.fromRGB(6, 8, 16)
	pmOverlay.BackgroundTransparency = 0.35
	pmOverlay.Text = ""
	pmOverlay.AutoButtonColor = false
	pmOverlay.Active = true
	pmOverlay.Modal = true
	pmOverlay.Visible = false
	pmOverlay.ZIndex = 50
	pmOverlay.Parent = mainFrame
	UI.pmOverlay = pmOverlay

	local pmBox = Instance.new("TextButton")
	pmBox.Size = UDim2.fromOffset(480, 326)
	pmBox.Position = UDim2.fromScale(0.5, 0.5)
	pmBox.AnchorPoint = Vector2.new(0.5, 0.5)
	pmBox.BackgroundColor3 = Color3.fromRGB(20, 24, 46)
	pmBox.Text = ""
	pmBox.AutoButtonColor = false
	pmBox.Active = true
	pmBox.BorderSizePixel = 0
	pmBox.ZIndex = 51
	pmBox.Parent = pmOverlay
	addCorner(pmBox, 14)
	addStroke(pmBox, THEME.TextGold, 2.4)
	UI.pmBox = pmBox

	local pmTitle = Instance.new("TextLabel")
	pmTitle.Size = UDim2.new(1, -56, 0, 34)
	pmTitle.Position = UDim2.fromOffset(14, 8)
	pmTitle.BackgroundTransparency = 1
	pmTitle.Text = "CÂY KỸ NĂNG VĨNH VIỄN"
	pmTitle.TextColor3 = THEME.TextGold
	pmTitle.Font = THEME.FontHead
	pmTitle.TextSize = 15
	pmTitle.TextXAlignment = Enum.TextXAlignment.Left
	pmTitle.ZIndex = 52
	pmTitle.Parent = pmBox
	UI.pmTitle = pmTitle

	UI.pmClose = makeArcadeBtn(pmBox, "X", UDim2.fromOffset(32, 30), UDim2.new(1, -40, 0, 8), Color3.fromRGB(208, 62, 68), Color3.fromRGB(148, 28, 36), 8, { TextSize = 12, ZIndex = 52, Depth = 3 })

	local pmList = Instance.new("Frame")
	pmList.Size = UDim2.new(1, -24, 1, -54)
	pmList.Position = UDim2.fromOffset(12, 46)
	pmList.BackgroundTransparency = 1
	pmList.ZIndex = 52
	pmList.Parent = pmBox
	local pmLay = Instance.new("UIListLayout")
	pmLay.Padding = UDim.new(0, 8)
	pmLay.Parent = pmList
	UI.pmList = pmList
end
SEC.buildLobby()

local function refreshLobbyStats()
	UI.lobbyStatsLbl.Text = "Tổng quái đã hạ: " .. formatNum(saveState.TotalKills) .. "  •  Sao kỹ năng: " .. formatNum(saveState.Stars)
	if UI.permUpgLbl then UI.permUpgLbl.Text = "KỸ NĂNG (" .. formatNum(saveState.Stars) .. ")" end
	if UI.questLbl then
		local readyQ = 0
		for _, q in ipairs(saveState.Quests) do if q.Progress >= q.Goal and not q.Claimed then readyQ += 1 end end
		UI.questLbl.Text = (readyQ > 0) and ("NHIỆM VỤ (" .. readyQ .. ")") or "NHIỆM VỤ"
	end
	for j, mc in ipairs(mapCards) do
		local id = mc.Map.Id
		mc.RecLbl.Text = mc.Map.Endless and string.format("Kỷ lục: Đợt %d\nChế độ Vô Tận", saveState.BestWave[id] or 0) or string.format("Kỷ lục: Đợt %d/%d\nThắng: %d lần", saveState.BestWave[id] or 0, mc.Map.Waves, saveState.Wins[id] or 0)
		local ms = saveState.MapStars[id] or 0
		if mc.Stars then for si = 1, 3 do mc.Stars[si].BackgroundColor3 = (si <= ms) and THEME.TextGold or Color3.fromRGB(64, 70, 96) end end
		mc.Stroke.Color = (j == saveState.SelectedMap) and THEME.TextGold or Color3.fromRGB(76, 86, 134)
		mc.Stroke.Thickness = (j == saveState.SelectedMap) and 3.0 or 2.2
	end
end
refreshLobbyStats()

-- ============================================================
-- XAY DUNG MAN CHOI (BAN CO 14x9 + BANG CHON 5 THAP + NANG CAP)
-- ============================================================
local popupBuildBtns = {}
function SEC.buildGameUI()
	-- Ban co 560x360 can giua dep mat (khong con cot thap ben ngoai)
	local board = Instance.new("Frame")
	board.Size = UDim2.fromOffset(COLS * CELL, ROWS * CELL)
	board.Position = UDim2.fromOffset(82, 4)
	board.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
	board.BorderSizePixel = 0
	board.ClipsDescendants = true
	board.ZIndex = 4
	board.Parent = gamePage
	addCorner(board, 10)
	addStroke(board, Color3.fromRGB(92, 74, 168), 2.2)
	UI.board = board

	-- Bang Ky Nang ben trai ban co (tan dung khoang trong 76x360)
	local leftHud = Instance.new("Frame")
	leftHud.Size = UDim2.fromOffset(76, 360)
	leftHud.Position = UDim2.fromOffset(0, 4)
	leftHud.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	leftHud.BorderSizePixel = 0
	leftHud.ZIndex = 5
	leftHud.Parent = gamePage
	addCorner(leftHud, 10)
	addStroke(leftHud, Color3.fromRGB(78, 72, 146), 1.6)
	addGradient(leftHud, Color3.fromRGB(30, 34, 66), Color3.fromRGB(16, 18, 36), 90)

	local lhTitle = Instance.new("TextLabel")
	lhTitle.Size = UDim2.new(1, 0, 0, 24)
	lhTitle.Position = UDim2.fromOffset(0, 6)
	lhTitle.BackgroundTransparency = 1
	lhTitle.Text = "KỸ NĂNG"
	lhTitle.TextColor3 = THEME.TextGold
	lhTitle.Font = THEME.FontHead
	lhTitle.TextSize = 10
	lhTitle.ZIndex = 6
	lhTitle.Parent = leftHud

	-- 4 Nut Ky Nang hinh tron bong 3D (tham khao anh mau)
	local function makeSkillOrb(yPos, labelTxt, c1, c2, iconKind)
		local orb, _, face = makeArcadeBtn(
			leftHud, "",
			UDim2.fromOffset(52, 52), UDim2.fromOffset(12, yPos),
			c1, c2, 26, { ZIndex = 6, Depth = 3, Stroke = 2.0 }
		)
		GFX.makeIcon(face, iconKind, 24, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), 9)
		local cap = Instance.new("TextLabel")
		cap.Size = UDim2.fromOffset(72, 24)
		cap.Position = UDim2.fromOffset(2, yPos + 53)
		cap.BackgroundTransparency = 1
		cap.Text = labelTxt
		cap.TextColor3 = THEME.TextMain
		cap.Font = THEME.FontHead
		cap.TextSize = 8
		cap.TextWrapped = true
		cap.ZIndex = 6
		cap.Parent = leftHud
		addTextOutline(cap, 1.2, THEME.Outline)
		return orb, cap
	end

	UI.skillBtn, UI.skillLbl = makeSkillOrb(28,  "THIÊN THẠCH", Color3.fromRGB(224, 96, 46),  Color3.fromRGB(154, 34, 32),  "meteor")
	UI.blizBtn,  UI.blizLbl  = makeSkillOrb(108, "BÃO TUYẾT",   Color3.fromRGB(54, 178, 228), Color3.fromRGB(28, 96, 178),  "snow")
	UI.healBtn,  UI.healLbl  = makeSkillOrb(188, "HỒI THÀNH",   Color3.fromRGB(64, 202, 92),  Color3.fromRGB(28, 136, 54),  "heal")
	UI.trapBtn,  UI.trapLbl  = makeSkillOrb(268, "BẪY: TẮT",    Color3.fromRGB(154, 76, 214), Color3.fromRGB(88, 36, 158),  "trap")

	-- Bang Thong Ke Sat Thuong truc tiep ben phai ban co (76x360)
	local rightHud = Instance.new("Frame")
	rightHud.Size = UDim2.fromOffset(76, 360)
	rightHud.Position = UDim2.fromOffset(648, 4)
	rightHud.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	rightHud.BorderSizePixel = 0
	rightHud.ZIndex = 5
	rightHud.Parent = gamePage
	addCorner(rightHud, 10)
	addStroke(rightHud, Color3.fromRGB(78, 72, 146), 1.6)
	addGradient(rightHud, Color3.fromRGB(30, 34, 66), Color3.fromRGB(16, 18, 36), 90)

	local rhTitle = Instance.new("TextLabel")
	rhTitle.Size = UDim2.new(1, 0, 0, 24)
	rhTitle.Position = UDim2.fromOffset(0, 6)
	rhTitle.BackgroundTransparency = 1
	rhTitle.Text = "SÁT THƯƠNG"
	rhTitle.TextColor3 = THEME.TextCyan
	rhTitle.Font = THEME.FontHead
	rhTitle.TextSize = 9
	rhTitle.ZIndex = 6
	rhTitle.Parent = rightHud

	local dmgListLbl = Instance.new("TextLabel")
	dmgListLbl.Size = UDim2.new(1, -8, 1, -36)
	dmgListLbl.Position = UDim2.fromOffset(4, 32)
	dmgListLbl.BackgroundTransparency = 1
	dmgListLbl.Text = "Chưa có\nsát thương"
	dmgListLbl.TextColor3 = THEME.TextMain
	dmgListLbl.Font = THEME.FontBody
	dmgListLbl.TextSize = 9
	dmgListLbl.TextYAlignment = Enum.TextYAlignment.Top
	dmgListLbl.TextWrapped = true
	dmgListLbl.ZIndex = 6
	dmgListLbl.Parent = rightHud
	UI.dmgListLbl = dmgListLbl

	local tileLayer = Instance.new("Frame")
	tileLayer.Size = UDim2.fromScale(1, 1)
	tileLayer.BackgroundTransparency = 1
	tileLayer.ZIndex = 5
	tileLayer.Parent = board
	UI.tileLayer = tileLayer

	local trapLayer = Instance.new("Frame")
	trapLayer.Size = UDim2.fromScale(1, 1)
	trapLayer.BackgroundTransparency = 1
	trapLayer.ZIndex = 8
	trapLayer.Parent = board
	UI.trapLayer = trapLayer

	-- Khung vien vang danh dau o dat dang chon de xay thap
	local tileMarker = Instance.new("Frame")
	tileMarker.Size = UDim2.fromOffset(CELL - 2, CELL - 2)
	tileMarker.AnchorPoint = Vector2.new(0.5, 0.5)
	tileMarker.BackgroundColor3 = THEME.TextGold
	tileMarker.BackgroundTransparency = 0.78
	tileMarker.BorderSizePixel = 0
	tileMarker.Visible = false
	tileMarker.ZIndex = 9
	tileMarker.Parent = board
	addCorner(tileMarker, 6)
	addStroke(tileMarker, THEME.TextGold, 2.2)
	UI.tileMarker = tileMarker

	local rangeRing = Instance.new("Frame")
	rangeRing.AnchorPoint = Vector2.new(0.5, 0.5)
	rangeRing.BackgroundColor3 = Color3.fromRGB(96, 192, 224)
	rangeRing.BackgroundTransparency = 0.84
	rangeRing.BorderSizePixel = 0
	rangeRing.Visible = false
	rangeRing.ZIndex = 8
	rangeRing.Parent = board
	addCorner(rangeRing, 999)
	addStroke(rangeRing, Color3.fromRGB(118, 212, 232), 1.6)
	UI.rangeRing = rangeRing

	local towerLayer = Instance.new("Frame")
	towerLayer.Size = UDim2.fromScale(1, 1)
	towerLayer.BackgroundTransparency = 1
	towerLayer.ZIndex = 10
	towerLayer.Parent = board
	UI.towerLayer = towerLayer

	local enemyLayer = Instance.new("Frame")
	enemyLayer.Size = UDim2.fromScale(1, 1)
	enemyLayer.BackgroundTransparency = 1
	enemyLayer.ZIndex = 14
	enemyLayer.Parent = board
	UI.enemyLayer = enemyLayer

	local fxLayer = Instance.new("Frame")
	fxLayer.Size = UDim2.fromScale(1, 1)
	fxLayer.BackgroundTransparency = 1
	fxLayer.ZIndex = 22
	fxLayer.Parent = board
	UI.fxLayer = fxLayer

	-- POPUP CHON 5 TOA THAP KHI BAM VAO VUNG DAT TRONG
	local buildPopup = Instance.new("Frame")
	buildPopup.Size = UDim2.fromOffset(430, 86)
	buildPopup.BackgroundColor3 = Color3.fromRGB(20, 24, 46)
	buildPopup.BorderSizePixel = 0
	buildPopup.Visible = false
	buildPopup.ZIndex = 34
	buildPopup.Parent = board
	addCorner(buildPopup, 12)
	addStroke(buildPopup, THEME.TextGold, 2.2)
	addGradient(buildPopup, Color3.fromRGB(34, 38, 72), Color3.fromRGB(18, 20, 40), 90)
	UI.buildPopup = buildPopup

	local bpTitle = Instance.new("TextLabel")
	bpTitle.Size = UDim2.new(1, -28, 0, 16)
	bpTitle.Position = UDim2.fromOffset(8, 3)
	bpTitle.BackgroundTransparency = 1
	bpTitle.Text = "CHỌN THÁP ĐỂ XÂY"
	bpTitle.TextColor3 = THEME.TextGold
	bpTitle.Font = THEME.FontHead
	bpTitle.TextSize = 10
	bpTitle.TextXAlignment = Enum.TextXAlignment.Left
	bpTitle.ZIndex = 35
	bpTitle.Parent = buildPopup

	local bpClose = makeArcadeBtn(
		buildPopup, "X",
		UDim2.fromOffset(20, 18), UDim2.new(1, -24, 0, 2),
		Color3.fromRGB(204, 62, 68), Color3.fromRGB(142, 28, 36), 6,
		{ TextSize = 10, ZIndex = 35, Depth = 2, Stroke = 1.4 }
	)
	UI.bpClose = bpClose

	for i, td in ipairs(TOWERS) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(56, 60)
		b.Position = UDim2.fromOffset(8 + (i - 1) * 60, 21)
		b.BackgroundColor3 = Color3.fromRGB(28, 34, 62)
		b.Text = ""
		b.AutoButtonColor = false
		b.BorderSizePixel = 0
		b.ZIndex = 35
		b.Parent = buildPopup
		addCorner(b, 8)
		local st = addStroke(b, Color3.fromRGB(78, 92, 146), 1.6)

		local iconBox = Instance.new("Frame")
		iconBox.Size = UDim2.fromOffset(30, 30)
		iconBox.Position = UDim2.new(0.5, 0, 0, 17)
		iconBox.AnchorPoint = Vector2.new(0.5, 0.5)
		iconBox.BackgroundTransparency = 1
		iconBox.ZIndex = 36
		iconBox.Parent = b
		GFX.buildTowerSprite(iconBox, td, 26, 36)

		local nm = Instance.new("TextLabel")
		nm.Size = UDim2.new(1, -2, 0, 13)
		nm.Position = UDim2.fromOffset(1, 32)
		nm.BackgroundTransparency = 1
		nm.Text = td.Name
		nm.TextColor3 = THEME.TextMain
		nm.Font = THEME.FontHead
		nm.TextSize = 8
		nm.TextTruncate = Enum.TextTruncate.AtEnd
		nm.ZIndex = 36
		nm.Parent = b

		local pr = Instance.new("TextLabel")
		pr.Size = UDim2.new(1, -2, 0, 13)
		pr.Position = UDim2.fromOffset(1, 45)
		pr.BackgroundTransparency = 1
		pr.Text = tostring(td.Cost) .. "V"
		pr.TextColor3 = THEME.TextGold
		pr.Font = THEME.FontHead
		pr.TextSize = 10
		pr.ZIndex = 36
		pr.Parent = b

		popupBuildBtns[i] = { Btn = b, Stroke = st, PriceLbl = pr, Def = td }
	end

	-- POPUP NANG CAP + NHANH TIEN HOA CAP 3 + MUC TIEU + BAN THAP
	local upgradePopup = Instance.new("Frame")
	upgradePopup.Size = UDim2.fromOffset(266, 108)
	upgradePopup.BackgroundColor3 = Color3.fromRGB(20, 24, 46)
	upgradePopup.BorderSizePixel = 0
	upgradePopup.Visible = false
	upgradePopup.ZIndex = 34
	upgradePopup.Parent = board
	addCorner(upgradePopup, 12)
	addStroke(upgradePopup, THEME.TextCyan, 2.2)
	addGradient(upgradePopup, Color3.fromRGB(34, 38, 72), Color3.fromRGB(18, 20, 40), 90)
	UI.upgradePopup = upgradePopup

	local upTitle = Instance.new("TextLabel")
	upTitle.Size = UDim2.new(1, -30, 0, 18)
	upTitle.Position = UDim2.fromOffset(8, 4)
	upTitle.BackgroundTransparency = 1
	upTitle.Text = "Cung Thủ Cấp 1"
	upTitle.TextColor3 = THEME.TextGold
	upTitle.Font = THEME.FontHead
	upTitle.TextSize = 11
	upTitle.TextXAlignment = Enum.TextXAlignment.Left
	upTitle.ZIndex = 35
	upTitle.Parent = upgradePopup
	UI.upTitle = upTitle

	local upStats = Instance.new("TextLabel")
	upStats.Size = UDim2.new(1, -16, 0, 14)
	upStats.Position = UDim2.fromOffset(8, 21)
	upStats.BackgroundTransparency = 1
	upStats.Text = "ST: 22  •  Tầm: 128"
	upStats.TextColor3 = THEME.TextMuted
	upStats.Font = THEME.FontBody
	upStats.TextSize = 10
	upStats.TextXAlignment = Enum.TextXAlignment.Left
	upStats.ZIndex = 35
	upStats.Parent = upgradePopup
	UI.upStats = upStats

	local upClose = makeArcadeBtn(
		upgradePopup, "X",
		UDim2.fromOffset(20, 18), UDim2.new(1, -24, 0, 3),
		Color3.fromRGB(204, 62, 68), Color3.fromRGB(142, 28, 36), 6,
		{ TextSize = 10, ZIndex = 35, Depth = 2, Stroke = 1.4 }
	)
	UI.upClose = upClose

	local upgBtn, upgLbl = makeArcadeBtn(
		upgradePopup, "NÂNG CẤP",
		UDim2.fromOffset(250, 28), UDim2.fromOffset(8, 38),
		Color3.fromRGB(64, 188, 96), Color3.fromRGB(28, 132, 58), 8,
		{ TextSize = 10, ZIndex = 35, Depth = 3, Stroke = 1.6 }
	)
	UI.upgBtn = upgBtn
	UI.upgLbl = upgLbl

	-- 2 nhanh tien hoa khi nang tu Cap 2 len Cap 3
	local evoABtn, evoALbl = makeArcadeBtn(
		upgradePopup, "HỦY DIỆT",
		UDim2.fromOffset(122, 28), UDim2.fromOffset(8, 38),
		Color3.fromRGB(214, 96, 48), Color3.fromRGB(154, 42, 32), 8,
		{ TextSize = 9, ZIndex = 35, Depth = 3, Stroke = 1.5 }
	)
	evoABtn.Visible = false
	UI.evoABtn = evoABtn
	UI.evoALbl = evoALbl

	local evoBBtn, evoBLbl = makeArcadeBtn(
		upgradePopup, "SIÊU TỐC",
		UDim2.fromOffset(122, 28), UDim2.fromOffset(136, 38),
		Color3.fromRGB(54, 152, 218), Color3.fromRGB(30, 88, 174), 8,
		{ TextSize = 9, ZIndex = 35, Depth = 3, Stroke = 1.5 }
	)
	evoBBtn.Visible = false
	UI.evoBBtn = evoBBtn
	UI.evoBLbl = evoBLbl

	local targetBtn, targetLbl = makeArcadeBtn(
		upgradePopup, "Mục tiêu: Xa nhất",
		UDim2.fromOffset(146, 28), UDim2.fromOffset(8, 72),
		Color3.fromRGB(108, 74, 186), Color3.fromRGB(66, 38, 134), 8,
		{ TextSize = 10, ZIndex = 35, Depth = 3, Stroke = 1.5 }
	)
	UI.targetBtn = targetBtn
	UI.targetLbl = targetLbl

	local sellBtn, sellLbl = makeArcadeBtn(
		upgradePopup, "BÁN",
		UDim2.fromOffset(98, 28), UDim2.fromOffset(160, 72),
		Color3.fromRGB(206, 72, 76), Color3.fromRGB(146, 34, 42), 8,
		{ TextSize = 10, ZIndex = 35, Depth = 3, Stroke = 1.5 }
	)
	UI.sellBtn = sellBtn
	UI.sellLbl = sellLbl

	-- Thanh mau Boss lon tren cung ban co (hien khi Boss xuat hien)
	local bossBarBg = Instance.new("Frame")
	bossBarBg.Size = UDim2.fromOffset(320, 26)
	bossBarBg.Position = UDim2.new(0.5, 0, 0, 8)
	bossBarBg.AnchorPoint = Vector2.new(0.5, 0)
	bossBarBg.BackgroundColor3 = Color3.fromRGB(22, 16, 34)
	bossBarBg.BorderSizePixel = 0
	bossBarBg.Visible = false
	bossBarBg.ZIndex = 36
	bossBarBg.Parent = board
	addCorner(bossBarBg, 8)
	addStroke(bossBarBg, THEME.TextGold, 2)
	UI.bossBarBg = bossBarBg

	local bossBarFill = Instance.new("Frame")
	bossBarFill.Size = UDim2.fromScale(1, 1)
	bossBarFill.BackgroundColor3 = Color3.fromRGB(204, 46, 74)
	bossBarFill.BorderSizePixel = 0
	bossBarFill.ZIndex = 37
	bossBarFill.Parent = bossBarBg
	addCorner(bossBarFill, 8)
	addGradient(bossBarFill, Color3.fromRGB(228, 62, 92), Color3.fromRGB(142, 22, 54), 90)
	UI.bossBarFill = bossBarFill

	local bossBarLbl = Instance.new("TextLabel")
	bossBarLbl.Size = UDim2.fromScale(1, 1)
	bossBarLbl.BackgroundTransparency = 1
	bossBarLbl.Text = "BOSS"
	bossBarLbl.TextColor3 = THEME.TextMain
	bossBarLbl.Font = THEME.FontHead
	bossBarLbl.TextSize = 11
	bossBarLbl.ZIndex = 38
	bossBarLbl.Parent = bossBarBg
	addTextOutline(bossBarLbl, 1.5, THEME.Outline)
	UI.bossBarLbl = bossBarLbl

	-- Thanh duoi (724x38): Huong dan + Nut Thien Thach + Nut Goi Dot
	local botBar = Instance.new("Frame")
	botBar.Size = UDim2.fromOffset(724, 38)
	botBar.Position = UDim2.fromOffset(0, 368)
	botBar.BackgroundColor3 = Color3.fromRGB(22, 26, 48)
	botBar.BorderSizePixel = 0
	botBar.ZIndex = 6
	botBar.Parent = gamePage
	addCorner(botBar, 10)
	addStroke(botBar, Color3.fromRGB(82, 72, 148), 1.6)

	local infoLbl = Instance.new("TextLabel")
	infoLbl.Size = UDim2.fromOffset(316, 36)
	infoLbl.Position = UDim2.fromOffset(12, 1)
	infoLbl.BackgroundTransparency = 1
	infoLbl.Text = "Chạm ô cỏ để xây tháp  •  Chạm tháp để nâng cấp"
	infoLbl.TextColor3 = THEME.TextMain
	infoLbl.Font = THEME.FontBody
	infoLbl.TextSize = 11
	infoLbl.TextXAlignment = Enum.TextXAlignment.Left
	infoLbl.ZIndex = 7
	infoLbl.Parent = botBar
	UI.botInfoLbl = infoLbl

	local matchBagBtn, _, matchBagFace = makeArcadeBtn(
		botBar, "KHO ĐỒ",
		UDim2.fromOffset(96, 30), UDim2.new(1, -382, 0, 4),
		Color3.fromRGB(218, 122, 42), Color3.fromRGB(164, 68, 22), 8,
		{ TextSize = 10, ZIndex = 8, Depth = 3, Stroke = 1.5, LabelPos = UDim2.fromOffset(10, 0), LabelSize = UDim2.new(1, -12, 1, 0) }
	)
	GFX.makeIcon(matchBagFace, "bag", 15, UDim2.new(0, 14, 0.5, 0), Vector2.new(0.5, 0.5), 11)
	UI.matchBagBtn = matchBagBtn

	local autoBtn, autoLbl = makeArcadeBtn(
		botBar, "TỰ GỌI: TẮT",
		UDim2.fromOffset(132, 30), UDim2.new(1, -280, 0, 4),
		Color3.fromRGB(78, 86, 122), Color3.fromRGB(48, 54, 82), 8,
		{ TextSize = 10, ZIndex = 8, Depth = 3, Stroke = 1.5 }
	)
	UI.autoBtn = autoBtn
	UI.autoLbl = autoLbl

	local waveBtn, waveBtnLbl, waveFace = makeArcadeBtn(
		botBar, "GỌI ĐỢT 1",
		UDim2.fromOffset(136, 30), UDim2.new(1, -142, 0, 4),
		Color3.fromRGB(64, 194, 88), Color3.fromRGB(28, 134, 54), 8,
		{ TextSize = 11, ZIndex = 8, Depth = 3, Stroke = 1.5, LabelPos = UDim2.fromOffset(10, 0), LabelSize = UDim2.new(1, -14, 1, 0) }
	)
	GFX.makeIcon(waveFace, "play", 16, UDim2.new(0, 15, 0.5, 0), Vector2.new(0.5, 0.5), 11)
	UI.waveBtn = waveBtn
	UI.waveBtnLbl = waveBtnLbl

	-- Bang Ket Thuc (Thang / Thua)
	local endCard = Instance.new("Frame")
	endCard.Size = UDim2.fromOffset(330, 194)
	endCard.Position = UDim2.fromScale(0.5, 0.5)
	endCard.AnchorPoint = Vector2.new(0.5, 0.5)
	endCard.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	endCard.BorderSizePixel = 0
	endCard.Visible = false
	endCard.ZIndex = 45
	endCard.Parent = board
	addCorner(endCard, 14)
	UI.endStroke = addStroke(endCard, THEME.TextGold, 2.6)
	UI.endCard = endCard

	local endTitle = Instance.new("TextLabel")
	endTitle.Size = UDim2.new(1, 0, 0, 34)
	endTitle.Position = UDim2.fromOffset(0, 14)
	endTitle.BackgroundTransparency = 1
	endTitle.Text = "CHIẾN THẮNG!"
	endTitle.TextColor3 = THEME.TextGold
	endTitle.Font = THEME.FontHead
	endTitle.TextSize = 20
	endTitle.ZIndex = 46
	endTitle.Parent = endCard
	addTextOutline(endTitle, 2, THEME.Outline)
	UI.endTitle = endTitle

	local endDesc = Instance.new("TextLabel")
	endDesc.Size = UDim2.new(1, -24, 0, 56)
	endDesc.Position = UDim2.fromOffset(12, 54)
	endDesc.BackgroundTransparency = 1
	endDesc.Text = ""
	endDesc.TextColor3 = THEME.TextMain
	endDesc.Font = THEME.FontBody
	endDesc.TextSize = 13
	endDesc.TextWrapped = true
	endDesc.ZIndex = 46
	endDesc.Parent = endCard
	UI.endDesc = endDesc

	UI.endReplayBtn = makeArcadeBtn(endCard, "CHƠI LẠI", UDim2.fromOffset(136, 40), UDim2.fromOffset(22, 134), Color3.fromRGB(64, 198, 86), Color3.fromRGB(28, 136, 52), 10, { TextSize = 13, ZIndex = 47, Depth = 4 })
	UI.endHomeBtn   = makeArcadeBtn(endCard, "VỀ SẢNH",  UDim2.fromOffset(136, 40), UDim2.fromOffset(172, 134), Color3.fromRGB(142, 72, 208), Color3.fromRGB(88, 36, 162), 10, { TextSize = 13, ZIndex = 47, Depth = 4 })
end
SEC.buildGameUI()

-- ============================================================
-- LOGIC GAME THU THANH 2D + HOAT ANH CHIEN DAU
-- ============================================================
local TD = {
	active = false,
	paused = false,
	over = false,
	speedMult = 1,
	map = MAPS[1],
	gold = 240,
	lives = 20,
	maxLives = 20,
	wave = 0,
	kills = 0,
	waveSpawning = false,
	spawnQueue = {},
	spawnTimer = 0,
	skillCd = 0,
	blizCd = 0,
	healCd = 0,
	dmgByTower = {},
	pendingCell = nil,
	selectedTower = nil,
	pathCells = {},
	pathPoints = {},
	towers = {},
	enemies = {},
	projectiles = {},
	obstacles = {},
	traps = {},
	trapMode = "none",
	autoWave = false,
	autoTimer = 0,
	shakeTime = 0,
}

local function addQuestProg(qId, amt)
	for _, q in ipairs(saveState.Quests) do
		if q.Id == qId and not q.Claimed then
			q.Progress = math.min(q.Goal, q.Progress + amt)
		end
	end
end

local function cellCenter(gx, gy)
	return (gx - 0.5) * CELL, (gy - 0.5) * CELL
end

local function spawnFloatingText(x, y, text, col)
	if saveState.LowFx then return end
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(80, 18)
	lbl.Position = UDim2.fromOffset(x, y - 10)
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = col or THEME.TextGold
	lbl.Font = THEME.FontHead
	lbl.TextSize = 11
	lbl.ZIndex = 28
	lbl.Parent = UI.fxLayer
	addTextOutline(lbl, 1.3, THEME.Outline)
	local tw = TweenService:Create(lbl, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(x, y - 34),
		TextTransparency = 1
	})
	tw:Play()
	tw.Completed:Connect(function() if lbl.Parent then lbl:Destroy() end end)
end

local function spawnExplosionRing(x, y, radius, col)
	if saveState.LowFx and radius < 40 then return end
	local ring = Instance.new("Frame")
	ring.Size = UDim2.fromOffset(10, 10)
	ring.Position = UDim2.fromOffset(x, y)
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.BackgroundColor3 = col
	ring.BackgroundTransparency = 0.45
	ring.BorderSizePixel = 0
	ring.ZIndex = 24
	ring.Parent = UI.fxLayer
	addCorner(ring, 999)
	addStroke(ring, col, 2)
	local tw = TweenService:Create(ring, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(radius * 2, radius * 2),
		BackgroundTransparency = 1
	})
	tw:Play()
	tw.Completed:Connect(function() if ring.Parent then ring:Destroy() end end)
end

local function spawnBeamLine(x1, y1, x2, y2, col, thick, dur)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 2 then return end
	local beam = Instance.new("Frame")
	beam.Size = UDim2.fromOffset(len, thick or 4)
	beam.Position = UDim2.fromOffset((x1 + x2) * 0.5, (y1 + y2) * 0.5)
	beam.AnchorPoint = Vector2.new(0.5, 0.5)
	beam.Rotation = math.deg(math.atan2(dy, dx))
	beam.BackgroundColor3 = col
	beam.BorderSizePixel = 0
	beam.ZIndex = 25
	beam.Parent = UI.fxLayer
	addCorner(beam, 99)
	local tw = TweenService:Create(beam, TweenInfo.new(dur or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(len, 1)
	})
	tw:Play()
	tw.Completed:Connect(function() if beam.Parent then beam:Destroy() end end)
end

local function spawnDeathParticles(x, y, col)
	if saveState.LowFx then return end
	for _ = 1, 5 do
		local p = Instance.new("Frame")
		p.Size = UDim2.fromOffset(6, 6)
		p.Position = UDim2.fromOffset(x, y)
		p.AnchorPoint = Vector2.new(0.5, 0.5)
		p.BackgroundColor3 = col
		p.BorderSizePixel = 0
		p.ZIndex = 26
		p.Parent = UI.fxLayer
		addCorner(p, 99)
		local ang = math.rad(math.random(0, 359))
		local dist = math.random(14, 28)
		local tw = TweenService:Create(p, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(x + math.cos(ang) * dist, y + math.sin(ang) * dist),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(2, 2)
		})
		tw:Play()
		tw.Completed:Connect(function() if p.Parent then p:Destroy() end end)
	end
end

local function positionPopupNear(popup, cx, cy, pw, ph)
	local boardW, boardH = COLS * CELL, ROWS * CELL
	local px = math.clamp(cx - pw * 0.5, 6, boardW - pw - 6)
	local py = cy - ph - 26
	if py < 6 then
		py = cy + 26
	end
	py = math.clamp(py, 6, boardH - ph - 6)
	popup.Position = UDim2.fromOffset(px, py)
end

local function closeBoardPopups()
	TD.pendingCell = nil
	TD.selectedTower = nil
	UI.buildPopup.Visible = false
	UI.upgradePopup.Visible = false
	UI.tileMarker.Visible = false
	UI.rangeRing.Visible = false
end

local function updateHUD()
	local curL, maxL = math.max(0, TD.lives), math.max(1, TD.maxLives)
	UI.livesLbl.Text = tostring(curL) .. "/" .. tostring(maxL)
	if UI.livesBarFill then UI.livesBarFill.Size = UDim2.fromScale(math.clamp(curL / maxL, 0, 1), 1) end
	UI.goldLbl.Text  = formatNum(TD.gold)
	UI.waveLbl.Text  = TD.map.Endless and (tostring(TD.wave) .. " (∞)") or (tostring(TD.wave) .. "/" .. tostring(TD.map.Waves))
	UI.spdLbl.Text   = tostring(TD.speedMult) .. "x"

	if TD.pendingCell then
		local cx, cy = cellCenter(TD.pendingCell.gx, TD.pendingCell.gy)
		UI.tileMarker.Visible = true
		UI.tileMarker.Position = UDim2.fromOffset(cx, cy)
		UI.buildPopup.Visible = true
		positionPopupNear(UI.buildPopup, cx, cy, 430, 86)
		for _, pb in ipairs(popupBuildBtns) do
			local afford = (TD.gold >= pb.Def.Cost)
			pb.Stroke.Color = afford and THEME.TextGold or Color3.fromRGB(118, 52, 58)
			pb.PriceLbl.TextColor3 = afford and THEME.TextGold or THEME.TextRed
		end
	else
		UI.tileMarker.Visible = false
		UI.buildPopup.Visible = false
	end

	if TD.selectedTower then
		local t = TD.selectedTower
		local upCost = (t.Level >= 3) and (320 + (t.Level - 2) * 260) or math.floor(t.Def.UpgradeCost * t.Level)
		local sellVal = math.floor(t.Invested * 0.7)
		UI.upgradePopup.Visible = true
		positionPopupNear(UI.upgradePopup, t.X, t.Y, 266, 108)
		local brTxt = t.Branch and (" • " .. t.Branch) or ""
		UI.upTitle.Text = string.format("%s • Cấp %d%s", t.Def.Name, t.Level, brTxt)
		if t.Def.Kind == "Buff" then
			local pct = math.floor((t.BuffDmg or 0.25) * 100)
			UI.upStats.Text = string.format("Tăng +%d%% ST cho tháp • Tầm: %d", pct, math.floor(t.Range))
		else
			UI.upStats.Text = string.format("ST: %d • Tầm: %d • Tốc: %.2fs", math.floor(t.Damage), math.floor(t.Range), t.FireRate)
		end
		if t.Level == 2 and t.Def.Kind ~= "Buff" then
			UI.upgBtn.Visible = false
			UI.evoABtn.Visible = true
			UI.evoBBtn.Visible = true
			UI.evoALbl.Text = "HỦY DIỆT (" .. upCost .. "V)"
			UI.evoBLbl.Text = "SIÊU TỐC (" .. upCost .. "V)"
		else
			UI.upgBtn.Visible = true
			UI.evoABtn.Visible = false
			UI.evoBBtn.Visible = false
			UI.upgLbl.Text = (t.Level < 3) and ("NÂNG CẤP (" .. upCost .. "V)") or ("CƯỜNG HÓA C" .. tostring(t.Level + 1) .. " (" .. formatNum(upCost) .. "V)")
		end
		local mNames = { First = "Xa nhất", Strong = "Máu cao", Weak = "Máu thấp" }
		UI.targetLbl.Text = "Mục tiêu: " .. (mNames[t.TargetMode or "First"] or "Xa nhất")
		UI.sellLbl.Text = "BÁN (+" .. sellVal .. "V)"
		UI.rangeRing.Visible = true
		UI.rangeRing.Position = UDim2.fromOffset(t.X, t.Y)
		UI.rangeRing.Size = UDim2.fromOffset(t.Range * 2, t.Range * 2)
		UI.botInfoLbl.Text = string.format("Đang chọn %s Cấp %d • Chọn nâng cấp hoặc mục tiêu", t.Def.Name, t.Level)
	else
		UI.upgradePopup.Visible = false
		UI.rangeRing.Visible = false
		if TD.pendingCell then
			UI.botInfoLbl.Text = "Chọn 1 trong 7 tòa tháp trên bảng để xây vào ô đất đã chọn"
		else
			UI.botInfoLbl.Text = "Chạm ô cỏ để xây tháp  •  Chạm tháp để nâng cấp"
		end
	end

	if TD.skillCd > 0 then
		UI.skillLbl.Text = string.format("THIÊN THẠCH\n%.0fs", math.ceil(TD.skillCd))
	else
		UI.skillLbl.Text = "THIÊN THẠCH"
	end
	if TD.blizCd > 0 then
		UI.blizLbl.Text = string.format("BÃO TUYẾT\n%.0fs", math.ceil(TD.blizCd))
	else
		UI.blizLbl.Text = "BÃO TUYẾT"
	end
	if TD.healCd > 0 then
		UI.healLbl.Text = string.format("HỒI THÀNH\n%.0fs", math.ceil(TD.healCd))
	else
		UI.healLbl.Text = "HỒI THÀNH"
	end
	local ranked = {}
	for k, v in pairs(TD.dmgByTower) do
		if v > 0 then table.insert(ranked, { Name = k, Dmg = math.floor(v) }) end
	end
	table.sort(ranked, function(a, b) return a.Dmg > b.Dmg end)
	if #ranked > 0 then
		local lines = {}
		for i = 1, math.min(5, #ranked) do
			table.insert(lines, ranked[i].Name .. "\n" .. formatNum(ranked[i].Dmg))
		end
		UI.dmgListLbl.Text = table.concat(lines, "\n\n")
	else
		UI.dmgListLbl.Text = "Chưa có\nsát thương"
	end

	if TD.waveSpawning or #TD.enemies > 0 then
		UI.waveBtnLbl.Text = "ĐANG CHIẾN..."
	elseif (not TD.map.Endless) and TD.wave >= TD.map.Waves then
		UI.waveBtnLbl.Text = "HOÀN THÀNH"
	else
		UI.waveBtnLbl.Text = "GỌI ĐỢT " .. tostring(TD.wave + 1)
	end
end

local function clearMatchLayers()
	for _, ch in ipairs(UI.tileLayer:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.towerLayer:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.enemyLayer:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.trapLayer:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.fxLayer:GetChildren()) do ch:Destroy() end
	TD.towers = {}
	TD.enemies = {}
	TD.projectiles = {}
	TD.obstacles = {}
	TD.traps = {}
	closeBoardPopups()
end

local function finishMatch(won)
	TD.over = true
	TD.active = false
	local mid = TD.map.Id
	if TD.wave > (saveState.BestWave[mid] or 0) then
		saveState.BestWave[mid] = TD.wave
	end
	if won then
		saveState.Wins[mid] = (saveState.Wins[mid] or 0) + 1
		local ratio = TD.lives / math.max(1, TD.maxLives)
		local earnedS = (ratio >= 0.99) and 3 or ((ratio >= 0.5) and 2 or 1)
		if earnedS > (saveState.MapStars[mid] or 0) then saveState.MapStars[mid] = earnedS end
		saveState.Stars += math.floor(15 * (getDiffDef(saveState.Difficulty).StarMult or 1) + 0.5)
		addQuestProg("win", 1)
	end
	saveData()
	UI.endTitle.Text = won and "CHIẾN THẮNG!" or "THẤT THỦ!"
	UI.endTitle.TextColor3 = won and THEME.TextGold or THEME.TextRed
	UI.endStroke.Color = won and THEME.TextGold or THEME.TextRed
	local mvpName, mvpDmg = "Chưa có", 0
	for k, v in pairs(TD.dmgByTower) do if v > mvpDmg then mvpDmg = math.floor(v) mvpName = k end end
	local dfName = getDiffDef(saveState.Difficulty).Name
	UI.endDesc.Text = string.format("%s (%s) • Đợt %d • Hạ: %d\nTháp MVP: %s (%s ST)", TD.map.Name, dfName, TD.wave, TD.kills, mvpName, formatNum(mvpDmg))
	UI.endCard.Visible = true
	updateHUD()
end

local function getTowerAt(gx, gy)
	for _, t in ipairs(TD.towers) do
		if t.GX == gx and t.GY == gy then return t end
	end
	return nil
end

local function buildTowerAt(gx, gy, towerIdx)
	if TD.over or TD.paused then return end
	if TD.pathCells[gx .. "_" .. gy] then return end
	if getTowerAt(gx, gy) then return end
	local def = TOWERS[towerIdx]
	if not def then return end
	if TD.gold < def.Cost then
		showToast("Không đủ vàng để xây " .. def.Name .. " (" .. def.Cost .. "V)!", THEME.TextRed, 2.0)
		return
	end
	TD.gold -= def.Cost
	local cx, cy = cellCenter(gx, gy)
	local holder = Instance.new("TextButton")
	holder.Size = UDim2.fromOffset(CELL, CELL)
	holder.Position = UDim2.fromOffset(cx, cy)
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.BackgroundTransparency = 1
	holder.Text = ""
	holder.ZIndex = 11
	holder.Parent = UI.towerLayer

	local sprite, turret, barrel = GFX.buildTowerSprite(holder, def, CELL - 4, 11)
	local lvTag = Instance.new("TextLabel")
	lvTag.Size = UDim2.fromOffset(22, 12)
	lvTag.Position = UDim2.new(1, -22, 1, -12)
	lvTag.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
	lvTag.BorderSizePixel = 0
	lvTag.Text = "C1"
	lvTag.TextColor3 = THEME.TextGold
	lvTag.Font = THEME.FontHead
	lvTag.TextSize = 9
	lvTag.ZIndex = 16
	lvTag.Parent = holder
	addCorner(lvTag, 4)

	-- Hoat anh dat thap nay len
	sprite.Size = UDim2.fromOffset(10, 10)
	TweenService:Create(sprite, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(CELL - 4, CELL - 4)
	}):Play()

	local dmgMult = 1 + (saveState.Upgrades.dmg or 0) * 0.08
	local tObj = {
		GX = gx, GY = gy, X = cx, Y = cy,
		Def = def, Level = 1, Branch = nil, TargetMode = "First", Invested = def.Cost,
		Damage = def.Damage * dmgMult, Range = def.Range, FireRate = def.FireRate,
		BuffDmg = def.BuffDmg or 0, BuffRate = def.BuffRate or 0,
		Cooldown = 0, Node = holder, Turret = turret, Barrel = barrel, LvTag = lvTag,
	}
	playSfx("upgrade", 1.15)

	addQuestProg("build", 1)
	table.insert(TD.towers, tObj)
	holder.MouseButton1Click:Connect(function()
		TD.pendingCell = nil
		TD.selectedTower = tObj
		updateHUD()
	end)
	closeBoardPopups()
	updateHUD()
end

local function buildMapBoard(mp)
	clearMatchLayers()
	TD.pathCells = {}
	TD.pathPoints = {}
	for _, wp in ipairs(mp.Waypoints) do
		local cx, cy = cellCenter(wp[1], wp[2])
		table.insert(TD.pathPoints, { x = cx, y = cy })
	end
	for w = 1, #mp.Waypoints - 1 do
		local a, b = mp.Waypoints[w], mp.Waypoints[w + 1]
		local dx = (b[1] > a[1]) and 1 or ((b[1] < a[1]) and -1 or 0)
		local dy = (b[2] > a[2]) and 1 or ((b[2] < a[2]) and -1 or 0)
		local cx, cy = a[1], a[2]
		while true do
			TD.pathCells[cx .. "_" .. cy] = true
			if cx == b[1] and cy == b[2] then break end
			cx += dx
			cy += dy
		end
	end

	for x = 1, COLS do
		for y = 1, ROWS do
			local isPath = (TD.pathCells[x .. "_" .. y] == true)
			local tile = Instance.new("TextButton")
			tile.Size = UDim2.fromOffset(CELL, CELL)
			tile.Position = UDim2.fromOffset((x - 1) * CELL, (y - 1) * CELL)
			tile.Text = ""
			tile.AutoButtonColor = false
			tile.BorderSizePixel = 0
			tile.ZIndex = 5
			if isPath then
				tile.BackgroundColor3 = mp.PathCol
				addStroke(tile, mp.PathBorder, 1)
				if (x + y) % 2 == 0 then
					local stone = Instance.new("Frame")
					stone.Size = UDim2.fromOffset(10, 6)
					stone.Position = UDim2.fromScale(0.5, 0.5)
					stone.AnchorPoint = Vector2.new(0.5, 0.5)
					stone.BackgroundColor3 = mp.PathBorder
					stone.BackgroundTransparency = 0.5
					stone.BorderSizePixel = 0
					stone.ZIndex = 6
					stone.Parent = tile
					addCorner(stone, 3)
				end
				tile.MouseButton1Click:Connect(function()
					closeBoardPopups()
					if not TD.over and not TD.paused then
						local tx, ty = cellCenter(x, y)
						if TD.trapMode == "spike" or TD.trapMode == "mine" then
							local trDef = TRAPS[TD.trapMode]
							if TD.gold >= trDef.Cost then
								TD.gold -= trDef.Cost
								local trNode = GFX.buildTrapSprite(UI.trapLayer, trDef.Id, 8)
								trNode.Position = UDim2.fromOffset(tx, ty)
								table.insert(TD.traps, {
									Def = trDef, X = tx, Y = ty, Uses = trDef.Uses, Cd = 0, Node = trNode
								})
								playSfx("upgrade", 1.2)
								spawnExplosionRing(tx, ty, 18, trDef.Color)
							else
								showToast("Cần " .. trDef.Cost .. " Vàng để đặt " .. trDef.Name .. "!", THEME.TextRed, 2.0)
							end
						end
					end
					updateHUD()
				end)
			else
				tile.BackgroundColor3 = ((x + y) % 2 == 0) and mp.Grass1 or mp.Grass2
				if (x * 7 + y * 13) % 5 == 0 then
					local deco = Instance.new("Frame")
					deco.Size = UDim2.fromOffset(6, 6)
					deco.Position = UDim2.fromOffset(8 + ((x * 5) % 20), 8 + ((y * 7) % 20))
					deco.BackgroundColor3 = mp.BossArena and Color3.fromRGB(218, 92, 52) or (mp.Endless and Color3.fromRGB(92, 198, 224) or Color3.fromRGB(98, 178, 92))
					deco.BackgroundTransparency = 0.55
					deco.BorderSizePixel = 0
					deco.ZIndex = 6
					deco.Parent = tile
					addCorner(deco, 99)
				end
				tile.MouseButton1Click:Connect(function()
					if TD.over or TD.paused then return end
					local obKey = x .. "_" .. y
					local ob = TD.obstacles[obKey]
					if ob then
						closeBoardPopups()
						updateHUD()
						showToast("Vật cản thiên nhiên — không thể phá hoặc xây lên!", THEME.TextMuted, 1.8)
						return
					end
					local existing = getTowerAt(x, y)
					if existing then
						TD.pendingCell = nil
						TD.selectedTower = existing
					else
						TD.selectedTower = nil
						TD.pendingCell = { gx = x, gy = y }
					end
					updateHUD()
				end)
			end
			tile.Parent = UI.tileLayer
		end
	end

	-- Sinh chuong ngai vat (cay coi, hon da, nha nho, tinh the) tren cac o co trong
	local freeGrass = {}
	for gx = 1, COLS do
		for gy = 1, ROWS do
			if not TD.pathCells[gx .. "_" .. gy] then
				table.insert(freeGrass, { gx, gy })
			end
		end
	end
	local kinds = mp.BossArena and {"rock", "crystal", "tree", "rock"} or (mp.Id == "desert" and {"rock", "crystal", "house", "tree"} or {"tree", "tree", "tree", "rock", "house"})
	for k = 1, math.min(14, #freeGrass) do
		local pick = table.remove(freeGrass, math.random(1, #freeGrass))
		local ox, oy = pick[1], pick[2]
		local oKind = kinds[((k - 1) % #kinds) + 1]
		local ocx, ocy = cellCenter(ox, oy)
		local obNode = Instance.new("Frame")
		obNode.Size = UDim2.fromOffset(CELL, CELL)
		obNode.Position = UDim2.fromOffset(ocx, ocy)
		obNode.AnchorPoint = Vector2.new(0.5, 0.5)
		obNode.BackgroundTransparency = 1
		obNode.ZIndex = 9
		obNode.Parent = UI.towerLayer
		GFX.buildObstacleSprite(obNode, oKind, 9)
		TD.obstacles[ox .. "_" .. oy] = { GX = ox, GY = oy, Kind = oKind, Node = obNode }
	end

	-- Cong xoan do xuat phat & Thanh tri xanh-vang chi tiet
	local pStart = TD.pathPoints[1]
	local pEnd = TD.pathPoints[#TD.pathPoints]
	local gate = Instance.new("Frame")
	gate.Size = UDim2.fromOffset(34, 34)
	gate.Position = UDim2.fromOffset(pStart.x, pStart.y)
	gate.AnchorPoint = Vector2.new(0.5, 0.5)
	gate.BackgroundColor3 = Color3.fromRGB(54, 58, 72)
	gate.BorderSizePixel = 0
	gate.ZIndex = 7
	gate.Parent = UI.tileLayer
	addCorner(gate, 10)
	addStroke(gate, THEME.Outline, 2.2)

	local vortex = Instance.new("Frame")
	vortex.Size = UDim2.fromOffset(22, 22)
	vortex.Position = UDim2.fromScale(0.5, 0.5)
	vortex.AnchorPoint = Vector2.new(0.5, 0.5)
	vortex.BackgroundColor3 = Color3.fromRGB(218, 42, 58)
	vortex.BorderSizePixel = 0
	vortex.ZIndex = 8
	vortex.Parent = gate
	addCorner(vortex, 7)
	addStroke(vortex, Color3.fromRGB(232, 118, 86), 1.5)
	addGradient(vortex, Color3.fromRGB(232, 68, 72), Color3.fromRGB(112, 16, 32), 45)
	UI.portalVortex = vortex

	local castle = Instance.new("Frame")
	castle.Size = UDim2.fromOffset(36, 36)
	castle.Position = UDim2.fromOffset(pEnd.x, pEnd.y)
	castle.AnchorPoint = Vector2.new(0.5, 0.5)
	castle.BackgroundColor3 = Color3.fromRGB(154, 118, 82)
	castle.BorderSizePixel = 0
	castle.ZIndex = 7
	castle.Parent = UI.tileLayer
	addCorner(castle, 8)
	addStroke(castle, THEME.TextGold, 2.2)
	for _, tx in ipairs({0.2, 0.8}) do
		local spire = Instance.new("Frame")
		spire.Size = UDim2.fromOffset(10, 14)
		spire.Position = UDim2.fromScale(tx, 0.14)
		spire.AnchorPoint = Vector2.new(0.5, 0.5)
		spire.BackgroundColor3 = Color3.fromRGB(48, 142, 214)
		spire.BorderSizePixel = 0
		spire.ZIndex = 8
		spire.Parent = castle
		addCorner(spire, 4)
		addStroke(spire, THEME.Outline, 1.3)
	end
	local cGate = Instance.new("Frame")
	cGate.Size = UDim2.fromOffset(12, 14)
	cGate.Position = UDim2.fromScale(0.5, 0.72)
	cGate.AnchorPoint = Vector2.new(0.5, 0.5)
	cGate.BackgroundColor3 = Color3.fromRGB(82, 48, 28)
	cGate.BorderSizePixel = 0
	cGate.ZIndex = 8
	cGate.Parent = castle
	addCorner(cGate, 5)
	addStroke(cGate, THEME.Outline, 1.2)
end

local function buildWaveQueue(waveNum)
	local q = {}
	local bossPool = { "boss", "cerberus", "lich_boss", "titan_boss", "dark_knight_boss", "phoenix_boss", "hero_boss" }
	if TD.map.Endless then
		local cnt = 7 + math.min(28, waveNum * 2)
		for i = 1, cnt do
			local k = "slime"
			if waveNum >= 2 and i % 4 == 0 then k = "spider"
			elseif waveNum >= 2 and i % 3 == 0 then k = "bat"
			elseif waveNum >= 3 and i % 5 == 0 then k = "skeleton"
			elseif waveNum >= 4 and i % 4 == 1 then k = "scorpion"
			elseif waveNum >= 5 and i % 6 == 0 then k = "orc"
			elseif waveNum >= 7 and i % 7 == 0 then k = "golem" end
			table.insert(q, k)
		end
		if waveNum % 3 == 0 then
			local bIdx = math.min(#bossPool, math.floor(waveNum / 3))
			table.insert(q, bossPool[bIdx])
		end
		return q
	end
	if TD.map.BossArena then
		local escorts = 4 + waveNum
		for i = 1, escorts do
			local k = (i % 4 == 0) and "orc" or ((i % 3 == 0) and "golem" or ((i % 2 == 0) and "scorpion" or "spider"))
			table.insert(q, k)
		end
		if waveNum == TD.map.Waves then
			table.insert(q, "phoenix_boss")
			table.insert(q, "hero_boss")
		elseif waveNum >= 8 then
			table.insert(q, "dark_knight_boss")
			table.insert(q, "phoenix_boss")
		elseif waveNum >= 6 then
			table.insert(q, "lich_boss")
			table.insert(q, "titan_boss")
		elseif waveNum >= 3 then
			table.insert(q, "cerberus")
		else
			table.insert(q, "boss")
		end
		return q
	end
	local count = 6 + waveNum * 2
	for i = 1, count do
		local kind = "slime"
		if waveNum >= 2 and i % 3 == 0 then kind = (i % 2 == 0) and "goblin" or "spider" end
		if waveNum >= 3 and i % 4 == 0 then kind = (i % 2 == 0) and "bat" or "skeleton" end
		if waveNum >= 5 and i % 5 == 0 then kind = (i % 2 == 0) and "knight" or "scorpion" end
		if waveNum >= 7 and i % 6 == 0 then kind = (i % 2 == 0) and "wraith" or "orc" end
		if waveNum >= 9 and i % 7 == 0 then kind = "golem" end
		table.insert(q, kind)
	end
	if waveNum % 5 == 0 or waveNum == TD.map.Waves then
		local bIdx = math.clamp(math.floor(waveNum / 4) + 1, 1, #bossPool)
		if waveNum == TD.map.Waves then bIdx = math.min(#bossPool, bIdx + 1) end
		table.insert(q, bossPool[bIdx])
	end
	return q
end

local function startNextWave()
	if TD.over or TD.paused or TD.waveSpawning or #TD.enemies > 0 then return end
	if TD.wave >= TD.map.Waves then return end
	TD.wave += 1
	TD.spawnQueue = buildWaveQueue(TD.wave)
	TD.waveSpawning = true
	TD.spawnTimer = 0.2
	local isBoss = (TD.wave % 5 == 0 or TD.wave == TD.map.Waves)
	showToast(isBoss and ("CẢNH BÁO BOSS ĐỢT " .. TD.wave .. "!") or ("Đợt quái " .. TD.wave .. " đang tiến vào!"), isBoss and THEME.TextRed or THEME.TextCyan, 2.2)
	updateHUD()
end

local function spawnEnemy(kind)
	local def = ENEMIES[kind] or ENEMIES.slime
	local diffDef = getDiffDef(saveState.Difficulty)
	local scaleHP = (1 + (TD.wave - 1) * 0.24) * (diffDef.HpMult or 1.0)
	local isElite = (TD.wave >= 15 and not def.Boss and math.random(1, 4) == 1)
	local maxHp = math.max(10, math.floor(def.HP * scaleHP * (isElite and 1.65 or 1.0)))
	local p0 = TD.pathPoints[1]
	local node, body, hpFill, frostCoat, wingL, wingR, bodyStroke = GFX.buildEnemySprite(UI.enemyLayer, def, kind, 15)
	if isElite and bodyStroke then bodyStroke.Color = Color3.fromRGB(224, 92, 224) bodyStroke.Thickness = 2.4 end
	node.Position = UDim2.fromOffset(p0.x, p0.y)
	table.insert(TD.enemies, {
		Kind = kind, Def = def, Elite = isElite, HP = maxHp, MaxHP = maxHp,
		X = p0.x, Y = p0.y, WpIdx = 2, Progress = 0,
		SlowTimer = 0, SlowFactor = 1, PoisonTimer = 0, PoisonDps = 0, HitFlash = 0, BobPhase = math.random() * 6, SkillCd = 5.5,
		Node = node, Body = body, HpFill = hpFill, FrostCoat = frostCoat,
		WingL = wingL, WingR = wingR, Dead = false
	})
end

local function damageEnemy(e, dmg, slowFrac, slowDur, poisonDps, poisonDur, srcName)
	if e.Dead then return end
	local actual = math.min(e.HP, dmg)
	if srcName and actual > 0 then
		TD.dmgByTower[srcName] = (TD.dmgByTower[srcName] or 0) + actual
	end
	e.HP -= dmg
	e.HitFlash = 0.10
	if slowFrac and slowDur and not e.Elite then
		e.SlowFactor = math.min(e.SlowFactor, 1 - slowFrac)
		e.SlowTimer = math.max(e.SlowTimer, slowDur)
	end
	if poisonDps and poisonDur then
		e.PoisonDps = math.max(e.PoisonDps, poisonDps)
		e.PoisonTimer = math.max(e.PoisonTimer, poisonDur)
	end
	if e.HP <= 0 then
		e.Dead = true
		TD.gold += e.Def.Reward
		TD.kills += 1
		saveState.TotalKills += 1
		addQuestProg("kills", 1)
		if e.Def.Boss then
			local bStars = math.max(5, math.floor(5 * (getDiffDef(saveState.Difficulty).StarMult or 1) + 0.5))
			saveState.Stars += bStars
			addQuestProg("boss", 1)
			spawnFloatingText(e.X, e.Y - 14, "+" .. bStars .. " Sao", THEME.TextPurple)
		end
		playSfx("kill", 1.1)
		spawnDeathParticles(e.X, e.Y, e.Def.Color)
		spawnFloatingText(e.X, e.Y, "+" .. tostring(e.Def.Reward) .. "V", THEME.TextGold)
		if e.Node and e.Node.Parent then e.Node:Destroy() end
		updateHUD()
	else
		e.HpFill.Size = UDim2.fromScale(math.clamp(e.HP / e.MaxHP, 0, 1), 1)
	end
end

local function getTowerBuffMults(t)
	local dmgBonus, rateBonus = 0, 0
	for _, other in ipairs(TD.towers) do
		if other.Def.Kind == "Buff" and other ~= t then
			local d = math.sqrt((other.X - t.X)^2 + (other.Y - t.Y)^2)
			if d <= other.Range then
				dmgBonus = math.max(dmgBonus, other.BuffDmg or 0.25)
				rateBonus = math.max(rateBonus, other.BuffRate or 0.20)
			end
		end
	end
	return 1 + dmgBonus, 1 - rateBonus
end

local function fireTower(t, target, effDmg)
	local dmg = effDmg or t.Damage
	if not saveState.LowFx then
		for _, ob in ipairs(TD.towers) do
			if ob.Def.Kind == "Buff" and math.sqrt((ob.X - t.X)^2 + (ob.Y - t.Y)^2) <= ob.Range then
				spawnBeamLine(ob.X, ob.Y, t.X, t.Y, THEME.TextGold, 1.5, 0.10)
				break
			end
		end
	end
	local ang = math.deg(math.atan2(target.Y - t.Y, target.X - t.X))
	t.Turret.Rotation = ang
	-- Hoat anh giat nong sung (Recoil)
	t.Barrel.Position = UDim2.fromScale(0.38, 0.5)
	TweenService:Create(t.Barrel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.55, 0.5)
	}):Play()

	if t.Def.Kind == "Lightning" then
		playSfx("zap", 1.1)
		local hitSet = {}
		local curX, curY = t.X, t.Y
		local curTarget = target
		for _ = 1, (t.Def.Chain or 3) do
			if not curTarget or curTarget.Dead then break end
			hitSet[curTarget] = true
			spawnBeamLine(curX, curY, curTarget.X, curTarget.Y, THEME.TextCyan, 3.5, 0.16)
			damageEnemy(curTarget, dmg, nil, nil, nil, nil, t.Def.Name)
			curX, curY = curTarget.X, curTarget.Y
			local nextBest, bestD = nil, 110
			for _, other in ipairs(TD.enemies) do
				if not other.Dead and not hitSet[other] then
					local d = math.sqrt((other.X - curX)^2 + (other.Y - curY)^2)
					if d < bestD then bestD = d nextBest = other end
				end
			end
			curTarget = nextBest
		end
	elseif t.Def.Kind == "Laser" then
		playSfx("laser", 1.0)
		spawnBeamLine(t.X, t.Y, target.X, target.Y, t.Def.Accent, 5, 0.22)
		spawnExplosionRing(target.X, target.Y, 16, t.Def.Accent)
		damageEnemy(target, dmg, nil, nil, nil, nil, t.Def.Name)
	else
		local pNode = Instance.new("Frame")
		if t.Def.Kind == "Arrow" then
			pNode.Size = UDim2.fromOffset(14, 4)
			pNode.Rotation = ang
			addCorner(pNode, 2)
		elseif t.Def.Kind == "Frost" then
			pNode.Size = UDim2.fromOffset(11, 6)
			pNode.Rotation = ang
			addCorner(pNode, 3)
		else
			pNode.Size = UDim2.fromOffset(12, 12)
			addCorner(pNode, 99)
		end
		pNode.Position = UDim2.fromOffset(t.X, t.Y)
		pNode.AnchorPoint = Vector2.new(0.5, 0.5)
		pNode.BackgroundColor3 = t.Def.Accent
		pNode.BorderSizePixel = 0
		pNode.ZIndex = 20
		pNode.Parent = UI.fxLayer
		addStroke(pNode, THEME.Outline, 1.4)
		playSfx(t.Def.Kind == "Frost" and "frost" or "shoot", 1.0)
		table.insert(TD.projectiles, {
			X = t.X, Y = t.Y, Target = target, TX = target.X, TY = target.Y,
			Speed = t.Def.ProjSpeed or 320, Damage = dmg,
			Splash = t.Def.Splash, Slow = t.Def.Slow, SlowDur = t.Def.SlowDur,
			PoisonDps = t.Def.PoisonDps and (t.Def.PoisonDps * t.Level) or nil, PoisonDur = t.Def.PoisonDur,
			SrcName = t.Def.Name, Color = t.Def.Accent, Node = pNode
		})
	end
end

local function startNewMatch()
	TD.map = MAPS[saveState.SelectedMap] or MAPS[1]
	local diffDef = getDiffDef(saveState.Difficulty)
	TD.gold = TD.map.StartGold + (saveState.Upgrades.gold or 0) * 40
	TD.lives = (diffDef.Id == "hell") and 1 or (diffDef.Lives + (saveState.Upgrades.lives or 0) * 2)
	TD.maxLives = TD.lives
	TD.healCd = 0
	TD.wave = 0
	TD.kills = 0
	TD.waveSpawning = false
	TD.spawnQueue = {}
	TD.skillCd = 0
	TD.over = false
	TD.paused = false
	TD.active = true
	closeBoardPopups()
	UI.pauseLbl.Text = "II"
	UI.endCard.Visible = false
	UI.bossBarBg.Visible = false
	UI.hudGroup.Visible = true
	UI.homeBtn.Visible = true
	UI.sfxBtn.Position = UDim2.new(1, -184, 0, 8)
	lobbyPage.Visible = false
	gamePage.Visible = true
	buildMapBoard(TD.map)
	TD.blizCd = 0
	TD.dmgByTower = {}
	TD.trapMode = "none"
	UI.trapLbl.Text = "BẪY: TẮT"
	updateHUD()
end

local function goLobby()
	TD.active = false
	TD.paused = false
	clearMatchLayers()
	UI.hudGroup.Visible = false
	UI.homeBtn.Visible = false
	UI.sfxBtn.Position = UDim2.new(1, -126, 0, 8)
	gamePage.Visible = false
	lobbyPage.Visible = true
	refreshLobbyStats()
end

-- ============================================================
-- KET NOI NUT BAM & VONG LAP CHINH (RENDERSTEPPED)
-- ============================================================
for i, pb in ipairs(popupBuildBtns) do
	pb.Btn.MouseButton1Click:Connect(function()
		if TD.pendingCell then
			buildTowerAt(TD.pendingCell.gx, TD.pendingCell.gy, i)
		end
	end)
end
UI.bpClose.MouseButton1Click:Connect(function()
	closeBoardPopups()
	updateHUD()
end)
UI.upClose.MouseButton1Click:Connect(function()
	closeBoardPopups()
	updateHUD()
end)

local function applyTowerUpgrade(branchName)
	local t = TD.selectedTower
	if not t then return end
	local cost = (t.Level >= 3) and (320 + (t.Level - 2) * 260) or math.floor(t.Def.UpgradeCost * t.Level)
	if TD.gold < cost then
		showToast("Cần " .. formatNum(cost) .. " Vàng để nâng cấp!", THEME.TextRed, 2.0)
		return
	end
	TD.gold -= cost
	t.Invested += cost
	t.Level += 1
	if t.Level > 3 then
		t.Damage = t.Damage * 1.25
		t.Range = math.min(240, t.Range + 4)
		if t.Def.Kind == "Buff" then
			t.BuffDmg = math.min(0.85, (t.BuffDmg or 0.25) + 0.05)
		end
		t.LvTag.Text = "C" .. tostring(t.Level)
	elseif branchName == "Hủy Diệt" then
		t.Branch = "Hủy Diệt"
		t.Damage = t.Damage * 1.85
		t.Range = t.Range * 1.10
		t.LvTag.Text = "C3A"
	elseif branchName == "Siêu Tốc" then
		t.Branch = "Siêu Tốc"
		t.Damage = t.Damage * 1.32
		t.Range = t.Range * 1.25
		t.FireRate = math.max(0.18, t.FireRate * 0.65)
		t.LvTag.Text = "C3B"
	else
		t.Damage = t.Damage * 1.52
		t.Range = t.Range * 1.12
		t.FireRate = math.max(0.25, t.FireRate * 0.88)
		if t.Def.Kind == "Buff" then
			t.BuffDmg = (t.BuffDmg or 0.25) + 0.08
			t.BuffRate = (t.BuffRate or 0.20) + 0.06
		end
		t.LvTag.Text = "C" .. tostring(t.Level)
	end
	if t.Level >= 3 then addQuestProg("tier3", 1) end
	if t.BuffAura then t.BuffAura.Size = UDim2.fromOffset(t.Range * 2, t.Range * 2) end
	playSfx("upgrade", 1.0)
	spawnExplosionRing(t.X, t.Y, 28, THEME.TextGold)
	showToast("Đã nâng " .. t.Def.Name .. " lên Cấp " .. t.Level .. (branchName and (" (" .. branchName .. ")") or "") .. "!", THEME.TextGreen, 2.0)
	updateHUD()
end

UI.upgBtn.MouseButton1Click:Connect(function() applyTowerUpgrade(nil) end)
UI.evoABtn.MouseButton1Click:Connect(function() applyTowerUpgrade("Hủy Diệt") end)
UI.evoBBtn.MouseButton1Click:Connect(function() applyTowerUpgrade("Siêu Tốc") end)

UI.targetBtn.MouseButton1Click:Connect(function()
	local t = TD.selectedTower
	if not t then return end
	local order = { First = "Strong", Strong = "Weak", Weak = "First" }
	t.TargetMode = order[t.TargetMode or "First"] or "First"
	updateHUD()
end)

UI.autoBtn.MouseButton1Click:Connect(function()
	TD.autoWave = not TD.autoWave
	UI.autoLbl.Text = TD.autoWave and "TỰ GỌI: BẬT" or "TỰ GỌI: TẮT"
	showToast(TD.autoWave and "Đã bật tự động gọi đợt kế tiếp!" or "Đã tắt tự động gọi đợt.", THEME.TextCyan, 1.8)
end)

UI.sfxBtn.MouseButton1Click:Connect(function()
	saveState.SfxOn = not saveState.SfxOn
	UI.sfxLbl.Text = saveState.SfxOn and "Âm" or "Tắt"
	saveData()
end)

local function openPermUpgrades()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "CÂY KỸ NĂNG  •  " .. formatNum(saveState.Stars) .. " Sao"
	local tabRow = Instance.new("Frame")
	tabRow.Size = UDim2.new(1, 0, 0, 32)
	tabRow.BackgroundTransparency = 1
	tabRow.ZIndex = 53
	tabRow.Parent = UI.pmList
	local tSkinBtn = makeArcadeBtn(tabRow, "MỞ CỬA HÀNG HIỆU ỨNG SAO", UDim2.fromOffset(290, 28), UDim2.new(0.5, -145, 0, 2), Color3.fromRGB(186, 68, 214), Color3.fromRGB(118, 32, 168), 8, { TextSize = 11, ZIndex = 54, Depth = 3 })
	tSkinBtn.MouseButton1Click:Connect(function()
		for _, ch in ipairs(UI.pmList:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
		UI.pmTitle.Text = "CỬA HÀNG SKIN SAO  •  " .. formatNum(saveState.Stars) .. " Sao"
		local backR = Instance.new("Frame")
		backR.Size = UDim2.new(1, 0, 0, 32)
		backR.BackgroundTransparency = 1
		backR.ZIndex = 53
		backR.Parent = UI.pmList
		local bkBtn = makeArcadeBtn(backR, "QUAY LẠI CÂY KỸ NĂNG", UDim2.fromOffset(220, 28), UDim2.new(0.5, -110, 0, 2), Color3.fromRGB(54, 148, 212), Color3.fromRGB(30, 86, 174), 8, { TextSize = 11, ZIndex = 54, Depth = 3 })
		bkBtn.MouseButton1Click:Connect(openPermUpgrades)
		for _, sk in ipairs(TD_SKINS) do
			local owned = (saveState.OwnedSkins[sk.Id] == true)
			local eq = (saveState.EquippedSkin == sk.Id)
			local sRow = Instance.new("Frame")
			sRow.Size = UDim2.new(1, 0, 0, 48)
			sRow.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
			sRow.BorderSizePixel = 0
			sRow.ZIndex = 53
			sRow.Parent = UI.pmList
			addCorner(sRow, 9)
			addStroke(sRow, eq and THEME.TextGreen or (sk.Aura or Color3.fromRGB(78, 86, 134)), eq and 2 or 1.5)
			local sn = Instance.new("TextLabel")
			sn.Size = UDim2.fromOffset(296, 20)
			sn.Position = UDim2.fromOffset(10, 4)
			sn.BackgroundTransparency = 1
			sn.Text = sk.Name
			sn.TextColor3 = sk.Aura or THEME.TextMain
			sn.Font = THEME.FontHead
			sn.TextSize = 12
			sn.TextXAlignment = Enum.TextXAlignment.Left
			sn.ZIndex = 54
			sn.Parent = sRow
			local sd = Instance.new("TextLabel")
			sd.Size = UDim2.fromOffset(296, 18)
			sd.Position = UDim2.fromOffset(10, 24)
			sd.BackgroundTransparency = 1
			sd.Text = sk.Desc
			sd.TextColor3 = THEME.TextMuted
			sd.Font = THEME.FontBody
			sd.TextSize = 10
			sd.TextXAlignment = Enum.TextXAlignment.Left
			sd.ZIndex = 54
			sd.Parent = sRow
			local sBtn = makeArcadeBtn(
				sRow, eq and "ĐANG DÙNG" or (owned and "TRANG BỊ" or (tostring(sk.Cost) .. " Sao")),
				UDim2.fromOffset(112, 32), UDim2.new(1, -120, 0, 8),
				eq and Color3.fromRGB(64, 194, 92) or (owned and Color3.fromRGB(54, 148, 212) or Color3.fromRGB(214, 152, 42)),
				eq and Color3.fromRGB(28, 134, 58) or (owned and Color3.fromRGB(30, 86, 174) or Color3.fromRGB(162, 92, 18)),
				8, { TextSize = 10, ZIndex = 54, Depth = 3 }
			)
			sBtn.MouseButton1Click:Connect(function()
				if owned then
					saveState.EquippedSkin = sk.Id
					saveData()
					showToast("Đã trang bị Skin: " .. sk.Name, THEME.TextGreen, 2.0)
					openPermUpgrades()
				elseif saveState.Stars >= sk.Cost then
					saveState.Stars -= sk.Cost
					saveState.OwnedSkins[sk.Id] = true
					saveState.EquippedSkin = sk.Id
					saveData()
					playSfx("upgrade", 1.1)
					refreshLobbyStats()
					showToast("Đã mở khóa Skin: " .. sk.Name .. "!", THEME.TextGold, 2.5)
					openPermUpgrades()
				else
					showToast("Cần " .. sk.Cost .. " Sao để mở Skin này!", THEME.TextRed, 2.0)
				end
			end)
		end
	end)
	for _, u in ipairs(PERM_UPGRADES) do
		local lv = saveState.Upgrades[u.Key] or 0
		local cost = u.BaseCost + lv * 10
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 48)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
		row.BorderSizePixel = 0
		row.ZIndex = 53
		row.Parent = UI.pmList
		addCorner(row, 10)
		addStroke(row, Color3.fromRGB(78, 86, 134), 1.6)

		local nm = Instance.new("TextLabel")
		nm.Size = UDim2.fromOffset(290, 20)
		nm.Position = UDim2.fromOffset(10, 6)
		nm.BackgroundTransparency = 1
		nm.Text = u.Name .. "  •  Cấp " .. tostring(lv) .. "/" .. tostring(u.Max)
		nm.TextColor3 = THEME.TextGold
		nm.Font = THEME.FontHead
		nm.TextSize = 12
		nm.TextXAlignment = Enum.TextXAlignment.Left
		nm.ZIndex = 54
		nm.Parent = row

		local ds = Instance.new("TextLabel")
		ds.Size = UDim2.fromOffset(290, 22)
		ds.Position = UDim2.fromOffset(10, 28)
		ds.BackgroundTransparency = 1
		ds.Text = u.Desc
		ds.TextColor3 = THEME.TextMuted
		ds.Font = THEME.FontBody
		ds.TextSize = 11
		ds.TextXAlignment = Enum.TextXAlignment.Left
		ds.ZIndex = 54
		ds.Parent = row

		local isMax = (lv >= u.Max)
		local b = makeArcadeBtn(
			row, isMax and "MAX" or (tostring(cost) .. " Sao"),
			UDim2.fromOffset(118, 34), UDim2.new(1, -126, 0, 11),
			isMax and Color3.fromRGB(72, 82, 112) or Color3.fromRGB(64, 194, 92),
			isMax and Color3.fromRGB(48, 54, 78) or Color3.fromRGB(28, 134, 58),
			9, { TextSize = 11, ZIndex = 54, Depth = 3 }
		)
		b.MouseButton1Click:Connect(function()
			if isMax then return end
			if saveState.Stars < cost then
				showToast("Không đủ Sao! Chơi qua đợt để kiếm thêm Sao.", THEME.TextRed, 2.2)
				return
			end
			saveState.Stars -= cost
			saveState.Upgrades[u.Key] = lv + 1
			saveData()
			playSfx("upgrade", 1.0)
			refreshLobbyStats()
			openPermUpgrades()
		end)
	end
	UI.pmOverlay.Visible = true
end

UI.permUpgBtn.MouseButton1Click:Connect(openPermUpgrades)
UI.pmClose.MouseButton1Click:Connect(function() UI.pmOverlay.Visible = false end)

-- Modal Nhiem Vu Kiem Sao (dung chung pmOverlay gon gang)
local function openStarQuests()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "NHIỆM VỤ KIẾM SAO  •  " .. formatNum(saveState.Stars) .. " Sao"
	local allDone = true
	for _, q in ipairs(saveState.Quests) do
		if not q.Claimed then allDone = false end
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
		row.BorderSizePixel = 0
		row.ZIndex = 53
		row.Parent = UI.pmList
		addCorner(row, 9)
		addStroke(row, (q.Progress >= q.Goal and not q.Claimed) and THEME.TextGreen or Color3.fromRGB(74, 82, 128), 1.5)

		local tLbl = Instance.new("TextLabel")
		tLbl.Size = UDim2.fromOffset(306, 42)
		tLbl.Position = UDim2.fromOffset(10, 1)
		tLbl.BackgroundTransparency = 1
		tLbl.Text = q.Title .. "  (" .. math.min(q.Progress, q.Goal) .. "/" .. q.Goal .. ")"
		tLbl.TextColor3 = THEME.TextMain
		tLbl.Font = THEME.FontBody
		tLbl.TextSize = 11
		tLbl.TextXAlignment = Enum.TextXAlignment.Left
		tLbl.ZIndex = 54
		tLbl.Parent = row

		local canClaim = (q.Progress >= q.Goal) and not q.Claimed
		local btn = makeArcadeBtn(
			row, q.Claimed and "ĐÃ NHẬN" or ("+" .. q.Reward .. " Sao"),
			UDim2.fromOffset(106, 30), UDim2.new(1, -114, 0, 7),
			canClaim and Color3.fromRGB(64, 194, 92) or Color3.fromRGB(72, 82, 112),
			canClaim and Color3.fromRGB(28, 134, 58) or Color3.fromRGB(48, 54, 78),
			8, { TextSize = 11, ZIndex = 54, Depth = 3 }
		)
		btn.MouseButton1Click:Connect(function()
			if not canClaim then return end
			q.Claimed = true
			saveState.Stars += q.Reward
			saveData()
			playSfx("upgrade", 1.1)
			refreshLobbyStats()
			openStarQuests()
		end)
	end
	if allDone then
		local rRow = Instance.new("Frame")
		rRow.Size = UDim2.new(1, 0, 0, 38)
		rRow.BackgroundTransparency = 1
		rRow.ZIndex = 53
		rRow.Parent = UI.pmList
		local rb = makeArcadeBtn(rRow, "LÀM MỚI NHIỆM VỤ", UDim2.fromOffset(200, 32), UDim2.new(0.5, -100, 0, 3), Color3.fromRGB(154, 72, 218), Color3.fromRGB(94, 34, 168), 9, { TextSize = 11, ZIndex = 54, Depth = 3 })
		rb.MouseButton1Click:Connect(function()
			saveState.Quests = createDefaultQuests()
			saveData()
			refreshLobbyStats()
			openStarQuests()
		end)
	end
	UI.pmOverlay.Visible = true
end
UI.questBtn.MouseButton1Click:Connect(openStarQuests)

-- Bang chon Che Do Kho khi bam vao 1 Ban Do ngoai sanh
UI.openDiffModal = function(mp)
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "CHỌN CẤP ĐỘ  •  " .. mp.Name
	for _, df in ipairs(DIFFICULTIES) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
		row.BorderSizePixel = 0
		row.ZIndex = 53
		row.Parent = UI.pmList
		addCorner(row, 9)
		addStroke(row, (saveState.Difficulty == df.Id) and df.Color or Color3.fromRGB(72, 82, 128), (saveState.Difficulty == df.Id) and 2.2 or 1.4)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.fromOffset(312, 42)
		lbl.Position = UDim2.fromOffset(10, 1)
		lbl.BackgroundTransparency = 1
		lbl.Text = string.format("%s  •  Thành %d HP  •  Máu quái x%.2g  •  Sao x%.2g", df.Name, df.Lives, df.HpMult, df.StarMult)
		lbl.TextColor3 = df.Color
		lbl.Font = THEME.FontHead
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 54
		lbl.Parent = row

		local goBtn = makeArcadeBtn(
			row, "CHƠI NGAY",
			UDim2.fromOffset(104, 30), UDim2.new(1, -112, 0, 7),
			Color3.fromRGB(64, 194, 92), Color3.fromRGB(28, 134, 58),
			8, { TextSize = 10, ZIndex = 54, Depth = 3 }
		)
		goBtn.MouseButton1Click:Connect(function()
			saveState.Difficulty = df.Id
			saveData()
			UI.pmOverlay.Visible = false
			startNewMatch()
		end)
	end
	UI.pmOverlay.Visible = true
end

-- Bang Cai Dat o sanh chinh (Cong tac gat Toggle Switch + Thanh truot Am Luong)
local function openLobbySettings()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "CÀI ĐẶT GAME"
	local function addToggleOpt(titleTxt, descTxt, isOn, onClick)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 56)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
		row.BorderSizePixel = 0
		row.ZIndex = 53
		row.Parent = UI.pmList
		addCorner(row, 10)
		addStroke(row, Color3.fromRGB(78, 86, 134), 1.6)

		local t1 = Instance.new("TextLabel")
		t1.Size = UDim2.fromOffset(320, 20)
		t1.Position = UDim2.fromOffset(12, 6)
		t1.BackgroundTransparency = 1
		t1.Text = titleTxt
		t1.TextColor3 = THEME.TextGold
		t1.Font = THEME.FontHead
		t1.TextSize = 12
		t1.TextXAlignment = Enum.TextXAlignment.Left
		t1.ZIndex = 54
		t1.Parent = row

		local t2 = Instance.new("TextLabel")
		t2.Size = UDim2.fromOffset(320, 20)
		t2.Position = UDim2.fromOffset(12, 28)
		t2.BackgroundTransparency = 1
		t2.Text = descTxt
		t2.TextColor3 = THEME.TextMuted
		t2.Font = THEME.FontBody
		t2.TextSize = 10
		t2.TextXAlignment = Enum.TextXAlignment.Left
		t2.ZIndex = 54
		t2.Parent = row

		-- Cong tac gat Toggle Switch xanh / xam (giong anh mau)
		local sw = Instance.new("TextButton")
		sw.Size = UDim2.fromOffset(62, 30)
		sw.Position = UDim2.new(1, -74, 0, 13)
		sw.BackgroundColor3 = isOn and Color3.fromRGB(56, 192, 92) or Color3.fromRGB(64, 70, 96)
		sw.Text = ""
		sw.AutoButtonColor = false
		sw.BorderSizePixel = 0
		sw.ZIndex = 54
		sw.Parent = row
		addCorner(sw, 99)
		addStroke(sw, THEME.Outline, 1.8)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(22, 22)
		knob.Position = isOn and UDim2.fromOffset(35, 4) or UDim2.fromOffset(5, 4)
		knob.BackgroundColor3 = Color3.fromRGB(224, 228, 236)
		knob.BorderSizePixel = 0
		knob.ZIndex = 55
		knob.Parent = sw
		addCorner(knob, 99)
		addStroke(knob, THEME.Outline, 1.3)

		sw.MouseButton1Click:Connect(onClick)
	end

	addToggleOpt("Tối ưu FPS (Giảm hiệu ứng)", "Tắt bớt hạt nổ & chữ bay để mượt hơn ở Đợt cao", saveState.LowFx, function()
		saveState.LowFx = not saveState.LowFx
		saveData()
		openLobbySettings()
	end)
	addToggleOpt("Âm thanh chiến đấu (SFX)", "Bật hoặc tắt tiếng bắn tháp, nổ pháo, nâng cấp", saveState.SfxOn, function()
		saveState.SfxOn = not saveState.SfxOn
		UI.sfxLbl.Text = saveState.SfxOn and "Âm" or "Tắt"
		saveData()
		openLobbySettings()
	end)

	-- Thanh truot chon muc Am Luong (20% - 100%)
	local volRow = Instance.new("Frame")
	volRow.Size = UDim2.new(1, 0, 0, 56)
	volRow.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
	volRow.BorderSizePixel = 0
	volRow.ZIndex = 53
	volRow.Parent = UI.pmList
	addCorner(volRow, 10)
	addStroke(volRow, Color3.fromRGB(78, 86, 134), 1.6)

	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.fromOffset(200, 22)
	vl.Position = UDim2.fromOffset(12, 6)
	vl.BackgroundTransparency = 1
	vl.Text = "Âm lượng hiệu ứng: " .. tostring(math.floor((saveState.SfxVol or 0.7) * 100)) .. "%"
	vl.TextColor3 = THEME.TextCyan
	vl.Font = THEME.FontHead
	vl.TextSize = 12
	vl.TextXAlignment = Enum.TextXAlignment.Left
	vl.ZIndex = 54
	vl.Parent = volRow

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -134, 0, 12)
	barBg.Position = UDim2.fromOffset(12, 34)
	barBg.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 54
	barBg.Parent = volRow
	addCorner(barBg, 6)
	addStroke(barBg, THEME.Outline, 1.3)

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(math.clamp(saveState.SfxVol or 0.7, 0.2, 1), 1)
	barFill.BackgroundColor3 = Color3.fromRGB(54, 168, 224)
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 55
	barFill.Parent = barBg
	addCorner(barFill, 6)

	local vMinus = makeArcadeBtn(volRow, "-", UDim2.fromOffset(44, 30), UDim2.new(1, -106, 0, 13), Color3.fromRGB(78, 88, 124), Color3.fromRGB(48, 54, 82), 8, { TextSize = 16, ZIndex = 54, Depth = 3 })
	local vPlus  = makeArcadeBtn(volRow, "+", UDim2.fromOffset(44, 30), UDim2.new(1, -56, 0, 13), Color3.fromRGB(56, 152, 214), Color3.fromRGB(32, 92, 174), 8, { TextSize = 16, ZIndex = 54, Depth = 3 })
	vMinus.MouseButton1Click:Connect(function()
		saveState.SfxVol = math.max(0.2, math.floor(((saveState.SfxVol or 0.7) - 0.2) * 10 + 0.5) / 10)
		saveData()
		openLobbySettings()
	end)
	vPlus.MouseButton1Click:Connect(function()
		saveState.SfxVol = math.min(1.0, math.floor(((saveState.SfxVol or 0.7) + 0.2) * 10 + 0.5) / 10)
		saveData()
		playSfx("upgrade", 1.1)
		openLobbySettings()
	end)
	UI.pmOverlay.Visible = true
end
UI.settingsBtn.MouseButton1Click:Connect(openLobbySettings)

-- Bang KHO DO (Mua bang Sao o sanh / Su dung truc tiep trong tran!)
local function openInventoryModal(inMatch)
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	UI.pmTitle.Text = inMatch and "KHO ĐỒ CHIẾN ĐẤU  •  DÙNG NGAY" or ("KHO ĐỒ  •  " .. formatNum(saveState.Stars) .. " Sao")
	for _, it in ipairs(BAG_ITEMS) do
		local qty = saveState.Bag[it.Id] or 0
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 62)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
		row.BorderSizePixel = 0
		row.ZIndex = 53
		row.Parent = UI.pmList
		addCorner(row, 10)
		addStroke(row, it.Color, 1.8)

		local ic = Instance.new("Frame")
		ic.Size = UDim2.fromOffset(38, 38)
		ic.Position = UDim2.fromOffset(10, 12)
		ic.BackgroundColor3 = it.Color
		ic.BorderSizePixel = 0
		ic.ZIndex = 54
		ic.Parent = row
		addCorner(ic, 9)
		addStroke(ic, THEME.Outline, 1.6)
		local qTag = Instance.new("TextLabel")
		qTag.Size = UDim2.fromScale(1, 1)
		qTag.BackgroundTransparency = 1
		qTag.Text = "x" .. tostring(qty)
		qTag.TextColor3 = THEME.TextMain
		qTag.Font = THEME.FontHead
		qTag.TextSize = 13
		qTag.ZIndex = 55
		qTag.Parent = ic
		addTextOutline(qTag, 1.5, THEME.Outline)

		local nm = Instance.new("TextLabel")
		nm.Size = UDim2.fromOffset(260, 20)
		nm.Position = UDim2.fromOffset(58, 8)
		nm.BackgroundTransparency = 1
		nm.Text = it.Name
		nm.TextColor3 = THEME.TextGold
		nm.Font = THEME.FontHead
		nm.TextSize = 12
		nm.TextXAlignment = Enum.TextXAlignment.Left
		nm.ZIndex = 54
		nm.Parent = row

		local ds = Instance.new("TextLabel")
		ds.Size = UDim2.fromOffset(260, 22)
		ds.Position = UDim2.fromOffset(58, 30)
		ds.BackgroundTransparency = 1
		ds.Text = it.Desc
		ds.TextColor3 = THEME.TextMuted
		ds.Font = THEME.FontBody
		ds.TextSize = 10
		ds.TextXAlignment = Enum.TextXAlignment.Left
		ds.ZIndex = 54
		ds.Parent = row

		local btnTxt = inMatch and (qty > 0 and "SỬ DỤNG" or "HẾT ĐỒ") or ("MUA (" .. it.Cost .. " Sao)")
		local actBtn = makeArcadeBtn(
			row, btnTxt,
			UDim2.fromOffset(118, 36), UDim2.new(1, -126, 0, 13),
			(inMatch and qty == 0) and Color3.fromRGB(72, 82, 112) or Color3.fromRGB(64, 194, 92),
			(inMatch and qty == 0) and Color3.fromRGB(48, 54, 78) or Color3.fromRGB(28, 134, 58),
			8, { TextSize = 10, ZIndex = 54, Depth = 3 }
		)
		actBtn.MouseButton1Click:Connect(function()
			if inMatch then
				if qty <= 0 or not TD.active or TD.over then return end
				saveState.Bag[it.Id] = qty - 1
				if it.Id == "potion" then
					TD.lives = math.min(TD.maxLives, TD.lives + 5)
					showToast("Dùng Bình Máu: +5 HP Thành Trì!", THEME.TextGreen, 2.2)
				elseif it.Id == "goldbag" then
					TD.gold += 250
					showToast("Dùng Túi Vàng: +250 Vàng!", THEME.TextGold, 2.2)
				elseif it.Id == "scroll" then
					TD.skillCd, TD.blizCd, TD.healCd = 0, 0, 0
					showToast("Dùng Cuộn Hồi Chiêu: Toàn bộ kỹ năng đã sẵn sàng!", THEME.TextPurple, 2.2)
				end
				saveData()
				playSfx("upgrade", 1.15)
				updateHUD()
				UI.pmOverlay.Visible = false
			else
				if saveState.Stars < it.Cost then
					showToast("Cần " .. it.Cost .. " Sao để mua " .. it.Name .. "!", THEME.TextRed, 2.0)
					return
				end
				saveState.Stars -= it.Cost
				saveState.Bag[it.Id] = qty + 1
				saveData()
				playSfx("upgrade", 1.1)
				refreshLobbyStats()
				openInventoryModal(false)
			end
		end)
	end
	UI.pmOverlay.Visible = true
end
UI.bagBtn.MouseButton1Click:Connect(function() openInventoryModal(false) end)
UI.matchBagBtn.MouseButton1Click:Connect(function() openInventoryModal(true) end)

-- Ky nang Hoi Mau Thanh (+3 HP)
UI.healBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.paused or TD.over or TD.healCd > 0 then return end
	if TD.lives >= TD.maxLives then
		showToast("Máu Thành Trì đang đầy!", THEME.TextGreen, 1.8)
		return
	end
	TD.healCd = math.max(16, 28 - (saveState.Upgrades.skill or 0) * 2)
	TD.lives = math.min(TD.maxLives, TD.lives + 3)
	playSfx("upgrade", 1.2)
	local pEnd = TD.pathPoints[#TD.pathPoints]
	if pEnd then spawnExplosionRing(pEnd.x, pEnd.y, 44, THEME.TextGreen) end
	showToast("Hồi Thành: +3 HP Thành Trì!", THEME.TextGreen, 2.0)
	updateHUD()
end)

UI.trapBtn.MouseButton1Click:Connect(function()
	if TD.trapMode == "none" then
		TD.trapMode = "spike"
		UI.trapLbl.Text = "BẪY GAI\n45V"
		showToast("Chạm vào đường đi để đặt Bẫy Gai (45V)", THEME.TextCyan, 2.0)
	elseif TD.trapMode == "spike" then
		TD.trapMode = "mine"
		UI.trapLbl.Text = "MÌN NỔ\n75V"
		showToast("Chạm vào đường đi để đặt Mìn Nổ (75V)", THEME.TextRed, 2.0)
	else
		TD.trapMode = "none"
		UI.trapLbl.Text = "BẪY: TẮT"
		showToast("Đã tắt chế độ đặt bẫy", THEME.TextMuted, 1.8)
	end
end)

-- Nut Ky Nang Bao Tuyet (dong bang toan ban do 4s)
UI.blizBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.paused or TD.over or TD.blizCd > 0 then return end
	if #TD.enemies == 0 then
		showToast("Chưa có quái trên đường!", THEME.TextCyan, 1.8)
		return
	end
	TD.blizCd = math.max(14, 24 - (saveState.Upgrades.skill or 0) * 2)
	playSfx("frost", 0.85)
	for _, e in ipairs(TD.enemies) do
		if not e.Dead then
			e.SlowFactor = 0.05
			e.SlowTimer = math.max(e.SlowTimer, 4.0)
			spawnExplosionRing(e.X, e.Y, 26, THEME.TextCyan)
		end
	end
	showToast("Bão Tuyết đóng băng toàn bộ quái 4 giây!", THEME.TextCyan, 2.2)
	updateHUD()
end)

UI.sellBtn.MouseButton1Click:Connect(function()
	local t = TD.selectedTower
	if not t then return end
	local refund = math.floor(t.Invested * 0.7)
	TD.gold += refund
	spawnFloatingText(t.X, t.Y, "+" .. refund .. "V", THEME.TextGold)
	if t.Node and t.Node.Parent then t.Node:Destroy() end
	for i = #TD.towers, 1, -1 do
		if TD.towers[i] == t then table.remove(TD.towers, i) break end
	end
	TD.selectedTower = nil
	updateHUD()
end)

UI.skillBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.paused or TD.over then return end
	if TD.skillCd > 0 then return end
	if #TD.enemies == 0 then
		showToast("Chưa có quái trên đường để thả Thiên Thạch!", THEME.TextGold, 2.0)
		return
	end
	TD.skillCd = math.max(12, 25 - (saveState.Upgrades.skill or 0) * 2)
	playSfx("explosion", 0.9)
	TD.shakeTime = 0.25
	local dmg = 95 + TD.wave * 24
	for _, e in ipairs(TD.enemies) do
		if not e.Dead then
			spawnExplosionRing(e.X, e.Y, 34, Color3.fromRGB(224, 96, 48))
			damageEnemy(e, dmg, nil, nil, nil, nil, "Thiên Thạch")
		end
	end
	showToast("Mưa Thiên Thạch giáng xuống toàn bản đồ!", THEME.TextGold, 2.2)
	updateHUD()
end)

UI.waveBtn.MouseButton1Click:Connect(startNextWave)
UI.playBtn.MouseButton1Click:Connect(startNewMatch)
UI.endReplayBtn.MouseButton1Click:Connect(startNewMatch)
UI.homeBtn.MouseButton1Click:Connect(goLobby)
UI.endHomeBtn.MouseButton1Click:Connect(goLobby)

UI.spdBtn.MouseButton1Click:Connect(function()
	TD.speedMult = (TD.speedMult == 1) and 2 or ((TD.speedMult == 2) and 3 or 1)
	updateHUD()
end)

UI.pauseBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.over then return end
	TD.paused = not TD.paused
	UI.pauseLbl.Text = TD.paused and "▶" or "II"
end)

local function minimizeMenu()
	if TD.active then TD.paused = true UI.pauseLbl.Text = "▶" end
	mainFrame.Visible = false
	backdrop.Visible = false
	floatBtn.Visible = true
end

local function restoreMenu()
	floatBtn.Visible = false
	mainFrame.Visible = true
	backdrop.Visible = true
end

UI.minBtn.MouseButton1Click:Connect(minimizeMenu)
floatBtn.MouseButton1Click:Connect(function() if not floatDragged then restoreMenu() end end)
-- Hop thoai Xac Nhan Thoat Game (giong anh mau)
UI.closeBtn.MouseButton1Click:Connect(function()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "THÔNG BÁO"
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 146)
	box.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
	box.BorderSizePixel = 0
	box.ZIndex = 53
	box.Parent = UI.pmList
	addCorner(box, 12)
	addStroke(box, THEME.TextGold, 1.8)

	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -24, 0, 56)
	msg.Position = UDim2.fromOffset(12, 18)
	msg.BackgroundTransparency = 1
	msg.Text = "Bạn có chắc muốn thoát game Thủ Thành 2D?\nTiến trình Sao và kỷ lục sẽ tự động được lưu lại."
	msg.TextColor3 = THEME.TextMain
	msg.Font = THEME.FontHead
	msg.TextSize = 13
	msg.TextWrapped = true
	msg.ZIndex = 54
	msg.Parent = box

	local cancelB = makeArcadeBtn(box, "HỦY", UDim2.fromOffset(146, 38), UDim2.new(0.5, -156, 0, 90), Color3.fromRGB(78, 92, 134), Color3.fromRGB(48, 56, 86), 9, { TextSize = 13, ZIndex = 54, Depth = 3 })
	local okB     = makeArcadeBtn(box, "ĐỒNG Ý", UDim2.fromOffset(146, 38), UDim2.new(0.5, 10, 0, 90), Color3.fromRGB(214, 62, 68), Color3.fromRGB(152, 28, 36), 9, { TextSize = 13, ZIndex = 54, Depth = 3 })
	cancelB.MouseButton1Click:Connect(function() UI.pmOverlay.Visible = false end)
	okB.MouseButton1Click:Connect(function()
		saveData()
		screenGui:Destroy()
	end)
	UI.pmOverlay.Visible = true
end)

track(UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.RightShift then
		if mainFrame.Visible then minimizeMenu() else restoreMenu() end
	end
end))

local cam = workspace.CurrentCamera
if cam then
	track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale))
end

track(RunService.RenderStepped:Connect(function(rawDt)
	if not mainFrame.Visible or not TD.active or TD.paused or TD.over then return end
	local dt = math.min(0.05, rawDt) * TD.speedMult

	-- Rung nhe ban co khi tha Thien Thach
	if TD.shakeTime > 0 then
		TD.shakeTime = math.max(0, TD.shakeTime - rawDt)
		UI.board.Position = UDim2.fromOffset(82 + math.random(-3, 3), 4 + math.random(-3, 3))
	else
		UI.board.Position = UDim2.fromOffset(82, 4)
	end

	-- Xoay vong cong quai
	if UI.portalVortex and UI.portalVortex.Parent then
		UI.portalVortex.Rotation = (UI.portalVortex.Rotation + dt * 160) % 360
	end

	-- Hoi chieu Thien Thach
	local needHud = false
	if TD.skillCd > 0 then
		local p1 = math.ceil(TD.skillCd)
		TD.skillCd = math.max(0, TD.skillCd - dt)
		if math.ceil(TD.skillCd) ~= p1 then needHud = true end
	end
	if TD.blizCd > 0 then
		local p2 = math.ceil(TD.blizCd)
		TD.blizCd = math.max(0, TD.blizCd - dt)
		if math.ceil(TD.blizCd) ~= p2 then needHud = true end
	end
	if TD.healCd > 0 then
		local p3 = math.ceil(TD.healCd)
		TD.healCd = math.max(0, TD.healCd - dt)
		if math.ceil(TD.healCd) ~= p3 then needHud = true end
	end
	if needHud then updateHUD() end

	-- Sinh quai theo dot
	if TD.waveSpawning then
		TD.spawnTimer -= dt
		if TD.spawnTimer <= 0 then
			if #TD.spawnQueue > 0 then
				local kind = table.remove(TD.spawnQueue, 1)
				spawnEnemy(kind)
				TD.spawnTimer = 0.68
			else
				TD.waveSpawning = false
			end
		end
	end

	-- Di chuyen & hoat anh nhun nhay cua quai
	for i = #TD.enemies, 1, -1 do
		local e = TD.enemies[i]
		if e.Dead then
			table.remove(TD.enemies, i)
		else
			if e.PoisonTimer > 0 then
				e.PoisonTimer = math.max(0, e.PoisonTimer - dt)
				damageEnemy(e, e.PoisonDps * dt)
				if e.Dead then table.remove(TD.enemies, i) continue end
			end
			if e.SlowTimer > 0 then
				e.SlowTimer = math.max(0, e.SlowTimer - dt)
				if e.SlowTimer == 0 then e.SlowFactor = 1 end
			end
			if e.FrostCoat then e.FrostCoat.Visible = (e.SlowTimer > 0) end
			if e.HitFlash > 0 then
				e.HitFlash = math.max(0, e.HitFlash - rawDt)
				e.Body.BackgroundColor3 = Color3.fromRGB(224, 224, 232)
			elseif e.SlowTimer > 0 then
				e.Body.BackgroundColor3 = Color3.fromRGB(96, 186, 224)
			elseif e.PoisonTimer > 0 then
				e.Body.BackgroundColor3 = Color3.fromRGB(108, 214, 72)
			else
				e.Body.BackgroundColor3 = e.Def.Color
			end
			if e.WingL and e.WingR then
				local flap = math.sin(e.BobPhase * 1.4) * 20
				e.WingL.Rotation = -18 + flap
				e.WingR.Rotation = 18 - flap
			end
			if e.Def.HeroBoss then
				e.SkillCd -= dt
				if e.SkillCd <= 0 then
					e.SkillCd = 6.0
					local heal = math.floor(e.MaxHP * 0.04)
					e.HP = math.min(e.MaxHP, e.HP + heal)
					e.HpFill.Size = UDim2.fromScale(math.clamp(e.HP / e.MaxHP, 0, 1), 1)
					spawnExplosionRing(e.X, e.Y, 44, Color3.fromRGB(186, 86, 232))
					spawnFloatingText(e.X, e.Y, "+" .. formatNum(heal) .. " HP", THEME.TextPurple)
				end
			end

			local wp = TD.pathPoints[e.WpIdx]
			if wp then
				local dx, dy = wp.x - e.X, wp.y - e.Y
				local dist = math.sqrt(dx * dx + dy * dy)
				local diffSpd = (getDiffDef(saveState.Difficulty).SpdMult or 1.0)
				local step = e.Def.Speed * diffSpd * e.SlowFactor * dt
				if dist <= step then
					e.X, e.Y = wp.x, wp.y
					e.WpIdx += 1
				else
					e.X += (dx / dist) * step
					e.Y += (dy / dist) * step
				end
				e.Progress += step
				e.BobPhase += dt * 11
				local bobY = -math.abs(math.sin(e.BobPhase)) * 4
				e.Node.Position = UDim2.fromOffset(e.X, e.Y)
				e.Body.Position = UDim2.new(0.5, 0, 0.5, bobY)
			else
				-- Quai thuong lot vao -1 HP, Boss lot vao la THUA NGAY!
				if e.Def.Boss then
					TD.lives = 0
					showToast("BOSS ĐÃ PHÁ HỦY THÀNH TRÌ!", THEME.TextRed, 3.0)
				else
					TD.lives -= 1
				end
				if e.Node and e.Node.Parent then e.Node:Destroy() end
				table.remove(TD.enemies, i)
				updateHUD()
				if TD.lives <= 0 then
					finishMatch(false)
					return
				end
			end
		end
	end

	-- Cap nhat Thanh Mau Boss lon tren cung ban co
	local activeBoss = nil
	for _, e in ipairs(TD.enemies) do
		if not e.Dead and e.Def.Boss then
			if not activeBoss or e.MaxHP > activeBoss.MaxHP then activeBoss = e end
		end
	end
	if activeBoss then
		UI.bossBarBg.Visible = true
		UI.bossBarFill.Size = UDim2.fromScale(math.clamp(activeBoss.HP / activeBoss.MaxHP, 0, 1), 1)
		UI.bossBarLbl.Text = activeBoss.Def.Name .. "  •  " .. formatNum(activeBoss.HP) .. " / " .. formatNum(activeBoss.MaxHP)
	else
		UI.bossBarBg.Visible = false
	end

	-- Kiem tra Bay Duong (Bay Gai & Min No) kich hoat khi quai giam len
	for ti = #TD.traps, 1, -1 do
		local tr = TD.traps[ti]
		tr.Cd = math.max(0, tr.Cd - dt)
		if tr.Cd <= 0 then
			local triggered = false
			for _, e in ipairs(TD.enemies) do
				if not e.Dead and math.sqrt((e.X - tr.X)^2 + (e.Y - tr.Y)^2) <= 22 then
					triggered = true
					if tr.Def.Id == "mine" then
						local mDmg = (tr.Def.Damage + TD.wave * 20 + math.floor(e.MaxHP * (e.Def.Boss and 0.04 or 0.12))) * (1 + (saveState.Upgrades.dmg or 0) * 0.08)
						playSfx("explosion", 0.95)
						spawnExplosionRing(tr.X, tr.Y, tr.Def.Splash or 68, tr.Def.Color)
						for _, oe in ipairs(TD.enemies) do
							if not oe.Dead and math.sqrt((oe.X - tr.X)^2 + (oe.Y - tr.Y)^2) <= (tr.Def.Splash or 68) then
								damageEnemy(oe, mDmg, nil, nil, nil, nil, "Mìn Nổ")
							end
						end
						tr.Uses = 0
					else
						local sDmg = (tr.Def.Damage + math.floor(e.MaxHP * (e.Def.Boss and 0.012 or 0.035))) * (1 + (saveState.Upgrades.dmg or 0) * 0.08)
						damageEnemy(e, sDmg, tr.Def.Slow, 1.2, nil, nil, "Bẫy Gai")
						spawnExplosionRing(tr.X, tr.Y, 16, tr.Def.Color)
						tr.Uses -= 1
						tr.Cd = 0.55
					end
					break
				end
			end
			if triggered and tr.Uses <= 0 then
				if tr.Node and tr.Node.Parent then tr.Node:Destroy() end
				table.remove(TD.traps, ti)
			end
		end
	end

	-- Thap tim muc tieu theo TargetMode + huong Buff tu Thap Buff
	for _, t in ipairs(TD.towers) do
		if t.Def.Kind ~= "Buff" then
			t.Cooldown = math.max(0, t.Cooldown - dt)
			local mode = t.TargetMode or "First"
			local bestE, bestVal = nil, nil
			for _, e in ipairs(TD.enemies) do
				if not e.Dead then
					local d = math.sqrt((e.X - t.X)^2 + (e.Y - t.Y)^2)
					if d <= t.Range then
						local val = (mode == "Strong") and e.HP or ((mode == "Weak") and -e.HP or e.Progress)
						if bestVal == nil or val > bestVal then
							bestVal = val
							bestE = e
						end
					end
				end
			end
			if bestE then
				t.Turret.Rotation = math.deg(math.atan2(bestE.Y - t.Y, bestE.X - t.X))
				if t.Cooldown <= 0 then
					local bDmg, bRate = getTowerBuffMults(t)
					t.Cooldown = math.max(0.15, t.FireRate * bRate)
					fireTower(t, bestE, t.Damage * bDmg)
				end
			end
		end
	end

	-- Cap nhat dan bay & va cham
	for i = #TD.projectiles, 1, -1 do
		local p = TD.projectiles[i]
		if p.Target and not p.Target.Dead then
			p.TX, p.TY = p.Target.X, p.Target.Y
		end
		local dx, dy = p.TX - p.X, p.TY - p.Y
		local dist = math.sqrt(dx * dx + dy * dy)
		local step = p.Speed * dt
		if dist <= step + 4 then
			if p.Splash then
				playSfx("explosion", 1.15)
				spawnExplosionRing(p.TX, p.TY, p.Splash, p.Color)
				for _, e in ipairs(TD.enemies) do
					if not e.Dead then
						local ed = math.sqrt((e.X - p.TX)^2 + (e.Y - p.TY)^2)
						if ed <= p.Splash then
							damageEnemy(e, p.Damage, p.Slow, p.SlowDur, p.PoisonDps, p.PoisonDur, p.SrcName)
						end
					end
				end
			elseif p.Target and not p.Target.Dead then
				if p.Slow then spawnExplosionRing(p.TX, p.TY, 18, THEME.TextCyan) end
				if p.PoisonDps then spawnExplosionRing(p.TX, p.TY, 16, THEME.TextGreen) end
				damageEnemy(p.Target, p.Damage, p.Slow, p.SlowDur, p.PoisonDps, p.PoisonDur, p.SrcName)
			end
			if p.Node and p.Node.Parent then p.Node:Destroy() end
			table.remove(TD.projectiles, i)
		else
			p.X += (dx / dist) * step
			p.Y += (dy / dist) * step
			p.Node.Position = UDim2.fromOffset(p.X, p.Y)
			if not p.Splash then p.Node.Rotation = math.deg(math.atan2(dy, dx)) end
		end
	end

	-- Kiem tra hoan thanh dot quai + thuong Sao + Tu Dong Goi Dot
	if not TD.waveSpawning and #TD.enemies == 0 and TD.wave > 0 then
		if (not TD.map.Endless) and TD.wave >= TD.map.Waves then
			finishMatch(true)
		elseif UI.waveBtnLbl.Text == "ĐANG CHIẾN..." then
			local bonus = 30 + TD.wave * 8
			TD.gold += bonus
			local wStars = math.max(2, math.floor(2 * (getDiffDef(saveState.Difficulty).StarMult or 1) + 0.5))
			saveState.Stars += wStars
			if TD.wave > (saveState.BestWave[TD.map.Id] or 0) then
				saveState.BestWave[TD.map.Id] = TD.wave
			end
			saveData()
			TD.autoTimer = 2.4
			showToast("Xong Đợt " .. TD.wave .. "! Thưởng +" .. bonus .. " Vàng & +" .. wStars .. " Sao", THEME.TextGreen, 2.2)
			updateHUD()
		elseif TD.autoWave then
			TD.autoTimer -= dt
			if TD.autoTimer <= 0 then
				startNextWave()
			end
		end
	end
end))

screenGui.Destroying:Connect(function()
	TD.active = false
	for _, c in ipairs(connections) do
		if c.Connected then c:Disconnect() end
	end
end)
end)
if not _ok then
	warn("[ThuThanh2D v5.2 ERROR]: " .. tostring(_err))
end
