local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local VirtualUser = game:GetService("VirtualUser")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.events

local Modules = ReplicatedStorage.modules
local Library = Modules.library

local FishLibrary = require(Library.fish)

--

local fc = {}

--[[
    FISHING
    functions
--]]

-- gets player's rod instance
-- rod(player: Player | LocalPlayer): Instance
function fc.rod(player)
    player = player or LocalPlayer
    local rodName = ReplicatedStorage.playerstats[player.Name].Stats.rod.Value
    return player.Character:FindFirstChild(rodName)
end

-- check if player is currently fishing (true when fishing and reeling)
-- isFishing(player: Player | LocalPlayer): boolean
function fc.isFishing(player)
    local rod = fc.rod(player or LocalPlayer)
    return rod and rod.values.casted.Value or false
end

-- check if player is currently reeling (false when fishing, true when reeling)
-- isReeling(player: Player | LocalPlayer): boolean
function fc.isReeling(player)
    local rod = fc.rod(player or LocalPlayer)
    return rod and rod.values.bite.Value or false
end

-- casts rod at a distance
-- cast(distance: number | 50): ()
function fc.cast(distance)
    if fc.isFishing() then return end
    fc.rod().events.cast:FireServer(distance or 50)
end

-- shakes 1 time if isFishing == true
-- shake(): ()
function fc.shake()
    if not fc.isFishing() then return end
    pcall(function()
        PlayerGui:FindFirstChild("shakeui").safezone:FindFirstChild("button").Size = UDim2.new(1001, 0, 1001, 0)
        VirtualUser:Button1Down(Vector2.new(1, 1))
        VirtualUser:Button1Up(Vector2.new(1, 1))
    end)
end

-- instantly finishes reeling stage with accuracy, 100 being perfect catch
-- finishReel(accuracy: number | 100): ()
function fc.finishReel(accuracy)
    ReplicatedStorage.events.reelfinished:FireServer(accuracy or 100, true)
end

--[[
    PLAYER
    functions
--]]

-- gets player's equipped tools
-- getEquippedTools(player: Player | LocalPlayer): {Instance, ...}?
function fc.getEquippedTools(player)
    player = player or LocalPlayer
    local tools = {}
    for _, child in player.Character:GetChildren() do
        if child:IsA("Tool") then
            table.insert(tools, child)
        end
    end
    return tools
end

--[[
    TRADING
    functions
--]]

-- offers held item to people (game has ~3s cooldown after offer is accepted)
-- offerHand(to: player | LocalPlayer): ()
function fc.offerHand(to)
    local equippedTools = fc.getEquippedTools()
    if #equippedTools ~= 1 then return error("not holding only 1 item") end

    local equippedTool = equippedTools[1]
    local offer = equippedTool:FindFirstChild("offer")

    if not offer then return error("unofferable") end
    
    offer:FireServer(to or LocalPlayer)
end
