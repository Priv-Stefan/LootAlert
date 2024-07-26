local lola_locked = false
lola_variables =
{
	Xpos = 0,
	Ypos = 0,
	wishes = {},
}
local start_index = 1
local max_lines = 9
local listframes = {}
local itemdb = {}

local function debug(...)
	local succ, message = pcall(string.format, ...)
	if succ then
		print("|cffff1100Debug: |r", message)
	else
		print("|cffff1100Debug: |r", tostringall(...))
	end
end

local function set_slider_max()
	if #lola_variables.wishes > max_lines then
		LoLaMain.slider:SetMinMaxValues(1, #lola_variables.wishes - max_lines + 1)
		--sprint(#lola_variables.wishes-max_lines)
	else
		LoLaMain.slider:SetMinMaxValues(1, 1)
	end
end

local function scan()
	debug("Scanning")
	itemdb = nil
	itemdb = {}
	for i = 40000, 55000 do
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice =
			GetItemInfo(i)
		if name ~= nil then
			item = {}
			item["name"] = name
			item["id"] = i
			table.insert(itemdb, item)
		end
	end
	debug("Scanning done")
end

local function show_items()
	if listframes[1] == nil then
		return
	end
	local index = 1
	for i = 1, max_lines do
		if i + start_index - 1 <= #lola_variables.wishes then
			local name, link, quality, iLevel, reqLevel, class, subclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(lola_variables.wishes[i + start_index - 1]["itemid"])
			listframes[i].item:SetText(link)
			listframes[i].link = link
			listframes[i]:Show()
			listframes[i].itemtexture:Show()
			listframes[i].itemtexture:SetTexture(texture)
		else
			listframes[i].item:SetText("")
			listframes[i].itemtexture:Hide()
			listframes[i]:Hide()
		end
	end
end

function lola_btnAdd_click(arg1)
	local itemname = edtWish:GetText()
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice
	local id = tonumber(itemname)
	if id ~= nil then
		name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(
			id)
	else
		name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(
			itemname)
	end

	if name == nil then
		for i = 1, #itemdb do
			if string.find(itemdb[i]['name'], itemname) then
				name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice =
					GetItemInfo(itemdb[i]['id'])
				break;
			end
		end
	end

	if name ~= nil then
		local itemNum = tonumber(link:match("|Hitem:(%d+):"))		
		local w = {}
		w['itemid'] = itemNum
		table.insert(lola_variables.wishes, w)
		if #lola_variables.wishes > max_lines then
			set_slider_max()
			start_index = #lola_variables.wishes - max_lines + 1
			LoLaMain.slider:SetValue(start_index)
		else
			show_items()
		end
		edtWish:SetText("")
	else
		edtWish:SetText("nf " .. itemname)
	end
end

function lola_btnscan_click()
	scan()
end

function lola_btnDel_click(self)
	local idx = tonumber(self:GetName():match('lolawish_(%d+)_'))
	table.remove(lola_variables.wishes, start_index + idx - 1)
	show_items()
	set_slider_max()
end

local function load_variables()
	LoLaMain:SetPoint("CENTER", "UIParent", "CENTER",
		lola_variables.Xpos, lola_variables.Ypos)

	--print("Loaded : ", lola_variables.Xpos, lola_variables.Ypos, lola_variables.wishes[1])

	if lola_variables.wishes == nil then
		lola_variables.wishes = {}
	end

	show_items()
	set_slider_max()
end

-- -----------------------------------------------------------------
function lola_texture_OnEnter(self, motion)
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end
end

-- -----------------------------------------------------------------
function lola_texture_OnLeave(self, motion)
	GameTooltip:Hide()
end

-- -----------------------------------------------------------------

function lola_OnEvent(self, event, ...)
	-- print(event)
	if event == "PLAYER_ENTERING_WORLD" then

	elseif event == "VARIABLES_LOADED" then
		load_variables()
	end
end

-----------------------------------------------------------------------
local function lola_SlashCommand(msg, ...)
	if LoLaMain:IsVisible() then
		LoLaMain:Hide()
	else
		LoLaMain:Show()
	end
end
-----------------------------------------------------------------------
function lola_onLoad()
	print("Loot Alert loaded")
	-- table.insert(lola_variables.wishes,"Wunsch 1")

	for i = 1, max_lines do
		local le = CreateFrame("Frame", "lolawish_" .. i, lolascrollframe, "ListElementTemplate")

		table.insert(listframes, le)
		if i == 1 then
			le:SetPoint("TOPLEFT", 4, -4)
		else
			le:SetPoint("TOPLEFT", listframes[i - 1], "BOTTOMLEFT", 0, 0)
		end
	end


	LoLaMain:RegisterEvent("PLAYER_ENTERING_WORLD")
	LoLaMain:RegisterEvent("VARIABLES_LOADED")

	SLASH_LOOTALERT1 = "/lola"
	SlashCmdList["LOOTALERT"] = lola_SlashCommand
end

-----------------------------------------------------------------------
function lola_start_moving(arg1)
	if lola_locked == false then
		arg1:StartMoving();
	end
end

-----------------------------------------------------------------------

function lola_savePosition(arg1)
	local relativeTo
	local point = "Center"
	local relativePoint = "Center"

	if lola_locked == false then
		arg1:StopMovingOrSizing();

		point, relativeTo, relativePoint,
		lola_variables.Xpos, lola_variables.Ypos = LoLaMain:GetPoint()
	end
end

function lola_slider_onload(self)
	self:SetMinMaxValues(1, max_lines)
	self:SetValueStep(1.0)
	self:SetValue(1)
end

function lola_slider_onValueChanged(self)
	start_index = self:GetValue()
	show_items()
end
