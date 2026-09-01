;;; module-git-link.el --- Git permalink generation -*- lexical-binding: t; -*-

;;; Code:

(use-package git-link
  :after evil
  :custom
  (git-link-open-in-browser nil)
  (git-link-use-commit t)
  :config
  (add-to-list 'git-link-remote-alist
               '("code\\.cargurus\\.com" git-link-github))
  (add-to-list 'git-link-commit-remote-alist
               '("code\\.cargurus\\.com" git-link-commit-github))
  (evil-define-key '(normal visual) 'global (kbd "<leader>gl") #'git-link)
  (evil-define-key '(normal visual) 'global (kbd "<leader>gc") #'git-link-commit)
  (evil-define-key '(normal visual) 'global (kbd "<leader>gh") #'git-link-homepage))

(provide 'module-git-link)
;;; module-git-link.el ends here
