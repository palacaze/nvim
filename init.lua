-- neovim configuration file
-- Maintainer: Pierre-Antoine Lacaze

local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then
    impatient.enable_profile()
end

require("settings")
require("plugins")
require("commands")
require("mappings")
require("ui")
