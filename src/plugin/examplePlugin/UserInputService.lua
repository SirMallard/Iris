local Signal = require(script.Parent.Signal)

local UserInputService: UserInputService = game:GetService("UserInputService")

local Input = {}

Input.X = 0
Input.Y = 0
Input.KeyDown = {}
Input._connections = {}

-- This frame will act as our UserInputService detector. Most events should go through it.
-- it's not perfect, but there's not a better alternative (I think)
local SinkFrame: Frame = Instance.new("Frame")
SinkFrame.Name = "SinkFrame"
SinkFrame.AnchorPoint = Vector2.new(0.5, 0.5)
SinkFrame.Position = UDim2.fromScale(0.5, 0.5)
SinkFrame.Size = UDim2.fromScale(1, 1)
SinkFrame.BackgroundTransparency = 1
SinkFrame.ZIndex = 1024 ^ 2

Input.SinkFrame = SinkFrame

-- Methods and events

Input.InputBegan = Signal.new()
Input.InputChanged = Signal.new()
Input.InputEnded = Signal.new()
Input.MouseMoved = Signal.new()
Input.TouchTapInWorld = Signal.new()

function Input:GetMouseLocation()
    return Vector2.new(Input.X, Input.Y)
end

function Input:IsKeyDown(keyCode: Enum.KeyCode)
    if Input.KeyDown[keyCode] == true then
        return true
    end
    return false
end

-- UserInputService hooks

function inputBegan(input: InputObject)
    Input.KeyDown[input.KeyCode] = true
    Input.InputBegan:Fire(input, true)
end

function inputChanged(input: InputObject)
    Input.InputChanged:Fire(input, true)
end

function inputEnded(input: InputObject)
    Input.KeyDown[input.KeyCode] = nil
    Input.InputEnded:Fire(input, true)
end

function mouseMoved(x: number, y: number)
    Input.X = x
    Input.Y = y
end

SinkFrame.InputBegan:Connect(inputBegan)
SinkFrame.InputChanged:Connect(inputChanged)
SinkFrame.InputEnded:Connect(inputEnded)
SinkFrame.MouseMoved:Connect(mouseMoved)

table.insert(Input._connections, UserInputService.InputBegan:Connect(inputBegan))
table.insert(Input._connections, UserInputService.InputChanged:Connect(inputChanged))
table.insert(Input._connections, UserInputService.InputEnded:Connect(inputEnded))

return Input
