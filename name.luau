-- 1. WAIT (Fixes the "Ugc" DataModel error)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local CoreGui = game:GetService("CoreGui")

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

-- Extra function to force patch CoreGui/Pause Menu text elements
local function patchPauseMenu(name)
    pcall(function()
        -- Traverse CoreGui for the Player Scroll List inside the Roblox Pause Menu
        local settingsShield = CoreGui:FindFirstChild("RobloxGui") and CoreGui.RobloxGui:FindFirstChild("SettingsShield")
        if settingsShield then
            for _, v in pairs(settingsShield:GetDescendants()) do
                -- Look for text labels displaying your old display name or username
                if v:IsA("TextLabel") and (v.Text == lp.Name or v.Text == "NXRivals") then
                    v.Text = name
                end
            end
        end
    end)
end

-- 3. THE "ONLY LOAD IF NEEDED" LOGIC
if targetName and targetName ~= "" then
    -- WE ALREADY HAVE A NAME: Skip Rayfield entirely to avoid 429 errors!
    task.spawn(function()
        while true do
            pcall(function()
                -- Player profile changes
                lp.DisplayName = targetName
                lp.Name = targetName
                
                -- Physical character changes (Updates the name tags above your head)
                if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                    local humanoid = lp.Character:FindFirstChildOfClass("Humanoid")
                    humanoid.DisplayName = targetName
                end

                -- Force overwrite the elements in the CoreGui Pause Menu
                patchPauseMenu(targetName)
            end)
            task.wait(2) -- Slightly faster loop to keep up with menu rendering
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
              if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                  lp.Character:FindFirstChildOfClass("Humanoid").DisplayName = Text
              end
              patchPauseMenu(Text)
          end)
       end,
    })
end

-- 4. THE CORRECT TELEPORT SYNC
if queue_on_teleport then
    -- This points back to your GitHub so it re-runs this logic in the 1v1
    queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/INFINITEVC23/NameChanger/refs/heads/main/name.luau'))(); print('Teleport Sync Active')")
end
