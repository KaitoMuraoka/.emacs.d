;;; ============================================================
;;; claude-code-ide
;;; ============================================================

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")

  :custom
  ;; ターミナルバックエンド: vterm
  (claude-code-ide-terminal-backend 'vterm)
  ;; Claude ウィンドウを右側に表示（'right / 'left / 'bottom / 'top）
  (claude-code-ide-window-side 'right)
  ;; ediff を使ったファイル差分表示を有効化
  (claude-code-ide-use-ide-diff t)

  :bind
  ;; C-c C-' : コマンドメニューを開く（transient）
  ("C-c C-'" . claude-code-ide-menu)
  ;; C-c A s : 現在のプロジェクトで Claude を起動
  ("C-c A s" . claude-code-ide)
  ;; C-c A c : 直近の会話を続ける
  ("C-c A c" . claude-code-ide-continue)
  ;; C-c A r : 過去の会話を選んで再開
  ("C-c A r" . claude-code-ide-resume)
  ;; C-c A b : Claude バッファへ切り替え
  ("C-c A b" . claude-code-ide-switch-to-buffer)

  :config
  ;; Emacs の xref・project などのツールを Claude から利用可能にする
  (claude-code-ide-emacs-tools-setup))


(provide 'mk-claude-code-ide)
