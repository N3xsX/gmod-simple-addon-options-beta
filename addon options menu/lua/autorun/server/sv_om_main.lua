local createdConVars = {}

function Opmenu:createConVar(type, conVar, def, min, max, flags)
    local flag
    if flags == nil then flag = "FCVAR_NONE" else flag = table.concat(flags, ", ") end
    if type == "server_options" then
        CreateConVar(conVar, def, flag, "", min, max)
    elseif type == "client_options" then
        CreateClientConVar(conVar, def, true, false, "", min, max)
    end
    if not createdConVars[conVar] then
        createdConVars[conVar] = {
            type = type,
            def = def,
            min = min,
            max = max,
            flags = flags
        }
    end
end

/*hook.Add( "PlayerInitialSpawn", "CreateSAOconVars", function( ply )
    PrintTable(createdConVars)
    if ply:IsAdmin() then
        for conVar, data in pairs(createdConVars) do
            local type = data.type
            local def = data.def
            local min = data.min
            local max = data.max
            local flags = data.flags

            if conVar ~= nil and not GetConVar(conVar) then
                local flag
                if flags == nil then flag = "FCVAR_NONE" else flag = flags end
                if type == "server_options" then
                    CreateConVar(conVar, def, flag, "", min, max)
                elseif type == "client_options" then
                    CreateClientConVar(conVar, def, true, false, "", min, max)
                end
                print(conVar, def, flag, "", min, max)
            end
        end
    end
end)*/