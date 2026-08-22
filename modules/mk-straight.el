;; -*- lexical-binding: t; -*-

;;; ============================================================
;; straight.el ブートストラップ
;;; ============================================================

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))


(straight-use-package 'use-package);; straight.el に use-package を管理させる
;; 全 use-package を自動的に straight で管理する
;; （既存の :ensure t と同じ感覚で使える）
;; レシピは straight.el の既定レシピリポジトリである MELPA から解決される
(setq straight-use-package-by-default t)

;; org を組み込みとして扱う
;; 理由: straight.el が org をソースからビルドする際に lisp/ ディレクトリが
;;       存在しないケースがあり :pre-build エラーで init.el がアボートするため
(straight-use-package '(org :type built-in))

;; project を組み込みとして扱う
;; 理由: 依存パッケージ経由で straight が外部版をビルドすると
;;       "Feature 'project' is now provided by a different file" エラーが発生するため
(straight-use-package '(project :type built-in))

;; flymake を組み込みとして扱う
;; 理由: 同上。外部版との競合で起動エラーになるため
(straight-use-package '(flymake :type built-in))

;; Emacs 29 以降で組み込みになったパッケージを built-in として宣言する
;; 理由: 依存パッケージが外部版を引き込み、起動時に
;;       "Feature 'X' is now provided by a different file" エラーが連鎖するため
(dolist (pkg '(xref eldoc seq eglot jsonrpc use-package))
  (straight-use-package `(,pkg :type built-in)))

(provide 'mk-straight)
