;;; --- -*- lexical-binding: t -*-

;; auto-completeの設定
(when (require 'auto-complete-config nil t)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default)
  (setq ac-use-menu-map t)
  (setq ac-ignore-case nil))

(provide 'mk-auto-complete)
