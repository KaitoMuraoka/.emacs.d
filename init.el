;; -*- lexical-binding: t; -*-

;;; ============================================================
;; straight.el ブートストラップ
;;; ============================================================

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; straight.el に use-package を管理させる
(straight-use-package 'use-package)

;; 全 use-package を自動的に straight で管理する
;; （既存の :ensure t と同じ感覚で使える）
(setq straight-use-package-by-default t)

;; org を組み込みとして扱う
;; 理由: straight.el が org をソースからビルドする際に lisp/ ディレクトリが
;;       存在しないケースがあり :pre-build エラーで init.el がアボートするため
(straight-use-package '(org :type built-in))

;; project を組み込みとして扱う
;; 理由: 依存パッケージ経由で straight が外部版をビルドすると
;;       "Feature 'project' is now provided by a different file" エラーが発生するため
(straight-use-package '(project :type built-in))

;; flymake を組み込みとして扱う
;; 理由: 同上。外部版との競合で起動エラーになるため
(straight-use-package '(flymake :type built-in))

;; Emacs 29 以降で組み込みになったパッケージを built-in として宣言する
;; 理由: 依存パッケージが外部版を引き込み、起動時に
;;       "Feature 'X' is now provided by a different file" エラーが連鎖するため
;; transient は agent-shell が新しい API（transient--set-layout 等）を使うため
;; built-in ではなく straight で外部版を管理する
(dolist (pkg '(xref eldoc seq eglot jsonrpc use-package))
  (straight-use-package `(,pkg :type built-in)))

;;; ============================================================
;; パッケージマネージャーの設定
;;; ============================================================
;; emacs info Japanese
(use-package info
  :ensure nil
  :config
  (add-to-list 'Info-directory-list "~/.emacs.d/info/"))

;;; ============================================================
;;; 環境変数（PATH）の引き継ぎ
;;; ============================================================
;; macOS の GUI Emacs はシェルの PATH を継承しないため
;; exec-path-from-shell でシェル環境を読み込む
;; gopls など go/bin に置かれるツールを認識させるために必要
(use-package exec-path-from-shell
  :config
  ;; GUI/TUI を問わず実行する
  ;; 理由: macOS は /etc/zprofile 経由で PATH を組み立てるため、
  ;;       起動方法によらずシェルから正しい PATH を取得する必要がある
  (exec-path-from-shell-initialize))

;;; ============================================================
;;; engine-mode
;;; ============================================================
(use-package engine-mode
  :ensure t
  :config
  (setq browse-url-chrome-program "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome");; Google Chrome に明示的に設定
  (defengine google
    "https://www.google.com/search?q=%s"
    :keybinding "g")
  (defengine github
    "https://github.com/search?q=%s"
    :keybinding "h")
  (defengine youtube
    "https://www.youtube.com/results?search_query=%s"
    :keybinding "y")
  (engine-mode t))

;;; ============================================================
;;; 基本的な Emacs の設定
;;; ============================================================
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
;; スタートアップ画面を表示しない
;;(setq inhibit-startup-screen t)

;; エラー音を無効化（視覚的なフラッシュも無効）
(setq ring-bell-function 'ignore)

;; バックアップファイル（file.txt~）を作らない
;; 作業ディレクトリが汚れるのを防ぐ
(setq make-backup-files nil)

;; 自動保存ファイル（#file.txt#）も作らない
(setq auto-save-default nil)

;; ロックファイル（.#file.txt）を作らない
;; 理由: macOS でロック/アンロック時に "Invalid argument" 警告が出るため
(setq create-lockfiles nil)

;; フォーカスが外れたら全ファイルバッファを保存する
;; 理由: 他アプリに切り替えた瞬間に変更が保存され、データ損失を防ぐ
(add-hook 'focus-out-hook
          (lambda ()
            (save-some-buffers t)))

;; 確認なしで保存
(setq magit-save-repository-buffers 'dontask)

;; yes/no を y/n で答えられるようにする
(setq use-short-answers t)

;; 現在行をハイライト
;; カーソル位置を視覚的に把握しやすくする
(global-hl-line-mode 1)

;; 行番号を表示（絶対行番号）
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; 対応する括弧をハイライト
(show-paren-mode 1)

;; タブではなくスペースを使う（多くの言語でのベストプラクティス）
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; 列数を表示
(column-number-mode 1)

;; ファイル末尾に改行を自動挿入
(setq require-final-newline t)

;; クリップボードをOSと共有する（コピー・ペースト両方向）
(setq select-enable-clipboard t)
;; ペースト前にクリップボードの内容をkill-ringに保存する
(setq save-interprogram-paste-before-kill t)

;;折り返しをデフォルトにする
(setq-default truncate-lines nil)

;; TUIモード（ターミナルエミュレータ）でのクリップボード連携
;; 理由: select-enable-clipboard はGUI専用のため、
;;       TUI環境では pbcopy/pbpaste 経由でOSクリップボードと接続する
;; call-process-region を使って同期実行することで、C-w / M-w 後に
;; 確実にOSクリップボードへ反映される
(unless (display-graphic-p)
  (setq interprogram-cut-function
        (lambda (text)
          ;; kill/copy 時に pbcopy へテキストを同期送信する
          (with-temp-buffer
            (insert text)
            (call-process-region (point-min) (point-max) "pbcopy"))))
  (setq interprogram-paste-function
        (lambda ()
          ;; yank 時に pbpaste からテキストを受け取る
          (let ((result (shell-command-to-string "pbpaste")))
            (unless (string-empty-p result) result)))))

;;; ============================================================
;;; 外観（透明化・ガラス効果）
;;; ============================================================
;; フォントサイズ
(set-face-attribute 'default nil :height 140)

;; GUI の外観
(load-theme 'modus-vivendi t)

;; TUI時はターミナルのマウスイベントを受け取る
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;;; ============================================================
;;; eat（Emulate A Terminal）
;;; ============================================================

(use-package eat
  :straight (:type git :host codeberg :repo "akib/emacs-eat"
             :files ("*.el" ("term" "term/*.ti") "integration"))

  :custom
  ;; ターミナル名（xterm-256color 互換）
  (eat-term-name "xterm-256color")
  ;; ログインシェルで起動する（vterm と同様の理由）
  (eat-shell (concat shell-file-name " -l"))

  :hook
  ;; eshell 内で eat を使う場合のシェル統合
  (eshell-load . eat-eshell-mode)

  :config
  ;; global-display-line-numbers-mode の内部 turn-on 関数をアドバイス
  ;; hook の実行順序に依存せず、eat バッファへの有効化を根本から阻止する
  (with-eval-after-load 'display-line-numbers
    (advice-add 'display-line-numbers--turn-on :around
                (lambda (orig-fn)
                  (unless (derived-mode-p 'eat-mode)
                    (funcall orig-fn)))))

  ;; eat バッファの表示をターミナルに近づける
  (add-hook 'eat-mode-hook
            (lambda ()
              (display-line-numbers-mode -1) ; 行番号を無効化
              (hl-line-mode -1)              ; カーソル行ハイライトを無効化
              (setq-local cursor-in-non-selected-windows nil)
              ;; 日本語環境では曖昧幅文字が全角扱いになり TUI レイアウトが崩れるため
              ;; 罫線・記号・Nerd Font の Private Use Area を半角幅に固定する
              (dolist (range '((#x2500 . #x257F)   ; Box Drawing
                               (#x2580 . #x259F)   ; Block Elements
                               (#x25A0 . #x25FF)   ; Geometric Shapes
                               (#x2600 . #x26FF)   ; Miscellaneous Symbols
                               (#x2700 . #x27BF)   ; Dingbats
                               (#xE000 . #xF8FF))) ; Private Use Area (Nerd Fonts)
                (set-char-table-range char-width-table range 1)))))

;;; ============================================================
;;; claude-code-ide
;;; ============================================================

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")

  :custom
  ;; ターミナルバックエンド: vterm
  (claude-code-ide-terminal-backend 'vterm)
  ;; Claude ウィンドウを右側に表示（'right / 'left / 'bottom / 'top）
  (claude-code-ide-window-side 'right)
  ;; ediff を使ったファイル差分表示を有効化
  (claude-code-ide-use-ide-diff t)

  :bind
  ;; C-c C-' : コマンドメニューを開く（transient）
  ("C-c C-'" . claude-code-ide-menu)
  ;; C-c A s : 現在のプロジェクトで Claude を起動
  ("C-c A s" . claude-code-ide)
  ;; C-c A c : 直近の会話を続ける
  ("C-c A c" . claude-code-ide-continue)
  ;; C-c A r : 過去の会話を選んで再開
  ("C-c A r" . claude-code-ide-resume)
  ;; C-c A b : Claude バッファへ切り替え
  ("C-c A b" . claude-code-ide-switch-to-buffer)

  :config
  ;; Emacs の xref・project などのツールを Claude から利用可能にする
  (claude-code-ide-emacs-tools-setup))

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

;;; ============================================================
;;; 補完システム
;;; ============================================================

;; Vertico: ミニバッファの補完UI
;; M-x や ファイル検索などの候補を縦リスト表示する
(use-package vertico
  :init
  (vertico-mode))

;; completion-ignore-case: ファイル名補完での大文字小文字無視
(setq completion-ignore-case t)

;; read-buffer-completion-ignore-case: バッファ名補完での無視
(setq read-buffer-completion-ignore-case t)

;; read-file-name-completion-ignore-case: ファイル名読み込み時の無視
(setq read-file-name-completion-ignore-case t)

;; Orderless: スペース区切りで複数キーワード検索できる補完スタイル
;; 例: "find file" → "file find" でも補完される
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)))

;; Marginalia: 補完候補の横に説明文を表示
(use-package marginalia
  :init
  (marginalia-mode))

;; Corfu: コード補完のポップアップUI（LSPの補完候補表示に使う）
(use-package corfu
  :custom
  (corfu-auto t)          ; 自動で補完候補を表示
  (corfu-auto-delay 0.3)  ; 0.3秒後に表示
  :init
  (global-corfu-mode))

;; corfu-terminal: ターミナル環境でCorfuの補完ポップアップを表示する
;; 理由: Corfuはデフォルトでchild frameを使うため、ターミナル（TUI）では動作しない
;;       corfu-terminalはオーバーレイで代替表示する
(use-package corfu-terminal
  :unless (display-graphic-p)
  :config
  (corfu-terminal-mode +1))

;; 閉じカッコの自動挿入
(electric-pair-mode 1)

;; yasnippet: スニペット（コードテンプレート）システム
;; タブストップ $1, $2... にカーソルが順番に移動する
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; yasnippet-snippets: 多数の言語の既製スニペット集
;; Swift, TypeScript, ELisp など主要言語のスニペットが含まれる
(use-package yasnippet-snippets)

;;; ============================================================
;;; LSP（Language Server Protocol）設定
;;; ============================================================

;; eglot は Emacs 29 組み込みの LSP クライアント
;; LSP = エディタとは独立した言語解析サーバーと通信する仕組み
;; これにより補完・定義ジャンプ・エラー表示が言語ごとに統一される
(use-package eglot
  :hook
  ;; 各言語モード起動時に自動でLSPを開始する
  ((swift-mode       . eglot-ensure)
   (typescript-mode  . eglot-ensure)
   (tsx-ts-mode      . eglot-ensure)
   (go-mode          . eglot-ensure)
   (go-ts-mode       . eglot-ensure)
   (python-mode      . eglot-ensure)
   (python-ts-mode   . eglot-ensure))

  :config
  ;; Swift: sourcekit-lsp を使用
  ;; Xcode に含まれているので追加インストール不要
  (add-to-list 'eglot-server-programs
               '(swift-mode . ("xcrun" "sourcekit-lsp")))

  ;; TypeScript: typescript-language-server を使用
  ;; インストール: npm install -g typescript-language-server typescript
  (add-to-list 'eglot-server-programs
               '((typescript-mode tsx-ts-mode) .
                 ("typescript-language-server" "--stdio")))

  ;; Go: gopls を使用
  ;; インストール: go install golang.org/x/tools/gopls@latest
  (add-to-list 'eglot-server-programs
               '((go-mode go-ts-mode) . ("gopls")))

  ;; Python: jedi-language-server を使用
  ;; インストール: pip install jedi-language-server
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("jedi-language-server")))

  ;; orderless との相性問題を回避するため
  ;; eglot の補完カテゴリでは orderless を優先して使用する
  (add-to-list 'completion-category-overrides
               '(eglot (styles orderless basic)))
  (add-to-list 'completion-category-overrides
               '(eglot-capf (styles orderless basic)))

  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)           ; シンボルのリネーム
              ("C-c l a" . eglot-code-actions)      ; コードアクション
              ("C-c l f" . eglot-format-buffer)     ; フォーマット
              ("M-."     . xref-find-definitions)   ; 定義へジャンプ
              ("M-,"     . xref-pop-marker-stack))) ; ジャンプ前に戻る

;;; ============================================================
;;; 言語モード
;;; ============================================================

;; Swift サポート
;; swift-mode は MELPA から提供
(use-package swift-mode)

;; TypeScript サポート
(use-package typescript-mode
  :mode ("\\.ts\\'" . typescript-mode)
  :mode ("\\.tsx\\'" . tsx-ts-mode))

;; Go サポート
;; treesit-auto により go-ts-mode に自動リマップされる
;; 事前に必要: go install golang.org/x/tools/gopls@latest
(use-package go-mode
  :custom
  ;; go-ts-mode のデフォルトは 8 だが、tab-width 4 と合わせてタブ1個分にする
  (go-ts-mode-indent-offset 4)
  :hook
  ((go-mode    . (lambda ()
                   (add-hook 'before-save-hook #'eglot-format-buffer nil t)))
   (go-ts-mode . (lambda ()
                   (add-hook 'before-save-hook #'eglot-format-buffer nil t)))))


;;; ============================================================
;;; markdown-mode
;;; ============================================================
(use-package markdown-mode
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))

  :hook
  ;; # や * などのマークアップ記号をデフォルトで非表示にする
  (markdown-mode . markdown-toggle-markup-hiding)

  :custom
  ;; コードブロックの言語別フォントロックを有効化
  (markdown-fontify-code-blocks-natively t)

  :custom-face
  ;; 見出しレベルごとのフォントサイズ・色（modus-vivendi 配色）
  (markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.6 :weight bold :foreground "#79a8ff"))))
  (markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.4 :weight bold :foreground "#f78fe7"))))
  (markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.2 :weight bold :foreground "#00d3d0"))))
  (markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.1 :weight bold :foreground "#fba849"))))
  (markdown-header-face-5 ((t (:inherit markdown-header-face :height 1.05 :weight bold :foreground "#b6a0ff"))))
  (markdown-header-face-6 ((t (:inherit markdown-header-face :height 1.0 :weight bold :foreground "#9ac8e0")))))

;;; ============================================================
;;; Git サポート
;;; ============================================================

;; Magit: Emacs 上で Git を操作できる強力なツール
;; ターミナルを開かず Git の全操作が行える
(use-package magit
  :bind ("C-c g" . magit-status))
;;; バッファに依存せず、常にディレクトリを明示的に入力する
(defun magit-status-ask-dir ()
  "Enter the directory to open Magit"
  (interactive)
  (magit-status (read-directory-name "Repo: " "~/")))

;; git-gutter: バッファ左端（ガター）に git の差分を記号で表示する
;;
;;   +  追加された行（git で言う +）
;;   -  削除された行
;;   ~  変更された行
;;
;; これにより「どこを編集したか」をコミット前に視覚的に把握できる
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode) ; プログラム用モードでのみ有効化
  :config
  (setq git-gutter:update-interval 2) ; 2秒ごとに差分を更新

  ;; 記号のカスタマイズ（デフォルトでも動くが視認性を上げる）
  (setq git-gutter:added-sign    "+")
  (setq git-gutter:deleted-sign  "-")
  (setq git-gutter:modified-sign "~")

  :bind
  ("C-c v n" . git-gutter:next-hunk)     ; 次の変更箇所へ
  ("C-c v p" . git-gutter:previous-hunk) ; 前の変更箇所へ
  ("C-c v r" . git-gutter:revert-hunk)   ; この変更を git で元に戻す
  ("C-c v s" . git-gutter:stage-hunk))   ; この変更だけをステージング

;;; ============================================================
;;; which-key
;;; ============================================================
(use-package which-key
  :config
  (setq which-key-idle-delay 0.8)

  ;; 'bottom は廃止。side-window を使い、表示位置を bottom に指定する
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-location 'bottom) ; 'top 'left 'right も選べる

  (which-key-mode))

;;; ============================================================
;;; eat ターミナル キーバインド
;;; ============================================================

;; C-c v e : 新しい eat ターミナルを開く
(global-set-key (kbd "C-c v e") #'eat)
;; C-c v o : 別ウィンドウで eat を開く
(global-set-key (kbd "C-c v o") #'eat-other-window)

;;; ============================================================
;;; vterm
;;; ============================================================

(use-package vterm
  :custom
  ;; スクロールバッファの最大行数
  (vterm-max-scrollback 10000)
  ;; プロセス終了時にバッファを自動で閉じる
  (vterm-kill-buffer-on-exit t)
  ;; コピーモード時に C-c C-c でターミナルに戻る
  (vterm-copy-exclude-prompt t)
  ;; ログインシェルで起動する
  ;; 理由: Terminal.app と同様に ~/.zprofile を読み込み
  ;;       Homebrew 等の PATH を引き継ぐため
  (vterm-shell (concat shell-file-name " -l"))

  :config
  ;; vterm バッファでは行番号・hl-line を無効化
  (add-hook 'vterm-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)
              (hl-line-mode -1)))

  :bind
  ;; C-c v t : vterm を開く
  ("C-c v t" . vterm))

(use-package vterm-toggle
  :after vterm
  :custom
  ;; vterm ウィンドウを下部に表示
  (vterm-toggle-fullscreen-p nil)
  (vterm-toggle-scope 'project)

  :config
  (add-to-list 'display-buffer-alist
               '((lambda (buf _)
                   (with-current-buffer buf (eq major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3)))

  :bind
  ;; C-c v v : vterm をトグル（下部に表示）
  ("C-c v v" . vterm-toggle)
  ;; C-c v f : 次の vterm バッファへ切り替え
  ("C-c v f" . vterm-toggle-forward)
  ;; C-c v b : 前の vterm バッファへ切り替え
  ("C-c v b" . vterm-toggle-backward))

 ;;; ============================================================
;;; プロジェクト管理
;;; ============================================================

;; project.el は Emacs 組み込み
;; Git リポジトリをプロジェクトとして認識し
;; プロジェクト内のファイル検索などができる
(global-set-key (kbd "C-c p f") #'project-find-file)
(global-set-key (kbd "C-c p b") #'project-switch-to-buffer)

;;; ============================================================
;;; 自作関数
;;; ============================================================

(defun my/post-to-x (text)
  "Intent URL を Emacs 内のWebKitブラウザで開く"
  (interactive
   (list (read-string "Xに投稿: ")))
  (let* ((encoded (url-hexify-string text))
         (url (concat "https://x.com/intent/tweet?text=" encoded)))
    (browse-url url)))

;;; ============================================================
;;; org-mode
;;; ============================================================

(use-package org
  :straight (:type built-in)

  :custom
  (org-directory "~/org")
  (org-default-notes-file "~/org/notes.org")
  (org-todo-keywords '((sequence "TODO" "DOING" "|" "DONE")))
  (org-clock-into-drawer t)
  (org-clock-persist t)
  (org-clock-persist-query-resume nil)
  (org-capture-templates
   '(("t" "タスク" entry
      (file org-default-notes-file)
      "* TODO %?\n"
      :empty-lines 1)))

  :config
  (org-clock-persistence-insinuate)

  :bind
  ("C-c a"       . org-agenda)
  ("C-c c"       . org-capture)
  ("C-c C-x C-i" . org-clock-in)
  ("C-c C-x C-o" . org-clock-out)
  ("C-c C-x C-j" . org-clock-goto))

;;; ============================================================
;;; よく使うキーバインド
;;; ============================================================

;; バッファの切り替えを便利に
(global-set-key (kbd "C-c b") #'switch-to-buffer)

;; ウィンドウ移動
(global-set-key (kbd "M-o") #'other-window)

;; macOS: Cmd+V でペースト
(global-set-key (kbd "s-v") #'yank)

;; IME切り替えとMarkのキーバインドをEmacsデフォルトに戻す
(global-set-key (kbd "C-SPC")  #'toggle-input-method)
(global-set-key (kbd "C-\\") #'set-mark-command)

;; C-h を削除キー（バックスペース相当）に変更する
;; 理由: ターミナル環境でバックスペースが C-h として送られることが多く、
;;       直感的な操作に合わせる
;; ヘルプは C-? で引き続き使用可能
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key (kbd "C-?") 'help-command)

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
