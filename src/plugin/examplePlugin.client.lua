local Iris = require(script.Parent.Iris)

local Toolbar: PluginToolbar = plugin:CreateToolbar("Iris")
local ToggleButton: PluginToolbarButton = Toolbar:CreateButton("Toggle Iris", "Toggle Iris running in a plugin window.", "rbxassetid://11505661049")
ToggleButton.ClickableWhenViewportHidden = true

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
        Iris:Connect(Iris.ShowDemoWindow())
    end
    IrisEnabled = not IrisEnabled
    IrisWidget.Enabled = IrisEnabled
    ToggleButton:SetActive(IrisEnabled)
end)
