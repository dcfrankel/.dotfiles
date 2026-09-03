;;; module-orderless.el --- Orderless completion style -*- lexical-binding: t; -*-

;;; Commentary:
;; Space-separated, order-agnostic component matching for minibuffer
;; completion (vertico/consult included).

;;; Code:

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(provide 'module-orderless)
;;; module-orderless.el ends here
