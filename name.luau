-- 1. WAIT FOR GAME LOAD (Fixes "Ugc" error)
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local HttpService = game:GetService("HttpService")
local fileName = "Rivals_Save_Data.json"

-- Check if ConfigGui was defined in the loader, default to true if not
if ConfigGui == nil then
    _G.ConfigGui = true
else
    _G.ConfigGui = ConfigGui
end

-- 2. LOCAL DATA CHECK
local function getSavedData()
    if isfile(fileName) then
        local success, result = pcall(function() 
            return HttpService:JSONDecode(readfile(fileName)) 
        end)
        if success then return result end
    end
    return {SavedName = nil, SavedID = nil}
end

local savedData = getSavedData()
local savedName = savedData.SavedName
local savedID = savedData.SavedID

-- 3. THE AUTO-APPLY LOGIC (Always runs in background)
task.spawn(function()
    while true do
        pcall(function()
            -- Name Spoof
            if savedName and savedName ~= "" then
                lp.DisplayName = savedName
                lp.Name = savedName
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.DisplayName = savedName
                end
            end
            -- Avatar Spoof
            if savedID and savedID ~= "" then
                lp.CharacterAppearanceId = tonumber(savedID)
            end
        end)
        task.wait(5) -- Safe delay to avoid HTTP 429
    end
end)

-- 4. THE UI (Only loads if _G.ConfigGui is TRUE)
if _G.ConfigGui then
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
       Name = "Rivals Identity + Avatar",
       LoadingTitle = "Identity System",
       ConfigurationSaving = {Enabled = false}
    })

    local Tab = Window:CreateTab("Main", 4483362458)

    Tab:CreateInput({
       Name = "Set Persistent Name",
       PlaceholderText = "Type name...",
       CurrentValue = savedName or "",
       Callback = function(Text)
          savedName = Text
          local data = getSavedData()
          data.SavedName = Text
          writefile(fileName, HttpService:JSONEncode(data))
          lp.DisplayName = Text
          lp.Name = Text
       end,
    })

    Tab:CreateInput({
       Name = "Set Avatar UserID",
       PlaceholderText = "Enter UserID...",
       CurrentValue = savedID or "",
       Callback = function(Text)
          savedID = Text
          local data = getSavedData()
          data.SavedID = Text
          writefile(fileName, HttpService:JSONEncode(data))
          lp.CharacterAppearanceId = tonumber(Text)
       end,
    })
end

-- 5. TELEPORT SYNC (Maintains the variable)
if queue_on_teleport then
    queue_on_teleport("local ConfigGui = " .. tostring(_G.ConfigGui) .. "; loadstring(game:HttpGet('https://raw.githubusercontent.com/INFINITEVC23/NameChanger/refs/heads/main/name.luau'))();")
end
