-- 1. WAIT (Fixes the "Ugc" DataModel error)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- 2. CHECK FOR SAVED DATA (Handles both custom names independently)
local HttpService = game:GetService("HttpService")
local fileName = "Rivals_Identity.json"

local function getSavedIdentity()
    if isfile(fileName) then
        local success, result = pcall(function() 
            return HttpService:JSONDecode(readfile(fileName)) 
        end)
        if success and type(result) == "table" then return result end
    end
    return nil
end

local identity = getSavedIdentity()
local targetName = identity and identity.SavedName
local targetDisplay = identity and identity.SavedDisplay

-- === Pure Visual Replacement Logic (From 1KS Kawaii Name Changer) ===
local function applyReplacements(text, fakeUser, fakeDisplay)
    if not text or text == "" then return nil end
    local origDisp, origUser = lp.DisplayName, lp.Name
    local changed = false

    -- Handle DisplayName text swaps
    if origDisp ~= "" and text:find(origDisp, 1, true) then
        text = text:gsub(origDisp, fakeDisplay)
        changed = true
    end

    -- Handle Username (@Name) text swaps
    if origUser ~= "" and text:find(origUser, 1, true) then
        text = text:gsub(origUser, fakeUser)
        changed = true
    end

    return changed and text or nil
end

local function patchLabel(lbl, fakeUser, fakeDisplay)
    local newText = applyReplacements(lbl.Text, fakeUser, fakeDisplay)
    if newText then lbl.Text = newText end
end

-- Active hierarchy watch loop for new CoreGui frames loading dynamically
local function watchGui(root, fakeUser, fakeDisplay)
    root.DescendantAdded:Connect(function(d)
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            d:GetPropertyChangedSignal("Text"):Connect(function()
                patchLabel(d, fakeUser, fakeDisplay)
            end)
            patchLabel(d, fakeUser, fakeDisplay)
        end
    end)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            d:GetPropertyChangedSignal("Text"):Connect(function()
                patchLabel(d, fakeUser, fakeDisplay)
            end)
            patchLabel(d, fakeUser, fakeDisplay)
        end
    end
end

-- 3. THE "ONLY LOAD IF NEEDED" LOGIC
if targetName and targetName ~= "" and targetDisplay and targetDisplay ~= "" then
    -- IDENTITY SECURED: Run background visual listeners immediately
    watchGui(CoreGui, targetName, targetDisplay)
    
    RunService.RenderStepped:Connect(function()
        for _, lbl in ipairs(CoreGui:GetDescendants()) do
            if lbl:IsA("TextLabel") or lbl:IsA("TextButton") then
                patchLabel(lbl, targetName, targetDisplay)
            end
        end
    end)
    print("Background Visual Spoof Active. Names Locked In CoreGui.")
else
    -- MISSING CONFIGURATION: Launch complete dual-input Setup Utility
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
       Name = "Rivals Identity System",
       LoadingTitle = "First Time Setup",
       ConfigurationSaving = {Enabled = false}
    })

    local Tab = Window:CreateTab("Settings", 4483362458)

    Tab:CreateInput({
       Name = "1. Set Username (@Name)",
       PlaceholderText = "Type system username...",
       CurrentValue = targetName or "",
       Callback = function(Text)
          targetName = Text
          writefile(fileName, HttpService:JSONEncode({SavedName = targetName, SavedDisplay = targetDisplay or ""}))
       end,
    })

    Tab:CreateInput({
       Name = "2. Set Display Name",
       PlaceholderText = "Type custom display name...",
       CurrentValue = targetDisplay or "",
       Callback = function(Text)
          targetDisplay = Text
          writefile(fileName, HttpService:JSONEncode({SavedName = targetName or "", SavedDisplay = targetDisplay}))
          
          -- Initialize the real-time replacement immediately once settings are updated
          if targetName and targetName ~= "" then
              watchGui(CoreGui, targetName, targetDisplay)
              RunService.RenderStepped:Connect(function()
                  for _, lbl in ipairs(CoreGui:GetDescendants()) do
                      if lbl:IsA("TextLabel") or lbl:IsA("TextButton") then
                          patchLabel(lbl, targetName, targetDisplay)
                      end
                  end
              end)
              print("Live CoreGui intercept initialized.")
          end
       end,
    })
end

-- 4. THE CORRECT TELEPORT SYNC
if queue_on_teleport then
    queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/INFINITEVC23/NameChanger/refs/heads/main/name.luau'))()")
end
