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
    if(item) then
        return self:FindElementDataByItemID(GetItemInfoInstant(item))
    end
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
        return tag
    else
        self:Insert(tag)
        return tag
    end
end

function TagListDataProviderMixin:SetItemFromTagIndex(item, index)
    if(not item) then
        return
    end
    local itemID = GetItemInfoInstant(item)
    if(index > 0 and index <= Addon.TagList:GetSize()) then
        TagListDataProviderMixin:SetItemFromTag(itemID, Addon.TagList:Find(index))
    else
        TagListDataProviderMixin:SetItemFromTag(itemID, nil)
    end
end

function TagListDataProviderMixin:SetItemFromTag(item, tag)
    if(not item) then
        return
    end
    local itemID = GetItemInfoInstant(item)
    if(itemID and tag and tag.GUID) then
        Tagit_Items[itemID] = tag.GUID
        return itemID, tag
    elseif(itemID and tag == nil) then
        Tagit_Items[itemID] = nil
        return itemID, nil
    end
end

Addon.TagList = CreateFromMixins(TagListDataProviderMixin)
Addon.TagList:Init({})