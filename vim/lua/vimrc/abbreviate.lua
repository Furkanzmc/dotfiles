local vim = vim

return function(lhs, rhs, opts)
	local opts_str = {}
	if opts == nil then
		opts = { buffer = false, expr = false }
	end

	for key, value in pairs(opts) do
		if value == true then
			table.insert(opts_str, "<" .. key .. ">")
		end
	end

	vim.cmd("abbreviate " .. table.concat(opts_str) .. lhs .. " " .. rhs)
end
