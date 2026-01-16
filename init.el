;; --- 基本設定 ---
(setq inhibit-startup-message t) ; スタートアップ画面を表示しない
(tool-bar-mode -1)               ; ツールバーを隠す
(menu-bar-mode -1)               ; メニューバーを隠す
(scroll-bar-mode -1)             ; スクロールバーを隠す
(column-number-mode t)           ; 列番号を表示
(global-display-line-numbers-mode t) ; 行番号を表示

;; --- 日本語フォント設定（例：macOS） ---
;; OSに合わせて調整が必要ですが、最近は標準でも結構綺麗です。

;; --- パッケージ管理の準備 ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
