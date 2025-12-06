---
sidebar_position: 5
---

# Understanding the Configuration

Each widget has a range of styling options to change its visual appearances, whether that be the
colours or sizing. These can either be configured for all widgets as a global style, or on a
per-widget basis. There are also some global properties which may need to be changed before Iris
is initialised, because they affect the entire UI.

The config is kept as a key-value pairs in a global table, viewable under `Iris.Internal._config`.
The file `Config.lua` contains a few different configurations (light, dark, big, small), of
which some are loaded by default when first requiring Iris. You can use this file to refer to the
default configuration, which are under 'colorDark', 'sizeDefault' and 'utilityDefault' (these
'categories' are purely to make the organisation clearer).

## Global

To change the global configuration, you can use `Iris.UpdateGlobalConfig()` with a key-value pair
table containing a set of configuration names and values which you would like to change. You do not
need to change all the values, since everything already has a default one.

If you would like to use an existing configuration (such as light mode), you can refer to
`Iris.TemplateConfig` which is the `Config.lua` file.

```lua
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight) -- change to the template light mode

Iris.UpdateGlobalConfig({
    RichText = true,
    IgnoreGuiInset = true,
    ScreenInsets = Enum.ScreenInsets.None,
    TextColor = Color3.fromRGB(85, 49, 218),
    TextSize = 16,
    FramePadding = Vector2.new(2, 1),
}) -- specify the specific properties to change

-- this can be specified before Iris is even initialised
Iris.Init()
```

:::caution Warn
`Iris.UpdateGlobalConfig()` should be called sparingly, normally when Iris is first initialised, or
when a specific configuration is manually made and never every frame, since it requires redrawing
every widget, which involves destroying and then creating every instance.
:::

## Per-Widget

To change the config for a specific widget, you can use `Iris.PushConfig()` and `Iris.PopConfig()`
around the widget. Internally, this updates the config with anything you pushed and then removes it
once you pop. This also stacks, so child widgets can be entirely different to their parent.

```lua
Iris.PushConfig({
    TextWrapped = true,
    ContentWidth = UDim.new(0.8, 0),
    FrameBgColor = Color3.fromRGB(41, 74, 122),
    FrameBgHoveredColor = Color3.fromRGB(66, 150, 250),
    FrameBgActiveColor = Color3.fromRGB(66, 150, 250),
})
do
    -- create any widgets with this config
end
Iris.PopConfig()
```

:::caution Warn
When a widget's config is changed between frames, Iris has to destroy and then create
the widget from scratch, so constantly changing the configuration on lots of widgets may decrease
performance significantly. However, if this the config stays the same, Iris does not require a
redraw.
:::


## Configuration

### Colours

Every config option has both a colour and a transparency. The colour will always end with `Color`
and the transparency will always end with `Transparency`, where `0` is fully opaque and `1` is
fully transparent. Many colours will be in pairs or trios, as the normal, the `Hovered` and the
`Active`.

Below the columns have been combined to put colour and transparency in the same row, and just the
suffix of the key. To change a value, append the key with either `Color` or `Transparency`, ie. the
colour of a hovering button would be `ButtonHovered` .. `Color` is `ButtonHoveredColor`.

| Key                        | Color                           | Transparency | Notes                                    |
| -------------------------- | ------------------------------- | ------------ | ---------------------------------------- |
| Text                       | `Color3.fromRGB(255, 255, 255)` | `0`          |                                          |
| TextDisabled               | `Color3.fromRGB(128, 128, 128)` | `0`          | InputText placeholder and Menu shortcuts |
| BorderColor                | `Color3.fromRGB(110, 110, 125)` | `0.5`        | Any Window or widget border              |
| BorderActive               | `Color3.fromRGB(160, 160, 175)` | `0.3`        | Active Window or Tooltip borders         |
| WindowBg                   | `Color3.fromRGB(15, 15, 15)`    | `0.06`       |                                          |
| PopupBg                    | `Color3.fromRGB(20, 20, 20)`    | `0.06`       |                                          |
| ScrollbarGrab              | `Color3.fromRGB(79, 79, 79)`    | `0`          |                                          |
| TitleBg                    | `Color3.fromRGB(10, 10, 10)`    | `0`          | Title bar of non-active Windows          |
| TitleBgActive              | `Color3.fromRGB(41, 74, 122)`   | `0`          | Title bar of active Window               |
| TitleBgCollapsed           | `Color3.fromRGB(0, 0, 0)`       | `0.5`        | Title bar of collapsed Window            |
| MenubarBg                  | `Color3.fromRGB(36, 36, 36)`    | `0`          |                                          |
| FrameBg                    | `Color3.fromRGB(41, 74, 122)`   | `0.46`       | Many widgets                             |
| FrameBgHovered             | `Color3.fromRGB(66, 150, 250)`  | `0.46`       |                                          |
| FrameBgActive              | `Color3.fromRGB(66, 150, 250)`  | `0.33`       |                                          |
| Button                     | `Color3.fromRGB(66, 150, 250)`  | `0.6`        | Any buttons                              |
| ButtonHovered              | `Color3.fromRGB(66, 150, 250)`  | `0`          |                                          |
| ButtonActive               | `Color3.fromRGB(15, 135, 250)`  | `0`          |                                          |
| Image                      | `Color3.fromRGB(255, 255, 255)` | `0`          | Image tint colour, white for normal      |
| SliderGrab                 | `Color3.fromRGB(66, 150, 250)`  | `0`          | Slider widgets                           |
| SliderGrabActive           | `Color3.fromRGB(117, 138, 204)` | `0`          |                                          |
| Header                     | `Color3.fromRGB(66, 150, 250)`  | `0.69`       | Selectable, Trees and Menus              |
| HeaderHovered              | `Color3.fromRGB(66, 150, 250)`  | `0.2`        |                                          |
| HeaderActive               | `Color3.fromRGB(66, 150, 250)`  | `0`          |                                          |
| Tab                        | `Color3.fromRGB(46, 89, 148)`   | `0.14`       | TabBar widget                            |
| TabHovered                 | `Color3.fromRGB(66, 150, 250)`  | `0.2`        |                                          |
| TabActive                  | `Color3.fromRGB(51, 105, 173)`  | `0`          |                                          |
| SelectionImageObject       | `Color3.fromRGB(255, 255, 255)` | `0.8`        | Internal                                 |
| SelectionImageObjectBorder | `Color3.fromRGB(255, 255, 255)` | `0`          |                                          |
| TableBorderStrong          | `Color3.fromRGB(79, 79, 89)`    | `0`          | Table outside border                     |
| TableBorderLight           | `Color3.fromRGB(59, 59, 64)`    | `0`          | Table insider border                     |
| TableRowBg                 | `Color3.fromRGB(0, 0, 0)`       | `1`          | Row background                           |
| TableRowBgAlt              | `Color3.fromRGB(255, 255, 255)` | `0.94`       | Alternating row background               |
| NavWindowingHighlight      | `Color3.fromRGB(255, 255, 255)` | `0.3`        | Unused                                   |
| NavWindowingDimBg          | `Color3.fromRGB(204, 204, 204)` | `0.65`       | Unused                                   |
| Separator                  | `Color3.fromRGB(110, 110, 128)` | `0.5`        |                                          |
| CheckMark                  | `Color3.fromRGB(66, 150, 250)`  | `0`          | Checkbox and RadioButton                 |
| PlotLines                  | `Color3.fromRGB(156, 156, 156)` | `0`          |                                          |
| PlotLinesHovered           | `Color3.fromRGB(255, 110, 89)`  | `0`          |                                          |
| PlotHistogram              | `Color3.fromRGB(230, 179, 0)`   | `0`          |                                          |
| PlotHistogramHovered       | `Color3.fromRGB(255, 153, 0)`   | `0`          |                                          |
| ResizeGrip                 | `Color3.fromRGB(66, 150, 250)`  | `0.8`        | Window resize grips                      |
| ResizeGripHovered          | `Color3.fromRGB(66, 150, 250)`  | `0.33`       |                                          |
| ResizeGripActive           | `Color3.fromRGB(66, 150, 250)`  | `0.05`       |                                          |
| Hover                      | `Color3.fromRGB(255, 255, 0)`   | `0.1`        | Unused                                   |

### Sizing

Sizing is either handled in pixel terms, as a number or Vector2, or as a UDim for both scale and
pixels.

ContentWidth is seen most notably on any widget which does not have a fixed widget, but instead
a scaling item on the left and then the text on the right, such as for Input widgets. By default,
the 'boxes' on the left will take up 65% of the total width, leaving 35% for the text. This can be
configured for the 'boxes' to take up the entire width.

| Key                     | Value                           | Notes                                                                                                       |
| ----------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| ItemWidth               | `UDim.new(1, 0)`                | Width of any widget which does not have a fixed size such as Plots, Table, Trees, Inputs                    |
| ContentWidth            | `UDim.new(0.65, 0)`             | Proportion of a full-width widget to be taken up by the content against text, such as Inputs, Plots, Combos |
| ContentHeight           | `UDim.new(0, 0)`                | Minimum height of widgets                                                                                   |
| WindowPadding           | `Vector2.new(8, 8)`             | Padding between Window border and content                                                                   |
| WindowResizePadding     | `Vector2.new(6, 6)`             | Sizes of window resize corners and edges                                                                    |
| FramePadding            | `Vector2.new(4, 3)`             | Padding between a frame edge and content                                                                    |
| ItemSpacing             | `Vector2.new(8, 4)`             | Spacing between sequential items, such as vertical space within a Window or Tree                            |
| ItemInnerSpacing        | `Vector2.new(4, 4)`             | Spacing between parts of the same widget, such as horizontal space between boxes in Input widgets           |
| CellPadding             | `Vector2.new(4, 2)`             | Table cell padding                                                                                          |
| DisplaySafeAreaPadding  | `Vector2.new(0, 0)`             | Padding around a window when moving                                                                         |
| SeparatorTextPadding    | `Vector2.new(20, 3)`            |                                                                                                             |
| IndentSpacing           | `21`                            |                                                                                                             |
| TextFont                | `Font.fromEnum(Enum.Font.Code)` |                                                                                                             |
| TextSize                | `13`                            |                                                                                                             |
| FrameBorderSize         | `0`                             |                                                                                                             |
| FrameRounding           | `0`                             |                                                                                                             |
| GrabRounding            | `0`                             |                                                                                                             |
| WindowRounding          | `0`                             | Not implemented                                                                                             |
| WindowBorderSize        | `1`                             |                                                                                                             |
| WindowTitleAlign        | `Enum.LeftRight.Left`           |                                                                                                             |
| PopupBorderSize         | `1`                             |                                                                                                             |
| PopupRounding           | `0`                             |                                                                                                             |
| ScrollbarSize           | `7`                             |                                                                                                             |
| GrabMinSize             | `10`                            | Min pixel width of a grab bar                                                                               |
| SeparatorTextBorderSize | `3`                             |                                                                                                             |
| ImageBorderSize         | `2`                             |                                                                                                             |

### Others

Other config options available, some of which should be defined before initialisation and then
left unchanged.

The RichText option will allow any text instance to support rich text. Equivalent with
TextWrapped and these both rely on Roblox to handle support for this.

UseScreenGUIs will determine whether the root UI instances are ScreenGUIs or Frames. This is useful
for when Iris is put inside existing UI, such as plugins or stories. ScreenInsets is applied first,
so make sure that IgnoreGuiInset agrees with the value (false when CoreUISafeInsets, true otherwise).

| Key                     | Value                                | Notes                                                                 |
| ----------------------- | ------------------------------------ | --------------------------------------------------------------------- |
| UseScreenGUIs           | `true`                               | Whether to use ScreenGUIs as the top level widget, or Frames instead. |
| ScreenInsets            | `Enum.ScreenInsets.CoreUISafeInsets` | Type of screenInset for ScreenGUIs, useful for mobile.                |
| IgnoreGuiInset          | `false`                              | If using ScreenGUIs                                                   |
| Parent                  | `nil`                                | Overrides the parent of the next widget, when creating                |
| RichText                | `false`                              | Text instances support RichText                                       |
| TextWrapped             | `false`                              | Text instances will wrap text                                         |
| DisplayOrderOffset      | `127`                                | Root widget offset, to draw over other UI                             |
| ZIndexOffset            | `0`                                  | Unused                                                                |
| MouseDoubleClickTime    | `0.30`                               | Time for a double-click, in seconds                                   |
| MouseDoubleClickMaxDist | `6.0`                                | Distance threshold to stay in to validate a double-click, in pixels   |
