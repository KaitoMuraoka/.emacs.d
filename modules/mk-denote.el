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
  (denote-rename-buffer-mode 1)
  ;; ~/org-work 配下では denote-directory を仕事用に切り替える(silo)
  (dir-locals-set-class-variables
   'mk-denote-work
   `((nil . ((denote-directory . ,(expand-file-name "~/org-work/"))))))
  (dir-locals-set-directory-class (expand-file-name "~/org-work/") 'mk-denote-work))

(use-package denote-silo
  :bind
  (("C-c n s" . denote-silo-select-silo-then-command)
   ("C-c n D" . denote-silo-dired))
  :custom
  (denote-silo-directories
   (list (expand-file-name "~/org/")
         (expand-file-name "~/org-work/"))))

(provide 'mk-denote)
