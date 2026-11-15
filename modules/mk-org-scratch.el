;;; mk-org-scratch.el --- -*- lexical-binding: t -*-

(defun org-scratch ()
  "org-mode 用scratch バッファ"
  (interactive)
  (let ((buf (get-buffer-create "*org-scratch*")))
	(with-current-buffer buf
	  (unless (derived-mode-p 'org-mode)
		(org-mode)))
	(pop-to-buffer-same-window buf))
	)

(provide 'mk-org-scratch)
