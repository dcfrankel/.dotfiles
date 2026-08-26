;;; module-rainbow-delimiters.el --- Rainbow delimiters -*- lexical-binding: t; -*-

;;; Commentary:
;; Color-coded matching brackets/parens/braces.

;;; Code:

;; Add support for rainbow brackets and other delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(provide 'module-rainbow-delimiters)
;;; module-rainbow-delimiters.el ends here
