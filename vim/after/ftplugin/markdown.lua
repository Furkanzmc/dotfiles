if vim.b.did_ftp == true then
    return
end

local add_command = nil
if vim.api.nvim_create_user_command ~= nil then
    add_command = vim.api.nvim_buf_create_user_command
else
    add_command = vim.api.nvim_buf_add_user_command
end

if vim.o.loadplugins and vim.g.vimrc_markdown_loaded_plugins == nil then
    vim.g.vimrc_markdown_loaded_plugins = true
end

vim.opt_local.signcolumn = "no"
vim.opt_local.spell = true
vim.opt_local.foldmethod = "expr"
vim.opt_local.conceallevel = 2
vim.opt_local.textwidth = 100
vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
vim.opt_local.formatexpr = ""
vim.opt_local.winbar = ""

if vim.fn.has("win32") == 1 then
    vim.opt_local.isfname:remove("[")
    vim.opt_local.isfname:remove("]")
end

if vim.fn.executable("qlmanage") == 1 then
    vim.keymap.set(
        "n",
        "<leader>p",
        ':call jobstart(["qlmanage", "-p", expand("<cfile>")], {"cwd": expand("%:h")})<CR>',
        { silent = true, buffer = bufnr }
    )
end

vim.cmd(
    [[abbreviate <silent> <buffer> today@ <C-R>=strftime("%d.%m.%Y")<CR><C-R>=abbreviations#eat_char('\s')<CR>]]
)

add_command(0, "MdWriteMermaid", function(opts)
    local lines =
        vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), opts.line1 - 1, opts.line2, true)
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

add_command(0, "MdZkInsertTOC", function(opts)
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

add_command(0, "MdZkNoteBrowserContent", function(opts)
    local lines = require("zettelkasten").get_note_browser_content()
    lines = vim.tbl_map(function(item)
        local file_name = string.match(item, "^.*.md")
        return "- " .. string.gsub(item, "^.*.md", "[" .. file_name .. "](" .. file_name .. ")")
    end, lines)

    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), opts.line1, opts.line2, true, lines)
end, {
    range = true,
})

if vim.fn.exists(":ZkBrowse") == 2 then
    vim.defer_fn(function()
        -- Looks like the file_name is not resolved when a new file is created with a name.
        -- Deferring this call so that I can get to the resolved name.
        local file_name = string.gsub(vim.fn.expand("%:p"), "\\", "/")
        local notes_path = string.gsub(require("zettelkasten.config").get().notes_path, "\\", "/")
        if string.sub(file_name, 1, string.len(notes_path)) == notes_path then
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                buffer = 0,
                callback = function(_)
                    vim.fn.execute("Git add % | Git commit -m Update | FGit push")
                end,
            })
        end
    end, 10)
end

if vim.fn.executable("ctags") == 1 then
    add_command(
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
