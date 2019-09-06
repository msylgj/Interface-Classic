daftSetSwapOptionsPanel = CreateFrame( "Frame", "daftSetSwapOptionsPanel", UIParent );
daftSetSwapOptionsPanel.name = "daftSetSwap";
InterfaceOptions_AddCategory(daftSetSwapOptionsPanel);

daftSetSwapOptionsPanel:RegisterEvent("ADDON_LOADED");

daftSetSwapOptionsPanel:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		
		if addon == "daftSetSwap" then -- Set Stored Options
		
			if ENABLED == true then
				EnableBtn:SetChecked(true);
			else
				ENABLED = false;
				EnableBtn:SetChecked(false);
			end;
			
			if SPEC1 == true then
				EnableSpec1Btn:SetChecked(true);
			else
				SPEC1 = false;
				EnableSpec1Btn:SetChecked(false);
			end;
			
			if SPEC1_NOCOMBAT then
				UIDropDownMenu_SetText(Spec1NoCombatDropdown, SPEC1_NOCOMBAT);
			else
				UIDropDownMenu_SetText(Spec1NoCombatDropdown, "None");
			end;
			if SPEC1_COMBAT then
				UIDropDownMenu_SetText(Spec1CombatDropdown, SPEC1_COMBAT);
			else
				UIDropDownMenu_SetText(Spec1CombatDropdown, "None");
			end;
			
			
			if SPEC2 == true then
				EnableSpec2Btn:SetChecked(true);
			else
				SPEC2 = false;
				EnableSpec2Btn:SetChecked(false);
			end;
			
			if SPEC2_NOCOMBAT then
				UIDropDownMenu_SetText(Spec2NoCombatDropdown, SPEC2_NOCOMBAT);
			else
				UIDropDownMenu_SetText(Spec2NoCombatDropdown, "None");
			end;
			if SPEC2_COMBAT then
				UIDropDownMenu_SetText(Spec2CombatDropdown, SPEC2_COMBAT);
			else
				UIDropDownMenu_SetText(Spec2CombatDropdown, "None");
			end;
			
			
			
			
			if SPEC3 == true then
				EnableSpec3Btn:SetChecked(true);
			else
				SPEC3 = false;
				EnableSpec3Btn:SetChecked(false);
			end;
			
			if SPEC3_NOCOMBAT then
				UIDropDownMenu_SetText(Spec3NoCombatDropdown, SPEC3_NOCOMBAT);
			else
				UIDropDownMenu_SetText(Spec3NoCombatDropdown, "None");
			end;
			if SPEC3_COMBAT then
				UIDropDownMenu_SetText(Spec3CombatDropdown, SPEC3_COMBAT);
			else
				UIDropDownMenu_SetText(Spec3CombatDropdown, "None");
			end;
			
			
			
			if SPEC4 == true then
				EnableSpec4Btn:SetChecked(true);
			else
				SPEC4 = false;
				EnableSpec4Btn:SetChecked(false);
			end;
			
			if SPEC4_NOCOMBAT then
				UIDropDownMenu_SetText(Spec4NoCombatDropdown, SPEC4_NOCOMBAT);
			else
				UIDropDownMenu_SetText(Spec4NoCombatDropdown, "None");
			end;
			if SPEC4_COMBAT then
				UIDropDownMenu_SetText(Spec4CombatDropdown, SPEC4_COMBAT);
			else
				UIDropDownMenu_SetText(Spec4CombatDropdown, "None");
			end;
		end;
	end;
end);

 
-- TITLE 

local titleLbl = daftSetSwapOptionsPanel:CreateFontString("titleLbl", "ARTWORK", "GameFontNormalLarge");
titleLbl:SetPoint("TOPLEFT", daftSetSwapOptionsPanel, "TOPLEFT", 10, -10);
titleLbl:SetText("daftSetSwap");


-- ENABLE BUTTON


local EnableBtn = CreateFrame("CheckButton", "EnableBtn", daftSetSwapOptionsPanel, "ChatConfigCheckButtonTemplate");
EnableBtn:SetPoint("TOPLEFT", titleLbl, "BOTTOMLEFT", 0, -5);
EnableBtn.tooltip = "Enable or Disable the entire addon.";
EnableBtn:SetScript("OnClick", function(self)
	if self:GetChecked() then
		ENABLED = true;
	else
		ENABLED = false;
	end;
end);


local enableLbl = daftSetSwapOptionsPanel:CreateFontString("enableLbl", "ARTWORK", "GameFontHighlight");
enableLbl:SetPoint("LEFT", EnableBtn, "RIGHT", 5, 0);
enableLbl:SetText("Enabled");


-- SPEC 1


local spec1Lbl = daftSetSwapOptionsPanel:CreateFontString("spec1Lbl", "ARTWORK", "GameFontNormalLarge");
spec1Lbl:SetPoint("TOPLEFT", EnableBtn, "BOTTOMLEFT", 0, -40);
spec1Lbl:SetText("Specialization 1");


local EnableSpec1Btn = CreateFrame("CheckButton", "EnableSpec1Btn", daftSetSwapOptionsPanel, "ChatConfigCheckButtonTemplate");
EnableSpec1Btn:SetPoint("TOPLEFT", spec1Lbl, "BOTTOMLEFT", 0, -5);
EnableSpec1Btn:SetScript("OnClick", function(self)
	if self:GetChecked() then
		SPEC1 = true;
	else
		SPEC1 = false;
	end;
end);
  
  
local enableSpec1Lbl = daftSetSwapOptionsPanel:CreateFontString("enableSpec1Lbl", "ARTWORK", "GameFontHighlight");
enableSpec1Lbl:SetPoint("LEFT", EnableSpec1Btn, "RIGHT", 5, 0);
enableSpec1Lbl:SetText("Enabled");


local Spec1NoCombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec1NoCombatLbl", "ARTWORK", "GameFontHighlight");
Spec1NoCombatLbl:SetPoint("TOPLEFT", EnableSpec1Btn, "BOTTOMLEFT", 0, -5);
Spec1NoCombatLbl:SetText("Out of Combat");


local Spec1NoCombatDropdown = CreateFrame("Frame", "Spec1NoCombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec1NoCombatDropdown:SetPoint("LEFT", Spec1NoCombatLbl, "RIGHT", -5, -5);
Spec1NoCombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC1_NOCOMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


local Spec1CombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec1CombatLbl", "ARTWORK", "GameFontHighlight");
Spec1CombatLbl:SetPoint("LEFT", Spec1NoCombatDropdown, "RIGHT", 130, 0);
Spec1CombatLbl:SetText("In Combat");


local Spec1CombatDropdown = CreateFrame("Frame", "Spec1CombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec1CombatDropdown:SetPoint("LEFT", Spec1CombatLbl, "RIGHT", -5, -5);
Spec1CombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC1_COMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


-- SPEC 2


local Spec2Lbl = daftSetSwapOptionsPanel:CreateFontString("Spec2Lbl", "ARTWORK", "GameFontNormalLarge");
Spec2Lbl:SetPoint("TOPLEFT", Spec1NoCombatLbl, "BOTTOMLEFT", 0, -40);
Spec2Lbl:SetText("Specialization 2");


local EnableSpec2Btn = CreateFrame("CheckButton", "EnableSpec2Btn", daftSetSwapOptionsPanel, "ChatConfigCheckButtonTemplate");
EnableSpec2Btn:SetPoint("TOPLEFT", Spec2Lbl, "BOTTOMLEFT", 0, -5);
EnableSpec2Btn:SetScript("OnClick", function(self)
	if self:GetChecked() then
		SPEC2 = true;
	else
		SPEC2 = false;
	end;
end);
  
  
local enableSpec2Lbl = daftSetSwapOptionsPanel:CreateFontString("enableSpec2Lbl", "ARTWORK", "GameFontHighlight");
enableSpec2Lbl:SetPoint("LEFT", EnableSpec2Btn, "RIGHT", 5, 0);
enableSpec2Lbl:SetText("Enabled");


local Spec2NoCombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec2NoCombatLbl", "ARTWORK", "GameFontHighlight");
Spec2NoCombatLbl:SetPoint("TOPLEFT", EnableSpec2Btn, "BOTTOMLEFT", 0, -5);
Spec2NoCombatLbl:SetText("Out of Combat");


local Spec2NoCombatDropdown = CreateFrame("Frame", "Spec2NoCombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec2NoCombatDropdown:SetPoint("LEFT", Spec2NoCombatLbl, "RIGHT", -5, -5);
Spec2NoCombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC2_NOCOMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


local Spec2CombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec2CombatLbl", "ARTWORK", "GameFontHighlight");
Spec2CombatLbl:SetPoint("LEFT", Spec2NoCombatDropdown, "RIGHT", 130, 0);
Spec2CombatLbl:SetText("In Combat");


local Spec2CombatDropdown = CreateFrame("Frame", "Spec2CombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec2CombatDropdown:SetPoint("LEFT", Spec2CombatLbl, "RIGHT", -5, -5);
Spec2CombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC2_COMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


-- SPEC 3


local Spec3Lbl = daftSetSwapOptionsPanel:CreateFontString("Spec3Lbl", "ARTWORK", "GameFontNormalLarge");
Spec3Lbl:SetPoint("TOPLEFT", Spec2NoCombatLbl, "BOTTOMLEFT", 0, -40);
Spec3Lbl:SetText("Specialization 3");


local EnableSpec3Btn = CreateFrame("CheckButton", "EnableSpec3Btn", daftSetSwapOptionsPanel, "ChatConfigCheckButtonTemplate");
EnableSpec3Btn:SetPoint("TOPLEFT", Spec3Lbl, "BOTTOMLEFT", 0, -5);
EnableSpec3Btn:SetScript("OnClick", function(self)
	if self:GetChecked() then
		SPEC3 = true;
	else
		SPEC3 = false;
	end;
end);
  
  
local enableSpec3Lbl = daftSetSwapOptionsPanel:CreateFontString("enableSpec3Lbl", "ARTWORK", "GameFontHighlight");
enableSpec3Lbl:SetPoint("LEFT", EnableSpec3Btn, "RIGHT", 5, 0);
enableSpec3Lbl:SetText("Enabled");


local Spec3NoCombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec3NoCombatLbl", "ARTWORK", "GameFontHighlight");
Spec3NoCombatLbl:SetPoint("TOPLEFT", EnableSpec3Btn, "BOTTOMLEFT", 0, -5);
Spec3NoCombatLbl:SetText("Out of Combat");


local Spec3NoCombatDropdown = CreateFrame("Frame", "Spec3NoCombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec3NoCombatDropdown:SetPoint("LEFT", Spec3NoCombatLbl, "RIGHT", -5, -5);
Spec3NoCombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC3_NOCOMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


local Spec3CombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec3CombatLbl", "ARTWORK", "GameFontHighlight");
Spec3CombatLbl:SetPoint("LEFT", Spec3NoCombatDropdown, "RIGHT", 130, 0);
Spec3CombatLbl:SetText("In Combat");


local Spec3CombatDropdown = CreateFrame("Frame", "Spec3CombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec3CombatDropdown:SetPoint("LEFT", Spec3CombatLbl, "RIGHT", -5, -5);
Spec3CombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC3_COMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


-- SPEC 4


local Spec4Lbl = daftSetSwapOptionsPanel:CreateFontString("Spec4Lbl", "ARTWORK", "GameFontNormalLarge");
Spec4Lbl:SetPoint("TOPLEFT", Spec3NoCombatLbl, "BOTTOMLEFT", 0, -40);
Spec4Lbl:SetText("Specialization 4");


local EnableSpec4Btn = CreateFrame("CheckButton", "EnableSpec4Btn", daftSetSwapOptionsPanel, "ChatConfigCheckButtonTemplate");
EnableSpec4Btn:SetPoint("TOPLEFT", Spec4Lbl, "BOTTOMLEFT", 0, -5);
EnableSpec4Btn:SetScript("OnClick", function(self)
	if self:GetChecked() then
		SPEC4 = true;
	else
		SPEC4 = false;
	end;
end);
  
  
local enableSpec4Lbl = daftSetSwapOptionsPanel:CreateFontString("enableSpec4Lbl", "ARTWORK", "GameFontHighlight");
enableSpec4Lbl:SetPoint("LEFT", EnableSpec4Btn, "RIGHT", 5, 0);
enableSpec4Lbl:SetText("Enabled");


local Spec4NoCombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec4NoCombatLbl", "ARTWORK", "GameFontHighlight");
Spec4NoCombatLbl:SetPoint("TOPLEFT", EnableSpec4Btn, "BOTTOMLEFT", 0, -5);
Spec4NoCombatLbl:SetText("Out of Combat");


local Spec4NoCombatDropdown = CreateFrame("Frame", "Spec4NoCombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec4NoCombatDropdown:SetPoint("LEFT", Spec4NoCombatLbl, "RIGHT", -5, -5);
Spec4NoCombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC4_NOCOMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


local Spec4CombatLbl = daftSetSwapOptionsPanel:CreateFontString("Spec4CombatLbl", "ARTWORK", "GameFontHighlight");
Spec4CombatLbl:SetPoint("LEFT", Spec4NoCombatDropdown, "RIGHT", 130, 0);
Spec4CombatLbl:SetText("In Combat");


local Spec4CombatDropdown = CreateFrame("Frame", "Spec4CombatDropdown", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate");
Spec4CombatDropdown:SetPoint("LEFT", Spec4CombatLbl, "RIGHT", -5, -5);
Spec4CombatDropdown.initialize = function(dropdown)
	
	local items = {};
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetInfo(i);
		items[i] = name;
	end;
	
	for i, v in pairs(items) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = items[i];
		info.value = items[i];
		info.func = function(self)
			SPEC4_COMBAT = self.value;
			UIDropDownMenu_SetText(dropdown, self.value);
		end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end;
end;


-- --Second Dropdown
-- local function SecondarySelection(button, setID, name)
	-- UIDropDownMenu_SetText(Secondary, name)
	-- ssname2 = name
-- end 

-- local Secondary = CreateFrame("Frame", "Secondary", daftSetSwapOptionsPanel, "UIDropDownMenuTemplate")
-- Secondary.initialize = function(self, selection) end
-- Secondary:SetPoint("TOPRIGHT", -275, -80);

-- Secondary.initialize = function(self, selection)
  
	
	-- if not selection then return end
    -- wipe(equipmentSet)
    -- if selection == 1 then
		-- equipmentSet.text = "None"
		-- --equipmentSet.icon = icon
		-- equipmentSet.func = SecondarySelection 
		-- --equipmentSet.setID = i
		-- equipmentSet.name = nil
		-- equipmentSet.notCheckable = 1
		-- UIDropDownMenu_AddButton(equipmentSet, selection)
		-- for i = 1, GetNumEquipmentSets() do
		-- local name, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = GetEquipmentSetsetInfo(i)
		-- equipmentSet.text = name
		-- equipmentSet.icon = icon
		-- equipmentSet.func = SecondarySelection 
		-- equipmentSet.setID = i
		-- equipmentSet.name = name
		-- equipmentSet.notCheckable = 1
		-- UIDropDownMenu_AddButton(equipmentSet, selection)
		-- end
    -- end
-- end
