local M = {}

local function split_token(str, sep, sep2)
    local res = {}
    local mn_chars = {}

    local ww = {}
    string.gsub(str, sep, function(w)
        table.insert(res, w)
    end)
    for _, v in ipairs(res) do
        string.gsub(v, sep2, function(w)
            table.insert(ww, w)
        end)
    end

    if #res > 0 then
        for _, v in ipairs(ww) do
            table.insert(mn_chars, string.sub(v, 1, 1))
        end
    end

    if #res == 0 then
        return { mn = {}, word = str }
    end
    return { mn = mn_chars, word = res[1] }
end

local function get_mnemonics(token, sep, base)
    local result = split_token(token, sep, "[A-Z]+")
    local characters = result.mn
    local items = {}
    local mnemonic = ""
    if #characters > 0 then
        if characters[1] ~= string.sub(result.word, 1, 1) then
            mnemonic = string.lower(string.sub(result.word, 1, 1) .. string.join(characters, ""))
        else
            mnemonic = string.lower(string.join(characters, ""))
        end

        if mnemonic == base then
            table.insert(items, {
                word = result.word,
                dup = 0,
                empty = 0,
                kind = "mnemonic",
            })
        end
    end

    return items
end

function M.complete(lines, base)
    local words = {}

    for _, line in ipairs(lines) do
        for token in string.gmatch(line, "[^%s. ]+") do
            local result = split_token(token, ".*_[a-zA-Z]+", "[^_]+")
            local characters = result.mn
            if #characters > 0 then
                local mnemonic = string.join(characters, "")
                if mnemonic == base then
                    table.insert(words, {
                        word = result.word,
                        dup = 0,
                        empty = 0,
                        kind = "mnemonic",
                    })
                end
            end

            table.extend(words, get_mnemonics(token, "[a-zA-Z]+", base))
        end
    end

    return words
end

return M
