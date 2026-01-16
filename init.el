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
   (tool-bar-mode . nil)                 ; ツールバー非表示
   (menu-bar-mode . nil)                 ; メニューバー非表示
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

;;; --- 5. Clojure/Lisp開発を快適にする追加設定 ---

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

;;; --- 6. Evil (Vim エミュレーション) ---

;; evil: Vim キーバインドを Emacs に導入
(leaf evil
  :doc "Extensible vi layer for Emacs"
  :ensure t
  :custom
  ((evil-want-integration . t)      ; 基本的な統合を有効化
   (evil-want-keybinding . nil)     ; evil-collection 用に nil に設定
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
  (evil-set-initial-state 'lisp-interaction-mode 'emacs)) ; *scratch* バッファ

;; evil-collection: 各種モードに Evil キーバインドを追加
(leaf evil-collection
  :doc "A set of keybindings for evil-mode"
  :ensure t
  :after evil
  :config
  (evil-collection-init))

;; git-commit-mode で確実に Emacs ステートにする（フックを使用）
(leaf git-commit
  :after (evil magit)
  :hook
  ((git-commit-mode-hook . evil-emacs-state)
   (git-rebase-mode-hook . evil-emacs-state)))
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
