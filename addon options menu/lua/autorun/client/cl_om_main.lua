local popupFrame
local mainFrame
local resetFrame
local createPresetsFrame
local loadPresetsframe

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

    local numErrors = 0
    -- error icon/button
    function Opmenu:createError(num, addonName, categoryName, categoryInfo, conVar, optionType)
        if GetConVar("cl_sao_enable_error"):GetBool() == false then return end
    
        frame.OnClose = function()
            self.enabled = false
        end

        Opmenu:PrintError(num, addonName, categoryName, categoryInfo, conVar, optionType)

        numErrors = numErrors + 1
    
        if not self.enabled then
            local button = vgui.Create("DButton", frame)
            button:SetText("")
            button:SetSize(30, 30)
            button:SetPos(10, 30)
            button:SetImage("icon16/error.png")
            self.enabled = true
            numErrors = 0
            numErrors = numErrors + 1
            button.DoClick = function()
                notification.AddLegacy("[SAO] Check Console - You have " .. numErrors .. " error/s", NOTIFY_ERROR, 4 )
                surface.PlaySound("buttons/button15.wav")
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
        checkBoxLabel:SetText("Toggle error messages")
        checkBoxLabel:SetWide(150)
        checkBoxLabel:SetTextColor(Color(0, 0, 0))
        local _checkBox = vgui.Create("DCheckBox", whitePanel)
        _checkBox:SetPos(150, 55)
        _checkBox:SetValue(GetConVar("cl_sao_enable_debug"):GetInt())
        _checkBox.OnChange = function(self, isChecked)
            RunConsoleCommand("cl_sao_enable_debug", isChecked and "1" or "0")
        end
        local _checkBoxLabel = vgui.Create("DLabel", whitePanel)
        _checkBoxLabel:SetPos(10, 53)
        _checkBoxLabel:SetText("Toggle debug info in options")
        _checkBoxLabel:SetWide(150)
        _checkBoxLabel:SetTextColor(Color(0, 0, 0))
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
        local versionLabel = vgui.Create("DLabel", whitePanel)
        versionLabel:SetPos(235, 90)
        versionLabel:SetText("ver. 1.0")
        versionLabel:SetWide(150)
        versionLabel:SetTextColor(Color(0, 0, 0))
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
        Opmenu:LoadPresets()
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
                    --Opmenu:createError(3, addonInfo.name)
                    icon:SetImage("noimg.png")
                end
            else
                local placeholderIcon = vgui.Create("DImage", button)
                placeholderIcon:SetPos(5, 5)
                placeholderIcon:SetSize(90 * buttonSizeSelect, 90 * buttonSizeSelect)
                placeholderIcon:SetImage("noimg.png")
            end
            if addonInfo.customMenu == true then
                local icon = vgui.Create("DImage", button)
                icon:SetPos(5, 5)
                icon:SetSize(10 * buttonSizeSelect, 10 * buttonSizeSelect)
                icon:SetImage("icon16/feed_go.png")
            end
            if addonInfo.autoGenerateConvars == true then
                local icon = vgui.Create("DImage", button)
                icon:SetSize(10 * buttonSizeSelect, 10 * buttonSizeSelect)
                icon:SetPos(buttonSizeX - icon:GetWide() - 5, 5)
                icon:SetImage("icon16/table_error.png")
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
                        --Opmenu:createError(5, addonInfo.name)
                        --voption:SetImage("icon16/application_xp_terminal.png")
                    else
                        local voption = menu:AddOption("Version: " .. addonInfo.version)
                        --voption:SetImage("icon16/application_xp_terminal.png")
                    end
                    if addonInfo.customMenu == true then
                        local option = menu:AddOption("Uses custom menu")
                        option:SetFont("saoProperties")
                        option:SetImage("icon16/feed_go.png")
                    end
                    if addonInfo.autoGenerateConvars == true then
                        local option = menu:AddOption("AutoGenerateConvars is on!")
                        option:SetFont("saoProperties")
                        option:SetImage("icon16/table_error.png")
                    end
                    menu:Open()
                elseif key == MOUSE_LEFT then
                    --print("Button Clicked for Addon: " .. addonName)
                    if addonInfo.customMenu == true then
                        hook.Call(addonInfo.customMenuHook)
                    else
                        Opmenu:CreateOptionUI(addonInfo.name, addonName)
                    end
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
        innerPanel:SetTall(2000)
    
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

local resetButton
local createPresets
local foundElements = false
local optionButtons = {}
local selectedButton = nil
local categoryWidth, categoryHeight

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
        foundElements = false
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
        if IsValid(resetButton) then
            resetButton:SetVisible(false)
        end
        if IsValid(createPresets) then
            createPresets:SetVisible(false)
        end
        if IsValid(resetFrame) then
            resetFrame:Close()
            resetFrame = nil
        end
        if IsValid(createPresetsFrame) then
            createPresetsFrame:Close()
            createPresetsFrame = nil
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
        if IsValid(resetFrame) then
            resetFrame:Close()
            resetFrame = nil
        end
        if IsValid(createPresetsFrame) then
            createPresetsFrame:Close()
            createPresetsFrame = nil
        end
    end

end

function Opmenu:CreateOptionPanels(frame, addonName, optionType)
    local frameW, frameH = frame:GetSize()

    local leftPanel = vgui.Create("DScrollPanel", frame)
    leftPanel:SetSize(frameW * 0.2, frameH * 0.74)
    leftPanel:SetPos(10, 130)
    leftPanel:GetVBar():SetWide(0)
    local leftWhitePanel = vgui.Create("DPanel", leftPanel)
    leftWhitePanel:SetSize(frameW * 0.2 - 5, frameH - 40)
    leftWhitePanel:SetBackgroundColor(Color(255, 255, 255))

    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:SetSize(frameW * 0.78, frameH - 40)
    rightPanel:SetPos(frameW * 0.21, 30)
    local rightWhitePanel = vgui.Create("DScrollPanel", rightPanel)
    rightWhitePanel:SetSize(frameW * 0.79 - 5, frameH + 2000)
    rightWhitePanel:SetBackgroundColor(Color(255, 255, 255))
    rightWhitePanel:GetVBar():SetWide(0)

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

    ----
    resetButton = vgui.Create("DButton", frame)
    resetButton:SetText("Reset Options")
    resetButton:SetImage("icon16/arrow_refresh.png")
    resetButton:SetSize(frameW * 0.2 - 3, 30)
    resetButton:SetPos(10, 96)

    local selectedSubcategoryButton = nil

    resetButton.DoClick = function() -- reseting button
        resetFrame = vgui.Create("DFrame")
        resetFrame:SetSize(300, 150)
        resetFrame:SetTitle("Reset Options")
        resetFrame:Center()
        resetFrame:MakePopup()

        local textLabel = vgui.Create("DLabel", resetFrame)
        textLabel:SetPos(10, 30)
        textLabel:SetText("                      Please select the type of reset.\n     Choose 'SubCategory' if you want to reset the whole\n    subcategory, or choose 'Category' to reset the whole\n                      category type (client or server).\n                         This action can't be undone!")
        textLabel:SizeToContents()
        
        local resetSubCategories = vgui.Create("DButton", resetFrame)
        resetSubCategories:SetSize(140, 30)
        resetSubCategories:SetPos(150, resetFrame:GetWide() * 0.35)
        resetSubCategories:SetText("SubCategory")
        resetSubCategories:SetEnabled(selectedSubcategoryButton ~= nil)
        resetSubCategories.DoClick = function()
            if selectedSubcategoryButton then
                local categoryData = optionsTable[selectedSubcategoryButton]
                if categoryData then
                    for optionName, optionData in pairs(categoryData) do
                        if optionName ~= "name" and optionData.default ~= nil then
                            --print(optionData.conVar .. " ; " .. optionData.default)
                            if optionData.type ~= "keybind" then
                                RunConsoleCommand(optionData.conVar, optionData.default)
                            end
                            for _, button in ipairs(optionButtons) do
                                button:Remove()
                            end
                            table.remove(optionButtons)
                            if IsValid(selectedButton) then
                                selectedButton.Paint = function()
                                    surface.SetDrawColor(194, 193, 192, 255)
                                    surface.DrawRect(0, 0, categoryWidth, categoryHeight)
                                end
                            end
                        end
                    end
                end
            end
        end

        local resetCategories = vgui.Create("DButton", resetFrame)
        resetCategories:SetSize(140, 30)
        resetCategories:SetPos(10, resetFrame:GetWide() * 0.35)
        resetCategories:SetText("Category")
        resetCategories.DoClick = function()
            for categoryName, categoryData in pairs(optionsTable) do
                for optionName, optionData in pairs(categoryData) do
                    if optionName ~= "name" and optionData.default ~= nil then
                        --print(optionData.conVar .. " ; " .. optionData.default)
                        if optionData.type ~= "keybind" then
                            RunConsoleCommand(optionData.conVar, optionData.default)
                        end
                        for _, button in ipairs(optionButtons) do
                            button:Remove()
                        end
                        table.remove(optionButtons)
                        if IsValid(selectedButton) then
                            selectedButton.Paint = function()
                                surface.SetDrawColor(194, 193, 192, 255)
                                surface.DrawRect(0, 0, categoryWidth, categoryHeight)
                            end
                        end
                    end
                    if optionName ~= "name" and optionName ~= "icon" and optionData.default == nil then
                        Opmenu:createError(12, addonName, categoryName, nil, optionName, optionType)
                    end
                end
            end
        end
    end

    createPresets = vgui.Create("DButton", frame)
    createPresets:SetText("Create Preset")
    createPresets:SetImage("icon16/table_add.png")
    createPresets:SetSize(frameW * 0.2 - 3, 30)
    createPresets:SetPos(10, 63)

    createPresets.DoClick = function()
        local createPresetsFrame = vgui.Create("DFrame")
        createPresetsFrame:SetSize(300, 200)
        createPresetsFrame:SetTitle("Create a preset for selected category")
        createPresetsFrame:Center()
        createPresetsFrame:MakePopup()
    
        local whitePanel = vgui.Create("DPanel", createPresetsFrame)
        whitePanel:SetSize(280, 150)
        whitePanel:SetBackgroundColor(Color(255, 255, 255))
        whitePanel:SetPos(10, 40)
    
        local typeBar = vgui.Create("DTextEntry", whitePanel)
        typeBar:SetSize(whitePanel:GetWide() - 20, 30)
        typeBar:SetPos(10, 10)
        typeBar:SetText("")
        typeBar:SetPlaceholderText("Select name...")
        typeBar:SetEnterAllowed(true)
    
        local createButton = vgui.Create("DButton", createPresetsFrame)
        createButton:SetSize(100, 30)
        createButton:SetPos(createPresetsFrame:GetWide() * 0.5 - 50, createPresetsFrame:GetTall() - 50)
        createButton:SetText("Create")
        createButton.DoClick = function()
            local presetName = typeBar:GetValue()
            if presetName == "czolg" then -- :)
                print("Japierdole czooooooooooooooołg!!!")
            end
            if presetName == "" or presetName:match("[^%w_]") then
                notification.AddLegacy("[SAO] Invalid preset name", NOTIFY_ERROR, 4 )
                surface.PlaySound("buttons/button15.wav")
                return
            end
            if presetName:lower():find("client") or presetName:lower():find("server") then
                notification.AddLegacy('[SAO] Presets can\'t contain "server" or "client" strings', NOTIFY_ERROR, 4)
                surface.PlaySound("buttons/button15.wav")
                return
            end
            local filePath = "sao_presets.txt"
            local fileData = file.Read(filePath, "DATA") or ""
            local presetsData = util.JSONToTable(fileData) or {}
            for name, _ in pairs(presetsData) do
                local strippedName = name:gsub("server_", ""):gsub("client_", "")
                if strippedName == presetName then
                    notification.AddLegacy("[SAO] Preset with the same name already exists", NOTIFY_ERROR, 4 )
                    surface.PlaySound("buttons/button15.wav")
                    return
                end
            end
            local presetTable = {}
            presetTable["addonName"] = self.existingExternalOptions[addonName].name
            for categoryName, categoryData in pairs(optionsTable) do
                if type(categoryData) == "table" then
                    for optionName, optionData in pairs(categoryData) do
                        if optionName ~= "name" and optionData.conVar ~= nil and optionData.type ~= "keybind" then
                            if optionData.type ~= "slider" then
                                presetTable[optionData.conVar] = GetConVar(optionData.conVar):GetInt()
                            else
                                presetTable[optionData.conVar] = GetConVar(optionData.conVar):GetFloat()
                            end
                        end
                    end
                end
            end
            presetName = optionType .. "_" .. presetName
            local presetJson = util.TableToJSON(presetTable)
            presetsData[presetName] = presetJson
            local presetsJson = util.TableToJSON(presetsData)
            file.Write(filePath, presetsJson)
            print("[Simple Addon Options] Preset '" .. presetName .. "' created successfully.")
            notification.AddLegacy("[SAO] Preset '" .. presetName .. "' created successfully", NOTIFY_HINT, 4 )
            surface.PlaySound("buttons/button15.wav")
            createPresetsFrame:Close()
        end
    end

    local posY = 5
    local buttonSizeY = 70
    if next(categories) == nil then
        local nothingFoundLabel = vgui.Create("DLabel", rightWhitePanel)
        nothingFoundLabel:SetText("Nothing found!")
        nothingFoundLabel:SetTextColor(Color(0, 0, 0))
        nothingFoundLabel:SetFont("saoCustomFont")
        nothingFoundLabel:SizeToContents()
        nothingFoundLabel:SetWide(300)
        nothingFoundLabel:SetPos(rightWhitePanel:GetWide() * 0.55 - nothingFoundLabel:GetWide() * 0.5, rightWhitePanel:GetTall() * 0.05)
    end
    for categoryName, displayName in pairs(categories) do -- creating subcategory buttons
        if not foundElements then
            local nothingFoundLabel = vgui.Create("DLabel", rightWhitePanel)
            nothingFoundLabel:SetText("Select subcategory to view options")
            nothingFoundLabel:SetTextColor(Color(0, 0, 0))
            nothingFoundLabel:SetFont("saoCustomFont")
            nothingFoundLabel:SizeToContents()
            nothingFoundLabel:SetWide(600)
            nothingFoundLabel:SetPos(rightWhitePanel:GetWide() * 0.60 - nothingFoundLabel:GetWide() * 0.5, rightWhitePanel:GetTall() * 0.01)
        end
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
        foundElements = true
        categoryButton.DoClick = function()
            local buttonY = 10
            if IsValid(selectedButton) then
                selectedButton.Paint = function()
                    surface.SetDrawColor(194, 193, 192, 255)
                    surface.DrawRect(0, 0, categoryButton:GetWide(), categoryButton:GetTall())
                end
            end
            selectedSubcategoryButton = categoryName
            categoryButton.Paint = function()
                surface.SetDrawColor(150, 150, 150, 255)
                surface.DrawRect(0, 0, categoryButton:GetWide(), categoryButton:GetTall())
            end
            for _, button in ipairs(optionButtons) do
                button:Remove()
            end
            table.remove(optionButtons)
            selectedButton = categoryButton
            categoryWidth = categoryButton:GetWide()
            categoryHeight = categoryButton:GetTall()
            local catInfo
            if optionType == "server" then
                catInfo = self.existingExternalOptions[addonName].server_options
            elseif optionType == "client" then
                catInfo = self.existingExternalOptions[addonName].client_options
            end
            local sortedOptionInfo = {}
            for optionName, optionInfo in pairs(catInfo[categoryName]) do
                table.insert(sortedOptionInfo, {name = optionName, info = optionInfo})
            end            
            local function customSort(a, b)
                local numA = tonumber(string.match(a.name, "%d+$")) or 0
                local numB = tonumber(string.match(b.name, "%d+$")) or 0
                return numA < numB
            end
            table.sort(sortedOptionInfo, customSort)
            for _, optionData in ipairs(sortedOptionInfo) do  -- creating option buttons for selected category
                local optionName = optionData.name
                local optionInfo = optionData.info
                if optionName ~= "name" and optionName ~= "icon" then
                    if optionInfo.default == nil and not optionInfo.type == "button" then
                        Opmenu:createError(12, addonName, categoryName, nil, optionName, optionType)
                    end
                    local optionButton = vgui.Create("DButton", rightWhitePanel)
                    optionButton:SetText("")
                    optionButton:SetSize(rightWhitePanel:GetWide() * 0.97, buttonSizeY)
                    optionButton:SetPos(10, buttonY)
                    optionButton.Paint = function()
                        surface.SetDrawColor(194, 193, 192, 255)
                        surface.DrawRect(0, 0, optionButton:GetWide(), optionButton:GetTall())
                    end
                    if optionInfo.description ~= nil then
                        local timerEnable = true
                        optionButton.OnCursorEntered = function(self)
                            if timerEnable then
                                timer.Create("HoverTimer", 1, 1, function()
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
                        if GetConVar("cl_sao_enable_debug"):GetInt() == 1 then -- debug menu
                            if key == MOUSE_RIGHT then
                                local menu = DermaMenu()
                                local debuginfo = menu:AddOption("Debug Info")
                                debuginfo:SetImage("icon16/script_code.png")
                                if optionInfo.comboBox ~= nil then
                                    menu:AddOption("ConVar: " .. optionInfo.conVar)
                                end
                                menu:AddOption("Type: " .. optionInfo.type)
                                if optionInfo.default ~= nil then
                                    menu:AddOption("Default Value: " .. optionInfo.default)
                                end
                                if optionInfo.min ~= nil then
                                    menu:AddOption("Max Value: " .. optionInfo.max)
                                end
                                if optionInfo.max ~= nil then
                                    menu:AddOption("Min Value: " .. optionInfo.min)
                                end
                                if optionInfo.dec ~= nil then
                                    menu:AddOption("Decimals: " .. optionInfo.dec)
                                end
                                if optionInfo.flags ~= nil and optionType == "server" then
                                    if table.concat(optionInfo.flags) == "" then
                                        menu:AddOption("Flags: n/a")
                                    else
                                        menu:AddOption("Flags: " .. table.concat(optionInfo.flags, ", "))
                                    end
                                end
                                if optionInfo.type == "button" then
                                    if optionInfo.buttonType == "hook" then
                                        menu:AddOption("Button type: hook")
                                    elseif optionInfo.buttonType == "command" then
                                        menu:AddOption("Button type: command")
                                    end
                                end
                                if optionInfo.conVar ~= nil and GetConVar(optionInfo.conVar) ~= nil then
                                    menu:AddOption("Current: " .. GetConVar(optionInfo.conVar):GetInt())
                                elseif optionInfo.conVar == nil and optionInfo.type ~= "keybind" and optionInfo.type ~= "button" then
                                    menu:AddOption("Current: nil")
                                end
                                menu:Open()
                            end
                        end
                    end
                    local optionTypes = {"checkbox", "slider", "textEntry", "comboBox", "button", "slideBox", "keybind"}
                    local isValidType = false
                    for _, v in ipairs(optionTypes) do
                        if v == optionInfo.type then
                            isValidType = true
                            break 
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
                    elseif optionInfo.type == "slider" or optionInfo.type == "textEntery" then
                        local _optionButton = vgui.Create("DPanel", optionButton)
                        _optionButton:SetSize(optionButton:GetWide() * 0.15, optionButton:GetTall() * 0.6)
                        _optionButton:SetPos(optionButton:GetWide() * 0.75, 14)
                        local textEntry = vgui.Create("DTextEntry", optionButton)
                        textEntry:SetSize(optionButton:GetWide() * 0.15, optionButton:GetTall() * 0.6)
                        textEntry:SetPos(optionButton:GetWide() * 0.75, 14)
                        if GetConVar(optionInfo.conVar) == nil then
                            textEntry:SetPlaceholderText("Current value: nil")
                        else
                            textEntry:SetPlaceholderText("Current value: " .. GetConVar(optionInfo.conVar):GetFloat())
                        end
                        textEntry.Paint = function(self, w, h)
                            local borderSize = 2
                            surface.SetDrawColor(158, 157, 157, 255)
                            surface.DrawRect(0, 0, w, borderSize)
                            surface.DrawRect(0, h - borderSize, w, borderSize)
                            surface.DrawRect(0, 0, borderSize, h)
                            surface.DrawRect(w - borderSize, 0, borderSize, h)
                            if self:GetText() == "" then
                                draw.SimpleText(self:GetPlaceholderText(), "DermaDefault", 5, h / 2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            end
                            self:DrawTextEntryText(Color(0, 0, 0), Color(255, 255, 255), Color(0, 0, 0))
                        end
                        if optionInfo.default < optionInfo.min then Opmenu:createError(10, addonName, categoryName, nil, optionName, optionType) return end
                        if optionInfo.min == nil or optionInfo.max == nil then Opmenu:createError(9, addonName, categoryName, nil, optionName, optionType) return end
                        textEntry.OnEnter = function(self)
                            local enteredValue = self:GetValue()
                            enteredValue = tonumber(enteredValue)
                            if not tonumber(enteredValue) then
                                notification.AddLegacy("[SAO] Entered value is not a number!", NOTIFY_ERROR, 4 )
                                surface.PlaySound("buttons/button15.wav")
                                return
                            end
                            if enteredValue >= optionInfo.min and enteredValue <= optionInfo.max then
                                RunConsoleCommand(optionInfo.conVar, enteredValue)
                            end
                            if enteredValue > optionInfo.max then
                                notification.AddLegacy("[SAO] Entered value is too large!", NOTIFY_ERROR, 4 )
                                surface.PlaySound("buttons/button15.wav")
                            end
                            if enteredValue < optionInfo.min then
                                notification.AddLegacy("[SAO] Entered value is too small!", NOTIFY_ERROR, 4 )
                                surface.PlaySound("buttons/button15.wav")
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
                    elseif optionInfo.type == "comboBox" then
                        local _optionButton = vgui.Create("DPanel", optionButton)
                        _optionButton:SetSize(optionButton:GetWide() * 0.2, optionButton:GetTall() * 0.6)
                        _optionButton:SetPos(optionButton:GetWide() * 0.75, 14)
                        local comboBox = vgui.Create("DComboBox", _optionButton)
                        comboBox:SetPos(0, 0)
                        comboBox:SetSize(optionButton:GetWide() * 0.2, optionButton:GetTall() * 0.6)
                        comboBox:SetTextColor(Color(0, 0, 0, 255))
                        comboBox:SetFont("DermaDefault")
                        comboBox.Paint = function(self, w, h)
                            local borderSize = 2
                            surface.SetDrawColor(158, 157, 157, 255)
                            surface.DrawRect(0, 0, w, borderSize)
                            surface.DrawRect(0, h - borderSize, w, borderSize)
                            surface.DrawRect(0, 0, borderSize, h)
                            surface.DrawRect(w - borderSize, 0, borderSize, h)
                        end
                        local convarValue = GetConVar(optionInfo.conVar):GetInt()
                        for key, value in pairs(optionInfo.comboBox) do
                            if convarValue == tonumber(string.match(key, "%d+$")) then
                                comboBox:SetValue(value)
                                break
                            end
                        end
                        local sortedKeys = {}
                        for key, _ in pairs(optionInfo.comboBox) do
                            table.insert(sortedKeys, key)
                        end
                        table.sort(sortedKeys, function(a, b)
                            return tonumber(string.match(a, "%d+$")) < tonumber(string.match(b, "%d+$"))
                        end)
                        for _, key in ipairs(sortedKeys) do
                            local option = optionInfo.comboBox[key]
                            comboBox:AddChoice(option)
                        end
                        comboBox.OnSelect = function(panel, index, value, data)
                            for _, key in ipairs(sortedKeys) do
                                local optionIndex = tonumber(string.match(key, "%d+$"))
                                if optionIndex == index then
                                    RunConsoleCommand(optionInfo.conVar, index)
                                    break
                                end
                            end
                        end
                    elseif optionInfo.type == "button" then
                        local __optionButton = vgui.Create("DButton", optionButton)
                        __optionButton:SetSize(optionButton:GetWide() * 0.2, optionButton:GetTall() * 0.6)
                        __optionButton:SetPos(optionButton:GetWide() * 0.75, 14)
                        __optionButton:SetText(optionInfo.buttonName)
                        __optionButton.Paint = function(self, w, h)
                            local borderSize = 2
                            surface.SetDrawColor(Color(255, 255, 255, 140))
                            surface.DrawRect(0, 0, w, h)
                            surface.SetDrawColor(158, 157, 157, 255)
                            surface.DrawRect(0, 0, w, borderSize)
                            surface.DrawRect(0, h - borderSize, w, borderSize)
                            surface.DrawRect(0, 0, borderSize, h)
                            surface.DrawRect(w - borderSize, 0, borderSize, h)
                        end
                        __optionButton.DoClick = function(self)
                            if optionInfo.buttonType == "hook" then
                                hook.Call(optionInfo.hookName)
                            elseif optionInfo.buttonType == "command" then
                                RunConsoleCommand(optionInfo.buttonCommand)
                            end
                        end
                    elseif optionInfo.type == "keybind" then
                        local binder = vgui.Create("DBinder", optionButton)
                        binder:SetSize(optionButton:GetWide() * 0.2, optionButton:GetTall() * 0.6)
                        binder:SetPos(optionButton:GetWide() * 0.75, 14)
                        local bindedKey = input.LookupBinding(optionInfo.conVar) or optionInfo.default
                        binder:SetText(bindedKey)
                        binder.Paint = function(self, w, h)
                            local borderSize = 2
                            surface.SetDrawColor(Color(255, 255, 255, 140))
                            surface.DrawRect(0, 0, w, h)
                            surface.SetDrawColor(158, 157, 157, 255)
                            surface.DrawRect(0, 0, w, borderSize)
                            surface.DrawRect(0, h - borderSize, w, borderSize)
                            surface.DrawRect(0, 0, borderSize, h)
                            surface.DrawRect(w - borderSize, 0, borderSize, h)
                        end
                        binder.OnChange = function(self, num)
                            hook.Call(optionInfo.hookName, nil, num)
                        end
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
        foundElements = false
        if IsValid(popupFrame) then
            popupFrame:Close()
            popupFrame = nil
        end
        if IsValid(resetFrame) then
            resetFrame:Close()
            resetFrame = nil
        end
        if IsValid(createPresetsFrame) then
            createPresetsFrame:Close()
            createPresetsFrame = nil
        end
        if IsValid(loadPresetsframe) then
            loadPresetsframe:Close()
            loadPresetsframe = nil
        end
    end

    popupFrame.OnClose = function()
        foundElements = false
        if IsValid(resetFrame) then
            resetFrame:Close()
            resetFrame = nil
        end
        if IsValid(createPresetsFrame) then
            createPresetsFrame:Close()
            createPresetsFrame = nil
        end
    end

    return leftPanel, leftWhitePanel, rightPanel, rightWhitePanel
end

local fullPresetName = {}

local function AddPresetToList(presetsData, presetList, filePath)
    fullPresetName = {}
    for presetName, presetData in pairs(presetsData) do
        local displayName = string.gsub(presetName, "^server_", "")
        displayName = string.gsub(displayName, "^client_", "")
        local iconPath = nil
        table.insert(fullPresetName, {displayName = displayName, fullPresetName = presetName})
        if string.match(presetName, "^server_") then
            iconPath = "icon16/drive.png"
        elseif string.match(presetName, "^client_") then
            iconPath = "icon16/user.png"
        end
        local innerData = util.JSONToTable(presetData)
        local addonName = innerData.addonName or "Unknown Addon"
        local listItem = presetList:AddLine(displayName, addonName)
        if iconPath then
            local iconImage = vgui.Create("DImage", listItem)
            iconImage:SetImage(iconPath)
            iconImage:SetPos(350,0)
            iconImage:SetSize(16, 16)
        end
        listItem.OnRightClick = function()
            local contextMenu = DermaMenu()
            contextMenu:AddOption("Remove", function()
                presetsData[presetName] = nil
                local newPresetsData = util.TableToJSON(presetsData)
                file.Write(filePath, newPresetsData)
                presetList:RemoveLine(listItem:GetID())
            end)
            contextMenu:Open()
        end
    end
end

function Opmenu:LoadPresets()
    local loadPresetsframe = vgui.Create("DFrame")
    loadPresetsframe:SetSize(400, 500)
    loadPresetsframe:SetTitle("Load preset")
    loadPresetsframe:Center()
    loadPresetsframe:MakePopup()

    local presetList = vgui.Create("DListView", loadPresetsframe)
    presetList:SetPos(10, 60)
    presetList:SetSize(380, 430)
    presetList:AddColumn("Preset Name")
    presetList:AddColumn("Addon")

    local searchEntry = vgui.Create("DTextEntry", loadPresetsframe)
    searchEntry:SetSize(200, 20)
    searchEntry:SetPos(10, 30)
    searchEntry:SetPlaceholderText("Search Presets...")

    local filterComboBox = vgui.Create("DComboBox", loadPresetsframe)
    filterComboBox:SetSize(70, 20)
    filterComboBox:SetPos(220, 30)
    filterComboBox:AddChoice("All")
    filterComboBox:AddChoice("Server")
    filterComboBox:AddChoice("Client")
    filterComboBox:SetValue("All")

    local loadButton = vgui.Create("DButton", loadPresetsframe)
    loadButton:SetSize(90, 20)
    loadButton:SetPos(300, 30)
    loadButton:SetText("Load")

    local filePath = "sao_presets.txt"
    local fileData = file.Read(filePath, "DATA")

    if not fileData then return end
    local presetsData = util.JSONToTable(fileData)

    if not presetsData then return end

    AddPresetToList(presetsData, presetList, filePath)

    loadButton.DoClick = function()
        local selectedLine = presetList:GetSelectedLine()
        if not selectedLine then
            notification.AddLegacy("[SAO] Nothing is selected!", NOTIFY_ERROR, 4 )
            surface.PlaySound("buttons/button15.wav")
            return
        end
    
        local presetName = presetList:GetLine(selectedLine):GetColumnText(1)

        for _, mapping in ipairs(fullPresetName) do
            if mapping.displayName == presetName then
                fullPresetName = mapping.fullPresetName
                break
            end
        end
    
        if not fullPresetName then return end
    
        local presetData = presetsData[fullPresetName]
        if not presetData then return end
    
        local decodedPresetData = util.JSONToTable(presetData)
        if not decodedPresetData then return end
    
        for preset, values in pairs(decodedPresetData) do
            if preset ~= "addonName" then
                RunConsoleCommand(preset, values)
            end
        end
        
        notification.AddLegacy("[SAO] Preset '" .. presetName .. "' loaded successfully", NOTIFY_HINT, 4 )
        surface.PlaySound("buttons/button15.wav")
        print("[Simple Addon Options] Preset '" .. presetName .. "' loaded successfully.")
    end

    searchEntry.OnTextChanged = function(self)
        local text = string.lower(self:GetValue())
        presetList:Clear()
        for presetName, presetData in pairs(presetsData) do
            if string.find(string.lower(presetName), text) then
                local displayName = string.gsub(presetName, "^server_", "")
                displayName = string.gsub(displayName, "^client_", "")
                local iconPath = nil
                if string.match(presetName, "^server_") then
                    iconPath = "icon16/drive.png"
                elseif string.match(presetName, "^client_") then
                    iconPath = "icon16/user.png"
                end
                local innerData = util.JSONToTable(presetData)
                local addonName = innerData.addonName or "Unknown Addon"
                local listItem = presetList:AddLine(displayName, addonName)
                if iconPath then
                    local iconImage = vgui.Create("DImage", listItem)
                    iconImage:SetImage(iconPath)
                    iconImage:SetPos(350,0)
                    iconImage:SetSize(16, 16)
                end
                listItem.OnRightClick = function()
                    local contextMenu = DermaMenu()
                    contextMenu:AddOption("Remove", function()
                        presetsData[presetName] = nil
                        local newPresetsData = util.TableToJSON(presetsData)
                        file.Write(filePath, newPresetsData)
                        presetList:RemoveLine(listItem:GetID())
                    end)
                    contextMenu:Open()
                end
            end
        end
    end

    filterComboBox.OnSelect = function(_, index, value)
        local filterText = searchEntry:GetValue()
        searchEntry:SetText("")
        presetList:Clear()
    
        local selectedFilter = filterComboBox:GetOptionText(index)
        if selectedFilter == "All" then
            AddPresetToList(presetsData, presetList, filePath)
        elseif selectedFilter == "Server" then
            for presetName, presetData in pairs(presetsData) do
                if string.match(presetName, "^server_") then
                    local displayName = string.gsub(presetName, "^server_", "")
                    local innerData = util.JSONToTable(presetData)
                    local addonName = innerData.addonName or "Unknown Addon"
                    local listItem = presetList:AddLine(displayName, addonName)
                    local iconImage = vgui.Create("DImage", listItem)
                    iconImage:SetImage("icon16/drive.png")
                    iconImage:SetPos(350,0)
                    iconImage:SetSize(16, 16)
                    listItem.OnRightClick = function()
                        local contextMenu = DermaMenu()
                        contextMenu:AddOption("Remove", function()
                            presetsData[presetName] = nil
                            local newPresetsData = util.TableToJSON(presetsData)
                            file.Write(filePath, newPresetsData)
                            presetList:RemoveLine(listItem:GetID())
                        end)
                        contextMenu:Open()
                    end
                end
            end
        elseif selectedFilter == "Client" then
            for presetName, presetData in pairs(presetsData) do
                if string.match(presetName, "^client_") then
                    local displayName = string.gsub(presetName, "^client_", "")
                    local innerData = util.JSONToTable(presetData)
                    local addonName = innerData.addonName or "Unknown Addon"
                    local listItem = presetList:AddLine(displayName, addonName)
                    local iconImage = vgui.Create("DImage", listItem)
                    iconImage:SetImage("icon16/user.png")
                    iconImage:SetPos(350,0)
                    iconImage:SetSize(16, 16)
                    listItem.OnRightClick = function()
                        local contextMenu = DermaMenu()
                        contextMenu:AddOption("Remove", function()
                            presetsData[presetName] = nil
                            local newPresetsData = util.TableToJSON(presetsData)
                            file.Write(filePath, newPresetsData)
                            presetList:RemoveLine(listItem:GetID())
                        end)
                        contextMenu:Open()
                    end
                end
            end
        end
    end
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
    surface.CreateFont( "saoProperties", {
        font = "Arial",
        extended = false,
        size = 14,
        weight = 500,
        antialias = true,
        italic = true,
    } )
end )