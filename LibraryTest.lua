local Library = {}
Library.__index = Library

function Library:MakeWindow(config)
    local Window = {}
    Window.__index = Window
    Window.Tabs = {}

    -- ScreenGui root for this window
    Window.ScreenGui = Instance.new("ScreenGui")
    Window.ScreenGui.Name = config.Name or "Window"
    Window.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Main frame contains content area and controls
    Window.MainFrame = Instance.new("Frame")
    Window.MainFrame.Size = UDim2.new(0, 500, 0, 350)
    Window.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    Window.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Window.MainFrame.Parent = Window.ScreenGui
    Instance.new("UICorner", Window.MainFrame).CornerRadius = UDim.new(0, 12)

    -- Sidebar frame (fixed, no shrink)
    Window.Sidebar = Instance.new("Frame")
    Window.Sidebar.Size = UDim2.new(0, 140, 0, 350)
    Window.Sidebar.Position = UDim2.new(0.5, -250, 0.5, -175)
    Window.Sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Window.Sidebar.Parent = Window.ScreenGui
    Instance.new("UICorner", Window.Sidebar).CornerRadius = UDim.new(0, 12)

    -- Sidebar buttons container (scrollable)
    Window.SidebarList = Instance.new("ScrollingFrame")
    Window.SidebarList.Size = UDim2.new(1, 0, 1, -60)
    Window.SidebarList.Position = UDim2.new(0, 0, 0, 50)
    Window.SidebarList.BackgroundTransparency = 1
    Window.SidebarList.ScrollBarThickness = 6
    Window.SidebarList.Parent = Window.Sidebar
    Instance.new("UIListLayout", Window.SidebarList).Padding = UDim.new(0, 8)

    -- Content frame inside MainFrame (minimizable)
    Window.ContentFrame = Instance.new("Frame")
    Window.ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    Window.ContentFrame.Position = UDim2.new(0, 0, 0, 0)
    Window.ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Window.ContentFrame.Parent = Window.MainFrame
    Instance.new("UICorner", Window.ContentFrame).CornerRadius = UDim.new(0, 12)

    -- Close button
    Window.CloseButton = Instance.new("ImageButton")
    Window.CloseButton.Size = UDim2.new(0, 25, 0, 25)
    Window.CloseButton.Position = UDim2.new(1, -35, 0, 10)
    Window.CloseButton.BackgroundTransparency = 1
    Window.CloseButton.Image = "rbxassetid://3926307974"
    Window.CloseButton.Parent = Window.MainFrame
    Window.CloseButton.MouseButton1Click:Connect(function()
        Window.ScreenGui.Enabled = false
    end)

    -- Minimize button (square with horizontal line)
    Window.MinimizeButton = Instance.new("Frame")
    Window.MinimizeButton.Size = UDim2.new(0, 26, 0, 26)
    Window.MinimizeButton.Position = UDim2.new(1, -65, 0, 15)
    Window.MinimizeButton.BackgroundColor3 = Color3.new(1, 1, 1)
    Window.MinimizeButton.Active = true
    Window.MinimizeButton.Parent = Window.MainFrame
    local minCorner = Instance.new("UICorner", Window.MinimizeButton)
    minCorner.CornerRadius = UDim.new(0, 6)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 14, 0, 3)
    line.Position = UDim2.new(0.5, -7, 0.5, -1.5)
    line.BackgroundColor3 = Color3.new(0, 0, 0)
    line.Parent = Window.MinimizeButton
    local lineRound = Instance.new("UICorner", line)
    lineRound.CornerRadius = UDim.new(0, 1.5)

    Window.isMinimized = false
    Window.originalContentSize = Window.ContentFrame.Size

    Window.tabs = {}
    Window.tabContentElements = {}
    Window.activeTabIndex = 1

    Window.MinimizeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not Window.isMinimized then
                TweenService:Create(Window.ContentFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 5)}):Play()
                for _, elements in pairs(Window.tabContentElements) do
                    for _, element in pairs(elements) do
                        element.Visible = false
                    end
                end
                Window.isMinimized = true
            else
                TweenService:Create(Window.ContentFrame, TweenInfo.new(0.3), {Size = Window.originalContentSize}):Play()
                for _, elements in pairs(Window.tabContentElements) do
                    for _, element in pairs(elements) do
                        element.Visible = true
                    end
                end
                Window.isMinimized = false
            end
        end
    end)

    function Window:AddTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 36)
        btn.BackgroundTransparency = 1
        btn.Text = "  "..name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Parent = self.SidebarList
        btn.LayoutOrder = #self.tabs + 1

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Visible = false
        container.Parent = self.ContentFrame

        table.insert(self.tabs, {Button = btn, Content = container})
        self.tabContentElements[#self.tabs] = {}

        btn.MouseButton1Click:Connect(function()
            self:SwitchTab(#self.tabs)
        end)

        return container
    end

    function Window:SwitchTab(index)
        for i, tab in ipairs(self.tabs) do
            local active = (i == index)
            tab.Content.Visible = active
            tab.Button.TextColor3 = active and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
            self.activeTabIndex = index
        end
    end

    function Window:CreateToggle(parent, name, posY)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, posY)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.Parent = parent
        local cr = Instance.new("UICorner", frame)
        cr.CornerRadius = UDim.new(0, 15)

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

        table.insert(self.tabContentElements[self.activeTabIndex], frame)
        return toggleButton
    end

    function Window:CreateButton(parent, name, posY, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, posY)
        btn.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

        btn.MouseButton1Click:Connect(callback)

        table.insert(self.tabContentElements[self.activeTabIndex], btn)
        return btn
    end

    function Window:CreateLabel(parent, title, content, posY)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.Position = UDim2.new(0, 0, 0, posY)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.Parent = frame

        local contentLabel = Instance.new("TextLabel")
        contentLabel.Text = content
        contentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.TextSize = 14
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.BackgroundTransparency = 1
        contentLabel.Size = UDim2.new(1, 0, 0, 28)
        contentLabel.Position = UDim2.new(0, 0, 0, 22)
        contentLabel.Parent = frame

        table.insert(self.tabContentElements[self.activeTabIndex], frame)
        return frame
    end

    function Window:CreateTextBox(parent, placeholder, posY, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 0, 36)
        box.Position = UDim2.new(0, 0, 0, posY)
        box.PlaceholderText = placeholder or ""
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        box.TextColor3 = Color3.fromRGB(240, 240, 240)
        box.Font = Enum.Font.GothamSemibold
        box.TextSize = 16
        box.Parent = parent
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

        box.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(box.Text)
            end
        end)

        table.insert(self.tabContentElements[self.activeTabIndex], box)
        return box
    end

    function Window:CreateDropdown(parent, name, options, posY, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.Position = UDim2.new(0, 0, 0, posY)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local label = Instance.new("TextLabel")
        label.Text = name
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local dropdown = Instance.new("TextButton")
        dropdown.Size = UDim2.new(0.55, 0, 1, 0)
        dropdown.Position = UDim2.new(0.45, 0, 0, 0)
        dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropdown.TextColor3 = Color3.fromRGB(240, 240, 240)
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
            optionBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            optionBtn.Font = Enum.Font.Gotham
            optionBtn.TextSize = 14
            optionBtn.LayoutOrder = i
            optionBtn.Parent = listFrame

            optionBtn.MouseButton1Click:Connect(function()
                dropdown.Text = option
                listFrame.Visible = false
                if callback then
                    callback(option)
                end
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

        table.insert(self.tabContentElements[self.activeTabIndex], frame)
        return dropdown
    end

    setmetatable(Window, Window)
    return Window
end

setmetatable(Library, Library)
return Library
