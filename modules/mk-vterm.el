;;; ============================================================
;;; vterm
;;; ============================================================
(use-package vterm
  :custom
  ;; スクロールバッファの最大行数
  (vterm-max-scrollback 100000)
  ;; プロセス終了時にバッファを自動で閉じる
  (vterm-kill-buffer-on-exit t)
  ;; コピーモード時、コピー範囲からプロンプトを除外する
  (vterm-copy-exclude-prompt t)
  ;; 太字フォントを有効にする
  (vterm-disable-bold-font nil)
  ;; ログインシェルで起動する
  ;; 理由: Terminal.app と同様に ~/.zprofile を読み込み、
  ;;       Homebrew 等の PATH を引き継ぐため
  (vterm-shell (concat shell-file-name " -l"))
  :hook
  ;; vterm バッファでは行番号・hl-line を無効化
  (vterm-mode . (lambda ()
                  (display-line-numbers-mode -1)
                  (hl-line-mode -1)))
  :bind
  ;; C-c v t : vterm を開く
  ("C-c v t" . vterm))

(use-package vterm-toggle
  :after vterm
  :custom
  (vterm-toggle-fullscreen-p nil)
  (vterm-toggle-scope 'project)
  :config
  ;; vterm バッファは画面下部に高さ 30% で表示
  (add-to-list 'display-buffer-alist
               '((lambda (buf _)
                   (with-current-buffer buf (eq major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3)))
  :bind
  ("C-c v v" . vterm-toggle)
  ("C-c v f" . vterm-toggle-forward)
  ("C-c v b" . vterm-toggle-backward))

(provide 'mk-vterm)
