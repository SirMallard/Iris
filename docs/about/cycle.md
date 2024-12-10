---
sidebar_position: 1
---

# Understanding the Lifecycle

## General Game Lifecycle

Iris is designed for games with a core 'game loop' which is the structure that controls what
part of the game process happens when. A typical game loop make look very similar to this:

```cpp
while(not_closed) {
    poll_input();
    update_game_state();
    step_physics();
    render_content();
    wait(); // for a 60 fps limit
}
```
Here we start firstly with polling for any input changes, since these affect the game state
for that frame. We then update the game state which generally includes the majority of a
game engine, since it would control any user updates, world changes, UI updates and others.
We may also then choose to step our physics engine, assuming we are using a constant frame
rate. Finally we render out everything to our GPU and wait until the appropriate time to
start processing the next frame.

Roblox takes most of this away from developers, and instead chooses to rely on an event-driven
loop, where we hook onto a part of the engine allowing something else to happen. This makes it
more difficult to use Iris, since not every place we want it will run every frame. However,
Roblox provides access to RunService events, allowing us to execute code every frame, which is
seen below:

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

This is taken from the [Task Scheduler Documentation](https://create.roblox.com/docs/studio/microprofiler/task-scheduler)
which goes into more detail about this.

## Iris Lifecycle

Iris needs to run every frame, called the cycle, in order to update global variables and to
clean any unused widgets. This is equivalent to calling `ImGui::EndFrame()` for Dear ImGui,
which would then process the frame buffers ready for use. This order is important for Iris,
which by default uses the `RunService.Heartbeat` event to process this all on. Therefore, for
each frame, any Iris code must run before this event. It is possible to change the event Iris
runs on when initialising, but for most cases, `RunService.Heartbeat` is ideal.

Understanding this is the key to most effectively using Iris. The library provides a handy
`Iris:Connect()` function which will run any code in the function every frame before the
cycle. This makes it the most convenient. However, any functions provided here will also run
on the initialised event, `RunService.Heartbeat` here, so will run after physics and animations
are calculated. Thankfully, Iris does not constrain you to use only `Iris:Connect()`. You are
able to run Iris code anywhere, in any event, at any time. As long as it is consistent on
every frame, and before the cycle event, it will work properly. Therefore, it is very possible
to put Iris directly into your core game loops.

## Demonstration

Say you have a weapon class which is used by every weapon and then also a weapon handler/serivce/system/controller
for handling all weapons on the client. Integrating Iris may look something similar to this:
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
    Iris.Window({ "Weapons Service" })

    WeaponsService.doSomething()
    Iris.CollapsingHeader({ "Global Variables" })
        Iris.DragNum({ "Max Weapons", 1, 0 }, { number = Iris.TableState(WeaponsService.maxWeapons) })
    Iris.End()

    Iris.CollapsingHeader({ "Weapons" })
        Iris.Tree({ `Active Weapon: {WeaponsService.activeWeapon.name}` })
            WeaponsService.activeWeapon:update()
        Iris.End()

        Iris.SeparatorText({ "All Weapons" })
        for _, weapon: weapon in WeaponsService.weapons do
            Iris.Tree({ weapon.name })
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
    Iris.Text({ `ID: {self.id}` })
    Iris.Text({ `Bullets: {self.bullets}/{self.capacity}" })
    Iris.Checkbox({ "No reload" }, { isChecked = Iris.TableState(self.noreload) })
    ...
    self:updateInputs()
    self:updateTransforms()
    ...
end

function Weapon.destroy(self)
end

```

Although this is very bare bones code, we are not using any `Iris:Connect()` methods
and instead place our Iris code directly in our update events which we know will run
every frame. Another practice this shows is starting a window somewhere and keeping it
open through all weapons before closing it and the end of the update. Therefore, we
can place lots of different widgets in one window and keep everything organised.

The showcase by [@Boogle](https://x.com/LeBoogle/status/1772384187426709879) shows
off Iris used exactly like this, but with an actual working system.
