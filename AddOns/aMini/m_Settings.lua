---------------- > Some slash commands
SlashCmdList['RELOADUI'] = function() ReloadUI() end
SLASH_RELOADUI1 = '/rl'

SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/gm"

SlashCmdList["READYCHECKSLASHRC"] = function() DoReadyCheck() end
SLASH_READYCHECKSLASHRC1 = '/rc'

SlashCmdList["DISABLE_ADDON"] = function(s) DisableAddOn(s) print(s, format("|cffd36b6b disabled")) end
SLASH_DISABLE_ADDON1 = "/dis"   -- You need to reload UI after enabling/disabling addon

SlashCmdList["ENABLE_ADDON"] = function(s) EnableAddOn(s) print(s, format("|cfff07100 enabled")) end
SLASH_ENABLE_ADDON1 = "/en"   -- You need to reload UI after enabling/disabling addon

SlashCmdList["CLCE"] = function() CombatLogClearEntries() end
SLASH_CLCE1 = "/clfix"

---------------- > a command to show frame you currently have mouseovered
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		ChatFrame1:AddMessage("Name: |cffFFD100"..arg:GetName())
		if arg:GetParent() then
			ChatFrame1:AddMessage("Parent: |cffFFD100"..arg:GetParent():GetName())
		end
 		ChatFrame1:AddMessage("Width: |cffFFD100"..format("%.2f",arg:GetWidth()))
		ChatFrame1:AddMessage("Height: |cffFFD100"..format("%.2f",arg:GetHeight()))
		ChatFrame1:AddMessage("Strata: |cffFFD100"..arg:GetFrameStrata())
		ChatFrame1:AddMessage("Level: |cffFFD100"..arg:GetFrameLevel())
 		if xOfs then
			ChatFrame1:AddMessage("X: |cffFFD100"..format("%.2f",xOfs))
		end
		if yOfs then
			ChatFrame1:AddMessage("Y: |cffFFD100"..format("%.2f",yOfs))
		end
		if relativeTo then
			ChatFrame1:AddMessage("Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
		end
		ChatFrame1:AddMessage("----------------------")
	elseif arg == nil then
		ChatFrame1:AddMessage("Invalid frame name")
	else
		ChatFrame1:AddMessage("Could not find frame info")
	end
end
SLASH_FRAME1 = "/gf"

---------------- > SetupUI
SetCVar("autoLootDefault", 1)
SetCVar("lootUnderMouse", 1)
SetCVar("autoSelfCast", 1)
SetCVar("ShowClassColorInNameplate", 1)
SetCVar("autoQuestWatch", 0)
SetCVar("instantQuestText", 1)
SetCVar("floatingCombatTextCombatDamage", 0)
SetCVar("floatingCombatTextReactives", 0)
--每次进入后重载一次 才生效
local setvalue = CreateFrame("Frame")
function SetCValue()
	SetCVar("scriptErrors", 0)
	SetCVar("profanityFilter", 0)
	SetCVar("chatClassColorOverride", 0)
	SetCVar("alwaysCompareItems", 1)
	SetCVar("nameplateMaxDistance", "4e1")
	SetCVar("cameraDistanceMaxZoomFactor", "2.6")
	setvalue:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
setvalue:RegisterEvent("PLAYER_ENTERING_WORLD")
setvalue:SetScript("OnEvent", SetCValue)

---------------- > Moving TicketStatusFrame
TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT",UIParent,"TOPLEFT")
TicketStatusFrame.SetPoint = function() end

---------------- > Disband Group
local GroupDisband = function()
	local pName = UnitName("player")
	if UnitInRaid("player") then
	SendChatMessage("解散当前队伍", "RAID")
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= pName then
				UninviteUnit(name)
			end
		end
	LeaveParty()
	elseif UnitInParty("player") then
		SendChatMessage("解散当前队伍", "PARTY")
		for i = 1, GetNumSubgroupMembers() do
			if UnitName("party"..i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	LeaveParty()
	else
		StaticPopup_Show("NOGROUP")
	end

end
StaticPopupDialogs["DISBAND_GROUP"] = {
	text = "确认要解散当前队伍?",
	button1 = YES,
	button2 = NO,
	OnAccept = GroupDisband,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["NOGROUP"] = {
	text = "你没有在任何一个队伍中!",
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
}

SlashCmdList["GROUPDISBAND"] = function()
	StaticPopup_Show("DISBAND_GROUP")
end
SLASH_GROUPDISBAND1 = '/rd'

---------------- > 法术书滚轮翻页
local function SpellBookFrame_OnMouseWheel(self, value, scrollBar)

	local currentPage, maxPages = SpellBook_GetCurrentPage()

	if(value > 0) then
		if(currentPage > 1) then
			SpellBookPrevPageButton_OnClick()
		end
	else
		if(currentPage < maxPages) then
			SpellBookNextPageButton_OnClick()
		end
	end
end

---------------- > 装备比较
local ItemRefTooltip = ItemRefTooltip

-- ItemRef.xml:45
ItemRefTooltip.UpdateTooltip = function(self)
	if ( not self.comparing and not IsModifiedClick("COMPAREITEMS")) then
		GameTooltip_ShowCompareItem(self)
		self.comparing = true
	elseif ( self.comparing and IsModifiedClick("COMPAREITEMS")) then
		for _, frame in pairs(self.shoppingTooltips) do
			frame:Hide()
		end
		self.needsReset = true
		self.comparing = false
	end
end

-- ItemRef.xml:60
ItemRefTooltip:SetScript("OnTooltipSetItem", function(self)
	if (not IsModifiedClick("COMPAREITEMS") and self:IsMouseOver()) then
		GameTooltip_ShowCompareItem(self)
		self.comparing = true
	end
end)

ItemRefTooltip:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	ValidateFramePosition(self)
	if (not IsModifiedClick("COMPAREITEMS") ) then --We do this to choose where the comparison is shown
		GameTooltip_ShowCompareItem(self)
		self.comparing = true
	end
end)

-- GameTooltip.xml:25
GameTooltip:SetScript("OnTooltipSetItem", function(self)
	if ( not IsModifiedClick("COMPAREITEMS") and not self:IsEquippedItem() ) then
		GameTooltip_ShowCompareItem(self)
	else
		local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips)
		shoppingTooltip1:Hide()
		shoppingTooltip2:Hide()
	end
	if (BattlePetTooltip) then
		BattlePetTooltip:Hide()
	end
end)
