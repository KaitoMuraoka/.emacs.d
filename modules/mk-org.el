;;; mk-org.el --- -*- lexical-binding: t -*-
(use-package org
  :custom
  (org-startup-with-link-previews t) ; 画像をインラインで表示
  (org-babel-load-languages '((emacs-lisp . t)
                              (shell . t)
                              (ruby . t)
                              (C . t)))
  :bind
  ("C-c l" . org-store-link)
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture))

(provide 'mk-org)
