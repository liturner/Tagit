local name, addon = ...

TagitAddonMixin = {
    LineAdded = false
}

function TagitAddonMixin:OnLoad()

	if Tagit_Items == nil then
		Tagit_Items = {}
	end

	if Tagit_Tags == nil then
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

	SLASH_ADDTAG1 = "/addtag"
	SlashCmdList["ADDTAG"] = function(label) self:SlashNewTag(label) end

    -- Tie onto the "OnClick" for all bag slots
	self:RegisterAllBagSlotsForOnClick()

	GameTooltip:HookScript("OnTooltipSetItem", TagitAddonMixin.OnTooltipSetItem)
	GameTooltip:HookScript("OnTooltipCleared", TagitAddonMixin.OnTooltipCleared)

end

-- This is only intended for an incoming slash command. It splits by comma
-- and passes the ars on to "NewTag"
function TagitAddonMixin:SlashNewTag(argString)
	local args = addon.Util:SplitArgs(argString)
	return self:NewTag(args[1], args[2])
end

function TagitAddonMixin:NewTag(label, id)
	if(not label) then
		UIErrorsFrame:AddExternalErrorMessage("Cannot add a tag with no label!")
		return
	end

	if(not id) then
		-- ToDo: Need to check if the random ID already exists first...
		-- The first 50 numbers are just reserved IDs
		id = math.random(50, 2147483646)
	end

	table.insert(Tagit_Tags, {GUID=id, Label=label})
end

function TagitAddonMixin.OnTooltipSetItem(tooltip, ...)
	if not TagitAddonMixin.LineAdded then
		local tooltipItem = tooltip:GetItem()

		TagitAddonMixin.CleanDb(tooltipItem)

		local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(tooltipItem)
		local tooltipNoteID = Tagit_Items[itemID]
		local tooltipNote = TagitAddonMixin:NoteGUIDToText(tooltipNoteID)
		
		if tooltipNote ~= nil then
			tooltip:AddLine(tooltipNote)
			TagitAddonMixin.LineAdded = true
		end
	end
end

function TagitAddonMixin.OnTooltipCleared(tooltip, ...)
	TagitAddonMixin.LineAdded = false
end

function TagitAddonMixin:TagFromGUID(GUID)
	addon.Util:Print("TagFromGUID: " .. tostring(GUID))
	if not GUID then
		return nil
	end
	for id, tag in ipairs(Tagit_Tags) do
		if(tag.GUID == GUID) then
			addon.Util:Print("TagFromGUID: " .. tag.GUID .. " = " .. tostring(id))
			return id, tag
		end
	end
end

-- Delete this function once the DB has no Name keys
function TagitAddonMixin.CleanDb(item)

	if not item then
		return
	end

	local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(item)
	local itemName = GetItemInfo(item)

	addon.Util:Print("Clean DB: " .. tostring(itemID) .. " = " .. tostring(itemName))

	if(Tagit_Items[itemName]) then
		Tagit_Items[itemID] = Tagit_Items[itemName]
		Tagit_Items[itemName] = nil
	end

end

-- Update the database and trigger a UI Refresh
function TagitAddonMixin:OnItemSelectedForMarking(itemId)
	addon.Util:Print("Marking: " .. itemId)

	local currentTagId, _ = self:TagFromGUID(Tagit_Items[itemId])

	addon.Util:Print("Marking: " .. "Current ID  = " .. tostring(currentTagId))
	addon.Util:Print("Marking: " .. "Current Tag = " .. tostring(Tagit_Items[itemId]))

	if not Tagit_Items[itemId] then
		Tagit_Items[itemId] = Tagit_Tags[1].GUID
	elseif currentTagId < #Tagit_Tags then
		Tagit_Items[itemId] = Tagit_Tags[currentTagId + 1].GUID
	else
		Tagit_Items[itemId] = nil
	end

	addon.Util:Print("Marking: " .. "New Tag     = " .. tostring(Tagit_Items[itemId]))

end

-- Return nil or a readable string. Can recieve nil safely
function TagitAddonMixin:NoteGUIDToText(noteGUID)
	addon.Util:Print("Labeling: " .. tostring(noteGUID))

	local tagId, tag = self:TagFromGUID(noteGUID)

	if Tagit_Tags[tagId] then
		addon.Util:Print("Labeling: " .. tostring(Tagit_Tags[tagId].Label))
		return Tagit_Tags[tagId].Label
	else 
		addon.Util:Print("Labeling: " .. tostring("Tag not present!!"))
		return nil
	end
end

function TagitAddonMixin:RegisterAllBagSlotsForOnClick()
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
							self:OnItemSelectedForMarking(itemID)
						end
					end
				end)
			end		
		end
	end
end