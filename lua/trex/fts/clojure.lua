local iron = require("iron")
local nvim = vim.api
local utils = {}

utils.get_ns = function()
  -- TODO silent normal!
  nvim.nvim_feedkeys("mxggf w\"sy$`x", "", "")
  cmd_out = nvim.nvim_eval("@s")

  return cmd_out
end

utils.get_current_parens = function()
  -- TODO silent normal!
  nvim.nvim_feedkeys("mx%\"sy%`x", "", "")
  cmd_out = nvim.nvim_eval("@s")

  return cmd_out
end


local clojure = {}

clojure.require_ns = function()
  nvim.nvim_feedkeys("mx%\"sy%`x", "", "")
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

clojure.lein_import = function()
    data = "(import '" .. utils.get_current_parens() .. ")"
  iron.ll.send_to_repl("clojure", data)
  return
end

return clojure


    -- ('<leader>sr', 'require-file', lein_require_file),
    -- ('<leader>sR', 'require-with-ns', lein_require_with_ns),
    -- ('<leader>s.', 'prompt-require', lein_prompt_require),
    -- ('<leader>s/', 'prompt-require-as', lein_prompt_require_as),
    -- ('<leader>ss', 'send-block', lein_send),

    -- ('<leader>mf', 'midje-load-facts', midje_load_facts),
    -- ('<leader>ma', 'midje-autotest', midje_autotest),
