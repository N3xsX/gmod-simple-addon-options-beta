local function GenerateConVar(addonName, type, conVar, def, min, max, flags)
    local flag
    if flags == nil or flags == "" then flag = "FCVAR_NONE" else flag = table.concat(flags, ", ") end
    if max == nil then max = "nil" end
    if min == nil then min = "nil" end
    if type == "server_options" then
        print('CreateConVar("'.. conVar .. '", ' .. def .. ', {' .. flag .. '}, "" , ' .. min .. ', ' .. max .. ')')
    elseif type == "client_options" then
        print('CreateClientConVar("'.. conVar .. '", ' .. def .. ', true, false, "", ' .. min .. ', ' .. max .. ')')
    end
end

function Opmenu:AddOption(newOptions)
    for addonName, addonInfo in pairs(newOptions) do
        self.existingExternalOptions[addonName] = {
            name = addonInfo.name,
            description = addonInfo.description,
            icon = addonInfo.icon,
            workshop = addonInfo.workshop,
            version = addonInfo.version,
            autoGenerateConvars = addonInfo.autoGenerateConvars,
            customMenu = addonInfo.customMenu,
            customMenuHook = addonInfo.customMenuHook,
            server_options = addonInfo.server_options and addonInfo.server_options.options or {},
            client_options = addonInfo.client_options and addonInfo.client_options.options or {}
        }

        for optionType, optionData in pairs{server_options = addonInfo.server_options, client_options = addonInfo.client_options} do
            if optionData then
                self.existingExternalOptions[addonName][optionType] = {}
                for categoryName, categoryOptions in pairs(optionData.options) do
                    self.existingExternalOptions[addonName][optionType][categoryName] = {}
                    for optionName, optionData in pairs(categoryOptions) do
                        self.existingExternalOptions[addonName][optionType][categoryName][optionName] = optionData
                        if optionData.conVar ~= nil and optionData.default ~= nil and not GetConVar(optionData.conVar) and addonInfo.autoGenerateConvars == true then
                            GenerateConVar(addonInfo.name, optionType, optionData.conVar, optionData.default, optionData.min, optionData.max, optionData.flags)
                        end
                    end
                end
            end
        end
    end
end