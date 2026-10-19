;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; DDSKK
;;; ============================================================
(use-package ddskk
  :bind ("C-x C-j" . skk-mode)
  :init
  (setq default-input-method "japanese-skk")
  :custom
  ;; macSKK がインストール済みの辞書を共用する
  (skk-large-jisyo "~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/SKK-JISYO.L")
  (skk-sticky-key ";")
  (skk-show-inline t)
  (skk-dcomp-activate t)
  (skk-egg-like-newline t)
  (skk-isearch-mode-enable 'always))

;; Emacsにフォーカスが移ったとき、macOSの入力ソースをABCに強制する
(defun my/force-ascii-input-source ()
  (start-process "input-source" nil
                 "/opt/homebrew/bin/im-select"
                 "com.apple.keylayout.ABC"))
(defun my/after-focus-change ()
  (when (frame-focus-state)
    (my/force-ascii-input-source)))
(add-function :after after-focus-change-function #'my/after-focus-change)

(provide 'mk-skk)
