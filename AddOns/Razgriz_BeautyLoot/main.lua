-------localization----------
local TitleText = "Items"
local LootFrameConfig = "Loot Frame"
local RollFrameConfig = "Roll Frame"
if GetLocale() == "zhCN" then
    TitleText = "战利品"
    LootFrameConfig = "拾取框"
    RollFrameConfig = "队伍分配框"
end
if GetLocale() == "zhTW" then
    TitleText = "戰利品"
    LootFrameConfig = "拾取框"
    RollFrameConfig = "隊伍分配框體"
end
-------------Settings-------------
local MediaRazgriz = [[Interface\AddOns\Razgriz_BeautyLoot\Media]]
local FrameBackdropColor = {0,0,0}
local FrameBorderColor = {121 / 255,121 / 255, 121 / 255}
local FrameAlpha = 0.65
local BorderAlpha = 1
local CommonFont = [[Fonts\ARKai_T.ttf]]
local LootFrameBorder= [[Interface\Buttons\White8x8]]
local LootButtonNormal = MediaRazgriz.."\\AuraFrameBorderNormal.tga"
local LootButtonBorderOverlay = MediaRazgriz.."\\AuraFrameBorderNormal.tga"
local LootButtonHighlight=MediaRazgriz.."\\AuraGloss.tga"
local LootFrameUpDownBottonNormal=MediaRazgriz.."\\AuraFrameBorderNormal.tga"
local LootFrameUpDownBottonHighlight=MediaRazgriz.."\\AuraGloss.tga"
local LootPrev = MediaRazgriz.."\\LootPrev.tga"
local LootNext = MediaRazgriz.."\\LootNext.tga"
local LootFrameBackdrop = {
        bgFile = LootFrameBorder,
        edgeFile = MediaRazgriz.."\\CommonFrameBorder.tga",
        tile = true,
        edgeSize = 8,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
local GroupLootFrameWarningBorder = {
		edgeFile = LootFrameBorder,
		tile = true,
		tileSize = 8,
		edgeSize = 1,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }
local LootFrameBackdropColor = {r=FrameBackdropColor[1],g=FrameBackdropColor[2],b=FrameBackdropColor[3],a=FrameAlpha}
local GroupLootFrameWarningBorderColor = {r=1,g=0,b=0}
local TimerBarTexture = LootFrameBorder
local RollFrameSize = 22
local RollFrameItemSize = 32
local LootFrameItemHighlightColor = RAID_CLASS_COLORS[select(2,UnitClass("player"))]
------------字体配置 fonts configuration area------------
local FontLootFrameTitle = CommonFont --font to show string like "Items × 4" 拾取框标题的字体
local FontLootFrameTitleSize = 14 --该字体的大小，当上面的字体有效时本参数才有用，下同。 size of font **** Attention! this parameter works only when FontLootFrameTitle is not nil ****
local FontLootFrameTitleFlag = "OUTLINE" --该字体是否有描边 font flag like "OUTLINE" **** Attention! this parameter works only when FontLootFrameTitle is not nil ****
local FontLootFrameTitleColor = RAID_CLASS_COLORS[select(2,UnitClass("player"))] --该字体的颜色font color of above string **** Attention! this parameter works only when FontLootFrameTitle is not nil ****

local FontItemName = CommonFont -- 拾取的物品名称的字体，与之有关的参数也要该字体有效才可。roll frame and loot frame share the same item name font. all related parameters are actived only when this is valid
local FontItemNameSize = 14
local FontItemNameFlag = "OUTLINE"

local FontGroupLootItemName = CommonFont   --Roll点框的字体 fonts to show group loot items
local FontGroupLootItemNameSize = 12
local FontGroupLootItemNameFlag = "OUTLINE"

local FontRollTimer = CommonFont
local FontRollTimerSize = 10
local FontRollTimerFlag = "OUTLINE"

local FontWarningText = nil
local FontWarningTextSize = 20
local FontWarningTextFlag = "OUTLINE"

local FontBindIndicator = CommonFont
local FontBindIndicatorSize = 9
local FontBindIndicatorFlag = "OUTLINE"

local FontBindMisButton = CommonFont
local FontBindMisButtonSize = 10
local FontBindMisButtonFlag = "OUTLINE"

-----------警告框体 Warning Frames-----------
local AnimationScale = .7
local TimetoScale = .15
local FadeOutDelay = 1.5
local TimetoFadeOut = .5
local WarningSound = "Sound\\Interface\\PVPFlagTakenMono.wav"

--物品名称字体没有颜色设置，因为我不想满足你天天拾取橙色物品的愿望~ no item name font color is available since they are all displayed in item quality color!
----------------------------------
local DummyFrame=CreateFrame("Frame") 
local ConfigFrameLoot = CreateFrame("Frame")
local TextArea
TextArea = ConfigFrameLoot:CreateFontString(nil,"OVERLAY","GameFontNormal")
TextArea:SetText(LootFrameConfig)
TextArea:SetAllPoints()
ConfigFrameLoot:Hide()

for i = 1, NUM_GROUP_LOOT_FRAMES do
	_G["ConfigFrameGroupLoot"..i] = CreateFrame("Frame","ConfigFrameGroupLoot"..i)
	TextArea = _G["ConfigFrameGroupLoot"..i]:CreateFontString(nil,"OVERLAY","GameFontNormal")
	TextArea:SetText(RollFrameConfig..i)
	TextArea:SetAllPoints()
	_G["ConfigFrameGroupLoot"..i]:Hide()
end
----------------------------------
local WarningTextFrames = {}
local BEAUTYLOOT_NUMBER_WARNING_FRAMES = 0
function WarningFinished(self)
    self:GetParent():SetAlpha(0)
    self:GetParent().Free = true
end
local function PopupWarningFrame(frame)
    frame:SetScale(1) --restore frame animation params
    frame:SetAlpha(1)
    frame.TimerCounter = 0
    local ScalePerFrame = (1 - frame.ScaleFinal) / max((frame.ScaleTime / 0.015), 1 ) --calculate how much should the window scale in one frame
    frame:Show()
    frame:SetScript("OnUpdate",function(self,TimePassed)
        if self.TimerCounter + TimePassed < 0.0015 then self.TimerCounter = self.TimerCounter + TimePassed return end
        if(self:GetScale() - ScalePerFrame <= self.ScaleFinal) then
            self:SetScale(self.ScaleFinal)
            self:SetScript("OnUpdate",nil)
            _G[self:GetName().."Animation"]:Play()
            return
        else
            self:SetScale(self:GetScale() - ScalePerFrame)
            self.TimerCounter = 0
        end
    end)
end
local function CreateWarningFrame()
    BEAUTYLOOT_NUMBER_WARNING_FRAMES = BEAUTYLOOT_NUMBER_WARNING_FRAMES + 1
    local WarningFrame = CreateFrame("Frame","WarningFrame"..BEAUTYLOOT_NUMBER_WARNING_FRAMES)
    if(BEAUTYLOOT_NUMBER_WARNING_FRAMES == 1) then
        WarningFrame:SetPoint("LEFT",UIParent,"CENTER",0,100)
    else
        WarningFrame:SetPoint("BOTTOM","WarningFrame"..(BEAUTYLOOT_NUMBER_WARNING_FRAMES-1),"TOP",0,10)
    end
    WarningFrame:SetWidth(400)
    WarningFrame:SetHeight(15)
    local text 
    if not FontWarningText then
        text = WarningFrame:CreateFontString("WarningFrame"..BEAUTYLOOT_NUMBER_WARNING_FRAMES.."Text","OVERLAY","GameFontNormal")
    else
        text = WarningFrame:CreateFontString("WarningFrame"..BEAUTYLOOT_NUMBER_WARNING_FRAMES.."Text","OVERLAY")
        text:SetFont(FontWarningText,FontWarningTextSize,FontWarningTextFlag)
    end
    text:SetAllPoints()
    text:SetJustifyH("LEFT")
    
    local Animation = WarningFrame:CreateAnimationGroup("WarningFrame"..BEAUTYLOOT_NUMBER_WARNING_FRAMES.."Animation")
    WarningFrame.ScaleFinal = AnimationScale
    WarningFrame.ScaleTime = TimetoScale
    --[[local scaler = Animation:CreateAnimation("Scale")
    scaler:SetScale(AnimationScale,AnimationScale)
    scaler:SetDuration(TimetoScale)]]--
    local alpha_ani =  Animation:CreateAnimation("Alpha")
    alpha_ani:SetStartDelay(FadeOutDelay)
    --alpha_ani:SetChange(-1)
    alpha_ani:SetDuration(TimetoFadeOut)
    Animation:SetScript("OnFinished",WarningFinished)
    
    local ItemIcon = WarningFrame:CreateTexture("WarningFrame"..BEAUTYLOOT_NUMBER_WARNING_FRAMES.."Icon","ARTWORK")
    ItemIcon:SetWidth(24)
    ItemIcon:SetHeight(24)
    ItemIcon:SetPoint("RIGHT",WarningFrame,"LEFT",-5,0)
    ItemIcon:SetTexCoord(.1,.9,.1,.9)
    local ItemBorder = WarningFrame:CreateTexture("WarningFrame"..BEAUTYLOOT_NUMBER_WARNING_FRAMES.."Border","OVERLAY")
    ItemBorder:SetPoint("TOPLEFT",ItemIcon,-4,4)
    ItemBorder:SetPoint("BOTTOMRIGHT",ItemIcon,4,-4)
    ItemBorder:SetTexture(LootButtonNormal)
    
    table.insert(WarningTextFrames,WarningFrame)
    WarningFrame.Free = true
    return WarningFrame
end

local function GetNextWarningFrame()
    for i,v in pairs(WarningTextFrames) do
        if v.Free then
            return v
        end
    end
    return CreateWarningFrame()
end
local function ShowWarningText(playername, itemname)
    local FreeFrame = GetNextWarningFrame()
    FreeFrame.Free = false
    PlaySoundFile(WarningSound)
    FreeFrame:SetAlpha(1)
    _G[FreeFrame:GetName().."Icon"]:SetTexture(GetItemIcon(itemname))
    local r,g,b = GetItemQualityColor(select(3,GetItemInfo(itemname)))
    _G[FreeFrame:GetName().."Border"]:SetVertexColor(r,g,b) -- quality border
    _G[FreeFrame:GetName().."Text"]:SetText(string.format("|cFF0080c0"..playername..": "..itemname))
    --_G[FreeFrame:GetName().."Animation"]:Play()
    PopupWarningFrame(FreeFrame)
end
----------------------------------
local CreatePulse = function(frame, speed, mult, alpha) -- pulse function originally by nightcracker
	frame.speed = speed or .05
	frame.mult = mult or 1
	frame.alpha = alpha or 1
	frame.tslu = 0 -- time since last update
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.tslu = self.tslu + elapsed
		if self.tslu > self.speed then
			self.tslu = 0
			self:SetAlpha(self.alpha)
		end
		self.alpha = self.alpha - elapsed*self.mult
		if self.alpha < 0 and self.mult > 0 then
			self.mult = self.mult*-1
			self.alpha = 0
		elseif self.alpha > 1 and self.mult < 0 then
			self.mult = self.mult*-1
		end
	end)
end

-----------------------------------
local myname, ns = ...

local locale = GetLocale()
ns.rollpairs = locale == "deDE" and {
	["(.*) passt automatisch bei (.+), weil [ersi]+ den Gegenstand nicht benutzen kann.$"]  = "pass",
	["(.*) würfelt nicht für: (.+|r)$"] = "pass",
	["(.*) hat für (.+) 'Gier' ausgewählt"] = "greed",
	["(.*) hat für (.+) 'Bedarf' ausgewählt"] = "need",
	["(.*) hat für '(.+)' Entzauberung gewählt."]  = "disenchant",
} or locale == "frFR" and {
	["(.*) a passé pour : (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"]  = "pass",
	["(.*) a passé pour : (.+)"]  = "pass",
	["(.*) a choisi Cupidité pour : (.+)"] = "greed",
	["(.*) a choisi Besoin pour : (.+)"]  = "need",
} or locale == "ruRU" and {
	["(.*) автоматически передает предмет (.+), поскольку не может его забрать"] = "pass",
	["(.*) пропускает розыгрыш предмета \"(.+)\", поскольку не может его забрать"] = "pass",
	["(.*) отказывается от предмета (.+)%."]  = "pass",
	["Разыгрывается: (.+)%. (.*): \"Не откажусь\""] = "greed",
	["Разыгрывается: (.+)%. (.*): \"Мне это нужно\""] = "need",
	["Разыгрывается: (.+)%. (.*): \"Распылить\""] = "disenchant",
} or locale == "zhTW" and {
	["(.*)自動放棄:(.+)，因為"]  = "pass",
	["(.*)放棄了:(.+)"] = "pass",
	["(.*)選擇了貪婪:(.+)"] = "greed",
	["(.*)選擇了需求:(.+)"] = "need",
	["(.*)選擇分解:(.+)"] = "disenchant",
} or locale == "zhCN" and {
    ["(.*)自动放弃:(.+)，因为"]  = "pass",
    ["(.*)放弃了:(.+)"] = "pass",
    ["(.*)选择了贪婪:(.+)"] = "greed",
    ["(.*)选择了需求:(.+)"] = "need",
    ["(.*)选择分解:(.+)"] = "disenchant",
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = "pass",
	["^(.*) passed on: (.+|r)$"]  = "pass",
	["(.*) has selected Greed for: (.+)"] = "greed",
	["(.*) has selected Need for: (.+)"]  = "need",
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant",
}
local function ParseRollChoice(msg)
	for i,v in pairs(ns.rollpairs) do
		local _, _, playername, itemname = string.find(msg, i)
		if playername and itemname and playername ~= "Everyone" then return playername, itemname, v end
	end
end

local function BeginFlash(frame)
    PlaySoundFile(WarningSound)
    frame:SetBackdropBorderColor(GroupLootFrameWarningBorderColor.r,GroupLootFrameWarningBorderColor.g,GroupLootFrameWarningBorderColor.b,1) --show the waring border
    CreatePulse(frame)
end

local in_soviet_russia = (GetLocale() == "ruRU")

local function CHAT_MSG_LOOT(msg)
	local playername, itemname, rolltype = ParseRollChoice(msg)
	if playername and itemname and rolltype == "need" then
		if in_soviet_russia then itemname, playername = playername, itemname end
        local index
        local FrameFound=false --indicate if the frame is found. if not, show warning text
        for index = 1, NUM_GROUP_LOOT_FRAMES do --find the frame which is associated with this item
            local rollid = _G["GroupLootFrame"..index].rollID
            if rollid and GetLootRollItemLink(rollid) == itemname and _G["GroupLootFrame"..index]:IsShown() then FrameFound = true end
            if rollid and GetLootRollItemLink(rollid) == itemname and _G["GroupLootFrame"..index]:IsShown() and not _G["GroupLootFrame"..index].WarningBorder:GetScript("OnUpdate") then --find the frame, ready to make a flash border
                BeginFlash(_G["GroupLootFrame"..index].WarningBorder)
            end
        end 
        if not FrameFound then
            ShowWarningText(playername,itemname)
        end
    end
end
----------------------------------------
function Razgriz_CreateFrame(strFrameType,strName,objParent)
	--[[First check the arguments]]--
	if (strName) then 
		if type(strName) ~= "string" then
			print("Call of |cffff0000Razgriz_CreateFrame|r failed! arg2 shall be string value.")
			return false , nil
		end
	end
	if (objParent) then
		if type(objParent) ~= "table" then
			print("Call of |cffff0000Razgriz_CreateFramee|r failed! arg3 shall be some frame.")
			return false , nil
		end
	else
		objParent = UIParent --If no parent frame specified, use UIParent instead
	end
	--[[Create the frame]]--
	local frame = CreateFrame(strFrameType,strName,objParent)
	frame:SetBackdrop(LootFrameBackdrop)
	frame:SetBackdropColor(FrameBackdropColor[1],FrameBackdropColor[2],FrameBackdropColor[3],FrameAlpha)
	frame:SetBackdropBorderColor(FrameBorderColor[1],FrameBorderColor[2],FrameBorderColor[3],BorderAlpha)
	
	return true, frame
	
end
----------------------------------------
function BeautyLootFrame_CreateBorderOverlay(frame)----------創建Frame邊框 Create an overlay border for frame needed
    if frame.OverlayBorder then return end
    frame.OverlayBorder = select(2,Razgriz_CreateFrame("Frame",nil,frame))
	frame.OverlayBorder:SetFrameStrata(frame:GetFrameStrata())
    frame.OverlayBorder:SetFrameLevel(max(frame:GetFrameLevel() - 1,0))
    frame.OverlayBorder:SetPoint("TOPLEFT",-3.5,3.5)
    frame.OverlayBorder:SetPoint("BOTTOMRIGHT",3.5,-3.5)
end
-----------------------------
function ReskinClose(f, a1, p, a2, x, y,size) -- reskin code from Aorura
	f:SetSize(size or 16, size or 16)

	if not a1 then
		f:SetPoint("TOPRIGHT", -4, -4)
	else
		f:ClearAllPoints()
		f:SetPoint(a1, p, a2, x, y)
	end

	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")
    f:SetBackdrop(LootFrameBackdrop)
	f:SetBackdropColor(FrameBackdropColor[1], FrameBackdropColor[2], FrameBackdropColor[3], a or FrameAlpha)
	f:SetBackdropBorderColor(FrameBorderColor[1], FrameBorderColor[2], FrameBorderColor[3], BorderAlpha)
	
	if not f.CloseButtonText then
		f.CloseButtonText = f:CreateFontString(nil, "OVERLAY")
		f.CloseButtonText:SetFont("Fonts\\ARIALN.TTF", 14, "THINOUTLINE")
		f.CloseButtonText:SetPoint("CENTER", 1, 1)
		f.CloseButtonText:SetJustifyH("CENTER")
		f.CloseButtonText:SetJustifyV("CENTER")
		f.CloseButtonText:SetText("x")

		f:HookScript("OnEnter", function(self) 
			self.CloseButtonText:SetTextColor(1, 0, 0)
		end)
		f:HookScript("OnLeave", function(self) 
			self.CloseButtonText:SetTextColor(1, 1, 1) 
		end)
	end
end

function BeautyLootFrame_UpdateButton(index) --用于更新物品材质边框的函数 functions to update the item quality border. Copied from BLZ UI....lol
    local numLootItems = LootFrame.numLootItems;
	--Logic to determine how many items to show per page
	local numLootToShow = LOOTFRAME_NUMBUTTONS;
	if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
		numLootToShow = numLootToShow - 1;
	end
    local slot = (numLootToShow * (LootFrame.page - 1)) + index
    local texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive, color
    color={r=1,g=1,b=1}
    if ( slot <= numLootItems ) then
        if ((LootSlotHasItem(slot) and index <= numLootToShow)) then
			texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot);
			color = ITEM_QUALITY_COLORS[quality];
        end
    end
    if isQuestItem then
       _G["LootButton"..index.."BorderOverlay"]:Show()
       _G["LootButton"..index.."BorderOverlay"]:SetVertexColor(1,1,0,1)
       _G["LootButton"..index.."Text"].m_objBorderFrame:SetBackdropBorderColor(1,1,0,1)
    else
       _G["LootButton"..index.."BorderOverlay"]:Show()
       _G["LootButton"..index.."BorderOverlay"]:SetVertexColor(color.r,color.g,color.b,1)
	   _G["LootButton"..index.."Text"].m_objBorderFrame:SetBackdropBorderColor(color.r,color.g,color.b,1)
    end
end
function BeautyLootFrame_UpdatePostion(self) --拾取框体的钩子函数，用于在拾取框体打开后设置它们的位置 function to hook the script of OnShow of Lootframe. Main functionality of this is to set the postion of frame
    if ( BeautyLootDB["TrackMouse"] ) then
		-- position loot window under mouse cursor
		local x, y = GetCursorPosition();
		x = x / self:GetEffectiveScale();
		y = y / self:GetEffectiveScale();

		local posX = x - 175;
		local posY = y + 25;
		
		if (self.numLootItems > 0) then
			posX = x - 40;
			posY = y + 55;
			posY = posY + 40;
		end

		if( posY < 350 ) then
			posY = 350;
		end

		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY);
		self:GetCenter();
		self:Raise();
	else
        local FrameName = self:GetName()
        if(BeautyLootDB[FrameName]) then
            self:ClearAllPoints()
            self:SetPoint("BOTTOMLEFT",UIParent,BeautyLootDB[FrameName].left,BeautyLootDB[FrameName].bottom)
        end
	end
    SaveFramePosition(self) --设置完成后要保存
end
--[[function GroupLootFrame_CreateMisButtonText(objButton,text)
	if not objButton.m_objText then
		if FontBindMisButton then
			objButton.m_objText = objButton:GetParent():CreateFontString(nil,"OVERLAY")
			objButton.m_objText:SetFont(FontBindMisButton,FontBindMisButtonSize,FontBindMisButtonFlag)
		else
			objButton.m_objText = objButton:GetParent():CreateFontString(nil,"OVERLAY","GameFontNormal")
		end
	end
	objButton.m_objText:SetAllPoints(objButton)
	objButton.m_objText:SetText(text)
	objButton:HookScript("OnEnter",function(self)
		if self:IsEnabled() then
			self.m_objText:SetTextColor(1,0,0)
		else
			self.m_objText:SetTextColor(.2,.2,.2)
		end
	end)
	objButton:HookScript("OnLeave",function(self)
		if self:IsEnabled() then
			self.m_objText:SetTextColor(1,1,1)
		else
			self.m_objText:SetTextColor(.2,.2,.2)
		end
	end)
end]]--
function GroupLootFrame_AfterShow(self) --队伍分配框体的钩子函数，用来隐藏一些没用的材质，设置背景和设置框体的位置 function to hook the script of OnShow of GroupLootFrames
    local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(self.rollID);
	--[[if bindOnPickUp then
		self.m_objBindingIndicator.m_objIndicator:SetText("|cFFFF0000BOP|r")
	else
		self.m_objBindingIndicator.m_objIndicator:SetText("|cFFFFFFFFBOE|r")
	end]]--
    if(ITEM_QUALITY_COLORS[quality]) then
        _G[self:GetName().."IconFrameBorderOverlay"]:SetVertexColor(ITEM_QUALITY_COLORS[quality].r,ITEM_QUALITY_COLORS[quality].g,ITEM_QUALITY_COLORS[quality].b)
    else
        _G[self:GetName().."IconFrameBorderOverlay"]:SetVertexColor(1,1,1)
    end
    --重设背景材质 Reset the backdrop of grouplootframes
    --self:SetBackdrop({})
    local FrameName = self:GetName()
    if(BeautyLootDB[FrameName]) then
        --读取位置 set the postion of current roll frame
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT","UIParent",BeautyLootDB[FrameName].left,BeautyLootDB[FrameName].bottom)
    end
    --[[_G[self:GetName()].Timer.Text:SetText("")
	_G[self:GetName().."NeedButton"]:SetAlpha(0)
	if _G[self:GetName().."NeedButton"]:IsEnabled() then
		_G[self:GetName().."NeedButton"].m_objText:SetTextColor(1,1,1)
	else
		_G[self:GetName().."NeedButton"].m_objText:SetTextColor(.2,.2,.2)
	end
	_G[self:GetName().."GreedButton"]:SetAlpha(0)
	if _G[self:GetName().."GreedButton"]:IsEnabled() then
		_G[self:GetName().."GreedButton"].m_objText:SetTextColor(1,1,1)
	else
		_G[self:GetName().."GreedButton"].m_objText:SetTextColor(.2,.2,.2)
	end
	_G[self:GetName().."DisenchantButton"]:SetAlpha(0)
	if _G[self:GetName().."DisenchantButton"]:IsEnabled() then
		_G[self:GetName().."DisenchantButton"].m_objText:SetTextColor(1,1,1)
	else
		_G[self:GetName().."DisenchantButton"].m_objText:SetTextColor(.2,.2,.2)
	end]]--
	
    self.WarningBorder:SetAlpha(0)
end

function GroupLootFrame_AfterHide(self)
    if(self.WarningBorder) then
        self.WarningBorder:SetScript("OnUpdate",nil) --关闭闪烁边框
    end
end
function LootFrameEnableDrag(enable)
    if enable then --允许拖拽 Drag action enabled
        --允许对标题的拖拽反映到拾取界面上  the drag action on the title frame can move the Loot frame
        LootFrame.TitleFrame:EnableMouse(true)  
        LootFrame.TitleFrame:RegisterForDrag("LeftButton")
        LootFrame.TitleFrame:SetScript("OnDragStart",LootFrame_StartMoving)
        LootFrame.TitleFrame:SetScript("OnDragStop",LootFrame_StopMoving) 
        
        --对头像的拖拽可以移动拾取界面 the drag action on the portrait frame can move the Loot frame
        LootFrame.LootSourcePortraitFrame:EnableMouse(true)  
        LootFrame.LootSourcePortraitFrame:RegisterForDrag("LeftButton")
        LootFrame.LootSourcePortraitFrame:SetScript("OnDragStart",LootFrame_StartMoving)
        LootFrame.LootSourcePortraitFrame:SetScript("OnDragStop",LootFrame_StopMoving)
        
		--允許拖拽底部面板 allow drat bottom panel
		LootFrame.BackgroundPanel:EnableMouse(true)
		LootFrame.BackgroundPanel:RegisterForDrag("LeftButton")
        LootFrame.BackgroundPanel:SetScript("OnDragStart",LootFrame_StartMoving)
        LootFrame.BackgroundPanel:SetScript("OnDragStop",LootFrame_StopMoving)
        --自身允许拖拽 Enable the drag action of lootframe itself
        LootFrame:EnableMouse(true) 
        --LootFrame:RegisterForDrag("LeftButton")
        --LootFrame:SetScript("OnDragStart",LootFrame_StartMoving)
        --LootFrame:SetScript("OnDragStop",LootFrame_StopMoving)
        
        --LootFrame:SetScript("OnMouseDown",function() end)
        --LootFrame:SetScript("OnMouseUp",function() end)
        
        ConfigFrameLoot:EnableMouse(true)  
        ConfigFrameLoot:RegisterForDrag("LeftButton")
        ConfigFrameLoot:SetScript("OnDragStart",LootFrame_StartMoving)
        ConfigFrameLoot:SetScript("OnDragStop",LootFrame_StopMoving)
    else --不允许拖拽 Drag action disabled
        LootFrame.TitleFrame:EnableMouse(false)
        LootFrame.LootSourcePortraitFrame:EnableMouse(false)
        LootFrame:EnableMouse(false)
		LootFrame.BackgroundPanel:EnableMouse(false)
        ConfigFrameLoot:EnableMouse(false)

    end
end

function SaveFramePosition(frame)
    local FrameName=frame:GetName()
    local left,bottom=frame:GetRect()
    BeautyLootDB[FrameName] = {
    left = left,
    bottom = bottom
    }    
end
-------------调整拾取界面 functions to modify the loot frame-----------------
LootFrame_StartMoving = function()
    LootFrame:StartMoving()
end
LootFrame_StopMoving = function()
    LootFrame:StopMovingOrSizing()
    SaveFramePosition(LootFrame)
end 
function GroupLootFrame_StartMoving(self)
    self:StartMoving()
end
function GroupLootFrame_StopMoving(self)
    self:StopMovingOrSizing()
    SaveFramePosition(self)
end
function ConfigGroupLootFrame_StartMoving(self)
    --self:StartMoving()
    _G["GroupLootFrame"..self:GetID()]:StartMoving()
    --ChatFrame1:AddMessage("GroupLootFrame"..self:GetID())
end
function ConfigGroupLootFrame_StopMoving(self)
    --self:StopMovingOrSizing()
    _G["GroupLootFrame"..self:GetID()]:StopMovingOrSizing()
    SaveFramePosition(_G["GroupLootFrame"..self:GetID()])
    --ChatFrame1:AddMessage("GroupLootFrame"..self:GetID())
end
function SavePostionWhenHide(frame)
    SaveFramePosition(frame)
end
---------------------
--[[根據拾取界面實際出現的按鈕數量來調整框體的大小.並重新設定各個拾取按鈕的位置 Reset loot button position according to actual count of loot items per page]]--
local objButtonArray = {}
objButtonArray.m_nCount = 0
local function ClearButtonArray()
	local nIndex
	for nIndex = 1, 4 do
		objButtonArray[nIndex] = nil
	end
	objButtonArray.m_nCount = 0
end
function LootFrame_UpdateAnchorAndSize()
	ClearButtonArray()
	local nIndex
	-- first check visibility of each loot item button
	for nIndex = 1, 4 do
		if _G["LootButton"..nIndex]:IsShown() then -- button is shown
			objButtonArray.m_nCount = objButtonArray.m_nCount + 1
			objButtonArray[objButtonArray.m_nCount] = _G["LootButton"..nIndex] --add this button into array
		end
	end
	for nIndex = 1, objButtonArray.m_nCount do
		objButtonArray[nIndex]:ClearAllPoints()
		if nIndex == 1 then
			objButtonArray[nIndex]:SetPoint("TOPLEFT",-3,3)
		else
			objButtonArray[nIndex]:SetPoint("TOP",objButtonArray[nIndex - 1],"BOTTOM",0,5)
		end
	end
end

local function ModifyLootFrame()
	
    local Regions = { LootFrame:GetRegions() }
	
	for _, Texture in pairs(Regions) do
		Texture:Hide()
		Texture.Show = function(self) end
	end
	LootFrameInset:Hide()
    --设置拾取界面的背景 Set the Backdrop of LootFrame
    LootFrame:SetBackdrop({})
    ConfigFrameLoot:SetBackdrop(LootFrameBackdrop)
    ConfigFrameLoot:SetBackdropColor(LootFrameBackdropColor.r,LootFrameBackdropColor.g,LootFrameBackdropColor.b,LootFrameBackdropColor.a)
    ConfigFrameLoot:SetBackdropBorderColor(LootFrameBackdropColor.r,LootFrameBackdropColor.g,LootFrameBackdropColor.b,1 or LootFrameBackdropColor.a)
	
    ----重新设置拾取界面的长宽 Resize the Loot frame
    LootFrame:SetWidth(180)
	LootFrame:SetHeight(190)
    LootFrame:SetHitRectInsets(0,0,0,0)
   
    --设置战利品标题 Set the loot tirle
	local TitleHight = 38
    if not LootFrame.TitleFrame then
        LootFrame.TitleFrame=CreateFrame("Frame",nil,LootFrame)
        LootFrame.TitleFrame:SetPoint("BOTTOMLEFT",LootFrame,"TOPLEFT",0,7)
		LootFrame.TitleFrame:SetPoint("BOTTOMRIGHT",LootFrame,"TOPRIGHT",0,7)
        LootFrame.TitleFrame:SetHeight(TitleHight)
		BeautyLootFrame_CreateBorderOverlay(LootFrame.TitleFrame)
        if not FontLootFrameTitle then
            LootFrame.TitleFrame:CreateFontString("LootTitle","ARTWORK","GameFontNormal")
        else
            LootFrame.TitleFrame:CreateFontString("LootTitle","ARTWORK")
            _G["LootTitle"]:SetFont(FontLootFrameTitle,FontLootFrameTitleSize,FontLootFrameTitleFlag)
        end
        LootTitle:SetPoint("TOPLEFT",5,0)
        LootTitle:SetPoint("BOTTOMRIGHT",-5,0)
        LootTitle:SetJustifyH("CENTER")
        LootTitle:SetText(TitleText)
        LootTitle:SetTextColor(FontLootFrameTitleColor.r,FontLootFrameTitleColor.g,FontLootFrameTitleColor.b)    
    end
	
	--[[--设置拾取框体的背景面板 set the loot frame background panel]]--
    
	if not LootFrame.BackgroundPanel then
		LootFrame.BackgroundPanel = CreateFrame("Frame",nil,LootFrame)
		BeautyLootFrame_CreateBorderOverlay(LootFrame.BackgroundPanel)
		LootFrame.BackgroundPanel:SetAllPoints()
		LootFrame.BackgroundPanel:SetFrameLevel(LootFrame:GetFrameLevel())
		LootFrame.BackgroundPanel:SetFrameStrata(LootFrame:GetFrameStrata())
	end
	
    --设置目标的头像 Set the target portrait
    if not LootFrame.LootSourcePortraitFrame then
        LootFrame.LootSourcePortraitFrame=CreateFrame("PlayerModel",nil,LootFrame)
        LootFrame.LootSourcePortraitFrame:SetPoint("TOPRIGHT",LootFrame.TitleFrame,"TOPLEFT",-11,0)
		LootFrame.LootSourcePortraitFrame:SetHeight(36)
        LootFrame.LootSourcePortraitFrame:SetWidth(36)
        BeautyLootFrame_CreateBorderOverlay(LootFrame.LootSourcePortraitFrame)
        LootFrame.LootSourcePortraitFrame:SetBackdrop(LootFrameBackdrop)
        LootFrame.LootSourcePortraitFrame:SetBackdropColor(LootFrameBackdropColor.r,LootFrameBackdropColor.g,LootFrameBackdropColor.b,LootFrameBackdropColor.a)
        LootFrame.LootSourcePortraitFrame:SetBackdropBorderColor(LootFrameBackdropColor.r,LootFrameBackdropColor.g,LootFrameBackdropColor.b,1 or LootFrameBackdropColor.a)
        LootFrame.LootSourcePortraitFrame = CreateFrame("PlayerModel","LootTargetPortrait",LootFrame.LootSourcePortraitFrame)
		LootTargetPortrait:SetFrameStrata(LootFrame.LootSourcePortraitFrame:GetFrameStrata())
        LootTargetPortrait:SetFrameLevel(LootFrame.LootSourcePortraitFrame:GetFrameLevel() + 1)
        LootTargetPortrait:SetPoint("TOPLEFT",2,-2);
        LootTargetPortrait:SetPoint("BOTTOMRIGHT",-2,2);
    end
	local LootFrameItemSize = LootFrame:GetHeight() / 4 + 5;
    --设置拾取的按钮组 Set the loot buttons
    for i = 1, 4 do --设置物品拾取按钮的材质和外框。 Set the texture of each loot button
        _G["LootButton"..i]:SetHeight(LootFrameItemSize)
        _G["LootButton"..i]:SetWidth(LootFrameItemSize)
        _G["LootButton"..i.."IconTexture"]:SetTexCoord(.1,.9,.1,.9)
        _G["LootButton"..i.."IconTexture"]:SetPoint("TOPLEFT",_G["LootButton"..i],5,-5)
        _G["LootButton"..i.."IconTexture"]:SetPoint("BOTTOMRIGHT",_G["LootButton"..i],-5,5)
        _G["LootButton"..i ]:SetNormalTexture(LootButtonNormal)
        _G["LootButton"..i ]:GetNormalTexture():SetPoint("TOPLEFT",_G["LootButton"..i])
        _G["LootButton"..i ]:GetNormalTexture():SetPoint("BOTTOMRIGHT",_G["LootButton"..i])
        _G["LootButton"..i ]:SetHighlightTexture(LootButtonHighlight)
        _G["LootButton"..i ]:GetHighlightTexture():SetVertexColor(LootFrameItemHighlightColor.r,LootFrameItemHighlightColor.g,LootFrameItemHighlightColor.b,1)
		_G["LootButton"..i ]:GetHighlightTexture():ClearAllPoints()
		_G["LootButton"..i ]:GetHighlightTexture():SetPoint("TOPLEFT",_G["LootButton"..i],-1,1)
		_G["LootButton"..i ]:GetHighlightTexture():SetPoint("BOTTOMRIGHT",_G["LootButton"..i],1,-1)
        _G["LootButton"..i ]:SetPushedTexture(LootButtonNormal)
        _G["LootButton"..i ]:SetDisabledTexture(LootButtonNormal)
        _G["LootButton"..i.."NameFrame"]:SetTexture(nil)
        _G["LootButton"..i.."Text"]:SetPoint("LEFT",_G["LootButton"..i],"RIGHT",4,0)
        _G["LootButton"..i.."Text"]:SetPoint("RIGHT",LootFrame,0,0)
        _G["LootButton"..i.."Text"]:SetPoint("TOP",_G["LootButton"..i],0,-2)
		_G["LootButton"..i.."Text"]:SetPoint("BOTTOM",_G["LootButton"..i],0,1.5)
		if not _G["LootButton"..i.."Text"].m_objBorderFrame then
			_G["LootButton"..i.."Text"].m_objBorderFrame = select(2,Razgriz_CreateFrame("Frame",nil,_G["LootButton"..i]))
			_G["LootButton"..i.."Text"].m_objBorderFrame:SetBackdropColor(0,0,0,0);
			_G["LootButton"..i.."Text"].m_objBorderFrame:SetFrameStrata(_G["LootButton"..i]:GetFrameStrata())
			_G["LootButton"..i.."Text"].m_objBorderFrame:SetFrameLevel(_G["LootButton"..i]:GetFrameLevel())
			_G["LootButton"..i.."Text"].m_objBorderFrame:SetPoint("TOPLEFT",_G["LootButton"..i.."Text"],-6,-1)
			_G["LootButton"..i.."Text"].m_objBorderFrame:SetPoint("BOTTOMRIGHT",_G["LootButton"..i.."Text"],0,1.5)
			_G["LootButton"..i.."Text"].m_objBorderFrame.m_objHighlight = _G["LootButton"..i.."Text"].m_objBorderFrame:CreateTexture(nil,"ARTWORK")
			_G["LootButton"..i.."Text"].m_objBorderFrame.m_objHighlight:SetTexture([[Interface\buttons\white8x8]])
			_G["LootButton"..i.."Text"].m_objBorderFrame.m_objHighlight:SetPoint("TOPLEFT",3.5,-3.5)
			_G["LootButton"..i.."Text"].m_objBorderFrame.m_objHighlight:SetPoint("BOTTOMRIGHT",-3.5,3.5)
			_G["LootButton"..i.."Text"].m_objBorderFrame.m_objHighlight:SetVertexColor(LootFrameItemHighlightColor.r,LootFrameItemHighlightColor.g,LootFrameItemHighlightColor.b)
			_G["LootButton"..i.."Text"].m_objBorderFrame.m_objHighlight:Hide()
			_G["LootButton"..i]:HookScript("OnEnter",function(self)
				_G[self:GetName().."Text"].m_objBorderFrame.m_objHighlight:Show()
			end)
			_G["LootButton"..i]:HookScript("OnLeave",function(self)
				_G[self:GetName().."Text"].m_objBorderFrame.m_objHighlight:Hide()
			end)
		end
		if not _G["LootButton"..i].m_objGlow then
			_G["LootButton"..i].m_objGlow = _G["LootButton"..i]:CreateTexture(nil,"OVERLAY")
			_G["LootButton"..i].m_objGlow:SetTexture(LootButtonHighlight)
			_G["LootButton"..i].m_objGlow:SetAllPoints(_G["LootButton"..i]:GetHighlightTexture())
		end
        if FontItemName then
            _G["LootButton"..i.."Text"]:SetFont(FontItemName,FontItemNameSize,FontItemNameFlag)
        end
		if not _G["LootButton"..i.."BorderOverlay"] then
			_G["LootButton"..i]:CreateTexture("LootButton"..i.."BorderOverlay","OVERLAY")
			_G["LootButton"..i.."BorderOverlay"]:SetTexture(LootButtonBorderOverlay)
			_G["LootButton"..i.."BorderOverlay"]:SetAllPoints(_G["LootButton"..i])
		end
		_G["LootButton"..i]:HookScript("OnShow",LootFrame_UpdateAnchorAndSize)
		_G["LootButton"..i]:HookScript("OnHide",LootFrame_UpdateAnchorAndSize)
    end
	LootFrame_UpdateAnchorAndSize()
    
    --设置翻页按钮 set the page down and up button
	LootFrameUpButton:ClearAllPoints()
    LootFrameUpButton:SetPoint("CENTER",LootFrame,"BOTTOM", 50, -2.5)
	LootFrameUpButton:SetFrameLevel(LootFrame.BackgroundPanel:GetFrameLevel() + 1)
    LootFrameUpButton:SetWidth(32)
    LootFrameUpButton:SetHeight(32)
    LootFrameUpButton:SetNormalTexture(LootPrev)
	LootFrameUpButton:GetNormalTexture():SetVertexColor(LootFrameItemHighlightColor.r, LootFrameItemHighlightColor.g, LootFrameItemHighlightColor.b, 1)
    LootFrameUpButton:GetNormalTexture():SetPoint("TOPLEFT",LootFrameUpButton)
    LootFrameUpButton:GetNormalTexture():SetPoint("BOTTOMRIGHT",LootFrameUpButton)
    LootFrameUpButton:SetHighlightTexture(LootPrev)
    LootFrameUpButton:SetPushedTexture(LootPrev)
    
	LootFrameDownButton:ClearAllPoints()
    LootFrameDownButton:SetPoint("CENTER",LootFrame,"BOTTOM", 78, -1)
	LootFrameDownButton:SetFrameLevel(LootFrame.BackgroundPanel:GetFrameLevel() + 1)
    LootFrameDownButton:SetWidth(32)
    LootFrameDownButton:SetHeight(32)
    LootFrameDownButton:SetNormalTexture(LootNext)
	LootFrameDownButton:GetNormalTexture():SetVertexColor(LootFrameItemHighlightColor.r, LootFrameItemHighlightColor.g, LootFrameItemHighlightColor.b, 1)
    LootFrameDownButton:GetNormalTexture():SetPoint("TOPLEFT",LootFrameDownButton)
    LootFrameDownButton:GetNormalTexture():SetPoint("BOTTOMRIGHT",LootFrameDownButton)
    LootFrameDownButton:SetHighlightTexture(LootNext)
    LootFrameDownButton:SetPushedTexture(LootNext)
    
	
    --为框体出现添加动画 Add animation effect to loot frame
	if not LootFrameAnimation then
		LootFrame:CreateAnimationGroup("LootFrameAnimation")
		LootFrameAnimation:CreateAnimation("Alpha","LootFrameAnimationAlpha")
		--LootFrameAnimationAlpha:SetChange(1)
		LootFrameAnimationAlpha:SetDuration(.25)
		LootFrameAnimation:SetScript("OnFinished",function() 
		LootFrame:SetAlpha(1.0)
		end)
		LootFrameAnimation:SetScript("OnStop",function() 
		LootFrame:SetAlpha(1.0)
		end)
	end
    --设置关闭按钮 customize the loot close button
    ReskinClose(_G["LootFrameCloseButton"],"CENTER",LootFrame.TitleFrame,"TOPRIGHT",0,0,20)
	_G["LootFrameCloseButton"]:SetFrameLevel(LootFrame.TitleFrame:GetFrameLevel() + 1)
    LootFrameEnableDrag(not BeautyLootDB["LockLoot"])
    LootFrame:HookScript("OnShow",BeautyLootFrame_UpdatePostion)
    LootFrame:HookScript("OnHide",SavePostionWhenHide) --当隐藏时候也保存 Save when hide. Frame would close exceptionally, such as entering combat
    hooksecurefunc("LootFrame_Show",BeautyLootFrame_UpdatePostion)
    hooksecurefunc("LootFrame_UpdateButton",BeautyLootFrame_UpdateButton)
end
--------------调整团队拾取界面 functions to modify the group loot frames-----------------
local function ModifyGroupLootFrames()
    local index
    ----调整每个框体 For each frame 
    for index = 1,NUM_GROUP_LOOT_FRAMES do
        -----调整高度和宽度，以及挂钩显示事件   Set the width and the Height. Hook the onshow event
        _G["GroupLootFrame"..index]:SetWidth(260)
        _G["GroupLootFrame"..index]:SetHeight(RollFrameSize) -- 15 = title height 8 = timer height
        _G["GroupLootFrame"..index]:HookScript("OnShow",GroupLootFrame_AfterShow)
        _G["GroupLootFrame"..index]:HookScript("OnHide",GroupLootFrame_AfterHide)
		
        _G["ConfigFrameGroupLoot"..index]:SetID(index)
        BeautyLootFrame_CreateBorderOverlay(_G["ConfigFrameGroupLoot"..index])
		BeautyLootFrame_CreateBorderOverlay(_G["GroupLootFrame"..index])
		
		-----隐藏背景与边框 hide the frame's background and border
		local RegionsToHide = {_G["GroupLootFrame"..index].Background, _G["GroupLootFrame"..index].Border, _G["GroupLootFrame"..index].IconFrame.Border}
		for i = 1, #RegionsToHide do
			RegionsToHide[i]:Hide()
			RegionsToHide[i].Show = function(self) end
		end
        
        
        -----调整拾取物品的图标  modify the item button and texture
        _G["GroupLootFrame"..index].IconFrame.Icon:SetTexCoord(.1,.9,.1,.9)
		_G["GroupLootFrame"..index].IconFrame.Icon:ClearAllPoints()
		_G["GroupLootFrame"..index].IconFrame.Icon:SetAllPoints()
		_G["GroupLootFrame"..index].IconFrame:SetSize(RollFrameItemSize, RollFrameItemSize)
		
		-----增加物品质量的边框 add texture border to show the quanlity of the item
		if not _G["GroupLootFrame"..index.."IconFrameBorderOverlay"] then
			_G["GroupLootFrame"..index].IconFrame:CreateTexture("GroupLootFrame"..index.."IconFrameBorderOverlay","OVERLAY")
			_G["GroupLootFrame"..index.."IconFrameBorderOverlay"]:SetTexture(LootButtonBorderOverlay)
			_G["GroupLootFrame"..index.."IconFrameBorderOverlay"]:SetPoint("TOPLEFT", _G["GroupLootFrame"..index].IconFrame.Icon, -3,3)
			_G["GroupLootFrame"..index.."IconFrameBorderOverlay"]:SetPoint("BOTTOMRIGHT", _G["GroupLootFrame"..index].IconFrame.Icon, 3,-3)
		end
        
		-----修改掉落图标的位置， modify the loot icon frame position
		_G["GroupLootFrame"..index].IconFrame:ClearAllPoints()
		_G["GroupLootFrame"..index].IconFrame:SetPoint("CENTER",_G["GroupLootFrame"..index].Timer:GetStatusBarTexture(),"RIGHT",0,0)
		
        -----调整物品名称的位置 set the position of item name string
        _G["GroupLootFrame"..index].Name:SetPoint("TOPLEFT",_G["GroupLootFrame"..index])
		_G["GroupLootFrame"..index].Name:SetPoint("BOTTOM",_G["GroupLootFrame"..index])
		_G["GroupLootFrame"..index].Name:SetPoint("RIGHT",_G["GroupLootFrame"..index],"CENTER")
		
        if FontGroupLootItemName then
            _G["GroupLootFrame"..index].Name:SetFont(FontGroupLootItemName,FontGroupLootItemNameSize,FontGroupLootItemNameFlag)
        end
		 -----添加警告框体 Add warning border
        if not _G["GroupLootFrame"..index].WarningBorder then
            _G["GroupLootFrame"..index].WarningBorder = CreateFrame("Frame","GroupLootFrame"..index.."WarningBorder",_G["GroupLootFrame"..index])
            _G["GroupLootFrame"..index].WarningBorder:SetAllPoints()
            _G["GroupLootFrame"..index].WarningBorder:SetBackdrop(GroupLootFrameWarningBorder)
            _G["GroupLootFrame"..index].WarningBorder:SetBackdropBorderColor(GroupLootFrameWarningBorderColor.r,GroupLootFrameWarningBorderColor.g,GroupLootFrameWarningBorderColor.b,1)
            _G["GroupLootFrame"..index].WarningBorder:SetAlpha(1)
            _G["GroupLootFrame"..index].WarningBorder:SetFrameLevel(_G["GroupLootFrame"..index]:GetFrameLevel()+1)
        end
		
        -----调整Roll点时间 modify the roll timer bar
        _G["GroupLootFrame"..index].Timer:ClearAllPoints()
		_G["GroupLootFrame"..index].Timer:SetPoint("LEFT")
		_G["GroupLootFrame"..index].Timer:SetPoint("Right")
		_G["GroupLootFrame"..index].Timer:SetPoint("TOP",_G["GroupLootFrame"..index],"BOTTOM",0,-7)
		_G["GroupLootFrame"..index].Timer:SetHeight(_G["GroupLootFrame"..index]:GetHeight() / 3.3)
		
        local Color = RAID_CLASS_COLORS[select(2,UnitClass("player"))]
        _G["GroupLootFrame"..index].Timer:SetStatusBarColor(Color.r,Color.g,Color.b)
        _G["GroupLootFrame"..index].Timer:SetStatusBarTexture(TimerBarTexture)
        select(1,_G["GroupLootFrame"..index].Timer:GetRegions()):SetTexture("");
		if not  _G["GroupLootFrame"..index].Timer.m_objBorderFrame then
			_G["GroupLootFrame"..index].Timer.m_objBorderFrame = CreateFrame("Frame",nil,_G["GroupLootFrame"..index].Timer)
			_G["GroupLootFrame"..index].Timer.m_objBorderFrame:SetFrameLevel(_G["GroupLootFrame"..index]:GetFrameLevel())
			_G["GroupLootFrame"..index].Timer.m_objBorderFrame:SetAllPoints(_G["GroupLootFrame"..index].Timer)
			BeautyLootFrame_CreateBorderOverlay(_G["GroupLootFrame"..index].Timer.m_objBorderFrame)
		end
		if not _G["GroupLootFrame"..index].Timer.Text then
			if not FontRollTimer then
				_G["GroupLootFrame"..index].Timer.Text = _G["GroupLootFrame"..index].Timer:CreateFontString("GroupLootFrame"..index.."TimerText","OVERLAY","GameFontNormal")
			else
				_G["GroupLootFrame"..index].Timer.Text = _G["GroupLootFrame"..index].Timer:CreateFontString("GroupLootFrame"..index.."TimerText","OVERLAY")
				_G["GroupLootFrame"..index].Timer.Text:SetFont(FontRollTimer,FontRollTimerSize,FontRollTimerFlag)
			end
		end
		_G["GroupLootFrame"..index].Timer.Text:SetText("1123123123")
        _G["GroupLootFrame"..index].Timer.Text:SetPoint("TOPLEFT",_G["GroupLootFrame"..index].Timer,"TOPLEFT",5,0)
        _G["GroupLootFrame"..index].Timer.Text:SetPoint("BOTTOMRIGHT",_G["GroupLootFrame"..index].Timer,"BOTTOMRIGHT",-5,0)
        _G["GroupLootFrame"..index].Timer.Text:SetJustifyH("RIGHT")
		
        _G["GroupLootFrame"..index].Timer:HookScript("OnUpdate",function(self, elapsed)
            local left = GetLootRollTimeLeft(self:GetParent().rollID);
            local min, max = self:GetMinMaxValues();
            if ( (left < min) or (left > max) ) then
                left = min;
            end
            self.Text:SetText(string.format("%02d:%02d",left/60000,(left/1000)%60))
        end)
		
		----物品綁定指示器 indicator text to show boe or bop
		--[[if not _G["GroupLootFrame"..index].m_objBindingIndicator then
			_G["GroupLootFrame"..index].m_objBindingIndicator = CreateFrame("Frame",nil,_G["GroupLootFrame"..index])
			if FontBindIndicator then
				_G["GroupLootFrame"..index].m_objBindingIndicator.m_objIndicator = _G["GroupLootFrame"..index].m_objBindingIndicator:CreateFontString(nil,"OVERLAY")
				_G["GroupLootFrame"..index].m_objBindingIndicator.m_objIndicator:SetFont(FontBindIndicator,FontBindIndicatorSize,FontBindIndicatorFlag)
			else
				_G["GroupLootFrame"..index].m_objBindingIndicator.m_objIndicator = _G["GroupLootFrame"..index].m_objBindingIndicator:CreateFontString(nil,"OVERLAY","GameFontNormal")
			end
			_G["GroupLootFrame"..index].m_objBindingIndicator.m_objIndicator:SetAllPoints()
			_G["GroupLootFrame"..index].m_objBindingIndicator:SetPoint("TOP")
			_G["GroupLootFrame"..index].m_objBindingIndicator:SetPoint("LEFT",_G["GroupLootFrame"..index].IconFrame,6,0)
			_G["GroupLootFrame"..index].m_objBindingIndicator:SetPoint("BOTTOM",_G["GroupLootFrame"..index].IconFrame,"TOP",0,1)
			_G["GroupLootFrame"..index].m_objBindingIndicator:SetPoint("RIGHT",_G["GroupLootFrame"..index].Name,"LEFT",-8,0)
			BeautyLootFrame_CreateBorderOverlay(_G["GroupLootFrame"..index].m_objBindingIndicator)
		end
		if not _G["GroupLootFrame"..index].m_objMiscButtonContainer then
			_G["GroupLootFrame"..index].m_objMiscButtonContainer = CreateFrame("Frame",nil,_G["GroupLootFrame"..index])
		end
		_G["GroupLootFrame"..index].m_objMiscButtonContainer:SetPoint("TOPLEFT",_G["GroupLootFrame"..index].m_objBindingIndicator,"TOPRIGHT",7,0)
		_G["GroupLootFrame"..index].m_objMiscButtonContainer:SetPoint("BOTTOMLEFT",_G["GroupLootFrame"..index].m_objBindingIndicator,"BOTTOMRIGHT",7,0)
		_G["GroupLootFrame"..index].m_objMiscButtonContainer:SetPoint("RIGHT",_G["GroupLootFrame"..index.."PassButton"],"LEFT",-7,0)
		_G["GroupLootFrame"..index].m_objMiscButtonContainer:SetFrameLevel(_G["GroupLootFrame"..index]:GetFrameLevel())
		BeautyLootFrame_CreateBorderOverlay(_G["GroupLootFrame"..index].m_objMiscButtonContainer)]]--
		
        ----设置需求，贪婪，分解和关闭按钮的位置 set the position of need, greed,Disenchant, and close buttons
        _G["GroupLootFrame"..index].NeedButton:ClearAllPoints()
		_G["GroupLootFrame"..index].GreedButton:ClearAllPoints()
		--_G["GroupLootFrame"..index].DisenchantButton:ClearAllPoints()
		_G["GroupLootFrame"..index].PassButton:ClearAllPoints();
        _G["GroupLootFrame"..index].NeedButton:SetPoint("RIGHT",_G["GroupLootFrame"..index].GreedButton,"LEFT",-5,0)
		_G["GroupLootFrame"..index].NeedButton:SetSize(20,20)
		--GroupLootFrame_CreateMisButtonText(_G["GroupLootFrame"..index].NeedButton,"N")
		
        
        _G["GroupLootFrame"..index].GreedButton:SetPoint("RIGHT",_G["GroupLootFrame"..index].PassButton,"LEFT",-5,0)
		_G["GroupLootFrame"..index].GreedButton:SetSize(20,20)
		--GroupLootFrame_CreateMisButtonText(_G["GroupLootFrame"..index.."GreedButton"],"G")
        
        --_G["GroupLootFrame"..index].DisenchantButton:SetPoint("RIGHT",_G["GroupLootFrame"..index].PassButton,"LEFT",-5,0)
		--_G["GroupLootFrame"..index].DisenchantButton:SetSize(20,20)
		--GroupLootFrame_CreateMisButtonText(_G["GroupLootFrame"..index.."DisenchantButton"],"D")
        
        _G["GroupLootFrame"..index].PassButton:SetPoint("RIGHT",_G["GroupLootFrame"..index],"RIGHT",-5,0)
		_G["GroupLootFrame"..index].PassButton:SetSize(20,20)
        ----设置框架可以被移动 make the frame movable
        _G["GroupLootFrame"..index]:EnableMouse(not BeautyLootDB["LockRoll"])
        _G["GroupLootFrame"..index]:SetMovable(true)
        _G["GroupLootFrame"..index]:RegisterForDrag("LeftButton")
        _G["GroupLootFrame"..index]:SetScript("OnDragStart",GroupLootFrame_StartMoving)
        _G["GroupLootFrame"..index]:SetScript("OnDragStop",GroupLootFrame_StopMoving) 
        
        _G["ConfigFrameGroupLoot"..index]:EnableMouse(not BeautyLootDB["LockRoll"])
        _G["ConfigFrameGroupLoot"..index]:SetMovable(true)
        _G["ConfigFrameGroupLoot"..index]:RegisterForDrag("LeftButton")
        _G["ConfigFrameGroupLoot"..index]:SetScript("OnDragStart",ConfigGroupLootFrame_StartMoving)
        _G["ConfigFrameGroupLoot"..index]:SetScript("OnDragStop",ConfigGroupLootFrame_StopMoving)
    end
end
local function BeautyLoot_Option(msg, editbox)
    if(string.lower(msg) == "lockroll") then 
        if(BeautyLootDB["LockRoll"]) then --解锁GroupLootFrames     Unlock the GroupLootFrames
            BeautyLootDB["LockRoll"] = false
            DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Roll frames: |cffff7fc0Unlocked") 
        else
            BeautyLootDB["LockRoll"] = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Roll frames: |cffff7fc0Locked")
        end
        local index
        for index=1,NUM_GROUP_LOOT_FRAMES do
            _G["GroupLootFrame"..index]:EnableMouse(not BeautyLootDB["LockRoll"])
            _G["ConfigFrameGroupLoot"..index]:EnableMouse(not BeautyLootDB["LockRoll"])
        end
        return;
    end
    if(string.lower(msg) == "lockloot") then 
        if(BeautyLootDB["LockLoot"]) then --解锁 LootFrame   Unlock the LootFrame
            BeautyLootDB["LockLoot"] = false
            DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Loot frame: |cffff7fc0Unlocked")
            LootFrameEnableDrag(true)
        else
            BeautyLootDB["LockLoot"] = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Loot frame: |cffff7fc0Locked")
            LootFrameEnableDrag(false)
        end
        return;
    end
    if(string.lower(msg) == "trackmouse") then 
        if(BeautyLootDB["TrackMouse"]) then --禁止鼠标跟踪    Disable mouse tracking
            BeautyLootDB["TrackMouse"] = false
            DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Loot frame mouse tracking: |cffff7fc0Disabled")
        else
            BeautyLootDB["TrackMouse"] = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Loot frame mouse tracking: |cffff7fc0Enabled")
        end
        return;
    end
    if(string.lower(msg) == "showcurrent") then --显示当前的设定
        local RollLockStatus
        if(BeautyLootDB["LockRoll"]) then 
            RollLockStatus = "Locked"
        else
            RollLockStatus = "UnLocked"
        end
        
        local LootLockStatus
        if(BeautyLootDB["LockLoot"]) then 
            LootLockStatus = "Locked"
        else
            LootLockStatus = "UnLocked"
        end
        
        local TrackMouseStatus
        if(BeautyLootDB["TrackMouse"]) then 
            TrackMouseStatus = "Enable"
        else
            TrackMouseStatus = "Disable"
        end
        
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff".."--------------------------------------------")
        DEFAULT_CHAT_FRAME:AddMessage("|cff99d9ea".."BeautyLoot Current Settings:")
        DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Roll frames:|cff7092be"..RollLockStatus)
        DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Loot frame:|cff7092be"..LootLockStatus)
        DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Mouse tracking:|cff7092be"..TrackMouseStatus)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff".."--------------------------------------------")
        return;
    end
    if (string.lower(msg) == "config") then
        if(ConfigFrameLoot:IsShown()) then
            ConfigFrameLoot:Hide()
			for i = 1, NUM_GROUP_LOOT_FRAMES do
				_G["ConfigFrameGroupLoot"..i]:Hide()
			end
        else
            LoadPositions() --先从数据库中读出位置，使得配置窗口可以真实的反映窗口位置
            --Read position parameters from DB first. This make configuration frames could really reflect the postion of real frames
            ConfigFrameLoot:Show()
            for i = 1, NUM_GROUP_LOOT_FRAMES do
				_G["ConfigFrameGroupLoot"..i]:Show()
			end
        end
        return;
    end
    if (string.lower(msg) == "reset") then
        InitSettings()
        LoadPositions()
        DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Configuration is resetted")
        return
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff".."--------------------------------------------")
    DEFAULT_CHAT_FRAME:AddMessage("|cff99d9ea".."BeautyLoot Configuration Options:")
    DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."LockRoll --- |cff7092beLock/Unlock the roll frames")
    DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."LockLoot --- |cff7092beLock/Unlock the loot frame")
    DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."TrackMouse --- |cff7092beEnable/Disable loot frame mouse tracking")
    DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."ShowCurrent --- |cff7092beShow Current Settings")
    DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Config --- |cff7092beShow loot frames for drag")
    DEFAULT_CHAT_FRAME:AddMessage("|cffefe4b0".."Reset --- |cff7092beReset all configurations to default")
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff".."--------------------------------------------")
end
function InitSettings()
    BeautyLootDB={
        ["LockRoll"] = false,
        ["LockLoot"] = false,
        ["TrackMouse"] = true,
        ["LootFrame"] ={
            left = 400,
            bottom = 400
        }
    }
    local index
    local GroupLootFrameYOffset = 120
    for index=1, NUM_GROUP_LOOT_FRAMES do --重设团队拾取框体 Reset the position of roll frames
        _G["GroupLootFrame"..index]:ClearAllPoints()
        _G["GroupLootFrame"..index]:SetPoint("BOTTOM","UIParent",0,GroupLootFrameYOffset+(35+_G["GroupLootFrame"..index]:GetHeight())*(index-1))
        SaveFramePosition(_G["GroupLootFrame"..index])
    end
end
function LoadPositions()
    --读取配置文件，设定框体位置 load position from profile and set the postion of loot and roll frames
    local index
    for index=1,NUM_GROUP_LOOT_FRAMES do
        _G["GroupLootFrame"..index]:ClearAllPoints()
        _G["GroupLootFrame"..index]:SetPoint("BOTTOMLEFT","UIParent",BeautyLootDB["GroupLootFrame"..index].left,BeautyLootDB["GroupLootFrame"..index].bottom)
    end
    LootFrame:ClearAllPoints()
    LootFrame:SetPoint("BOTTOMLEFT","UIParent",BeautyLootDB["LootFrame"].left,BeautyLootDB["LootFrame"].bottom)
end
function InitAddon()
    SlashCmdList["BeautyLoot"]=BeautyLoot_Option
    SLASH_BeautyLoot1="/BTL"
    SLASH_BeautyLoot2="/BeautyLoot"
    if(not BeautyLootDB) then
        InitSettings()
    end
    ModifyLootFrame()
    ModifyGroupLootFrames()
	hooksecurefunc("GroupLootContainer_Update", function()
		LoadPositions()
	end)
--[[    hooksecurefunc("AlertFrame_FixAnchors",function()
        if  AchievementAlertFrame1 then  --固定成就通告框架1的位置 fix the position of AchievementAlertFrame1
		    AchievementAlertFrame1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
	    end
        --如果有成就框架显示，则地城完成框架在最上面的那个框架上 if there are some AchievementAlertFrames showing, the DungeonCompletionAlertFrame1 frame would be at the top of the last AchievementAlertFrame
        for i=MAX_ACHIEVEMENT_ALERTS, 1, -1 do
		    local frame = _G["AchievementAlertFrame"..i];
		    if ( frame and frame:IsShown() ) then
			    DungeonCompletionAlertFrame1:SetPoint("BOTTOM", frame, "TOP", 0, 10);
			    return;
		    end
	    end
        --否则 地城完成框架的位置固定为从下面开始的128像素 otherwise, the DungeonCompletionAlertFrame1 would be at 128 of bottom of UIPaent
        DungeonCompletionAlertFrame1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
    end)--]]
    DummyFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    
    ConfigFrameLoot:SetPoint("TOPLEFT",LootFrame)
    ConfigFrameLoot:SetPoint("BOTTOMRIGHT",LootFrame)
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		_G["ConfigFrameGroupLoot"..i]:SetAllPoints(_G["GroupLootFrame"..i])
	end
    LoadPositions()
end

function BeautyLoot_OnEvent(self,event, id)
    if(event=="LOOT_OPENED") then
        LootTitle:SetText(TitleText.." × "..GetNumLootItems())
        if(UnitExists("target") and not IsFishingLoot()) then
            LootTargetPortrait:SetUnit("target")
            LootTargetPortrait:SetCamera(0)
        elseif IsFishingLoot() then
            LootTargetPortrait:ClearModel()
            LootTargetPortrait:SetModel("PARTICLES\\Lootfx.m2")
            LootTargetPortrait:SetCamera(0)
        else
            LootTargetPortrait:ClearModel()
            LootTargetPortrait:SetModel("PARTICLES\\Lootfx.m2")
        end
        LootFrame:SetAlpha(0)
        LootFrameAnimation:Play()
    elseif(event=="LOOT_CLOSED") then
        if LootFrameAnimation:IsPlaying() then
            LootFrameAnimation:Stop()
        end
    elseif(event=="CHAT_MSG_LOOT") then
        CHAT_MSG_LOOT(id)
    else
        InitAddon()
    end
end

DummyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
DummyFrame:RegisterEvent("LOOT_OPENED")
DummyFrame:RegisterEvent("LOOT_CLOSED")
DummyFrame:RegisterEvent("CHAT_MSG_LOOT")
DummyFrame:SetScript("OnEvent", BeautyLoot_OnEvent);
--[[hook lootframe show event. chage quest border]]--
--[[LootFrame:HookScript("OnShow",function(self)
	LootFrame_UpdateAnchorAndSize()
	local nIndex = 1
	for nIndex = 1,4 do
		_G["LootButton"..nIndex.."IconQuestTexture"]:SetAllPoints()
		_G["LootButton"..nIndex.."IconQuestTexture"]:SetTexture(LootButtonBorderOverlay)
		_G["LootButton"..nIndex.."IconQuestTexture"]:SetBlendMode("BLEND")
		_G["LootButton"..nIndex.."IconQuestTexture"]:SetVertexColor(1,0,0)
		_G["LootButton"..nIndex.."IconQuestTexture"].SetTexture = function() end
		_G["LootButton"..nIndex.."IconQuestTexture"].SetVertexColor = function() end
	end
end)--]]