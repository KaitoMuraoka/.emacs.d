;;; mk-centaur-tabs.el --- -*- lexical-binding: t -*-

(use-package centaur-tabs
  :ensure t
  :demand
  :custom
  (centaur-tabs-enable-key-bindings t) ; C-c t プレフィックスのキーバインドを有効化
  (centaur-tabs-headline-match "box")
  (centaur-tabs-set-bar 'under)
  (centaur-tabs-set-modified-marker t)
  (centaur-tabs-set-icons t)
  (centaur-tabs-icon-type 'nerd-icons)
  :config
  (centaur-tabs-mode t))

(provide 'mk-centaur-tabs)
;;; mk-centaur-tabs.el ends here
