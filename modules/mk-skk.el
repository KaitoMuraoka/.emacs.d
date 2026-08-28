;;; ============================================================
;;; DDSKK
;;; ============================================================
(use-package ddskk
  :bind ("C-x C-j" . skk-mode)
  :custom
  ;; macSKK がインストール済みの辞書を共用する
  (skk-large-jisyo "~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/SKK-JISYO.L")
  (skk-sticky-key ";")
  (skk-show-inline t)
  (skk-dcomp-activate t)
  (skk-egg-like-newline t)
  (skk-isearch-mode-enable 'always))

(provide 'mk-skk)
