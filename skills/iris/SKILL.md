---
name: iris
description: Guide for building debug, visualization, and content-creation UI in Roblox with the Iris immediate-mode GUI module. Use when writing Iris widget code, wiring widget state to game values, theming via config, choosing between state types, or fixing common Iris errors like End() mismatches, init-once failures, or yields inside the UI thread.
---

# Iris (Roblox Immediate-Mode GUI)

Iris is an immediate-mode GUI library for Roblox, based on Dear ImGui. You declare UI every frame instead of keeping references to instances. There are no click events and no stored handles to widgets: each frame you call the widget, check its return values, and let Iris create/destroy/parent all UI instances automatically.

This differs from Roblox's retained mode (instances + `MouseButton1Click` connections). With Iris, writing `Iris.Button({"Save"})` every frame makes a button exist for that frame; dropping the call removes it.

## Setup

- Install as a Wally package (`sirmallard/iris`), as an rbxm from the latest GitHub release, or build from source. No external dependencies.
- Place Iris somewhere on the client (`StarterPlayerScripts` or `ReplicatedStorage`) and require it from client scripts only. Works under PlayerGui, CoreGui, BillboardGui, SurfaceGui, and PluginGui.
- Types are available via `require(path.to.Iris.PubTypes)`, which exports typed `Widget`, `State<T>`, and per-widget types.

```lua
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local Iris = require(StarterPlayerScripts.Client.Iris).Init()
```

- **`Iris.Init(parentInstance?, eventConnection?, allowMultipleInits?)` may be called exactly once per client.** It starts the cycle and returns Iris. Options: `parentInstance` is a `BasePlayerGui | GuiBase2d` to place UI under (defaults to PlayerGui); `eventConnection` is the cycle signal, a `() -> number` function, or `false` to drive `Internal._cycle` yourself (defaults to `RunService.Heartbeat`); `allowMultipleInits = true` makes later `Init()` calls silently no-op instead of erroring. Initialise from a single early entry point (e.g. `ReplicatedFirst`) so other scripts can `require` Iris without calling `.Init()` again.
- `Iris:Connect(fn)` runs `fn` every cycle, before Iris' internal cycle. It returns a function you can call to disconnect. You are not limited to `Connect` — Iris code can live in any callback that runs consistently every frame before the cycle, e.g. a weapon system's own `update(dt)`.
- Lifecycle controls: `Iris.Shutdown()` stops Iris permanently (cannot be restarted); `Iris.Disabled = true` freezes rendering without destroying widgets; `Iris.ForceRefresh()` destroys and regenerates every instance (expensive — never per-frame).
- `Iris.Append(guiInstance)` inserts an arbitrary Roblox GuiObject into the current parent widget.
- Quick smoke test: `Iris.Init()` then `Iris:Connect(Iris.ShowDemoWindow)`. The demo window (`Iris.ShowDemoWindow`) shows every widget and is the best reference for the full API; the source is `lib/demoWindow.lua`.

## Core API Model

Every widget is a function taking two arguments: a **positional arguments array** (required, can be `{}`) and an **optional state dictionary** keyed by state name.

```lua
Iris.WidgetName({ arg1, arg2 }, { stateName = state })
```

- Arguments are passed by position: `Iris.Window({"Title", nil, nil, nil, true})`. Order matters; use `Iris.Args.Widget.Argument` as named indices for rarely used args, e.g. `Iris.Window({[Iris.Args.Window.Title] = "Title", [Iris.Args.Window.NoClose] = true})`.
- **String-keyed argument tables error** (`{Title = "x"}` is invalid). Only the states dictionary uses string keys.
- A widget with children (Window, Tree, CollapsingHeader, Table, Combo, SameLine, MenuBar, Indent, ...) must be closed with a matching `Iris.End()`. Use `do ... end` blocks to pair them visibly.
- Events are methods on the returned widget that return booleans. They fire on the frame after the action so any visual change propagates first.
- Widgets are identified per frame by the source line they were called from; calling the same widget on inconsistent lines across frames creates duplicates. To keep a widget persistent when its call site varies between frames (or across separate code paths), override the generated ID: `Iris.PushId(id)` / `Iris.PopId()` for all subsequent widgets, or `Iris.SetNextWidgetID(id)` for a single next widget (also the pattern for reusing a window with `Iris.Append`).

## Widget + Event Pattern

```lua
Iris.Window({"My Second Window"}, { size = Iris.State(Vector2.new(300, 400)) })
    Iris.Text({"The current time is: " .. time()})
    Iris.InputText({"Enter Text"})

    if Iris.Button({"Click me"}).clicked() then
        print("button was clicked")
    end

    Iris.InputColor4()

    Iris.Tree()
        for i = 1, 8 do
            Iris.Text({"Text in a loop: " .. i})
        end
    Iris.End()
Iris.End()
```

Common events: `clicked()`, `hovered()` (continuous), `checked()`, and window events `opened()`, `closed()`, `collapsed()`, `uncollapsed()`. Buttons also expose `rightClicked()`, `doubleClicked()`, and `ctrlClicked()`. Window also accepts `NoTitleBar`, `NoBackground`, `NoCollapse`, `NoClose`, `NoMove`, `NoScrollbar`, `NoResize`, `NoNav`, `NoMenu` booleans.

## Widgets

The full catalog — every widget with its exact Arguments / Events / States — is in `references/widgets.md`. Common widgets:

| Widget | Purpose | Key args | Key events / states |
|---|---|---|---|
| `Iris.Window` | Top-level container (every widget descends from one) | `Title`, `No*` flags | `opened()`, `closed()`; states `size`, `position`, `isOpened`, `isUncollapsed` |
| `Iris.Text` | Label | `Text`, `Wrapped?`, `Color?`, `RichText?` | `hovered()` |
| `Iris.Button` | Clickable | `Text`, `Size?` | `clicked()`, `rightClicked()`, `doubleClicked()` |
| `Iris.Checkbox` | Boolean toggle | `Text` | `checked()`, `unchecked()`; state `isChecked` |
| `Iris.InputText` | Free text entry | `Text`, `TextHint?`, `ReadOnly?`, `MultiLine?` | `textChanged()`; state `text` |
| `Iris.InputNum` | Typed number | `Text`, `Increment?`, `Min?`, `Max?`, `Format?`, `NoButtons?` | `numberChanged()`; state `number` |
| `Iris.DragNum` | Drag-to-edit number | `Text`, `Increment?`, `Min?`, `Max?` | `numberChanged()`; state `number` |
| `Iris.SliderNum` | Slider (defaults 0..100) | `Text`, `Increment? = 1`, `Min? = 0`, `Max? = 100` | `numberChanged()`; state `number` |
| `Iris.InputColor3` / `InputColor4` | Color input | `Text`, `UseFloats?`, `UseHSV?` | state `color` (+ `transparency` for Color4) |
| `Iris.Combo` / `Iris.Selectable` | Dropdown from selectables | `Text`, `NoButton?`, `NoPreview?` | `changed()`; shared state `index` |
| `Iris.ComboArray` / `Iris.ComboEnum` | Dropdown from array / enum | `(args, states?, array\|enum)` — 3rd param is the choices | state `index` |
| `Iris.Tree` / `Iris.CollapsingHeader` | Collapsible container | `Text`, `DefaultOpen?` | `collapsed()`, `uncollapsed()`; state `isUncollapsed` |
| `Iris.SameLine` / `Iris.Indent` | Layout | `Width?` | — |
| `Iris.Tooltip` | Hover help | `Text` | gate on another widget's `hovered()` |
| `Iris.Separator` / `Iris.SeparatorText` | Dividers | `Text` (SeparatorText) | — |
| `Iris.MenuBar` + `Iris.Menu` + `Iris.MenuItem`/`MenuToggle` | Menu system | `Text`, `KeyCode?`, `ModifierKey?` (display-only) | `clicked()`, `checked()` |
| `Iris.ProgressBar` | Progress | `Text`, `Format?` | state `progress` |
| `Iris.PlotLines` / `Iris.PlotHistogram` | Graphs | `Text`, `Height?`, `Min?`, `Max?`, `TextOverlay?` | state `values` |
| `Iris.Table` | Grid layout | `NumColumns`, `Header?`, `RowBackground?`, ... | column helpers `NextColumn()` etc. |
| `Iris.TabBar` + `Iris.Tab` | Tabs | `Text`, `Hideable?` | shared state `index` |
| `Iris.Image` / `Iris.ImageButton` | Image display / button | `Image`, `Size`, `ScaleType?` | button click events |

Special call forms to remember:
- `Iris.ComboArray(arguments, states?, array)` and `Iris.ComboEnum(arguments, states?, enumType)` generate their own Selectable children — do **not** call `Iris.End()` after them.
- `Iris.Table` uses helper calls, not children ordering: `Iris.NextColumn()`, `Iris.NextRow()`, `Iris.SetColumnIndex(i)`, `Iris.SetRowIndex(i)`, `Iris.NextHeaderColumn()`, `Iris.SetHeaderColumnIndex(i)`, `Iris.SetColumnWidth(i, width)`.

## State

A State is a table holding a value plus connected widgets/callbacks; setting it updates dependent widget UI. States replace C++-style pointers in Luau (tables pass by reference).

- `Iris.State(initial)` — base state.
- `Iris.VariableState(value, setter)` — links a state to a local variable; the setter writes the widget's value back to your variable.
  ```lua
  local myNumber = 5
  local state = Iris.VariableState(myNumber, function(value) myNumber = value end)
  Iris.DragNum({"My number"}, { number = state })
  ```
- `Iris.TableState(table, key[, callback])` — links to a table field; syncs both ways without a setter. The optional third arg is an interception callback run on state change that gates the table write: `tab[key]` is updated only when it returns truthy (return `false` to handle the write yourself, e.g. to run side effects).
  ```lua
  local data = { myNumber = 5 }
  Iris.DragNum({"My number"}, { number = Iris.TableState(data, "myNumber") })
  ```
- `Iris.WeakState(value)` — like State, but calling it by ID clears all connected widgets/callbacks while keeping the value (useful for disconnecting widgets).
- `Iris.ComputedState(state, fn)` — derives a state that stays in sync with another state.

Pass states to widgets as `{ name = state }` or read them back from a created widget: `local win = Iris.Window({"W"}); win.state.position`. Use states when a widget value is needed outside the widget call or to give widgets an initial value.

### State methods

A state object has `:get()`, `:set(value, force?)`, `:onChange(callback)`, and `:changed()`. `:get()` is preferred over reading `.value`.

- **Use `:set()` to mutate a state, not `.value = x`.** Assigning `.value` directly does not propagate to connected widgets or fire `onChange` callbacks; `:set()` does.
- Register `:onChange()` callbacks **once per state's lifetime**, never inside the per-frame widget block — calling it every frame leaks one callback per frame.
- **Never call `:set()` on a state from inside that same state's `:onChange()` callback** — it causes an infinite callback loop.
- `:changed()` returns whether the state changed this cycle (like an event).

## Config / Theming

- `Iris.UpdateGlobalConfig({...})` changes the global style (colors, text, sizing). Call sparingly, typically once before `Iris.Init()` — it redraws every widget (destroy + recreate).
- Preset themes: `Iris.TemplateConfig.colorLight` / `colorDark` and `sizeClear` / `sizeDefault`, applied via `Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)`.
- `Iris.PushConfig({...})` / `Iris.PopConfig()` scope config to a block and stack, so child widgets can differ from parents.
- Every color option has a `Color` and a `Transparency` key (0 = opaque, 1 = transparent). Interaction variants are suffixed `Hovered` / `Active` (e.g. `ButtonColor`, `ButtonHoveredColor`, `ButtonActiveColor`). The exact key names (including `TableHeaderColor`, which is easy to miss) live in the upstream `config.lua`.
- Sizing uses numbers/Vector2/UDim: `ItemWidth`, `ContentWidth` (proportion of a widget taken by its value box vs. label), `FramePadding`, `ItemSpacing`, `ItemInnerSpacing`, `WindowPadding`, etc.
- Other global options: `UseScreenGUIs` (ScreenGUIs vs Frames), `ScreenInsets` / `IgnoreGuiInset` (should agree), `RichText`, `TextWrapped`, `DisplayOrderOffset`. Changing a widget's config between frames forces a redraw of that widget.

## Constraints

- **Never yield inside Iris code.** Iris must finish every frame or you get `Iris cycleCoroutine took too long to yield. Connected functions should not yield.` Use `task.spawn(...)` for async work and show the result once available.
- Iris code must run every frame before the cycle for widgets to persist; a widget not called in a frame is discarded.
- Use `Iris.TableState` / `VariableState` to bridge widget values into your game's data without breaking the no-yield rule.

## Common Pitfalls

- **`Iris.Init() can only be called once.`** — one `Init()` per client; require without `.Init()` everywhere else.
- **`Iris:Connect() was called before calling Iris.Init(); always initialise Iris first.`** — just a warning; init first for deterministic ordering.
- **`Too few calls to Iris.End().` / `Too many calls to Iris.End().`** — every parent widget needs one matching `End()`. Errors or yields inside a widget block also cause this because the `End()` never runs.
- **`Iris.Window({ Title = "x" })` errors** — arguments are positional; only states use string keys.
- **Wrong `End()` count from conditional layouts** — keep `End()` calls unconditional and inside the same frame path as the parent widget.

## Source Files

This skill is derived from the upstream Iris documentation: the `docs/` folder of https://github.com/SirMallard/Iris (getting started, widgets, states, events, config, lifecycle, common issues), the repository README, and the Iris source snapshot (`lib/API.lua` for the widget catalog, `lib/init.lua` for the Iris API surface, `lib/config.lua` for config keys, `lib/Internal.lua` for the State class).
