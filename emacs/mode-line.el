;;; mode-line.el --- Custom mode-line -*- lexical-binding: t; -*-

;;; Commentary:
;; A hand-built, color-coded mode-line.  Left side: file name and git branch.
;; Right edge: major mode, minor modes, flymake, and the evil state tag as the
;; final segment.  Segments are joined by a white circle separator (○).
;; Colors come from the active catppuccin flavor via `catppuccin-color'.

;;; Code:
(require 'cl-lib)

;; The white-circle segment separator, dimmed.
(defvar-local my/ml-separator
  (propertize " ○ " 'face `(:foreground ,(catppuccin-color 'overlay0)))
  "Separator string placed between mode-line segments.")

(defun my/ml-join (segments)
  "Join non-empty SEGMENTS with `my/ml-separator'."
  (mapconcat #'identity
             (seq-remove (lambda (s) (or (null s) (string-empty-p s))) segments)
             my/ml-separator))

;; --- Segments ---
(defun my/ml-evil-state ()
  "Evil state tag (e.g. <N>), colored per state.  Empty if evil is absent."
  (if (and (bound-and-true-p evil-mode) (boundp 'evil-state) evil-state)
      (let* ((color (pcase evil-state
                      ('normal   (catppuccin-color 'green))
                      ('insert   (catppuccin-color 'sky))
                      ('visual   (catppuccin-color 'mauve))
                      ('replace  (catppuccin-color 'red))
                      ('operator (catppuccin-color 'peach))
                      ('motion   (catppuccin-color 'lavender))
                      ('emacs    (catppuccin-color 'peach))
                      (_         (catppuccin-color 'text))))
             (raw (evil-state-property evil-state :tag t))
             (tag (string-trim (or (if (functionp raw) (funcall raw) raw) ""))))
        (propertize tag 'face `(:foreground ,color :weight bold)))
    ""))

(defun my/ml-file-name ()
  "Buffer name with a modified (*) or read-only (%) marker."
  (let ((marker (cond (buffer-read-only " %")
                      ((buffer-modified-p) " *")
                      (t ""))))
    (concat (propertize (buffer-name) 'face 'mode-line-buffer-id)
            (propertize marker 'face `(:foreground ,(catppuccin-color 'red))))))

(defun my/ml-git-branch ()
  "Current VC branch (with a nerd-font git glyph).  Empty when not under VC."
  (if (and vc-mode (stringp vc-mode))
      (let ((branch (replace-regexp-in-string
                     "\\`[[:space:]]*\\(Git\\|SVN\\|Hg\\)[-:@]" "" vc-mode)))
        (propertize (string-trim branch) 'face `(:foreground ,(catppuccin-color 'peach))))
    ""))

(defun my/ml-major-mode ()
  "Major mode name."
  (propertize (format-mode-line mode-name)
              'face `(:foreground ,(catppuccin-color 'blue) :weight bold)))

(defun my/ml-minor-modes ()
  "Active minor-mode lighters, excluding flymake (shown as its own segment)."
  (string-trim
   (format-mode-line
    (seq-remove (lambda (e) (eq (car-safe e) 'flymake-mode)) minor-mode-alist))))

(defun my/ml-flymake ()
  "Flymake's built-in mode-line construct (title, state, counts).  Empty when off."
  (if (and (bound-and-true-p flymake-mode)
           (boundp 'flymake-mode-line-format))
      (string-trim (format-mode-line flymake-mode-line-format))
    ""))

;; --- Assembly ---
(defvar-local my/ml-left
  '(:eval (my/ml-join (list (my/ml-evil-state) (my/ml-file-name) (my/ml-git-branch))))
  "Left-aligned segment group.")

(put 'my/ml-left' risky-local-variable t)

(defun my/ml-right ()
  "Right-aligned segment group (evil state is the final segment)."
  (my/ml-join (list (my/ml-major-mode) (my/ml-minor-modes)
                    (my/ml-flymake))))

(defvar-local my/ml-right-adjusted
  '(:eval (let ((r (my/ml-right)))
            (concat
             (propertize
              " "
              'display `((space :align-to (- right ,(+ 1 (string-width r))))))
             r " ")))
  "The right adjusted ml components.")

(put 'my/ml-right-adjusted' risky-local-variable t)

;; Set the custom format of the mode line
(setq-default mode-line-format
      '("%e"
	" "
	my/ml-left
        my/ml-right-adjusted))

(provide 'mode-line)
;;; mode-line.el ends here
