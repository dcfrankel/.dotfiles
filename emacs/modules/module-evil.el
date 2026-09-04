;;; module-evil.el --- Evil mode configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Vim-style modal editing via evil, plus evil-collection for evil bindings
;; in non-editing modes.

;;; Code:
(defun my/doc-at-point ()
  "Show documentation for the thing under point, dispatching on major context."
  (interactive)
  (cond
   ((and (fboundp 'eglot-managed-p) (eglot-managed-p))
    (call-interactively #'eglot-help-at-point))
   ((symbol-at-point)
    (describe-symbol (symbol-at-point)))
   (t (call-interactively #'describe-symbol))))

(defun my/create-scratch-buffer ()
  "Create a new unique scratch buffer and switch to it."
  (interactive)
  (let ((buf (generate-new-buffer "*scratch*")))
    (switch-to-buffer buf)
    (lisp-interaction-mode)))

;; Evil config
(use-package evil
  :pin "melpa"
  :custom
  ;; Fixes control based navigation
  (evil-disable-insert-state-bindings t)
  (evil-want-C-u-scroll t)
  (evil-want-keybinding nil)
  ;; The custom mode-line renders its own state segment (see "Custom Mode Line"),
  ;; so silence evil's built-in indicators: the echo-area "-- INSERT --" message
  ;; below the mode-line and the state tag it splices into the mode-line front.
  (evil-echo-state nil)
  (evil-mode-line-format nil)
  (evil-undo-system 'undo-redo)

  :hook (after-init . evil-mode)

  :config
  ;; Set the leader key
  (evil-set-leader '(normal motion visual) (kbd "SPC"))
  ;; Window navigation
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>h") 'evil-window-left)
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>j") 'evil-window-down)
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>k") 'evil-window-up)
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>l") 'evil-window-right)
  ;; VSCode-style quick open: find file in project
  (evil-define-key '(normal insert visual motion) 'global (kbd "C-p") 'consult-fd)
  ;; VSCode-style project-wide search
  (evil-define-key '(normal insert visual motion) 'global (kbd "M-F") 'consult-ripgrep)
  ;; Toggle the directory-tree sidebar
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>t") 'treemacs)
  ;; Evaluate top level elisp expression surrounding the cursor
  (evil-define-key '(normal) 'global (kbd "<leader>e") 'eval-defun)
  ;; Show documentation for the symbol under the cursor
  (evil-define-key '(normal) 'global (kbd "K") 'my/doc-at-point)
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>s") 'my/create-scratch-buffer))

(use-package evil-collection
  :pin "melpa"
  :after evil
  :ensure t
  :custom
  ;; Use SPC as the evil leader (see the `evil' block above). evil-collection
  ;; binds SPC directly in many read-only/pager modes (help, Info, etc.), and
  ;; those buffer-local bindings shadow the global leader.
  (evil-collection-key-blacklist '("SPC"))
  :config (evil-collection-init))

(provide 'module-evil)
;;; module-evil.el ends here
