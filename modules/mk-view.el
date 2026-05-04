;;; ============================================================
;;; 外観（透明化・ガラス効果）
;;; ============================================================
;; フォント（HackGen は日本語グリフ内包のため fontset 設定不要）
(set-face-attribute 'default nil :family "HackGen" :height 140)

;; GUI の外観
(load-theme 'modus-vivendi t)

;; TUI時はターミナルのマウスイベントを受け取る
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

(provide 'mk-view)
