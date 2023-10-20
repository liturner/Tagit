local name, Addon = ...

TagitOptionsMixin = {
	name = name,
}

function TagitOptionsMixin:OnLoad()
	self.AddKeyButton:SetScript("OnClick", function() self:OnAddClicked() end)
	InterfaceOptions_AddCategory(self)
end

function TagitOptionsMixin:OnAddClicked()
	if(self.AddKeyEditBox:IsTagExisting()) then
		UIErrorsFrame:AddExternalErrorMessage("Cannot add a tag. It already exists!")
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