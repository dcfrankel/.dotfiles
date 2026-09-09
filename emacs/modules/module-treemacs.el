;;; module-treemacs.el --- Treemacs directory tree sidebar -*- lexical-binding: t; -*-

;;; Commentary:
;; Treemacs plus its evil and nerd-icons integrations.

;;; Code:

;; Directory tree sidebar (VSCode/Zed-style)
(use-package treemacs
  :defer t
  :init
  ;; Daemon workflow: open the sidebar in each new emacsclient frame without stealing focus from the editing window
  (add-hook 'server-after-make-frame-hook #'treemacs-start-on-boot)
  :custom
  (treemacs-width 32)
  (treemacs-follow-after-init t)   ; keep tree in sync with active file
  ;; Disable python-based dir flattening (auto-enabled just because python3 is
  ;; on PATH) -- it spawns a python3 process on every directory expand/open,
  ;; which caused a noticeable delay opening new projects in daemon mode
  (treemacs-collapse-dirs 0)
  :config
  ;; No line numbers in the sidebar (global-display-line-numbers-mode is on)
  (add-hook 'treemacs-mode-hook (lambda () (display-line-numbers-mode -1)))
  ;; Root the tree at the current project and follow across projects
  (treemacs-project-follow-mode 1)
  ;; Daemon workflow: treemacs-follow-mode's idle timer can fire while a
  ;; frame's treemacs scope is transiently uninitialized (e.g. switching
  ;; between emacsclient frames), throwing `wrong-type-argument arrayp nil'
  ;; and spamming *Messages* on every subsequent tick. Skip that tick instead.
  (define-advice treemacs--follow (:around (fn &rest args) my/treemacs-follow-ignore-errors)
    (ignore-errors (apply fn args))))

;; Evil keybindings inside the treemacs buffer
;; (evil-collection has no treemacs module, so this is required and non-conflicting)
(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :config
  (treemacs-load-theme "nerd-icons"))

(provide 'module-treemacs)
;;; module-treemacs.el ends here
