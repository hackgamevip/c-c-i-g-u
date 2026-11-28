-- ============================================================
-- THU THANH 2D (TOWER DEFENSE) v8.4 - KHO DO + NUT TRON 3D + HOI MAU THANH + 3 SAO MAP + TOGGLE + XAC NHAN THOAT
-- Full-Screen Mobile & PC | Tu dong luu ky luc | Phim tat PC: RightShift
-- ============================================================
local _ok, _err = pcall(function()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
while not player do
	task.wait(0.1)
	player = Players.LocalPlayer
end
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
if oldGui then pcall(function() oldGui:Destroy() end) end

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
		Id = "heroic_boss", Name = "Đấu Trường Cuối Cùng", Diff = "Siêu Khó", Waves = 10, StartGold = 520, StartLives = 15,
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

local STAGE_PATH_VARIANTS = {
	{ {1, 2}, {12, 2}, {12, 5}, {3, 5}, {3, 8}, {14, 8} },
	{ {1, 7}, {3, 7}, {3, 2}, {6, 2}, {6, 7}, {9, 7}, {9, 2}, {12, 2}, {12, 6}, {14, 6} },
	{ {1, 8}, {11, 8}, {11, 5}, {2, 5}, {2, 2}, {14, 2} },
	{ {1, 2}, {3, 2}, {3, 8}, {6, 8}, {6, 3}, {10, 3}, {10, 8}, {13, 8}, {13, 4}, {14, 4} },
	{ {1, 2}, {6, 2}, {6, 5}, {2, 5}, {2, 8}, {9, 8}, {9, 2}, {14, 2} },
	{ {1, 4}, {3, 4}, {3, 1}, {7, 1}, {7, 6}, {4, 6}, {4, 9}, {11, 9}, {11, 3}, {14, 3} },
	{ {1, 5}, {4, 5}, {4, 8}, {11, 8}, {11, 5}, {7, 5}, {7, 2}, {14, 2} },
	{ {1, 1}, {5, 1}, {5, 4}, {9, 4}, {9, 8}, {13, 8}, {13, 3}, {14, 3} },
}

local TOWERS = {
	{
		Id = "archer", Name = "Cung Thủ", Cost = 65, UpgradeCost = 65,
		Damage = 18, Range = 134, FireRate = 0.62, ProjSpeed = 450,
		Kind = "Arrow", BaseCol = Color3.fromRGB(64, 176, 92), TopCol = Color3.fromRGB(168, 118, 56),
		Accent = Color3.fromRGB(214, 186, 86), Desc = "Bắn nhanh, tầm rộng, mở trận ổn định"
	},
	{
		Id = "frost", Name = "Băng Giá", Cost = 95, UpgradeCost = 90,
		Damage = 13, Range = 128, FireRate = 0.90, ProjSpeed = 360, Slow = 0.38, SlowDur = 2.3,
		Kind = "Frost", BaseCol = Color3.fromRGB(54, 152, 212), TopCol = Color3.fromRGB(132, 206, 224),
		Accent = Color3.fromRGB(182, 222, 232), Desc = "Làm chậm quái 38% giữ nhịp phòng thủ"
	},
	{
		Id = "cannon", Name = "Đại Bác", Cost = 125, UpgradeCost = 105,
		Damage = 42, Range = 122, FireRate = 1.38, ProjSpeed = 300, Splash = 58,
		Kind = "Bomb", BaseCol = Color3.fromRGB(196, 82, 54), TopCol = Color3.fromRGB(58, 62, 76),
		Accent = Color3.fromRGB(218, 128, 48), Desc = "Nổ diện rộng dọn đàn quái đông"
	},
	{
		Id = "poison", Name = "Tháp Độc", Cost = 130, UpgradeCost = 110,
		Damage = 16, Range = 132, FireRate = 0.88, ProjSpeed = 370, PoisonDps = 14, PoisonDur = 3.5,
		Kind = "Poison", BaseCol = Color3.fromRGB(48, 168, 72), TopCol = Color3.fromRGB(32, 92, 46),
		Accent = Color3.fromRGB(118, 224, 72), Desc = "Độc rút máu bền bỉ khắc chế quái trâu"
	},
	{
		Id = "buff", Name = "Tháp Buff", Cost = 155, UpgradeCost = 140,
		Damage = 0, Range = 132, FireRate = 1.0, BuffDmg = 0.20, BuffRate = 0.14,
		Kind = "Buff", BaseCol = Color3.fromRGB(204, 156, 38), TopCol = Color3.fromRGB(226, 204, 102),
		Accent = Color3.fromRGB(232, 212, 84), Desc = "Tăng +20% ST hoặc Tầm cho tháp quanh nó"
	},
	{
		Id = "tesla", Name = "Lôi Điện", Cost = 180, UpgradeCost = 155,
		Damage = 32, Range = 138, FireRate = 0.94, Chain = 3,
		Kind = "Lightning", BaseCol = Color3.fromRGB(142, 72, 212), TopCol = Color3.fromRGB(214, 192, 62),
		Accent = Color3.fromRGB(112, 204, 228), Desc = "Sét chuỗi giật lan 3 mục tiêu liên tiếp"
	},
	{
		Id = "laser", Name = "Laze Thần", Cost = 260, UpgradeCost = 225,
		Damage = 82, Range = 162, FireRate = 1.15,
		Kind = "Laser", BaseCol = Color3.fromRGB(204, 58, 118), TopCol = Color3.fromRGB(224, 184, 54),
		Accent = Color3.fromRGB(228, 92, 168), Desc = "Tia laze xuyên phá diệt Boss cực nhanh"
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
	{ Id = "easy",   Name = "Dễ",          Lives = 40, HpMult = 0.90, SpdMult = 0.98, StarMult = 1.0, Color = Color3.fromRGB(82, 206, 108),  Top = Color3.fromRGB(64, 196, 92),  Bot = Color3.fromRGB(28, 134, 54) },
	{ Id = "normal", Name = "Bình Thường", Lives = 25, HpMult = 1.30, SpdMult = 1.05, StarMult = 1.3, Color = Color3.fromRGB(84, 178, 228),  Top = Color3.fromRGB(54, 152, 214), Bot = Color3.fromRGB(28, 92, 164) },
	{ Id = "hard",   Name = "Khó",         Lives = 10, HpMult = 1.85, SpdMult = 1.12, StarMult = 1.8, Color = Color3.fromRGB(228, 148, 56),  Top = Color3.fromRGB(218, 94, 52),  Bot = Color3.fromRGB(154, 42, 32) },
}

local function getDiffDef(id)
	for _, d in ipairs(DIFFICULTIES) do
		if d.Id == id then return d end
	end
	return DIFFICULTIES[2]
end

local ENEMIES = {
	slime            = { Name = "Slime Xanh",        HP = 105,   Speed = 56, Reward = 10,  Size = 22, Color = Color3.fromRGB(72, 198, 96),   Eye = Color3.fromRGB(20, 26, 22),   Damage = 1 },
	goblin           = { Name = "Yêu Tinh Nhanh",    HP = 78,    Speed = 90, Reward = 12,  Size = 20, Color = Color3.fromRGB(214, 156, 48),  Eye = Color3.fromRGB(196, 46, 46),  Damage = 1 },
	spider           = { Name = "Nhện Bóng Đêm",     HP = 115,   Speed = 84, Reward = 14,  Size = 22, Color = Color3.fromRGB(46, 38, 56),    Eye = Color3.fromRGB(228, 48, 54),  Damage = 1 },
	bat              = { Name = "Dơi Ma Tím",        HP = 95,    Speed = 96, Reward = 14,  Size = 21, Color = Color3.fromRGB(118, 54, 178),  Eye = Color3.fromRGB(232, 92, 134), Damage = 1 },
	skeleton         = { Name = "Xương Khô",         HP = 175,   Speed = 60, Reward = 15,  Size = 23, Color = Color3.fromRGB(208, 212, 220), Eye = Color3.fromRGB(22, 24, 34),   Damage = 1 },
	knight           = { Name = "Hiệp Sĩ Giáp",      HP = 310,   Speed = 44, Reward = 20,  Size = 26, Color = Color3.fromRGB(122, 136, 162), Eye = Color3.fromRGB(76, 188, 216), Damage = 2 },
	scorpion         = { Name = "Bọ Cạp Sa Mạc",     HP = 350,   Speed = 55, Reward = 22,  Size = 26, Color = Color3.fromRGB(186, 128, 54),  Eye = Color3.fromRGB(64, 212, 86),  Damage = 2 },
	wraith           = { Name = "Ma Bóng Đêm",       HP = 210,   Speed = 76, Reward = 19,  Size = 24, Color = Color3.fromRGB(148, 86, 212),  Eye = Color3.fromRGB(220, 212, 228),Alpha = 0.25, Damage = 2 },
	orc              = { Name = "Chằn Tinh Orc",     HP = 520,   Speed = 42, Reward = 28,  Size = 28, Color = Color3.fromRGB(74, 132, 54),   Eye = Color3.fromRGB(224, 68, 48),  Damage = 2 },
	golem            = { Name = "Khổng Lồ Đá",       HP = 740,   Speed = 34, Reward = 36,  Size = 30, Color = Color3.fromRGB(156, 88, 62),   Eye = Color3.fromRGB(224, 182, 52), Damage = 3 },
	boss             = { Name = "Rồng Hắc Ám",       HP = 2400,  Speed = 36, Reward = 130, Size = 36, Color = Color3.fromRGB(198, 42, 66),   Eye = Color3.fromRGB(232, 196, 56), Boss = true, Damage = 5 },
	cerberus         = { Name = "Chó Địa Ngục 3 Đầu",HP = 3600,  Speed = 40, Reward = 180, Size = 38, Color = Color3.fromRGB(178, 36, 42),   Eye = Color3.fromRGB(234, 186, 48), Boss = true, Damage = 5 },
	lich_boss        = { Name = "Pháp Sư Xương",     HP = 4400,  Speed = 34, Reward = 210, Size = 38, Color = Color3.fromRGB(54, 34, 78),    Eye = Color3.fromRGB(118, 232, 134),Boss = true, HeroBoss = true, Damage = 6 },
	titan_boss       = { Name = "Chúa Quỷ Dung Nham",HP = 5400,  Speed = 32, Reward = 240, Size = 39, Color = Color3.fromRGB(142, 34, 28),   Eye = Color3.fromRGB(236, 152, 44), Boss = true, Damage = 6 },
	dark_knight_boss = { Name = "Hắc Kỵ Sĩ Đen",     HP = 6800,  Speed = 36, Reward = 290, Size = 40, Color = Color3.fromRGB(36, 32, 46),    Eye = Color3.fromRGB(224, 48, 72),  Boss = true, Damage = 7 },
	phoenix_boss     = { Name = "Phượng Hoàng Lửa",  HP = 8400,  Speed = 38, Reward = 360, Size = 41, Color = Color3.fromRGB(218, 86, 36),   Eye = Color3.fromRGB(238, 214, 72), Boss = true, HeroBoss = true, Damage = 8 },
	hero_boss        = { Name = "Đế Vương Hư Không", HP = 11500, Speed = 30, Reward = 450, Size = 42, Color = Color3.fromRGB(48, 22, 88),    Eye = Color3.fromRGB(236, 196, 64), Boss = true, HeroBoss = true, Damage = 10 },
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
	Hide3D = false,
	MapStars = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 },
	StageUnlocked = { meadow = 1, desert = 1, citadel = 1, heroic_boss = 1, endless = 1 },
	StageStars = {},
	StageDiffUnlocked = {},
	SelectedStage = 1,
	Bag = { goldbag = 2 },
	SkillStock = { meteor = 3, bliz = 3, void = 2, spike = 4, mine = 3 },
	SelectedMap = 1,
	Difficulty = "normal",
	OwnedSkins = { default = true },
	EquippedSkin = "default",
	UsedCodes = {},
	FirstCleared = {},
	Perfect3Star = {},
	Quests = nil,
}

local function createDefaultQuests()
	return {
		{ Id = "kills",   Track = "kills", Title = "Tiêu diệt 50 quái vật",          Goal = 50,   Progress = 0, Reward = 10, Claimed = false },
		{ Id = "boss",    Track = "boss",  Title = "Hạ gục 2 Boss bất kỳ",           Goal = 2,    Progress = 0, Reward = 12, Claimed = false },
		{ Id = "skill",   Track = "skill", Title = "Dùng kỹ năng hoặc bẫy 5 lần",    Goal = 5,    Progress = 0, Reward = 8,  Claimed = false },
		{ Id = "build",   Track = "build", Title = "Xây dựng 12 tòa tháp",           Goal = 12,   Progress = 0, Reward = 8,  Claimed = false },
		{ Id = "tier3",   Track = "tier3", Title = "Nâng 3 tháp lên Cấp 3",          Goal = 3,    Progress = 0, Reward = 10, Claimed = false },
		{ Id = "wave",    Track = "wave",  Title = "Vượt qua 10 đợt quái",           Goal = 10,   Progress = 0, Reward = 12, Claimed = false },
		{ Id = "win",     Track = "win",   Title = "Chiến thắng 2 ải bất kỳ",        Goal = 2,    Progress = 0, Reward = 18, Claimed = false },
		{ Id = "kills2",  Track = "kills", Title = "Tiêu diệt 250 quái vật",         Goal = 250,  Progress = 0, Reward = 25, Claimed = false },
		{ Id = "kills3",  Track = "kills", Title = "Tiêu diệt 1,000 quái vật",       Goal = 1000, Progress = 0, Reward = 60, Claimed = false },
		{ Id = "boss2",   Track = "boss",  Title = "Hạ gục 10 Boss bất kỳ",          Goal = 10,   Progress = 0, Reward = 35, Claimed = false },
		{ Id = "skill2",  Track = "skill", Title = "Dùng kỹ năng hoặc bẫy 25 lần",   Goal = 25,   Progress = 0, Reward = 22, Claimed = false },
		{ Id = "build2",  Track = "build", Title = "Xây dựng 50 tòa tháp",           Goal = 50,   Progress = 0, Reward = 25, Claimed = false },
		{ Id = "tier3_2", Track = "tier3", Title = "Nâng 15 tháp lên Cấp 3",         Goal = 15,   Progress = 0, Reward = 30, Claimed = false },
		{ Id = "wave2",   Track = "wave",  Title = "Vượt qua 50 đợt quái",           Goal = 50,   Progress = 0, Reward = 40, Claimed = false },
		{ Id = "win2",    Track = "win",   Title = "Chiến thắng 10 ải bất kỳ",       Goal = 10,   Progress = 0, Reward = 55, Claimed = false },
	}
end
saveState.Quests = createDefaultQuests()

local SHOP_SKILLS = {
	{ Id = "meteor",  Kind = "skill", Name = "Thiên Thạch",    Cost = 4, Img = "sk_meteor",  Desc = "Mưa thiên thạch giáng xuống toàn bản đồ", Color = Color3.fromRGB(224, 96, 46) },
	{ Id = "bliz",    Kind = "skill", Name = "Bão Tuyết",      Cost = 4, Img = "sk_bliz",    Desc = "Đóng băng toàn bộ quái trong 4 giây",     Color = Color3.fromRGB(54, 178, 228) },
	{ Id = "void",    Kind = "skill", Name = "Hố Đen",         Cost = 5, Img = "sk_void",    Desc = "Hút và nghiền nát quái trong 3.2 giây",   Color = Color3.fromRGB(168, 56, 224) },
	{ Id = "spike",   Kind = "skill", Name = "Bẫy Gai",        Cost = 3, Img = "icon_spike", Desc = "Đặt trên đường đi làm chậm & gây ST",     Color = Color3.fromRGB(142, 62, 212) },
	{ Id = "mine",    Kind = "skill", Name = "Mìn Nổ",         Cost = 4, Img = "icon_mine",  Desc = "Nổ lớn khi quái giẫm lên trên đường",     Color = Color3.fromRGB(214, 72, 46) },
	{ Id = "goldbag", Kind = "bag",   Name = "Túi Vàng Khẩn",  Cost = 5, Img = "icon_goldbag",  Desc = "Dùng trong trận nhận ngay +250 Vàng",     Color = Color3.fromRGB(232, 186, 46) },
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
			if type(tbl.Hide3D) == "boolean" then saveState.Hide3D = tbl.Hide3D end
			if type(tbl.StageUnlocked) == "table" then for k, v in pairs(tbl.StageUnlocked) do saveState.StageUnlocked[k] = math.clamp(tonumber(v) or 1, 1, 7) end end
			if type(tbl.StageStars) == "table" then for k, v in pairs(tbl.StageStars) do saveState.StageStars[k] = math.clamp(tonumber(v) or 0, 0, 3) end end
			if type(tbl.StageDiffUnlocked) == "table" then for k, v in pairs(tbl.StageDiffUnlocked) do saveState.StageDiffUnlocked[k] = math.clamp(tonumber(v) or 1, 1, 3) end end
			if type(tbl.SkillStock) == "table" then for k, v in pairs(tbl.SkillStock) do saveState.SkillStock[k] = math.max(0, math.floor(tonumber(v) or 0)) end end
			if type(tbl.UsedCodes) == "table" then for k, v in pairs(tbl.UsedCodes) do if v == true then saveState.UsedCodes[k] = true end end end
			if type(tbl.FirstCleared) == "table" then for k, v in pairs(tbl.FirstCleared) do if v == true then saveState.FirstCleared[k] = true end end end
			if type(tbl.Perfect3Star) == "table" then for k, v in pairs(tbl.Perfect3Star) do if v == true then saveState.Perfect3Star[k] = true end end end
			if saveState.Difficulty == "insane" or saveState.Difficulty == "hell" then saveState.Difficulty = "hard" end
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
local getMapImageAsset
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

local function darkenCol(col, factor)
	return Color3.new(
		math.clamp(col.R * factor, 0, 1),
		math.clamp(col.G * factor, 0, 1),
		math.clamp(col.B * factor, 0, 1)
	)
end

local function lightenCol(col, amt)
	return Color3.new(
		math.clamp(col.R + (1 - col.R) * amt, 0, 1),
		math.clamp(col.G + (1 - col.G) * amt, 0, 1),
		math.clamp(col.B + (1 - col.B) * amt, 0, 1)
	)
end

local function add3DGloss(parent, radius, z, alpha)
	local gl = Instance.new("Frame")
	gl.Size = UDim2.new(1, -6, 0, math.min(20, math.max(8, (radius or 10))))
	gl.Position = UDim2.fromOffset(3, 2)
	gl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	gl.BackgroundTransparency = alpha or 0.84
	gl.BorderSizePixel = 0
	gl.ZIndex = z
	gl.Parent = parent
	addCorner(gl, math.max(4, (radius or 10) - 2))
	local gr = Instance.new("UIGradient")
	gr.Rotation = 90
	gr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
	gr.Parent = gl
	return gl
end

local function makeArcadeBtn(parent, text, size, pos, c1, c2, radius, opts)
	opts = opts or {}
	local depth = opts.Depth or 4
	local z = opts.ZIndex or 4

	local btn = Instance.new("TextButton")
	btn.Size = size
	if pos then btn.Position = pos end
	-- Khoi de 3D dam mau theo sac nut (extruded 3D plinth)
	btn.BackgroundColor3 = darkenCol(c2, 0.56)
	btn.BackgroundTransparency = 0
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
	addGradient(face, lightenCol(c1, 0.12), c2, 90)

	-- Anh sang phan chieu kinh 3D phia tren
	local shine = Instance.new("Frame")
	shine.Size = UDim2.new(1, -8, 0.42, 0)
	shine.Position = UDim2.fromOffset(4, 2)
	shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shine.BackgroundTransparency = 0.72
	shine.BorderSizePixel = 0
	shine.ZIndex = z + 2
	shine.Parent = face
	addCorner(shine, math.max(4, (radius or 10) - 2))
	local sGrad = Instance.new("UIGradient")
	sGrad.Rotation = 90
	sGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
	sGrad.Parent = shine

	-- Vien phan quang duoi mat nut 3D
	local rim = Instance.new("Frame")
	rim.Size = UDim2.new(1, -12, 0, 2)
	rim.Position = UDim2.new(0, 6, 1, -3)
	rim.BackgroundColor3 = lightenCol(c1, 0.35)
	rim.BackgroundTransparency = 0.55
	rim.BorderSizePixel = 0
	rim.ZIndex = z + 2
	rim.Parent = face
	addCorner(rim, 2)

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

	-- Bong do 3D mem duoi chan thap
	local shad = Instance.new("Frame")
	shad.Size = UDim2.fromScale(0.98, 0.72)
	shad.Position = UDim2.fromScale(0.52, 0.72)
	shad.AnchorPoint = Vector2.new(0.5, 0.5)
	shad.BackgroundColor3 = Color3.fromRGB(6, 8, 16)
	shad.BackgroundTransparency = 0.45
	shad.BorderSizePixel = 0
	shad.ZIndex = zBase
	shad.Parent = root
	addCorner(shad, 99)

	-- Khoi de noi 3D (extruded pedestal) tao chieu sau
	local bRad = (towerDef.Id == "tesla" or towerDef.Id == "frost") and 12 or 7
	local plinth = Instance.new("Frame")
	plinth.Size = UDim2.fromScale(0.84, 0.82)
	plinth.Position = UDim2.fromScale(0.5, 0.56)
	plinth.AnchorPoint = Vector2.new(0.5, 0.5)
	plinth.BackgroundColor3 = darkenCol(towerDef.BaseCol, 0.48)
	plinth.BorderSizePixel = 0
	plinth.ZIndex = zBase + 1
	plinth.Parent = root
	addCorner(plinth, bRad)

	-- Mat tren de thap 3D co anh sang noi khoi
	local base = Instance.new("Frame")
	base.Size = UDim2.fromScale(0.84, 0.80)
	base.Position = UDim2.fromScale(0.5, 0.46)
	base.AnchorPoint = Vector2.new(0.5, 0.5)
	base.BackgroundColor3 = towerDef.BaseCol
	base.BorderSizePixel = 0
	base.ZIndex = zBase + 1
	base.Parent = root
	addCorner(base, bRad)
	addStroke(base, THEME.Outline, 1.8)
	local bGloss = Instance.new("Frame")
	bGloss.Size = UDim2.fromScale(0.76, 0.30)
	bGloss.Position = UDim2.fromScale(0.5, 0.18)
	bGloss.AnchorPoint = Vector2.new(0.5, 0.5)
	bGloss.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bGloss.BackgroundTransparency = 0.78
	bGloss.BorderSizePixel = 0
	bGloss.ZIndex = zBase + 2
	bGloss.Parent = base
	addCorner(bGloss, 99)

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

	-- Than quai 3D noi khoi (do bong 135 do + dom phan quang)
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
	local bodyStroke = addStroke(body, def.Boss and THEME.TextGold or THEME.Outline, def.Boss and 2.4 or 1.6)
	local volGrad = Instance.new("UIGradient")
	volGrad.Rotation = 135
	volGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(224, 224, 232)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(132, 132, 152)),
	})
	volGrad.Parent = body
	local spec3d = Instance.new("Frame")
	spec3d.Size = UDim2.fromScale(0.34, 0.20)
	spec3d.Position = UDim2.fromScale(0.32, 0.22)
	spec3d.AnchorPoint = Vector2.new(0.5, 0.5)
	spec3d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	spec3d.BackgroundTransparency = 0.68
	spec3d.BorderSizePixel = 0
	spec3d.ZIndex = zBase + 3
	spec3d.Parent = body
	addCorner(spec3d, 99)

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

function GFX.buildObstacleSprite(parent, kind, zBase, mapId)
	mapId = mapId or "meadow"
	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(CELL - 4, CELL - 4)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.BackgroundTransparency = 1
	root.ZIndex = zBase
	root.Parent = parent

	-- Bong do 3D duoi chan vat can
	local obShad = Instance.new("Frame")
	obShad.Size = UDim2.fromOffset(26, 10)
	obShad.Position = UDim2.fromScale(0.54, 0.88)
	obShad.AnchorPoint = Vector2.new(0.5, 0.5)
	obShad.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
	obShad.BackgroundTransparency = 0.45
	obShad.BorderSizePixel = 0
	obShad.ZIndex = zBase
	obShad.Parent = root
	addCorner(obShad, 99)

	if kind == "tree" then
		if mapId == "desert" then
			-- Sa Mac: Cay chet kho (than nau sam + canh kho tro trui, khong la)
			local trunk = Instance.new("Frame")
			trunk.Size = UDim2.fromOffset(7, 22)
			trunk.Position = UDim2.fromScale(0.5, 0.62)
			trunk.AnchorPoint = Vector2.new(0.5, 0.5)
			trunk.BackgroundColor3 = Color3.fromRGB(98, 66, 44)
			trunk.BorderSizePixel = 0
			trunk.ZIndex = zBase + 1
			trunk.Parent = root
			addCorner(trunk, 3)
			addStroke(trunk, THEME.Outline, 1.4)
			addGradient(trunk, Color3.fromRGB(128, 86, 56), Color3.fromRGB(68, 44, 28), 0)

			for _, br in ipairs({{0.32, 0.42, -38, 12}, {0.68, 0.36, 36, 13}, {0.38, 0.24, -22, 9}}) do
				local b = Instance.new("Frame")
				b.Size = UDim2.fromOffset(4, br[4])
				b.Position = UDim2.fromScale(br[1], br[2])
				b.AnchorPoint = Vector2.new(0.5, 0.5)
				b.Rotation = br[3]
				b.BackgroundColor3 = Color3.fromRGB(106, 72, 48)
				b.BorderSizePixel = 0
				b.ZIndex = zBase + 1
				b.Parent = root
				addCorner(b, 2)
				addStroke(b, THEME.Outline, 1.2)
			end
		elseif mapId == "citadel" then
			-- Thanh Tri Hac Am: Cay ma kho xuong xau + dom lua tim
			local trunk = Instance.new("Frame")
			trunk.Size = UDim2.fromOffset(8, 22)
			trunk.Position = UDim2.fromScale(0.5, 0.62)
			trunk.AnchorPoint = Vector2.new(0.5, 0.5)
			trunk.BackgroundColor3 = Color3.fromRGB(58, 48, 74)
			trunk.BorderSizePixel = 0
			trunk.ZIndex = zBase + 1
			trunk.Parent = root
			addCorner(trunk, 3)
			addStroke(trunk, THEME.Outline, 1.4)
			for _, br in ipairs({{0.30, 0.40, -42, 13}, {0.70, 0.38, 40, 13}}) do
				local b = Instance.new("Frame")
				b.Size = UDim2.fromOffset(4, br[4])
				b.Position = UDim2.fromScale(br[1], br[2])
				b.AnchorPoint = Vector2.new(0.5, 0.5)
				b.Rotation = br[3]
				b.BackgroundColor3 = Color3.fromRGB(68, 56, 88)
				b.BorderSizePixel = 0
				b.ZIndex = zBase + 1
				b.Parent = root
				addCorner(b, 2)
				addStroke(b, THEME.Outline, 1.2)
			end
			local wisp = Instance.new("Frame")
			wisp.Size = UDim2.fromOffset(7, 7)
			wisp.Position = UDim2.fromScale(0.32, 0.28)
			wisp.BackgroundColor3 = Color3.fromRGB(186, 82, 232)
			wisp.BorderSizePixel = 0
			wisp.ZIndex = zBase + 2
			wisp.Parent = root
			addCorner(wisp, 99)
		else
			-- Thao Nguyen / Dau Truong / Vo Tan: Cay 3D tan 2 tang theo mau ban do
			local c1 = (mapId == "heroic_boss") and Color3.fromRGB(214, 158, 38) or ((mapId == "endless") and Color3.fromRGB(128, 54, 198) or Color3.fromRGB(44, 148, 66))
			local c2 = (mapId == "heroic_boss") and Color3.fromRGB(238, 198, 72) or ((mapId == "endless") and Color3.fromRGB(178, 86, 232) or Color3.fromRGB(84, 196, 88))
			local trunk = Instance.new("Frame")
			trunk.Size = UDim2.fromOffset(8, 12)
			trunk.Position = UDim2.fromScale(0.5, 0.78)
			trunk.AnchorPoint = Vector2.new(0.5, 0.5)
			trunk.BackgroundColor3 = (mapId == "endless") and Color3.fromRGB(64, 52, 92) or Color3.fromRGB(118, 74, 42)
			trunk.BorderSizePixel = 0
			trunk.ZIndex = zBase
			trunk.Parent = root
			addCorner(trunk, 3)
			addStroke(trunk, THEME.Outline, 1.4)

			local leaf1 = Instance.new("Frame")
			leaf1.Size = UDim2.fromOffset(26, 22)
			leaf1.Position = UDim2.fromScale(0.5, 0.42)
			leaf1.AnchorPoint = Vector2.new(0.5, 0.5)
			leaf1.BackgroundColor3 = c1
			leaf1.BorderSizePixel = 0
			leaf1.ZIndex = zBase + 1
			leaf1.Parent = root
			addCorner(leaf1, 99)
			addStroke(leaf1, THEME.Outline, 1.6)
			addGradient(leaf1, c2, darkenCol(c1, 0.65), 135)

			local leaf2 = Instance.new("Frame")
			leaf2.Size = UDim2.fromOffset(15, 13)
			leaf2.Position = UDim2.fromScale(0.45, 0.34)
			leaf2.AnchorPoint = Vector2.new(0.5, 0.5)
			leaf2.BackgroundColor3 = c2
			leaf2.BorderSizePixel = 0
			leaf2.ZIndex = zBase + 2
			leaf2.Parent = root
			addCorner(leaf2, 99)
		end
	elseif kind == "cactus" then
		-- Xuong rong sa mac 3D
		local body = Instance.new("Frame")
		body.Size = UDim2.fromOffset(9, 24)
		body.Position = UDim2.fromScale(0.5, 0.58)
		body.AnchorPoint = Vector2.new(0.5, 0.5)
		body.BackgroundColor3 = Color3.fromRGB(58, 158, 62)
		body.BorderSizePixel = 0
		body.ZIndex = zBase + 1
		body.Parent = root
		addCorner(body, 5)
		addStroke(body, THEME.Outline, 1.4)
		local armL = Instance.new("Frame")
		armL.Size = UDim2.fromOffset(10, 6)
		armL.Position = UDim2.fromScale(0.28, 0.52)
		armL.AnchorPoint = Vector2.new(0.5, 0.5)
		armL.BackgroundColor3 = Color3.fromRGB(52, 146, 56)
		armL.BorderSizePixel = 0
		armL.ZIndex = zBase + 1
		armL.Parent = root
		addCorner(armL, 3)
		local armR = Instance.new("Frame")
		armR.Size = UDim2.fromOffset(10, 6)
		armR.Position = UDim2.fromScale(0.72, 0.44)
		armR.AnchorPoint = Vector2.new(0.5, 0.5)
		armR.BackgroundColor3 = Color3.fromRGB(68, 174, 72)
		armR.BorderSizePixel = 0
		armR.ZIndex = zBase + 1
		armR.Parent = root
		addCorner(armR, 3)
	elseif kind == "house" then
		local wCol = (mapId == "desert") and Color3.fromRGB(214, 174, 112) or ((mapId == "citadel") and Color3.fromRGB(78, 72, 102) or Color3.fromRGB(196, 178, 148))
		local rCol = (mapId == "desert") and Color3.fromRGB(186, 112, 46) or ((mapId == "citadel") and Color3.fromRGB(52, 36, 78) or ((mapId == "heroic_boss") and Color3.fromRGB(218, 172, 44) or Color3.fromRGB(186, 62, 56)))
		local wall = Instance.new("Frame")
		wall.Size = UDim2.fromOffset(24, 18)
		wall.Position = UDim2.fromScale(0.5, 0.66)
		wall.AnchorPoint = Vector2.new(0.5, 0.5)
		wall.BackgroundColor3 = wCol
		wall.BorderSizePixel = 0
		wall.ZIndex = zBase
		wall.Parent = root
		addCorner(wall, 3)
		addStroke(wall, THEME.Outline, 1.5)

		local roof = Instance.new("Frame")
		roof.Size = UDim2.fromOffset(30, 14)
		roof.Position = UDim2.fromScale(0.5, 0.32)
		roof.AnchorPoint = Vector2.new(0.5, 0.5)
		roof.BackgroundColor3 = rCol
		roof.BorderSizePixel = 0
		roof.ZIndex = zBase + 1
		roof.Parent = root
		addCorner(roof, 5)
		addStroke(roof, THEME.Outline, 1.6)
		addGradient(roof, lightenCol(rCol, 0.18), darkenCol(rCol, 0.72), 90)

		local win = Instance.new("Frame")
		win.Size = UDim2.fromOffset(7, 7)
		win.Position = UDim2.fromScale(0.5, 0.68)
		win.AnchorPoint = Vector2.new(0.5, 0.5)
		win.BackgroundColor3 = (mapId == "citadel") and Color3.fromRGB(224, 68, 72) or Color3.fromRGB(232, 202, 82)
		win.BorderSizePixel = 0
		win.ZIndex = zBase + 2
		win.Parent = root
		addCorner(win, 2)
		addStroke(win, THEME.Outline, 1.1)
	elseif kind == "crystal" then
		local cr1 = (mapId == "endless") and Color3.fromRGB(186, 72, 236) or ((mapId == "heroic_boss") and Color3.fromRGB(232, 192, 52) or Color3.fromRGB(218, 84, 52))
		local cr2 = (mapId == "endless") and Color3.fromRGB(112, 186, 236) or ((mapId == "heroic_boss") and Color3.fromRGB(244, 224, 128) or Color3.fromRGB(232, 148, 56))
		local c1 = Instance.new("Frame")
		c1.Size = UDim2.fromOffset(14, 24)
		c1.Position = UDim2.fromScale(0.5, 0.5)
		c1.AnchorPoint = Vector2.new(0.5, 0.5)
		c1.Rotation = 14
		c1.BackgroundColor3 = cr1
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
		c2.BackgroundColor3 = cr2
		c2.BorderSizePixel = 0
		c2.ZIndex = zBase
		c2.Parent = root
		addCorner(c2, 4)
		addStroke(c2, THEME.Outline, 1.4)
	else
		local rkCol = (mapId == "desert") and Color3.fromRGB(178, 112, 62) or ((mapId == "citadel") and Color3.fromRGB(72, 68, 96) or Color3.fromRGB(108, 114, 128))
		local r1 = Instance.new("Frame")
		r1.Size = UDim2.fromOffset(26, 20)
		r1.Position = UDim2.fromScale(0.5, 0.56)
		r1.AnchorPoint = Vector2.new(0.5, 0.5)
		r1.BackgroundColor3 = rkCol
		r1.BorderSizePixel = 0
		r1.ZIndex = zBase
		r1.Parent = root
		addCorner(r1, 8)
		addStroke(r1, THEME.Outline, 1.6)
		addGradient(r1, lightenCol(rkCol, 0.22), darkenCol(rkCol, 0.68), 135)

		local r2 = Instance.new("Frame")
		r2.Size = UDim2.fromOffset(14, 10)
		r2.Position = UDim2.fromScale(0.36, 0.42)
		r2.AnchorPoint = Vector2.new(0.5, 0.5)
		r2.BackgroundColor3 = lightenCol(rkCol, 0.30)
		r2.BorderSizePixel = 0
		r2.ZIndex = zBase + 1
		r2.Parent = root
		addCorner(r2, 6)
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
-- ============================================================
-- ANH GOC 5 BAN DO NHUNG TRUC TIEP (PNG + getcustomasset)
-- ============================================================
local MAP_IMG_B64 = {
	meadow = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEUoYxrhnyZdWV8MZt4dYaNbZJug3iMjmSKdZyFgpBBgXiPk3SKhmRofLlkLpqQdmd5c4R4pWWNXoNqdn6Ocm8Zkj6Pe3FgnznAeISgmySogLJXPbBmYZVYrnVhJKKDV29xmYdVJLZteJSLbmlpX0FWvoEsd2vZSp2IZDWiYzN9iOcxj0e8VCTUky4mSapHNpqwCOctmRNao21ThKlHmUVXMuMQjElkfElvk2JVROFVjKqhLLZGtLVUAAP9nCnNVVapxcf9/AP9ePcudyqeGc9beMDdqyYyaOQj/AP9oRLv/f/////8PBy0/P78/IoSqVf/Ydo4AARHy/fP8tgKt+AMtx/z8xwKM6QX811QMt/r7qwEAAAD85VgAivwIqPuV9AUYFFEBlv0FBjH862gnuvslGWxz5QQEaFEDdlFp6v1v2QWz9v00yAf91QH98m0Eh0z8yE/R+f1Q1gRJ1/wCB0j8+tgUFS75tU0WwvxORy0EmFJ05ix0da4vtwvkmwVYOKxOxwfP+gU0KBL1p1BY5P1QQw0GhTktJlP+9jU50/2Q5vwDd2gsJXAOWDIOpywKljEGWKsQtiePiLMvqAu1VRbnm1YIp1IcFmNqVyY60gRxNioJSDIBl5F28/0GWU5sR9anmbSM2/qs6/sJdjGR9v3u/AsCh48uxlIDeIxMuAiSRSURthcFp8yIORH158wKZjEKR0oDhmuXlbPJtCgrGBSyqLLRyMZSKCb+9U8GOC0Epo4JqHE1OScrmA65rDJQOCsHmG1raq6VRBTNubUOtk2nSxJSJRcKSBJ2NBWn6QRLyvyK2ggiFllJOhE3Hog5J4tqKRXKqSQ3NRdJ10mFfLQCV+84I5E11E9q2itx1/uFPCfz17YLNxIEh6xtyQYMt3Hyly7o2MgruVJwRjTPilQIKRS8sTjLZhINWBGtVyQOZhQvhgsGR9EGaWlPZrH65boTqBP9+IsKGBFLyTH9+rATx0xoWRjoyrMKttQpGHRNLKdMqAhq51QrZQ5MhgnUx7ixHpsHAAABAHRSTlP///////7/////////+/////////////////z///+2//z0////////Ef/7/x3/////uf////9bpP//FWb/AQ8DAgK6//////8BlwIBQwRwA//+////////////AP/////+//7///7///////////////////z//v/////////////////////+//////7//////////////v/////////9///////////////////////////////////////////////////////////+/7r+////////uf////////////////////////////////////////////+3/f//////Sy8/rgAAMcdJREFUeNrFnAlAU2e690/2hYRshJ2CuGurvbZ2m+XO3Jm527eiYEAQECHBQBsWQcWkRabFCgYqULREKRpls7KVRUTKDgp1ai1WUUSRoS64FWu19arf87wnCQHBmbnLdx8hCScn5/zO/1ne5z3nGCrYzhb8Ch7+52uvv/7TT+LwmezLCcO/bMujoqJw0a5dUbvgZRRZ8DyDlckT+UP8+uuvvQg7/+0Cex7Kni04+MXXxbDqrvANGzaE/yXb9ZfeJxa16xkjb02sgStZCIHv19PCwRsLfoIjjojw+++wiIgNwPfTAgIyFW4BqBYVteG/h8wKGO4eBeq9OBXuV8GvRbmHE7S0H/miL7777vPP4Ye2L4h9990X9vYd2hffWV58Z104d+53lge7xXafstsWWZG2L0TCNCvea8H/PBnuV8Gvu0dF+EX4pfEdQn5ISloxgyVNeWvmNZ9ZJ4nYjCt9H+IsrEW8qAk6yuLTn9x3gWxpopDvf/hhEkSSdaNJzzF4d8VfWse6xZkIk5J+COGPA90u99eDfzsBR7NFRAgdAO2HH/4KNf52e75w8D7u+XuHDyx0C6xwC8Cnu8IjxkUHCRuu9A7YkSNHQkJCyCN5eMdiR4jZ/WF5FYJr44N1FevfxBxoC5nYjr19b93zERHk7S7w7Is03K+DX3OHmpnM+DAEVvr+nRAHEf8DsJNo9Avrw/PNsp51TfLKsoW/8EkhX/R5yDuoyvfvfJ4cQeJuAcItWPBiVNQ28TYGfWir+Cf/e+rIB6K3j6A0HzKSN8Do8uKvFgDcWxBw23ZsY7xNTOTq55cs4yiVSoWirk4Bxv7ov8TYbLZSYTUlRwZ6HROhOm87iGDo+wqTgloATt2xTSx6exX+E/r5iZWLMzIGMiZCtXfN32Jr15JH8mot/cezq+Abawdse4jJyMhYqBRHhO8mAhG6qBeDF1C/DhZ/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",
	desert = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEUwGGOSYlklFFxPLKCvllgiE15xXFMVEycYKQpbG3BPK5ZmNtOllIzfZR0vL7lULaybwwD/AP/btKYpJWVXM0tzPbNeYSt/f3+SPmERCTgfWwB/AP9lOsVVVf9qQdGppzPAU1XbtDDOvFbO6QP79GLdwp3///88H4hsHBhEIn9rRt5+tAGHLyS3eYP9yDT8uDP9x1H6pzH91U34mC/7tgP7d1T7xwL8uFD92AL91mcAARYBAjH8pk/RZTL7h1H8l075qgMXFlHzhi8AAAAlGWvueTD898b05cT8+pn+0jn95QiRRhPMWzRRJg6tVxRwNhKxVExWNbCIOlWwSEgoJG3TeIfxhxMCB0ezVy79+anWd3nXlgX95XL+9zHRdxDTdS2JaBbp3MX7ymr95o51Sun55bW5Y4WyXIMcFmJMOySxZRHJWEo2JItnKxTolYnx2rSkSxfDrAdyRxA4KQ7ShivzbFGvejFQNxNrlwLke3eRRiuSVg71lhVxNitJdwqIOilpZC7jiYUnJVR0NEnKaRNuWRSVeDGPtQG0ZiqHPBdUhgbRZk01FgpFGwzZh4z72IxwWyPFaoWshDPphnexdhV3ZhUsVgTmazH0x5GvWHjUlisSEzfShhP0t3KPdhGsyAL0qG5qKiwxHYQ3MxJaKTCNaSrJsQo1ZwpUVg51RSWXQ1WIqwEvRwaTVirQhnLtuY0hGVpRRw+3ZHbyl29kOM2xSzQcIlVMKqh3pAGThUbQl27pehT98hLPd0nJanZcWidQZgbPhU09cwyxdkrTpSvWpnH89lBpLEhDJ5hsQ9fSlFBPQynsyqkwJzGdgTuuhhJpiQO0ZknpqIn76ColFmtMKUp7Ue/I1wb75E+il428qQi20QLYk45gObd0dDy7c3OkvALWp4caSgKahA4SCjUAAH8pCwk6NS5GM5J2bGmyhUuxlA3WpFXauI/ie4J0VlVneAN2dEG4lSvGWhUAAFUAAP8cI2cmF240M1dVAKpcOMRVVaqsOS4oGjBGRE1ckAKs29bcAAABAHRSTlMZ/2Kl/5j/GP8VZff//wPP/wH//v8P/wL/Qf8CsgPO/////////wGD/3C2/////////////////////v7///////7/AP7////////////////+///+///+/////////////////v////7////+/////////////////////////////v////////////////////////////////7////////+//////////////////7////8///7//////////////////////36/////////////7T///////////3///////8uAv///v//////////////AwH/1v8D/AP/////HFyx0QAAKG9JREFUeNrFnAlAG9e57/GSvb3db3uXd/d73y5pGIzMIpAEAhMhDWYRMqaSLAKOBRgiyywSghiEEZupzWoMGLyBzWaMiV0cXK917Nj1kuTFTdIszdabfWmbNve2fd93zsxoJITt9+5r35eANKMzZ37z/5ZzzshMRJLEIvDXXyy/7/nko2DJ92Jiq6MazT0eEtaev2/5X+DZf7mIhxruX/680Prxxx/nfz8uGtkvaSA1DTV4I7QVe6AHSg8IQ1dSUvLFfW8lJf327XBwsHP5F8nJmty42P/nFhcXF24fb3uIaTQA+MXypKSHFsP9Kinii33Jfwyy/4NL0JSUPP9W0m9D4MCl9yUjWlzcg5WNb770xFL20ktPHDr0Evx+4qXAHmKHDh0KbXzoEN15SHgjtDsk7BH2vvRmd2UsCAN4+5Yn/VUQHLA9v08DaLEz70evfpTa008/GrCng+37YD9G+z5vQY3/r2x19JtbUL7kkvuSviGB+2XSW8nAFhdb+cRqYqT1c889B4eslhyPO4R3P/7xP/3TjwW7fZs0/Q/ao6vf30LEex6CTICDVAC2PXF7rq9eHR0dvToI6F6v+9EwdPxH92p46iEIrMeBLkKA+y36dE/uu4cQDVuIHdKTLsVzdykWNVzqUNwVTfCe+F2u5vF99xGwCGS7b19yvebZaPgY0aLfH2qs3LRpU2XAAu83Bdmzzwa/3pM9ixa8a6Zx6Iloirc6+t1cTTJkxUMI92dJy/dlZ/9aYDvUfS3uP2i5aGF2L90ef1+zRQl0j9cnJ7/1q7cB7u0HkrOzs39P2FZH2/bkauobjmT8ie1IQ70m99oQYVt9qD47ed/z4NGICHBq9rfqD5HdT2zJzf12xqp7sARqobu3oq26JwtptzXj2xrNs1EkI9/HYToi6ZcRSQ/sK8n+9RBl2xN39GbCqnuEWwS1hC2BVj07Ww2f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",
	citadel = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEWZYVvolmAjFFqZGCqfVKMpG1hnGy5wX1qZJV3qKiz1Ui/mX1P88CQlFGObXi2umRleKZalndYQCjFOLZ1uWiCnlZ01GCYnHGRmN6fEn84jLZllAGVbHmVPLZXaJE77+qHdxvw8RbZ0WtionVrEbv1iM9CXMIyeOuLaSJz/f//FjQc9PMJiRLF7Vs/UM4P/AP/GkIv///8PBzk/P788HYU/QEZ/AP9aZ6J/f/+iWd+qqv/S0k8DBSspJlQDBBYVF04rKGupibP6twG1lLpsWI5wRu38yAL+1wURFTI1NG4vJo1KKrQnGG+vd/sYI1IXGGtUNctSR4qVZfmKWPZ5Y5RRRXUAAABPN7FpOs6EaphGO2/65f2Rd6vSlvtSRq8JC0k4NY7zqwF3Zac3KLJGOY/HiPxtRtTmuf1wWa1TOeala/ttVswkG00bJWyFaqq0lcX+5AYrJDV3VfXoxf1NOxkoGzRIOyTx1/25hPrlp/2JS/A4NavIwzAtG4iVdxBnWBrHsQpNNlBFK8VVRck2M1dYU4+agrLbtPx1ZtJFKZSoiSXUpvyrisNkTI0bJIpmU3rIqghuGS5GK0iNcptaQexnViUTG4VqPOmJZc+tkywUEhuEO9FlSa9SGDCOFytQQyWPds5uCBGYgQ/8+pCTde89J8NjTHlZU67tChPSChX+/HFLKTlMBhCQCA7+8v56c7E8QoStFCn65y9KKHFTQhr660kyBApaUspmOkyJWayoWPTqBy55ZuSDWtTDmrPFpMVZUXiwWqvzFBglFWvKykbjnP46QXaXh86xlfBsFlHKFysTITxsCE2JRN2NZG6vDBmsiBPLBzPFvSbvFyoYKqlsSU+mednQp7IAAH8pF3BMG2llMbuyBy3Ee/xLQ1ZhLrqwdmvFZLT8+U0AAFUAAP8sCkwzJho4NS5QCCtxGWh7dMyJCEuYhuejTenOTKfQmgfymFVTC05VVaprJmyPag6hfai1lgvSExsJDmk/AH8pGhlVAKpJGE13EhV6dJqKGVIOyskwAAABAHRSTlP//2H//yX/////////k///8v8lm/////8c/+sC/2j/////6P//6////wL//5Wj/wH/AUIErP8C/wL/A//+//7+/v/////////+/v7+/v///v7//////wD+/v////////7//////v/+///////+///////+//////////////7///////////////7///////////////////////////////////////////////////////////////////////////+x//////////////////////////8C0////////////wMB/////////////////wP///////8E/wP/////CCLx3gAALaNJREFUeNrFnAlgG/Wd7w3hLOUq0Gvbvl57vN19e7z7mJn/387YmRnr8Mgay1bskZDHimJJDnKixLHWpMaWY9fYJgk4JjjB7Mvm2ABJCCUEEsgLj5tyLEfLWV63HAV2S7f3vd/ff0a2FCuB7vV+EN2j+czv/v1HnpqWMvnbb+LmP5554QMv+jKusHLx/SvKAw+ceSYhnF3OU7Pw8JtAO/vCF+mjQRLG6F+ZBD9YfisgLsRYkAeI72+rweHFsx/w+VhMkpTTSfV3JRLvrkxO2qjiDbrTtHLLGIbvwpaWXyyG+0XLx4AWOz3Yv44s4MZ8xqehvW+eBPfNljNdNEn5+Ia/vPi6RXKx99pXfis5eZNTfcV1P776zp8THoNx503rwX2n5UKfj+DXPF3XcFWZfBTy7W//9YL875KUXvg2BB+66p8jy0gafnwnVCMFDd/HWn6nDO47LQ/4GDT75o8bljUsKwltdscdXysngvw7kvIXCPOOO+64atk/Sxpov9dtgH2ZMXC2qzsB91+JTZOkq4HW0LBAt8w9KBCSfO1kcV++o4oSllU++y34Ln4TdAPQ3Tc9uF+0XDgQZDHtOoFWDvcvIVf9Np+Cdu4kuhdFzALud1rOHPBxlvuKy7as4XtXb7h57c1r165ds2btzXTvyc1l4r20Zu2aO+9cA1n7W4v3He6WG66+ruEq8ij8vyGmsYEHyO1qYN0zfVznw3UuWt3VOen/h7Dc5XVCcw2gy/gGzgRdDYz7osH1Yc+mV+diSDadEU+GhpKQ2VRJ0smhIdvGG51lYgxADGOAkvzAgPFPEs5ZTPZ8vuHmIEfIfqel5mcwKtezTy8TFr0zxnydTStJrq+v7+1tbg6FQv4FwbNQb29vff311690pemvXOnsnH9QIY2djR9ODOC9JVS0rE7mvoELW35W86dQnM4vd0PhrRjQSLDXEttOf7e/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",
	heroic_boss = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEUWYmOinWdgnteXqMzXoF9hX1ubbCQnYiOfmCYcKmOab1MqlWBfmSVgn6QdX5JdmlscjJ/Z39FfVxyfz9XbnR4jk9bm3JkPKSdJKaoWc9bLeBubspxQbqmS0wf57i2pz5sRBl9MdchOOiGUc5fRzmMhEWEMBjIgEVY3oCEzJpJUMqfesJ0VxflRMZVNPGJjFbHJelJlONpVVaqUyGyJW/BIHmxqav9lyWJty+IqKrhiN9GqVf8RCTw5HoY1GoYAAP9EIXh/H/9oyg1vw5T/f//HpsT///9zTMPOf52t5/zQuLD6twP92Gv5xwUDBjGP1/ru+/gVFE4EmPz05s7aw7WJeKj81goAAACT5vwAABYMpvz4qgLQ9vuy8/yUhq2KdpV1Z5Gql6u1pq5w2PwvuPzp2chzyPpOyPywl5UMC0b86S74x2n79tEmGHDjybWUhpP+5XFrWHFjO8nyuGgCivhOqBMStPvKp5H95Avs1bdSR2vVyMbxuFNruAnFq6orJA1uuPZ2datzdpGJyvUaFWRMLK/HiAvNmG8TdzVKuPtwRuYrJm+VlbA2xP2Ca5PSpnEbFBqmiZBQRlEyNTVpWi7Opg762Sv4x092WEr5xjD++G0shysrqvlva6V0xAbE6/txZXR5eSszN05W0v1wVRG6hgoSFS554/21o5b55U/71k9TM7fVtZL9/bU0lSlSWIyo2/bzty/9+pBImRVVtBGxiGxUVnJuiKnW1c83JI9RZZFsW4fSl1EHd9XRmRH+9lJxlrDvp1JpQdTUqFZFOk2Y8/4WRi3txoytmFI4lxlSd5XEm4kpJ1FPZqZyZTLmuosSaaskGxDPhi4QaTS5tLPLusQROS0GZkf05bYydstQhq1uRjWydjPsly3tmFEwHIcyZpNwhpZyt9XSlS8tKy4wRkwtWC4yaLM3iBWRlpSOprbrlw4Mdo8XhDOji6nwpi4Oh3Jpqg+RdnGyiFDz2IwRVzAxRmoyd61cOcRMpi2IyAYRKFERdrFUVFNxdnOKaHLsuiMEAAABAHRSTlP////////////7///////////////////c/////////w/8////nxhb/92i//9f/wP/5QP//ycC//8DvANNeboBTAP//wL/AaP////////+///+//////8A//7////////////////////+/////v/////+///////////////////////+/v/////+/v///////////////////////////////////v/////+//////////////////7///////////3////////////+/////////////////////////v////////////////////////////////7/////////xHG7bQAANedJREFUeNrFnAlcE/e+6LMHwi6LClhb7Xba03N61ru+d/f7XoYloUkgSpjJjAaDCYkpxRgSUgkqWCM5xBZERDm0VaSUpcgiooWKCy7Vg0vd674vdau1dXm//3+SEBTPue/dez/vJ5BkMvOf7/z2/z9jOFkj8iL8vvraK6EZCzJAFvj+YsmHf8GSjzfl+zbm57NP8/8zEvrKa6/5IPzCGcX22it5iCgjD0v6cyVvRMbe+qwEjet7yW7K8CkilAV8NRiPE4wWmr8gPX3aNN+5pv2XytgjPnXNGQvyXwHrPQ0HG16Bi2FH+MOfguR9+AHxvfC9+q+XP0xDZ07Pyw99LeufRsO9mvVqaAamnyIKiUtDkpmZif/4pcov60bJ7D8v/vfn+SQzc17m2BL36Sd/QngL8l/L+mUw3ItZL4YuALVN+yQuc968F2bPfuGFL5Gs8MsXX3zx+VNi/Hws+SJIfAf6XnwZAHyupIW8D3h5YNoXR+BezPr7UIjN9CkfgbYy2St+Cg2xGZ8V38ax0L4YORa/WvcMHGgR/gRegMxLE4Eb5n3ro+Ngtldx+IiQIcGU80BxLwSZ5gVWgnFZ+TJIAvsEqTzwAt7+S1rDcHDyuHNAB5Z91Q/36iv5wBaSGfC1lDElLSUtWEa/evrlU28Gxnhq68gTlg3+jcsDur9HugO4v8l6JT90t48tM/Mj0bj3/xAka9YEnv3hebImIL5XEO9syD89yprAk/H4yZ/GI4En748LSUFOBQRT8tYsyH/1HxAcBEN+/pIlPraPpqQ/nX1wdnnqdfp/seCct+brNNZ4yyAlvwIhy4HfV4BNxG7+GvJ26L5N77Hyznu8+fPnn4mNje2JieFt2jRx4qZnZeLE996Lh33fiQfhIUFP0OET4b2A4D3hITamDWT+/FI08pkz8Df+PfxmZGhG3jlWRXG7l+Tng9I4L2a9lr8k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",
	endless = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEVkVB4uG19gK6QiEVu0ptdmc5ojDmUeV2gQCjVeYHHXLP307U0pFWwjWZRQMZCRcyObkquoWdaspCsWIt0dTtRgUeIiIikjEqFjEtPTsAx2AHZLLJ1aVKyFNbhDOC1sRMdlkImqVf////83HoUAAP+AHdeGWp2wqEMQCzo/IYRHIF9WGp5fQqZVVf9ris3Cn9DLyyvHwc0AAKozgXpHMH9/f39LhWWGfVG9weQVFlEPB20sJXELBlMEBjIyJownGm74twL6xwWVd9H61wZVRpMYGWoAABWqhvEsGY0AAABwRvH6qQBLKK7+5g5QR66OVvhnOs4UE5E1NpEXCodJN5MuF65iSpZPN65uN/KHZa/yxvwUFTKnaftIKZBuR9OudvsYGKxRKM5wWKxRJ+ojGVkzFsztuPyXZfjUpvuOSPeYe+QuCqtuJ/JSVbM1JqsrJdBwZ9AVJG6bguYzNXVLF9GScbtRBfGON/fMmftUNcsrJ+lsB/ZRNvKOGPnBiAj31/xxFvIpJBKOJvQmCZWtV/psWM+ohRQoJFeadxRIGa9rSLCLZw5QGeuuKPw3N6muN/mIa86uRvpuKM9ZVccyRZXtqf1WR8t2VuvLN/3+6yasGPwWJFY0RqdDN3NYQvLRR/yagdkWJ4o2CcqNCPrJiP3XtPlMBtAaFRrxiP1FQ1DNV/t4dxz95f45N02jfBVrN7V8fCfuZ/1uGdD0ePz0mP39+5TRePvJKf3OaPwbHMkdIcs1MvNoKbN3YrQVNI4vGOeEWbBJGZaHR9OagxREB7eDgzEWNm/vWP2LWNCvlfAmHhCLNtPsSv2HKtapiNobIrNUU5b99v5tU5kpKTTNpwo4B+VLRHRzc9qxhSTz2yZ7d+WmedFYVFZyZ40WRWswVKxBOVdXYrS0pPEAAFUyMjYUOFMYN6ZMORNoVypiWVrRmQrWxvMAAHtDKnt1ZuvMuNj+8zH8+6IWDUwYR45+gCqVhbOpDP2tpsrZ1vD99nIpF287NsVUYsZ/P7+Vkey2lg/GK9E4AAABAHRSTlP/HO5l///o/x3///+i/1j////////u/+/4/wKqDv//tf8DAZoB////WWn/G14D/////wP/hAL////+//7+/v7+///////+/v/+AP7//v///v7//v/+///+/////v/+/v///////v///////////////////v/////////////////////////+/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wP//////////wP//////4v/////////z///BP//rxr8KAAAMLtJREFUeNrFnAdAG2ea97Hj9LJJNtl6W26vl+/K14eRZgzWoEGZFUJIlkAFSwiBkBASwgghdBAJmUAQIFENtjE1hMNhKYfJujs+l3WJneLsJZd6m3LJbrK3uylbbvd7nnckECVl9+77vsdGDCPNzG/+z/M+7/O+M5qM3FW7BX9+cgdFURzHcmDsiq0uciuWtvKzG72yxKwz9g/uuAEA/iUNKGNl6Yfwc8NNFEdJJFKpVEJeP9kkGwzOi0r+olK/yJr0D6Qb4qYMAH/xkzV4GWlsN7AsEOX8XzMp7nyTUxQ5cRlc9pM0uhTcV3JvuYmlRLRHHnzwwe99j7yQXw+mllN/P5j89dnt0z//iMgvYW/609wta+H+BWXD83ok46FnsnZ8gv1Tuu34z7OsLz+RgYBSjvtTEv0rcFtyf8JyINv3Htq+49srtnfv3h/v3Zv668c//vHtP/8HtH/7t3/7hzX285/fTj7+7c3stwDc/vAjRLyfJD2bIcbbT1iIW2nG9h1ZWTvS4fauHnFvOlw63s+B7fb/IBbRDg6dlQFBiXQ/TMGhT4HN8Ay8n5VOt7nt3buW+re2HR+LDwH1GwO0C3YL0S4DddvCsjbq6S+LbFnwa/uKPbD9t7esdEutSltNFtdvk2TL+vaXvyCVsuwtf/hDAvcXuTexNHdoe5LsNxlvfs+QskfWG1mD6w1pnzF8mq3bxyb29Nff+g3KAoDPGCD/3YTSZeT+V3CqjT4k6rZjzw8+Pfl+Ukr+D2wsffohZMva8RvMzjcAXUbuH94CWdr7mx1EtgxIieQgmWtM8v/EOMnXtxO6h6gWlsv9w9yMLbl38DT9FpHtmaclVOamtn4/vyvwmr2l7xteMzmaayGNckcG1wLS/TAjF4XzPYNwz3yB4tYyFYBtSvcpcB/3bua6v9JPH46mTdLteKaFZn+R+5WM3Bt41puBvNuJ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",
	btn_play = "iVBORw0KGgoAAAANSUhEUgAAAKgAAAA6CAMAAAATO+LOAAADAFBMVEUrWR0lZyIpVyOe6GG43JRrjGZ13F+FuFcuUx4/YmE/vz9VAFVmZmZlbXxYfIpFgz9VqlV//3+Wq56dwMX/AP/d8PQXuT2N6k9240r0+Ppp3EgDNRFU10UAAAAqyEcRdjIDShkXukAIhi8DKRAsxjw2lksOlDMzZjcRVSXj6vHP5bMGUxskeDcBGRAMKCva5e0bwkKr8VMPaCsVNzKv7WLj/qOn7VQjuzsbwT0kViqZ8FMXpjnI1tkISiMwSE22yM0puENPyE3N3ObZ/JTN929DmUtNp00qhThPtU0vp0lPZ2zh/ZuVqK860UUrh0ZM0j0smDd1ho0FGyU3U1Wz82UZqUJEV1sAJQKpucS71NhHWmNXdHfN4tkABQAXhUFGzDsJNAwbfEEnPUcSZxoiOjYupTlpeoOouLv1/M8AVQBld3puyVCKmKLEzdHD8lq51uMACQ8YOkIkTCxQkzdJpjtm3D6L2lcblkV6l6MBGAIBGQAAPAAUVSaImJqasbUIKAkONxIaSScsZzI+0D1BS1VVVVVc4U15lZpkuVGCjJCOyVj///8SRxYRSBkURBcYXSY0ZjFMYllKgzJKikpGjUiWt8LC62UGJwYDIwINNQ0KORMXRxoWSyEeVCIdZzEAfwArVSkkYxk/fz9BeTlMsTp/f3901mCWy2eiqbGs13DD45sAAAAADgAAGAAAFgAGLgcAKioAPz8ZPiAcTCMeQkEZUh0AZjMffR0Afz8Af38BiR4qKiojLz4/PwAuShomTx0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABjRehmAAAAwHRSTlMT66D//////27/BAMF///YAwL//wH////////+/wH//v7//v///v/+/v///v7///////3////////+/////v/////////+/v7//v/////+//7///////9m//////8x/P9v///+//////8D//////////////////z/U2YE0P//WLdxzv//A////v//AZW5z7Sz///S/P//NpiYy1DKbt8Dpf8E6P8C//////9Aah8tqgYEbo//0gX/BAL/Bv8EdPmPxFuQAAAN0ElEQVR42sWah3va1hbASefb+2HLF6FxLSweSNhSY4gBMRKDIYQYYzse9Ygdx2n2aGabtGlem9X1uvd8nW/v/d6/9s65kkAY7CZu+vV85ko69+jen864EkY+vin/webCN97btm1b36Zlmy1fbMbajl0n73p7EVE+8LDxvsbeQzfh6PkXXyoUhpui2MK2eNhQNvs6SbVaVarKpgUGf/GJN+eAqQPokzz/+oeFglIUjEhEdCTSImuPO4raPBvMVbV5tL6AGRqyDRNDVgqFvsfnkGoNqI8//3yhUDQ846ZVFWKoNsUdaJtqh9c9dPa3tWjVpoaptp08ibt2a2vTaexKsxHdhhETQkSjWir0vdrBo/99ATDh4vpO3X/js3s+/9nXJp9/9sn99/aJgCoXXnq8EX4HdO6uwugydJ668coOlO07mTibndtd2bp1686mbN1AWO+GFky2t8sObD45FQFUZfgNr0cf+s6v+q4VIegv3H30KOM8OnB0YHx8fGAA/gYH4Y99BgcfaMjgA+xgvKkZ9+x/gTQHGnSkyxWYCWYGhHseOCWKalX5C8+/2/To/+4bjZDIjfGjr2zfuZ2BdhJ7vEHc7RpyZWDAbkA51OWVoaGuIWfrNGtlqKurkxrnAC/tGB9ZJun5wpa5DxzQf/F3XSuqZMuZgcHtWw8c2IoubWccHBgaxLk9ozuojb1OJK5h162Kawl+7V74m5guDhMn9E/yjw2DP9/vGhjceoDjDux0ORGOte5Utz7bHZHx8Z6FoigWX1rEgvLxN+c+LCyLkTODrwDnAeR0MbuaufPVM3a3q+6+uycnk7QSnfs2gPr4pwuCKB7qGtx+AOK+E/PTm91fOeBaacmDQHaZGIW3+R/yvpv890cj4sNdXTtg7YFKsqscXHjmzJk7yGJ7rBsP7J3udsS1xGB538KoKFaj5/lHfPwiOHS5u2vAWZec2j5UhNvhCzfulJs2K0PdcYEYyp8w8k8MR8Rfdg8ySrZgMs4IRRFPndk4je4g0zqkCyvg0j4spheL4nIPlPz4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",
	btn_skill = "iVBORw0KGgoAAAANSUhEUgAAAKgAAAA6CAMAAAATO+LOAAADAFBMVEXq3CtJG1+hlSInEmfTYe7mlAwiCh5dVhtqamq9YNaQmK0fDCwSABsqKlUrDUU+E1MAAP8A//9KGmZiCp1xe6iATQ2qVaqYXbmUm8G9yeD/AP//f//Ku1Pi3Ub///+RFO2JDei3R/jIV/gQAVBTA6uuOPcAAAD5+vxHCJFxCcwuA3QIATilKPbWY/YEAQQoBkybJPIvDkT+yv6XdLLvi/eiGfdOE5JjB7vHS/j4qQTxk/g6BYj62AZ9MbcZAmT5yQV2KrL4swMOF0zp6PRXE6XR1+bmaPhmFrPsdfi9UfewuM0YI1OCM7f692r+0v6Ol7P2mAI4RG80EUiVbLFKFXNyFcuQNtP7ufz75AttdphkbZAtN2cCAAVZY4iKKM/b4vL46jL791JCS3NHVHnDydn3pfqEFNqcQegjK1kHABF5Jct5hKaXO+UAAFUlCjuGC9u7xNc/AD8iBDpaJKpRW4MwClJUOQpyNZWEja/4+JH7+80sC0w6FIorNVlSJJGkq8P8+q4YBCcVAigqGwQyJgdkGpiJQ6zDOfbmWPn88y48AHojKmVEC3JoKYqPaBOZo7mdpMXM0t0NARkbEgImCjlVAFV/AH93M8ZuVA7QmBcAAD8HED07FVI7O3ZcAcBCJgd6g5uEK7myiBjFhRXKpRnHuSjHzeL47FDy63AbBS0YBTEAAH8mCzYlCjA2F0k8FFY7NwtXInFRSRBpSQ5zbBl/f/+MQNiDVRGYhRWiO9ioS86laxCvfBegeLndgvTYtR0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM8ngyAAAAwHRSTlP/2P/z///h/wL//yiLBnWnAQG5////A////wEC//8B//////79/wH//v/+/v////7/k//////+/v////7///7///////7///7//////v//////kv/6/v7//////y3//v////////////9M/v//A5X//wT+///Q//r///+u///+//95jv////////8E//37/////27/pgMC////BP/RBP//////////////XKwCVnhc9P/s////Av////////////+TcQLRAAANlElEQVR42s2aiX/TRhbHTa/ddu/7XtkeWcfIURxIZCcKiiM7cRInOKa2czkJ5CIJIQmEkECBAuUs0AKlpfd9n9vtff9r+95IsiXbodCD7u8T5NHMaOar9+a9kZF9gkt72PHKYsP2shoaFhcbKlVd4xJeg/9qt9Vo2W5ftb3UeqKIIHvdbD5X+VFBmNv+/lovKr61d6utOKhcLNX39lrnrNhrV9l6wbrGvrI3Xu5aHtIZy66Pb42Xmnp7L77/9C8FoTboW4C5aa1QyKf4n1YSz6fyY4X4puNFl1F9LnNevVgYi0qUGpaILVeJkHKl4Tr7gWUYlEqpsfh7c8KfK0GfEYqbevM8BR1dO/2Xe13asmWLdfzqqy3fJtbR6r1xn5rXuUr3nl7LEUKl6NjFtyst+ivhnbVCVDfqj35e19nV2DKA2jxgafN30DavXFVOh42vHZhu/PruNQqo81ufnvtojwv0GeHd02MSJdrdnYDJ1NLY0tLSeH212HKK9qf1UWp1xnGXvQM4J43lQldX3Wlq0FThPeHfZdC9wvFe4KSn686etfi6LHWWVIeyjj+GgsEgHp3TLgZQpxHKF34DZrRB9wjFNeDM3XE21jU9MD0N3p5uaexyCIPWKNZwWAx+R93MlXUIGowTmupdZLHPLFpcKwBn8I5Yy+ZEYtvA5sRmxumiCwZ7L54O3lIBajCGpPHjuBMB6M+FpwsQ7sFYcHqbCIIYanEwnau6c6qq5rp/GIRuJlaqbvOgxs4A6XxOeAxBYYFujVL6ucOZAL93dbopg8EAcgJpoGLYmKcCTwKAEOhGGNbeDYVYAIUlaGHFbvbhUWWNTRoKa4Sf/7XwIIB+JOTGdNIbi01vZpzo9orVhJw/++dJVT3lDGHXg2Klg61YYANt2LBB51gMVnV4jNKUBl737RXeiPNGLnamcQANmthmmdNltVjgoqr+9/W+Vx5Q1Xj5/q8/b6z7prg2GCRYF+NSRI8vCg/6/iFsmtfpZ2eC02jRxLbprk6vewOxuKr+51/HXh98+RFV6b3R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",
	btn_shop = "iVBORw0KGgoAAAANSUhEUgAAAKgAAAA6CAMAAAATO+LOAAADAFBMVEVPLBdxSiZXWGCfd3G4hCrFcUP34GX897XZ1tQ/Pz8AfwA8QD5hNABVMhB/AH9/fwBnb4KCDQOqVQCaYTmKf5Sgn7C/0fLbfSTQoDnQp0z4awL5thj5dQP5pw71+PoAAAD4mQpwFwH3xSb4hQjOOwVuCQCUOhZIGgvSRgp0QyUuCAL86GstGA7q6u/66K2MSCaQl7FRCQByJwamVCfWVAiQRBXR2eYrKC8OCA5tNxHiVAWxucnHydGMJwYXExX4vCPa4+xPJgqwORCFGgNnPCLR1dquRg+oSyZJR02mp7PQZhLLdBP5wB20VhL51TdveI2ZorMRFydpaG44Njg1O0eUVBJ6hJCIh5G5xNBGJyb75FayZBM1IhiwZzFxS0eTUynWhhnhSgNMNTD42ksIAAAPAAB1QwpzU1CvtLv56JaGi6dVWmVbY214iK3rmSIaJDE5Q1FaNBONk5rNLQBXVFpvc3imLAqnjI03AAAoCAE2FQUpHCFEPEXTiCQ0FAFrNQBrXWeGU06dYxGHd3q4dhemrMHbkRzTkyXuqiT89JH++8c5FwZAGghSKQFRJBBUQDR/AAC1dTH02nD//wAdBgACCyIwAgAqBAA3HAY0EgY3NwBHFgFKKg1YMhZVVQCOmMCWocCqVVWxaUKpkY+6yuTJub7ljSP///8aBgAwBgIvDAFVAABMFgpHHQ9FJgtIKQ9cOBldbIxhNxpmMzOXPCOlPSG4cUfBXy7BZi7DvsbCzub/AADhPwLoeSLivFHvy0kAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB1BKBqAAAAwHRSTlOY5/////3///8EAv8/awIC//8D////////////////Af/+/////v7+//7+//7///7///7+//7////+/////f////z9/v7//v7///////7////////////////////+//v/////MUn///////////////3//////v8Er27///9MBP//////////////1XVK0/8C//8BcP9LjI6rBE+QvQP//wP+/////wGLc80DstRwstH/pwX//f/7////Af////8RrmPiAAAOBUlEQVR42s2ah3/aWLbH2b6v9yYDQgYkfHN5IBkhCZBAELDAdgwGG4gh7i3x2InX6WWyM2mTmZ2+02d3dtqWt+1tf1v/tXeuJEBgk8lnJ9ndXzxCt3/vOecewYCLdujFn5Lrlb9799xxS2NdHR8jZUU5br2Y6nawX6HhnGI1D4x2zEPaz4EUu11RNvrbz+k/+uGrhONJJxrt6ivRa2/8ePFf2u3x8YmexkkpAiJXqypiy2wcNzuQK6laJLJaF8ePktU6/iC1Fxc/884aPQT0LZpe/wmZoMAKjKUg8ycT17tVVbbQ/sJLn/nROk1fOgz6JL327GJ7nFWZIM8JiiLCtsciQ3TYpd3aiPmvWzfY+RNnUgTTTGqh3R77wVrP/x3Qb9E3xgAzF2SEuVv/+fs/rL68/d9E29vW1Sr1tH246pFo++Uv/v6/Pj+nACs7/v7YDfqf+0G/Rf9wsZ1VGUa8nl5dPXnyxInVk8dMnQTB5diADtc8IsHEXzy2mv68yDAC2168Amh9FnW1x8Hpyt1RQFxdPTH6ZxTYCPSHuyLHqL9sv+O06E/pd39RyDHCQnp09OXtZ46tnjjhQJ0aGRk66VTvbmrKvI5YSo+kiaa66lQP19SINQNhJRpdEBh1/BfvOi2qv19ggsLd9Ojq9v37JqgDBiZPH43ZVz01RcgcC/cVpkYeTlOj6fToCNAC6cgSy+TG29zaKxboN+g3iN/Z3XT65fve+9vHiOfNZS2rDM4F86SPbHikIob1+Anp+LOWRZ/8+1cjbeC8lx7d/tL9L22fNDlH/gJkkaq/jFwGY7rob9M62FPYTY+efOaZZ46dPPGXwklIfX41yH5BgaeU6xX68iKkgknPCElIpjlHP6VjPUMqPR74s/TArg7StK/EMBPvv0l/G0DPgUFFj+fEiZPmIbp3SxRFlhVv+f5YLovJvPN0y5+sbi/H0LTHXwjmfiUAKP0dYtAlz6idku4KPI9APC8sjXgevOPhS3keiQipb5IJZiPfgRh9hxjUB6Bmkrmn8PrnLl68+MHn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",
	btn_bag = "iVBORw0KGgoAAAANSUhEUgAAAKgAAAA6CAMAAAATO+LOAAADAFBMVEXaniX421eYYSBbH22qYc7j4dcfBC2fM91yTBPha1RpKpjMYCX46aMfDDSXS7b82xopB0FTIx0xCUd1gZiSLSHbq102AG40Fk14AHh2b6Q9EodqX1eOMqecosDdke8AAP85QFxEGFd7HtGiZUy2jhv///8AAD8rEjkAVVUA/wAA//9JFGNVAKpVVVW/yuP/AP/gX/j7m4KYFfLPV/i1OfcsAG/ESfipJvYAAACjGvZwBM5NCZO7Q/fz9/wOAU1SE4laC6gFATTld/QaAi/YYvZrGK6INLInAlcSAAlkC7D+yP50Ja6zlNL0pg57Mq+viM7vmAtCHFTcdfKOJwz2tw7R1+k7GU94FMo6A4QTF0jkaPjr6vfthfd0FgaJJ87UdgvSZgrriAv7uf2GFtXa4/L+0/5HIVhSF3SJGRBtdZQhBjquSQ6vVwvleQgkKFD5xxMGAA4bI0u0Zg/0l/lFFliZJOuTmrEqBQgqAjNECXVaFadqJIrRWUb61ioWACNkaYyxuMxcZYd7JMaPOAb3pvsAAAKUN9HjaFHse2MrNFhJGAWRDumsR9Glq8TWY1BYI3KDKrWRRgyzRjLJXAs4ADhVJwpNVnZUW4NsDAeEiqinKyTVhQ81FAFFTHAbAmIyOWRuKAWcpbi7w9bFy9oQFj1IC02CC9uTFyGkqLoMABg8Rm5TBgH3xygyCUtVAFWlPAimNyntgmr95jT76HIYAClnG5ZzOQacLSPDPP3BTDvrqCkAAFU5FHR8hqakKxy1chEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADl8yfiAAAAwHRSTlP////o//+a/////v//2P//Zf+s////BOIC////////Af+l////AQRvAwEBVwMD/wH///////7//wD///3////+/P//bv/8//7//f/+//////9v/////2/+/v///////f/////+//9v/P//b///////S/////7////9/v7+//9O/////v//Kf7///////7///r+////BP//////////////////////////b////84D//////+K/v//////A/////9ncQn4AAAOcElEQVR42s2aiWMS177HyR6Ny7Wt3W7b27u99+59y70XOGxDDkzMwCCXPhRSwMhW8EEKCQkKIYkxCyY1W02M2czikmgTjdW61Wpr/7X7O2cGGEjM1b6nvm8CzDlzZs5nftsMzMg0RbpI3oY2Dv3r50eOHPmfvEjjiNBzJK/PPxc+paPEJlkJEt7hs9AltMXdSbqEXvr55aENyvLuUymZrARzqL264nzPblOJJk1beya39n8GEhboYqmsW3uoSjp6zle8t/fMkEbzH9uDEmtWR4DRN+jiOKMlL6NR0pD27qTuX7CGTsNx3KAPjvX8W+0azbfbW7S6Aig5I+N2ozcjt5tO7WaMnG+Yon67DeiZCtMkx8BAxvBZJei/85IsFvR36fLzlR/79xcQGVm574PdBgLLDZtOHdL8sRgU3P7ebhPHINT1WeXR4ydPnjz7Bejw4cNfFOvwVp0QJSwVNw8/Vydym0o7yQxnQZ9U7gNWhpvsuT1UBPovmqHz4z4LgyL7jh4/Dpzw1iDRUfp2tPFooaew2HBcVEOpjhYp19VQ3Ek/GhvFfro3MNPZT/ZFANVq/a1G8zQPelHTfn58EMxpOgq2pId1kk57DPRXBagRpFDklgQpFKU9jVtXvoQkWzcQ2E/2EaOaKoZooIqurxgnbq+E9Yebm08cJqDHKaiEp3Sn205BGopfrEZFbh+NxLSVBsSETO+15y06VFEJnBFYefZEfX1zAfPYi87a+L/B217HjjUc0z9EzKDJrHmfgn6r2UvSyACcXzRTTkrZ+Aomf1lUhZ5DjM9a/W/vA+jFP2/0+AR7fnEC/E44iSm3o1SpXnAOyUBVsbZ0CJ3QnXsVNm08plCC94fPD/0ngP5JExkm8dnYcPbsYRqd1Od0ZOX4vn3jlcUT5nanUhRPtC3BL1bOqCqwoeWz25r3ZX/UVJsmGWRSNJ4k1VPAFEaN91zv5PnM9QrTvvHxAsh2SDtD6vXwr5e2S6SSrNcX06rB+daeMyRGiUEZheK4UDzz1hyvyPBLtbW1Bzr5zs7M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",
	btn_quest = "iVBORw0KGgoAAAANSUhEUgAAAKgAAAA6CAMAAAATO+LOAAADAFBMVEX1mgH51hf5yAz3pgX4tgcAAADKaQn45C359/R0NwNuJwGtZxVRNA1NKAf53CNzQxDZhAv++YlLGQGqeSQ2FgQzBwCNRwbRdgloHADjhwiDNwGUVg3x6+n681Pu4K6pWQrs3an79m6wdBZSOCiNeGuolYk8JwizgihFCgDk2dNyWUiXZBSXhnj56Ub44hrGt63b1c/Wy8WDZ1K2pZkGAQB7ZFKHUyO4qqPPmBjtuiXzxifGhykNAgBpSDSXiYO3hRe9s637+K77+tDQljDYpBhTNhnr5NtVAACRZSXq2pNbRTaoayLlqiI0GAM5OQBvVDfOpizRxbvEeiQTBQA/AAAqFgB4WBiEbmKadCry2EtwNwCkTAuhi3qhjoT36Gz78TEbBgAAAP87JQVJKARELSJVVQCoknFIMwthPCdkTUaBSiCBXUTWsCYcBwAjDQA2GwIzIQQ7JQVMLRRDKwVPOABNNg5UPAtRNw5bSEZVVVV/AABqSBZ/fwCIaS2/lxrTu0fayVPXw4ngdxHt12b67IwAACoAAFUAAH8cHAAhDAAqDwAlDwA/HwAyGwspEgAxHAQkJAA/JAIqKio/KiNJKhVIKgZYPCZbRRZcSRFhPAZjSBZsSwJ0TSZ4WRlmZgB9b2B/f3+ecQ+bkoW0ljK+pFK+sJ3SnUDDpkfDqp7MuXzSvJvbxjb/AADlzVPhzcHk3OH///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8muVlAAAAwHRSTlP//////wD+///+/v7+/v/+/v///v7//v7///7+/////v///v////7+/////v//////////M//+//////1L/////////f8+/wP+///+/4oE/f7//WoEbvr///8E//////+wAYjW/wP/Tv//////iKw2dqo+b26Pq9j/AwLPAtX/////////BgMCCT1ggQhCpN0HxQb/j6kuzuGTLnMuzwX/Av//////////////Af///wEAAAAAAAAAAAAAAAAAAADgj6fmAAAMrklEQVR42s2ah2PbNhbGKZGSRVAQGYgEJVIubQ1recpyLMszti9x7Axn76RJ03Sv67rrXrf33nvv+xPvAaAk0pZ7idOm+RKJALF+fA94BC1KsaCOXGbfZ869/MovcJIJhzQyMtJNYeyXj/Qk2vjNkp0WyT4SrXDfsldfOXeGYVx+I4gmBdKPw6d56823Ny6mQWVQup/yXOn+2qsRK0nv3QYKy0LLUO3ixts/eaIZMmEIFGz52vnyfFlzKaUOpaqu7pDOFMjtTt2L9mhFXS8/v1Y++RqgXt4N+s9Y7Fyyvpz3KGISvfhd6XcnXlX833E+fIHq3p2yAj481ebLG683d1v0ROzMT8treQ+q6fXl7Wf/kbp0dGjo6FH4EnokmBl6RAiOvGhIJDrpoU5Rr9YjgY9oP9QpC+ro0Q/fe/cv5bqOkOOl1zZebsaOhEBPxJrn1wzAVOutdmpsbHBwcHj4wIED7PMgNMzEj2zg4ev/2q6ryHHny8mF2DcDoL+OPVFf08Dp9WdTA4A5PDzGNbCnPrbwPsXGHxyb01RE82u/aoIVexZ98eK8p2J3OzVw6bq4sC7H+HgK1O0lFRkfD/YaznUqgSL3rpQvxjpwY2DdRar25/MLXYueiL1Uz7sI51MDqeuHVlcPAengYGhUQZrq9dQtGuhmeUEqUGsXxN2gsooR0WVkTkOqt+YeZ4FTYiHgeHoeOJdTqUsfrSYSADo8GKZMBS64d+GBkcUAqf6M92RU8RFXH2Wk7vb5hf8+DqBvffe58+B3tZVKjR3gnAG/C7D+Pab2tEnkExGwRhUg1daSX3oLQH8bS867KmqlImPD3O9dc6b8y/vMlEopsodUo/x87Kz0eOxWOa+SfDs6MMgDhJid45GHQinlmIPo2vmFm9IXF/Q1iuhcNDXIgmdnEfXqtueendu3WaPR6F1V2xM0qhhIzZeP35RgJaURakWjLMp3V3qvZkvHBNfnovtAFGIU4hhUOOefC11bJ6uAGdf0phT7Gax4qkSBLjQ3fW1ji+BKxZ3rb5ruWZ6IftLioDbM0vqCtKCWKTKikU78DoeWtm4tTgxdJBWt3TFD5N6IIvd3AZGI0nKQVv651DyYV9V1AE2FTSk4XQv/ffXQpXqFLO93KGW9tX4/pIpMM7T8qvTChoaoHIV7ym7Htn9Xse4kVg8MtFULt/Y30LIOG33aau8bNCpryElj6XMbLnKV6A5jci9H3iFWY3X1wPB4pIUtXdnHMHN5kiz9tYjx8n2A2gL0IEUegO5eJ+1tZOlD7AYwHokuk0q+j1UU+dicwo+yrMwpx+RAZn19fS6PF/+dyCWmn0TG3Pr6MbntN5IVJerX9JuwUyLTKxaSDRWlk9LnXQ4aCl7ttrK+rOnYwu8zTgCNpPIVQrXllhzoQVGWdYSxnp8z2GOB7oKTUV1pwX0O63UVchDaSqd+UyhNFU2V5VVXjip5SEFsBJaWixBmKYMXwiRBdP0YbDtgvykHQCErQF0lGP7W8zASqViWOXJnlXEOjgNpu46JZVUIPCS0OrAtjGu1GsYwdKPxDCaLtVqBaC55ptFIksLMzKKJa8VG7anazIVFs1CbaZzElBm5UWuosDoVHT/TmHmSzK/xfgqFmUaNuFvQTWORuEoQ1E1y13dA+fk68FhY3yj/8f2hQ4cY59g423SOXXr3Dxf1JJQS6l9unszkcomSic2ZXOJwDU8kIKPjQjWXKJqlRG7KLEyC4xPwmTCL8F0t4LqePAWpUdNVDJKEmtOmvmGOJnK5GnxVwQtkgp8E94sJEAKNdoPdsmmdvPO3ox/Bbf+Q2Jj6oOwOO3j9+nvbF4lFFS6NzABFoiFATwpQtQuamIQkUFYPT+amARS0RFTME6MmlQxkTicAHnx+CiqPAOgUgJqzicS0pQpQZSdoV66lfsifYPjDCzsw13e28Qz7kmuRlgA1OWh10byQCIDeDoOWCoXCZkGA5jYxnuKgFpVkatbA3jMYn8wx9A7oSg9UCYNqAVDNwuV2m21bb3AbMlZI3+BPHbDxiiot1SKSb9EGGzQxyyyaWzQZ6Ag2bwPdBQG6Ccklk4uDJkoWvzbmelk2OPU0JqNQl1/KFEY6CYEqAhTvAm0hi+T55IhE/Aet4cEbfJvCJwwEC6viiV7yDDR3GIwCljm8yXxWnZ2dhkPQolOz038qcYzJyUT1qVl2SFwlAHpMZ4hTeIS7gtWoJmEecFA9DJrsxNFuxIHwapE6lPsbDnD32ABjFOFO0ohFfE4BOsXGWuKgK4muitY1hsBAmQ4XwLGJlSVwbjWxNOuDyhrZPJzLbRbYDCc+KGWgs2FQ1VXFHJUZoi8ghd2SHAit4hLYR8q6FQtrUgeUzdFTt6dhyYLra8z1k7Ozsys5BroEoCMMdHJlZaKUZKATEATY6oEldNV0JeZ7C6CXoOoExqTIV9bTxAftkHKL6gw0EwKFAlqpqC0lunNnqchZalkoL8m+NAtcfsr0zXYSQHPgQR6TihYzNEvCdGR/12MYEyxmgZMnxKoH6WzKTv4HLoyoUCNXTWJEoJiFp76gSgCU8VQqyOgGV6XDCdPTQnaXU65z0KS/oGtsjpbMJMHVXO4CX8MctGiyPzCaHHSRL7oVH5T5HvOrrCaTB6GzXA62BQ1wT9Gi7H7KYSUbQFXpiac5aEiy5BGrnhoXO+xO4IVVXqk4AU7fokA2y5z/BYuDPo3xZBA0N7WysjJVGily/46eGiXmRI6DQg8QSks8GJgqMINHchNQCDMA1oGQD6pLv+RzNMzJOrCW+QNeVAmAGrCBDnACKCymySQmBYgyAnSaULWQ81d9tTMrIMlB+d+BCXP9HcLmqCxRa5MV14gGE+7JCVF5sgaO647CQOu6dPygw9rsAIUtyDsD3O0d8YhALBoEzZPFq9fYfsPa/P3S6G1rplSaIa6Kr5ZKi2atVAKnF5dAo6NLF8ynStcasFNwKLIa10o1bjJJsgkplpaKBBnAU8HF0vR0qViwSMAgWQDVdMk8SHEIlF8E3Hy2B3xOf1ZDeg5ZahBUooRUCPFsxPcHiIBUQxNHAssKpqZp1kYLsMFhWYI02/bLHYNxSpILuUoFe5C0KbF+MHqtYBJHy8oh0DoDZRaVApTCI+pchzOb7S5A3ULZEKmtaVpckg04aEbW1uK2IU5qtuZ5Xl5zTRZqMfY0fpKh8XLbkASoZEM9z86yJCzWElvxqhEcJNt1PaIwuiJWmQ+ALJqK8ACf1RxHYw0ZKBjakKReL3wkng327J/mgtkxdXgaq4b0f8U9VKtWi5YT6E2RDADd0qUfw2JyDKMHyWQQK59imDZFsDGFjZ3NZ4dmWbYUIO2B7pDUOWQpwQVwuXRXslVe2/atLQwKcwVtJaVvHXSRA45QgqR2xVpuy4bHKInqsB2zqsGkSlcsGFIW/3umC1uza11elvUch9rSXcqG2i63vtzp1gAM9sz0Nd1DKJ415CApWBS7lK8QGs9mbUFMNWRVbN6HoJNCoH6a/+tU4qjZrHTX6lbm/THP2+BVmv6htKDnnYyXtbO9lQRVNAYJxvRnOSwTjm1VaBDhUxWfP7DzsFl02nhBaj6WhkkKWUkJes+mqqPZPVswszoIwob0wCR8a9teRrXdBSl2fAsmq/dB3GbrSZiLf2X3dsuDA80yg2bofLLJ/ux4mmacuC1IZVl6SMRDkx3/4EpG1dLHb0onYt9LayhzxY77pA8RaBasF0cIDLoQk47EHgWToowX75A+HKyAYjAkRJzT2rdjZ9nPN+ZWnsI0hdNx6eFwv7g9M04no3qnk7GvxKTYkZsLybTm2zRuS+F7lPxZYWYZTdzJON5p9fnv89+ZjsS+oeY5qe2jfhra4167R2VOEvfA79q8+hz74Vb8xPgo1hgpjQtUFuX55lqRe1uqwEawc5JvZJRwoaJ8LEJg3xioGGoDuxCOGackA5z6QuyNzm+hZ78KYR8CegZdifuVgBbCPZMRUuhEL50NqJsxjJ1tjWAto59gWB/gCsogGp9/M/Sj7ZHYwsjGPDMqol68V3mHbFayR9knKBgB7oIEOZ7BAtPZ4O/1R2JNU08bDJWxer1WsDF+sNK8Kw7KMEztdB3vfLFATFQ3DVtyB/WU2SHUT5m+FXc24afEf3463FnnnN8SOVTLp93HzvV5+eVs7Mux5ktJd2sLniEodRwn8P6HsyPhiGIn9JIIfxfE/+6e6Sb5f78W8ktYL84uUQq2TNf1Hz3KXd33LZ1Ys3nrdd2t1/kTjral7aE9C/ajfDibTmt1V3/s603+JsEerxOdEO9nvXir77tT2H/zaj+6+1YYf+fcGfbWw+WzQbT/AfKlI04NkmV1AAAAAElFTkSuQmCC",
	btn_settings = "iVBORw0KGgoAAAANSUhEUgAAAKgAAAA6CAMAAAATO+LOAAADAFBMVEUFW9UmmPcHY9oKRa8ypvcNduwXh/X1+fwAAAAIaeQCOawBAQgGGE7V5/gAGG8GNZIADE4BKIa31PkPJE0BBzEDJnM7s/fJ2/Jn2vaw/f5Eufbk7PUIFzUckfdtmLxOxvgsdMsqbMOqyvURRJaQuPIDSMNv5foRVLQjie8LITutt85Y1fiV9/1pm8NXZ4qYwvgNNXUAAANKV3cIFDY2R21td5CMlq4qaLbO+vy6xddzh6kYdNcnNVZamsPDydUiLVaYqMcAARB3gpYAAFUtOWMnWI4AAD0CCycXY7MEFDcsUXQXVJAjKTEjWLAviM5yoc+XobQUQ3AudrZFSlBVdqR4pukABBcOJ1MOJ01JXIbCzOMXGR0FFjgHG0wKJUsAOjoAVVVCTXZmZ2yGiY+G7PmjrMYPM1pibY+DjKilqK8GGkYBHoEZMlkAf38A//8zNTk5RVEhSYw0hLFUlr1Hptp/f/9iye988/uFruyZtde3uLoABxsACCAEFzQALqAUNl4TMmQBPcAaVHcqZJQifeA7wv1ZcZmivuX///8ADiQACywLG0IAKlUMKGYfPHgAVaode7wegNsfoO8zAAAnLmAgTq8oX8w5l8s/o99QU1lLbaBDj8JAquVe4PlgXmJrcnpyf6RkicPN0NsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB3+tehAAAAwHRSTlP+//7+/////wH//v/+//7+//7//v/+//////////////7+//7////+///////////9LP+W/////////////////1D/A//9BJT/r/////7////5/////3GW0f///8vNtAQD//////+S////l/7sAgH///v///8C//////+Ib3L/0JH/////////AUaguAaQ3gP///8F///5////////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABkgE1mAAAOWElEQVR42sWah2Pbxr3HjwAncARA8iDIImnKhChqUiS1rBFZsqVI3iPxHokTZzWrSds03ekeb7/2jfbN9i/t93eHRYpO0tp57yuRBHAH4IPfuN+BIMsndI7e9paXb7/55puf3akozQaqPFVh6+xsTUptrOFPbp+tRPvKTUq1AcUnePTm7dvL3+tFOKFYYvmDfL63fH39xiR06pR8I62vh29y40idCvaJ+gf7qn2i/RJbqF940GDzetS8fnD9Ua+XHw36Iox55wDHYG1dNwx6jZIeylCvZM+wxUj0SO444mgDu0U9mTY5+dPKXtKoLObsnT+4MskMu2T9v+vdkqFrpw7u9PKvDoOey++9d2NSt0sl11+/8R8vkL7xwqL8XITk8uJVLF2lN6mTT5VsUl0+r1tyj8Vwr6sv3Fj3bdcqGWy9+/1hi76Sv3Uw2TZAeWVifnx6ekHqxELwSZIf8Wqk09GC1Iln1sL09Hzj3y5aQD118GAQVHIaJct/oTE/P/9f01LjkT75+OAC6affaIyjfXxA0wMr0+PHND9/bJ/PkTo39vgmUG22/iD/tzEo/H4wqZfcG435xvj0E3m2+flGqI8rwgzU/c/GRKMxQQo+sBB+Sk0Maoyk3hPCBjQN94yPMk6ojSvwP1v/Qf4fYovuXZ80XPebYJteUG7+9vT4fHDiKzUzlj8xcLrjDEpp/IdKLB7XWNRK+8SHBut8I2VbpfbB4W/PBaDfyv9o0ngXnGPjCydyOYQZcQaYY+muab703Z2djY2d1++btSvh8RXQV6AQdXp+LOWD9KO9wKKv5h+R3/+9MTZ94nQOOvGEMOHSj3/ykxvpK9y8X80prZrmxdTkxe7FK+mvWEBFHKbJpv/a7f2KQClAtZJ1JeZEjH4CW6avk68rXWH+XmFWc2umOXudAra2/iVOlkouD+t479TgHun0xPxEfaZkGZfPw5hMOl63Lk6kxxck5+knZM6xiVQ3CszXJefpYm4jDtaLicNGJ06pldFoX1YJszbSWc2ymE+ufzF/6zIrual/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",
	btn_exit = "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",
	btn_continue = "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",
	btn_close = "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",
	sk_meteor = "iVBORw0KGgoAAAANSUhEUgAAAEQAAABECAMAAAAPzWOAAAADAFBMVEVvAgEAAACNBAHOGAH2aAZTAgP3dwauCQDPJgTtNwPyVwXwRwTnJwH7xwb51wr4hgX5pwT5lwSOJwyyFQL6uAVrFw81AQJRFxVxJwv65RPNNgr69E3PRwb49W/56imONxErCgKwNgb8+q6yJwPPdTY3EhLHaS/694368TJ2MxHseUrJVQ2xRhGNFwYaBACwWCdLFQH++83wh004AADiHQEUAAGcakOXRRewVxa3ZCuibEXDDgHZhkZpIiWdcUrpdzHql1D3yY/PZBALAAArCQdVAABZHCTWekTrqGr95a9FDQJoHCLahDnvZy7uo1DytXL71os6EwpbJQyrRCPohTP1ynf+55IpCgVIGA2baDzKdQb/AAD58BYmCAo9FQOHOiGicUrOiA7tm2X5pSz9xio7ExRdIid/AACTSyieVQalOybCViXMaE7dmFTqVinysl7vuYj72iz927j670weAgAcAAAyDQBVVVVwMRN6OSR/fwC4YwW8eQq7fDbGjWramhHZnXTfrBHeqIXzZ0LggmDskyr/0nr+/eAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIYNNDAAAAwHRSTlP+Af////7////////////////9///+/Pv+/////////nj+////ef////////79df91//8E/1H/////////////////L6wD+v///3X+////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",
	sk_bliz = "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",
	sk_void = "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",
	sk_heal = "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",
	sk_rage = "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",
	spd_x1 = "iVBORw0KGgoAAAANSUhEUgAAADgAAAA4CAMAAACfWMssAAADAFBMVEUBd/gChvkIl/gBASjz+vsPpvgBZ/cAABQAAAAmuvgYs/gyxfgDFFUAMtQALNEDSdBP1fcFAiUAPOgIOHUBRe633PoBACMDWe84OVQZRnARFTUmRm+K/f7M5vcAAB614/cHOo0EAiVv4/aQ5/YFJmtDzPh3/f6w+PsJRo0JJFYFSbgJVrnm6O8Xw/ymqbkw1veXmqvO9/oCC0cGVcsMdtYDByoEG2iyucsDBycAAFUCKJEDOK4KZs1P9v3V2ecEBBsCADcIVZQKZ64rOWZXV25k3faXptDFx9QEDS0CFywt4/tYZJROZ6mDmdSborWItfwFAR4AAH8Ug7UTgNUY1v4wrcgjqPleYHdsgbx6kdBvl+OIh5iXw/+prcAFAh8XFxcHHy8PEjMAPwAYMl0KUXwbe6gZl7khIjUgLVwnOjo4TZAye5c7orgz8P9AP1dNTmRVc7hefsVF4fdjZHpyc4Zlg5pkidl/qO+qve+8wtqky/+30dvFzecAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACYyVDzAAAAwHRSTlP+//79//7+/gD+/v/+///+/rL+/v7/1/7//////v/c//6N///+//7//v7///////7//v7+/nD+/00D//7///8oCv7///////8wHP7//////0oC/f//+///////////YgsgVAT///v7//8N//v9///////////+///////8/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD7IGZBAAAErElEQVR42o3Wh1viSBgH4Ml8yUwCAaRGg56AUUBFRMBe1t5Wt97d7u1e7733++Pvm5mEFHzO++kTIeTlm5IZQ0yVLz/MV+DeVPLDD0xzSwAi2UdDVO3jajRTU1PqGKb6sQ1QvzSfKLhlXlSg/evfvV6z2Zwey0KY6YWJb6YANlXFLXMT4OtpRM1ec1ZkLkxD5rRxejqBaSzs7V19ZsPQfCAqXgC8ubc319P1Hn48P58OYmFSKoaKlf6p+zzVxppb5Mn7FXRXTR0zNzGClnIojUDJpLqdjmHDBVYcwqffdkMXlBpVMxJJp4wB1E1yCe1utxE4hJYVc+OyY1APLkkdnl51xbg0lEvf4yg1UrQPQ5Jfs5439J5ikYaOOYqRB5rS2FqecK+Tnu4F5QRLJzsohCIqBiV2hfBiJ92YmEcXTMFbS8XWM19Gr49AhhCmOhON9HwwC+hqnHNoGZaoFxea5r/wYXciMuPWANyNVZevD8bqaSJJaAV9s3b5pK7vn2BRaow7ZRVMpbvh3FnGkoC6vuJye/dO50OOMBhHS4yiD/VlLFrTxhwZwaKEcuTl6AcwVlQZDB4kfEPBcMaiUF9+2y+qjaDEAeykU5Gbox/CoKiWgJrf1I4VOkpj0C8ac4RqjhjVYuTOElmKQVl0nYRKtNSHhoSj4UtCffn7mNTi0B88/InC3gxG3wBgkQ7GYDjodDGAMzNlzGz5UZWvOREnoRhVhNEZVlCp8uzs6x/bnG9HXQQaSThi5d+ruFS2WdRhRlCL3IkSKld+/YPL+XqOxAoSBbGPhqFpSTgryr1zLMo5JJEA4uq5A86UHz2U5Vg4f1T7D0gk9Mut7bDI/XJ09EzSOyFREMsBB68faV4LcEspUrlCSkkoLhHwr9++iJcjgzY/OT//mR/Ja5JQXpID9+FXEBsU/AKXr+LsbvAWDSAPoX+VjU3ithoUdVajLb4hb3je0sbg6Pv7nm3vOIodtZY0bdA6bMOygO9KqEVhdJ4YY+KAHbM5LuRD/OfP+eo/5wLWIlBLQmUZo0Vs4LnLJ5eXX3GAVdFUCTUf0jEoHdNcFxu48vm+rv+J3Q4hVhRbB97ud9VDWORVsZBxf7a5zWMVxXokxAhFxDExwNdyZR5zr8Zvdf0s1lTmGFpYacTE6z7n+1jxlgPbERVvuYeXUlKQTWUFSmNNDOPxFbkZ/MK9NRdncuM7IakjoccKsZKR1PgrbOcZ1jwRY4Pbjz4JhNJMYQ37aJNCZtTLOASxiVzzMxwddcsJODCcbA5hBQalTCDjzgH3pvyCc/fsj2vg1ZuXL29eAFCSLexAheThkGQzWSZXaaKp27gB4G2Lky9+VVokky2t41MHPshRB2WOhBvWaFOquWAv4dFt75Ka1257Xq2UzZZyAAfEzOOuU0CZzTgsubsQJs8xFrwr4ZUFxxZPVuYBwGGqlM1k0I5Hnox8lMkWHA9APj3WAT4xWEHQ+1NwnHWAx+J59QFK3n5KnBKmIKNeyDfxMyXGFnGR1dXz6hZ2E8BuLfVz96S/WBNDXA+fyesgR/ze4PRA5bEZQtMc5uF/Jb/pgwCa5kG9Uqnkx1Kvh3/r7x2MLv8Xq0GogBst6Q0AAAAASUVORK5CYII=",
	spd_x2 = "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",
	spd_x3 = "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",
	btn_start = "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",
	btn_exit_lobby = "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",
	icon_goldbag = "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",
	btn_qmark = "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",
	tile_lock = "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",
	diff_norm_lock = "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",
	diff_hard_lock = "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",
	btn_menu3 = "iVBORw0KGgoAAAANSUhEUgAAADgAAAA4CAMAAACfWMssAAADAFBMVEUAAAAGiPwBdvzO5PsRl/z3/P02tfwmqfwBZ/oGNLEAf/4AStYAP/8AFJBMxvsSpv4ASusAAP8AJ9gAP78AKM4AOs4ARvYjRrAAN+gCl/xzne2aqdipy/wAVvoAaPtBvfvH3fgDLK8AVfNWfN1yg8UMsv8Cifs3xPxO1PxufcFs2fvV9/0AAK4ANeYAVdgAVfkAqv8Av/9x5fwAVap2ovGZ6vuw9/zGzOfj6/cPJZwAK+IAM9cAdfwA//9HVq5ahOGjrtms0P8AAH8ACoUAJs0AKdIALNFZa7xbgNmGm9iY8/sAH6MAL94ALNcAMNYAPOsAP/MANuIAQ78ASNoATvgAU/kAW/wIaf8AYf0AfP8Adf8Bc/0Gh/sBjfsAjfwYnfIPl/8EnfsJpP8hNKI7W8I+ZcwzZv8gn/pEZ8tXfuBIkf9vfb97kNGEoOGOu/+pt+EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADqhRR1AAAAwHRSTlMA/Pz8+/z8/P39BP0E/fz8+QH9BI39dv11df39/X58/Pz9/f39/3X6+f37/AP4/QQDBPkD/fz7/f39/yl2Af39/f0C/SRqrP39/fv9Vt6DM1yW/QdUK9odhi9ZllON3RUgm1L9/f0F/f39B/39/f39AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACCML4dAAAChElEQVR42u2WV3PaQBRGV8sKVpJBWhuZGDumiYBpJrQYbFPc7fTee+///y27kg0rQNI+5SU5wzCMRme+q3u5sAD856+wW7/KUCfUd0W8+ryLmwJ54PW7lTFXbF6oQA3QiApWdD1P0W2QjQR3gEoC6nyrF9qds0ajUaTEYrECJSzB5/7V1mleUZbLnVIp5gLBdT9TJW9QQZblM6alwhNSMYQfE+/nVMHLfEeW20zjPQZ84t0gAr69KpbL7Yu0iIP9MYwefSLEM/ApanTajhaZBj/0jFTBM71R4uKckUQiiL3hB2DBU9zJ2x66p/BAOkpdh8t+YrhEvYhiDVfHDK2MxExfcT0fo1XWLNnFsRYs6inaRe2avBWaIK8q7HsXILKmUJHz0uWksGjxYij0QUBE4chnHXZzg5Pc15zD4GMUI9oe7C/SoSGkRV1oEiVQtBcQaxxYEhZrSoIjI5yIE1v8GNPvcaB4GbEfC21Ib59MUv6hoEBRskXXHEPlnxk78ZKvyB7R/O0WT8RECWmJ0WhtzOiX0x0BUbre5bcqGoUiIrsHmrxoOoMUESXN5NBgkLhwISp967tlbVgbDKufgWIiqh27F7lvNyfrK0KWaK65F/k0EyguO6LzBUifE0qKiOwW89S9yF8U2mgoINa6yVarlTynNYjWqAcNP/GOPTKo7PN7vJ+hGsbGDbDkITbBbYNq9JXlFzlre7i6DYjnn85mFbOqZqBe9uZ9T5GWcteQ5mo0MO5ZKYvcrmYnJp540Fj0rtQ+ldyqGvPyjF6ctsDn0NGsHPVMI2tMYfaO9pq+xw5CKvHFOcQrhAQcdAA4OIxPcXgAAAk8WlWEL86ELs2w928eh/8AZmdaUVDkYLgAAAAASUVORK5CYII=",
	icon_spike = "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",
	icon_mine = "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",
	pm_quit = "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",
	pm_resume = "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",
	logo_banner = "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",
	pill_hp = "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",
	pill_coin = "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",
	pill_wave = "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",
}

local function b64DecodeLua(data)
	-- Uu tien ham giai ma Base64 goc cua Executor (nhanh tuc thi)
	if crypt and type(crypt.base64decode) == "function" then
		local ok, res = pcall(crypt.base64decode, data)
		if ok and type(res) == "string" and #res > 100 then return res end
	end
	if type(base64_decode) == "function" then
		local ok, res = pcall(base64_decode, data)
		if ok and type(res) == "string" and #res > 100 then return res end
	end
	-- Fallback giai ma Luau thuan bang bit32
	local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local lookup = {}
	for i = 1, #b do lookup[string.byte(b, i)] = i - 1 end
	local out = {}
	local len = #data
	local idx = 1
	while idx <= len do
		local c1 = lookup[string.byte(data, idx)] or 0
		local c2 = lookup[string.byte(data, idx + 1)] or 0
		local b3 = string.byte(data, idx + 2)
		local b4 = string.byte(data, idx + 3)
		local c3 = b3 and lookup[b3] or 0
		local c4 = b4 and lookup[b4] or 0
		local n = bit32.lshift(c1, 18) + bit32.lshift(c2, 12) + bit32.lshift(c3, 6) + c4
		table.insert(out, string.char(bit32.band(bit32.rshift(n, 16), 255)))
		if b3 and b3 ~= 61 then
			table.insert(out, string.char(bit32.band(bit32.rshift(n, 8), 255)))
		end
		if b4 and b4 ~= 61 then
			table.insert(out, string.char(bit32.band(n, 255)))
		end
		idx += 4
	end
	return table.concat(out)
end

local mapAssetCache = {}
getMapImageAsset = function(mapId)
	if mapAssetCache[mapId] ~= nil then return mapAssetCache[mapId] end
	local getAsset = (type(getcustomasset) == "function" and getcustomasset) or (type(getsynasset) == "function" and getsynasset) or nil
	if not getAsset or type(writefile) ~= "function" then
		mapAssetCache[mapId] = false
		return false
	end
	local b64 = MAP_IMG_B64[mapId]
	if not b64 then
		mapAssetCache[mapId] = false
		return false
	end
	local fname = "ThuThanh2D_Map_" .. tostring(mapId) .. "_v72.png"
	local ok, url = pcall(function()
		local exists = (type(isfile) == "function") and isfile(fname)
		if not exists then
			writefile(fname, b64DecodeLua(b64))
		end
		return getAsset(fname)
	end)
	if ok and type(url) == "string" and #url > 0 then
		mapAssetCache[mapId] = url
		return url
	end
	mapAssetCache[mapId] = false
	return false
end

-- Ve boi canh phong canh 3D chi tiet cho 5 ban do ngoai Sanh (theo anh mau)
function GFX.buildMapScene(prev, mapId, z)
	local sky = Instance.new("Frame")
	sky.Size = UDim2.fromScale(1, 1)
	sky.BorderSizePixel = 0
	sky.ZIndex = z
	sky.Parent = prev

	if mapId == "meadow" then
		-- Thao Nguyen Xanh: troi xanh may trang, nui xa, lau dai trang mai xanh co do, doi co, duong dat & hang rao go
		sky.BackgroundColor3 = Color3.fromRGB(54, 174, 232)
		addGradient(sky, Color3.fromRGB(36, 146, 224), Color3.fromRGB(168, 226, 244), 90)
		for _, cl in ipairs({{14, 8, 26, 10}, {46, 12, 22, 8}}) do
			local c = Instance.new("Frame")
			c.Size = UDim2.fromOffset(cl[3], cl[4])
			c.Position = UDim2.fromOffset(cl[1], cl[2])
			c.BackgroundColor3 = Color3.fromRGB(236, 244, 248)
			c.BackgroundTransparency = 0.15
			c.BorderSizePixel = 0
			c.ZIndex = z + 1
			c.Parent = prev
			addCorner(c, 99)
		end
		local mt = Instance.new("Frame")
		mt.Size = UDim2.fromOffset(44, 44)
		mt.Position = UDim2.fromOffset(22, 32)
		mt.Rotation = 45
		mt.BackgroundColor3 = Color3.fromRGB(72, 162, 206)
		mt.BorderSizePixel = 0
		mt.ZIndex = z + 1
		mt.Parent = prev
		addCorner(mt, 6)
		local hill1 = Instance.new("Frame")
		hill1.Size = UDim2.fromOffset(152, 76)
		hill1.Position = UDim2.fromOffset(-16, 48)
		hill1.BackgroundColor3 = Color3.fromRGB(58, 172, 68)
		hill1.BorderSizePixel = 0
		hill1.ZIndex = z + 2
		hill1.Parent = prev
		addCorner(hill1, 99)
		addGradient(hill1, Color3.fromRGB(118, 212, 76), Color3.fromRGB(32, 128, 52), 90)
		-- Duong dat vang uon luon
		local rd1 = Instance.new("Frame")
		rd1.Size = UDim2.fromOffset(22, 32)
		rd1.Position = UDim2.fromOffset(58, 48)
		rd1.Rotation = 18
		rd1.BackgroundColor3 = Color3.fromRGB(232, 198, 112)
		rd1.BorderSizePixel = 0
		rd1.ZIndex = z + 3
		rd1.Parent = prev
		addCorner(rd1, 10)
		local rd2 = Instance.new("Frame")
		rd2.Size = UDim2.fromOffset(30, 52)
		rd2.Position = UDim2.fromOffset(44, 72)
		rd2.BackgroundColor3 = Color3.fromRGB(228, 192, 104)
		rd2.BorderSizePixel = 0
		rd2.ZIndex = z + 3
		rd2.Parent = prev
		addCorner(rd2, 12)
		-- Lau dai trang mai xanh + cong go + co do
		local cas = Instance.new("Frame")
		cas.Size = UDim2.fromOffset(42, 26)
		cas.Position = UDim2.fromOffset(66, 26)
		cas.BackgroundColor3 = Color3.fromRGB(224, 228, 236)
		cas.BorderSizePixel = 0
		cas.ZIndex = z + 2
		cas.Parent = prev
		addCorner(cas, 4)
		local cDoor = Instance.new("Frame")
		cDoor.Size = UDim2.fromOffset(8, 12)
		cDoor.Position = UDim2.new(0.5, -4, 1, -12)
		cDoor.BackgroundColor3 = Color3.fromRGB(132, 78, 38)
		cDoor.BorderSizePixel = 0
		cDoor.ZIndex = z + 3
		cDoor.Parent = cas
		addCorner(cDoor, 4)
		for _, tx in ipairs({66, 82, 98}) do
			local rf = Instance.new("Frame")
			rf.Size = UDim2.fromOffset(10, 10)
			rf.Position = UDim2.fromOffset(tx, 18)
			rf.Rotation = 45
			rf.BackgroundColor3 = Color3.fromRGB(44, 124, 218)
			rf.BorderSizePixel = 0
			rf.ZIndex = z + 3
			rf.Parent = prev
		end
		-- Cay xanh to ben trai
		local trk = Instance.new("Frame")
		trk.Size = UDim2.fromOffset(12, 28)
		trk.Position = UDim2.fromOffset(6, 52)
		trk.BackgroundColor3 = Color3.fromRGB(132, 78, 38)
		trk.BorderSizePixel = 0
		trk.ZIndex = z + 3
		trk.Parent = prev
		local tr = Instance.new("Frame")
		tr.Size = UDim2.fromOffset(42, 42)
		tr.Position = UDim2.fromOffset(-10, 18)
		tr.BackgroundColor3 = Color3.fromRGB(82, 202, 54)
		tr.BorderSizePixel = 0
		tr.ZIndex = z + 4
		tr.Parent = prev
		addCorner(tr, 99)
		-- Hang rao go 2 ben
		for _, fx in ipairs({4, 86}) do
			local fn = Instance.new("Frame")
			fn.Size = UDim2.fromOffset(28, 12)
			fn.Position = UDim2.fromOffset(fx, 86)
			fn.BackgroundColor3 = Color3.fromRGB(168, 104, 48)
			fn.BorderSizePixel = 0
			fn.ZIndex = z + 4
			fn.Parent = prev
			addCorner(fn, 3)
		end
	elseif mapId == "desert" then
		-- Sa Mac Lua: hoang hon vang cam, mat troi, nui da do, xuong rong co tay, hang rao go
		sky.BackgroundColor3 = Color3.fromRGB(234, 158, 62)
		addGradient(sky, Color3.fromRGB(224, 118, 46), Color3.fromRGB(242, 212, 124), 90)
		local sun = Instance.new("Frame")
		sun.Size = UDim2.fromOffset(24, 24)
		sun.Position = UDim2.fromOffset(32, 10)
		sun.BackgroundColor3 = Color3.fromRGB(246, 232, 138)
		sun.BorderSizePixel = 0
		sun.ZIndex = z + 1
		sun.Parent = prev
		addCorner(sun, 99)
		for _, ms in ipairs({{-6, 30, 44, 38}, {72, 24, 52, 44}}) do
			local m = Instance.new("Frame")
			m.Size = UDim2.fromOffset(ms[3], ms[4])
			m.Position = UDim2.fromOffset(ms[1], ms[2])
			m.BackgroundColor3 = Color3.fromRGB(186, 86, 42)
			m.BorderSizePixel = 0
			m.ZIndex = z + 1
			m.Parent = prev
			addCorner(m, 8)
		end
		local sand = Instance.new("Frame")
		sand.Size = UDim2.fromOffset(146, 72)
		sand.Position = UDim2.fromOffset(-14, 54)
		sand.BackgroundColor3 = Color3.fromRGB(232, 178, 72)
		sand.BorderSizePixel = 0
		sand.ZIndex = z + 2
		sand.Parent = prev
		addCorner(sand, 28)
		addGradient(sand, Color3.fromRGB(240, 198, 88), Color3.fromRGB(198, 128, 46), 90)
		-- Xuong rong 2 ben co canh
		for _, cx in ipairs({10, 96}) do
			local cac = Instance.new("Frame")
			cac.Size = UDim2.fromOffset(10, 28)
			cac.Position = UDim2.fromOffset(cx, 50)
			cac.BackgroundColor3 = Color3.fromRGB(62, 174, 54)
			cac.BorderSizePixel = 0
			cac.ZIndex = z + 3
			cac.Parent = prev
			addCorner(cac, 5)
			local arm = Instance.new("Frame")
			arm.Size = UDim2.fromOffset(18, 6)
			arm.Position = UDim2.fromOffset(cx - 4, 60)
			arm.BackgroundColor3 = Color3.fromRGB(58, 166, 52)
			arm.BorderSizePixel = 0
			arm.ZIndex = z + 3
			arm.Parent = prev
			addCorner(arm, 3)
		end
		for _, fx in ipairs({4, 86}) do
			local fn = Instance.new("Frame")
			fn.Size = UDim2.fromOffset(28, 12)
			fn.Position = UDim2.fromOffset(fx, 90)
			fn.BackgroundColor3 = Color3.fromRGB(162, 96, 44)
			fn.BorderSizePixel = 0
			fn.ZIndex = z + 4
			fn.Parent = prev
			addCorner(fn, 3)
		end
	elseif mapId == "citadel" then
		-- Thanh Tri Hac Am: trang tron sang, lau dai den chop nhon + cua so do + cong ruc do + 2 co do
		sky.BackgroundColor3 = Color3.fromRGB(54, 32, 96)
		addGradient(sky, Color3.fromRGB(40, 22, 84), Color3.fromRGB(118, 72, 176), 90)
		local moon = Instance.new("Frame")
		moon.Size = UDim2.fromOffset(28, 28)
		moon.Position = UDim2.fromOffset(12, 8)
		moon.BackgroundColor3 = Color3.fromRGB(234, 224, 246)
		moon.BorderSizePixel = 0
		moon.ZIndex = z + 1
		moon.Parent = prev
		addCorner(moon, 99)
		local grd = Instance.new("Frame")
		grd.Size = UDim2.fromOffset(136, 60)
		grd.Position = UDim2.fromOffset(-8, 62)
		grd.BackgroundColor3 = Color3.fromRGB(78, 72, 108)
		grd.BorderSizePixel = 0
		grd.ZIndex = z + 1
		grd.Parent = prev
		addCorner(grd, 14)
		local dc = Instance.new("Frame")
		dc.Size = UDim2.fromOffset(58, 38)
		dc.Position = UDim2.fromOffset(42, 26)
		dc.BackgroundColor3 = Color3.fromRGB(46, 40, 74)
		dc.BorderSizePixel = 0
		dc.ZIndex = z + 2
		dc.Parent = prev
		addCorner(dc, 5)
		for _, spx in ipairs({46, 65, 84}) do
			local sp = Instance.new("Frame")
			sp.Size = UDim2.fromOffset(12, 12)
			sp.Position = UDim2.fromOffset(spx, 18)
			sp.Rotation = 45
			sp.BackgroundColor3 = Color3.fromRGB(58, 52, 92)
			sp.BorderSizePixel = 0
			sp.ZIndex = z + 2
			sp.Parent = prev
		end
		local gate = Instance.new("Frame")
		gate.Size = UDim2.fromOffset(14, 18)
		gate.Position = UDim2.new(0.5, -7, 1, -18)
		gate.BackgroundColor3 = Color3.fromRGB(228, 48, 56)
		gate.BorderSizePixel = 0
		gate.ZIndex = z + 3
		gate.Parent = dc
		addCorner(gate, 6)
		for _, bx in ipairs({8, 96}) do
			local bn = Instance.new("Frame")
			bn.Size = UDim2.fromOffset(14, 22)
			bn.Position = UDim2.fromOffset(bx, 82)
			bn.BackgroundColor3 = Color3.fromRGB(198, 36, 52)
			bn.BorderSizePixel = 0
			bn.ZIndex = z + 3
			bn.Parent = prev
			addCorner(bn, 3)
		end
	elseif mapId == "heroic_boss" then
		-- Boss Anh Hung: troi thien duong xanh sang, cung dien hoang gia chop vang, 2 tru da & san dau vang
		sky.BackgroundColor3 = Color3.fromRGB(64, 174, 232)
		addGradient(sky, Color3.fromRGB(48, 148, 228), Color3.fromRGB(188, 230, 246), 90)
		local plaza = Instance.new("Frame")
		plaza.Size = UDim2.fromOffset(140, 56)
		plaza.Position = UDim2.fromOffset(-10, 68)
		plaza.BackgroundColor3 = Color3.fromRGB(222, 204, 152)
		plaza.BorderSizePixel = 0
		plaza.ZIndex = z + 1
		plaza.Parent = prev
		addCorner(plaza, 20)
		local ringG = Instance.new("Frame")
		ringG.Size = UDim2.fromOffset(64, 20)
		ringG.Position = UDim2.new(0.5, -32, 0, 82)
		ringG.BackgroundColor3 = Color3.fromRGB(236, 196, 58)
		ringG.BorderSizePixel = 0
		ringG.ZIndex = z + 2
		ringG.Parent = prev
		addCorner(ringG, 99)
		local pal = Instance.new("Frame")
		pal.Size = UDim2.fromOffset(56, 38)
		pal.Position = UDim2.new(0.5, -28, 0, 30)
		pal.BackgroundColor3 = Color3.fromRGB(228, 230, 238)
		pal.BorderSizePixel = 0
		pal.ZIndex = z + 2
		pal.Parent = prev
		addCorner(pal, 5)
		local sp = Instance.new("Frame")
		sp.Size = UDim2.fromOffset(18, 18)
		sp.Position = UDim2.new(0.5, -9, 0, 14)
		sp.Rotation = 45
		sp.BackgroundColor3 = Color3.fromRGB(240, 198, 52)
		sp.BorderSizePixel = 0
		sp.ZIndex = z + 3
		sp.Parent = prev
		for _, px in ipairs({8, 94}) do
			local pil = Instance.new("Frame")
			pil.Size = UDim2.fromOffset(16, 34)
			pil.Position = UDim2.fromOffset(px, 56)
			pil.BackgroundColor3 = Color3.fromRGB(214, 218, 228)
			pil.BorderSizePixel = 0
			pil.ZIndex = z + 3
			pil.Parent = prev
			addCorner(pil, 3)
		end
	else
		-- Vo Tan: vu tru sao tim, dao bay 2 ben, cong xoan hu khong tim sang & cum pha le tim
		sky.BackgroundColor3 = Color3.fromRGB(24, 14, 58)
		addGradient(sky, Color3.fromRGB(16, 10, 48), Color3.fromRGB(72, 28, 126), 90)
		for _, fl in ipairs({{8, 18, 22, 12}, {88, 16, 22, 12}}) do
			local fi = Instance.new("Frame")
			fi.Size = UDim2.fromOffset(fl[3], fl[4])
			fi.Position = UDim2.fromOffset(fl[1], fl[2])
			fi.BackgroundColor3 = Color3.fromRGB(68, 54, 112)
			fi.BorderSizePixel = 0
			fi.ZIndex = z + 1
			fi.Parent = prev
			addCorner(fi, 5)
		end
		local isl = Instance.new("Frame")
		isl.Size = UDim2.fromOffset(128, 54)
		isl.Position = UDim2.fromOffset(-5, 68)
		isl.BackgroundColor3 = Color3.fromRGB(64, 54, 102)
		isl.BorderSizePixel = 0
		isl.ZIndex = z + 1
		isl.Parent = prev
		addCorner(isl, 14)
		local arch = Instance.new("Frame")
		arch.Size = UDim2.fromOffset(48, 44)
		arch.Position = UDim2.new(0.5, -24, 0, 24)
		arch.BackgroundColor3 = Color3.fromRGB(82, 74, 126)
		arch.BorderSizePixel = 0
		arch.ZIndex = z + 2
		arch.Parent = prev
		addCorner(arch, 20)
		local vort = Instance.new("Frame")
		vort.Size = UDim2.fromOffset(30, 30)
		vort.Position = UDim2.fromScale(0.5, 0.56)
		vort.AnchorPoint = Vector2.new(0.5, 0.5)
		vort.BackgroundColor3 = Color3.fromRGB(208, 72, 240)
		vort.BorderSizePixel = 0
		vort.ZIndex = z + 3
		vort.Parent = arch
		addCorner(vort, 99)
		local vCore = Instance.new("Frame")
		vCore.Size = UDim2.fromOffset(14, 14)
		vCore.Position = UDim2.fromScale(0.5, 0.5)
		vCore.AnchorPoint = Vector2.new(0.5, 0.5)
		vCore.BackgroundColor3 = Color3.fromRGB(238, 192, 246)
		vCore.BorderSizePixel = 0
		vCore.ZIndex = z + 4
		vCore.Parent = vort
		addCorner(vCore, 99)
		for _, cx in ipairs({8, 96}) do
			local cr = Instance.new("Frame")
			cr.Size = UDim2.fromOffset(14, 24)
			cr.Position = UDim2.fromOffset(cx, 82)
			cr.Rotation = (cx < 50) and -16 or 16
			cr.BackgroundColor3 = Color3.fromRGB(192, 74, 238)
			cr.BorderSizePixel = 0
			cr.ZIndex = z + 3
			cr.Parent = prev
			addCorner(cr, 4)
		end
	end
end

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
	elseif kind == "skull" then
		-- Dau lau trang 3D giong anh mau Dot
		local head = Instance.new("Frame")
		head.Size = UDim2.fromScale(0.84, 0.72)
		head.Position = UDim2.fromScale(0.5, 0.42)
		head.AnchorPoint = Vector2.new(0.5, 0.5)
		head.BackgroundColor3 = Color3.fromRGB(238, 236, 246)
		head.BorderSizePixel = 0
		head.ZIndex = z + 1
		head.Parent = box
		addCorner(head, 99)
		addStroke(head, THEME.Outline, 1.4)
		local jaw = Instance.new("Frame")
		jaw.Size = UDim2.fromScale(0.52, 0.30)
		jaw.Position = UDim2.fromScale(0.5, 0.78)
		jaw.AnchorPoint = Vector2.new(0.5, 0.5)
		jaw.BackgroundColor3 = Color3.fromRGB(224, 218, 238)
		jaw.BorderSizePixel = 0
		jaw.ZIndex = z + 1
		jaw.Parent = box
		addCorner(jaw, 4)
		addStroke(jaw, THEME.Outline, 1.3)
		for _, ex in ipairs({0.33, 0.67}) do
			local eye = Instance.new("Frame")
			eye.Size = UDim2.fromScale(0.22, 0.24)
			eye.Position = UDim2.fromScale(ex, 0.44)
			eye.AnchorPoint = Vector2.new(0.5, 0.5)
			eye.BackgroundColor3 = Color3.fromRGB(20, 18, 42)
			eye.BorderSizePixel = 0
			eye.ZIndex = z + 2
			eye.Parent = box
			addCorner(eye, 99)
		end
		local nose = Instance.new("Frame")
		nose.Size = UDim2.fromScale(0.14, 0.14)
		nose.Position = UDim2.fromScale(0.5, 0.62)
		nose.AnchorPoint = Vector2.new(0.5, 0.5)
		nose.Rotation = 45
		nose.BackgroundColor3 = Color3.fromRGB(24, 20, 48)
		nose.BorderSizePixel = 0
		nose.ZIndex = z + 2
		nose.Parent = box
	elseif kind == "chest" then
		-- Ruong kho bau nau vien vang (Kho Do giong anh mau)
		local body = Instance.new("Frame")
		body.Size = UDim2.fromScale(0.86, 0.76)
		body.Position = UDim2.fromScale(0.5, 0.54)
		body.AnchorPoint = Vector2.new(0.5, 0.5)
		body.BackgroundColor3 = Color3.fromRGB(168, 86, 32)
		body.BorderSizePixel = 0
		body.ZIndex = z + 1
		body.Parent = box
		addCorner(body, 4)
		addStroke(body, THEME.Outline, 1.5)
		local band = Instance.new("Frame")
		band.Size = UDim2.new(1, 0, 0.26, 0)
		band.Position = UDim2.fromScale(0, 0.34)
		band.BackgroundColor3 = Color3.fromRGB(238, 194, 46)
		band.BorderSizePixel = 0
		band.ZIndex = z + 2
		band.Parent = body
		local lock = Instance.new("Frame")
		lock.Size = UDim2.fromScale(0.28, 0.34)
		lock.Position = UDim2.fromScale(0.5, 0.52)
		lock.AnchorPoint = Vector2.new(0.5, 0.5)
		lock.BackgroundColor3 = Color3.fromRGB(244, 212, 68)
		lock.BorderSizePixel = 0
		lock.ZIndex = z + 3
		lock.Parent = body
		addCorner(lock, 3)
		addStroke(lock, THEME.Outline, 1.2)
	elseif kind == "star5" then
		-- Ngoi sao vang 3D (Nhiem Vu giong anh mau)
		for _, rot in ipairs({0, 36, 72}) do
			local arm = Instance.new("Frame")
			arm.Size = UDim2.fromScale(0.76, 0.36)
			arm.Position = UDim2.fromScale(0.5, 0.5)
			arm.AnchorPoint = Vector2.new(0.5, 0.5)
			arm.Rotation = rot
			arm.BackgroundColor3 = Color3.fromRGB(246, 206, 48)
			arm.BorderSizePixel = 0
			arm.ZIndex = z + 1
			arm.Parent = box
			addCorner(arm, 4)
			addStroke(arm, THEME.Outline, 1.2)
		end
		local core = Instance.new("Frame")
		core.Size = UDim2.fromScale(0.46, 0.46)
		core.Position = UDim2.fromScale(0.5, 0.5)
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.BackgroundColor3 = Color3.fromRGB(252, 224, 92)
		core.BorderSizePixel = 0
		core.ZIndex = z + 2
		core.Parent = box
		addCorner(core, 99)
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
	place     = "rbxassetid://12222124",
	boss      = "rbxassetid://12222058",
	victory   = "rbxassetid://12222253",
	freeze    = "rbxassetid://12222030",
}
local sfxPool, sfxLast = {}, {}
local function playSfx(kind, pitch)
	if not saveState.SfxOn then return end
	local id = SFX_IDS[kind]
	if not id then return end
	local now = os.clock()
	if sfxLast[kind] and (now - sfxLast[kind]) < 0.06 then return end
	sfxLast[kind] = now
	pcall(function()
		local s = sfxPool[kind]
		if not (s and s.Parent) then
			s = Instance.new("Sound")
			s.SoundId = id
			s.Parent = screenGui
			sfxPool[kind] = s
		end
		s.Volume = ((kind == "explosion" or kind == "upgrade") and 0.34 or 0.22) * (saveState.SfxVol or 0.7)
		s.PlaybackSpeed = pitch or 1
		s.TimePosition = 0
		s:Play()
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
addCorner(mainFrame, 16)
addStroke(mainFrame, Color3.fromRGB(118, 86, 214), 2.4)
addGradient(mainFrame, Color3.fromRGB(24, 28, 54), Color3.fromRGB(11, 13, 26), 110)

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

-- Nut menu chinh thu nho thiet ke lai: Huy hieu Lau Dai 3D vien vang hien dai
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.fromOffset(56, 56)
floatBtn.Position = UDim2.new(0, 16, 0.5, -28)
floatBtn.BackgroundColor3 = Color3.fromRGB(24, 20, 56)
floatBtn.Text = ""
floatBtn.AutoButtonColor = false
floatBtn.BorderSizePixel = 0
floatBtn.ZIndex = 40
floatBtn.Parent = screenGui
addCorner(floatBtn, 16)
addStroke(floatBtn, THEME.TextGold, 2.6)
addGradient(floatBtn, Color3.fromRGB(68, 44, 146), Color3.fromRGB(22, 18, 52), 135)
add3DGloss(floatBtn, 14, 41, 0.78)

local fbInner = Instance.new("Frame")
fbInner.Size = UDim2.fromOffset(44, 44)
fbInner.Position = UDim2.fromScale(0.5, 0.5)
fbInner.AnchorPoint = Vector2.new(0.5, 0.5)
fbInner.BackgroundColor3 = Color3.fromRGB(18, 16, 44)
fbInner.BackgroundTransparency = 0.25
fbInner.BorderSizePixel = 0
fbInner.ZIndex = 41
fbInner.Parent = floatBtn
addCorner(fbInner, 12)
addStroke(fbInner, Color3.fromRGB(122, 92, 224), 1.4)

GFX.makeIcon(fbInner, "castle_logo", 28, UDim2.fromScale(0.5, 0.38), Vector2.new(0.5, 0.5), 42)

local fbTag = Instance.new("TextLabel")
fbTag.Size = UDim2.fromOffset(40, 14)
fbTag.Position = UDim2.new(0.5, 0, 1, -2)
fbTag.AnchorPoint = Vector2.new(0.5, 1)
fbTag.BackgroundColor3 = Color3.fromRGB(196, 142, 28)
fbTag.BorderSizePixel = 0
fbTag.Text = "TD 2D"
fbTag.TextColor3 = Color3.fromRGB(244, 246, 252)
fbTag.Font = THEME.FontHead
fbTag.TextSize = 8
fbTag.ZIndex = 44
fbTag.Parent = floatBtn
addCorner(fbTag, 5)
addStroke(fbTag, THEME.Outline, 1.3)
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
	addGradient(top, Color3.fromRGB(58, 46, 112), Color3.fromRGB(20, 22, 46), 90)
	add3DGloss(top, 10, 11, 0.84)

	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, 0, 0, 2)
	div.Position = UDim2.new(0, 0, 1, -2)
	div.BackgroundColor3 = Color3.fromRGB(112, 74, 204)
	div.BorderSizePixel = 0
	div.ZIndex = 11
	div.Parent = top

	local lbUrl = getMapImageAsset("logo_banner")
	if lbUrl then
		local lbImg = Instance.new("ImageLabel")
		lbImg.Size = UDim2.fromOffset(136, 38)
		lbImg.Position = UDim2.fromOffset(6, 5)
		lbImg.BackgroundTransparency = 1
		lbImg.Image = lbUrl
		lbImg.ScaleType = Enum.ScaleType.Fit
		lbImg.ZIndex = 12
		lbImg.Parent = top
		UI.topTitle = lbImg
	else
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
	end

	-- Cac chi so trong tran (an khi o sanh)
	local hudGroup = Instance.new("Frame")
	hudGroup.Size = UDim2.fromOffset(350, 40)
	hudGroup.Position = UDim2.fromOffset(146, 4)
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
		addGradient(p, Color3.fromRGB(28, 32, 62), Color3.fromRGB(12, 14, 28), 90)
		add3DGloss(p, 8, 12, 0.82)
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

	-- O Mau Thanh Tri (dung anh 3D + so nhay dong)
	local hpImgUrl = getMapImageAsset("pill_hp")
	local hpPill = Instance.new("Frame")
	hpPill.Size = UDim2.fromOffset(88, 34)
	hpPill.Position = UDim2.fromOffset(0, 3)
	hpPill.BackgroundColor3 = Color3.fromRGB(28, 16, 26)
	hpPill.BackgroundTransparency = hpImgUrl and 1 or 0
	hpPill.BorderSizePixel = 0
	hpPill.ClipsDescendants = true
	hpPill.ZIndex = 12
	hpPill.Parent = hudGroup
	if hpImgUrl then
		local hbg = Instance.new("ImageLabel")
		hbg.Size = UDim2.fromScale(1, 1)
		hbg.BackgroundTransparency = 1
		hbg.Image = hpImgUrl
		hbg.ScaleType = Enum.ScaleType.Fit
		hbg.ZIndex = 12
		hbg.Parent = hpPill
		UI.livesBarFill = nil
	else
		addCorner(hpPill, 10)
		addStroke(hpPill, Color3.fromRGB(206, 68, 76), 1.6)
		local hpBar = Instance.new("Frame")
		hpBar.Size = UDim2.fromScale(1, 1)
		hpBar.BackgroundColor3 = Color3.fromRGB(186, 44, 56)
		hpBar.BorderSizePixel = 0
		hpBar.ZIndex = 12
		hpBar.Parent = hpPill
		addCorner(hpBar, 9)
		UI.livesBarFill = hpBar
		GFX.makeIcon(hpPill, "heart", 18, UDim2.new(0, 14, 0.5, 0), Vector2.new(0.5, 0.5), 14)
	end
	local hpTxt = Instance.new("TextLabel")
	hpTxt.Size = UDim2.new(1, -30, 1, 0)
	hpTxt.Position = UDim2.fromOffset(28, 0)
	hpTxt.BackgroundTransparency = 1
	hpTxt.Text = "30/30"
	hpTxt.TextColor3 = THEME.TextMain
	hpTxt.Font = THEME.FontHead
	hpTxt.TextSize = 11
	hpTxt.ZIndex = 15
	hpTxt.Parent = hpPill
	addTextOutline(hpTxt, 1.5, THEME.Outline)
	UI.livesLbl = hpTxt

	-- O Vang (dung anh 3D + so vang nhay dong)
	local coinImgUrl = getMapImageAsset("pill_coin")
	if coinImgUrl then
		local cp = Instance.new("ImageLabel")
		cp.Size = UDim2.fromOffset(96, 34)
		cp.Position = UDim2.fromOffset(90, 3)
		cp.BackgroundTransparency = 1
		cp.Image = coinImgUrl
		cp.ScaleType = Enum.ScaleType.Fit
		cp.ZIndex = 12
		cp.Parent = hudGroup
		local cl = Instance.new("TextLabel")
		cl.Size = UDim2.new(1, -36, 1, 0)
		cl.Position = UDim2.fromOffset(32, 0)
		cl.BackgroundTransparency = 1
		cl.Text = "240"
		cl.TextColor3 = THEME.TextGold
		cl.Font = THEME.FontHead
		cl.TextSize = 12
		cl.ZIndex = 14
		cl.Parent = cp
		addTextOutline(cl, 1.5, THEME.Outline)
		UI.goldLbl = cl
	else
		UI.goldLbl = makeStatPill(90, 96, Color3.fromRGB(186, 146, 42), THEME.TextGold, "240", "coin")
	end

	-- O Dot Quai 3D (dung anh dau lau 3D + chu Dot X/Y nhay dong)
	local wImgUrl = getMapImageAsset("pill_wave")
	if wImgUrl then
		local wp = Instance.new("ImageLabel")
		wp.Size = UDim2.fromOffset(108, 34)
		wp.Position = UDim2.fromOffset(188, 3)
		wp.BackgroundTransparency = 1
		wp.Image = wImgUrl
		wp.ScaleType = Enum.ScaleType.Fit
		wp.ZIndex = 12
		wp.Parent = hudGroup
		local wLbl = Instance.new("TextLabel")
		wLbl.Size = UDim2.new(1, -36, 1, 0)
		wLbl.Position = UDim2.fromOffset(32, 0)
		wLbl.BackgroundTransparency = 1
		wLbl.RichText = true
		wLbl.Text = '<font color="#F0D23C">Đợt 0</font><font color="#E2E8F4">/12</font>'
		wLbl.TextColor3 = THEME.TextMain
		wLbl.Font = THEME.FontHead
		wLbl.TextSize = 11
		wLbl.ZIndex = 14
		wLbl.Parent = wp
		addTextOutline(wLbl, 1.4, THEME.Outline)
		UI.waveLbl = wLbl
	else
		local wavePill = Instance.new("Frame")
		wavePill.Size = UDim2.fromOffset(106, 32)
		wavePill.Position = UDim2.fromOffset(190, 4)
		wavePill.BackgroundColor3 = Color3.fromRGB(28, 26, 78)
		wavePill.BorderSizePixel = 0
		wavePill.ZIndex = 12
		wavePill.Parent = hudGroup
		addCorner(wavePill, 14)
		addStroke(wavePill, Color3.fromRGB(108, 98, 224), 2.0)
		GFX.makeIcon(wavePill, "skull", 20, UDim2.new(0, 15, 0.5, 0), Vector2.new(0.5, 0.5), 13)
		local wLbl = Instance.new("TextLabel")
		wLbl.Size = UDim2.new(1, -30, 1, 0)
		wLbl.Position = UDim2.fromOffset(26, 0)
		wLbl.BackgroundTransparency = 1
		wLbl.RichText = true
		wLbl.Text = '<font color="#F0D23C">Đợt 0</font><font color="#E2E8F4">/12</font>'
		wLbl.TextColor3 = THEME.TextMain
		wLbl.Font = THEME.FontHead
		wLbl.TextSize = 11
		wLbl.ZIndex = 14
		wLbl.Parent = wavePill
		UI.waveLbl = wLbl
	end

	local spdUrl = getMapImageAsset("spd_x1")
	if spdUrl then
		local sb = Instance.new("ImageButton")
		sb.Size = UDim2.fromOffset(36, 36)
		sb.Position = UDim2.fromOffset(302, 2)
		sb.BackgroundTransparency = 1
		sb.Image = spdUrl
		sb.ScaleType = Enum.ScaleType.Fit
		sb.AutoButtonColor = false
		sb.BorderSizePixel = 0
		sb.ZIndex = 12
		sb.Parent = hudGroup
		UI.spdBtn = sb
		UI.spdIsImg = true
		UI.spdLbl = { Text = "1x" }
	else
		local spdBtn, spdLbl = makeArcadeBtn(
			hudGroup, "1x",
			UDim2.fromOffset(44, 32), UDim2.fromOffset(298, 4),
			Color3.fromRGB(56, 148, 212), Color3.fromRGB(32, 86, 174), 9,
			{ TextSize = 12, ZIndex = 12, Depth = 3, Stroke = 1.6 }
		)
		UI.spdBtn = spdBtn
		UI.spdLbl = spdLbl
		UI.spdIsImg = false
	end


	UI.sfxLbl = { Text = "" }
	local m3Url = getMapImageAsset("btn_menu3")
	if m3Url then
		local mb = Instance.new("ImageButton")
		mb.Size = UDim2.fromOffset(46, 44)
		mb.Position = UDim2.new(1, -138, 0, 2)
		mb.BackgroundTransparency = 1
		mb.Image = m3Url
		mb.ScaleType = Enum.ScaleType.Fit
		mb.AutoButtonColor = false
		mb.BorderSizePixel = 0
		mb.Visible = false
		mb.ZIndex = 12
		mb.Parent = top
		UI.pauseBtn = mb
		UI.pauseLbl = { Text = "II" }
	else
		local pauseBtn, pauseLbl = makeArcadeBtn(
			top, "≡",
			UDim2.fromOffset(36, 32), UDim2.new(1, -124, 0, 8),
			Color3.fromRGB(48, 148, 232), Color3.fromRGB(24, 86, 182), 9,
			{ TextSize = 14, ZIndex = 12, Depth = 3, Stroke = 1.6 }
		)
		pauseBtn.Visible = false
		UI.pauseBtn = pauseBtn
		UI.pauseLbl = pauseLbl
	end
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
		local st = addStroke(card, mp.BossArena and Color3.fromRGB(196, 72, 92) or Color3.fromRGB(86, 98, 156), 2.2)
		add3DGloss(card, 12, 6, 0.82)

		-- Boi canh anh goc PNG 5 ban do (tu dong fallback ve vector neu Executor khong ho tro getcustomasset)
		local prev = Instance.new("Frame")
		prev.Size = UDim2.fromOffset(122, 118)
		prev.Position = UDim2.fromOffset(7, 10)
		prev.BackgroundTransparency = 1
		prev.BorderSizePixel = 0
		prev.ClipsDescendants = true
		prev.ZIndex = 6
		prev.Parent = card

		local imgUrl = getMapImageAsset(mp.Id)
		if imgUrl then
			local pic = Instance.new("ImageLabel")
			pic.Size = UDim2.fromScale(1, 1)
			pic.BackgroundTransparency = 1
			pic.Image = imgUrl
			pic.ScaleType = Enum.ScaleType.Fit
			pic.ZIndex = 7
			pic.Parent = prev
		else
			prev.BackgroundTransparency = 0
			prev.BackgroundColor3 = mp.Grass1
			addCorner(prev, 12)
			addStroke(prev, THEME.TextGold, 2.4)
			GFX.buildMapScene(prev, mp.Id, 6)
			add3DGloss(prev, 10, 11, 0.80)
		end

		local nLbl = Instance.new("TextLabel")
		nLbl.Size = UDim2.new(1, -12, 0, 26)
		nLbl.Position = UDim2.fromOffset(6, 138)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = mp.Name
		nLbl.TextColor3 = THEME.TextMain
		nLbl.Font = THEME.FontHead
		nLbl.TextSize = 13
		nLbl.ZIndex = 6
		nLbl.Parent = card

		local recLbl = Instance.new("TextLabel")
		recLbl.Size = UDim2.new(1, -12, 0, 18)
		recLbl.Position = UDim2.fromOffset(6, 166)
		recLbl.BackgroundTransparency = 1
		recLbl.Text = mp.Endless and "Vô Tận" or "Ải 1/7"
		recLbl.TextColor3 = THEME.TextMuted
		recLbl.Font = THEME.FontBody
		recLbl.TextSize = 11
		recLbl.ZIndex = 6
		recLbl.Parent = card

		mapCards[idx] = { Card = card, Stroke = st, RecLbl = recLbl, Map = mp }
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

	-- Nut Sanh dung anh goc 3D PNG (tu dong fallback ve nut vector neu khong ho tro getcustomasset)
	local function makeLobbyImgBtn(imgKey, fallbackTxt, size, pos, c1, c2, iconKind, badgeColor)
		local url = getMapImageAsset(imgKey)
		if url then
			local ib = Instance.new("ImageButton")
			ib.Size = size
			ib.Position = pos
			ib.BackgroundTransparency = 1
			ib.Image = url
			ib.ScaleType = Enum.ScaleType.Fit
			ib.AutoButtonColor = false
			ib.BorderSizePixel = 0
			ib.ZIndex = 6
			ib.Parent = lobbyPage
			local baseY = pos.Y.Offset
			ib.MouseButton1Down:Connect(function()
				ib.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, baseY + 2)
			end)
			local function up()
				ib.Position = pos
			end
			ib.MouseButton1Up:Connect(up)
			ib.MouseLeave:Connect(up)

			local badge = nil
			if badgeColor then
				badge = Instance.new("TextLabel")
				badge.Size = UDim2.fromOffset(34, 18)
				badge.Position = UDim2.new(1, -30, 0, -4)
				badge.BackgroundColor3 = badgeColor
				badge.BorderSizePixel = 0
				badge.Text = ""
				badge.TextColor3 = Color3.fromRGB(246, 248, 252)
				badge.Font = THEME.FontHead
				badge.TextSize = 10
				badge.Visible = false
				badge.ZIndex = 9
				badge.Parent = ib
				addCorner(badge, 9)
				addStroke(badge, THEME.Outline, 1.5)
			end
			return ib, badge, true
		else
			local b, lbl, face = makeArcadeBtn(
				lobbyPage, fallbackTxt, size, pos, c1, c2, 14,
				{ TextSize = 11, ZIndex = 6, Depth = 5, Stroke = 2.4, LabelPos = UDim2.fromOffset(16, 0), LabelSize = UDim2.new(1, -20, 1, 0) }
			)
			GFX.makeIcon(face, iconKind, 19, UDim2.new(0, 18, 0.5, 0), Vector2.new(0.5, 0.5), 9)
			return b, lbl, false
		end
	end

	local shopBtn = makeLobbyImgBtn("btn_shop", "CỬA HÀNG", UDim2.fromOffset(128, 48), UDim2.new(0.5, -340, 1, -64), Color3.fromRGB(236, 134, 34), Color3.fromRGB(186, 74, 18), "chest", nil)
	UI.shopBtn = shopBtn

	local bagBtn, bagLbl = makeLobbyImgBtn("btn_bag", "KHO ĐỒ", UDim2.fromOffset(128, 48), UDim2.new(0.5, -202, 1, -64), Color3.fromRGB(168, 68, 224), Color3.fromRGB(108, 32, 178), "chest", nil)
	UI.bagBtn = bagBtn
	UI.bagLbl = bagLbl

	local qBtn, qLbl, qIsImg = makeLobbyImgBtn("btn_quest", "NHIỆM VỤ", UDim2.fromOffset(128, 48), UDim2.new(0.5, -64, 1, -64), Color3.fromRGB(244, 206, 42), Color3.fromRGB(222, 132, 18), "star5", Color3.fromRGB(214, 52, 58))
	UI.questBtn = qBtn
	UI.questLbl = qLbl
	UI.qIsImg   = qIsImg

	local setBtn = makeLobbyImgBtn("btn_settings", "CÀI ĐẶT", UDim2.fromOffset(128, 48), UDim2.new(0.5, 74, 1, -64), Color3.fromRGB(48, 148, 232), Color3.fromRGB(24, 86, 182), "gear", nil)
	UI.settingsBtn = setBtn

	local lobbyExitBtn = makeLobbyImgBtn("btn_exit_lobby", "THOÁT", UDim2.fromOffset(128, 48), UDim2.new(0.5, 212, 1, -64), Color3.fromRGB(224, 58, 66), Color3.fromRGB(158, 24, 34), "close", nil)
	UI.lobbyExitBtn = lobbyExitBtn

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
	addGradient(pmBox, Color3.fromRGB(32, 36, 72), Color3.fromRGB(14, 16, 34), 95)
	add3DGloss(pmBox, 12, 52, 0.84)
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
	pmLay.Padding = UDim.new(0, 6)
	pmLay.Parent = pmList
	UI.pmList = pmList
end
SEC.buildLobby()

local function refreshLobbyStats()
	UI.lobbyStatsLbl.Text = "Tổng quái đã hạ: " .. formatNum(saveState.TotalKills) .. "  •  Sao kỹ năng: " .. formatNum(saveState.Stars)
	if UI.permUpgLbl then
		if UI.permIsImg then
			UI.permUpgLbl.Text = formatNum(saveState.Stars)
			UI.permUpgLbl.Visible = (saveState.Stars > 0)
		else
			UI.permUpgLbl.Text = "KỸ NĂNG (" .. formatNum(saveState.Stars) .. ")"
		end
	end
	if UI.questLbl then
		local readyQ = 0
		for _, q in ipairs(saveState.Quests) do if q.Progress >= q.Goal and not q.Claimed then readyQ += 1 end end
		if UI.qIsImg then
			UI.questLbl.Text = tostring(readyQ)
			UI.questLbl.Visible = (readyQ > 0)
		else
			UI.questLbl.Text = (readyQ > 0) and ("NHIỆM VỤ (" .. readyQ .. ")") or "NHIỆM VỤ"
		end
	end
	for j, mc in ipairs(mapCards) do
		local id = mc.Map.Id
		local uSt = math.clamp(saveState.StageUnlocked[id] or 1, 1, 7)
		mc.RecLbl.Text = mc.Map.Endless and "Chế độ Vô Tận" or ("Mở khóa: Ải " .. tostring(uSt) .. "/7")
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
	addGradient(leftHud, Color3.fromRGB(36, 42, 80), Color3.fromRGB(14, 16, 34), 90)
	add3DGloss(leftHud, 8, 6, 0.84)

	local lhTitle = Instance.new("TextLabel")
	lhTitle.Size = UDim2.new(1, 0, 0, 24)
	lhTitle.Position = UDim2.fromOffset(0, 6)
	lhTitle.BackgroundTransparency = 1
	lhTitle.Text = "KỸ NĂNG"
	lhTitle.TextColor3 = THEME.TextGold
	lhTitle.Font = Enum.Font.GothamBlack
	lhTitle.TextSize = 11
	addTextOutline(lhTitle, 1.4, THEME.Outline)
	lhTitle.ZIndex = 6
	lhTitle.Parent = leftHud

	-- 6 O Ky Nang & Vat Pham xep 1 hang doc can giua gon dep
	local function makeSkillSlot(idx, labelTxt, priceTxt, imgKey, c1, c2)
		local xPos = 19
		local yPos = 26 + (idx - 1) * 55
		local url = getMapImageAsset(imgKey)
		local btn
		if url then
			btn = Instance.new("ImageButton")
			btn.Size = UDim2.fromOffset(38, 38)
			btn.Position = UDim2.fromOffset(xPos, yPos)
			btn.BackgroundTransparency = 1
			btn.Image = url
			btn.ScaleType = Enum.ScaleType.Fit
			btn.AutoButtonColor = false
			btn.BorderSizePixel = 0
			btn.ZIndex = 7
			btn.Parent = leftHud
		else
			btn = makeArcadeBtn(leftHud, "", UDim2.fromOffset(38, 38), UDim2.fromOffset(xPos, yPos), c1, c2, 8, { ZIndex = 7, Depth = 2, Stroke = 1.4 })
		end
		local st = addStroke(btn, Color3.fromRGB(72, 78, 118), 1.5)
		addCorner(btn, 7)

		local costTag = Instance.new("TextLabel")
		costTag.Size = UDim2.fromOffset(28, 10)
		costTag.Position = UDim2.new(0.5, 0, 1, 0)
		costTag.AnchorPoint = Vector2.new(0.5, 1)
		costTag.BackgroundColor3 = Color3.fromRGB(14, 16, 30)
		costTag.BackgroundTransparency = 0.18
		costTag.BorderSizePixel = 0
		costTag.Text = priceTxt
		costTag.TextColor3 = THEME.TextGold
		costTag.Font = THEME.FontHead
		costTag.TextSize = 7
		costTag.ZIndex = 8
		costTag.Parent = btn
		addCorner(costTag, 3)

		local cdMask = Instance.new("TextLabel")
		cdMask.Size = UDim2.fromScale(1, 1)
		cdMask.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
		cdMask.BackgroundTransparency = 0.35
		cdMask.BorderSizePixel = 0
		cdMask.Text = ""
		cdMask.TextColor3 = THEME.TextGold
		cdMask.Font = THEME.FontHead
		cdMask.TextSize = 11
		cdMask.Visible = false
		cdMask.ZIndex = 9
		cdMask.Parent = btn
		addCorner(cdMask, 7)

		local cap = Instance.new("TextLabel")
		cap.Size = UDim2.fromOffset(72, 13)
		cap.Position = UDim2.fromOffset(2, yPos + 39)
		cap.BackgroundTransparency = 1
		cap.Text = labelTxt
		cap.TextColor3 = THEME.TextMain
		cap.Font = Enum.Font.GothamBlack
		cap.TextSize = 7
		cap.ZIndex = 7
		cap.Parent = leftHud
		addTextOutline(cap, 1.3, THEME.Outline)
		return btn, cdMask, st, costTag
	end

	UI.skillBtn,   UI.skillLbl,   UI.skillSt,    UI.skillQtyLbl   = makeSkillSlot(1, "Thiên Thạch", "x0", "sk_meteor",    Color3.fromRGB(224, 96, 46),  Color3.fromRGB(154, 34, 32))
	UI.blizBtn,    UI.blizLbl,    UI.blizSt,     UI.blizQtyLbl    = makeSkillSlot(2, "Bão Tuyết",   "x0", "sk_bliz",      Color3.fromRGB(54, 178, 228), Color3.fromRGB(28, 96, 178))
	UI.voidBtn,    UI.voidLbl,    UI.voidSt,     UI.voidQtyLbl    = makeSkillSlot(3, "Hố Đen",      "x0", "sk_void",      Color3.fromRGB(168, 56, 224), Color3.fromRGB(88, 22, 148))
	local _u
	UI.spikeBtn,   _u,            UI.spikeStroke,UI.spikeQtyLbl   = makeSkillSlot(4, "Bẫy Gai",     "x0", "icon_spike",   Color3.fromRGB(142, 62, 212), Color3.fromRGB(82, 32, 148))
	UI.mineBtn,    _u,            UI.mineStroke, UI.mineQtyLbl    = makeSkillSlot(5, "Mìn Nổ",      "x0", "icon_mine",    Color3.fromRGB(214, 72, 46),  Color3.fromRGB(146, 36, 28))
	UI.goldBagBtn, _u,            UI.goldBagSt,  UI.goldBagLbl    = makeSkillSlot(6, "Túi Vàng",    "x0", "icon_goldbag", Color3.fromRGB(236, 184, 38), Color3.fromRGB(178, 108, 16))

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
	addGradient(rightHud, Color3.fromRGB(36, 42, 80), Color3.fromRGB(14, 16, 34), 90)
	add3DGloss(rightHud, 8, 6, 0.84)

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
	UI.bpTitle = bpTitle

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
	upgradePopup.Size = UDim2.fromOffset(266, 126)
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

	local upPreview = Instance.new("TextLabel")
	upPreview.Size = UDim2.new(1, -16, 0, 14)
	upPreview.Position = UDim2.fromOffset(8, 35)
	upPreview.BackgroundTransparency = 1
	upPreview.Text = ""
	upPreview.TextColor3 = THEME.TextCyan
	upPreview.Font = THEME.FontHead
	upPreview.TextSize = 9
	upPreview.TextXAlignment = Enum.TextXAlignment.Left
	upPreview.ZIndex = 35
	upPreview.Parent = upgradePopup
	UI.upPreview = upPreview

	local upClose = makeArcadeBtn(
		upgradePopup, "X",
		UDim2.fromOffset(20, 18), UDim2.new(1, -24, 0, 3),
		Color3.fromRGB(204, 62, 68), Color3.fromRGB(142, 28, 36), 6,
		{ TextSize = 10, ZIndex = 35, Depth = 2, Stroke = 1.4 }
	)
	UI.upClose = upClose

	local upgBtn, upgLbl = makeArcadeBtn(
		upgradePopup, "NÂNG CẤP",
		UDim2.fromOffset(250, 28), UDim2.fromOffset(8, 52),
		Color3.fromRGB(64, 188, 96), Color3.fromRGB(28, 132, 58), 8,
		{ TextSize = 10, ZIndex = 35, Depth = 3, Stroke = 1.6 }
	)
	UI.upgBtn = upgBtn
	UI.upgLbl = upgLbl

	-- 2 nhanh tien hoa khi nang tu Cap 2 len Cap 3
	local evoABtn, evoALbl = makeArcadeBtn(
		upgradePopup, "HỦY DIỆT",
		UDim2.fromOffset(122, 28), UDim2.fromOffset(8, 52),
		Color3.fromRGB(214, 96, 48), Color3.fromRGB(154, 42, 32), 8,
		{ TextSize = 9, ZIndex = 35, Depth = 3, Stroke = 1.5 }
	)
	evoABtn.Visible = false
	UI.evoABtn = evoABtn
	UI.evoALbl = evoALbl

	local evoBBtn, evoBLbl = makeArcadeBtn(
		upgradePopup, "SIÊU TỐC",
		UDim2.fromOffset(122, 28), UDim2.fromOffset(136, 52),
		Color3.fromRGB(54, 152, 218), Color3.fromRGB(30, 88, 174), 8,
		{ TextSize = 9, ZIndex = 35, Depth = 3, Stroke = 1.5 }
	)
	evoBBtn.Visible = false
	UI.evoBBtn = evoBBtn
	UI.evoBLbl = evoBLbl

	local targetBtn, targetLbl = makeArcadeBtn(
		upgradePopup, "Mục tiêu: Xa nhất",
		UDim2.fromOffset(146, 28), UDim2.fromOffset(8, 88),
		Color3.fromRGB(108, 74, 186), Color3.fromRGB(66, 38, 134), 8,
		{ TextSize = 10, ZIndex = 35, Depth = 3, Stroke = 1.5 }
	)
	UI.targetBtn = targetBtn
	UI.targetLbl = targetLbl

	local sellBtn, sellLbl = makeArcadeBtn(
		upgradePopup, "BÁN",
		UDim2.fromOffset(98, 28), UDim2.fromOffset(160, 88),
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
	addStroke(botBar, Color3.fromRGB(92, 82, 168), 1.8)
	addGradient(botBar, Color3.fromRGB(34, 38, 72), Color3.fromRGB(16, 18, 36), 90)
	add3DGloss(botBar, 8, 7, 0.84)

	local infoLbl = Instance.new("TextLabel")
	infoLbl.Size = UDim2.fromOffset(316, 36)
	infoLbl.Position = UDim2.fromOffset(12, 1)
	infoLbl.BackgroundTransparency = 1
	infoLbl.Text = "Chạm ô cỏ để xây tháp  •  Chạm tháp để nâng cấp"
	infoLbl.TextColor3 = THEME.TextMain
	infoLbl.Font = THEME.FontBody
	infoLbl.TextSize = 11
	infoLbl.TextXAlignment = Enum.TextXAlignment.Left
	infoLbl.TextTruncate = Enum.TextTruncate.AtEnd
	infoLbl.ZIndex = 7
	infoLbl.Visible = false
	infoLbl.Text = ""
	infoLbl.Parent = botBar
	UI.botInfoLbl = infoLbl
	UI.trapLbl = { Text = "BẪY: TẮT" }

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

	-- Bieu ngu canh bao Boss xuat hien
	local bossWarn = Instance.new("Frame")
	bossWarn.Size = UDim2.fromOffset(420, 34)
	bossWarn.Position = UDim2.new(0.5, 0, 0, 42)
	bossWarn.AnchorPoint = Vector2.new(0.5, 0)
	bossWarn.BackgroundColor3 = Color3.fromRGB(148, 24, 42)
	bossWarn.BorderSizePixel = 0
	bossWarn.Visible = false
	bossWarn.ZIndex = 39
	bossWarn.Parent = board
	addCorner(bossWarn, 9)
	addStroke(bossWarn, THEME.TextGold, 2.2)
	addGradient(bossWarn, Color3.fromRGB(196, 36, 58), Color3.fromRGB(112, 16, 32), 90)
	UI.bossWarn = bossWarn

	local bossWarnLbl = Instance.new("TextLabel")
	bossWarnLbl.Size = UDim2.fromScale(1, 1)
	bossWarnLbl.BackgroundTransparency = 1
	bossWarnLbl.Text = "CẢNH BÁO BOSS ĐANG TIẾN VÀO!"
	bossWarnLbl.TextColor3 = THEME.TextGold
	bossWarnLbl.Font = THEME.FontHead
	bossWarnLbl.TextSize = 13
	bossWarnLbl.ZIndex = 40
	bossWarnLbl.Parent = bossWarn
	addTextOutline(bossWarnLbl, 1.8, THEME.Outline)
	UI.bossWarnLbl = bossWarnLbl

	-- Bang Ket Thuc (Thang / Thua) co bieu do sat thuong + nut Choi Lai Ngay
	local endCard = Instance.new("Frame")
	endCard.Size = UDim2.fromOffset(376, 286)
	endCard.Position = UDim2.fromScale(0.5, 0.5)
	endCard.AnchorPoint = Vector2.new(0.5, 0.5)
	endCard.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	endCard.BorderSizePixel = 0
	endCard.Visible = false
	endCard.ZIndex = 45
	endCard.Parent = board
	addCorner(endCard, 14)
	UI.endStroke = addStroke(endCard, THEME.TextGold, 2.6)
	addGradient(endCard, Color3.fromRGB(32, 38, 72), Color3.fromRGB(14, 16, 34), 95)
	add3DGloss(endCard, 12, 46, 0.84)
	UI.endCard = endCard

	local endTitle = Instance.new("TextLabel")
	endTitle.Size = UDim2.new(1, 0, 0, 30)
	endTitle.Position = UDim2.fromOffset(0, 10)
	endTitle.BackgroundTransparency = 1
	endTitle.Text = "CHIẾN THẮNG!"
	endTitle.TextColor3 = THEME.TextGold
	endTitle.Font = THEME.FontHead
	endTitle.TextSize = 19
	endTitle.ZIndex = 46
	endTitle.Parent = endCard
	addTextOutline(endTitle, 2, THEME.Outline)
	UI.endTitle = endTitle

	local endDesc = Instance.new("TextLabel")
	endDesc.Size = UDim2.new(1, -24, 0, 38)
	endDesc.Position = UDim2.fromOffset(12, 42)
	endDesc.BackgroundTransparency = 1
	endDesc.Text = ""
	endDesc.TextColor3 = THEME.TextMain
	endDesc.Font = THEME.FontBody
	endDesc.TextSize = 12
	endDesc.TextWrapped = true
	endDesc.ZIndex = 46
	endDesc.Parent = endCard
	UI.endDesc = endDesc

	local endChartBox = Instance.new("Frame")
	endChartBox.Size = UDim2.new(1, -28, 0, 134)
	endChartBox.Position = UDim2.fromOffset(14, 86)
	endChartBox.BackgroundColor3 = Color3.fromRGB(14, 18, 34)
	endChartBox.BorderSizePixel = 0
	endChartBox.ZIndex = 46
	endChartBox.Parent = endCard
	addCorner(endChartBox, 9)
	addStroke(endChartBox, Color3.fromRGB(64, 72, 118), 1.4)
	UI.endChartBox = endChartBox

	local contUrl = getMapImageAsset("btn_continue")
	if contUrl then
		local cb = Instance.new("ImageButton")
		cb.Size = UDim2.fromOffset(162, 42)
		cb.Position = UDim2.fromOffset(18, 232)
		cb.BackgroundTransparency = 1
		cb.Image = contUrl
		cb.ScaleType = Enum.ScaleType.Fit
		cb.AutoButtonColor = false
		cb.BorderSizePixel = 0
		cb.ZIndex = 47
		cb.Parent = endCard
		UI.endReplayBtn = cb
	else
		UI.endReplayBtn = makeArcadeBtn(endCard, "TIẾP TỤC", UDim2.fromOffset(162, 38), UDim2.fromOffset(18, 234), Color3.fromRGB(64, 198, 86), Color3.fromRGB(28, 136, 52), 10, { TextSize = 12, ZIndex = 47, Depth = 4 })
	end
	UI.endHomeBtn   = makeArcadeBtn(endCard, "VỀ SẢNH",       UDim2.fromOffset(162, 38), UDim2.fromOffset(196, 234), Color3.fromRGB(142, 72, 208), Color3.fromRGB(88, 36, 162), 10, { TextSize = 12, ZIndex = 47, Depth = 4 })
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
		if (q.Track or q.Id) == qId and not q.Claimed then
			q.Progress = math.min(q.Goal, q.Progress + amt)
		end
	end
end

local function cellCenter(gx, gy)
	return (gx - 0.5) * CELL, (gy - 0.5) * CELL
end

local function canSpawnFx(priority)
	local cap = saveState.LowFx and 4 or 14
	if priority then cap += 4 end
	if (TD.fxCount or 0) >= cap then return false end
	TD.fxCount = (TD.fxCount or 0) + 1
	return true
end

local function releaseFx(inst)
	TD.fxCount = math.max(0, (TD.fxCount or 1) - 1)
	if inst and inst.Parent then inst:Destroy() end
end

local function spawnFloatingText(x, y, text, col)
	if saveState.LowFx or not canSpawnFx(true) then return end
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(80, 18)
	lbl.Position = UDim2.fromOffset(x, y - 10)
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = col or THEME.TextGold
	lbl.TextStrokeTransparency = 0.25
	lbl.TextStrokeColor3 = THEME.Outline
	lbl.Font = THEME.FontHead
	lbl.TextSize = 11
	lbl.ZIndex = 28
	lbl.Parent = UI.fxLayer
	local tw = TweenService:Create(lbl, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(x, y - 30),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	tw:Play()
	tw.Completed:Connect(function() releaseFx(lbl) end)
end

local function spawnDmgNumber(x, y, dmg, isCrit)
	if saveState.LowFx or not canSpawnFx(isCrit) then return end
	local jx = math.random(-10, 10)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(isCrit and 74 or 52, 16)
	lbl.Position = UDim2.fromOffset(x + jx, y - 10)
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.BackgroundTransparency = 1
	lbl.Text = isCrit and ("CRIT -" .. formatNum(dmg)) or ("-" .. formatNum(dmg))
	lbl.TextColor3 = isCrit and Color3.fromRGB(238, 198, 54) or Color3.fromRGB(218, 224, 236)
	lbl.TextStrokeTransparency = 0.25
	lbl.TextStrokeColor3 = THEME.Outline
	lbl.Font = THEME.FontHead
	lbl.TextSize = isCrit and 12 or 10
	lbl.ZIndex = 29
	lbl.Parent = UI.fxLayer
	local tw = TweenService:Create(lbl, TweenInfo.new(isCrit and 0.52 or 0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(x + jx, y - (isCrit and 30 or 22)),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	tw:Play()
	tw.Completed:Connect(function() releaseFx(lbl) end)
end

local function spawnWeatherParticle(mp)
	if saveState.LowFx or not mp or not canSpawnFx(false) then return end
	local p = Instance.new("Frame")
	local boardW, boardH = COLS * CELL, ROWS * CELL
	local sx, sy, ex, ey, col, sz, dur
	if mp.Id == "desert" then
		sx, sy = math.random(12, boardW - 12), boardH - 6
		ex, ey = sx + math.random(-34, 34), sy - math.random(90, 160)
		col, sz, dur = Color3.fromRGB(232, 128, 48), math.random(3, 5), 2.0
	elseif mp.Id == "citadel" then
		sx, sy = math.random(12, boardW - 12), math.random(12, boardH - 12)
		ex, ey = sx + math.random(-40, 40), sy - math.random(24, 54)
		col, sz, dur = Color3.fromRGB(168, 112, 226), math.random(4, 6), 2.4
	elseif mp.BossArena then
		sx, sy = math.random(12, boardW - 12), boardH - 6
		ex, ey = sx + math.random(-44, 44), sy - math.random(100, 180)
		col, sz, dur = Color3.fromRGB(224, 68, 62), math.random(3, 5), 1.9
	elseif mp.Endless then
		sx, sy = math.random(12, boardW - 12), 6
		ex, ey = sx + math.random(-28, 28), sy + math.random(90, 160)
		col, sz, dur = Color3.fromRGB(112, 206, 232), math.random(3, 5), 2.2
	else
		sx, sy = math.random(12, boardW - 12), 6
		ex, ey = sx + math.random(28, 66), sy + math.random(90, 150)
		col, sz, dur = Color3.fromRGB(108, 198, 92), math.random(4, 6), 2.3
	end
	p.Size = UDim2.fromOffset(sz, sz)
	p.Position = UDim2.fromOffset(sx, sy)
	p.BackgroundColor3 = col
	p.BackgroundTransparency = 0.28
	p.BorderSizePixel = 0
	p.ZIndex = 23
	p.Parent = UI.fxLayer
	addCorner(p, 99)
	local tw = TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(ex, ey),
		BackgroundTransparency = 1
	})
	tw:Play()
	tw.Completed:Connect(function() releaseFx(p) end)
end

local function spawnCastleSmoke(x, y)
	if saveState.LowFx or not canSpawnFx(false) then return end
	local s = Instance.new("Frame")
	s.Size = UDim2.fromOffset(8, 8)
	s.Position = UDim2.fromOffset(x + math.random(-10, 10), y + math.random(-8, 4))
	s.AnchorPoint = Vector2.new(0.5, 0.5)
	s.BackgroundColor3 = (math.random(1, 3) == 1) and Color3.fromRGB(218, 88, 44) or Color3.fromRGB(82, 86, 102)
	s.BackgroundTransparency = 0.25
	s.BorderSizePixel = 0
	s.ZIndex = 25
	s.Parent = UI.fxLayer
	addCorner(s, 99)
	local tw = TweenService:Create(s, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(x + math.random(-16, 16), y - 28),
		Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1
	})
	tw:Play()
	tw.Completed:Connect(function() releaseFx(s) end)
end

local function showBossWarning(bossName)
	if not UI.bossWarn then return end
	UI.bossWarnLbl.Text = "CẢNH BÁO BOSS: " .. tostring(bossName) .. " ĐANG TIẾN VÀO!"
	UI.bossWarn.Visible = true
	UI.bossWarn.BackgroundTransparency = 0.1
	TD.bossWarnSeq = (TD.bossWarnSeq or 0) + 1
	local seq = TD.bossWarnSeq
	task.delay(2.5, function()
		if TD.bossWarnSeq == seq and UI.bossWarn then
			UI.bossWarn.Visible = false
		end
	end)
end

local function updateTowerVisual(t)
	if not t or not t.Node or not t.Node.Parent then return end
	if not t.EvoRing then
		local er = Instance.new("Frame")
		er.Size = UDim2.fromOffset(CELL - 2, CELL - 2)
		er.Position = UDim2.fromScale(0.5, 0.5)
		er.AnchorPoint = Vector2.new(0.5, 0.5)
		er.BackgroundTransparency = 1
		er.ZIndex = 10
		er.Parent = t.Node
		addCorner(er, 99)
		t.EvoStroke = addStroke(er, THEME.TextGold, 1.8)
		t.EvoRing = er
	end
	if t.Level == 2 then
		t.EvoRing.Visible = true
		t.EvoStroke.Color = Color3.fromRGB(162, 186, 218)
		t.EvoStroke.Thickness = 1.8
		t.LvTag.TextColor3 = Color3.fromRGB(204, 216, 232)
	elseif t.Level == 3 then
		t.EvoRing.Visible = true
		if t.Branch == "Hủy Diệt" then
			t.EvoStroke.Color = Color3.fromRGB(224, 82, 58)
			t.EvoStroke.Thickness = 2.4
			t.LvTag.TextColor3 = Color3.fromRGB(232, 108, 76)
			if t.Barrel then t.Barrel.BackgroundColor3 = Color3.fromRGB(224, 96, 56) end
		elseif t.Branch == "Siêu Tốc" then
			t.EvoStroke.Color = THEME.TextCyan
			t.EvoStroke.Thickness = 2.4
			t.LvTag.TextColor3 = THEME.TextCyan
			if t.Barrel then t.Barrel.BackgroundColor3 = Color3.fromRGB(82, 206, 232) end
		else
			t.EvoStroke.Color = THEME.TextGold
			t.EvoStroke.Thickness = 2.2
		end
	elseif t.Level >= 4 then
		t.EvoRing.Visible = true
		t.EvoStroke.Color = (t.Level >= 6) and Color3.fromRGB(214, 92, 232) or THEME.TextGold
		t.EvoStroke.Thickness = 2.8
		t.LvTag.TextColor3 = THEME.TextGold
		if not t.CrownDot then
			local cr = Instance.new("Frame")
			cr.Size = UDim2.fromOffset(8, 8)
			cr.Position = UDim2.new(0.5, 0, 0, 2)
			cr.AnchorPoint = Vector2.new(0.5, 0)
			cr.BackgroundColor3 = THEME.TextGold
			cr.BorderSizePixel = 0
			cr.ZIndex = 17
			cr.Parent = t.Node
			addCorner(cr, 99)
			addStroke(cr, THEME.Outline, 1.2)
			t.CrownDot = cr
		end
		t.CrownDot.BackgroundColor3 = (t.Level >= 6) and Color3.fromRGB(214, 92, 232) or THEME.TextGold
	end
end

local function spawnExplosionRing(x, y, radius, col)
	if (saveState.LowFx and radius < 40) or not canSpawnFx(radius >= 40) then return end
	local ring = Instance.new("Frame")
	ring.Size = UDim2.fromOffset(10, 10)
	ring.Position = UDim2.fromOffset(x, y)
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.BackgroundColor3 = col
	ring.BackgroundTransparency = 0.42
	ring.BorderSizePixel = 0
	ring.ZIndex = 24
	ring.Parent = UI.fxLayer
	addCorner(ring, 999)
	local tw = TweenService:Create(ring, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(radius * 2, radius * 2),
		BackgroundTransparency = 1
	})
	tw:Play()
	tw.Completed:Connect(function() releaseFx(ring) end)
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
	TD.previewTowerIdx = nil
	UI.buildPopup.Visible = false
	UI.upgradePopup.Visible = false
	UI.tileMarker.Visible = false
	UI.rangeRing.Visible = false
end

local function getNextWavePreviewText()
	if not TD.map then return "" end
	local cacheKey = tostring(TD.map.Id) .. "_" .. tostring(TD.wave)
	if TD.previewCacheKey == cacheKey and TD.previewCacheTxt then
		return TD.previewCacheTxt
	end
	if (not TD.map.Endless) and TD.wave >= TD.map.Waves then
		return "Đã hoàn thành tất cả đợt quái!"
	end
	local nw = TD.wave + 1
	local q = UI.buildWaveQueueFn and UI.buildWaveQueueFn(nw) or nil
	if not q or #q == 0 then return "Chạm ô cỏ để xây tháp  •  Chạm tháp để nâng cấp" end
	local counts, order = {}, {}
	for _, k in ipairs(q) do
		if not counts[k] then
			counts[k] = 0
			table.insert(order, k)
		end
		counts[k] += 1
	end
	local parts = {}
	for idx = 1, math.min(4, #order) do
		local k = order[idx]
		local ed = ENEMIES[k]
		local nm = ed and ed.Name or k
		table.insert(parts, (ed and ed.Boss) and ("BOSS " .. nm) or (tostring(counts[k]) .. " " .. nm))
	end
	if #order > 4 then table.insert(parts, "...") end
	local res = "Đợt " .. tostring(nw) .. " tới: " .. table.concat(parts, " • ")
	TD.previewCacheKey = cacheKey
	TD.previewCacheTxt = res
	return res
end

local getTowerBuffMults
local function updateHUD()
	local curL, maxL = math.max(0, TD.lives), math.max(1, TD.maxLives)
	UI.livesLbl.Text = tostring(curL) .. "/" .. tostring(maxL)
	if UI.livesBarFill then UI.livesBarFill.Size = UDim2.fromScale(math.clamp(curL / maxL, 0, 1), 1) end
	UI.goldLbl.Text  = formatNum(TD.gold)
	UI.waveLbl.Text  = TD.map.Endless and ('<font color="#F0D23C">Đợt ' .. tostring(TD.wave) .. '</font><font color="#E2E8F4"> ∞</font>') or ('<font color="#F0D23C">Đợt ' .. tostring(TD.wave) .. '</font><font color="#E2E8F4">/' .. tostring(TD.map.Waves) .. '</font>')
	if UI.spdIsImg then
		local su = getMapImageAsset("spd_x" .. tostring(TD.speedMult))
		if su then UI.spdBtn.Image = su end
	else
		UI.spdLbl.Text = tostring(TD.speedMult) .. "x"
	end

	if TD.pendingCell then
		local cx, cy = cellCenter(TD.pendingCell.gx, TD.pendingCell.gy)
		UI.tileMarker.Visible = true
		UI.tileMarker.Position = UDim2.fromOffset(cx, cy)
		UI.buildPopup.Visible = true
		positionPopupNear(UI.buildPopup, cx, cy, 430, 86)
		for idx, pb in ipairs(popupBuildBtns) do
			local afford = (TD.gold >= pb.Def.Cost)
			local isPrev = (TD.previewTowerIdx == idx)
			pb.Stroke.Color = isPrev and THEME.TextCyan or (afford and THEME.TextGold or Color3.fromRGB(118, 52, 58))
			pb.Stroke.Thickness = isPrev and 2.6 or 1.6
			pb.PriceLbl.TextColor3 = afford and THEME.TextGold or THEME.TextRed
		end
		if TD.previewTowerIdx and TOWERS[TD.previewTowerIdx] then
			local pDef = TOWERS[TD.previewTowerIdx]
			UI.rangeRing.Visible = true
			UI.rangeRing.Position = UDim2.fromOffset(cx, cy)
			UI.rangeRing.Size = UDim2.fromOffset(pDef.Range * 2, pDef.Range * 2)
			if UI.bpTitle then UI.bpTitle.Text = pDef.Name .. " (Tầm " .. tostring(pDef.Range) .. ") — CHẠM LẠI ĐỂ XÂY" end
		else
			if UI.bpTitle then UI.bpTitle.Text = "CHỌN THÁP ĐỂ XÂY (Chạm 1 lần xem tầm)" end
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
		positionPopupNear(UI.upgradePopup, t.X, t.Y, 266, 126)
		local brTxt = t.Branch and (" • " .. t.Branch) or ""
		UI.upTitle.Text = string.format("%s • Cấp %d%s", t.Def.Name, t.Level, brTxt)
		local isEvoChoice = (t.Level == 3 and not t.Branch)
		if t.Def.Kind == "Buff" then
			local isRng = (t.BuffMode == "range")
			local curPct = math.floor((isRng and (t.BuffRange or 0.24) or (t.BuffDmg or 0.28)) * 100)
			UI.upStats.Text = isRng
				and string.format("Buff Tầm: +%d%% • Phủ: %d", curPct, math.floor(t.Range))
				or string.format("Buff ST: +%d%% • Tốc +%d%% • Phủ: %d", curPct, math.floor((t.BuffRate or 0.20)*100), math.floor(t.Range))
			if isEvoChoice then
				UI.upPreview.Text = "Hủy Diệt: Buff +10% | Siêu Tốc: Phủ +16% & Tốc +8%"
			elseif t.Level < 3 then
				local nPct = curPct + 6
				local nRng = math.floor(t.Range * 1.08)
				UI.upPreview.Text = string.format("Nâng: %s +%d%%→+%d%% | Phủ: %d→%d", isRng and "Tầm" or "ST", curPct, nPct, math.floor(t.Range), nRng)
			else
				local nPct = math.min(65, curPct + 4)
				local nRng = math.min(230, math.floor(t.Range + 3))
				UI.upPreview.Text = string.format("Cường hóa: +%d%%→+%d%% | Phủ: %d→%d", curPct, nPct, math.floor(t.Range), nRng)
			end
		else
			local bD, bR, bRg = 1, 1, 1
			if getTowerBuffMults then bD, bR, bRg = getTowerBuffMults(t) end
			local curD = math.floor(t.Damage * bD)
			local curRg = math.floor(t.Range * bRg)
			UI.upStats.Text = string.format("ST: %d • Tầm: %d • Tốc: %.2fs", curD, curRg, t.FireRate * bR)
			if isEvoChoice then
				local dA = math.floor(t.Damage * 1.50)
				local rB = math.floor(t.Range * 1.16)
				local fB = math.max(0.22, t.FireRate * 0.74)
				UI.upPreview.Text = string.format("Hủy Diệt: ST→%d | Siêu Tốc: Tầm→%d, Tốc→%.2fs", dA, rB, fB)
			elseif t.Level < 3 then
				local nD = math.floor(t.Damage * 1.35)
				local nRg = math.floor(t.Range * 1.08)
				local nFr = math.max(0.28, t.FireRate * 0.92)
				UI.upPreview.Text = string.format("Nâng: ST %d→%d | Tầm %d→%d | Tốc %.2f→%.2fs", math.floor(t.Damage), nD, math.floor(t.Range), nRg, t.FireRate, nFr)
			else
				local nD = math.floor(t.Damage * 1.18)
				local nRg = math.min(230, math.floor(t.Range + 3))
				UI.upPreview.Text = string.format("Cường hóa: ST %d→%d | Tầm %d→%d", math.floor(t.Damage), nD, math.floor(t.Range), nRg)
			end
		end
		if isEvoChoice then
			UI.upgBtn.Visible = false
			UI.evoABtn.Visible = true
			UI.evoBBtn.Visible = true
			UI.evoALbl.Text = "HỦY DIỆT (" .. formatNum(upCost) .. "V)"
			UI.evoBLbl.Text = "SIÊU TỐC (" .. formatNum(upCost) .. "V)"
		else
			UI.upgBtn.Visible = true
			UI.evoABtn.Visible = false
			UI.evoBBtn.Visible = false
			UI.upgLbl.Text = (t.Level < 3) and ("NÂNG CẤP C" .. tostring(t.Level + 1) .. " (" .. formatNum(upCost) .. "V)") or ("CƯỜNG HÓA C" .. tostring(t.Level + 1) .. " (" .. formatNum(upCost) .. "V)")
		end
		if t.Def.Kind == "Buff" then
			UI.targetLbl.Text = (t.BuffMode == "range") and "Chế độ: Buff Tầm" or "Chế độ: Buff Sức Mạnh"
		else
			local mNames = { First = "Xa nhất", Strong = "Máu cao", Weak = "Máu thấp" }
			UI.targetLbl.Text = "Mục tiêu: " .. (mNames[t.TargetMode or "First"] or "Xa nhất")
		end
		UI.sellLbl.Text = "BÁN (+" .. sellVal .. "V)"
		UI.rangeRing.Visible = true
		UI.rangeRing.Position = UDim2.fromOffset(t.X, t.Y)
		local _, _, ringMult = 1, 1, 1
		if t.Def.Kind ~= "Buff" and getTowerBuffMults then _, _, ringMult = getTowerBuffMults(t) end
		local showR = t.Range * (ringMult or 1)
		UI.rangeRing.Size = UDim2.fromOffset(showR * 2, showR * 2)
		
	else
		UI.upgradePopup.Visible = false
		if not (TD.pendingCell and TD.previewTowerIdx) then
			UI.rangeRing.Visible = false
		end
		if TD.pendingCell then
			
		else
			
		end
	end

	local function setCdMask(mask, cd)
		if not mask then return end
		if (cd or 0) > 0 then
			mask.Visible = true
			mask.Text = tostring(math.ceil(cd)) .. "s"
		else
			mask.Visible = false
		end
	end
	setCdMask(UI.skillLbl,   TD.skillCd)
	setCdMask(UI.blizLbl,    TD.blizCd)
	setCdMask(UI.voidLbl,    TD.voidCd)
	if UI.skillQtyLbl then UI.skillQtyLbl.Text = "x" .. tostring(saveState.SkillStock.meteor or 0) end
	if UI.blizQtyLbl  then UI.blizQtyLbl.Text  = "x" .. tostring(saveState.SkillStock.bliz or 0) end
	if UI.voidQtyLbl  then UI.voidQtyLbl.Text  = "x" .. tostring(saveState.SkillStock.void or 0) end
	if UI.spikeQtyLbl then UI.spikeQtyLbl.Text = "x" .. tostring(saveState.SkillStock.spike or 0) end
	if UI.mineQtyLbl  then UI.mineQtyLbl.Text  = "x" .. tostring(saveState.SkillStock.mine or 0) end
	if UI.goldBagLbl  then UI.goldBagLbl.Text  = "x" .. tostring(saveState.Bag.goldbag or 0) end
	local nowT = os.clock()
	if (not TD.lastDmgUi) or (nowT - TD.lastDmgUi >= 0.45) or TD.over or TD.wave == 0 then
		TD.lastDmgUi = nowT
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
	end

	if TD.waveSpawning or #TD.enemies > 0 then
		UI.waveBtnLbl.Text = "ĐANG CHIẾN..."
	elseif (not TD.map.Endless) and TD.wave >= TD.map.Waves then
		UI.waveBtnLbl.Text = "HOÀN THÀNH"
	else
		local nw = TD.wave + 1
		local nextBoss = TD.map.BossArena or (TD.map.Endless and nw % 3 == 0) or ((not TD.map.Endless) and (nw % 5 == 0 or nw == TD.map.Waves))
		UI.waveBtnLbl.Text = nextBoss and ("ĐỢT " .. tostring(nw) .. " (BOSS)") or ("GỌI ĐỢT " .. tostring(nw))
	end
end

local function clearMatchLayers(asyncMode)
	TD.boardToken = (TD.boardToken or 0) + 1
	local myTok = TD.boardToken
	TD.towers = {}
	TD.enemies = {}
	TD.projectiles = {}
	TD.obstacles = {}
	TD.traps = {}
	TD.fxCount = 0
	closeBoardPopups()
	local layers = { UI.fxLayer, UI.enemyLayer, UI.trapLayer, UI.towerLayer, UI.tileLayer }
	if asyncMode then
		task.spawn(function()
			for _, ly in ipairs(layers) do
				if TD.boardToken ~= myTok then return end
				if ly and ly.Parent then ly:ClearAllChildren() end
				task.wait()
			end
		end)
	else
		for _, ly in ipairs(layers) do
			if ly and ly.Parent then ly:ClearAllChildren() end
		end
	end
end

local function finishMatch(won)
	TD.over = true
	TD.active = false
	local mid = TD.map.Id
	if TD.wave > (saveState.BestWave[mid] or 0) then
		saveState.BestWave[mid] = TD.wave
	end
	local diffMult = (getDiffDef(saveState.Difficulty).StarMult or 1)
	local matchStars = 0
	local earnedStageStars = 0
	local starNote = ""
	local stKey = mid .. "_" .. tostring(TD.stage or 1)
	if won then
		saveState.Wins[mid] = (saveState.Wins[mid] or 0) + 1
		-- Co che tinh Sao cho moi Ai:
		-- Khong lot con nao = 3 Sao | Lot >=1 con (con >50% tim) = -1 Sao (2 Sao) | Mat >=50% so tim = -2 Sao (1 Sao)
		if TD.lives <= TD.maxLives * 0.5 then
			earnedStageStars = 1
			starNote = "1/3 Sao (-2 Sao do mất >=50% tim)"
		elseif (TD.leaks or 0) >= 1 or TD.lives < TD.maxLives then
			earnedStageStars = 2
			starNote = "2/3 Sao (-1 Sao do lọt quái)"
		else
			earnedStageStars = 3
			starNote = "3/3 Sao (Toàn thắng không lọt quái!)"
		end
		if earnedStageStars > (saveState.StageStars[stKey] or 0) then
			saveState.StageStars[stKey] = earnedStageStars
		end
		if earnedStageStars > (saveState.MapStars[mid] or 0) then
			saveState.MapStars[mid] = earnedStageStars
		end
		-- Mo khoa cap do tiep theo cho Ai nay (De -> Binh Thuong -> Kho)
		local curDiffIdx = (saveState.Difficulty == "hard") and 3 or ((saveState.Difficulty == "normal") and 2 or 1)
		local nextDiffLv = math.min(3, curDiffIdx + 1)
		if nextDiffLv > (saveState.StageDiffUnlocked[stKey] or 1) then
			saveState.StageDiffUnlocked[stKey] = nextDiffLv
		end
		-- Thuong Sao ky nang cong them + Thuong Vuot Lan Dau (First Clear) + Thuong Tron 3 Sao
		matchStars = math.floor((10 + (TD.stage or 1) * 3 + earnedStageStars * 4) * diffMult + 0.5)
		if not TD.map.Endless then
			local fcKey = stKey .. "_" .. tostring(saveState.Difficulty)
			if not saveState.FirstCleared[fcKey] then
				saveState.FirstCleared[fcKey] = true
				local fcBonus = (saveState.Difficulty == "hard") and 40 or ((saveState.Difficulty == "normal") and 25 or 15)
				matchStars += fcBonus
				starNote = starNote .. " | Lần đầu +" .. tostring(fcBonus) .. "★"
			end
			if earnedStageStars == 3 and not saveState.Perfect3Star[fcKey] then
				saveState.Perfect3Star[fcKey] = true
				local p3Bonus = (saveState.Difficulty == "hard") and 30 or ((saveState.Difficulty == "normal") and 20 or 15)
				matchStars += p3Bonus
				saveState.Bag.goldbag = (saveState.Bag.goldbag or 0) + 1
				starNote = starNote .. " | Trọn 3★ +" .. tostring(p3Bonus) .. "★ & +1 Túi Vàng"
			end
		end
		saveState.Stars += matchStars
		playSfx("victory", 1.25)
		TD.shakeTime = 0.16
		if (not TD.map.Endless) and (TD.stage or 1) < 7 then
			local nextSt = (TD.stage or 1) + 1
			if nextSt > (saveState.StageUnlocked[mid] or 1) then
				saveState.StageUnlocked[mid] = nextSt
			end
			saveState.SelectedStage = nextSt
		end
		addQuestProg("win", 1)
	elseif TD.wave > 0 then
		-- Che do Vo Tan: dat Dot 10 mo Binh Thuong, Dot 20 mo Kho
		if TD.map.Endless then
			if TD.wave >= 20 and (saveState.StageDiffUnlocked[stKey] or 1) < 3 then saveState.StageDiffUnlocked[stKey] = 3
			elseif TD.wave >= 10 and (saveState.StageDiffUnlocked[stKey] or 1) < 2 then saveState.StageDiffUnlocked[stKey] = 2 end
		end
		matchStars = math.max(2, math.floor(TD.wave * 2 * diffMult + 0.5))
		saveState.Stars += matchStars
		starNote = "Thưởng nỗ lực: +" .. tostring(matchStars) .. " Sao"
	end
	saveData()
	UI.endTitle.Text = won and (TD.map.Endless and "CHIẾN THẮNG!" or ("VƯỢT ẢI " .. tostring(TD.stage or 1) .. "/7!")) or "THẤT THỦ!"
	UI.endTitle.TextColor3 = won and THEME.TextGold or THEME.TextRed
	UI.endStroke.Color = won and THEME.TextGold or THEME.TextRed
	local mvpName, mvpDmg = "Chưa có", 0
	for k, v in pairs(TD.dmgByTower) do if v > mvpDmg then mvpDmg = math.floor(v) mvpName = k end end
	local dfName = getDiffDef(saveState.Difficulty).Name
	local stTag = TD.map.Endless and "" or (" • Ải " .. tostring(TD.stage or 1) .. "/7")
	UI.endDesc.Text = string.format("%s%s (%s) • +%d Sao\n%s • MVP: %s (%s ST)", TD.map.Name, stTag, dfName, matchStars, starNote, mvpName, formatNum(mvpDmg))
	if UI.endChartBox then
		for _, ch in ipairs(UI.endChartBox:GetChildren()) do
			if ch:IsA("Frame") or ch:IsA("TextLabel") then ch:Destroy() end
		end
		local cTitle = Instance.new("TextLabel")
		cTitle.Size = UDim2.new(1, -12, 0, 18)
		cTitle.Position = UDim2.fromOffset(8, 4)
		cTitle.BackgroundTransparency = 1
		cTitle.Text = "BIỂU ĐỒ TỈ LỆ SÁT THƯƠNG (TOP 5)"
		cTitle.TextColor3 = THEME.TextGold
		cTitle.Font = THEME.FontHead
		cTitle.TextSize = 10
		cTitle.TextXAlignment = Enum.TextXAlignment.Left
		cTitle.ZIndex = 47
		cTitle.Parent = UI.endChartBox

		local list, totalDmg = {}, 0
		for k, v in pairs(TD.dmgByTower) do
			if v > 0 then
				table.insert(list, { Name = k, Dmg = math.floor(v) })
				totalDmg += v
			end
		end
		table.sort(list, function(a, b) return a.Dmg > b.Dmg end)
		local barCols = { Color3.fromRGB(224, 174, 52), Color3.fromRGB(82, 198, 224), Color3.fromRGB(168, 92, 226), Color3.fromRGB(92, 198, 102), Color3.fromRGB(218, 92, 86) }
		if #list == 0 then
			local emptyL = Instance.new("TextLabel")
			emptyL.Size = UDim2.new(1, -16, 0, 40)
			emptyL.Position = UDim2.fromOffset(8, 48)
			emptyL.BackgroundTransparency = 1
			emptyL.Text = "Chưa ghi nhận sát thương trong trận này."
			emptyL.TextColor3 = THEME.TextMuted
			emptyL.Font = THEME.FontBody
			emptyL.TextSize = 11
			emptyL.ZIndex = 47
			emptyL.Parent = UI.endChartBox
		else
			for idx = 1, math.min(5, #list) do
				local it = list[idx]
				local pct = math.floor((it.Dmg / math.max(1, totalDmg)) * 100 + 0.5)
				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, -16, 0, 20)
				row.Position = UDim2.fromOffset(8, 24 + (idx - 1) * 21)
				row.BackgroundTransparency = 1
				row.ZIndex = 47
				row.Parent = UI.endChartBox

				local nm = Instance.new("TextLabel")
				nm.Size = UDim2.fromOffset(90, 20)
				nm.BackgroundTransparency = 1
				nm.Text = it.Name
				nm.TextColor3 = THEME.TextMain
				nm.Font = THEME.FontHead
				nm.TextSize = 10
				nm.TextXAlignment = Enum.TextXAlignment.Left
				nm.TextTruncate = Enum.TextTruncate.AtEnd
				nm.ZIndex = 48
				nm.Parent = row

				local bg = Instance.new("Frame")
				bg.Size = UDim2.new(1, -172, 0, 12)
				bg.Position = UDim2.fromOffset(92, 4)
				bg.BackgroundColor3 = Color3.fromRGB(28, 34, 60)
				bg.BorderSizePixel = 0
				bg.ZIndex = 48
				bg.Parent = row
				addCorner(bg, 6)

				local fl = Instance.new("Frame")
				fl.Size = UDim2.fromScale(math.clamp(it.Dmg / math.max(1, totalDmg), 0.04, 1), 1)
				fl.BackgroundColor3 = barCols[idx] or THEME.TextCyan
				fl.BorderSizePixel = 0
				fl.ZIndex = 49
				fl.Parent = bg
				addCorner(fl, 6)

				local vl = Instance.new("TextLabel")
				vl.Size = UDim2.fromOffset(76, 20)
				vl.Position = UDim2.new(1, -76, 0, 0)
				vl.BackgroundTransparency = 1
				vl.Text = formatNum(it.Dmg) .. " (" .. tostring(pct) .. "%)"
				vl.TextColor3 = THEME.TextMuted
				vl.Font = THEME.FontBody
				vl.TextSize = 9
				vl.TextXAlignment = Enum.TextXAlignment.Right
				vl.ZIndex = 48
				vl.Parent = row
			end
		end
	end
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
		BuffDmg = def.BuffDmg or 0, BuffRate = def.BuffRate or 0, BuffRange = (def.Kind == "Buff") and 0.18 or 0, BuffMode = "dmg",
		Cooldown = 0, StunTimer = 0, FreezeTimer = 0, Node = holder, Turret = turret, Barrel = barrel, LvTag = lvTag,
	}
	local stBadge = Instance.new("TextLabel")
	stBadge.Size = UDim2.fromOffset(30, 12)
	stBadge.Position = UDim2.new(0.5, 0, 0, -2)
	stBadge.AnchorPoint = Vector2.new(0.5, 0)
	stBadge.BackgroundColor3 = Color3.fromRGB(132, 42, 186)
	stBadge.BorderSizePixel = 0
	stBadge.Text = "CHOÁNG"
	stBadge.TextColor3 = THEME.TextGold
	stBadge.Font = THEME.FontHead
	stBadge.TextSize = 7
	stBadge.Visible = false
	stBadge.ZIndex = 18
	stBadge.Parent = holder
	addCorner(stBadge, 4)
	tObj.StunBadge = stBadge
	playSfx("place", 1.1)
	TD.shakeTime = math.max(TD.shakeTime or 0, 0.08)

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

local function getStageWaypoints(mp, stageNum)
	local st = math.clamp(tonumber(stageNum) or 1, 1, 7)
	if mp.Endless then
		local roll = math.random(0, #STAGE_PATH_VARIANTS)
		return (roll == 0) and mp.Waypoints or STAGE_PATH_VARIANTS[roll]
	end
	if st == 1 then return mp.Waypoints end
	local mapOff = 0
	for idx, m in ipairs(MAPS) do if m.Id == mp.Id then mapOff = idx - 1 break end end
	local vIdx = ((st - 2 + mapOff) % #STAGE_PATH_VARIANTS) + 1
	return STAGE_PATH_VARIANTS[vIdx]
end

local function buildMapBoard(mp)
	clearMatchLayers()
	TD.pathCells = {}
	TD.pathPoints = {}
	local activeWps = getStageWaypoints(mp, TD.stage or 1)
	for _, wp in ipairs(activeWps) do
		local cx, cy = cellCenter(wp[1], wp[2])
		table.insert(TD.pathPoints, { x = cx, y = cy })
	end
	for w = 1, #activeWps - 1 do
		local a, b = activeWps[w], activeWps[w + 1]
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
				tile.BorderSizePixel = 1
				tile.BorderColor3 = mp.PathBorder
				local bevel = Instance.new("Frame")
				bevel.Size = UDim2.new(1, 0, 0, 3)
				bevel.BackgroundColor3 = Color3.fromRGB(6, 8, 16)
				bevel.BackgroundTransparency = 0.72
				bevel.BorderSizePixel = 0
				bevel.ZIndex = 6
				bevel.Parent = tile
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
							local tStk = saveState.SkillStock[TD.trapMode] or 0
							if tStk > 0 then
								saveState.SkillStock[TD.trapMode] = tStk - 1
								addQuestProg("skill", 1)
								saveData()
								local trNode = GFX.buildTrapSprite(UI.trapLayer, trDef.Id, 8)
								trNode.Position = UDim2.fromOffset(tx, ty)
								table.insert(TD.traps, {
									Def = trDef, X = tx, Y = ty, Uses = trDef.Uses, Cd = 0, Node = trNode
								})
								playSfx("upgrade", 1.2)
								spawnExplosionRing(tx, ty, 18, trDef.Color)
							else
								showToast("Hết " .. trDef.Name .. "! Mua thêm ở Cửa Hàng ngoài Sảnh.", THEME.TextRed, 2.0)
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
						TD.previewTowerIdx = nil
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
	local kinds = mp.BossArena and {"rock", "crystal", "tree", "house"} or (mp.Id == "desert" and {"tree", "cactus", "rock", "house"} or (mp.Id == "endless" and {"crystal", "tree", "rock", "crystal"} or {"tree", "tree", "rock", "house"}))
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
		GFX.buildObstacleSprite(obNode, oKind, 9, mp.Id)
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

	-- Thanh Tri 3D theo tung che do choi
	local cWallCol = (mp.Id == "desert") and Color3.fromRGB(204, 152, 82) or ((mp.Id == "citadel") and Color3.fromRGB(64, 58, 92) or ((mp.Id == "heroic_boss") and Color3.fromRGB(218, 214, 206) or ((mp.Id == "endless") and Color3.fromRGB(58, 44, 98) or Color3.fromRGB(168, 148, 122))))
	local cRoofCol = (mp.Id == "desert") and Color3.fromRGB(224, 126, 42) or ((mp.Id == "citadel") and Color3.fromRGB(178, 38, 62) or ((mp.Id == "heroic_boss") and Color3.fromRGB(236, 188, 48) or ((mp.Id == "endless") and Color3.fromRGB(186, 72, 236) or Color3.fromRGB(48, 142, 218))))
	local cGateCol = (mp.Id == "citadel") and Color3.fromRGB(224, 46, 58) or ((mp.Id == "endless") and Color3.fromRGB(196, 82, 242) or Color3.fromRGB(88, 52, 28))

	local castle = Instance.new("Frame")
	castle.Size = UDim2.fromOffset(38, 38)
	castle.Position = UDim2.fromOffset(pEnd.x, pEnd.y)
	castle.AnchorPoint = Vector2.new(0.5, 0.5)
	castle.BackgroundColor3 = cWallCol
	castle.BorderSizePixel = 0
	castle.ZIndex = 7
	castle.Parent = UI.tileLayer
	addCorner(castle, 8)
	addStroke(castle, THEME.TextGold, 2.2)
	addGradient(castle, lightenCol(cWallCol, 0.16), darkenCol(cWallCol, 0.68), 90)

	-- Thap canh 2 ben + thap giua cao
	for _, spInfo in ipairs({{0.18, 0.12, 10, 14}, {0.82, 0.12, 10, 14}, {0.5, 0.04, 12, 16}}) do
		local spire = Instance.new("Frame")
		spire.Size = UDim2.fromOffset(spInfo[3], spInfo[4])
		spire.Position = UDim2.fromScale(spInfo[1], spInfo[2])
		spire.AnchorPoint = Vector2.new(0.5, 0.5)
		spire.BackgroundColor3 = cRoofCol
		spire.BorderSizePixel = 0
		spire.ZIndex = 8
		spire.Parent = castle
		addCorner(spire, 4)
		addStroke(spire, THEME.Outline, 1.3)
		addGradient(spire, lightenCol(cRoofCol, 0.22), darkenCol(cRoofCol, 0.65), 90)
	end
	local cGate = Instance.new("Frame")
	cGate.Size = UDim2.fromOffset(14, 15)
	cGate.Position = UDim2.fromScale(0.5, 0.74)
	cGate.AnchorPoint = Vector2.new(0.5, 0.5)
	cGate.BackgroundColor3 = cGateCol
	cGate.BorderSizePixel = 0
	cGate.ZIndex = 8
	cGate.Parent = castle
	addCorner(cGate, 6)
	addStroke(cGate, THEME.Outline, 1.3)
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

UI.buildWaveQueueFn = buildWaveQueue

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
	local stKeyInit = TD.map.Id .. "_" .. tostring(TD.stage)
	local maxDiffLv = math.clamp(saveState.StageDiffUnlocked[stKeyInit] or 1, 1, 3)
	local curDiffLv = (saveState.Difficulty == "hard") and 3 or ((saveState.Difficulty == "normal") and 2 or 1)
	if curDiffLv > maxDiffLv then
		saveState.Difficulty = DIFFICULTIES[maxDiffLv].Id
	end
	local diffDef = getDiffDef(saveState.Difficulty)
	local stageMult = 1 + ((TD.stage or 1) - 1) * 0.22
	local w0 = math.max(0, (TD.wave or 1) - 1)
	local scaleHP = (1 + w0 * 0.28 + (w0 * w0) * 0.014) * stageMult * (diffDef.HpMult or 1.0)
	local isElite = (TD.wave >= 6 and not def.Boss and math.random(1, 5) == 1)
	local maxHp = math.max(15, math.floor(def.HP * scaleHP * (isElite and 1.75 or 1.0)))
	local p0 = TD.pathPoints[1]
	local node, body, hpFill, frostCoat, wingL, wingR, bodyStroke = GFX.buildEnemySprite(UI.enemyLayer, def, kind, 15)
	if isElite and bodyStroke then bodyStroke.Color = Color3.fromRGB(224, 92, 224) bodyStroke.Thickness = 2.4 end
	node.Position = UDim2.fromOffset(p0.x, p0.y)
	local eObj = {
		Kind = kind, Def = def, Elite = isElite, HP = maxHp, MaxHP = maxHp,
		X = p0.x, Y = p0.y, WpIdx = 2, Progress = 0,
		SlowTimer = 0, SlowFactor = 1, PoisonTimer = 0, PoisonDps = 0, SprintTimer = 0, HitFlash = 0, BobPhase = math.random() * 6, SkillCd = 6.2,
		Node = node, Body = body, HpFill = hpFill, FrostCoat = frostCoat,
		WingL = wingL, WingR = wingR, Dead = false
	}
	table.insert(TD.enemies, eObj)
	if def.Boss then
		showBossWarning(def.Name)
		playSfx("boss", 0.78)
		TD.shakeTime = math.max(TD.shakeTime or 0, 0.45)
	end
	return eObj
end

local function damageEnemy(e, dmg, slowFrac, slowDur, poisonDps, poisonDur, srcName)
	if e.Dead then return end
	local isCrit = false
	if srcName and dmg >= 8 and math.random(1, 100) <= 14 then
		isCrit = true
		dmg = math.floor(dmg * 1.65)
	end
	local actual = math.min(e.HP, dmg)
	if srcName and actual > 0 then
		TD.dmgByTower[srcName] = (TD.dmgByTower[srcName] or 0) + actual
		spawnDmgNumber(e.X, e.Y, math.max(1, math.floor(actual + 0.5)), isCrit)
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

getTowerBuffMults = function(t)
	local dmgBonus, rateBonus, rangeBonus = 0, 0, 0
	for _, other in ipairs(TD.towers) do
		if other.Def.Kind == "Buff" and other ~= t then
			local d = math.sqrt((other.X - t.X)^2 + (other.Y - t.Y)^2)
			if d <= other.Range then
				if other.BuffMode == "range" then
					rangeBonus = math.max(rangeBonus, other.BuffRange or 0.24)
					rateBonus = math.max(rateBonus, (other.BuffRate or 0.18) * 0.65)
				else
					dmgBonus = math.max(dmgBonus, other.BuffDmg or 0.28)
					rateBonus = math.max(rateBonus, other.BuffRate or 0.20)
				end
			end
		end
	end
	return 1 + dmgBonus, math.max(0.45, 1 - rateBonus), 1 + rangeBonus
end

local function fireTower(t, target, effDmg)
	local dmg = effDmg or t.Damage
	if not saveState.LowFx then
		for _, ob in ipairs(TD.towers) do
			if ob.Def.Kind == "Buff" and math.sqrt((ob.X - t.X)^2 + (ob.Y - t.Y)^2) <= ob.Range then
				spawnBeamLine(ob.X, ob.Y, t.X, t.Y, (ob.BuffMode == "range") and THEME.TextCyan or THEME.TextGold, 1.5, 0.10)
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
	local maxU = math.clamp(saveState.StageUnlocked[TD.map.Id] or 1, 1, 7)
	TD.stage = TD.map.Endless and 1 or math.clamp(saveState.SelectedStage or 1, 1, maxU)
	local diffDef = getDiffDef(saveState.Difficulty)
	TD.gold = TD.map.StartGold + (TD.stage - 1) * 35 + (saveState.Upgrades.gold or 0) * 40
	TD.lives = (diffDef.Id == "hell") and 1 or (diffDef.Lives + (saveState.Upgrades.lives or 0) * 2)
	TD.maxLives = TD.lives
	TD.leaks = 0
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
	if UI.bossWarn then UI.bossWarn.Visible = false end
	TD.weatherTimer = 0.7
	TD.smokeTimer = 0.7
	TD.fxCount = 0
	TD.previewCacheKey = nil
	TD.lastDmgUi = 0
	UI.hudGroup.Visible = true
	UI.homeBtn.Visible = false
	UI.pauseBtn.Visible = true
	lobbyPage.Visible = false
	gamePage.Visible = true
	buildMapBoard(TD.map)
	TD.blizCd = 0
	TD.voidCd = 0
	TD.rageCd = 0
	TD.rageTimer = 0
	TD.voidHole = nil
	TD.dmgByTower = {}
	TD.trapMode = "none"
	UI.trapLbl.Text = "BẪY: TẮT"
	updateHUD()
end

local function goLobby()
	TD.active = false
	TD.paused = false
	TD.over = false
	if UI.pauseOverlay then UI.pauseOverlay.Visible = false end
	UI.hudGroup.Visible = false
	UI.homeBtn.Visible = false
	UI.pauseBtn.Visible = false
	gamePage.Visible = false
	lobbyPage.Visible = true
	refreshLobbyStats()
	clearMatchLayers(true)
end

-- ============================================================
-- KET NOI NUT BAM & VONG LAP CHINH (RENDERSTEPPED)
-- ============================================================
for i, pb in ipairs(popupBuildBtns) do
	pb.Btn.MouseEnter:Connect(function()
		if TD.pendingCell then
			local cx, cy = cellCenter(TD.pendingCell.gx, TD.pendingCell.gy)
			UI.rangeRing.Visible = true
			UI.rangeRing.Position = UDim2.fromOffset(cx, cy)
			UI.rangeRing.Size = UDim2.fromOffset(pb.Def.Range * 2, pb.Def.Range * 2)
		end
	end)
	pb.Btn.MouseButton1Click:Connect(function()
		if not TD.pendingCell then return end
		if TD.previewTowerIdx == i then
			buildTowerAt(TD.pendingCell.gx, TD.pendingCell.gy, i)
		else
			TD.previewTowerIdx = i
			updateHUD()
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
	local wasLv3Evo = (t.Level == 3 and not t.Branch and branchName ~= nil)
	t.Level += 1
	if wasLv3Evo and branchName == "Hủy Diệt" then
		t.Branch = "Hủy Diệt"
		t.Damage = t.Damage * 1.50
		t.Range = t.Range * 1.08
		if t.Def.Kind == "Buff" then
			t.BuffDmg = math.min(0.65, (t.BuffDmg or 0.20) + 0.10)
			t.BuffRange = math.min(0.60, (t.BuffRange or 0.18) + 0.10)
		end
		t.LvTag.Text = "C4A"
	elseif wasLv3Evo and branchName == "Siêu Tốc" then
		t.Branch = "Siêu Tốc"
		t.Damage = t.Damage * 1.18
		t.Range = t.Range * 1.16
		t.FireRate = math.max(0.22, t.FireRate * 0.74)
		if t.Def.Kind == "Buff" then
			t.BuffRate = math.min(0.42, (t.BuffRate or 0.14) + 0.08)
			t.BuffRange = math.min(0.60, (t.BuffRange or 0.18) + 0.08)
		end
		t.LvTag.Text = "C4B"
	elseif t.Level > 3 then
		t.Damage = t.Damage * 1.18
		t.Range = math.min(230, t.Range + 3)
		if t.Def.Kind == "Buff" then
			t.BuffDmg = math.min(0.65, (t.BuffDmg or 0.20) + 0.04)
			t.BuffRange = math.min(0.60, (t.BuffRange or 0.18) + 0.04)
		end
		t.LvTag.Text = "C" .. tostring(t.Level)
	else
		t.Damage = t.Damage * 1.35
		t.Range = t.Range * 1.08
		t.FireRate = math.max(0.28, t.FireRate * 0.92)
		if t.Def.Kind == "Buff" then
			t.BuffDmg = (t.BuffDmg or 0.20) + 0.06
			t.BuffRange = (t.BuffRange or 0.18) + 0.06
			t.BuffRate = (t.BuffRate or 0.14) + 0.04
		end
		t.LvTag.Text = "C" .. tostring(t.Level)
	end
	if t.Level >= 3 then addQuestProg("tier3", 1) end
	if t.BuffAura then t.BuffAura.Size = UDim2.fromOffset(t.Range * 2, t.Range * 2) end
	updateTowerVisual(t)
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
	if t.Def.Kind == "Buff" then
		t.BuffMode = (t.BuffMode == "range") and "dmg" or "range"
		if t.BuffAura then
			t.BuffAura.BackgroundColor3 = (t.BuffMode == "range") and Color3.fromRGB(64, 198, 232) or Color3.fromRGB(232, 196, 64)
		end
		showToast(t.BuffMode == "range" and "Tháp Buff chuyển sang: BUFF TẦM ĐÁNH!" or "Tháp Buff chuyển sang: BUFF SỨC MẠNH!", t.BuffMode == "range" and THEME.TextCyan or THEME.TextGold, 1.8)
		updateHUD()
		return
	end
	local order = { First = "Strong", Strong = "Weak", Weak = "First" }
	t.TargetMode = order[t.TargetMode or "First"] or "First"
	updateHUD()
end)

UI.autoBtn.MouseButton1Click:Connect(function()
	TD.autoWave = not TD.autoWave
	UI.autoLbl.Text = TD.autoWave and "TỰ GỌI: BẬT" or "TỰ GỌI: TẮT"
	showToast(TD.autoWave and "Đã bật tự động gọi đợt kế tiếp!" or "Đã tắt tự động gọi đợt.", THEME.TextCyan, 1.8)
end)


local function openPermUpgrades()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "CÂY KỸ NĂNG  •  " .. formatNum(saveState.Stars) .. " Sao"
	local tabRow = Instance.new("Frame")
	tabRow.Size = UDim2.new(1, 0, 0, 32)
	tabRow.BackgroundTransparency = 1
	tabRow.ZIndex = 53
	tabRow.Parent = UI.pmList
	local function openStarShop()
		for _, ch in ipairs(UI.pmList:GetChildren()) do if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end end
		UI.pmTitle.Text = "CỬA HÀNG  •  " .. formatNum(saveState.Stars) .. " Sao"

		local sc = Instance.new("ScrollingFrame")
		sc.Size = UDim2.new(1, 0, 0, 260)
		sc.BackgroundTransparency = 1
		sc.BorderSizePixel = 0
		sc.ScrollBarThickness = 5
		sc.ScrollBarImageColor3 = THEME.TextGold
		sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
		sc.CanvasSize = UDim2.new(0, 0, 0, 0)
		sc.ZIndex = 53
		sc.Parent = UI.pmList
		local lay = Instance.new("UIListLayout")
		lay.Padding = UDim.new(0, 6)
		lay.Parent = sc

		for _, it in ipairs(SHOP_SKILLS) do
			local qty = (it.Kind == "bag") and (saveState.Bag[it.Id] or 0) or (saveState.SkillStock[it.Id] or 0)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -8, 0, 52)
			row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
			row.BorderSizePixel = 0
			row.ZIndex = 53
			row.Parent = sc
			addCorner(row, 9)
			addStroke(row, it.Color, 1.6)

			local u = getMapImageAsset(it.Img)
			if u then
				local ic = Instance.new("ImageLabel")
				ic.Size = UDim2.fromOffset(36, 36)
				ic.Position = UDim2.fromOffset(8, 8)
				ic.BackgroundTransparency = 1
				ic.Image = u
				ic.ScaleType = Enum.ScaleType.Fit
				ic.ZIndex = 54
				ic.Parent = row
			end

			local nm = Instance.new("TextLabel")
			nm.Size = UDim2.fromOffset(250, 20)
			nm.Position = UDim2.fromOffset(52, 5)
			nm.BackgroundTransparency = 1
			nm.Text = it.Name .. "  •  Đang có: x" .. tostring(qty)
			nm.TextColor3 = THEME.TextGold
			nm.Font = THEME.FontHead
			nm.TextSize = 11
			nm.TextXAlignment = Enum.TextXAlignment.Left
			nm.ZIndex = 54
			nm.Parent = row

			local ds = Instance.new("TextLabel")
			ds.Size = UDim2.fromOffset(250, 20)
			ds.Position = UDim2.fromOffset(52, 26)
			ds.BackgroundTransparency = 1
			ds.Text = it.Desc
			ds.TextColor3 = THEME.TextMuted
			ds.Font = THEME.FontBody
			ds.TextSize = 10
			ds.TextXAlignment = Enum.TextXAlignment.Left
			ds.ZIndex = 54
			ds.Parent = row

			local buyB = makeArcadeBtn(row, "MUA (" .. tostring(it.Cost) .. " Sao)", UDim2.fromOffset(118, 34), UDim2.new(1, -126, 0, 9),
				Color3.fromRGB(64, 194, 92), Color3.fromRGB(28, 134, 58), 8, { TextSize = 10, ZIndex = 54, Depth = 3 })
			buyB.MouseButton1Click:Connect(function()
				if saveState.Stars < it.Cost then
					showToast("Cần " .. tostring(it.Cost) .. " Sao để mua " .. it.Name .. "!", THEME.TextRed, 1.8)
					return
				end
				saveState.Stars -= it.Cost
				if it.Kind == "bag" then
					saveState.Bag[it.Id] = (saveState.Bag[it.Id] or 0) + 1
				else
					saveState.SkillStock[it.Id] = (saveState.SkillStock[it.Id] or 0) + 1
				end
				saveData()
				playSfx("upgrade", 1.1)
				refreshLobbyStats()
				local newQty = (it.Kind == "bag") and (saveState.Bag[it.Id] or 0) or (saveState.SkillStock[it.Id] or 0)
				nm.Text = it.Name .. "  •  Đang có: x" .. tostring(newQty)
				UI.pmTitle.Text = "CỬA HÀNG  •  " .. formatNum(saveState.Stars) .. " Sao"
			end)
		end
		UI.pmOverlay.Visible = true
	end
	UI.openStarShop = openStarShop
	local tSkinBtn = makeArcadeBtn(tabRow, "MỞ CỬA HÀNG HIỆU ỨNG SAO", UDim2.fromOffset(290, 28), UDim2.new(0.5, -145, 0, 2), Color3.fromRGB(186, 68, 214), Color3.fromRGB(118, 32, 168), 8, { TextSize = 11, ZIndex = 54, Depth = 3 })
	tSkinBtn.MouseButton1Click:Connect(function()
		for _, ch in ipairs(UI.pmList:GetChildren()) do if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end end
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
		addStroke(row, Color3.fromRGB(92, 106, 168), 1.8)
		addGradient(row, Color3.fromRGB(38, 44, 82), Color3.fromRGB(20, 24, 46), 90)

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

UI.shopBtn.MouseButton1Click:Connect(function()
	if not UI.openStarShop then openPermUpgrades() end
	if UI.openStarShop then UI.openStarShop() end
end)
UI.pmClose.MouseButton1Click:Connect(function() UI.pmOverlay.Visible = false end)

-- Modal Nhiem Vu Kiem Sao (dung chung pmOverlay gon gang)
local function openStarQuests()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "NHIỆM VỤ KIẾM SAO  •  " .. formatNum(saveState.Stars) .. " Sao"
	local qScroll = Instance.new("ScrollingFrame")
	qScroll.Size = UDim2.new(1, 0, 0, 260)
	qScroll.BackgroundTransparency = 1
	qScroll.BorderSizePixel = 0
	qScroll.ScrollBarThickness = 5
	qScroll.ScrollBarImageColor3 = THEME.TextGold
	qScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	qScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	qScroll.ZIndex = 53
	qScroll.Parent = UI.pmList
	local qLay = Instance.new("UIListLayout")
	qLay.Padding = UDim.new(0, 6)
	qLay.Parent = qScroll
	local allDone = true
	for _, q in ipairs(saveState.Quests) do
		if not q.Claimed then allDone = false end
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
		row.BorderSizePixel = 0
		row.ZIndex = 53
		row.Parent = qScroll
		addCorner(row, 9)
		local rowStroke = addStroke(row, (q.Progress >= q.Goal and not q.Claimed) and THEME.TextGreen or Color3.fromRGB(74, 82, 128), 1.5)

		local tLbl = Instance.new("TextLabel")
		tLbl.Size = UDim2.fromOffset(306, 20)
		tLbl.Position = UDim2.fromOffset(10, 4)
		tLbl.BackgroundTransparency = 1
		tLbl.Text = q.Title .. "  (" .. math.min(q.Progress, q.Goal) .. "/" .. q.Goal .. ")"
		tLbl.TextColor3 = THEME.TextMain
		tLbl.Font = THEME.FontHead
		tLbl.TextSize = 11
		tLbl.TextXAlignment = Enum.TextXAlignment.Left
		tLbl.ZIndex = 54
		tLbl.Parent = row

		local qBarBg = Instance.new("Frame")
		qBarBg.Size = UDim2.fromOffset(296, 8)
		qBarBg.Position = UDim2.fromOffset(10, 28)
		qBarBg.BackgroundColor3 = Color3.fromRGB(16, 18, 36)
		qBarBg.BorderSizePixel = 0
		qBarBg.ZIndex = 54
		qBarBg.Parent = row
		addCorner(qBarBg, 4)
		local qBarFl = Instance.new("Frame")
		qBarFl.Size = UDim2.fromScale(math.clamp(q.Progress / math.max(1, q.Goal), 0, 1), 1)
		qBarFl.BackgroundColor3 = (q.Progress >= q.Goal) and THEME.TextGreen or THEME.TextGold
		qBarFl.BorderSizePixel = 0
		qBarFl.ZIndex = 55
		qBarFl.Parent = qBarBg
		addCorner(qBarFl, 4)

		local canClaim = (q.Progress >= q.Goal) and not q.Claimed
		local btn, btnLbl = makeArcadeBtn(
			row, q.Claimed and "ĐÃ NHẬN" or ("+" .. q.Reward .. " Sao"),
			UDim2.fromOffset(106, 30), UDim2.new(1, -114, 0, 7),
			canClaim and Color3.fromRGB(64, 194, 92) or Color3.fromRGB(72, 82, 112),
			canClaim and Color3.fromRGB(28, 134, 58) or Color3.fromRGB(48, 54, 78),
			8, { TextSize = 11, ZIndex = 54, Depth = 3 }
		)
		btn.MouseButton1Click:Connect(function()
			if q.Claimed or q.Progress < q.Goal then return end
			q.Claimed = true
			saveState.Stars += q.Reward
			saveData()
			playSfx("upgrade", 1.1)
			refreshLobbyStats()
			UI.pmTitle.Text = "NHIỆM VỤ KIẾM SAO  •  " .. formatNum(saveState.Stars) .. " Sao"
			btnLbl.Text = "ĐÃ NHẬN"
			btn.BackgroundColor3 = Color3.fromRGB(72, 82, 112)
			rowStroke.Color = Color3.fromRGB(74, 82, 128)
			for _, gc in ipairs(btn:GetDescendants()) do
				if gc:IsA("UIGradient") then
					gc.Color = ColorSequence.new(Color3.fromRGB(72, 82, 112), Color3.fromRGB(48, 54, 78))
				elseif gc:IsA("Frame") and gc.Name == "Face" then
					gc.BackgroundColor3 = Color3.fromRGB(72, 82, 112)
				end
			end
			local nowAll = true
			for _, oq in ipairs(saveState.Quests) do if not oq.Claimed then nowAll = false break end end
			if nowAll and not qScroll:FindFirstChild("ResetQuestRow") then
				local rRow = Instance.new("Frame")
				rRow.Name = "ResetQuestRow"
				rRow.Size = UDim2.new(1, 0, 0, 38)
				rRow.BackgroundTransparency = 1
				rRow.ZIndex = 53
				rRow.Parent = qScroll
				local rb = makeArcadeBtn(rRow, "LÀM MỚI NHIỆM VỤ", UDim2.fromOffset(200, 32), UDim2.new(0.5, -100, 0, 3), Color3.fromRGB(154, 72, 218), Color3.fromRGB(94, 34, 168), 9, { TextSize = 11, ZIndex = 54, Depth = 3 })
				rb.MouseButton1Click:Connect(function()
					saveState.Quests = createDefaultQuests()
					saveData()
					refreshLobbyStats()
					openStarQuests()
				end)
			end
		end)
	end
	if allDone then
		local rRow = Instance.new("Frame")
		rRow.Size = UDim2.new(1, 0, 0, 38)
		rRow.BackgroundTransparency = 1
		rRow.ZIndex = 53
		rRow.Parent = qScroll
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

-- Bang chon Man Choi & Cap Do 3D: bo chu tru sao, dung nut Khoa/Xich 3D va them nut BAT DAU
UI.openDiffModal = function(mp)
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = mp.Name .. (mp.Endless and "  •  CHỌN CẤP ĐỘ" or "  •  CHỌN MÀN CHƠI")

	local maxUnlocked = math.clamp(saveState.StageUnlocked[mp.Id] or 1, 1, 7)
	if (saveState.SelectedStage or 1) > maxUnlocked then saveState.SelectedStage = maxUnlocked end
	local curStage = mp.Endless and 1 or math.clamp(saveState.SelectedStage or 1, 1, maxUnlocked)
	local stKey = mp.Id .. "_" .. tostring(curStage)
	local unlockedDiffLv = math.clamp(saveState.StageDiffUnlocked[stKey] or 1, 1, 3)

	-- Dam bao cap do dang chon nam trong pham vi da mo khoa cua Ai nay
	local curDiffLv = (saveState.Difficulty == "hard") and 3 or ((saveState.Difficulty == "normal") and 2 or 1)
	if curDiffLv > unlockedDiffLv then
		curDiffLv = unlockedDiffLv
		saveState.Difficulty = DIFFICULTIES[curDiffLv].Id
	end

	-- 1. Thanh gioi thieu ban do gon dep (chi giu Tong Sao Ai)
	local banner = Instance.new("Frame")
	banner.Size = UDim2.new(1, 0, 0, 48)
	banner.BackgroundColor3 = Color3.fromRGB(26, 30, 62)
	banner.BorderSizePixel = 0
	banner.ZIndex = 53
	banner.Parent = UI.pmList
	addCorner(banner, 10)
	addStroke(banner, THEME.TextGold, 1.8)
	addGradient(banner, Color3.fromRGB(44, 48, 96), Color3.fromRGB(20, 22, 46), 90)

	local thumbUrl = getMapImageAsset(mp.Id)
	if thumbUrl then
		local th = Instance.new("ImageLabel")
		th.Size = UDim2.fromOffset(40, 38)
		th.Position = UDim2.fromOffset(6, 5)
		th.BackgroundTransparency = 1
		th.Image = thumbUrl
		th.ScaleType = Enum.ScaleType.Fit
		th.ZIndex = 54
		th.Parent = banner
	end

	local totalSt = 0
	for s = 1, 7 do totalSt += (saveState.StageStars[mp.Id .. "_" .. tostring(s)] or 0) end
	local bName = Instance.new("TextLabel")
	bName.Size = UDim2.new(1, -60, 0, 20)
	bName.Position = UDim2.fromOffset(52, 5)
	bName.BackgroundTransparency = 1
	bName.Text = mp.Endless and (mp.Name .. "  •  Kỷ lục Đợt " .. tostring(saveState.BestWave[mp.Id] or 0)) or (mp.Name .. "  •  Ải đang chọn: " .. tostring(curStage) .. "/7")
	bName.TextColor3 = THEME.TextGold
	bName.Font = THEME.FontHead
	bName.TextSize = 12
	bName.TextXAlignment = Enum.TextXAlignment.Left
	bName.ZIndex = 54
	bName.Parent = banner

	local bSub = Instance.new("TextLabel")
	bSub.Size = UDim2.new(1, -60, 0, 18)
	bSub.Position = UDim2.fromOffset(52, 25)
	bSub.BackgroundTransparency = 1
	bSub.Text = mp.Endless and "Vượt Đợt 10 mở Bình Thường • Đợt 20 mở Khó" or string.format("Tổng Sao Ải: %d/21", totalSt)
	bSub.TextColor3 = THEME.TextCyan
	bSub.Font = THEME.FontHead
	bSub.TextSize = 11
	bSub.TextXAlignment = Enum.TextXAlignment.Left
	bSub.ZIndex = 54
	bSub.Parent = banner

	-- 2. Khung chon 7 Ai co 3 Sao tung ai + icon O Khoa 3D
	if not mp.Endless then
		local stCard = Instance.new("Frame")
		stCard.Size = UDim2.new(1, 0, 0, 86)
		stCard.BackgroundColor3 = Color3.fromRGB(22, 26, 52)
		stCard.BorderSizePixel = 0
		stCard.ZIndex = 53
		stCard.Parent = UI.pmList
		addCorner(stCard, 11)
		addStroke(stCard, Color3.fromRGB(78, 88, 142), 1.6)

		local stTitle = Instance.new("TextLabel")
		stTitle.Size = UDim2.new(1, -20, 0, 18)
		stTitle.Position = UDim2.fromOffset(10, 4)
		stTitle.BackgroundTransparency = 1
		stTitle.Text = "CHỌN ẢI (7 MÀN • SAO RIÊNG TỪNG ẢI)"
		stTitle.TextColor3 = THEME.TextCyan
		stTitle.Font = THEME.FontHead
		stTitle.TextSize = 10
		stTitle.TextXAlignment = Enum.TextXAlignment.Left
		stTitle.ZIndex = 54
		stTitle.Parent = stCard

		local stGrid = Instance.new("Frame")
		stGrid.Size = UDim2.new(1, -14, 0, 60)
		stGrid.Position = UDim2.fromOffset(7, 23)
		stGrid.BackgroundTransparency = 1
		stGrid.ZIndex = 54
		stGrid.Parent = stCard

		local lockUrl = getMapImageAsset("tile_lock")
		for sIdx = 1, 7 do
			local unlocked = (sIdx <= maxUnlocked)
			local picked = (curStage == sIdx)
			local earned = saveState.StageStars[mp.Id .. "_" .. tostring(sIdx)] or 0
			local sBtn
			if (not unlocked) and lockUrl then
				sBtn = Instance.new("ImageButton")
				sBtn.Size = UDim2.fromOffset(58, 40)
				sBtn.Position = UDim2.fromOffset((sIdx - 1) * 63 + 2, 1)
				sBtn.BackgroundTransparency = 1
				sBtn.Image = lockUrl
				sBtn.ScaleType = Enum.ScaleType.Stretch
				sBtn.AutoButtonColor = false
				sBtn.ZIndex = 55
				sBtn.Parent = stGrid
				addCorner(sBtn, 8)
			else
				local c1 = picked and Color3.fromRGB(228, 176, 44) or (unlocked and Color3.fromRGB(58, 132, 208) or Color3.fromRGB(46, 50, 74))
				local c2 = picked and Color3.fromRGB(164, 102, 16) or (unlocked and Color3.fromRGB(32, 74, 148) or Color3.fromRGB(28, 32, 52))
				sBtn = makeArcadeBtn(
					stGrid, unlocked and ("Ải " .. tostring(sIdx)) or "Khóa",
					UDim2.fromOffset(58, 40), UDim2.fromOffset((sIdx - 1) * 63 + 2, 1),
					c1, c2, 8, { TextSize = 11, ZIndex = 55, Depth = 3, Stroke = picked and 2.4 or 1.6 }
				)
			end
			for si = 1, 3 do
				local stDot = Instance.new("Frame")
				stDot.Size = UDim2.fromOffset(9, 9)
				stDot.Position = UDim2.fromOffset((sIdx - 1) * 63 + 12 + (si - 1) * 14, 46)
				stDot.Rotation = 45
				stDot.BackgroundColor3 = (si <= earned) and THEME.TextGold or Color3.fromRGB(54, 60, 88)
				stDot.BorderSizePixel = 0
				stDot.ZIndex = 55
				stDot.Parent = stGrid
				addCorner(stDot, 2)
				addStroke(stDot, THEME.Outline, 1.1)
			end
			sBtn.MouseButton1Click:Connect(function()
				if not unlocked then
					showToast("Thắng Ải " .. tostring(sIdx - 1) .. " để mở khóa Ải " .. tostring(sIdx) .. "!", THEME.TextRed, 1.9)
					return
				end
				saveState.SelectedStage = sIdx
				UI.openDiffModal(mp)
			end)
		end
	end

	-- 3. Khung chon Cap Do (De -> Binh Thuong -> Kho) voi day xich 3D khi khoa
	local dWrap = Instance.new("Frame")
	dWrap.Size = UDim2.new(1, 0, 0, 72)
	dWrap.BackgroundColor3 = Color3.fromRGB(22, 26, 52)
	dWrap.BorderSizePixel = 0
	dWrap.ZIndex = 53
	dWrap.Parent = UI.pmList
	addCorner(dWrap, 11)
	addStroke(dWrap, Color3.fromRGB(78, 88, 142), 1.6)

	local dTitle = Instance.new("TextLabel")
	dTitle.Size = UDim2.new(1, -20, 0, 18)
	dTitle.Position = UDim2.fromOffset(10, 4)
	dTitle.BackgroundTransparency = 1
	dTitle.Text = "CHỌN CẤP ĐỘ (THẮNG ĐỂ MỞ CẤP TIẾP THEO)"
	dTitle.TextColor3 = THEME.TextGold
	dTitle.Font = THEME.FontHead
	dTitle.TextSize = 10
	dTitle.TextXAlignment = Enum.TextXAlignment.Left
	dTitle.ZIndex = 54
	dTitle.Parent = dWrap

	for dIdx, df in ipairs(DIFFICULTIES) do
		local isOpen = (dIdx <= unlockedDiffLv)
		local isPicked = (saveState.Difficulty == df.Id)
		local lockImgKey = (dIdx == 2) and "diff_norm_lock" or ((dIdx == 3) and "diff_hard_lock" or nil)
		local lockImgUrl = (not isOpen) and lockImgKey and getMapImageAsset(lockImgKey) or nil
		local dBtn
		if lockImgUrl then
			dBtn = Instance.new("ImageButton")
			dBtn.Size = UDim2.fromOffset(138, 40)
			dBtn.Position = UDim2.fromOffset(12 + (dIdx - 1) * 146, 25)
			dBtn.BackgroundTransparency = 1
			dBtn.Image = lockImgUrl
			dBtn.ScaleType = Enum.ScaleType.Stretch
			dBtn.AutoButtonColor = false
			dBtn.ZIndex = 55
			dBtn.Parent = dWrap
			addCorner(dBtn, 9)
		else
			local cTop = isOpen and df.Top or Color3.fromRGB(62, 68, 92)
			local cBot = isOpen and df.Bot or Color3.fromRGB(36, 40, 58)
			local btnTxt = isOpen and df.Name or (df.Name .. " (Khóa)")
			dBtn = makeArcadeBtn(
				dWrap, btnTxt,
				UDim2.fromOffset(138, 40), UDim2.fromOffset(12 + (dIdx - 1) * 146, 25),
				cTop, cBot, 10, { TextSize = isOpen and 12 or 10, ZIndex = 55, Depth = 3, Stroke = isPicked and 2.6 or 1.6 }
			)
			if isPicked then addStroke(dBtn, THEME.TextGold, 2.4) end
		end
		dBtn.MouseButton1Click:Connect(function()
			if not isOpen then
				local prevName = DIFFICULTIES[dIdx - 1] and DIFFICULTIES[dIdx - 1].Name or "Dễ"
				showToast("Hãy thắng cấp " .. prevName .. " trước để mở " .. df.Name .. "!", THEME.TextRed, 2.2)
				return
			end
			saveState.Difficulty = df.Id
			saveData()
			UI.openDiffModal(mp)
		end)
	end

	-- 4. Nut BAT DAU 3D o day bang chon man choi
	local startRow = Instance.new("Frame")
	startRow.Size = UDim2.new(1, 0, 0, 42)
	startRow.BackgroundTransparency = 1
	startRow.ZIndex = 53
	startRow.Parent = UI.pmList

	local stUrl = getMapImageAsset("btn_start")
	local startBtn
	if stUrl then
		startBtn = Instance.new("ImageButton")
		startBtn.Size = UDim2.fromOffset(172, 42)
		startBtn.Position = UDim2.new(0.5, -86, 0, 0)
		startBtn.BackgroundTransparency = 1
		startBtn.Image = stUrl
		startBtn.ScaleType = Enum.ScaleType.Fit
		startBtn.AutoButtonColor = false
		startBtn.ZIndex = 55
		startBtn.Parent = startRow
	else
		startBtn = makeArcadeBtn(
			startRow, "BẮT ĐẦU",
			UDim2.fromOffset(172, 40), UDim2.new(0.5, -86, 0, 1),
			Color3.fromRGB(48, 218, 92), Color3.fromRGB(16, 148, 52), 12,
			{ TextSize = 14, ZIndex = 55, Depth = 4, Stroke = 2.2 }
		)
	end
	startBtn.MouseButton1Click:Connect(function()
		UI.pmOverlay.Visible = false
		startNewMatch()
	end)

	UI.pmOverlay.Visible = true
end

-- Bang Cai Dat o sanh chinh (Cong tac gat Toggle Switch + Thanh truot Am Luong)
local function openLobbySettings()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "CÀI ĐẶT & NHẬP CODE"
	local setScroll = Instance.new("ScrollingFrame")
	setScroll.Size = UDim2.new(1, 0, 0, 260)
	setScroll.BackgroundTransparency = 1
	setScroll.BorderSizePixel = 0
	setScroll.ScrollBarThickness = 5
	setScroll.ScrollBarImageColor3 = THEME.TextGold
	setScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	setScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	setScroll.ZIndex = 53
	setScroll.Parent = UI.pmList
	local setLay = Instance.new("UIListLayout")
	setLay.Padding = UDim.new(0, 6)
	setLay.SortOrder = Enum.SortOrder.LayoutOrder
	setLay.Parent = setScroll
	local function addToggleOpt(titleTxt, descTxt, isOn, onClick)
		local row = Instance.new("Frame")
		row.LayoutOrder = 2
		row.Size = UDim2.new(1, 0, 0, 50)
		row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
		row.BorderSizePixel = 0
		row.ZIndex = 53
		row.Parent = setScroll
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
		t2.Position = UDim2.fromOffset(12, 24)
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
		sw.Position = UDim2.new(1, -74, 0, 10)
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

	addToggleOpt("Tối ưu FPS (Giảm hiệu ứng)", "Tắt chữ dame, hạt nổ nhỏ, thời tiết để mượt hơn", saveState.LowFx, function()
		saveState.LowFx = not saveState.LowFx
		saveData()
		openLobbySettings()
	end)
	addToggleOpt("Ẩn 3D nền khi chơi (Siêu mượt)", "Tạm tắt vẽ game 3D phía sau; thu nhỏ sẽ tự bật lại", saveState.Hide3D, function()
		saveState.Hide3D = not saveState.Hide3D
		saveData()
		if UI.apply3dState then UI.apply3dState() end
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
	volRow.LayoutOrder = 3
	volRow.Size = UDim2.new(1, 0, 0, 52)
	volRow.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
	volRow.BorderSizePixel = 0
	volRow.ZIndex = 53
	volRow.Parent = setScroll
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

	-- Nhap Code nhan Sao + Ky Nang + Tui Vang (kem nut ? goi y code)
	local codeRow = Instance.new("Frame")
	codeRow.LayoutOrder = 1
	codeRow.Size = UDim2.new(1, -6, 0, 56)
	codeRow.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
	codeRow.BorderSizePixel = 0
	codeRow.ZIndex = 53
	codeRow.Parent = setScroll
	addCorner(codeRow, 10)
	addStroke(codeRow, THEME.TextGold, 1.8)
	addGradient(codeRow, Color3.fromRGB(44, 38, 86), Color3.fromRGB(20, 22, 46), 90)

	local cTitle = Instance.new("TextLabel")
	cTitle.Size = UDim2.fromOffset(118, 46)
	cTitle.Position = UDim2.fromOffset(10, 5)
	cTitle.BackgroundTransparency = 1
	cTitle.Text = "NHẬP CODE QUÀ"
	cTitle.TextColor3 = THEME.TextGold
	cTitle.Font = THEME.FontHead
	cTitle.TextSize = 11
	cTitle.TextXAlignment = Enum.TextXAlignment.Left
	cTitle.ZIndex = 54
	cTitle.Parent = codeRow

	local cBox = Instance.new("Frame")
	cBox.Size = UDim2.new(1, -234, 0, 34)
	cBox.Position = UDim2.fromOffset(128, 11)
	cBox.BackgroundColor3 = Color3.fromRGB(14, 16, 32)
	cBox.BorderSizePixel = 0
	cBox.ZIndex = 54
	cBox.Parent = codeRow
	addCorner(cBox, 8)
	addStroke(cBox, Color3.fromRGB(82, 92, 148), 1.4)

	local cInput = Instance.new("TextBox")
	cInput.Size = UDim2.new(1, -38, 1, 0)
	cInput.Position = UDim2.fromOffset(8, 0)
	cInput.BackgroundTransparency = 1
	cInput.BorderSizePixel = 0
	cInput.Text = ""
	cInput.PlaceholderText = "Nhập code tại đây..."
	cInput.PlaceholderColor3 = Color3.fromRGB(118, 126, 158)
	cInput.TextColor3 = THEME.TextMain
	cInput.Font = THEME.FontHead
	cInput.TextSize = 11
	cInput.TextXAlignment = Enum.TextXAlignment.Left
	cInput.ClearTextOnFocus = false
	cInput.ZIndex = 55
	cInput.Parent = cBox

	local qmUrl = getMapImageAsset("btn_qmark")
	local hintBtn
	if qmUrl then
		hintBtn = Instance.new("ImageButton")
		hintBtn.Size = UDim2.fromOffset(26, 26)
		hintBtn.Position = UDim2.new(1, -30, 0.5, -13)
		hintBtn.BackgroundTransparency = 1
		hintBtn.Image = qmUrl
		hintBtn.ScaleType = Enum.ScaleType.Fit
		hintBtn.AutoButtonColor = false
		hintBtn.ZIndex = 56
		hintBtn.Parent = cBox
	else
		hintBtn = makeArcadeBtn(cBox, "?", UDim2.fromOffset(26, 26), UDim2.new(1, -30, 0.5, -13), Color3.fromRGB(48, 152, 232), Color3.fromRGB(24, 86, 182), 7, { TextSize = 12, ZIndex = 56, Depth = 2 })
	end

	local cBtn = makeArcadeBtn(codeRow, "NHẬN", UDim2.fromOffset(88, 34), UDim2.new(1, -96, 0, 11), Color3.fromRGB(64, 194, 92), Color3.fromRGB(28, 134, 58), 8, { TextSize = 11, ZIndex = 54, Depth = 3 })

	hintBtn.MouseButton1Click:Connect(function()
		for _, ch in ipairs(UI.pmList:GetChildren()) do if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end end
		UI.pmTitle.Text = "GỢI Ý CODE QUÀ TẶNG"
		local PUBLIC_CODES = {
			{ Code = "THUTHANH2D", Desc = "+30 Sao, +2 Thiên Thạch, +2 Bão Tuyết, +2 Túi Vàng" },
			{ Code = "TANTHU2026", Desc = "+25 Sao, +3 Bẫy Gai, +2 Mìn Nổ, +1 Hố Đen" },
			{ Code = "VIPBOSS888", Desc = "+50 Sao, +3 Thiên Thạch, +3 Hố Đen, +3 Túi Vàng" },
			{ Code = "SIEUCAP999", Desc = "+100 Sao & +5 tất cả Kỹ Năng, Bẫy, Túi Vàng" },
			{ Code = "QUATANG500", Desc = "+40 Sao, +3 Bão Tuyết, +3 Bẫy Gai, +2 Túi Vàng" },
			{ Code = "THAPCANH2D", Desc = "+35 Sao, +3 Thiên Thạch, +3 Mìn Nổ" },
			{ Code = "PHONGTHU77", Desc = "+60 Sao, +2 Hố Đen, +4 Bẫy Gai, +3 Mìn Nổ" },
			{ Code = "VUOTAI2026", Desc = "+80 Sao, +4 Thiên Thạch, +4 Bão Tuyết, +4 Túi Vàng" },
			{ Code = "CHIENBINH9", Desc = "+75 Sao, +4 Hố Đen, +5 Bẫy Gai, +5 Mìn Nổ" },
			{ Code = "DAUTRUONG1", Desc = "+120 Sao & +6 tất cả Kỹ Năng, Bẫy, Túi Vàng" },
			{ Code = "BAOVETHANH", Desc = "+45 Sao, +3 Thiên Thạch, +3 Bẫy Gai, +2 Túi Vàng" },
			{ Code = "THIENTHACH", Desc = "+55 Sao, +5 Thiên Thạch, +2 Túi Vàng" },
			{ Code = "BAOTUYET26", Desc = "+55 Sao, +5 Bão Tuyết, +3 Bẫy Gai" },
			{ Code = "HODENVIP99", Desc = "+65 Sao, +4 Hố Đen, +4 Mìn Nổ" },
			{ Code = "KHOBAUVANG", Desc = "+90 Sao, +6 Túi Vàng, +3 Thiên Thạch" },
			{ Code = "HUYENTHOAI", Desc = "+150 Sao & +8 tất cả Kỹ Năng, Bẫy, Túi Vàng" },
		}
		local cScroll = Instance.new("ScrollingFrame")
		cScroll.Size = UDim2.new(1, 0, 0, 218)
		cScroll.BackgroundTransparency = 1
		cScroll.BorderSizePixel = 0
		cScroll.ScrollBarThickness = 5
		cScroll.ScrollBarImageColor3 = THEME.TextCyan
		cScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		cScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		cScroll.ZIndex = 53
		cScroll.Parent = UI.pmList
		local cLay = Instance.new("UIListLayout")
		cLay.Padding = UDim.new(0, 6)
		cLay.Parent = cScroll
		for _, pc in ipairs(PUBLIC_CODES) do
			local used = (saveState.UsedCodes[pc.Code] == true)
			local r = Instance.new("Frame")
			r.Size = UDim2.new(1, -8, 0, 48)
			r.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
			r.BorderSizePixel = 0
			r.ZIndex = 53
			r.Parent = cScroll
			addCorner(r, 9)
			addStroke(r, used and Color3.fromRGB(72, 78, 112) or THEME.TextCyan, 1.5)

			local cl = Instance.new("TextLabel")
			cl.Size = UDim2.fromOffset(318, 18)
			cl.Position = UDim2.fromOffset(10, 4)
			cl.BackgroundTransparency = 1
			cl.Text = pc.Code .. (used and "  (Đã dùng)" or "")
			cl.TextColor3 = used and THEME.TextMuted or THEME.TextGold
			cl.Font = THEME.FontHead
			cl.TextSize = 11
			cl.TextXAlignment = Enum.TextXAlignment.Left
			cl.ZIndex = 54
			cl.Parent = r

			local dl = Instance.new("TextLabel")
			dl.Size = UDim2.fromOffset(318, 18)
			dl.Position = UDim2.fromOffset(10, 24)
			dl.BackgroundTransparency = 1
			dl.Text = pc.Desc
			dl.TextColor3 = THEME.TextMuted
			dl.Font = THEME.FontBody
			dl.TextSize = 9
			dl.TextXAlignment = Enum.TextXAlignment.Left
			dl.ZIndex = 54
			dl.Parent = r

			local cpBtn = makeArcadeBtn(r, "CHÉP", UDim2.fromOffset(92, 30), UDim2.new(1, -100, 0, 9), Color3.fromRGB(54, 152, 214), Color3.fromRGB(28, 86, 168), 8, { TextSize = 10, ZIndex = 54, Depth = 3 })
			cpBtn.MouseButton1Click:Connect(function()
				if typeof(setclipboard) == "function" then pcall(setclipboard, pc.Code) end
				showToast("Đã sao chép code: " .. pc.Code, THEME.TextCyan, 1.8)
			end)
		end
		local backR = Instance.new("Frame")
		backR.Size = UDim2.new(1, 0, 0, 36)
		backR.BackgroundTransparency = 1
		backR.ZIndex = 53
		backR.Parent = UI.pmList
		local bk = makeArcadeBtn(backR, "QUAY LẠI CÀI ĐẶT", UDim2.fromOffset(180, 30), UDim2.new(0.5, -90, 0, 3), Color3.fromRGB(154, 72, 218), Color3.fromRGB(94, 34, 168), 8, { TextSize = 10, ZIndex = 54, Depth = 3 })
		bk.MouseButton1Click:Connect(openLobbySettings)
	end)

	cBtn.MouseButton1Click:Connect(function()
		local code = string.upper((cInput.Text or ""):gsub("%s+", ""))
		if code == "" then return end
		if saveState.UsedCodes[code] then
			showToast("Code này bạn đã sử dụng rồi!", THEME.TextRed, 2.0)
			return
		end
		if code == "ADMINFULLALLTHUTHANH2D" then
			saveState.UsedCodes[code] = true
			saveState.Stars += 999999
			for _, sk in ipairs({"meteor", "bliz", "void", "spike", "mine"}) do
				saveState.SkillStock[sk] = (saveState.SkillStock[sk] or 0) + 9999
			end
			saveState.Bag.goldbag = (saveState.Bag.goldbag or 0) + 9999
			for _, u in ipairs(PERM_UPGRADES) do saveState.Upgrades[u.Key] = u.Max end
			for _, mp in ipairs(MAPS) do
				saveState.StageUnlocked[mp.Id] = 7
				for s = 1, 7 do saveState.StageDiffUnlocked[mp.Id .. "_" .. tostring(s)] = 3 end
			end
			saveData()
			playSfx("upgrade", 1.25)
			refreshLobbyStats()
			showToast("ADMIN FULL: +999,999 Sao, +9,999 Kỹ Năng/Vật Phẩm & Mở Full Ải!", THEME.TextGold, 3.2)
			cInput.Text = ""
			return
		end
		local REWARDS = {
			THUTHANH2D = { Stars = 30,  meteor = 2, bliz = 2, goldbag = 2, Msg = "+30 Sao, +2 Thiên Thạch, +2 Bão Tuyết, +2 Túi Vàng!" },
			TANTHU2026 = { Stars = 25,  spike = 3, mine = 2, void = 1, Msg = "+25 Sao, +3 Bẫy Gai, +2 Mìn Nổ, +1 Hố Đen!" },
			VIPBOSS888 = { Stars = 50,  meteor = 3, void = 3, goldbag = 3, Msg = "+50 Sao, +3 Thiên Thạch, +3 Hố Đen, +3 Túi Vàng!" },
			SIEUCAP999 = { Stars = 100, meteor = 5, bliz = 5, void = 5, spike = 5, mine = 5, goldbag = 5, Msg = "+100 Sao & +5 tất cả Kỹ Năng, Bẫy, Túi Vàng!" },
			QUATANG500 = { Stars = 40,  bliz = 3, spike = 3, goldbag = 2, Msg = "+40 Sao, +3 Bão Tuyết, +3 Bẫy Gai, +2 Túi Vàng!" },
			THAPCANH2D = { Stars = 35,  meteor = 3, mine = 3, Msg = "+35 Sao, +3 Thiên Thạch, +3 Mìn Nổ!" },
			PHONGTHU77 = { Stars = 60,  void = 2, spike = 4, mine = 3, Msg = "+60 Sao, +2 Hố Đen, +4 Bẫy Gai, +3 Mìn Nổ!" },
			VUOTAI2026 = { Stars = 80,  meteor = 4, bliz = 4, goldbag = 4, Msg = "+80 Sao, +4 Thiên Thạch, +4 Bão Tuyết, +4 Túi Vàng!" },
			CHIENBINH9 = { Stars = 75,  void = 4, spike = 5, mine = 5, Msg = "+75 Sao, +4 Hố Đen, +5 Bẫy Gai, +5 Mìn Nổ!" },
			DAUTRUONG1 = { Stars = 120, meteor = 6, bliz = 6, void = 6, spike = 6, mine = 6, goldbag = 6, Msg = "+120 Sao & +6 tất cả Kỹ Năng, Bẫy, Túi Vàng!" },
			BAOVETHANH = { Stars = 45,  meteor = 3, spike = 3, goldbag = 2, Msg = "+45 Sao, +3 Thiên Thạch, +3 Bẫy Gai, +2 Túi Vàng!" },
			THIENTHACH = { Stars = 55,  meteor = 5, goldbag = 2, Msg = "+55 Sao, +5 Thiên Thạch, +2 Túi Vàng!" },
			BAOTUYET26 = { Stars = 55,  bliz = 5, spike = 3, Msg = "+55 Sao, +5 Bão Tuyết, +3 Bẫy Gai!" },
			HODENVIP99 = { Stars = 65,  void = 4, mine = 4, Msg = "+65 Sao, +4 Hố Đen, +4 Mìn Nổ!" },
			KHOBAUVANG = { Stars = 90,  goldbag = 6, meteor = 3, Msg = "+90 Sao, +6 Túi Vàng, +3 Thiên Thạch!" },
			HUYENTHOAI = { Stars = 150, meteor = 8, bliz = 8, void = 8, spike = 8, mine = 8, goldbag = 8, Msg = "+150 Sao & +8 tất cả Kỹ Năng, Bẫy, Túi Vàng!" },
		}
		local rw = REWARDS[code]
		if not rw then
			showToast("Code không hợp lệ! Bấm dấu ? để xem gợi ý.", THEME.TextRed, 2.2)
			return
		end
		saveState.UsedCodes[code] = true
		saveState.Stars += (rw.Stars or 0)
		for _, sk in ipairs({"meteor", "bliz", "void", "spike", "mine"}) do
			if rw[sk] then saveState.SkillStock[sk] = (saveState.SkillStock[sk] or 0) + rw[sk] end
		end
		if rw.goldbag then saveState.Bag.goldbag = (saveState.Bag.goldbag or 0) + rw.goldbag end
		saveData()
		playSfx("upgrade", 1.2)
		refreshLobbyStats()
		showToast("NHẬN CODE THÀNH CÔNG: " .. rw.Msg, THEME.TextGold, 3.0)
		cInput.Text = ""
	end)

	-- Nut Reset du lieu choi lai tu dau (co xac nhan 2 buoc)
	local resetRow = Instance.new("Frame")
	resetRow.LayoutOrder = 4
	resetRow.Size = UDim2.new(1, -6, 0, 52)
	resetRow.BackgroundColor3 = Color3.fromRGB(40, 22, 34)
	resetRow.BorderSizePixel = 0
	resetRow.ZIndex = 53
	resetRow.Parent = setScroll
	addCorner(resetRow, 10)
	addStroke(resetRow, THEME.TextRed, 1.8)
	addGradient(resetRow, Color3.fromRGB(64, 24, 38), Color3.fromRGB(28, 14, 24), 90)

	local rTitle = Instance.new("TextLabel")
	rTitle.Size = UDim2.fromOffset(310, 20)
	rTitle.Position = UDim2.fromOffset(12, 6)
	rTitle.BackgroundTransparency = 1
	rTitle.Text = "CHƠI LẠI TỪ ĐẦU (RESET DỮ LIỆU)"
	rTitle.TextColor3 = THEME.TextRed
	rTitle.Font = THEME.FontHead
	rTitle.TextSize = 11
	rTitle.TextXAlignment = Enum.TextXAlignment.Left
	rTitle.ZIndex = 54
	rTitle.Parent = resetRow

	local rDesc = Instance.new("TextLabel")
	rDesc.Size = UDim2.fromOffset(310, 18)
	rDesc.Position = UDim2.fromOffset(12, 27)
	rDesc.BackgroundTransparency = 1
	rDesc.Text = "Xóa Sao, Ải đã mở, Kỹ năng, Nhiệm vụ & Code đã nhập"
	rDesc.TextColor3 = THEME.TextMuted
	rDesc.Font = THEME.FontBody
	rDesc.TextSize = 9
	rDesc.TextXAlignment = Enum.TextXAlignment.Left
	rDesc.ZIndex = 54
	rDesc.Parent = resetRow

	local rBtn = makeArcadeBtn(resetRow, "RESET", UDim2.fromOffset(88, 32), UDim2.new(1, -96, 0, 10), Color3.fromRGB(218, 62, 72), Color3.fromRGB(148, 28, 38), 8, { TextSize = 11, ZIndex = 54, Depth = 3 })
	rBtn.MouseButton1Click:Connect(function()
		for _, ch in ipairs(UI.pmList:GetChildren()) do if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end end
		UI.pmTitle.Text = "XÁC NHẬN CHƠI LẠI TỪ ĐẦU"

		local warnCard = Instance.new("Frame")
		warnCard.Size = UDim2.new(1, 0, 0, 118)
		warnCard.BackgroundColor3 = Color3.fromRGB(36, 20, 32)
		warnCard.BorderSizePixel = 0
		warnCard.ZIndex = 53
		warnCard.Parent = UI.pmList
		addCorner(warnCard, 12)
		addStroke(warnCard, THEME.TextRed, 2.0)

		local wl = Instance.new("TextLabel")
		wl.Size = UDim2.new(1, -24, 0, 86)
		wl.Position = UDim2.fromOffset(12, 16)
		wl.BackgroundTransparency = 1
		wl.Text = "Bạn có chắc chắn muốn RESET toàn bộ dữ liệu game?\n\nToàn bộ Sao, Ải & Độ khó đã mở, Kỹ năng/Kho đồ, Nhiệm vụ và Code đã dùng sẽ quay về trạng thái ban đầu."
		wl.TextColor3 = THEME.TextMain
		wl.Font = THEME.FontBody
		wl.TextSize = 12
		wl.TextWrapped = true
		wl.ZIndex = 54
		wl.Parent = warnCard

		local actRow = Instance.new("Frame")
		actRow.Size = UDim2.new(1, 0, 0, 44)
		actRow.BackgroundTransparency = 1
		actRow.ZIndex = 53
		actRow.Parent = UI.pmList

		local cancelB = makeArcadeBtn(actRow, "HỦY", UDim2.fromOffset(156, 36), UDim2.new(0.5, -166, 0, 4), Color3.fromRGB(82, 92, 128), Color3.fromRGB(48, 54, 82), 9, { TextSize = 12, ZIndex = 54, Depth = 3 })
		local okB     = makeArcadeBtn(actRow, "XÁC NHẬN RESET", UDim2.fromOffset(176, 36), UDim2.new(0.5, 6, 0, 4), Color3.fromRGB(224, 58, 68), Color3.fromRGB(152, 24, 34), 9, { TextSize = 12, ZIndex = 54, Depth = 3 })

		cancelB.MouseButton1Click:Connect(openLobbySettings)
		okB.MouseButton1Click:Connect(function()
			saveState.BestWave = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 }
			saveState.Wins = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 }
			saveState.TotalKills = 0
			saveState.Stars = 15
			saveState.Upgrades = { dmg = 0, gold = 0, lives = 0, skill = 0 }
			saveState.MapStars = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 }
			saveState.StageUnlocked = { meadow = 1, desert = 1, citadel = 1, heroic_boss = 1, endless = 1 }
			saveState.StageStars = {}
			saveState.StageDiffUnlocked = {}
			saveState.SelectedStage = 1
			saveState.Bag = { goldbag = 2 }
			saveState.SkillStock = { meteor = 3, bliz = 3, void = 2, spike = 4, mine = 3 }
			saveState.SelectedMap = 1
			saveState.Difficulty = "easy"
			saveState.OwnedSkins = { default = true }
			saveState.EquippedSkin = "default"
			saveState.UsedCodes = {}
			saveState.FirstCleared = {}
			saveState.Perfect3Star = {}
			saveState.Quests = createDefaultQuests()
			saveData()
			refreshLobbyStats()
			UI.pmOverlay.Visible = false
			playSfx("upgrade", 0.9)
			showToast("Đã reset toàn bộ dữ liệu! Bắt đầu hành trình mới.", THEME.TextGold, 2.8)
		end)
	end)

	UI.pmOverlay.Visible = true
end
UI.settingsBtn.MouseButton1Click:Connect(openLobbySettings)

-- Bang KHO DO: chi hien thi vat pham & ky nang da mua (so luong > 0) kem hinh anh 3D
local function openInventoryModal()
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "KHO ĐỒ CỦA BẠN  •  VẬT PHẨM ĐÃ MUA"

	local sc = Instance.new("ScrollingFrame")
	sc.Size = UDim2.new(1, 0, 0, 260)
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.ScrollBarThickness = 5
	sc.ScrollBarImageColor3 = THEME.TextGold
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.ZIndex = 53
	sc.Parent = UI.pmList
	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 6)
	lay.Parent = sc

	local countShown = 0
	for _, it in ipairs(SHOP_SKILLS) do
		local qty = (it.Kind == "bag") and (saveState.Bag[it.Id] or 0) or (saveState.SkillStock[it.Id] or 0)
		if qty > 0 then
			countShown += 1
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -8, 0, 52)
			row.BackgroundColor3 = Color3.fromRGB(28, 32, 58)
			row.BorderSizePixel = 0
			row.ZIndex = 53
			row.Parent = sc
			addCorner(row, 10)
			addStroke(row, it.Color, 1.6)

			local u = getMapImageAsset(it.Img)
			if u then
				local ic = Instance.new("ImageLabel")
				ic.Size = UDim2.fromOffset(38, 38)
				ic.Position = UDim2.fromOffset(8, 7)
				ic.BackgroundTransparency = 1
				ic.Image = u
				ic.ScaleType = Enum.ScaleType.Fit
				ic.ZIndex = 54
				ic.Parent = row
			end

			local nm = Instance.new("TextLabel")
			nm.Size = UDim2.fromOffset(270, 20)
			nm.Position = UDim2.fromOffset(54, 6)
			nm.BackgroundTransparency = 1
			nm.Text = it.Name
			nm.TextColor3 = THEME.TextGold
			nm.Font = THEME.FontHead
			nm.TextSize = 12
			nm.TextXAlignment = Enum.TextXAlignment.Left
			nm.ZIndex = 54
			nm.Parent = row

			local ds = Instance.new("TextLabel")
			ds.Size = UDim2.fromOffset(270, 18)
			ds.Position = UDim2.fromOffset(54, 27)
			ds.BackgroundTransparency = 1
			ds.Text = it.Desc
			ds.TextColor3 = THEME.TextMuted
			ds.Font = THEME.FontBody
			ds.TextSize = 10
			ds.TextXAlignment = Enum.TextXAlignment.Left
			ds.ZIndex = 54
			ds.Parent = row

			local qBadge = Instance.new("TextLabel")
			qBadge.Size = UDim2.fromOffset(64, 30)
			qBadge.Position = UDim2.new(1, -72, 0, 11)
			qBadge.BackgroundColor3 = Color3.fromRGB(38, 46, 86)
			qBadge.BorderSizePixel = 0
			qBadge.Text = formatNum(qty)
			qBadge.TextColor3 = THEME.TextGold
			qBadge.Font = THEME.FontHead
			qBadge.TextSize = 13
			qBadge.ZIndex = 54
			qBadge.Parent = row
			addCorner(qBadge, 8)
			addStroke(qBadge, it.Color, 1.4)
		end
	end
	if countShown == 0 then
		local emptyL = Instance.new("TextLabel")
		emptyL.Size = UDim2.new(1, 0, 0, 80)
		emptyL.BackgroundTransparency = 1
		emptyL.Text = "Kho đồ trống! Hãy vào Cửa Hàng ngoài Sảnh để mua Kỹ Năng & Túi Vàng."
		emptyL.TextColor3 = THEME.TextMuted
		emptyL.Font = THEME.FontHead
		emptyL.TextSize = 12
		emptyL.TextWrapped = true
		emptyL.ZIndex = 54
		emptyL.Parent = sc
	end
	UI.pmOverlay.Visible = true
end
UI.bagBtn.MouseButton1Click:Connect(openInventoryModal)


local function refreshTrapHighlight()
	if UI.spikeStroke then
		UI.spikeStroke.Color = (TD.trapMode == "spike") and THEME.TextGold or Color3.fromRGB(72, 78, 118)
		UI.spikeStroke.Thickness = (TD.trapMode == "spike") and 2.6 or 1.4
	end
	if UI.mineStroke then
		UI.mineStroke.Color = (TD.trapMode == "mine") and THEME.TextGold or Color3.fromRGB(72, 78, 118)
		UI.mineStroke.Thickness = (TD.trapMode == "mine") and 2.6 or 1.4
	end
end

UI.spikeBtn.MouseButton1Click:Connect(function()
	if TD.trapMode == "spike" then
		TD.trapMode = "none"
		showToast("Đã tắt đặt Bẫy Gai", THEME.TextMuted, 1.5)
	else
		TD.trapMode = "spike"
		if (saveState.SkillStock.spike or 0) <= 0 then showToast("Hết Bẫy Gai! Mua thêm ở Cửa Hàng ngoài Sảnh.", THEME.TextRed, 2.0) return end
		showToast("Chạm vào đường đi để đặt Bẫy Gai (Còn x" .. tostring(saveState.SkillStock.spike) .. ")", THEME.TextCyan, 2.0)
	end
	refreshTrapHighlight()
end)

UI.mineBtn.MouseButton1Click:Connect(function()
	if TD.trapMode == "mine" then
		TD.trapMode = "none"
		showToast("Đã tắt đặt Mìn Nổ", THEME.TextMuted, 1.5)
	else
		TD.trapMode = "mine"
		if (saveState.SkillStock.mine or 0) <= 0 then showToast("Hết Mìn Nổ! Mua thêm ở Cửa Hàng ngoài Sảnh.", THEME.TextRed, 2.0) return end
		showToast("Chạm vào đường đi để đặt Mìn Nổ (Còn x" .. tostring(saveState.SkillStock.mine) .. ")", THEME.TextRed, 2.0)
	end
	refreshTrapHighlight()
end)

UI.goldBagBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.paused or TD.over then return end
	local q = saveState.Bag.goldbag or 0
	if q <= 0 then
		showToast("Hết Túi Vàng! Mua thêm ở Cửa Hàng ngoài Sảnh.", THEME.TextRed, 2.0)
		return
	end
	saveState.Bag.goldbag = q - 1
	TD.gold += 250
	addQuestProg("skill", 1)
	saveData()
	playSfx("upgrade", 1.2)
	showToast("Dùng Túi Vàng: +250 Vàng!", THEME.TextGold, 2.0)
	updateHUD()
end)

-- Nut Ky Nang Bao Tuyet (dong bang toan ban do 4s)
UI.blizBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.paused or TD.over or TD.blizCd > 0 then return end
	if #TD.enemies == 0 then
		showToast("Chưa có quái trên đường!", THEME.TextCyan, 1.8)
		return
	end
	local stk = saveState.SkillStock.bliz or 0
	if stk <= 0 then showToast("Hết Bão Tuyết! Mua thêm ở Cửa Hàng ngoài Sảnh.", THEME.TextRed, 2.0) return end
	saveState.SkillStock.bliz = stk - 1
	addQuestProg("skill", 1)
	saveData()
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

-- Do hoa hieu ung chien dau (VFX) cho 8 ky nang moi
local function spawnSkillVfxMeteor(tx, ty)
	if not canSpawnFx(true) then return end
	local rock = Instance.new("Frame")
	rock.Size = UDim2.fromOffset(18, 18)
	rock.Position = UDim2.fromOffset(tx - 54, ty - 76)
	rock.AnchorPoint = Vector2.new(0.5, 0.5)
	rock.BackgroundColor3 = Color3.fromRGB(232, 92, 36)
	rock.BorderSizePixel = 0
	rock.ZIndex = 27
	rock.Parent = UI.fxLayer
	addCorner(rock, 99)
	local tw = TweenService:Create(rock, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.fromOffset(tx, ty),
		Size = UDim2.fromOffset(24, 24)
	})
	tw:Play()
	tw.Completed:Connect(function()
		releaseFx(rock)
		spawnExplosionRing(tx, ty, 38, Color3.fromRGB(234, 98, 42))
	end)
end

-- 3. Ky nang HO DEN: tao lo den hut quai & rut mau lien tuc 3.2s
UI.voidBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.paused or TD.over or (TD.voidCd or 0) > 0 then return end
	if #TD.enemies == 0 then showToast("Chưa có quái trên đường!", THEME.TextPurple, 1.8) return end
	local lead = TD.enemies[1]
	for _, e in ipairs(TD.enemies) do if not e.Dead and e.Progress > lead.Progress then lead = e end end
	local stk = saveState.SkillStock.void or 0
	if stk <= 0 then showToast("Hết Hố Đen! Mua thêm ở Cửa Hàng ngoài Sảnh.", THEME.TextRed, 2.0) return end
	saveState.SkillStock.void = stk - 1
	addQuestProg("skill", 1)
	saveData()
	TD.voidCd = math.max(14, 24 - (saveState.Upgrades.skill or 0) * 2)
	playSfx("explosion", 0.72)
	if TD.voidHole and TD.voidHole.Node and TD.voidHole.Node.Parent then TD.voidHole.Node:Destroy() end
	local vn = Instance.new("Frame")
	vn.Size = UDim2.fromOffset(56, 56)
	vn.Position = UDim2.fromOffset(lead.X, lead.Y)
	vn.AnchorPoint = Vector2.new(0.5, 0.5)
	vn.BackgroundColor3 = Color3.fromRGB(18, 8, 36)
	vn.BorderSizePixel = 0
	vn.ZIndex = 23
	vn.Parent = UI.fxLayer
	addCorner(vn, 99)
	addStroke(vn, Color3.fromRGB(196, 72, 242), 3.0)
	TD.voidHole = { X = lead.X, Y = lead.Y, Timer = 3.2, Node = vn }
	spawnExplosionRing(lead.X, lead.Y, 64, Color3.fromRGB(192, 72, 238))
	showToast("Hố Đen xuất hiện — hút và nghiền nát quái!", THEME.TextPurple, 2.2)
	updateHUD()
end)

UI.skillBtn.MouseButton1Click:Connect(function()
	if not TD.active or TD.paused or TD.over then return end
	if TD.skillCd > 0 then return end
	if #TD.enemies == 0 then
		showToast("Chưa có quái trên đường để thả Thiên Thạch!", THEME.TextGold, 2.0)
		return
	end
	local stk = saveState.SkillStock.meteor or 0
	if stk <= 0 then showToast("Hết Thiên Thạch! Mua thêm ở Cửa Hàng ngoài Sảnh.", THEME.TextRed, 2.0) return end
	saveState.SkillStock.meteor = stk - 1
	addQuestProg("skill", 1)
	saveData()
	TD.skillCd = math.max(12, 25 - (saveState.Upgrades.skill or 0) * 2)
	playSfx("explosion", 0.9)
	TD.shakeTime = 0.25
	local dmg = 95 + TD.wave * 24
	for _, e in ipairs(TD.enemies) do
		if not e.Dead then
			spawnSkillVfxMeteor(e.X, e.Y)
			damageEnemy(e, dmg, nil, nil, nil, nil, "Thiên Thạch")
		end
	end
	showToast("Mưa Thiên Thạch giáng xuống toàn bản đồ!", THEME.TextGold, 2.2)
	updateHUD()
end)

UI.waveBtn.MouseButton1Click:Connect(startNextWave)
UI.endReplayBtn.MouseButton1Click:Connect(startNewMatch)
UI.homeBtn.MouseButton1Click:Connect(goLobby)
UI.endHomeBtn.MouseButton1Click:Connect(goLobby)

UI.spdBtn.MouseButton1Click:Connect(function()
	TD.speedMult = (TD.speedMult == 1) and 2 or ((TD.speedMult == 2) and 3 or 1)
	updateHUD()
end)

local function openPauseMenu()
	if not TD.active or TD.over then return end
	TD.paused = true
	if not UI.pauseOverlay then
		local ov = Instance.new("TextButton")
		ov.Size = UDim2.fromScale(1, 1)
		ov.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
		ov.BackgroundTransparency = 0.42
		ov.Text = ""
		ov.AutoButtonColor = false
		ov.Active = true
		ov.Modal = true
		ov.BorderSizePixel = 0
		ov.ZIndex = 58
		ov.Visible = false
		ov.Parent = mainFrame
		addCorner(ov, 14)

		local box = Instance.new("TextButton")
		box.Size = UDim2.fromOffset(254, 182)
		box.Position = UDim2.fromScale(0.5, 0.5)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.BackgroundColor3 = Color3.fromRGB(22, 26, 52)
		box.Text = ""
		box.AutoButtonColor = false
		box.Active = true
		box.Modal = true
		box.BorderSizePixel = 0
		box.ZIndex = 59
		box.Parent = ov
		addCorner(box, 14)
		addStroke(box, THEME.TextGold, 2.2)
		addGradient(box, Color3.fromRGB(36, 40, 78), Color3.fromRGB(16, 18, 38), 95)

		local ttl = Instance.new("TextLabel")
		ttl.Size = UDim2.new(1, 0, 0, 32)
		ttl.Position = UDim2.fromOffset(0, 8)
		ttl.BackgroundTransparency = 1
		ttl.Text = "TẠM DỪNG"
		ttl.TextColor3 = THEME.TextGold
		ttl.Font = THEME.FontHead
		ttl.TextSize = 15
		ttl.ZIndex = 60
		ttl.Parent = box
		addTextOutline(ttl, 1.5, THEME.Outline)

		local resUrl, quitUrl = getMapImageAsset("pm_resume"), getMapImageAsset("pm_quit")
		local resBtn, quitBtn
		if resUrl then
			resBtn = Instance.new("ImageButton")
			resBtn.Size = UDim2.fromOffset(186, 56)
			resBtn.Position = UDim2.new(0.5, -93, 0, 46)
			resBtn.BackgroundTransparency = 1
			resBtn.Image = resUrl
			resBtn.ScaleType = Enum.ScaleType.Fit
			resBtn.AutoButtonColor = false
			resBtn.ZIndex = 60
			resBtn.Parent = box
		else
			resBtn = makeArcadeBtn(box, "Tiếp Tục", UDim2.fromOffset(186, 48), UDim2.new(0.5, -93, 0, 48), Color3.fromRGB(54, 214, 88), Color3.fromRGB(22, 146, 52), 11, { TextSize = 14, ZIndex = 60, Depth = 4 })
		end
		if quitUrl then
			quitBtn = Instance.new("ImageButton")
			quitBtn.Size = UDim2.fromOffset(186, 56)
			quitBtn.Position = UDim2.new(0.5, -93, 0, 110)
			quitBtn.BackgroundTransparency = 1
			quitBtn.Image = quitUrl
			quitBtn.ScaleType = Enum.ScaleType.Fit
			quitBtn.AutoButtonColor = false
			quitBtn.ZIndex = 60
			quitBtn.Parent = box
		else
			quitBtn = makeArcadeBtn(box, "Thoát", UDim2.fromOffset(186, 48), UDim2.new(0.5, -93, 0, 112), Color3.fromRGB(224, 58, 66), Color3.fromRGB(158, 24, 34), 11, { TextSize = 14, ZIndex = 60, Depth = 4 })
		end

		resBtn.MouseButton1Click:Connect(function()
			ov.Visible = false
			TD.paused = false
		end)
		quitBtn.MouseButton1Click:Connect(function()
			ov.Visible = false
			TD.paused = false
			goLobby()
		end)
		UI.pauseOverlay = ov
	end
	UI.pauseOverlay.Visible = true
end

UI.pauseBtn.MouseButton1Click:Connect(openPauseMenu)

local function apply3dState()
	pcall(function()
		RunService:Set3dRenderingEnabled(not (saveState.Hide3D and mainFrame.Visible))
	end)
end
UI.apply3dState = apply3dState

local function minimizeMenu()
	if TD.active then TD.paused = true UI.pauseLbl.Text = "▶" end
	mainFrame.Visible = false
	backdrop.Visible = false
	floatBtn.Visible = true
	apply3dState()
end

local function restoreMenu()
	floatBtn.Visible = false
	mainFrame.Visible = true
	backdrop.Visible = true
	apply3dState()
end

screenGui.Destroying:Connect(function()
	pcall(function() RunService:Set3dRenderingEnabled(true) end)
end)
apply3dState()

UI.minBtn.MouseButton1Click:Connect(minimizeMenu)
floatBtn.MouseButton1Click:Connect(function() if not floatDragged then restoreMenu() end end)
-- Hop thoai Xac Nhan Thoat Game gon gang (khong long khung ngoai lon)
local function openExitConfirm()
	if not UI.exitOverlay then
		local ov = Instance.new("TextButton")
		ov.Size = UDim2.fromScale(1, 1)
		ov.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
		ov.BackgroundTransparency = 0.42
		ov.Text = ""
		ov.AutoButtonColor = false
		ov.Active = true
		ov.Modal = true
		ov.BorderSizePixel = 0
		ov.ZIndex = 60
		ov.Visible = false
		ov.Parent = mainFrame
		addCorner(ov, 14)

		local box = Instance.new("TextButton")
		box.Size = UDim2.fromOffset(396, 150)
		box.Position = UDim2.fromScale(0.5, 0.5)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.BackgroundColor3 = Color3.fromRGB(24, 28, 52)
		box.Text = ""
		box.AutoButtonColor = false
		box.Active = true
		box.Modal = true
		box.BorderSizePixel = 0
		box.ZIndex = 61
		box.Parent = ov
		addCorner(box, 14)
		addStroke(box, THEME.TextGold, 2.2)

		local msg = Instance.new("TextLabel")
		msg.Size = UDim2.new(1, -28, 0, 56)
		msg.Position = UDim2.fromOffset(14, 18)
		msg.BackgroundTransparency = 1
		msg.Text = "Bạn có chắc muốn thoát game Thủ Thành 2D?\nTiến trình Sao và kỷ lục sẽ tự động được lưu lại."
		msg.TextColor3 = THEME.TextMain
		msg.Font = THEME.FontHead
		msg.TextSize = 13
		msg.TextWrapped = true
		msg.ZIndex = 62
		msg.Parent = box

		local clUrl, exUrl = getMapImageAsset("btn_close"), getMapImageAsset("btn_exit")
		local cancelB, okB
		if clUrl then
			cancelB = Instance.new("ImageButton")
			cancelB.Size = UDim2.fromOffset(146, 44)
			cancelB.Position = UDim2.new(0.5, -156, 0, 88)
			cancelB.BackgroundTransparency = 1
			cancelB.Image = clUrl
			cancelB.ScaleType = Enum.ScaleType.Fit
			cancelB.AutoButtonColor = false
			cancelB.ZIndex = 62
			cancelB.Parent = box
		else
			cancelB = makeArcadeBtn(box, "ĐÓNG", UDim2.fromOffset(146, 38), UDim2.new(0.5, -156, 0, 92), Color3.fromRGB(78, 92, 134), Color3.fromRGB(48, 56, 86), 9, { TextSize = 13, ZIndex = 62, Depth = 3 })
		end
		if exUrl then
			okB = Instance.new("ImageButton")
			okB.Size = UDim2.fromOffset(146, 44)
			okB.Position = UDim2.new(0.5, 10, 0, 88)
			okB.BackgroundTransparency = 1
			okB.Image = exUrl
			okB.ScaleType = Enum.ScaleType.Fit
			okB.AutoButtonColor = false
			okB.ZIndex = 62
			okB.Parent = box
		else
			okB = makeArcadeBtn(box, "THOÁT", UDim2.fromOffset(146, 38), UDim2.new(0.5, 10, 0, 92), Color3.fromRGB(214, 62, 68), Color3.fromRGB(152, 28, 36), 9, { TextSize = 13, ZIndex = 62, Depth = 3 })
		end
		cancelB.MouseButton1Click:Connect(function() ov.Visible = false end)
		ov.MouseButton1Click:Connect(function() ov.Visible = false end)
		okB.MouseButton1Click:Connect(function()
			saveData()
			screenGui:Destroy()
		end)
		UI.exitOverlay = ov
	end
	UI.exitOverlay.Visible = true
end

UI.closeBtn.MouseButton1Click:Connect(function()
	if gamePage.Visible and TD.active and not TD.over then
		openPauseMenu()
	else
		openExitConfirm()
	end
end)
UI.lobbyExitBtn.MouseButton1Click:Connect(openExitConfirm)

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

track(RunService.Heartbeat:Connect(function(rawDt)
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
	local function tickCd(key)
		local v = TD[key] or 0
		if v > 0 then
			local prev = math.ceil(v)
			TD[key] = math.max(0, v - dt)
			if math.ceil(TD[key]) ~= prev then needHud = true end
		end
	end
	tickCd("healCd")
	tickCd("voidCd")
	tickCd("rageCd")
	if (TD.rageTimer or 0) > 0 then
		TD.rageTimer = math.max(0, TD.rageTimer - dt)
	end
	if TD.voidHole then
		local vh = TD.voidHole
		vh.Timer -= dt
		if vh.Node and vh.Node.Parent then
			vh.Node.Rotation = (vh.Node.Rotation + dt * 260) % 360
		end
		local vDps = (48 + TD.wave * 12) * dt
		for _, e in ipairs(TD.enemies) do
			if not e.Dead then
				local dx, dy = vh.X - e.X, vh.Y - e.Y
				local d = math.sqrt(dx * dx + dy * dy)
				if d <= 125 and d > 4 then
					e.X += (dx / d) * 34 * dt
					e.Y += (dy / d) * 34 * dt
					damageEnemy(e, vDps, 0.5, 0.35, nil, nil, "Hố Đen")
				end
			end
		end
		if vh.Timer <= 0 then
			if vh.Node and vh.Node.Parent then vh.Node:Destroy() end
			TD.voidHole = nil
		end
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
			if e.SprintTimer and e.SprintTimer > 0 then
				e.SprintTimer = math.max(0, e.SprintTimer - dt)
			end
			if e.Def.Boss then
				e.SkillCd -= dt
				if e.SkillCd <= 0 then
					e.SkillCd = 7.8
					local roll = math.random(1, 4)
					if roll == 1 then
						-- Goi 2-3 linh con tai vi tri Boss
						spawnExplosionRing(e.X, e.Y, 44, Color3.fromRGB(178, 82, 224))
						spawnFloatingText(e.X, e.Y - 12, "GỌI LÍNH!", THEME.TextPurple)
						local pool = { "goblin", "spider", "skeleton" }
						local cnt = e.Def.HeroBoss and 3 or 2
						for sIdx = 1, cnt do
							local sub = spawnEnemy(pool[((sIdx - 1) % #pool) + 1])
							if sub then
								sub.Summoned = true
								sub.X = e.X + math.random(-10, 10)
								sub.Y = e.Y + math.random(-10, 10)
								sub.WpIdx = e.WpIdx
								sub.Progress = e.Progress
								sub.Node.Position = UDim2.fromOffset(sub.X, sub.Y)
							end
						end
					elseif roll == 2 then
						-- Dong bang toi da 2 thap gan nhat trong 2.2 giay
						local hit = 0
						for _, tw in ipairs(TD.towers) do
							if math.sqrt((tw.X - e.X)^2 + (tw.Y - e.Y)^2) <= 175 then
								tw.FreezeTimer = math.max(tw.FreezeTimer or 0, 2.2)
								spawnBeamLine(e.X, e.Y, tw.X, tw.Y, THEME.TextCyan, 4, 0.28)
								spawnExplosionRing(tw.X, tw.Y, 26, THEME.TextCyan)
								spawnFloatingText(tw.X, tw.Y - 10, "ĐÓNG BĂNG!", THEME.TextCyan)
								hit += 1
								if hit >= 2 then break end
							end
						end
						if hit > 0 then playSfx("freeze", 0.95) else e.SprintTimer = 1.8 end
					elseif roll == 3 then
						-- Lam choang 1 thap gan nhat trong 2.0 giay + rung nhe
						local nearT, bestD = nil, 170
						for _, tw in ipairs(TD.towers) do
							local dd = math.sqrt((tw.X - e.X)^2 + (tw.Y - e.Y)^2)
							if dd < bestD then bestD = dd nearT = tw end
						end
						if nearT then
							nearT.StunTimer = math.max(nearT.StunTimer or 0, 2.0)
							TD.shakeTime = math.max(TD.shakeTime or 0, 0.16)
							spawnBeamLine(e.X, e.Y, nearT.X, nearT.Y, Color3.fromRGB(186, 86, 232), 4, 0.25)
							spawnExplosionRing(nearT.X, nearT.Y, 28, Color3.fromRGB(186, 86, 232))
							spawnFloatingText(nearT.X, nearT.Y - 10, "CHOÁNG!", THEME.TextPurple)
						else
							e.SprintTimer = 2.0
						end
					else
						if e.Def.HeroBoss then
							local heal = math.floor(e.MaxHP * 0.04)
							e.HP = math.min(e.MaxHP, e.HP + heal)
							e.HpFill.Size = UDim2.fromScale(math.clamp(e.HP / e.MaxHP, 0, 1), 1)
							spawnExplosionRing(e.X, e.Y, 44, Color3.fromRGB(186, 86, 232))
							spawnFloatingText(e.X, e.Y, "+" .. formatNum(heal) .. " HP", THEME.TextPurple)
						else
							e.SprintTimer = 2.0
							spawnExplosionRing(e.X, e.Y, 36, THEME.TextRed)
							spawnFloatingText(e.X, e.Y - 12, "TĂNG TỐC!", THEME.TextRed)
						end
					end
				end
			elseif not e.Summoned and (e.Kind == "golem" or e.Kind == "orc" or e.Kind == "wraith" or e.Kind == "skeleton" or e.Kind == "scorpion" or e.Elite) then
				-- Quai dac biet / Tinh anh co ky nang rieng: Choang, Dong bang, hoac Goi linh
				e.SkillCd -= dt
				if e.SkillCd <= 0 then
					e.SkillCd = 10.0
					if e.Kind == "golem" or e.Kind == "orc" then
						local nearT, bestD = nil, 125
						for _, tw in ipairs(TD.towers) do
							local dd = math.sqrt((tw.X - e.X)^2 + (tw.Y - e.Y)^2)
							if dd < bestD then bestD = dd nearT = tw end
						end
						if nearT then
							nearT.StunTimer = math.max(nearT.StunTimer or 0, 1.3)
							spawnExplosionRing(nearT.X, nearT.Y, 22, THEME.TextGold)
							spawnFloatingText(nearT.X, nearT.Y - 10, "CHOÁNG!", THEME.TextGold)
						end
					elseif e.Kind == "wraith" or e.Kind == "skeleton" then
						local nearT, bestD = nil, 130
						for _, tw in ipairs(TD.towers) do
							local dd = math.sqrt((tw.X - e.X)^2 + (tw.Y - e.Y)^2)
							if dd < bestD then bestD = dd nearT = tw end
						end
						if nearT then
							nearT.FreezeTimer = math.max(nearT.FreezeTimer or 0, 1.5)
							spawnBeamLine(e.X, e.Y, nearT.X, nearT.Y, THEME.TextCyan, 3, 0.22)
							spawnFloatingText(nearT.X, nearT.Y - 10, "ĐÓNG BĂNG!", THEME.TextCyan)
						end
					elseif (e.Kind == "scorpion" or e.Elite) and #TD.enemies < 32 then
						local sub = spawnEnemy("spider")
						if sub then
							sub.Summoned = true
							sub.X = e.X + math.random(-6, 6)
							sub.Y = e.Y + math.random(-6, 6)
							sub.WpIdx = e.WpIdx
							sub.Progress = e.Progress
							sub.Node.Position = UDim2.fromOffset(sub.X, sub.Y)
							spawnFloatingText(e.X, e.Y - 10, "GỌI LÍNH!", THEME.TextPurple)
						end
					end
				end
			end

			local wp = TD.pathPoints[e.WpIdx]
			if wp then
				local dx, dy = wp.x - e.X, wp.y - e.Y
				local dist = math.sqrt(dx * dx + dy * dy)
				local diffSpd = (getDiffDef(saveState.Difficulty).SpdMult or 1.0)
				local sprintMult = (e.SprintTimer and e.SprintTimer > 0) and 1.65 or 1.0
				local step = e.Def.Speed * diffSpd * e.SlowFactor * sprintMult * dt
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
					TD.leaks = (TD.leaks or 0) + 1
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

	-- Thoi tiet theo ban do & khoi thanh tri khi mau thap
	if not saveState.LowFx then
		TD.weatherTimer = (TD.weatherTimer or 0.5) - rawDt
		if TD.weatherTimer <= 0 then
			TD.weatherTimer = 0.75
			spawnWeatherParticle(TD.map)
		end
		local lowHp = (TD.lives / math.max(1, TD.maxLives) <= 0.35) or (TD.maxLives <= 3 and TD.lives < TD.maxLives)
		if lowHp then
			TD.smokeTimer = (TD.smokeTimer or 0.6) - rawDt
			if TD.smokeTimer <= 0 then
				TD.smokeTimer = 0.55
				local pEnd = TD.pathPoints[#TD.pathPoints]
				if pEnd then spawnCastleSmoke(pEnd.x, pEnd.y) end
			end
		end
	end

	-- Thap tim muc tieu theo TargetMode + huong Buff tu Thap Buff + Kiem tra choang Boss
	for _, t in ipairs(TD.towers) do
		local disabled = false
		if t.FreezeTimer and t.FreezeTimer > 0 then
			t.FreezeTimer = math.max(0, t.FreezeTimer - dt)
			if t.FreezeTimer > 0 then
				disabled = true
				if t.StunBadge then
					t.StunBadge.Text = "ĐÓNG BĂNG"
					t.StunBadge.BackgroundColor3 = Color3.fromRGB(32, 148, 214)
					t.StunBadge.TextColor3 = Color3.fromRGB(236, 248, 255)
					t.StunBadge.Visible = true
				end
			end
		end
		if t.StunTimer and t.StunTimer > 0 then
			t.StunTimer = math.max(0, t.StunTimer - dt)
			if t.StunTimer > 0 and not disabled then
				disabled = true
				if t.StunBadge then
					t.StunBadge.Text = "CHOÁNG"
					t.StunBadge.BackgroundColor3 = Color3.fromRGB(132, 42, 186)
					t.StunBadge.TextColor3 = THEME.TextGold
					t.StunBadge.Visible = true
				end
			end
		end
		if disabled then continue end
		if t.StunBadge and t.StunBadge.Visible then
			t.StunBadge.Visible = false
		end
		if t.Def.Kind ~= "Buff" then
			t.Cooldown = math.max(0, t.Cooldown - dt)
			local bDmg, bRate, bRange = getTowerBuffMults(t)
			local effRange = t.Range * (bRange or 1)
			local mode = t.TargetMode or "First"
			local bestE, bestVal = nil, nil
			for _, e in ipairs(TD.enemies) do
				if not e.Dead then
					local d = math.sqrt((e.X - t.X)^2 + (e.Y - t.Y)^2)
					if d <= effRange then
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
					local rageDmg = ((TD.rageTimer or 0) > 0) and 1.50 or 1.0
					local rageRate = ((TD.rageTimer or 0) > 0) and 0.60 or 1.0
					t.Cooldown = math.max(0.12, t.FireRate * bRate * rageRate)
					fireTower(t, bestE, t.Damage * bDmg * rageDmg)
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
			addQuestProg("wave", 1)
			local bonus = 35 + TD.wave * 10
			TD.gold += bonus
			local wStars = math.max(2, math.floor(2 * (getDiffDef(saveState.Difficulty).StarMult or 1) + 0.5))
			local endlessExtra = 0
			if TD.map.Endless and TD.wave % 5 == 0 then
				local tier = math.floor(TD.wave / 5)
				endlessExtra = 5 + tier * 5
				wStars += endlessExtra
				playSfx("victory", 1.15)
			end
			saveState.Stars += wStars
			if TD.wave > (saveState.BestWave[TD.map.Id] or 0) then
				saveState.BestWave[TD.map.Id] = TD.wave
			end
			saveData()
			TD.autoTimer = 2.4
			if endlessExtra > 0 then
				showToast("MỐC VÔ TẬN ĐỢT " .. TD.wave .. "! Thưởng +" .. bonus .. " Vàng & +" .. wStars .. " Sao!", THEME.TextGold, 3.0)
			else
				showToast("Xong Đợt " .. TD.wave .. "! Thưởng +" .. bonus .. " Vàng & +" .. wStars .. " Sao", THEME.TextGreen, 2.2)
			end
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
	local errMsg = "[ThuThanh2D v8.4 ERROR]: " .. tostring(_err)
	warn(errMsg)
	pcall(function()
		local lp = game:GetService("Players").LocalPlayer
		local pg = (typeof(gethui) == "function" and select(2, pcall(gethui))) or (lp and lp:FindFirstChildOfClass("PlayerGui"))
		if pg then
			local eg = Instance.new("ScreenGui")
			eg.Name = "ThuThanh2D_ErrBox"
			eg.DisplayOrder = 2147483647
			eg.Parent = pg
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0.86, 0, 0, 72)
			lbl.Position = UDim2.new(0.07, 0, 0.08, 0)
			lbl.BackgroundColor3 = Color3.fromRGB(148, 28, 36)
			lbl.TextColor3 = Color3.fromRGB(245, 245, 245)
			lbl.TextWrapped = true
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 12
			lbl.Text = errMsg
			lbl.Parent = eg
			task.delay(10, function() pcall(function() eg:Destroy() end) end)
		end
	end)
end
