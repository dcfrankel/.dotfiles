;;; -*- lexical-binding: t; -*-

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
  (defun my/disable-frame-chrome (&optional _frame)
    (menu-bar-mode -1)
    (tool-bar-mode -1)
    (scroll-bar-mode -1))
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
  (flymake-show-diagnostics-at-end-of-line 'short))

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
  ;; Silently save modified, local file-visiting buffers on demand
  (defun my/save-visited-buffers (&rest _)
    (save-some-buffers
     t
     (lambda () (and buffer-file-name
                     (not (file-remote-p buffer-file-name))))))
  ;; Save when switching windows/buffers and when the frame loses focus
  (add-hook 'window-selection-change-functions #'my/save-visited-buffers)
  (add-function :after after-focus-change-function #'my/save-visited-buffers))

;; -------------------------
;; Mode Configs
;; -------------------------
;; Yaml mode config
(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

;; Go mode config
(use-package go-mode
  :mode ("\\.go\\'" . go-mode))

;; Markdown mode config
(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

;; Terraform mode config
(use-package terraform-mode
  :mode (("\\.tf\\'" . terraform-mode)
         ("\\.tfvars\\'" . terraform-mode)))

;; -------------------------
;; External Packages
;; -------------------------
;; Theme
(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'mocha) ; Options are 'latte, 'frappe, 'macchiato, or 'mocha
  (catppuccin-reload))

;; Which key config
(use-package which-key
  :config (which-key-mode))

;; Show documentation for the symbol at point: LSP docstring when eglot manages
;; the buffer, otherwise Emacs' own describe-symbol (e.g. in emacs-lisp-mode).
(defun my/doc-at-point ()
  "Show documentation for the thing under point, dispatching on major context."
  (interactive)
  (cond
   ((and (fboundp 'eglot-managed-p) (eglot-managed-p))
    (call-interactively #'eglot-help-at-point))
   ((symbol-at-point)
    (describe-symbol (symbol-at-point)))
   (t (call-interactively #'describe-symbol))))

;; Evil config
(use-package evil
  :init
  ;; Fixes control based navigation
  (setq evil-disable-insert-state-bindings t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)
  ;; The custom mode-line renders its own state segment (see "Custom Mode Line"),
  ;; so silence evil's built-in indicators: the echo-area "-- INSERT --" message
  ;; below the mode-line and the state tag it splices into the mode-line front.
  (setq evil-echo-state nil)
  (setq evil-mode-line-format nil)

  :config
  (evil-mode 1)
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
  (evil-define-key '(normal) 'global (kbd "K") 'my/doc-at-point))

(use-package evil-collection
  :after evil
  :ensure t
  :config (evil-collection-init))

;; Directory tree sidebar (VSCode/Zed-style)
(use-package treemacs
  :defer t
  :init
  ;; Daemon workflow: open the sidebar in each new emacsclient frame without stealing focus from the editing window
  (add-hook 'server-after-make-frame-hook #'treemacs-start-on-boot)
  :custom
  (treemacs-width 32)
  (treemacs-follow-after-init t)   ; keep tree in sync with active file
  :config
  ;; No line numbers in the sidebar (global-display-line-numbers-mode is on)
  (add-hook 'treemacs-mode-hook (lambda () (display-line-numbers-mode -1)))
  ;; Root the tree at the current project and follow across projects
  (treemacs-project-follow-mode 1))

;; Evil keybindings inside the treemacs buffer
;; (evil-collection has no treemacs module, so this is required and non-conflicting)
(use-package treemacs-evil
  :after (treemacs evil))

;; Use nerd font icons
(use-package nerd-icons)

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :config
  (treemacs-load-theme "nerd-icons"))

;; Add support for rainbow brackets and other delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

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

;; Vertical completion UI in the minibuffer
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

;; Search and navigation commands
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

;; Git gutter / VCS change indicators in the fringe
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

;; Show indentation with faint vertical guide bars
(use-package indent-bars
  :hook ((prog-mode yaml-mode) . indent-bars-mode)
  :custom
  ;; macOS (NS) builds lack stipple support, so render bars with characters
  ;; instead of stipple bitmaps — otherwise the bars won't appear.
  (indent-bars-prefer-character t)
  ;; Draw a bar every 2 columns instead of guessing from the major mode's
  ;; indent offset.
  (indent-bars-spacing-override 2)
  ;; Highlight the bar at the cursor's current indentation depth.
  (indent-bars-highlight-current-depth '(:blend 0.8)))

;; -------------------------
;; Custom Mode Line
;; -------------------------
(load (locate-user-emacs-file "mode-line.el"))
