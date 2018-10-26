local iron = require("iron")
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

  return cb, ft
end

trex.ll.hist_nav = function(mv)
  local cb = nvim.nvim_get_current_buf()
  local lines = nvim.nvim_buf_line_count(cb)
  local op = nil

  if mv == 0 then
    op = function()
      return true
    end

  elseif mv == 1 then
    op = function()
      return trex.data.cursor >= #trex.data.history
    end

  elseif mv == -1 then
    op = function()
      return trex.data.cursor <= 1
    end

  end

  if op() then
    trex.data.cursor = 0
  else
    trex.data.cursor = trex.data.cursor + mv
  end

  local content = trex.data.history[trex.data.cursor] or {}

  nvim.nvim_buf_set_lines(cb, 0, lines, false, content)
end


trex.attach = function(ft)

  if ft == nil then
    local _
    _, ft = trex.ll.bufdata()
  end

  iron.core.focus_on(ft)

  nvim.nvim_command("belowright 20 new")
  nvim.nvim_command("setl nobuflisted buftype=nofile bufhidden=wipe ft=" .. ft)
  nvim.nvim_command("map <buffer> <localleader>h <Cmd>TrexNext<CR>")
  nvim.nvim_command("map <buffer> <localleader>l <Cmd>TrexPrev<CR>")
  nvim.nvim_command("map <buffer> <localleader>r <Cmd>TrexReset<CR>")
  nvim.nvim_command("map <buffer> <localleader>! <Cmd>TrexClearHistory<CR>")
  nvim.nvim_command("map <buffer> <localleader><CR> <Cmd>TrexFlush<CR>")
end

trex.invoke = function()
  local _, ft = trex.ll.bufdata()

  iron.ll.ensure_repl_exists(ft)
  trex.attach(ft)
end

trex.flush = function()
  local cb, ft = trex.ll.bufdata()

  local lines = nvim.nvim_buf_line_count(cb)
  local buff = nvim.nvim_buf_get_lines(cb, 0, lines, false)

  if type(buff) == "string" then
    buff = {buff}
  end

  iron.ll.send_to_repl(ft, buff)

  if trex.data.cursor == 0 then
    table.insert(trex.data.history, buff)
    trex.data.cursor = 0
  end

  nvim.nvim_buf_set_lines(cb, 0, lines, false, {})
end

trex.clear_history = function()
  local _, ft = trex.ll.bufdata()

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

trex.debug = function()
  print(require("inspect")(trex.data))
end

return trex
