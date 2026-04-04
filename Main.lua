-- Main Script Loader
-- Handles multi-game detection and update checks.
local RegistryUrl = "https://raw.githubusercontent.com/username/repo/main/Wsup.lua"

-- LOADER
local function ExecuteLoader()
    local success, registry = pcall(function()
        local content = game:HttpGet(RegistryUrl)
        return loadstring(content)()
    end)

    if not success or type(registry) ~= "table" then
        warn("[LOADER ERROR] Failed to fetch registry: " .. tostring(registry))
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
            loadstring(game:HttpGet(gameConfig.ScriptUrl))()
        end
    else
        warn("[LOADER] This game (ID: " .. currentId .. ") is not supported.")
    end
end

ExecuteLoader()
-- Made by mornd