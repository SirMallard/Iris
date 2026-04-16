-- include iris
local Iris = require(game:HttpGet('https://raw.githubusercontent.com/NoobProgramer6918/Iris4Cheats/refs/heads/main/lib/init.lua')).Init()

local CheatWindows = {}

CheatWindows.Main = function()
  Iris.Window {"Cheat"}
  Iris.Text {"Hello!"}
  if Iris.Button {"esp"}.clicked() then
    -- esp stuff that i wont include since this is simple
  end
  Iris.InputNum {"totaly changes your speed"}

  Iris.End() -- when doing some thing like creating an Window
  -- treat this like an normal lua 'end' but just for iris stuff
end

Iris:Connect(CheatWindows.Main) -- connect the window function to iris
