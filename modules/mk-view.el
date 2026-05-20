;;; ============================================================
;;; 外観（透明化・ガラス効果）
;;; ============================================================
(set-default-coding-systems 'utf-8)
;; フォント（HackGen は日本語グリフ内包のため fontset 設定不要）
(set-face-attribute 'default nil :family "HackGen Console" :height 140)
;; 絵文字・天気記号（☁ ⛅ 🌧 等）は HackGen 非収録のため Apple Color Emoji へフォールバック
(when (display-graphic-p)
  (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") nil 'prepend)
  (set-fontset-font t '(#x2600 . #x26FF) (font-spec :family "Apple Color Emoji") nil 'prepend)
  (set-fontset-font t '(#x1F300 . #x1FAFF) (font-spec :family "Apple Color Emoji") nil 'prepend))

;; GUI/TUI の外観
;;(load-theme 'modus-vivendi t)
(use-package gruvbox-theme
  :straight (:host github :repo "Greduan/emacs-theme-gruvbox"))
(load-theme 'gruvbox-dark-medium t)

;; TUI時はターミナルのマウスイベントを受け取る
(unless (display-graphic-p)
  (load-theme 'modus-vivendi t)
  (set-face-background 'default "unspecified-bg")
  (set-face-background 'line-number "unspecified-bg")
  (set-face-background 'line-number-current-line "unspecified-bg")
  (xterm-mouse-mode 1))

;; メニューバーを非表示
(menu-bar-mode 0)

;; ツールバーを非表示
(tool-bar-mode 0)

;; ピンチジェスチャーによるフォントサイズ変更を無効化
(global-set-key (kbd "<pinch>") 'ignore)

;; splash.svg の :scale default が Retina 環境でフレーム高を超え
;; use-fancy-splash-screens-p が nil を返す問題を修正する。
;; SVG が描画可能な場合は常にロゴを表示するよう advice でバイパスする。
(when (display-graphic-p)
  (advice-add 'use-fancy-splash-screens-p :override
              (lambda ()
                (and (display-graphic-p)
                     (ignore-errors
                       (create-image (fancy-splash-image-file)))))))

(provide 'mk-view)
