;;; ============================================================
;;; Git サポート
;;; ============================================================

;; Magit: Emacs 上で Git を操作できる強力なツール
;; ターミナルを開かず Git の全操作が行える
(use-package magit
  :bind ("C-c g" . magit-status))
;;; バッファに依存せず、常にディレクトリを明示的に入力する
(defun magit-status-ask-dir ()
  "Enter the directory to open Magit"
  (interactive)
  (magit-status (read-directory-name "Repo: " "~/")))

;; git-gutter: バッファ左端（ガター）に git の差分を記号で表示する
;;
;;   +  追加された行（git で言う +）
;;   -  削除された行
;;   ~  変更された行
;;
;; これにより「どこを編集したか」をコミット前に視覚的に把握できる
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode) ; プログラム用モードでのみ有効化
  :config
  (setq git-gutter:update-interval 2) ; 2秒ごとに差分を更新

  ;; 記号のカスタマイズ（デフォルトでも動くが視認性を上げる）
  (setq git-gutter:added-sign    "+")
  (setq git-gutter:deleted-sign  "-")
  (setq git-gutter:modified-sign "~")

  :bind
  ("C-c v n" . git-gutter:next-hunk)     ; 次の変更箇所へ
  ("C-c v p" . git-gutter:previous-hunk) ; 前の変更箇所へ
  ("C-c v r" . git-gutter:revert-hunk)   ; この変更を git で元に戻す
  ("C-c v s" . git-gutter:stage-hunk))   ; この変更だけをステージング

(provide 'mk-git)
