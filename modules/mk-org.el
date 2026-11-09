;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; org-mode
;;; ============================================================
(defconst org-path
  "~/org/")
(defconst org-work-path
  "~/org-work/")
(global-set-key (kbd "C-c o") (lambda () (interactive) (dired org-path)))

(defun mk/org-work-available-p ()
  "仕事用ディレクトリ（org-work-path）が存在すれば non-nil を返す。"
  (file-directory-p (expand-file-name org-work-path)))

(when (mk/org-work-available-p)
  (global-set-key (kbd "C-c O") (lambda () (interactive) (dired org-work-path))))

(defun mk/org-journal-path ()
  "私用 silo（org-path）の今日のジャーナルのパスを返す。
現在のバッファの .dir-locals.el に左右されないよう、ディレクトリを明示する。"
  (let ((denote-directory (expand-file-name org-path))
        (denote-journal-directory (expand-file-name "journal" org-path)))
    (denote-journal-path-to-new-or-existing-entry)))

(defun mk/org-work-journal-path ()
  "仕事用 silo（org-work-path）の今日のジャーナルのパスを返す。"
  (let ((denote-directory (expand-file-name org-work-path))
        (denote-journal-directory (expand-file-name "journal" org-work-path)))
    (denote-journal-path-to-new-or-existing-entry)))

(use-package org
  :straight (:type built-in)

  :custom
  (org-directory org-path)
  (org-default-notes-file (concat org-path "inbox.org"))
  ;; タスクの状態: 未着手 → 対応中 → 完了
  (org-todo-keywords '((sequence "TODO" "WIP" "|" "DONE")))
  (org-todo-keyword-faces '(("WIP" . (:foreground "orange" :weight bold))))
  ;; agenda は各 silo の inbox.org と、直下・journal 配下の Denote ノートを対象にする
  ;; ディレクトリ指定にして、起動後に作成されたファイルも参照時に拾われるようにする
  ;; ディレクトリからは Denote のファイル名（識別子で始まるもの）だけを拾い、README.org などは除く
  (org-agenda-file-regexp "\\`[0-9]\\{8\\}T[0-9]\\{6\\}.*\\.org\\'")
  ;; 存在しないパスがあると agenda 起動時に削除を求められ、その削除で一覧が init.el に保存されてしまうため除く
  (org-agenda-files (seq-filter #'file-exists-p
                                (list (concat org-path "inbox.org")
                                      org-path
                                      (concat org-path "journal")
                                      (concat org-work-path "inbox.org")
                                      org-work-path
                                      (concat org-work-path "journal"))))
  ;; refile は org-agenda-files の見出しレベル2までを対象にする
  (org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  ;; capture テンプレート（%a を付けない）
  (org-capture-templates
   `(("t" "タスク" entry
      (file+headline org-default-notes-file "Tasks")
      "* TODO %?\n %u\n"
      :empty-lines 1)
     ("l" "ログ" item
      (file+headline mk/org-journal-path "ログ")
      "- %<%H:%M>：%?")
     ,@(when (mk/org-work-available-p)
         `(("T" "仕事のタスク" entry
            (file+headline ,(concat org-work-path "inbox.org") "Tasks")
            "* TODO %?\n %u\n"
            :empty-lines 1)
           ("L" "仕事のログ" item
            (file+headline mk/org-work-journal-path "ログ")
            "- %<%H:%M>：%?")))))

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
