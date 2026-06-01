;;; ============================================================
;;; eshell（Emacs Lisp 製シェル）
;;; ============================================================
;; 素の eshell として独立運用する。eat 統合（eat-eshell-mode）は使わず、
;; 全画面コマンドは eshell 標準の term バッファ（eshell-visual-commands）で開く。

;;; ------------------------------------------------------------
;;; プロンプト
;;; ------------------------------------------------------------
;; 短縮ディレクトリ + git ブランチ + 終了ステータス + プロンプト記号 を表示する。
;; git ブランチは外部プロセスを起動せず vc-mode 経由で取得する。

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

(use-package eshell
  :ensure nil
  :custom
  ;; プロンプト
  (eshell-prompt-function #'mk-eshell-prompt)
  (eshell-prompt-regexp "^[^λ#\n]*[λ#] ")
  (eshell-highlight-prompt t)
  ;; 履歴
  (eshell-history-size 10000)
  (eshell-hist-ignoredups t)
  (eshell-save-history-on-exit t)
  ;; 補完
  (eshell-cmpl-ignore-case t)
  (eshell-cmpl-cycle-completions nil)
  (eshell-scroll-to-bottom-on-input 'this))

;;; ------------------------------------------------------------
;;; エイリアス（zshrc から eshell で有用なものだけ移植）
;;; ------------------------------------------------------------
;; init で完結させるため alias ファイルではなく eshell-command-aliases-list に登録する。

(with-eval-after-load 'em-alias
  (dolist (alias '(("gs" "git status $*")
                   ("gc" "git config user.name; git config user.email")
                   ("c"  "clear-scrollback")
                   ;; eza 系（zshrc の ls 系エイリアスに対応）
                   ("ls" "eza --icons --git $*")
                   ("la" "eza -a --icons --git $*")
                   ("ll" "eza -aahl --icons --git $*")
                   ("lt" "eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons $*")))
    (add-to-list 'eshell-command-aliases-list alias)))

;;; ------------------------------------------------------------
;;; visual commands（全画面コマンドは term バッファで開く）
;;; ------------------------------------------------------------

(with-eval-after-load 'em-term
  (dolist (cmd '("htop" "top" "less" "more" "ssh" "tmux" "nvim" "vim"))
    (add-to-list 'eshell-visual-commands cmd)))

(provide 'mk-eshell)
