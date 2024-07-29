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

local function sort_comp(a,b)	
	local name1,name2, link, quality, iLevel, reqLevel, class, subclass,maxStack, equipSlot, texture, vendorPrice 
	name1, link, quality, iLevel, reqLevel, class, subclass,	maxStack, equipSlot, texture, vendorPrice = GetItemInfo(a['id'])
	name2, link, quality, iLevel, reqLevel, class, subclass,	maxStack, equipSlot, texture, vendorPrice = GetItemInfo(b['id'])

	return name1 < name2
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

-- --------------------------------------------------------------------
-- Check whether an ID is in a a list
function isIDinList(id, list)
	for i=1, #list do
		if list[i]['id'] == id then
			return true
		end
	end
	return false
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

-- --------------------------------------------------------
-- Show looted items
local function show_loot()
	if listlootedframes[1] == nil then
		return
	end
	local index = 1
	for i = 1, max_lines do
		if i + loot_start_index - 1 <= #lola_variables.loot then
			local id = lola_variables.loot[i + loot_start_index - 1]['id']
			local name, link, quality, iLevel, reqLevel, class, subclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo( id )
			listlootedframes[i].item:SetText( lola_variables.loot[i + loot_start_index - 1]['count'] .. " " .. link)
			listlootedframes[i].link = link
			listlootedframes[i]:Show()
			listlootedframes[i].itemtexture:Show()
			listlootedframes[i].itemtexture:SetTexture(texture)
			if isIDinList(id, lola_variables.wishes) then
				listlootedframes[i].background2:Show()
			else
				listlootedframes[i].background2:Hide()
			end
		else
			listlootedframes[i].item:SetText("")
			listlootedframes[i].itemtexture:Hide()
			listlootedframes[i]:Hide()
		end
	end
end

-- --------------------------------------------------------
-- Show wishlist
local function show_items()
	if listframes[1] == nil then
		return
	end
	local index = 1
	for i = 1, max_lines do
		if i + wish_start_index - 1 <= #lola_variables.wishes then
			local id = lola_variables.wishes[i + wish_start_index - 1]["id"]
			local name, link, quality, iLevel, reqLevel, class, subclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(id)
			listframes[i].item:SetText(link)
			listframes[i].link = link
			listframes[i]:Show()
			listframes[i].itemtexture:Show()
			listframes[i].itemtexture:SetTexture(texture)
			if isIDinList(id,lola_variables.loot) then
				listframes[i].background2:Show()
			else
				listframes[i].background2:Hide()
			end
		else
			listframes[i].item:SetText("")
			listframes[i].itemtexture:Hide()
			listframes[i]:Hide()
		end
	end	
end

-- -----------------------------------------------------------------
-- Add looted item to the loot list
local function add_loot( message )
	local itemNum = tonumber(string.match(message,"item:(%d+):"))	

	if itemNum ~= nil then
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice= GetItemInfo(itemNum)
		if name~=nil then
			if quality < 4 then
				return
			end
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
			show_items() -- Color update
		end
	end
end

-- ----------------------------------------------------
-- scan for items, so we can add them, even if they are 
-- not in the char's item cache
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


-- ----------------------------------------------------
-- Add item to the wishlist 
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
		w['id'] = itemNum
		table.insert(lola_variables.wishes, w)
		table.sort(lola_variables.wishes,sort_comp)

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

-- ----------------------------------------------------
-- Delete item to the from lists
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
			show_items() -- Color update
		end
	end
end

function lola_btnscan_click()
	scan()
end

local function warn_loot( message )
	local itemNum = tonumber(string.match(message,"item:(%d+):"))
	
	if itemNum ~= nil then
		if isIDinList(itemNum, lola_variables.wishes) then
			PlaySoundFile("sound\\interface\\PVPFlagTakenHordeMono.wav")
			local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice= GetItemInfo(itemNum)
			debug("Roll ", name)
		end
	end
end

-- -----------------------------------------------------------------
local function load_variables()
	LoLaMain:SetPoint("CENTER", "UIParent", "CENTER",
		lola_variables.Xpos, lola_variables.Ypos)

	if lola_variables.wishes == nil then
		lola_variables.wishes = {}
	else
		-- compatibility for rename itemid to id 
		for i=1,#lola_variables.wishes do
			if lola_variables.wishes[i]['itemid'] ~= nil then
				lola_variables.wishes[i]['id'] = lola_variables.wishes[i]['itemid']
				lola_variables.wishes[i]['itemid'] = nil
			end
		end
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
-- Show the item tooltips
function lola_texture_OnEnter(self, motion)	
	local link = self:GetParent().link
	if link then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(link)
		if IsShiftKeyDown() then
				
			ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE");
			ShoppingTooltip2:SetOwner(GameTooltip, "ANCHOR_NONE");
			ShoppingTooltip3:SetOwner(GameTooltip, "ANCHOR_NONE");

			local comp1 = nil
			local comp2 = nil
			local comp3 = nil
			if ShoppingTooltip1:SetHyperlinkCompareItem(link,1,1,GameTooltip) then
				comp1 = true
			end
			if ShoppingTooltip2:SetHyperlinkCompareItem(link,2,1,GameTooltip) then
				comp2 = true
			end
			if ShoppingTooltip3:SetHyperlinkCompareItem(link,3,1,GameTooltip) then
				comp3 = true
			end		
			GameTooltip:Show()

			local left, right, anchor1, anchor2 = GameTooltip:GetLeft(), GameTooltip:GetRight(), "TOPLEFT", "TOPRIGHT";
			if comp1 then
				ShoppingTooltip1:ClearAllPoints();
				ShoppingTooltip1:SetPoint(anchor1, GameTooltip, anchor2, 0, -10);
				ShoppingTooltip1:Show();
			end
			if comp2 then
				ShoppingTooltip2:ClearAllPoints();
				if comp1 then
					ShoppingTooltip2:SetPoint(anchor1, ShoppingTooltip1, anchor2, 0, -10);
				else
					ShoppingTooltip2:SetPoint(anchor1, GameTooltip, anchor2, 0, -10);
				end
				ShoppingTooltip2:Show();
			end
			if comp3 then
				ShoppingTooltip3:ClearAllPoints();
				ShoppingTooltip3:SetPoint(anchor1, GameTooltip, anchor2, 0, -10);
				ShoppingTooltip3:Show();
			end
		end
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
	elseif event == "CHAT_MSG_RAID_WARNING" then
		warn_loot(...)
	end
end

-----------------------------------------------------------------------
local function lola_SlashCommand(msg, ...)
	if string.sub(msg,1,7) =="addloot"then
		local id = tonumber(string.sub(msg,8))
		if id == nil then
			debug("Gib doch bitte eine ID an!")
		else
			add_loot("item:" .. id .. ":")
		end
	else
		if LoLaMain:IsVisible() then
			LoLaMain:Hide()
		else
			LoLaMain:Show()
		end
	end
end
-----------------------------------------------------------------------
function lola_onLoad()
	print("|cff5555ffLoot Alert|r")	
	
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
	LoLaMain:RegisterEvent("CHAT_MSG_RAID_WARNING")
	
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
