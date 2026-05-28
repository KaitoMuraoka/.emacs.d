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

;; ディスク上のファイルが変更されたら自動的にバッファを再読み込みする
(global-auto-revert-mode 1)

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

;;折り返しをデフォルトにする
(setq-default truncate-lines nil)
(setq-default org-startup-truncated nil);; org-mode ではデフォルト折り返ししないので


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

;; Setup DDSKK
(use-package ddskk
  :ensure t
  :bind ("C-x C-j" . skk-mode)
  :custom
  (skk-large-jisyo "~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/skk-jisyo.utf8")
  (skk-large-jisyo "~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/SKK-JISYO.L")
  (skk-sticky-key ";")
  (skk-show-inline t)
  (skk-dcomp-activate t)
  (skk-egg-like-newline t)
  (skk-isearch-mode-enable 'always))

(provide 'mk-base)
