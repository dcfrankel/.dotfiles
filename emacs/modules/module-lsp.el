;;; module-lsp.el --- Eglot LSP configurations -*- lexical-binding: t; -*-

;;; Commentary:
;; Language server wiring for Eglot: per-language server overrides and
;; activation hooks.

;;; Code:

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

  ;; Java: JDT.LS returns jdt:// URIs for JDK builtins and decompiled/
  ;; dependency classes that have no plain source file on disk. Stock eglot
  ;; doesn't declare the capability JDT.LS needs to return those, nor know
  ;; how to resolve a jdt:// URI, so go-to-definition silently fails for
  ;; them. Add a small custom server class + URI resolver for this.
  (defclass my/eglot-jdtls (eglot-lsp-server) ()
    :documentation "Eclipse JDT language server with jdt:// URI support.")

  (cl-defmethod eglot-initialization-options ((_server my/eglot-jdtls))
    '(:extendedClientCapabilities (:classFileContentsSupport t)))

  (add-to-list 'eglot-server-programs
               '((java-mode java-ts-mode) . (my/eglot-jdtls "jdtls")))

  (defvar my/eglot-jdt-cache-dir (locate-user-emacs-file "eglot-jdt-cache/")
    "Where decompiled/jdt:// class contents fetched from jdtls are cached.
Lives under `user-emacs-directory', never inside a project, so it can't
pollute a project's version control.")

  (defun my/eglot-jdt-uri-to-path (uri)
    "Resolve a jdt:// URI to a local file, fetching its content from jdtls."
    (let* ((name (if (string-match "jdt://contents/\\(.*?\\)/\\(.*\\)\\.class\\?" uri)
                     (replace-regexp-in-string "/" "." (match-string 2 uri) t t)
                   (md5 uri)))
           ;; Always end in .java so auto-mode-alist/major-mode-remap-alist
           ;; picks java-ts-mode; an extensionless cache file silently falls
           ;; back to fundamental-mode (no highlighting).
           (file (expand-file-name (concat name ".java") my/eglot-jdt-cache-dir)))
      (unless (file-readable-p file)
        (let ((content (jsonrpc-request (eglot-current-server) :java/classFileContents (list :uri uri))))
          (make-directory my/eglot-jdt-cache-dir t)
          (with-temp-file file (insert content))))
      file))

  (advice-add 'eglot-uri-to-path :around
              (lambda (fn uri)
                (if (string-prefix-p "jdt://" uri)
                    (my/eglot-jdt-uri-to-path uri)
                  (funcall fn uri))))

  :hook
  ((python-mode . eglot-ensure)
   (python-ts-mode . eglot-ensure)
   (go-mode . eglot-ensure)
   (go-ts-mode . eglot-ensure)
   (yaml-mode . eglot-ensure)
   (yaml-ts-mode . eglot-ensure)
   (helm-mode . eglot-ensure)
   (terraform-mode . eglot-ensure)
   (java-mode . eglot-ensure)
   (java-ts-mode . eglot-ensure)))

(provide 'module-lsp)
;;; module-lsp.el ends here
