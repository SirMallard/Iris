# Widget Reference

Complete catalog of Iris widgets and their APIs, distilled from https://github.com/SirMallard/Iris/tree/main/lib/API.lua (Iris 2.5.1). Each entry lists the moonwave-documented arguments, events and states. `hasChildren` widgets must be paired with `Iris.End()`.

Notation: `Arg? = default` means optional argument. `[CONFIG]` means the value falls back to the global config.

## Window

- `hasChildren: true`, `hasState: true`
- Arguments: `Title: string`, `NoTitleBar? = false`, `NoBackground? = false`, `NoCollapse? = false`, `NoClose? = false`, `NoMove? = false`, `NoScrollbar? = false`, `NoResize? = false`, `NoNav? = false`, `NoMenu? = false`
- Events: `opened()`, `closed()`, `collapsed()`, `uncollapsed()`, `hovered()`
- States: `size: State<Vector2>? = Vector2.new(400, 300)`, `position: State<Vector2>?`, `isUncollapsed: State<boolean>? = true`, `isOpened: State<boolean>? = true`, `scrollDistance: State<number>?`

The top-level container; every other widget must be a descendant of a window. Cannot contain embedded windows. `Iris.SetFocusedWindow(window)` brings a window to front.

## Tooltip

- `hasChildren: false`, `hasState: false`
- Arguments: `Text: string`
- Events: `hovered()`

Displays a text label next to the cursor, typically gated on another widget's `hovered()`:
```lua
local text = Iris.Text({ "?" })
if text.hovered() then
    Iris.Tooltip({ "Helpful explanation" })
end
```

## Menus

### MenuBar
- `hasChildren: true`, `hasState: false`
- No arguments. Declares a menubar for the current window; must be called directly under a Window. Add `Iris.Menu(...)` children.

### Menu
- `hasChildren: true`, `hasState: true`
- Arguments: `Text: string`
- Events: `clicked()`, `opened()`, `closed()`, `hovered()`
- States: `isOpened: State<boolean>?`

A collapsible menu. Under a MenuBar it sits horizontally below the title; nested under another Menu it becomes a submenu with an arrow.

### MenuItem
- `hasChildren: false`, `hasState: false`
- Arguments: `Text: string`, `KeyCode: Enum.KeyCode? = nil`, `ModifierKey: Enum.ModifierKey? = nil`
- Events: `clicked()`, `hovered()`

A button inside a menu. **KeyCode/ModifierKey only display the key name; they do not bind a connection.**

### MenuToggle
- `hasChildren: false`, `hasState: true`
- Arguments: `Text: string`, `KeyCode? = nil`, `ModifierKey? = nil`
- Events: `checked()`, `unchecked()`, `hovered()`
- States: `isChecked: State<boolean>?`

A togglable menu item; functionally a checkbox.

## Format / Layout

### Separator
- `hasChildren: false`, `hasState: false`
- No arguments. A horizontal line between widgets.

### SeparatorText
- `hasChildren: false`, `hasState: false`
- Arguments: `Text: string`
- A separator with a text label; good section header when a Tree is too heavy.

### Indent
- `hasChildren: true`, `hasState: false`
- Arguments: `Width: number? = Iris._config.IndentSpacing`
- Indents its children.

### SameLine
- `hasChildren: true`, `hasState: false`
- Arguments: `Width: number? = Iris._config.ItemSpacing.X`, `VerticalAlignment? = Enum.VerticalAlignment.Center`, `HorizontalAlignment? = Enum.HorizontalAlignment.Center`
- Positions children in a horizontal row.

### Group
- `hasChildren: true`, `hasState: false`
- No arguments. Groups children into a single layout unit.

## Text

### Text
- `hasChildren: false`, `hasState: false`
- Arguments: `Text: string`, `Wrapped: boolean? = [CONFIG] false`, `Color: Color3? = Iris._config.TextColor`, `RichText: boolean? = [CONFIG] false`
- Events: `hovered()`

Deprecated aliases `Iris.TextWrapped` and `Iris.TextColored` exist; prefer `Text` with `Wrapped`/`Color` arguments.

### InputText
- `hasChildren: false`, `hasState: true`
- Arguments: `Text: string? = "InputText"`, `TextHint: string? = ""`, `ReadOnly: boolean? = false`, `MultiLine: boolean? = false`
- Events: `textChanged()` (fires when the box loses focus after a change), `hovered()`
- States: `text: State<string>?`

## Basic

### Button
- `hasChildren: false`, `hasState: false`
- Arguments: `Text: string`, `Size: UDim2? = UDim2.fromOffset(0, 0)`
- Events: `clicked()`, `rightClicked()`, `doubleClicked()`, `ctrlClicked()` (control key held), `hovered()`

### SmallButton
- Same as Button but no padding: Arguments `Text: string`, `Size: UDim2?`; same events.

### Checkbox
- `hasChildren: false`, `hasState: true`
- Arguments: `Text: string`
- Events: `checked()`, `unchecked()`, `hovered()`
- States: `isChecked: State<boolean>?`

### RadioButton
- `hasChildren: false`, `hasState: true`
- Arguments: `Text: string`, `Index: any` (the value the shared state is set to when clicked)
- Events: `selected()`, `unselected()`, `active()` (if its Index equals the state), `hovered()`
- States: `index: State<any>?`

Use multiple RadioButtons sharing the same `index` state to represent one-of-many values.

## Image

### Image
- `hasChildren: false`, `hasState: false`
- Arguments: `Image: string` (texture asset id), `Size: UDim2`, `Rect: Rect?`, `ScaleType? = Enum.ScaleType.Stretch`, `ResampleMode? = Enum.ResampleMode.Default`, `TileSize? = UDim2.fromScale(1, 1)`, `SliceCenter: Rect?`, `SliceScale: number? = 1`
- Events: `hovered()`
- `TileSize` only used when `ScaleType = Tile`; `SliceCenter`/`SliceScale` only when `Slice`.

### ImageButton
- Same as Image plus button events: `clicked()`, `rightClicked()`, `doubleClicked()`, `ctrlClicked()`, `hovered()`.

## Trees

### Tree
- `hasChildren: true`, `hasState: true`
- Arguments: `Text: string`, `SpanAvailWidth: boolean? = false`, `NoIndent: boolean? = false`, `DefaultOpen: boolean? = false`
- Events: `collapsed()`, `uncollapsed()`, `hovered()`
- States: `isUncollapsed: State<boolean>?`

### CollapsingHeader
- `hasChildren: true`, `hasState: true`
- Arguments: `Text: string`, `DefaultOpen: boolean? = false`
- Events: `collapsed()`, `uncollapsed()`, `hovered()`
- States: `isUncollapsed: State<boolean>?`

Same as Tree but a larger title; mainly for first-level organization in a window.

## Tabs

### TabBar
- `hasChildren: true`, `hasState: true`
- States: `index: State<number>?`
- Container for `Tab` children; the index (1-based) controls which tab is active.

### Tab
- `hasChildren: true`, `hasState: true`
- Arguments: `Text: string`, `Hideable: boolean? = nil`
- Events: `clicked()`, `hovered()`, `selected()`, `unselected()`, `active()`, `opened()`, `closed()`
- States: `isOpened: State<boolean>?`
- Must be directly under a TabBar (the TabBar owns the index; you cannot pass an index state to a Tab).

## Input

Shared argument pattern for all `Input*`/`Drag*`/`Slider*` numeric widgets:
1. `Text: string? = "Input{type}"`
2. `Increment: DataType? = nil`
3. `Min: DataType? = nil`
4. `Max: DataType? = nil`
5. `Format: string | { string }? = [DYNAMIC]`

Without an explicit `Format`, Iris infers a reasonable format from Increment/Min/Max (e.g. integers for 1/0/100) and prefixes boxes (`X:`, `Y:`, `Z:` for Vector3). Events: `numberChanged()`, `hovered()`. States: `number: State<DataType>?`, `editingText: State<boolean>?`.

- `InputNum` — number. Extra arg `NoButtons: boolean? = false` (hide +/- buttons).
- `InputVector2`, `InputVector3`, `InputUDim`, `InputUDim2`, `InputRect` — respective datatypes.
- `DragNum`, `DragVector2`, `DragVector3`, `DragUDim`, `DragUDim2`, `DragRect` — drag-to-edit fields. Ctrl+click types a value; hold Shift for faster, Alt for slower dragging.
- `SliderNum` (defaults `Increment=1, Min=0, Max=100`), `SliderVector2` (`{1,1}`, `{0,0}`, `{100,100}`), `SliderVector3`, `SliderUDim`, `SliderUDim2`, `SliderRect` — a grip constrained between Min and Max.
- `InputColor3` — args `Text`, `UseFloats? = false` (0..1 floats vs 0..255 ints), `UseHSV? = false`, `Format`. States: `color: State<Color3>?`, `editingText: State<boolean>?`.
- `InputColor4` — Color3 + alpha. States: `color: State<Color3>?`, `transparency: State<number>?`, `editingText: State<boolean>?`.
- `InputEnum` — alias for `ComboEnum` (see Combo).

## Combo

### Selectable
- `hasChildren: false`, `hasState: true`
- Arguments: `Text: string`, `Index: any` (value stored in the shared state), `NoClick: boolean? = false`
- Events: `selected()`, `unselected()`, `active()`, `clicked()`, `rightClicked()`, `doubleClicked()`, `ctrlClicked()`, `hovered()`
- States: `index: State<any>` — a state shared between all selectables in the group.

### Combo
- `hasChildren: true`, `hasState: true`
- Arguments: `Text: string`, `NoButton: boolean? = false` (hide dropdown button), `NoPreview: boolean? = false` (hide preview field)
- Events: `opened()`, `closed()`, `changed()`, `clicked()`, `hovered()`
- States: `index: State<any>`, `isOpened: State<boolean>?`
- Children are `Selectable` items sharing the combo's `index` state.

### ComboArray
- Function form: `Iris.ComboArray(arguments, states?, selectionArray: { any })` — third parameter is the array of choices. Generates the combo and its Selectable children internally (it inserts them itself; don't call `Iris.End()` after it).

### ComboEnum
- Function form: `Iris.ComboEnum(arguments, states?, enumType: Enum)` — third parameter is an Enum. Generates a combo of the enum's items, storing the selected `EnumItem`.

## Plots

### ProgressBar
- `hasChildren: false`, `hasState: true`
- Arguments: `Text: string? = "Progress Bar"`, `Format: string? = nil` (custom label like `"29/54"`)
- Events: `hovered()`, `changed()`
- States: `progress: State<number>?`

### PlotLines
- `hasChildren: false`, `hasState: true`
- Arguments: `Text? = "Plot Lines"`, `Height: number? = 0`, `Min: number? = min`, `Max: number? = max`, `TextOverlay: string? = ""`
- Events: `hovered()`
- States: `values: State<{number}>?`, `hovered: State<{number}>?` (read-only)

### PlotHistogram
- Same as PlotLines plus `BaseLine: number? = 0` argument (where bars start from). States: `values`, `hovered` (read-only).

## Table

- `hasChildren: true`, `hasState: false`
- Arguments: `NumColumns: number` (cannot be changed later), `Header: boolean? = false`, `RowBackground: boolean? = false`, `OuterBorders: boolean? = false`, `InnerBorders: boolean? = false`, `Resizable: boolean? = false`, `FixedWidth: boolean? = false`, `ProportionalWidth: boolean? = false`, `LimitTableWidth: boolean? = false`
- Events: `hovered()`
- States: `widths: State<{ number }>?` — column widths when `Resizable` (0..1 proportions, or pixels >2 when `FixedWidth`)

Column helpers (must be called directly within the table):
- `Iris.NextColumn()` — next cell, wrapping to the next row at the last column.
- `Iris.NextRow()` — first column of the next row.
- `Iris.SetColumnIndex(index)` — move to a column in the same row (1..NumColumns).
- `Iris.SetRowIndex(index)` — move to a row in the same column.
- `Iris.NextHeaderColumn()` / `Iris.SetHeaderColumnIndex(index)` — move within the header row (row 0).
- `Iris.SetColumnWidth(index, width)` — set a column's width via the `widths` state.

To change `NumColumns` later, wrap in `Iris.PushConfig({ columns = numColumns })` / `Iris.PopConfig()` so Iris redraws the table. When growing the column count, keep the `widths` state array at least as long as the new column count.
