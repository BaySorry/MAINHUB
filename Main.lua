-- Main Script Loader
-- Handles multi-game detection and update checks.
local RegistryUrl = "https://raw.githubusercontent.com/BaySorry/MAINHUB/refs/heads/main/Update%20Checker/Wsup.lua"

-- LOADER
local function ExecuteLoader()
    local success, content = pcall(function()
        return game:HttpGet(RegistryUrl)
    end)

    if not success then
        warn("[LOADER ERROR] HTTP Request failed: " .. tostring(content))
        return
    end

    if content:find("404: Not Found") or content:find("<!DOCTYPE html>") then
        warn("[LOADER ERROR] Registry file not found (404) at URL: " .. RegistryUrl)
        warn("Please ensure the file is pushed to GitHub and the URL is correct.")
        return
    end

    local loadSuccess, registryFunc = pcall(loadstring, content)
    if not loadSuccess or not registryFunc then
        warn("[LOADER ERROR] Syntax error in registry content: " .. tostring(registryFunc))
        return
    end

    local execSuccess, registry = pcall(registryFunc)
    if not execSuccess or type(registry) ~= "table" then
        warn("[LOADER ERROR] Failed to initialize registry: " .. tostring(registry))
        return
    end

    local currentId = tostring(game.PlaceId)
    local gameConfig = registry.Database[currentId]

    if gameConfig then
        if gameConfig.NeedsUpdate then
            if registry.ShowBanner then
                registry.ShowBanner(gameConfig.Name)
            end
            warn("[LOADER] " .. gameConfig.Name .. " is currently under maintenance.")
        else
            warn("[LOADER] Launching " .. gameConfig.Name .. "...")
            local scriptContent = game:HttpGet(gameConfig.ScriptUrl)
            loadstring(scriptContent)()
        end
    else
        warn("[LOADER] This game (ID: " .. currentId .. ") is not supported.")
    end
end

ExecuteLoader()
-- Made by mornd.
