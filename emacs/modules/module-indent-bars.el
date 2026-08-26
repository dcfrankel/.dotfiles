;;; module-indent-bars.el --- Indentation guide bars -*- lexical-binding: t; -*-

;;; Commentary:
;; Show indentation with faint vertical guide bars.

;;; Code:

(use-package indent-bars
  :hook ((prog-mode yaml-mode) . indent-bars-mode)
  :custom
  ;; macOS (NS) builds lack stipple support, so render bars with characters
  ;; instead of stipple bitmaps — otherwise the bars won't appear.
  (indent-bars-prefer-character t)
  ;; Highlight the bar at the cursor's current indentation depth.
  (indent-bars-highlight-current-depth '(:blend 0.8)))

(provide 'module-indent-bars)
;;; module-indent-bars.el ends here
