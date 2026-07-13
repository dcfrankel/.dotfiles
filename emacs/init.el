;;; -*- lexical-binding: t; -*-

;; =======================
;; Basic Customization
;; =======================

;; Redirect the package-managed custom variables to a separate file
(setq custom-file (locate-user-emacs-file "custom-vars.el"))

;; Load that file if it exists, ignoring errors if it doesn't yet
(when (file-exists-p custom-file)
  (load custom-file))

;; Better buffer list
(defalias 'list-buffers 'ibuffer)

;; Automatically add closing delimiters
(electric-pair-mode 1)

;; Show whitespace
(setq whitespace-style '(face spaces space-mark tabs tab-mark trailing))
(global-whitespace-mode 1)

;; Better completions
(require 'ido)
(ido-mode t)

;; Use relative line numbers
(global-display-line-numbers-mode t)

;; Disable splash screen and startup message
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; Disable all the ugly menu bars
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; =========================
;; Package Support
;; =========================
;; Add package archives
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Make sure all packages are installed on the system
(require 'use-package)
(setq use-package-always-ensure t)

;; Theme
(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'mocha) ;; Options are 'latte, 'frappe, 'macchiato, or 'mocha
  (catppuccin-reload))


;; Which key config
(use-package which-key
  :ensure t
  :config (which-key-mode))

;; Evil config
(use-package evil
  :ensure t
  :config
  (evil-mode 1))

;; Yaml mode config
(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\" . yaml-mode))
