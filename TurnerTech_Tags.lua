local name, Addon = ...

TagitAddonMixin = {
    LineAdded = false
}

function TagitAddonMixin:OnEvent(event, ...)
    print("OnEvent")
	if event == "PLAYER_ENTERING_WORLD" then
		TagitAddonMixin:OnPlayerEnteringWorld()
	end
end

function TagitAddonMixin:OnLoad()
    Addon.Util:Print("Tagit OnLoad")

    -- Slash Command

    SLASH_ADDTAG1 = "/addtag"
    SlashCmdList["ADDTAG"] = function(label) self:SlashNewTag(label) end

    SLASH_REMOVETAG1 = "/removetag"
    SlashCmdList["REMOVETAG"] = function(label) self:RemoveTag(label) end

    -- Callbacks / Events etc.

    self:RegisterAllBagSlotsForOnClick()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    GameTooltip:HookScript("OnTooltipSetItem", TagitAddonMixin.OnTooltipSetItem)
    GameTooltip:HookScript("OnTooltipCleared", TagitAddonMixin.OnTooltipCleared)
end

function TagitAddonMixin:OnPlayerEnteringWorld()
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
function TagitAddonMixin:SlashNewTag(argString)
    local args = Addon.Util:SplitArgs(argString)
    return self:NewTag(args[1], args[2])
end

function TagitAddonMixin:NewTag(label, guid)
    if(not label) then
        UIErrorsFrame:AddExternalErrorMessage("Cannot add a tag with no label!")
        return
    end
    Addon.TagList:InsertTag(guid, label)
end

function TagitAddonMixin:RemoveTag(label)
    local predicate = function(tag) return tag.Label == label end
    if(not Addon.TagList:ContainsByPredicate(predicate)) then
        UIErrorsFrame:AddExternalErrorMessage("Cannot find a tag '" .. label .. "'")
    end
    Addon.TagList:RemoveByPredicate(predicate)
end

function TagitAddonMixin.OnTooltipSetItem(tooltip, ...)
    if not TagitAddonMixin.LineAdded then
        local tag = Addon.TagList:FindElementDataByItem(tooltip:GetItem())

        if(tag) then
            tooltip:AddLine(tag.Label)
            TagitAddonMixin.LineAdded = true
        end
    end
end

function TagitAddonMixin.OnTooltipCleared(tooltip, ...)
    TagitAddonMixin.LineAdded = false
end

-- Update the database and trigger a UI Refresh
function TagitAddonMixin:OnItemSelectedForMarking(itemID)
    local tagIndex = Addon.TagList:FindIndexByItemID(itemID)
    if(not tagIndex) then
        Addon.TagList:SetItemIDFromTagIndex(itemID, 1)
    else
        Addon.TagList:SetItemIDFromTagIndex(itemID, tagIndex + 1)
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
