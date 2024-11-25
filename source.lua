--[[

	Fisch Community
	A community-maintained list of functions to assist script developers in Fisch

	Make a pull request to help update!

	To use, 
	local fc = loadstring(game:HttpGet('https://raw.githubusercontent.com/treee-pro/FischCommunity/main/source.lua'))()

--]]

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
function fc.rod(player)
    player = player or LocalPlayer
    local rodName = ReplicatedStorage.playerstats[player.Name].Stats.rod.Value
    return player.Character:FindFirstChild(rodName)
end

-- check if player is currently fishing (true when reeling and fishing)
function fc.isFishing(player)
    player = player or LocalPlayer
    return (fc.rod(player) and fc.rod(player):FindFirstChild("bobber")) and true or false
end

-- check if player is currently reeling (true when reeling, false when fishing)
function fc.isReeling(player)
    return (fc.rod(player).values.bite.Value) and true or false
end

-- casts rod with options.distance
function fc.cast(options)
    options = options or {}
    if fc.isFishing() then return end
    fc.rod().events.cast:FireServer(options.distance or 0)
end

-- shakes 1 time if isFishing == true
function fc.shake()
    if not fc.isFishing() then return end
    pcall(function()
        PlayerGui:FindFirstChild("shakeui").safezone:FindFirstChild("button").Size = UDim2.new(1001, 0, 1001, 0)
        VirtualUser:Button1Down(Vector2.new(1, 1))
        VirtualUser:Button1Up(Vector2.new(1, 1))
    end)
end

-- instantly finishes reeling stage with options.accuracy, 100 being perfect catch
function fc.finishReel(options)
    options = options or {}
    ReplicatedStorage.events.reelfinished:FireServer(options.accuracy or 100, true)
end

--[[
    debug
--]]

-- library modules store info on all fishes/items/locations/... in game
-- refer to "game.ReplicatedStorage.modules.library" to view all types of info stored
-- to use, getLibrary the name of any modulescript under this path, for example getLibrary("fish") returns a dictionary of fish info.
function fc.getLibrary(name)
    for _, mod in pairs(Library:GetDescendants()) do
        if mod.Name == name then
            return require(mod)
        end
    end
end

return fc
