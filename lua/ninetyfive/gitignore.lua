local git = require("ninetyfive.git")
local log = require("ninetyfive.util.log")

local GitignoreCache = {}

---@param bufnr number
function GitignoreCache.is_cached(bufnr)
    local status = vim.b[bufnr].ninetyfive_gitignored
    return status ~= nil
end
---@param bufnr number
function GitignoreCache.is_ignored(bufnr, cb)
    local status = vim.b[bufnr].ninetyfive_gitignored
    if status ~= nil then
        cb(status)
        return
    end

    local timer = vim.loop.new_timer()
    local elapsed = 0
    local max_wait = 3000

    local done = false
    timer:start(
        0,
        60,
        vim.schedule_wrap(function()
            if done then
                return
            end
            local status2 = vim.b[bufnr].ninetyfive_gitignored

            if status2 ~= nil then
                done = true
                -- print("RESOLVING FROM STATUS")
                timer:stop()
                timer:close()
                cb(status2)
            elseif elapsed >= max_wait then
                done = true
                timer:stop()
                timer:close()
                cb(true)
            end
            elapsed = elapsed + 60
        end)
    )

    -- // case 1 - return cb(false)- ws is not closed
    -- vim.defer_fn(function()
    --     cb(false)
    -- end, 1000)
    -- case 2 - call update status and wrap calbacl - ws is closed
    -- GitignoreCache.update_status(bufnr, function(v)
    --     cb(v == true)
    -- end)
end

---@param bufnr number
function GitignoreCache.update_status(bufnr, cb)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local bufname = vim.api.nvim_buf_get_name(bufnr)

    if not bufname or bufname == "" then
        vim.b[bufnr].ninetyfive_gitignored = false
        log.debug("gitignore", "Buffer " .. bufnr .. " has no name, marking as not ignored")
        return
    end
    git.is_ignored(bufname, function(ignored)
        -- if not vim.api.nvim_buf_is_valid(bufnr) then
        --     return
        -- end

        vim.b[bufnr].ninetyfive_gitignored = ignored

        if ignored then
            -- print("gitignore " .. bufname .. " is gitignored")
            log.debug("gitignore", "Buffer " .. bufnr .. " (" .. bufname .. ") is gitignored")
        else
            -- print("gitignore " .. bufname .. " is not gitignored")
            log.debug("gitignore", "Buffer " .. bufnr .. " (" .. bufname .. ") is not gitignored")
        end
        if cb ~= nil then
            cb(ignored)
        end
    end)
end

---@param bufnr number
function GitignoreCache.clear_status(bufnr)
    vim.b[bufnr].ninetyfive_gitignored = nil
end

return GitignoreCache
