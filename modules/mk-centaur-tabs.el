;;; mk-centaur-tabs.el --- -*- lexical-binding: t -*-

(use-package centaur-tabs
  :ensure t
  :demand
  :custom
  (centaur-tabs-enable-key-bindings t) ; C-c t プレフィックスのキーバインドを有効化
  (centaur-tabs-set-bar 'under)
  (centaur-tabs-set-modified-marker t)
  (centaur-tabs-set-icons t)
  (centaur-tabs-icon-type 'nerd-icons)
  :custom-face
  ;; 色を直書きせず nano-theme の face を継承し、OS の Dark/Light 切替に追従させる
  (centaur-tabs-default             ((t (:inherit header-line))))
  (centaur-tabs-selected            ((t (:inherit default))))
  (centaur-tabs-selected-modified   ((t (:inherit default))))
  (centaur-tabs-unselected          ((t (:inherit (nano-faded nano-subtle)))))
  (centaur-tabs-unselected-modified ((t (:inherit (nano-faded nano-subtle)))))
  (centaur-tabs-active-bar-face     ((t (:inherit nano-salient-i))))
  :config
  (centaur-tabs-mode t)
  :bind
  (:map centaur-tabs-mode-map
        ("C-<tab>"     . centaur-tabs-forward)
        ("C-S-<tab>"   . centaur-tabs-backward)
        ("C-<backtab>" . centaur-tabs-backward)))

(provide 'mk-centaur-tabs)
;;; mk-centaur-tabs.el ends here
