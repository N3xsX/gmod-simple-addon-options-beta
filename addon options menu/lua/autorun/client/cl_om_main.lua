local popupFrame
local mainFrame

function Opmenu:OpenPanel()
    if IsValid(self.frame) then
        self.frame:Close()
        self.frame = nil
        return
    end

    local frameW = math.max(ScrW() * 0.6, 820)
    local frameH = math.max(ScrH() * 0.6, 500)

    frameW = math.Clamp(frameW, 600, ScrW())
    frameH = math.Clamp(frameH, 400, ScrH())

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Simple Addon Options")
    frame:SetSize(frameW, frameH)
    frame:SetSizable(true)
    frame:SetDraggable(true)
    frame:SetDeleteOnClose(true)
    frame:SetScreenLock(true)
    frame:SetMinWidth(600)
    frame:SetMinHeight(400)
    frame:MakePopup()

    mainFrame = frame

    local screenWidth, screenHeight = ScrW(), ScrH()
    local posX = (screenWidth - frameW) / 2
    local posY = (screenHeight - frameH) / 2
    frame:SetPos(posX, posY)

    self.frame = frame

    -- search bar
    local searchBar = vgui.Create("DTextEntry", frame)
    local searchBarSize = frameW * 0.25
    local searchBarX = frameW * 0.5 - searchBarSize * 0.5
    searchBar:SetPos(searchBarX, 30)
    searchBar:SetSize(searchBarSize, 30)
    searchBar:SetPlaceholderText("Search for addons...")
    searchBar.OnEnter = function(self)
        local searchText = self:GetText()
        --print("Searching for:", searchText)
        self:SetUpdateOnType(true)
    end

    -- error icon/button
    function Opmenu:createError(num, addonName, categoryName, categoryInfo, conVar, optionType)
        if GetConVar("cl_sao_enable_error"):GetBool() == false then return end
        frame.OnClose = function()
            self.enabled = false
        end
        Opmenu:PrintError(num, addonName, categoryName, categoryInfo, conVar, optionType)
        if not self.enabled then
        local button = vgui.Create("DButton", frame)
        button:SetText("")
        button:SetSize(30, 30)
        button:SetPos(10, 30)
        button:SetImage("icon16/error.png")
        self.enabled = true
        button.DoClick = function()
            notification.AddLegacy( "[SAO] Check Console", NOTIFY_ERROR, 4 )
            surface.PlaySound( "buttons/button15.wav" )
            self.enabled = false
            button:Remove()
        end
        end
    end

    --SAO Options button
    local button = vgui.Create("DButton", frame)
    button:SetText("")
    button:SetSize(30, 30)
    button:SetPos(frameW - 40, 30)
    button:SetImage("icon16/cog.png")
    button.DoClick = function()
        local popup = vgui.Create("DFrame")
        popup:SetSize(300, 150)
        popup:SetTitle("Options")
        popup:Center()
        popup:MakePopup()
        local whitePanel = vgui.Create("DPanel", popup)
        whitePanel:SetSize(280, 110)
        whitePanel:SetPos(10, 30)
        whitePanel:SetBackgroundColor(Color(255, 255, 255))
        local checkBox = vgui.Create("DCheckBox", whitePanel)
        checkBox:SetPos(125, 10)
        checkBox:SetValue(GetConVar("cl_sao_enable_error"):GetInt())
        checkBox.OnChange = function(self, isChecked)
            RunConsoleCommand("cl_sao_enable_error", isChecked and "1" or "0")
        end
        local checkBoxLabel = vgui.Create("DLabel", whitePanel)
        checkBoxLabel:SetPos(10, 8)
        checkBoxLabel:SetText("Toggle Error Messages")
        checkBoxLabel:SetWide(150)
        checkBoxLabel:SetTextColor(Color(0, 0, 0))
        local comboBox = vgui.Create("DComboBox", whitePanel)
        comboBox:SetPos(60, 30)
        comboBox:SetSize(70, 20)
        local comboBoxLabel = vgui.Create("DLabel", whitePanel)
        comboBoxLabel:SetPos(11, 30)
        comboBoxLabel:SetText("Icon size")
        comboBoxLabel:SetWide(150)
        comboBoxLabel:SetTextColor(Color(0, 0, 0))
        local imgSize = GetConVar("cl_sao_img_size"):GetInt()
        comboBox:SetValue(imgSize == 1 and "Small" or imgSize == 2 and "Medium" or imgSize == 3 and "Large")
        comboBox:AddChoice("Small")
        comboBox:AddChoice("Medium")
        comboBox:AddChoice("Large")
        comboBox.OnSelect = function(_, index, value, data)
            RunConsoleCommand("cl_sao_img_size", index)
        end
        mainFrame.OnClose = function()
            if IsValid(popup) then
                popup:Close()
                popup = nil
            end
        end
    end

    local cbutton = vgui.Create("DButton", frame)
    cbutton:SetText("    Load Preset")
    cbutton:SetSize(130, 30)
    cbutton:SetPos(frameW - button:GetWide() - 140, 30)
    cbutton:SetImage("icon16/table_go.png")
    cbutton.DoClick = function()
  
    end

    local buttonSize = GetConVar("cl_sao_img_size"):GetInt()
    local buttonSizeMap = { [1] = 0.9, [2] = 1.1, [3] = 1.3 }
    local buttonSizeSelect = buttonSizeMap[buttonSize]

    local buttonSizeX = 100 * buttonSizeSelect
    local buttonSizeY = 130 * buttonSizeSelect
    local buttonSpacing = 10

    local buttons = {}
    local currentY = buttonSpacing + 45
    local labelText = ""

    local currentRowWidth = 0
    local currentRowHeight = 0
    local rows = {}
    local currentRow = {}

    local buttonsPerRow = math.floor((frameW - buttonSpacing) / (buttonSizeX + buttonSpacing))

    local function positionButtons(buttons)
    
        for _, button in ipairs(buttons) do
            if currentRowWidth + buttonSizeX + buttonSpacing > frameW or #currentRow >= buttonsPerRow then
                table.insert(rows, currentRow)
                currentRow = {}
                currentRowWidth = 0
                currentRowHeight = 0
                currentY = currentY + buttonSizeY + buttonSpacing
            end
    
            button:SetPos(currentRowWidth + buttonSpacing, currentY)
            currentRowWidth = currentRowWidth + buttonSizeX + buttonSpacing
            currentRowHeight = math.max(currentRowHeight, buttonSizeY)
            table.insert(currentRow, button)
        end
    
        table.insert(rows, currentRow)
    
        --local startY = (frameH - (#rows * (buttonSizeY + buttonSpacing) - buttonSpacing)) / 2
        local startY = 20
        for _, row in ipairs(rows) do
            local startX = (frameW - (math.min(#row, buttonsPerRow) * (buttonSizeX + buttonSpacing) - buttonSpacing)) / 2 - 10
            for _, button in ipairs(row) do
                button:SetPos(startX, startY)
                startX = startX + buttonSizeX + buttonSpacing
            end
            startY = startY + buttonSizeY + buttonSpacing
        end
    
        --frame:SetTall(math.max(currentY + currentRowHeight + buttonSpacing, frameH))
    end

    local function positionFilteredButtons(buttons)
        local visibleButtons = {}
        local currentY = buttonSpacing + 45
        local currentRowWidth = 0
        local currentRowHeight = 0
        local rows = {}
        local currentRow = {}
    
        for _, button in ipairs(buttons) do
            if button:IsVisible() then
                table.insert(visibleButtons, button)
                if currentRowWidth + buttonSizeX + buttonSpacing > frameW or #currentRow >= buttonsPerRow then
                    table.insert(rows, currentRow)
                    currentRow = {}
                    currentRowWidth = 0
                    currentRowHeight = 0
                    currentY = currentY + buttonSizeY + buttonSpacing
                end
    
                button:SetPos(currentRowWidth + buttonSpacing, currentY)
                currentRowWidth = currentRowWidth + buttonSizeX + buttonSpacing
                currentRowHeight = math.max(currentRowHeight, buttonSizeY)
                table.insert(currentRow, button)
            end
        end
    
        table.insert(rows, currentRow)
    
        local startY = 20
        for _, row in ipairs(rows) do
            local startX = (frameW - (math.min(#row, buttonsPerRow) * (buttonSizeX + buttonSpacing) - buttonSpacing)) / 2 - 5
            for _, button in ipairs(row) do
                button:SetPos(startX, startY)
                startX = startX + buttonSizeX + buttonSpacing
            end
            startY = startY + buttonSizeY + buttonSpacing
        end
    
        --frame:SetTall(math.max(currentY + currentRowHeight + buttonSpacing, frameH))
    end
    
    
    local function filterAddons(searchText)
        local visibleButtons = {}
        local foundAny = false
        for _, button in ipairs(buttons) do
            local buttonName = button.Name
            local isVisible = string.find(buttonName, searchText:lower()) ~= nil
            button:SetVisible(isVisible)
            if isVisible then
                table.insert(visibleButtons, button)
                foundAny = true
            end
        end
    
        if searchText ~= "" then
            if not foundAny then
                if not IsValid(nothingFoundLabel) then
                    nothingFoundLabel = vgui.Create("DLabel", frame)
                    nothingFoundLabel:SetText("Nothing found!")
                    nothingFoundLabel:SetTextColor(Color(0, 0, 0))
                    nothingFoundLabel:SetFont("saoCustomFont")
                    nothingFoundLabel:SizeToContents()
                    nothingFoundLabel:SetWide(300)
                    nothingFoundLabel:SetPos(frameW * 0.55 - nothingFoundLabel:GetWide() * 0.5, frameH * 0.2)
                end
            elseif IsValid(nothingFoundLabel) then
                nothingFoundLabel:Remove()
                nothingFoundLabel = nil
            end
        else
            searchBar:SetText("")
            for _, button in ipairs(buttons) do
                button:SetVisible(true)
            end
    
            if IsValid(nothingFoundLabel) then
                nothingFoundLabel:Remove()
                nothingFoundLabel = nil
            end
        end
    
        positionFilteredButtons(visibleButtons)
    end
    
    searchBar.OnTextChanged = function(self)
        local searchText = self:GetText()
        filterAddons(searchText)
    end

    local function CenterText(panel, text, buttonSizeX, buttonSizeY)
        local extractedText = ""
        surface.SetFont( "saoCustomFont" )
        local textWidth, textHeight = surface.GetTextSize(text)
        local posX = (buttonSizeX - textWidth) / 2
        local posY = buttonSizeY - 40

        if textWidth > buttonSizeX + 80 then
            local lines = {}
            local currentLine = ""
            for word in text:gmatch("%S+") do
                local tempLine = currentLine == "" and word or currentLine .. " " .. word
                if surface.GetTextSize(tempLine) <= buttonSizeX + 80 then
                    currentLine = tempLine
                else
                    table.insert(lines, currentLine)
                    currentLine = word
                end
            end
            table.insert(lines, currentLine)
            for _, lineText in ipairs(lines) do
                local lineTextWidth, _ = surface.GetTextSize(lineText)
                local linePosX = (buttonSizeX - lineTextWidth) / 2
                local label = vgui.Create("DLabel", panel)
                label:SetText(lineText)
                label:SetFont("DermaDefaultBold")
                label:SetColor(Color(0, 0, 0))
                label:SetPos(linePosX, posY)
                label:SetContentAlignment(5)
                label:SetSize(lineTextWidth, textHeight)
                posY = posY + 10
                extractedText = extractedText .. lineText .. "\n"
            end
        else
            local label = vgui.Create("DLabel", panel)
            label:SetText(text)
            label:SetFont("DermaDefaultBold")
            label:SetColor(Color(0, 0, 0))
            label:SetPos(posX, posY)
            label:SetSize(textWidth, textHeight)
            label:SetContentAlignment(5)
            extractedText = text
        end

        labelText = extractedText

    end

    local function createButtons()
        for addonName, addonInfo in pairs(self.existingExternalOptions) do
            local button = vgui.Create("DButton", frame)
            button:SetText("")

            button.Paint = function(self, w, h)
                surface.SetDrawColor(194, 193, 192, 255)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(158, 157, 157, 255)
                local borderSize = 2
                surface.DrawRect(0, 0, w, borderSize)
                surface.DrawRect(0, h - borderSize, w, borderSize)
                surface.DrawRect(0, 0, borderSize, h)
                surface.DrawRect(w - borderSize, 0, borderSize, h)
            end
            button.Name = addonInfo.name

            if addonInfo.name == nil then return end
            CenterText(button, addonInfo.name, buttonSizeX, buttonSizeY)
    
            button:SetSize(buttonSizeX, buttonSizeY)

            if addonInfo.icon and addonInfo.icon ~= "none" then
                local icon = vgui.Create("DImage", button)
                icon:SetPos(5, 5)
                icon:SetSize(90 * buttonSizeSelect, 90 * buttonSizeSelect)
                if file.Exists(addonInfo.icon, "GAME") then
                    icon:SetImage(addonInfo.icon)
                else
                    Opmenu:createError(3, addonInfo.name)
                    icon:SetImage("noimg.png")
                end
            else
                local placeholderIcon = vgui.Create("DImage", button)
                placeholderIcon:SetPos(5, 5)
                placeholderIcon:SetSize(90 * buttonSizeSelect, 90 * buttonSizeSelect)
                placeholderIcon:SetImage("noimg.png")
            end
            button.OnMousePressed = function(self, key)
                if key == MOUSE_RIGHT then
                    local menu = DermaMenu()
                    local doption = menu:AddOption("Description", function()
                        local popup = vgui.Create("DFrame")
                        popup:SetSize(300, 150)
                        popup:SetTitle("DES")
                        popup:Center()
                        popup:MakePopup()
                    end)
                    doption:SetImage("icon16/information.png")
                    if addonInfo.workshop ~= nil and not string.match(addonInfo.workshop, "^https://steamcommunity.com/sharedfiles") then
                        Opmenu:createError(4, addonInfo.name)
                    end
                    if addonInfo.workshop and addonInfo.workshop ~= "" and string.match(addonInfo.workshop, "^https://steamcommunity.com/sharedfiles") then
                        local option = menu:AddOption("Open Workshop Page", function()
                            gui.OpenURL(addonInfo.workshop)
                        end)
                        option:SetImage("icon16/world_link.png")
                    end
                    if addonInfo.version == nil then
                        local voption = menu:AddOption("Version: N/A")
                        Opmenu:createError(5, addonInfo.name)
                        --voption:SetImage("icon16/application_xp_terminal.png")
                    else
                        local voption = menu:AddOption("Version: " .. addonInfo.version)
                        --voption:SetImage("icon16/application_xp_terminal.png")
                    end
                    menu:Open()
                elseif key == MOUSE_LEFT then
                    --print("Button Clicked for Addon: " .. addonName)
                    Opmenu:CreateOptionUI(addonInfo.name, addonName)
                end
            end
    
            table.insert(buttons, button)
        end
        
        local totalButtonHeight = 0
        for _, button in ipairs(buttons) do
            totalButtonHeight = totalButtonHeight + buttonSizeY + buttonSpacing
        end
    
        local scrollPanel = vgui.Create("DScrollPanel", frame)
        scrollPanel:SetSize(frameW - 20, frameH - frameH * 0.12)
        scrollPanel:SetPos((frameW - scrollPanel:GetWide()) / 2, frameH - frameH * 0.9)
    
        local scrollBar = scrollPanel:GetVBar()
        scrollBar:SetWide(0)
    
        local innerPanel = vgui.Create("DPanel", scrollPanel)
        innerPanel:SetWide(scrollPanel:GetWide())
        innerPanel:SetTall(totalButtonHeight)
    
        local startX = (frameW - buttonSizeX) / 2
        local startY = 0
        for _, button in ipairs(buttons) do
            button:SetParent(innerPanel)
            button:SetPos(startX, startY)
            startY = startY + buttonSizeY + buttonSpacing
        end
    
        return buttons, scrollPanel
    end

    if next(self.existingExternalOptions) == nil then
        Opmenu:createError(1)
        return
    end

    local buttons = createButtons()
    positionButtons(buttons)

    if Opmenu:CheckForDuplicates() then
        Opmenu:createError(2)
    end

end

function Opmenu:CreateOptionUI(addonName, tableName)
    if IsValid(popupFrame) then
        popupFrame:Close()
        popupFrame = nil
    end
    local frameW = math.max(ScrW() * 0.5, 820)
    local frameH = math.max(ScrH() * 0.5, 500)

    frameW = math.Clamp(frameW, 600, ScrW())
    frameH = math.Clamp(frameH, 400, ScrH())

    local frame = vgui.Create("DFrame")
    frame:SetTitle(addonName .. " Options")
    frame:SetSize(frameW, frameH)
    frame:SetSizable(true)
    frame:SetDraggable(true)
    frame:SetDeleteOnClose(true)
    frame:SetScreenLock(true)
    frame:SetMinWidth(600)
    frame:SetMinHeight(400)
    frame:MakePopup()

    local screenWidth, screenHeight = ScrW(), ScrH()
    local posX = (screenWidth - frameW) / 2
    local posY = (screenHeight - frameH) / 2
    frame:SetPos(posX, posY)

    self.frame = frame

    local leftOptionButtonPanel = vgui.Create("DPanel", frame)
    leftOptionButtonPanel:SetSize(frameW * 0.5 - 10, frameH * 0.9)
    leftOptionButtonPanel:SetPos(10, 30)
    leftOptionButtonPanel:SetBackgroundColor(Color(255, 255, 255))

    self.leftOptionButton = vgui.Create("DImageButton", leftOptionButtonPanel)
    self.leftOptionButton:SetImage("srvic.png")
    self.leftOptionButton:SetSize(leftOptionButtonPanel:GetWide() * 0.8, leftOptionButtonPanel:GetTall() * 0.8)
    self.leftOptionButton:SetPos(50, 40)
    self.leftOptionButton.DoClick = function()
        leftOptionButtonPanel:SetVisible(false)
        self.rightOptionButtonPanel:SetVisible(false)
        self.backButton:SetVisible(true)
        self.leftPanel, self.leftWhitePanel, self.rightPanel, self.rightWhitePanel = Opmenu:CreateOptionPanels(frame, tableName, "server")
    end

    local buttonTextHeight = 70
    local leftLabel = vgui.Create("DLabel", leftOptionButtonPanel)
    leftLabel:SetText("Server Options")
    leftLabel:SetSize(leftOptionButtonPanel:GetWide(), buttonTextHeight)
    leftLabel:SetContentAlignment(5)
    leftLabel:SetFont("saoCustomFont")
    leftLabel:SetTextColor(Color(0, 0, 0))
    leftLabel:SetPos(10, leftOptionButtonPanel:GetTall() - buttonTextHeight)

    self.rightOptionButtonPanel = vgui.Create("DPanel", frame)
    self.rightOptionButtonPanel:SetSize(frameW * 0.5 - 20, frameH * 0.9)
    self.rightOptionButtonPanel:SetPos(frameW * 0.5 + 10, 30)
    self.rightOptionButtonPanel:SetBackgroundColor(Color(255, 255, 255))

    self.rightOptionButton = vgui.Create("DImageButton", self.rightOptionButtonPanel)
    self.rightOptionButton:SetImage("test.png")
    self.rightOptionButton:SetSize(self.rightOptionButtonPanel:GetWide() * 0.8, self.rightOptionButtonPanel:GetTall() * 0.8)
    self.rightOptionButton:SetPos(50, 40)
    self.rightOptionButton.DoClick = function()
        leftOptionButtonPanel:SetVisible(false)
        self.rightOptionButtonPanel:SetVisible(false)
        self.backButton:SetVisible(true)
        self.leftPanel, self.leftWhitePanel, self.rightPanel, self.rightWhitePanel = Opmenu:CreateOptionPanels(frame, tableName, "client")
    end

    local rightLabel = vgui.Create("DLabel", self.rightOptionButtonPanel)
    rightLabel:SetText("Client Options")
    rightLabel:SetSize(self.rightOptionButtonPanel:GetWide(), buttonTextHeight)
    rightLabel:SetContentAlignment(5)
    rightLabel:SetFont("saoCustomFont")
    rightLabel:SetTextColor(Color(0, 0, 0))
    rightLabel:SetPos(10, self.rightOptionButtonPanel:GetTall() - buttonTextHeight)

    self.backButton = vgui.Create("DButton", frame)
    self.backButton:SetText("Back")
    self.backButton:SetImage("icon16/arrow_left.png")
    self.backButton:SetSize(frameW * 0.2 - 3, 30)
    self.backButton:SetPos(10, 30)
    self.backButton:SetVisible(false)
    self.backButton.DoClick = function()
        leftOptionButtonPanel:SetVisible(true)
        self.rightOptionButtonPanel:SetVisible(true)
        self.backButton:SetVisible(false)
        if IsValid(self.leftPanel) then
            self.leftPanel:Remove()
            self.leftWhitePanel:Remove()
        end
        if IsValid(self.rightPanel) then
            self.rightPanel:Remove()
            self.rightWhitePanel:Remove()
        end
    end

    if self.existingExternalOptions[tableName] then
        if not self.existingExternalOptions[tableName].server_options then
            self.leftOptionButton:SetEnabled(false)
            leftLabel:SetTextColor(Color(150, 150, 150))
        end
    
        if not self.existingExternalOptions[tableName].client_options then
            self.rightOptionButton:SetEnabled(false)
            rightLabel:SetTextColor(Color(150, 150, 150))
        end
    else
        Opmenu:createError(6, tableName)
    end

    popupFrame = frame

    mainFrame.OnClose = function()
        if IsValid(popupFrame) then
            popupFrame:Close()
            popupFrame = nil
        end
    end

end

function Opmenu:CreateOptionPanels(frame, addonName, optionType)
    local frameW, frameH = frame:GetSize()

    local leftPanel = vgui.Create("DScrollPanel", frame)
    leftPanel:SetSize(frameW * 0.2, frameH * 0.8)
    leftPanel:SetPos(10, 97)
    leftPanel:GetVBar():SetWide(0)
    local leftWhitePanel = vgui.Create("DPanel", leftPanel)
    leftWhitePanel:SetSize(frameW * 0.2 - 5, frameH - 40)
    leftWhitePanel:SetBackgroundColor(Color(255, 255, 255))

    local rightPanel = vgui.Create("DScrollPanel", frame)
    rightPanel:SetSize(frameW * 0.79, frameH - 40)
    rightPanel:SetPos(frameW * 0.21, 30)
    rightPanel:GetVBar():SetWide(0)
    local rightWhitePanel = vgui.Create("DPanel", rightPanel)
    rightWhitePanel:SetSize(frameW * 0.79 - 5, frameH - 40)
    rightWhitePanel:SetBackgroundColor(Color(255, 255, 255))

    local categories = {}
    local optionsTable = {}
    if optionType == "server" then
        optionsTable = self.existingExternalOptions[addonName].server_options
    elseif optionType == "client" then
        optionsTable = self.existingExternalOptions[addonName].client_options
    end

    if optionsTable then
        for categoryName, categoryData in pairs(optionsTable) do
            if not categories[categoryName] then
                categories[categoryName] = categoryData.name
            end
        end
    end

    -- create buttons for each category
    local selectedButton = nil
    local posY = 5
    local buttonSizeY = 70
    local optionButtons = {}
    for categoryName, displayName in pairs(categories) do
        local categoryButton = vgui.Create("DButton", leftPanel)
        categoryButton:SetText(displayName)
        local icon = nil
        if optionType == "server" then
            icon = self.existingExternalOptions[addonName].server_options[categoryName].icon
        elseif optionType == "client" then
            icon = self.existingExternalOptions[addonName].client_options[categoryName].icon
        end
        if icon ~= nil and icon ~= "" --[[and file.Exists(icon, "GAME")]] then
            categoryButton:SetImage(icon)
        else
            Opmenu:createError(7, addonName, categoryName, nil, nil, optionType)
        end
        categoryButton:SetSize(leftWhitePanel:GetWide() * 0.95, 30)
        categoryButton:SetPos(5, posY)
        categoryButton.Paint = function()
            surface.SetDrawColor(194, 193, 192, 255)
            surface.DrawRect(0, 0, categoryButton:GetWide(), categoryButton:GetTall())
        end
        categoryButton.DoClick = function()
            local buttonY = 10
            if IsValid(selectedButton) then
                selectedButton.Paint = function()
                    surface.SetDrawColor(194, 193, 192, 255)
                    surface.DrawRect(0, 0, categoryButton:GetWide(), categoryButton:GetTall())
                end
            end
            categoryButton.Paint = function()
                surface.SetDrawColor(150, 150, 150, 255)
                surface.DrawRect(0, 0, categoryButton:GetWide(), categoryButton:GetTall())
            end
            for _, button in ipairs(optionButtons) do
                button:Remove()
            end
            table.remove(optionButtons)
            selectedButton = categoryButton
            local catInfo
            if optionType == "server" then
                catInfo = self.existingExternalOptions[addonName].server_options
            elseif optionType == "client" then
                catInfo = self.existingExternalOptions[addonName].client_options
            end
            for optionName, optionInfo in pairs(catInfo[categoryName]) do
                if optionName ~= "name" and optionName ~= "icon" then
                    local optionButton = vgui.Create("DButton", rightPanel)
                    optionButton:SetText("")
                    optionButton:SetSize(rightWhitePanel:GetWide() * 0.97, buttonSizeY)
                    optionButton:SetPos(10, buttonY)
                    optionButton.Paint = function()
                        surface.SetDrawColor(194, 193, 192, 255)
                        surface.DrawRect(0, 0, optionButton:GetWide(), optionButton:GetTall())
                    end
                    local timerEnable = true
                    optionButton.OnCursorEntered = function(self)
                        if timerEnable then
                            timer.Create("HoverTimer", 2, 1, function()
                                hook.Add("DrawOverlay", "DrawHoverText", function()
                                    local x, y = gui.MousePos()
                                    local lines = string.Explode("\n", optionInfo.description)
                                    local lineHeight = draw.GetFontHeight("DermaDefault")
                                    for i, line in ipairs(lines) do
                                        y = y + 4
                                        draw.WordBox(2, x + 15, y + 10 + (i - 1) * lineHeight, line, "DermaDefault", Color(0, 0, 0, 200), Color(255, 255, 255, 255))
                                    end
                                end)
                                timerEnable = true
                            end)
                            timerEnable = false
                        end
                    end
                    optionButton.OnCursorExited = function(self)
                        timerEnable = true
                        timer.Remove("HoverTimer")
                        hook.Remove("DrawOverlay", "DrawHoverText")
                    end
                    optionButton.Paint = function(self, w, h)
                        surface.SetDrawColor(194, 193, 192, 255)
                        surface.DrawRect(0, 0, w, h)
                        surface.SetDrawColor(158, 157, 157, 255)
                        local borderSize = 2
                        surface.DrawRect(0, 0, w, borderSize)
                        surface.DrawRect(0, h - borderSize, w, borderSize)
                        surface.DrawRect(0, 0, borderSize, h)
                        surface.DrawRect(w - borderSize, 0, borderSize, h)
                    end
                    optionButton.label = vgui.Create("DLabel", optionButton)
                    optionButton.label:SetText(optionInfo.name)
                    optionButton.label:SetTextColor(Color(0, 0, 0))
                    optionButton.label:SetFont("saoOptionsFont")
                    optionButton.label:SetWide(optionButton:GetWide() * 0.6)
                    optionButton.label:SetPos(10, optionButton:GetTall() - draw.GetFontHeight("saoOptionsFont") / 0.55 )
                    optionButton.OnMousePressed = function(self, key)
                        if key == MOUSE_RIGHT then
                            local menu = DermaMenu()
                            local debuginfo = menu:AddOption("Debug Info")
                            debuginfo:SetImage("icon16/script_code.png")
                            menu:AddOption("ConVar: " .. optionInfo.conVar)
                            menu:AddOption("Type: " .. optionInfo.type)
                            menu:AddOption("Default Value: " .. optionInfo.default)
                            if optionInfo.min ~= nil then
                                menu:AddOption("Max Value: " .. optionInfo.max)
                            end
                            if optionInfo.max ~= nil then
                                menu:AddOption("Min Value: " .. optionInfo.min)
                            end
                            if optionInfo.dec ~= nil then
                                menu:AddOption("Decimals: " .. optionInfo.dec)
                            end
                            if table.concat(optionInfo.flags) == "" then
                                menu:AddOption("Flags: n/a")
                            else
                                menu:AddOption("Flags: " .. table.concat(optionInfo.flags, ", "))
                            end
                            if GetConVar(optionInfo.conVar) ~= nil then
                                menu:AddOption("Current: " .. GetConVar(optionInfo.conVar):GetInt())
                            end
                            menu:Open()
                        end
                    end
                    local optionTypes = {"checkbox", "slider", "textEntry", "comboBox", "click"}
                    local isValidType = false
                    for _, v in ipairs(optionTypes) do
                        if v == optionInfo.type then
                            isValidType = true
                            break -- No need to continue if a match is found
                        end
                    end
                    if not isValidType then
                        Opmenu:createError(11, addonName, categoryName, nil, optionName, optionType)
                    end
                    if optionInfo.type == "checkbox" then
                        optionButton.swich = vgui.Create("DButton", optionButton)
                        optionButton.swich:SetSize(optionButton:GetWide() * 0.2, optionButton:GetTall() * 0.6)
                        optionButton.swich:SetPos(optionButton:GetWide() * 0.75, 14)
                        if GetConVar(optionInfo.conVar) == nil then
                            Opmenu:createError(8, nil, nil, nil, optionInfo.conVar)
                            optionButton.swich:SetText("N/A")
                            optionButton.swich.Paint = function(self, w, h)
                                surface.SetDrawColor(117, 117, 117, 255)
                                surface.DrawRect(0, 0, optionButton.swich:GetWide(), optionButton.swich:GetTall())
                                local borderSize = 2
                                surface.SetDrawColor(158, 157, 157, 255)
                                surface.DrawRect(0, 0, w, borderSize)
                                surface.DrawRect(0, h - borderSize, w, borderSize)
                                surface.DrawRect(0, 0, borderSize, h)
                                surface.DrawRect(w - borderSize, 0, borderSize, h)
                            end
                        else GetConVar(optionInfo.conVar):GetInt()
                            local isChecked = GetConVar(optionInfo.conVar):GetInt() > 0

                            optionButton.swich:SetText(isChecked and "Enabled" or "Disabled")
                            optionButton.swich.Paint = function(self, w, h)
                                local color = isChecked and Color(55, 230, 87) or Color(219, 39, 48)
                                surface.SetDrawColor(color)
                                surface.DrawRect(0, 0, optionButton.swich:GetWide(), optionButton.swich:GetTall())
                                local borderSize = 2
                                surface.SetDrawColor(158, 157, 157, 255)
                                surface.DrawRect(0, 0, w, borderSize)
                                surface.DrawRect(0, h - borderSize, w, borderSize)
                                surface.DrawRect(0, 0, borderSize, h)
                                surface.DrawRect(w - borderSize, 0, borderSize, h)
                            end
                            
                            optionButton.swich.DoClick = function()
                                isChecked = not isChecked
                                optionButton.swich:SetText(isChecked and "Enabled" or "Disabled")
                                local value = isChecked and "1" or "0"
                                RunConsoleCommand(optionInfo.conVar, value)
                            end
                        end
                    elseif optionInfo.type == "slider" or "textEntery" then
                        local textEntry = vgui.Create("DTextEntry", optionButton)
                        textEntry:SetSize(optionButton:GetWide() * 0.15, optionButton:GetTall() * 0.6)
                        textEntry:SetPos(optionButton:GetWide() * 0.75, 14)
                        textEntry:SetPlaceholderText("Current value: " .. GetConVar(optionInfo.conVar):GetFloat())
                        if optionInfo.default < optionInfo.min then Opmenu:createError(10, addonName, categoryName, nil, optionName, optionType) return end
                        if optionInfo.min == nil or optionInfo.max == nil then Opmenu:createError(9, addonName, categoryName, nil, optionName, optionType) return end
                        textEntry.OnEnter = function(self)
                            local enteredValue = self:GetValue()
                            enteredValue = tonumber(enteredValue)
                            if enteredValue >= optionInfo.min and enteredValue <= optionInfo.max then
                                RunConsoleCommand(optionInfo.conVar, enteredValue)
                            end
                        end
                        local minlabel = vgui.Create("DLabel", optionButton)
                        minlabel:SetText("Min: " .. optionInfo.min)
                        minlabel:SetFont("DermaDefaultBold")
                        minlabel:SetColor(Color(0, 0, 0))
                        minlabel:SetPos(optionButton:GetWide() * 0.75 + textEntry:GetWide() + 10 , 20 )
                        local maxlabel = vgui.Create("DLabel", optionButton)
                        maxlabel:SetText("Max: " .. optionInfo.max)
                        maxlabel:SetFont("DermaDefaultBold")
                        maxlabel:SetColor(Color(0, 0, 0))
                        maxlabel:SetPos(optionButton:GetWide() * 0.75 + textEntry:GetWide() + 10 , 30 )
                    end
                    table.insert(optionButtons, optionButton)
                    rightWhitePanel:SetSize(frameW * 0.79 - 5, rightPanel:GetTall())
                    buttonY = buttonY + buttonSizeY + 10
                end
            end
        end
        posY = posY + 35
    end

    popupFrame = frame

    mainFrame.OnClose = function()
        if IsValid(popupFrame) then
            popupFrame:Close()
            popupFrame = nil
        end
    end

    return leftPanel, leftWhitePanel, rightPanel, rightWhitePanel
end

hook.Add( "Initialize", "saofont", function()
	surface.CreateFont("saoCustomFont", {
        font = "Arial",
        size = 32,
        weight = 1500,
        antialias = true
    })
    surface.CreateFont("saoOptionsFont", {
        font = "Arial",
        size = 24,
        weight = 1000,
        antialias = true
    })
end )