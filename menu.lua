-- ============================================================
-- MINI GAME HUB (DÁN TRỰC TIẾP VÀO CUỐI SCRIPT CỦA BẠN)
-- Gọi _G.MiniGameHub.Toggle() nếu muốn mở từ nút trong menu riêng
-- ============================================================
task.spawn(function()
	local SHOW_FLOAT_BUTTON = true -- Đổi thành false nếu bạn muốn tự gọi bằng nút trong menu của bạn

	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local player = Players.LocalPlayer
	local GUI_NAME = "MiniGameHub_PlugIn"

	-- Tự chọn nơi gắn GUI an toàn (chạy được cả Executor lẫn Roblox Studio)
	local function getGuiParent()
		if typeof(gethui) == "function" then
			local ok, hui = pcall(gethui)
			if ok and hui then return hui end
		end
		local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
		if ok and coreGui then
			local testOk = pcall(function()
				local f = Instance.new("Folder")
				f.Parent = coreGui
				f:Destroy()
			end)
			if testOk then return coreGui end
		end
		return player:WaitForChild("PlayerGui")
	end

	local guiParent = getGuiParent()

	-- Xóa menu cũ nếu chạy lại script để tránh bị nhân đôi UI
	local oldGui = guiParent:FindFirstChild(GUI_NAME)
	if oldGui then oldGui:Destroy() end

	local connections = {}
	local function track(conn)
		table.insert(connections, conn)
		return conn
	end

	-- Hàm hỗ trợ tạo UI & kéo thả (hỗ trợ cả chuột và cảm ứng)
	local function addCorner(parent, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r or 8)
		c.Parent = parent
		return c
	end

	local function addStroke(parent, color, thickness)
		local s = Instance.new("UIStroke")
		s.Color = color or Color3.fromRGB(60, 65, 85)
		s.Thickness = thickness or 1.2
		s.Parent = parent
		return s
	end

	local function makeBtn(parent, text, size, pos, bgColor)
		local b = Instance.new("TextButton")
		b.Size = size
		b.Position = pos or UDim2.new()
		b.BackgroundColor3 = bgColor or Color3.fromRGB(45, 52, 70)
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.Text = text
		b.AutoButtonColor = true
		b.BorderSizePixel = 0
		b.Parent = parent
		addCorner(b, 7)
		return b
	end

	local function makeDraggable(dragHandle, targetFrame)
		local dragging, dragStart, startPos
		track(dragHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = targetFrame.Position
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
				targetFrame.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end))
	end

	-- ==========================================
	-- KHUNG GIAO DIỆN CHÍNH
	-- ==========================================
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = GUI_NAME
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = guiParent

	-- Nút nổi mở nhanh (kéo thả được)
	local floatBtn = makeBtn(
		screenGui,
		"🎮 Mini Game",
		UDim2.fromOffset(118, 36),
		UDim2.new(0, 16, 0.5, -18),
		Color3.fromRGB(37, 99, 235)
	)
	floatBtn.Visible = SHOW_FLOAT_BUTTON
	addStroke(floatBtn, Color3.fromRGB(96, 165, 250), 1.5)
	makeDraggable(floatBtn, floatBtn)

	-- Khung Hub chính
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.fromOffset(420, 355)
	mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = screenGui
	addCorner(mainFrame, 12)
	addStroke(mainFrame, Color3.fromRGB(55, 65, 85), 1.5)

	-- Thanh tiêu đề (kéo thả cửa sổ)
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 36)
	topBar.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame
	addCorner(topBar, 12)
	makeDraggable(topBar, mainFrame)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -90, 1, 0)
	titleLbl.Position = UDim2.fromOffset(14, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "🎮 MINI GAME HUB"
	titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextSize = 15
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = topBar

	local closeBtn = makeBtn(topBar, "X", UDim2.fromOffset(26, 26), UDim2.new(1, -34, 0, 5), Color3.fromRGB(220, 38, 38))
	closeBtn.TextSize = 13

	-- Thanh chọn Tab Game
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -20, 0, 32)
	tabBar.Position = UDim2.fromOffset(10, 42)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = mainFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.Parent = tabBar

	-- Vùng hiển thị nội dung từng game
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, -20, 1, -86)
	contentArea.Position = UDim2.fromOffset(10, 78)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainFrame

	local tabs = {}
	local activeTabName = nil

	local function createTab(name, labelText)
		local tabBtn = makeBtn(tabBar, labelText, UDim2.new(1/3, -4, 1, 0), nil, Color3.fromRGB(35, 40, 55))
		tabBtn.TextSize = 13

		local page = Instance.new("Frame")
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.Parent = contentArea

		local entry = { Name = name, Button = tabBtn, Page = page, OnOpen = nil, OnClose = nil }
		tabs[name] = entry
		return entry
	end

	local function switchTab(name)
		for tName, entry in pairs(tabs) do
			if tName == name then
				entry.Page.Visible = true
				entry.Button.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
				if entry.OnOpen then entry.OnOpen() end
			else
				if entry.Page.Visible and entry.OnClose then entry.OnClose() end
				entry.Page.Visible = false
				entry.Button.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
			end
		end
		activeTabName = name
	end

	-- ==========================================
	-- GAME 1: RẮN SĂN MỒI (SNAKE)
	-- ==========================================
	local snakeTab = createTab("Snake", "🐍 Rắn Săn Mồi")
	local GRID_N, CELL_PX = 14, 16

	local snakeScoreLbl = Instance.new("TextLabel")
	snakeScoreLbl.Size = UDim2.new(1, -100, 0, 26)
	snakeScoreLbl.BackgroundTransparency = 1
	snakeScoreLbl.Text = "Điểm: 0  |  Kỷ lục: 0"
	snakeScoreLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
	snakeScoreLbl.Font = Enum.Font.GothamBold
	snakeScoreLbl.TextSize = 14
	snakeScoreLbl.TextXAlignment = Enum.TextXAlignment.Left
	snakeScoreLbl.Parent = snakeTab.Page

	local snakeRestartBtn = makeBtn(snakeTab.Page, "🔄 Chơi lại", UDim2.fromOffset(90, 26), UDim2.new(1, -90, 0, 0), Color3.fromRGB(22, 163, 74))
	snakeRestartBtn.TextSize = 12

	local snakeBoard = Instance.new("Frame")
	snakeBoard.Size = UDim2.fromOffset(GRID_N * CELL_PX, GRID_N * CELL_PX)
	snakeBoard.Position = UDim2.fromOffset(6, 34)
	snakeBoard.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
	snakeBoard.BorderSizePixel = 0
	snakeBoard.Parent = snakeTab.Page
	addCorner(snakeBoard, 6)

	local snakeCells = {}
	for x = 1, GRID_N do
		snakeCells[x] = {}
		for y = 1, GRID_N do
			local c = Instance.new("Frame")
			c.Size = UDim2.fromOffset(CELL_PX - 1, CELL_PX - 1)
			c.Position = UDim2.fromOffset((x - 1) * CELL_PX, (y - 1) * CELL_PX)
			c.BorderSizePixel = 0
			c.BackgroundColor3 = Color3.fromRGB(24, 30, 46)
			c.Parent = snakeBoard
			snakeCells[x][y] = c
		end
	end

	local snakeOverLbl = Instance.new("TextLabel")
	snakeOverLbl.Size = UDim2.new(1, -16, 0, 48)
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
	addCorner(snakeOverLbl, 6)

	local snakeHint = Instance.new("TextLabel")
	snakeHint.Size = UDim2.fromOffset(145, 36)
	snakeHint.Position = UDim2.fromOffset(244, 42)
	snakeHint.BackgroundTransparency = 1
	snakeHint.Text = "WASD / Phím mũi tên\nhoặc bấm nút dưới"
	snakeHint.TextColor3 = Color3.fromRGB(148, 163, 184)
	snakeHint.Font = Enum.Font.Gotham
	snakeHint.TextSize = 11
	snakeHint.Parent = snakeTab.Page

	local sUp    = makeBtn(snakeTab.Page, "▲", UDim2.fromOffset(42, 42), UDim2.fromOffset(296, 92))
	local sLeft  = makeBtn(snakeTab.Page, "◄", UDim2.fromOffset(42, 42), UDim2.fromOffset(250, 138))
	local sRight = makeBtn(snakeTab.Page, "►", UDim2.fromOffset(42, 42), UDim2.fromOffset(342, 138))
	local sDown  = makeBtn(snakeTab.Page, "▼", UDim2.fromOffset(42, 42), UDim2.fromOffset(296, 184))

	local snakeBody, sDir, sNextDir, sFood = {}, { x = 1, y = 0 }, { x = 1, y = 0 }, nil
	local sScore, sBest, sAlive, sRunId = 0, 0, false, 0

	local function setSnakeDir(dx, dy)
		if not sAlive or (dx == -sDir.x and dy == -sDir.y) then return end
		sNextDir = { x = dx, y = dy }
	end

	local function spawnSnakeFood()
		local empty = {}
		for x = 1, GRID_N do
			for y = 1, GRID_N do
				local busy = false
				for _, seg in ipairs(snakeBody) do
					if seg.x == x and seg.y == y then busy = true break end
				end
				if not busy then table.insert(empty, { x = x, y = y }) end
			end
		end
		sFood = #empty > 0 and empty[math.random(1, #empty)] or nil
	end

	local function drawSnake()
		for x = 1, GRID_N do
			for y = 1, GRID_N do
				snakeCells[x][y].BackgroundColor3 = Color3.fromRGB(24, 30, 46)
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
		snakeBody = { { x = 6, y = 7 }, { x = 5, y = 7 }, { x = 4, y = 7 } }
		sDir, sNextDir = { x = 1, y = 0 }, { x = 1, y = 0 }
		sScore = 0
		sAlive = true
		snakeOverLbl.Visible = false
		snakeScoreLbl.Text = "Điểm: 0  |  Kỷ lục: " .. sBest
		spawnSnakeFood()
		drawSnake()

		task.spawn(function()
			while sAlive and myId == sRunId do
				task.wait(math.max(0.085, 0.21 - sScore * 0.004))
				if not sAlive or myId ~= sRunId then break end
				sDir = sNextDir
				local head = snakeBody[1]
				local nh = { x = head.x + sDir.x, y = head.y + sDir.y }

				if nh.x < 1 or nh.x > GRID_N or nh.y < 1 or nh.y > GRID_N then
					sAlive = false
					snakeOverLbl.Text = "ĐỤNG TƯỜNG! (" .. sScore .. " điểm)"
					snakeOverLbl.Visible = true
					break
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
				drawSnake()
			end
		end)
	end

	sUp.MouseButton1Click:Connect(function() setSnakeDir(0, -1) end)
	sDown.MouseButton1Click:Connect(function() setSnakeDir(0, 1) end)
	sLeft.MouseButton1Click:Connect(function() setSnakeDir(-1, 0) end)
	sRight.MouseButton1Click:Connect(function() setSnakeDir(1, 0) end)
	snakeRestartBtn.MouseButton1Click:Connect(startSnake)
	snakeTab.OnOpen = startSnake
	snakeTab.OnClose = stopSnake

	-- ==========================================
	-- GAME 2: CỜ CARO 3x3 (VS BOT THÔNG MINH)
	-- ==========================================
	local tttTab = createTab("Caro", "❌⭕ Caro")
	local tttGrid = Instance.new("Frame")
	tttGrid.Size = UDim2.fromOffset(216, 216)
	tttGrid.Position = UDim2.fromOffset(14, 24)
	tttGrid.BackgroundTransparency = 1
	tttGrid.Parent = tttTab.Page

	local tttStatus = Instance.new("TextLabel")
	tttStatus.Size = UDim2.fromOffset(148, 52)
	tttStatus.Position = UDim2.fromOffset(244, 42)
	tttStatus.BackgroundTransparency = 1
	tttStatus.Text = "Lượt của bạn (X)"
	tttStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
	tttStatus.Font = Enum.Font.GothamBold
	tttStatus.TextSize = 15
	tttStatus.TextWrapped = true
	tttStatus.Parent = tttTab.Page

	local tttScoreLbl = Instance.new("TextLabel")
	tttScoreLbl.Size = UDim2.fromOffset(148, 30)
	tttScoreLbl.Position = UDim2.fromOffset(244, 102)
	tttScoreLbl.BackgroundTransparency = 1
	tttScoreLbl.Text = "Bạn: 0  -  Bot: 0"
	tttScoreLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
	tttScoreLbl.Font = Enum.Font.GothamBold
	tttScoreLbl.TextSize = 14
	tttScoreLbl.Parent = tttTab.Page

	local tttResetBtn = makeBtn(tttTab.Page, "🔄 Ván mới", UDim2.fromOffset(130, 36), UDim2.fromOffset(253, 155), Color3.fromRGB(22, 163, 74))

	local tttBoard = {}
	local tttButtons = {}
	local tttOver, tttLock = false, false
	local pWins, bWins = 0, 0

	local winLines = {
		{1,2,3},{4,5,6},{7,8,9},
		{1,4,7},{2,5,8},{3,6,9},
		{1,5,9},{3,5,7}
	}

	local function checkWinner(b)
		for _, line in ipairs(winLines) do
			local a, c, d = b[line[1]], b[line[2]], b[line[3]]
			if a ~= "" and a == c and c == d then return a, line end
		end
		for i = 1, 9 do
			if b[i] == "" then return nil end
		end
		return "DRAW"
	end

	local function findWinningMove(symbol)
		for i = 1, 9 do
			if tttBoard[i] == "" then
				tttBoard[i] = symbol
				local w = checkWinner(tttBoard)
				tttBoard[i] = ""
				if w == symbol then return i end
			end
		end
		return nil
	end

	local function resetTTT()
		tttOver, tttLock = false, false
		tttStatus.Text = "Lượt của bạn (X)"
		tttStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
		for i = 1, 9 do
			tttBoard[i] = ""
			tttButtons[i].Text = ""
			tttButtons[i].BackgroundColor3 = Color3.fromRGB(34, 40, 56)
		end
	end

	local function finishTTT(res, line)
		tttOver = true
		if line then
			for _, idx in ipairs(line) do
				tttButtons[idx].BackgroundColor3 = (res == "X") and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(185, 28, 28)
			end
		end
		if res == "X" then
			pWins += 1
			tttStatus.Text = "🎉 Bạn thắng!"
			tttStatus.TextColor3 = Color3.fromRGB(74, 222, 128)
		elseif res == "O" then
			bWins += 1
			tttStatus.Text = "🤖 Bot thắng!"
			tttStatus.TextColor3 = Color3.fromRGB(248, 113, 113)
		else
			tttStatus.Text = "🤝 Hòa nhau!"
			tttStatus.TextColor3 = Color3.fromRGB(250, 204, 21)
		end
		tttScoreLbl.Text = "Bạn: " .. pWins .. "  -  Bot: " .. bWins
	end

	for i = 1, 9 do
		local row = math.floor((i - 1) / 3)
		local col = (i - 1) % 3
		local btn = makeBtn(tttGrid, "", UDim2.fromOffset(66, 66), UDim2.fromOffset(col * 74, row * 74), Color3.fromRGB(34, 40, 56))
		btn.TextSize = 28
		tttButtons[i] = btn
		tttBoard[i] = ""

		btn.MouseButton1Click:Connect(function()
			if tttOver or tttLock or tttBoard[i] ~= "" then return end
			tttBoard[i] = "X"
			btn.Text = "X"
			btn.TextColor3 = Color3.fromRGB(96, 165, 250)

			local w, line = checkWinner(tttBoard)
			if w then finishTTT(w, line) return end

			tttLock = true
			tttStatus.Text = "Bot đang tính..."
			task.delay(0.28, function()
				if tttOver then return end
				local move = findWinningMove("O") or findWinningMove("X")
				if not move and tttBoard[5] == "" then move = 5 end
				if not move then
					local empty = {}
					for k = 1, 9 do if tttBoard[k] == "" then table.insert(empty, k) end end
					if #empty > 0 then move = empty[math.random(1, #empty)] end
				end
				if move then
					tttBoard[move] = "O"
					tttButtons[move].Text = "O"
					tttButtons[move].TextColor3 = Color3.fromRGB(248, 113, 113)
				end
				local bw, bline = checkWinner(tttBoard)
				if bw then
					finishTTT(bw, bline)
				else
					tttStatus.Text = "Lượt của bạn (X)"
					tttLock = false
				end
			end)
		end)
	end
	tttResetBtn.MouseButton1Click:Connect(resetTTT)

	-- ==========================================
	-- GAME 3: FLAPPY BOX
	-- ==========================================
	local flappyTab = createTab("Flappy", "🐤 Flappy Box")

	local fScoreLbl = Instance.new("TextLabel")
	fScoreLbl.Size = UDim2.new(1, 0, 0, 26)
	fScoreLbl.BackgroundTransparency = 1
	fScoreLbl.Text = "Điểm: 0  |  Kỷ lục: 0   (Bấm khung hoặc Space để nhảy)"
	fScoreLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
	fScoreLbl.Font = Enum.Font.GothamBold
	fScoreLbl.TextSize = 12
	fScoreLbl.TextXAlignment = Enum.TextXAlignment.Left
	fScoreLbl.Parent = flappyTab.Page

	local fArea = Instance.new("TextButton")
	fArea.Size = UDim2.new(1, 0, 1, -32)
	fArea.Position = UDim2.fromOffset(0, 32)
	fArea.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	fArea.Text = ""
	fArea.AutoButtonColor = false
	fArea.ClipsDescendants = true
	fArea.BorderSizePixel = 0
	fArea.Parent = flappyTab.Page
	addCorner(fArea, 8)

	local bird = Instance.new("Frame")
	bird.Size = UDim2.fromOffset(22, 22)
	bird.Position = UDim2.fromOffset(70, 100)
	bird.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
	bird.BorderSizePixel = 0
	bird.ZIndex = 3
	bird.Parent = fArea
	addCorner(bird, 6)

	local fMsg = Instance.new("TextLabel")
	fMsg.Size = UDim2.new(1, -20, 0, 44)
	fMsg.Position = UDim2.fromScale(0.5, 0.5)
	fMsg.AnchorPoint = Vector2.new(0.5, 0.5)
	fMsg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	fMsg.BackgroundTransparency = 0.25
	fMsg.Text = "BẤM ĐỂ BẮT ĐẦU BAY!"
	fMsg.TextColor3 = Color3.fromRGB(255, 255, 255)
	fMsg.Font = Enum.Font.GothamBlack
	fMsg.TextSize = 14
	fMsg.ZIndex = 5
	fMsg.Parent = fArea
	addCorner(fMsg, 8)

	local fPlaying, fScore, fBest = false, 0, 0
	local birdY, birdVel, pipeTimer = 100, 0, 0
	local pipes = {}

	local function clearPipes()
		for _, p in ipairs(pipes) do
			if p.Top then p.Top:Destroy() end
			if p.Bot then p.Bot:Destroy() end
		end
		pipes = {}
	end

	local function stopFlappy(showText)
		fPlaying = false
		if showText then
			fMsg.Text = showText
			fMsg.Visible = true
		end
	end

	local function startFlappy()
		clearPipes()
		fScore = 0
		birdY = 100
		birdVel = -230
		pipeTimer = 0.9
		fPlaying = true
		fMsg.Visible = false
		bird.Position = UDim2.fromOffset(70, birdY)
		fScoreLbl.Text = "Điểm: 0  |  Kỷ lục: " .. fBest .. "   (Bấm khung hoặc Space để nhảy)"
	end

	local function flapAction()
		if not fPlaying then
			startFlappy()
		else
			birdVel = -235
		end
	end

	fArea.MouseButton1Click:Connect(flapAction)
	flappyTab.OnClose = function() stopFlappy("BẤM ĐỂ CHƠI TIẾP!") end

	track(RunService.RenderStepped:Connect(function(dt)
		if not fPlaying or not mainFrame.Visible or not flappyTab.Page.Visible then return end
		dt = math.min(dt, 0.05)

		local areaH = fArea.AbsoluteSize.Y
		local areaW = fArea.AbsoluteSize.X
		if areaH <= 0 then return end

		birdVel += 680 * dt
		birdY += birdVel * dt
		bird.Position = UDim2.fromOffset(70, birdY)

		if birdY < 0 or birdY + 22 > areaH then
			stopFlappy("RỚT RỒI! Điểm: " .. fScore .. " (Bấm chơi lại)")
			return
		end

		pipeTimer += dt
		if pipeTimer >= 1.45 then
			pipeTimer = 0
			local gap = 82
			local topH = math.random(28, math.max(30, math.floor(areaH - gap - 28)))

			local topP = Instance.new("Frame")
			topP.Size = UDim2.fromOffset(38, topH)
			topP.Position = UDim2.fromOffset(areaW, 0)
			topP.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
			topP.BorderSizePixel = 0
			topP.Parent = fArea

			local botP = Instance.new("Frame")
			botP.Size = UDim2.fromOffset(38, areaH - topH - gap)
			botP.Position = UDim2.fromOffset(areaW, topH + gap)
			botP.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
			botP.BorderSizePixel = 0
			botP.Parent = fArea

			table.insert(pipes, { X = areaW, TopH = topH, Gap = gap, Top = topP, Bot = botP, Passed = false })
		end

		for i = #pipes, 1, -1 do
			local p = pipes[i]
			p.X -= 135 * dt
			p.Top.Position = UDim2.fromOffset(p.X, 0)
			p.Bot.Position = UDim2.fromOffset(p.X, p.TopH + p.Gap)

			-- Kiểm tra va chạm hộp (Bird: x=70..92, y=birdY..birdY+22)
			if p.X < 92 and (p.X + 38) > 70 then
				if birdY < p.TopH or (birdY + 22) > (p.TopH + p.Gap) then
					stopFlappy("ĐỤNG ỐNG! Điểm: " .. fScore .. " (Bấm chơi lại)")
					return
				end
			end

			if not p.Passed and (p.X + 38) < 70 then
				p.Passed = true
				fScore += 1
				if fScore > fBest then fBest = fScore end
				fScoreLbl.Text = "Điểm: " .. fScore .. "  |  Kỷ lục: " .. fBest .. "   (Bấm khung hoặc Space để nhảy)"
			end

			if p.X < -45 then
				p.Top:Destroy()
				p.Bot:Destroy()
				table.remove(pipes, i)
			end
		end
	end))

	-- ==========================================
	-- PHÍM TẮT & ĐIỀU KHIỂN CHUNG
	-- ==========================================
	for name, entry in pairs(tabs) do
		entry.Button.MouseButton1Click:Connect(function()
			switchTab(name)
		end)
	end

	track(UserInputService.InputBegan:Connect(function(input, gp)
		if gp or not mainFrame.Visible then return end
		if activeTabName == "Snake" then
			if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.W then setSnakeDir(0, -1)
			elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then setSnakeDir(0, 1)
			elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then setSnakeDir(-1, 0)
			elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then setSnakeDir(1, 0)
			end
		elseif activeTabName == "Flappy" and input.KeyCode == Enum.KeyCode.Space then
			flapAction()
		end
	end))

	local function openHub()
		mainFrame.Visible = true
		switchTab(activeTabName or "Snake")
	end

	local function closeHub()
		mainFrame.Visible = false
		stopSnake()
		stopFlappy("BẤM ĐỂ BẮT ĐẦU BAY!")
	end

	local function toggleHub()
		if mainFrame.Visible then closeHub() else openHub() end
	end

	floatBtn.MouseButton1Click:Connect(toggleHub)
	closeBtn.MouseButton1Click:Connect(closeHub)

	-- Dọn sạch event khi GUI bị hủy để không gây lag
	screenGui.Destroying:Connect(function()
		stopSnake()
		fPlaying = false
		for _, conn in ipairs(connections) do
			if conn.Connected then conn:Disconnect() end
		end
	end)

	-- Xuất hàm điều khiển toàn cục để gắn vào nút trong menu riêng của bạn
	_G.MiniGameHub = {
		Open = openHub,
		Close = closeHub,
		Toggle = toggleHub,
		Destroy = function() screenGui:Destroy() end
	}
end)
