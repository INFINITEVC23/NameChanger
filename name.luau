-- 1. WAIT FOR ENGINE (Stops 'Ugc' errors)
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local HttpService = game:GetService("HttpService")
local fileName = "Rivals_Save_Data.json"

-- Capture the variable from your executor
local showUI = false
if ConfigGui ~= nil then
    showUI = ConfigGui
    _G.StoredConfigGui = ConfigGui -- Store for teleporting
end

-- 2. LOCAL DATA CHECK
local function getSavedData()
    if isfile(fileName) then
        local success, result = pcall(function() 
            return HttpService:JSONDecode(readfile(fileName)) 
        end)
        if success then return result end
    end
    return {SavedName = "", SavedID = ""}
end

local savedData = getSavedData()
local currentName = savedData.SavedName
local currentID = savedData.SavedID

-- 3. BACKGROUND SPOOFER (Always active)
task.spawn(function()
    while true do
        pcall(function()
            -- Spoof Name
            if currentName ~= "" then
                lp.DisplayName = currentName
                lp.Name = currentName
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.DisplayName = currentName
                end
            end
            -- Spoof Avatar (UserID)
            if currentID ~= "" then
                lp.CharacterAppearanceId = tonumber(currentID)
            end
        end)
        task.wait(5) -- 5s delay prevents HTTP 429
    end
end)

-- 4. INTERFACE (Only loads if showUI is true)
if showUI then
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
       Name = "Rivals Identity System",
       LoadingTitle = "Loading Config...",
       ConfigurationSaving = {Enabled = false}
    })

    local Tab = Window:CreateTab("Main", 4483362458)

    Tab:CreateInput({
       Name = "Set Persistent Name",
       PlaceholderText = "Type name...",
       CurrentValue = currentName,
       Callback = function(Text)
          currentName = Text
          writefile(fileName, HttpService:JSONEncode({SavedName = currentName, SavedID = currentID}))
          lp.DisplayName = Text
          lp.Name = Text
       end,
    })

    Tab:CreateInput({
       Name = "Set Avatar UserID",
       PlaceholderText = "Enter UserID...",
       CurrentValue = currentID,
       Callback = function(Text)
          currentID = Text
          writefile(fileName, HttpService:JSONEncode({SavedName = currentName, SavedID = currentID}))
          lp.CharacterAppearanceId = tonumber(Text)
          Rayfield:Notify({Title = "Avatar Saved", Content = "Applies on next spawn.", Duration = 3})
       end,
    })
end

-- 5. TELEPORT AUTO-LOAD
if queue_on_teleport then
    -- This ensures that if you chose 'false' in the lobby, it stays 'false' in the 1v1
    local syncVal = tostring(showUI)
    queue_on_teleport("local ConfigGui = " .. syncVal .. "; loadstring(game:HttpGet('https://raw.githubusercontent.com/INFINITEVC23/NameChanger/refs/heads/main/name.luau'))()")
end
