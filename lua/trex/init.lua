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


local nvim = vim.api -- luacheck: ignore
local trex = {
  ll = {},
  data = {
    history = {},
    cursor = 0
  },
  fts = require("trex.fts")
}

trex.ll.bufdata = function()
  local cb = nvim.nvim_get_current_buf()
  local ft = nvim.nvim_buf_get_option(cb, 'filetype')

  return ft, cb
end

trex.ll.hist_nav = function(mv)
  local cb = nvim.nvim_get_current_buf()
  local lines = nvim.nvim_buf_line_count(cb)

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

  nvim.nvim_buf_set_lines(cb, 0, lines, false, content)
end

trex.attach = function(ft)
  local session = math.random(10000, 99999)

  if ft == nil then
    ft = trex.ll.bufdata()
  end

  iron.core.focus_on(ft)

  nvim.nvim_command("belowright 8 new")
  nvim.nvim_command("setl wfh")
  nvim.nvim_command("setl nobuflisted buftype=nofile bufhidden=wipe ft=" .. ft)
  nvim.nvim_command("file trex://" .. ft  .. "/" .. session)
  nvim.nvim_command("nmap <buffer> q <Cmd>q!<CR>")

  nvim.nvim_command("nmap <buffer> <Left> <Cmd>TrexPrev<CR>")
  nvim.nvim_command("nmap <buffer> <Right> <Cmd>TrexNext<CR>")
  nvim.nvim_command("nmap <buffer> <Up> <Cmd>TrexReset<CR>")
  nvim.nvim_command("nmap <buffer> <S-Up> <Cmd>TrexClearHistory<CR>")
  nvim.nvim_command("nmap <buffer> <localleader><CR> <Cmd>TrexFlush<CR>")

  nvim.nvim_command("imap <buffer> <S-Left> <Cmd>TrexPrev<CR>")
  nvim.nvim_command("imap <buffer> <S-Right> <Cmd>TrexNext<CR>")
  nvim.nvim_command("imap <buffer> <S-Up> <Cmd>TrexReset<CR>")
  nvim.nvim_command("imap <buffer> <S-Up> <Cmd>TrexClearHistory<CR>")
  nvim.nvim_command("imap <buffer> <S-CR> <Cmd>TrexFlush<CR>")
end

trex.invoke = function()
  local ft = trex.ll.bufdata()

  iron.ll.ensure_repl_exists(ft)
  trex.attach(ft)
end

trex.flush = function()
  local ft, cb = trex.ll.bufdata()

  local lines = nvim.nvim_buf_line_count(cb)
  local buff = nvim.nvim_buf_get_lines(cb, 0, lines, false)

  if type(buff) == "string" then
    buff = {buff}
  end

  iron.ll.send_to_repl(ft, buff)

  if trex.data.cursor == 0 or not utils.all_equals(trex.data.history[trex.data.cursor], buff) then
    table.insert(trex.data.history, buff)
    trex.data.cursor = trex.data.cursor + 1
  end
  nvim.nvim_buf_set_lines(cb, 0, lines, false, {})
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
  local ft = trex.ll.bufdata()
  local bindings = trex.fts[ft]

  if bindings ~= nil then
    for mapping, command in pairs(bindings.mappings) do
      nvim.nvim_command("map <buffer> " .. mapping .. " <Cmd>lua require('trex').fts." .. ft .. "." .. command .. "()<CR>")
    end
  end
end

trex.debug = function()
  print(require("inspect")(trex.data))
end

return trex
