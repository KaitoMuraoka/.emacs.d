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
  (org-default-notes-file (concat org-icloud-path "note.org")))

(provide 'mk-org)
