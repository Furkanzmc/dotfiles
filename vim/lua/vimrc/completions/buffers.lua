local s_defaults = {
    keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%([\-]\w*\)*\)]],
    get_bufnrs = function()
        return table.uniq(vim.fn.tabpagebuflist(vim.fn.tabpagenr()))
    end,
}
local buffer = {}

function buffer.new(bufnr, pattern)
    local self = setmetatable({}, { __index = buffer })
    self.bufnr = bufnr
    self.regexes = {}
    self.pattern = pattern
    self.timer = nil
    self.words = {}
    self.processing = false
    return self
end

function buffer.close(self)
    if self.timer then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
    end
    self.words = {}
end

function buffer.index(self)
    self.processing = true
    local index = 1
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    self.timer = vim.loop.new_timer()
    self.timer:start(
        0,
        200,
        vim.schedule_wrap(function()
            local chunk = math.min(index + 1000, #lines)
            vim.api.nvim_buf_call(self.bufnr, function()
                for i = index, chunk do
                    self:index_line(i, lines[i] or "")
                end
            end)
            index = chunk + 1

            if chunk >= #lines then
                if self.timer then
                    self.timer:stop()
                    self.timer:close()
                    self.timer = nil
                end
                self.processing = false
            end
        end)
    )
end

function buffer.watch(self)
    vim.api.nvim_buf_attach(self.bufnr, false, {
        on_lines = vim.schedule_wrap(
            function(_, _, _, firstline, old_lastline, new_lastline, _, _, _)
                if not vim.api.nvim_buf_is_valid(self.bufnr) then
                    self:close()
                    return true
                end

                for i = old_lastline, new_lastline - 1 do
                    table.insert(self.words, i + 1, {})
                end

                for _ = new_lastline, old_lastline - 1 do
                    table.remove(self.words, new_lastline + 1)
                end

                local lines = vim.api.nvim_buf_get_lines(self.bufnr, firstline, new_lastline, false)
                vim.api.nvim_buf_call(self.bufnr, function()
                    for i, line in ipairs(lines) do
                        if line then
                            self:index_line(firstline + i, line or "")
                        end
                    end
                end)
            end
        ),
    })
end

function buffer.index_line(self, i, line)
    local words = {}
    local buf = line

    while true do
        local s, e = self:matchstrpos(buf)
        if s then
            local word = string.sub(buf, s, e - 1)
            if #word > 1 then
                table.insert(words, word)
            end
        end
        local new_buffer = string.sub(buf, e and e + 1 or 2)
        if buf == new_buffer then
            break
        end
        buf = new_buffer
    end

    self.words[i] = words
end

function buffer.get_words(self)
    local words = {}
    for _, line in ipairs(self.words) do
        for _, w in ipairs(line) do
            table.insert(words, w)
        end
    end

    return words
end

function buffer.matchstrpos(self, text)
    local s, e = self:regex(self.pattern):match_str(text)
    if s == nil then
        return nil, nil
    end

    return s + 1, e + 1
end

function buffer.regex(self, pattern)
    self.regexes[pattern] = self.regexes[pattern] or vim.regex(pattern)
    return self.regexes[pattern]
end

local source = {}

source.new = function()
    local self = setmetatable({}, { __index = source })
    self.buffers = {}
    return self
end

source.complete = function(self, params, callback)
    local processing = false
    for _, buf in ipairs(self:_get_buffers(s_defaults.get_bufnrs(), s_defaults.keyword_pattern)) do
        processing = processing or buf.processing
    end

    vim.defer_fn(
        vim.schedule_wrap(function()
            local input = params.word_to_complete
            local items = {}
            local words = {}
            for _, buf in ipairs(self:_get_buffers(s_defaults.get_bufnrs(), s_defaults.keyword_pattern)) do
                for _, word in ipairs(buf:get_words()) do
                    if not words[word] and input ~= word then
                        words[word] = true
                        table.insert(items, {
                            label = word,
                            kind = vim.lsp.protocol.CompletionItemKind["Text"],
                            dup = 0,
                        })
                    end
                end
            end

            callback({ items = items, isIncomplete = processing })
        end),
        processing and 100 or 0
    )
end

source._get_buffers = function(self, bufnrs, keyword_pattern)
    local buffers = {}
    for _, bufnr in ipairs(bufnrs) do
        if not self.buffers[bufnr] then
            local new_buf = buffer.new(bufnr, keyword_pattern)
            new_buf:index()
            new_buf:watch()
            self.buffers[bufnr] = new_buf
        end
        table.insert(buffers, self.buffers[bufnr])
    end

    return buffers
end

return source
