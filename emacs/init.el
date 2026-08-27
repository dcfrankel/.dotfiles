;;; init.el --- Emacs init file -*- lexical-binding: t; -*-

;;; Commentary:
;; My init file with most of my Emacs configurations.

;;; Code:
;; =========================
;; Functions
;; =========================
(defun my/disable-frame-chrome (&optional _frame)
  "Disable various frame related modes."
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

(defun my/save-visited-buffers (&rest _)
  "Silently save modified, local file-visiting buffers on demand."
  (save-some-buffers
   t
   (lambda () (and buffer-file-name
		   (not (file-remote-p buffer-file-name))))))

;; =========================
;; Package Configurations
;; =========================

;; Add package archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Prefer GNU (official) over MELPA
(setq package-archive-priorities '(("gnu" . 20)("nongnu" . 15)("melpa" . 10)))

;; Make sure all packages are installed on the system
(require 'use-package)
(setq use-package-always-ensure t)

;; Non-built-in package configurations live in their own files under modules/
(add-to-list 'load-path (locate-user-emacs-file "modules"))

;; -------------------------
;; Internal Packages
;; -------------------------

;; Basic customization and global settings
(use-package emacs
  :ensure nil
  :init
  ;; Redirect the package-managed custom variables to a separate file
  (setq custom-file (locate-user-emacs-file "custom.el"))
  ;; Load that file if it exists, ignoring errors if it doesn't yet
  (when (file-exists-p custom-file)
    (load custom-file))
  :hook (prog-mode . delete-trailing-whitespace-mode)

  :custom
  ;; Show whitespace
  (whitespace-style '(face tabs tab-mark trailing))
  ;; Scrolling behavior
  (scroll-conservatively most-positive-fixnum) ; Scroll line-by-line, no recentering jumps
  (scroll-margin 0)                            ; Allow last line to sit at window bottom
  (scroll-error-top-bottom t)                  ; Page-scroll stops at buffer boundary, not past it
  ;; Disable splash screen and startup message
  (inhibit-startup-message t)
  (initial-scratch-message nil)
  ;; TAB key: fix indentation if needed, otherwise perform completion
  (tab-always-indent 'complete)
  (require-final-newline 'visit-save)
  ;; Correctly update cursor shape in TTY
  (xterm-update-cursor t)
  ;; Properly display child frames in TTY
  (tty-tip-mode 1)

  :config
  ;; Open with full sized window
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  ;; Disable the menu/tool/scroll bars. The default-frame-alist entries give
  ;; the initial frame a clean start, but under the daemon a one-time
  ;; (menu-bar-mode -1) doesn't stick: the modes stay on and re-apply the menu
  ;; bar to each new emacsclient frame. Force them off on every client frame
  ;; too. -1 is a no-op for the GUI-only bars in a tty.
  (add-to-list 'default-frame-alist '(menu-bar-lines . 0))
  (add-to-list 'default-frame-alist '(tool-bar-lines . 0))
  (add-to-list 'default-frame-alist '(vertical-scroll-bars))
  (add-hook 'server-after-make-frame-hook #'my/disable-frame-chrome)
  ;; Better buffer list
  (defalias 'list-buffers 'ibuffer)
  ;; Automatically add closing delimiters
  (electric-pair-mode 1)
  ;; Show whitespace
  (global-whitespace-mode 1)
  ;; Use relative line numbers
  (global-display-line-numbers-mode t)
  ;; Font size 14 (Emacs :height is in 1/10 pt)
  (set-face-attribute 'default nil :family "Hack Nerd Font" :height 140)
  (setq-default line-spacing 1)
  (setq completion-styles '(flex basic))
  ;; Store backups in a centralized location
  (setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
  ;; Fix issues with frame locking across multiple buffers when using the daemon
  (setq multiple-terminals-merge-keyboards t)
  ;; Terminal Emacs: send kills (incl. evil yanks) to the macOS clipboard.
  ;; GUI Emacs already handles this via gui-select-text, so only override -nw.
  (when (and (not (display-graphic-p)) (executable-find "pbcopy"))
    (setq interprogram-cut-function
          (lambda (text)
            (let ((proc (make-process :name "pbcopy"
                                      :command '("pbcopy")
                                      :connection-type 'pipe
                                      :noquery t)))
              (process-send-string proc text)
              (process-send-eof proc))))))

;; Tree-sitter switch modes with a ts variant to *-ts-mode and auto-fetch/compile grammars on demand
(use-package treesit
  :ensure nil
  :if (>= emacs-major-version 31)
  :config
  ;; Silently fetch + compile a missing grammar the first time a file needs it.
  (setopt treesit-auto-install-grammar 'always)
  ;; Enable every built-in major mode that has a tree-sitter variant.
  (setopt treesit-enabled-modes t))

(use-package markdown-ts-mode
  :ensure nil
  :if (>= emacs-major-version 31)
  :mode ("\\.md\\'" "\\.mdx\\'" "\\.markdown\\'")
  :config
  (require 'markdown-ts-mode-x))

;; Eglot LSP configurations
(use-package eglot
  :ensure nil
  :config
  ;; Python: use ty as the python language server
  (add-to-list 'eglot-server-programs '(python-mode . ("uvx" "ty" "server")))
  ;; Helm charts: dedicated major mode derived from yaml-mode so helm-ls is
  ;; only invoked for Helm templates, not ordinary YAML files.
  ;; Activate with M-x helm-mode or a file-local -*- mode: helm -*- header.
  (define-derived-mode helm-mode yaml-mode "Helm"
    "Major mode for editing Kubernetes Helm templates.")
  (add-to-list 'eglot-server-programs '(helm-mode . ("helm_ls" "serve")))
  ;; Terraform: use terraform-ls as the language server
  (add-to-list 'eglot-server-programs '(terraform-mode . ("terraform-ls" "serve")))

  :hook
  ((python-mode . eglot-ensure)
   (go-mode . eglot-ensure)
   (yaml-mode . eglot-ensure)
   (helm-mode . eglot-ensure)
   (terraform-mode . eglot-ensure)))

;; Project management
(use-package project
  :ensure nil
  :config
  (when (file-directory-p "~/work/ghec")
    (project-remember-projects-under "~/work/ghec"))
  (when (file-directory-p "~/work/ghes")
    (project-remember-projects-under "~/work/ghes"))
  ;; Override the default projectg commands to use consult
  (setq project-switch-commands
        '((consult-project-buffer "Buffer" ?b)
          (consult-ripgrep        "Ripgrep" ?g)
          (consult-fd             "Find file" ?f)
          (project-find-dir       "Find dir" ?d)
          (project-eshell         "Eshell" ?e))))

;; Error diagnostics and syntax checks
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-show-diagnostics-at-end-of-line 'fancy)
  :config
  ;; Emacs core's `flymake--eol-draw-fancy' hardcodes the wrap column so fancy EOL
  ;; diagnostics wrap even with plenty of screen space. Widen the wrap column to the window width.
  (define-advice flymake--eol-draw-fancy-1
      (:filter-args (args) my/flymake-eol-window-width)
    ;; args = (text face line-beg-col height-to-clear text-beg-col text-end-col)
    (setf (nth 5 args) (max (nth 5 args) (- (window-width) 2)))
    args))

;; Enable spell checking of comments
(use-package flyspell
  :ensure nil
  ;; Only load if aspell is available
  :if (executable-find "aspell")
  :hook (prog-mode . flyspell-prog-mode))

;; Reload buffers when their underlying files change on disk
(use-package autorevert
  :ensure nil
  :custom
  (auto-revert-verbose nil)                 ; No "Reverting buffer" chatter
  (global-auto-revert-non-file-buffers t)   ; Also refresh Dired/ibuffer
  :config
  (global-auto-revert-mode 1))

;; Auto-save file-visiting buffers to their real files after a short idle
(use-package files
  :ensure nil
  :custom
  (auto-save-visited-interval 1)             ; Save 1s after edits stop
  (auto-save-visited-predicate               ; Skip remote/TRAMP files
   (lambda () (not (file-remote-p buffer-file-name))))
  :config
  (auto-save-visited-mode 1)
  ;; Save when switching windows/buffers and when the frame loses focus
  (add-hook 'window-selection-change-functions #'my/save-visited-buffers)
  (add-function :after after-focus-change-function #'my/save-visited-buffers))

;; -------------------------
;; External Packages
;; -------------------------

(require 'module-theme)
(require 'module-evil)
(require 'module-treemacs)
(require 'module-rainbow-delimiters)
(require 'module-corfu)
(require 'module-vertico)
(require 'module-consult)
(require 'module-diff-hl)
(require 'module-indent-bars)
(require 'module-langs)

;; -------------------------
;; Custom Mode Line
;; -------------------------

(load (locate-user-emacs-file "mode-line.el"))
;;; init.el ends here
