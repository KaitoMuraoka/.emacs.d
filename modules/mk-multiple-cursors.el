;;; mk-multiple-cursors.el --- -*- lexical-binding: t -*-
(use-package multiple-cursors
  :ensure t
  :bind
  ("C-S-c C-S-c" . 'mc/edit-lines)
  ("C->" . 'mc/mark-next-lines)
  ("C-<" . 'mc/mark-previous-like-this)
  ("C-c C-<" . 'mc/mark-all-like-this)
  )

(provide 'mk-multiple-cursors)
