local M = {}

-- jdtls needs a dedicated workspace data dir per project; that's why it can't
-- be a static `lsp/jdtls.lua` + vim.lsp.enable() config like the other
-- servers, and instead gets its own FileType autocmd that computes this
-- per-buffer and calls jdtls's own start_or_attach().
local function workspace_dir(root_dir)
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  return vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name
end

function M.setup()
  local group = vim.api.nvim_create_augroup("UserConfig", { clear = false })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "java",
    callback = function(ev)
      local root_dir = vim.fs.root(ev.buf, { "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
      if not root_dir then
        return
      end

      require("jdtls").start_or_attach({
        cmd = { "jdtls", "-data", workspace_dir(root_dir) },
        root_dir = root_dir,
      })
    end,
  })
end

return M
