;;; ============================================================
;;; 外観（透明化・ガラス効果）
;;; ============================================================
(set-default-coding-systems 'utf-8)
;; フォント（HackGen は日本語グリフ内包のため fontset 設定不要）
(set-face-attribute 'default nil :family "HackGen" :height 140)
;; 絵文字・天気記号（☁ ⛅ 🌧 等）は HackGen 非収録のため Apple Color Emoji へフォールバック
(when (display-graphic-p)
  (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") nil 'prepend)
  (set-fontset-font t '(#x2600 . #x26FF) (font-spec :family "Apple Color Emoji") nil 'prepend)
  (set-fontset-font t '(#x1F300 . #x1FAFF) (font-spec :family "Apple Color Emoji") nil 'prepend))

;; GUI の外観
(load-theme 'modus-vivendi t)

;; TUI時はターミナルのマウスイベントを受け取る
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

(provide 'mk-view)
