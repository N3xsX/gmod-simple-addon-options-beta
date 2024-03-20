Opmenu = {}
Opmenu.existingExternalOptions = {}

local filePath = "sao_presets.txt"

if file.Exists(filePath, "DATA") then
    print("[Simple Addon Options] Loaded presets.txt successfully.")
else
    local fileHandle = file.Open(filePath, "w", "DATA")
    
    if fileHandle then
        fileHandle:Close()
        print("[Simple Addon Options] File presets.txt created successfully.")
    else
        print("[Simple Addon Options] Error: Unable to create file presets.txt.")
    end
end

if SERVER then
    include( "server/sv_om_main.lua" )
    AddCSLuaFile( "client/cl_om_main.lua" )
    AddCSLuaFile( "client/cl_om_misc.lua" )
    AddCSLuaFile( "client/cl_om_presets.lua" )
end

if CLIENT then
    include( "server/sv_om_main.lua" )
    include( "client/cl_om_main.lua" )
    include( "client/cl_om_misc.lua" )
    include( "client/cl_om_presets.lua" )
end

CreateClientConVar("cl_sao_enable_error", "1", true, false, "Enable error messages")
CreateClientConVar("cl_sao_img_size", "2", true, false, "Icon size inside options menu")
CreateClientConVar("cl_sao_enable_debug", "1", true, false, "Enable debug information in options")