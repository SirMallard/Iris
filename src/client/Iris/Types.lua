export type ID = string

export type State = {
	value: any,
	ConnectedWidgets: { [ID]:  Widget },
	ConnectedFunctions: { (any) -> () },

	get: (self: State) -> any,
	set: (self: State, newValue: any) -> (),
	onChange: (self: State, funcToConnect: (any) -> ()) -> (),
}
export type States = { [string]: State }

export type Event = {
	Init: (Widget) -> (),
	Get: (Widget) -> (boolean)
}
export type Events = { [string]: Event }

export type Widget = {
	ID: ID,
	type: string,
	state: State,

	parentWidget: Widget,
	Instance: GuiObject,
	arguments: Arguments,

	ZIndex: number,

	trackedEvents: {},
	lastCycleTick: number
}

export type Argument = any
export type Arguments = { [string]: Argument }
export type WidgetArguments = { [number]: Argument }

export type WidgetClass = {
	Generate: (thisWidget: Widget) -> (GuiObject),
	Discard: (thisWidget: Widget) -> (),
	Update: (thisWidget: Widget) -> (),

	Args: { [string]: number },
	Events: Events,
	hasChildren: boolean,
	hasState: boolean,
	ArgNames: { [number]: string },

	GenerateState: (thisWidget: Widget) -> (),
	UpdateState: (thisWidget: Widget) -> (),

	ChildAdded: (thisWidget: Widget) -> (GuiObject),
	ChildDiscarded: (thisWidget: Widget, thisChild: Widget) -> (),
}

export type Iris = {
	_started: boolean,
	_globalRefreshRequested: boolean,
	_localRefreshActive: boolean,
	_widgets: { [string]: WidgetClass },
	_rootConfig: {},
	_config: {},
	_rootInstance: GuiObject,
	_rootWidget: Widget,
	_states: { [ID]: State },
	_postCycleCallbacks: {},
	_connectedFunctions: {},
	_IDStack: { State },
	_usedIDs: { [ID]: number },
	_stackIndex: number,
	_cycleTick: number,
	_widgetCount: number,
	_lastWidget: Widget,
	_nextWidgetId: ID,
	SelectionImageObject: Frame,
	parentInstance: BasePlayerGui,

	_lastVDOM: { [ID]: Widget },
	_VDOM: { [ID]: Widget },

	Args: {},

	_generateSelectionImageObject: () -> (),
	_generateRootInstance: () -> (),
	_deepCompare: ( t1: {}, t2: {} ) -> boolean,
	_getID: (levelsToIgnore: number) -> ID,
	SetNextWidgetID: (ID: ID) -> (),
	_generateEmptyVDOM: () -> { [ID]: Widget },
	_cycle: () -> (),
	_GetParentWidget: () -> Widget,
	_EventCall: (thisWidget: Widget, eventName: string) -> boolean,
	ForceRefresh: () -> (),
	_NoOp: () -> (),
	WidgetConstructor: (type: string, widgetClass: WidgetClass) -> (),

	UpdateGlobalConfig: (deltaStyle: { [any]: any }) -> (),
	PushConfig: (deltaStyle: { [any]: any }) -> (),
	PopConfig: () -> (),

	State: (initialValue: any) -> (),
	ComputatedState: (firstState: State, onChangeCallback: (firstState: any) -> (any)) -> State,
	_widgetState: (thisWidget: Widget, stateName: string, initialValue: any) -> State,

	Init: (parentInstance: BasePlayerGui?, eventConnection: (RBXScriptConnection | () -> {})?) -> (),
	Connect: (callback: () -> ()) -> (),

	_DiscardWidget: (widgetToDiscard: Widget) -> (),
	_GenNewWidget: (widgetType: string, arguments: Arguments, widgetState: States?, ID: ID) -> Widget,
	_Inset: (widgetType: string, args: { [number]: any }, widgetState: States?) -> Widget,
	_ContinueWidget: (ID: ID, widgetType: string) -> Widget,
	Append: (userInstance: GuiObject) -> (),

	End: () -> (),
	Text: (args: WidgetArguments) -> Widget,
	TextColored: (args: WidgetArguments) -> Widget,
	TextWrapped: (args: WidgetArguments) -> Widget,

	Button: (args: WidgetArguments) -> Widget,
	SmallButton: (args: WidgetArguments) -> Widget,
	Checkbox: (args: WidgetArguments, state: States?) -> Widget,
	RadioButton: (args: WidgetArguments, state: States?) -> Widget,

	Separator: (args: WidgetArguments) -> Widget,
	Indent: (args: WidgetArguments) -> Widget,
	SameLine: (args: WidgetArguments) -> Widget,
	Group: (args: WidgetArguments) -> Widget,
	Selectable: (args: WidgetArguments, state: States?) -> Widget,

	Tree: (args: WidgetArguments, state: States?) -> Widget,
	CollapsingHeader: (args: WidgetArguments, state: States?) -> Widget,
	
	DragNum: (args: WidgetArguments, state: States?) -> Widget,
	SliderNum: (args: WidgetArguments, state: States?) -> Widget,
	InputNum: (args: WidgetArguments, state: States?) -> Widget,
	InputText: (args: WidgetArguments, state: States?) -> Widget,
	InputEnum: (args: WidgetArguments, state: States?, enumType: Enum) -> Widget,
	Combo: (args: WidgetArguments, state: States?) -> Widget,
	ComboArray: (args: WidgetArguments, state: States?, selectionArray: {any} ) -> Widget,
	
	Table: (args: WidgetArguments, state: States?) -> Widget,
	NextColumn: () -> (),
	SetColumnIndex: (columnIndex: number) -> (),
	NextRow: () -> (),
	
	Window: (args: WidgetArguments, state: States?) -> Widget,
	Tooltip: (args: WidgetArguments) -> Widget,
	SetFocusedWindow: (thisWidget: Widget?) -> ()
}

return {}