
UNFINISHED!!!

# Iris

Iris is an Immediate mode GUI Library for Roblox, Based on [Dear ImGui](https://github.com/ocornut/imgui). It solves the same problems as Dear ImGui: providing a simple and bloat-free UI system, designed for visualisation and debugging. It is fast, portable, and self-contained (no external dependencies).

# Iris4Cheats
Iris4Cheats is an fork of Iris made to be used for cheats in roblox as an gui lib.
The planed changes for this fork are:

- Load all modules via web
- Change coregui instead of playergui

#### What is Dear ImGui, and why is it important?
Dear ImGui is best known for allowing developers to create content-creation and visualisation and debugging UI. Using the Dear ImGui paradigm (Immediate Mode), UI design is remarkably easy and simple. Because of this, Dear ImGui has been adopted in almost every major game engine from Unity and Unreal Engine to in-house engines from Rockstar and Ubisoft (and now Roblox!).

Iris favors simplicity and productivity; It is designed to simplify UI, streamlining the process for creating visualisation, debug, and data input tools. To accomplish this, Iris offers a different approach to Roblox UI than existing libraries, at the cost of certain features commonly found in more intricate UI libraries. Iris opts to supercede the Roblox UI API, instead having a streamlined Immediate-Mode library and a set of widgets which developers can use to build the UI and tools they need.

Demo Place: https://rblx.games/7245022703

### Usage

Heres an simple example script for iris:

``` luau
-- include iris
local Iris = require(game:HttpGet('https://raw.githubusercontent.com/NoobProgramer6918/Iris4Cheats/refs/heads/main/lib/init.lua')).Init()

local CheatWindows = {}

CheatWindows.Main = function()
  Iris.Window {"Cheat"}
  Iris.Text {"Hello!"}
  if Iris.Button {"esp"}.clicked() then
    -- esp stuff that i wont include since this is simple
  end
  Iris.InputNum {"totaly changes your speed"}

  Iris.End() -- when doing some thing like creating an Window
  -- treat this like an normal lua 'end' but just for iris stuff
end

Iris:Connect(CheatWindows.Main) -- connect the window function to iris

```

### Learning Iris

The best way to learn Iris is to look at the `Iris.DemoWindow` example file, which showcases all of Iris' features. The code can be found under `lib\demoWindow.lua`.

### How it Works

Iris is an immediate mode UI library, as opposed to retained mode.

In a retained mode model, you might make a button and connect a clicked event, with code that is invoked when the event happens. The button is retained in the DataModel, and to change the text on it you need to store a reference to it.

In an immediate mode model, we call the button function and check if it's been clicked every frame (60 times per second). There's no need for a clicked event or to store a reference to the button.

Therefore, you are not keeping track of the UI instances, you just declare what functionality you would like and Iris manages all instances and cleanup for you.

Check out the Dear ImGuis [About the IMGUI paradigm](https://github.com/ocornut/imgui/wiki/About-the-IMGUI-paradigm) section if you want to understand the core principles behind the IMGUI paradigm.

### Extensions

Iris has an amazing community, who have created some extensions to Iris or adding new features. Check them out!
- [ImPlot](https://devforum.roblox.com/t/4301691): a range of 2D graphing and plotting widgets - [LinusKat/ImPlot](https://github.com/LinusKat/ImPlot)
- [Ceive ImGizmo](https://devforum.roblox.com/t/2470790): a 3D gizmo rendering library - [JakeyWasTaken/CeiveImGizmo](https://github.com/JakeyWasTaken/CeiveImGizmo)

### Credits

Created originally by [Michael_48](https://github.com/Michael-48) and now maintained by [SirMallard](https://github.com/SirMallard).

Many thanks to [JakeyWasTaken](https://github.com/JakeyWasTaken), [OverHash](https://github.com/OverHash) and everyone else who has contributed to Iris in any way.

Inspriation and design: [Omar Cornut](https://www.miracleworld.net/), [Evaera](https://github.com/evaera).

Fork by NoobProgramer6918 on github!

Thanks!
