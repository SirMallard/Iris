local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

--[=[
    @class Image

    Provides two widgets for Images and ImageButtons, with the same controls as an ImageLabel instance.
]=]

--[=[
    @within Image
    @interface Image
    .& Widget
    .hovered () -> boolean -- fires when the mouse hovers over any of the image
    
    .arguments { Content: Content, Size: UDim2, Rect: Rect?, ScaleType: Enum.ScaleType?, TileSize: UDim2?, SliceCenter: Rect?, SliceScale: number?, ResampleMode: Enum.ResamplerMode? }
]=]

export type Image = Types.Widget & {
    arguments: {
        Content: Content,
        Size: UDim2,
        Rect: Rect?,
        ScaleType: Enum.ScaleType?,
        TileSize: UDim2?,
        SliceCenter: Rect?,
        SliceScale: number?,
        ResampleMode: Enum.ResamplerMode?,
    },
} & Types.Hovered

--[=[
    @within Image
    @interface ImageButton_
    .& Image
    .clicked () -> boolean -- fires when a button is clicked
    .rightClicked () -> boolean -- fires when a button is right clicked
    .doubleClicked () -> boolean -- fires when a button is double clicked
    .ctrlClicked () -> boolean -- fires when a button is ctrl clicked
]=]
export type ImageButton_ = Image & Types.Clicked & Types.RightClicked & Types.DoubleClicked & Types.CtrlClicked

local abstractImage = {
    hasState = false,
    hasChildren = false,
    numArguments = 8,
    Arguments = { "Image", "Size", "Rect", "ScaleType", "ResampleMode", "TileSize", "SliceCenter", "SliceScale" },
    Discard = function(thisWidget: Image)
        thisWidget.instance:Destroy()
    end,
} :: Types.WidgetClass

-----------
-- Image
-----------

Internal._widgetConstructor(
    "Image",
    Utility.extend(
        abstractImage,
        {
            Events = {
                ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                    return thisWidget.instance
                end),
            },
            Generate = function(_thisWidget: Image)
                local Image = Instance.new("ImageLabel")
                Image.Name = "Iris_Image"
                Image.BackgroundTransparency = 1
                Image.BorderSizePixel = 0
                Image.ImageColor3 = Internal._config.ImageColor
                Image.ImageTransparency = Internal._config.ImageTransparency

                Utility.applyFrameStyle(Image, true)

                return Image
            end,
            Update = function(thisWidget: Image)
                local Image = thisWidget.instance :: ImageLabel

                Image.ImageContent = thisWidget.arguments.Content or Utility.ICONS.UNKNOWN_TEXTURE
                Image.Size = thisWidget.arguments.Size
                if thisWidget.arguments.ScaleType then
                    Image.ScaleType = thisWidget.arguments.ScaleType
                    if thisWidget.arguments.ScaleType == Enum.ScaleType.Tile and thisWidget.arguments.TileSize then
                        Image.TileSize = thisWidget.arguments.TileSize
                    elseif thisWidget.arguments.ScaleType == Enum.ScaleType.Slice then
                        if thisWidget.arguments.SliceCenter then
                            Image.SliceCenter = thisWidget.arguments.SliceCenter
                        end
                        if thisWidget.arguments.SliceScale then
                            Image.SliceScale = thisWidget.arguments.SliceScale
                        end
                    end
                end

                if thisWidget.arguments.Rect then
                    Image.ImageRectOffset = thisWidget.arguments.Rect.Min
                    Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
                end

                if thisWidget.arguments.ResampleMode then
                    Image.ResampleMode = thisWidget.arguments.ResampleMode
                end
            end,
        } :: Types.WidgetClass
    )
)

-----------------
-- ImageButton
-----------------

Internal._widgetConstructor(
    "ImageButton",
    Utility.extend(
        abstractImage,
        {
            Events = {
                ["clicked"] = Utility.EVENTS.click(function(thisWidget: Types.Widget)
                    return thisWidget.instance
                end),
                ["rightClicked"] = Utility.EVENTS.rightClick(function(thisWidget: Types.Widget)
                    return thisWidget.instance
                end),
                ["doubleClicked"] = Utility.EVENTS.doubleClick(function(thisWidget: Types.Widget)
                    return thisWidget.instance
                end),
                ["ctrlClicked"] = Utility.EVENTS.ctrlClick(function(thisWidget: Types.Widget)
                    return thisWidget.instance
                end),
                ["hovered"] = Utility.EVENTS.hover(function(thisWidget: Types.Widget)
                    return thisWidget.instance
                end),
            },
            Generate = function(_thisWidget: ImageButton_)
                local Button = Instance.new("ImageButton")
                Button.Name = "Iris_ImageButton"
                Button.AutomaticSize = Enum.AutomaticSize.XY
                Button.BackgroundColor3 = Internal._config.FrameBgColor
                Button.BackgroundTransparency = Internal._config.FrameBgTransparency
                Button.BorderSizePixel = 0
                Button.Image = ""
                Button.ImageTransparency = 1
                Button.AutoButtonColor = false

                Utility.applyFrameStyle(Button, true)
                Utility.UIPadding(Button, Vector2.new(Internal._config.ImageBorderSize, Internal._config.ImageBorderSize))

                local Image = Instance.new("ImageLabel")
                Image.Name = "ImageLabel"
                Image.BackgroundTransparency = 1
                Image.BorderSizePixel = 0
                Image.ImageColor3 = Internal._config.ImageColor
                Image.ImageTransparency = Internal._config.ImageTransparency
                Image.Parent = Button

                Utility.applyInteractionHighlights("Background", Button, Button, {
                    Color = Internal._config.FrameBgColor,
                    Transparency = Internal._config.FrameBgTransparency,
                    HoveredColor = Internal._config.FrameBgHoveredColor,
                    HoveredTransparency = Internal._config.FrameBgHoveredTransparency,
                    ActiveColor = Internal._config.FrameBgActiveColor,
                    ActiveTransparency = Internal._config.FrameBgActiveTransparency,
                })

                return Button
            end,
            Update = function(thisWidget: ImageButton_)
                local Button = thisWidget.instance :: TextButton
                local Image: ImageLabel = Button.ImageLabel

                Image.ImageContent = thisWidget.arguments.Content or Utility.ICONS.UNKNOWN_TEXTURE
                Image.Size = thisWidget.arguments.Size
                if thisWidget.arguments.ScaleType then
                    Image.ScaleType = thisWidget.arguments.ScaleType
                    if thisWidget.arguments.ScaleType == Enum.ScaleType.Tile and thisWidget.arguments.TileSize then
                        Image.TileSize = thisWidget.arguments.TileSize
                    elseif thisWidget.arguments.ScaleType == Enum.ScaleType.Slice then
                        if thisWidget.arguments.SliceCenter then
                            Image.SliceCenter = thisWidget.arguments.SliceCenter
                        end
                        if thisWidget.arguments.SliceScale then
                            Image.SliceScale = thisWidget.arguments.SliceScale
                        end
                    end
                end

                if thisWidget.arguments.Rect then
                    Image.ImageRectOffset = thisWidget.arguments.Rect.Min
                    Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
                end

                if thisWidget.arguments.ResampleMode then
                    Image.ResampleMode = thisWidget.arguments.ResampleMode
                end
            end,
        } :: Types.WidgetClass
    )
)

--[=[
    @within Image
    @tag Widget

    @function Image
    @param content Content -- texture content, allowing support for editable images
    @param size UDim2 -- required size in the window
    @param rect Rect? -- default to a zero rect, making no difference
    @param scaleType Enum.ScaleType? -- determines type of image scaling, default is Enum.ScaleType.Stretch
    @param resampleMode Enum.ResamplerMode? -- default is Enum.ResampleMode.Default
    @param tileSize UDim2? -- only used if ScaleType is Tile, default is UDim2.fromScale(1, 1)
    @param sliceCenter Rect? -- only used if ScaleType is Slice, default is empty Rect
    @param sliceScale number? -- only used if ScaleType is Slice, default is 1

    @return Image

    An image widget for displaying an image given its texture ID and a size. The widget also supports Rect Offset and Size allowing cropping of the image and the rest of the ScaleType functionerties
    Some of the arguments are only used depending on the ScaleType functionerty
]=]
local API_Image = function(content: Content, size: UDim2, rect: Rect?, scaleType: Enum.ScaleType?, resampleMode: Enum.ResamplerMode?, tileSize: UDim2?, sliceCenter: Rect?, sliceScale: number?)
    return Internal._insert("Image", content, size, rect, scaleType, resampleMode, tileSize, sliceCenter, sliceScale) :: Image
end

--[=[
    @within Image
    @tag Widget
    
    @function ImageButton
    @param content Content -- texture content, allowing support for editable images
    @param size UDim2 -- required size in the window
    @param rect Rect? -- default to a zero rect, making no difference
    @param scaleType Enum.ScaleType? -- determines type of image scaling, default is Enum.ScaleType.Stretch
    @param resampleMode Enum.ResamplerMode? -- default is Enum.ResampleMode.Default
    @param tileSize UDim2? -- only used if ScaleType is Tile, default is UDim2.fromScale(1, 1)
    @param sliceCenter Rect? -- only used if ScaleType is Slice, default is empty Rect
    @param sliceScale number? -- only used if ScaleType is Slice, default is 1
    
    @return ImageButton

    An image button widget for a button as an image given its texture ID and a size. The widget also supports Rect Offset and Size allowing cropping of the image, and the rest of the ScaleType functionerties
    Supports all of the events of a regular button.
]=]
local API_ImageButton = function(content: Content, size: UDim2, rect: Rect?, scaleType: Enum.ScaleType?, resampleMode: Enum.ResamplerMode?, tileSize: UDim2?, sliceCenter: Rect?, sliceScale: number?)
    return Internal._insert("ImageButton", content, size, rect, scaleType, resampleMode, tileSize, sliceCenter, sliceScale) :: ImageButton_
end

return {
    API_Image = API_Image,
    API_ImageButton = API_ImageButton,
}
