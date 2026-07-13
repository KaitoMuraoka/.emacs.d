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
  ;; capture テンプレート（%a を付けない）
  (org-capture-templates
   '(("t" "タスク" entry
      (file org-default-notes-file)
      "* TODO %?\n %u\n"
      :empty-lines 1)))

  :bind
  ("C-c a" . org-agenda))

;; 画像をインラインで表示
(setq org-startup-with-inline-images t)

(provide 'mk-org)
