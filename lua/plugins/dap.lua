return {
    {
        "mfussenegger/nvim-dap",
        deps = {
            "mason-org/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },
        lazy = true,
        keys = {
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<M-b>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>dK", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
            { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
            { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
            { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end, desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
        },
        config = function()
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            local ui = require("config.icons").ui
            local dap_icons = {
                Stopped = { ui.Position, "DiagnosticWarn", "DapStoppedLine" },
                Breakpoint = { ui.Breakpoint, },
                BreakpointCondition = { ui.Question, },
                BreakpointRejected = { ui.Exclamation, "DiagnosticError" },
                LogPoint = { ui.Logging, },
            }

            for name, sign in pairs(dap_icons) do
                vim.fn.sign_define("Dap" .. name, {
                    text = sign[1],
                    texthl = sign[2] or "DiagnosticInfo",
                    linehl = sign[3],
                    numhl = sign[3]
                })
            end

            local dap = require("dap")
            -- This avoid unnecessary jumps
            dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"
            dap.defaults.fallback.exception_breakpoints = "uncaught"

        end,
    },

    {
        "miroshQa/debugmaster.nvim",
        enabled = false,
        lazy = true,
        keys = {
            { "<leader>dd", function() require("debugmaster").mode.toggle() end, nowait = true, mode = {"n", "v"}, desc = "Toggle debugger" },
        },
        -- osv is needed if you want to debug neovim lua code. Also can be used
        -- as a way to quickly test-drive the plugin without configuring debug adapters
        dependencies = {
            "mfussenegger/nvim-dap",
            { "jbyuki/one-small-step-for-vimkind", lazy = true },
        },
        config = function()
            local dm = require("debugmaster")
            -- make sure you don't have any other keymaps that starts with "<leader>d" to avoid delay
            -- Alternative keybindings to "<leader>d" could be: "<leader>m", "<leader>;"
            -- vim.keymap.set({ "n", "v" }, "<leader>d", dm.mode.toggle, { nowait = true })
            -- If you want to disable debug mode in addition to leader+d using the Escape key:
            -- vim.keymap.set("n", "<Esc>", dm.mode.disable)
            -- This might be unwanted if you already use Esc for ":noh"
            vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

            dm.plugins.osv_integration.enabled = true -- needed if you want to debug neovim lua code
            -- local dap = require("dap")
            -- Configure your debug adapters here
            -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
        end

    },

    -- UI for the debugger
    {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        dependencies =  {
            "mfussenegger/nvim-dap",
            { "nvim-neotest/nvim-nio", lazy = true },
        },
        keys = {
            { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
            { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
        },
        opts = {
            icons = { expanded = "▾", collapsed = "▸" },
            mappings = {
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            expand_lines = true,
            floating = {
                max_height = nil,
                max_width = nil,
                border = "single",
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            windows = { indent = 1 },
            render = {
                max_type_length = nil,
            },
        },
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup(opts)
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
                dap.repl.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
                dap.repl.close()
            end
        end,
    },

    -- Virtual text for the debugger
    {
        "theHamsta/nvim-dap-virtual-text",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap" },
        opts = { commented = true },
    },

    {
        "julianolf/nvim-dap-lldb",
        ft = { "c", "cpp", "rust" },
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local dap_lldb = require("dap-lldb")
             dap_lldb.setup()
         end,
    },

    {
        "mfussenegger/nvim-dap-python",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap-python").setup("python")
            table.insert(require("dap").configurations.python, {
                type = "python",
                request = "launch",
                name = "My custom launch configuration",
                pythonPath = function()
                    local cwd = vim.fn.getcwd()
                    if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                        return cwd .. "/venv/bin/python"
                    elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                        return cwd .. "/.venv/bin/python"
                    else
                        return "python3"
                    end
                end,
                console = "integratedTerminal",
                cmd = "${workspaceFolder}",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
            })
        end
    },

    -- Mason integration
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
            ensure_installed = {
                "cppdbg",
                "codelldb",
            },
        },
    },
}
