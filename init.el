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

;; straight.el に use-package を管理させる
(straight-use-package 'use-package)

;; 全 use-package を自動的に straight で管理する
;; （既存の :ensure t と同じ感覚で使える）
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
;; transient は agent-shell が新しい API（transient--set-layout 等）を使うため
;; built-in ではなく straight で外部版を管理する
(dolist (pkg '(xref eldoc seq eglot jsonrpc use-package))
  (straight-use-package `(,pkg :type built-in)))

(dolist (path (list
               (expand-file-name "modules" user-emacs-directory)))
  (add-to-list 'load-path path))

(add-to-list 'load-path "~/dev-emacs/magh")

(server-start) ;; GUI Emacsをサーバーとして常駐させる

(load "mk-base" nil 'nomessage)
(load "mk-view" nil 'nomessage)
(load "mk-path-from-shell" nil 'nomessage)
(load "mk-engine-mode" nil 'nomessage)
(load "mk-which-key" nil 'nomessage)
;;(load "mk-evil" nil 'nomessage)
(load "mk-eat" nil 'nomessage)
(load "mk-vterm" nil 'nomessage)
(load "mk-ghostel" nil 'nomessage)
(load "mk-claude-code-ide" nil 'nomessage)
(load "mk-claude-code" nil 'nomessage)
(load "mk-agent-shell" nil 'nomessage)
(load "mk-git" nil 'nomessage)
(load "mk-dirvish" nil 'nomessage)
(load "mk-org" nil 'nomessage)
(load "mk-keybind" nil 'nomessage)
(load "mk-lsp" nil 'nomessage)
(load "mk-language-mode" nil 'nomessage)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
