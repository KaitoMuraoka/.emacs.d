;;; ============================================================
;;; xwidgets (内蔵 WebKit ブラウザ)
;;; ============================================================

(defun mk-xwidgets-google (query)
  "QUERY を Google 検索し、結果を内蔵 WebKit で開く。"
  (interactive "sGoogle: ")
  (xwidget-webkit-browse-url
   (format "https://www.google.com/search?q=%s"
           (url-hexify-string query))))

;; xwidgets は Emacs 同梱の機能で、GUI かつ xwidget サポート付きで
;; ビルドされている場合のみ動作する。TUI や非対応ビルドでロードしても
;; 害がないようガードする。
(use-package xwidget
  :ensure nil
  :if (and (display-graphic-p) (featurep 'xwidget-internal))
  :custom
  ;; browse-url 経由のリンク・検索結果を Emacs 内 WebKit で開く
  ;; engine-mode (mk-engine-mode) の検索結果もこちらに流れる
  (browse-url-browser-function #'xwidget-webkit-browse-url)
  ;; Cookie をセッション間で永続化する
  (xwidget-webkit-cookie-file
   (expand-file-name "xwidget-cookies" user-emacs-directory))
  :bind
  (("C-c w w" . xwidget-webkit-browse-url)
   ("C-c w b" . xwidget-webkit-bookmark-jump-new-session)
   ("C-c w g" . mk-xwidgets-google)
   :map xwidget-webkit-mode-map
   ("n" . xwidget-webkit-scroll-up-line)
   ("p" . xwidget-webkit-scroll-down-line)
   ("f" . xwidget-webkit-forward)
   ("b" . xwidget-webkit-back)
   ("r" . xwidget-webkit-reload)
   ("g" . xwidget-webkit-browse-url)
   ("y" . xwidget-webkit-copy-selection-as-kill)
   ("c" . xwidget-webkit-current-url)))

(provide 'mk-xwidgets)
