-- 1. WAIT (Fixes the "Ugc" DataModel error)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- 2. CHECK FOR SAVED NAME (Local only, no server call)
local HttpService = game:GetService("HttpService")
local fileName = "Rivals_Identity.json"

local function getSavedName()
    if isfile(fileName) then
        local success, result = pcall(function() 
            -- FIXED: Changed JSONEncode to JSONDecode so it reads the file correctly
            return HttpService:JSONDecode(readfile(fileName)).SavedName 
        end)
        -- Note: We use pcall to ensure a bad file doesn't crash the script
        if success then return result end
    end
    return nil
end

local targetName = getSavedName()

-- 3. THE "ONLY LOAD IF NEEDED" LOGIC
if targetName and targetName ~= "" then
    -- WE ALREADY HAVE A NAME: Skip Rayfield entirely to avoid 429 errors!
    task.spawn(function()
        while true do
            pcall(function()
                lp.DisplayName = targetName
                lp.Name = targetName
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.DisplayName = targetName
                end
            end)
            task.wait(5) -- 5s wait keeps Roblox servers happy
        end
    end)
    print("Background Spoof Active. No UI loaded to prevent 429.")
else
    -- NO NAME SAVED: Only now do we call Rayfield
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
end

-- 4. THE CORRECT TELEPORT SYNC
if queue_on_teleport then
    -- This points back to your GitHub so it re-runs this logic in the 1v1
    queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/INFINITEVC23/NameChanger/refs/heads/main/name.luau'))(); print('Teleport Sync Active')")
end
