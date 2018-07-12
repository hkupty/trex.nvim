# TREX - Terminal and Repl Extensions

Trex extends [iron.nvim](https://github.com/vigemus/iron.nvim) by adding sugar
coating to repl management.

Still highly experimental but you are more then welcome to use and open
issues/PRs.

## How it works

Trex exposes two commands that allow you to invoke repls: `TrexInvoke [{ft}]`
It optionally takes a filetype. If you don't supply an ft, it will infer based
on current buffers filetype.

It adds a minibuffer below the REPl, with the following properties:

```vim
" commands
TrexFlush "Flushes current scratch buffer to repl
TrexPrev "Cycles the history backward to the previous used command
TrexNext "Cycles the history forward to the next used command

" Mappings
<localleader>h <Cmd>TrexPrev<CR>
<localleader>l <Cmd>TrexNext<CR>
<localleader><CR> <Cmd>TrexFlush<CR>
```

## Under the hood

It relies on iron to get the correct repl and send chunks of data to it.
It manages the ui and command history and outsources the rest to iron.

## Why not part of iron?

I don't want to bloat users with features they won't want/need.
No cost involved in adding extensions to existing plugins thanks to lua.

> But VimL allows those as well.

True, but then you have function and command calls throught the code without
explicit dependencies.
By doing `local iron = require("iron")` an explicit dependency on external
resources exists, making it easier to spot.

> But this has no major advantage for the user.

Indeed, the user sees the same thing. But it becomes a major advantage to those
who maintain the plugin. For example, it allows a much easier to understand
codebase.
