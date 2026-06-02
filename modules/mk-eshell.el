(defun mk-eshell--git-branch ()
  "カレントディレクトリの git ブランチ名を返す（無ければ空文字）。"
  (let ((branch (when (fboundp 'vc-git--symbolic-ref)
                  (ignore-errors (vc-git--symbolic-ref default-directory)))))
    (if (and branch (not (string-empty-p branch)))
        (format " (%s)" branch)
      "")))

(defun mk-eshell-prompt ()
  "eshell 用のカスタムプロンプトを返す。"
  (let ((status eshell-last-command-status))
    (concat
     (abbreviate-file-name (eshell/pwd))
     (mk-eshell--git-branch)
     (if (zerop status) " " (format " [%d] " status))
     (if (zerop (user-uid)) "# " "λ "))))

(setq eshell-prompt-function #'mk-eshell-prompt)
(setq eshell-highlight-prompt t);; プロンプトの部分をハイライトにする
;; 履歴
(setq eshell-history-size 10000)
(setq eshell-hist-ignoredups t)
(setq eshell-save-history-on-exit t)
;; 補完
(setq eshell-cmpl-ignore-case t);; 補完時に大文字小文字を区別しない
(setq eshell-cmpl-cycle-completions nil)
(setq eshell-scroll-to-bottom-on-input 'this)


;;; alias
(setq eshell-command-aliases-list
      (append
       (list
        (list "gs" "git status $*")
        (list "gc" "git config user.name; git config user.email")
        (list "c" "clear-scrollback")
        ;; eza 系
        (list "ls" "eza --icons --git $*")
        (list "la" "eza -a --icons --git $*")
        (list "ll" "eza -aahl --icons --git $*")
        )))

;; visual commands（全画面コマンドは term バッファで開く）
(with-eval-after-load 'em-term
  (dolist (cmd '("htop" "top" "less" "more" "ssh" "tmux" "nvim" "vim"))
    (add-to-list 'eshell-visual-commands cmd)))

(provide 'mk-eshell)
