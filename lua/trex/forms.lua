-- luacheck: globals vim
-- Copied from acid

local forms = {}

forms.get_ns_form_boundaries = function()
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, {1, 0})

  local ns = vim.fn.searchpos("(ns", "c")

  if #ns == 0 then
    return
  end

  local to_filter = "nr"
  local from_filter = "nbcr"

  local to = vim.fn.searchpairpos("(", "", ")", to_filter)
  local from = vim.fn.searchpairpos("(", "", ")", from_filter)

  -- FIXME solve boundaries for if cursor at `)`
  to[2] = to[2] + 1

  vim.api.nvim_win_set_cursor(0, cur_pos)

  return {
    from = from,
    to = to,
    bufnr = vim.api.nvim_get_current_buf()
  }
end


forms.get_form_boundaries = function(top)
  local to_filter, from_filter
  local curpos = vim.fn.getcurpos()
  local last_parens = vim.fn.strcharpart(vim.fn.getline(curpos[2]), curpos[3] - 1, 1)

  if last_parens == ")" then
    to_filter = "nc"
    from_filter = "nb"
  else
    to_filter = "n"
    from_filter = "nbc"
  end

  if top then
    to_filter = to_filter .. "r"
    from_filter = from_filter .. "r"
  end

  local to = vim.fn.searchpairpos("(", "", ")", to_filter)
  local from = vim.fn.searchpairpos("(", "", ")", from_filter)

  -- FIXME solve boundaries for if cursor at `)`
  to[2] = to[2] + 1

  return {
    from = from,
    to = to,
    bufnr = curpos[1]
  }
end

forms.extract = function(coordinates)
  local lines = vim.api.nvim_buf_get_lines(coordinates.bufnr, coordinates.from[1] - 1, coordinates.to[1], 0)

  if coordinates.from[2] ~= 0 then
    lines[1] = string.sub(lines[1], coordinates.from[2])
  end

  if coordinates.to[2] ~= 0 then
    if coordinates.from[1] == coordinates.to[1] then
      lines[#lines] = string.sub(lines[#lines], 1, coordinates.to[2] - coordinates.from[2])
    else
      lines[#lines] = string.sub(lines[#lines], 1, coordinates.to[2])
    end
  end

  return lines, coordinates
end

forms.form_under_cursor = function(top)
  local coordinates = forms.get_form_boundaries(top)

  return forms.extract(coordinates)
end



forms.symbol_under_cursor = function()
  local isk = vim.o.iskeyword
  vim.o.iskeyword = isk .. ",#,%,&,'"
  local cw = vim.fn.expand("<cword>")
  local from = vim.fn.searchpos(cw, "nc")
  local to = vim.fn.searchpos(cw, "nce")
  vim.o.iskeyword = isk

  return cw, {
    from = from,
    to = to,
    bufnr = vim.api.nvim_get_current_buf()
  }
end

return forms
