---
sidebar_position: 1
---

# Iris

Iris is an immediate mode GUI Library for Roblox, based on Dear ImGui, for creating the UI for debug / visualisation and content-creation tools.

Iris does this by requiring the developer to only describe what they want, letting Iris will handle all of the 'how'. This allows quick iterations with simple and minimal code to produce the tools you need anywhere in your game. Iris makes it faster and more convenient for developers to use a wide range of powerful widgets to build their UI systems. Iris is aimed at the developers who need to quickly check and alter code in development rather than an end-user UI solution, but how you use it is up to you.

Iris uses an immediate mode UI paradigm, which is different from other conventional UI libraries designed for Roblox. Instead of keeping a reference to every UI element, with Iris you declare the UI you want to appear every frame and it will show you what you asked for. Iris also manages the layout and arrangment of UI elements, making it simple to construct a fully suite of UI debugging tools without worrying about where the UI is going to be positioned.

## Demonstration

### Simple Example

With just 8 lines of code, you can create a basic window and simple widgets, with instant functionality:

<div style={{"width": "100%", "display": "flex", "flex-direction": "row", "justify-content": "center"}}>
<div style={{"width": "50%", "align": "center"}}>

```lua
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris).Init()

Iris:Connect(function()
    Iris.Window("My First Window!")
        Iris.Text("Hello, World")
        Iris.Button("Save")
        Iris.InputNum("Input")
    Iris.End()
end)
```
</div>
<div style={{"width": "50%", "display": "flex", "justify-content": "center", "align-items": "center"}}>
    <img src="/Iris/assets/docs/simpleExample1.png" />
</div>
</div>

We can break this code down to explain Iris better:
```lua
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
-- initialise Iris, placing it by default under the PlayerGui
local Iris = require(StarterPlayerScripts.Client.Iris).Init()

-- use `:Connect()` to create a function that will run every frame, or provide your
-- own loop. as long as your code executes every frame, your UI will show
Iris:Connect(function()
    -- createa a window and give it a title. 
    -- windows can be  moved and resized and all widgets are descendents of them
    Iris.Window("My First Window!")
        -- show text, including RichText
        Iris.Text("Hello, World")
        -- handle an event when a user clicks a button
        Iris.Button("Save")
        -- input a number, with optional constraints
        Iris.InputNum("Input")
    -- any parent widget (Windows, Trees, Tables) *must* end with an `.End()`.
    -- to make it easier to read, use a do-end block for indentation
    Iris.End()
end)
```

### More Complex Example

We can also then make a more complicated example:

<div style={{"width": "100%", "display": "flex", "flex-direction": "row", "justify-content": "center"}}>
<div style={{"width": "50%", "align": "center"}}>

```lua
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris).Init()

Iris:Connect(function()
    local windowSize = Iris.State(Vector2.new(300, 400))

    Iris.Window("My Second Window", nil, windowSize)
        Iris.Text("The current time is: " .. time())

        Iris.InputText("Enter Text")

        if Iris.Button("Click me").clicked() then
            print("button was clicked")
        end

        Iris.InputColor4()

        Iris.Tree()
            for i = 1,8 do
                Iris.Text("Text in a loop: " .. i)
            end
        Iris.End()
    Iris.End()
end)
```
</div>
<div style={{"width":"50%", "display": "flex", "justify-content": "center", "align-items": "center"}}>
    <img src="/Iris/assets/docs/simpleExample2.png" />
</div>
</div>

This example has introduced the state object which allows us to control the state or value of Iris widgets and use these values in actual code. This is the bridge between your variables and being able to modify them in Iris. We also demonstrate the tree node which is useful for helping organise your UI.

## Adding to your Game

So far we've seen how Iris works in a simple environment, but Iris is most helpful when you are using it alongside your main code. For more examples of Iris being used in actual games as either debug and visualisation tools or for content creation tooling, checkout the [Showcases](./showcase.md) page.
