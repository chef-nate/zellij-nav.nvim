local M = {}

function M.mappings()
  local map = vim.api.nvim_set_keymap
  -- Check if zellij_navigator_no_default_mappings exists and is equal to 1
  if vim.g.zellij_nav_default_mappings == false then
    return
  else
    -- 'Alt Key' Shortcut Pane Keymaps
    map("n", "<A-h>", "<cmd>ZellijNavigateLeft<CR>", { silent = true })
    map("n", "<A-j>", "<cmd>ZellijNavigateDown<CR>", { silent = true })
    map("n", "<A-k>", "<cmd>ZellijNavigateUp<CR>", { silent = true })
    map("n", "<A-l>", "<cmd>ZellijNavigateRight<CR>", { silent = true })
    map("n", "<A-n>", "<cmd>ZellijNewPane<CR>", { silent = true })
    map("n", "<A-s>", "<cmd>ZellijNewPaneSplit<CR>", { silent = true })
    map("n", "<A-v>", "<cmd>ZellijNewPaneVSplit<CR>", { silent = true })
    map("n", "<A-f>", "<cmd>ZellijToggleFloatingPanes<CR>", { silent = true })
    map("n", "<A-x>", "<cmd>ZellijClosePane<CR>", { silent = true })
    map("n", "<A-t>", "<cmd>ZellijNewTab<CR>", { silent = true })

    -- 'Ctrl-p' Pane Keymaps
    map("n", "<C-p>", "", { silent = true, desc = "Zellij Panes" })
    map("n", "<C-p>h", "<cmd>ZellijNavigateLeft<cr>", { desc = "Focus Pane: Left" })
    map("n", "<C-p>j", "<cmd>ZellijNavigateDown<cr>", { desc = "Focus Pane: Down" })
    map("n", "<C-p>k", "<cmd>ZellijNavigateUp<cr>", { desc = "Focus Pane: Up" })
    map("n", "<C-p>l", "<cmd>ZellijNavigateRight<cr>", { desc = "Focus Pane: Right" })
    map("n", "<C-p>x", "<cmd>ZellijClosePane<cr>", { desc = "Close Active Pane" })
    map("n", "<C-p>d", "<cmd>ZellijNewPaneSplit<cr>", { desc = "New Pane: Down" })
    map("n", "<C-p>r", "<cmd>ZellijNewPaneVSplit<cr>", { desc = "New Pane: Right" })
    map("n", "<C-p>n", "<cmd>ZellijNewPaneSplit<cr>", { desc = "New Pane" })
    map("n", "<C-p>f", "<cmd>ZellijToggleFullscreen<cr>", { desc = "Toggle Fullscreen Pane" })
    map("n", "<C-p>c", "<cmd>ZellijRenamePane<cr>", { desc = "Rename Pane" })
  end
end

return M
