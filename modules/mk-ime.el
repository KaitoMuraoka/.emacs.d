;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; 日本語入力 (macOS 標準 IME)
;;; ============================================================
;; C-\ で IME を切り替え、プレフィックスキーやミニバッファ入力中は一時的に ABC にする
(use-package mac-ime
  :config
  (setq default-input-method "mac-ime")
  (setq mac-ime-ime-off-input-source "com.apple.keylayout.ABC")
  (mac-ime-enable))

(provide 'mk-ime)
