local M = {}

M.config = {
	enabled = true,
	select_on_navigate = false,
	select_whole_column = false,
	filetypes = { "markdown" },
	keybindings = {
		n_move_forward = "<Tab>",
		n_move_backward = "<S-Tab>",
		i_move_forward = "<Tab>",
		i_move_backward = "<S-Tab>",
	},
}

local function parse_opts(select_on_navigate, select_whole_column)
	local r_select_on_navigate = M.config.select_on_navigate
	local r_select_whole_column = M.config.select_whole_column

	if select_on_navigate ~= nil then
		r_select_on_navigate = select_on_navigate
	end
	if select_whole_column ~= nil then
		r_select_whole_column = select_whole_column
	end

	return r_select_on_navigate, r_select_whole_column
end

local function is_in_table()
	return vim.fn.getline("."):match("^|.*|$")
end

local function get_table_columns(line)
	local fields = {}
	local col_start = nil
	local text_start = nil

	for start_idx, end_idx in line:gmatch("()|()") do
		if col_start then
			-- We have detected the end of the previous column
			local text_end = (text_start and end_idx - 2) or col_start -- If empty, text_end is same as col_start
			table.insert(fields, {
				text_start_pos = nil,
				text_end_pos = nil,
				col_content_start_pos = text_start,
				col_content_end_pos = text_end,
				col_start_pos = col_start,
				col_end_pos = end_idx - 2,
			})
		end

		col_start = start_idx
		text_start = end_idx
	end

	-- Handle the last column
	if col_start then
		local text_end = #line
		table.insert(fields, {
			text_start_pos = text_start or col_start,
			text_end_pos = text_end,
			col_start_pos = col_start,
			col_end_pos = #line,
		})
	end

	-- remove the last element which is not needed as it contain only the last pipe symbol location
	table.remove(fields)

	-- iterate over line one more time to capture text startn and end positions
	local text_start_pos = nil
	local idx = 1
	for start_idx, end_idx in line:gmatch("()%s*|%s*()") do
		if idx > 1 then
			fields[idx - 1].text_start_pos = text_start_pos
			fields[idx - 1].text_end_pos = start_idx
		end
		text_start_pos = end_idx
		idx = idx + 1
	end

	return fields
end

local function is_up_table(buf, current_line)
	if current_line <= 1 then
		return false
	end

	local line_above = vim.api.nvim_buf_get_lines(buf, current_line - 2, current_line - 1, false)[1]
	if line_above:match("^|.*|$") then
		return line_above
	end

	return false
end

local function is_down_table(buf, current_line_num)
	local total_lines = vim.api.nvim_buf_line_count(buf)

	if current_line_num == total_lines then
		return false
	end

	local line_below = vim.api.nvim_buf_get_lines(buf, current_line_num, current_line_num + 1, false)[1]
	if line_below:match("^|.*|$") then
		return line_below
	end

	return false
end

local function get_curr_col_num(columns, cursor_pos)
	for i, col in ipairs(columns) do
		if cursor_pos >= col.col_start_pos and cursor_pos <= col.col_end_pos then
			return i
		end
	end

	-- if we're not withing table boundaries then most probably we at the last pipe symbol (|)
	-- so return the last column in this case
	return #columns
end

local function navigate_col_by_num(line, column, select_on_nav, select_whole)
	select_on_nav, select_whole = parse_opts(select_on_nav, select_whole)
	local start_pos = column.text_start_pos
	local end_pos = column.text_end_pos
	local in_insert_mode = vim.fn.mode() == "i" and true

	if select_whole then
		start_pos = column.col_content_start_pos
		end_pos = column.col_content_end_pos
	end

	vim.cmd("normal ! <Esc>")

	if select_on_nav and not in_insert_mode then
		vim.fn.cursor(line, start_pos)
		vim.cmd("normal! v")
	end

	vim.fn.cursor(line, end_pos)
end

M.move_forward = function(select_on_nav, select_whole)
	local line = is_in_table()
	if not line then
		return
	end

	local columns = get_table_columns(line)

	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local curr_line_pos, curr_col_pos = unpack(vim.api.nvim_win_get_cursor(win))

	-- neovim returns position starting from 0 but in lua we need it to start from, so we need to shift one char
	curr_col_pos = curr_col_pos + 1

	local curr_col_num = get_curr_col_num(columns, curr_col_pos)

	local in_visual_mode = vim.fn.mode() == "v" and true
	local next_col_num = curr_col_num

	-- depending on the M.config.select_whole_column the end position for a jump could be end of a column
	-- or an end of a text
	local end_pos_for_compare = (M.config.select_whole_column and columns[curr_col_num].col_content_end_pos)
		or columns[curr_col_num].text_end_pos
	-- local at_end_pos = (curr_col_pos == columns[curr_col_num].text_end_pos and true) or false
	local at_end_pos = (curr_col_pos == end_pos_for_compare and true) or false

	-- if current mode is visual then assuming that select_on_navigate = true and current column
	-- is already selected and we need to jump to the next column.
	-- Also veryfing the current cursor position and if it at the end of the column text, then
	-- also making a jump to the next column
	if in_visual_mode or at_end_pos then
		next_col_num = curr_col_num + 1
	end

	if next_col_num <= #columns then
		navigate_col_by_num(curr_line_pos, columns[next_col_num], select_on_nav, select_whole)
		return
	end

	local line_below = is_down_table(buf, curr_line_pos)
	if not line_below then
		return
	end

	local below_columns = get_table_columns(line_below)
	vim.fn.cursor(curr_line_pos + 1, 1)
	navigate_col_by_num(curr_line_pos + 1, below_columns[1], select_on_nav, select_whole)
end

M.move_backward = function(select_on_nav, select_whole)
	local line = is_in_table()
	if not line then
		return
	end

	local columns = get_table_columns(line)

	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local curr_line_pos, curr_col_pos = unpack(vim.api.nvim_win_get_cursor(win))

	local curr_col_num = get_curr_col_num(columns, curr_col_pos)

	if curr_col_num > 1 then
		navigate_col_by_num(line, columns[curr_col_num - 1], select_on_nav, select_whole)
		return
	end

	local line_above = is_up_table(buf, curr_line_pos)
	if not line_above then
		-- if above is not table row then do nothing and stop futher execution
		return
	end

	local above_columns = get_table_columns(line_above)
	navigate_col_by_num(curr_line_pos - 1, above_columns[#above_columns], select_on_nav, select_whole)
end

-- Check buffer-local enabled state (if set), otherwise fall back to global state
local function is_enabled()
	return vim.b.mdtn_enabled ~= false and vim.g.mdtn_enabled
end

local function disable_for_current_buffer(bufnr)
	vim.keymap.del({ "n", "v" }, M.config.keybindings.n_move_forward, { buffer = bufnr })
	vim.keymap.del({ "n", "v" }, M.config.keybindings.n_move_backward, { buffer = bufnr })
	vim.keymap.del("i", M.config.keybindings.i_move_forward, { buffer = bufnr })
	vim.keymap.del("i", M.config.keybindings.i_move_backward, { buffer = bufnr })
end

local function setup_keybindings(bufnr)
	local ft = vim.bo.filetype

	disable_for_current_buffer(bufnr)

	if is_enabled() and vim.tbl_contains(M.config.filetypes, ft) then
		vim.keymap.set({ "n", "v" }, M.config.keybindings.n_move_forward, function()
			M.move_forward()
		end, { silent = true, buffer = bufnr })

		vim.keymap.set({ "n", "v" }, M.config.keybindings.n_move_backward, function()
			M.move_backward()
		end, { silent = true, buffer = bufnr })

		vim.keymap.set("i", M.config.keybindings.i_move_forward, function()
			M.move_forward()
		end, { silent = true, buffer = bufnr })

		vim.keymap.set("i", M.config.keybindings.i_move_backward, function()
			M.move_backward()
		end, { silent = true, buffer = bufnr })
	end
end

-- Function to apply settings to all buffers
local function reapply_keybinds_to_all_buffers()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			setup_keybindings(bufnr)
		end
	end
end

function M.setup_autocmds()
	-- registering the keybindings only for specified M.config.filetypes
	vim.api.nvim_create_augroup("MDTableNavAutocommands", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = "MDTableNavAutocommands",
		pattern = M.config.filetypes,
		callback = function()
			setup_keybindings(vim.api.nvim_get_current_buf())
		end,
	})
end

function M.register_usercmds()
	-- validate args for move_foward and move_backward
	local function parse_and_validate_args(opts)
		-- Parse the arguments
		local select = opts.args:match("select=(%a+)")
		local whole_col = opts.args:match("whole_col=(%a+)")

		-- validate that parameters are boolean (true/false strings)
		local function validate_bool(arg, name)
			if arg and arg ~= "true" and arg ~= "false" then
				vim.api.nvim_err_writeln(string.format("Invalid value for %s: %s (expected true or false)", name, arg))
				return false
			end
			return true
		end

		-- Validate the arguments
		if not validate_bool(select, "select") or not validate_bool(whole_col, "whole_col") then
			return nil, nil
		end

		select = select and select == "true" or false
		whole_col = whole_col and whole_col == "true" or false

		return select, whole_col
	end

	vim.api.nvim_create_user_command("MDTableNavMoveForward", function(opts)
		local select, whole_col = parse_and_validate_args(opts)

		M.move_forward(select, whole_col)
	end, {
		nargs = "?",
		complete = function(ArgLead, CmdLine, CursorPos)
			local completions = {
				"select=true",
				"select=false",
				"whole_col=true",
				"whole_col=false",
			}
			return vim.tbl_filter(function(val)
				return val:find(ArgLead, 1, true) == 1
			end, completions)
		end,
	})

	vim.api.nvim_create_user_command("MDTableNavMoveBackward", function(opts)
		local select, whole_col = parse_and_validate_args(opts)

		M.move_backward(select, whole_col)
	end, {
		nargs = "?",
		complete = function(ArgLead, CmdLine, CursorPos)
			local completions = {
				"select=true",
				"select=false",
				"whole_col=true",
				"whole_col=false",
			}
			return vim.tbl_filter(function(val)
				return val:find(ArgLead, 1, true) == 1
			end, completions)
		end,
	})

	vim.api.nvim_create_user_command("MDTableNavBufEnable", M.buf_enable, {})
	vim.api.nvim_create_user_command("MDTableNavBufDisable", M.buf_disable, {})
	vim.api.nvim_create_user_command("MDTableNavBufToggle", M.buf_toggle, {})

	vim.api.nvim_create_user_command("MDTableNavEnable", M.g_enable, {})
	vim.api.nvim_create_user_command("MDTableNavDisable", M.g_disable, {})
	vim.api.nvim_create_user_command("MDTableNavToggle", M.g_toggle, {})
end

function M.g_toggle()
	if is_enabled() then
		M.g_disable()
	else
		M.g_enable()
	end
end

function M.g_enable()
	vim.g.mdtn_enabled = true
	reapply_keybinds_to_all_buffers()
	vim.api.nvim_echo({ { "Markdown table navigation enabled for all buffers", "InfoMsg" } }, false, {})
end

function M.g_disable()
	vim.g.mdtn_enabled = false
	reapply_keybinds_to_all_buffers()
	vim.api.nvim_echo({ { "Markdown table navigation disabled for all buffers", "InfoMsg" } }, false, {})
end

function M.buf_toggle()
	if is_enabled() then
		M.buf_disable()
	else
		M.buf_enable()
	end
end

function M.buf_enable()
	if not vim.g.mdtn_enabled then
		vim.api.nvim_echo(
			{ { "Cannot enable for buffer: md table navigation disabled globally", "WarningMsg" } },
			false,
			{}
		)
		return
	end
	vim.b.mdtn_enabled = true
	setup_keybindings()
	vim.api.nvim_echo({ { "Markdown table navigation enabled for current buffer", "InfoMsg" } }, false, {})
end

function M.buf_disable()
	vim.b.mdtn_enabled = false
	setup_keybindings()
	vim.api.nvim_echo({ { "Markdown table navigation disabled for current buffer", "InfoMsg" } }, false, {})
end

-- Plugin setup function
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

	vim.g.mdtn_enabled = M.config.enabled

	M.setup_autocmds()
	M.register_usercmds()
end

return M
