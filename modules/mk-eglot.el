;;; mk-eglot.el --- -*- lexical-binding: t -*-

;; eglot: 組み込みの LSP クライアント
(use-package eglot
  :hook ((ruby-mode ruby-ts-mode) . eglot-ensure)
  :config
  ;; solargraph も入っているため、毎回の選択を避けて ruby-lsp に固定する
  (add-to-list 'eglot-server-programs '((ruby-mode ruby-ts-mode) "ruby-lsp")))

;; flymake: Emacs Lisp はバイトコンパイル結果で診断する（elisp 用 LSP は無いため）
(use-package flymake
  :hook (emacs-lisp-mode . flymake-mode))

(provide 'mk-eglot)
;;; mk-eglot.el ends here
