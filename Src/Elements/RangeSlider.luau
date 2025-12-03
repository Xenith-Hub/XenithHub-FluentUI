local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "RangeSlider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Max, "RangeSlider - Missing maximum value.")

	local RangeSlider = {
		Min = typeof(Config.Min) == "number" and Config.Min or 0,
		Max = Config.Max,
		ValueMin = nil,
		ValueMax = nil,
		Rounding = typeof(Config.Rounding) == "number" and Config.Rounding or 0,
		Callback = typeof(Config.Callback) == "function" and Config.Callback or function(Min, Max) end,
		Changed = Config.Changed or function() end,
		Type = "RangeSlider"
	}

	local DraggingMin = false
	local DraggingMax = false

	local SliderFrame = require(Components.Element)(Config.Title or "Range Slider", Config.Description, self.Container, false)
	SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	RangeSlider.SetTitle = SliderFrame.SetTitle
	RangeSlider.SetDesc = SliderFrame.SetDesc

	-- Min handle (left)
	local SliderDotMin = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ZIndex = 2,
		ThemeTag = {
			ImageColor3 = "Accent",
		}
	})

	-- Max handle (right)
	local SliderDotMax = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ZIndex = 2,
		ThemeTag = {
			ImageColor3 = "Accent",
		}
	})

	local SliderRail = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(1, -14, 1, 0)
	}, {
		SliderDotMin,
		SliderDotMax,
	})

	-- Fill between the two handles
	local SliderFill = New("Frame", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 1,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		})
	})

	-- Display showing Min - Max
	local SliderDisplay = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = "0 - 100",
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 14),
		Position = UDim2.new(0, -4, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = {
			TextColor3 = "SubText",
		}
	})

	local SliderInner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 4),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 0.4,
		Parent = SliderFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "SliderRail",
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		New("UISizeConstraint", {
			MaxSize = Vector2.new(150, math.huge),
		}),
		SliderDisplay,
		SliderFill,
		SliderRail
	})

	-- Min handle dragging
	Creator.AddSignal(SliderDotMin.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			DraggingMin = true
		end
	end)

	Creator.AddSignal(SliderDotMin.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			DraggingMin = false
		end
	end)

	-- Max handle dragging
	Creator.AddSignal(SliderDotMax.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			DraggingMax = true
		end
	end)

	Creator.AddSignal(SliderDotMax.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			DraggingMax = false
		end
	end)

	function RangeSlider:OnChanged(Func)
		RangeSlider.Changed = Func
		Library:SafeCallback(Func, RangeSlider.ValueMin, RangeSlider.ValueMax)
	end

	function RangeSlider:SetValueMin(Value: number)
		local OldValue = self.ValueMin or Value

		-- Ensure min doesn't exceed max
		Value = math.min(Value, self.ValueMax or self.Max)

		rawset(self, "ValueMin", Library.Utilities:Round(math.clamp(Value, RangeSlider.Min, RangeSlider.Max), RangeSlider.Rounding))

		self:UpdateDisplay()

		if typeof(RangeSlider.Callback) == "function" then
			Library:SafeCallback(RangeSlider.Callback, self.ValueMin, self.ValueMax)
		end
		if typeof(RangeSlider.Changed) == "function" then
			Library:SafeCallback(RangeSlider.Changed, self.ValueMin, self.ValueMax)
		end
	end

	function RangeSlider:SetValueMax(Value: number)
		local OldValue = self.ValueMax or Value

		-- Ensure max doesn't go below min
		Value = math.max(Value, self.ValueMin or self.Min)

		rawset(self, "ValueMax", Library.Utilities:Round(math.clamp(Value, RangeSlider.Min, RangeSlider.Max), RangeSlider.Rounding))

		self:UpdateDisplay()

		if typeof(RangeSlider.Callback) == "function" then
			Library:SafeCallback(RangeSlider.Callback, self.ValueMin, self.ValueMax)
		end
		if typeof(RangeSlider.Changed) == "function" then
			Library:SafeCallback(RangeSlider.Changed, self.ValueMin, self.ValueMax)
		end
	end

	function RangeSlider:SetValues(MinValue: number, MaxValue: number)
		rawset(self, "ValueMin", Library.Utilities:Round(math.clamp(MinValue, RangeSlider.Min, RangeSlider.Max), RangeSlider.Rounding))
		rawset(self, "ValueMax", Library.Utilities:Round(math.clamp(MaxValue, RangeSlider.Min, RangeSlider.Max), RangeSlider.Rounding))

		-- Ensure min <= max
		if self.ValueMin > self.ValueMax then
			local temp = self.ValueMin
			rawset(self, "ValueMin", self.ValueMax)
			rawset(self, "ValueMax", temp)
		end

		self:UpdateDisplay()

		if typeof(RangeSlider.Callback) == "function" then
			Library:SafeCallback(RangeSlider.Callback, self.ValueMin, self.ValueMax)
		end
		if typeof(RangeSlider.Changed) == "function" then
			Library:SafeCallback(RangeSlider.Changed, self.ValueMin, self.ValueMax)
		end
	end

	function RangeSlider:UpdateDisplay()
		local minScale = (self.ValueMin - RangeSlider.Min) / (RangeSlider.Max - RangeSlider.Min)
		local maxScale = (self.ValueMax - RangeSlider.Min) / (RangeSlider.Max - RangeSlider.Min)

		SliderDotMin.Position = UDim2.new(minScale, -7, 0.5, 0)
		SliderDotMax.Position = UDim2.new(maxScale, -7, 0.5, 0)

		SliderFill.Position = UDim2.fromScale(minScale, 0)
		SliderFill.Size = UDim2.fromScale(maxScale - minScale, 1)

		SliderDisplay.Text = tostring(self.ValueMin) .. " - " .. tostring(self.ValueMax)
	end

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if
			(DraggingMin or DraggingMax)
			and (
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local SizeScale =
				math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
			local NewValue = RangeSlider.Min + ((RangeSlider.Max - RangeSlider.Min) * SizeScale)

			if DraggingMin then
				RangeSlider:SetValueMin(NewValue)
			elseif DraggingMax then
				RangeSlider:SetValueMax(NewValue)
			end
		end
	end)

	function RangeSlider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	-- Set initial values
	local DefaultMin = typeof(Config.DefaultMin) == "number" and Config.DefaultMin or RangeSlider.Min
	local DefaultMax = typeof(Config.DefaultMax) == "number" and Config.DefaultMax or RangeSlider.Max

	RangeSlider:SetValues(DefaultMin, DefaultMax)

	Library.Options[Idx] = RangeSlider

	RangeSlider.Instance = SliderFrame

	return setmetatable(RangeSlider, {
		__newindex = function(self, index, newvalue)
			if index == "ValueMin" then
				task.spawn(RangeSlider.SetValueMin, RangeSlider, newvalue)
			elseif index == "ValueMax" then
				task.spawn(RangeSlider.SetValueMax, RangeSlider, newvalue)
			end
			rawset(self, index, newvalue)
		end
	})
end

return Element
