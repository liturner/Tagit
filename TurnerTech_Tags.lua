local name, Addon = ...
local LineAdded = false

local function OnPlayerEnteringWorld()
    -- Data Models (Fill from stored variables)

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

-- This is only intended for an incoming slash command. It splits by comma
-- and passes the ars on to "NewTag"
local function SlashNewTag(argString)
    local args = Addon.Util:SplitArgs(argString)
    return TurnerTech_Tags:InsertTag(args[1], args[2])
end

local function RegisterAllBagSlotsForOnClick()
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
                            OnItemSelectedForMarking(itemID)
                        end
                    end
                end)
            end
        end
    end
end

local function OnTooltipCleared(tooltip, ...)
    LineAdded = false
end

local function OnTooltipSetItem(tooltip, ...)
    if not LineAdded then
        local tag = TurnerTech_Tags:FindTagsByItem(tooltip:GetItem())

        if(tag[1]) then
            tooltip:AddLine(tag[1].Label)
            LineAdded = true
        end
    end
end

-- Update the database and trigger a UI Refresh
function OnItemSelectedForMarking(itemID)
    local tagIndex = Addon.TagList:FindIndexByItemID(itemID)
    if(not tagIndex) then
        Addon.TagList:SetItemIDFromTagIndex(itemID, 1)
    else
        Addon.TagList:SetItemIDFromTagIndex(itemID, tagIndex + 1)
    end
end

-- TurnerTech_Tags

TagitAddonMixin = CreateFromMixins(CallbackRegistryMixin)

TagitAddonMixin:GenerateCallbackEvents({
    "Tag_Added",
    "Tag_Removed",
    "Tag_ItemTagged",
    "Tag_ItemTagRemoved"
})

function TagitAddonMixin:OnEvent(event, ...)
    print("OnEvent")
	if event == "PLAYER_ENTERING_WORLD" then
		OnPlayerEnteringWorld()
	end
end

function TagitAddonMixin:OnLoad()
    Addon.Util:Print("Tagit OnLoad")
    CallbackRegistryMixin.OnLoad(self);

    -- Slash Command

    SLASH_ADDTAG1 = "/addtag"
    SlashCmdList["ADDTAG"] = function(label) SlashNewTag(label) end

    SLASH_REMOVETAG1 = "/removetag"
    SlashCmdList["REMOVETAG"] = function(label) self:RemoveTagByLabel(label) end

    -- Callbacks / Events etc.

    RegisterAllBagSlotsForOnClick()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
    GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
end

---Creates a new tag which can later be assigned to items.
---@param label string The label to assign to the tag.
---@param labelID number|nil A globaly unique ID for the new Tag. If nil is used, a random ID is generated.
---@return table|nil tag The newly created tag (or nil on error).
function TagitAddonMixin:CreateTag(label, labelID)
    if(not label) then
        UIErrorsFrame:AddExternalErrorMessage("Cannot add a tag with no label!")
        return nil
    end
    local tag = Addon.TagList:InsertTag(labelID, label)
    if(tag) then
        self:TriggerEvent("Tag_Added", tag)
    end
    return tag
end

---Ads a Tag to an Item. This is a tollerant function which will create a tag
---where one does not exist. If an unknown Tag ID is used, then the item will
---still be tagged!
---@param item number|string Item ID, Link or Name.
---@param tag number|string|table Tag ID, Label or instance
function TagitAddonMixin:TagItem(item, tag)
end

---Removes all tags with the provided label. This should only be one tag, but
---be in the case of multiple tags with the same label (in this local), all
---tags will be removed.
---@param label string The tag label.
function TagitAddonMixin:DeleteTagsByLabel(label)
    local predicate = function(tag) return tag.Label == label end
    while(Addon.TagList:ContainsByPredicate(predicate)) do
        Addon.TagList:RemoveByPredicate(predicate)
    end
end

---Gets a table of tags assigned to a particular item.
---@param item number|string Item ID, Link or Name.
---@return table tags A list of tags associated to this item.
function TagitAddonMixin:FindTagsByItem(item)
    return {Addon.TagList:FindElementDataByItem(item)}
end