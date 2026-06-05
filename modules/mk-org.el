;;; ============================================================
;;; org-mode
;;; ============================================================
(defconst org-icloud-path
  "~/Library/Mobile Documents/com~apple~CloudDocs/org/")
(global-set-key (kbd "C-c o") (lambda () (interactive) (dired org-icloud-path)))

(defun mk-org-capture-note ()
  "ミニバッファからメモを入力し、note.org の日付ツリー末尾に時刻付きで追記する。"
  (interactive)
  (org-capture nil "n"))

(defun mk-org-note-datetree-end ()
  "今日の日付ツリーを見つけ（なければ作成し）、そのサブツリー末尾へ移動する。"
  (org-datetree-find-date-create
   (calendar-gregorian-from-absolute (org-today)))
  (org-end-of-subtree t))

(use-package org
  :straight (:type built-in)

  :custom
  (org-directory org-icloud-path)
  (org-default-notes-file (concat org-icloud-path "note.org"))
  (org-todo-keywords '((sequence "TODO" "DOING" "|" "DONE")))
  (org-clock-into-drawer t)
  (org-clock-persist t)
  (org-clock-persist-query-resume nil)
  (org-capture-templates
   '(("t" "タスク" entry
      (file org-default-notes-file)
      "* TODO %?\n"
      :empty-lines 1)
     ("n" "メモ" plain
      (file+function org-default-notes-file mk-org-note-datetree-end)
      "%<%H:%M>: %^{メモ}"
      :immediate-finish t)))

  :config
  (org-clock-persistence-insinuate)

  :bind
  ("C-c n"       . mk-org-capture-note)
  ("C-c a"       . org-agenda)
  ("C-c c"       . org-capture)
  ("C-c C-x C-i" . org-clock-in)
  ("C-c C-x C-o" . org-clock-out)
  ("C-c C-x C-j" . org-clock-goto))

(provide 'mk-org)
