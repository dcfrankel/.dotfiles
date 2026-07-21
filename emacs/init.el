;;; -*- lexical-binding: t; -*-

;; =======================
;; Basic Customization
;; =======================

;; Redirect the package-managed custom variables to a separate file
(setq custom-file (locate-user-emacs-file "custom-vars.el"))

;; Load that file if it exists, ignoring errors if it doesn't yet
(when (file-exists-p custom-file)
  (load custom-file))

;; Open with full sized window
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Better buffer list
(defalias 'list-buffers 'ibuffer)

;; Automatically add closing delimiters
(electric-pair-mode 1)

;; Show whitespace
(setq whitespace-style '(face spaces space-mark tabs tab-mark trailing))
(global-whitespace-mode 1)

;; Use relative line numbers
(global-display-line-numbers-mode t)

;; Scrolling behavior
(setq scroll-conservatively most-positive-fixnum) ; Scroll line-by-line, no recentering jumps
(setq scroll-margin 0)                            ; Allow last line to sit at window bottom
(setq scroll-error-top-bottom t)                  ; Page-scroll stops at buffer boundary, not past it

;; Disable splash screen and startup message
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; Disable all the ugly menu bars
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; =======================
;; Font Configuration
;; =======================
;; Font size 14 (Emacs :height is in 1/10 pt)
(set-face-attribute 'default nil :family "Hack Nerd Font" :height 140)
(setq-default line-spacing 1)

;; =========================
;; Packages
;; =========================
;; Add package archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Prefer GNU (official) over MELPA
(setq package-archive-priorities '(("gnu" . 20)("melpa" . 10)))

;; Make sure all packages are installed on the system
(require 'use-package)
(setq use-package-always-ensure t)

;; -------------------------
;; Internal Packages
;; -------------------------
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

  :hook
  ((python-mode . eglot-ensure)
   (go-mode . eglot-ensure)
   (yaml-mode . eglot-ensure)
   (helm-mode . eglot-ensure)))

;; Project management
(use-package project
  :ensure nil
  :config
  (when (file-directory-p "~/work")
    (project-remember-projects-under "~/work"))
  :bind
  ("S-M-p" . project-switch-project))

;; -------------------------
;; Mode Configs
;; -------------------------
;; Yaml mode config
(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

;; Go mode config
(use-package go-mode
  :mode ("\\.go\\'" . go-mode))

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

;; Evil config
(use-package evil
  :init
  ;; Fixes control based navigation
  (setq evil-disable-insert-state-bindings t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)

  :config
  (evil-mode 1)
  ;; Set the leader key
  (evil-set-leader '(normal motion visual) (kbd "SPC"))
  ;; Window navigation
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>h") 'evil-window-left)
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>j") 'evil-window-down)
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>k") 'evil-window-up)
  (evil-define-key '(normal motion visual) 'global (kbd "<leader>l") 'evil-window-right))

(use-package evil-collection
  :after evil
  :ensure t
  :config (evil-collection-init))

;; TAB key: fix indentation if needed, otherwise perform completion
(setq tab-always-indent 'complete)

;; Use corfu for at-point compltion within buffers
(use-package corfu
  :custom
  (corfu-auto t) ; Auto completions
  (corfu-on-exact-match 'insert) ; Complete if there is only a single candidate
  (corfu-quit-no-match t)

  :init (global-corfu-mode 1)

  :config
  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1)) ; Show documentation next to completions

;; Add support for rainbow brackets and other delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))
