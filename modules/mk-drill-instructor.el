;;; ============================================================
;;; 鬼軍曹.el (drill-instructor)
;;; ============================================================

(defun mk/drill-instructor-allow-tab (&rest _)
  "鬼軍曹のキーマップから TAB の禁止だけを取り除く。"
  (keymap-unset drill-instructor-key-map "<tab>" t))

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
  ;; TAB だけは見逃す（矢印・DEL・RET の禁止は維持）
  ;; 理由: 鬼軍曹.el は drill-instructor 呼び出しのたびに [tab] を登録し直すため、
  ;;       一度外すだけではバッファ切り替えで復活してしまう
  (advice-add 'drill-instructor :after #'mk/drill-instructor-allow-tab)
  ;; 起動直後のバッファにも適用する
  (drill-instructor t))

(provide 'mk-drill-instructor)
