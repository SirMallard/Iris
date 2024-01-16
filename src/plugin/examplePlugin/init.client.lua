local Iris = require(script.Parent.Iris)

local Input = require(script.Input)

local Toolbar: PluginToolbar = plugin:CreateToolbar("Iris")
local ToggleButton: PluginToolbarButton = Toolbar:CreateButton("Toggle Iris", "Toggle Iris running in a plugin window.", "rbxasset://textures/AnimationEditor/icon_checkmark.png")
ToggleButton.ClickableWhenViewportHidden = true

local ShutdownButton: PluginToolbarButton = Toolbar:CreateButton("Shutdown Iris", "Shutdown Iris from running.", "rbxasset://textures/AnimationEditor/icon_close.png")
ShutdownButton.ClickableWhenViewportHidden = true

local IrisEnabled: boolean = false

local widgetInfo: DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 300)

local IrisWidget: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("IrisWidget", widgetInfo)
IrisWidget.Title = "Iris"
IrisWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
IrisWidget.Name = "Iris"

Iris.Internal._utility.UserInputService = Input
Iris.UpdateGlobalConfig({
    UseScreenGUIs = false,
    UsePluginEnvironment = true,
})
Iris.Disabled = true

Iris.Init(IrisWidget)
Iris:Connect(Iris.ShowDemoWindow)

Input.SinkFrame.Parent = IrisWidget

IrisWidget:BindToClose(function()
    IrisEnabled = false
    IrisWidget.Enabled = false
    Iris.Disabled = true
    ToggleButton:SetActive(false)
end)

ToggleButton.Click:Connect(function()
    IrisEnabled = not IrisEnabled
    IrisWidget.Enabled = IrisEnabled
    Iris.Disabled = not IrisEnabled
    ToggleButton:SetActive(IrisEnabled)
end)

local function shutdown()
    ShutdownButton:SetActive(true)
    Iris.Shutdown()

    for _, connection in Input._connections do
        connection:DisconnectAll()
    end

    Input.SinkFrame:Destroy()

    IrisEnabled = false
    IrisWidget.Enabled = false
    Iris.Disabled = true
    ToggleButton:SetActive(false)
    ShutdownButton:SetActive(false)
end

ShutdownButton.Click:Connect(shutdown)
plugin.Unloading:Connect(shutdown)
