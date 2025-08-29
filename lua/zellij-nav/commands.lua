local M = {}

function M.commands(nav)
  local ucmd = vim.api.nvim_create_user_command
  local acmd = vim.api.nvim_create_autocmd
  -- User commands
  ucmd("ZellijNavigateUp", function()
    nav.up()
  end, {})
  ucmd("ZellijNavigateDown", function()
    nav.down()
  end, {})
  ucmd("ZellijNavigateLeft", function()
    nav.left()
  end, {})
  ucmd("ZellijNavigateRight", function()
    nav.right()
  end, {})

  -- Lock and unlock zellij
  ucmd("ZellijLock", function()
    nav.lock()
  end, {})
  ucmd("ZellijUnlock", function()
    nav.unlock()
  end, {})

  ucmd("ZellijNewPane", function()
    nav.new_pane()
  end, {})
  ucmd("ZellijNewPaneSplit", function()
    nav.new_pane("down")
  end, {})
  ucmd("ZellijNewPaneVSplit", function()
    nav.new_pane("right")
  end, {})
  ucmd("ZellijClosePane", function()
    nav.close_pane()
  end, {})

  ucmd("ZellijNewTab", function()
    nav.new_tab()
  end, {})

  ucmd("ZellijNewPaneCMD", function(opts)
    -- opts.fargs contains the arguments as a table
    nav.new_pane_cmd(opts)
  end, {
    nargs = "*",  -- allow any number of arguments
})

  ucmd("ZellijToggleFloatingPane", function()
    nav.toggle_floating_pane()
  end, {})

  -- Autocommands
  acmd("VimEnter", {
    pattern = "*",
    command = "ZellijLock",
  })

  acmd("VimLeavePre", {
    pattern = "*",
    command = "ZellijUnlock",
  })

  -- Additional commands can be added as needed
end

return M
