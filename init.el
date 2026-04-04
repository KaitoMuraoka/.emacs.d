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
  :if (memq window-system '(mac ns x))
  :config
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
(setq inhibit-startup-screen t)

;; エラー音を無効化（視覚的なフラッシュも無効）
(setq ring-bell-function 'ignore)

;; バックアップファイル（file.txt~）を作らない
;; 作業ディレクトリが汚れるのを防ぐ
(setq make-backup-files nil)

;; 自動保存ファイル（#file.txt#）も作らない
(setq auto-save-default nil)

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
(setq display-line-numbers-type 'visual)
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

;; コンソール時だけ背景を透明（ターミナルの背景をそのまま使う）
(unless (display-graphic-p)
  (set-face-background 'default "unspecified-bg")
  ;; 行番号の背景をターミナル背景に合わせて透明にする
  ;; 理由: TUIでは行番号エリアにテーマの背景色が残り浮いて見えるため
  (set-face-background 'line-number "unspecified-bg")
  (set-face-background 'line-number-current-line "unspecified-bg")
  ;; TUI時はターミナルのマウスイベントを受け取る
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
  ;; ターミナルバックエンド: eat
  (claude-code-ide-terminal-backend 'eat)
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
        (agent-shell-anthropic-make-authentication :login t)))

;;; ============================================================
;;; org-mode
;;; ============================================================
(use-package org
  :hook (org-mode . visual-line-mode)
  :custom
  (org-directory "~/org/")
  (org-agenda-files '("~/org/todo.org" "~/org/diary.org"))
  (org-todo-keywords
   '((sequence "TODO(t)" "DOING(i)" "|" "DONE(d)" "CANCEL(c)")))
  (org-startup-indented t)
  (org-hide-leading-stars t)
  (org-startup-folded 'content)
  (org-enforce-todo-checkbox-dependencies nil)

  ;; org-capture テンプレートもここに移動
  (org-capture-templates
   '(("d" "今日の日記" entry
      (file+olp+datetree "~/org/diary.org")
      "* %<%H:%M> %?\n"
      :empty-lines 1)
     ("t" "TODO追加" entry
      (file+headline "~/org/todo.org" "TODO")
      "** TODO %?\n  DEADLINE: %^{期限}t\n  %i\n"
      :empty-lines 1)
     ("m" "ミーティングメモ" entry
      (file+olp+datetree "~/org/diary.org")
      "* MTG: %^{タイトル}\n** 参加者: %?\n** 内容:\n** アクション:\n"
      :empty-lines 1)))

  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)))
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
   (python-ts-mode   . eglot-ensure)
   (emacs-lisp-mode  . eglot-ensure))

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

  ;; ELisp: Emacs 自体が LSP 的な機能を持つため
  ;; eglot-ensure を hook するだけで eldoc などが働く
  ;; (追加のサーバー設定は不要)

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
  (setq git-gutter:update-interval 0.5) ; 0.5秒ごとに差分を更新

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
;;; Claude Code CLIでコミットメッセージを生成する
;;; ============================================================
(defun my/ai-commit--generate-async (detail callback)
  "Claude CLI を非同期で呼び出す。
完了したら CALLBACK を (funcall callback message-string) で呼ぶ。
DETAIL が non-nil なら詳細形式。"
  (let* ((prompt
          (if detail
              "Generate a Git commit message in Japanese based strictly on the contents of `git diff --cached`. \
Format it as follows: First line: a concise one-line summary. \
Then a blank line. \
Then a detailed bullet-point list explaining what was changed and why. \
Output ONLY the commit message, no extra explanation."
              "Generate ONLY a one-line Git commit message in Japanese. \
The message should summarize what was changed and why, based strictly on the contents of `git diff --cached`. \
DO NOT add an explanation or a body. Output ONLY the commit summary line."))

         ;; プロセスの出力を受け取るための専用バッファ
         ;; " " で始まる名前は Emacs の慣習で「内部用の隠しバッファ」を意味する
         (output-buffer (generate-new-buffer " *ai-commit-output*"))

         ;; sentinel = プロセスの状態が変わったときに呼ばれるコールバック関数
         ;; proc: プロセスオブジェクト, event: "finished\n" / "exited abnormally..." 等の文字列
         (sentinel
          (lambda (proc event)
            (cond
             ;; 正常終了した場合のみ処理する
             ((string-prefix-p "finished" event)
              (let ((msg (with-current-buffer output-buffer
                           (string-trim (buffer-string)))))
                ;; 使い終わったバッファを解放
                (kill-buffer output-buffer)
                (if (string-empty-p msg)
                    (user-error "AI commit: claude returned empty output")
                  ;; ここで初めて magit を呼ぶ（非同期の「続き」）
                  (funcall callback msg))))

             ;; 異常終了した場合はエラーメッセージを表示
             ((string-prefix-p "exited abnormally" event)
              (kill-buffer output-buffer)
              (user-error "AI commit: claude failed — %s" event))))))

    (message "🤖 Generating AI commit message...")

    ;; make-process: ノンブロッキングでサブプロセスを起動する
    ;; start-process と違い、キーワード引数で読みやすく書ける
    (make-process
     :name    "ai-commit-claude"      ; プロセスの識別名（*process-list* に表示される）
     :buffer  output-buffer           ; stdout をここに蓄積する
     :command (list "claude"
                    "--no-session-persistence"
                    "--print"
                    prompt)
     :sentinel sentinel)))            ; 終了時に呼ぶ関数

(defun my/ai-commit ()
  "一行形式のAIコミットメッセージを非同期生成し、Magitのコミット編集バッファを開く。"
  (interactive)
  (my/ai-commit--generate-async
   nil  ; detail = false
   (lambda (msg)
     (magit-commit-create (list (concat "--message=" msg) "--edit")))))

(defun my/ai-commit-detail ()
  "詳細形式のAIコミットメッセージを非同期生成し、Magitのコミット編集バッファを開く。"
  (interactive)
  (my/ai-commit--generate-async
   t    ; detail = true
   (lambda (msg)
     (magit-commit-create (list (concat "--message=" msg) "--edit")))))

(with-eval-after-load 'magit-commit
  (transient-append-suffix 'magit-commit "c"
    '("A" "AI commit (one-line)"  my/ai-commit))
  (transient-append-suffix 'magit-commit "A"
    '("D" "AI commit (detail)"    my/ai-commit-detail)))


;;; ============================================================
;;; magit-gh
;;; ============================================================
(use-package magit-gh
  :ensure t
  :after magit)

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

;; C-c v t : 新しい eat ターミナルを開く
(global-set-key (kbd "C-c v t") #'eat)
;; C-c v o : 別ウィンドウで eat を開く
(global-set-key (kbd "C-c v o") #'eat-other-window)

 ;;; ============================================================
;;; プロジェクト管理
;;; ============================================================

;; project.el は Emacs 組み込み
;; Git リポジトリをプロジェクトとして認識し
;; プロジェクト内のファイル検索などができる
(global-set-key (kbd "C-c p f") #'project-find-file)
(global-set-key (kbd "C-c p b") #'project-switch-to-buffer)


;;; ============================================================
;;; 行の折り返し
;;; ============================================================

;; 全バッファで行の折り返しを有効化
(global-visual-line-mode 1)

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
(global-set-key (kbd "C-h") 'delete-backward-char)
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
