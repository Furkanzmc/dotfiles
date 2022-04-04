if vim.b.did_ftp == true then
    return
end

if vim.o.loadplugins and vim.g.vimrc_markdown_loaded_plugins == nil then
    vim.g.vimrc_markdown_loaded_plugins = true
end

vim.opt_local.spell = true
vim.opt_local.colorcolumn = "100"
vim.opt_local.foldmethod = "expr"
vim.opt_local.conceallevel = 2
vim.opt_local.textwidth = 99
vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
vim.opt_local.formatexpr = ""

if vim.fn.has("win32") == 1 then
    vim.opt_local.isfname:remove("[")
    vim.opt_local.isfname:remove("]")
end

if vim.fn.executable("qlmanage") == 1 then
    require("vimrc").map(
        "n",
        "<leader>p",
        ':call jobstart(["qlmanage", "-p", expand("<cfile>")], {"cwd": expand("%:h")})<CR>',
        { silent = true, buffer = bufnr }
    )
end

vim.api.nvim_buf_add_user_command(0, "MdWriteMermaid", function(opts)
    local lines = vim.api.nvim_buf_get_lines(
        vim.api.nvim_get_current_buf(),
        opts.line1 - 1,
        opts.line2,
        true
    )
    local tmp_file = vim.fn.tempname()
    local file_handle = io.open(tmp_file, "w")
    file_handle:write(table.concat(lines, "\n"))
    file_handle:close()
    -- TODO: Maybe there's a way to pipe the data to the executable.
    vim.fn.jobstart(
        { "mmdc", "-i", tmp_file, "-o", opts.args },
        { cwd = vim.fn.expand(vim.fn.expand("%:~:h")) }
    )
end, {
    nargs = 1,
    range = "%",
})

vim.api.nvim_buf_add_user_command(0, "MdZkInsertTOC", function(opts)
    vim.api.nvim_buf_set_lines(
        vim.api.nvim_get_current_buf(),
        opts.line1,
        opts.line2,
        true,
        require("zettelkasten").get_toc(opts.args)
    )
end, {
    nargs = 1,
    range = true,
})

vim.api.nvim_buf_add_user_command(0, "MdZkNoteBrowserContent", function(opts)
    local lines = require("zettelkasten").get_note_browser_content()
    lines = vim.tbl_map(function(item)
        local file_name = string.match(item, "^.*.md")
        return "- " .. string.gsub(item, "^.*.md", "[" .. file_name .. "](" .. file_name .. ")")
    end, lines)

    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), opts.line1, opts.line2, true, lines)
end, {
    range = true,
})

if vim.fn.executable("ctags") == 1 then
    vim.api.nvim_buf_add_user_command(
        0,
        "MdZkUpdateTags",
        "!ctags -R --langdef=markdowntags --languages=markdowntags --langmap=markdowntags:.md --kinddef-markdowntags=t,tag,tags --mline-regex-markdowntags='/(^|[[:space:]])\\#(\\w\\S*)/\\2/t/{mgroup=1}' .",
        {
            range = false,
        }
    )
end

if vim.fn.exists(":RunQML") ~= 2 then
    vim.cmd([[command -buffer -range RunQML :call qml#run()]])
end
