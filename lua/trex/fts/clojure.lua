local iron = require("iron")
local nvim = vim.api
local utils = {}

utils.get_ns = function()
  nvim.nvim_feedkeys("mxggf w\"syw`x", "x", "")
  cmd_out = nvim.nvim_call_function("getreg",{"s"})

  return cmd_out
end

utils.get_current_parens = function()
  nvim.nvim_feedkeys("mx%\"sy%`x", "x", "")
  cmd_out = nvim.nvim_call_function("getreg",{"s"})

  return cmd_out
end

utils.get_outer_parens = function()
  nvim.nvim_feedkeys("mx?^(\\"sya(`x'", "x", "")
  nvim.nvim_command("nohl")

  cmd_out = nvim.nvim_call_function("getreg",{"s"})
  return cmd_out
end

utils.get_visual = function()
  nvim.nvim_feedkeys("gv\"sy", "x", "")

  cmd_out = nvim.nvim_call_function("getreg",{"s"})
  return cmd_out
end

clojure = {
  fn = {}
}

clojure.fn.require_ns = function()
  nvim.nvim_feedkeys("mx%\"sy%`x", "x", "")
  cmd_out = nvim.nvim_call_function("getreg",{"s"})

  data = "(require '" .. cmd_out .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.switch_ns = function()
  data = "(in-ns '" .. utils.get_ns() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.switch_to_user_ns = function()
  data = "(in-ns 'user)"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.lein_require = function()
  data = "(require '" .. utils.get_current_parens() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.lein_require_current_file = function()
  data = "(require '" .. utils.get_ns() .. " :reload)"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.lein_import = function()
  data = "(import '" .. utils.get_current_parens() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.lein_send = function()
  data = utils.get_outer_parens()
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.lein_send_visual = function()
  data = utils.get_visual()
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.fn.test_current_file = function()
  data = "(clojure.fn.test/run-tests '" .. utils.get_ns() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.mappings = {
  ["<localleader>t"] = 'fn.test_current_file',
  ["<localleader>sv"] = 'fn.lein_send_visual',
  ["<localleader>s"] = 'fn.lein_send',
  ["<localleader>i"] = 'fn.lein_import',
  ["<localleader>R"] = 'fn.lein_require_current_file',
  ["<localleader>r"] = 'fn.lein_require',
  ["<localleader>n"] = 'fn.switch_to_user_ns',
  ["<localleader>i"] = 'fn.switch_ns',
  ["<localleader>rs"] = 'fn.require_ns'
}

return clojure
