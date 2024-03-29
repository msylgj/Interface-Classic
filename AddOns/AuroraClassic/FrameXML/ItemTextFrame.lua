local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	InboxFrameBg:Hide()
	ItemTextPrevPageButton:GetRegions():Hide()
	ItemTextNextPageButton:GetRegions():Hide()
	ItemTextMaterialTopLeft:SetAlpha(0)
	ItemTextMaterialTopRight:SetAlpha(0)
	ItemTextMaterialBotLeft:SetAlpha(0)
	ItemTextMaterialBotRight:SetAlpha(0)

	ItemTextFrame.CloseButton = ItemTextCloseButton
	F.ReskinPortraitFrame(ItemTextFrame, 15, -15, -30, 65)
	F.ReskinScroll(ItemTextScrollFrameScrollBar)
	F.ReskinArrow(ItemTextPrevPageButton, "left")
	F.ReskinArrow(ItemTextNextPageButton, "right")
	--ItemTextFramePageBg:SetAlpha(0)
	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = F.dummy

	-- fix scrollbar bg, need reviewed
	ItemTextScrollFrame:DisableDrawLayer("ARTWORK")
	ItemTextScrollFrame:DisableDrawLayer("BACKGROUND")
end)