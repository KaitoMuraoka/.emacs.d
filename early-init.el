;; ~/.emacs.d/early-init.el

;; パッケージシステムの自動初期化を遅らせる
;; （init.el で手動で初期化するため）
(setq package-enable-at-startup nil)

;; 起動時のフレームパラメータを事前設定することで
;; UIのちらつきを防ぐ
(setq default-frame-alist
      '((tool-bar-lines . 1)    ; ツールバー非表示
        (menu-bar-lines . 1)    ; メニューバー非表示
        (vertical-scroll-bars . nil))) ; スクロールバー非表示
