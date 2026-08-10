--[[
    unit types
]]
type Text = "Text"
type Wrapped = "Wrapped"
type Color = "Color"
type RichText = "RichText"
type TextHint = "TextHint"
type ReadOnly = "ReadOnly"
type MultiLine = "MultiLine"
type Title = "Title"
type NoTitleBar = "NoTitleBar"
type NoBackground = "NoBackground"
type NoCollapse = "NoCollapse"
type NoClose = "NoClose"
type NoMove = "NoMove"
type NoScrollbar = "NoScrollbar"
type NoResize = "NoResize"
type NoNav = "NoNav"
type NoMenu = "NoMenu"
type Width = "Width"
type VerticalAlignment = "VerticalAlignment"
type HorizontalAlignment = "HorizontalAlignment"
type Increment = "Increment"
type Min = "Min"
type Max = "Max"
type Format = "Format"
type UseFloats = "UseFloats"
type UseHSV = "UseHSV"
type Image = "Image"
type Size = "Size"
type Rect = "Rect"
type ScaleType = "ScaleType"
type ResampleMode = "ResampleMode"
type TileSize = "TileSize"
type SliceCenter = "SliceCenter"
type SliceScale = "SliceScale"
type Index = "Index"
type NoClick = "NoClick"
type Hideable = "Hideable"
type SpanAvailWidth = "SpanAvailWidth"
type NoIndent = "NoIndent"
type DefaultOpen = "DefaultOpen"
type NoButton = "NoButton"
type NoPreview = "NoPreview"
type KeyCode = "KeyCode"
type ModifierKey = "ModifierKey"
type Height = "Height"
type TextOverlay = "TextOverlay"
type BaseLine = "BaseLine"
type NumColumns = "NumColumns"
type Header = "Header"
type RowBackground = "RowBackground"
type OuterBorders = "OuterBorders"
type InnerBorders = "InnerBorders"
type Resizable = "Resizable"
type FixedWidth = "FixedWidth"
type ProportionalWidth = "ProportionalWidth"
type LimitTableWidth = "LimitTableWidth"

--[[
    arg types (used as indices/keys for Iris.Args[...])
]]
type TextArgs = Text | Wrapped | Color | RichText
type SeparatorTextArgs = Text
type TooltipArgs = Text
type WindowArgs = Title | NoTitleBar | NoBackground | NoCollapse | NoClose | NoMove | NoScrollbar | NoResize | NoNav | NoMenu
type MenuArgs = Text
type MenuItemArgs = Text | KeyCode | ModifierKey
type MenuToggleArgs = Text | KeyCode | ModifierKey -- seperated incase you'd want to change in the future
type IndentArgs = Width
type SameLineArgs = Width | VerticalAlignment | HorizontalAlignment
type ButtonArgs = Text | Size
type SelectableArgs = Text | Index | NoClick
type ComboArgs = Text | NoButton | NoPreview
type ImageArgs = Image | Size | Rect | ScaleType | ResampleMode | TileSize | SliceCenter | SliceScale
type CheckboxArgs = Text
type RadioButtonArgs = Text | Index
type TabArgs = Text | Hideable
type TreeArgs = Text | SpanAvailWidth | NoIndent | DefaultOpen
type CollapsingHeaderArgs = Text | DefaultOpen
type InputScaleArgs = Text | Increment | Min | Max | Format
type InputColorArgs = Text | UseFloats | UseHSV | Format
type InputTextArgs = Text | TextHint | ReadOnly | MultiLine
type ProgressBarArgs = Text | Format
type PlotLinesArgs = Text | Height | Min | Max | TextOverlay
type PlotHistogramArgs = Text | Height | Min | Max | TextOverlay | BaseLine
type TableArgs = NumColumns | Header | RowBackground | OuterBorders | InnerBorders | Resizable | FixedWidth | ProportionalWidth | LimitTableWidth

--[[
    exposed Args type
]]
export type Args = {
    -- have no args, so we'll just hide them lol
    -- MenuBar: {};
    -- Group: {};
    -- Separator: {};
    -- Root: {};
	-- TabBar: {};

	Text: {[TextArgs]: number};
	SeparatorText: {[SeparatorTextArgs]: number};
	Tooltip: {[TooltipArgs]: number};
	Window: {[WindowArgs]: number};
	Menu: {[MenuArgs]: number};
	MenuItem: {[MenuItemArgs]: number};
	MenuToggle: {[MenuToggleArgs]: number};
	Indent: {[IndentArgs]: number};
	SameLine: {[SameLineArgs]: number};
	Button: {[ButtonArgs]: number};
	SmallButton: {[ButtonArgs]: number};
	Selectable: {[SelectableArgs]: number};
	Combo: {[ComboArgs]: number};
	Image: {[ImageArgs]: number};
	ImageButton: {[ImageArgs]: number};
	Checkbox: {[CheckboxArgs]: number};
	RadioButton: {[RadioButtonArgs]: number};
	Tab: {[TabArgs]: number};
	Tree: {[TreeArgs]: number};
	CollapsingHeader: {[CollapsingHeaderArgs]: number};
	InputNum: {[InputScaleArgs]: number};
	InputVector2: {[InputScaleArgs]: number};
	InputVector3: {[InputScaleArgs]: number};
	InputUDim: {[InputScaleArgs]: number};
	InputUDim2: {[InputScaleArgs]: number};
	InputRect: {[InputScaleArgs]: number};
	DragNum: {[InputScaleArgs]: number};
	DragVector2: {[InputScaleArgs]: number};
	DragVector3: {[InputScaleArgs]: number};
	DragUDim: {[InputScaleArgs]: number};
	DragUDim2: {[InputScaleArgs]: number};
	DragRect: {[InputScaleArgs]: number};
	SliderNum: {[InputScaleArgs]: number};
	SliderVector2: {[InputScaleArgs]: number};
	SliderVector3: {[InputScaleArgs]: number};
	SliderUDim: {[InputScaleArgs]: number};
	SliderUDim2: {[InputScaleArgs]: number};
	SliderRect: {[InputScaleArgs]: number};
	SliderEnum: {[Text]: number};
	InputColor3: {[InputColorArgs]: number};
	InputColor4: {[InputColorArgs]: number};
	InputText: {[InputTextArgs]: number};
	ProgressBar: {[ProgressBarArgs]: number};
	PlotLines: {[PlotLinesArgs]: number};
	PlotHistogram: {[PlotHistogramArgs]: number};
	Table: {[TableArgs]: number};
}

return {}
