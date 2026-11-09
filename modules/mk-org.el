;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; org-mode
;;; ============================================================
(global-set-key (kbd "C-c o") (lambda () (interactive) (dired org-path)))

(use-package org
  :straight (:type built-in)

  :custom
  (org-directory org-path)
  (org-default-notes-file (concat org-path "inbox.org"))
  ;; タスクの状態: 未着手 → 対応中 → 完了
  (org-todo-keywords '((sequence "TODO" "WIP" "|" "DONE")))
  (org-todo-keyword-faces '(("WIP" . (:foreground "orange" :weight bold))))
  ;; agenda は ~/org と ~/org-work 直下の全ファイルを対象にする
  ;; ディレクトリ指定にして、起動後に作成されたファイルも参照時に拾われるようにする
  (org-agenda-files (list "~/org" "~/org-work/"))
  ;; refile は org-agenda-files の見出しレベル2までを対象にする
  (org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  ;; capture テンプレート（%a を付けない）
  (org-capture-templates
   '(("t" "タスク" entry
      (file+headline org-default-notes-file "Tasks")
      "* TODO %?\n %u\n"
      :empty-lines 1)
     ("T" "仕事タスク" entry
      (file "~/org-work/inbox.org")
      "* TODO %?\n %u\n"
      :empty-lines 1)))

  :bind
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture))

;; 画像をインラインで表示
(setq org-startup-with-inline-images t)


(defun org-insert-title ()
  "org-mode でタイトルを出力するショートカット"
  (interactive)
  (insert "#+TITLE: "))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c t") 'org-insert-title))

(provide 'mk-org)
