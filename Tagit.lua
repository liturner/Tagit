local name, lMiniMap = ...
local lineAdded = false
lMiniMap.MainFrame = CreateFrame('FRAME', nil, UIParent)

function lMiniMap.OnEvent(self, event, ...) 
	print(event)
	if event == "ADDON_LOADED" and ... == "lMiniMap" then
		print('lMiniMap: ADDON_LOADED')
		
		-- Make sure we have an initialised settings database
		if TAPIV_Settings == nil then
			TAPIV_Settings = { AddonName = 'Forager', NodesLootedDatabase = {} }
		end
		
		-- Tie onto the "OnClick" for all bag slots
		lMiniMap.RegisterAllBagSlotsForOnClick()		
		
		self:UnregisterEvent("ADDON_LOADED")
	end
	
	if GetMouseButtonClicked() == 'LeftButton' then
		print("TIMMEH!")
	end
end

local function OnTooltipSetItem(tooltip)
	if not lineAdded then
		tooltipItem = tooltip:GetItem()
		tooltipNoteID = TAPIV_Settings[tooltipItem]
		tooltipNote = lMiniMap.NoteIDToText(tooltipNoteID)
		
		if tooltipNote ~= nil then
			tooltip:AddLine(tooltipNote)
			lineAdded = true
		end
	end
end

local function OnTooltipCleared(tooltip, ...)
   lineAdded = false
end

-- Update the database and trigger a UI Refresh
function lMiniMap.OnItemSelectedForMarking(itemName)
	if TAPIV_Settings[itemName] == nil then
		TAPIV_Settings[itemName] = 1
	elseif TAPIV_Settings[itemName] < 4 then
		TAPIV_Settings[itemName] = TAPIV_Settings[itemName] + 1
	else
		TAPIV_Settings[itemName] = 0
	end

	print("itemName" .. itemName)
	
	note = lMiniMap.NoteIDToText(TAPIV_Settings[itemID])
	if note ~= nil then print("Note" .. note) end
end

-- Return nil or a readable string. Can recieve nil safely
function lMiniMap.NoteIDToText(noteID)
	if noteID == 0 then 
		return nil
	elseif noteID == 1 then
		return "Sell"
	elseif noteID == 2 then
		return "Auction"
	elseif noteID == 3 then
		return "Profession"
	elseif noteID == 4 then
		return "Collect"
	else
		return nil
	end
end

function lMiniMap.RegisterAllBagSlotsForOnClick()
	for b = 1, 5 do
		for s = 0, 32 do -- using 32 as a max bag size and therefore a max count for button frame creations, could be an issue, need to know if all bag slot buttons are created on game start and just hidden OR are they created per bag equipped ?
			-- get global name
			if _G['ContainerFrame'..b..'Item'..s] then
				_G['ContainerFrame'..b..'Item'..s]:HookScript('OnClick', function()
					if IsAltKeyDown() then
						local bagSize = GetContainerNumSlots(b - 1)
						local itemID = GetContainerItemID((b - 1), (bagSize - (s - 1)))

						-- Trigger event if not nil
						if GetMouseButtonClicked() == 'LeftButton' and itemID ~= nil then
						
							itemName = GetItemInfo(itemID)
							lMiniMap.OnItemSelectedForMarking(itemName)
						end
					end
				end)
			end		
		end
	end
end

lMiniMap.MainFrame:RegisterEvent('ADDON_LOADED')
lMiniMap.MainFrame:SetScript('OnEvent', lMiniMap.OnEvent)
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
