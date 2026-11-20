-- ============================================================
-- SNAKE ARCADE PRO v2 - TỰ ĐỘNG LƯU + FIX FULL UI MOBILE & PC
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

-- ============================================================
-- DỮ LIỆU GỐC (SKIN, ĐỒ ĂN, KỸ NĂNG, BẢNG XẾP HẠNG)
-- ============================================================
local SKINS = {
	{
		Id = "classic_green", Name = "Rắn Xanh Lá", Price = 0, Currency = "Coins",
		HeadColor = Color3.fromRGB(52, 211, 56), Body1 = Color3.fromRGB(34, 197, 54), Body2 = Color3.fromRGB(74, 222, 90),
		Accessory = nil
	},
	{
		Id = "classic_red", Name = "Rắn Đỏ Rực", Price = 100, Currency = "Coins",
		HeadColor = Color3.fromRGB(239, 55, 55), Body1 = Color3.fromRGB(220, 38, 38), Body2 = Color3.fromRGB(248, 95, 95),
		Accessory = nil
	},
	{
		Id = "classic_blue", Name = "Rắn Xanh Biển", Price = 150, Currency = "Coins",
		HeadColor = Color3.fromRGB(38, 155, 255), Body1 = Color3.fromRGB(29, 130, 235), Body2 = Color3.fromRGB(96, 185, 255),
		Accessory = nil
	},
	{
		Id = "classic_gold", Name = "Rắn Vàng Ong", Price = 200, Currency = "Coins",
		HeadColor = Color3.fromRGB(250, 204, 21), Body1 = Color3.fromRGB(234, 179, 8), Body2 = Color3.fromRGB(254, 225, 85),
		Accessory = nil
	},
	{
		Id = "classic_purple", Name = "Rắn Tím Huyền", Price = 250, Currency = "Coins",
		HeadColor = Color3.fromRGB(178, 75, 255), Body1 = Color3.fromRGB(147, 51, 234), Body2 = Color3.fromRGB(196, 118, 255),
		Accessory = nil
	},
	{
		Id = "king_snake", Name = "Vua Rắn", Price = 400, Currency = "Coins",
		HeadColor = Color3.fromRGB(46, 220, 62), Body1 = Color3.fromRGB(34, 197, 54), Body2 = Color3.fromRGB(250, 204, 21),
		Accessory = "Crown"
	},
	{
		Id = "fire_dragon", Name = "Rồng Lửa", Price = 15, Currency = "Gems",
		HeadColor = Color3.fromRGB(42, 32, 48), Body1 = Color3.fromRGB(239, 68, 25), Body2 = Color3.fromRGB(251, 146, 30),
		Accessory = "Fire"
	},
	{
		Id = "ice_dragon", Name = "Rồng Băng", Price = 20, Currency = "Gems",
		HeadColor = Color3.fromRGB(56, 198, 255), Body1 = Color3.fromRGB(14, 165, 233), Body2 = Color3.fromRGB(186, 238, 255),
		Accessory = "Ice"
	},
	{
		Id = "dj_rainbow", Name = "DJ Cầu Vồng", Price = 30, Currency = "Gems",
		HeadColor = Color3.fromRGB(236, 72, 153), Body1 = Color3.fromRGB(236, 72, 153), Body2 = Color3.fromRGB(56, 189, 248),
		Accessory = "Headphones", Rainbow = true
	},
	{
		Id = "golden_dragon", Name = "Rồng Vàng VIP", Price = 50, Currency = "Gems",
		HeadColor = Color3.fromRGB(255, 195, 20), Body1 = Color3.fromRGB(245, 158, 11), Body2 = Color3.fromRGB(255, 235, 105),
		Accessory = "GoldDragon"
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
	{ Id = "Double", Icon = "⭐", Color = Color3.fromRGB(250, 204, 21), Name = "2x Điểm" },
	{ Id = "Ghost",  Icon = "👻", Color = Color3.fromRGB(196, 181, 253), Name = "Bóng Ma" },
	{ Id = "Shield", Icon = "🛡️", Color = Color3.fromRGB(56, 189, 248), Name = "Khiên" },
	{ Id = "Magnet", Icon = "🧲", Color = Color3.fromRGB(248, 113, 113), Name = "Nam Châm" },
	{ Id = "Speed",  Icon = "⚡", Color = Color3.fromRGB(253, 224, 71), Name = "Tăng Tốc" },
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
			BombsEnabled = true,
			ShowDpad = true,
		},
		Quests = {
			{ Id = "eat",   Title = "Ăn 15 món ăn bất kỳ",     Goal = 15,  Progress = 0, Reward = 120, Currency = "Coins", Claimed = false },
			{ Id = "score", Title = "Đạt 150 điểm trong 1 ván", Goal = 150, Progress = 0, Reward = 8,   Currency = "Gems",  Claimed = false },
			{ Id = "power", Title = "Nhặt 3 vật phẩm kỹ năng",  Goal = 3,   Progress = 0, Reward = 10,  Currency = "Gems",  Claimed = false },
			{ Id = "games", Title = "Chơi hoàn thành 3 ván",    Goal = 3,   Progress = 0, Reward = 200, Currency = "Coins", Claimed = false },
		}
	}
end

local state = createDefaultState()

-- ============================================================
-- HỆ THỐNG LƯU & TẢI DỮ LIỆU TỰ ĐỘNG (FILE JSON + BỘ NHỚ RAM)
-- ============================================================
local canWriteFile = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local saveModeName = canWriteFile and "File lưu vĩnh viễn" or "Bộ nhớ tạm (RAM)"
local saveStatusLbl = nil

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
	if not saveStatusLbl then return end
	saveStatusLbl.Text = text
	saveStatusLbl.TextColor3 = color
	task.delay(1.6, function()
		if saveStatusLbl and saveStatusLbl.Parent then
			saveStatusLbl.Text = "💾 Tự động lưu"
			saveStatusLbl.TextColor3 = Color3.fromRGB(134, 239, 172)
		end
	end)
end

local function saveData()
	local payload = packSaveData()
	local okEnc, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
	if not okEnc then return false end

	-- Lớp 1: Lưu dự phòng vào bộ nhớ phiên
	local cache = getCacheRoot()
	cache["SnakeArcadePro_JSON_" .. tostring(player.UserId)] = encoded

	-- Lớp 2: Ghi ra file cứng trên máy (nếu Executor hỗ trợ)
	if canWriteFile then
		local okWrite = pcall(writefile, SAVE_FILE, encoded)
		if okWrite then
			flashSaveBadge("✔ Đã lưu file", Color3.fromRGB(74, 222, 128))
			return true
		end
	end
	flashSaveBadge("✔ Đã lưu RAM", Color3.fromRGB(125, 211, 252))
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
-- HÀM DỰNG UI HOẠT HÌNH SẮC NÉT (KHÔNG LỖI FONT / VIỀN MẢNH)
-- ============================================================
local function addCorner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(12, 15, 24)
	s.Thickness = thickness or 2
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

-- Icon đồng xu vàng tự vẽ (thay thế hoàn toàn emoji bị lỗi ô vuông)
local function makeCoinIcon(parent, sizePx, pos)
	local coin = Instance.new("Frame")
	coin.Size = UDim2.fromOffset(sizePx, sizePx)
	coin.Position = pos
	coin.AnchorPoint = Vector2.new(0, 0.5)
	coin.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
	coin.BorderSizePixel = 0
	coin.Parent = parent
	addCorner(coin, 99)
	addStroke(coin, Color3.fromRGB(161, 98, 7), 1.6)
	addGradient(coin, Color3.fromRGB(254, 240, 138), Color3.fromRGB(234, 179, 8), 90)

	local dollar = Instance.new("TextLabel")
	dollar.Size = UDim2.fromScale(1, 1)
	dollar.BackgroundTransparency = 1
	dollar.Text = "$"
	dollar.TextColor3 = Color3.fromRGB(146, 64, 14)
	dollar.Font = Enum.Font.GothamBlack
	dollar.TextSize = math.max(10, math.floor(sizePx * 0.72))
	dollar.Parent = coin
	return coin
end

local function makeGlossyBtn(parent, text, size, pos, topColor, botColor, cornerRadius)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos or UDim2.new()
	b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextStrokeColor3 = Color3.fromRGB(15, 18, 30)
	b.TextStrokeTransparency = 0.45 -- Viền mảnh giúp chữ nhỏ vẫn sáng rõ
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 14
	b.Text = text
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.Parent = parent
	addCorner(b, cornerRadius or 10)
	addStroke(b, Color3.fromRGB(15, 18, 28), 2)
	addGradient(b, topColor, botColor or topColor, 90)
	return b
end

local function makeNotifDot(parent)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(12, 12)
	dot.Position = UDim2.new(1, -14, 0, 4)
	dot.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	dot.BorderSizePixel = 0
	dot.Visible = false
	dot.ZIndex = 10
	dot.Parent = parent
	addCorner(dot, 99)
	addStroke(dot, Color3.fromRGB(255, 255, 255), 1.5)
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

-- Vẽ ĐẦU RẮN HOẠT HÌNH (mắt to, lưỡi đỏ, vương miện/lửa/băng/tai nghe)
local function buildCartoonHead(parent, sizePx, skin)
	local head = Instance.new("Frame")
	head.Size = UDim2.fromOffset(sizePx, sizePx)
	head.AnchorPoint = Vector2.new(0.5, 0.5)
	head.BackgroundColor3 = skin.HeadColor
	head.BorderSizePixel = 0
	head.ZIndex = 6
	head.Parent = parent
	addCorner(head, math.floor(sizePx * 0.48))
	addStroke(head, Color3.fromRGB(12, 14, 22), math.max(1.8, sizePx * 0.075))

	local shine = Instance.new("Frame")
	shine.Size = UDim2.fromScale(0.42, 0.22)
	shine.Position = UDim2.fromScale(0.16, 0.12)
	shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shine.BackgroundTransparency = 0.62
	shine.BorderSizePixel = 0
	shine.ZIndex = 7
	shine.Parent = head
	addCorner(shine, 99)

	local tongue = Instance.new("Frame")
	tongue.Size = UDim2.fromScale(0.36, 0.16)
	tongue.Position = UDim2.fromScale(0.92, 0.42)
	tongue.BackgroundColor3 = Color3.fromRGB(239, 45, 55)
	tongue.BorderSizePixel = 0
	tongue.ZIndex = 5
	tongue.Parent = head
	addCorner(tongue, 4)
	addStroke(tongue, Color3.fromRGB(20, 10, 12), 1.2)

	for _, yPos in ipairs({ 0.14, 0.54 }) do
		local eyeWhite = Instance.new("Frame")
		eyeWhite.Size = UDim2.fromScale(0.33, 0.33)
		eyeWhite.Position = UDim2.fromScale(0.49, yPos)
		eyeWhite.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		eyeWhite.BorderSizePixel = 0
		eyeWhite.ZIndex = 8
		eyeWhite.Parent = head
		addCorner(eyeWhite, 99)
		addStroke(eyeWhite, Color3.fromRGB(15, 15, 22), 1.2)

		local pupil = Instance.new("Frame")
		pupil.Size = UDim2.fromScale(0.6, 0.6)
		pupil.Position = UDim2.fromScale(0.28, 0.2)
		pupil.BackgroundColor3 = (skin.Id == "fire_dragon") and Color3.fromRGB(255, 110, 15) or Color3.fromRGB(22, 18, 28)
		pupil.BorderSizePixel = 0
		pupil.ZIndex = 9
		pupil.Parent = eyeWhite
		addCorner(pupil, 99)

		local glint = Instance.new("Frame")
		glint.Size = UDim2.fromScale(0.34, 0.34)
		glint.Position = UDim2.fromScale(0.15, 0.12)
		glint.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		glint.BorderSizePixel = 0
		glint.ZIndex = 10
		glint.Parent = pupil
		addCorner(glint, 99)
	end

	if skin.Accessory then
		local acc = Instance.new("TextLabel")
		acc.BackgroundTransparency = 1
		acc.Size = UDim2.fromScale(0.66, 0.66)
		acc.Position = UDim2.fromScale(-0.14, 0.17)
		acc.ZIndex = 11
		acc.TextScaled = true
		acc.Font = Enum.Font.GothamBold
		if skin.Accessory == "Crown" or skin.Accessory == "GoldDragon" then acc.Text = "👑"
		elseif skin.Accessory == "Fire" then acc.Text = "🔥"
		elseif skin.Accessory == "Ice" then acc.Text = "❄️"
		elseif skin.Accessory == "Headphones" then acc.Text = "🎧" end
		acc.Parent = head
	end
	return head
end

-- ============================================================
-- CỬA SỔ CHÍNH (CHỪA KHOẢNG AN TOÀN TRÁNH THANH ROBLOX MOBILE)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local floatBtn = makeGlossyBtn(
	screenGui, "🐍",
	UDim2.fromOffset(50, 50),
	UDim2.new(0, 16, 0.5, -25),
	Color3.fromRGB(74, 222, 128), Color3.fromRGB(22, 163, 74), 25
)
floatBtn.TextSize = 24
floatBtn.Visible = false
local floatDragged = false
makeDraggable(floatBtn, floatBtn, function(v) floatDragged = v end)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(620, 400)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 20) -- Đẩy nhẹ xuống để không bị thanh Roblox che góc trên trái
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 38)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
addCorner(mainFrame, 16)
addStroke(mainFrame, Color3.fromRGB(115, 88, 220), 2.5)
addGradient(mainFrame, Color3.fromRGB(26, 28, 50), Color3.fromRGB(15, 17, 30), 90)

local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame

local function calcScale()
	local cam = workspace.CurrentCamera
	if not cam then return 1 end
	local vp = cam.ViewportSize
	-- Chừa 58px phía trên tránh cụm nút chat/mic của Roblox mobile
	local scaleX = (vp.X - 24) / 620
	local scaleY = (vp.Y - 68) / 400
	return math.clamp(math.min(1, scaleX, scaleY), 0.48, 1)
end
uiScale.Scale = calcScale()

-- ============================================================
-- THANH ĐẦU TRANG (HỒ SƠ + XU + KIM CƯƠNG + ĐÈN BÁO LƯU)
-- ============================================================
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = Color3.fromRGB(30, 32, 58)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
addGradient(topBar, Color3.fromRGB(42, 38, 82), Color3.fromRGB(24, 26, 46), 90)
makeDraggable(topBar, mainFrame)

local profileBox = Instance.new("Frame")
profileBox.Size = UDim2.fromOffset(176, 36)
profileBox.Position = UDim2.fromOffset(10, 6)
profileBox.BackgroundColor3 = Color3.fromRGB(20, 22, 38)
profileBox.BorderSizePixel = 0
profileBox.Parent = topBar
addCorner(profileBox, 18)
addStroke(profileBox, Color3.fromRGB(115, 90, 220), 1.6)

local avatarIconHolder = Instance.new("Frame")
avatarIconHolder.Size = UDim2.fromOffset(28, 28)
avatarIconHolder.Position = UDim2.fromOffset(6, 4)
avatarIconHolder.BackgroundTransparency = 1
avatarIconHolder.Parent = profileBox

local profileName = Instance.new("TextLabel")
profileName.Size = UDim2.fromOffset(124, 16)
profileName.Position = UDim2.fromOffset(42, 3)
profileName.BackgroundTransparency = 1
profileName.Text = player.DisplayName
profileName.TextColor3 = Color3.fromRGB(255, 255, 255)
profileName.Font = Enum.Font.GothamBlack
profileName.TextSize = 12
profileName.TextXAlignment = Enum.TextXAlignment.Left
profileName.TextTruncate = Enum.TextTruncate.AtEnd
profileName.Parent = profileBox

local lvLabel = Instance.new("TextLabel")
lvLabel.Size = UDim2.fromOffset(42, 12)
lvLabel.Position = UDim2.fromOffset(42, 20)
lvLabel.BackgroundTransparency = 1
lvLabel.Text = "Lv. 1"
lvLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
lvLabel.Font = Enum.Font.GothamBlack
lvLabel.TextSize = 11
lvLabel.TextXAlignment = Enum.TextXAlignment.Left
lvLabel.Parent = profileBox

local expBg = Instance.new("Frame")
expBg.Size = UDim2.fromOffset(78, 8)
expBg.Position = UDim2.fromOffset(86, 22)
expBg.BackgroundColor3 = Color3.fromRGB(40, 44, 68)
expBg.BorderSizePixel = 0
expBg.Parent = profileBox
addCorner(expBg, 4)

local expFill = Instance.new("Frame")
expFill.Size = UDim2.fromScale(0.1, 1)
expFill.BackgroundColor3 = Color3.fromRGB(74, 222, 128)
expFill.BorderSizePixel = 0
expFill.Parent = expBg
addCorner(expFill, 4)

-- Ô Xu (với icon đồng xu vàng tự vẽ, không bị ô vuông)
local coinPill = Instance.new("Frame")
coinPill.Size = UDim2.fromOffset(114, 32)
coinPill.Position = UDim2.fromOffset(196, 8)
coinPill.BackgroundColor3 = Color3.fromRGB(20, 22, 38)
coinPill.BorderSizePixel = 0
coinPill.Parent = topBar
addCorner(coinPill, 16)
addStroke(coinPill, Color3.fromRGB(95, 78, 175), 1.5)
makeCoinIcon(coinPill, 20, UDim2.new(0, 8, 0.5, 0))

local coinsLbl = Instance.new("TextLabel")
coinsLbl.Size = UDim2.new(1, -34, 1, 0)
coinsLbl.Position = UDim2.fromOffset(32, 0)
coinsLbl.BackgroundTransparency = 1
coinsLbl.Text = tostring(state.Coins)
coinsLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
coinsLbl.Font = Enum.Font.GothamBlack
coinsLbl.TextSize = 14
coinsLbl.TextXAlignment = Enum.TextXAlignment.Left
coinsLbl.Parent = coinPill

-- Ô Kim Cương
local gemPill = Instance.new("Frame")
gemPill.Size = UDim2.fromOffset(106, 32)
gemPill.Position = UDim2.fromOffset(318, 8)
gemPill.BackgroundColor3 = Color3.fromRGB(20, 22, 38)
gemPill.BorderSizePixel = 0
gemPill.Parent = topBar
addCorner(gemPill, 16)
addStroke(gemPill, Color3.fromRGB(95, 78, 175), 1.5)

local gemsLbl = Instance.new("TextLabel")
gemsLbl.Size = UDim2.new(1, -10, 1, 0)
gemsLbl.Position = UDim2.fromOffset(5, 0)
gemsLbl.BackgroundTransparency = 1
gemsLbl.Text = "💎 " .. tostring(state.Gems)
gemsLbl.TextColor3 = Color3.fromRGB(103, 232, 249)
gemsLbl.Font = Enum.Font.GothamBlack
gemsLbl.TextSize = 14
gemsLbl.Parent = gemPill

-- Đèn báo trạng thái Tự Động Lưu (thay cho chữ [RightShift] thừa trên mobile)
saveStatusLbl = Instance.new("TextLabel")
saveStatusLbl.Size = UDim2.fromOffset(106, 32)
saveStatusLbl.Position = UDim2.fromOffset(432, 8)
saveStatusLbl.BackgroundTransparency = 1
saveStatusLbl.Text = hadSavedData and "✔ Đã tải dữ liệu" or "💾 Tự động lưu"
saveStatusLbl.TextColor3 = Color3.fromRGB(134, 239, 172)
saveStatusLbl.Font = Enum.Font.GothamBold
saveStatusLbl.TextSize = 11
saveStatusLbl.Parent = topBar

local minBtn   = makeGlossyBtn(topBar, "-", UDim2.fromOffset(30, 30), UDim2.new(1, -72, 0, 9), Color3.fromRGB(90, 100, 130), Color3.fromRGB(55, 62, 85), 8)
local closeBtn = makeGlossyBtn(topBar, "X", UDim2.fromOffset(30, 30), UDim2.new(1, -36, 0, 9), Color3.fromRGB(248, 70, 70), Color3.fromRGB(185, 28, 28), 8)
minBtn.TextSize = 18
closeBtn.TextSize = 15

-- ============================================================
-- VÙNG NỘI DUNG: SẢNH CHỜ (LOBBY) & MÀN CHƠI (GAME)
-- ============================================================
local container = Instance.new("Frame")
container.Size = UDim2.fromOffset(600, 338)
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
-- 1. SẢNH CHỜ (SHOWCASE RẮN + PLAY + TOP 10 + 5 NÚT DƯỚI)
-- ============================================================
local showcaseCard = Instance.new("Frame")
showcaseCard.Size = UDim2.fromOffset(362, 268)
showcaseCard.BackgroundColor3 = Color3.fromRGB(24, 28, 48)
showcaseCard.BorderSizePixel = 0
showcaseCard.Parent = lobbyPage
addCorner(showcaseCard, 14)
addStroke(showcaseCard, Color3.fromRGB(72, 65, 135), 1.8)
addGradient(showcaseCard, Color3.fromRGB(34, 38, 68), Color3.fromRGB(18, 21, 36), 90)

local showcaseTitle = Instance.new("TextLabel")
showcaseTitle.Size = UDim2.new(1, 0, 0, 34)
showcaseTitle.Position = UDim2.fromOffset(0, 6)
showcaseTitle.BackgroundTransparency = 1
showcaseTitle.Text = "🐍 RẮN SĂN MỒI PRO"
showcaseTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
showcaseTitle.Font = Enum.Font.GothamBlack
showcaseTitle.TextSize = 20
showcaseTitle.Parent = showcaseCard

local previewStage = Instance.new("Frame")
previewStage.Size = UDim2.fromOffset(330, 96)
previewStage.Position = UDim2.fromOffset(16, 44)
previewStage.BackgroundColor3 = Color3.fromRGB(15, 18, 32)
previewStage.BorderSizePixel = 0
previewStage.ClipsDescendants = true
previewStage.Parent = showcaseCard
addCorner(previewStage, 12)
addStroke(previewStage, Color3.fromRGB(58, 66, 105), 1.5)

local equippedSkinLbl = Instance.new("TextLabel")
equippedSkinLbl.Size = UDim2.new(1, 0, 0, 24)
equippedSkinLbl.Position = UDim2.fromOffset(0, 144)
equippedSkinLbl.BackgroundTransparency = 1
equippedSkinLbl.Text = "Skin đang dùng: Rắn Xanh Lá"
equippedSkinLbl.TextColor3 = Color3.fromRGB(165, 243, 252)
equippedSkinLbl.Font = Enum.Font.GothamBold
equippedSkinLbl.TextSize = 13
equippedSkinLbl.Parent = showcaseCard

local playBtn = makeGlossyBtn(
	showcaseCard, "▶  CHƠI NGAY",
	UDim2.fromOffset(230, 56),
	UDim2.fromOffset(66, 174),
	Color3.fromRGB(74, 240, 110), Color3.fromRGB(22, 163, 74), 26
)
playBtn.TextSize = 21

local bestScoreTip = Instance.new("TextLabel")
bestScoreTip.Size = UDim2.new(1, 0, 0, 24)
bestScoreTip.Position = UDim2.fromOffset(0, 236)
bestScoreTip.BackgroundTransparency = 1
bestScoreTip.Text = "🏆 Kỷ lục của bạn: 0 điểm"
bestScoreTip.TextColor3 = Color3.fromRGB(203, 213, 225)
bestScoreTip.Font = Enum.Font.GothamBold
bestScoreTip.TextSize = 12
bestScoreTip.Parent = showcaseCard

-- Bảng Xếp Hạng Top 10
local lbCard = Instance.new("Frame")
lbCard.Size = UDim2.fromOffset(228, 268)
lbCard.Position = UDim2.fromOffset(372, 0)
lbCard.BackgroundColor3 = Color3.fromRGB(22, 24, 42)
lbCard.BorderSizePixel = 0
lbCard.Parent = lobbyPage
addCorner(lbCard, 14)
addStroke(lbCard, Color3.fromRGB(147, 51, 234), 2)

local lbHeader = Instance.new("Frame")
lbHeader.Size = UDim2.new(1, 0, 0, 34)
lbHeader.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
lbHeader.BorderSizePixel = 0
lbHeader.Parent = lbCard
addCorner(lbHeader, 12)
addGradient(lbHeader, Color3.fromRGB(168, 85, 247), Color3.fromRGB(109, 40, 217), 90)

local lbTitle = Instance.new("TextLabel")
lbTitle.Size = UDim2.fromScale(1, 1)
lbTitle.BackgroundTransparency = 1
lbTitle.Text = "🏆 BẢNG XẾP HẠNG"
lbTitle.TextColor3 = Color3.fromRGB(255, 240, 130)
lbTitle.Font = Enum.Font.GothamBlack
lbTitle.TextSize = 14
lbTitle.Parent = lbHeader

local lbList = Instance.new("Frame")
lbList.Size = UDim2.new(1, -12, 1, -42)
lbList.Position = UDim2.fromOffset(6, 38)
lbList.BackgroundTransparency = 1
lbList.Parent = lbCard

local lbLayout = Instance.new("UIListLayout")
lbLayout.Padding = UDim.new(0, 2)
lbLayout.Parent = lbList

local function refreshLeaderboard()
	for _, ch in ipairs(lbList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	local entries = {}
	for _, b in ipairs(BOT_SCORES) do
		table.insert(entries, { Name = b.Name, Score = b.Score, IsYou = false })
	end
	table.insert(entries, { Name = "You (" .. player.DisplayName .. ")", Score = state.HighScore, IsYou = true })
	table.sort(entries, function(a, b) return a.Score > b.Score end)

	for i = 1, math.min(10, #entries) do
		local e = entries[i]
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 20)
		row.BackgroundColor3 = e.IsYou and Color3.fromRGB(120, 82, 22) or Color3.fromRGB(30, 33, 56)
		row.BackgroundTransparency = e.IsYou and 0.15 or 0.55
		row.BorderSizePixel = 0
		row.Parent = lbList
		addCorner(row, 5)

		local medal = (i == 1 and "👑") or (i == 2 and "🥈") or (i == 3 and "🥉") or tostring(i)
		local rankLbl = Instance.new("TextLabel")
		rankLbl.Size = UDim2.fromOffset(24, 20)
		rankLbl.Position = UDim2.fromOffset(4, 0)
		rankLbl.BackgroundTransparency = 1
		rankLbl.Text = medal
		rankLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
		rankLbl.Font = Enum.Font.GothamBlack
		rankLbl.TextSize = 11
		rankLbl.Parent = row

		local nLbl = Instance.new("TextLabel")
		nLbl.Size = UDim2.fromOffset(128, 20)
		nLbl.Position = UDim2.fromOffset(28, 0)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = e.Name
		nLbl.TextColor3 = e.IsYou and Color3.fromRGB(254, 240, 138) or Color3.fromRGB(235, 240, 255)
		nLbl.Font = e.IsYou and Enum.Font.GothamBlack or Enum.Font.GothamBold
		nLbl.TextSize = 11
		nLbl.TextXAlignment = Enum.TextXAlignment.Left
		nLbl.TextTruncate = Enum.TextTruncate.AtEnd
		nLbl.Parent = row

		local sLbl = Instance.new("TextLabel")
		sLbl.Size = UDim2.fromOffset(52, 20)
		sLbl.Position = UDim2.new(1, -56, 0, 0)
		sLbl.BackgroundTransparency = 1
		sLbl.Text = tostring(e.Score)
		sLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
		sLbl.Font = Enum.Font.GothamBlack
		sLbl.TextSize = 11
		sLbl.TextXAlignment = Enum.TextXAlignment.Right
		sLbl.Parent = row
	end
end

-- 5 nút chức năng dưới cùng (đã sửa X THOÁT không lỗi ô vuông)
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.fromOffset(600, 56)
bottomBar.Position = UDim2.fromOffset(0, 278)
bottomBar.BackgroundTransparency = 1
bottomBar.Parent = lobbyPage

local bLayout = Instance.new("UIListLayout")
bLayout.FillDirection = Enum.FillDirection.Horizontal
bLayout.Padding = UDim.new(0, 8)
bLayout.Parent = bottomBar

local shopBtn     = makeGlossyBtn(bottomBar, "🏪 SHOP",     UDim2.fromOffset(113, 52), nil, Color3.fromRGB(251, 146, 60), Color3.fromRGB(220, 38, 38), 12)
local giftBtn     = makeGlossyBtn(bottomBar, "🎁 QUÀ TẶNG", UDim2.fromOffset(114, 52), nil, Color3.fromRGB(192, 132, 252), Color3.fromRGB(126, 34, 206), 12)
local questBtn    = makeGlossyBtn(bottomBar, "📋 NHIỆM VỤ", UDim2.fromOffset(114, 52), nil, Color3.fromRGB(56, 189, 248), Color3.fromRGB(29, 78, 216), 12)
local settingsBtn = makeGlossyBtn(bottomBar, "⚙️ CÀI ĐẶT",  UDim2.fromOffset(114, 52), nil, Color3.fromRGB(250, 204, 21), Color3.fromRGB(217, 119, 6), 12)
local exitBtn     = makeGlossyBtn(bottomBar, "X THOÁT",     UDim2.fromOffset(113, 52), nil, Color3.fromRGB(248, 113, 113), Color3.fromRGB(185, 28, 28), 12)

local giftDot  = makeNotifDot(giftBtn)
local questDot = makeNotifDot(questBtn)

-- Rắn mẫu ngoài Sảnh Chờ (đốt nối liền khít, không hở đuôi)
local previewSegs = {}
local previewHead = nil

local function rebuildLobbyPreview()
	for _, ch in ipairs(previewStage:GetChildren()) do ch:Destroy() end
	for _, ch in ipairs(avatarIconHolder:GetChildren()) do ch:Destroy() end
	previewSegs = {}

	local skin = getSkinById(state.EquippedSkin)
	equippedSkinLbl.Text = "Skin đang dùng: " .. skin.Name .. (skin.Accessory and " ✨" or "")

	local miniAvatar = buildCartoonHead(avatarIconHolder, 24, skin)
	miniAvatar.Position = UDim2.fromScale(0.5, 0.5)

	for i = 10, 1, -1 do
		local sz = math.max(16, 31 - (i * 1.25))
		local seg = Instance.new("Frame")
		seg.Size = UDim2.fromOffset(sz, sz)
		seg.AnchorPoint = Vector2.new(0.5, 0.5)
		seg.BackgroundColor3 = (i % 2 == 0) and skin.Body1 or skin.Body2
		seg.BorderSizePixel = 0
		seg.ZIndex = 5 - math.floor(i / 4)
		seg.Parent = previewStage
		addCorner(seg, 99)
		addStroke(seg, Color3.fromRGB(12, 14, 22), 2)
		previewSegs[i] = seg
	end

	previewHead = buildCartoonHead(previewStage, 35, skin)
end

-- ============================================================
-- CẬP NHẬT CHỈ SỐ, THÔNG BÁO & CÁC BẢNG POPUP
-- ============================================================
local function refreshNotifDots()
	giftDot.Visible = (os.time() >= state.NextGiftUnix)
	local hasQuest = false
	for _, q in ipairs(state.Quests) do
		if q.Progress >= q.Goal and not q.Claimed then
			hasQuest = true
			break
		end
	end
	questDot.Visible = hasQuest
end

local function updateTopStats()
	coinsLbl.Text = tostring(state.Coins)
	gemsLbl.Text  = "💎 " .. tostring(state.Gems)
	lvLabel.Text  = "Lv. " .. tostring(state.Level)
	expFill.Size  = UDim2.fromScale(math.clamp(state.Exp / state.ExpNeed, 0.06, 1), 1)
	bestScoreTip.Text = "🏆 Kỷ lục của bạn: " .. tostring(state.HighScore) .. " điểm"
	refreshLeaderboard()
	refreshNotifDots()
end

local function addExp(amount)
	state.Exp += amount
	while state.Exp >= state.ExpNeed do
		state.Exp -= state.ExpNeed
		state.Level += 1
		state.ExpNeed = math.floor(state.ExpNeed * 1.35)
		state.Gems += 2
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

-- Popup dùng chung (đã thêm Padding để không bị cắt viền khi cuộn)
local modalOverlay = Instance.new("Frame")
modalOverlay.Size = UDim2.fromScale(1, 1)
modalOverlay.BackgroundColor3 = Color3.fromRGB(5, 6, 12)
modalOverlay.BackgroundTransparency = 0.28
modalOverlay.Visible = false
modalOverlay.ZIndex = 30
modalOverlay.Parent = mainFrame

local modalBox = Instance.new("Frame")
modalBox.Size = UDim2.fromOffset(476, 326)
modalBox.Position = UDim2.fromScale(0.5, 0.5)
modalBox.AnchorPoint = Vector2.new(0.5, 0.5)
modalBox.BackgroundColor3 = Color3.fromRGB(24, 27, 46)
modalBox.BorderSizePixel = 0
modalBox.ZIndex = 31
modalBox.Parent = modalOverlay
addCorner(modalBox, 14)
addStroke(modalBox, Color3.fromRGB(139, 92, 246), 2.4)

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -55, 0, 38)
modalTitle.Position = UDim2.fromOffset(14, 4)
modalTitle.BackgroundTransparency = 1
modalTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
modalTitle.Font = Enum.Font.GothamBlack
modalTitle.TextSize = 17
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.ZIndex = 32
modalTitle.Parent = modalBox

local modalClose = makeGlossyBtn(modalBox, "X", UDim2.fromOffset(28, 28), UDim2.new(1, -36, 0, 8), Color3.fromRGB(248, 70, 70), Color3.fromRGB(185, 28, 28), 8)
modalClose.TextSize = 15
modalClose.ZIndex = 33

local modalBody = Instance.new("ScrollingFrame")
modalBody.Size = UDim2.new(1, -20, 1, -54)
modalBody.Position = UDim2.fromOffset(10, 46)
modalBody.BackgroundTransparency = 1
modalBody.ScrollBarThickness = 5
modalBody.CanvasSize = UDim2.new(0, 0, 0, 0)
modalBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
modalBody.ZIndex = 32
modalBody.Parent = modalBox

local activeModalTag = nil
local liveGiftBtn = nil

modalClose.MouseButton1Click:Connect(function()
	modalOverlay.Visible = false
	activeModalTag = nil
	liveGiftBtn = nil
end)

local function openModal(tag, titleText)
	for _, ch in ipairs(modalBody:GetChildren()) do ch:Destroy() end
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = modalBody

	activeModalTag = tag
	liveGiftBtn = nil
	modalTitle.Text = titleText
	modalOverlay.Visible = true
end

-- POPUP SHOP SKIN
local function openShop()
	openModal("Shop", "🏪 CỬA HÀNG SKIN RẮN")
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(212, 76)
	grid.CellPadding = UDim2.fromOffset(10, 10)
	grid.Parent = modalBody

	for _, skin in ipairs(SKINS) do
		local card = Instance.new("Frame")
		card.BackgroundColor3 = Color3.fromRGB(32, 36, 62)
		card.BorderSizePixel = 0
		card.ZIndex = 33
		card.Parent = modalBody
		addCorner(card, 10)
		addStroke(card, (state.EquippedSkin == skin.Id) and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(68, 76, 115), 1.8)

		local headBox = Instance.new("Frame")
		headBox.Size = UDim2.fromOffset(42, 42)
		headBox.Position = UDim2.fromOffset(10, 17)
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
		nLbl.Size = UDim2.fromOffset(145, 22)
		nLbl.Position = UDim2.fromOffset(60, 8)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = skin.Name
		nLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		nLbl.Font = Enum.Font.GothamBlack
		nLbl.TextSize = 13
		nLbl.TextXAlignment = Enum.TextXAlignment.Left
		nLbl.ZIndex = 34
		nLbl.Parent = card

		local owned = state.OwnedSkins[skin.Id]
		local equipped = (state.EquippedSkin == skin.Id)
		local btnText, c1, c2
		if equipped then
			btnText = "✔ ĐANG DÙNG"
			c1, c2 = Color3.fromRGB(74, 222, 128), Color3.fromRGB(22, 163, 74)
		elseif owned then
			btnText = "TRANG BỊ"
			c1, c2 = Color3.fromRGB(56, 189, 248), Color3.fromRGB(37, 99, 235)
		else
			local curLabel = (skin.Currency == "Gems") and ("💎 " .. skin.Price) or (skin.Price .. " Xu")
			btnText = "MUA " .. curLabel
			c1, c2 = Color3.fromRGB(250, 204, 21), Color3.fromRGB(217, 119, 6)
		end

		local actBtn = makeGlossyBtn(card, btnText, UDim2.fromOffset(138, 30), UDim2.fromOffset(60, 36), c1, c2, 8)
		actBtn.TextSize = 12
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

-- POPUP QUÀ TẶNG (TỰ ĐẾM NGƯỢC TRỰC TIẾP & LƯU THEO OS.TIME)
local function openGift()
	openModal("Gift", "🎁 QUÀ TẶNG MIỄN PHÍ")
	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, 0, 0, 96)
	desc.Position = UDim2.fromOffset(0, 12)
	desc.BackgroundTransparency = 1
	desc.Text = "🎁 HỘP QUÀ MAY MẮN\nNhận ngay +150 Xu và +5 💎 Kim Cương\n(Hồi lại sau mỗi 60 giây - tự động lưu)"
	desc.TextColor3 = Color3.fromRGB(240, 244, 255)
	desc.Font = Enum.Font.GothamBold
	desc.TextSize = 15
	desc.ZIndex = 33
	desc.Parent = modalBody

	local remain = math.max(0, state.NextGiftUnix - os.time())
	local ready = (remain <= 0)
	local claimBtn = makeGlossyBtn(
		modalBody,
		ready and "🎉 NHẬN QUÀ NGAY!" or ("⏳ CHỜ " .. remain .. " GIÂY"),
		UDim2.fromOffset(236, 52),
		UDim2.fromOffset(102, 126),
		ready and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(95, 104, 136),
		ready and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(65, 72, 98),
		14
	)
	claimBtn.TextSize = 16
	claimBtn.ZIndex = 34
	liveGiftBtn = claimBtn

	claimBtn.MouseButton1Click:Connect(function()
		if os.time() < state.NextGiftUnix then return end
		state.NextGiftUnix = os.time() + 60
		state.Coins += 150
		state.Gems += 5
		updateTopStats()
		saveData()
		openGift()
	end)
end

-- POPUP NHIỆM VỤ
local function openQuests()
	openModal("Quests", "📋 NHIỆM VỤ NHẬN THƯỞNG")
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = modalBody

	for _, q in ipairs(state.Quests) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 56)
		row.BackgroundColor3 = Color3.fromRGB(32, 36, 62)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = modalBody
		addCorner(row, 10)
		addStroke(row, Color3.fromRGB(68, 76, 115), 1.5)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.fromOffset(286, 24)
		title.Position = UDim2.fromOffset(12, 6)
		title.BackgroundTransparency = 1
		title.Text = q.Title .. " (" .. math.min(q.Progress, q.Goal) .. "/" .. q.Goal .. ")"
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 34
		title.Parent = row

		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.fromOffset(272, 10)
		barBg.Position = UDim2.fromOffset(12, 34)
		barBg.BackgroundColor3 = Color3.fromRGB(20, 22, 38)
		barBg.BorderSizePixel = 0
		barBg.ZIndex = 34
		barBg.Parent = row
		addCorner(barBg, 5)

		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.fromScale(math.clamp(q.Progress / q.Goal, 0, 1), 1)
		barFill.BackgroundColor3 = Color3.fromRGB(74, 222, 128)
		barFill.BorderSizePixel = 0
		barFill.ZIndex = 35
		barFill.Parent = barBg
		addCorner(barFill, 5)

		local rewardTxt = (q.Currency == "Gems") and (q.Reward .. " 💎") or (q.Reward .. " Xu")
		local canClaim = (q.Progress >= q.Goal) and not q.Claimed
		local btnText = q.Claimed and "✔ ĐÃ NHẬN" or (canClaim and ("NHẬN +" .. rewardTxt) or rewardTxt)
		local cBtn = makeGlossyBtn(
			row, btnText,
			UDim2.fromOffset(126, 34), UDim2.new(1, -136, 0, 11),
			canClaim and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(85, 95, 128),
			canClaim and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(58, 66, 92),
			8
		)
		cBtn.TextSize = 12
		cBtn.ZIndex = 35
		cBtn.MouseButton1Click:Connect(function()
			if not canClaim then return end
			q.Claimed = true
			if q.Currency == "Gems" then state.Gems += q.Reward else state.Coins += q.Reward end
			addExp(35)
			openQuests()
		end)
	end
end

-- POPUP CÀI ĐẶT + QUẢN LÝ LƯU DỮ LIỆU
local function openSettings()
	openModal("Settings", "⚙️ CÀI ĐẶT & LƯU DỮ LIỆU")
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = modalBody

	local function addSettingRow(labelTxt, getText, onToggle, c1, c2)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -2, 0, 46)
		row.BackgroundColor3 = Color3.fromRGB(32, 36, 62)
		row.BorderSizePixel = 0
		row.ZIndex = 33
		row.Parent = modalBody
		addCorner(row, 10)

		local l = Instance.new("TextLabel")
		l.Size = UDim2.fromOffset(255, 46)
		l.Position = UDim2.fromOffset(12, 0)
		l.BackgroundTransparency = 1
		l.Text = labelTxt
		l.TextColor3 = Color3.fromRGB(255, 255, 255)
		l.Font = Enum.Font.GothamBold
		l.TextSize = 13
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = 34
		l.Parent = row

		local b = makeGlossyBtn(row, getText(), UDim2.fromOffset(146, 32), UDim2.new(1, -156, 0, 7), c1 or Color3.fromRGB(56, 189, 248), c2 or Color3.fromRGB(37, 99, 235), 8)
		b.TextSize = 12
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

	local speedNames = { "Chậm", "Vừa", "Nhanh" }
	addSettingRow("⚡ Tốc độ Rắn", function()
		return speedNames[state.Settings.SpeedMode]
	end, function()
		state.Settings.SpeedMode = (state.Settings.SpeedMode % 3) + 1
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
	end, Color3.fromRGB(74, 222, 128), Color3.fromRGB(22, 163, 74))

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
	end, Color3.fromRGB(248, 113, 113), Color3.fromRGB(185, 28, 28))
end

shopBtn.MouseButton1Click:Connect(openShop)
giftBtn.MouseButton1Click:Connect(openGift)
questBtn.MouseButton1Click:Connect(openQuests)
settingsBtn.MouseButton1Click:Connect(openSettings)

-- ============================================================
-- 2. MÀN HÌNH CHƠI GAME RẮN SĂN MỒI
-- ============================================================
local COLS, ROWS, CELL = 16, 12, 24

local hudBar = Instance.new("Frame")
hudBar.Size = UDim2.fromOffset(600, 36)
hudBar.BackgroundColor3 = Color3.fromRGB(26, 30, 52)
hudBar.BorderSizePixel = 0
hudBar.Parent = gamePage
addCorner(hudBar, 10)
addStroke(hudBar, Color3.fromRGB(68, 76, 118), 1.5)

local liveScoreLbl = Instance.new("TextLabel")
liveScoreLbl.Size = UDim2.fromOffset(310, 36)
liveScoreLbl.Position = UDim2.fromOffset(12, 0)
liveScoreLbl.BackgroundTransparency = 1
liveScoreLbl.Text = "Điểm: 0   |   +0 Xu   |   +0 💎"
liveScoreLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
liveScoreLbl.Font = Enum.Font.GothamBlack
liveScoreLbl.TextSize = 14
liveScoreLbl.TextXAlignment = Enum.TextXAlignment.Left
liveScoreLbl.Parent = hudBar

local pauseBtn   = makeGlossyBtn(hudBar, "II", UDim2.fromOffset(38, 28), UDim2.new(1, -206, 0, 4), Color3.fromRGB(56, 189, 248), Color3.fromRGB(37, 99, 235), 8)
local restartBtn = makeGlossyBtn(hudBar, "🔄 Lại", UDim2.fromOffset(72, 28), UDim2.new(1, -162, 0, 4), Color3.fromRGB(74, 222, 128), Color3.fromRGB(22, 163, 74), 8)
local lobbyBtn   = makeGlossyBtn(hudBar, "🏠 Sảnh", UDim2.fromOffset(78, 28), UDim2.new(1, -84, 0, 4), Color3.fromRGB(168, 85, 247), Color3.fromRGB(109, 40, 217), 8)
restartBtn.TextSize = 12
lobbyBtn.TextSize = 12

local board = Instance.new("Frame")
board.Size = UDim2.fromOffset(COLS * CELL, ROWS * CELL)
board.Position = UDim2.fromOffset(0, 44)
board.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
board.BorderSizePixel = 0
board.ClipsDescendants = true
board.Parent = gamePage
addCorner(board, 10)
addStroke(board, Color3.fromRGB(80, 92, 145), 2)

for x = 1, COLS do
	for y = 1, ROWS do
		if (x + y) % 2 == 0 then
			local tile = Instance.new("Frame")
			tile.Size = UDim2.fromOffset(CELL, CELL)
			tile.Position = UDim2.fromOffset((x - 1) * CELL, (y - 1) * CELL)
			tile.BackgroundColor3 = Color3.fromRGB(20, 26, 44)
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

local snakeLayer = Instance.new("Frame")
snakeLayer.Size = UDim2.fromScale(1, 1)
snakeLayer.BackgroundTransparency = 1
snakeLayer.ZIndex = 4
snakeLayer.Parent = board

local gameOverCard = Instance.new("Frame")
gameOverCard.Size = UDim2.fromOffset(296, 178)
gameOverCard.Position = UDim2.fromScale(0.5, 0.5)
gameOverCard.AnchorPoint = Vector2.new(0.5, 0.5)
gameOverCard.BackgroundColor3 = Color3.fromRGB(22, 24, 44)
gameOverCard.BorderSizePixel = 0
gameOverCard.Visible = false
gameOverCard.ZIndex = 20
gameOverCard.Parent = board
addCorner(gameOverCard, 14)
addStroke(gameOverCard, Color3.fromRGB(248, 113, 113), 2.5)

local goTitle = Instance.new("TextLabel")
goTitle.Size = UDim2.new(1, 0, 0, 34)
goTitle.Position = UDim2.fromOffset(0, 10)
goTitle.BackgroundTransparency = 1
goTitle.Text = "💀 KẾT THÚC!"
goTitle.TextColor3 = Color3.fromRGB(248, 113, 113)
goTitle.Font = Enum.Font.GothamBlack
goTitle.TextSize = 20
goTitle.ZIndex = 21
goTitle.Parent = gameOverCard

local goStats = Instance.new("TextLabel")
goStats.Size = UDim2.new(1, -20, 0, 62)
goStats.Position = UDim2.fromOffset(10, 48)
goStats.BackgroundTransparency = 1
goStats.Text = ""
goStats.TextColor3 = Color3.fromRGB(240, 244, 255)
goStats.Font = Enum.Font.GothamBold
goStats.TextSize = 13
goStats.ZIndex = 21
goStats.Parent = gameOverCard

local goReplayBtn = makeGlossyBtn(gameOverCard, "🔄 CHƠI LẠI", UDim2.fromOffset(124, 38), UDim2.fromOffset(18, 124), Color3.fromRGB(74, 222, 128), Color3.fromRGB(22, 163, 74), 10)
local goLobbyBtn  = makeGlossyBtn(gameOverCard, "🏠 VỀ SẢNH", UDim2.fromOffset(124, 38), UDim2.fromOffset(154, 124), Color3.fromRGB(168, 85, 247), Color3.fromRGB(109, 40, 217), 10)
goReplayBtn.ZIndex = 22
goLobbyBtn.ZIndex  = 22

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.fromOffset(204, 288)
rightPanel.Position = UDim2.fromOffset(396, 44)
rightPanel.BackgroundTransparency = 1
rightPanel.Parent = gamePage

local buffBox = Instance.new("Frame")
buffBox.Size = UDim2.fromOffset(204, 114)
buffBox.BackgroundColor3 = Color3.fromRGB(24, 28, 48)
buffBox.BorderSizePixel = 0
buffBox.Parent = rightPanel
addCorner(buffBox, 12)
addStroke(buffBox, Color3.fromRGB(68, 76, 115), 1.5)

local buffHeader = Instance.new("TextLabel")
buffHeader.Size = UDim2.new(1, 0, 0, 22)
buffHeader.Position = UDim2.fromOffset(0, 4)
buffHeader.BackgroundTransparency = 1
buffHeader.Text = "✨ KỸ NĂNG ĐANG BẬT"
buffHeader.TextColor3 = Color3.fromRGB(165, 243, 252)
buffHeader.Font = Enum.Font.GothamBlack
buffHeader.TextSize = 11
buffHeader.Parent = buffBox

local buffStatusLbl = Instance.new("TextLabel")
buffStatusLbl.Size = UDim2.new(1, -14, 1, -28)
buffStatusLbl.Position = UDim2.fromOffset(7, 26)
buffStatusLbl.BackgroundTransparency = 1
buffStatusLbl.Text = "Chưa có buff nào\n⭐ 2x  👻 Ma  🛡️ Khiên\n🧲 Hút  ⚡ Nhanh  💣 Tránh"
buffStatusLbl.TextColor3 = Color3.fromRGB(203, 213, 225)
buffStatusLbl.Font = Enum.Font.GothamBold
buffStatusLbl.TextSize = 11
buffStatusLbl.TextWrapped = true
buffStatusLbl.Parent = buffBox

local dpadFrame = Instance.new("Frame")
dpadFrame.Size = UDim2.fromOffset(204, 166)
dpadFrame.Position = UDim2.fromOffset(0, 122)
dpadFrame.BackgroundColor3 = Color3.fromRGB(24, 28, 48)
dpadFrame.BorderSizePixel = 0
dpadFrame.Parent = rightPanel
addCorner(dpadFrame, 12)
addStroke(dpadFrame, Color3.fromRGB(68, 76, 115), 1.5)

local dUp    = makeGlossyBtn(dpadFrame, "▲", UDim2.fromOffset(48, 48), UDim2.fromOffset(78, 8),   Color3.fromRGB(56, 189, 248), Color3.fromRGB(29, 78, 216), 24)
local dLeft  = makeGlossyBtn(dpadFrame, "◄", UDim2.fromOffset(48, 48), UDim2.fromOffset(24, 59),  Color3.fromRGB(56, 189, 248), Color3.fromRGB(29, 78, 216), 24)
local dRight = makeGlossyBtn(dpadFrame, "►", UDim2.fromOffset(48, 48), UDim2.fromOffset(132, 59), Color3.fromRGB(56, 189, 248), Color3.fromRGB(29, 78, 216), 24)
local dDown  = makeGlossyBtn(dpadFrame, "▼", UDim2.fromOffset(48, 48), UDim2.fromOffset(78, 110), Color3.fromRGB(56, 189, 248), Color3.fromRGB(29, 78, 216), 24)
dUp.TextSize, dLeft.TextSize, dRight.TextSize, dDown.TextSize = 18, 18, 18, 18

-- ============================================================
-- LOGIC GAME RẮN SĂN MỒI
-- ============================================================
local playing, paused = false, false
local snake, prevSnake, turnQueue = {}, {}, {}
local dir = { x = 1, y = 0 }
local runScore, runCoins, runGems = 0, 0, 0
local stepTimer, stepDuration = 0, 0.16
local powerSpawnTimer, bombSpawnTimer = 0, 0
local buffs = { Double = 0, Ghost = 0, Magnet = 0, Speed = 0, Shield = false, Invuln = 0 }
local boardItems = {}
local bodyFrames = {}
local activeHeadNode, shieldRing = nil, nil

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
	for _, it in ipairs(boardItems) do
		if it.Node then it.Node:Destroy() end
	end
	boardItems = {}
end

local function clearSnakeVisuals()
	for _, ch in ipairs(snakeLayer:GetChildren()) do ch:Destroy() end
	bodyFrames = {}
	activeHeadNode = nil
	shieldRing = nil
end

local function findFreeCell(avoidNearHead)
	local free = {}
	local head = snake[1]
	for x = 1, COLS do
		for y = 1, ROWS do
			local busy = false
			for _, seg in ipairs(snake) do
				if seg.x == x and seg.y == y then busy = true break end
			end
			if not busy then
				for _, it in ipairs(boardItems) do
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
		-- Đồng xu vàng tự vẽ rơi trên bàn chơi (không bị lỗi ô vuông)
		node = Instance.new("Frame")
		node.Size = UDim2.fromOffset(CELL - 4, CELL - 4)
		node.AnchorPoint = Vector2.new(0.5, 0.5)
		node.Position = UDim2.fromOffset(cx, cy)
		node.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
		node.BorderSizePixel = 0
		node.ZIndex = 3
		node.Parent = itemLayer
		addCorner(node, 99)
		addStroke(node, Color3.fromRGB(161, 98, 7), 1.8)

		local sym = Instance.new("TextLabel")
		sym.Size = UDim2.fromScale(1, 1)
		sym.BackgroundTransparency = 1
		sym.Text = "$"
		sym.TextColor3 = Color3.fromRGB(146, 64, 14)
		sym.Font = Enum.Font.GothamBlack
		sym.TextSize = 14
		sym.ZIndex = 4
		sym.Parent = node
	else
		node = Instance.new("TextLabel")
		node.Size = UDim2.fromOffset(CELL, CELL)
		node.AnchorPoint = Vector2.new(0.5, 0.5)
		node.Position = UDim2.fromOffset(cx, cy)
		node.BackgroundTransparency = (itemType == "Power") and 0.72 or 1
		node.BackgroundColor3 = (customData and customData.Color) or Color3.fromRGB(255, 255, 255)
		node.Font = Enum.Font.GothamBold
		node.TextScaled = true
		node.ZIndex = 3
		if itemType == "Food" then node.Text = customData.Icon
		elseif itemType == "Gem" then node.Text = "💎"
		elseif itemType == "Power" then
			node.Text = customData.Icon
			addCorner(node, 99)
			addStroke(node, customData.Color, 1.5)
		elseif itemType == "Bomb" then node.Text = "💣" end
		node.Parent = itemLayer
	end

	table.insert(boardItems, {
		Type = itemType, X = pos.x, Y = pos.y,
		Data = customData, Node = node, Life = lifeTime
	})
end

local function ensureFoodExists()
	local count = 0
	for _, it in ipairs(boardItems) do
		if it.Type == "Food" then count += 1 end
	end
	while count < 2 do
		spawnItem("Food", FOODS[math.random(1, #FOODS)], nil)
		count += 1
	end
end

local function updateHUD()
	liveScoreLbl.Text = string.format("Điểm: %d   |   +%d Xu   |   +%d 💎", runScore, runCoins, runGems)
	local lines = {}
	if buffs.Double > 0 then table.insert(lines, string.format("⭐ 2x Điểm: %.1fs", buffs.Double)) end
	if buffs.Ghost  > 0 then table.insert(lines, string.format("👻 Bóng Ma: %.1fs", buffs.Ghost)) end
	if buffs.Magnet > 0 then table.insert(lines, string.format("🧲 Nam Châm: %.1fs", buffs.Magnet)) end
	if buffs.Speed  > 0 then table.insert(lines, string.format("⚡ Tăng Tốc: %.1fs", buffs.Speed)) end
	if buffs.Shield then table.insert(lines, "🛡️ Khiên: Sẵn sàng đỡ 1 đòn") end

	if #lines == 0 then
		buffStatusLbl.Text = "Chưa có buff nào\n⭐ 2x  👻 Ma  🛡️ Khiên\n🧲 Hút  ⚡ Nhanh  💣 Tránh"
		buffStatusLbl.TextColor3 = Color3.fromRGB(165, 175, 205)
	else
		buffStatusLbl.Text = table.concat(lines, "\n")
		buffStatusLbl.TextColor3 = Color3.fromRGB(254, 240, 138)
	end
end

local function syncSnakeNodes()
	local skin = getSkinById(state.EquippedSkin)
	if not activeHeadNode then
		activeHeadNode = buildCartoonHead(snakeLayer, CELL + 4, skin)
		shieldRing = Instance.new("Frame")
		shieldRing.Size = UDim2.fromScale(1.38, 1.38)
		shieldRing.Position = UDim2.fromScale(0.5, 0.5)
		shieldRing.AnchorPoint = Vector2.new(0.5, 0.5)
		shieldRing.BackgroundTransparency = 1
		shieldRing.Visible = false
		shieldRing.ZIndex = 12
		shieldRing.Parent = activeHeadNode
		addCorner(shieldRing, 99)
		addStroke(shieldRing, Color3.fromRGB(56, 189, 248), 2.5)
	end

	local needBody = #snake - 1
	while #bodyFrames < needBody do
		local idx = #bodyFrames + 1
		local seg = Instance.new("Frame")
		seg.AnchorPoint = Vector2.new(0.5, 0.5)
		seg.BackgroundColor3 = (idx % 2 == 0) and skin.Body1 or skin.Body2
		seg.BorderSizePixel = 0
		seg.ZIndex = 5
		seg.Parent = snakeLayer
		addCorner(seg, 99)
		addStroke(seg, Color3.fromRGB(12, 14, 22), 1.8)
		table.insert(bodyFrames, seg)
	end
	for i = 1, #bodyFrames do
		bodyFrames[i].Visible = (i <= needBody)
		if i <= needBody then
			local taper = (i > needBody - 3) and (CELL - 1 - (3 - (needBody - i)) * 2) or CELL
			taper = math.max(14, taper)
			bodyFrames[i].Size = UDim2.fromOffset(taper, taper)
		end
	end
end

local function renderSnakeSmooth(alpha)
	if #snake == 0 or not activeHeadNode then return end
	local skin = getSkinById(state.EquippedSkin)
	local ghostTrans = (buffs.Ghost > 0 or buffs.Invuln > 0) and 0.42 or 0

	for i = 1, #snake do
		local curr = snake[i]
		local prev = prevSnake[i] or curr
		local gx, gy
		if math.abs(curr.x - prev.x) > 1 or math.abs(curr.y - prev.y) > 1 then
			gx, gy = curr.x, curr.y
		else
			gx = prev.x + (curr.x - prev.x) * alpha
			gy = prev.y + (curr.y - prev.y) * alpha
		end
		local px, py = cellToCenter(gx, gy)

		if i == 1 then
			activeHeadNode.Position = UDim2.fromOffset(px, py)
			activeHeadNode.Rotation = dirToAngle(dir)
			activeHeadNode.BackgroundTransparency = ghostTrans
			if shieldRing then shieldRing.Visible = buffs.Shield end
			if skin.Rainbow then
				activeHeadNode.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.45) % 1, 0.85, 1)
			end
		else
			local node = bodyFrames[i - 1]
			if node then
				node.Position = UDim2.fromOffset(px, py)
				node.BackgroundTransparency = ghostTrans
				if skin.Rainbow then
					node.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.45 + i * 0.06) % 1, 0.85, 1)
				end
			end
		end
	end
end

local function queueTurn(dx, dy)
	if not playing or paused then return end
	local last = (#turnQueue > 0) and turnQueue[#turnQueue] or dir
	if (dx == -last.x and dy == -last.y) or (dx == last.x and dy == last.y) then return end
	if #turnQueue < 2 then
		table.insert(turnQueue, { x = dx, y = dy })
	end
end

local function endRun(reasonText)
	playing = false
	local isRecord = false
	if runScore > state.HighScore then
		state.HighScore = runScore
		isRecord = true
	end
	state.Coins += runCoins
	state.Gems  += runGems
	addQuestProgress("games", 1, false)
	addQuestProgress("score", runScore, true)
	addExp(math.floor(runScore * 0.4) + 10) -- addExp tự gọi updateTopStats() và saveData()

	goTitle.Text = "💀 " .. reasonText
	goStats.Text = string.format(
		"Điểm ván này: %d %s\nNhận: +%d Xu  |  +%d 💎  (Đã tự lưu!)",
		runScore, isRecord and "🏆(KỶ LỤC!)" or "", runCoins, runGems
	)
	gameOverCard.Visible = true
end

local function startNewRun()
	clearItems()
	clearSnakeVisuals()
	gameOverCard.Visible = false
	dpadFrame.Visible = state.Settings.ShowDpad

	snake = { { x = 6, y = 6 }, { x = 5, y = 6 }, { x = 4, y = 6 }, { x = 3, y = 6 } }
	prevSnake = {}
	for i, s in ipairs(snake) do prevSnake[i] = { x = s.x, y = s.y } end

	dir = { x = 1, y = 0 }
	turnQueue = {}
	runScore, runCoins, runGems = 0, 0, 0
	buffs = { Double = 0, Ghost = 0, Magnet = 0, Speed = 0, Shield = false, Invuln = 0 }
	stepTimer, powerSpawnTimer, bombSpawnTimer = 0, 4, 6
	paused = false
	pauseBtn.Text = "II"
	playing = true

	syncSnakeNodes()
	ensureFoodExists()
	spawnItem("Coin", nil, 15)
	updateHUD()
	renderSnakeSmooth(1)
end

local function openLobby()
	if playing and (runCoins > 0 or runGems > 0 or runScore > 0) then
		-- Lưu lại phần thưởng người chơi vừa nhặt nếu thoát sớm về Sảnh
		state.Coins += runCoins
		state.Gems  += runGems
		if runScore > state.HighScore then state.HighScore = runScore end
		runScore, runCoins, runGems = 0, 0, 0
		saveData()
	end
	playing = false
	paused = false
	gamePage.Visible = false
	lobbyPage.Visible = true
	rebuildLobbyPreview()
	updateTopStats()
end

local function openGame()
	modalOverlay.Visible = false
	activeModalTag = nil
	liveGiftBtn = nil
	lobbyPage.Visible = false
	gamePage.Visible = true
	startNewRun()
end

local function stepSnakeLogic()
	if #turnQueue > 0 then dir = table.remove(turnQueue, 1) end
	prevSnake = {}
	for i, s in ipairs(snake) do prevSnake[i] = { x = s.x, y = s.y } end

	local head = snake[1]
	local nx, ny = head.x + dir.x, head.y + dir.y

	local canWrap = state.Settings.WallPass or buffs.Ghost > 0 or buffs.Invuln > 0
	if nx < 1 or nx > COLS or ny < 1 or ny > ROWS then
		if canWrap then
			if nx < 1 then nx = COLS elseif nx > COLS then nx = 1 end
			if ny < 1 then ny = ROWS elseif ny > ROWS then ny = 1 end
		elseif buffs.Shield then
			buffs.Shield = false
			buffs.Invuln = 1.6
			if nx < 1 then nx = COLS elseif nx > COLS then nx = 1 end
			if ny < 1 then ny = ROWS elseif ny > ROWS then ny = 1 end
		else
			endRun("ĐỤNG TƯỜNG!")
			return
		end
	end

	if buffs.Magnet > 0 then
		for _, it in ipairs(boardItems) do
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

	local grew = false
	for i = #boardItems, 1, -1 do
		local it = boardItems[i]
		if it.X == nx and it.Y == ny then
			local mult = (buffs.Double > 0 and 2 or 1) * (buffs.Speed > 0 and 1.5 or 1)
			if it.Type == "Food" then
				grew = true
				runScore += math.floor(it.Data.Score * mult)
				runCoins += math.floor(it.Data.Coins * mult)
				addQuestProgress("eat", 1, false)
				addQuestProgress("score", runScore, true)
				it.Node:Destroy()
				table.remove(boardItems, i)
			elseif it.Type == "Coin" then
				runCoins += math.floor(25 * mult)
				runScore += math.floor(15 * mult)
				it.Node:Destroy()
				table.remove(boardItems, i)
			elseif it.Type == "Gem" then
				runGems += 2
				runScore += math.floor(30 * mult)
				it.Node:Destroy()
				table.remove(boardItems, i)
			elseif it.Type == "Power" then
				local pId = it.Data.Id
				if pId == "Double" then buffs.Double = 10
				elseif pId == "Ghost" then buffs.Ghost = 8
				elseif pId == "Magnet" then buffs.Magnet = 10
				elseif pId == "Speed" then buffs.Speed = 7
				elseif pId == "Shield" then buffs.Shield = true end
				addQuestProgress("power", 1, false)
				it.Node:Destroy()
				table.remove(boardItems, i)
			elseif it.Type == "Bomb" then
				it.Node:Destroy()
				table.remove(boardItems, i)
				if buffs.Ghost <= 0 and buffs.Invuln <= 0 then
					if buffs.Shield then
						buffs.Shield = false
						buffs.Invuln = 1.6
					else
						endRun("TRÚNG BOM!")
						return
					end
				end
			end
		end
	end

	if not grew then
		table.remove(snake)
	else
		table.insert(prevSnake, prevSnake[#prevSnake])
	end

	if buffs.Ghost <= 0 and buffs.Invuln <= 0 then
		for _, seg in ipairs(snake) do
			if seg.x == nx and seg.y == ny then
				if buffs.Shield then
					buffs.Shield = false
					buffs.Invuln = 1.6
					break
				else
					endRun("TỰ CẮN THÂN!")
					return
				end
			end
		end
	end

	table.insert(snake, 1, { x = nx, y = ny })
	syncSnakeNodes()
	ensureFoodExists()

	if grew then
		local roll = math.random(1, 100)
		if roll <= 22 then spawnItem("Coin", nil, 14)
		elseif roll <= 30 then spawnItem("Gem", nil, 12) end
	end
	updateHUD()
end

-- Vòng lặp chính (Animation Sảnh + Đếm ngược Quà + Chuyển động Game)
local lastSecondCheck = 0
track(RunService.RenderStepped:Connect(function(dt)
	dt = math.min(dt, 0.05)

	-- Cập nhật chấm thông báo & đồng hồ Quà Tặng mỗi giây
	local nowSec = os.time()
	if nowSec ~= lastSecondCheck then
		lastSecondCheck = nowSec
		refreshNotifDots()
		if modalOverlay.Visible and activeModalTag == "Gift" and liveGiftBtn and liveGiftBtn.Parent then
			local remain = math.max(0, state.NextGiftUnix - nowSec)
			if remain <= 0 then
				if liveGiftBtn.Text ~= "🎉 NHẬN QUÀ NGAY!" then openGift() end
			else
				liveGiftBtn.Text = "⏳ CHỜ " .. remain .. " GIÂY"
			end
		end
	end

	-- Animation rắn ngoài Sảnh (nối khít từng đốt)
	if mainFrame.Visible and lobbyPage.Visible and previewHead then
		local t = os.clock() * 3.2
		local skin = getSkinById(state.EquippedSkin)
		local hx = 246
		local hy = 48 + math.sin(t) * 14
		previewHead.Position = UDim2.fromOffset(hx, hy)
		previewHead.Rotation = math.cos(t) * 14
		if skin.Rainbow then
			previewHead.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.4) % 1, 0.85, 1)
		end
		for i, seg in ipairs(previewSegs) do
			local sx = hx - (i * 16.5) -- Khoảng cách khít, không hở đuôi
			local sy = 48 + math.sin(t - i * 0.42) * 14
			seg.Position = UDim2.fromOffset(sx, sy)
			if skin.Rainbow then
				seg.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.4 + i * 0.07) % 1, 0.85, 1)
			end
		end
	end

	if not mainFrame.Visible or not gamePage.Visible or not playing or paused then return end

	local buffChanged = false
	for _, key in ipairs({ "Double", "Ghost", "Magnet", "Speed", "Invuln" }) do
		if buffs[key] > 0 then
			buffs[key] = math.max(0, buffs[key] - dt)
			buffChanged = true
		end
	end

	for i = #boardItems, 1, -1 do
		local it = boardItems[i]
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
				table.remove(boardItems, i)
			end
		end
	end

	powerSpawnTimer -= dt
	if powerSpawnTimer <= 0 then
		powerSpawnTimer = math.random(8, 13)
		spawnItem("Power", POWERUPS[math.random(1, #POWERUPS)], 10)
	end

	if state.Settings.BombsEnabled then
		bombSpawnTimer -= dt
		if bombSpawnTimer <= 0 then
			bombSpawnTimer = math.random(9, 14)
			spawnItem("Bomb", nil, 11)
		end
	end

	local baseSpeeds = { 0.21, 0.16, 0.115 }
	local speed = baseSpeeds[state.Settings.SpeedMode] or 0.16
	speed = math.max(0.085, speed - math.min(0.04, runScore * 0.0001))
	if buffs.Speed > 0 then speed *= 0.72 end
	stepDuration = speed

	stepTimer += dt
	while stepTimer >= stepDuration and playing do
		stepTimer -= stepDuration
		stepSnakeLogic()
	end

	if playing then
		renderSnakeSmooth(math.clamp(stepTimer / stepDuration, 0, 1))
		if buffChanged then updateHUD() end
	end
end))

-- ============================================================
-- KẾT NỐI NÚT BẤM, PHÍM TẮT & LƯU KHI ĐÓNG
-- ============================================================
playBtn.MouseButton1Click:Connect(openGame)
restartBtn.MouseButton1Click:Connect(startNewRun)
goReplayBtn.MouseButton1Click:Connect(startNewRun)
lobbyBtn.MouseButton1Click:Connect(openLobby)
goLobbyBtn.MouseButton1Click:Connect(openLobby)

pauseBtn.MouseButton1Click:Connect(function()
	if not playing then return end
	paused = not paused
	pauseBtn.Text = paused and "▶" or "II"
end)

dUp.MouseButton1Click:Connect(function() queueTurn(0, -1) end)
dDown.MouseButton1Click:Connect(function() queueTurn(0, 1) end)
dLeft.MouseButton1Click:Connect(function() queueTurn(-1, 0) end)
dRight.MouseButton1Click:Connect(function() queueTurn(1, 0) end)

local function minimizeMenu()
	if playing then paused = true pauseBtn.Text = "▶" end
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

minBtn.MouseButton1Click:Connect(minimizeMenu)
floatBtn.MouseButton1Click:Connect(function()
	if not floatDragged then restoreMenu() end
end)

local function destroyMenu()
	if playing and (runCoins > 0 or runGems > 0 or runScore > 0) then
		state.Coins += runCoins
		state.Gems  += runGems
		if runScore > state.HighScore then state.HighScore = runScore end
	end
	saveData()
	screenGui:Destroy()
end
closeBtn.MouseButton1Click:Connect(destroyMenu)
exitBtn.MouseButton1Click:Connect(destroyMenu)

track(UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if mainFrame.Visible then minimizeMenu() else restoreMenu() end
		return
	end
	if not mainFrame.Visible or not gamePage.Visible then return end
	if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.W then queueTurn(0, -1)
	elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then queueTurn(0, 1)
	elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then queueTurn(-1, 0)
	elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then queueTurn(1, 0)
	elseif input.KeyCode == Enum.KeyCode.Space and playing then
		paused = not paused
		pauseBtn.Text = paused and "▶" or "II"
	end
end))

local cam = workspace.CurrentCamera
if cam then
	track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if mainFrame.Visible then uiScale.Scale = calcScale() end
	end))
end

screenGui.Destroying:Connect(function()
	playing = false
	for _, c in ipairs(connections) do
		if c.Connected then c:Disconnect() end
	end
end)

-- Khởi chạy Sảnh Chờ & lưu khởi tạo lần đầu
rebuildLobbyPreview()
updateTopStats()
if not hadSavedData then saveData() end
