local M = {}

function M.setup()
  local nav = require("zellij-nav.utils").zellij_navigate
  local sys = vim.fn.system

  function M.up()
    nav("k", "up")
  end

  function M.down()
    nav("j", "down")
  end

  function M.left()
    nav("h", "left")
  end

  function M.right()
    nav("l", "right")
  end

  function M.lock()
    sys("zellij action switch-mode locked")
  end

  function M.unlock()
    sys("zellij action switch-mode normal")
  end

  function M.new_tab()
    sys("zellij action new-tab")
  end

  function M.new_pane(opts)
    M.unlock() -- Ensure we are in normal mode

    local fargs
    local l_zellij_args

    if type(opts) == "table" and opts.fargs then
      -- called as nvim command
      -- e.g. :ZellijNewPane down OR :ZellijNewPane --floating -- htop
      fargs = opts.fargs
    elseif type(opts) == "string" then
      -- called directly from lua
      -- e.g. new_pane("down")
      fargs = { opts }
    elseif type(opts) == "table" then
      -- called directly from lua with table of args
      -- e.g. new_pane("--floating","-- htop")
      fargs = opts
    else
      fargs = {}
    end

    if #fargs == 0 then
      -- No args given, spawn floating pane with default shell
      l_zellij_args = string.format("--close-on-exit --floating --cwd %s -- %s", vim.fn.getcwd(), vim.env.SHELL)
    elseif #fargs == 1 and fargs[1]:sub(1, 2) ~= "--"  then
      -- Check to see if a direction has been passed in. (e.g. :ZellijNewPane down)
      -- we make sure only one opt has been passed, and that the first characters of
      -- it are not '--' (i.e. not a flag for zellij)
      l_zellij_args = string.format("--close-on-exit --direction %s --cwd %s -- %s", fargs[1], vim.fn.getcwd(), vim.env.SHELL) 
    else
      -- Assuming that if the above is not true, this has been called with flags for
      -- zellij (e.g. :ZellijNewPane --close-on-exit --floating -- htop)
      l_zellij_args = table.concat(fargs, " ")
    end

    sys(
      "zellij action new-pane "
      .. l_zellij_args
    )
  end

  function M.close_pane()
    -- Save all open buffers in neovim and close zellij pane
    sys("zellij action switch-mode normal")
    sys("zellij action close-pane")
  end

  function M.toggle_floating_panes()
    sys("zellij action toggle-floating-panes")
  end
end
require("zellij-nav.commands").commands(M)
require("zellij-nav.mappings").mappings()

return M
