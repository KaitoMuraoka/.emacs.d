;;; ============================================================
;;; org-mode
;;; ============================================================
(defconst org-icloud-path
  "~/Library/Mobile Documents/com~apple~CloudDocs/org/")
(global-set-key (kbd "C-c o") (lambda () (interactive) (dired org-icloud-path)))

(use-package org
  :straight (:type built-in)

  :custom
  (org-directory org-icloud-path)
  (org-default-notes-file (concat org-icloud-path "note.org"))
  ;; agenda はタスクを書き込む note.org のみを対象にする
  (org-agenda-files (list (concat org-icloud-path "note.org")))
  ;; capture テンプレート（%a を付けない）
  (org-capture-templates
   '(("t" "タスク" entry
      (file+headline org-default-notes-file "Tasks")
      "* TODO %?\n %u\n"
      :empty-lines 1)
     ("k" "ナレッジ" entry
      (file "knowledge.org")
      "* %?\n  # Wrote on %U"
      :empty-lines 1)))

  :bind
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture))

;; 画像をインラインで表示
(setq org-startup-with-inline-images t)

(provide 'mk-org)
