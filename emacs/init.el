;;; -*- lexical-binding: t; -*-

;; =======================
;; Basic Customization
;; =======================
;; Better buffer list
(defalias 'list-buffers 'ibuffer)

;; Automatically add closing delimiters
(electric-pair-mode 1)
(setq show-trailing-whitespace t)

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
;; Theme
(use-package modus-themes
  :ensure t
  :config (load-theme 'modus-vivendi-tinted t))

;; Add package archives
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Make sure all packages are installed on the system
(require 'use-package)
(setq use-package-always-ensure t)

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
