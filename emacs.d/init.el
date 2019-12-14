;; =======================
;; Basic Customization
;; =======================
;; better buffer list
(defalias 'list-buffers 'ibuffer) 
;; automatically add closing delimters
(electric-pair-mode 1) 
(load-theme 'manoj-dark)
(setq show-trailing-whitespace t)
;; better completions
(require 'ido)
(ido-mode t)

;; use relative line numbers
(global-display-line-numbers-mode t)

;;disable splash screen and startup message
(setq inhibit-startup-message t) 
(setq initial-scratch-message nil)

;; =========================
;; Package Support
;; =========================
(require 'package)

;; adds MELPA as repo
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(which-key ;; which key to help show emacs commands
    projectile ;; project management
    evil ;; vim keybindings
    yaml-mode ;; yaml mode
    pyvenv ;; use python environments
    elpy ;; python goodness
    nord-theme ;; Nord theme
    ))

;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

;; Theme
(load-theme 'nord t)

;; which key config
(require 'which-key)
(which-key-mode)

;; evil configs
(require 'evil)
(evil-mode 1)

;; yaml mode config
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;; elpy config
(elpy-enable)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (elpy pyvenv yaml-mode evil-escape evil projectile org-bullets which-key))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
