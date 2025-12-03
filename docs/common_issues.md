---
sidebar_position: 9
---

# Common Issues

When using Iris you may run into different issues. The most common ones are explained
below and explain why the issue arises and how to fix it.

## Iris.Init() can only be called once.
:::danger Error
`Iris.Init() can only be called once.`
:::

Iris can only be initialised once per client. The best way to initialise Iris then is
to place it at the start of one of your first running script. For example you may have:
```lua
----------------------------------
--- ReplicatedFirst/client.lua or StarterPlayer/StarterPlayerScripts/client.lua
----------------------------------
 1| -- code in ReplicatedFirst will execute before other code, so it is best practice 
 2| -- to initialise Iris here even if you are not going to use it.
 3| require(game.ReplicatedStorage.Iris).Init()
 4| 
 5| ...

----------------------------------------
--- StarterPlayer/StarterPlayerScripts/raycast.lua
----------------------------------------
 1| -- therefore, when you require it any scripts elsewhere it is already initialised
 2| -- and ready to go and you do not need to worry about where to init
 3| local Iris = require(game.ReplicatedStorage.Iris)
 4| 
 5| -- wrong, you have initialised it twice here
 6| local Iris = require(game.ReplicatedStorage.Iris).Init()
 7|
 8| ...

```

This becomes more difficult if you have many local scripts which could all execute at
the same time. This is why most games will only use a few local scripts and rely on
modules for the rest, which ensures that code runs in an expected and deterministic
order and therefore any client-wide initialisation can happen before anything that
relies on it does.

## Iris:Connect() was called before calling Iris.Init(); always initialise Iris first.
:::caution Warn
`Iris:Connect() was called before calling Iris.Init(); always initialise Iris first.`
:::

Iris should always be initialised before attempting to use 'Connect()'. This is just a
warning to make sure that you are initialising Iris in the first place. If you connect
and then initialise, your code will still run normally and Iris functions fine. However,
as mentioned in the `Iris.Init() can only be called once.` issue, it is better practice to
initalise Iris before any other Iris code runs and therefore you can ensure consistent
ordering.

## Iris cycleCoroutine took to long to yield. Connected functions should not yield.
:::danger Error
`Iris cycleCoroutine took to long to yield. Connected functions should not yield.`
:::

Iris does not support yielding statements becaues it needs to run and finish every frame.
Therefore if you have code which needs to yield and wait, you should either handle it
outside of an Iris widget, or spawn a new thread. The example below demonstrates the issue:

```lua
-----------------------
--- bad_example.lua
-----------------------
 4| Iris.Window("Async Window")
 5|     -- this code yields which will prevent Iris from finishing before the next frame
 6|     local response = httpService:GetAsync(...)
 7|     Iris.Text(response)
 8| Iris.End()

------------------------
--- good_example.lua    
------------------------
 4| local response = "NONE"
 5| 
 6| Iris.Window("Async Window")
 7|     -- we use another thread to ensure the thread Iris is in will finish before the next frame
 8|     task.spawn(function()
 9|         response = httpService:GetAsync(...)
10|     end)
11|     Iris.Text(response)
12| Iris.End()
```

These examples are fairly simple, but when you are integrating Iris directly into your codebase
it should become much clearer.

## Too few calls to Iris.End()., Too many calls to Iris.End().
:::danger Error
`Too few calls to Iris.End().`, `Too many calls to Iris.End().`
:::

These issues are caused respectively by have too few or too many calls to `Iris.End()`. Every
widget that has children, from Windows and Trees to MenuBars and Combos to SameLine and Indent
must have an `Iris.End()` statement to say that you are done appending to that parent. To ensure
this does not happen, it is best to use do-end blocks to indent out parent widgets from their
children and make it clearer to see where an `Iris.End()` statement must go. For example:

```lua
 4| Iris.Window("Do-End Block")
 5| do
 6|     Iris.Text("Text goes here.")
 7| end
 8| Iris.End()
```
This makes it clear that an `Iris.End()` statement should always go after an `end` block.

This issue may also arise if some of your code either yields or errors and therefore not all the
`Iris.End()` calls happen. For example:

```lua
 4| Iris.Window("Valid Code with Error")
 5|     error("Something has gone wrong. :(") -- errors within Iris
 6| Iris.End()

 7| Iris.Window("Asynchronous Code")
 8|     task.wait(1) -- yields within Iris
 9| Iris.End()
```

Although all the `Iris.End()` statements are there and in the right space, the error has prevented
it from running and therefore we will get this error.
