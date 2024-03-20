local sandboxoptions = {
    sandboxoptions = {
        name = "Sandbox Settings",
        description = "",
        icon = "materials/gmod.png",
        version = "1.0.2",
        server_options = {
        options = {
            category1 = {
                name = "General",
                icon = "icon16/cog.png",
                option2 = {
                    name = "Gravity",
                    description = "Sets the gravity level for the server",
                    type = "slider",
                    conVar = "sv_gravity",
                    default = 600,
                    min = 1,
                    max = 10000,
                    dec = 0,
                    flags = {}
                },
                option3 = {
                    name = "Acceleration",
                    description = "Sets the acceleration level for players",
                    type = "slider",
                    conVar = "sv_accelerate",
                    default = 10,
                    min = 1,
                    max = 10000,
                    dec = 0,
                    flags = {}
                },
                option4 = {
                    name = "Noclip speed",
                    description = "Sets the speed of players in noclip mode",
                    type = "slider",
                    conVar = "sv_noclipspeed",
                    default = 5,
                    min = 1,
                    max = 10000,
                    dec = 0,
                    flags = {}
                },
                option5 = {
                    name = "Realistic falldamage",
                    description = "Toggles realistic falldamage",
                    type = "checkbox",
                    conVar = "mp_falldamage",
                    default = 0,
                    flags = {}
                },
            },
        },
    },
        client_options = {
            options = {
                category1 = {
                    name = "General",
                    icon = "icon16/cog.png",
                    option1 = {
                        name = "Noclip",
                        description = "Enables free movement through the game world, useful for exploration and building",
                        type = "button",
                        buttonType = "command",
                        buttonCommand = "noclip",
                        buttonName = "Turn on/off",
                    },
                    option2 = {
                        name = "God",
                        description = "Toggles god mode, making the player invincible to damage",
                        type = "button",
                        buttonType = "command",
                        buttonCommand = "god",
                        buttonName = "Turn on/off",
                    },
                    option3 = {
                        name = "Thirdperson",
                        description = "Toggles third-person view mode",
                        type = "button",
                        buttonType = "command",
                        buttonCommand = "thirdperson",
                        buttonName = "Turn on",
                    },
                    option4 = {
                        name = "Firstperson",
                        description = "Toggles first-person view mode",
                        type = "button",
                        buttonType = "command",
                        buttonCommand = "firstperson",
                        buttonName = "Turn on",
                    },
                },
                category2 = {
                    name = "Client Sliders",
                    option1 = {
                        name = "Opcja 1 client sl",
                        description = "super fajna dluga opcja ktora cos robi\n lolololol\n xddddddddddddddddd",
                        type = "slider",
                        conVar = "cl_slider1",
                        min = 0,
                        max = 100,
                        default = 50,
                        flags = {}
                    },
                }
            }
        }
    }
}


Opmenu:AddOption(sandboxoptions)