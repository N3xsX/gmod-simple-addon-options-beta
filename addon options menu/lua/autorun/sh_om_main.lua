Opmenu = {}
Opmenu.existingExternalOptions = {}

if SERVER then
    include( "server/sv_om_main.lua" )
    AddCSLuaFile( "client/cl_om_main.lua" )
    AddCSLuaFile( "client/cl_om_functions.lua" )
end

if CLIENT then
    include( "server/sv_om_main.lua" )
    include( "client/cl_om_main.lua" )
    include( "client/cl_om_functions.lua" )
end

CreateClientConVar("cl_sao_enable_error", "1", true, false, "Enable error messages")
CreateClientConVar("cl_sao_img_size", "2", true, false, "Icon size inside options menu")
