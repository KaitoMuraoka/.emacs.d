(use-package websocket
  :straight t)

(use-package monet
  :straight (:type git :host github :repo "stevemolitor/monet" :branch "main" :depth 1)
  :config
  (monet-mode 1))

(use-package claude-code
  :straight (:type git :host github :repo "stevemolitor/claude-code.el" :branch "main" :depth 1
                   :files ("*.el" (:exclude "images/*")))
  :custom
  (claude-code-terminal-backend 'eat)
  (claude-code-display-window-fn
   (lambda (buffer)
     (display-buffer buffer '((display-buffer-in-side-window)
                              (side . right)
                              (window-width . 90)))))
  :bind-keymap
  ("C-c a" . claude-code-command-map)
  :bind
  (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode))
  :config
  (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
  (claude-code-mode))

(provide 'mk-claude-code)
