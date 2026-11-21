-- ============================================================
-- THU THANH 2D (TOWER DEFENSE) v2.0 - DO HOA CHI TIET 5 THAP + 6 QUAI + CONG XOAY + THANH TRI + HOAT ANH
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
}

local TOWERS = {
	{
		Id = "archer", Name = "Cung Thủ", Cost = 60, UpgradeCost = 55,
		Damage = 22, Range = 128, FireRate = 0.55, ProjSpeed = 420,
		Kind = "Arrow", BaseCol = Color3.fromRGB(64, 176, 92), TopCol = Color3.fromRGB(168, 118, 56),
		Accent = Color3.fromRGB(214, 186, 86), Desc = "Bắn nhanh, tầm trung"
	},
	{
		Id = "cannon", Name = "Đại Bác", Cost = 110, UpgradeCost = 95,
		Damage = 58, Range = 118, FireRate = 1.35, ProjSpeed = 280, Splash = 62,
		Kind = "Bomb", BaseCol = Color3.fromRGB(196, 82, 54), TopCol = Color3.fromRGB(58, 62, 76),
		Accent = Color3.fromRGB(218, 128, 48), Desc = "Nổ diện rộng sát thương lớn"
	},
	{
		Id = "frost", Name = "Băng Giá", Cost = 100, UpgradeCost = 85,
		Damage = 18, Range = 124, FireRate = 0.85, ProjSpeed = 340, Slow = 0.45, SlowDur = 2.4,
		Kind = "Frost", BaseCol = Color3.fromRGB(54, 152, 212), TopCol = Color3.fromRGB(132, 206, 224),
		Accent = Color3.fromRGB(182, 222, 232), Desc = "Làm chậm quái 45%"
	},
	{
		Id = "tesla", Name = "Lôi Điện", Cost = 160, UpgradeCost = 140,
		Damage = 36, Range = 136, FireRate = 0.95, Chain = 3,
		Kind = "Lightning", BaseCol = Color3.fromRGB(142, 72, 212), TopCol = Color3.fromRGB(214, 192, 62),
		Accent = Color3.fromRGB(112, 204, 228), Desc = "Sét lan 3 mục tiêu"
	},
	{
		Id = "laser", Name = "Laze Thần", Cost = 240, UpgradeCost = 210,
		Damage = 95, Range = 185, FireRate = 1.05,
		Kind = "Laser", BaseCol = Color3.fromRGB(204, 58, 118), TopCol = Color3.fromRGB(224, 184, 54),
		Accent = Color3.fromRGB(228, 92, 168), Desc = "Tia laze tầm xa cực mạnh"
	},
}

local ENEMIES = {
	slime  = { Name = "Slime Xanh",    HP = 65,   Speed = 54, Reward = 12, Size = 22, Color = Color3.fromRGB(72, 198, 96),  Eye = Color3.fromRGB(20, 26, 22), Damage = 1 },
	goblin = { Name = "Yêu Tinh Nhanh",HP = 48,   Speed = 88, Reward = 14, Size = 20, Color = Color3.fromRGB(214, 156, 48), Eye = Color3.fromRGB(196, 46, 46), Damage = 1 },
	knight = { Name = "Hiệp Sĩ Giáp",  HP = 185,  Speed = 40, Reward = 24, Size = 26, Color = Color3.fromRGB(122, 136, 162),Eye = Color3.fromRGB(76, 188, 216), Damage = 2 },
	wraith = { Name = "Ma Bóng Đêm",   HP = 120,  Speed = 72, Reward = 22, Size = 24, Color = Color3.fromRGB(148, 86, 212), Eye = Color3.fromRGB(220, 212, 228), Alpha = 0.25, Damage = 2 },
	golem  = { Name = "Khổng Lồ Đá",   HP = 420,  Speed = 30, Reward = 45, Size = 30, Color = Color3.fromRGB(156, 88, 62),  Eye = Color3.fromRGB(224, 182, 52), Damage = 3 },
	boss   = { Name = "Rồng Hắc Ám",   HP = 1250, Speed = 34, Reward = 150,Size = 36, Color = Color3.fromRGB(198, 42, 66),  Eye = Color3.fromRGB(232, 196, 56), Boss = true, Damage = 5 },
}

-- ============================================================
-- LUU & TAI KY LUC TU DONG
-- ============================================================
local canWriteFile = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local saveState = {
	BestWave = { meadow = 0, desert = 0, citadel = 0 },
	Wins = { meadow = 0, desert = 0, citadel = 0 },
	TotalKills = 0,
	SelectedMap = 1,
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
			if type(tbl.SelectedMap) == "number" then saveState.SelectedMap = math.clamp(tbl.SelectedMap, 1, #MAPS) end
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
	elseif kind == "boss" then
		-- Doi canh rong do-den dap nhip nhang + vuong mien vang
		wingL = Instance.new("Frame")
		wingL.Size = UDim2.fromScale(0.58, 0.44)
		wingL.Position = UDim2.fromScale(-0.22, 0.42)
		wingL.AnchorPoint = Vector2.new(0.5, 0.5)
		wingL.Rotation = -18
		wingL.BackgroundColor3 = Color3.fromRGB(154, 28, 46)
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
		wingR.BackgroundColor3 = Color3.fromRGB(154, 28, 46)
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

	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromOffset(172, 46)
	title.Position = UDim2.fromOffset(12, 0)
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
	hudGroup.Position = UDim2.fromOffset(178, 4)
	hudGroup.BackgroundTransparency = 1
	hudGroup.Visible = false
	hudGroup.ZIndex = 11
	hudGroup.Parent = top
	UI.hudGroup = hudGroup

	local function makeStatPill(x, w, strokeCol, txtCol, initTxt)
		local p = Instance.new("Frame")
		p.Size = UDim2.fromOffset(w, 32)
		p.Position = UDim2.fromOffset(x, 4)
		p.BackgroundColor3 = Color3.fromRGB(16, 18, 36)
		p.BorderSizePixel = 0
		p.ZIndex = 12
		p.Parent = hudGroup
		addCorner(p, 10)
		addStroke(p, strokeCol, 1.6)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.fromScale(1, 1)
		l.BackgroundTransparency = 1
		l.Text = initTxt
		l.TextColor3 = txtCol
		l.Font = THEME.FontHead
		l.TextSize = 12
		l.ZIndex = 13
		l.Parent = p
		addTextOutline(l, 1.3, THEME.Outline)
		return l
	end

	UI.livesLbl = makeStatPill(0,   88,  Color3.fromRGB(196, 68, 76),  THEME.TextRed,  "Máu: 20")
	UI.goldLbl  = makeStatPill(94,  112, Color3.fromRGB(186, 146, 42), THEME.TextGold, "Vàng: 240")
	UI.waveLbl  = makeStatPill(212, 106, Color3.fromRGB(72, 158, 206), THEME.TextCyan, "Đợt: 0/12")

	local spdBtn, spdLbl = makeArcadeBtn(
		hudGroup, "1x",
		UDim2.fromOffset(46, 32), UDim2.fromOffset(324, 4),
		Color3.fromRGB(56, 148, 212), Color3.fromRGB(32, 86, 174), 9,
		{ TextSize = 12, ZIndex = 12, Depth = 3, Stroke = 1.6 }
	)
	UI.spdBtn = spdBtn
	UI.spdLbl = spdLbl

	local pauseBtn, pauseLbl = makeArcadeBtn(
		hudGroup, "II",
		UDim2.fromOffset(46, 32), UDim2.fromOffset(376, 4),
		Color3.fromRGB(204, 144, 44), Color3.fromRGB(152, 86, 22), 9,
		{ TextSize = 12, ZIndex = 12, Depth = 3, Stroke = 1.6 }
	)
	UI.pauseBtn = pauseBtn
	UI.pauseLbl = pauseLbl

	UI.homeBtn = makeArcadeBtn(top, "Sảnh", UDim2.fromOffset(54, 32), UDim2.new(1, -140, 0, 8), Color3.fromRGB(142, 72, 208), Color3.fromRGB(88, 36, 162), 9, { TextSize = 11, ZIndex = 12, Depth = 3, Stroke = 1.6 })
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
	row.Size = UDim2.new(1, -16, 0, 244)
	row.Position = UDim2.fromOffset(8, 64)
	row.BackgroundTransparency = 1
	row.ZIndex = 4
	row.Parent = lobbyPage

	local lay = Instance.new("UIListLayout")
	lay.FillDirection = Enum.FillDirection.Horizontal
	lay.Padding = UDim.new(0, 12)
	lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lay.Parent = row

	for idx, mp in ipairs(MAPS) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.fromOffset(224, 240)
		card.BackgroundColor3 = Color3.fromRGB(24, 28, 52)
		card.Text = ""
		card.AutoButtonColor = false
		card.BorderSizePixel = 0
		card.ZIndex = 5
		card.Parent = row
		addCorner(card, 14)
		local st = addStroke(card, Color3.fromRGB(76, 86, 134), 2.2)

		-- Mini preview ban do
		local prev = Instance.new("Frame")
		prev.Size = UDim2.fromOffset(200, 108)
		prev.Position = UDim2.fromOffset(12, 12)
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
			local x1, y1 = (a[1] - 0.5) * (200 / COLS), (a[2] - 0.5) * (108 / ROWS)
			local x2, y2 = (b[1] - 0.5) * (200 / COLS), (b[2] - 0.5) * (108 / ROWS)
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
		nLbl.Position = UDim2.fromOffset(8, 128)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = mp.Name
		nLbl.TextColor3 = THEME.TextMain
		nLbl.Font = THEME.FontHead
		nLbl.TextSize = 14
		nLbl.ZIndex = 6
		nLbl.Parent = card

		local dLbl = Instance.new("TextLabel")
		dLbl.Size = UDim2.new(1, -16, 0, 18)
		dLbl.Position = UDim2.fromOffset(8, 152)
		dLbl.BackgroundTransparency = 1
		dLbl.Text = "Độ khó: " .. mp.Diff .. "  •  " .. mp.Waves .. " Đợt"
		dLbl.TextColor3 = THEME.TextCyan
		dLbl.Font = THEME.FontBody
		dLbl.TextSize = 11
		dLbl.ZIndex = 6
		dLbl.Parent = card

		local recLbl = Instance.new("TextLabel")
		recLbl.Size = UDim2.new(1, -16, 0, 38)
		recLbl.Position = UDim2.fromOffset(8, 174)
		recLbl.BackgroundTransparency = 1
		recLbl.Text = "Kỷ lục: Đợt 0/" .. mp.Waves .. "\nChiến thắng: 0 lần"
		recLbl.TextColor3 = THEME.TextGold
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
		end)
	end

	UI.playBtn = makeArcadeBtn(
		lobbyPage, "▶  BẮT ĐẦU PHÒNG THỦ",
		UDim2.fromOffset(276, 54), UDim2.new(0.5, -138, 1, -72),
		Color3.fromRGB(68, 206, 74), Color3.fromRGB(28, 144, 48), 16,
		{ TextSize = 17, ZIndex = 6, Depth = 5, Stroke = 2.6 }
	)
end
SEC.buildLobby()

local function refreshLobbyStats()
	UI.lobbyStatsLbl.Text = "Tổng quái đã tiêu diệt: " .. formatNum(saveState.TotalKills)
	for j, mc in ipairs(mapCards) do
		local id = mc.Map.Id
		mc.RecLbl.Text = string.format("Kỷ lục: Đợt %d/%d\nChiến thắng: %d lần", saveState.BestWave[id] or 0, mc.Map.Waves, saveState.Wins[id] or 0)
		mc.Stroke.Color = (j == saveState.SelectedMap) and THEME.TextGold or Color3.fromRGB(76, 86, 134)
		mc.Stroke.Thickness = (j == saveState.SelectedMap) and 3.0 or 2.2
	end
end
refreshLobbyStats()

-- ============================================================
-- XAY DUNG MAN CHOI (BAN CO 14x9 + BANG CHON 5 THAP + NANG CAP)
-- ============================================================
local towerShopBtns = {}
function SEC.buildGameUI()
	-- Ban co 560x360 ben trai
	local board = Instance.new("Frame")
	board.Size = UDim2.fromOffset(COLS * CELL, ROWS * CELL)
	board.Position = UDim2.fromOffset(0, 4)
	board.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
	board.BorderSizePixel = 0
	board.ClipsDescendants = true
	board.ZIndex = 4
	board.Parent = gamePage
	addCorner(board, 10)
	addStroke(board, Color3.fromRGB(92, 74, 168), 2.2)
	UI.board = board

	local tileLayer = Instance.new("Frame")
	tileLayer.Size = UDim2.fromScale(1, 1)
	tileLayer.BackgroundTransparency = 1
	tileLayer.ZIndex = 5
	tileLayer.Parent = board
	UI.tileLayer = tileLayer

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

	-- Bang dieu khien ben phai (156x360)
	local side = Instance.new("Frame")
	side.Size = UDim2.fromOffset(156, 360)
	side.Position = UDim2.fromOffset(568, 4)
	side.BackgroundColor3 = Color3.fromRGB(22, 26, 48)
	side.BorderSizePixel = 0
	side.ZIndex = 6
	side.Parent = gamePage
	addCorner(side, 10)
	addStroke(side, Color3.fromRGB(82, 72, 148), 1.8)
	UI.sidePanel = side

	local sideTitle = Instance.new("TextLabel")
	sideTitle.Size = UDim2.new(1, 0, 0, 22)
	sideTitle.Position = UDim2.fromOffset(0, 4)
	sideTitle.BackgroundTransparency = 1
	sideTitle.Text = "XÂY THÁP THỦ"
	sideTitle.TextColor3 = THEME.TextGold
	sideTitle.Font = THEME.FontHead
	sideTitle.TextSize = 12
	sideTitle.ZIndex = 7
	sideTitle.Parent = side

	for i, td in ipairs(TOWERS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(142, 46)
		btn.Position = UDim2.fromOffset(7, 28 + (i - 1) * 50)
		btn.BackgroundColor3 = Color3.fromRGB(30, 36, 64)
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0
		btn.ZIndex = 7
		btn.Parent = side
		addCorner(btn, 9)
		local st = addStroke(btn, Color3.fromRGB(68, 78, 122), 1.6)

		local iconBox = Instance.new("Frame")
		iconBox.Size = UDim2.fromOffset(34, 34)
		iconBox.Position = UDim2.fromOffset(6, 6)
		iconBox.BackgroundTransparency = 1
		iconBox.ZIndex = 8
		iconBox.Parent = btn
		GFX.buildTowerSprite(iconBox, td, 30, 8)

		local nm = Instance.new("TextLabel")
		nm.Size = UDim2.fromOffset(96, 18)
		nm.Position = UDim2.fromOffset(44, 5)
		nm.BackgroundTransparency = 1
		nm.Text = td.Name
		nm.TextColor3 = THEME.TextMain
		nm.Font = THEME.FontHead
		nm.TextSize = 11
		nm.TextXAlignment = Enum.TextXAlignment.Left
		nm.ZIndex = 8
		nm.Parent = btn

		local pr = Instance.new("TextLabel")
		pr.Size = UDim2.fromOffset(96, 16)
		pr.Position = UDim2.fromOffset(44, 23)
		pr.BackgroundTransparency = 1
		pr.Text = tostring(td.Cost) .. " Vàng"
		pr.TextColor3 = THEME.TextGold
		pr.Font = THEME.FontBody
		pr.TextSize = 11
		pr.TextXAlignment = Enum.TextXAlignment.Left
		pr.ZIndex = 8
		pr.Parent = btn

		towerShopBtns[i] = { Btn = btn, Stroke = st, Def = td }
	end

	-- Nut Ky nang Mua Thien Thach
	local skillBtn, skillLbl = makeArcadeBtn(
		side, "THIÊN THẠCH",
		UDim2.fromOffset(142, 34), UDim2.fromOffset(7, 282),
		Color3.fromRGB(214, 86, 48), Color3.fromRGB(156, 36, 32), 9,
		{ TextSize = 11, ZIndex = 8, Depth = 3, Stroke = 1.6 }
	)
	UI.skillBtn = skillBtn
	UI.skillLbl = skillLbl

	-- Nut Goi Dot Quai
	local waveBtn, waveBtnLbl = makeArcadeBtn(
		side, "GỌI ĐỢT 1",
		UDim2.fromOffset(142, 34), UDim2.fromOffset(7, 320),
		Color3.fromRGB(64, 194, 88), Color3.fromRGB(28, 134, 54), 9,
		{ TextSize = 12, ZIndex = 8, Depth = 3, Stroke = 1.6 }
	)
	UI.waveBtn = waveBtn
	UI.waveBtnLbl = waveBtnLbl

	-- Thanh duoi (724x36): Thong tin thap dang chon hoac Nang Cap / Ban Thap
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
	infoLbl.Size = UDim2.fromOffset(420, 36)
	infoLbl.Position = UDim2.fromOffset(12, 1)
	infoLbl.BackgroundTransparency = 1
	infoLbl.Text = "Chọn tháp bên phải rồi chạm vào ô cỏ để xây phòng thủ"
	infoLbl.TextColor3 = THEME.TextMain
	infoLbl.Font = THEME.FontBody
	infoLbl.TextSize = 12
	infoLbl.TextXAlignment = Enum.TextXAlignment.Left
	infoLbl.ZIndex = 7
	infoLbl.Parent = botBar
	UI.botInfoLbl = infoLbl

	local upgBtn, upgLbl = makeArcadeBtn(
		botBar, "NÂNG CẤP",
		UDim2.fromOffset(146, 30), UDim2.new(1, -280, 0, 4),
		Color3.fromRGB(64, 188, 96), Color3.fromRGB(28, 132, 58), 8,
		{ TextSize = 11, ZIndex = 8, Depth = 3, Stroke = 1.6 }
	)
	upgBtn.Visible = false
	UI.upgBtn = upgBtn
	UI.upgLbl = upgLbl

	local sellBtn, sellLbl = makeArcadeBtn(
		botBar, "BÁN THÁP",
		UDim2.fromOffset(120, 30), UDim2.new(1, -126, 0, 4),
		Color3.fromRGB(206, 72, 76), Color3.fromRGB(146, 34, 42), 8,
		{ TextSize = 11, ZIndex = 8, Depth = 3, Stroke = 1.6 }
	)
	sellBtn.Visible = false
	UI.sellBtn = sellBtn
	UI.sellLbl = sellLbl

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
	wave = 0,
	kills = 0,
	waveSpawning = false,
	spawnQueue = {},
	spawnTimer = 0,
	skillCd = 0,
	selectedBuildIdx = 1,
	selectedTower = nil,
	pathCells = {},
	pathPoints = {},
	towers = {},
	enemies = {},
	projectiles = {},
	shakeTime = 0,
}

local function cellCenter(gx, gy)
	return (gx - 0.5) * CELL, (gy - 0.5) * CELL
end

local function spawnFloatingText(x, y, text, col)
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

local function updateHUD()
	UI.livesLbl.Text = "Máu: " .. tostring(math.max(0, TD.lives))
	UI.goldLbl.Text  = "Vàng: " .. formatNum(TD.gold)
	UI.waveLbl.Text  = "Đợt: " .. tostring(TD.wave) .. "/" .. tostring(TD.map.Waves)
	UI.spdLbl.Text   = tostring(TD.speedMult) .. "x"

	for i, sb in ipairs(towerShopBtns) do
		local isSel = (TD.selectedBuildIdx == i) and (TD.selectedTower == nil)
		sb.Stroke.Color = isSel and THEME.TextGold or ((TD.gold >= sb.Def.Cost) and Color3.fromRGB(78, 96, 148) or Color3.fromRGB(118, 52, 58))
		sb.Stroke.Thickness = isSel and 2.4 or 1.5
	end

	if TD.selectedTower then
		local t = TD.selectedTower
		local upCost = math.floor(t.Def.UpgradeCost * t.Level)
		local sellVal = math.floor(t.Invested * 0.7)
		UI.botInfoLbl.Text = string.format("%s Cấp %d  •  Sát thương: %d  •  Tầm: %d", t.Def.Name, t.Level, math.floor(t.Damage), math.floor(t.Range))
		UI.upgBtn.Visible = (t.Level < 3)
		UI.upgLbl.Text = (t.Level < 3) and ("NÂNG CẤP (" .. upCost .. ")") or "MAX CẤP"
		UI.sellBtn.Visible = true
		UI.sellLbl.Text = "BÁN (+" .. sellVal .. ")"
		UI.rangeRing.Visible = true
		UI.rangeRing.Position = UDim2.fromOffset(t.X, t.Y)
		UI.rangeRing.Size = UDim2.fromOffset(t.Range * 2, t.Range * 2)
	else
		local bd = TOWERS[TD.selectedBuildIdx]
		UI.botInfoLbl.Text = "Đang chọn: " .. bd.Name .. " (" .. bd.Cost .. " Vàng)  •  " .. bd.Desc
		UI.upgBtn.Visible = false
		UI.sellBtn.Visible = false
		UI.rangeRing.Visible = false
	end

	if TD.skillCd > 0 then
		UI.skillLbl.Text = string.format("HỒI %.0fs", math.ceil(TD.skillCd))
	else
		UI.skillLbl.Text = "THIÊN THẠCH"
	end

	if TD.waveSpawning or #TD.enemies > 0 then
		UI.waveBtnLbl.Text = "ĐANG CHIẾN..."
	elseif TD.wave >= TD.map.Waves then
		UI.waveBtnLbl.Text = "HOÀN THÀNH"
	else
		UI.waveBtnLbl.Text = "GỌI ĐỢT " .. tostring(TD.wave + 1)
	end
end

local function clearMatchLayers()
	for _, ch in ipairs(UI.tileLayer:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.towerLayer:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.enemyLayer:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(UI.fxLayer:GetChildren()) do ch:Destroy() end
	TD.towers = {}
	TD.enemies = {}
	TD.projectiles = {}
	TD.selectedTower = nil
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
	end
	saveData()
	UI.endTitle.Text = won and "CHIẾN THẮNG!" or "THẤT THỦ!"
	UI.endTitle.TextColor3 = won and THEME.TextGold or THEME.TextRed
	UI.endStroke.Color = won and THEME.TextGold or THEME.TextRed
	UI.endDesc.Text = string.format("Bản đồ: %s\nĐạt Đợt %d/%d  •  Tiêu diệt: %d quái", TD.map.Name, TD.wave, TD.map.Waves, TD.kills)
	UI.endCard.Visible = true
	updateHUD()
end

local function getTowerAt(gx, gy)
	for _, t in ipairs(TD.towers) do
		if t.GX == gx and t.GY == gy then return t end
	end
	return nil
end

local function buildTowerAt(gx, gy)
	if TD.over or TD.paused then return end
	if TD.pathCells[gx .. "_" .. gy] then return end
	local existing = getTowerAt(gx, gy)
	if existing then
		TD.selectedTower = existing
		updateHUD()
		return
	end
	local def = TOWERS[TD.selectedBuildIdx]
	if TD.gold < def.Cost then
		showToast("Không đủ vàng để xây " .. def.Name .. "!", THEME.TextRed, 2.0)
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

	local tObj = {
		GX = gx, GY = gy, X = cx, Y = cy,
		Def = def, Level = 1, Invested = def.Cost,
		Damage = def.Damage, Range = def.Range, FireRate = def.FireRate,
		Cooldown = 0, Node = holder, Turret = turret, Barrel = barrel, LvTag = lvTag,
	}
	table.insert(TD.towers, tObj)
	holder.MouseButton1Click:Connect(function()
		TD.selectedTower = tObj
		updateHUD()
	end)
	TD.selectedTower = nil
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
			else
				tile.BackgroundColor3 = ((x + y) % 2 == 0) and mp.Grass1 or mp.Grass2
				tile.MouseButton1Click:Connect(function()
					buildTowerAt(x, y)
				end)
			end
			tile.Parent = UI.tileLayer
		end
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
	local count = 6 + waveNum * 2
	for i = 1, count do
		local kind = "slime"
		if waveNum >= 2 and i % 3 == 0 then kind = "goblin" end
		if waveNum >= 4 and i % 4 == 0 then kind = "knight" end
		if waveNum >= 6 and i % 5 == 0 then kind = "wraith" end
		if waveNum >= 8 and i % 6 == 0 then kind = "golem" end
		table.insert(q, kind)
	end
	if waveNum % 5 == 0 or waveNum == TD.map.Waves then
		table.insert(q, "boss")
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
	local scaleHP = 1 + (TD.wave - 1) * 0.24
	local maxHp = math.floor(def.HP * scaleHP)
	local p0 = TD.pathPoints[1]
	local node, body, hpFill, frostCoat, wingL, wingR = GFX.buildEnemySprite(UI.enemyLayer, def, kind, 15)
	node.Position = UDim2.fromOffset(p0.x, p0.y)
	table.insert(TD.enemies, {
		Kind = kind, Def = def, HP = maxHp, MaxHP = maxHp,
		X = p0.x, Y = p0.y, WpIdx = 2, Progress = 0,
		SlowTimer = 0, SlowFactor = 1, HitFlash = 0, BobPhase = math.random() * 6,
		Node = node, Body = body, HpFill = hpFill, FrostCoat = frostCoat,
		WingL = wingL, WingR = wingR, Dead = false
	})
end

local function damageEnemy(e, dmg, slowFrac, slowDur)
	if e.Dead then return end
	e.HP -= dmg
	e.HitFlash = 0.12
	if slowFrac and slowDur then
		e.SlowFactor = math.min(e.SlowFactor, 1 - slowFrac)
		e.SlowTimer = math.max(e.SlowTimer, slowDur)
	end
	if e.HP <= 0 then
		e.Dead = true
		TD.gold += e.Def.Reward
		TD.kills += 1
		saveState.TotalKills += 1
		spawnDeathParticles(e.X, e.Y, e.Def.Color)
		spawnFloatingText(e.X, e.Y, "+" .. tostring(e.Def.Reward) .. "V", THEME.TextGold)
		if e.Node and e.Node.Parent then e.Node:Destroy() end
		updateHUD()
	else
		e.HpFill.Size = UDim2.fromScale(math.clamp(e.HP / e.MaxHP, 0, 1), 1)
	end
end

local function fireTower(t, target)
	local ang = math.deg(math.atan2(target.Y - t.Y, target.X - t.X))
	t.Turret.Rotation = ang
	-- Hoat anh giat nong sung (Recoil)
	t.Barrel.Position = UDim2.fromScale(0.38, 0.5)
	TweenService:Create(t.Barrel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.55, 0.5)
	}):Play()

	if t.Def.Kind == "Lightning" then
		local hitSet = {}
		local curX, curY = t.X, t.Y
		local curTarget = target
		for _ = 1, (t.Def.Chain or 3) do
			if not curTarget or curTarget.Dead then break end
			hitSet[curTarget] = true
			spawnBeamLine(curX, curY, curTarget.X, curTarget.Y, THEME.TextCyan, 3.5, 0.16)
			damageEnemy(curTarget, t.Damage)
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
		spawnBeamLine(t.X, t.Y, target.X, target.Y, t.Def.Accent, 5, 0.22)
		spawnExplosionRing(target.X, target.Y, 16, t.Def.Accent)
		damageEnemy(target, t.Damage)
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
		table.insert(TD.projectiles, {
			X = t.X, Y = t.Y, Target = target, TX = target.X, TY = target.Y,
			Speed = t.Def.ProjSpeed or 320, Damage = t.Damage,
			Splash = t.Def.Splash, Slow = t.Def.Slow, SlowDur = t.Def.SlowDur,
			Color = t.Def.Accent, Node = pNode
		})
	end
end

local function startNewMatch()
	TD.map = MAPS[saveState.SelectedMap] or MAPS[1]
	TD.gold = TD.map.StartGold
	TD.lives = TD.map.StartLives
	TD.wave = 0
	TD.kills = 0
	TD.waveSpawning = false
	TD.spawnQueue = {}
	TD.skillCd = 0
	TD.over = false
	TD.paused = false
	TD.active = true
	TD.selectedBuildIdx = 1
	UI.pauseLbl.Text = "II"
	UI.endCard.Visible = false
	UI.hudGroup.Visible = true
	UI.homeBtn.Visible = true
	lobbyPage.Visible = false
	gamePage.Visible = true
	buildMapBoard(TD.map)
	updateHUD()
end

local function goLobby()
	TD.active = false
	TD.paused = false
	clearMatchLayers()
	UI.hudGroup.Visible = false
	UI.homeBtn.Visible = false
	gamePage.Visible = false
	lobbyPage.Visible = true
	refreshLobbyStats()
end

-- ============================================================
-- KET NOI NUT BAM & VONG LAP CHINH (RENDERSTEPPED)
-- ============================================================
for i, sb in ipairs(towerShopBtns) do
	sb.Btn.MouseButton1Click:Connect(function()
		TD.selectedBuildIdx = i
		TD.selectedTower = nil
		updateHUD()
	end)
end

UI.upgBtn.MouseButton1Click:Connect(function()
	local t = TD.selectedTower
	if not t or t.Level >= 3 then return end
	local cost = math.floor(t.Def.UpgradeCost * t.Level)
	if TD.gold < cost then
		showToast("Cần " .. cost .. " Vàng để nâng cấp!", THEME.TextRed, 2.0)
		return
	end
	TD.gold -= cost
	t.Invested += cost
	t.Level += 1
	t.Damage = t.Damage * 1.52
	t.Range = t.Range * 1.12
	t.FireRate = math.max(0.25, t.FireRate * 0.88)
	t.LvTag.Text = "C" .. tostring(t.Level)
	spawnExplosionRing(t.X, t.Y, 26, THEME.TextGold)
	showToast("Đã nâng " .. t.Def.Name .. " lên Cấp " .. t.Level .. "!", THEME.TextGreen, 2.0)
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
	TD.skillCd = 25
	TD.shakeTime = 0.25
	local dmg = 95 + TD.wave * 24
	for _, e in ipairs(TD.enemies) do
		if not e.Dead then
			spawnExplosionRing(e.X, e.Y, 34, Color3.fromRGB(224, 96, 48))
			damageEnemy(e, dmg)
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
	TD.speedMult = (TD.speedMult == 1) and 2 or 1
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
UI.closeBtn.MouseButton1Click:Connect(function()
	saveData()
	screenGui:Destroy()
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
		UI.board.Position = UDim2.fromOffset(math.random(-3, 3), 4 + math.random(-3, 3))
	else
		UI.board.Position = UDim2.fromOffset(0, 4)
	end

	-- Xoay vong cong quai
	if UI.portalVortex and UI.portalVortex.Parent then
		UI.portalVortex.Rotation = (UI.portalVortex.Rotation + dt * 160) % 360
	end

	-- Hoi chieu Thien Thach
	if TD.skillCd > 0 then
		local prevCeil = math.ceil(TD.skillCd)
		TD.skillCd = math.max(0, TD.skillCd - dt)
		if math.ceil(TD.skillCd) ~= prevCeil then updateHUD() end
	end

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
			else
				e.Body.BackgroundColor3 = e.Def.Color
			end
			if e.WingL and e.WingR then
				local flap = math.sin(e.BobPhase * 1.4) * 20
				e.WingL.Rotation = -18 + flap
				e.WingR.Rotation = 18 - flap
			end

			local wp = TD.pathPoints[e.WpIdx]
			if wp then
				local dx, dy = wp.x - e.X, wp.y - e.Y
				local dist = math.sqrt(dx * dx + dy * dy)
				local step = e.Def.Speed * e.SlowFactor * dt
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
				-- Quai lot vao thanh
				TD.lives -= (e.Def.Damage or 1)
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

	-- Thap tim muc tieu di xa nhat trong tam & ban
	for _, t in ipairs(TD.towers) do
		t.Cooldown = math.max(0, t.Cooldown - dt)
		local bestE, bestProg = nil, -1
		for _, e in ipairs(TD.enemies) do
			if not e.Dead then
				local d = math.sqrt((e.X - t.X)^2 + (e.Y - t.Y)^2)
				if d <= t.Range and e.Progress > bestProg then
					bestProg = e.Progress
					bestE = e
				end
			end
		end
		if bestE then
			t.Turret.Rotation = math.deg(math.atan2(bestE.Y - t.Y, bestE.X - t.X))
			if t.Cooldown <= 0 then
				t.Cooldown = t.FireRate
				fireTower(t, bestE)
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
				spawnExplosionRing(p.TX, p.TY, p.Splash, p.Color)
				for _, e in ipairs(TD.enemies) do
					if not e.Dead then
						local ed = math.sqrt((e.X - p.TX)^2 + (e.Y - p.TY)^2)
						if ed <= p.Splash then
							damageEnemy(e, p.Damage, p.Slow, p.SlowDur)
						end
					end
				end
			elseif p.Target and not p.Target.Dead then
				if p.Slow then spawnExplosionRing(p.TX, p.TY, 18, THEME.TextCyan) end
				damageEnemy(p.Target, p.Damage, p.Slow, p.SlowDur)
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

	-- Kiem tra hoan thanh dot quai
	if not TD.waveSpawning and #TD.enemies == 0 and TD.wave > 0 then
		if TD.wave >= TD.map.Waves then
			finishMatch(true)
		elseif UI.waveBtnLbl.Text == "ĐANG CHIẾN..." then
			local bonus = 30 + TD.wave * 8
			TD.gold += bonus
			showToast("Xong Đợt " .. TD.wave .. "! Thưởng +" .. bonus .. " Vàng", THEME.TextGreen, 2.2)
			updateHUD()
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
	warn("[ThuThanh2D v2.0 ERROR]: " .. tostring(_err))
end
