;;; ============================================================
;;; 基本的な Emacs の設定
;;; ============================================================
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
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
(add-hook 'focus-out-hook
          (lambda ()
            (save-some-buffers t)))
;; 確認なしで保存
(setq magit-save-repository-buffers 'dontask)
;; yes/no を y/n で答えられるようにする
(setq use-short-answers t)
;; ディスク上のファイルが変更されたら自動的にバッファを再読み込みする
(global-auto-revert-mode 1)
;; 現在行をハイライト
;; カーソル位置を視覚的に把握しやすくする
(global-hl-line-mode 1)
;; 行番号を表示（見た目の行を数える相対行番号）
;; visual-line-mode で折り返した継続行も1行として数えるため、
;; C-n / C-p の移動量と行番号の数え方が一致する
(setq display-line-numbers-type 'visual)
;; ガター幅を固定する。
;; display-line-numbers-width-start はモード有効化時の行数から「最小幅」を
;; 一度だけ決めるだけなので、追記でバッファが伸びたり、カーソルが桁の境目
;; （9→10, 99→100）を跨ぐたびに幅が再計算されて本文がずれる。
;; 最小幅を直接指定し、grow-only で一度広がった幅が縮まないようにする。
(setq display-line-numbers-width 3)
(setq display-line-numbers-grow-only t)
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
;; 段落を物理改行なしで視覚的に折り返す
;; ファイル上は1段落=1行のまま保たれ、C-a / C-e / C-k が
;; 見た目の行に対して働くようになる
(global-visual-line-mode 1)
;; 文末はスペース1つで区切る
;; 「文末2スペース」の慣習を廃し、M-a / M-e の文単位ナビゲーションを機能させる
(setq sentence-end-double-space nil)
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
;; Emacsにフォーカスが移ったとき、macOSの入力ソースをABCに強制する
(defun my/force-ascii-input-source ()
  (start-process "input-source" nil
                 "/opt/homebrew/bin/im-select"
                 "com.apple.keylayout.ABC"))
(defun my/after-focus-change ()
  (when (frame-focus-state)
    (my/force-ascii-input-source)))
(add-function :after after-focus-change-function #'my/after-focus-change)
(provide 'mk-base)
