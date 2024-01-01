local Iris = require(script.Parent.Iris)

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

IrisWidget:BindToClose(function()
    IrisEnabled = false
    IrisWidget.Enabled = false
    ToggleButton:SetActive(false)
end)

ToggleButton.Click:Connect(function()
    if not Iris.Internal._started then
        Iris.Internal._rootConfig.UseScreenGUIs = false
        Iris.Init(IrisWidget)
        Iris:Connect(Iris.ShowDemoWindow)
    end
    IrisEnabled = not IrisEnabled
    IrisWidget.Enabled = IrisEnabled
    ToggleButton:SetActive(IrisEnabled)
end)

local function shutdown()
    if Iris.Internal._started then
        Iris.Shutdown()
    end
    IrisEnabled = false
    IrisWidget.Enabled = false
    ToggleButton:SetActive(false)
    ShutdownButton:SetActive(false)
end

ShutdownButton.Click:Connect(shutdown)
plugin.Unloading:Connect(shutdown)
