;;; mk-ime --- -*- lexical-binding: t -*-

(use-package mac-ime
    :ensure t
    :config
    ;; input methodを"mac-ime"に設定
    (setq default-input-method "mac-ime")
    ;; モジュールの有効化 (イベント監視の開始)
    (mac-ime-enable))


(if (fboundp 'mac-auto-ascii-mode)
    ;; emacs-mac は標準機能で、プレフィックスキーやミニバッファ入力時に ABC を選ぶ
    (mac-auto-ascii-mode 1)
  ;; C-\ で IME を切り替え、プレフィックスキーやミニバッファ入力中は一時的に ABC にする
  (use-package mac-ime
    :config
    (setq default-input-method "mac-ime")
    (setq mac-ime-ime-off-input-source "com.apple.keylayout.ABC")
    (mac-ime-enable)))

(provide 'mk-ime)
