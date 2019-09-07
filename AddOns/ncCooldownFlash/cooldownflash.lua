--nccooldownflash

local lib = LibStub("LibCooldown")
if not lib then error("CooldownFlash requires LibCooldown") return end
local point = {"CENTER", UIParent, 0, 0}

local filter = {
	["pet"] = "all",
	["item"] = {
		[6948] = true, -- hearthstone
	},
	["spell"] = {
	},
}
	
local flash = CreateFrame("Frame", nil, UIParent)
flash.icon = flash:CreateTexture(nil, "OVERLAY")

local function GetScreenModes()
	local curResIndex = GetCurrentResolution()
	local curRes = curResIndex > 0 and select(curResIndex, GetScreenResolutions()) or nil
	local windowedMode = Display_DisplayModeDropDown:windowedmode()
	
	local resolution = curRes or (windowedMode and GetCVar("gxWindowedResolution")) or GetCVar("gxFullscreenResolution")
	
	return resolution
end

flash:SetScript("OnEvent", function()
	local mult = 768/string.match(GetScreenModes(), "%d+x(%d+)")/GetCVar("uiScale")
	local function scale(x) return mult*math.floor(x+.5) end
	flash:SetPoint(unpack(point))
	flash:SetSize(scale(80),scale(80))
	flash:SetBackdrop({
	  bgFile = [[Interface\AddOns\ncCooldownFlash\solid]], 
	  edgeFile = [[Interface\AddOns\ncCooldownFlash\solid]], 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	flash:SetBackdropColor(.1,.1,.1)
	flash:SetBackdropBorderColor(.6,.6,.6)

	flash.icon:SetPoint("TOPLEFT", scale(2), scale(-2))
	flash.icon:SetPoint("BOTTOMRIGHT", scale(-2), scale(2))
	flash.icon:SetTexCoord(.08, .92, .08, .92)

	flash:Hide()
	flash:SetScript("OnUpdate", function(self, e)
		flash.e = flash.e + e
		if flash.e > .75 then
			flash:Hide()
		elseif flash.e < .25 then
			flash:SetAlpha(flash.e*4)
		elseif flash.e > .5 then
			flash:SetAlpha(1-(flash.e%.5)*4)
		end
	end)
	
	flash:UnregisterEvent("PLAYER_ENTERING_WORLD")
	flash:SetScript("OnEvent", nil)
	
end)

flash:RegisterEvent("PLAYER_ENTERING_WORLD")

lib:RegisterCallback("stop", function(id, class)
	if filter[class]=="all" or filter[class][id] then return end
	flash.icon:SetTexture(class=="item" and GetItemIcon(id) or select(3, GetSpellInfo(id)))
	flash.e = 0
	flash:Show()
end)