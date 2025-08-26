local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library

function Library.new(windowName)
    local self = setmetatable({}, Library)

    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = windowName or "EazvyHub"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = PlayerGui

    -- Main Window Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 520, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    local mainCorner = Instance.new("UICorner", self.MainFrame)
    mainCorner.CornerRadius = UDim.new(0, 15)

    -- Draggable Top Bar
    self.TopBar = Instance.new("Frame")
    self.TopBar.Size = UDim2.new(1, 0, 0, 40)
    self.TopBar.Position = UDim2.new(0, 0, 0, 0)
    self.TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.TopBar.Parent = self.MainFrame
    local topBarCorner = Instance.new("UICorner", self.TopBar)
    topBarCorner.CornerRadius = UDim.new(0, 15)

    -- Title Label in top bar - set text to windowName or default text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = windowName or "EazvyHub"
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Parent = self.TopBar

    -- Make the window draggable via TopBar
    local dragging = false
    local dragInput, dragStart, startPos

    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            -- Also move tabs to match new position
            self.TabsContainer.Position = UDim2.new(
                self.MainFrame.Position.X.Scale,
                self.MainFrame.Position.X.Offset,
                self.MainFrame.Position.Y.Scale,
                self.MainFrame.Position.Y.Offset + 40 -- Below topbar
            )
        end
    end)

    -- Tabs Container on left side inside MainFrame
    self.TabsContainer = Instance.new("Frame")
    self.TabsContainer.Size = UDim2.new(0, 140, 1, -40)
    self.TabsContainer.Position = UDim2.new(0, 0, 0, 40)
    self.TabsContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    self.TabsContainer.Parent = self.MainFrame
    local tabsCorner = Instance.new("UICorner", self.TabsContainer)
    tabsCorner.CornerRadius = UDim.new(0, 15)

    -- ScrollingFrame for tabs with layout
    self.TabsList = Instance.new("ScrollingFrame")
    self.TabsList.Size = UDim2.new(1, 0, 1, 0)
    self.TabsList.BackgroundTransparency = 1
    self.TabsList.ScrollBarThickness = 6
    self.TabsList.Parent = self.TabsContainer

    local tabsLayout = Instance.new("UIListLayout", self.TabsList)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 8)

    -- Content container to the right of tabs
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Size = UDim2.new(1, -140, 1, -40)
    self.ContentContainer.Position = UDim2.new(0, 140, 0, 40)
    self.ContentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.ContentContainer.Parent = self.MainFrame
    local contentCorner = Instance.new("UICorner", self.ContentContainer)
    contentCorner.CornerRadius = UDim.new(0, 15)

    -- Close button with white bg and X symbol
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Text = "X"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -40, 0, 5)
    self.CloseButton.BackgroundColor3 = Color3.new(1, 1, 1)
    self.CloseButton.TextColor3 = Color3.fromRGB(40, 40, 40)
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.TextSize = 22
    self.CloseButton.Parent = self.TopBar
    self.CloseButton.AutoButtonColor = true
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui.Enabled = false
    end)

    -- Minimize button as thick horizontal white line next to close
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Text = ""
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 10)
    self.MinimizeButton.Position = UDim2.new(1, -80, 0, 15)
    self.MinimizeButton.BackgroundColor3 = Color3.new(1, 1, 1)
    self.MinimizeButton.AutoButtonColor = true
    self.MinimizeButton.TextTransparency = 1
    self.MinimizeButton.Parent = self.TopBar
    local minimizeLine = Instance.new("Frame")
    minimizeLine.Size = UDim2.new(0, 20, 0, 5)
    minimizeLine.Position = UDim2.new(0.5, -10, 0.5, -2.5)
    minimizeLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    minimizeLine.Parent = self.MinimizeButton
    local minLineCorner = Instance.new("UICorner", minimizeLine)
    minLineCorner.CornerRadius = UDim.new(1, 0)

    -- Store and manage UI elements for showing/hiding on minimize
    self.UIElements = {}

    self.isMinimized = false
    self.originalSize = self.MainFrame.Size

    -- Function to toggle minimize
    self.MinimizeButton.MouseButton1Click:Connect(function()
        if not self.isMinimized then
            TweenService:Create(self.MainFrame, TweenInfo.new(0.35), {Size = UDim2.new(self.MainFrame.Size.X.Scale, self.MainFrame.Size.X.Offset, 0, 50)}):Play()
            -- Hide content, tabs and controls except top bar
            for _, elem in pairs(self.UIElements) do
                elem.Visible = false
            end
            self.TabsContainer.Visible = false
            self.ContentContainer.Visible = false
            self.isMinimized = true
        else
            TweenService:Create(self.MainFrame, TweenInfo.new(0.35), {Size = self.originalSize}):Play()
            for _, elem in pairs(self.UIElements) do
                elem.Visible = true
            end
            self.TabsContainer.Visible = true
            self.ContentContainer.Visible = true
            self.isMinimized = false
        end
    end)

    -- Tab Management -

    self.Tabs = {}
    self.CurrentTab = nil

    -- Add a tab function
    function self:AddTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -20, 0, 35)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabButton.BackgroundTransparency = 1
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 15
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Parent = self.TabsList

        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = self.ContentContainer

        -- UI Elements container per tab for toggles etc
        local elements = {}

        function tabContent:AddToggle(name, posY)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 40)
            frame.Position = UDim2.new(0, 0, 0, posY)
            frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            frame.Parent = tabContent
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)

            local label = Instance.new("TextLabel")
            label.Text = name
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local toggleButton = Instance.new("ImageButton")
            toggleButton.Size = UDim2.new(0, 32, 0, 32)
            toggleButton.Position = UDim2.new(1, -44, 0.5, -16)
            toggleButton.BackgroundColor3 = Color3.fromRGB(120, 0, 30)
            toggleButton.Parent = frame
            local toggleCorner = Instance.new("UICorner", toggleButton)
            toggleCorner.CornerRadius = UDim.new(0, 11)

            local toggled = false
            toggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                if toggled then
                    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                else
                    toggleButton.BackgroundColor3 = Color3.fromRGB(120, 0, 30)
                end
            end)

            table.insert(elements, frame)
            table.insert(self.UIElements, frame)
            return toggleButton
        end

        function tabContent:AddButton(name, posY, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.Position = UDim2.new(0, 0, 0, posY)
            btn.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
            btn.Text = name
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 16
            btn.Parent = tabContent
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

            btn.MouseButton1Click:Connect(callback)

            table.insert(elements, btn)
            table.insert(self.UIElements, btn)
            return btn
        end

        function tabContent:AddLabel(title, content, posY)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.Position = UDim2.new(0, 0, 0, posY)
            frame.BackgroundTransparency = 1
            frame.Parent = tabContent

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Text = title
            titleLabel.TextColor3 = Color3.new(1, 1, 1)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 16
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.BackgroundTransparency = 1
            titleLabel.Size = UDim2.new(1, 0, 0, 20)
            titleLabel.Parent = frame

            local contentLabel = Instance.new("TextLabel")
            contentLabel.Text = content or ""
            contentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.TextSize = 14
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.BackgroundTransparency = 1
            contentLabel.Size = UDim2.new(1, 0, 0, 28)
            contentLabel.Position = UDim2.new(0, 0, 0, 22)
            contentLabel.Parent = frame

            table.insert(elements, frame)
            table.insert(self.UIElements, frame)

            return frame
        end

        function tabContent:AddDropdown(name, options, posY, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 36)
            frame.Position = UDim2.new(0, 0, 0, posY)
            frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            frame.Parent = tabContent
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

            local label = Instance.new("TextLabel")
            label.Text = name
            label.Size = UDim2.new(0.4, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(0.55, 0, 1, 0)
            dropdown.Position = UDim2.new(0.45, 0, 0, 0)
            dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            dropdown.TextColor3 = Color3.new(1, 1, 1)
            dropdown.Font = Enum.Font.Gotham
            dropdown.TextSize = 16
            dropdown.Text = options[1] or ""
            dropdown.Parent = frame
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 10)

            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(0, dropdown.AbsoluteSize.X, 0, 0)
            listFrame.Position = UDim2.new(0, 0, 1, 2)
            listFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            listFrame.ClipsDescendants = true
            listFrame.Visible = false
            listFrame.Parent = dropdown

            local uiList = Instance.new("UIListLayout", listFrame)
            uiList.SortOrder = Enum.SortOrder.LayoutOrder

            for i, option in ipairs(options) do
                local optionBtn = Instance.new("TextButton")
                optionBtn.Size = UDim2.new(1, 0, 0, 30)
                optionBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                optionBtn.Text = option
                optionBtn.TextColor3 = Color3.new(1, 1, 1)
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.TextSize = 14
                optionBtn.LayoutOrder = i
                optionBtn.Parent = listFrame

                optionBtn.MouseButton1Click:Connect(function()
                    dropdown.Text = option
                    listFrame.Visible = false
                    if callback then callback(option) end
                end)
            end

            local function updateListSize()
                listFrame.Size = UDim2.new(0, dropdown.AbsoluteSize.X, 0, uiList.AbsoluteContentSize.Y)
            end

            uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateListSize)
            updateListSize()

            dropdown.MouseButton1Click:Connect(function()
                listFrame.Visible = not listFrame.Visible
            end)

            table.insert(elements, frame)
            table.insert(self.UIElements, frame)

            return dropdown
        end

        tabContent.Visible = false

        table.insert(self.Tabs, {Button = tabButton, Content = tabContent})

        tabButton.MouseButton1Click:Connect(function()
            self:SwitchTab(#self.Tabs)
        end)

        return tabContent
    end

    function self:SwitchTab(index)
        for i, tab in ipairs(self.Tabs) do
            local active = (i == index)
            tab.Content.Visible = active
            tab.Button.TextColor3 = active and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
            self.CurrentTab = index
        end
    end

    setmetatable(self, Library)
    return self
end

setmetatable(Library, Library)
return Library
