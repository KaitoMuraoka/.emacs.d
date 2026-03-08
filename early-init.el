;; ~/.emacs.d/early-init.el

;; パッケージシステムの自動初期化を遅らせる
;; （init.el で手動で初期化するため）
(setq package-enable-at-startup nil)

;; 起動時のフレームパラメータを事前設定することで
;; UIのちらつきを防ぐ
(setq default-frame-alist
      '((tool-bar-lines . nil)         ; ツールバー非表示
        (menu-bar-lines . 1)         ; メニューバー非表示
        (vertical-scroll-bars . nil) ; スクロールバー非表示
        (alpha . (92 . 80))))        ; フレーム全体を半透明（アクティブ:92%, 非アクティブ:80%）
;; macOSのVibrancy APIを使ってブラーをかける
;; 引数は見た目のスタイル（'active が最も一般的）
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
