return {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {

        -- UI for the debugger
        {
            "rcarriga/nvim-dap-ui",
            lazy = true,
            dependencies =  { "nvim-neotest/nvim-nio", lazy = true },
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
            opts = { commented = true },
        },

        {
            "mfussenegger/nvim-dap-python",
            lazy = true,
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
                            return "/usr/bin/python"
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
                automatic_installation = true,
                handlers = {
                    cppdbg = function(config)
                        -- This does not work, gdb does not understand -enable-pretty-printing
                        -- for _, conf in ipairs(config.configurations) do
                        --     conf.setupCommands = {
                        --         text = "-enable-pretty-printing",
                        --         description = "enable pretty printing",
                        --         ignoreFailures = false
                        --     }
                        -- end
                        require("mason-nvim-dap").default_setup(config)
                    end
                    -- codelldb = function(config)
                        -- require("mason-nvim-dap").default_setup(config)
                    -- end,
                },
                ensure_installed = {
                    "cppdbg",
                    -- "codelldb",
                },
            },
        },
    },

    keys = {
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
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
            Breakpoint = ui.Breakpoint,
            BreakpointCondition = ui.Question,
            BreakpointRejected = { ui.Exclamation, "DiagnosticError" },
            LogPoint = ui.Logging,
        }

        for name, sign in pairs(dap_icons) do
            sign = type(sign) == "table" and sign or { sign }
            vim.fn.sign_define("Dap" .. name, {
                text = sign[1],
                texthl = sign[2] or "DiagnosticInfo",
                linehl = sign[3],
                numhl = sign[3]
            })
        end
    end,
}
