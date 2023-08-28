local TemplateConfig = {
    colorDark = { -- Dear, ImGui default dark
        TextColor = Color3.fromRGB(255, 255, 255),
        TextTransparency = 0,
        TextDisabledColor = Color3.fromRGB(128, 128, 128),
        TextDisabledTransparency = 0,

        BorderColor = Color3.fromRGB(110, 110, 125),
        -- Dear ImGui uses 110, 110, 125
        -- The Roblox window selection highlight is 67, 191, 254
        BorderActiveColor = Color3.fromRGB(160, 160, 175), -- does not exist in Dear ImGui

        BorderTransparency = 0,
        BorderActiveTransparency = 0,
        -- BorderTransparency will be problematic for non UIStroke border implimentations
        -- is not implimented because of this

        WindowBgColor = Color3.fromRGB(15, 15, 15),
        WindowBgTransparency = 0.072,

        ScrollbarGrabColor = Color3.fromRGB(128, 128, 128),
        ScrollbarGrabTransparency = 0,

        TitleBgColor = Color3.fromRGB(10, 10, 10),
        TitleBgTransparency = 0,
        TitleBgActiveColor = Color3.fromRGB(41, 74, 122),
        TitleBgActiveTransparency = 0,
        TitleBgCollapsedColor = Color3.fromRGB(0, 0, 0),
        TitleBgCollapsedTransparency = 0.5,

        MenubarBgColor = Color3.fromRGB(36, 36, 36),
        MenubarBgTransparency = 0,

        FrameBgColor = Color3.fromRGB(41, 74, 122),
        FrameBgTransparency = 0.46,
        FrameBgHoveredColor = Color3.fromRGB(66, 150, 250),
        FrameBgHoveredTransparency = 0.46,
        FrameBgActiveColor = Color3.fromRGB(66, 150, 250),
        FrameBgActiveTransparency = 0.33,

        ButtonColor = Color3.fromRGB(66, 150, 250),
        ButtonTransparency = 0.6,
        ButtonHoveredColor = Color3.fromRGB(66, 150, 250),
        ButtonHoveredTransparency = 0,
        ButtonActiveColor = Color3.fromRGB(15, 135, 250),
        ButtonActiveTransparency = 0,

        SliderGrabColor = Color3.fromRGB(66, 150, 250),
        SliderGrabTransparency = 0,
        SliderGrabActiveColor = Color3.fromRGB(117, 138, 204),
        SliderGrabActiveTransparency = 0,

        HeaderColor = Color3.fromRGB(66, 150, 250),
        HeaderTransparency = 0.69,
        HeaderHoveredColor = Color3.fromRGB(66, 150, 250),
        HeaderHoveredTransparency = 0.2,
        HeaderActiveColor = Color3.fromRGB(66, 150, 250),
        HeaderActiveTransparency = 0,

        SelectionImageObjectColor = Color3.fromRGB(255, 255, 255),
        SelectionImageObjectTransparency = 0.8,
        SelectionImageObjectBorderColor = Color3.fromRGB(255, 255, 255),
        SelectionImageObjectBorderTransparency = 0,

        TableBorderStrongColor = Color3.fromRGB(79, 79, 89),
        TableBorderStrongTransparency = 0,
        TableBorderLightColor = Color3.fromRGB(59, 59, 64),
        TableBorderLightTransparency = 0,
        TableRowBgColor = Color3.fromRGB(0, 0, 0),
        TableRowBgTransparency = 1,
        TableRowBgAltColor = Color3.fromRGB(255, 255, 255),
        TableRowBgAltTransparency = 0.94,

        NavWindowingHighlightColor = Color3.fromRGB(255, 255, 255),
        NavWindowingHighlightTransparency = 0.3,
        NavWindowingDimBgColor = Color3.fromRGB(204, 204, 204),
        NavWindowingDimBgTransparency = 0.65,

        SeparatorColor = Color3.fromRGB(110, 110, 128),
        SeparatorTransparency = 0.5,

        CheckMarkColor = Color3.fromRGB(66, 150, 250),
        CheckMarkTransparency = 0,
    },
    colorLight = { -- Dear, ImGui default light
        TextColor = Color3.fromRGB(0, 0, 0),
        TextTransparency = 0,
        TextDisabledColor = Color3.fromRGB(153, 153, 153),
        TextDisabledTransparency = 0,

        BorderColor = Color3.fromRGB(64, 64, 64),
        -- Dear ImGui uses 0, 0, 0, 77
        -- The Roblox window selection highlight is 67, 191, 254
        BorderActiveColor = Color3.fromRGB(64, 64, 64), -- does not exist in Dear ImGui

        -- BorderTransparency = 0.5,
        -- BorderTransparency will be problematic for non UIStroke border implimentations
        -- will not be implimented because of this

        WindowBgColor = Color3.fromRGB(240, 240, 240),
        WindowBgTransparency = 0,

        TitleBgColor = Color3.fromRGB(245, 245, 245),
        TitleBgTransparency = 0,
        TitleBgActiveColor = Color3.fromRGB(209, 209, 209),
        TitleBgActiveTransparency = 0,
        TitleBgCollapsedColor = Color3.fromRGB(255, 255, 255),
        TitleBgCollapsedTransparency = 0.5,

        MenubarBgColor = Color3.fromRGB(219, 219, 219),
        MenubarBgTransparency = 0,

        ScrollbarGrabColor = Color3.fromRGB(96, 96, 96),
        ScrollbarGrabTransparency = 0,

        FrameBgColor = Color3.fromRGB(255, 255, 255),
        FrameBgTransparency = 0.6,
        FrameBgHoveredColor = Color3.fromRGB(66, 150, 250),
        FrameBgHoveredTransparency = 0.6,
        FrameBgActiveColor = Color3.fromRGB(66, 150, 250),
        FrameBgActiveTransparency = 0.33,

        ButtonColor = Color3.fromRGB(66, 150, 250),
        ButtonTransparency = 0.6,
        ButtonHoveredColor = Color3.fromRGB(66, 150, 250),
        ButtonHoveredTransparency = 0,
        ButtonActiveColor = Color3.fromRGB(15, 135, 250),
        ButtonActiveTransparency = 0,

        HeaderColor = Color3.fromRGB(66, 150, 250),
        HeaderTransparency = 0.31,
        HeaderHoveredColor = Color3.fromRGB(66, 150, 250),
        HeaderHoveredTransparency = 0.2,
        HeaderActiveColor = Color3.fromRGB(66, 150, 250),
        HeaderActiveTransparency = 0,

        SliderGrabColor = Color3.fromRGB(61, 133, 224),
        SliderGrabTransparency = 0,
        SliderGrabActiveColor = Color3.fromRGB(66, 150, 250),
        SliderGrabActiveTransparency = 0,

        SelectionImageObjectColor = Color3.fromRGB(0, 0, 0),
        SelectionImageObjectTransparency = 0.8,
        SelectionImageObjectBorderColor = Color3.fromRGB(0, 0, 0),
        SelectionImageObjectBorderTransparency = 0,

        TableBorderStrongColor = Color3.fromRGB(145, 145, 163),
        TableBorderStrongTransparency = 0,
        TableBorderLightColor = Color3.fromRGB(173, 173, 189),
        TableBorderLightTransparency = 0,
        TableRowBgColor = Color3.fromRGB(0, 0, 0),
        TableRowBgTransparency = 1,
        TableRowBgAltColor = Color3.fromRGB(77, 77, 77),
        TableRowBgAltTransparency = 0.91,

        NavWindowingHighlightColor = Color3.fromRGB(179, 179, 179),
        NavWindowingHighlightTransparency = 0.3,
        NavWindowingDimBgColor = Color3.fromRGB(51, 51, 51),
        NavWindowingDimBgTransparency = 0.8,

        SeparatorColor = Color3.fromRGB(99, 99, 99),
        SeparatorTransparency = 0.38,

        CheckMarkColor = Color3.fromRGB(66, 150, 250),
        CheckMarkTransparency = 0,
    },

    sizeDefault = { -- Dear, ImGui default
        ItemWidth = UDim.new(1, 0),
        ContentWidth = UDim.new(0.65, 0),

        WindowPadding = Vector2.new(8, 8),
        WindowResizePadding = Vector2.new(6, 6),
        FramePadding = Vector2.new(4, 3),
        ItemSpacing = Vector2.new(8, 4),
        ItemInnerSpacing = Vector2.new(4, 4),
        CellPadding = Vector2.new(4, 2),
        DisplaySafeAreaPadding = Vector2.new(0, 0),
        SeparatorTextPadding = Vector2.new(20, 3),
        IndentSpacing = 21,

        TextFont = Font.fromEnum(Enum.Font.Code),
        TextSize = 13,
        FrameBorderSize = 0,
        FrameRounding = 0,
        GrabRounding = 0,
        WindowRounding = 0, -- these don't actually work but it's nice to have them.
        WindowBorderSize = 1,
        WindowTitleAlign = Enum.LeftRight.Left,
        PopupBorderSize = 1,
        PopupRounding = 0,
        ScrollbarSize = 7,
        GrabMinSize = 10,
        SeparatorTextBorderSize = 3,
    },
    sizeClear = { -- easier to read and manuveure
        ItemWidth = UDim.new(1, 0),
        ContentWidth = UDim.new(0.65, 0),

        WindowPadding = Vector2.new(12, 8),
        WindowResizePadding = Vector2.new(8, 8),
        FramePadding = Vector2.new(6, 4),
        ItemSpacing = Vector2.new(8, 8),
        ItemInnerSpacing = Vector2.new(8, 8),
        CellPadding = Vector2.new(4, 4),
        DisplaySafeAreaPadding = Vector2.new(8, 8),
        SeparatorTextPadding = Vector2.new(24, 6),
        IndentSpacing = 25,

        TextFont = Font.fromEnum(Enum.Font.Ubuntu),
        TextSize = 15,
        FrameBorderSize = 1,
        FrameRounding = 4,
        GrabRounding = 4,
        WindowRounding = 4,
        WindowBorderSize = 1,
        WindowTitleAlign = Enum.LeftRight.Center,
        PopupBorderSize = 1,
        PopupRounding = 4,
        ScrollbarSize = 9,
        GrabMinSize = 14,
        SeparatorTextBorderSize = 4,
    },

    utilityDefault = {
        UseScreenGUIs = true,
        IgnoreGuiInset = false,
        Parent = nil,
        DisplayOrderOffset = 127,
        ZIndexOffset = 0,

        MouseDoubleClickTime = 0.30, -- Time for a double-click, in seconds.
        MouseDoubleClickMaxDist = 6.0, -- Distance threshold to stay in to validate a double-click, in pixels.

        HoverColor = Color3.fromRGB(255, 255, 0),
        HoverTransparency = 0.1,
    },
}

return TemplateConfig
