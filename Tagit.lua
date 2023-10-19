local name, Tagit = ...

Tagit.LineAdded = false
Tagit.Debug = false
Tagit.MainFrame = CreateFrame('FRAME', nil, UIParent)

function Tagit.print(text)
	if(Tagit.Debug) then
		print(text)
	end
end

function Tagit.OnEvent(self, event, ...) 
	if event == "ADDON_LOADED" and ... == "Tagit" then		
		-- Make sure we have an initialised settings database

		if Tagit_Items == nil then
			Tagit_Items = {}
		end

		if Tagit_Tags == nil then
			-- TODO: This should be a migration. The Items part should remain untouched.
			Tagit_Tags = { 
				{
					GUID = "6945e800-19fa-4a85-bbe7-265c6768aa62",
					Label = "Sell"
				},
				{
					GUID = "5d1c2acd-8882-4710-879a-e6c837db92d4",
					Label = "Auction"
				},
				{
					GUID = "855a860c-f99d-4850-87f1-0d7bc81fa706",
					Label = "Profession"
				},
				{
					GUID = "ddb8e218-9fc3-4a61-946d-6bbd7bca6a38",
					Label = "Quest"
				}
			}
		end
		
		-- Tie onto the "OnClick" for all bag slots
		Tagit.RegisterAllBagSlotsForOnClick()		
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end

Tagit.TagFromGUID = function (GUID)
	Tagit.print("TagFromGUID: " .. tostring(GUID))
	if not GUID then
		return nil
	end
	for id, tag in ipairs(Tagit_Tags) do
		if(tag.GUID == GUID) then
			Tagit.print("TagFromGUID: " .. tag.GUID .. " = " .. tostring(id))
			return id, tag
		end
	end
end

function Tagit.OnTooltipSetItem(tooltip, ...)
	if not Tagit.LineAdded then
		local tooltipItem = tooltip:GetItem()
		local tooltipNoteID = Tagit_Items[tooltipItem]
		local tooltipNote = Tagit.NoteGUIDToText(tooltipNoteID)
		
		if tooltipNote ~= nil then
			tooltip:AddLine(tooltipNote)
			Tagit.LineAdded = true
		end
	end
end

function Tagit.OnTooltipCleared(tooltip, ...)
	Tagit.LineAdded = false
end

-- Update the database and trigger a UI Refresh
function Tagit.OnItemSelectedForMarking(itemName)
	Tagit.print("Marking: " .. itemName)

	local currentTagId, _ = Tagit.TagFromGUID(Tagit_Items[itemName])

	Tagit.print("Marking: " .. "Current ID  = " .. tostring(currentTagId))
	Tagit.print("Marking: " .. "Current Tag = " .. tostring(Tagit_Items[itemName]))

	if not Tagit_Items[itemName] then
		Tagit_Items[itemName] = Tagit_Tags[1].GUID
	elseif currentTagId < #Tagit_Tags then
		Tagit_Items[itemName] = Tagit_Tags[currentTagId + 1].GUID
	else
		Tagit_Items[itemName] = nil
	end

	Tagit.print("Marking: " .. "New Tag     = " .. tostring(Tagit_Items[itemName]))

end

-- Return nil or a readable string. Can recieve nil safely
function Tagit.NoteGUIDToText(noteGUID)
	Tagit.print("Labeling: " .. tostring(noteGUID))

	local tagId, tag = Tagit.TagFromGUID(noteGUID)

	if Tagit_Tags[tagId] then
		Tagit.print("Labeling: " .. tostring(Tagit_Tags[tagId].Label))
		return Tagit_Tags[tagId].Label
	else 
		Tagit.print("Labeling: " .. tostring("Tag not present!!"))
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
