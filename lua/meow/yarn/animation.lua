-- MIT License
--
-- Copyright (c) 2025 Andrew Vasilyev <me@retran.me>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- @file: lua/meow/yarn/animation.lua
-- @brief: Loading spinner animation management for hierarchy views
-- @author: Andrew Vasilyev
-- @license: MIT

---@mod meow.yarn.animation
---@brief Manages the loading spinner animation for hierarchy views.

local state = require("meow.yarn.state")
local get_config = function() return require("meow.yarn.config.internal").get() end

local M = {}

---@alias meow.yarn.animate_spinners function
local animate_spinners

--- The callback function for the animation timer.
--- It iterates through active hierarchies and re-renders them to update the spinner icon.
function animate_spinners()
    local cfg = get_config()
    state.G.animation_frame_index = (state.G.animation_frame_index % #cfg.icons.animation_frames) + 1
    for bufnr, hierarchy in pairs(state.G.active_hierarchies) do
        if hierarchy and hierarchy:is_valid() then
            hierarchy.tree:render()
        else
            state.G.active_hierarchies[bufnr] = nil
        end
    end
end

--- Starts or stops the global animation timer based on whether there are any
--- active hierarchies that need animating.
function M.manage_animation_timer()
    local active_count = vim.tbl_count(state.G.active_hierarchies)
    if active_count > 0 and not state.G.animation_timer then
        local cfg = get_config()
        state.G.animation_timer = vim.fn.timer_start(cfg.animation_speed, animate_spinners, { ["repeat"] = -1 })
    elseif active_count == 0 and state.G.animation_timer then
        vim.fn.timer_stop(state.G.animation_timer)
        state.G.animation_timer = nil
    end
end

return M
