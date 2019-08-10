local name, Tagit = ...
local lineAdded = false
Tagit.MainFrame = CreateFrame('FRAME', nil, UIParent)

function Tagit.OnEvent(self, event, ...) 
	if event == "ADDON_LOADED" and ... == "Tagit" then		
		-- Make sure we have an initialised settings database
		if Tagit_Database == nil then
			Tagit_Database = { AddonName = 'Forager', NodesLootedDatabase = {} }
		end
		
		-- Tie onto the "OnClick" for all bag slots
		Tagit.RegisterAllBagSlotsForOnClick()		
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function Tagit.OnTooltipSetItem(tooltip, ...)
	if not lineAdded then
		tooltipItem = tooltip:GetItem()
		tooltipNoteID = Tagit_Database[tooltipItem]
		tooltipNote = Tagit.NoteIDToText(tooltipNoteID)
		
		if tooltipNote ~= nil then
			tooltip:AddLine(tooltipNote)
			lineAdded = true
		end
	end
end

function Tagit.OnTooltipCleared(tooltip, ...)
   lineAdded = false
end

-- Update the database and trigger a UI Refresh
function Tagit.OnItemSelectedForMarking(itemName)
	if Tagit_Database[itemName] == nil then
		Tagit_Database[itemName] = 1
	elseif Tagit_Database[itemName] < 4 then
		Tagit_Database[itemName] = Tagit_Database[itemName] + 1
	else
		Tagit_Database[itemName] = 0
	end
end

-- Return nil or a readable string. Can recieve nil safely
function Tagit.NoteIDToText(noteID)
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

function Tagit.RegisterAllBagSlotsForOnClick()
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
							Tagit.OnItemSelectedForMarking(itemName)
						end
					end
				end)
			end		
		end
	end
end

Tagit.MainFrame:RegisterEvent('ADDON_LOADED')
Tagit.MainFrame:SetScript('OnEvent', Tagit.OnEvent)
GameTooltip:HookScript("OnTooltipSetItem", Tagit.OnTooltipSetItem)
GameTooltip:HookScript("OnTooltipCleared", Tagit.OnTooltipCleared)
