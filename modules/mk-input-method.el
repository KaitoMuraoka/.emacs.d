;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; 日本語入力
;;; ============================================================
;; C-\ で Emacs 内蔵の japanese 入力メソッドをオン/オフする
;; 変換中に K でカタカナ、qq で英数に切り替わる
(setq default-input-method "japanese")

;; 内蔵 IME と二重にならないよう、フォーカスが戻ったら macOS の入力ソースを ABC にする
(defun my/force-ascii-input-source ()
  (start-process "input-source" nil
                 "/opt/homebrew/bin/im-select"
                 "com.apple.keylayout.ABC"))
(defun my/after-focus-change ()
  (when (frame-focus-state)
    (my/force-ascii-input-source)))
(add-function :after after-focus-change-function #'my/after-focus-change)

(provide 'mk-input-method)
