local _, Addon = ...

-- The "API" for working with the database.
Addon.Tags = {}

-- Observable List of Tags available for use.
Addon.TagList = CreateFromMixins(DataProviderMixin)
Addon.TagList:Init({})

function Addon.Tags:Initialise()
    if Tagit_Items == nil then
        Tagit_Items = {}
    end

    if Tagit_Tags == nil then
        Tagit_Tags = {
            {
                GUID = 0,
                Label = "Sell"
            },
            {
                GUID = 1,
                Label = "Auction"
            },
            {
                GUID = 2,
                Label = "Profession"
            },
            {
                GUID = 3,
                Label = "Quest"
            }
        }
    end
    Addon.TagList:Init(Tagit_Tags)
    Tagit_Tags = Addon.TagList:GetCollection()
end

function Addon.Tags:GetTagIndexFromTagGUID(guid)
    return Addon.TagList:FindIndexByPredicate(function(tag) return tag.GUID == guid end)
end

function Addon.Tags:GetTagIndexFromItemID(itemID)
    Addon.Util:Print("Getting Tag Index For Item: " .. tostring(itemID))
    local tag = self:GetTagFromItemID(itemID)
    if(tag) then
        return self:GetTagIndexFromTagGUID(tag.GUID)
    end
end

function Addon.Tags:GetTagFromTagGUID(guid)
    return Addon.TagList:FindElementDataByPredicate(function(tag) return tag.GUID == guid end)
end

function Addon.Tags:GetTagFromTagLabel(label)
    return Addon.TagList:FindElementDataByPredicate(function(tag) return tag.Label == label end)
end

function Addon.Tags:GetTagFromTagIndex(index)
    return Addon.TagList:Find(index)
end

-- Adds a new Tag to the Database
-- Will generate a unique GUID if none was provided
-- Will overwrite an existing label if existing GUID is supplied
function Addon.Tags:Put(guid, label)
    local tag = Addon.Tags:GetTagFromTagLabel(label)
    if(not guid and tag) then
        UIErrorsFrame:AddExternalErrorMessage("A Tag with that label already exists!")
        return
    end
    if(not guid) then
        while(not guid or self:GetTagFromTagGUID(guid)) do
            -- Hint: The first 50 numbers are just reserved GUIDs
            guid = math.random(50, 2147483646)
        end
    end
    local idx = self:GetTagIndexFromTagGUID(guid)
    tag = {GUID=guid, Label=label}
    if(idx) then
        Addon.TagList:RemoveIndex(idx)
        Addon.TagList:InsertAtIndex(tag, idx)
    else
        Addon.TagList:Insert(tag)
    end
end

function Addon.Tags:SetItemIDFromTagIndex(itemID, index)
    Addon.Util:Print("Tagging Item: " .. tostring(itemID) .. " With Index: " .. tostring(index))
    if index > 0 and index <= Addon.TagList:GetSize() then
        Tagit_Items[itemID] = Addon.TagList:Find(index).GUID
    else
        Tagit_Items[itemID] = nil
    end
end

-- Returns a complete Tag (or nil) from the database based on the provided item
function Addon.Tags:GetTagFromItemID(itemID)
    return Addon.TagList:FindElementDataByPredicate(function(tag) return tag.GUID == Tagit_Items[itemID] end)
end

function Addon.Tags:GetTagFromItem(item)
    local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(item)
    return self:GetTagFromItemID(itemID)
end
