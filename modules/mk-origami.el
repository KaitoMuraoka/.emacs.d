;; -*- lexical-binding: t; -*-

;;; ============================================================
;;; コード折りたたみ（origami）
;;; ============================================================

;; origami: コードブロックの折りたたみ
;; ruby-ts-mode は origami-parser-alist に無いため、
;; インデントベースのパーサーに自動フォールバックして折りたたむ
;; 例: C-c f f（トグル）/ C-c f c（全て閉じる）/ C-c f o（全て開く）
(use-package origami
  :hook (ruby-ts-mode . origami-mode)
  :bind (:map origami-mode-map
              ("C-c f f" . origami-recursively-toggle-node)
              ("C-c f o" . origami-open-all-nodes)
              ("C-c f c" . origami-close-all-nodes)
              ("C-c f u" . origami-undo)))

(provide 'mk-origami)
