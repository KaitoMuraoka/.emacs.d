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
   (scroll-bar-mode . nil))              ; スクロールバー非表示
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
