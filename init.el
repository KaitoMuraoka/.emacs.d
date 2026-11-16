;;; init.el --- -*- lexical-binding: t -*- ;; Emacs 30 からは、このクッキーがない elisp ファイルを読み込むと警告が出る。
;; 設定本体は config.org。emacs-lisp ブロックを config.el に tangle して読み込む
(org-babel-load-file (locate-user-emacs-file "config.org"))
