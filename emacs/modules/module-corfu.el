;;; module-corfu.el --- In-buffer completion -*- lexical-binding: t; -*-

;;; Commentary:
;; At-point completion popup.

;;; Code:

;; At-point completion within buffers
(use-package corfu
  :custom
  (corfu-auto t) ; Auto completions
  (corfu-on-exact-match 'insert) ; Complete if there is only a single candidate
  (corfu-quit-no-match t)

  :init (global-corfu-mode 1)

  :config
  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1)) ; Show documentation next to completions

(provide 'module-corfu)
;;; module-corfu.el ends here
