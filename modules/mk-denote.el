;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; denote (プライベート: ~/org, 仕事用: ~/org-work を silo として分ける)
;;; ============================================================
(use-package denote
  :hook (dired-mode . denote-dired-mode)
  :bind
  (("C-c n n" . denote)
   ("C-c n r" . denote-rename-file)
   ("C-c n l" . denote-link)
   ("C-c n b" . denote-backlinks)
   ("C-c n d" . denote-dired)
   ("C-c n g" . denote-grep))
  :custom
  (denote-directory (expand-file-name "~/org/"))
  :config
  (denote-rename-buffer-mode 1))

(use-package denote-silo
  :bind
  (("C-c n s" . denote-silo-select-silo-then-command)
   ("C-c n D" . denote-silo-dired))
  :custom
  (denote-silo-directories
   (list (expand-file-name "~/org/")
         (expand-file-name "~/org-work/"))))

(defun mk-denote-work-journal ()
  "仕事用 silo (~/org-work) の今日の日報を開く。無ければ作る。"
  (interactive)
  (let ((denote-directory (expand-file-name "~/org-work/")))
    (call-interactively #'denote-journal-new-or-existing-entry)))

(use-package denote-journal
  :bind (("C-c n j" . denote-journal-new-or-existing-entry)
         ("C-c n J" . mk-denote-work-journal))
  :hook (calendar-mode . denote-journal-calendar-mode)
  :custom
  ;; nil にして各 silo の denote-directory 直下に作る
  (denote-journal-directory nil)
  ;; 日報に _project のノートへのリンク一覧を入れる
  (denote-templates
   '((journal . "* 今日やったタスク\n#+BEGIN: denote-links :regexp \"_project\"\n#+END:\n")))
  :config
  (add-hook 'denote-journal-hook #'org-update-all-dblocks))

;; denote-links 動的ブロックを提供する
(use-package denote-org
  :defer t)

(provide 'mk-denote)
