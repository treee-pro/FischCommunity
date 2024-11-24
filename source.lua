--[[

    Welcome to the Fisch Community script!
    An open-source, community-maintained script.

    Send a pull request to contribute!

--]]

local Config = {
    AutoCast = false;
    AutoShake = false;
    AutoReel = false;
}

----

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:FindFirstChild("events")

local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack

local World = workspace.world
local NPCs = World.npcs
local TpSpots = World.spawns.TpSpots

--

-- (): string
function getRodName()
    return ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
end

-- (): boolean
function isPlayerFishing()
    RodName = getRodName()
    return (LocalPlayer.Character:FindFirstChild(RodName) and LocalPlayer.Character:FindFirstChild(RodName):FindFirstChild("bobber"))
end

-- (): boolean
function isPlayerReeling()
    RodName = getRodName()
    return LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value
end

-- (name: boolean): Instance | boolean
function getNearestMerchant(name)
    -- NPCs only load if you are near them.
    for _, npc in NPCs:GetChildren() do
        if npc.Name:find("Merchant") and (npc.Name ~= "Travelling Merchant") then
            if name then
                return npc.Name
            end
            return npc
        end
    end
end

-- (): {string, ...}
function getTpSpotNames()
    local result = {}
    for _, TpSpot in TpSpots:GetChildren() do
        table.insert(result, TpSpot.Name)
    end
    return result
end

--

local Functions = {
    AutoCast = function()
        while Config.AutoCast and task.wait() do
            -- If currently fishing, don't proceed.
            if isPlayerFishing() then continue end
            
            -- Get rod name.
            RodName = getRodName()

            -- If rod not equipped, equip.
            if Backpack:FindFirstChild(RodName) then
                LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
            end

            -- Cast.
            LocalPlayer.Character:FindFirstChild(RodName).events.cast:FireServer(100)
            
            -- debounce
            task.wait(1)
        end
    end;

    AutoShake = function()
        while Config.AutoShake and task.wait() do
            -- If not currently fishing, don't proceed.
            if not isPlayerFishing() then continue end
        
            -- Get rod name.
            RodName = getRodName()

			repeat
				pcall(function()
					PlayerGui:FindFirstChild("shakeui").safezone:FindFirstChild("button").Size = UDim2.new(1001, 0, 1001, 0)
				    VirtualUser:Button1Down(Vector2.new(1, 1))
					VirtualUser:Button1Up(Vector2.new(1, 1))
				end)
				RunService.Heartbeat:Wait()
			until not LocalPlayer.Character:FindFirstChild(RodName) or LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value
            -- no need debounce
        end
    end;

    AutoReel = function()
        while Config.AutoReel and task.wait() do
            
            -- If not currently reeling, don't proceed.
            if not isPlayerReeling() then continue end

            ReplicatedStorage.events.reelfinished:FireServer(100, true)
            
            -- debounce
            task.wait(1)
        end
    end;

    SellEverything = function()
        local Merchant = getNearestMerchant()
        if Merchant then
            Merchant.merchant.sellall:InvokeServer()
        end
    end;

    SellHand = function()
        local Merchant = getNearestMerchant()
        if Merchant then
            Merchant.merchant.sell:InvokeServer()
        end
    end;

}

-- UI

local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()

local ui = library:CreateWindow({
    Name = "Fisch Community",
    Themeable = false
})

-- Main

local MainTab = ui:CreateTab {
    Name = "Main"
}

local FarmingSection = MainTab:CreateSection {
    Name = "Farming"
}

FarmingSection:AddToggle {
    Name = "Auto Cast";
    Value = false;
    Callback = function(value)
        Config.AutoCast = value
        Functions.AutoCast()
    end
}

FarmingSection:AddToggle {
    Name = "Auto Shake";
    Value = false;
    Callback = function(value)
        Config.AutoShake = value
        Functions.AutoShake()
    end
}   

FarmingSection:AddToggle {
    Name = "Auto Reel";
    Value = false;
    Callback = function(value)
        Config.AutoReel = value
        Functions.AutoReel()
    end
}

-- Merchants

local MerchantSection = MainTab:CreateSection {
    Name = "Merchant"
}

local MerchantsAvailableLabel = MerchantSection:AddLabel {
    Name = getNearestMerchant(true) or "No merchants found."
}

NPCs.ChildAdded:Connect(function(child)
    if child.Name:find("Merchant") then
        MerchantsAvailableLabel:Set(getNearestMerchant(true))
    end
end)

NPCs.ChildRemoved:Connect(function(child)
    if child.Name:find("Merchant") then
        MerchantsAvailableLabel:Set("No merchants found.")
    end
end)

MerchantSection:AddButton {
    Name = "Sell All";
    Callback = function()
        Functions.SellEverything()
    end
}

MerchantSection:AddButton {
    Name = "Sell Hand";
    Callback = function()
        Functions.SellHand()
    end
}

MerchantSection:AddButton {
    Name = "Teleport to Merchant";
    Callback = function()
        LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = getNearestMerchant().HumanoidRootPart.CFrame
    end
}

-- Teleports

local TeleportSection = MainTab:CreateSection {
    Name = "Teleport"
}

TeleportSection:AddDropdown {
    Name = "TpSpots";
    List = getTpSpotNames();

    Callback = function(value)
        LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = TpSpots[value].CFrame
    end
}

-- Player

local PlayerSection = MainTab:CreateSection {
    Name = "Player"
}

PlayerSection:AddSlider {
    Name = "WalkSpeed";
    Value = 16;
    Min = 16;
    Max = 100;
    Textbox = true;
    IllegalInput = true;
    Callback = function(value)
        LocalPlayer.Character:FindFirstChild("Humanoid").WalkSpeed = value
    end
}

PlayerSection:AddToggle {
    Name = "Anti Drown";
    Value = false;
    Callback = function(value)
        LocalPlayer.Character.client.oxygen.Disabled = value
    end
}




-- Other stuff

-- Anti-AFK
pcall(function()
    for i,v in pairs(getconnections(Client.Idled)) do
        v:Disable() 
    end
    Client.Idled:connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    while task.wait(300) do
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end
end)
