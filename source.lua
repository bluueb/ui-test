local UI = {}
UI.__index = UI

local Window = {}
Window.__index = Window

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local T_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_MED  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function make(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

local function tw(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local function getParent()
	if typeof(gethui) == "function" then
		return gethui()
	end

	local ok, core = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and core then
		local canUse = pcall(function()
			local f = Instance.new("Frame")
			f.Parent = core
			f:Destroy()
		end)
		if canUse then return core end
	end

	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function makeDraggable(frame, handle)
	local dragging, dragStart, startPos = false

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging  = true
		dragStart = input.Position
		startPos  = frame.Position
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = false
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local d = input.Position - dragStart
		tw(frame, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		})
	end)
end

function UI.new(cfg)
	local self = setmetatable({}, UI)
	cfg = cfg or {}

	self.gui = make("ScreenGui", {
		Name         = cfg.Name or "Library",
		Enabled      = cfg.Enabled ~= nil and cfg.Enabled or true,
		ResetOnSpawn = false,
	}, getParent())

	self.windows = {}
	return self
end

function UI:Window(cfg)
	cfg = cfg or {}

	local win      = setmetatable({}, Window)
	win.tabs       = {}
	win.activeTab  = nil

	local defaultPos = cfg.Position or UDim2.new(0.5, -216, 0.5, -230)
	local defaultSize = cfg.Size or UDim2.new(0, 432, 0, 460)

	win.frame = make("Frame", {
		Name             = cfg.Name or "Window",
		BackgroundColor3 = Color3.fromRGB(18, 18, 22),
		BorderSizePixel  = 0,
		Position         = defaultPos,
		Size             = defaultSize,
	}, self.gui)

	make("UICorner", { CornerRadius = UDim.new(0, 10) }, win.frame)

	win.tabBar = make("Frame", {
		Name                  = "TabBar",
		BackgroundTransparency = 1,
		BorderSizePixel       = 0,
		Size                  = UDim2.new(1, 0, 0, 40),
	}, win.frame)

	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		Padding           = UDim.new(0, 8),
		SortOrder         = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, win.tabBar)

	make("UIPadding", { PaddingLeft = UDim.new(0, 8) }, win.tabBar)

	win.contentHolder = make("Frame", {
		Name                  = "ContentHolder",
		BackgroundTransparency = 1,
		BorderSizePixel       = 0,
		Position              = UDim2.new(0, 0, 0, 40),
		Size                  = UDim2.new(1, 0, 1, -40),
	}, win.frame)

	make("UIPadding", {
		PaddingLeft   = UDim.new(0, 9),
		PaddingRight  = UDim.new(0, 9),
		PaddingTop    = UDim.new(0, 9),
		PaddingBottom = UDim.new(0, 9),
	}, win.contentHolder)

	makeDraggable(win.frame, win.tabBar)
	table.insert(self.windows, win)
	return win
end

function UI:Destroy()
	self.gui:Destroy()
end

function Window:Tab(cfg)
	cfg = cfg or {}

	local win      = self
	local tabIndex = #self.tabs + 1

	local label = make("TextLabel", {
		Name                  = "Tab_" .. (cfg.Name or "Tab"),
		Font                  = Enum.Font.GothamMedium,
		Text                  = cfg.Name or "Tab",
		TextColor3            = Color3.fromRGB(100, 100, 100),
		TextSize              = 13,
		BackgroundTransparency = 1,
		Size                  = UDim2.new(0, 56, 0, 30),
		LayoutOrder           = tabIndex,
	}, self.tabBar)

	local indicator = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		Position         = UDim2.new(0.5, -7, 1, -2),
		Size             = UDim2.new(0, 14, 0, 2),
		Visible          = false,
	}, label)

	make("UICorner", { CornerRadius = UDim.new(1, 0) }, indicator)

	local colHolder = make("CanvasGroup", {
		Name                  = "ColHolder",
		BackgroundTransparency = 1,
		BorderSizePixel       = 0,
		GroupTransparency     = 1,
		Size                  = UDim2.new(1, 0, 1, 0),
		Visible               = false,
	}, self.contentHolder)

	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		Padding           = UDim.new(0, 9),
		SortOrder         = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, colHolder)

	local leftFrame = make("Frame", {
		Name                  = "LeftCol",
		BackgroundTransparency = 1,
		BorderSizePixel       = 0,
		Size                  = UDim2.new(0.5, -5, 1, 0),
		LayoutOrder           = 1,
	}, colHolder)

	make("UIListLayout", {
		Padding   = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, leftFrame)

	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 1),
		PaddingRight = UDim.new(0, 1),
		PaddingTop   = UDim.new(0, 1),
	}, leftFrame)

	local rightFrame = make("Frame", {
		Name                  = "RightCol",
		BackgroundTransparency = 1,
		BorderSizePixel       = 0,
		Size                  = UDim2.new(0.5, -5, 1, 0),
		LayoutOrder           = 2,
	}, colHolder)

	make("UIListLayout", {
		Padding   = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, rightFrame)

	make("UIPadding", {
		PaddingRight = UDim.new(0, 1),
		PaddingTop   = UDim.new(0, 1),
	}, rightFrame)

	local tab = {
		label        = label,
		indicator    = indicator,
		colHolder    = colHolder,
		leftFrame    = leftFrame,
		rightFrame   = rightFrame,
		sectionCount = 0,
	}

	function tab:Activate()
		if win.activeTab == tab then return end

		if win.activeTab then
			local prev = win.activeTab
			prev.indicator.Visible           = false
			prev.indicator.Size              = UDim2.new(0, 14, 0, 2)
			prev.colHolder.Visible           = false
			prev.colHolder.GroupTransparency = 1
			tw(prev.label, T_FAST, { TextColor3 = Color3.fromRGB(100, 100, 100) })
		end

		indicator.Visible           = true
		colHolder.GroupTransparency = 1
		colHolder.Visible           = true
		tw(label,     T_FAST, { TextColor3 = Color3.fromRGB(245, 245, 245) })
		tw(colHolder, T_MED,  { GroupTransparency = 0 })

		win.activeTab = tab
	end

	label.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			tab:Activate()
		end
	end)

	label.MouseEnter:Connect(function()
		if win.activeTab ~= tab then
			tw(label, T_FAST, { TextColor3 = Color3.fromRGB(180, 180, 180) })
		end
	end)

	label.MouseLeave:Connect(function()
		if win.activeTab ~= tab then
			tw(label, T_FAST, { TextColor3 = Color3.fromRGB(100, 100, 100) })
		end
	end)

	function tab:Section(scfg)
		scfg = scfg or {}
		self.sectionCount = self.sectionCount + 1

		local side = scfg.Side and scfg.Side:lower()
		local parentCol = side == "left" and leftFrame
			or side == "right" and rightFrame
			or (self.sectionCount % 2 == 1) and leftFrame
			or rightFrame

		local sectionFrame = make("Frame", {
			Name             = "Section_" .. (scfg.Name or "Section"),
			BackgroundColor3 = Color3.fromRGB(21, 21, 26),
			BorderSizePixel  = 0,
			Size             = UDim2.new(1, 0, 0, 32),
			LayoutOrder      = self.sectionCount,
		}, parentCol)

		make("UICorner", { CornerRadius = UDim.new(0, 7) }, sectionFrame)
		make("UIStroke", { Color = Color3.fromRGB(60, 60, 66) }, sectionFrame)

		make("TextLabel", {
			Font                  = Enum.Font.GothamMedium,
			Text                  = scfg.Name or "Section",
			TextColor3            = Color3.fromRGB(245, 245, 245),
			TextSize              = 13,
			TextXAlignment        = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position              = UDim2.new(0, 10, 0, 0),
			Size                  = UDim2.new(1, -10, 0, 32),
		}, sectionFrame)

		local content = make("Frame", {
			Name                  = "Content",
			BackgroundTransparency = 1,
			BorderSizePixel       = 0,
			Position              = UDim2.new(0, 0, 0, 32),
			Size                  = UDim2.new(1, 0, 0, 0),
		}, sectionFrame)

		local layout = make("UIListLayout", {
			Padding             = UDim.new(0, 6),
			SortOrder           = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}, content)

		local itemCount = 0

		-- use AbsoluteContentSize directly from the layout, no child loop
		local function recalc()
			local childH = layout.AbsoluteContentSize.Y
			local pad = childH > 0 and 10 or 0
			sectionFrame.Size = UDim2.new(1, 0, 0, 32 + childH + pad)
			content.Size      = UDim2.new(1, 0, 0, childH + pad)
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(recalc)

		local sec = {}

		function sec:Button(bcfg)
			bcfg = bcfg or {}
			itemCount = itemCount + 1

			local btn = make("TextButton", {
				Name                  = "Button_" .. (bcfg.Name or "Button"),
				Font                  = Enum.Font.GothamMedium,
				Text                  = bcfg.Name or "Button",
				TextColor3            = Color3.fromRGB(245, 245, 245),
				TextSize              = 12,
				BackgroundColor3      = Color3.fromRGB(108, 108, 134),
				BackgroundTransparency = 1,
				BorderSizePixel       = 0,
				Size                  = UDim2.new(1, -16, 0, 20),
				LayoutOrder           = itemCount,
			}, content)

			make("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color           = Color3.fromRGB(108, 108, 134),
				Transparency    = 0.7,
			}, btn)

			make("UICorner", { CornerRadius = UDim.new(0, 4) }, btn)

			btn.MouseButton1Down:Connect(function()
				tw(btn, T_FAST, { BackgroundTransparency = 0.6 })
			end)
			btn.MouseButton1Up:Connect(function()
				tw(btn, T_FAST, { BackgroundTransparency = 1 })
			end)
			btn.MouseButton1Click:Connect(function()
				if bcfg.Callback then bcfg.Callback() end
			end)

			return btn
		end

		function sec:Toggle(tcfg)
			tcfg = tcfg or {}
			itemCount = itemCount + 1

			local state     = tcfg.Default or false
			local OFF_COLOR = Color3.fromRGB(30, 30, 35)
			local ON_COLOR  = Color3.fromRGB(206, 206, 255)

			local row = make("Frame", {
				Name                  = "Toggle_" .. (tcfg.Name or "Toggle"),
				BackgroundTransparency = 1,
				BorderSizePixel       = 0,
				Size                  = UDim2.new(1, -16, 0, 20),
				LayoutOrder           = itemCount,
			}, content)

			make("TextLabel", {
				Font                  = Enum.Font.GothamMedium,
				Text                  = tcfg.Name or "Toggle",
				TextColor3            = Color3.fromRGB(245, 245, 245),
				TextSize              = 12,
				TextXAlignment        = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size                  = UDim2.new(1, -19, 1, 0),
			}, row)

			local box = make("Frame", {
				Name             = "Box",
				BackgroundColor3 = state and ON_COLOR or OFF_COLOR,
				BorderSizePixel  = 0,
				AnchorPoint      = Vector2.new(1, 0.5),
				Position         = UDim2.new(1, 0, 0.5, 0),
				Size             = UDim2.new(0, 14, 0, 14),
			}, row)

			make("UIStroke", { Color = Color3.fromRGB(40, 40, 40) }, box)
			make("UICorner", { CornerRadius = UDim.new(0.2, 0) }, box)

			local function setState(val)
				state = val
				tw(box, T_FAST, { BackgroundColor3 = state and ON_COLOR or OFF_COLOR })
				if tcfg.Callback then tcfg.Callback(state) end
			end

			box.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					setState(not state)
				end
			end)

			local tog = {}
			function tog:Set(val) setState(val) end
			function tog:Get() return state end
			return tog
		end

		return sec
	end

	table.insert(self.tabs, tab)
	if #self.tabs == 1 then tab:Activate() end
	return tab
end

return UI
