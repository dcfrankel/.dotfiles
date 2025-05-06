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

;; Add package repos
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Install use-package automatically
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

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

;; Org mode config
(use-package org
  :mode ("\\.org\\" . org-mode)
  :ensure t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("30dc9873c16a0efb187bb3f8687c16aae46b86ddc34881b7cae5273e56b97580" default))
 '(package-selected-packages '(yaml-mode evil which-key use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
