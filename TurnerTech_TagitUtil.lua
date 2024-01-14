local name, addon = ...

addon.Debug = true
addon.Util = {}

if(addon.Debug) then
	UIParentLoadAddOn("Blizzard_DebugTools");
end

function addon.Util:SplitArgs(argString)
    local args = {}
    for word in string.gmatch(argString, '([^,]+)') do
		table.insert(args, word)
	end
    return args
end

function addon.Util:Print(text)
	if(addon.Debug) then
		print(text)
	end
end