local UILibrary = {}

function UILibrary.new()
    local library = {
        ui = {},
        options = {},
    }

    -- Method to create the entire loader UI
    function library:createLoaderUI(options)
        self.options = options or {}

        -- Access Roblox services
        local TweenService = game:GetService("TweenService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        -- ScreenGui
        local loader = Instance.new("ScreenGui")
        loader.Name = "loader"
        loader.Parent = player:WaitForChild("PlayerGui")
        loader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self.ui.loader = loader

        -- Main Loader Frame
        local loaderFrame = Instance.new("Frame")
        loaderFrame.Name = "loader"
        loaderFrame.Parent = loader
        loaderFrame.BackgroundColor3 = self.options.backgroundColor or Color3.fromRGB(3, 12, 26)
        loaderFrame.BorderSizePixel = 0
        loaderFrame.Position = self.options.position or UDim2.new(0.340620816, 0, 0.248743713, 0)
        loaderFrame.Size = self.options.size or UDim2.new(0, 500, 0, 400)
        loaderFrame.Visible = false
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 9)
        uiCorner.Parent = loaderFrame
        self.ui.loaderFrame = loaderFrame

        -- Initial Frame (for initial state)
        local initialFrame = Instance.new("Frame")
        initialFrame.Name = "initialFrame"
        initialFrame.Parent = loaderFrame
        initialFrame.BackgroundTransparency = 1
        initialFrame.Size = UDim2.new(1, 0, 1, 0)
        self.ui.initialFrame = initialFrame

        -- User Label
        local userLabel = Instance.new("TextLabel")
        userLabel.Name = "user"
        userLabel.Parent = initialFrame
        userLabel.BackgroundTransparency = 1
        userLabel.Position = self.options.userLabelPosition or UDim2.new(0, 65, 0, 348)
        userLabel.Size = self.options.userLabelSize or UDim2.new(0, 45, 0, 22)
        userLabel.Font = Enum.Font.Unknown
        userLabel.Text = self.options.userLabelText or player.DisplayName
        userLabel.TextColor3 = self.options.userLabelTextColor or Color3.fromRGB(255, 255, 255)
        userLabel.TextSize = 13
        userLabel.TextXAlignment = Enum.TextXAlignment.Left
        userLabel.TextYAlignment = Enum.TextYAlignment.Top

        -- Subscription Labels
        local subscriptionLabel = Instance.new("TextLabel")
        subscriptionLabel.Name = "Subscription"
        subscriptionLabel.Parent = initialFrame
        subscriptionLabel.BackgroundTransparency = 1
        subscriptionLabel.Position = self.options.subscriptionPosition or UDim2.new(0, 165, 0, 22)
        subscriptionLabel.Size = self.options.subscriptionSize or UDim2.new(0, 110, 0, 33)
        subscriptionLabel.Font = Enum.Font.Unknown
        subscriptionLabel.Text = self.options.subscriptionText or "Subscription"
        subscriptionLabel.TextColor3 = self.options.subscriptionTextColor or Color3.fromRGB(255, 255, 255)
        subscriptionLabel.TextSize = 26
        subscriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        subscriptionLabel.TextYAlignment = Enum.TextYAlignment.Top

        local availableSubsLabel = Instance.new("TextLabel")
        availableSubsLabel.Name = "AvailableSubscriptions"
        availableSubsLabel.Parent = initialFrame
        availableSubsLabel.BackgroundTransparency = 1
        availableSubsLabel.Position = self.options.availableSubsPosition or UDim2.new(0, 165, 0, 55)
        availableSubsLabel.Size = self.options.availableSubsSize or UDim2.new(0, 143, 0, 25)
        availableSubsLabel.Font = Enum.Font.SciFi
        availableSubsLabel.Text = self.options.availableSubsText or "Available subscriptions"
        availableSubsLabel.TextColor3 = self.options.availableSubsTextColor or Color3.fromRGB(128, 149, 161)
        availableSubsLabel.TextSize = 20
        availableSubsLabel.TextXAlignment = Enum.TextXAlignment.Left
        availableSubsLabel.TextYAlignment = Enum.TextYAlignment.Top

        -- Button Frame
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Name = "buttonFrame"
        buttonFrame.Parent = initialFrame
        buttonFrame.BackgroundColor3 = Color3.fromRGB(3, 12, 26)
        buttonFrame.BorderSizePixel = 0
        buttonFrame.Position = UDim2.new(0, 165, 0, 111)
        buttonFrame.Size = UDim2.new(0, 303, 0, 73)
        local uiCornerButtonFrame = Instance.new("UICorner")
        uiCornerButtonFrame.CornerRadius = UDim.new(0, 10)
        uiCornerButtonFrame.Parent = buttonFrame

        -- Button
        local button = Instance.new("TextButton")
        button.Name = "button"
        button.Parent = buttonFrame
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Font = Enum.Font.SourceSans
        button.Text = ""
        button.TextSize = 14

        -- Overlay
        local overlay = Instance.new("Frame")
        overlay.Name = "overlay"
        overlay.Parent = loaderFrame
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.3
        overlay.BorderSizePixel = 0
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.Visible = false
        overlay.ZIndex = 5
        local uiCornerOverlay = Instance.new("UICorner")
        uiCornerOverlay.CornerRadius = UDim.new(0, 9)
        uiCornerOverlay.Parent = overlay
        self.ui.overlay = overlay

        -- Loader Selection Frame
        local loaderSelectionFrame = Instance.new("Frame")
        loaderSelectionFrame.Name = "loaderSelectionFrame"
        loaderSelectionFrame.Parent = loaderFrame
        loaderSelectionFrame.BackgroundTransparency = 1
        loaderSelectionFrame.Size = UDim2.new(1, 0, 1, 0)
        loaderSelectionFrame.Visible = false
        self.ui.loaderSelectionFrame = loaderSelectionFrame

        local loaderSelection = Instance.new("Frame")
        loaderSelection.Name = "loader_selection"
        loaderSelection.Parent = loaderSelectionFrame
        loaderSelection.AnchorPoint = Vector2.new(0.5, 0.5)
        loaderSelection.BackgroundColor3 = Color3.fromRGB(3, 12, 24)
        loaderSelection.BorderSizePixel = 0
        loaderSelection.Position = UDim2.new(0.5, 0, 0.5, 0)
        loaderSelection.Size = UDim2.new(0, 450, 0, 350)
        loaderSelection.ZIndex = 6
        local uiCornerLoaderSelection = Instance.new("UICorner")
        uiCornerLoaderSelection.CornerRadius = UDim.new(0, 3)
        uiCornerLoaderSelection.Parent = loaderSelection

        -- Close Button
        local closeButton = Instance.new("ImageButton")
        closeButton.Name = "Close"
        closeButton.Parent = loaderSelection
        closeButton.BackgroundTransparency = 1
        closeButton.Position = UDim2.new(0, 422, 0, 29)
        closeButton.Size = UDim2.new(0, 8, 0, 8)
        closeButton.Image = self.options.closeButtonImage or "http://www.roblox.com/asset/?id=126084898850977"

        -- Load Button
        local loadButton = Instance.new("TextButton")
        loadButton.Name = "Load"
        loadButton.Parent = loaderSelection
        loadButton.BackgroundColor3 = self.options.loadButtonColor or Color3.fromRGB(0, 123, 172)
        loadButton.BorderSizePixel = 0
        loadButton.Position = UDim2.new(0, 329, 0, 299)
        loadButton.Size = UDim2.new(0, 102, 0, 32)
        loadButton.Font = Enum.Font.SciFi
        loadButton.Text = self.options.loadButtonText or "         Load"
        loadButton.TextColor3 = self.options.loadButtonTextColor or Color3.fromRGB(172, 242, 253)
        loadButton.TextSize = 21
        local uiCornerLoadButton = Instance.new("UICorner")
        uiCornerLoadButton.CornerRadius = UDim.new(0, 5)
        uiCornerLoadButton.Parent = loadButton

        -- Launching Frame
        local launchingFrame = Instance.new("Frame")
        launchingFrame.Name = "launchingFrame"
        launchingFrame.Parent = loaderFrame
        launchingFrame.BackgroundTransparency = 1
        launchingFrame.Size = UDim2.new(1, 0, 1, 0)
        launchingFrame.Visible = false
        self.ui.launchingFrame = launchingFrame

        local launching = Instance.new("Frame")
        launching.Name = "launching"
        launching.Parent = launchingFrame
        launching.AnchorPoint = Vector2.new(0.5, 0.5)
        launching.BackgroundColor3 = Color3.fromRGB(3, 12, 24)
        launching.BorderSizePixel = 0
        launching.Position = UDim2.new(0.5, 0, 0.5, 0)
        launching.Size = UDim2.new(0, 310, 0, 206)
        local uiCornerLaunching = Instance.new("UICorner")
        uiCornerLaunching.CornerRadius = UDim.new(0, 3)
        uiCornerLaunching.Parent = launching

        -- Progress Bar Container
        local container = Instance.new("Frame")
        container.Name = "container"
        container.Parent = launching
        container.BackgroundColor3 = Color3.fromRGB(3, 17, 28)
        container.BorderSizePixel = 0
        container.Position = UDim2.new(0, 47, 0, 148)
        container.Size = UDim2.new(0, 217, 0, 3)
        local uiCornerContainer = Instance.new("UICorner")
        uiCornerContainer.CornerRadius = UDim.new(0, 3)
        uiCornerContainer.Parent = container

        -- Progress Bar
        local bar = Instance.new("Frame")
        bar.Name = "bar"
        bar.Parent = container
        bar.BackgroundColor3 = self.options.progressBarColor or Color3.fromRGB(28, 135, 181)
        bar.BorderSizePixel = 0
        bar.Size = UDim2.new(0, 0, 0, 3)
        bar.ZIndex = 2
        local uiCornerBar = Instance.new("UICorner")
        uiCornerBar.CornerRadius = UDim.new(0, 3)
        uiCornerBar.Parent = bar
        self.ui.progressBar = bar

        -- Setup Interactions
        button.MouseButton1Click:Connect(function()
            initialFrame.Visible = false
            loaderSelectionFrame.Visible = true
            overlay.Visible = true
            local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local overlayTween = TweenService:Create(overlay, tweenInfo, {BackgroundTransparency = 0.3})
            local selectionTween = TweenService:Create(loaderSelection, tweenInfo, {BackgroundTransparency = 0})
            overlayTween:Play()
            selectionTween:Play()
        end)

        closeButton.MouseButton1Click:Connect(function()
            loaderSelectionFrame.Visible = false
            overlay.Visible = false
            initialFrame.Visible = true
        end)

        loadButton.MouseButton1Click:Connect(function()
            loaderSelectionFrame.Visible = false
            overlay.Visible = false
            launchingFrame.Visible = true
            spawn(function()
                self:startLoadingAnimation(5)
            end)
        end)

        -- Add more UI elements (logos, images, etc.) similarly with options
        -- For brevity, not all elements are included here, but follow the same pattern
    end

    -- Method to start loading animation
    function library:startLoadingAnimation(duration)
        local maxWidth = 217
        local steps = 100
        local stepTime = duration / steps
        for i = 1, steps do
            local progress = i / steps
            local targetWidth = math.floor(maxWidth * progress)
            self.ui.progressBar.Size = UDim2.new(0, targetWidth, 0, 3)
            wait(stepTime)
        end
        if self.options.onLoadingComplete then
            self.options.onLoadingComplete()
        end
    end

    return library
end

return UILibrary
