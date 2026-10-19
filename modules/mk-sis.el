;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; sis
;;; ============================================================
;; コマンド入力時は英数に戻し、カーソル色で入力ソースを示す
(use-package sis
  :config
  (sis-ism-lazyman-config
   "com.apple.keylayout.ABC"
   "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese")
  (sis-global-respect-mode 1)
  (sis-global-cursor-color-mode 1)
  ;; フォーカス時にバッファごとの入力ソースを復元すると下の ABC 固定と競合するため止める
  ;; ponytail: sis の内部関数に依存。sis 更新で名前が変わったら advice が空振りする
  (advice-add 'sis--respect-focus-in-handler :override #'ignore))

;; Emacsにフォーカスが移ったとき、macOSの入力ソースをABCに強制する
(defun my/force-ascii-input-source ()
  (start-process "input-source" nil
                 "/opt/homebrew/bin/im-select"
                 "com.apple.keylayout.ABC"))
(defun my/after-focus-change ()
  (when (frame-focus-state)
    (my/force-ascii-input-source)))
(add-function :after after-focus-change-function #'my/after-focus-change)

(provide 'mk-sis)
