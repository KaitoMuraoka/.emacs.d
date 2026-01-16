;; --- 基本設定 ---
(setq inhibit-startup-message t) ; スタートアップ画面を表示しない
(column-number-mode t)           ; 列番号を表示
(global-display-line-numbers-mode t) ; 行番号を表示

;; --- 日本語フォント設定（例：macOS） ---
;; OSに合わせて調整が必要ですが、最近は標準でも結構綺麗です。

;; --- 背景色の設定 ---
(load-theme 'modus-vivendi t)

;; --- パッケージ管理の準備 ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Emacs サーバーを自動起動
;; これで、一度Emacsを起動したら、以降は`emacsclient` コマンドを使ってファイルを素早く起動することができます
(require 'server)
(unless (server-running-p)
  (server-start))
