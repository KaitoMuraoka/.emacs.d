;; -*- lexical-binding: t; -*-

;;; ============================================================
;;; マルチカーソル（multiple-cursors）
;;; ============================================================

;; multiple-cursors: 複数箇所の同時編集
;; 例: リージョン選択して C-S-c C-S-c（各行にカーソル）
;;     C->（次の同一文字列に追加）/ C-<（前の同一文字列に追加）
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(provide 'mk-multiple-cursors)
