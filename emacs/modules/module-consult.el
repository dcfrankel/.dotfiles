;;; module-consult.el --- Search and navigation commands -*- lexical-binding: t; -*-

;;; Commentary:
;; Consult-based buffer, file, and grep/ripgrep pickers.

;;; Code:

(use-package consult
  :bind (("C-x b"   . consult-buffer)          ; orig. switch-to-buffer
         ("C-x p b" . consult-project-buffer)  ; orig. project-switch-to-buffer
         ("M-y"     . consult-yank-pop)        ; orig. yank-pop
         ("M-s l"   . consult-line)
         ("M-s g"   . consult-grep)
         ("M-s r"   . consult-ripgrep)         ; project-aware ripgrep
         ("M-s f"   . consult-find))
  :custom
  (consult-project-function #'consult--default-project-function)
  ;; Include hidden dotfiles (e.g. .github) in searches, but skip .git/
  (consult-ripgrep-args
   "rg --null --line-buffered --color=never --max-columns=1000 --path-separator /\
   --smart-case --no-heading --with-filename --line-number --search-zip --hidden --glob=!.git/")
  (consult-find-args "find . -not ( -path */.git* -prune )"))

(provide 'module-consult)
;;; module-consult.el ends here
