;;; ============================================================
;;; 基本的な Emacs の設定
;;; ============================================================
(set-language-environment "Japanese")
;; emacs info Japanese
(use-package info
  :ensure nil
  :config
  (add-to-list 'Info-directory-list "~/.emacs.d/info/"))

(prefer-coding-system 'utf-8)
;; スタートアップ画面を表示しない
;;(setq inhibit-startup-screen t)

;; エラー音を無効化（視覚的なフラッシュも無効）
(setq ring-bell-function 'ignore)

;; バックアップファイル（file.txt~）を作らない
;; 作業ディレクトリが汚れるのを防ぐ
(setq make-backup-files nil)

;; 自動保存ファイル（#file.txt#）も作らない
(setq auto-save-default nil)

;; ロックファイル（.#file.txt）を作らない
;; 理由: macOS でロック/アンロック時に "Invalid argument" 警告が出るため
(setq create-lockfiles nil)

;; フォーカスが外れたら全ファイルバッファを保存する
;; 理由: 他アプリに切り替えた瞬間に変更が保存され、データ損失を防ぐ
(add-hook 'focus-out-hook
          (lambda ()
            (save-some-buffers t)))

;; 確認なしで保存
(setq magit-save-repository-buffers 'dontask)

;; yes/no を y/n で答えられるようにする
(setq use-short-answers t)

;; 現在行をハイライト
;; カーソル位置を視覚的に把握しやすくする
(global-hl-line-mode 1)

;; 行番号を表示（絶対行番号）
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; 対応する括弧をハイライト
(show-paren-mode 1)

;; タブではなくスペースを使う（多くの言語でのベストプラクティス）
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; 列数を表示
(column-number-mode 1)

;; ファイル末尾に改行を自動挿入
(setq require-final-newline t)

;; ペースト前にクリップボードの内容をkill-ringに保存する
(setq save-interprogram-paste-before-kill t)

;;折り返しをデフォルトにする
(setq-default truncate-lines nil)
(setq-default org-startup-truncated nil);; org-mode ではデフォルト折り返ししないので

;; クリップボードをOSと共有する（コピー・ペースト両方向）
(setq select-enable-clipboard t)
;; TUIモード（ターミナルエミュレータ）でのクリップボード連携
;; 理由: select-enable-clipboard はGUI専用のため、
;;       TUI環境では pbcopy/pbpaste 経由でOSクリップボードと接続する
;; call-process-region を使って同期実行することで、C-w / M-w 後に
;; 確実にOSクリップボードへ反映される
(unless (display-graphic-p)
  (setq interprogram-cut-function
        (lambda (text)
          ;; kill/copy 時に pbcopy へテキストを同期送信する
          (with-temp-buffer
            (insert text)
            (call-process-region (point-min) (point-max) "pbcopy"))))
  (setq interprogram-paste-function
        (lambda ()
          ;; yank 時に pbpaste からテキストを受け取る
          (let ((result (shell-command-to-string "pbpaste")))
            (unless (string-empty-p result) result)))))


(setq explicit-shell-file-name "/bin/zsh")
(setq shell-file-name "zsh")
(setq explicit-zsh-args '("--login" "-i"))
(setq shell-command-switch "-ic")
(setenv "SHELL" shell-file-name)

(provide 'mk-base)
