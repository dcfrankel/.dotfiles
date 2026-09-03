;;; module-theme.el --- Theme and general UI chrome -*- lexical-binding: t; -*-

;;; Commentary:
;; Color theme, icon set, and the which-key popup.

;;; Code:

;; Theme
(use-package catppuccin-theme
  :demand t
  :custom
  (catppuccin-flavor 'mocha) ; Options are 'latte, 'frappe, 'macchiato, or 'mocha
  :config
  (catppuccin-reload))

;; Which key config
(use-package which-key
  :hook (after-init . which-key-mode))

;; Use nerd font icons
(use-package nerd-icons
  :demand t)

(provide 'module-theme)
;;; module-theme.el ends here
