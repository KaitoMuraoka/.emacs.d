;;; mk-vterm --- -*- lexical-binding: t -*-
(use-package vterm
  :ensure t
  :custom
  (vterm-max-scrollback 10000)        ; スクロールバック行数
  (vterm-kill-buffer-on-exit t)       ; シェル終了時にバッファも消す
  (vterm-shell "/bin/zsh")            ; 起動するシェル
  (vterm-buffer-name-string "vterm: %s") ; タイトルをバッファ名に反映
  :config
  ;; Emacs 側に渡したいキーを追加する
  (add-to-list 'vterm-keymap-exceptions "M-o")
  :bind
  (:map vterm-mode-map
        ("C-y" . vterm-yank)))

(provide 'mk-vterm)
