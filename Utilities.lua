local name, addon = ...

addon.TurnerTech = {}

function addon.TurnerTech:SplitArgs(argString)
    local args = {}
    for word in string.gmatch(argString, '([^,]+)') do
		table.insert(args, word)
	end
    return args
end