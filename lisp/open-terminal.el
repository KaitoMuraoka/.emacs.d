;;; open-terminal.el --- 外部ターミナルでコマンドを起動するユーティリティ -*- lexical-binding: t; -*-

;; Author: KaitoMuraoka <https://github.com/KaitoMuraoka>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: terminals, tools
;; URL: https://github.com/KaitoMuraoka/emacs-open-terminal

;;; Commentary:
;; 外部ターミナル（WezTerm / Ghostty / Terminal.app）で任意のコマンドを
;; 非同期実行するユーティリティ関数を提供する。

;;; Code:

(defun my/open-terminal-with-command (dir command)
  "DIR をカレントディレクトリとして COMMAND を外部ターミナルで非同期実行する。
優先順位: WezTerm → Ghostty → Terminal.app"
  (let ((wezterm "/opt/homebrew/bin/wezterm"))
    (cond
     ;; WezTerm: CLI が利用可能
     ((file-executable-p wezterm)
      (start-process "claude-terminal" nil
                     wezterm "start" "--cwd" dir "--" "bash" "-c" command)
      (start-process "claude-terminal-focus" nil
                     "osascript" "-e" "tell application \"WezTerm\" to activate"))
     ;; Ghostty: osascript で新規ウィンドウを開いてコマンドを送る
     ((file-directory-p "~/Applications/Ghostty.app")
      (start-process "claude-terminal" nil
                     "osascript" "-e"
                     (format "tell application \"Ghostty\" to activate")))
     ;; Terminal.app: フォールバック
     (t
      (start-process "claude-terminal" nil
                     "osascript" "-e"
                     (format "tell application \"Terminal\" to do script \"cd %s && %s\""
                             (shell-quote-argument dir) command))
      (start-process "claude-terminal-focus" nil
                     "osascript" "-e" "tell application \"Terminal\" to activate")))))

(defun open-claude-code ()
  "現在のバッファのディレクトリで Claude Code を外部ターミナルで開く。"
  (interactive)
  (let ((dir (expand-file-name default-directory)))
    (my/open-terminal-with-command dir "claude")
    (message "Claude Code を起動しました: %s" dir)))

(global-set-key (kbd "C-c A t") #'open-claude-code)

(provide 'open-terminal)

;;; open-terminal.el ends here
