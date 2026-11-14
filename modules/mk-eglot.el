;;; mk-eglot.el --- -*- lexical-binding: t -*-

;; eglot: 組み込みの LSP クライアント
(use-package eglot
  :hook ((ruby-mode ruby-ts-mode) . eglot-ensure)
  :config
  ;; solargraph も入っているため、毎回の選択を避けて ruby-lsp に固定する
  ;; Dock から起動した Emacs の PATH には rbenv の shims が無いため、絶対パスで指定する
  (add-to-list 'eglot-server-programs
               `((ruby-mode ruby-ts-mode) ,(expand-file-name "~/.rbenv/shims/ruby-lsp"))))

;; 自分の設定ファイルを信頼済みにする（未信頼だと flymake のバイトコンパイル診断が無効になる）
(use-package files
  :custom
  (trusted-content (list (abbreviate-file-name user-emacs-directory))))

;; flymake: Emacs Lisp はバイトコンパイル結果で診断する（elisp 用 LSP は無いため）
(use-package elisp-mode
  :hook (emacs-lisp-mode . (lambda () (when buffer-file-name (flymake-mode))))  ;; *scratch* などファイルの無いバッファは常に未信頼扱いで警告が出るため除外する
  :custom
  ;; 診断用の子プロセスにも modules と elpa のパッケージを見せる
  (elisp-flymake-byte-compile-load-path load-path))

(provide 'mk-eglot)
;;; mk-eglot.el ends here
