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
(provide 'mk-olivetti)
