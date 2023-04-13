## Methods:
- Iris.Connect
- Iris.State
- Iris.End
- Iris.UpdateGlobalConfig
- Iris.PushConfig
- Iris.PopConfig
- Iris.ForceRefresh
- Iris.WidgetConstructor

- Iris.NextRow
- Iris.NextColumn
- Iris.SetColumnIndex

- Iris.SetFocusedWindow

- Iris.ShowDemoWindow


Things to complete for release:
- [X] Iris.Window cant resize from its edges
- [X] @ Iris.Table Rows dont align vertically 
- [X] PushConfig changes wont be propogated to widgets until they refresh, somehow
- [X] there is no retained mode interoperability (GUI Instances in Iris, Iris in GUI Instances)
- [X] Iris cant be used in unusual contexts, (like in CoreGui, BillboardGui, plugins)
- [X] Gamepad and Touch behavior dont work
- [X] Window Scrollbar state resets, Window has no state of it
- [X] Window position and size dont reflect realtime coordinates when moving / resizing
- [X] State syntax is unintuitive, could be simplified or possibly borrowed from another library?
- [X] Remove all local vars in Iris.lua, commit fully to Iris._variable
- [ ] add wally integration
- [ ] complete documentation (overview, explanation, advanced section, Library docs- section for runtime and widgets)
- [ ] documentation window for ShowDemoWindow
- [X] polish error handling
- [X] fix the visual glitch in tree when an expanded Iris.Tree increases in width while having no children
- [X] comment out debug.profileBegin and debug.ProfileEnd

@ = Cannot be fixed or would be problematic to fix