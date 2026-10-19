;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; org-mode
;;; ============================================================
(defconst org-path
  "~/org/")
(global-set-key (kbd "C-c o") (lambda () (interactive) (dired org-path)))

(use-package org
  :straight (:type built-in)

  :custom
  (org-directory org-path)
  (org-default-notes-file (concat org-path "inbox.org"))
  ;; タスクの状態: 未着手 → 対応中 → 完了
  (org-todo-keywords '((sequence "TODO" "WIP" "|" "DONE")))
  (org-todo-keyword-faces '(("WIP" . (:foreground "orange" :weight bold))))
  ;; agenda は inbox.org / projects・daily 配下の全ファイルを対象にする
  (org-agenda-files (append (list (concat org-path "inbox.org"))
                            (directory-files-recursively (concat org-path "projects") "\\.org$")
                            (directory-files-recursively (concat org-path "daily") "\\.org$")))
  ;; refile は org-agenda-files（projects 配下含む）の見出しレベル2までを対象にする
  (org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  ;; capture テンプレート（%a を付けない）
  (org-capture-templates
   '(("t" "タスク" entry
      (file+headline org-default-notes-file "Tasks")
      "* TODO %?\n %u\n"
      :empty-lines 1)
     ("l" "ログ" item
      (file (lambda () (expand-file-name (format-time-string "daily/%Y-%m-%d.org") org-path)))
      "- %<%H:%M>：%?")))

  :bind
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture))

;; 画像をインラインで表示
(setq org-startup-with-inline-images t)


(defun org-insert-title ()
  "org-mode でタイトルを出力するショートカット"
  (interactive)
  (insert "#+TITLE: "))
(define-key org-mode-map (kbd "C-c t") 'org-insert-title)

(provide 'mk-org)
