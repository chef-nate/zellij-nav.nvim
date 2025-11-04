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
      l_zellij_args =
        string.format("--close-on-exit --floating --cwd %s -- %s", vim.fn.shellescape(vim.fn.getcwd()), vim.env.SHELL)
    elseif #fargs == 1 and fargs[1]:sub(1, 2) ~= "--" then
      -- Check to see if a direction has been passed in. (e.g. :ZellijNewPane down)
      -- we make sure only one opt has been passed, and that the first characters of
      -- it are not '--' (i.e. not a flag for zellij)
      l_zellij_args = string.format(
        "--close-on-exit --direction %s --cwd %s -- %s",
        fargs[1],
        vim.fn.shellescape(vim.fn.getcwd()),
        vim.env.SHELL
      )
    else
      -- If the above is not true, then this has probably been called with flags for zellij
      -- (e.g. :ZellijNewPane --close-on-exit --floating -- htop)
      l_zellij_args = table.concat(fargs, " ")
    end

    sys("zellij action new-pane " .. l_zellij_args)
  end

  function M.close_pane()
    -- Save all open buffers in neovim and close zellij pane
    sys("zellij action switch-mode normal")
    sys("zellij action close-pane")
  end

  function M.toggle_floating_panes()
    sys("zellij action toggle-floating-panes")
  end

  function M.toggle_fullscreen()
    sys("zellij action toggle-fullscreen")
  end

  function M.rename_pane(opts)
    local arg
    if type(opts) == "table" then
      arg = opts.args ~= "" and opts.args or nil
    elseif type(opts) == "string" then
      arg = opts ~= "" and opts or nil
    else
      arg = nil
    end

    if not arg then
      arg = vim.fn.input("New Pane Name: ")
      if arg == "" then
        vim.notify("No pane name provided - rename cancelled.", vim.log.levels.WARN, { title = "ZellijRenamePane" })
        return
      end
    end

    sys(string.format("zellij action rename-pane -- %q", arg))
  end

  function M.resize_pane(opts)
    local arg
    if type(opts) == "table" then
      arg = opts.args ~= "" and opts.args or nil
    elseif type(opts) == "string" then
      arg = opts ~= "" and opts or nil
    else
      arg = nil
    end

    if arg then
      sys(string.format("zellij action resize increase %s", arg))
    else
      -- No direction provided. Take user input to resize until escape key is pressed
      -- If user cancells, want to restore prev layout. unfortunatly while 'zellij action dump-layout'
      -- exists, there is no way to restore the layout to this that i can find. So changes are tracked
      -- and reverted in the event of a cancel
      local reverse_changes = {}
      vim.api.nvim_echo(
        { { "-- Resize Mode (h/j/k/l to resize, Enter=commit, Esc=cancel) --", "WarningMsg" } },
        false,
        {}
      )

      while true do
        local key = vim.fn.getchar(-1, { number = false })

        if key == "h" then
          M.resize_pane("left")
          table.insert(reverse_changes, "right")
        elseif key == "j" then
          M.resize_pane("down")
          table.insert(reverse_changes, "up")
        elseif key == "k" then
          M.resize_pane("up")
          table.insert(reverse_changes, "down")
        elseif key == "l" then
          M.resize_pane("right")
          table.insert(reverse_changes, "left")
        elseif key == "\r" then
          break
        elseif key == "\x1b" then
          for i = #reverse_changes, 1, -1 do
            M.resize_pane(reverse_changes[i])
          end
          break
        else
          vim.notify(
            "Valid key not pressed [h/j/k/l] for resize. Please press 'Enter'/'Escape' to save/cancel resize mode",
            vim.log.levels.INFO,
            { title = "ZellijResizePane" }
          )
        end
      end
    end
  end

  function M.new_tab()
    sys("zellij action new-tab")
  end
end
require("zellij-nav.commands").commands(M)
require("zellij-nav.mappings").mappings()

return M
