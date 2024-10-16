---
sidebar_position: 9
---

# Common Issues

When using Iris you may run into different issues. The most common ones are explained
below and explain why the issue arises and how to fix it.

## Iris.Init can only be called once.
:::danger[Error]
`Iris.Init can only be called once.`
:::

Iris can only be initialised once per client. The best way to initialise Iris then is
to place it at the start of one of your first running script. For example you may have:
```lua
----------------------------------
--- ReplicatedFirst/client.lua or StarterPlayer/StarterPlayerScripts/client.lua
----------------------------------
1| -- code in ReplicatedFirst will execute before other code, so it is best practice 
2| -- to initialise Iris here even if you are not going to use it.
3| reqire(game.ReplicatedStorage.Iris).Init()
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

## Iris:Connect() was called before calling Iris.Init(), the connected function will never run.
:::caution[Warn]
`Iris:Connect() was called before calling Iris.Init(), the connected function will never run.`
:::


## Iris cycleCoroutine took to long to yield. Connected functions should not yield.
:::danger[Error]
`Iris cycleCoroutine took to long to yield. Connected functions should not yield.`
:::

## Callback has too few calls to Iris.End().
:::danger[Error]
`Callback has too few calls to Iris.End()`
:::
