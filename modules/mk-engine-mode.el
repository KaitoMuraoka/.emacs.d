;;; ============================================================
;;; engine-mode
;;; ============================================================
(use-package engine-mode
  :ensure t
  :config
  (setq browse-url-chrome-program "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome");; Google Chrome に明示的に設定
  (defengine google
    "https://www.google.com/search?q=%s"
    :keybinding "g")
  (defengine github
    "https://github.com/search?q=%s"
    :keybinding "h")
  (defengine youtube
    "https://www.youtube.com/results?search_query=%s"
    :keybinding "y")
  (engine-mode t))

(provide 'mk-engine-mode)
