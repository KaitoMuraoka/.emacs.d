;; ~/.emacs.d/init.el

;;; ============================================================
;; パッケージマネージャーの設定
;;; ============================================================

;; package.el は Emacs 組み込みのパッケージ管理システム
(require 'package)

;; パッケージリポジトリを追加
;; MELPA は最大のサードパーティパッケージリポジトリ
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

;; パッケージリスト未取得なら取得する
(unless package-archive-contents
  (package-refresh-contents))

;; use-package をインストール
;; use-package はパッケージの設定を宣言的・整理しやすく書けるマクロ
;; 「このパッケージがなければインストールする」を自動でやってくれる
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

;; use-package で指定したパッケージを自動インストールする
(setq use-package-always-ensure t)

;; emacs info Japanese
(use-package info
  :ensure nil
  :config
  (add-to-list 'Info-directory-list "~/.emacs.d/info/"))

;;; ============================================================
;;; 基本的な Emacs の設定
;;; ============================================================

;; スタートアップ画面を表示しない
(setq inhibit-startup-screen t)

;; エラー音を無効化（視覚的なフラッシュも無効）
(setq ring-bell-function 'ignore)

;; バックアップファイル（file.txt~）を作らない
;; 作業ディレクトリが汚れるのを防ぐ
(setq make-backup-files nil)

;; 自動保存ファイル（#file.txt#）も作らない
(setq auto-save-default nil)

;; yes/no を y/n で答えられるようにする
(setq use-short-answers t)

;; 現在行をハイライト
;; カーソル位置を視覚的に把握しやすくする
(global-hl-line-mode 1)

;; 行番号を表示（相対行番号）
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

;; クリップボードをOSと共有する
(setq select-enable-clipboard t)

;; ダークテーマ
(load-theme 'modus-vivendi t)

;;; ============================================================
;;; org-mode
;;; ============================================================

;; C-c a でorg-agendaを開く
(global-set-key (kbd "C-c a") 'org-agenda)

;; CLOSED タイムスタンプを自動記録する
;; TODOをDONEにした時、完了時刻を自動記録する
(setq org-log-done 'time)

;; TODOキーワードをカスタマイズする
;; TODO : 未完了(自分ボール)
;; DOING: 実行中(自分ボール)
;; WAIT : 停止中
;; DONE : 完了
(setq org-todo-keywords
      '((sequence "TODO" "DOING" "WAIT" "DONE")))
(setq org-todo-keyword-faces
      '(
        ("DOING" . (:foreground "blue"))
        ("WAIT" . (:foreground "gray"))
        ))

;; 状態変化に連動してタイマーを制御する
(defun org-clock-on-state-change()
  (cond
   ;; DOINGになったらタイマー開始
   ((string= org-state "DOING")
    (org-clock-in))
   ;; WAITになったらタイマー停止
   ((string= org-state "WAIT")
    (when (org-clock-is-active)
      (org-clock-out)))
   ;; DONEになったらタイマー停止
   ((string= org-state "DONE")
    (when (org-clock-is-active)
      (org-clock-out)))
   ))

;; 状態変化のたびに上の関数を呼び出す
(add-hook 'org-after-todo-state-change-hook 'org-clock-on-state-change)

;; ob-swift
(use-package ob-swift :ensure t)
;; ob-kotlin
(use-package ob-kotlin :ensure t)
;; ob-typescript
(use-package ob-typescript :ensure t)

;; Org-babelで使う言語を有効化する
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)
   (swift . t)
   (kotlin . t)
   (typescript . t)))

;;; ============================================================
;;; シンタックスハイライト
;;; ============================================================

;; tree-sitter はコードをASTとして解析するため
;; 正規表現ベースのハイライトより高精度・高速
;; Emacs 29以降は組み込み（treesit）で利用可能
(use-package treesit-auto
  :config
  ;; 必要な tree-sitter グラマーを自動インストールする設定
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))


;;; ============================================================
;;; Treemacs
;;; ============================================================
;; treemacs: VSCode のようなサイドバーのディレクトリツリー
;; プロジェクト全体のファイル構造を左ペインで把握できる
(use-package treemacs
  :bind
  ("C-c t t" . treemacs)                      ; ツリーの表示/非表示トグル
  ("C-c t f" . treemacs-find-file)            ; 今開いているファイルをツリーで選択状態にする
  ("C-c t p" . treemacs-add-and-display-current-project) ; 現在のプロジェクトを追加

  :config
  ;; ツリーの幅（文字数）
  (setq treemacs-width 30)

  ;; ファイル変更を自動で検知してツリーを更新する
  (treemacs-filewatch-mode t)

  ;; git の状態（変更済み・未追跡など）をツリー上にアイコン表示する
  (treemacs-git-mode 'simple))

;; treemacs-magit: treemacs と magit を連携させる
;; magit でファイル操作した結果をツリーに即時反映する
(use-package treemacs-magit
  :after (treemacs magit))

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

  ;; ELisp: Emacs 自体が LSP 的な機能を持つため
  ;; eglot-ensure を hook するだけで eldoc などが働く
  ;; (追加のサーバー設定は不要)

  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)           ; シンボルのリネーム
              ("C-c l a" . eglot-code-actions)      ; コードアクション
              ("C-c l f" . eglot-format-buffer)     ; フォーマット
              ("M-."     . xref-find-definitions)   ; 定義へジャンプ
              ("M-,"     . xref-pop-marker-stack))) ; ジャンプ前に戻る


;;; 言語モード
;;; ============================================================

;; Swift サポート
;; swift-mode は MELPA から提供
(use-package swift-mode)

;; TypeScript サポート
(use-package typescript-mode
  :mode ("\\.ts\\'" . typescript-mode)
  :mode ("\\.tsx\\'" . tsx-ts-mode))


;;; ============================================================
;;; Git サポート
;;; ============================================================

;; Magit: Emacs 上で Git を操作できる強力なツール
;; ターミナルを開かず Git の全操作が行える
(use-package magit
  :bind ("C-c g" . magit-status))

(use-package forge
  :after magit)

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
;;; vterm（ターミナルエミュレータ）
;;; ============================================================

(use-package vterm
  :commands vterm ; vterm コマンドが呼ばれた時だけ読み込む（遅延読み込み）

  :config
  ;; シェルの設定
  ;; Emacs は $SHELL 環境変数からシェルを自動検出するが
  ;; 明示的に指定することで確実に希望のシェルが起動する
  (setq vterm-shell (getenv "SHELL"))

  ;; ターミナルの最大スクロール行数
  ;; 大きくすると過去の出力を遡れるがメモリを使う
  (setq vterm-max-scrollback 10000)

  ;; vterm バッファを閉じた時、ウィンドウも一緒に閉じる
  ;; ターミナルを exit した後に空のバッファが残らないようにする
  (setq vterm-kill-buffer-on-exit t)

  :bind
  ("C-c v t" . vterm)              ; 新しい vterm を開く
  ("C-c v o" . vterm-other-window)) ; 別ウィンドウで開く

;; vterm-toggle: vterm をトグル表示するパッケージ
;; エディタ画面を保ちながら下部にターミナルを出し入れできる
;; VSCode のターミナルパネルに近い感覚で使える
(use-package vterm-toggle
  :after vterm
  :config
  ;; ターミナルを画面下部に表示する
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda (buf actions)
                   (with-current-buffer buf (equal major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (dedicated . t)
                 (reusable-frames . visible)
                 (window-height . 0.3))) ; 画面の30%の高さで表示

  :bind
  ("C-c v v" . vterm-toggle)             ; ターミナルの表示/非表示
  ("C-c v n" . vterm-toggle-forward)     ; 次のターミナルへ
  ("C-c v p" . vterm-toggle-backward))   ; 前のターミナルへ

 ;;; ============================================================
;;; プロジェクト管理
;;; ============================================================

;; project.el は Emacs 組み込み
;; Git リポジトリをプロジェクトとして認識し
;; プロジェクト内のファイル検索などができる
(global-set-key (kbd "C-c p f") #'project-find-file)
(global-set-key (kbd "C-c p b") #'project-switch-to-buffer)


;;; ============================================================
;;; よく使うキーバインド
;;; ============================================================

;; バッファの切り替えを便利に
(global-set-key (kbd "C-c b") #'switch-to-buffer)

;; ウィンドウ移動
(global-set-key (kbd "M-o") #'other-window)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files '("~/org/note.org"))
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
