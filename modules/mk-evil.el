
;;; ============================================================
;;; Evil モード
;;; ============================================================

(use-package undo-fu)

(use-package evil
  :init
  (setq evil-want-keybinding nil)   ; evil-collection 使用前に必須
  (setq evil-want-C-u-scroll t)     ; C-u でページ半分スクロール（Vim デフォルト）
  (setq evil-undo-system 'undo-fu)

  :config
  (evil-mode 1)

  ;; org-mode / markdown-mode では Emacs キーバインドを維持する
  (evil-set-initial-state 'org-mode      'emacs)
  (evil-set-initial-state 'markdown-mode 'emacs)
  (evil-set-initial-state 'gfm-mode      'emacs)

  ;; Dired でも Emacs キーバインドを維持する
  (evil-set-initial-state 'dired-mode 'emacs)

  ;; ターミナルバッファでも Evil を無効化
  (evil-set-initial-state 'vterm-mode 'emacs)
  (evil-set-initial-state 'eat-mode   'emacs)

  ;; agent-shell: 各バッファタイプを個別に指定
  (evil-set-initial-state 'agent-shell-mode               'emacs)
  (evil-set-initial-state 'agent-shell-viewport-edit-mode 'emacs)
  (evil-set-initial-state 'agent-shell-viewport-view-mode 'emacs)
  (evil-set-initial-state 'agent-shell-diff-mode          'emacs))

(use-package evil-collection
  :after evil
  :config
  ;; evil-collection が Magit モードに対して独自の state を設定するのを防ぐため
  ;; Magit を除外してから初期化する
  (setq evil-collection-mode-list
        (remove 'dired (remove 'magit evil-collection-mode-list)))
  (evil-collection-init))

;; Magit: evil-collection の初期化後に hook で強制的に emacs state にする
;; evil-set-initial-state だけでは evil-collection に上書きされるため hook を使う
(with-eval-after-load 'magit
  (add-hook 'magit-mode-hook #'evil-emacs-state))

;; Dired: evil-collection の初期化後に hook で強制的に emacs state にする
(with-eval-after-load 'dired
  (add-hook 'dired-mode-hook #'evil-emacs-state))

;; emacsclient で開いたコミットメッセージバッファを Emacs state にする
;; git-commit パッケージは magit の一部で standalone ロード不可のため
;; find-file-hook でファイル名を直接検知する方式を使う
(add-hook 'find-file-hook
          (lambda ()
            (when (and buffer-file-name
                       (string-match-p
                        "COMMIT_EDITMSG\\|MERGE_MSG\\|SQUASH_MSG\\|NOTES_EDITMSG\\|git-rebase-todo"
                        (file-name-nondirectory buffer-file-name)))
              (evil-emacs-state))))

;; git-commit-mode hook: Magit 経由で開いた場合のフォールバック
(with-eval-after-load 'git-commit
  (add-hook 'git-commit-mode-hook #'evil-emacs-state))

;; with-editor-mode: Magit がエディタとして開くすべてのバッファに適用される minor mode
;; (COMMIT_EDITMSG 等が fundamental-mode のまま開かれるケースをカバーする)
(with-eval-after-load 'with-editor
  (add-hook 'with-editor-mode-hook #'evil-emacs-state))

(provide 'mk-evil)
