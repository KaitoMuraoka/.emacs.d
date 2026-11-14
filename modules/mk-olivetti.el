;;; mk-olivetti.el --- -*- lexical-binding: t -*-
;;; ---- 執筆用（org-mode / Markdown のみ） ----
(use-package olivetti
  :ensure t
  :custom
  (olivetti-body-width 120)
  (olivetti-style 'fancy))
(use-package typo :ensure t)
(use-package markdown-mode :ensure t)

(defun my/writing-setup ()
  "執筆用バッファだけに適用する設定。"
  (visual-line-mode 1)
  (olivetti-mode 1)
  (typo-mode 1)
  (setq-local mode-line-format nil)
  (local-set-key (kbd "C-d") #'dictionary-lookup-definition))

(add-hook 'org-mode-hook #'my/writing-setup)
(add-hook 'markdown-mode-hook #'my/writing-setup)

(defun my/splash-center (&rest _)
  "起動画面と About 画面を olivetti で中央に寄せる。"
  (dolist (name '("*GNU Emacs*" "*About GNU Emacs*"))
    (when-let* ((buf (get-buffer name)))
      (with-current-buffer buf
        (setq-local olivetti-body-width 80)
        (olivetti-mode 1)))))
(advice-add 'fancy-startup-screen :after #'my/splash-center)
(advice-add 'fancy-about-screen :after #'my/splash-center)
(provide 'mk-olivetti)
