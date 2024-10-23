
# Iris

Iris is an Immediate mode GUI Library for Roblox, Based on [Dear ImGui](https://github.com/ocornut/imgui). It solves the same problems as Dear ImGui: providing a simple and bloat-free UI system, designed for visualisation and debugging. It is fast, portable, and self-contained (no external dependencies).

#### What is Dear ImGui, and why is it important?
Dear ImGui is best known for allowing developers to create content-creation and visualisation and debugging UI UI. Using the Dear ImGui paradigm (Immediate Mode), UI design is remarkably easy and simple. Because of this, Dear ImGui has been adopted in almost every major game engine from Unity and Unreal Engine to in-house engines from Rockstar and Ubisoft (and now Roblox!).

Iris favors simplicity and productivity; It is designed to simplify UI, streamlining the process for creating visualisation, debug, and data input tools. To accomplish this, Iris offers a different approach to Roblox UI than existing libraries, at the cost of certain features commonly found in more intricate UI libraries. Iris opts to supercede the Roblox UI API, instead having a streamlined Immediate-Mode library and a set of widgets which developers can use to build the UI and tools they need.

Demo Place: https://rblx.games/11145814918

### Usage

Iris can be installed through [Wally](https://wally.run/) as a [package](https://wally.run/package/sirmallard/iris) or through a GitHub release comes as an rbxm or zip file. You can import the rbxm into any roblox project, and begin creating UI in any client side script. No external dependences are needed. Iris can be used in any kind of Roblox UI, including PlayerGui, CoreGui, BillboardGui, SurfaceGui, and PluginGui.

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

<div align="center">
    <img src="https://raw.githubusercontent.com/Michael-48/Iris/main/assets/simpleDarkExample.png" alt="Sample Display Output"/>
</div>

And a more complex Example:

```lua
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris).Init()

Iris:Connect(function()
    -- use a unique window size, rather than default
    local windowSize = Iris.State(Vector2.new(300, 400))

    Iris.Window({"My Second Window"}, {size = windowSize})
        Iris.Text({"The current time is: " .. time()})

        Iris.InputText({"Enter Text"})

        if Iris.Button({"Click me"}).clicked() then
            print("button was clicked")
        end

        Iris.InputColor4()

        Iris.Tree()
            for i = 1,8 do
                Iris.Text({"Text in a loop: " .. i})
            end
        Iris.End()
    Iris.End()
end)
```

<div align="center">
    <img src="https://raw.githubusercontent.com/Michael-48/Iris/main/assets/complexDarkExample.png" alt="Sample Display Output"/>
</div>

The appearance of Iris is fully customizable, including colors, fonts, transparencies and layout. By default, Iris comes with a dark theme and light theme, as well as 2 layout themes.

```lua
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)

Iris:Connect(Iris.ShowDemoWindow)
```

<div align="center">
    <img src="https://raw.githubusercontent.com/Michael-48/Iris/main/assets/simpleLightExample.png" alt="Sample Display Output"/>
</div>

Finally, Iris comes with a demo window, `Iris.ShowDemoWindow`. This window demonstrates the functionality of every part of the library, and contains useful utilities, like a style editor and a runtime information window. It is a useful reference for you and other coders can to refer to.

<div align="center">
    <img src="https://raw.githubusercontent.com/Michael-48/Iris/main/assets/demoWindow.png" alt="Sample Display Output"/>
</div>

### Learning Iris

The best way to learn Iris is to look at the `Iris.DemoWindow` example file, which showcases all of Iris' features. The code can be found under `lib\demoWindow.lua`.

### How it Works

Iris is an immediate mode UI library, as opposed to retained mode.

In a retained mode model, you might make a button and connect a clicked event, with code that is invoked when the event happens. The button is retained in the DataModel, and to change the text on it you need to store a reference to it.

In an immediate mode model, we call the button function and check if it's been clicked every frame (60 times per second). There's no need for a clicked event or to store a reference to the button.

Therefore, you are not keeping track of the UI instances, you just declare what functionality you would like and Iris manages all instances and cleanup for you.

Check out the Dear ImGuis [About the IMGUI paradigm](https://github.com/ocornut/imgui/wiki/About-the-IMGUI-paradigm) section if you want to understand the core principles behind the IMGUI paradigm.

### Credits

Created originally by [Michael_48](https://github.com/Michael-48) and now maintained by [SirMallard](https://github.com/SirMallard).

Many thanks to [JakeyWasTaken](https://github.com/JakeyWasTaken), [OverHash](https://github.com/OverHash) and everyone else who has contributed to Iris in any way.

Inspriation and design: [Omar Cornut](https://www.miracleworld.net/), [Evaera](https://github.com/evaera), Thanks!
<meta name="google-site-verification" content="Ito4GceH5YJJXReIhx9JMqN0YEDdKePHaylk8H3-9Oo" />
