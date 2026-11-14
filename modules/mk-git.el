;;; mk-git.el --- -*- lexical-binding: t -*-

(use-package magit
  :ensure t
  :bind ("C-c g" . magit-status)
  )

(use-package git-gutter
  :ensure t
  :config
  (setq git-gutter:update-interval 2) ;2秒ごとに差分を更新
  ;; 記号のカスタマイズ（デフォルトでも動くが視認性を上げる）
  (setq git-gutter:added-sign    "+")
  (setq git-gutter:deleted-sign  "-")
  (setq git-gutter:modified-sign "~")
  (global-git-gutter-mode t)
  )

(provide 'mk-git)
;;; mk-git.el ends here
