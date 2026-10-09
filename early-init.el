;; -*- lexical-binding: t; -*-
;; ~/.emacs.d/early-init.el

;; パッケージシステムの自動初期化を遅らせる
;; （init.el で手動で初期化するため）
(setq package-enable-at-startup nil)

;; 起動時のフレームパラメータを事前設定することで
;; UIのちらつきを防ぐ
(setq default-frame-alist
      '((menu-bar-lines . 0)          ; メニューバー非表示
        (fullscreen . fullheight)))    ; 高さを画面いっぱいに

;; 同梱 libgccjit が Darwin 27 から誤った macOS バージョン(18.0)を算出するため明示する
(when (eq system-type 'darwin)
  (setq native-comp-driver-options '("-mmacosx-version-min=27.0")))
