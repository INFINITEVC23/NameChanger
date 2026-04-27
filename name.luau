-- 1. ENGINE CHECK
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local HttpService = game:GetService("HttpService")
local fileName = "Rivals_Save_Data.json"

-- Check the global variable from your loader
local showUI = _G.ConfigGui
if showUI == nil then showUI = true end -- Default to true if not specified

-- 2. DATA LOADING
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

-- 3. THE REFRESH FUNCTION (Forces Avatar to change)
local function refreshAppearance(id)
    if id and id ~= "" then
        pcall(function()
            lp.CharacterAppearanceId = tonumber(id)
            if lp.Character then
                local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local desc = Players:GetHumanoidDescriptionFromUserId(tonumber(id))
                    hum:ApplyDescription(desc)
                end
            end
        end)
    end
end

-- 4. PERMANENT BACKGROUND LOOP
task.spawn(function()
    while true do
        pcall(function()
            if currentName ~= "" then
                lp.DisplayName = currentName
                lp.Name = currentName
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.DisplayName = currentName
                end
            end
            if currentID ~= "" then
                lp.CharacterAppearanceId = tonumber(currentID)
            end
        end)
        task.wait(5)
    end
end)

-- 5. THE UI (Only triggers if showUI is true)
if showUI then
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "Rivals Identity",
        LoadingTitle = "Setup Mode",
        ConfigurationSaving = {Enabled = false}
    })
    local Tab = Window:CreateTab("Main", 4483362458)

    Tab:CreateInput({
        Name = "Name Spoof",
        PlaceholderText = "Enter Name...",
        CurrentValue = currentName,
        Callback = function(t)
            currentName = t
            writefile(fileName, HttpService:JSONEncode({SavedName = currentName, SavedID = currentID}))
        end
    })

    Tab:CreateInput({
        Name = "Avatar UserID",
        PlaceholderText = "Enter ID...",
        CurrentValue = currentID,
        Callback = function(t)
            currentID = t
            writefile(fileName, HttpService:JSONEncode({SavedName = currentName, SavedID = currentID}))
            refreshAppearance(t)
        end
    })
end

-- 6. TELEPORT SYNC (Keeps your 'Stealth' or 'Setup' choice)
if queue_on_teleport then
    queue_on_teleport(string.format("_G.ConfigGui = %s; loadstring(game:HttpGet('https://raw.githubusercontent.com/INFINITEVC23/NameChanger/refs/heads/main/name.luau'))()", tostring(showUI)))
end
