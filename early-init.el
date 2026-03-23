;; ~/.emacs.d/early-init.el

;; パッケージシステムの自動初期化を遅らせる
;; （init.el で手動で初期化するため）
(setq package-enable-at-startup nil)

;; 起動時のフレームパラメータを事前設定することで
;; UIのちらつきを防ぐ
(setq default-frame-alist
      '((menu-bar-lines . 0)))        ; メニューバー非表示
