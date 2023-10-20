local name, addon = ...

Mixin(addon, CallbackRegistryMixin)

addon:GenerateCallbackEvents({
    "Tag_Added",
    "Tag_Removed"
})

CallbackRegistryMixin.OnLoad(addon)