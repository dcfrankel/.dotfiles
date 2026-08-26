;;; module-vertico.el --- Minibuffer completion UI -*- lexical-binding: t; -*-

;;; Commentary:
;; Vertical completion UI in the minibuffer.

;;; Code:

(use-package vertico
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode 1)
  :bind (:map vertico-map
              ("TAB"       . vertico-next)
              ("<tab>"     . vertico-next)
              ("S-TAB"     . vertico-previous)
              ("<backtab>" . vertico-previous)))

(provide 'module-vertico)
;;; module-vertico.el ends here
