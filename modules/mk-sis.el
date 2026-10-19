;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; sis
;;; ============================================================
;; コマンド入力時は英数に戻し、カーソル色で入力ソースを示す
(use-package sis
  :config
  ;; macism の同期呼び出しで入力が重くなるため、アイドル時の自動リフレッシュを止める
  (setq sis-auto-refresh-seconds nil)
  (sis-ism-lazyman-config
   "com.apple.keylayout.ABC"
   "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese")
  (sis-global-respect-mode 1)
  (sis-global-cursor-color-mode 1))

(provide 'mk-sis)
