;;; ============================================================
;;; agent-shell
;;; ============================================================
(use-package agent-shell
  :ensure t
  :ensure-system-package
  ((claude . "brew install claude-code")
   (claude-agent-acp . "npm install -g @zed-industries/claude-agent-acp"))
  :config
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))

  ;; agent-shell--start が呼ばれた瞬間のバッファの dir を保存する
  ;; 理由: start 内で default-directory が書き換わる前に正しいディレクトリを確保するため
  (defvar my/agent-shell--invoked-dir nil)

  (advice-add 'agent-shell--start :before
              (lambda (&rest _)
                (setq my/agent-shell--invoked-dir default-directory)))

  ;; Claude Code と同じパスエンコード: / と . を - に変換
  ;; 例: /Users/foo/.bar → -Users-foo--bar
  (defun my/agent-shell--encode-path (path)
    (replace-regexp-in-string "[/.]" "-" (directory-file-name path)))

  ;; 正しいプロジェクトルートをキャプチャ済みの dir から解決する
  (setq agent-shell-cwd-function
        (lambda ()
          (let* ((dir (or my/agent-shell--invoked-dir default-directory))
                 (proj (let ((default-directory dir))
                         (when-let ((p (project-current nil)))
                           (project-root p)))))
            (or proj dir))))

  ;; 保存先を ~/.claude/projects/{encoded}/agent-shell/{subdir} に変更
  ;; 理由: Claude Code と同じディレクトリ構造に合わせる
  (setq agent-shell-dot-subdir-function
        (lambda (subdir)
          (let* ((dir (or my/agent-shell--invoked-dir default-directory))
                 (proj (let ((default-directory dir))
                         (when-let ((p (project-current nil)))
                           (project-root p))))
                 (base (or proj dir))
                 (encoded (my/agent-shell--encode-path base))
                 (dest (expand-file-name
                        (file-name-concat "projects" encoded "agent-shell" subdir)
                        "~/.claude")))
            (make-directory dest t)
            dest))))
