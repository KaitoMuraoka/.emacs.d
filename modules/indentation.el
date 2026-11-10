;;; indentation.el --- -*- lexical-binding: t -*-
(setq-default tab-width 4) ;; TAB の表示幅。初期値は8

;; paren-mode：対応する括弧を強調して表示する
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expressionは括弧内も強調表示
(setq show-paren-style 'expression)
;; フェイスを変更する
(set-face-background 'show-paren-match nil)
(set-face-underline 'show-paren-match "darkgreen")


(provide 'indentation)
;;; indentation.el ends here
