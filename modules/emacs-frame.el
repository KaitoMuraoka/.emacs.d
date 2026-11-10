;;; emacs-frame.el --- -*- lexical-binding: t -*-
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

(provide 'emacs-frame)
;;; emacs-frame.el ends here
