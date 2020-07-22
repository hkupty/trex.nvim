local iron = require("iron")
local forms = require("trex.forms")
local nvim = vim.api
local utils = {}

utils.get_ns = function()
  local lines = table.concat(
    forms.extract(forms.get_ns_form_boundaries()),
    " ")
  -- TODO make it secure against
  --    ^:metadata
  --    "docstring"
  local match = [[ns ([^()':" ]+)]]

  return lines:match(match)
end

utils.get_current_parens = function()
  return table.concat(forms.form_under_cursor(), " ")
end

utils.get_outer_parens = function()
  return table.concat(forms.form_under_cursor(true), " ")
end

utils.get_visual = function()
  nvim.nvim_feedkeys("gv\"sy", "x", "")

  cmd_out = nvim.nvim_call_function("getreg",{"s"})
  return cmd_out
end

clojure = {
get_ns = utils.get_ns,
  fn = {}
}

clojure.fn.require_ns = function()
  data = "(require '[" .. utils.get_ns() .. "])"
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
  data = "(require '[" .. utils.get_ns() .. " :reload])"
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
  data = "(clojure.test/run-tests '" .. utils.get_ns() .. ")"
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
