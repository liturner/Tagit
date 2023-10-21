local name, Addon = ...

TagitOptionsMixin = {
	name = name,
}

function TagitOptionsMixin:OnLoad()
	self.TestListView:SetDataProvider(Addon.TagList)

	self.AddKeyButton:HookScript("OnClick", function() self:OnAddClicked() end)
	self.AddKeyEditBox:HookScript("OnTextChanged", function(editBox) self:OnTextChanged(editBox) end)

	InterfaceOptions_AddCategory(self)
end

function TagitOptionsMixin:OnAddClicked()

end

function TagitOptionsMixin:OnTextChanged(editBox)
	if(editBox:IsTagExisting()) then
		self.AddKeyButton:SetEnabled(false)
	else
		self.AddKeyButton:SetEnabled(true)
	end
end

AddKeyEditBoxMixin = {}

function AddKeyEditBoxMixin:OnTextChanged(userInput)
	if(self:IsTagExisting()) then
		self:SetTextColor(1.0, 0, 0)
	else
		self:SetTextColor(1.0, 1.0, 1.0)
	end
end

function AddKeyEditBoxMixin:IsTagExisting()
	return Addon.Tags:GetTagFromTagLabel(self:GetText()) ~= nil
end