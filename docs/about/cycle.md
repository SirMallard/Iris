---
sidebar_position: 1
---

# Understanding the Lifecycle

## General Game Lifecycle

Iris works on the premise of a 'game loop'. A game loop is the top-level structure to determine the order of execution
of each part of the game (this is not just game scripts, but everything from user input handling, to final rendering). 

A typical game loop make look very similar to this:

```cpp
while(not_closed) {
    poll_input();
    update_game_state();
    step_physics();
    render_content();
    wait(); // for a 60 fps limit
}
```
Firstly, we handle any user inputs, that is, the mouse being moved, a key press or release, or anything else related to
the user. The user input is responsible for affecting the next frame, so we handle these before any game logic or
rendering happens.

Secondly, we apply our new inputs to update the game state. This may be moving the player character, showing some text
on screen, and any game scripts. The bulk of the game engine happens in this phase.

Thirdly, we update our game physics. We may have moved objects, but we need to ensure that they interact correctly, such
as applying gravity to our character, or handling a bullet moving through the air.

Finally, we render out our game to the screen, by taking all the objects on screen and sending them to the GPU to turn
into the final pixels of the game.

Roblox takes most of this away from developers, and instead chooses to rely on an event-driven loop, where we hook onto
a part of the engine. This makes it more difficult to use Iris, since not every place we want it will run every frame.
However, Roblox provides access to RunService events, allowing us to execute code every frame, which is seen below:

```lua
while not_closed do
    update(UserInputService)
    update(ContextActionService)

    event(RunService.BindToRenderStepped)
    event(RunService.RenderStepped)

    render()

    event(wait)
    event(RunService.Stepped)
    update(PhysicsService)

    event(RunService.Heartbeat)
    update(ReplicationService)

    delay() -- for a 60 fps limit
end
```

Adapted from the [Task Scheduler Documentation](https://create.roblox.com/docs/studio/microprofiler/task-scheduler)

## Iris Lifecycle

For Iris to render properly, all UI code must execute every frame, or cycle. As such, each cycle, Iris must do three
things:
1. prepare our next frame (resetting the widget tree and removing unused widgets)
2. call our widget APIs
3. end frane (check for yeilding)

Iris needs to run every frame, called the cycle, in order to update global variables and to clean any unused widgets.
This is equivalent to calling `ImGui::EndFrame()` for Dear ImGui, which would then process the frame buffers ready for
use. This order is important for Iris, which by default uses the `RunService.Heartbeat` event to process this all on.
Therefore, for each frame, any Iris code must run before this event. It is possible to change the event Iris runs on
when initialising, but for most cases, `RunService.Heartbeat` is ideal. Understanding this is the key to most
effectively using Iris. The library provides a handy `Iris:Connect()` function which will run any code in the function
every frame before the cycle. This makes it the most convenient. However, any functions provided here will also run on
the initialised event, `RunService.Heartbeat` here, so will run after physics and animations are calculated. Thankfully,
Iris does not constrain you to use only `Iris:Connect()`. You are able to run Iris code anywhere, in any event, at any
time. As long as it is consistent on every frame, and before the cycle event, it will work properly. Therefore, it is
very possible to put Iris directly into your core game loops.

## Demonstration

Say you have a weapon class which is used by every weapon and then also a weapon handler/serivce/system/controller for
handling all weapons on the client. Integrating Iris may look something similar to this:
```lua
------------------------------------------------------------------------
--- game.ReplicatedStorage.Modules.Client.Weaopns.WeaponsService.lua
------------------------------------------------------------------------
local WeaponsService = {
    maxWeapons = 10,
    activeWeapon = nil,
    weapons = {}
}

function WeaponsService.init()
end

-- called every frame to update all weapons
function WeaponsService.update(deltaTime: number)
    Iris.Window("Weapons Service")

    WeaponsService.doSomething()
    Iris.CollapsingHeader("Global Variables")
        Iris.DragNum("Max Weapons", 1, 0, nil, nil, Iris.TableState(WeaponsService.maxWeapons))
    Iris.End()

    Iris.CollapsingHeader("Weapons")
        Iris.Tree(`Active Weapon: {WeaponsService.activeWeapon.name}`)
            WeaponsService.activeWeapon:update()
        Iris.End()

        Iris.SeparatorText("All Weapons")
        for _, weapon in WeaponsService.weapons do
            Iris.Tree(weapon.name)
                weapon:update()
            Iris.End()
        end
    Iris.End()
    
    WeaponsService.doSomethingElse()
    Iris.End()
end

function WeaponsService.terminate()
end

return WeaponsService

------------------------------------------------------------------------
--- game.ReplicatedStorage.Modules.Client.Weaopns.Weapon.lua
------------------------------------------------------------------------
local Weapon = {}
Weapon.__index = Weapon

function Weapon.new(...)
end

function Weapon.update(self, deltaTime: number)
    Iris.Text(`ID: {self.id}`)
    Iris.Text(`Bullets: {self.bullets}/{self.capacity}")
    Iris.Checkbox("No reload", Iris.TableState(self.noreload))
    ...
    self:updateInputs()
    self:updateTransforms()
    ...
end

function Weapon.destroy(self)
end

```

Although this is very bare bones code, we are not using any `Iris:Connect()` methods and instead place our Iris code
directly in our update events which we know will run every frame. Another practice this shows is starting a window
somewhere and keeping it open through all weapons before closing it and the end of the update. Therefore, we can place
lots of different widgets in one window and keep everything organised.

The showcase by [@Boogle](https://x.com/LeBoogle/status/1772384187426709879) shows off Iris used exactly like this, but
with an actual working system.
