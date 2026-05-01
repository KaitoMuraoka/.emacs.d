;;; ============================================================
;;; 外観（透明化・ガラス効果）
;;; ============================================================
;; フォントサイズ
(set-face-attribute 'default nil :height 140)

;; GUI の外観
(load-theme 'modus-vivendi t)

;; TUI時はターミナルのマウスイベントを受け取る
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

(provide 'mk-view)
