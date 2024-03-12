concommand.Add("om_menu_open", function() Opmenu:OpenPanel() end, nil, "Opens options menu")

function Opmenu:AddOption(newOptions)
    for addonName, addonInfo in pairs(newOptions) do
        self.existingExternalOptions[addonName] = {
            name = addonInfo.name,
            description = addonInfo.description,
            icon = addonInfo.icon,
            workshop = addonInfo.workshop,
            version = addonInfo.version,
            server_options = addonInfo.server_options and addonInfo.server_options.options or {},
            client_options = addonInfo.client_options and addonInfo.client_options.options or {}
        }

        -- Handling options for both server and client
        for optionType, optionData in pairs{server_options = addonInfo.server_options, client_options = addonInfo.client_options} do
            if optionData then
                self.existingExternalOptions[addonName][optionType] = {}
                for categoryName, categoryOptions in pairs(optionData.options) do
                    self.existingExternalOptions[addonName][optionType][categoryName] = {}
                    for optionName, optionData in pairs(categoryOptions) do
                        self.existingExternalOptions[addonName][optionType][categoryName][optionName] = optionData
                        if optionData.conVar ~= nil and not GetConVar(optionData.conVar) then
                            Opmenu:createConVar(optionType, optionData.conVar, optionData.default, optionData.min, optionData.max, optionData.flags, LocalPlayer())
                        end
                    end
                end
            end
        end
    end
end

function Opmenu:PrintError(num, addonName, categoryName, categoryInfo, conVar, optionType)
    local errorMessages = {
        "[Simple Addon Options] Error 1: No options are instaled",
        "[Simple Addon Options] Error 2: Two or more addon have the same name!",
        "[Simple Addon Options] Error 3: Couldn't load addon icon for " .. tostring(addonName) .. ". File is missing?",
        "[Simple Addon Options] Error 4: Invalid workshop link! Addon: " .. tostring(addonName),
        "[Simple Addon Options] Error 5: Invalid version! Addon: " .. tostring(addonName),
        "[Simple Addon Options] Error 6: Table" .. tostring(addonName) .. "not found in existingExternalOptions",
        "[Simple Addon Options] Error 7: Invalid category icon for " .. tostring(addonName) .. " => " .. tostring(optionType) .. " => " .. tostring(categoryName),
        "[Simple Addon Options] Error 8: ConVar " .. tostring(conVar) .." doesn't exist!",
        "[Simple Addon Options] Error 9: Max or Min valuse in " .. tostring(addonName) .. " => " .. tostring(optionType) .. " => " .. tostring(categoryName) .. " => " .. tostring(conVar) .. " is NIL!",
        "[Simple Addon Options] Error 10: Default value can't be lower than minimal value! " .. tostring(addonName) .. " => " .. tostring(optionType) .. " => " .. tostring(categoryName) .. " => " .. tostring(conVar),
        "[Simple Addon Options] Error 11: Invalid option type in " .. tostring(addonName) .. " => " .. tostring(optionType) .. " => " .. tostring(categoryName) .. " => " .. tostring(conVar),
    }

    local errorMessage = errorMessages[num]
    if errorMessage then
        print(errorMessage)
    else
        print("[Simple Addon Options] Error: Invalid error number provided.")
    end
end

function Opmenu:CheckForDuplicates()
    local addonNames = {}
    for key, addonInfo in pairs(self.existingExternalOptions) do
        if addonNames[addonInfo.name] then
            return true
        else
            addonNames[addonInfo.name] = true
        end
    end
    return false
end