local lola_locked = false
lola_variables =
{
	Xpos = 0,
	Ypos = 0,
	wishes = {},
	loot={}
}
local wish_start_index = 1
local loot_start_index = 1
local max_lines = 9
local listframes = {}
local listlootedframes = {}
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
		lola_wish_frame.slider:SetMinMaxValues(1, #lola_variables.wishes - max_lines + 1)
		--sprint(#lola_variables.wishes-max_lines)
	else
		lola_wish_frame.slider:SetMinMaxValues(1, 1)
	end
end

local function set_loot_slider_max()
	if #lola_variables.loot > max_lines then
		lola_looted.slider:SetMinMaxValues(1, #lola_variables.loot - max_lines + 1)
		--sprint(#lola_variables.wishes-max_lines)
	else
		lola_looted.slider:SetMinMaxValues(1, 1)
	end
end

local function show_loot()
	if listlootedframes[1] == nil then
		return
	end
	local index = 1
	for i = 1, max_lines do
		if i + loot_start_index - 1 <= #lola_variables.loot then
			local name, link, quality, iLevel, reqLevel, class, subclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(lola_variables.loot[i + loot_start_index - 1]['id'])
			listlootedframes[i].item:SetText( lola_variables.loot[i + loot_start_index - 1]['count'] .. " " .. link)
			listlootedframes[i].link = link
			listlootedframes[i]:Show()
			listlootedframes[i].itemtexture:Show()
			listlootedframes[i].itemtexture:SetTexture(texture)
		else
			listlootedframes[i].item:SetText("")
			listlootedframes[i].itemtexture:Hide()
			listlootedframes[i]:Hide()
		end
	end

end

-- local function show_loot()
-- 	if listlootedframes[1] == nil then
-- 		return
-- 	end
-- 	local index = 1
-- 	for i = 1, max_lines do
-- 		if i + wish_start_index - 1 <= #lola_variables.wishes then
-- 			local name, link, quality, iLevel, reqLevel, class, subclass,
-- 			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemdb[i + loot_start_index - 1]["id"])
-- 			listlootedframes[i].item:SetText(link)
-- 			listlootedframes[i].link = link
-- 			listlootedframes[i]:Show()
-- 			listlootedframes[i].itemtexture:Show()
-- 			listlootedframes[i].itemtexture:SetTexture(texture)
-- 		else
-- 			listlootedframes[i].item:SetText("")
-- 			listlootedframes[i].itemtexture:Hide()
-- 			listlootedframes[i]:Hide()
-- 		end
-- 	end
-- end


local function scan()
	debug("Scanning")
	itemdb = nil
	itemdb = {}
	for i = 40000, 55000 do
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice =
			GetItemInfo(i)
		if name ~= nil then
			if quality > 3 then
				item = {}
				item["name"] = name
				item["id"] = i
				table.insert(itemdb, item)
			end
		end
	end
	if #itemdb > max_lines then
		lola_looted.slider:SetMinMaxValues(1, #itemdb- max_lines + 1)
	else
		lola_looted.slider:SetMinMaxValues(1, 1)
	end

	show_loot()
	debug("Scanning done")
end

local function show_items()
	if listframes[1] == nil then
		return
	end
	local index = 1
	for i = 1, max_lines do
		if i + wish_start_index - 1 <= #lola_variables.wishes then
			local name, link, quality, iLevel, reqLevel, class, subclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(lola_variables.wishes[i + wish_start_index - 1]["itemid"])
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
			wish_start_index = #lola_variables.wishes - max_lines + 1
			lola_wish_frame.slider:SetValue(wish_start_index)
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
	if idx ~= nil then 
		table.remove(lola_variables.wishes, wish_start_index + idx - 1)
		show_items()
		set_slider_max()
	else
		idx = tonumber(self:GetName():match('lolaloot_(%d+)_'))		
		if idx ~= nil then 
			table.remove(lola_variables.loot, loot_start_index + idx - 1)
			show_loot()
			set_loot_slider_max()
		end
	end
end

local function load_variables()
	LoLaMain:SetPoint("CENTER", "UIParent", "CENTER",
		lola_variables.Xpos, lola_variables.Ypos)

	--print("Loaded : ", lola_variables.Xpos, lola_variables.Ypos, lola_variables.wishes[1])

	if lola_variables.wishes == nil then
		lola_variables.wishes = {}
	end

	if lola_variables.loot == nil then
		lola_variables.loot = {}
	end
	show_items()
	set_slider_max()

	show_loot()
	set_loot_slider_max()
end

-- -----------------------------------------------------------------
local function add_loot( message )
	local itemNum = tonumber(string.match(message,"item:(%d+):"))	

	if itemNum ~= nil then
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice= GetItemInfo(itemNum)
		if name~=nil then
			local found = false
			for i=1,#lola_variables.loot do
				if lola_variables.loot[i]['id'] == itemNum then
					lola_variables.loot[i]['count'] = lola_variables.loot[i]['count'] + 1
					found = true
					break
				end
			end
			if found == false then 
				item = {}
				item["count"] = 1
				item["id"] = itemNum

				table.insert(lola_variables.loot, item)
				if #lola_variables.loot > max_lines then
					lola_looted.slider:SetMinMaxValues(1, #lola_variables.loot- max_lines + 1)
					loot_start_index = #lola_variables.loot - max_lines + 1
				else
					lola_looted.slider:SetMinMaxValues(1, 1)
					loot_start_index = 1
				end
				lola_looted.slider:SetValue(loot_start_index)
			end
			show_loot()
		end
	end
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
	elseif event == "CHAT_MSG_LOOT" then
		add_loot(...)
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
	
	for i = 1, max_lines do
		local wish = CreateFrame("Frame", "lolawish_" .. i, lola_wish_frame.main, "ListElementTemplate")
		local loot = CreateFrame("Frame", "lolaloot_" .. i, lola_looted.main, "ListElementTemplate")		                                                    

		table.insert(listframes, wish)
		table.insert(listlootedframes, loot)
		if i == 1 then
			wish:SetPoint("TOPLEFT", 4, -4)
			loot:SetPoint("TOPLEFT", 4, -4)
		else
			wish:SetPoint("TOPLEFT", listframes[i - 1], "BOTTOMLEFT", 0, 0)
			loot:SetPoint("TOPLEFT", listlootedframes[i - 1], "BOTTOMLEFT", 0, 0)
		end
		loot:Hide()
	end

	LoLaMain:RegisterEvent("PLAYER_ENTERING_WORLD")
	LoLaMain:RegisterEvent("VARIABLES_LOADED")
	LoLaMain:RegisterEvent("CHAT_MSG_LOOT")
	
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
	if self:GetName()=="lola_wish_frame_vslider"  then
		wish_start_index = self:GetValue()
		show_items()
	else
		loot_start_index = self:GetValue()
		show_loot()
	end
end
