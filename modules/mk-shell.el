;;; ============================================================
;;; shell / eshell
;;; ============================================================

;; shell バッファでは行番号を表示しない
(add-hook 'shell-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)))

;; eshell バッファでは行番号を表示しない
(add-hook 'eshell-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)))

(provide 'mk-shell)
