;;; ============================================================
;;; vterm
;;; ============================================================

(use-package vterm
  :custom
  ;; スクロールバッファの最大行数
  (vterm-max-scrollback 10000)
  ;; プロセス終了時にバッファを自動で閉じる
  (vterm-kill-buffer-on-exit t)
  ;; コピーモード時に C-c C-c でターミナルに戻る
  (vterm-copy-exclude-prompt t)
  ;; ログインシェルで起動する
  ;; 理由: Terminal.app と同様に ~/.zprofile を読み込み
  ;;       Homebrew 等の PATH を引き継ぐため
  (vterm-shell (concat shell-file-name " -l"))

  :config
  ;; vterm バッファでは行番号・hl-line を無効化
  (add-hook 'vterm-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)
              (hl-line-mode -1)))

  :bind
  ;; C-c v t : vterm を開く
  ("C-c v t" . vterm))

(use-package vterm-toggle
  :after vterm
  :custom
  ;; vterm ウィンドウを下部に表示
  (vterm-toggle-fullscreen-p nil)
  (vterm-toggle-scope 'project)

  :config
  (add-to-list 'display-buffer-alist
               '((lambda (buf _)
                   (with-current-buffer buf (eq major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3)))

  :bind
  ;; C-c v v : vterm をトグル（下部に表示）
  ("C-c v v" . vterm-toggle)
  ;; C-c v f : 次の vterm バッファへ切り替え
  ("C-c v f" . vterm-toggle-forward)
  ;; C-c v b : 前の vterm バッファへ切り替え
  ("C-c v b" . vterm-toggle-backward))

(provide 'mk-vterm)
