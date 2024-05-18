local ffi = require("ffi")

ffi.cdef([[
int compress(unsigned char *dest, unsigned long *destLen, const unsigned char *source, unsigned long sourceLen);
unsigned long compressBound(unsigned long sourceLen);
]])

local M = {
}

local zlib = ffi.load(ffi.os == "Windows" and "zlib1" or "z")

--deflate the text in argument using zlib
local function z_deflate(text)
    local in_size = #text
    local max_out_size = zlib.compressBound(in_size)
    local out_size = ffi.new("unsigned long[?]", 1, max_out_size)
    local inbuf = ffi.new("unsigned char[?]", in_size + 1)
    local outbuf = ffi.new("unsigned char[?]", max_out_size)
    ffi.copy(inbuf, text)
    local err = zlib.compress(outbuf, out_size, inbuf, in_size)
    if err ~= 0 or out_size[0] < 6 then
        return ""
    end
    -- compress() compresses the data in a single call, and always compresses to
    -- the zlib format, which is deflate data with a two-byte header and a four-byte
    -- check value trailer.
    return ffi.string(outbuf + 2, out_size[0] - 6)
end

-- deflate the content of the buffer
local function z_deflate_buf(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(bufnr), false)
    local content = table.concat(lines, "\n")
    return z_deflate(content)
end


local function bits_extract(v, from, width)
    local bit = require("bit")
    return bit.band(bit.rshift(v, from), bit.lshift(1, width) - 1)
end

-- PlantUML uses a base64-like url-encoding. Same algorithm, different table
local function make_puml_b64_set()
    local encoder = {}
    local puml_table = {
        [0]='0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G',
        'H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
        'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q',
        'r','s','t','u','v','w','x','y','z','-','_','='
    }
    for code, char in pairs(puml_table) do
        encoder[code] = char:byte()
    end
    return encoder
end

local PUML_BS64_SET = make_puml_b64_set()

-- base64 algorithm, taken from https://github.com/iskolbin/lbase64, MIT license
local function puml_b64encode(str)
    local encoder = PUML_BS64_SET
    local t, k, n = {}, 1, #str
    local lastn = n % 3
    for i = 1, n - lastn, 3 do
        local a, b, c = str:byte(i, i + 2)
        local v = a * 0x10000 + b * 0x100 + c
        local s = string.char(
            encoder[bits_extract(v,18,6)],
            encoder[bits_extract(v,12,6)],
            encoder[bits_extract(v,6,6)],
            encoder[bits_extract(v,0,6)])
        t[k] = s
        k = k + 1
    end
    if lastn == 2 then
        local a, b = str:byte(n - 1, n)
        local v = a * 0x10000 + b * 0x100
        t[k] = string.char(
            encoder[bits_extract(v,18,6)],
            encoder[bits_extract(v,12,6)],
            encoder[bits_extract(v,6,6)],
            encoder[64])
    elseif lastn == 1 then
        local v = str:byte(n) * 0x10000
        t[k] = string.char(
            encoder[bits_extract(v,18,6)],
            encoder[bits_extract(v,12,6)],
            encoder[64],
            encoder[64])
    end
    return table.concat(t)
end

-- Default options
local defaults = {
    format = "svg",
    viewer = "nomacs",
    tempdir = vim.fn.stdpath("cache"),
    -- Generator to use.
    -- This plugin can either use the standalone plantuml executable or defer
    -- generation to a plantuml server. Using a plantuml server to generate
    -- preview images is recommended, as it can process images concurrently
    -- and does not incur a delay to execute the program. The server can be a
    -- full plantuml-server instance, or minimalist 'plantuml -picoweb' one.
    -- Put "picoweb" if you want the plugin to start a background plantuml picoweb
    -- instance for you. If you started a picoweb instance manually, use "server"
    -- instead.
    -- Some servers allow the POST method to send the puml code instead of the
    -- more common GET method. POST allows bigger files to bet send over.
    -- The picoweb server only supports GET, as does the official plantuml.com.
    -- The plugin attempts POSTING first, and permanently downgrades to GET
    -- upon failure.
    generator = "server",  -- or "command", or "picoweb"
    -- Standalone executable to use to generate images. Easy but might be slower
    -- than servers.
    command = "plantuml",
    -- Plantuml server or picoweb to generate preview images. Also used to start
    -- a background picoweb instance if requested.
    server = "http://localhost:8000",
}

M.options = {}

local function make_preview_command(opts)
    -- Plantuml command
    if opts.generator == "command" then
        return string.format("%s -t%s -o '%s' '%s'", opts.command, opts.format, opts.out_dir, opts.file)
    end

    -- POSTING the file using curl
    if not M.http_post_unavailable then
        return string.format("curl -X POST -s -o '%s' -w '%%{http_code}' --data-binary @'%s' %s/%s",
                             opts.out_file, opts.file, opts.server, opts.format)
    end

    -- GET method
    local encoded = puml_b64encode(z_deflate_buf(opts.bufnr))
    return string.format("curl -s -o '%s' -w '%%{http_code}' '%s/%s/%s'",
                         opts.out_file, opts.server, opts.format, encoded)
end

-- Start up the image viewer
local function start_viewer(image_ok, opts)
    if image_ok then
        local viewer_id = vim.fn.jobstart({ opts.viewer, opts.out_file })
        vim.api.nvim_buf_set_var(opts.bufnr, "puml_viewer_job", viewer_id)
        print(string.format("Plantuml previewer started at %s", opts.out_file))
    end
end

-- Start a preview job
-- continuation is a function taking a bool (true on generation success) and opts
local function generate_preview(opts, continuation)
    local cmd = make_preview_command(opts)
    local out_chunks = { "" }
    -- generate the image immediately and open the result in an viewer
    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, output, _)
            for _, x in pairs(output) do
                out_chunks[#out_chunks+1] = x
            end
        end,
        on_exit = function(_, exit_code, _)
            local out_text = table.concat(out_chunks)
            vim.print(string.format("Got text: %s", out_text))
            -- signal failure
            if exit_code ~= 0 then
                vim.print(string.format("Plantuml preview generation failed with code: %d", exit_code))
                vim.print(string.format("Ouput: %s", out_text))
            end

            -- if POSTing was attempted and failed, deactivate POST
            local was_posting = M.http_post_unavailable == false and opts.generator ~= "command"
            if was_posting then
                local http_code = tonumber(out_text)
                if not http_code or (http_code and http_code ~= 200) then
                    vim.print("seems like POST did not work, deactivate it and try again")
                    M.http_post_unavailable = true
                end
            end

            -- Empty file and posting, try again
            local stat = vim.uv.fs_stat(opts.out_file)
            local image_ok = stat and stat.size > 0
            if not image_ok then
                if was_posting then
                    generate_preview(opts, continuation)
                    return
                end
            end

            if continuation then
                continuation(image_ok, opts)
            end
        end
    })
end

-- Stop plantuml previewing
function M.stop_preview(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if vim.b[bufnr].puml_preview_augroup then
        local grp = vim.b[bufnr].puml_preview_augroup
        vim.api.nvim_buf_del_var(bufnr, "puml_preview_augroup")
        vim.api.nvim_del_augroup_by_id(grp)
    end

    if vim.b[bufnr].puml_viewer_job then
       local viewer_job = vim.b[bufnr].puml_viewer_job
        vim.api.nvim_buf_del_var(bufnr, "puml_viewer_job")
        vim.fn.jobstop(viewer_job)
    end

    print("Plantuml previewer stopped")
end

-- Start previewing a plantuml file in an image viewer
function M.start_preview(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local file = vim.uv.fs_realpath(vim.fn.expand(vim.api.nvim_buf_get_name(bufnr), true))

    if not file then
        vim.print("Cannot preview unnamed buffer")
        return
    end

    local out_dir = vim.fs.normalize(M.options.tempdir .. "/puml_preview")
    local out_filename = vim.fn.fnamemodify(vim.fs.basename(file), ":t:r")
    local out_file = vim.fs.normalize(string.format("%s/%s.%s", out_dir, out_filename, M.options.format))
    local grp = vim.api.nvim_create_augroup("puml_preview_" .. bufnr, { clear = true })

    local opts = vim.tbl_deep_extend("force", M.options, {
        bufnr = bufnr,
        grp = grp,
        file = file,
        out_dir = out_dir,
        out_file = out_file,
    })

    -- Reset attempt to POST
    M.http_post_unavailable = false

    vim.fn.mkdir(out_dir, "p")
    vim.api.nvim_buf_set_var(bufnr, "puml_preview_augroup", grp)

    -- Regenerate preview whenever the buffer gets written
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = grp,
        buffer = bufnr,
        callback = function()
            generate_preview(opts)
        end,
    })

    -- Stop preview on buffer deletion
    vim.api.nvim_create_autocmd({ "BufDelete" }, {
        group = grp,
        buffer = bufnr,
        callback = function()
            M.stop_preview(bufnr)
        end,
    })

    -- Generate the image immediately and open the result in an viewer
    generate_preview(opts, start_viewer)
end

-- Toggle previsualization of a plantuml file in an image viewer
vim.api.nvim_create_user_command('PumlToggle', function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.b.puml_preview_augroup then
        M.stop_preview(bufnr)
    else
        M.start_preview(bufnr)
    end
end, {})

-- Setup the plugin
function M.setup(options)
    M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
