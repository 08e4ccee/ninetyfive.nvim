local log = require("ninetyfive.util.log")
local websocket = require("ninetyfive.websocket")
local completion_state = require("ninetyfive.completion_state")

local Transport = {}

local mode = nil

local function get_plugin_root()
    local runtime = vim.api.nvim_get_runtime_file("lua/ninetyfive/init.lua", false)[1] or ""
    return vim.fn.fnamemodify(runtime, ":h:h:h")
end

local function enable_websocket(server_uri, user_id, api_key)
    local ok, err = websocket.setup_connection(server_uri, user_id, api_key)
    if ok then
        mode = "websocket"
        return true
    end

    return false, err
end

function Transport.current_mode()
    return mode
end

function Transport.shutdown()
    -- websocket.shutdown()
    mode = nil
end

function Transport.setup_connection(server_uri, user_id, api_key)
    Transport.shutdown()

    local plugin_root = get_plugin_root()
    if plugin_root ~= "" then
        local dist_dir = plugin_root .. "/dist"
        -- local has_dist = vim.fn.isdirectory(dist_dir) == 1
    end

    local ws_ok, ws_err = enable_websocket(server_uri, user_id, api_key)
    if ws_ok then
        Transport.setup_autocommands()
        return true, mode
    end

    -- local fallback_reason
    -- if ws_err == "missing_binary" then
    --     fallback_reason = "Websocket proxy binary not available"
    -- else
    --     fallback_reason = "Websocket setup failed"
    -- end
    --
    return false
end

function Transport.setup_autocommands()
    websocket.setup_autocommands()
end

function Transport.has_active()
    return completion_state.has_active()
end

function Transport.clear()
    completion_state.clear()
end

function Transport.accept()
    completion_state.accept()
end

function Transport.accept_edit()
    completion_state.accept_edit()
end

function Transport.reject()
    completion_state.reject()
end

function Transport.get_completion()
    return completion_state.get_completion_chunks()
end

function Transport.reset_completion()
    completion_state.reset_completion()
end

return Transport
