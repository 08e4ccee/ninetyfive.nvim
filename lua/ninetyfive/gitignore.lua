local git = require("ninetyfive.git")
local log = require("ninetyfive.util.log")

local GitignoreCache = {}

---@param bufnr number
function GitignoreCache.is_ignored(bufnr, cb)
    local status = vim.b[bufnr].ninetyfive_gitignored
    if status ~= nil then
        if cb then
            cb(status)
        end
    end
    GitignoreCache.update_status(bufnr, cb)
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
