local Internal = require(script.Parent.Parent.Internal)
local Utility = require(script.Parent)

local Types = require(script.Parent.Parent.Types)

export type Image = Types.Widget & {
    arguments: {
        Image: string,
        Size: UDim2,
        Rect: Rect?,
        ScaleType: Enum.ScaleType?,
        TileSize: UDim2?,
        SliceCenter: Rect?,
        SliceScale: number?,
        ResampleMode: Enum.ResamplerMode?,
    },
} & Types.Hovered

-- ooops, may have overriden a Roblox type, and then got a weird type message
-- let's just hope I don't have to use a Roblox ImageButton type anywhere by name in this file
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

                Image.Image = thisWidget.arguments.Image or Utility.ICONS.UNKNOWN_TEXTURE
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

                Image.Image = thisWidget.arguments.Image or Utility.ICONS.UNKNOWN_TEXTURE
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

return {}
