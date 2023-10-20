local _, Addon = ...

Addon.Tags = {}

function Addon.Tags:Initialise()
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
end

function Addon.Tags:GetTagIndexFromTagGUID(guid)
    for idx, tag in ipairs(Tagit_Tags) do
        if(tag.GUID and tag.GUID == guid) then
            return idx
        end
    end
end

function Addon.Tags:GetTagIndexFromItemID(itemID)
    Addon.Util:Print("Getting Tag Index For Item: " .. tostring(itemID))
    local tag = self:GetTagFromItemID(itemID)
    if(tag) then
        return self:GetTagIndexFromTagGUID(tag.GUID)
    end
end

function Addon.Tags:GetTagFromTagGUID(guid)
    for _, tag in ipairs(Tagit_Tags) do
        if(tag.GUID and tag.GUID == guid) then
            return tag
        end
    end
end

function Addon.Tags:GetTagFromTagLabel(label)
    for _, tag in ipairs(Tagit_Tags) do
        if(tag.Label and tag.Label == label) then
            return tag
        end
    end
end

function Addon.Tags:DeleteTagFromTagGUID(guid)
    local index = Addon.Tags:GetTagIndexFromTagGUID(guid)
    if(index) then
        table.remove(Tagit_Tags, index)
    end
end

function Addon.Tags:GetTagFromTagIndex(idx)
    return Tagit_Tags[idx]
end

-- Adds a new Tag to the Database
-- Will generate a unique GUID if none was provided
-- Will overwrite an existing label if existing GUID is supplied
function Addon.Tags:Put(guid, label)
    if(not guid) then
        while(not guid or self:GetTagFromTagGUID(guid)) do
            -- Hint: The first 50 numbers are just reserved GUIDs
            guid = math.random(50, 2147483646)
        end
    end
    local idx = self:GetTagIndexFromTagGUID(guid)
    if(idx) then
        table.remove(Tagit_Tags, idx)
        table.insert(Tagit_Tags, idx, {GUID=guid, Label=label})
    else
        table.insert(Tagit_Tags, {GUID=guid, Label=label})
    end
end

function Addon.Tags:SetItemIDFromTagIndex(itemID, index)
    Addon.Util:Print("Tagging Item: " .. tostring(itemID) .. " With Index: " .. tostring(index))
    if index > 0 and index <= #Tagit_Tags then
        Tagit_Items[itemID] = Tagit_Tags[index].GUID
    else
        Tagit_Items[itemID] = nil
    end
end

-- Returns a complete Tag (or nil) from the database based on the provided item
function Addon.Tags:GetTagFromItemID(itemID)
    return self:GetTagFromTagGUID(Tagit_Items[itemID])
end

function Addon.Tags:GetTagFromItem(item)
    Addon.Tags:FixItem(item)
    local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(item)
    return self:GetTagFromItemID(itemID)
end

-- Delete this function once the DB has no Name keys.
-- It currently just replaces the old name based itemId with an ItemId.
function Addon.Tags:FixItem(item)
    if not item then
        return
    end

    local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(item)
    local itemName = GetItemInfo(item)

    if(Tagit_Items[itemName]) then
        Tagit_Items[itemID] = Tagit_Items[itemName]
        Tagit_Items[itemName] = nil
    end
end