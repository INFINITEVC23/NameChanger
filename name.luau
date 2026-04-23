-- 1. WAIT FOR GAME LOAD (Fixes "Ugc" error)
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local fileName = "Rivals_Save_Data.json"

-- 2. LOCAL DATA CHECK (No server contact)
local function getSavedName()
    if isfile(fileName) then
        local success, result = pcall(function() 
            return HttpService:JSONDecode(readfile(fileName)).SavedName 
        end)
        if success then return result end
    end
    return nil
end

-- Check if we already have a name saved
local savedName = getSavedName()

-- 3. THE AUTO-APPLY LOGIC
-- If a name exists, we start the loop IMMEDIATELY without waiting for UI
if savedName then
    task.spawn(function()
        while true do
            pcall(function()
                lp.DisplayName = savedName
                lp.Name = savedName
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.DisplayName = savedName
                end
            end)
            task.wait(5) -- 5s delay prevents the HTTP 429 error
        end
    end)
end

-- 4. THE UI (Only loads if you haven't set a name yet)
if not savedName then
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
       Name = "Rivals Identity",
       LoadingTitle = "First Time Setup",
       ConfigurationSaving = {Enabled = false}
    })

    local Tab = Window:CreateTab("Main", 4483362458)

    Tab:CreateInput({
       Name = "Set Persistent Name",
       PlaceholderText = "Type name and hit Enter...",
       Callback = function(Text)
          writefile(fileName, HttpService:JSONEncode({SavedName = Text}))
          print("Name saved! It will now auto-load in every match.")
          -- Force an immediate apply
          pcall(function()
              lp.DisplayName = Text
              lp.Name = Text
          end)
       end,
    })
else
    print("Gemini: Identity found! Auto-applying '" .. savedName .. "' in background.")
end

-- 5. TELEPORT SYNC
if queue_on_teleport then
    -- This prepares the script to run as soon as you land in the 1v1/FFA
    queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/INFINITEVC23/NameChanger/refs/heads/main/name.luau'))(); print('Teleport Sync Active')")
end
