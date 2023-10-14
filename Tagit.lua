local name, Tagit = ...

Tagit.lineAdded = false
Tagit.tags = {"Sell", "Auction", "Profession", "Quest"}
Tagit.MainFrame = CreateFrame('FRAME', nil, UIParent)

function Tagit.OnEvent(self, event, ...) 
	if event == "ADDON_LOADED" and ... == "Tagit" then		
		-- Make sure we have an initialised settings database
		if Tagit_Database == nil then
			Tagit_Database = { AddonName = 'Forager', SchemaVersion = 1, NodesLootedDatabase = {} }
		end
		
		-- Tie onto the "OnClick" for all bag slots
		Tagit.RegisterAllBagSlotsForOnClick()		
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function Tagit.OnTooltipSetItem(tooltip, ...)
	if not Tagit.lineAdded then
		local tooltipItem = tooltip:GetItem()
		local tooltipNoteID = Tagit_Database[tooltipItem]
		local tooltipNote = Tagit.NoteIDToText(tooltipNoteID)
		
		if tooltipNote ~= nil then
			tooltip:AddLine(tooltipNote)
			Tagit.lineAdded = true
		end
	end
end

function Tagit.OnTooltipCleared(tooltip, ...)
	Tagit.lineAdded = false
end

-- Update the database and trigger a UI Refresh
function Tagit.OnItemSelectedForMarking(itemName)
	if not Tagit_Database[itemName] then
		Tagit_Database[itemName] = 1
	elseif Tagit_Database[itemName] < #Tagit.tags then
		Tagit_Database[itemName] = Tagit_Database[itemName] + 1
	else
		Tagit_Database[itemName] = nil
	end
end

-- Return nil or a readable string. Can recieve nil safely
function Tagit.NoteIDToText(noteID)
	if Tagit.tags[noteID] then
		return Tagit.tags[noteID]
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
						local bagSize = C_Container.GetContainerNumSlots(b - 1)
						local itemID = C_Container.GetContainerItemID((b - 1), (bagSize - (s - 1)))

						-- Trigger event if not nil
						if GetMouseButtonClicked() == 'LeftButton' and itemID ~= nil then
							local itemName = GetItemInfo(itemID)
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
