# Iris
Iris is an Immediate mode GUI Library for Roblox, Based on [Dear ImGui](https://github.com/ocornut/imgui). It aims to solve the same problems as Dear ImGui. It is fast, portable, and self-contained (no external dependencies).

<sub> what is Dear ImGui, and why is it important?
Dear ImGui is best known for its widespread use for developing debug UI. Using the Dear ImGui paradigm (Immediate Mode), UI is remarkably easy. Because of this, Dear ImGui has seen adoption in almost every major game engine, including Unity and Unreal Engine (and now Roblox!).
</sub>

Iris favors simplicity and productivity; It is designed to simplify UI, streamlining the process for creating visualization, debug tools, and data input. To accomplish this, Iris offers a different approach to Roblox UI than existing libraries, lacking certain features commonly found in more intricate UI libraries. Iris opts to supercede the Roblox engine UI, instead offering a streamlined Immediate-Mode library and a set of widgets to empower developers to create UI easily.

### Usage
The Iris release comes packaged as a single ModuleScript. You can import this ModuleScript into any roblox project, and begin creating UI in any client side script! No external dependences are needed. Iris can be used in any kind of Roblox UI, including PlayerGui, CoreGui, BillboardGui, SurfaceGui, and PluginGui.

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
![Sample Code Output](https://raw.githubusercontent.com/Michael-48/Iris/main/.github/images/simpleDarkExample.png)

### How it Works
the

### Integration
the

### Credits
Developed By [Michael_48](https://github.com/Michael-48). Design, Inspriation and Feedback: [Omar Cornut](https://www.miracleworld.net/), [Evaera](https://github.com/evaera), and [JakeyWasTaken](https://github.com/JakeyWasTaken). Thanks!