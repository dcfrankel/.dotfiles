;;; module-diff-hl.el --- VCS change indicators -*- lexical-binding: t; -*-

;;; Commentary:
;; Git gutter / VCS change indicators in the fringe.

;;; Code:

(use-package diff-hl
  :hook (dired-mode . diff-hl-dired-mode)
  :init
  (global-diff-hl-mode 1)
  :config
  ;; Update indicators live as you edit, not just on save
  (diff-hl-flydiff-mode 1)
  ;; Terminals have no fringe — fall back to margin indicators
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1)))

(provide 'module-diff-hl)
;;; module-diff-hl.el ends here
