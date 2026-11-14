;;; mk-view.el --- -*- lexical-binding: t -*-
(column-number-mode t) ;; カラム番号を追加

;; リージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
(defun count-lines-and-chars ()
  (if mark-active
      (format "(%dlines,%dchars) "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
    ""))

(setq-default mode-line-format
              (cons '(:eval (count-lines-and-chars))
                    (default-value 'mode-line-format)))

(setq frame-title-format "%f") ;; タイトルバーにフルパスを表示する
;;(global-display-line-numbers-mode t)  ;;グローバル
(add-hook 'prog-mode-hook 'display-line-numbers-mode) ;;プログラミングモードのみ

;; paren-mode：対応する括弧を強調して表示する
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expressionは括弧内も強調表示
(setq show-paren-style 'expression)
;; フェイスを変更する
(set-face-background 'show-paren-match nil)
(set-face-underline 'show-paren-match "darkgreen")
(setq-default cursor-type 'bar) ;; カーソル変更 縦棒(|) 'bar
(set-default-coding-systems 'utf-8) ;; 文字コードの既定を UTF-8 にする
(setq-default line-spacing '(2 . 3));; (上 . 下) で振り分けて文字を行の中央に置く（Emacs 31 以降）
(set-face-attribute 'default nil :family "HackGen Console" :height 120) ;; フォント（HackGen は日本語グリフ内包のため fontset 設定不要）

;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
  (menu-bar-mode 0))

(provide 'mk-view)
;;; mk-view.el ends here
