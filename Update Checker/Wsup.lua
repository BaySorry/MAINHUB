local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function ShowUpdateBanner(gameName)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UpdateBanner"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(1, 0, 0, 52)
    banner.Position = UDim2.new(0, 0, 0, -60)
    banner.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    banner.BorderSizePixel = 0
    banner.ZIndex = 10
    banner.Parent = screenGui

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(1, 0, 0, 3)
    stripe.Position = UDim2.new(0, 0, 1, -3)
    stripe.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    stripe.BorderSizePixel = 0
    stripe.ZIndex = 11
    stripe.Parent = banner

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 50, 1, 0)
    icon.Position = UDim2.new(0, 12, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚠"
    icon.TextColor3 = Color3.fromRGB(255, 220, 60)
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 11
    icon.Parent = banner

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 60, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "⚡ [" .. gameName .. "] NEEDS TO BE UPDATED — Please wait for the next version."
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = false
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 11
    label.Parent = banner

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local slideDown = TweenService:Create(banner, tweenInfo, { Position = UDim2.new(0, 0, 0, 0) })
    local slideUp = TweenService:Create(banner, tweenInfo, { Position = UDim2.new(0, 0, 0, -60) })

    task.spawn(function()
        task.wait(1.5)
        slideDown:Play()
        task.wait(5)
        slideUp:Play()
        slideUp.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

-- DATA: GAME REGISTRY
local Database = {
    ["70845479499574"] = {
        Name = "Bite By Night",
        ScriptUrl = "https://raw.githubusercontent.com/username/repo/main/bite.lua",
        NeedsUpdate = false
    },
}

return {
    Database = Database,
    ShowBanner = ShowUpdateBanner
}
