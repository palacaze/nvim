local ok, ufo = pcall(require, "ufo")
if not ok then
    return
end

local u = require("util")

-- local function handler(virtText, lnum, endLnum, width, truncate)
--     local newVirtText = {}
--     local suffix = ('  %d '):format(endLnum - lnum)
--     local sufWidth = vim.fn.strdisplaywidth(suffix)
--     local targetWidth = width - sufWidth
--
--     local curWidth = 0
--     for _, chunk in ipairs(virtText) do
--         local chunkText = chunk[1]
--         local chunkWidth = vim.fn.strdisplaywidth(chunkText)
--         if targetWidth > curWidth + chunkWidth then
--             table.insert(newVirtText, chunk)
--         else
--             chunkText = truncate(chunkText, targetWidth - curWidth)
--             local hlGroup = chunk[2]
--             table.insert(newVirtText, {chunkText, hlGroup})
--             chunkWidth = vim.fn.strdisplaywidth(chunkText)
--             -- str width returned from truncate() may less than 2nd argument, need padding
--             if curWidth + chunkWidth < targetWidth then
--                 suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
--             end
--             break
--         end
--         curWidth = curWidth + chunkWidth
--     end
--
--     table.insert(newVirtText, {suffix, 'MoreMsg'})
--     return newVirtText
-- end

ufo.setup({
    provide_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
    -- fold_virt_text_handler = handler,
})

u.map_n('zR', ufo.openAllFolds, "Open All folds", { remap = true })
u.map_n('zM', ufo.closeAllFolds, "Close All folds", { remap = true })
u.map_n('À', function()
    local winid = ufo.peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
    end
end)

