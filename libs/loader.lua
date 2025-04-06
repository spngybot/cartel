local library = {}
library.flags = {}

-- Initialize the library by creating a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyUILibrary"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Enabled = true -- Can be toggled later if needed

-- Function to create a new window
function library:CreateWindow(properties)
    local windowProps = properties or {}
    local window = Instance.new("Frame")
    window.Name = windowProps.name or "Window"
    window.Size = windowProps.size or UDim2.new(0, 835, 0, 615)
    window.Position = windowProps.position or UDim2.new(0.15, 0, 0.07, 0)
    window.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    window.BorderSizePixel = 0
    window.Parent = screenGui

    -- Sidebar for tab navigation
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Color3.fromRGB(8, 19, 28)
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0, 0, 0, 1)
    sidebar.Size = UDim2.new(0, 191, 1, -1)
    sidebar.Parent = window

    -- Tab content area
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.BackgroundColor3 = Color3.fromRGB(10, 12, 15)
    tabContent.BorderSizePixel = 0
    tabContent.Position = UDim2.new(0, 191, 0, 1)
    tabContent.Size = UDim2.new(1, -191, 1, -1)
    tabContent.Parent = window

    -- Window object with methods
    local windowObj = {
        tabs = {},
        selectedTab = nil,
        sidebar = sidebar,
        tabContent = tabContent
    }

    -- Method to add a tab
    function windowObj:AddTab(properties)
        local tabProps = properties or {}
        local tabName = tabProps.name or "Tab"

        -- Tab button in sidebar
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Button"
        tabButton.BackgroundColor3 = Color3.fromRGB(14, 49, 82) -- Default highlighted color
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(0, 168, 0, 28)
        tabButton.Position = UDim2.new(0, 13, 0, #windowObj.tabs * 30 + 27)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextSize = 15
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = tabButton
        tabButton.Parent = sidebar

        -- Tab content frame
        local tabFrame = Instance.new("Frame")
        tabFrame.Name = tabName .. "Frame"
        tabFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 15)
        tabFrame.BorderSizePixel = 0
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.Visible = false
        tabFrame.Parent = tabContent

        -- Topbar for the tab content
        local topbar = Instance.new("Frame")
        topbar.Name = "Topbar"
        topbar.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
        topbar.BorderSizePixel = 0
        topbar.Size = UDim2.new(1, 0, 0, 69)
        topbar.Parent = tabFrame

        -- Main content area below topbar
        local main = Instance.new("Frame")
        main.Name = "Main"
        main.BackgroundTransparency = 1
        main.Position = UDim2.new(0, 0, 0, 71)
        main.Size = UDim2.new(1, 0, 1, -71)
        main.Parent = tabFrame

        -- UIListLayout for sections
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 10)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = main

        local tabObj = {
            button = tabButton,
            frame = tabFrame,
            main = main
        }

        table.insert(windowObj.tabs, tabObj)

        -- Tab selection logic
        tabButton.MouseButton1Click:Connect(function()
            if windowObj.selectedTab then
                windowObj.selectedTab.frame.Visible = false
                windowObj.selectedTab.button.BackgroundColor3 = Color3.fromRGB(8, 19, 28) -- Unselected color
            end
            windowObj.selectedTab = tabObj
            tabObj.frame.Visible = true
            tabObj.button.BackgroundColor3 = Color3.fromRGB(14, 49, 82) -- Selected color
        end)

        -- Select first tab by default
        if #windowObj.tabs == 1 then
            windowObj.selectedTab = tabObj
            tabObj.frame.Visible = true
            tabObj.button.BackgroundColor3 = Color3.fromRGB(14, 49, 82)
        else
            tabButton.BackgroundColor3 = Color3.fromRGB(8, 19, 28)
        end

        -- Method to add a section to the tab
        function tabObj:AddSection(properties)
            local sectionProps = properties or {}
            local sectionName = sectionProps.name or "Section"

            local section = Instance.new("Frame")
            section.Name = sectionName
            section.BackgroundColor3 = Color3.fromRGB(8, 10, 19)
            section.BorderSizePixel = 0
            section.Size = UDim2.new(1, -20, 0, 186) -- Adjustable height
            section.Parent = tabObj.main

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Position = UDim2.new(0, 15, 0, 8)
            sectionTitle.Size = UDim2.new(1, -20, 0, 20)
            sectionTitle.Font = Enum.Font.SourceSans
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.TextSize = 14
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = section

            local elementLayout = Instance.new("UIListLayout")
            elementLayout.Padding = UDim.new(0, 5)
            elementLayout.SortOrder = Enum.SortOrder.LayoutOrder
            elementLayout.Parent = section

            local sectionObj = {
                frame = section,
                layout = elementLayout
            }

            -- Method to add a toggle
            function sectionObj:AddToggle(properties)
                local toggleProps = properties or {}
                local toggleName = toggleProps.name or "Toggle"
                local flag = toggleProps.flag
                local default = toggleProps.default or false
                local callback = toggleProps.callback or function() end

                if flag then
                    library.flags[flag] = default
                end

                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "Toggle"
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(1, 0, 0, 20)
                toggleFrame.Parent = section.frame

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "Label"
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Size = UDim2.new(0, 200, 1, 0)
                toggleLabel.Font = Enum.Font.SourceSans
                toggleLabel.Text = toggleName
                toggleLabel.TextColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(137, 138, 144)
                toggleLabel.TextSize = 14
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame

                local toggleButton = Instance.new("TextButton")
                toggleButton.Name = "Button"
                toggleButton.BackgroundColor3 = Color3.fromRGB(12, 17, 38)
                toggleButton.BorderSizePixel = 0
                toggleButton.Position = UDim2.new(1, -44, 0, 3)
                toggleButton.Size = UDim2.new(0, 29, 0, 14)
                toggleButton.Text = ""
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 10)
                toggleCorner.Parent = toggleButton
                toggleButton.Parent = toggleFrame

                local toggleIndicator = Instance.new("Frame")
                toggleIndicator.Name = "Indicator"
                toggleIndicator.BackgroundColor3 = default and Color3.fromRGB(84, 124, 253) or Color3.fromRGB(128, 135, 142)
                toggleIndicator.BorderSizePixel = 0
                toggleIndicator.Size = UDim2.new(0, 14, 0, 14)
                toggleIndicator.Position = default and UDim2.new(1, -14, 0, 0) or UDim2.new(0, 0, 0, 0)
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(1, 0)
                indicatorCorner.Parent = toggleIndicator
                toggleIndicator.Parent = toggleButton

                local function updateToggle(state)
                    toggleIndicator.Position = state and UDim2.new(1, -14, 0, 0) or UDim2.new(0, 0, 0, 0)
                    toggleIndicator.BackgroundColor3 = state and Color3.fromRGB(84, 124, 253) or Color3.fromRGB(128, 135, 142)
                    toggleLabel.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(137, 138, 144)
                    if flag then
                        library.flags[flag] = state
                    end
                    callback(state)
                end

                toggleButton.MouseButton1Click:Connect(function()
                    local newState = not (flag and library.flags[flag] or default)
                    updateToggle(newState)
                end)

                updateToggle(default)
            end

            -- Method to add a slider
            function sectionObj:AddSlider(properties)
                local sliderProps = properties or {}
                local sliderName = sliderProps.name or "Slider"
                local min = sliderProps.min or 0
                local max = sliderProps.max or 100
                local default = math.clamp(sliderProps.default or min, min, max)
                local flag = sliderProps.flag
                local callback = sliderProps.callback or function() end

                if flag then
                    library.flags[flag] = default
                end

                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "Slider"
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Size = UDim2.new(1, 0, 0, 30)
                sliderFrame.Parent = section.frame

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "Label"
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Size = UDim2.new(0, 200, 0, 16)
                sliderLabel.Font = Enum.Font.SourceSans
                sliderLabel.Text = sliderName
                sliderLabel.TextColor3 = Color3.fromRGB(137, 138, 144)
                sliderLabel.TextSize = 14
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame

                local sliderBar = Instance.new("Frame")
                sliderBar.Name = "Bar"
                sliderBar.BackgroundColor3 = Color3.fromRGB(8, 15, 33)
                sliderBar.BorderSizePixel = 0
                sliderBar.Position = UDim2.new(0, 150, 0, 22)
                sliderBar.Size = UDim2.new(0, 100, 0, 4)
                local barCorner = Instance.new("UICorner")
                barCorner.CornerRadius = UDim.new(0, 2)
                barCorner.Parent = sliderBar
                sliderBar.Parent = sliderFrame

                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.BackgroundColor3 = Color3.fromRGB(87, 126, 244)
                sliderFill.BorderSizePixel = 0
                sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(0, 2)
                fillCorner.Parent = sliderFill
                sliderFill.Parent = sliderBar

                local sliderKnob = Instance.new("Frame")
                sliderKnob.Name = "Knob"
                sliderKnob.BackgroundColor3 = Color3.fromRGB(84, 124, 253)
                sliderKnob.BorderSizePixel = 0
                sliderKnob.Position = UDim2.new((default - min) / (max - min), -6, 0, -4)
                sliderKnob.Size = UDim2.new(0, 12, 0, 12)
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = sliderKnob
                sliderKnob.Parent = sliderBar

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Name = "Value"
                valueLabel.BackgroundTransparency = 1
                valueLabel.Position = UDim2.new(1, 10, 0, 18)
                valueLabel.Size = UDim2.new(0, 50, 0, 11)
                valueLabel.Font = Enum.Font.SourceSans
                valueLabel.Text = tostring(default)
                valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                valueLabel.TextSize = 13
                valueLabel.Parent = sliderBar

                local dragging = false
                sliderKnob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                sliderKnob.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouseX = input.Position.X
                        local barX = sliderBar.AbsolutePosition.X
                        local barWidth = sliderBar.AbsoluteSize.X
                        local relativeX = math.clamp(mouseX - barX, 0, barWidth)
                        local value = min + (relativeX / barWidth) * (max - min)
                        value = math.floor(value + 0.5) -- Round to nearest integer
                        sliderFill.Size = UDim2.new(relativeX / barWidth, 0, 1, 0)
                        sliderKnob.Position = UDim2.new(relativeX / barWidth, -6, 0, -4)
                        valueLabel.Text = tostring(value)
                        if flag then
                            library.flags[flag] = value
                        end
                        callback(value)
                    end
                end)
            end

            return sectionObj
        end

        return tabObj
    end

    return windowObj
end

return library
