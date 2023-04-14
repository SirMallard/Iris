# Iris
Iris is an Immediate mode GUI Library for Roblox, Based on [Dear ImGui](https://github.com/ocornut/imgui). It aims to solve the same problems as Dear ImGui. It is fast, portable, and self-contained (no external dependencies).

what is Dear ImGui, and why is it important?
<sub>Dear ImGui is best known for its widespread use for developing debug UI. Using the Dear ImGui paradigm (Immediate Mode), UI is remarkably easy. Because of this, Dear ImGui has seen adoption in almost every major game engine, including Unity and Unreal Engine (and now Roblox!).</sub>

Iris favors simplicity and productivity; It is designed to simplify UI, streamlining the process for creating visualization, debug tools, and data input. To accomplish this, Iris offers a different approach to Roblox UI than existing libraries, lacking certain features commonly found in more intricate UI libraries. Iris opts to supercede the Roblox engine UI, instead offering a streamlined Immediate-Mode library and a set of widgets to empower developers to create UI easily.

### Usage
The Iris release comes packaged as a single ModuleScript. You can import this ModuleScript into any roblox project, and begin creating UI in any client side script! No external dependences are needed. Iris can be used in any kind of Roblox UI, including PlayerGui, CoreGui, BillboardGui, SurfaceGui, and PluginGui.

Heres a basic Example:
```lua
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris).Init()

Iris:Connect(function()
    Iris.Window({"My First Window!"})
        Iris.Text({"Hello, World"})
        Iris.Button({"Save"})
        Iris.InputNum({"Input"})
    Iris.End()
end)
```
![Sample Code Output](/assets/simpleDarkExample.png)

And a more complex Example:
```lua
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris).Init()

Iris:Connect(function()
	-- use a unique window size, rather than default
	local windowSize = Iris.State(Vector2.new(500, 600))

	Iris.Window({"My Second Window"}, {size = windowSize})
		Iris.Text({"The current time is: " .. os.clock()})

		Iris.InputText({"Enter Text"})

		if Iris.Button({"Click me"}).clicked then
			print("button was clicked")
		end

		Iris.Tree({"A list of buttons"})
			for i = 1,10 do
				Iris.Button({"Button - " .. i})
			end
		Iris.End()
	Iris.End()
end)
```
![Sample Code Output](/assets/complexDarkExample.png)

The appearance of Iris is fully customizable; colors, fonts, transparencies, and layout are all customizable. By default, Iris comes with a dark theme and light theme, as well as 2 layout themes.

```lua
Iris.UpdateGlobalConfig(Iris.templateConfig.colorLight)
Iris.UpdateGlobalConfig(Iris.templateConfig.sizeClear)

Iris:Connect(Iris.ShowDemoWindow)
```
![Sample Code Output](/assets/simpleLightExample.png)

Finally, Iris comes with a demo window, `Iris.ShowDemoWindow`. This window demonstrates the functionality of aspect of the library, and contains useful utilities, a style editor and a runtime information window. It is the most useful reference that you and other coders will want to refer to.

### How it Works
the

Check out the Dear ImGuis [About the IMGUI paradigm](https://github.com/ocornut/imgui/wiki/About-the-IMGUI-paradigm) section if you want to understand the core principles behind the IMGUI paradigm.

### Integration
the

### Credits
Developed By [Michael_48](https://github.com/Michael-48). Design, Inspriation and Feedback: [Omar Cornut](https://www.miracleworld.net/), [Evaera](https://github.com/evaera), and [JakeyWasTaken](https://github.com/JakeyWasTaken). Thanks!