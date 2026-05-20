;;; ============================================================
;;; org-mode
;;; ============================================================
(defconst org-icloud-path
  "/Users/kaito.muraoka/Library/Mobile Documents/com~apple~CloudDocs/org/")
(global-set-key (kbd "C-c o") (lambda () (interactive) (dired org-icloud-path)))
(use-package org
  :straight (:type built-in)

  :custom
  (org-directory org-icloud-path)
  (org-default-notes-file (concat org-icloud-path "notes.org"))
  (org-todo-keywords '((sequence "TODO" "DOING" "|" "DONE")))
  (org-clock-into-drawer t)
  (org-clock-persist t)
  (org-clock-persist-query-resume nil)
  (org-capture-templates
   '(("t" "タスク" entry
      (file org-default-notes-file)
      "* TODO %?\n"
      :empty-lines 1)))

  :config
  (org-clock-persistence-insinuate)

  :bind
  ("C-c a"       . org-agenda)
  ("C-c c"       . org-capture)
  ("C-c C-x C-i" . org-clock-in)
  ("C-c C-x C-o" . org-clock-out)
  ("C-c C-x C-j" . org-clock-goto))

(provide 'mk-org)
