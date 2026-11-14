;;; mk-auto-complete.el --- -*- lexical-binding: t -*-

;; auto-completeの設定
(use-package auto-complete
  :ensure t
  :demand t
  :bind (:map ac-mode-map ("M-TAB" . auto-complete))
  :custom
  (ac-use-menu-map t)
  (ac-ignore-case nil)
  :config
  (require 'auto-complete-config)
  (ac-config-default))

(provide 'mk-auto-complete)
;;; mk-auto-complete.el ends here
