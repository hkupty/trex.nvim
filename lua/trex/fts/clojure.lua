local iron = require("iron")
local nvim = vim.api
local utils = {}

utils.get_ns = function()
  nvim.nvim_feedkeys("mxggf w\"syw`x", "x", "")
  cmd_out = nvim.nvim_eval("@s")

  return cmd_out
end

utils.get_current_parens = function()
  nvim.nvim_feedkeys("mx%\"sy%`x", "x", "")
  cmd_out = nvim.nvim_eval("@s")

  return cmd_out
end

utils.get_outer_parens = function()
  nvim.nvim_feedkeys("mx?^(\\"sya(`x'", "x", "")
  nvim.nvim_command("nohl")

  cmd_out = nvim.nvim_eval("@s")
  return cmd_out
end

utils.get_visual = function()
  nvim.nvim_feedkeys("gv\"sy", "x", "")

  cmd_out = nvim.nvim_eval("@s")
  return cmd_out
end


local clojure = {}

clojure.require_ns = function()
  nvim.nvim_feedkeys("mx%\"sy%`x", "x", "")
  cmd_out = nvim.nvim_eval("@s")

  data = "(require '" .. cmd_out .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.switch_ns = function()
  data = "(in-ns '" .. utils.get_ns() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.lein_require = function()
  data = "(require '" .. utils.get_current_parens() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.lein_require_current_file = function()
  data = "(require '" .. utils.get_ns() .. " :reload)"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.lein_import = function()
  data = "(import '" .. utils.get_current_parens() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.lein_send = function()
  data = utils.get_outer_parens()
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.lein_send_visual = function()
  data = utils.get_visual()
  iron.ll.send_to_repl("clojure", data)
  return
end

clojure.test_current_file = function()
  data = "(clojure.test/run-tests '" .. utils.get_ns() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

return clojure
