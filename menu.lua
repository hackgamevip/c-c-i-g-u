-- ============================================================
-- STANDALONE MINI GAME HUB (CHẠY ĐỘC LẬP - PC & MOBILE)
-- Phím tắt ẩn/hiện nhanh trên PC: RightShift
-- ============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local GUI_NAME = "StandaloneMiniGameHub"

-- Chọn nơi gắn GUI an toàn (chạy được trên cả Executor và Studio)
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

-- Xóa bản cũ nếu chạy lại script
local existing = guiParent:FindFirstChild(GUI_NAME)
if existing then existing:Destroy() end

local connections = {}
local function track(conn)
	table.insert(connections, conn)
	return conn
end

-- ============================================================
-- HÀM HỖ TRỢ GIAO DIỆN & KÉO THẢ
-- ============================================================
local function addCorner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(58, 66, 90)
	s.Thickness = thickness or 1.2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function makeBtn(parent, text, size, pos, bgColor)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos or UDim2.new()
	b.BackgroundColor3 = bgColor or Color3.fromRGB(38, 44, 62)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = text
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.Parent = parent
	addCorner(b, 7)
	return b
end

-- Kéo thả có phân biệt giữa bấm (click) và kéo (drag)
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
			if onMovedFlag and delta.Magnitude > 6 then
				onMovedFlag(true)
			end
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end))
end

-- ============================================================
-- KHUNG MENU CHÍNH & NÚT THU GỌN
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

-- Nút nổi khi thu gọn menu (kéo thả được, bấm để mở lại)
local floatBtn = makeBtn(
	screenGui,
	"🎮",
	UDim2.fromOffset(48, 48),
	UDim2.new(0, 18, 0.5, -24),
	Color3.fromRGB(37, 99, 235)
)
floatBtn.TextSize = 22
floatBtn.Visible = false
addCorner(floatBtn, 24)
addStroke(floatBtn, Color3.fromRGB(147, 197, 253), 1.8)

local floatWasDragged = false
makeDraggable(floatBtn, floatBtn, function(v) floatWasDragged = v end)

-- Cửa sổ chính (540 x 350)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(540, 350)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
addCorner(mainFrame, 12)
addStroke(mainFrame, Color3.fromRGB(63, 72, 102), 1.5)

-- Tự co giãn trên màn hình điện thoại nhỏ
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

local function updateResponsiveScale()
	local cam = workspace.CurrentCamera
	if not cam then return 1 end
	local vp = cam.ViewportSize
	local scaleX = (vp.X - 24) / 540
	local scaleY = (vp.Y - 24) / 350
	return math.clamp(math.min(1, scaleX, scaleY), 0.55, 1)
end
uiScale.Scale = updateResponsiveScale()

-- Thanh tiêu đề (TopBar)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
makeDraggable(topBar, mainFrame)

local topDivider = Instance.new("Frame")
topDivider.Size = UDim2.new(1, 0, 0, 1)
topDivider.Position = UDim2.new(0, 0, 1, -1)
topDivider.BackgroundColor3 = Color3.fromRGB(45, 52, 74)
topDivider.BorderSizePixel = 0
topDivider.Parent = topBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -180, 1, 0)
titleLbl.Position = UDim2.fromOffset(14, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "🎮 MINI GAME HUB"
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local hotkeyLbl = Instance.new("TextLabel")
hotkeyLbl.Size = UDim2.fromOffset(105, 40)
hotkeyLbl.Position = UDim2.new(1, -180, 0, 0)
hotkeyLbl.BackgroundTransparency = 1
hotkeyLbl.Text = "[RightShift]"
hotkeyLbl.TextColor3 = Color3.fromRGB(120, 132, 160)
hotkeyLbl.Font = Enum.Font.Gotham
hotkeyLbl.TextSize = 11
hotkeyLbl.TextXAlignment = Enum.TextXAlignment.Right
hotkeyLbl.Parent = topBar

local minBtn = makeBtn(topBar, "—", UDim2.fromOffset(28, 26), UDim2.new(1, -68, 0, 7), Color3.fromRGB(55, 65, 85))
local closeBtn = makeBtn(topBar, "✕", UDim2.fromOffset(28, 26), UDim2.new(1, -34, 0, 7), Color3.fromRGB(220, 38, 38))

-- Sidebar chọn game bên trái
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.fromOffset(135, 294)
sidebar.Position = UDim2.fromOffset(10, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
addCorner(sidebar, 10)
addStroke(sidebar, Color3.fromRGB(42, 48, 68), 1)

local sideList = Instance.new("Frame")
sideList.Size = UDim2.new(1, -12, 1, -44)
sideList.Position = UDim2.fromOffset(6, 8)
sideList.BackgroundTransparency = 1
sideList.Parent = sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 7)
sideLayout.Parent = sideList

local sideFooter = Instance.new("TextLabel")
sideFooter.Size = UDim2.new(1, -10, 0, 28)
sideFooter.Position = UDim2.new(0, 5, 1, -32)
sideFooter.BackgroundTransparency = 1
sideFooter.Text = "4 Mini Games\nSẵn sàng chơi"
sideFooter.TextColor3 = Color3.fromRGB(115, 126, 152)
sideFooter.Font = Enum.Font.Gotham
sideFooter.TextSize = 10
sideFooter.Parent = sidebar

-- Khung nội dung game bên phải (375 x 294)
local gameArea = Instance.new("Frame")
gameArea.Size = UDim2.fromOffset(375, 294)
gameArea.Position = UDim2.fromOffset(155, 48)
gameArea.BackgroundTransparency = 1
gameArea.Parent = mainFrame

local tabs = {}
local activeTab = nil

local function registerGame(id, labelText)
	local btn = makeBtn(sideList, labelText, UDim2.new(1, 0, 0, 40), nil, Color3.fromRGB(32, 37, 52))
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextSize = 13

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.Parent = btn

	local page = Instance.new("Frame")
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = gameArea

	local entry = { Id = id, Btn = btn, Page = page, OnOpen = nil, OnClose = nil }
	tabs[id] = entry
	return entry
end

local function switchGame(id)
	for gId, entry in pairs(tabs) do
		if gId == id then
			entry.Page.Visible = true
			TweenService:Create(entry.Btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(37, 99, 235) }):Play()
			if entry.OnOpen then entry.OnOpen() end
		else
			if entry.Page.Visible and entry.OnClose then entry.OnClose() end
			entry.Page.Visible = false
			TweenService:Create(entry.Btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(32, 37, 52) }):Play()
		end
	end
	activeTab = id
end

-- ============================================================
-- GAME 1: RẮN SĂN MỒI (CÓ CHẾ ĐỘ XUYÊN TƯỜNG)
-- ============================================================
local snakeGame = registerGame("Snake", "🐍 Rắn Săn Mồi")
local S_GRID, S_CELL = 15, 16

local snakeScoreLbl = Instance.new("TextLabel")
snakeScoreLbl.Size = UDim2.fromOffset(172, 28)
snakeScoreLbl.BackgroundTransparency = 1
snakeScoreLbl.Text = "Điểm: 0  |  Kỷ lục: 0"
snakeScoreLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
snakeScoreLbl.Font = Enum.Font.GothamBold
snakeScoreLbl.TextSize = 13
snakeScoreLbl.TextXAlignment = Enum.TextXAlignment.Left
snakeScoreLbl.Parent = snakeGame.Page

local wallPass = false
local wallToggleBtn = makeBtn(snakeGame.Page, "Xuyên tường: TẮT", UDim2.fromOffset(114, 28), UDim2.fromOffset(174, 0), Color3.fromRGB(51, 65, 85))
wallToggleBtn.TextSize = 11

local snakeResetBtn = makeBtn(snakeGame.Page, "🔄 Chơi lại", UDim2.fromOffset(80, 28), UDim2.fromOffset(295, 0), Color3.fromRGB(22, 163, 74))
snakeResetBtn.TextSize = 11

local snakeBoard = Instance.new("Frame")
snakeBoard.Size = UDim2.fromOffset(S_GRID * S_CELL, S_GRID * S_CELL)
snakeBoard.Position = UDim2.fromOffset(0, 38)
snakeBoard.BackgroundColor3 = Color3.fromRGB(11, 14, 22)
snakeBoard.BorderSizePixel = 0
snakeBoard.Parent = snakeGame.Page
addCorner(snakeBoard, 6)
addStroke(snakeBoard, Color3.fromRGB(45, 55, 78), 1)

local snakeCells = {}
for x = 1, S_GRID do
	snakeCells[x] = {}
	for y = 1, S_GRID do
		local c = Instance.new("Frame")
		c.Size = UDim2.fromOffset(S_CELL - 1, S_CELL - 1)
		c.Position = UDim2.fromOffset((x - 1) * S_CELL, (y - 1) * S_CELL)
		c.BorderSizePixel = 0
		c.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
		c.Parent = snakeBoard
		snakeCells[x][y] = c
	end
end

local snakeOverLbl = Instance.new("TextLabel")
snakeOverLbl.Size = UDim2.new(1, -16, 0, 52)
snakeOverLbl.Position = UDim2.fromScale(0.5, 0.5)
snakeOverLbl.AnchorPoint = Vector2.new(0.5, 0.5)
snakeOverLbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
snakeOverLbl.BackgroundTransparency = 0.2
snakeOverLbl.TextColor3 = Color3.fromRGB(248, 113, 113)
snakeOverLbl.Font = Enum.Font.GothamBlack
snakeOverLbl.TextSize = 14
snakeOverLbl.Visible = false
snakeOverLbl.ZIndex = 5
snakeOverLbl.Parent = snakeBoard
addCorner(snakeOverLbl, 8)

local snakeHint = Instance.new("TextLabel")
snakeHint.Size = UDim2.fromOffset(127, 40)
snakeHint.Position = UDim2.fromOffset(248, 42)
snakeHint.BackgroundTransparency = 1
snakeHint.Text = "WASD / Mũi tên\nhoặc bấm nút dưới"
snakeHint.TextColor3 = Color3.fromRGB(148, 163, 184)
snakeHint.Font = Enum.Font.Gotham
snakeHint.TextSize = 11
snakeHint.Parent = snakeGame.Page

local sUp    = makeBtn(snakeGame.Page, "▲", UDim2.fromOffset(38, 38), UDim2.fromOffset(292, 104))
local sLeft  = makeBtn(snakeGame.Page, "◄", UDim2.fromOffset(38, 38), UDim2.fromOffset(250, 146))
local sRight = makeBtn(snakeGame.Page, "►", UDim2.fromOffset(38, 38), UDim2.fromOffset(334, 146))
local sDown  = makeBtn(snakeGame.Page, "▼", UDim2.fromOffset(38, 38), UDim2.fromOffset(292, 188))

local snakeBody, sDir, sNextDir, sFood = {}, { x = 1, y = 0 }, { x = 1, y = 0 }, nil
local sScore, sBest, sAlive, sRunId = 0, 0, false, 0

local function setSnakeDir(dx, dy)
	if not sAlive or (dx == -sDir.x and dy == -sDir.y) then return end
	sNextDir = { x = dx, y = dy }
end

local function spawnSnakeFood()
	local empty = {}
	for x = 1, S_GRID do
		for y = 1, S_GRID do
			local busy = false
			for _, seg in ipairs(snakeBody) do
				if seg.x == x and seg.y == y then busy = true break end
			end
			if not busy then table.insert(empty, { x = x, y = y }) end
		end
	end
	sFood = #empty > 0 and empty[math.random(1, #empty)] or nil
end

local function renderSnake()
	for x = 1, S_GRID do
		for y = 1, S_GRID do
			snakeCells[x][y].BackgroundColor3 = Color3.fromRGB(22, 28, 42)
		end
	end
	if sFood then
		snakeCells[sFood.x][sFood.y].BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	end
	for i, seg in ipairs(snakeBody) do
		snakeCells[seg.x][seg.y].BackgroundColor3 = (i == 1) and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(22, 163, 74)
	end
end

local function stopSnake()
	sAlive = false
	sRunId += 1
end

local function startSnake()
	stopSnake()
	local myId = sRunId
	snakeBody = { { x = 7, y = 8 }, { x = 6, y = 8 }, { x = 5, y = 8 } }
	sDir, sNextDir = { x = 1, y = 0 }, { x = 1, y = 0 }
	sScore = 0
	sAlive = true
	snakeOverLbl.Visible = false
	snakeScoreLbl.Text = "Điểm: 0  |  Kỷ lục: " .. sBest
	spawnSnakeFood()
	renderSnake()

	task.spawn(function()
		while sAlive and myId == sRunId do
			task.wait(math.max(0.08, 0.21 - sScore * 0.004))
			if not sAlive or myId ~= sRunId then break end
			sDir = sNextDir
			local head = snakeBody[1]
			local nh = { x = head.x + sDir.x, y = head.y + sDir.y }

			if wallPass then
				if nh.x < 1 then nh.x = S_GRID elseif nh.x > S_GRID then nh.x = 1 end
				if nh.y < 1 then nh.y = S_GRID elseif nh.y > S_GRID then nh.y = 1 end
			else
				if nh.x < 1 or nh.x > S_GRID or nh.y < 1 or nh.y > S_GRID then
					sAlive = false
					snakeOverLbl.Text = "ĐỤNG TƯỜNG! (" .. sScore .. " điểm)"
					snakeOverLbl.Visible = true
					break
				end
			end

			local ate = sFood and (nh.x == sFood.x and nh.y == sFood.y)
			if not ate then table.remove(snakeBody) end

			local hitSelf = false
			for _, seg in ipairs(snakeBody) do
				if seg.x == nh.x and seg.y == nh.y then hitSelf = true break end
			end
			if hitSelf then
				sAlive = false
				snakeOverLbl.Text = "TỰ CẮN THÂN! (" .. sScore .. " điểm)"
				snakeOverLbl.Visible = true
				break
			end

			table.insert(snakeBody, 1, nh)
			if ate then
				sScore += 1
				if sScore > sBest then sBest = sScore end
				snakeScoreLbl.Text = "Điểm: " .. sScore .. "  |  Kỷ lục: " .. sBest
				spawnSnakeFood()
				if not sFood then
					sAlive = false
					snakeOverLbl.Text = "PHÁ ĐẢO! (" .. sScore .. " điểm)"
					snakeOverLbl.Visible = true
					break
				end
			end
			renderSnake()
		end
	end)
end

wallToggleBtn.MouseButton1Click:Connect(function()
	wallPass = not wallPass
	wallToggleBtn.Text = wallPass and "Xuyên tường: BẬT" or "Xuyên tường: TẮT"
	wallToggleBtn.BackgroundColor3 = wallPass and Color3.fromRGB(37, 99, 235) or Color3.fromRGB(51, 65, 85)
end)

sUp.MouseButton1Click:Connect(function() setSnakeDir(0, -1) end)
sDown.MouseButton1Click:Connect(function() setSnakeDir(0, 1) end)
sLeft.MouseButton1Click:Connect(function() setSnakeDir(-1, 0) end)
sRight.MouseButton1Click:Connect(function() setSnakeDir(1, 0) end)
snakeResetBtn.MouseButton1Click:Connect(startSnake)
snakeGame.OnOpen = startSnake
snakeGame.OnClose = stopSnake

-- ============================================================
-- GAME 2: CỜ CARO 3x3 (VS BOT)
-- ============================================================
local caroGame = registerGame("Caro", "❌⭕ Cờ Caro")

local caroGrid = Instance.new("Frame")
caroGrid.Size = UDim2.fromOffset(232, 232)
caroGrid.Position = UDim2.fromOffset(6, 30)
caroGrid.BackgroundTransparency = 1
caroGrid.Parent = caroGame.Page

local caroStatus = Instance.new("TextLabel")
caroStatus.Size = UDim2.fromOffset(127, 48)
caroStatus.Position = UDim2.fromOffset(248, 38)
caroStatus.BackgroundTransparency = 1
caroStatus.Text = "Lượt của bạn (X)"
caroStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
caroStatus.Font = Enum.Font.GothamBold
caroStatus.TextSize = 14
caroStatus.TextWrapped = true
caroStatus.Parent = caroGame.Page

local caroScoreLbl = Instance.new("TextLabel")
caroScoreLbl.Size = UDim2.fromOffset(127, 68)
caroScoreLbl.Position = UDim2.fromOffset(248, 94)
caroScoreLbl.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
caroScoreLbl.Text = "Bạn: 0\nHòa: 0\nBot: 0"
caroScoreLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
caroScoreLbl.Font = Enum.Font.GothamBold
caroScoreLbl.TextSize = 13
caroScoreLbl.Parent = caroGame.Page
addCorner(caroScoreLbl, 8)

local caroResetBtn = makeBtn(caroGame.Page, "🔄 Ván mới", UDim2.fromOffset(118, 36), UDim2.fromOffset(252, 180), Color3.fromRGB(22, 163, 74))

local tttBoard, tttBtns = {}, {}
local tttOver, tttLock = false, false
local pWin, draws, bWin = 0, 0, 0
local winLines = { {1,2,3},{4,5,6},{7,8,9},{1,4,7},{2,5,8},{3,6,9},{1,5,9},{3,5,7} }

local function checkTTT(b)
	for _, l in ipairs(winLines) do
		if b[l[1]] ~= "" and b[l[1]] == b[l[2]] and b[l[2]] == b[l[3]] then
			return b[l[1]], l
		end
	end
	for i = 1, 9 do if b[i] == "" then return nil end end
	return "DRAW"
end

local function findMove(sym)
	for i = 1, 9 do
		if tttBoard[i] == "" then
			tttBoard[i] = sym
			local w = checkTTT(tttBoard)
			tttBoard[i] = ""
			if w == sym then return i end
		end
	end
	return nil
end

local function resetCaro()
	tttOver, tttLock = false, false
	caroStatus.Text = "Lượt của bạn (X)"
	caroStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
	for i = 1, 9 do
		tttBoard[i] = ""
		tttBtns[i].Text = ""
		tttBtns[i].BackgroundColor3 = Color3.fromRGB(32, 38, 54)
	end
end

local function endCaro(res, line)
	tttOver = true
	if line then
		for _, idx in ipairs(line) do
			tttBtns[idx].BackgroundColor3 = (res == "X") and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(185, 28, 28)
		end
	end
	if res == "X" then
		pWin += 1
		caroStatus.Text = "🎉 Bạn thắng!"
		caroStatus.TextColor3 = Color3.fromRGB(74, 222, 128)
	elseif res == "O" then
		bWin += 1
		caroStatus.Text = "🤖 Bot thắng!"
		caroStatus.TextColor3 = Color3.fromRGB(248, 113, 113)
	else
		draws += 1
		caroStatus.Text = "🤝 Hòa nhau!"
		caroStatus.TextColor3 = Color3.fromRGB(250, 204, 21)
	end
	caroScoreLbl.Text = "Bạn: " .. pWin .. "\nHòa: " .. draws .. "\nBot: " .. bWin
end

for i = 1, 9 do
	local r, c = math.floor((i - 1) / 3), (i - 1) % 3
	local btn = makeBtn(caroGrid, "", UDim2.fromOffset(72, 72), UDim2.fromOffset(c * 80, r * 80), Color3.fromRGB(32, 38, 54))
	btn.TextSize = 30
	tttBtns[i] = btn
	tttBoard[i] = ""

	btn.MouseButton1Click:Connect(function()
		if tttOver or tttLock or tttBoard[i] ~= "" then return end
		tttBoard[i] = "X"
		btn.Text = "X"
		btn.TextColor3 = Color3.fromRGB(96, 165, 250)

		local w, line = checkTTT(tttBoard)
		if w then endCaro(w, line) return end

		tttLock = true
		caroStatus.Text = "Bot đang tính..."
		task.delay(0.25, function()
			if tttOver then return end
			local move = findMove("O") or findMove("X")
			if not move and tttBoard[5] == "" then move = 5 end
			if not move then
				local empty = {}
				for k = 1, 9 do if tttBoard[k] == "" then table.insert(empty, k) end end
				if #empty > 0 then move = empty[math.random(1, #empty)] end
			end
			if move then
				tttBoard[move] = "O"
				tttBtns[move].Text = "O"
				tttBtns[move].TextColor3 = Color3.fromRGB(248, 113, 113)
			end
			local bw, bline = checkTTT(tttBoard)
			if bw then
				endCaro(bw, bline)
			else
				caroStatus.Text = "Lượt của bạn (X)"
				tttLock = false
			end
		end)
	end)
end
caroResetBtn.MouseButton1Click:Connect(resetCaro)

-- ============================================================
-- GAME 3: FLAPPY BOX
-- ============================================================
local flappyGame = registerGame("Flappy", "🐤 Flappy Box")
local F_AREA_W, F_AREA_H = 375, 256

local fScoreLbl = Instance.new("TextLabel")
fScoreLbl.Size = UDim2.fromOffset(375, 26)
fScoreLbl.BackgroundTransparency = 1
fScoreLbl.Text = "Điểm: 0  |  Kỷ lục: 0   (Bấm khung / Space để bay)"
fScoreLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
fScoreLbl.Font = Enum.Font.GothamBold
fScoreLbl.TextSize = 12
fScoreLbl.TextXAlignment = Enum.TextXAlignment.Left
fScoreLbl.Parent = flappyGame.Page

local fArea = Instance.new("TextButton")
fArea.Size = UDim2.fromOffset(F_AREA_W, F_AREA_H)
fArea.Position = UDim2.fromOffset(0, 32)
fArea.BackgroundColor3 = Color3.fromRGB(13, 19, 34)
fArea.Text = ""
fArea.AutoButtonColor = false
fArea.ClipsDescendants = true
fArea.BorderSizePixel = 0
fArea.Parent = flappyGame.Page
addCorner(fArea, 8)
addStroke(fArea, Color3.fromRGB(45, 55, 78), 1)

local bird = Instance.new("Frame")
bird.Size = UDim2.fromOffset(22, 22)
bird.Position = UDim2.fromOffset(70, 110)
bird.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
bird.BorderSizePixel = 0
bird.ZIndex = 3
bird.Parent = fArea
addCorner(bird, 6)

local fMsg = Instance.new("TextLabel")
fMsg.Size = UDim2.new(1, -24, 0, 46)
fMsg.Position = UDim2.fromScale(0.5, 0.5)
fMsg.AnchorPoint = Vector2.new(0.5, 0.5)
fMsg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fMsg.BackgroundTransparency = 0.25
fMsg.Text = "BẤM VÀO KHUNG ĐỂ BẮT ĐẦU!"
fMsg.TextColor3 = Color3.fromRGB(255, 255, 255)
fMsg.Font = Enum.Font.GothamBlack
fMsg.TextSize = 13
fMsg.ZIndex = 5
fMsg.Parent = fArea
addCorner(fMsg, 8)

local fPlaying, fScore, fBest = false, 0, 0
local birdY, birdVel, pipeTimer = 110, 0, 0
local pipes = {}

local function clearPipes()
	for _, p in ipairs(pipes) do
		if p.Top then p.Top:Destroy() end
		if p.Bot then p.Bot:Destroy() end
	end
	pipes = {}
end

local function stopFlappy(msg)
	fPlaying = false
	if msg then
		fMsg.Text = msg
		fMsg.Visible = true
	end
end

local function startFlappy()
	clearPipes()
	fScore, birdY, birdVel, pipeTimer = 0, 110, -230, 0.9
	fPlaying = true
	fMsg.Visible = false
	bird.Position = UDim2.fromOffset(70, birdY)
	fScoreLbl.Text = "Điểm: 0  |  Kỷ lục: " .. fBest .. "   (Bấm khung / Space để bay)"
end

local function flap()
	if not fPlaying then startFlappy() else birdVel = -235 end
end

fArea.MouseButton1Click:Connect(flap)
flappyGame.OnClose = function() stopFlappy("BẤM VÀO KHUNG ĐỂ CHƠI TIẾP!") end

track(RunService.RenderStepped:Connect(function(dt)
	if not fPlaying or not mainFrame.Visible or not flappyGame.Page.Visible then return end
	dt = math.min(dt, 0.05)

	birdVel += 680 * dt
	birdY += birdVel * dt
	bird.Position = UDim2.fromOffset(70, birdY)

	if birdY < 0 or birdY + 22 > F_AREA_H then
		stopFlappy("RỚT RỒI! Điểm: " .. fScore .. " (Bấm để chơi lại)")
		return
	end

	pipeTimer += dt
	if pipeTimer >= 1.45 then
		pipeTimer = 0
		local gap = 84
		local topH = math.random(28, F_AREA_H - gap - 28)

		local topP = Instance.new("Frame")
		topP.Size = UDim2.fromOffset(38, topH)
		topP.Position = UDim2.fromOffset(F_AREA_W, 0)
		topP.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		topP.BorderSizePixel = 0
		topP.Parent = fArea

		local botP = Instance.new("Frame")
		botP.Size = UDim2.fromOffset(38, F_AREA_H - topH - gap)
		botP.Position = UDim2.fromOffset(F_AREA_W, topH + gap)
		botP.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		botP.BorderSizePixel = 0
		botP.Parent = fArea

		table.insert(pipes, { X = F_AREA_W, TopH = topH, Gap = gap, Top = topP, Bot = botP, Passed = false })
	end

	for i = #pipes, 1, -1 do
		local p = pipes[i]
		p.X -= 135 * dt
		p.Top.Position = UDim2.fromOffset(p.X, 0)
		p.Bot.Position = UDim2.fromOffset(p.X, p.TopH + p.Gap)

		if p.X < 92 and (p.X + 38) > 70 then
			if birdY < p.TopH or (birdY + 22) > (p.TopH + p.Gap) then
				stopFlappy("ĐỤNG ỐNG! Điểm: " .. fScore .. " (Bấm để chơi lại)")
				return
			end
		end

		if not p.Passed and (p.X + 38) < 70 then
			p.Passed = true
			fScore += 1
			if fScore > fBest then fBest = fScore end
			fScoreLbl.Text = "Điểm: " .. fScore .. "  |  Kỷ lục: " .. fBest .. "   (Bấm khung / Space để bay)"
		end

		if p.X < -45 then
			p.Top:Destroy()
			p.Bot:Destroy()
			table.remove(pipes, i)
		end
	end
end))

-- ============================================================
-- GAME 4: DÒ MÌN 8x8 (MINESWEEPER - HỖ TRỢ CẢ MOBILE)
-- ============================================================
local mineGame = registerGame("Mines", "💣 Dò Mìn 8x8")
local M_SIZE, M_TOTAL = 8, 10

local mineGrid = Instance.new("Frame")
mineGrid.Size = UDim2.fromOffset(238, 238)
mineGrid.Position = UDim2.fromOffset(4, 28)
mineGrid.BackgroundTransparency = 1
mineGrid.Parent = mineGame.Page

local mineStatus = Instance.new("TextLabel")
mineStatus.Size = UDim2.fromOffset(125, 50)
mineStatus.Position = UDim2.fromOffset(250, 32)
mineStatus.BackgroundTransparency = 1
mineStatus.Text = "💣 Mìn còn: 10\nBấm ô để mở"
mineStatus.TextColor3 = Color3.fromRGB(250, 204, 21)
mineStatus.Font = Enum.Font.GothamBold
mineStatus.TextSize = 13
mineStatus.TextWrapped = true
mineStatus.Parent = mineGame.Page

local flagMode = false
local flagModeBtn = makeBtn(mineGame.Page, "⛏️ Chế độ: Đào", UDim2.fromOffset(120, 38), UDim2.fromOffset(252, 98), Color3.fromRGB(37, 99, 235))
flagModeBtn.TextSize = 12

local mineResetBtn = makeBtn(mineGame.Page, "🔄 Ván mới", UDim2.fromOffset(120, 36), UDim2.fromOffset(252, 148), Color3.fromRGB(22, 163, 74))

local mineTip = Instance.new("TextLabel")
mineTip.Size = UDim2.fromOffset(125, 52)
mineTip.Position = UDim2.fromOffset(250, 198)
mineTip.BackgroundTransparency = 1
mineTip.Text = "PC: Chuột phải để\ncắm cờ nhanh.\nÔ đầu luôn an toàn."
mineTip.TextColor3 = Color3.fromRGB(148, 163, 184)
mineTip.Font = Enum.Font.Gotham
mineTip.TextSize = 11
mineTip.Parent = mineGame.Page

local mBtns, mMines, mRev, mFlag = {}, {}, {}, {}
local mOver, mFirstClick, mSafeOpen, mFlagsPlaced = false, true, 0, 0
local numColors = {
	Color3.fromRGB(96, 165, 250),
	Color3.fromRGB(74, 222, 128),
	Color3.fromRGB(248, 113, 113),
	Color3.fromRGB(192, 132, 252),
	Color3.fromRGB(251, 146, 60),
	Color3.fromRGB(45, 212, 191),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(156, 163, 175)
}

local function countAdj(r, c)
	local n = 0
	for dr = -1, 1 do
		for dc = -1, 1 do
			local nr, nc = r + dr, c + dc
			if nr >= 1 and nr <= M_SIZE and nc >= 1 and nc <= M_SIZE and mMines[nr][nc] then
				n += 1
			end
		end
	end
	return n
end

local function placeMines(safeR, safeC)
	local placed = 0
	while placed < M_TOTAL do
		local r, c = math.random(1, M_SIZE), math.random(1, M_SIZE)
		if not mMines[r][c] and not (r == safeR and c == safeC) then
			mMines[r][c] = true
			placed += 1
		end
	end
end

local function revealAllMines(won)
	for r = 1, M_SIZE do
		for c = 1, M_SIZE do
			if mMines[r][c] then
				mBtns[r][c].Text = won and "🚩" or "💣"
				mBtns[r][c].BackgroundColor3 = won and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(185, 28, 28)
			end
		end
	end
end

local function revealTile(r, c)
	if r < 1 or r > M_SIZE or c < 1 or c > M_SIZE then return end
	if mRev[r][c] or mFlag[r][c] then return end
	mRev[r][c] = true
	local b = mBtns[r][c]
	if mMines[r][c] then
		mOver = true
		revealAllMines(false)
		b.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
		mineStatus.Text = "💥 NỔ MÌN RỒI!\nThử lại nhé"
		mineStatus.TextColor3 = Color3.fromRGB(248, 113, 113)
		return
	end
	mSafeOpen += 1
	local adj = countAdj(r, c)
	b.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	if adj > 0 then
		b.Text = tostring(adj)
		b.TextColor3 = numColors[adj] or Color3.fromRGB(255, 255, 255)
	else
		b.Text = ""
		for dr = -1, 1 do
			for dc = -1, 1 do
				if not (dr == 0 and dc == 0) then
					revealTile(r + dr, c + dc)
				end
			end
		end
	end
	if not mOver and mSafeOpen == (M_SIZE * M_SIZE - M_TOTAL) then
		mOver = true
		revealAllMines(true)
		mineStatus.Text = "🎉 PHÁ ĐẢO!\nGỡ sạch mìn"
		mineStatus.TextColor3 = Color3.fromRGB(74, 222, 128)
	end
end

local function toggleFlag(r, c)
	if mOver or mRev[r][c] then return end
	mFlag[r][c] = not mFlag[r][c]
	if mFlag[r][c] then
		mFlagsPlaced += 1
		mBtns[r][c].Text = "🚩"
		mBtns[r][c].BackgroundColor3 = Color3.fromRGB(68, 52, 34)
	else
		mFlagsPlaced -= 1
		mBtns[r][c].Text = ""
		mBtns[r][c].BackgroundColor3 = Color3.fromRGB(40, 47, 68)
	end
	mineStatus.Text = "💣 Mìn còn: " .. (M_TOTAL - mFlagsPlaced) .. "\nĐang dò mìn..."
end

local function resetMines()
	mOver, mFirstClick, mSafeOpen, mFlagsPlaced = false, true, 0, 0
	mineStatus.Text = "💣 Mìn còn: " .. M_TOTAL .. "\nBấm ô để mở"
	mineStatus.TextColor3 = Color3.fromRGB(250, 204, 21)
	for r = 1, M_SIZE do
		for c = 1, M_SIZE do
			mMines[r][c] = false
			mRev[r][c] = false
			mFlag[r][c] = false
			mBtns[r][c].Text = ""
			mBtns[r][c].BackgroundColor3 = Color3.fromRGB(40, 47, 68)
		end
	end
end

for r = 1, M_SIZE do
	mBtns[r], mMines[r], mRev[r], mFlag[r] = {}, {}, {}, {}
	for c = 1, M_SIZE do
		local b = makeBtn(mineGrid, "", UDim2.fromOffset(28, 28), UDim2.fromOffset((c - 1) * 30, (r - 1) * 30), Color3.fromRGB(40, 47, 68))
		b.TextSize = 14
		addCorner(b, 5)
		mBtns[r][c] = b

		b.MouseButton1Click:Connect(function()
			if mOver then return end
			if flagMode then
				toggleFlag(r, c)
			else
				if mFlag[r][c] then return end
				if mFirstClick then
					mFirstClick = false
					placeMines(r, c)
				end
				revealTile(r, c)
			end
		end)
		b.MouseButton2Click:Connect(function()
			toggleFlag(r, c)
		end)
	end
end
resetMines()

flagModeBtn.MouseButton1Click:Connect(function()
	flagMode = not flagMode
	flagModeBtn.Text = flagMode and "🚩 Chế độ: Cắm cờ" or "⛏️ Chế độ: Đào"
	flagModeBtn.BackgroundColor3 = flagMode and Color3.fromRGB(217, 119, 6) or Color3.fromRGB(37, 99, 235)
end)
mineResetBtn.MouseButton1Click:Connect(resetMines)

-- ============================================================
-- ĐIỀU KHIỂN ĐÓNG / MỞ / PHÍM TẮT
-- ============================================================
for id, entry in pairs(tabs) do
	entry.Btn.MouseButton1Click:Connect(function()
		switchGame(id)
	end)
end

local function minimizeMenu()
	stopSnake()
	stopFlappy("BẤM VÀO KHUNG ĐỂ BẮT ĐẦU!")
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
	local targetScale = updateResponsiveScale()
	TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = targetScale }):Play()
	switchGame(activeTab or "Snake")
end

minBtn.MouseButton1Click:Connect(minimizeMenu)

floatBtn.MouseButton1Click:Connect(function()
	if not floatWasDragged then
		restoreMenu()
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

track(UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if mainFrame.Visible then minimizeMenu() else restoreMenu() end
		return
	end
	if not mainFrame.Visible then return end
	if activeTab == "Snake" then
		if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.W then setSnakeDir(0, -1)
		elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then setSnakeDir(0, 1)
		elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then setSnakeDir(-1, 0)
		elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then setSnakeDir(1, 0)
		end
	elseif activeTab == "Flappy" and input.KeyCode == Enum.KeyCode.Space then
		flap()
	end
end))

screenGui.Destroying:Connect(function()
	stopSnake()
	fPlaying = false
	for _, c in ipairs(connections) do
		if c.Connected then c:Disconnect() end
	end
end)

-- Mở sẵn game Rắn Săn Mồi ngay khi khởi chạy
switchGame("Snake")
