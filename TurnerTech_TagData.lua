local _, Addon = ...

local TagListDataProviderMixin = CreateFromMixins(DataProviderMixin)

function TagListDataProviderMixin:FindIndexByTagGUID(guid)
    return self:FindIndexByPredicate(function(tag) return tag.GUID == guid end)
end

function TagListDataProviderMixin:FindIndexByItemID(itemID)
    return self:FindIndexByPredicate(function(tag) return tag.GUID == Tagit_Items[itemID] end)
end

function TagListDataProviderMixin:FindElementDataByTagGUID(guid)
    return self:FindElementDataByPredicate(function(tag) return tag.GUID == guid end)
end

function TagListDataProviderMixin:FindElementDataByTagLabel(label)
    return self:FindElementDataByPredicate(function(tag) return tag.Label == label end)
end

function TagListDataProviderMixin:FindElementDataByItemID(itemID)
    return self:FindElementDataByPredicate(function(tag) return tag.GUID == Tagit_Items[itemID] end)
end

function TagListDataProviderMixin:FindElementDataByItem(item)
    return self:FindElementDataByItemID(GetItemInfoInstant(item))
end

-- Adds a new Tag to the Database
-- Will generate a unique GUID if none was provided
-- Will overwrite an existing label if existing GUID is supplied
function TagListDataProviderMixin:InsertTag(guid, label)
    local tag = self:FindElementDataByPredicate(function(tag) return tag.Label == label end)
    if(not guid and tag) then
        UIErrorsFrame:AddExternalErrorMessage("A Tag with that label already exists!")
        return
    end
    if(not guid) then
        while(not guid or self:FindElementDataByTagGUID(guid)) do
            -- Hint: The first 50 numbers are just reserved GUIDs
            guid = math.random(50, 2147483646)
        end
    end
    local idx = self:FindIndexByTagGUID(guid)
    tag = {GUID=guid, Label=label}
    if(idx) then
        self:RemoveIndex(idx)
        self:InsertAtIndex(tag, idx)
    else
        self:Insert(tag)
    end
end

function TagListDataProviderMixin:SetItemIDFromTagIndex(itemID, index)
    Addon.Util:Print("Tagging Item: " .. tostring(itemID) .. " With Index: " .. tostring(index))
    if index > 0 and index <= Addon.TagList:GetSize() then
        Tagit_Items[itemID] = Addon.TagList:Find(index).GUID
    else
        Tagit_Items[itemID] = nil
    end
end

Addon.TagList = CreateFromMixins(TagListDataProviderMixin)
Addon.TagList:Init({})