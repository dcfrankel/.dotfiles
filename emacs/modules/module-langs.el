;;; module-langs.el --- Language mode configurations -*- lexical-binding: t; -*-

;;; Commentary:
;; Simple major-mode/file-extension associations for languages without
;; further configuration.

;;; Code:

;; Yaml mode config
(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

;; Go mode config
(use-package go-mode
  :mode ("\\.go\\'" . go-mode))

;; Terraform mode config
(use-package terraform-mode
  :mode (("\\.tf\\'" . terraform-mode)
         ("\\.tfvars\\'" . terraform-mode)))

(provide 'module-langs)
;;; module-langs.el ends here
