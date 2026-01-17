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
  :doc "Disable backup and auto-save files"
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
   (treemacs-fringe-indicator-mode . t)))    ; 現在行にインジケーター表示

;; Treemacs + Evil 連携
(leaf treemacs-evil
  :doc "Evil integration for Treemacs"
  :ensure t
  :after (treemacs evil))

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

;;; --- 7. Ruby on Rails 開発環境 ---

;; ruby-mode: Emacs 標準の Ruby サポート
(leaf ruby-mode
  :doc "Major mode for editing Ruby files"
  :tag "builtin"
  :mode ("\\.rb\\'" "Rakefile" "Gemfile" "\\.rake\\'")
  :custom
  ((ruby-insert-encoding-magic-comment . nil))) ; マジックコメントを挿入しない

;; inf-ruby: IRB/Pry との連携
(leaf inf-ruby
  :doc "Run an inferior Ruby process in Emacs"
  :ensure t
  :hook (ruby-mode-hook . inf-ruby-minor-mode)
  :bind (:ruby-mode-map
         ("C-c C-s" . inf-ruby)         ; IRB を起動
         ("C-c C-r" . ruby-send-region) ; 選択範囲を送信
         ("C-c C-l" . ruby-load-file))) ; ファイルをロード

;; robe: Ruby コード補完と定義ジャンプ
(leaf robe
  :doc "Code navigation, documentation lookup and completion for Ruby"
  :ensure t
  :hook (ruby-mode-hook . robe-mode)
  :config
  (eval-after-load 'company
    '(push 'company-robe company-backends)))

;; rubocop: Ruby リンター連携
(leaf rubocop
  :doc "RuboCop integration for Emacs"
  :ensure t
  :hook (ruby-mode-hook . rubocop-mode)
  :bind (:ruby-mode-map
         ("C-c C-e" . rubocop-check-current-file)   ; 現在のファイルをチェック
         ("C-c C-a" . rubocop-autocorrect-current-file))) ; 自動修正

;; projectile: プロジェクト管理 (Rails 用の前提)
(leaf projectile
  :doc "Project navigation and management library"
  :ensure t
  :require t
  :global-minor-mode projectile-mode
  :custom
  ((projectile-completion-system . 'default))
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; projectile-rails: Rails プロジェクト専用のナビゲーション
(leaf projectile-rails
  :doc "Minor mode for Rails projects based on projectile"
  :ensure t
  :hook (projectile-mode-hook . projectile-rails-global-mode)
  :bind (:projectile-rails-mode-map
         ("C-c r m" . projectile-rails-find-model)       ; モデルへ移動
         ("C-c r c" . projectile-rails-find-controller)  ; コントローラへ移動
         ("C-c r v" . projectile-rails-find-view)        ; ビューへ移動
         ("C-c r h" . projectile-rails-find-helper)      ; ヘルパーへ移動
         ("C-c r s" . projectile-rails-find-spec)        ; スペックへ移動
         ("C-c r r" . projectile-rails-console)          ; Rails コンソール起動
         ("C-c r g" . projectile-rails-goto-gemfile)))   ; Gemfile へ移動

;; web-mode: ERB, HTML, CSS 等のテンプレート編集
(leaf web-mode
  :doc "Major mode for editing web templates"
  :ensure t
  :mode ("\\.erb\\'" "\\.html?\\'" "\\.css\\'" "\\.scss\\'")
  :custom
  ((web-mode-markup-indent-offset . 2)   ; HTML インデント
   (web-mode-css-indent-offset . 2)      ; CSS インデント
   (web-mode-code-indent-offset . 2)     ; Ruby/JS インデント
   (web-mode-enable-auto-pairing . t)    ; 自動ペアリング
   (web-mode-enable-css-colorization . t))) ; CSS カラー表示

;; yaml-mode: YAML 設定ファイル編集
(leaf yaml-mode
  :doc "Major mode for editing YAML files"
  :ensure t
  :mode ("\\.ya?ml\\'"))

;; rspec-mode: RSpec テスト実行
(leaf rspec-mode
  :doc "Minor mode for RSpec specifications"
  :ensure t
  :hook (ruby-mode-hook . rspec-mode)
  :bind (:rspec-mode-map
         ("C-c , v" . rspec-verify)              ; 現在のスペック実行
         ("C-c , a" . rspec-verify-all)          ; 全スペック実行
         ("C-c , s" . rspec-verify-single)       ; カーソル位置のテスト実行
         ("C-c , r" . rspec-rerun)               ; 最後のテスト再実行
         ("C-c , t" . rspec-toggle-spec-and-target))) ; テスト/実装を切り替え

;;; --- 8. Evil (Vim エミュレーション) ---

;; evil: Vim キーバインドを Emacs に導入
(leaf evil
  :doc "Extensible vi layer for Emacs"
  :ensure t
  :custom
  ((evil-want-integration . t)      ; 基本的な統合を有効化
   (evil-want-keybinding . t)       ; デフォルトのキーバインドを使用
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
  (evil-set-initial-state 'forge-post-mode 'emacs))    ; Forge 投稿

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
