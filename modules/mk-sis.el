;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; sis
;;; ============================================================
;; コマンド入力時は英数に戻し、カーソル色で入力ソースを示す
(use-package sis
  :config
  (sis-ism-lazyman-config
   "com.apple.keylayout.ABC"
   "jp.monokakido.inputmethod.Kawasemi4.japanese")
  (sis-global-respect-mode 1)
  (sis-global-cursor-color-mode 1))

(provide 'mk-sis)
