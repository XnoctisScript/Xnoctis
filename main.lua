--[[

██╗  ██╗███╗   ██╗ ██████╗  ██████╗████████╗██╗███████╗
╚██╗██╔╝████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██║██╔════╝
 ╚███╔╝ ██╔██╗ ██║██║   ██║██║        ██║   ██║███████╗
 ██╔██╗ ██║╚██╗██║██║   ██║██║        ██║   ██║╚════██║
██╔╝ ██╗██║ ╚████║╚██████╔╝╚██████╗   ██║   ██║███████║
╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝╚══════╝

----------------------------------------
if not game:IsLoaded() then game.Loaded:Wait() end

local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local RS      = game:GetService("RunService")
local Debris  = game:GetService("Debris")
local Players = game:GetService("Players")
local TSvc    = game:GetService("TextService")

local IceLib = {}

local THEMES = {
        Default     = {bg=Color3.fromRGB(3,3,3),     topbar=Color3.fromRGB(6,6,6),    section=Color3.fromRGB(9,9,9),    element=Color3.fromRGB(14,14,14), accent=Color3.fromRGB(160,160,160),text=Color3.fromRGB(230,230,230), sub=Color3.fromRGB(110,110,110), stroke=Color3.fromRGB(28,28,28)},
	Crimson  = {bg=Color3.fromRGB(10,3,3),    topbar=Color3.fromRGB(14,5,5),   section=Color3.fromRGB(16,6,6),   element=Color3.fromRGB(22,10,10), accent=Color3.fromRGB(220,35,35),  text=Color3.fromRGB(240,220,220), sub=Color3.fromRGB(155,100,100), stroke=Color3.fromRGB(40,14,14)},
	Ocean    = {bg=Color3.fromRGB(5,12,22),   topbar=Color3.fromRGB(7,16,30),  section=Color3.fromRGB(8,18,34),  element=Color3.fromRGB(12,24,44), accent=Color3.fromRGB(40,130,235), text=Color3.fromRGB(220,235,255), sub=Color3.fromRGB(100,140,190), stroke=Color3.fromRGB(15,35,65)},
	Forest   = {bg=Color3.fromRGB(5,14,8),    topbar=Color3.fromRGB(7,18,10),  section=Color3.fromRGB(8,20,11),  element=Color3.fromRGB(11,25,14), accent=Color3.fromRGB(45,190,80),  text=Color3.fromRGB(215,240,220), sub=Color3.fromRGB(90,150,100),  stroke=Color3.fromRGB(15,45,20)},
	Midnight = {bg=Color3.fromRGB(10,8,20),   topbar=Color3.fromRGB(14,11,28), section=Color3.fromRGB(15,12,30), element=Color3.fromRGB(20,16,38), accent=Color3.fromRGB(130,80,235), text=Color3.fromRGB(225,220,245), sub=Color3.fromRGB(120,100,170), stroke=Color3.fromRGB(35,25,65)},
	Red      = {bg=Color3.fromRGB(8,8,8),     topbar=Color3.fromRGB(11,11,11), section=Color3.fromRGB(13,13,13), element=Color3.fromRGB(18,18,18), accent=Color3.fromRGB(180,25,25),  text=Color3.fromRGB(235,235,235), sub=Color3.fromRGB(130,130,130), stroke=Color3.fromRGB(35,35,35)},
}

local function tw(o, d, p, s, e)
	TS:Create(o, TweenInfo.new(d, s or Enum.EasingStyle.Quint, e or Enum.EasingDirection.Out), p):Play()
end

local function mkC(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
	return c
end

local function mkS(p, col, t)
	local s = Instance.new("UIStroke")
	s.Color = col
	s.Thickness = t or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function mkI(cls, props)
	local o = Instance.new(cls)
	local par = props.Parent
	for k, v in pairs(props) do
		if k ~= "Parent" then o[k] = v end
	end
	if par then o.Parent = par end
	return o
end

local function ripple(btn, x, y)
	local ap, as = btn.AbsolutePosition, btn.AbsoluteSize
	local r = Instance.new("Frame")
	r.Size = UDim2.new(0, 0, 0, 0)
	r.Position = UDim2.new(0, x - ap.X, 0, y - ap.Y)
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.BackgroundColor3 = Color3.new(1, 1, 1)
	r.BackgroundTransparency = 0.82
	r.BorderSizePixel = 0
	r.ZIndex = btn.ZIndex + 2
	r.Parent = btn
	mkC(r, 999)
	tw(r, 0.7, {Size = UDim2.new(0, math.max(as.X, as.Y) * 2.5, 0, math.max(as.X, as.Y) * 2.5), BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
	Debris:AddItem(r, 0.8)
end

local function playSound(id)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. tostring(id):gsub("rbxassetid://", "")
	s.Volume = 0.5
	s.Parent = workspace
	s:Play()
	Debris:AddItem(s, 3)
end

local function dragify(handle, target, canDragFn)
	local dragging   = false
	local dragOffset = Vector2.new()
	local dragCon
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
		if canDragFn and not canDragFn() then return end
		dragging   = true
		dragOffset = Vector2.new(
			inp.Position.X - target.AbsolutePosition.X,
			inp.Position.Y - target.AbsolutePosition.Y
		)
		if dragCon then dragCon:Disconnect() end
		dragCon = UIS.InputChanged:Connect(function(i)
			if not dragging then dragCon:Disconnect() return end
			if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
			if canDragFn and not canDragFn() then dragging = false dragCon:Disconnect() return end
			local vp = workspace.CurrentCamera.ViewportSize
			local ms = target.AbsoluteSize
			local nx = math.clamp(i.Position.X - dragOffset.X, 0, vp.X - ms.X)
			local ny = math.clamp(i.Position.Y - dragOffset.Y, 0, vp.Y - ms.Y)
			tw(target, 0.06, {Position = UDim2.new(0, nx, 0, ny)}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		end)
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if dragCon then dragCon:Disconnect() dragCon = nil end
		end
	end)
end

function IceLib.new(cfg)
	cfg = cfg or {}
	local self        = {}
	self._t           = THEMES[cfg.Theme or "Default"] or THEMES.Default
	self._refs        = {}
	self._tabBtns     = {}
	self._tabs        = {}
	self._toggles     = {}
	self._activeTab   = nil
	self._minimized   = false
	self._tabSound    = cfg.TabSound ~= false
	self._notifyCount = 0

	local canDrag    = cfg.Draggable ~= false
	local canDragMin = cfg.DraggableMinimized ~= false

	local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local scale    = isMobile and 0.88 or 1
	local W, H     = (cfg.Width or 440) * scale, (cfg.Height or 520) * scale

	pcall(function() game:GetService("CoreGui").IceLib:Destroy() end)
	pcall(function() Players.LocalPlayer.PlayerGui.IceLib:Destroy() end)

	local gui = Instance.new("ScreenGui")
	gui.Name           = "IceLib"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn   = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
		gui.Parent = game:GetService("CoreGui")
	end)
	if not gui.Parent then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	self._gui = gui

	local main = Instance.new("Frame")
	main.Name             = "IceLib_Main"
	main.Size             = UDim2.new(0, W, 0, H)
	main.Position         = UDim2.new(0.5, -W/2, 0.5, -H/2)
	main.BackgroundColor3       = self._t.bg
		main.BorderSizePixel        = 0
	main.ClipsDescendants       = true
	main.Active           = true
	main.Parent           = gui
	mkC(main, 12)
	local mainStroke = mkS(main, self._t.stroke, 1.2)
	self._main         = main
	self._originalSize = main.Size

	local function ref(o, p, k)
		table.insert(self._refs, {obj = o, prop = p, key = k})
	end
	self._ref = ref
	ref(main, "BackgroundColor3", "bg")
	ref(mainStroke, "Color", "stroke")

	local topbar = mkI("Frame", {
		Size                   = UDim2.new(1, 0, 0, 44),
		BackgroundColor3       = self._t.topbar,
		BorderSizePixel        = 0,
		ZIndex                 = 6,
		Parent                 = main,
	})
	mkC(topbar, 12)
	local tbfix = mkI("Frame", {
		Size                   = UDim2.new(1, 0, 0, 14),
		Position               = UDim2.new(0, 0, 1, -14),
		BackgroundColor3       = self._t.topbar,
		BorderSizePixel        = 0,
		ZIndex                 = 6,
		Parent                 = topbar,
	})
	ref(topbar, "BackgroundColor3", "topbar")
	ref(tbfix,  "BackgroundColor3", "topbar")
	self._topbar = topbar

	local dot = mkI("Frame", {
		Size             = UDim2.new(0, 5, 0, 5),
		Position         = UDim2.new(0, 14, 0.5, -2.5),
		BackgroundColor3 = self._t.accent,
		BorderSizePixel  = 0,
		ZIndex           = 7,
		Parent           = topbar,
	})
	mkC(dot, 999)
	ref(dot, "BackgroundColor3", "accent")

	local titleL = mkI("TextLabel", {
		Text                   = cfg.Title or "ice lib",
		Size                   = UDim2.new(0, 200, 1, 0),
		Position               = UDim2.new(0, 26, 0, 0),
		BackgroundTransparency = 1,
		TextColor3             = self._t.text,
		TextXAlignment         = Enum.TextXAlignment.Left,
		Font                   = Enum.Font.GothamBold,
		TextSize               = isMobile and 16 or 14,
		ZIndex                 = 7,
		Parent                 = topbar,
	})
	ref(titleL, "TextColor3", "text")

	local tbLine = mkI("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 0, 43),
		BackgroundColor3 = self._t.stroke,
		BorderSizePixel  = 0,
		ZIndex           = 5,
		Parent           = main,
	})
	ref(tbLine, "BackgroundColor3", "stroke")

	local function mkWBtn(txt, xOff)
		local bw = isMobile and 36 or 28
		local bh = isMobile and 28 or 24
		local b = mkI("TextButton", {
			Text             = txt,
			Size             = UDim2.new(0, bw, 0, bh),
			Position         = UDim2.new(1, xOff, 0.5, -bh/2),
			BackgroundColor3 = self._t.element,
			TextColor3       = self._t.sub,
			Font             = Enum.Font.GothamBold,
			TextSize         = isMobile and 18 or 15,
			ZIndex           = 7,
			BorderSizePixel  = 0,
			Parent           = topbar,
		})
		mkC(b, 6)
		ref(b, "BackgroundColor3", "element")
		b.MouseEnter:Connect(function() tw(b, 0.15, {TextColor3 = self._t.text}) end)
		b.MouseLeave:Connect(function() tw(b, 0.15, {TextColor3 = self._t.sub}) end)
		return b
	end

	local xClose = isMobile and -44 or -36
	local xMin   = isMobile and -86 or -70
	local closeBtn = mkWBtn("×", xClose)
	local minBtn   = mkWBtn("−", xMin)

	local tabBar = mkI("Frame", {
		Size                   = UDim2.new(1, -24, 0, 34),
		Position               = UDim2.new(0, 12, 0, 44),
		BackgroundTransparency = 1,
		ZIndex                 = 5,
		Parent                 = main,
	})
	local tbLayout = Instance.new("UIListLayout")
	tbLayout.FillDirection     = Enum.FillDirection.Horizontal
	tbLayout.Padding           = UDim.new(0, isMobile and 8 or 5)
	tbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tbLayout.Parent            = tabBar
	self._tabBar = tabBar

	local tabSep = mkI("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 0, 78),
		BackgroundColor3 = self._t.stroke,
		BorderSizePixel  = 0,
		ZIndex           = 4,
		Parent           = main,
	})
	ref(tabSep, "BackgroundColor3", "stroke")

	local contentArea = mkI("Frame", {
		Size                   = UDim2.new(1, 0, 1, -80),
		Position               = UDim2.new(0, 0, 0, 80),
		BackgroundTransparency = 1,
		ZIndex                 = 3,
		Parent                 = main,
	})
	self._contentArea = contentArea

	dragify(topbar, main, function()
		return (self._minimized and canDragMin) or (not self._minimized and canDrag)
	end)

	minBtn.MouseButton1Click:Connect(function()
		self._minimized = not self._minimized
		if self._minimized then
			tw(main, 0.35, {Size = UDim2.new(0, W, 0, 44)})
			task.delay(0.01, function()
				contentArea.Visible = false
				tabBar.Visible      = false
				tabSep.Visible      = false
				tbLine.Visible      = false
				tbfix.Visible       = false
			end)
			minBtn.Text = "+"
		else
			contentArea.Visible = true
			tabBar.Visible      = true
			tabSep.Visible      = true
			tbLine.Visible      = true
			tbfix.Visible       = true
			tw(main, 0.35, {Size = self._originalSize})
			minBtn.Text = "−"
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		tw(main, 0.28, {Size = UDim2.new(0, W, 0, 0)})
		task.delay(0.3, function() gui:Destroy() end)
	end)

	local notifySoundId = 3023237993
	local NW = isMobile and 280 or 320
	local NH = isMobile and 82 or 74

	function self:Notify(title, msg, duration)
		duration = duration or 5
		self._notifyCount = self._notifyCount + 1
		local index = self._notifyCount
		local nf = mkI("Frame", {
			Size                   = UDim2.new(0, NW, 0, NH),
			Position               = UDim2.new(1, NW+16, 1, -(NH+24)-((index-1)*(NH+10))),
			BackgroundColor3       = Color3.fromRGB(10, 10, 10),
			BorderSizePixel        = 0,
			ZIndex                 = 20,
			Parent                 = gui,
		})
		mkC(nf, 10)
		mkS(nf, Color3.fromRGB(40, 40, 40), 1)
		mkI("TextLabel", {
			Text                   = (title or "notification"):upper(),
			Size                   = UDim2.new(1, -16, 0, 16),
			Position               = UDim2.new(0, 12, 0, 10),
			BackgroundTransparency = 1,
			TextColor3             = Color3.fromRGB(255, 255, 255),
			TextTransparency       = 0.45,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Font                   = Enum.Font.GothamBold,
			TextSize               = isMobile and 10 or 9,
			ZIndex                 = 21,
			Parent                 = nf,
		})
		mkI("TextLabel", {
			Text                   = msg or "",
			Size                   = UDim2.new(1, -16, 0, 30),
			Position               = UDim2.new(0, 12, 0, 28),
			BackgroundTransparency = 1,
			TextColor3             = Color3.fromRGB(235, 235, 235),
			TextXAlignment         = Enum.TextXAlignment.Left,
			TextWrapped            = true,
			Font                   = Enum.Font.Gotham,
			TextSize               = isMobile and 13 or 12,
			ZIndex                 = 21,
			Parent                 = nf,
		})
		local pbTrack = mkI("Frame", {
			Size             = UDim2.new(1, -24, 0, isMobile and 4 or 3),
			Position         = UDim2.new(0, 12, 1, -(isMobile and 14 or 12)),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BorderSizePixel  = 0,
			ZIndex           = 21,
			Parent           = nf,
		})
		mkC(pbTrack, 999)
		local pbFill = mkI("Frame", {
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel  = 0,
			ZIndex           = 22,
			Parent           = pbTrack,
		})
		mkC(pbFill, 999)
		pbFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		playSound(notifySoundId)
		tw(nf, 0.45, {Position = UDim2.new(1, -(NW+16), 1, -(NH+24)-((index-1)*(NH+10)))}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		task.delay(0.45, function()
			TS:Create(pbFill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, 0)}):Play()
		end)
		task.delay(duration + 0.45, function()
			tw(nf, 0.4, {Position = UDim2.new(1, NW+16, 1, -(NH+24)-((index-1)*(NH+10)))}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			task.delay(0.45, function()
				nf:Destroy()
				self._notifyCount = self._notifyCount - 1
			end)
		end)
	end

	function self:_applyTheme()
		local t = self._t
		for _, r in ipairs(self._refs) do
			local col = t[r.key]
			if col then tw(r.obj, 0.3, {[r.prop] = col}) end
		end
		for _, tg in ipairs(self._toggles) do
			if tg.getState() then tw(tg.track, 0.3, {BackgroundColor3 = t.accent}) end
		end
		for _, tb_ in ipairs(self._tabBtns) do
			local active = (tb_.tabObj == self._activeTab)
			tw(tb_.btn, 0.3, {
				BackgroundColor3 = active and t.accent or t.element,
				TextColor3       = active and Color3.new(1,1,1) or t.sub,
			})
		end
	end

	function self:SetTheme(name)
		self._t = THEMES[name] or THEMES.Default
		self:_applyTheme()
	end

	function self:ThemeSection(tab)
		local sec = tab:Section("Themes")
		for name in pairs(THEMES) do
			local n = name
			sec:Button(n, function() self:SetTheme(n) end)
		end
	end

	function self:Tab(name, icon)
		local win    = self
		local btnH   = isMobile and 34 or 30
		local fSize  = isMobile and 14 or 12

		local txtBounds = TSvc:GetTextSize(name, fSize, Enum.Font.GothamMedium, Vector2.new(1000, 100))
		local padH      = isMobile and 28 or 22
		local iconExtra = (icon and icon ~= "") and (isMobile and 22 or 18) or 0
		local btnW      = txtBounds.X + padH + iconExtra

		local tabBtn = mkI("TextButton", {
			Text             = "",
			Size             = UDim2.new(0, btnW, 0, btnH),
			BackgroundColor3 = self._t.element,
			BorderSizePixel  = 0,
			ZIndex           = 6,
			Parent           = self._tabBar,
		})
		mkC(tabBtn, 6)

		local innerLayout = Instance.new("UIListLayout")
		innerLayout.FillDirection       = Enum.FillDirection.Horizontal
		innerLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
		innerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		innerLayout.Padding             = UDim.new(0, 5)
		innerLayout.Parent              = tabBtn

		local innerPad = Instance.new("UIPadding")
		innerPad.PaddingLeft  = UDim.new(0, isMobile and 14 or 10)
		innerPad.PaddingRight = UDim.new(0, isMobile and 14 or 10)
		innerPad.Parent       = tabBtn

		local iconImg = nil
		if icon and icon ~= "" then
			iconImg = mkI("ImageLabel", {
				Size                   = UDim2.new(0, isMobile and 16 or 13, 0, isMobile and 16 or 13),
				BackgroundTransparency = 1,
				Image                  = icon,
				ImageColor3            = self._t.sub,
				ZIndex                 = 7,
				Parent                 = tabBtn,
			})
			ref(iconImg, "ImageColor3", "sub")
		end

		local tabLabel = mkI("TextLabel", {
			Size                   = UDim2.new(0, txtBounds.X, 1, 0),
			BackgroundTransparency = 1,
			TextColor3             = self._t.sub,
			Text                   = name,
			Font                   = Enum.Font.GothamMedium,
			TextSize               = fSize,
			TextXAlignment         = Enum.TextXAlignment.Center,
			ZIndex                 = 7,
			Parent                 = tabBtn,
		})
		ref(tabLabel, "TextColor3", "sub")

		local scroll = mkI("ScrollingFrame", {
			Size                   = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel        = 0,
			ScrollBarThickness     = isMobile and 3 or 2,
			ScrollBarImageColor3   = Color3.fromRGB(55, 55, 55),
			CanvasSize             = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize    = Enum.AutomaticSize.Y,
			Visible                = false,
			ZIndex                 = 3,
			Parent                 = self._contentArea,
		})
		local sl = Instance.new("UIListLayout")
		sl.Padding             = UDim.new(0, isMobile and 10 or 8)
		sl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		sl.Parent              = scroll
		local sp = Instance.new("UIPadding")
		sp.PaddingTop    = UDim.new(0, isMobile and 12 or 10)
		sp.PaddingBottom = UDim.new(0, isMobile and 12 or 10)
		sp.PaddingLeft   = UDim.new(0, isMobile and 14 or 12)
		sp.PaddingRight  = UDim.new(0, isMobile and 14 or 12)
		sp.Parent        = scroll

		local tabObj = {
			_win    = win,
			_scroll = scroll,
			_btn    = tabBtn,
			_label  = tabLabel,
			_icon   = iconImg,
			_name   = name,
		}
		table.insert(self._tabs, tabObj)
		table.insert(self._tabBtns, {btn = tabBtn, label = tabLabel, icon = iconImg, tabObj = tabObj})

		local function activate()
			for _, tb_ in ipairs(win._tabBtns) do
				local isThis = (tb_.tabObj == tabObj)
				tb_.tabObj._scroll.Visible = isThis
				tw(tb_.btn,   0.2, {BackgroundColor3 = isThis and win._t.accent or win._t.element})
				tw(tb_.label, 0.2, {TextColor3 = isThis and Color3.new(1,1,1) or win._t.sub})
				if tb_.icon then
					tw(tb_.icon, 0.2, {ImageColor3 = isThis and Color3.new(1,1,1) or win._t.sub})
				end
			end
			if win._activeTab ~= nil and win._activeTab ~= tabObj and win._tabSound then
				playSound(3023237993)
			end
			win._activeTab = tabObj
		end

		tabBtn.MouseButton1Click:Connect(activate)
		if #self._tabs == 1 then activate() end

		function tabObj:Section(sname)
			local sec = {_tab = tabObj, _win = win}
			local mob = isMobile

			local sf = mkI("Frame", {
				Size                   = UDim2.new(1, 0, 0, 0),
				AutomaticSize          = Enum.AutomaticSize.Y,
				BackgroundColor3       = win._t.section,
				BorderSizePixel        = 0,
				Parent                 = scroll,
			})
			mkC(sf, 8)
			local sfs = mkS(sf, win._t.stroke, 1)
			ref(sf,  "BackgroundColor3", "section")
			ref(sfs, "Color", "stroke")

			local sfL = Instance.new("UIListLayout")
			sfL.Padding             = UDim.new(0, mob and 8 or 6)
			sfL.HorizontalAlignment = Enum.HorizontalAlignment.Center
			sfL.Parent              = sf
			local sfP = Instance.new("UIPadding")
			sfP.PaddingTop    = UDim.new(0, mob and 10 or 8)
			sfP.PaddingBottom = UDim.new(0, mob and 12 or 10)
			sfP.PaddingLeft   = UDim.new(0, mob and 12 or 10)
			sfP.PaddingRight  = UDim.new(0, mob and 12 or 10)
			sfP.Parent        = sf

			if sname and sname ~= "" then
				local hdr = mkI("Frame", {
					Size                   = UDim2.new(1, 0, 0, mob and 28 or 24),
					BackgroundTransparency = 1,
					Parent                 = sf,
				})
				local bar = mkI("Frame", {
					Size             = UDim2.new(0, mob and 4 or 3, 0, mob and 16 or 14),
					Position         = UDim2.new(0, 0, 0.5, mob and -8 or -7),
					BackgroundColor3 = win._t.accent,
					BorderSizePixel  = 0,
					Parent           = hdr,
				})
				mkC(bar, 2)
				ref(bar, "BackgroundColor3", "accent")
				local hL = mkI("TextLabel", {
					Text                   = sname,
					Size                   = UDim2.new(1, -16, 1, 0),
					Position               = UDim2.new(0, mob and 14 or 12, 0, 0),
					BackgroundTransparency = 1,
					TextColor3             = win._t.text,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.GothamBold,
					TextSize               = mob and 14 or 13,
					Parent                 = hdr,
				})
				ref(hL, "TextColor3", "text")
				mkI("Frame", {
					Size                   = UDim2.new(1, 0, 0, 4),
					BackgroundTransparency = 1,
					Parent                 = sf,
				})
			end

			function sec:Button(text, cb)
				local bh  = mob and 42 or 34
				local btn = mkI("TextButton", {
					Text             = text,
					Size             = UDim2.new(1, 0, 0, bh),
					BackgroundColor3 = win._t.element,
					TextColor3       = win._t.text,
					Font             = Enum.Font.GothamMedium,
					TextSize         = mob and 14 or 13,
					BorderSizePixel  = 0,
					ClipsDescendants = true,
					Parent           = sf,
				})
				mkC(btn, 6)
				ref(btn, "BackgroundColor3", "element")
				ref(btn, "TextColor3", "text")
				btn.MouseEnter:Connect(function()
					tw(btn, 0.12, {BackgroundColor3 = Color3.fromRGB(
						math.min(win._t.element.R*255+10, 255),
						math.min(win._t.element.G*255+10, 255),
						math.min(win._t.element.B*255+10, 255)
					)})
				end)
				btn.MouseLeave:Connect(function() tw(btn, 0.12, {BackgroundColor3 = win._t.element}) end)
				btn.MouseButton1Click:Connect(function()
					local m = UIS:GetMouseLocation()
					ripple(btn, m.X, m.Y)
					if cb then task.spawn(cb) end
				end)
			end

			function sec:Toggle(text, default, cb)
				local state = default == true
				local h = mkI("Frame", {
					Size             = UDim2.new(1, 0, 0, mob and 42 or 34),
					BackgroundColor3 = win._t.element,
					BorderSizePixel  = 0,
					Parent           = sf,
				})
				mkC(h, 6)
				ref(h, "BackgroundColor3", "element")
				local lbl = mkI("TextLabel", {
					Text                   = text,
					Size                   = UDim2.new(1, -64, 1, 0),
					Position               = UDim2.new(0, mob and 14 or 12, 0, 0),
					BackgroundTransparency = 1,
					TextColor3             = win._t.text,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.GothamMedium,
					TextSize               = mob and 14 or 13,
					Parent                 = h,
				})
				ref(lbl, "TextColor3", "text")
				local tw_  = mob and 44 or 36
				local th_  = mob and 24 or 20
				local trk  = mkI("Frame", {
					Size             = UDim2.new(0, tw_, 0, th_),
					Position         = UDim2.new(1, -(tw_+10), 0.5, -th_/2),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					BorderSizePixel  = 0,
					Parent           = h,
				})
				mkC(trk, 999)
				local kw  = mob and 18 or 14
				local knb = mkI("Frame", {
					Size             = UDim2.new(0, kw, 0, kw),
					Position         = UDim2.new(0, mob and 4 or 3, 0.5, -kw/2),
					BackgroundColor3 = Color3.fromRGB(140, 140, 140),
					BorderSizePixel  = 0,
					ZIndex           = 2,
					Parent           = trk,
				})
				mkC(knb, 999)
				local onX  = mob and 22 or 19
				local offX = mob and 4 or 3
				local function set(v, anim)
					state = v
					local d = anim and 0.2 or 0
					if state then
						tw(trk, d, {BackgroundColor3 = win._t.accent})
						tw(knb, d, {Position = UDim2.new(0, onX, 0.5, -kw/2), BackgroundColor3 = Color3.new(1,1,1)})
					else
						tw(trk, d, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
						tw(knb, d, {Position = UDim2.new(0, offX, 0.5, -kw/2), BackgroundColor3 = Color3.fromRGB(140, 140, 140)})
					end
				end
				set(state, false)
				table.insert(win._toggles, {track = trk, getState = function() return state end})
				local cl = mkI("TextButton", {
					Size                   = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text                   = "",
					ZIndex                 = 3,
					Parent                 = h,
				})
				cl.MouseButton1Click:Connect(function()
					set(not state, true)
					if cb then task.spawn(cb, state) end
				end)
				local obj = {}
				function obj:Set(v) set(v, true) end
				function obj:Get() return state end
				return obj
			end

			function sec:Slider(text, min, max, default, cb)
				local h = mkI("Frame", {
					Size             = UDim2.new(1, 0, 0, mob and 56 or 50),
					BackgroundColor3 = win._t.element,
					BorderSizePixel  = 0,
					Parent           = sf,
				})
				mkC(h, 6)
				ref(h, "BackgroundColor3", "element")
				local lbl = mkI("TextLabel", {
					Text                   = text,
					Size                   = UDim2.new(1, -70, 0, mob and 22 or 20),
					Position               = UDim2.new(0, mob and 14 or 12, 0, mob and 9 or 8),
					BackgroundTransparency = 1,
					TextColor3             = win._t.text,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.GothamMedium,
					TextSize               = mob and 13 or 12,
					Parent                 = h,
				})
				ref(lbl, "TextColor3", "text")
				local valT = mkI("TextLabel", {
					Size                   = UDim2.new(0, 54, 0, mob and 22 or 20),
					Position               = UDim2.new(1, -62, 0, mob and 9 or 8),
					BackgroundTransparency = 1,
					TextColor3             = win._t.sub,
					TextXAlignment         = Enum.TextXAlignment.Right,
					Font                   = Enum.Font.GothamMedium,
					TextSize               = mob and 13 or 12,
					Parent                 = h,
				})
				ref(valT, "TextColor3", "sub")
				local trk = mkI("Frame", {
					Size             = UDim2.new(1, mob and -28 or -24, 0, mob and 4 or 3),
					Position         = UDim2.new(0, mob and 14 or 12, 0, mob and 40 or 38),
					BackgroundColor3 = Color3.fromRGB(28, 28, 28),
					BorderSizePixel  = 0,
					Parent           = h,
				})
				mkC(trk, 999)
				local fill = mkI("Frame", {
					Size             = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = win._t.accent,
					BorderSizePixel  = 0,
					Parent           = trk,
				})
				mkC(fill, 999)
				ref(fill, "BackgroundColor3", "accent")
				local ks  = mob and 13 or 11
				local knb = mkI("Frame", {
					Size             = UDim2.new(0, ks, 0, ks),
					AnchorPoint      = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel  = 0,
					ZIndex           = 2,
					Parent           = trk,
				})
				mkC(knb, 999)
				local cur       = default
				local dragging_ = false
				local function sv(v)
					cur = math.clamp(v, min, max)
					local p = (cur - min) / (max - min)
					fill.Size    = UDim2.new(p, 0, 1, 0)
					knb.Position = UDim2.new(p, 0, 0.5, 0)
					valT.Text    = tostring(math.floor(cur))
					if cb then cb(cur) end
				end
				sv(default)
				trk.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging_ = true
						local con
						con = UIS.InputChanged:Connect(function(i)
							if not dragging_ then con:Disconnect() return end
							if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
								sv(min + (max-min) * math.clamp((i.Position.X - trk.AbsolutePosition.X) / trk.AbsoluteSize.X, 0, 1))
							end
						end)
					end
				end)
				UIS.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging_ = false
					end
				end)
				local obj = {}
				function obj:Set(v) sv(v) end
				function obj:Get() return cur end
				return obj
			end

			function sec:Dropdown(text, options, cb)
				local selected_ = nil
				local open_     = false
				local HH        = mob and 42 or 36
				local con = mkI("Frame", {
					Size             = UDim2.new(1, 0, 0, HH),
					BackgroundColor3 = Color3.fromRGB(10, 10, 10),
					BorderSizePixel  = 0,
					ClipsDescendants = true,
					Parent           = sf,
				})
				mkC(con, 6)
				local cs = mkS(con, win._t.stroke, 1)
				ref(cs, "Color", "stroke")
				local hBtn = mkI("TextButton", {
					Size                   = UDim2.new(1, 0, 0, HH),
					BackgroundTransparency = 1,
					Text                   = "",
					ZIndex                 = 2,
					Parent                 = con,
				})
				local tL_ = mkI("TextLabel", {
					Text                   = text,
					Size                   = UDim2.new(0.5, 0, 1, 0),
					Position               = UDim2.new(0, mob and 14 or 12, 0, 0),
					BackgroundTransparency = 1,
					TextColor3             = win._t.text,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.GothamMedium,
					TextSize               = mob and 13 or 12,
					ZIndex                 = 3,
					Parent                 = hBtn,
				})
				ref(tL_, "TextColor3", "text")
				local selL = mkI("TextLabel", {
					Text                   = "select...",
					Size                   = UDim2.new(0.4, 0, 1, 0),
					Position               = UDim2.new(0.5, 0, 0, 0),
					BackgroundTransparency = 1,
					TextColor3             = win._t.sub,
					TextXAlignment         = Enum.TextXAlignment.Right,
					Font                   = Enum.Font.GothamMedium,
					TextSize               = mob and 13 or 12,
					ZIndex                 = 3,
					Parent                 = hBtn,
				})
				ref(selL, "TextColor3", "sub")
				local arr = mkI("TextLabel", {
					Text                   = "",
					Size                   = UDim2.new(0, 0, 1, 0),
					Position               = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					TextColor3             = win._t.sub,
					Font                   = Enum.Font.GothamBold,
					TextSize               = mob and 18 or 16,
					ZIndex                 = 3,
					Parent                 = hBtn,
				})
				local divL = mkI("Frame", {
					Size             = UDim2.new(1, -24, 0, 1),
					Position         = UDim2.new(0, 12, 0, HH),
					BackgroundColor3 = win._t.stroke,
					BorderSizePixel  = 0,
					Visible          = false,
					Parent           = con,
				})
				ref(divL, "BackgroundColor3", "stroke")
				local inner = mkI("Frame", {
					Size                   = UDim2.new(1, 0, 0, 0),
					Position               = UDim2.new(0, 0, 0, HH+1),
					BackgroundTransparency = 1,
					AutomaticSize          = Enum.AutomaticSize.Y,
					Parent                 = con,
				})
				local iL = Instance.new("UIListLayout")
				iL.Padding             = UDim.new(0, mob and 5 or 4)
				iL.HorizontalAlignment = Enum.HorizontalAlignment.Center
				iL.Parent              = inner
				local iP = Instance.new("UIPadding")
				iP.PaddingTop    = UDim.new(0, mob and 8 or 6)
				iP.PaddingBottom = UDim.new(0, mob and 8 or 6)
				iP.PaddingLeft   = UDim.new(0, mob and 10 or 8)
				iP.PaddingRight  = UDim.new(0, mob and 10 or 8)
				iP.Parent        = inner
				for _, opt in ipairs(options) do
					local ob = mkI("TextButton", {
						Size             = UDim2.new(1, 0, 0, mob and 34 or 28),
						BackgroundColor3 = Color3.fromRGB(16, 16, 16),
						TextColor3       = win._t.text,
						Text             = opt,
						Font             = Enum.Font.GothamMedium,
						TextSize         = mob and 13 or 12,
						BorderSizePixel  = 0,
						ClipsDescendants = true,
						ZIndex           = 3,
						Parent           = inner,
					})
					mkC(ob, 5)
					ref(ob, "TextColor3", "text")
					ob.MouseEnter:Connect(function() tw(ob, 0.1, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}) end)
					ob.MouseLeave:Connect(function() tw(ob, 0.1, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}) end)
					ob.MouseButton1Click:Connect(function()
						local m = UIS:GetMouseLocation()
						ripple(ob, m.X, m.Y)
						selected_    = opt
						selL.Text    = opt
						open_        = false
						divL.Visible = false
						tw(con, 0.25, {Size = UDim2.new(1, 0, 0, HH)})
						tw(arr, 0.25, {Rotation = 0})
						if cb then task.spawn(cb, opt) end
					end)
				end
				hBtn.MouseButton1Click:Connect(function()
					open_ = not open_
					if open_ then
						divL.Visible = true
						task.wait()
						tw(con, 0.3, {Size = UDim2.new(1, 0, 0, HH+1+inner.AbsoluteSize.Y)})
					else
						divL.Visible = false
						tw(con, 0.25, {Size = UDim2.new(1, 0, 0, HH)})
					end
					tw(arr, 0.25, {Rotation = open_ and 90 or 0})
				end)
				local obj = {}
				function obj:Set(v) selected_ = v selL.Text = v end
				function obj:Get() return selected_ end
				return obj
			end

			function sec:ColorPicker(text, default, cb)
				local r_ = default and math.floor(default.R*255) or 180
				local g_ = default and math.floor(default.G*255) or 25
				local b_ = default and math.floor(default.B*255) or 25
				local wr = mkI("Frame", {
					Size             = UDim2.new(1, 0, 0, 0),
					AutomaticSize    = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(10, 10, 10),
					BorderSizePixel  = 0,
					Parent           = sf,
				})
				mkC(wr, 6)
				local ws = mkS(wr, win._t.stroke, 1)
				ref(ws, "Color", "stroke")
				local wL = Instance.new("UIListLayout")
				wL.Padding             = UDim.new(0, mob and 9 or 8)
				wL.HorizontalAlignment = Enum.HorizontalAlignment.Center
				wL.Parent              = wr
				local wP = Instance.new("UIPadding")
				wP.PaddingTop    = UDim.new(0, mob and 12 or 10)
				wP.PaddingBottom = UDim.new(0, mob and 14 or 12)
				wP.PaddingLeft   = UDim.new(0, mob and 12 or 10)
				wP.PaddingRight  = UDim.new(0, mob and 12 or 10)
				wP.Parent        = wr
				local hL2 = mkI("TextLabel", {
					Text                   = text,
					Size                   = UDim2.new(1, 0, 0, mob and 20 or 18),
					BackgroundTransparency = 1,
					TextColor3             = win._t.text,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.GothamMedium,
					TextSize               = mob and 13 or 12,
					Parent                 = wr,
				})
				ref(hL2, "TextColor3", "text")
				local pvS = mob and 50 or 44
				local pr  = mkI("Frame", {Size = UDim2.new(1, 0, 0, pvS), BackgroundTransparency = 1, Parent = wr})
				local pv  = mkI("Frame", {
					Size             = UDim2.new(0, pvS, 0, pvS),
					BackgroundColor3 = Color3.fromRGB(r_, g_, b_),
					BorderSizePixel  = 0,
					Parent           = pr,
				})
				mkC(pv, 8)
				mkS(pv, win._t.stroke, 1)
				local hx = mkI("TextLabel", {
					Size                   = UDim2.new(1, -(pvS+10), 0, mob and 24 or 22),
					Position               = UDim2.new(0, pvS+10, 0, 0),
					BackgroundTransparency = 1,
					TextColor3             = win._t.text,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.GothamBold,
					TextSize               = mob and 15 or 14,
					Parent                 = pr,
				})
				ref(hx, "TextColor3", "text")
				local rb = mkI("TextLabel", {
					Size                   = UDim2.new(1, -(pvS+10), 0, mob and 18 or 16),
					Position               = UDim2.new(0, pvS+10, 0, mob and 26 or 24),
					BackgroundTransparency = 1,
					TextColor3             = win._t.sub,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.Gotham,
					TextSize               = mob and 12 or 11,
					Parent                 = pr,
				})
				ref(rb, "TextColor3", "sub")
				local function upd()
					local col = Color3.fromRGB(r_, g_, b_)
					pv.BackgroundColor3 = col
					hx.Text = string.format("#%02X%02X%02X", r_, g_, b_)
					rb.Text = string.format("%d,  %d,  %d", r_, g_, b_)
					if cb then cb(col) end
				end
				upd()
				local function mkCh(lbl_, init_, fc, onChange)
					local row = mkI("Frame", {Size = UDim2.new(1, 0, 0, mob and 28 or 26), BackgroundTransparency = 1, Parent = wr})
					mkI("TextLabel", {
						Text                   = lbl_,
						Size                   = UDim.new(0, mob and 14 or 12, 1, 0),
						BackgroundTransparency = 1,
						TextColor3             = fc,
						Font                   = Enum.Font.GothamBold,
						TextSize               = mob and 12 or 11,
						Parent                 = row,
					})
					local vt = mkI("TextLabel", {
						Size                   = UDim2.new(0, mob and 28 or 26, 1, 0),
						Position               = UDim2.new(1, mob and -28 or -26, 0, 0),
						BackgroundTransparency = 1,
						TextColor3             = win._t.sub,
						TextXAlignment         = Enum.TextXAlignment.Right,
						Font                   = Enum.Font.GothamMedium,
						TextSize               = mob and 12 or 11,
						Text                   = tostring(init_),
						Parent                 = row,
					})
					ref(vt, "TextColor3", "sub")
					local trk_ = mkI("Frame", {
						Size             = UDim2.new(1, mob and -52 or -46, 0, mob and 5 or 4),
						Position         = UDim2.new(0, mob and 20 or 18, 0.5, mob and -2.5 or -2),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel  = 0,
						Parent           = row,
					})
					mkC(trk_, 999)
					local fi_ = mkI("Frame", {
						Size             = UDim2.new(init_/255, 0, 1, 0),
						BackgroundColor3 = fc,
						BorderSizePixel  = 0,
						Parent           = trk_,
					})
					mkC(fi_, 999)
					local ks_ = mob and 11 or 10
					local kn_ = mkI("Frame", {
						Size             = UDim2.new(0, ks_, 0, ks_),
						AnchorPoint      = Vector2.new(0.5, 0.5),
						Position         = UDim2.new(init_/255, 0, 0.5, 0),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderSizePixel  = 0,
						ZIndex           = 2,
						Parent           = trk_,
					})
					mkC(kn_, 999)
					local dg_ = false
					local function sv_(pct)
						pct = math.clamp(pct, 0, 1)
						local v = math.floor(pct * 255)
						fi_.Size     = UDim2.new(pct, 0, 1, 0)
						kn_.Position = UDim2.new(pct, 0, 0.5, 0)
						vt.Text      = tostring(v)
						onChange(v)
					end
					trk_.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							dg_ = true
							sv_(math.clamp((inp.Position.X - trk_.AbsolutePosition.X) / trk_.AbsoluteSize.X, 0, 1))
							local con
							con = UIS.InputChanged:Connect(function(i)
								if not dg_ then con:Disconnect() return end
								if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
									sv_(math.clamp((i.Position.X - trk_.AbsolutePosition.X) / trk_.AbsoluteSize.X, 0, 1))
								end
							end)
						end
					end)
					UIS.InputEnded:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							dg_ = false
						end
					end)
				end
				mkCh("R", r_, Color3.fromRGB(210, 55, 55),  function(v) r_ = v upd() end)
				mkCh("G", g_, Color3.fromRGB(55, 195, 75),  function(v) g_ = v upd() end)
				mkCh("B", b_, Color3.fromRGB(55, 115, 215), function(v) b_ = v upd() end)
			end

			function sec:Label(text_)
				local l = mkI("TextLabel", {
					Text                   = text_,
					Size                   = UDim2.new(1, 0, 0, mob and 22 or 20),
					BackgroundTransparency = 1,
					TextColor3             = win._t.sub,
					TextXAlignment         = Enum.TextXAlignment.Left,
					Font                   = Enum.Font.Gotham,
					TextSize               = mob and 13 or 12,
					Parent                 = sf,
				})
				ref(l, "TextColor3", "sub")
				return l
			end

			function sec:Input(placeholder_, cb)
				local box = mkI("TextBox", {
					Size              = UDim2.new(1, 0, 0, mob and 42 or 34),
					BackgroundColor3  = win._t.element,
					TextColor3        = win._t.text,
					PlaceholderColor3 = win._t.sub,
					PlaceholderText   = placeholder_ or "type here...",
					Text              = "",
					Font              = Enum.Font.GothamMedium,
					TextSize          = mob and 14 or 13,
					BorderSizePixel   = 0,
					ClearTextOnFocus  = false,
					Parent            = sf,
				})
				mkC(box, 6)
				local bs = mkS(box, win._t.stroke, 1)
				ref(bs,  "Color", "stroke")
				ref(box, "BackgroundColor3", "element")
				ref(box, "TextColor3", "text")
				local bp = Instance.new("UIPadding")
				bp.PaddingLeft = UDim.new(0, mob and 12 or 10)
				bp.Parent      = box
				box.Focused:Connect(function() tw(bs, 0.2, {Color = win._t.accent}) end)
				box.FocusLost:Connect(function(enter)
					tw(bs, 0.2, {Color = win._t.stroke})
					if enter and cb then task.spawn(cb, box.Text) end
				end)
				return box
			end

			sec._sf = sf
			return sec
		end

		return tabObj
	end

	function self:Destroy()
		self._gui:Destroy()
	end

	return self
end

-- ================================================================
--  XNOCTIS
-- ================================================================

local win = IceLib.new({
	Title              = "Xnoctis",
	Theme              = "Default",
	Draggable          = true,
	DraggableMinimized = true,
	Width              = 520,
})

-- ================ ACTIONS AND GAME FEATURES ================
local ACTIONS = {
	Teleport    = { Enabled = false, Key = Enum.KeyCode.F },
	Trip        = { Enabled = false, Key = Enum.KeyCode.T },
	Rewind      = { Enabled = false, Key = Enum.KeyCode.C },
	Facebang    = { Enabled = false, Key = Enum.KeyCode.Z },
	Glitch      = { Enabled = false, Key = Enum.KeyCode.X },
	Refresh     = { Enabled = false, Key = Enum.KeyCode.G },
	Invisible   = { Enabled = false, Key = Enum.KeyCode.V },
	Sfly        = { Enabled = false, Key = Enum.KeyCode.H },
	MenuToggle  = { Enabled = true,  Key = Enum.KeyCode.K },
}

-- Facebang system
local facebangSpeed        = 0.2
local facebangActive       = false
local facebangTarget       = nil
local playersCache         = {}
local lastPlayerCacheTime  = 0
local PLAYER_CACHE_INTERVAL = 0.5

local function findNearestPlayer()
	local now = tick()
	if now - lastPlayerCacheTime > PLAYER_CACHE_INTERVAL then
		playersCache = Players:GetPlayers()
		lastPlayerCacheTime = now
	end
	local nearestDist   = math.huge
	local nearestPlayer = nil
	local myHRP = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end
	local myPos = myHRP.Position
	for i = 1, #playersCache do
		local plr = playersCache[i]
		if plr ~= Players.LocalPlayer then
			local char = plr.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local dist = (myPos - hrp.Position).Magnitude
					if dist < nearestDist then
						nearestPlayer = plr
						nearestDist   = dist
					end
				end
			end
		end
	end
	return nearestPlayer
end

local function startFacebang()
	local lp   = Players.LocalPlayer
	local char = lp.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	if not facebangActive then
		local target = findNearestPlayer()
		if target and hum.PlatformStand == false then
			hum.PlatformStand = true
			local originalCFrame = hrp.CFrame
			task.spawn(function()
				repeat task.wait() until hum.PlatformStand == false
				facebangActive = false
				hrp.CFrame = facebangTarget and CFrame.new(facebangTarget) or originalCFrame
			end)
			facebangActive = true
			task.spawn(function()
				local counter  = 0
				local sinCache = {}
				for i = 0, 628 do sinCache[i] = math.sin(i * 0.01) end
				while facebangActive do
					counter = counter + 1
					RS.Stepped:Wait()
					if facebangActive and target.Character and target.Character:FindFirstChild("Head") then
						hrp.Velocity = Vector3.new(0, 0, 0)
						local sineIndex = (counter * math.floor(facebangSpeed * 100)) % 628
						hrp.CFrame = target.Character.Head.CFrame
							* CFrame.new(0, 1, -0.5 + sinCache[sineIndex] * 0.5)
							* CFrame.Angles(0, math.rad(180), 0)
						facebangTarget = target.Character.HumanoidRootPart.Position
					end
				end
			end)
		end
	else
		facebangActive    = false
		hum.PlatformStand = false
	end
end

local humanoid, HRP
local function bindCharacter()
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	humanoid   = char:WaitForChild("Humanoid")
	HRP        = char:WaitForChild("HumanoidRootPart")
end
bindCharacter()
Players.LocalPlayer.CharacterAdded:Connect(bindCharacter)

-- ================ INVISIBILITY SYSTEM ================
local invisActive  = false
local invisParts   = {}

local function collectInvisParts()
	invisParts = {}
	local char = Players.LocalPlayer.Character
	if not char then return end
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 0 then
			invisParts[#invisParts + 1] = v
		end
	end
end
collectInvisParts()

local function toggleInvis()
	if not ACTIONS.Invisible.Enabled then return end
	invisActive = not invisActive
	for _, part in ipairs(invisParts) do
		part.Transparency = invisActive and 0.5 or 0
	end
end

RS.Heartbeat:Connect(function()
	if not invisActive then return end
	-- Skip the HRP teleport trick if shift lock is active to prevent camera glitching
	if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then return end
	local hrp_ = HRP
	local hum_ = humanoid
	if not hrp_ or not hum_ then return end
	local cf = hrp_.CFrame
	local co = hum_.CameraOffset
	local below = cf * CFrame.new(0, -200, 0)
	hrp_.CFrame = below
	hum_.CameraOffset = below:ToObjectSpace(CFrame.new(cf.Position)).Position
	RS.RenderStepped:Wait()
	hrp_.CFrame = cf
	hum_.CameraOffset = co
end)

Players.LocalPlayer.CharacterAdded:Connect(function()
	invisActive = false
	collectInvisParts()
end)

-- ================ SFLY SYSTEM ================
local sflyActive       = false
local sflySpeed        = 120
local sflyConns        = {}
local sflyMoveState    = { forward=0, backward=0, left=0, right=0 }
local sflyVelocity     = Vector3.new(0,0,0)
local sflyCF           = nil
local sflyAnimTrack    = nil
local originalGravity  = workspace.Gravity

local function sflyDisableAnim()
	local anim = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Animate")
	if anim then anim.Disabled = true end
end
local function sflyEnableAnim()
	local anim = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Animate")
	if anim then anim.Disabled = false end
end
local function sflyPlayAnim(id, startT, spd)
	if sflyAnimTrack then sflyAnimTrack:Stop(0.1) sflyAnimTrack = nil end
	sflyDisableAnim()
	if humanoid then
		for _, t in ipairs(humanoid:GetPlayingAnimationTracks()) do t:Stop() end
		local a = Instance.new("Animation") a.AnimationId = "rbxassetid://"..tostring(id)
		sflyAnimTrack = humanoid:LoadAnimation(a)
		sflyAnimTrack:Play() sflyAnimTrack.TimePosition = startT sflyAnimTrack:AdjustSpeed(spd)
	end
end
local function sflyStopAnim()
	if sflyAnimTrack then sflyAnimTrack:Stop(0.1) sflyAnimTrack = nil end
	sflyEnableAnim()
	if humanoid then
		for _, t in ipairs(humanoid:GetPlayingAnimationTracks()) do t:Stop() end
	end
end

local function startSfly()
	if sflyActive then return end
	local char = Players.LocalPlayer.Character
	local hrp_ = HRP local hum_ = humanoid
	if not char or not hrp_ or not hum_ then return end
	sflyActive = true
	hum_:ChangeState(Enum.HumanoidStateType.Jumping)
	task.wait(0.1)
	workspace.Gravity = 0
	hum_.PlatformStand = true
	sflyPlayAnim(10714347256, 4, 0)
	local gyro = Instance.new("BodyGyro")
	gyro.Name = "SflyGyro" gyro.Parent = hrp_
	gyro.P = 90000 gyro.MaxTorque = Vector3.new(9e9,9e9,9e9) gyro.CFrame = hrp_.CFrame
	local bv = Instance.new("BodyVelocity")
	bv.Name = "SflyVelocity" bv.Parent = hrp_
	bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.new(0,0.1,0)
	sflyVelocity = Vector3.new(0,0,0)
	local upd = RS.RenderStepped:Connect(function()
		local cam = workspace.CurrentCamera
		local fwd  = sflyMoveState.forward  - sflyMoveState.backward
		local side = sflyMoveState.right    - sflyMoveState.left
		local iv = (cam.CFrame.LookVector*fwd) + (cam.CFrame.RightVector*side)
		if fwd ~= 0 then iv = iv + Vector3.new(0, 0.2*fwd, 0) end
		local bob = math.sin(tick()*3)*2
		local dv = iv.Magnitude > 0 and iv.Unit*sflySpeed or Vector3.new(0,bob,0)
		sflyVelocity = sflyVelocity:Lerp(dv, 0.25) bv.Velocity = sflyVelocity
		local dcf = fwd > 0
			and cam.CFrame * CFrame.Angles(math.rad(-90),0,0)
			or  cam.CFrame * CFrame.Angles(math.rad(-45*fwd),0,0)
		sflyCF = sflyCF and sflyCF:Lerp(dcf, 0.2) or dcf
		gyro.CFrame = sflyCF
	end)
	table.insert(sflyConns, upd)
	local kb = UIS.InputBegan:Connect(function(inp, gp)
		if gp then return end
		local k = inp.KeyCode
		if k == Enum.KeyCode.W then sflyMoveState.forward=1  sflyPlayAnim(10714177846,4.65,0)
		elseif k == Enum.KeyCode.S then sflyMoveState.backward=1 sflyPlayAnim(10714347256,4,0)
		elseif k == Enum.KeyCode.A then sflyMoveState.left=1
		elseif k == Enum.KeyCode.D then sflyMoveState.right=1 end
	end)
	local ke = UIS.InputEnded:Connect(function(inp)
		local k = inp.KeyCode
		if k == Enum.KeyCode.W then sflyMoveState.forward=0  sflyPlayAnim(10714347256,4,0)
		elseif k == Enum.KeyCode.S then sflyMoveState.backward=0 sflyPlayAnim(10714347256,4,0)
		elseif k == Enum.KeyCode.A then sflyMoveState.left=0
		elseif k == Enum.KeyCode.D then sflyMoveState.right=0 end
	end)
	table.insert(sflyConns, kb) table.insert(sflyConns, ke)
end

local function stopSfly()
	if not sflyActive then return end
	sflyActive = false
	workspace.Gravity = originalGravity
	if humanoid then humanoid.PlatformStand = false end
	sflyStopAnim()
	if HRP then
		if HRP:FindFirstChild("SflyGyro")    then HRP.SflyGyro:Destroy()    end
		if HRP:FindFirstChild("SflyVelocity") then HRP.SflyVelocity:Destroy() end
	end
	for _, c in ipairs(sflyConns) do if c.Connected then c:Disconnect() end end
	sflyConns = {} sflyMoveState = {forward=0,backward=0,left=0,right=0}
end

Players.LocalPlayer.CharacterAdded:Connect(function()
	stopSfly()
end)

-- ================ INPUT ================
local mouse = Players.LocalPlayer:GetMouse()

UIS.InputBegan:Connect(function(input, gpe)
	if gpe or UIS:GetFocusedTextBox() then return end

	if ACTIONS.Teleport.Enabled and input.KeyCode == ACTIONS.Teleport.Key then
		pcall(function()
			local character = Players.LocalPlayer.Character
			local hum_      = character:FindFirstChildOfClass("Humanoid")
			if hum_ and hum_.SeatPart then
				hum_.Sit = false
				task.wait(0.1)
			end
			local hipHeight    = hum_ and hum_.HipHeight > 0 and (hum_.HipHeight + 1)
			local rootPart     = HRP or character:FindFirstChild("HumanoidRootPart")
			local rootPartPos  = rootPart.Position
			local hitPosition  = mouse.Hit.Position
			local newCFrame    = CFrame.new(
				hitPosition,
				Vector3.new(rootPartPos.X, hitPosition.Y, rootPartPos.Z)
			) * CFrame.Angles(0, math.pi, 0)
			rootPart.CFrame = newCFrame + Vector3.new(0, hipHeight or 4, 0)
		end)
	end

	if ACTIONS.Trip.Enabled and input.KeyCode == ACTIONS.Trip.Key then
		if humanoid and HRP then
			humanoid:ChangeState(0)
			HRP.Velocity = HRP.CFrame.LookVector * 30
		end
	end

	if ACTIONS.Glitch.Enabled and input.KeyCode == ACTIONS.Glitch.Key then
		local glitching = not (ACTIONS.Glitch._glitching or false)
		ACTIONS.Glitch._glitching = glitching
		if glitching and HRP then
			task.spawn(function()
				local cf1 = CFrame.new(15, 0, 0)
				local cf2 = CFrame.new(-30, 0, 0)
				local cf3 = CFrame.new(15, 0, 0)
				while ACTIONS.Glitch._glitching and HRP do
					HRP.CFrame = HRP.CFrame * cf1 task.wait()
					HRP.CFrame = HRP.CFrame * cf2 task.wait()
					HRP.CFrame = HRP.CFrame * cf3 task.wait()
				end
			end)
		end
	end

	-- Facebang: only fires when enabled, does NOT auto-trigger on toggle
	if ACTIONS.Facebang.Enabled and input.KeyCode == ACTIONS.Facebang.Key then
		startFacebang()
	end

	if ACTIONS.Refresh.Enabled and input.KeyCode == ACTIONS.Refresh.Key then
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local refreshEvent = ReplicatedStorage:FindFirstChild("event_modify_refresh")
		if refreshEvent then
			refreshEvent:FireServer(Players.LocalPlayer)
		end
	end

	if ACTIONS.Invisible.Enabled and input.KeyCode == ACTIONS.Invisible.Key then
		toggleInvis()
	end

	if ACTIONS.Sfly.Enabled and input.KeyCode == ACTIONS.Sfly.Key then
		if sflyActive then stopSfly() else startSfly() end
	end

	-- Menu Toggle keybind
	if ACTIONS.MenuToggle.Enabled and input.KeyCode == ACTIONS.MenuToggle.Key then
		local main_ = win._main
		if main_ then
			local isVisible = main_.Visible
			if isVisible then
				tw(main_, 0.25, {Size = UDim2.new(0, main_.AbsoluteSize.X, 0, 0)})
				task.delay(0.26, function() main_.Visible = false main_.Size = win._originalSize end)
			else
				main_.Size    = UDim2.new(0, main_.AbsoluteSize.X, 0, 0)
				main_.Visible = true
				tw(main_, 0.3, {Size = win._originalSize})
			end
		end
	end
end)

-- Rewind
local rewindBuffer = {}
local MAX_FRAMES   = 300
RS.Heartbeat:Connect(function()
	if not ACTIONS.Rewind.Enabled then return end
	if not HRP or not humanoid then return end
	if UIS:IsKeyDown(ACTIONS.Rewind.Key) then
		local frame = table.remove(rewindBuffer)
		if frame then
			HRP.CFrame = frame[1]
			humanoid:ChangeState(frame[3])
		end
	else
		if #rewindBuffer >= MAX_FRAMES then table.remove(rewindBuffer, 1) end
		table.insert(rewindBuffer, {HRP.CFrame, HRP.Velocity, humanoid:GetState()})
	end
end)

-- ================ MAIN TAB ================
local main    = win:Tab("Main")
local section = main:Section("")

section:Toggle("Teleport", false, function(v)
	ACTIONS.Teleport.Enabled = v
end)

section:Toggle("Trip", false, function(v)
	ACTIONS.Trip.Enabled = v
end)

section:Toggle("Rewind", false, function(v)
	ACTIONS.Rewind.Enabled = v
end)

-- FIXED: toggle only arms/disarms, never auto-triggers startFacebang
section:Toggle("Face Bang", false, function(v)
	ACTIONS.Facebang.Enabled = v
	if not v then
		facebangActive = false
		local char = Players.LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.PlatformStand = false end
		end
	end
end)

section:Slider("Facebang Speed", 1, 2, 1, function(v)
	facebangSpeed = v * 0.1
end)

do
	local _gap = Instance.new("Frame")
	_gap.Size = UDim2.new(1, 0, 0, 16)
	_gap.BackgroundTransparency = 1
	_gap.BorderSizePixel = 0
	_gap.Parent = section._sf
end

section:Toggle("Glitch", false, function(v)
	ACTIONS.Glitch.Enabled = v
end)

section:Toggle("Refresh", false, function(v)
	ACTIONS.Refresh.Enabled = v
end)

section:Toggle("Invisible", false, function(v)
	ACTIONS.Invisible.Enabled = v
	if not v and invisActive then
		invisActive = false
		for _, part in ipairs(invisParts) do
			part.Transparency = 0
		end
	end
end)

do
	local _gap2 = Instance.new("Frame")
	_gap2.Size = UDim2.new(1, 0, 0, 16)
	_gap2.BackgroundTransparency = 1
	_gap2.BorderSizePixel = 0
	_gap2.Parent = section._sf
end

section:Toggle("Sfly", false, function(v)
	ACTIONS.Sfly.Enabled = v
	if not v and sflyActive then stopSfly() end
end)

section:Slider("Sfly Speed", 10, 400, 120, function(v)
	sflySpeed = v
end)

local walkSpeedSlider = section:Slider("Walk Speed", 16, 300, 16, function(v)
	local char = Players.LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end
end)

-- Re-apply walk speed on respawn
Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = walkSpeedSlider:Get() end
end)

do
	local _gap3 = Instance.new("Frame")
	_gap3.Size = UDim2.new(1, 0, 0, 16)
	_gap3.BackgroundTransparency = 1
	_gap3.BorderSizePixel = 0
	_gap3.Parent = section._sf
end

-- ================ KEYBIND SAVE/LOAD ================
local KEYBIND_SAVE_FILE = "IceLib_Keybinds.json"
local HttpService2 = game:GetService("HttpService")

-- Default keybind names (mirrors ACTIONS defaults above)
local defaultKeybindNames = {
	Teleport    = "F",
	Trip        = "T",
	Rewind      = "C",
	Facebang    = "Z",
	Glitch      = "X",
	Refresh     = "G",
	Invisible   = "V",
	Sfly        = "H",
	MenuToggle  = "K",
}

local savedKeybindNames = {}

-- Load saved keybinds
pcall(function()
	if isfile(KEYBIND_SAVE_FILE) then
		local decoded = HttpService2:JSONDecode(readfile(KEYBIND_SAVE_FILE))
		if type(decoded) == "table" then
			savedKeybindNames = decoded
		end
	end
end)

-- Apply loaded keybinds to ACTIONS
for action, keyName in pairs(savedKeybindNames) do
	local key = Enum.KeyCode[keyName]
	if key and ACTIONS[action] then
		ACTIONS[action].Key = key
	end
end

if next(savedKeybindNames) then
	task.spawn(function()
		task.wait(1.5)
		win:Notify("Keybinds", "Saved keybinds restored", 3)
	end)
end

local function saveKeybinds()
	local toSave = {}
	for action, data in pairs(ACTIONS) do
		toSave[action] = data.Key.Name
	end
	pcall(function()
		writefile(KEYBIND_SAVE_FILE, HttpService2:JSONEncode(toSave))
	end)
end

-- ================ KEYBINDS (inline in Main) ================
local keybindsInlineSec = main:Section("Keybinds")
keybindsInlineSec:Label("Menu Toggle default: K")

local selectedAction = "Teleport"
local allKeys = {
	"A","B","C","D","E","F","G","H","I","J","K","L","M",
	"N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
	"Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine",
	"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
	"Return","Tab","Space","Escape","Delete","Backspace",
	"LeftShift","RightShift","LeftControl","RightControl","LeftAlt","RightAlt",
	"Up","Down","Left","Right","Home","End","PageUp","PageDown",
	"Insert","Minus","Equals","LeftBracket","RightBracket","Backslash",
	"Semicolon","Quote","Comma","Period","Slash"
}

keybindsInlineSec:Dropdown("Select Action", {"Teleport","Trip","Rewind","Facebang","Glitch","Refresh","Invisible","Sfly","MenuToggle"}, function(v)
	local map = {
		["Teleport"]    = "Teleport",
		["Trip"]        = "Trip",
		["Rewind"]      = "Rewind",
		["Facebang"]    = "Facebang",
		["Glitch"]      = "Glitch",
		["Refresh"]     = "Refresh",
		["Invisible"]   = "Invisible",
		["Sfly"]        = "Sfly",
		["MenuToggle"]  = "MenuToggle",
	}
	selectedAction = map[v] or "Teleport"
end)

keybindsInlineSec:Dropdown("Key", allKeys, function(v)
	local key = Enum.KeyCode[v]
	if key and selectedAction then
		ACTIONS[selectedAction].Key = key
		saveKeybinds()
		win:Notify("Keybind Changed", selectedAction .. " → " .. v, 3)
	end
end)

-- ================ EXPLOITS TAB ================
local exploitsTab = win:Tab("Exploits")
local exploitsSec = exploitsTab:Section("")

-- Anti Kidnap logic
local antiKidnapEnabled   = false
local antiKidnapHeartbeat = nil

local function startAntiKidnap()
	local character = Players.LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	if antiKidnapHeartbeat then antiKidnapHeartbeat:Disconnect() end
	antiKidnapHeartbeat = RS.Heartbeat:Connect(function()
		if humanoid.Sit then humanoid.Sit = false end
		if humanoid:GetState() == Enum.HumanoidStateType.Seated then
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local sw = rootPart:FindFirstChild("SeatWeld")
			if sw then sw:Destroy() end
		end
	end)
end

local function stopAntiKidnap()
	local character = Players.LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		end
	end
	if antiKidnapHeartbeat then
		antiKidnapHeartbeat:Disconnect()
		antiKidnapHeartbeat = nil
	end
end

Players.LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	if antiKidnapEnabled then startAntiKidnap() end
end)

exploitsSec:Toggle("Anti Kidnap", false, function(v)
	antiKidnapEnabled = v
	if v then startAntiKidnap() else stopAntiKidnap() end
end)

-- Anti Bang logic
local antiBangEnabled   = false
local antiBangHeartbeat = nil
local bangSavedPos      = nil
local bangTeleportTime  = 0.1

local function resetCamSubject()
	if workspace.CurrentCamera and Players.LocalPlayer.Character then
		local hum = Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then workspace.CurrentCamera.CameraSubject = hum end
	end
end

local function startAntiBang()
	local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	bangSavedPos = hrp.Position

	local gazepart = Instance.new("Part")
	gazepart.Size         = Vector3.new(4, 1, 4)
	gazepart.Position     = bangSavedPos
	gazepart.Anchored     = true
	gazepart.CanCollide   = false
	gazepart.Transparency = 0.5
	gazepart.Name         = "AntiBangGaze"
	gazepart.Parent       = workspace
	workspace.CurrentCamera.CameraSubject = gazepart

	workspace.FallenPartsDestroyHeight = -1000
	local tweenInfo = TweenInfo.new(bangTeleportTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	TS:Create(hrp, tweenInfo, {CFrame = CFrame.new(Vector3.new(905, -500, 0))}):Play()

	if antiBangHeartbeat then antiBangHeartbeat:Disconnect() end
	antiBangHeartbeat = RS.Heartbeat:Connect(function()
		if antiBangEnabled then
			hrp.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

local function stopAntiBang()
	if antiBangHeartbeat then
		antiBangHeartbeat:Disconnect()
		antiBangHeartbeat = nil
	end
	local character = Players.LocalPlayer.Character
	if character and bangSavedPos then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local tweenInfo = TweenInfo.new(bangTeleportTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			TS:Create(hrp, tweenInfo, {CFrame = CFrame.new(bangSavedPos)}):Play()
		end
	end
	workspace.FallenPartsDestroyHeight = -500
	local gaze = workspace:FindFirstChild("AntiBangGaze")
	if gaze then gaze:Destroy() end
	resetCamSubject()
end

exploitsSec:Toggle("Anti Bang", false, function(v)
	antiBangEnabled = v
	if v then startAntiBang() else stopAntiBang() end
end)

local exploitList = {
	{ name = "Yeild",    subtitle = "Exploit script",  url = "https://raw.githubusercontent.com/Reelicss/STOPSKID/refs/heads/main/Yeild",  method = "HttpGet" },
	{ name = "AK Admin", subtitle = "Admin commands",  url = "https://absent.wtf/AKADMIN.lua",                                             method = "HttpGet" },
}

local function makeExploitCard(data, isLast)
	local mob  = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local card = Instance.new("Frame")
	card.Size             = UDim2.new(1, 0, 0, mob and 58 or 50)
	card.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	card.BorderSizePixel  = 0
	card.ClipsDescendants = false
	card.Parent           = exploitsSec._sf
	mkC(card, 6)

	if not isLast then
		local divOuter = Instance.new("Frame")
		divOuter.Size                   = UDim2.new(1, -20, 0, 12)
		divOuter.Position               = UDim2.new(0, 10, 1, -6)
		divOuter.BackgroundTransparency = 1
		divOuter.BorderSizePixel        = 0
		divOuter.ZIndex                 = 2
		divOuter.ClipsDescendants       = true
		divOuter.Parent                 = card
		local divLine = Instance.new("Frame")
		divLine.Size             = UDim2.new(1, 0, 0, 12)
		divLine.Position         = UDim2.new(0, 0, 0, 0)
		divLine.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		divLine.BorderSizePixel  = 0
		divLine.ZIndex           = 2
		divLine.Parent           = divOuter
		mkC(divLine, 6)
	end

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Text               = data.name
	nameLbl.Size               = UDim2.new(1, -24, 1, 0)
	nameLbl.Position           = UDim2.new(0, mob and 16 or 14, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.TextColor3         = Color3.fromRGB(210, 210, 210)
	nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
	nameLbl.Font               = Enum.Font.GothamMedium
	nameLbl.TextSize           = mob and 14 or 13
	nameLbl.ZIndex             = 2
	nameLbl.Parent             = card

	local click = Instance.new("TextButton")
	click.Size                   = UDim2.new(1, 0, 1, 0)
	click.BackgroundTransparency = 1
	click.Text                   = ""
	click.ZIndex                 = 4
	click.Parent                 = card

	click.MouseEnter:Connect(function()
		tw(card,    0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
		tw(nameLbl, 0.2, {TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	click.MouseLeave:Connect(function()
		tw(card,    0.2, {BackgroundColor3 = Color3.fromRGB(12, 12, 12)})
		tw(nameLbl, 0.2, {TextColor3 = Color3.fromRGB(210, 210, 210)})
	end)
	click.MouseButton1Down:Connect(function()
		tw(card,    0.08, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
		tw(nameLbl, 0.08, {TextColor3 = Color3.fromRGB(150, 150, 150)})
	end)
	click.MouseButton1Click:Connect(function()
		tw(card, 0.2, {BackgroundColor3 = Color3.fromRGB(12, 12, 12)})
		task.spawn(function()
			loadstring(game:HttpGet(data.url))()
		end)
	end)
end

for i, data in ipairs(exploitList) do
	makeExploitCard(data, i == #exploitList)
end

-- ================ REMOVE ZOOM LIMIT ================
local cam = workspace.CurrentCamera
local function removeZoomLimit()
	local lp = Players.LocalPlayer
	pcall(function()
		lp.CameraMaxZoomDistance = 1000
		lp.CameraMinZoomDistance = 0
	end)
end
removeZoomLimit()
Players.LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	removeZoomLimit()
end)

-- ================ GUIS TAB ================
local guisTab = win:Tab("GUIs")
local guisSec = guisTab:Section("")

local guiList = {
	{ name = "GUI  I",   url = "https://raw.githubusercontent.com/Reelicss/STOPLS/refs/heads/main/GUI%201", method = "HttpGet" },
	{ name = "GUI  II",  url = "https://raw.githubusercontent.com/Reelicss/STOPLS/refs/heads/main/GUI%202", method = "HttpGetAsync" },
	{ name = "GUI  III", url = "https://raw.githubusercontent.com/Reelicss/STOPLS/refs/heads/main/GUI%203", method = "HttpGetAsync" },
	{ name = "GUI  IV",  url = "https://raw.githubusercontent.com/Reelicss/STOPLS/refs/heads/main/GUI%204", method = "HttpGet" },
}

local function mkC2(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
	return c
end

local function makeGuiCard(data, isLast)
	local mob  = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local card = Instance.new("Frame")
	card.Size             = UDim2.new(1, 0, 0, mob and 58 or 50)
	card.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	card.BorderSizePixel  = 0
	card.ClipsDescendants = false
	card.Parent           = guisSec._sf
	mkC2(card, 6)

	if not isLast then
		local divOuter = Instance.new("Frame")
		divOuter.Size                   = UDim2.new(1, -20, 0, 12)
		divOuter.Position               = UDim2.new(0, 10, 1, -6)
		divOuter.BackgroundTransparency = 1
		divOuter.BorderSizePixel        = 0
		divOuter.ZIndex                 = 2
		divOuter.ClipsDescendants       = true
		divOuter.Parent                 = card
		local divLine = Instance.new("Frame")
		divLine.Size             = UDim2.new(1, 0, 0, 12)
		divLine.Position         = UDim2.new(0, 0, 0, 0)
		divLine.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		divLine.BorderSizePixel  = 0
		divLine.ZIndex           = 2
		divLine.Parent           = divOuter
		mkC2(divLine, 6)
	end

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Text               = data.name
	nameLbl.Size               = UDim2.new(1, -24, 1, 0)
	nameLbl.Position           = UDim2.new(0, mob and 16 or 14, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.TextColor3         = Color3.fromRGB(210, 210, 210)
	nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
	nameLbl.Font               = Enum.Font.GothamMedium
	nameLbl.TextSize           = mob and 14 or 13
	nameLbl.ZIndex             = 2
	nameLbl.Parent             = card

	local click = Instance.new("TextButton")
	click.Size                   = UDim2.new(1, 0, 1, 0)
	click.BackgroundTransparency = 1
	click.Text                   = ""
	click.ZIndex                 = 4
	click.Parent                 = card

	click.MouseEnter:Connect(function()
		tw(card,    0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
		tw(nameLbl, 0.2, {TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	click.MouseLeave:Connect(function()
		tw(card,    0.2, {BackgroundColor3 = Color3.fromRGB(12, 12, 12)})
		tw(nameLbl, 0.2, {TextColor3 = Color3.fromRGB(210, 210, 210)})
	end)
	click.MouseButton1Down:Connect(function()
		tw(card,    0.08, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
		tw(nameLbl, 0.08, {TextColor3 = Color3.fromRGB(150, 150, 150)})
	end)
	click.MouseButton1Click:Connect(function()
		tw(card, 0.2, {BackgroundColor3 = Color3.fromRGB(12, 12, 12)})
		task.spawn(function()
			if data.method == "HttpGetAsync" then
				loadstring(game:HttpGetAsync(data.url))()
			else
				loadstring(game:HttpGet(data.url))()
			end
		end)
	end)
end

for i, data in ipairs(guiList) do
	makeGuiCard(data, i == #guiList)
end

-- ================ BASEPLATE TAB ================
local baseplateTab = win:Tab("BasePlate")
local baseplateSec = baseplateTab:Section("")

local function makeBaseplateRow(title, subtitle, url)
	local mob = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local row = Instance.new("Frame")
	row.Size                   = UDim2.new(1, 0, 0, mob and 80 or 68)
	row.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
	row.BackgroundTransparency = 0.4
	row.BorderSizePixel        = 0
	row.ClipsDescendants       = true
	row.Parent                 = baseplateSec._sf
	mkC(row, 8)
	mkS(row, Color3.fromRGB(35, 35, 35), 1)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Text               = title
	titleLbl.Size               = UDim2.new(1, -24, 0, mob and 28 or 24)
	titleLbl.Position           = UDim2.new(0, 14, 0, mob and 12 or 10)
	titleLbl.BackgroundTransparency = 1
	titleLbl.TextColor3         = win._t.text
	titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
	titleLbl.Font               = Enum.Font.GothamMedium
	titleLbl.TextSize           = mob and 14 or 13
	titleLbl.Parent             = row

	local subLbl = Instance.new("TextLabel")
	subLbl.Text               = subtitle
	subLbl.Size               = UDim2.new(1, -24, 0, mob and 20 or 18)
	subLbl.Position           = UDim2.new(0, 14, 0, mob and 42 or 36)
	subLbl.BackgroundTransparency = 1
	subLbl.TextColor3         = win._t.sub
	subLbl.TextXAlignment     = Enum.TextXAlignment.Left
	subLbl.Font               = Enum.Font.Gotham
	subLbl.TextSize           = mob and 13 or 12
	subLbl.Parent             = row

	local click = Instance.new("TextButton")
	click.Size                   = UDim2.new(1, 0, 1, 0)
	click.BackgroundTransparency = 1
	click.Text                   = ""
	click.ZIndex                 = 3
	click.Parent                 = row

	click.MouseEnter:Connect(function()
		tw(row, 0.15, {BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0})
		tw(titleLbl, 0.15, {TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	click.MouseLeave:Connect(function()
		tw(row, 0.15, {BackgroundColor3 = Color3.fromRGB(18, 18, 18), BackgroundTransparency = 0.4})
		tw(titleLbl, 0.15, {TextColor3 = win._t.text})
	end)
	click.MouseButton1Down:Connect(function()
		tw(row, 0.08, {BackgroundColor3 = Color3.fromRGB(45, 45, 45), BackgroundTransparency = 0})
	end)
	click.MouseButton1Click:Connect(function()
		tw(row, 0.15, {BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0})
		task.spawn(function()
			loadstring(game:HttpGet(url))()
		end)
	end)
end

baseplateSec:Label(" ")
makeBaseplateRow("Opaque",      "Solid baseplate",             "https://raw.githubusercontent.com/Reelicss/STOPPLEEJ/refs/heads/main/1")
baseplateSec:Label(" ")
makeBaseplateRow("Transparent", "Invisible baseplate",         "https://raw.githubusercontent.com/Reelicss/STOPPLEEJ/refs/heads/main/2")
baseplateSec:Label(" ")
makeBaseplateRow("Sand",        "Sandy baseplate texture",     "https://raw.githubusercontent.com/Reelicss/STOPPLEEJ/refs/heads/main/3")
baseplateSec:Label(" ")
makeBaseplateRow("Reset",       "Reset baseplate to default",  "https://raw.githubusercontent.com/Reelicss/STOPPLEEJ/refs/heads/main/4")
baseplateSec:Label(" ")

-- ================ SHADE TAB ================
local shadeTab = win:Tab("Shade")
local shadeSec = shadeTab:Section("")

local function makeShadeRow(title, subtitle, url)
	local mob = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local row = Instance.new("Frame")
	row.Size                   = UDim2.new(1, 0, 0, mob and 80 or 68)
	row.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
	row.BackgroundTransparency = 0.4
	row.BorderSizePixel        = 0
	row.ClipsDescendants       = true
	row.Parent                 = shadeSec._sf
	mkC(row, 8)
	mkS(row, Color3.fromRGB(35, 35, 35), 1)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Text               = title
	titleLbl.Size               = UDim2.new(1, -24, 0, mob and 28 or 24)
	titleLbl.Position           = UDim2.new(0, 14, 0, mob and 12 or 10)
	titleLbl.BackgroundTransparency = 1
	titleLbl.TextColor3         = win._t.text
	titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
	titleLbl.Font               = Enum.Font.GothamMedium
	titleLbl.TextSize           = mob and 14 or 13
	titleLbl.Parent             = row

	local subLbl = Instance.new("TextLabel")
	subLbl.Text               = subtitle
	subLbl.Size               = UDim2.new(1, -24, 0, mob and 20 or 18)
	subLbl.Position           = UDim2.new(0, 14, 0, mob and 42 or 36)
	subLbl.BackgroundTransparency = 1
	subLbl.TextColor3         = win._t.sub
	subLbl.TextXAlignment     = Enum.TextXAlignment.Left
	subLbl.Font               = Enum.Font.Gotham
	subLbl.TextSize           = mob and 13 or 12
	subLbl.Parent             = row

	local click = Instance.new("TextButton")
	click.Size                   = UDim2.new(1, 0, 1, 0)
	click.BackgroundTransparency = 1
	click.Text                   = ""
	click.ZIndex                 = 3
	click.Parent                 = row

	click.MouseEnter:Connect(function()
		tw(row, 0.15, {BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0})
		tw(titleLbl, 0.15, {TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	click.MouseLeave:Connect(function()
		tw(row, 0.15, {BackgroundColor3 = Color3.fromRGB(18, 18, 18), BackgroundTransparency = 0.4})
		tw(titleLbl, 0.15, {TextColor3 = win._t.text})
	end)
	click.MouseButton1Down:Connect(function()
		tw(row, 0.08, {BackgroundColor3 = Color3.fromRGB(45, 45, 45), BackgroundTransparency = 0})
	end)
	click.MouseButton1Click:Connect(function()
		tw(row, 0.15, {BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0})
		task.spawn(function()
			loadstring(game:HttpGet(url))()
		end)
	end)
end

shadeSec:Label(" ")
makeShadeRow("Black", "Bravo 6 going dark",                        "https://raw.githubusercontent.com/Reelicss/PLSVRO/refs/heads/main/1")
shadeSec:Label(" ")
makeShadeRow("Pink",  "Gwen Stacy's Theme",                        "https://raw.githubusercontent.com/Reelicss/PLSVRO/refs/heads/main/2")
shadeSec:Label(" ")
makeShadeRow("Space", "Entering different dimensions",             "https://raw.githubusercontent.com/Reelicss/PLSVRO/refs/heads/main/3")
shadeSec:Label(" ")
makeShadeRow("Reset", "Need to reset everytime you use the shader","https://raw.githubusercontent.com/Reelicss/PLSVRO/refs/heads/main/4")
shadeSec:Label(" ")

-- ================ ANIM TAB ================
local animTab = win:Tab("Anim")

-- ---- Animation data (complete from animations.txt) ----
local AnimDB = {
	["Idle"] = {
		["2016 Animation (mm2)"]          = {"387947158","387947464"},
		["(UGC) Oh Really?"]              = {"98004748982532","98004748982532"},
		["Astronaut"]                     = {"891621366","891633237"},
		["Adidas Community"]              = {"122257458498464","102357151005774"},
		["Bold"]                          = {"16738333868","16738334710"},
		["(UGC) Slasher"]                 = {"140051337061095","140051337061095"},
		["(UGC) Retro"]                   = {"80479383912838","80479383912838"},
		["(UGC) Magician"]                = {"139433213852503","139433213852503"},
		["(UGC) John Doe"]                = {"72526127498800","72526127498800"},
		["(UGC) Noli"]                    = {"139360856809483","139360856809483"},
		["(UGC) Coolkid"]                 = {"95203125292023","95203125292023"},
		["(UGC) Survivor Injured"]        = {"73905365652295","73905365652295"},
		["(UGC) Retro Zombie"]            = {"90806086002292","90806086002292"},
		["(UGC) 1x1x1x1"]                = {"76780522821306","76780522821306"},
		["Borock"]                        = {"3293641938","3293642554"},
		["Bubbly"]                        = {"910004836","910009958"},
		["Cartoony"]                      = {"742637544","742638445"},
		["Confident"]                     = {"1069977950","1069987858"},
		["Catwalk Glam"]                  = {"133806214992291","94970088341563"},
		["Cowboy"]                        = {"1014390418","1014398616"},
		["Drooling Zombie"]               = {"3489171152","3489171152"},
		["Elder"]                         = {"10921101664","10921102574"},
		["Ghost"]                         = {"616006778","616008087"},
		["Knight"]                        = {"657595757","657568135"},
		["Levitation"]                    = {"616006778","616008087"},
		["Mage"]                          = {"707742142","707855907"},
		["MrToilet"]                      = {"4417977954","4417978624"},
		["Ninja"]                         = {"656117400","656118341"},
		["NFL"]                           = {"92080889861410","74451233229259"},
		["OldSchool"]                     = {"10921230744","10921232093"},
		["Patrol"]                        = {"1149612882","1150842221"},
		["Pirate"]                        = {"750781874","750782770"},
		["Default Retarget"]              = {"95884606664820","95884606664820"},
		["Very Long"]                     = {"18307781743","18307781743"},
		["Sway"]                          = {"560832030","560833564"},
		["Popstar"]                       = {"1212900985","1150842221"},
		["Princess"]                      = {"941003647","941013098"},
		["R6"]                            = {"12521158637","12521162526"},
		["R15 Reanimated"]                = {"4211217646","4211218409"},
		["Realistic"]                     = {"17172918855","17173014241"},
		["Robot"]                         = {"616088211","616089559"},
		["Sneaky"]                        = {"1132473842","1132477671"},
		["Sports (Adidas)"]               = {"18537376492","18537371272"},
		["Soldier"]                       = {"3972151362","3972151362"},
		["Stylish"]                       = {"616136790","616138447"},
		["Stylized Female"]               = {"4708191566","4708192150"},
		["Superhero"]                     = {"10921288909","10921290167"},
		["Toy"]                           = {"782841498","782845736"},
		["Udzal"]                         = {"3303162274","3303162549"},
		["Vampire"]                       = {"1083445855","1083450166"},
		["Werewolf"]                      = {"1083195517","1083214717"},
		["Wicked (Popular)"]              = {"118832222982049","76049494037641"},
		["No Boundaries (Walmart)"]       = {"18747067405","18747063918"},
		["Zombie"]                        = {"616158929","616160636"},
		["(UGC) Zombie"]                  = {"77672872857991","77672872857991"},
		["(UGC) TailWag"]                 = {"129026910898635","129026910898635"},
		["[VOTE] warming up"]             = {"83573330053643","83573330053643"},
		["cesus"]                         = {"115879733952840","115879733952840"},
		["[VOTE] Float"]                  = {"110375749767299","110375749767299"},
		["UGC Oneleft"]                   = {"121217497452435","121217497452435"},
		["AuraFarming"]                   = {"138665010911335","138665010911335"},
		["[VOTE] Mech Float"]             = {"74447366032908","74447366032908"},
		["Badware"]                       = {"140131631438778","140131631438778"},
		["Wicked Dancing Through Life"]   = {"92849173543269","132238900951109"},
		["Unboxed By Amazon"]             = {"98281136301627","138183121662404"},
	},
	["Walk"] = {
		["Geto"]                          = "85811471336028",
		["Patrol"]                        = "1151231493",
		["Drooling Zombie"]               = "3489174223",
		["Adidas Community"]              = "122150855457006",
		["Levitation"]                    = "616013216",
		["Catwalk Glam"]                  = "109168724482748",
		["Knight"]                        = "10921127095",
		["Pirate"]                        = "750785693",
		["Bold"]                          = "16738340646",
		["Sports (Adidas)"]               = "18537392113",
		["Zombie"]                        = "616168032",
		["Astronaut"]                     = "891667138",
		["Cartoony"]                      = "742640026",
		["Ninja"]                         = "656121766",
		["Confident"]                     = "1070017263",
		["Wicked Dancing Through Life"]   = "73718308412641",
		["Unboxed By Amazon"]             = "90478085024465",
		["Gojo"]                          = "95643163365384",
		["R15 Reanimated"]                = "4211223236",
		["Ghost"]                         = "616013216",
		["2016 Animation (mm2)"]          = "387947975",
		["(UGC) Zombie"]                  = "113603435314095",
		["No Boundaries (Walmart)"]       = "18747074203",
		["Rthro"]                         = "10921269718",
		["Werewolf"]                      = "1083178339",
		["Wicked (Popular)"]              = "92072849924640",
		["Vampire"]                       = "1083473930",
		["Popstar"]                       = "1212980338",
		["Mage"]                          = "707897309",
		["(UGC) Smooth"]                  = "76630051272791",
		["R6"]                            = "12518152696",
		["NFL"]                           = "110358958299415",
		["Bubbly"]                        = "910034870",
		["(UGC) Retro"]                   = "107806791584829",
		["(UGC) Retro Zombie"]            = "140703855480494",
		["OldSchool"]                     = "10921244891",
		["Elder"]                         = "10921111375",
		["Stylish"]                       = "616146177",
		["Stylized Female"]               = "4708193840",
		["Robot"]                         = "616095330",
		["Sneaky"]                        = "1132510133",
		["Superhero"]                     = "10921298616",
		["Udzal"]                         = "3303162967",
		["Toy"]                           = "782843345",
		["Default Retarget"]              = "115825677624788",
		["Princess"]                      = "941028902",
		["Cowboy"]                        = "1014421541",
	},
	["Run"] = {
		["Robot"]                         = "10921250460",
		["Patrol"]                        = "1150967949",
		["Drooling Zombie"]               = "3489173414",
		["Adidas Community"]              = "82598234841035",
		["Heavy Run (Udzal/Borock)"]      = "3236836670",
		["Catwalk Glam"]                  = "81024476153754",
		["Knight"]                        = "10921121197",
		["Pirate"]                        = "750783738",
		["Bold"]                          = "16738337225",
		["Sports (Adidas)"]               = "18537384940",
		["Zombie"]                        = "616163682",
		["Astronaut"]                     = "10921039308",
		["Cartoony"]                      = "10921076136",
		["Ninja"]                         = "656118852",
		["(UGC) Dog"]                     = "130072963359721",
		["Wicked Dancing Through Life"]   = "135515454877967",
		["Unboxed By Amazon"]             = "134824450619865",
		["[UGC] Flipping"]                = "124427738251511",
		["Sneaky"]                        = "1132494274",
		["R6"]                            = "12518152696",
		["[VOTE] Aura"]                   = "120142877225965",
		["Popstar"]                       = "1212980348",
		["[UGC] reset"]                   = "0",
		["Wicked (Popular)"]              = "72301599441680",
		["[UGC] chibi"]                   = "85887415033585",
		["R15 Reanimated"]                = "4211220381",
		["Mage"]                          = "10921148209",
		["Ghost"]                         = "616013216",
		["Rthro"]                         = "10921261968",
		["Confident"]                     = "1070001516",
		["Stylized Female"]               = "4708192705",
		["No Boundaries (Walmart)"]       = "18747070484",
		["Elder"]                         = "10921104374",
		["Werewolf"]                      = "10921336997",
		["[UGC] Girly"]                   = "128578785610052",
		["Stylish"]                       = "10921276116",
		["(UGC) Pride"]                   = "116462200642360",
		["NFL"]                           = "117333533048078",
		["(UGC) Soccer"]                  = "116881956670910",
		["MrToilet"]                      = "4417979645",
		["[VOTE] Float"]                  = "71267457613791",
		["Levitation"]                    = "616010382",
		["(UGC) Retro"]                   = "107806791584829",
		["(UGC) Retro Zombie"]            = "140703855480494",
		["OldSchool"]                     = "10921240218",
		["Vampire"]                       = "10921320299",
		["furry"]                         = "102269417125238",
		["Bubbly"]                        = "10921057244",
		["fake wicked"]                   = "138992096476836",
		["2016 Animation (mm2)"]          = "387947975",
		["[UGC] ball"]                    = "132499588684957",
		["Superhero"]                     = "10921291831",
		["Toy"]                           = "10921306285",
		["Default Retarget"]              = "102294264237491",
		["Princess"]                      = "941015281",
		["Cowboy"]                        = "1014401683",
	},
	["Jump"] = {
		["Robot"]                         = "616090535",
		["Patrol"]                        = "1148811837",
		["Adidas Community"]              = "75290611992385",
		["Levitation"]                    = "616008936",
		["Catwalk Glam"]                  = "116936326516985",
		["Knight"]                        = "910016857",
		["Pirate"]                        = "750782230",
		["Bold"]                          = "16738336650",
		["Sports (Adidas)"]               = "18537380791",
		["Zombie"]                        = "616161997",
		["Astronaut"]                     = "891627522",
		["Cartoony"]                      = "742637942",
		["Ninja"]                         = "656117878",
		["Confident"]                     = "1069984524",
		["Wicked Dancing Through Life"]   = "78508480717326",
		["Unboxed By Amazon"]             = "121454505477205",
		["R6"]                            = "12520880485",
		["R15 Reanimated"]                = "4211219390",
		["Ghost"]                         = "616008936",
		["Rthro"]                         = "10921263860",
		["No Boundaries (Walmart)"]       = "18747069148",
		["Werewolf"]                      = "1083218792",
		["Cowboy"]                        = "1014394726",
		["UGC"]                           = "91788124131212",
		["[VOTE] Animal"]                 = "131203832825082",
		["Popstar"]                       = "1212954642",
		["Mage"]                          = "10921149743",
		["Sneaky"]                        = "1132489853",
		["Superhero"]                     = "10921294559",
		["Elder"]                         = "10921107367",
		["(UGC) Retro"]                   = "139390570947836",
		["NFL"]                           = "119846112151352",
		["OldSchool"]                     = "10921242013",
		["Stylized Female"]               = "4708188025",
		["Stylish"]                       = "616139451",
		["Bubbly"]                        = "910016857",
		["[VOTE] Float"]                  = "75611679208549",
		["[VOTE] Aura"]                   = "93382302369459",
		["Vampire"]                       = "1083455352",
		["Wicked (Popular)"]              = "104325245285198",
		["Toy"]                           = "10921308158",
		["Default Retarget"]              = "117150377950987",
		["Princess"]                      = "941008832",
		["[UGC] happy"]                   = "72388373557525",
	},
	["Fall"] = {
		["Robot"]                         = "616087089",
		["Patrol"]                        = "1148863382",
		["Adidas Community"]              = "98600215928904",
		["Levitation"]                    = "616005863",
		["Catwalk Glam"]                  = "92294537340807",
		["Knight"]                        = "10921122579",
		["Pirate"]                        = "750780242",
		["Bold"]                          = "16738333171",
		["Sports (Adidas)"]               = "18537367238",
		["Zombie"]                        = "616157476",
		["Astronaut"]                     = "891617961",
		["Cartoony"]                      = "742637151",
		["Ninja"]                         = "656115606",
		["Confident"]                     = "1069973677",
		["Wicked Dancing Through Life"]   = "78147885297412",
		["Unboxed By Amazon"]             = "94788218468396",
		["R6"]                            = "12520972571",
		["[UGC] skydiving"]               = "102674302534126",
		["R15 Reanimated"]                = "4211216152",
		["Rthro"]                         = "10921262864",
		["No Boundaries (Walmart)"]       = "18747062535",
		["Werewolf"]                      = "1083189019",
		["[VOTE] TPose"]                  = "139027266704971",
		["Mage"]                          = "707829716",
		["[VOTE] Animal"]                 = "77069224396280",
		["Wicked (Popular)"]              = "121152442762481",
		["Popstar"]                       = "1212900995",
		["NFL"]                           = "129773241321032",
		["OldSchool"]                     = "10921241244",
		["Sneaky"]                        = "1132469004",
		["Elder"]                         = "10921105765",
		["Bubbly"]                        = "910001910",
		["Stylish"]                       = "616134815",
		["Stylized Female"]               = "4708186162",
		["Vampire"]                       = "1083443587",
		["Superhero"]                     = "10921293373",
		["Toy"]                           = "782846423",
		["Default Retarget"]              = "110205622518029",
		["Princess"]                      = "941000007",
		["Cowboy"]                        = "1014384571",
	},
	["Climb"] = {
		["Robot"]                         = "616086039",
		["Patrol"]                        = "1148811837",
		["Adidas Community"]              = "88763136693023",
		["Levitation"]                    = "10921132092",
		["Catwalk Glam"]                  = "119377220967554",
		["Knight"]                        = "10921125160",
		["[VOTE] Animal"]                 = "124810859712282",
		["Bold"]                          = "16738332169",
		["Sports (Adidas)"]               = "18537363391",
		["Zombie"]                        = "616156119",
		["Astronaut"]                     = "10921032124",
		["Cartoony"]                      = "742636889",
		["Ninja"]                         = "656114359",
		["Confident"]                     = "1069946257",
		["Wicked Dancing Through Life"]   = "129447497744818",
		["Unboxed By Amazon"]             = "121145883950231",
		["R6"]                            = "12520982150",
		["Ghost"]                         = "616003713",
		["Rthro"]                         = "10921257536",
		["Cowboy"]                        = "1014380606",
		["No Boundaries (Walmart)"]       = "18747060903",
		["Mage"]                          = "707826056",
		["[VOTE] sticky"]                 = "77520617871799",
		["Reanimated R15"]                = "4211214992",
		["Popstar"]                       = "1213044953",
		["(UGC) Retro"]                   = "121075390792786",
		["NFL"]                           = "134630013742019",
		["OldSchool"]                     = "10921229866",
		["Sneaky"]                        = "1132461372",
		["Elder"]                         = "845392038",
		["Stylized Female"]               = "4708184253",
		["Stylish"]                       = "10921271391",
		["Superhero"]                     = "10921286911",
		["Werewolf"]                      = "10921329322",
		["Vampire"]                       = "1083439238",
		["Toy"]                           = "10921300839",
		["Wicked (Popular)"]              = "131326830509784",
		["Princess"]                      = "940996062",
		["[VOTE] Rope"]                   = "134977367563514",
	},
	["Swim"] = {
		["Sneaky"]                        = "1132500520",
		["Patrol"]                        = "1151204998",
		["Adidas Community"]              = "133308483266208",
		["Levitation"]                    = "10921138209",
		["Catwalk Glam"]                  = "134591743181628",
		["Knight"]                        = "10921125160",
		["Pirate"]                        = "750784579",
		["Bold"]                          = "16738339158",
		["Sports (Adidas)"]               = "18537389531",
		["Zombie"]                        = "616165109",
		["Astronaut"]                     = "891663592",
		["Cartoony"]                      = "10921079380",
		["Wicked (Popular)"]              = "99384245425157",
		["Mage"]                          = "707876443",
		["Popstar"]                       = "1212998578",
		["Unboxed By Amazon"]             = "105962919001086",
		["R6"]                            = "12518152696",
		["[VOTE] Boat"]                   = "85689117221382",
		["Rthro"]                         = "10921264784",
		["Cowboy"]                        = "1014406523",
		["No Boundaries (Walmart)"]       = "18747073181",
		["Werewolf"]                      = "10921340419",
		["NFL"]                           = "132697394189921",
		["OldSchool"]                     = "10921243048",
		["Wicked Dancing Through Life"]   = "110657013921774",
		["Elder"]                         = "10921108971",
		["Bubbly"]                        = "910028158",
		["Robot"]                         = "10921253142",
		["[VOTE] Aura"]                   = "80645586378736",
		["Vampire"]                       = "10921324408",
		["Stylish"]                       = "10921281000",
		["Toy"]                           = "10921309319",
		["Superhero"]                     = "10921295495",
		["Princess"]                      = "941018893",
		["Confident"]                     = "1070009914",
	},
	["SwimIdle"] = {
		["Sneaky"]                        = "1132506407",
		["Superhero"]                     = "10921297391",
		["Adidas Community"]              = "109346520324160",
		["Levitation"]                    = "10921139478",
		["Catwalk Glam"]                  = "98854111361360",
		["Knight"]                        = "10921125935",
		["Pirate"]                        = "750785176",
		["Bold"]                          = "16738339817",
		["Sports (Adidas)"]               = "18537387180",
		["Stylized Female"]               = "4708190607",
		["Astronaut"]                     = "891663592",
		["Cartoony"]                      = "10921079380",
		["Wicked (Popular)"]              = "113199415118199",
		["Mage"]                          = "707894699",
		["Wicked Dancing Through Life"]   = "129183123083281",
		["Unboxed By Amazon"]             = "129126268464847",
		["R6"]                            = "12518152696",
		["Rthro"]                         = "10921265698",
		["Cowboy"]                        = "1014411816",
		["No Boundaries (Walmart)"]       = "18747071682",
		["Werewolf"]                      = "10921341319",
		["NFL"]                           = "79090109939093",
		["OldSchool"]                     = "10921244018",
		["Robot"]                         = "10921253767",
		["Elder"]                         = "10921110146",
		["Bubbly"]                        = "910030921",
		["Patrol"]                        = "1151221899",
		["Vampire"]                       = "10921325443",
		["Popstar"]                       = "1212998578",
		["Ninja"]                         = "656118341",
		["Toy"]                           = "10921310341",
		["Confident"]                     = "1070012133",
		["Princess"]                      = "941025398",
		["Stylish"]                       = "10921281964",
	},
}

-- ---- Animation apply logic (from animations.txt) ----
local ANIM_SAVE_FILE = "IceLib_SavedAnims.json"
local HttpService    = game:GetService("HttpService")
local animLastApplied = {}

-- Load saved animations from file on script start
pcall(function()
	if isfile(ANIM_SAVE_FILE) then
		local decoded = HttpService:JSONDecode(readfile(ANIM_SAVE_FILE))
		if type(decoded) == "table" then animLastApplied = decoded end
	end
end)

local function animSave()
	pcall(function()
		writefile(ANIM_SAVE_FILE, HttpService:JSONEncode(animLastApplied))
	end)
end

local function animFreeze()
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = true end
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and not part.Anchored then part.Anchored = true end
		end
	end
end

local function animUnfreeze()
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Anchored then part.Anchored = false end
		end
	end
end

local function animRefresh()
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	hum:ChangeState(Enum.HumanoidStateType.Freefall)
end

local function animRefreshSwim()
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait(0.1)
	hum:ChangeState(Enum.HumanoidStateType.Swimming)
end

local function animRefreshClimb()
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait(0.1)
	hum:ChangeState(Enum.HumanoidStateType.Climbing)
end

local function setAnimation(animationType, animationId)
	if type(animationId) ~= "table" and type(animationId) ~= "string" then return end
	local player = Players.LocalPlayer
	if not player.Character then return end
	local Char = player.Character
	local Animate = Char:FindFirstChild("Animate")
	if not Animate then return end

	animFreeze()
	task.wait(0.1)

	local ok, err = pcall(function()
		local hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
		if hum then
			for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
		end
		if animationType == "Idle" then
			animLastApplied.Idle = animationId
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
			animRefresh()
		elseif animationType == "Walk" then
			animLastApplied.Walk = animationId
			Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
			animRefresh()
		elseif animationType == "Run" then
			animLastApplied.Run = animationId
			Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
			animRefresh()
		elseif animationType == "Jump" then
			animLastApplied.Jump = animationId
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
			animRefresh()
		elseif animationType == "Fall" then
			animLastApplied.Fall = animationId
			Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
			animRefresh()
		elseif animationType == "Swim" and Animate:FindFirstChild("swim") then
			animLastApplied.Swim = animationId
			Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
			animRefreshSwim()
		elseif animationType == "SwimIdle" and Animate:FindFirstChild("swimidle") then
			animLastApplied.SwimIdle = animationId
			Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
			animRefreshSwim()
		elseif animationType == "Climb" then
			animLastApplied.Climb = animationId
			Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
			animRefreshClimb()
		end
		animSave()
	end)
	if not ok then warn("Anim error:", err) end

	task.wait(0.1)
	animUnfreeze()
end

-- Re-apply animations on respawn
Players.LocalPlayer.CharacterAdded:Connect(function(character)
	local hum = character:WaitForChild("Humanoid")
	local animate = character:WaitForChild("Animate", 10)
	if not animate then return end
	task.wait(1)
	if animLastApplied.Idle     then setAnimation("Idle",     animLastApplied.Idle)     end
	if animLastApplied.Walk     then setAnimation("Walk",     animLastApplied.Walk)     end
	if animLastApplied.Run      then setAnimation("Run",      animLastApplied.Run)      end
	if animLastApplied.Jump     then setAnimation("Jump",     animLastApplied.Jump)     end
	if animLastApplied.Fall     then setAnimation("Fall",     animLastApplied.Fall)     end
	if animLastApplied.Swim     then setAnimation("Swim",     animLastApplied.Swim)     end
	if animLastApplied.SwimIdle then setAnimation("SwimIdle", animLastApplied.SwimIdle) end
	if animLastApplied.Climb    then setAnimation("Climb",    animLastApplied.Climb)    end
end)

-- Auto-apply any saved animations from previous sessions on startup
task.spawn(function()
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	char:WaitForChild("Animate", 10)
	task.wait(1)
	local any = false
	for _ in pairs(animLastApplied) do any = true break end
	if any then
		win:Notify("Animations", "Reloading saved animations", 2)
		if animLastApplied.Idle     then setAnimation("Idle",     animLastApplied.Idle)     end
		if animLastApplied.Walk     then setAnimation("Walk",     animLastApplied.Walk)     end
		if animLastApplied.Run      then setAnimation("Run",      animLastApplied.Run)      end
		if animLastApplied.Jump     then setAnimation("Jump",     animLastApplied.Jump)     end
		if animLastApplied.Fall     then setAnimation("Fall",     animLastApplied.Fall)     end
		if animLastApplied.Swim     then setAnimation("Swim",     animLastApplied.Swim)     end
		if animLastApplied.SwimIdle then setAnimation("SwimIdle", animLastApplied.SwimIdle) end
		if animLastApplied.Climb    then setAnimation("Climb",    animLastApplied.Climb)    end
	end
end)

-- ---- Build the UI sections with dropdowns ----
local animTypeOrder = {"Idle", "Walk", "Run", "Jump", "Fall", "Climb", "Swim", "SwimIdle"}

for _, animType in ipairs(animTypeOrder) do
	local sec = animTab:Section("")
	local names = {}
	for name in pairs(AnimDB[animType]) do
		table.insert(names, name)
	end
	table.sort(names)
	sec:Dropdown(animType, names, function(selected)
		local id = AnimDB[animType][selected]
		if id then
			setAnimation(animType, id)
			win:Notify("Animation", selected .. " → " .. animType, 2)
		end
	end)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Reelicss/STOPSKID/refs/heads/main/Pop%20Up"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Reelicss/GETAJOB/refs/heads/main/1"))()

-- ================ MISC TAB ================
local misc = win:Tab("Misc")
local tp   = misc:Section("Teleport")
tp:Dropdown("Location", {"Spawn","Island","Cave"}, function(v) end)
tp:Input("Custom coords x,y,z", function(t) end)

-- ================ SETTINGS TAB ================
local settings = win:Tab("Settings")
win:ThemeSection(settings)
local accentSec = settings:Section("Accent")
accentSec:ColorPicker("Color", Color3.fromRGB(180, 25, 25), function(col) end)
