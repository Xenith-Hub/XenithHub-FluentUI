local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New

local Element = {}
Element.__index = Element
Element.__type = "Divider"

function Element:New(Idx, Config)
	if Config == nil and typeof(Idx) == "table" then
		Config, Idx = Idx, nil
	end

	Config = Config or {}
	local Library = self.Library

	local TitleText = Config.Title or Config.Text
	local Padding = Config.Padding or 12
	local Thickness = Config.Thickness or 1
	local Transparency = typeof(Config.Transparency) == "number" and Config.Transparency or 0.35

	local Divider = {
		Type = "Divider",
		CreatedAt = tick(),
	}

	local DividerFrame = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = self.Container,
		LayoutOrder = 7,
	}, {
		New("UIPadding", {
			PaddingLeft = UDim.new(0, Padding),
			PaddingRight = UDim.new(0, Padding),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}),
	})

	local Layout = New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, TitleText and 4 or 2),
	})
	Layout.Parent = DividerFrame

	local Label: TextLabel?
	local Line = New("Frame", {
		LayoutOrder = TitleText and 2 or 1,
		Size = UDim2.new(1, 0, 0, Thickness),
		BackgroundTransparency = Transparency,
		ThemeTag = {
			BackgroundColor3 = "ElementBorder",
		},
		Parent = DividerFrame,
	})

	local function RefreshLayout()
		local HasTitle = TitleText ~= nil and TitleText ~= ""
		Layout.Padding = UDim.new(0, HasTitle and 4 or 2)
		Line.LayoutOrder = HasTitle and 2 or 1
	end

	local function EnsureLabel()
		local HasTitle = TitleText ~= nil and TitleText ~= ""

		if not HasTitle then
			if Label then
				Label:Destroy()
				Label = nil
			end
			RefreshLayout()
			Divider.Label = Label
			return
		end

		if not Label then
			Label = New("TextLabel", {
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 14),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextSize = 12,
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				ThemeTag = {
					TextColor3 = "SubText",
				},
				Parent = DividerFrame,
			})
		end

		Label.Text = TitleText
		Divider.Label = Label
		RefreshLayout()
	end

	EnsureLabel()

	Divider.Frame = DividerFrame
	Divider.Line = Line
	Divider.Label = Label
	Divider.Instance = DividerFrame

	function Divider:SetTitle(Text)
		TitleText = Text
		EnsureLabel()
		Divider.Label = Label
	end

	function Divider:Destroy()
		DividerFrame:Destroy()
		if Idx and Library and Library.Options then
			Library.Options[Idx] = nil
		end
	end

	if Idx and Library and Library.Options then
		Library.Options[Idx] = Divider
	end

	return Divider
end

return Element
