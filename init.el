;;; --- 1. インフラ設定 (leaf のセットアップ) ---
(eval-and-compile
  (setq package-archives '(("org"   . "https://orgmode.org/elpa/")
                           ("melpa" . "https://melpa.org/packages/")
                           ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init (leaf-keywords-init)))

;;; --- 2. 基本的な振る舞いと見た目 ---
(leaf emacs
  :custom
  ((inhibit-startup-message . t)         ; スタートアップ画面非表示
   (column-number-mode . t)              ; 列番号表示
   (scroll-bar-mode . nil)               ; スクロールバー非表示
   (display-line-numbers-type . t)         ; デフォルトは絶対行番号
   ;; macOS: Option キーをメタキーとして使用
   (mac-option-modifier . 'meta)
   (mac-command-modifier . 'super))      ; Command は super に
  :config
  (global-display-line-numbers-mode t))  ; 行番号表示

(leaf files
  :doc "Disable backup and auto-save file"
  :tag "builtin"
  :custom
  ((make-backup-files . nil)    ; init.el~ を作らない
   (auto-save-default . nil)))  ; #init.el# を作らない

;; --- 真っ黒な背景設定 ---
(leaf modus-themes
  :doc "High contrast themes with pure black background"
  :ensure t
  :custom
  ((modus-themes-vivendi-color-overrides . '((bg-main . "#000000"))))
  :config
  (load-theme 'modus-vivendi t))

;;; --- 3. サーバー設定 (emacsclient連携) ---
(leaf server
  :doc "Emacs server for emacsclient"
  :tag "builtin"
  :require server
  :config
  (unless (server-running-p)
    (server-start)))

;;; --- 4. ご要望の機能 (paren & company) ---

;; paren: 対応する括弧の強調表示
(leaf paren
  :doc "Highlight matching parentheses"
  :tag "builtin"
  :custom ((show-paren-delay . 0))
  :global-minor-mode show-paren-mode)

;; company: 高速な自動補完
(leaf company
  :doc "Modular text completion framework"
  :ensure t
  :leaf-defer nil
  :bind ((:company-active-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("<tab>" . company-complete-selection)))
  :custom
  ((company-idle-delay . 0)
   (company-minimum-prefix-length . 1)
   (company-selection-wrap-around . t))
  :global-minor-mode global-company-mode)

;; Magit: 最強のGitインターフェース
(leaf magit
  :ensure t
  :bind (("C-x g" . magit-status)) ; C-x g で Git 操作画面を開く
  :custom
  ((magit-display-buffer-function . 'magit-display-buffer-same-window-except-diff-v1)))

;; Forge: GitHub/GitLab Issue・PR を Magit から操作
(setq auth-sources '("~/.authinfo"))
(leaf forge
  :ensure t
  :after magit)

;; git-gutter: 変更行を左側に表示
(leaf git-gutter
  :ensure t
  :global-minor-mode global-git-gutter-mode
  :custom
  ((git-gutter:modified-sign . "~") ; 変更箇所のマーク
   (git-gutter:added-sign . "+")    ; 追加箇所のマーク
   (git-gutter:deleted-sign . "-")) ; 削除箇所のマーク
  :custom-face
  ((git-gutter:modified . '((t (:foreground "yellow"))))
   (git-gutter:added    . '((t (:foreground "green"))))
   (git-gutter:deleted  . '((t (:foreground "red"))))))

;;; --- 5. ファイル操作 (Treemacs) ---

;; Treemacs: サイドバーにディレクトリツリーを表示
(leaf treemacs
  :doc "A tree layout file explorer for Emacs"
  :ensure t
  :bind (("C-x t t" . treemacs)              ; ツリー表示のトグル
         ("C-x t 1" . treemacs-select-window) ; Treemacs ウィンドウに移動
         ("C-x t d" . treemacs-select-directory)) ; ディレクトリを選択して表示
  :custom
  ((treemacs-width . 30)                     ; サイドバーの幅
   (treemacs-follow-mode . t)                ; カーソル位置に追従
   (treemacs-filewatch-mode . t)             ; ファイル変更を監視
   (treemacs-fringe-indicator-mode . t))     ; 現在行にインジケーター表示
  :config
  ;; TreemacsでEvilを無効にし、Emacsキーバインドを使用
  (with-eval-after-load 'evil
    (evil-set-initial-state 'treemacs-mode 'emacs)))

;; Treemacs + Magit 連携
(leaf treemacs-magit
  :doc "Magit integration for Treemacs"
  :ensure t
  :after (treemacs magit))

;;; --- 6. Clojure/Lisp開発を快適にする追加設定 ---

;; rainbow-delimiters: 括弧を階層ごとに色分け
(leaf rainbow-delimiters
  :doc "Colorize brackets according to their depth"
  :ensure t
  :hook (prog-mode-hook . rainbow-delimiters-mode))

;; which-key: キー操作のヒントを表示
(leaf which-key
  :doc "Display available keybindings in popup"
  :ensure t
  :global-minor-mode which-key-mode)

;;; --- 7. Swift 開発 ---

;; swift-mode: Swift のシンタックスハイライトとインデント
(leaf swift-mode
  :doc "Major mode for Apple's Swift programming language"
  :ensure t
  :mode "\\.swift\\'"
  :custom
  ((swift-mode:basic-offset . 4)))  ; インデント幅

;; eglot: LSP クライアント (Emacs 29+ でビルトイン)
(leaf eglot
  :doc "Emacs client for Language Server Protocol"
  :tag "builtin"
  :hook ((swift-mode-hook . eglot-ensure)
         (nix-mode-hook . eglot-ensure))    ; Nix ファイルで自動起動
  :config
  ;; sourcekit-lsp を Swift の LSP サーバーとして登録
  (add-to-list 'eglot-server-programs
               '(swift-mode . ("/usr/bin/sourcekit-lsp")))
  ;; nixd を Nix の LSP サーバーとして登録
  (add-to-list 'eglot-server-programs
               '(nix-mode . ("nixd"))))

;;; --- 8. Nix 開発 ---

;; nix-mode: Nix のシンタックスハイライトとインデント
(leaf nix-mode
  :doc "Major mode for editing Nix expressions"
  :ensure t
  :mode "\\.nix\\'"
  :custom
  ((nix-indent-function . 'nix-indent-line))) ; 標準のインデント関数を使用

;; envrc: direnv 統合 (nix-shell / nix develop の環境を自動読み込み)
(leaf envrc
  :doc "Support for direnv which operates buffer-locally"
  :ensure t
  :hook (after-init-hook . envrc-global-mode)
  :bind (:envrc-mode-map
         ("C-c e" . envrc-command-map))       ; C-c e でコマンドマップを開く
  :config
  ;; direnv の環境変更時にメッセージを表示
  (setq envrc-show-summary-in-minibuffer t))

;;; --- 9. Org-mode ---

;; org: Emacs のアウトライナー・タスク管理ツール
(leaf org
  :doc "Outline-based notes management and organizer"
  :tag "builtin"
  :bind (("C-c a" . org-agenda)     ; アジェンダを開く
         ("C-c c" . org-capture)    ; クイックキャプチャ
         ("C-c l" . org-store-link)) ; リンクを保存
  :custom
  ((org-directory . "~/org")              ; org ファイルのルートディレクトリ
   (org-agenda-files . '("~/org"))        ; アジェンダに含めるファイル/ディレクトリ
   (org-default-notes-file . "~/org/notes.org") ; デフォルトのメモファイル
   (org-startup-indented . t)             ; インデント表示を有効化
   (org-startup-folded . 'content)        ; 起動時は見出しのみ表示
   (org-hide-leading-stars . t)           ; 余分な * を非表示
   (org-log-done . 'time)                 ; TODO 完了時にタイムスタンプを記録
   (org-return-follows-link . t)          ; RET でリンクを開く
   (org-todo-keywords . '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
   ;; LOGBOOK ドロワー設定（チャット風メモ）
   (org-log-into-drawer . t)              ; ノートを LOGBOOK ドロワーに格納
   (org-log-note-clock-out . nil)         ; クロックアウト時のノートは不要
   (org-log-state-notes-insert-after-drawers . nil) ; ドロワーの先頭にノートを追加
   ;; ソースブロック設定
   (org-src-fontify-natively . t)         ; コードブロック内でシンタックスハイライト
   (org-src-tab-acts-natively . t)        ; コードブロック内でタブが言語に応じて動作
   (org-src-preserve-indentation . t)     ; コードブロックのインデントを保持
   (org-edit-src-content-indentation . 0)) ; C-c ' で編集時の追加インデントなし
  :config
  ;; org ディレクトリが存在しない場合は作成
  (unless (file-exists-p org-directory)
    (make-directory org-directory t))

  ;; Capture テンプレート
  (setq org-capture-templates
        '(("t" "Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a")
          ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
           "* %?\n  %U")
          ("j" "Journal" entry (file+datetree "~/org/journal.org")
           "* %?\n  %U")))

  ;; org-babel: コードブロック実行の設定
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (swift . t)))  ; Swift を有効化

  ;; コードブロック実行時の確認を省略（任意）
  (setq org-confirm-babel-evaluate nil)

  ;; org-tempo: コードブロックの簡単挿入 (<s TAB で #+begin_src など)
  (require 'org-tempo)

  ;; コードブロックテンプレートを追加
  ;; <n TAB で nix ブロック, <sh TAB で shell ブロック
  (add-to-list 'org-structure-template-alist '("n" . "src nix"))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("ba" . "src bash"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp")))

;; ob-swift: org-babel で Swift を実行するためのパッケージ
(leaf ob-swift
  :doc "Org-babel functions for Swift"
  :ensure t
  :after org)

;;; --- 10. Evil (Vim エミュレーション) ---

;; evil: Vim キーバインドを Emacs に導入
(leaf evil
  :doc "Extensible vi layer for Emacs"
  :ensure t
  :custom
  ((evil-want-integration . t)      ; 基本的な統合を有効化
   (evil-want-keybinding . t)       ; デフォルトのキーバインドを使用
   (evil-want-minibuffer . nil)     ; minibuffer では Evil を無効化
   (evil-want-C-u-scroll . t)       ; C-u で半ページ上スクロール (Vim風)
   (evil-want-C-i-jump . t)         ; C-i でジャンプリスト進む
   (evil-undo-system . 'undo-redo)) ; Emacs 28+ のネイティブ undo-redo を使用
  :config
  (evil-mode 1)

  ;; Evil ステートに応じて行番号タイプを切り替え
  (defun my/evil-relative-line-numbers ()
    "Vi 操作時は相対行番号"
    (setq-local display-line-numbers 'relative))
  (defun my/evil-absolute-line-numbers ()
    "Emacs 操作時は絶対行番号"
    (setq-local display-line-numbers t))
  (add-hook 'evil-normal-state-entry-hook #'my/evil-relative-line-numbers)
  (add-hook 'evil-visual-state-entry-hook #'my/evil-relative-line-numbers)
  (add-hook 'evil-motion-state-entry-hook #'my/evil-relative-line-numbers)
  (add-hook 'evil-insert-state-entry-hook #'my/evil-relative-line-numbers)
  (add-hook 'evil-emacs-state-entry-hook #'my/evil-absolute-line-numbers)

  ;; 以下のモードでは Evil を無効化し、素の Emacs キーバインドを使用
  (evil-set-initial-state 'text-mode 'emacs)           ; txt ファイル
  (evil-set-initial-state 'markdown-mode 'emacs)       ; Markdown
  (evil-set-initial-state 'gfm-mode 'emacs)            ; GitHub Flavored Markdown
  (evil-set-initial-state 'html-mode 'emacs)           ; HTML
  (evil-set-initial-state 'mhtml-mode 'emacs)          ; HTML (Emacs 25+)
  (evil-set-initial-state 'nxml-mode 'emacs)           ; XML
  (evil-set-initial-state 'sgml-mode 'emacs)           ; SGML/マークアップ全般
  (evil-set-initial-state 'git-commit-mode 'emacs)     ; Git コミットメッセージ
  (evil-set-initial-state 'git-rebase-mode 'emacs)     ; Git rebase
  (evil-set-initial-state 'lisp-interaction-mode 'emacs) ; *scratch* バッファ
  ;; Magit/Forge: 独自のキーバインドを持つため Evil を無効化
  (evil-set-initial-state 'magit-mode 'emacs)          ; Magit 全般
  (evil-set-initial-state 'forge-topic-mode 'emacs)    ; Forge トピック
  (evil-set-initial-state 'forge-post-mode 'emacs)    ; Forge 投稿
  ;; Org-mode: 標準キーバインドの方が使いやすい
  (evil-set-initial-state 'org-mode 'emacs)           ; Org ファイル
  (evil-set-initial-state 'org-agenda-mode 'emacs)    ; Org アジェンダ
  ;; Dired: ファイル操作は Emacs キーバインドの方が使いやすい
  (evil-set-initial-state 'dired-mode 'emacs))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
