;;; ============================================================
;;; 鬼軍曹.el (drill-instructor)
;;; ============================================================

;; MELPA 未登録のため GitHub から直接取得する
(use-package drill-instructor
  :straight (:type git :host github :repo "k1LoW/emacs-drill-instructor")
  ;; defadvice でバッファ切り替えをフックするため起動時に読み込む
  :demand t

  ;; 設定は :custom ではなく :config + setq で行う
  ;; 理由: 鬼軍曹.el の変数は defcustom ではなく素の defvar のため、
  ;;       custom theme 経由の :custom では値が反映されない
  :config
  ;; 鬼軍曹を常駐させる（バッファ切り替えごとに自動で有効化）
  (setq drill-instructor-global t)
  ;; ターミナル系バッファでは矢印キーなどをそのまま通す
  (setq drill-instructor-unset-major-mode-list
        '(term-mode vterm-mode eshell-mode shell-mode))
  ;; 起動直後のバッファにも適用する
  (drill-instructor t))

(provide 'mk-drill-instructor)
