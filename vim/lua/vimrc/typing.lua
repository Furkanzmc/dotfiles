local M = {}

local TRUE = {
    ['1'] = true,
    ['t'] = true,
    ['T'] = true,
    ['true'] = true,
    ['TRUE'] = true,
    ['True'] = true,
    ['YES'] = true,
    ['Y'] = true,
    ['y'] = true
}
local FALSE = {
    ['0'] = false,
    ['f'] = false,
    ['F'] = false,
    ['false'] = false,
    ['FALSE'] = false,
    ['False'] = false,
    ['NO'] = false,
    ['no'] = false,
    ['n'] = false
}

function M.toboolean(str)
    assert(type(str) == "string", "str must be string")

    if TRUE[str] == true then
        return true;
    elseif FALSE[str] == false then
        return false;
    end

    return nil
end

return M
