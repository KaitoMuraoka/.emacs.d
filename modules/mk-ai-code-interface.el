;;; ============================================================
;;; ai-code-interface.el
;;; https://github.com/tninja/ai-code-interface.el
;;; ============================================================

(use-package ai-code
  :config
  (ai-code-set-backend 'claude-code)
  ;; Optional: use a narrower transient menu on smaller frames
  ;; (setq ai-code-menu-layout 'two-columns)
  (global-set-key (kbd "C-c a") #'ai-code-menu))


(provide 'mk-ai-code-interface)
