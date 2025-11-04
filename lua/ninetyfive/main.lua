local log = require("ninetyfive.util.log")
local state = require("ninetyfive.state")
local Websocket = require("ninetyfive.websocket")

local gitignore_cache = require("ninetyfive.gitignore")

-- internal methods
local main = {}

-- Toggle the plugin by calling the `enable`/`disable` methods respectively.
--
---@param scope string: internal identifier for logging purposes.
---@private
function main.toggle(scope)
    if state.get_enabled(state) then
        print("toggle: is enabled, disabling..")
        log.debug(scope, "ninetyfive is now disabled!")

        return main.disable(scope)
    end

    print("toggle: is disabled, enabling..")
    log.debug(scope, "ninetyfive is now enabled!")
    local bufnr = vim.api.nvim_get_current_buf()
    if not gitignore_cache.is_cached(bufnr) then
        gitignore_cache.update_status(bufnr, nil)
    end
    main.enable(scope)
end

--- Initializes the plugin, sets event listeners and internal state.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.enable(scope)
    if state.get_enabled(state) then
        log.debug(scope, "ninetyfive is already enabled")

        return
    end

    state.set_enabled(state)

    -- saves the state globally to `_G.Ninetyfive.state`
    state.save(state)
end

--- Disables the plugin for the given tab, clear highlight groups and autocmds, closes side buffers and resets the internal state.
---
--- @param scope string: internal identifier for logging purposes.
---@private
function main.disable(scope)
    if not state.get_enabled(state) then
        log.debug(scope, "ninetyfive is already disabled")

        return
    end

    state.set_disabled(state)

    -- saves the state globally to `_G.Ninetyfive.state`
    state.save(state)
    Websocket.shutdown()
end

return main
