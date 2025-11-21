local M = {}

local function normalize_arg(opts)
  -- normalize command vs lua call arguments (single/no arg)

  -- command call
  if type(opts) == "table" then
    -- distinguish no string vs empty string
    if opts.args == "" then
      return nil
    else
      return opts.args
    end
  end

  -- lua call
  return opts
end

local function normalize_fargs(opts)
  -- normalize command vs lua call arguments (multiple/no arg)

  -- command call
  if type(opts) == "table" and opts.fargs then
    return opts.fargs

  -- lua call (multiple args)
  elseif type(opts) == "table" then
    return opts

  -- lua call (single arg)
  elseif opts ~= nil then
    return { opts }
  end

  -- no args
  return {}
end

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

    local fargs = normalize_fargs(opts)

    local cwd = vim.fn.shellescape(vim.fn.getcwd())
    local shell = vim.env.SHELL

    -- if no fargs provided spawn floating pane with default shell
    if #fargs == 0 then
      sys(string.format("zellij action new-pane --close-on-exit --floating --cwd %s -- %s", cwd, shell))
      return
    elseif #fargs == 1 then
      -- check if direction provided
      local valid_dir = { left = true, right = true, up = true, down = true }

      if valid_dir[fargs[1]] then
        -- direction specified
        sys(string.format("zellij action new-pane --close-on-exit --direction %s --cwd %s -- %s", fargs[1], cwd, shell))
        return
      end
    end

    -- if havn't returned by now then opts provided
    sys(string.format("zellij action new-pane %s", table.concat(fargs, " ")))
  end

  function M.close_pane()
    -- Save all open buffers in neovim and close zellij pane
    sys("zellij action switch-mode normal")
    sys("zellij action close-pane")
  end

  function M.toggle_floating_panes()
    sys("zellij action toggle-floating-panes")
  end

  function M.toggle_pane_fullscreen()
    sys("zellij action toggle-fullscreen")
  end

  function M.rename_pane(opts)
    local arg = normalize_arg(opts)

    local function apply_rename(name)
      -- user cancel
      if name == nil then
        return
      end

      sys(string.format("zellij action rename-pane -- %q", name))
    end

    if arg ~= nil then
      apply_rename(arg)
      return
    end

    vim.ui.input({ prompt = "New Pane Name: " }, apply_rename)
  end

  function M.resize_pane(opts)
    local arg = normalize_arg(opts)

    if arg then
      sys(string.format("zellij action resize increase %s", arg))
      return
    end
    -- interactive resize mode
    -- track changes so that if user cancels, original layout can be restored
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
        -- cancelled so reverse changes
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

  function M.move_pane(opts)
    local arg = normalize_arg(opts)

    -- only accept valid inputs
    local valid = { left = true, right = true, up = true, down = true }

    if not valid[arg] then
      vim.notify(
        string.format("Invalid argument: %s. Must be 'left' or 'right'.", tostring(arg)),
        vim.log.levels.ERROR,
        { title = "ZelliijMovePane" }
      )
      return
    end

    sys(string.format("zellij action move-pane %s", arg))
  end

  function M.new_tab()
    sys("zellij action new-tab")
  end

  function M.close_tab()
    sys("zellij action close-tab")
  end

  function M.rename_tab(opts)
    local arg = normalize_arg(opts)

    local function apply_rename(name)
      -- user cancel
      if name == nil then
        return
      end

      sys(string.format("zellij action rename-tab -- %q", name))
    end

    if arg ~= nil then
      apply_rename(arg)
      return
    end

    vim.ui.input({ prompt = "New Tab Name: " }, apply_rename)
  end

  function M.move_tab(opts)
    local arg = normalize_arg(opts)

    -- only accept valid inputs
    local valid = { left = true, right = true }

    if not valid[arg] then
      vim.notify(
        string.format("Invalid argument: %s. Must be 'left' or 'right'.", tostring(arg)),
        vim.log.levels.ERROR,
        { title = "ZelliijMoveTab" }
      )
      return
    end

    sys(string.format("zellij action move-tab %s", arg))
  end
end
require("zellij-nav.commands").commands(M)
require("zellij-nav.mappings").mappings()

return M
