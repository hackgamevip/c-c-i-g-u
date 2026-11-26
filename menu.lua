-- ============================================================
-- THU THANH 2D (TOWER DEFENSE) v6.1 - KHO DO + NUT TRON 3D + HOI MAU THANH + 3 SAO MAP + TOGGLE + XAC NHAN THOAT
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
		Damage = 26, Range = 138, FireRate = 0.54, ProjSpeed = 450,
		Kind = "Arrow", BaseCol = Color3.fromRGB(64, 176, 92), TopCol = Color3.fromRGB(168, 118, 56),
		Accent = Color3.fromRGB(214, 186, 86), Desc = "Bắn nhanh, tầm rộng, mở trận ổn định"
	},
	{
		Id = "frost", Name = "Băng Giá", Cost = 90, UpgradeCost = 80,
		Damage = 18, Range = 132, FireRate = 0.82, ProjSpeed = 360, Slow = 0.44, SlowDur = 2.5,
		Kind = "Frost", BaseCol = Color3.fromRGB(54, 152, 212), TopCol = Color3.fromRGB(132, 206, 224),
		Accent = Color3.fromRGB(182, 222, 232), Desc = "Làm chậm quái 44% giữ nhịp phòng thủ"
	},
	{
		Id = "cannon", Name = "Đại Bác", Cost = 115, UpgradeCost = 95,
		Damage = 58, Range = 124, FireRate = 1.24, ProjSpeed = 300, Splash = 66,
		Kind = "Bomb", BaseCol = Color3.fromRGB(196, 82, 54), TopCol = Color3.fromRGB(58, 62, 76),
		Accent = Color3.fromRGB(218, 128, 48), Desc = "Nổ diện rộng dọn đàn quái đông"
	},
	{
		Id = "poison", Name = "Tháp Độc", Cost = 120, UpgradeCost = 100,
		Damage = 22, Range = 136, FireRate = 0.80, ProjSpeed = 370, PoisonDps = 20, PoisonDur = 3.8,
		Kind = "Poison", BaseCol = Color3.fromRGB(48, 168, 72), TopCol = Color3.fromRGB(32, 92, 46),
		Accent = Color3.fromRGB(118, 224, 72), Desc = "Độc rút máu bền bỉ khắc chế quái trâu"
	},
	{
		Id = "buff", Name = "Tháp Buff", Cost = 140, UpgradeCost = 125,
		Damage = 0, Range = 136, FireRate = 1.0, BuffDmg = 0.28, BuffRate = 0.20,
		Kind = "Buff", BaseCol = Color3.fromRGB(204, 156, 38), TopCol = Color3.fromRGB(226, 204, 102),
		Accent = Color3.fromRGB(232, 212, 84), Desc = "Tăng +28% ST & tốc bắn tháp quanh nó"
	},
	{
		Id = "tesla", Name = "Lôi Điện", Cost = 165, UpgradeCost = 140,
		Damage = 44, Range = 142, FireRate = 0.84, Chain = 4,
		Kind = "Lightning", BaseCol = Color3.fromRGB(142, 72, 212), TopCol = Color3.fromRGB(214, 192, 62),
		Accent = Color3.fromRGB(112, 204, 228), Desc = "Sét chuỗi giật lan 4 mục tiêu liên tiếp"
	},
	{
		Id = "laser", Name = "Laze Thần", Cost = 240, UpgradeCost = 205,
		Damage = 116, Range = 168, FireRate = 1.02,
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
	{ Id = "easy",   Name = "Dễ",          Lives = 50, HpMult = 0.78, SpdMult = 0.95, StarMult = 1.0, Color = Color3.fromRGB(82, 206, 108),  Top = Color3.fromRGB(64, 196, 92),  Bot = Color3.fromRGB(28, 134, 54) },
	{ Id = "normal", Name = "Bình Thường", Lives = 30, HpMult = 1.00, SpdMult = 1.00, StarMult = 1.3, Color = Color3.fromRGB(84, 178, 228),  Top = Color3.fromRGB(54, 152, 214), Bot = Color3.fromRGB(28, 92, 164) },
	{ Id = "hard",   Name = "Khó",         Lives = 10, HpMult = 1.45, SpdMult = 1.05, StarMult = 1.8, Color = Color3.fromRGB(228, 148, 56),  Top = Color3.fromRGB(218, 94, 52),  Bot = Color3.fromRGB(154, 42, 32) },
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
	Hide3D = false,
	MapStars = { meadow = 0, desert = 0, citadel = 0, heroic_boss = 0, endless = 0 },
	StageUnlocked = { meadow = 1, desert = 1, citadel = 1, heroic_boss = 1, endless = 1 },
	SelectedStage = 1,
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
			if type(tbl.Hide3D) == "boolean" then saveState.Hide3D = tbl.Hide3D end
			if type(tbl.StageUnlocked) == "table" then for k, v in pairs(tbl.StageUnlocked) do saveState.StageUnlocked[k] = math.clamp(tonumber(v) or 1, 1, 7) end end
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

function GFX.buildObstacleSprite(parent, kind, zBase)
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
	obShad.BackgroundTransparency = 0.48
	obShad.BorderSizePixel = 0
	obShad.ZIndex = zBase
	obShad.Parent = root
	addCorner(obShad, 99)

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
-- ============================================================
-- ANH GOC 5 BAN DO NHUNG TRUC TIEP (PNG + getcustomasset)
-- ============================================================
local MAP_IMG_B64 = {
	meadow = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEUoYxrhnyZdWV8MZt4dYaNbZJug3iMjmSKdZyFgpBBgXiPk3SKhmRofLlkLpqQdmd5c4R4pWWNXoNqdn6Ocm8Zkj6Pe3FgnznAeISgmySogLJXPbBmYZVYrnVhJKKDV29xmYdVJLZteJSLbmlpX0FWvoEsd2vZSp2IZDWiYzN9iOcxj0e8VCTUky4mSapHNpqwCOctmRNao21ThKlHmUVXMuMQjElkfElvk2JVROFVjKqhLLZGtLVUAAP9nCnNVVapxcf9/AP9ePcudyqeGc9beMDdqyYyaOQj/AP9oRLv/f/////8PBy0/P78/IoSqVf/Ydo4AARHy/fP8tgKt+AMtx/z8xwKM6QX811QMt/r7qwEAAAD85VgAivwIqPuV9AUYFFEBlv0FBjH862gnuvslGWxz5QQEaFEDdlFp6v1v2QWz9v00yAf91QH98m0Eh0z8yE/R+f1Q1gRJ1/wCB0j8+tgUFS75tU0WwvxORy0EmFJ05ix0da4vtwvkmwVYOKxOxwfP+gU0KBL1p1BY5P1QQw0GhTktJlP+9jU50/2Q5vwDd2gsJXAOWDIOpywKljEGWKsQtiePiLMvqAu1VRbnm1YIp1IcFmNqVyY60gRxNioJSDIBl5F28/0GWU5sR9anmbSM2/qs6/sJdjGR9v3u/AsCh48uxlIDeIxMuAiSRSURthcFp8yIORH158wKZjEKR0oDhmuXlbPJtCgrGBSyqLLRyMZSKCb+9U8GOC0Epo4JqHE1OScrmA65rDJQOCsHmG1raq6VRBTNubUOtk2nSxJSJRcKSBJ2NBWn6QRLyvyK2ggiFllJOhE3Hog5J4tqKRXKqSQ3NRdJ10mFfLQCV+84I5E11E9q2itx1/uFPCfz17YLNxIEh6xtyQYMt3Hyly7o2MgruVJwRjTPilQIKRS8sTjLZhINWBGtVyQOZhQvhgsGR9EGaWlPZrH65boTqBP9+IsKGBFLyTH9+rATx0xoWRjoyrMKttQpGHRNLKdMqAhq51QrZQ5MhgnUx7ixHpsHAAABAHRSTlP///////7/////////+/////////////////z///+2//z0////////Ef/7/x3/////uf////9bpP//FWb/AQ8DAgK6//////8BlwIBQwRwA//+////////////AP/////+//7///7///////////////////z//v/////////////////////+//////7//////////////v/////////9///////////////////////////////////////////////////////////+/7r+////////uf////////////////////////////////////////////+3/f//////Sy8/rgAAMcdJREFUeNrFnAlAU2e690/2hYRshJ2CuGurvbZ2m+XO3Jm527eiYEAQECHBQBsWQcWkRabFCgYqULREKRpls7KVRUTKDgp1ai1WUUSRoS64FWu19arf87wnCQHBmbnLdx8hCScn5/zO/1ne5z3nGCrYzhb8Ch7+52uvv/7TT+LwmezLCcO/bMujoqJw0a5dUbvgZRRZ8DyDlckT+UP8+uuvvQg7/+0Cex7Kni04+MXXxbDqrvANGzaE/yXb9ZfeJxa16xkjb02sgStZCIHv19PCwRsLfoIjjojw+++wiIgNwPfTAgIyFW4BqBYVteG/h8wKGO4eBeq9OBXuV8GvRbmHE7S0H/miL7777vPP4Ye2L4h9990X9vYd2hffWV58Z104d+53lge7xXafstsWWZG2L0TCNCvea8H/PBnuV8Gvu0dF+EX4pfEdQn5ISloxgyVNeWvmNZ9ZJ4nYjCt9H+IsrEW8qAk6yuLTn9x3gWxpopDvf/hhEkSSdaNJzzF4d8VfWse6xZkIk5J+COGPA90u99eDfzsBR7NFRAgdAO2HH/4KNf52e75w8D7u+XuHDyx0C6xwC8Cnu8IjxkUHCRuu9A7YkSNHQkJCyCN5eMdiR4jZ/WF5FYJr44N1FevfxBxoC5nYjr19b93zERHk7S7w7Is03K+DX3OHmpnM+DAEVvr+nRAHEf8DsJNo9Avrw/PNsp51TfLKsoW/8EkhX/R5yDuoyvfvfJ4cQeJuAcItWPBiVNQ28TYGfWir+Cf/e+rIB6K3j6A0HzKSN8Do8uKvFgDcWxBw23ZsY7xNTOTq55cs4yiVSoWirk4Bxv7ov8TYbLZSYTUlRwZ6HROhOm87iGDo+wqTgloATt2xTSx6exX+E/r5iZWLMzIGMiZCtXfN32Jr15JH8mot/cezq+Abawdse4jJyMhYqBRHhO8mAhG6qBeDF1C/DhZ/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",
	desert = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEUwGGOSYlklFFxPLKCvllgiE15xXFMVEycYKQpbG3BPK5ZmNtOllIzfZR0vL7lULaybwwD/AP/btKYpJWVXM0tzPbNeYSt/f3+SPmERCTgfWwB/AP9lOsVVVf9qQdGppzPAU1XbtDDOvFbO6QP79GLdwp3///88H4hsHBhEIn9rRt5+tAGHLyS3eYP9yDT8uDP9x1H6pzH91U34mC/7tgP7d1T7xwL8uFD92AL91mcAARYBAjH8pk/RZTL7h1H8l075qgMXFlHzhi8AAAAlGWvueTD898b05cT8+pn+0jn95QiRRhPMWzRRJg6tVxRwNhKxVExWNbCIOlWwSEgoJG3TeIfxhxMCB0ezVy79+anWd3nXlgX95XL+9zHRdxDTdS2JaBbp3MX7ymr95o51Sun55bW5Y4WyXIMcFmJMOySxZRHJWEo2JItnKxTolYnx2rSkSxfDrAdyRxA4KQ7ShivzbFGvejFQNxNrlwLke3eRRiuSVg71lhVxNitJdwqIOilpZC7jiYUnJVR0NEnKaRNuWRSVeDGPtQG0ZiqHPBdUhgbRZk01FgpFGwzZh4z72IxwWyPFaoWshDPphnexdhV3ZhUsVgTmazH0x5GvWHjUlisSEzfShhP0t3KPdhGsyAL0qG5qKiwxHYQ3MxJaKTCNaSrJsQo1ZwpUVg51RSWXQ1WIqwEvRwaTVirQhnLtuY0hGVpRRw+3ZHbyl29kOM2xSzQcIlVMKqh3pAGThUbQl27pehT98hLPd0nJanZcWidQZgbPhU09cwyxdkrTpSvWpnH89lBpLEhDJ5hsQ9fSlFBPQynsyqkwJzGdgTuuhhJpiQO0ZknpqIn76ColFmtMKUp7Ue/I1wb75E+il428qQi20QLYk45gObd0dDy7c3OkvALWp4caSgKahA4SCjUAAH8pCwk6NS5GM5J2bGmyhUuxlA3WpFXauI/ie4J0VlVneAN2dEG4lSvGWhUAAFUAAP8cI2cmF240M1dVAKpcOMRVVaqsOS4oGjBGRE1ckAKs29bcAAABAHRSTlMZ/2Kl/5j/GP8VZff//wPP/wH//v8P/wL/Qf8CsgPO/////////wGD/3C2/////////////////////v7///////7/AP7////////////////+///+///+/////////////////v////7////+/////////////////////////////v////////////////////////////////7////////+//////////////////7////8///7//////////////////////36/////////////7T///////////3///////8uAv///v//////////////AwH/1v8D/AP/////HFyx0QAAKG9JREFUeNrFnAlAG9e57/GSvb3db3uXd/d73y5pGIzMIpAEAhMhDWYRMqaSLAKOBRgiyywSghiEEZupzWoMGLyBzWaMiV0cXK917Nj1kuTFTdIszdabfWmbNve2fd93zsxoJITt9+5r35eANKMzZ37z/5ZzzshMRJLEIvDXXyy/7/nko2DJ92Jiq6MazT0eEtaev2/5X+DZf7mIhxruX/680Prxxx/nfz8uGtkvaSA1DTV4I7QVe6AHSg8IQ1dSUvLFfW8lJf327XBwsHP5F8nJmty42P/nFhcXF24fb3uIaTQA+MXypKSHFsP9Kinii33Jfwyy/4NL0JSUPP9W0m9D4MCl9yUjWlzcg5WNb770xFL20ktPHDr0Evx+4qXAHmKHDh0KbXzoEN15SHgjtDsk7BH2vvRmd2UsCAN4+5Yn/VUQHLA9v08DaLEz70evfpTa008/GrCng+37YD9G+z5vQY3/r2x19JtbUL7kkvuSviGB+2XSW8nAFhdb+cRqYqT1c889B4eslhyPO4R3P/7xP/3TjwW7fZs0/Q/ao6vf30LEex6CTICDVAC2PXF7rq9eHR0dvToI6F6v+9EwdPxH92p46iEIrMeBLkKA+y36dE/uu4cQDVuIHdKTLsVzdykWNVzqUNwVTfCe+F2u5vF99xGwCGS7b19yvebZaPgY0aLfH2qs3LRpU2XAAu83Bdmzzwa/3pM9ixa8a6Zx6Iloirc6+t1cTTJkxUMI92dJy/dlZ/9aYDvUfS3uP2i5aGF2L90ef1+zRQl0j9cnJ7/1q7cB7u0HkrOzs39P2FZH2/bkauobjmT8ie1IQ70m99oQYVt9qD47ed/z4NGICHBq9rfqD5HdT2zJzf12xqp7sARqobu3oq26JwtptzXj2xrNs1EkI9/HYToi6ZcRSQ/sK8n+9RBl2xN39GbCqnuEWwS1hC2BVj07Ww2f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",
	citadel = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEWZYVvolmAjFFqZGCqfVKMpG1hnGy5wX1qZJV3qKiz1Ui/mX1P88CQlFGObXi2umRleKZalndYQCjFOLZ1uWiCnlZ01GCYnHGRmN6fEn84jLZllAGVbHmVPLZXaJE77+qHdxvw8RbZ0WtionVrEbv1iM9CXMIyeOuLaSJz/f//FjQc9PMJiRLF7Vs/UM4P/AP/GkIv///8PBzk/P788HYU/QEZ/AP9aZ6J/f/+iWd+qqv/S0k8DBSspJlQDBBYVF04rKGupibP6twG1lLpsWI5wRu38yAL+1wURFTI1NG4vJo1KKrQnGG+vd/sYI1IXGGtUNctSR4qVZfmKWPZ5Y5RRRXUAAABPN7FpOs6EaphGO2/65f2Rd6vSlvtSRq8JC0k4NY7zqwF3Zac3KLJGOY/HiPxtRtTmuf1wWa1TOeala/ttVswkG00bJWyFaqq0lcX+5AYrJDV3VfXoxf1NOxkoGzRIOyTx1/25hPrlp/2JS/A4NavIwzAtG4iVdxBnWBrHsQpNNlBFK8VVRck2M1dYU4+agrLbtPx1ZtJFKZSoiSXUpvyrisNkTI0bJIpmU3rIqghuGS5GK0iNcptaQexnViUTG4VqPOmJZc+tkywUEhuEO9FlSa9SGDCOFytQQyWPds5uCBGYgQ/8+pCTde89J8NjTHlZU67tChPSChX+/HFLKTlMBhCQCA7+8v56c7E8QoStFCn65y9KKHFTQhr660kyBApaUspmOkyJWayoWPTqBy55ZuSDWtTDmrPFpMVZUXiwWqvzFBglFWvKykbjnP46QXaXh86xlfBsFlHKFysTITxsCE2JRN2NZG6vDBmsiBPLBzPFvSbvFyoYKqlsSU+mednQp7IAAH8pF3BMG2llMbuyBy3Ee/xLQ1ZhLrqwdmvFZLT8+U0AAFUAAP8sCkwzJho4NS5QCCtxGWh7dMyJCEuYhuejTenOTKfQmgfymFVTC05VVaprJmyPag6hfai1lgvSExsJDmk/AH8pGhlVAKpJGE13EhV6dJqKGVIOyskwAAABAHRSTlP//2H//yX/////////k///8v8lm/////8c/+sC/2j/////6P//6////wL//5Wj/wH/AUIErP8C/wL/A//+//7+/v/////////+/v7+/v///v7//////wD+/v////////7//////v/+///////+///////+//////////////7///////////////7///////////////////////////////////////////////////////////////////////////+x//////////////////////////8C0////////////wMB/////////////////wP///////8E/wP/////CCLx3gAALaNJREFUeNrFnAlgG/Wd7w3hLOUq0Gvbvl57vN19e7z7mJn/387YmRnr8Mgay1bskZDHimJJDnKixLHWpMaWY9fYJgk4JjjB7Mvm2ABJCCUEEsgLj5tyLEfLWV63HAV2S7f3vd/ff0a2FCuB7vV+EN2j+czv/v1HnpqWMvnbb+LmP5554QMv+jKusHLx/SvKAw+ceSYhnF3OU7Pw8JtAO/vCF+mjQRLG6F+ZBD9YfisgLsRYkAeI72+rweHFsx/w+VhMkpTTSfV3JRLvrkxO2qjiDbrTtHLLGIbvwpaWXyyG+0XLx4AWOz3Yv44s4MZ8xqehvW+eBPfNljNdNEn5+Ia/vPi6RXKx99pXfis5eZNTfcV1P776zp8THoNx503rwX2n5UKfj+DXPF3XcFWZfBTy7W//9YL875KUXvg2BB+66p8jy0gafnwnVCMFDd/HWn6nDO47LQ/4GDT75o8bljUsKwltdscdXysngvw7kvIXCPOOO+64atk/Sxpov9dtgH2ZMXC2qzsB91+JTZOkq4HW0LBAt8w9KBCSfO1kcV++o4oSllU++y34Ln4TdAPQ3Tc9uF+0XDgQZDHtOoFWDvcvIVf9Np+Cdu4kuhdFzALud1rOHPBxlvuKy7as4XtXb7h57c1r165ds2btzXTvyc1l4r20Zu2aO+9cA1n7W4v3He6WG66+ruEq8ij8vyGmsYEHyO1qYN0zfVznw3UuWt3VOen/h7Dc5XVCcw2gy/gGzgRdDYz7osH1Yc+mV+diSDadEU+GhpKQ2VRJ0smhIdvGG51lYgxADGOAkvzAgPFPEs5ZTPZ8vuHmIEfIfqel5mcwKtezTy8TFr0zxnydTStJrq+v7+1tbg6FQv4FwbNQb29vff311690pemvXOnsnH9QIY2djR9ODOC9JVS0rE7mvoELW35W86dQnM4vd0PhrRjQSLDXEttOf7e/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",
	heroic_boss = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEUWYmOinWdgnteXqMzXoF9hX1ubbCQnYiOfmCYcKmOab1MqlWBfmSVgn6QdX5JdmlscjJ/Z39FfVxyfz9XbnR4jk9bm3JkPKSdJKaoWc9bLeBubspxQbqmS0wf57i2pz5sRBl9MdchOOiGUc5fRzmMhEWEMBjIgEVY3oCEzJpJUMqfesJ0VxflRMZVNPGJjFbHJelJlONpVVaqUyGyJW/BIHmxqav9lyWJty+IqKrhiN9GqVf8RCTw5HoY1GoYAAP9EIXh/H/9oyg1vw5T/f//HpsT///9zTMPOf52t5/zQuLD6twP92Gv5xwUDBjGP1/ru+/gVFE4EmPz05s7aw7WJeKj81goAAACT5vwAABYMpvz4qgLQ9vuy8/yUhq2KdpV1Z5Gql6u1pq5w2PwvuPzp2chzyPpOyPywl5UMC0b86S74x2n79tEmGHDjybWUhpP+5XFrWHFjO8nyuGgCivhOqBMStPvKp5H95Avs1bdSR2vVyMbxuFNruAnFq6orJA1uuPZ2datzdpGJyvUaFWRMLK/HiAvNmG8TdzVKuPtwRuYrJm+VlbA2xP2Ca5PSpnEbFBqmiZBQRlEyNTVpWi7Opg762Sv4x092WEr5xjD++G0shysrqvlva6V0xAbE6/txZXR5eSszN05W0v1wVRG6hgoSFS554/21o5b55U/71k9TM7fVtZL9/bU0lSlSWIyo2/bzty/9+pBImRVVtBGxiGxUVnJuiKnW1c83JI9RZZFsW4fSl1EHd9XRmRH+9lJxlrDvp1JpQdTUqFZFOk2Y8/4WRi3txoytmFI4lxlSd5XEm4kpJ1FPZqZyZTLmuosSaaskGxDPhi4QaTS5tLPLusQROS0GZkf05bYydstQhq1uRjWydjPsly3tmFEwHIcyZpNwhpZyt9XSlS8tKy4wRkwtWC4yaLM3iBWRlpSOprbrlw4Mdo8XhDOji6nwpi4Oh3Jpqg+RdnGyiFDz2IwRVzAxRmoyd61cOcRMpi2IyAYRKFERdrFUVFNxdnOKaHLsuiMEAAABAHRSTlP////////////7///////////////////c/////////w/8////nxhb/92i//9f/wP/5QP//ycC//8DvANNeboBTAP//wL/AaP////////+///+//////8A//7////////////////////+/////v/////+///////////////////////+/v/////+/v///////////////////////////////////v/////+//////////////////7///////////3////////////+/////////////////////////v////////////////////////////////7/////////xHG7bQAANedJREFUeNrFnAlcE/e+6LMHwi6LClhb7Xba03N61ru+d/f7XoYloUkgSpjJjAaDCYkpxRgSUgkqWCM5xBZERDm0VaSUpcgiooWKCy7Vg0vd674vdau1dXm//3+SEBTPue/dez/vJ5BkMvOf7/z2/z9jOFkj8iL8vvraK6EZCzJAFvj+YsmHf8GSjzfl+zbm57NP8/8zEvrKa6/5IPzCGcX22it5iCgjD0v6cyVvRMbe+qwEjet7yW7K8CkilAV8NRiPE4wWmr8gPX3aNN+5pv2XytgjPnXNGQvyXwHrPQ0HG16Bi2FH+MOfguR9+AHxvfC9+q+XP0xDZ07Pyw99LeufRsO9mvVqaAamnyIKiUtDkpmZif/4pcov60bJ7D8v/vfn+SQzc17m2BL36Sd/QngL8l/L+mUw3ItZL4YuALVN+yQuc968F2bPfuGFL5Gs8MsXX3zx+VNi/Hws+SJIfAf6XnwZAHyupIW8D3h5YNoXR+BezPr7UIjN9CkfgbYy2St+Cg2xGZ8V38ax0L4YORa/WvcMHGgR/gRegMxLE4Eb5n3ro+Ngtldx+IiQIcGU80BxLwSZ5gVWgnFZ+TJIAvsEqTzwAt7+S1rDcHDyuHNAB5Z91Q/36iv5wBaSGfC1lDElLSUtWEa/evrlU28Gxnhq68gTlg3+jcsDur9HugO4v8l6JT90t48tM/Mj0bj3/xAka9YEnv3hebImIL5XEO9syD89yprAk/H4yZ/GI4En748LSUFOBQRT8tYsyH/1HxAcBEN+/pIlPraPpqQ/nX1wdnnqdfp/seCct+brNNZ4yyAlvwIhy4HfV4BNxG7+GvJ26L5N77Hyznu8+fPnn4mNje2JieFt2jRx4qZnZeLE996Lh33fiQfhIUFP0OET4b2A4D3hITamDWT+/FI08pkz8Df+PfxmZGhG3jlWRXG7l+Tng9I4L2a9lr8k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",
	endless = "iVBORw0KGgoAAAANSUhEUgAAAJwAAACWCAMAAAAc/REZAAADAFBMVEVkVB4uG19gK6QiEVu0ptdmc5ojDmUeV2gQCjVeYHHXLP307U0pFWwjWZRQMZCRcyObkquoWdaspCsWIt0dTtRgUeIiIikjEqFjEtPTsAx2AHZLLJ1aVKyFNbhDOC1sRMdlkImqVf////83HoUAAP+AHdeGWp2wqEMQCzo/IYRHIF9WGp5fQqZVVf9ris3Cn9DLyyvHwc0AAKozgXpHMH9/f39LhWWGfVG9weQVFlEPB20sJXELBlMEBjIyJownGm74twL6xwWVd9H61wZVRpMYGWoAABWqhvEsGY0AAABwRvH6qQBLKK7+5g5QR66OVvhnOs4UE5E1NpEXCodJN5MuF65iSpZPN65uN/KHZa/yxvwUFTKnaftIKZBuR9OudvsYGKxRKM5wWKxRJ+ojGVkzFsztuPyXZfjUpvuOSPeYe+QuCqtuJ/JSVbM1JqsrJdBwZ9AVJG6bguYzNXVLF9GScbtRBfGON/fMmftUNcsrJ+lsB/ZRNvKOGPnBiAj31/xxFvIpJBKOJvQmCZWtV/psWM+ohRQoJFeadxRIGa9rSLCLZw5QGeuuKPw3N6muN/mIa86uRvpuKM9ZVccyRZXtqf1WR8t2VuvLN/3+6yasGPwWJFY0RqdDN3NYQvLRR/yagdkWJ4o2CcqNCPrJiP3XtPlMBtAaFRrxiP1FQ1DNV/t4dxz95f45N02jfBVrN7V8fCfuZ/1uGdD0ePz0mP39+5TRePvJKf3OaPwbHMkdIcs1MvNoKbN3YrQVNI4vGOeEWbBJGZaHR9OagxREB7eDgzEWNm/vWP2LWNCvlfAmHhCLNtPsSv2HKtapiNobIrNUU5b99v5tU5kpKTTNpwo4B+VLRHRzc9qxhSTz2yZ7d+WmedFYVFZyZ40WRWswVKxBOVdXYrS0pPEAAFUyMjYUOFMYN6ZMORNoVypiWVrRmQrWxvMAAHtDKnt1ZuvMuNj+8zH8+6IWDUwYR45+gCqVhbOpDP2tpsrZ1vD99nIpF287NsVUYsZ/P7+Vkey2lg/GK9E4AAABAHRSTlP/HO5l///o/x3///+i/1j////////u/+/4/wKqDv//tf8DAZoB////WWn/G14D/////wP/hAL////+//7+/v7+///////+/v/+AP7//v///v7//v/+///+/////v/+/v///////v///////////////////v/////////////////////////+/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wP//////////wP//////4v/////////z///BP//rxr8KAAAMLtJREFUeNrFnAdAG2ea97Hj9LJJNtl6W26vl+/K14eRZgzWoEGZFUJIlkAFSwiBkBASwgghdBAJmUAQIFENtjE1hMNhKYfJujs+l3WJneLsJZd6m3LJbrK3uylbbvd7nnckECVl9+77vsdGDCPNzG/+z/M+7/O+M5qM3FW7BX9+cgdFURzHcmDsiq0uciuWtvKzG72yxKwz9g/uuAEA/iUNKGNl6Yfwc8NNFEdJJFKpVEJeP9kkGwzOi0r+olK/yJr0D6Qb4qYMAH/xkzV4GWlsN7AsEOX8XzMp7nyTUxQ5cRlc9pM0uhTcV3JvuYmlRLRHHnzwwe99j7yQXw+mllN/P5j89dnt0z//iMgvYW/609wta+H+BWXD83ok46FnsnZ8gv1Tuu34z7OsLz+RgYBSjvtTEv0rcFtyf8JyINv3Htq+49srtnfv3h/v3Zv668c//vHtP/8HtH/7t3/7hzX285/fTj7+7c3stwDc/vAjRLyfJD2bIcbbT1iIW2nG9h1ZWTvS4fauHnFvOlw63s+B7fb/IBbRDg6dlQFBiXQ/TMGhT4HN8Ay8n5VOt7nt3buW+re2HR+LDwH1GwO0C3YL0S4DddvCsjbq6S+LbFnwa/uKPbD9t7esdEutSltNFtdvk2TL+vaXvyCVsuwtf/hDAvcXuTexNHdoe5LsNxlvfs+QskfWG1mD6w1pnzF8mq3bxyb29Nff+g3KAoDPGCD/3YTSZeT+V3CqjT4k6rZjzw8+Pfl+Ukr+D2wsffohZMva8RvMzjcAXUbuH94CWdr7mx1EtgxIieQgmWtM8v/EOMnXtxO6h6gWlsv9w9yMLbl38DT9FpHtmaclVOamtn4/vyvwmr2l7xteMzmaayGNckcG1wLS/TAjF4XzPYNwz3yB4tYyFYBtSvcpcB/3bua6v9JPH46mTdLteKaFZn+R+5WM3Bt41puBvNuJ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",
	btn_play = "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",
	btn_skill = "iVBORw0KGgoAAAANSUhEUgAAANIAAABKCAMAAAD5cvpeAAADAFBMVEWxSPqMK+OWNeqHKNzFVvmkO/O6Uvo0A0v6+vxxGpAAAADLZfZsFHVyBa0HAjEzGUz7uP5wI3flmfsrJDeMCriPN9cVBEvxefoLAQl2BMV6JobwhPoxJE8uGDNMGY+uVtSFJYkwCWxtAZrp6fT5tQfNSORtJ6+QE7j6xwdKSGrqo/v81w5HCFEuBDlWVnTIyNaKFs+kSsvX1+b4qQiSRc9raIqVl62LNpWbRup6M8pSI5UbFEVOGE52dZE1E3I3NFfGOtz84hGmprjadviAG4b790mJCsb0lwRQFnW3tshpDHGKiaZLBmp3K8dvM7WFhpnJQ90XFDf86S9xGqn+w/9TCY1aJaVmZnv98zX+/c84ADgoFwDS09z59W47E4NYG6KQOKyyKc7c4ez01yr7+JD8+646N2eUJa+5Ydg2LGVSJFRCPGWwOdHHZ9g1JQQvIzZWSQx/AH+kG8WpqcPwa/n66UoqGSs5OTlFR1t6E8zHOuAlFCUwFTAyGTVKKwNWOAVZVoJxWA+QaA+WehWdorWzihminbTMqiXJujERBhQcCRo8DYM0Fi8yJDAxIjFJJXV4RciXQaurfBfOixjBvdPLy+jvyycYGBgZFB04JjpVAFVcBqpBEjtGGkhZUA1cYnd+MI1hXH20Vbevsby9wNPg3ez162kAAD8AAH8eB2UaFQAiDB05J0I4NAhADj1BPV1LQ1hVVVVcYoNhHl1kOgRrRwpiXIJ8faN/gZqXWtqdVu2RkprHVtHWctnehfnfmPvWoxz/AP/0pyAbDR8eCyoYFCQfEyQfIQEcJE4gCgAoDygvDy8pDycgECAxJzc+LUs7LEM9IIczMwA/M0c6QVw+QGNEGjxCGz1BHUFELkhALEVVTGViIltmM2Z3RLlnYBZ+exh4cih/f39xcX59g6KCTwyRWw2CfpaDfqCSiBqUhyWbli2gKbamOaerbhKpmh+knSy+riKopFq+tynQmx/AmibQyEjZ0WHiXO3hcN7omSLvtSLq20Pk2msAAAAAAAB4WqG7AAABAHRSTlP//////////v/+Af/+///+//7//v////////7//vz///7+//////////////7+/////////////v/////7//////////7///////7//v////////////////8E///////+/////////f///P/+/v/T/wL/////dwX///9Pq83//////////////y1H/4xyif7/////////Fi20A//40////f/+/////wQC//9Rx//+/z4D//7///////////7+////Af+A1j9q////MmCCP049hf8Fvf//vctxeMc//wX/////Av/////////////7/////////////////////wAAXjkyswAAEedJREFUeNrVmwd401i2x2UptoRjywQiITu2BsVEiYnthCQ27hmShUnPJJCEGmBoC0Ov09vOML338qbuzPbe+77ee++9996/751zJdmSLdkBMrvf+38QS1dXV+d3T7nXAVHesnZe8npv/+yp1dUKD66uVSSyeomKmLpGDNUOETHJer/DsXHXqd/+7I96vZcqHJTXpMdfjgSuSeHqcxD5YajmqtO1hmIN4Ti/fNFri3Tnb0US8XjLRpPWGgo5qKWOfKDKYaXNZ7pQlsP4b74ZKptSMevpp5/etw8PyM+WQiFw7JO1SJ/zvnwsUdj49rfaiNa0ramrNr2bTVsDOd9fNbS5c00P8nn+vHZ+4u2WeCH8kvcjVqRfOhWIbzzRtub8f3R03Nih60YQObjttutvu15T+aLRxXLadGXqsJPx0BvLghPt4bfpn4bArus7moDsOh975yWrlx4+xfpOtJ3v2H+2s7W1dQuotb46Ox2aa9QLMn/Wk3n4ztYlaAt2Pbu/43xziL3zJRPSpY+cCrT855qOs9DJb6/29nb/lamdyLbRSQ0u1/bXBFaf7WjeyH7ypTLSTu8vRFqG1xwHZH+ncN0HT6A+iLruWrTBQQMDlaOBgafxx4Bxhgf6zbZDlkclp8TEDUcI1PXgp8iLZz5KkP7I+/OBwrfO74dg672ubf3KlSu3rVxebdu2rWGHel22Od8Et60f3odQ+7/pC7wM7kGkj146xb69Zj/E5fG29aBVdYRlyNqi3bDeuNF8+/oq2Q9Zfdl0+J3v1LPFdGfzVmTaEC9c9L4CSK9474i8CUStnZ5V64nVa4abHaTVqebvl/Q62WyxYHgYJnn4iB88si8eefjMGcylSPxER+sWf5M+51D09dvN41ytPEvq5IE/+KP2QlnYST+39gGqtlXfZpDJV3jce4n6nPeJxMYmKAzUqrZVK1caRM2GP5re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",
	btn_bag = "iVBORw0KGgoAAAANSUhEUgAAANIAAABKCAMAAAD5cvpeAAADAFBMVEX6lQn6iwn8tw38xhL7pwz82CzvdgkAAADUZRJUNw/qaQbMWRM5JA8uGQf7rCr5+vkRAwGWVhinRQuoNAT+9GgsBgByDAD6szFPKAePOQlvOAvUuTmTRQuxWBLnXABwRglMFQBvKQT5ySdwFgD850/o6OnQhxbUdg/95jNNCwDylzLyhyi1t7XW1tasZw/Jycl4eHb60xn8skJYVlMXEw+ydxOnqKYsKSU5NzSTZhH862tsaWfWmBnZwzyXl5ZHOi7TmCb73EZKSUfOqTCIh4XOiCVmVTbueSCHKQb+8zT99Y88MRJORDV5VQn98VP9+687OwCRWCLVvEGzdyg9AAAxJRT+5RspGQovJQ9mYlu8wb7+/c8OBwITCQOKRCKYdRWziSja2+E0KBJbQhBySCOtZyS5iRi0lSrd4uLyx0soGgs8OjxiWlSEhXzOZifi4twcHAAZFAkmGAMrGwgoKAA1KBY7JRJVAABJMxdJOShzVi2hpZzNeSfCwbsZFAFOOShaVjt/AABrPCN8foGSYymDfHusWia3lguhnJzCvrzbwUD/AADwmkX6rEbg3dwZEwQpGAQuJw87KyA5KyE1Mxk9RDxIKgtCLSNINBtENyVGRDVVVQB7YQ9/f3+eoqG8vcG7wcDGTw/Mo07h3eD87YUbCwUaFgknFQMgHyEuLi4tLSE9MRo/NSI7Oyk8PkA7QUNCJA5AJg9IJCRLNR9ANRxGOitDMyFaSDpVVVVeVURfZl5cYWB/Pz9tXkphXGF5YiV/gXufgBefiEeen6CfpZymLwLWvBnAvsTey2Df4NjoxWb/0Wr//wD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABjzX2CAAABAHRSTlP///////7/AP/+//7+/v////7+///////+/v7+/v7//v7+/v///////////////v////////7////+///////9/////P//Vv/////+/f7//wT///8EVf+vNf///y1M/v3+/5L7////+///jgf/////CVEzaga00QPOrP////8tzFYC////////////Af///3NYbT65Nv/O/66OVQP7Av////3///+Vidn/C1XVNGL//5qmB1FzU3GqA1n//wRW/////f////////////8BAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALyUaGwAAD2ZJREFUeNrVm4dj2ki+xyUsirAEEomCkOUIgQFjU+wYMASvSVze+hJ7N1mnb9qlJ9t77+V292737l2/e9fvXrt7vffey//0fr8ZCSRAmMTxS+4bB9BoNJrP/H7zmwJigm4doW/P/Py7b7/99q/0SLg9qUTCjujFv/3L7x7Huj7WhcC4jo59H3KcfOXPX4GK8HdDhqFp/M6p9dYrtzp26IOEZ45/rdWCmnzvwsXry8vLY6hlW2O3q08++eSBBx5oHz7glit1UDGPjD3SVid1+Xq1sWHw/Lf/9Fww+P3+SH8RDN76mqDy37s+5p9E+e9rkRqmrjcu8+ql33Zaqo30v2ChV3jV+McxzMlxDIsK2AqDAn0V7qhPWsBb4aHV93KWYThfyu8fuwCu/R2w1Ds9Vnr6O+Bw11P+OMf03G5vW/1THeqf2ntx/wK608IeV9qoLMulUssXDL71J91W+mLwVou/fOGm38dYBmGZSCRuK2Ir7pI70fFxH6hzUcROIa/7OgeOLJF9HVkFWyWRou1SO1dMTbGk5QMBhksty/yV1pddSEeCL6zzxrI/xbCQLcDEU/6JiYmHqHbfn9q//+DNCKlugOXiVf5y6zeCx9pIv4ZEG2MpDvsOGz844dR9GiYmoWq7d0+kwKvQpeLXtMv8l4PPW0iPPf27QBQnRBbQftIQ8KFTxuzs7MjWmh0ZLt9dUAq5HkIoNEQka1x++WzwJYJ05J1TLbBRHGJcgElBpt2HDj388MOHdu9vE83+v9XzNuWffOihiThxrkhVu3wJHI463lvQjwgsB11o/6GHH30UiA4B0STlGbmPhVBQdxaYSjx/ilopeJznr1lEkxP7AehRBAKig4Ro5L7W7CxAYVgDpgb/C4gQiHSYb8SxHzEwIu/uIkqN3P8CqBT6HrNq8L8aPMI8H7wEbofuyKQmJydILwIgm+iXAQm8z+9D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",
	btn_quest = "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",
	btn_settings = "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",
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
local function getMapImageAsset(mapId)
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
	local fname = "ThuThanh2D_Map_" .. tostring(mapId) .. "_v60.png"
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
	addGradient(top, Color3.fromRGB(58, 46, 112), Color3.fromRGB(20, 22, 46), 90)
	add3DGloss(top, 10, 11, 0.84)

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
	-- O Dot Quai 3D dau lau + vien tim + khung chim ben trong (giong anh mau 2)
	local wavePill = Instance.new("Frame")
	wavePill.Size = UDim2.fromOffset(106, 32)
	wavePill.Position = UDim2.fromOffset(190, 4)
	wavePill.BackgroundColor3 = Color3.fromRGB(28, 26, 78)
	wavePill.BorderSizePixel = 0
	wavePill.ZIndex = 12
	wavePill.Parent = hudGroup
	addCorner(wavePill, 14)
	addStroke(wavePill, Color3.fromRGB(108, 98, 224), 2.0)
	addGradient(wavePill, Color3.fromRGB(48, 44, 118), Color3.fromRGB(20, 18, 56), 90)
	GFX.makeIcon(wavePill, "skull", 20, UDim2.new(0, 15, 0.5, 0), Vector2.new(0.5, 0.5), 13)

	local waveInner = Instance.new("Frame")
	waveInner.Size = UDim2.new(1, -32, 0, 22)
	waveInner.Position = UDim2.fromOffset(28, 5)
	waveInner.BackgroundColor3 = Color3.fromRGB(16, 14, 46)
	waveInner.BorderSizePixel = 0
	waveInner.ZIndex = 13
	waveInner.Parent = wavePill
	addCorner(waveInner, 9)
	addStroke(waveInner, Color3.fromRGB(58, 54, 134), 1.2)

	local wLbl = Instance.new("TextLabel")
	wLbl.Size = UDim2.fromScale(1, 1)
	wLbl.BackgroundTransparency = 1
	wLbl.RichText = true
	wLbl.Text = '<font color="#F0D23C">Đợt 0</font><font color="#E2E8F4">/12</font>'
	wLbl.TextColor3 = THEME.TextMain
	wLbl.Font = THEME.FontHead
	wLbl.TextSize = 11
	wLbl.ZIndex = 14
	wLbl.Parent = waveInner
	addTextOutline(wLbl, 1.4, THEME.Outline)
	UI.waveLbl = wLbl

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

	local playBtn = makeLobbyImgBtn("btn_play", "CHƠI NGAY", UDim2.fromOffset(140, 50), UDim2.new(0.5, -356, 1, -66), Color3.fromRGB(48, 224, 92), Color3.fromRGB(16, 154, 56), "play", nil)
	UI.playBtn = playBtn

	local permBtn, permLbl, permIsImg = makeLobbyImgBtn("btn_skill", "KỸ NĂNG", UDim2.fromOffset(140, 50), UDim2.new(0.5, -208, 1, -66), Color3.fromRGB(186, 68, 232), Color3.fromRGB(118, 28, 188), "star", Color3.fromRGB(196, 134, 24))
	UI.permUpgBtn = permBtn
	UI.permUpgLbl = permLbl
	UI.permIsImg  = permIsImg

	local bagBtn, bagLbl = makeLobbyImgBtn("btn_bag", "KHO ĐỒ", UDim2.fromOffset(132, 50), UDim2.new(0.5, -60, 1, -66), Color3.fromRGB(242, 192, 36), Color3.fromRGB(218, 116, 18), "chest", nil)
	UI.bagBtn = bagBtn
	UI.bagLbl = bagLbl

	local qBtn, qLbl, qIsImg = makeLobbyImgBtn("btn_quest", "NHIỆM VỤ", UDim2.fromOffset(138, 50), UDim2.new(0.5, 80, 1, -66), Color3.fromRGB(244, 206, 42), Color3.fromRGB(222, 132, 18), "star5", Color3.fromRGB(214, 52, 58))
	UI.questBtn = qBtn
	UI.questLbl = qLbl
	UI.qIsImg   = qIsImg

	local setBtn = makeLobbyImgBtn("btn_settings", "CÀI ĐẶT", UDim2.fromOffset(130, 50), UDim2.new(0.5, 226, 1, -66), Color3.fromRGB(118, 146, 218), Color3.fromRGB(68, 86, 158), "gear", nil)
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
	pmLay.Padding = UDim.new(0, 8)
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

	UI.endReplayBtn = makeArcadeBtn(endCard, "CHƠI LẠI NGAY", UDim2.fromOffset(162, 38), UDim2.fromOffset(18, 234), Color3.fromRGB(64, 198, 86), Color3.fromRGB(28, 136, 52), 10, { TextSize = 12, ZIndex = 47, Depth = 4 })
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
		if q.Id == qId and not q.Claimed then
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

local function updateHUD()
	local curL, maxL = math.max(0, TD.lives), math.max(1, TD.maxLives)
	UI.livesLbl.Text = tostring(curL) .. "/" .. tostring(maxL)
	if UI.livesBarFill then UI.livesBarFill.Size = UDim2.fromScale(math.clamp(curL / maxL, 0, 1), 1) end
	UI.goldLbl.Text  = formatNum(TD.gold)
	UI.waveLbl.Text  = TD.map.Endless and ('<font color="#F0D23C">Đợt ' .. tostring(TD.wave) .. '</font><font color="#E2E8F4"> ∞</font>') or ('<font color="#F0D23C">Đợt ' .. tostring(TD.wave) .. '</font><font color="#E2E8F4">/' .. tostring(TD.map.Waves) .. '</font>')
	UI.spdLbl.Text   = tostring(TD.speedMult) .. "x"

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
		if not (TD.pendingCell and TD.previewTowerIdx) then
			UI.rangeRing.Visible = false
		end
		if TD.pendingCell then
			UI.botInfoLbl.Text = "Chạm 1 lần để xem tầm bắn  •  Chạm lần 2 để xây tháp"
		else
			UI.botInfoLbl.Text = getNextWavePreviewText()
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
	local diffMult = (getDiffDef(saveState.Difficulty).StarMult or 1)
	local matchStars = 0
	if won then
		saveState.Wins[mid] = (saveState.Wins[mid] or 0) + 1
		local ratio = TD.lives / math.max(1, TD.maxLives)
		local earnedS = (ratio >= 0.99) and 3 or ((ratio >= 0.5) and 2 or 1)
		if earnedS > (saveState.MapStars[mid] or 0) then saveState.MapStars[mid] = earnedS end
		matchStars = math.floor((12 + (TD.stage or 1) * 3) * diffMult + 0.5)
		saveState.Stars += matchStars
		if (not TD.map.Endless) and (TD.stage or 1) < 7 then
			local nextSt = (TD.stage or 1) + 1
			if nextSt > (saveState.StageUnlocked[mid] or 1) then
				saveState.StageUnlocked[mid] = nextSt
			end
			saveState.SelectedStage = nextSt
		end
		addQuestProg("win", 1)
	elseif TD.wave > 0 then
		matchStars = math.max(2, math.floor(TD.wave * 2 * diffMult + 0.5))
		saveState.Stars += matchStars
	end
	saveData()
	UI.endTitle.Text = won and (TD.map.Endless and "CHIẾN THẮNG!" or ("VƯỢT ẢI " .. tostring(TD.stage or 1) .. "/7!")) or "THẤT THỦ!"
	UI.endTitle.TextColor3 = won and THEME.TextGold or THEME.TextRed
	UI.endStroke.Color = won and THEME.TextGold or THEME.TextRed
	local mvpName, mvpDmg = "Chưa có", 0
	for k, v in pairs(TD.dmgByTower) do if v > mvpDmg then mvpDmg = math.floor(v) mvpName = k end end
	local dfName = getDiffDef(saveState.Difficulty).Name
	local stTag = TD.map.Endless and "" or (" • Ải " .. tostring(TD.stage or 1) .. "/7")
	UI.endDesc.Text = string.format("%s%s (%s) • Thưởng: +%d Sao\nĐợt %d • Hạ: %d • MVP: %s (%s ST)", TD.map.Name, stTag, dfName, matchStars, TD.wave, TD.kills, mvpName, formatNum(mvpDmg))
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
		BuffDmg = def.BuffDmg or 0, BuffRate = def.BuffRate or 0,
		Cooldown = 0, StunTimer = 0, Node = holder, Turret = turret, Barrel = barrel, LvTag = lvTag,
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
	local diffDef = getDiffDef(saveState.Difficulty)
	local stageMult = 1 + ((TD.stage or 1) - 1) * 0.16
	local scaleHP = (1 + (TD.wave - 1) * 0.20) * stageMult * (diffDef.HpMult or 1.0)
	local isElite = (TD.wave >= 15 and not def.Boss and math.random(1, 4) == 1)
	local maxHp = math.max(10, math.floor(def.HP * scaleHP * (isElite and 1.65 or 1.0)))
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
	local maxU = math.clamp(saveState.StageUnlocked[TD.map.Id] or 1, 1, 7)
	TD.stage = TD.map.Endless and 1 or math.clamp(saveState.SelectedStage or 1, 1, maxU)
	local diffDef = getDiffDef(saveState.Difficulty)
	TD.gold = TD.map.StartGold + (TD.stage - 1) * 35 + (saveState.Upgrades.gold or 0) * 40
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
	if UI.bossWarn then UI.bossWarn.Visible = false end
	TD.weatherTimer = 0.7
	TD.smokeTimer = 0.7
	TD.fxCount = 0
	TD.previewCacheKey = nil
	TD.lastDmgUi = 0
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
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "CÂY KỸ NĂNG  •  " .. formatNum(saveState.Stars) .. " Sao"
	local tabRow = Instance.new("Frame")
	tabRow.Size = UDim2.new(1, 0, 0, 32)
	tabRow.BackgroundTransparency = 1
	tabRow.ZIndex = 53
	tabRow.Parent = UI.pmList
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
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
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

-- Bang chon Ai (7 Man moi ban do) + 3 nut Cap Do nam ngang gon (bam vao la vo tran luon)
UI.openDiffModal = function(mp)
	for _, ch in ipairs(UI.pmList:GetChildren()) do
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = mp.Name .. (mp.Endless and "  •  CHỌN CẤP ĐỘ" or "  •  CHỌN ẢI & CẤP ĐỘ")

	local maxUnlocked = math.clamp(saveState.StageUnlocked[mp.Id] or 1, 1, 7)
	if (saveState.SelectedStage or 1) > maxUnlocked then saveState.SelectedStage = maxUnlocked end

	if not mp.Endless then
		local stCard = Instance.new("Frame")
		stCard.Size = UDim2.new(1, 0, 0, 108)
		stCard.BackgroundColor3 = Color3.fromRGB(24, 28, 54)
		stCard.BorderSizePixel = 0
		stCard.ZIndex = 53
		stCard.Parent = UI.pmList
		addCorner(stCard, 12)
		addStroke(stCard, Color3.fromRGB(78, 88, 142), 1.6)

		local stTitle = Instance.new("TextLabel")
		stTitle.Size = UDim2.new(1, -20, 0, 22)
		stTitle.Position = UDim2.fromOffset(10, 6)
		stTitle.BackgroundTransparency = 1
		stTitle.Text = "CHỌN MÀN CHƠI (7 ẢI • THẮNG MỖI ẢI ĐƯỢC CỘNG SAO)"
		stTitle.TextColor3 = THEME.TextGold
		stTitle.Font = THEME.FontHead
		stTitle.TextSize = 11
		stTitle.TextXAlignment = Enum.TextXAlignment.Left
		stTitle.ZIndex = 54
		stTitle.Parent = stCard

		local stGrid = Instance.new("Frame")
		stGrid.Size = UDim2.new(1, -16, 0, 64)
		stGrid.Position = UDim2.fromOffset(8, 34)
		stGrid.BackgroundTransparency = 1
		stGrid.ZIndex = 54
		stGrid.Parent = stCard

		for sIdx = 1, 7 do
			local unlocked = (sIdx <= maxUnlocked)
			local picked = (saveState.SelectedStage == sIdx)
			local c1 = picked and Color3.fromRGB(224, 174, 48) or (unlocked and Color3.fromRGB(62, 134, 206) or Color3.fromRGB(48, 52, 78))
			local c2 = picked and Color3.fromRGB(164, 104, 18) or (unlocked and Color3.fromRGB(34, 78, 152) or Color3.fromRGB(30, 34, 54))
			local sBtn = makeArcadeBtn(
				stGrid, unlocked and ("Ải " .. tostring(sIdx)) or ("Khóa"),
				UDim2.fromOffset(58, 48), UDim2.fromOffset((sIdx - 1) * 63, 6),
				c1, c2, 9, { TextSize = 11, ZIndex = 55, Depth = 3, Stroke = picked and 2.4 or 1.6 }
			)
			sBtn.MouseButton1Click:Connect(function()
				if not unlocked then
					showToast("Vượt Ải " .. tostring(sIdx - 1) .. " để mở khóa Ải " .. tostring(sIdx) .. "!", THEME.TextRed, 1.8)
					return
				end
				saveState.SelectedStage = sIdx
				UI.openDiffModal(mp)
			end)
		end
	end

	-- Hang ngang nho 3 nut Cap Do (De | Binh Thuong | Kho) -> bam vao la vo tran ngay
	local dWrap = Instance.new("Frame")
	dWrap.Size = UDim2.new(1, 0, 0, 96)
	dWrap.BackgroundColor3 = Color3.fromRGB(24, 28, 54)
	dWrap.BorderSizePixel = 0
	dWrap.ZIndex = 53
	dWrap.Parent = UI.pmList
	addCorner(dWrap, 12)
	addStroke(dWrap, Color3.fromRGB(78, 88, 142), 1.6)

	local dTitle = Instance.new("TextLabel")
	dTitle.Size = UDim2.new(1, -20, 0, 22)
	dTitle.Position = UDim2.fromOffset(10, 6)
	dTitle.BackgroundTransparency = 1
	dTitle.Text = "CHỌN CẤP ĐỘ ĐỂ VÀO TRẬN NGAY"
	dTitle.TextColor3 = THEME.TextCyan
	dTitle.Font = THEME.FontHead
	dTitle.TextSize = 11
	dTitle.TextXAlignment = Enum.TextXAlignment.Left
	dTitle.ZIndex = 54
	dTitle.Parent = dWrap

	for dIdx, df in ipairs(DIFFICULTIES) do
		local dBtn = makeArcadeBtn(
			dWrap, df.Name,
			UDim2.fromOffset(138, 48), UDim2.fromOffset(12 + (dIdx - 1) * 146, 36),
			df.Top, df.Bot, 11, { TextSize = 13, ZIndex = 55, Depth = 4, Stroke = 2.0 }
		)
		dBtn.MouseButton1Click:Connect(function()
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
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
	end
	UI.pmTitle.Text = "CÀI ĐẶT GAME"
	local function addToggleOpt(titleTxt, descTxt, isOn, onClick)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 50)
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
	volRow.Size = UDim2.new(1, 0, 0, 52)
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
		if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then ch:Destroy() end
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

		local cancelB = makeArcadeBtn(box, "HỦY", UDim2.fromOffset(146, 38), UDim2.new(0.5, -156, 0, 92), Color3.fromRGB(78, 92, 134), Color3.fromRGB(48, 56, 86), 9, { TextSize = 13, ZIndex = 62, Depth = 3 })
		local okB     = makeArcadeBtn(box, "ĐỒNG Ý", UDim2.fromOffset(146, 38), UDim2.new(0.5, 10, 0, 92), Color3.fromRGB(214, 62, 68), Color3.fromRGB(152, 28, 36), 9, { TextSize = 13, ZIndex = 62, Depth = 3 })
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

UI.closeBtn.MouseButton1Click:Connect(openExitConfirm)

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
			if e.SprintTimer and e.SprintTimer > 0 then
				e.SprintTimer = math.max(0, e.SprintTimer - dt)
			end
			if e.Def.Boss then
				e.SkillCd -= dt
				if e.SkillCd <= 0 then
					e.SkillCd = 8.5
					if e.Def.HeroBoss then
						local heal = math.floor(e.MaxHP * 0.04)
						e.HP = math.min(e.MaxHP, e.HP + heal)
						e.HpFill.Size = UDim2.fromScale(math.clamp(e.HP / e.MaxHP, 0, 1), 1)
						spawnExplosionRing(e.X, e.Y, 44, Color3.fromRGB(186, 86, 232))
						spawnFloatingText(e.X, e.Y, "+" .. formatNum(heal) .. " HP", THEME.TextPurple)
					else
						local roll = math.random(1, 3)
						if roll == 1 then
							-- Trieu hoi 2 quai con tai vi tri Boss
							spawnExplosionRing(e.X, e.Y, 42, Color3.fromRGB(178, 82, 224))
							spawnFloatingText(e.X, e.Y - 12, "TRIỆU HỒI!", THEME.TextPurple)
							for sIdx = 1, 2 do
								local sub = spawnEnemy((sIdx == 1) and "goblin" or "spider")
								if sub then
									sub.X = e.X + math.random(-8, 8)
									sub.Y = e.Y + math.random(-8, 8)
									sub.WpIdx = e.WpIdx
									sub.Progress = e.Progress
									sub.Node.Position = UDim2.fromOffset(sub.X, sub.Y)
								end
							end
						elseif roll == 2 then
							-- Tang toc doan ngan
							e.SprintTimer = 2.0
							spawnExplosionRing(e.X, e.Y, 36, THEME.TextRed)
							spawnFloatingText(e.X, e.Y - 12, "TĂNG TỐC!", THEME.TextRed)
						else
							-- Lam choang 1 thap gan nhat trong 2 giay
							local nearT, bestD = nil, 155
							for _, tw in ipairs(TD.towers) do
								local dd = math.sqrt((tw.X - e.X)^2 + (tw.Y - e.Y)^2)
								if dd < bestD then bestD = dd nearT = tw end
							end
							if nearT then
								nearT.StunTimer = 1.6
								spawnBeam(e.X, e.Y, nearT.X, nearT.Y, Color3.fromRGB(186, 86, 232), 4, 0.25)
								spawnExplosionRing(nearT.X, nearT.Y, 26, Color3.fromRGB(186, 86, 232))
								spawnFloatingText(nearT.X, nearT.Y - 10, "CHOÁNG!", THEME.TextPurple)
							else
								e.SprintTimer = 1.8
							end
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
		if t.StunTimer and t.StunTimer > 0 then
			t.StunTimer = math.max(0, t.StunTimer - dt)
			if t.StunBadge then t.StunBadge.Visible = (t.StunTimer > 0) end
			if t.StunTimer > 0 then continue end
		elseif t.StunBadge and t.StunBadge.Visible then
			t.StunBadge.Visible = false
		end
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
			local bonus = 35 + TD.wave * 10
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
	warn("[ThuThanh2D v6.1 ERROR]: " .. tostring(_err))
end
