return {

    { "folke/lazy.nvim", version = "*" },
    { "nvim-lua/plenary.nvim", lazy = true },
    {
        "antoinemadec/FixCursorHold.nvim",
        init = function()
            vim.g.cursorhold_updatetime = 100
        end
    },
    {
        "stevearc/profile.nvim",
        enabled = false,
        lazy = true,
        priority = 999,
        init = function()
            local should_profile = os.getenv("NVIM_PROFILE")
            if should_profile then
                require("profile").instrument_autocmds()
                if should_profile:lower():match("^start") then
                    require("profile").start("*")
                else
                    require("profile").instrument("*")
                end
            end

            local function toggle_profile()
                local prof = require("profile")
                if prof.is_recording() then
                    prof.stop()
                    vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
                        if filename then
                            prof.export(filename)
                            vim.notify(string.format("Wrote %s", filename))
                        end
                    end)
                else
                    prof.start("*")
                end
            end
            vim.keymap.set("", "<F8>", toggle_profile)
        end,
    },

}
