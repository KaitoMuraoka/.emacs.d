;;; ============================================================
;;; which-key
;;; ============================================================
(use-package which-key
  :config
  (setq which-key-idle-delay 0.8)

  ;; 'bottom は廃止。side-window を使い、表示位置を bottom に指定する
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-location 'bottom) ; 'top 'left 'right も選べる

  (which-key-mode))

(provide 'mk-which-key)
