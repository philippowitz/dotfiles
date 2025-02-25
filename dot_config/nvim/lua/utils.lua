local M = {}
---Force a specific language for ltex-ls
---@param lang string
M.set_ltex_lang = function(lang)
  local clients = vim.lsp.get_clients { buffer = 0 }

  for _, client in ipairs(clients) do
    if client.name == 'ltex' then
      client.config.settings.ltex.language = lang
      vim.lsp.buf_notify(0, 'workspace/didChangeConfiguration', { settings = client.config.settings })
      return
    end
  end
end

return M
