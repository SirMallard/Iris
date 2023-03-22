# Iris
## Widgets needed for release (*unchecked = incomplete*):

- [X]	Iris.Text
- - [X]	Iris.Args.Text.Text

- [X]	Iris.TextWrapped
- - [X]	Iris.Args.Text.TextWrapped
	
- [X]	Iris.Button
- - [X]	Iris.Args.Button.Text
	
- [X]	Iris.SmallButton
- - [X]	Iris.Args.SmallButton.Text
	
- [X]	Iris.Tree
- - [X]	Iris.Args.Tree.SpanAvailWidth
- - [X] Iris.Args.Tree.NoIndent
	
- [ ]	Iris.Window
- - [X] Iris.Args.Window.Title
- - [X]	Iris.Args.Window.NoTitlebar
- - [X]	Iris.Args.Window.NoScrollbar
- - [X]	Iris.Args.Window.NoMove
- - [X] Iris.Args.Window.NoResize
- - [X] Iris.Args.Window.NoCollapse
- - [X] Iris.Args.Window.NoClose
- - [X] Iris.Args.Window.NoBackground
- - [X] Iris.Args.Window.NoNav

- [X]	Iris.Separator
	
- [X]	Iris.Indent
- - [X]	Iris.Args.Indent.Width
	
- [X]	Iris.Checkbox
- - [X]	Iris.Args.Checkbox.Text

- [X]	Iris.SameLine
- - [X]	Iris.Args.SameLine.Width

- [X]	Iris.Group
	
- [X]	Iris.InputNum
- - [X]	Iris.Args.InputNum.Text
- - [X]	Iris.Args.InputNum.Increment
- - [X]	Iris.Args.InputNum.Min
- - [X]	Iris.Args.InputNum.Max
- - [X]	Iris.Args.InputNum.Format
- - [X] Iris.Args.InputNum.NoButtons
- - [X] Iris.Args.InputNum.NoField

- [X]	Iris.InputText
- - [X]	Iris.Args.InputText.Text
- - [X]	Iris.Args.InputText.TextHint

- [X]	Iris.Table
- - [X] Iris.Args.Table.NumColumns
- - [X]	Iris.Args.Table.RowBg
- - [X] Iris.Args.Table.BordersOuter
- - [X] Iris.Args.Table.BordersInner

## Methods:
*May change prior to release*
- Iris.UpdateGlobalStyle
- Iris.PushStyle
- Iris.PopStyle
- Iris.End
- Iris.Connect
- Iris.ForceRefresh
- Iris.WidgetConstructor

- Iris.NextRow
- Iris.NextColumn
- Iris.SetColumnIndex


Thing to complete for release:
- [X] Iris.Window cant resize from its edges
- [*] Iris.Table Rows dont align vertically 
- [ ] PushStyle changes wont be propogated to widgets until they refresh, somehow
- [ ] there is no retained mode interoperability (GUI Instances in Iris, Iris in GUI Instances)
- [ ] Iris cant be used in unusual contexts, (like in CoreGui, BillboardGui, plugins)
- [ ] Gamepad and Touch behavior dont work
- [X] Window Scrollbar state resets, Window has no state of it
- [X] Window position and size dont reflect realtime coordinates when moving / resizing
- [ ] State syntax is unintuitive, could be simplified or possibly borrowed from another library?
- [X] Remove all local vars in Iris.lua, commit fully to Iris._variable
- [ ] add wally integration
- [ ] complete documentation (overview, explanation, advanced section, Library docs- section for runtime and widgets)
- [ ] documentation window for ShowDemoWindow
- [ ] runtime WYSIWYG editor window for ShowDemoWindow
- [ ] polish error handling, fix the visual glitch in tree when an expanded Iris.Tree increases in width while having no children
- [ ] comment out debug.profileBegin and debug.ProfileEnd
- [ ] remove Iris.Connect syntax for Iris.BeginFrame and Iris.EndFrame
\* = Cannot be fixed or would be problematic to fix