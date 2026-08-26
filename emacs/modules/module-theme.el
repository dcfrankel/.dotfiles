;;; module-theme.el --- Theme and general UI chrome -*- lexical-binding: t; -*-

;;; Commentary:
;; Color theme, icon set, and the which-key popup.

;;; Code:

;; Theme
(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'mocha) ; Options are 'latte, 'frappe, 'macchiato, or 'mocha
  (catppuccin-reload))

;; Which key config
(use-package which-key
  :config (which-key-mode))

;; Use nerd font icons
(use-package nerd-icons)

(provide 'module-theme)
;;; module-theme.el ends here
