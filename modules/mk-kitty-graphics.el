;;; ============================================================
;;; kitty-graphics (terminal Emacs での画像表示)
;;; ============================================================

(use-package kitty-graphics
  :straight (:type git :host github :repo "cashmeredev/kitty-graphics.el" :branch "master")
  ;; GUI Emacs では不要。ターミナル接続時のみ有効化する
  :if (not (display-graphic-p))

  :custom
  ;; auto: 起動時に Kitty / Sixel を自動判定する
  ;; Ghostty では Kitty backend が選ばれる
  (kitty-gfx-preferred-protocol 'auto)

  :config
  ;; global minor mode を有効化する
  (kitty-graphics-mode 1))

(provide 'mk-kitty-graphics)
