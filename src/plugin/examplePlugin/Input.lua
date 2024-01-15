local UserInputService: UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Signal)

local Input = {}

Input.X = 0
Input.Y = 0
Input.KeyDown = {}
Input._connections = {}

local SinkFrame: Frame = Instance.new("Frame")
SinkFrame.Name = "SinkFrame"
SinkFrame.AnchorPoint = Vector2.new(0.5, 0.5)
SinkFrame.Position = UDim2.fromScale(0.5, 0.5)
SinkFrame.Size = UDim2.fromScale(1, 1)
SinkFrame.BackgroundTransparency = 1

Input.SinkFrame = SinkFrame

Input.InputBegan = Signal.new()
Input.InputChanged = Signal.new()
Input.InputEnded = Signal.new()
Input.MouseMoved = Signal.new()
Input.TouchTapInWorld = Signal.new()

SinkFrame.InputBegan:Connect(function(input: InputObject)
    Input.KeyDown[input.KeyCode] = true
    Input.InputBegan:Fire(input, true)
end)

-- local connection: RBXScriptConnection = UserInputService.InputBegan:Connect(function(input: InputObject)
--     Input.KeyDown[input.KeyCode] = true
--     Input.InputBegan:Fire(input, false)
-- end)
-- table.insert(Input._connections, connection)

SinkFrame.InputEnded:Connect(function(input: InputObject)
    Input.KeyDown[input.KeyCode] = nil
    Input.InputEnded:Fire(input, true)
end)

-- connection = UserInputService.InputEnded:Connect(function(input: InputObject)
--     Input.KeyDown[input.KeyCode] = nil
--     Input.InputEnded:Fire(input, false)
-- end)
-- table.insert(Input._connections, connection)

SinkFrame.InputChanged:Connect(function(input: InputObject)
    print("SINK:")
    Input.InputChanged:Fire(input, true)
end)

-- connection = UserInputService.InputChanged:Connect(function(input: InputObject)
--     print("SERVICE:")
--     Input.InputChanged:Fire(input, false)
-- end)
-- table.insert(Input._connections, connection)

SinkFrame.MouseMoved:Connect(function(x: number, y: number)
    Input.X = x
    Input.Y = y
end)

function Input:GetMouseLocation()
    return Vector2.new(Input.X, Input.Y)
end

function Input:IsKeyDown(keyCode: Enum.KeyCode)
    return Input.KeyDown[keyCode] or false
end

return Input
