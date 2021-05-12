-- luacheck: globals vim
local iron = require("iron")

local utils = {}

utils.all_equals = function(a, b)
  if #a ~= #b then
    return false
  end

  for i, v in ipairs(a) do
    if v ~= b[i] then
      return false
    end
  end

  return true
end


local trex = {
  ll = {},
  data = {
    history = {},
    cursor = 0
  },
  fts = require("trex.fts")
}

trex.ll.hist_nav = function(mv)
  local cb = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_line_count(cb)

  if mv == 0 then
    trex.data.cursor = 0
  elseif mv == 1 then
      if trex.data.cursor >= #trex.data.history then
        trex.data.cursor = 0
      else
        trex.data.cursor = trex.data.cursor + 1
    end
  elseif mv == -1 then
      if trex.data.cursor < 1 then
        trex.data.cursor = #trex.data.history
      else
        trex.data.cursor = trex.data.cursor - 1
      end
  end

  local content = trex.data.history[trex.data.cursor] or {}

  vim.api.nvim_buf_set_lines(cb, 0, lines, false, content)
end

trex.attach = function(ft)
  local session = math.random(10000, 99999)

  if ft == nil then
    ft = vim.bo['filetype']
  end

  iron.core.focus_on(ft)

  vim.api.nvim_command("belowright 8 new")
  vim.api.nvim_command("setl wfh")
  vim.api.nvim_command("setl nobuflisted buftype=nofile bufhidden=wipe ft=" .. ft)
  vim.api.nvim_command("file trex://" .. ft  .. "/" .. session)
  vim.api.nvim_command("nmap <buffer> q <Cmd>q!<CR>")

  vim.api.nvim_command("nmap <buffer> <Left> <Cmd>TrexPrev<CR>")
  vim.api.nvim_command("nmap <buffer> <Right> <Cmd>TrexNext<CR>")
  vim.api.nvim_command("nmap <buffer> <Up> <Cmd>TrexReset<CR>")
  vim.api.nvim_command("nmap <buffer> <S-Up> <Cmd>TrexClearHistory<CR>")
  vim.api.nvim_command("nmap <buffer> <localleader><CR> <Cmd>TrexFlush<CR>")

  vim.api.nvim_command("imap <buffer> <S-Left> <Cmd>TrexPrev<CR>")
  vim.api.nvim_command("imap <buffer> <S-Right> <Cmd>TrexNext<CR>")
  vim.api.nvim_command("imap <buffer> <S-Up> <Cmd>TrexReset<CR>")
  vim.api.nvim_command("imap <buffer> <S-Up> <Cmd>TrexClearHistory<CR>")
  vim.api.nvim_command("imap <buffer> <S-CR> <Cmd>TrexFlush<CR>")
end

trex.invoke = function()
  local ft = vim.bo['filetype']

  iron.ll.ensure_repl_exists(ft)
  trex.attach(ft)
end

trex.flush = function()
  local ft = vim.bo['filetype']
  local cb = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_line_count(cb)
  local buff = vim.api.nvim_buf_get_lines(cb, 0, lines, false)

  if type(buff) == "string" then
    buff = {buff}
  end

  iron.ll.send_to_repl(ft, buff)

  if trex.data.cursor == 0 or not utils.all_equals(trex.data.history[trex.data.cursor], buff) then
    table.insert(trex.data.history, buff)
    trex.data.cursor = trex.data.cursor + 1
  end
  vim.api.nvim_buf_set_lines(cb, 0, lines, false, {})
end

trex.clear_history = function()
  trex.data.history = {}
  trex.data.cursor = 0
end

trex.previous = function()
  return trex.ll.hist_nav(-1)
end

trex.next = function()
  return trex.ll.hist_nav(1)
end

trex.reset = function()
  return trex.ll.hist_nav(0)
end

trex.map_bindings = function()
  local ft = vim.bo['filetype']
  local bindings = trex.fts[ft]

  if bindings ~= nil then
    for mapping, command in pairs(bindings.mappings) do
      vim.api.nvim_command(
      "map <buffer> " ..
      mapping ..
      " <Cmd>lua require('trex').fts." ..
      ft ..
      "." ..
      command ..
      "()<CR>")
    end
  end
end

trex.debug = function()
  print(require("inspect")(trex.data))
end

return trex
