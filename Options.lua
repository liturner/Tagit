local name, addon = ...

TagitOptionsMixin = {
	name = name,
}

function TagitOptionsMixin:OnLoad()
	InterfaceOptions_AddCategory(self)
end

function TagitOptionsMixin:OnAddTag()
	Tagit_Addon:NewTag("From The GUI", 12037)
end