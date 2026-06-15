;;; ============================================================
;;; org-mode 専用のscratch バッファ
;;; ============================================================
(defun my/org-scratch ()
  "org-mode 用の scratch バッファを開く"
  (interactive)
  (let ((buf (get-buffer-create "*org-scratch")))
    (with-current-buffer buf
      (unless (derived-mode-p 'org-mode)
        (org-mode)))
    (pop-to-buffer-same-window buf))
  )

(provide 'mk-org-scratch)
