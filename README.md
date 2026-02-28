# Emacs

シンタックスハイライト・LSP・Git統合を備えた、見た目はシンプルでパワフルな開発環境の構築ガイドです。

## 動作環境

- Emacs 29 以上
- macOS（Xcodeインストール済み）
- Node.js / npm（TypeScript LSP用）

---

## ファイル構成

```
~/.emacs.d/
├── early-init.el   # 起動の最初期に読まれる設定（UIのちらつき防止）
└── init.el         # メインの設定ファイル
```

---

## セットアップ手順

### 1. 設定ファイルを配置する

下記の `early-init.el` と `init.el` を `~/.emacs.d/` に作成します。

### 2. 外部ツールをインストールする

```bash
# TypeScript Language Server
npm install -g typescript-language-server typescript
```

Swift LSP（sourcekit-lsp）はXcodeに同梱されているため、追加インストールは不要です。

### 3. Emacsを起動する

初回起動時に全パッケージが自動インストールされます。完了まで1〜2分かかります。

### 4. GitHub連携（forge）の認証設定

`~/.authinfo` ファイルを作成して以下を記載します。

```
machine api.github.com login <GitHubユーザー名>^forge password <PersonalAccessToken>
```

Personal Access Token は GitHub の `Settings → Developer settings → Personal access tokens` で発行します。必要なスコープは `repo` と `user` です。

---

## early-init.el

```elisp
;; パッケージシステムの自動初期化を遅らせる（init.elで手動初期化するため）
(setq package-enable-at-startup nil)

;; フレームをEmacsが作成する前にUIパラメータを設定することで
;; 起動時のUIのちらつきを防ぐ
(setq default-frame-alist
      '((tool-bar-lines . 0)
        (menu-bar-lines . 0)
        (vertical-scroll-bars . nil)))
```

---

## init.el

```elisp
;;; ============================================================
;;; パッケージマネージャーの設定
;;; ============================================================

(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; use-package: パッケージ設定を宣言的に書けるマクロ
;; 「インストールされていなければ自動インストール」が :ensure t で行える
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


;;; ============================================================
;;; 基本設定
;;; ============================================================

(setq inhibit-startup-screen t)   ; スタートアップ画面を非表示
(setq ring-bell-function 'ignore)  ; エラー音を無効化
(setq make-backup-files nil)       ; バックアップファイル（file.txt~）を作らない
(setq auto-save-default nil)       ; 自動保存ファイル（#file.txt#）を作らない
(setq use-short-answers t)         ; yes/no を y/n で答える

(global-hl-line-mode 1)            ; 現在行をハイライト
(show-paren-mode 1)                ; 対応する括弧をハイライト
(column-number-mode 1)             ; 列数を表示
(electric-pair-mode 1)             ; 括弧の自動補完

(setq-default indent-tabs-mode nil) ; タブではなくスペースを使う
(setq-default tab-width 4)
(setq require-final-newline t)      ; ファイル末尾に改行を自動挿入
(setq select-enable-clipboard t)    ; クリップボードをOSと共有

;; 相対行番号
;; カーソルから何行上下かが一目でわかる（N行移動時に便利）
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)


;;; ============================================================
;;; テーマ
;;; ============================================================

;; modus-vivendi: Emacs 28以降に組み込まれたダークテーマ
;; WCAG（アクセシビリティ基準）に準拠したコントラスト設計で目に優しい
(load-theme 'modus-vivendi t)


;;; ============================================================
;;; シンタックスハイライト（tree-sitter）
;;; ============================================================

;; tree-sitter はコードをASTとして解析する
;; 正規表現ベースより高精度・高速なハイライトが実現できる
;; Emacs 29以降は treesit として組み込まれている
(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt) ; 必要なグラマーを確認しながら自動インストール
  (global-treesit-auto-mode))


;;; ============================================================
;;; 補完システム
;;; ============================================================

;; Vertico: M-x やファイル検索などの候補を縦リスト表示するUI
(use-package vertico
  :init
  (vertico-mode))

;; Orderless: スペース区切りで複数キーワード・あいまい検索できる補完スタイル
;; flex スタイルにより「str」→「String」「NSString」なども候補に出る
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-ignore-case t
        orderless-matching-styles '(orderless-literal
                                    orderless-prefixes
                                    orderless-flex)))

;; 大文字小文字を無視した補完の追加設定
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

;; Marginalia: 補完候補の横に説明文を表示
(use-package marginalia
  :init
  (marginalia-mode))

;; Corfu: コード補完のポップアップUI（LSPの補完候補表示に使う）
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.3)
  :init
  (global-corfu-mode))


;;; ============================================================
;;; LSP（Language Server Protocol）設定
;;; ============================================================

;; eglot: Emacs 29組み込みのLSPクライアント
;; LSP = エディタと独立した言語解析サーバーと通信する仕組み
;; 補完・定義ジャンプ・エラー表示が言語ごとに統一される
(use-package eglot
  :hook
  ((swift-mode       . eglot-ensure)
   (typescript-mode  . eglot-ensure)
   (tsx-ts-mode      . eglot-ensure)
   (emacs-lisp-mode  . eglot-ensure))

  :config
  ;; Swift: sourcekit-lsp（Xcodeに同梱、追加インストール不要）
  (add-to-list 'eglot-server-programs
               '(swift-mode . ("xcrun" "sourcekit-lsp")))

  ;; TypeScript: typescript-language-server
  ;; 事前インストール: npm install -g typescript-language-server typescript
  (add-to-list 'eglot-server-programs
               '((typescript-mode tsx-ts-mode) .
                 ("typescript-language-server" "--stdio")))

  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format-buffer)
              ("M-."     . xref-find-definitions)
              ("M-,"     . xref-pop-marker-stack)))


;;; ============================================================
;;; スニペット（引数へのフォーカス）
;;; ============================================================

;; yasnippet: コードテンプレートシステム
;; $1, $2... というタブストップにカーソルが順番に移動する
;; 例: print<TAB> → print(█) の █ 部分にフォーカスが当たる
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; yasnippet-snippets: Swift・TypeScript・ELisp等の既製スニペット集
(use-package yasnippet-snippets)


;;; ============================================================
;;; 言語モード
;;; ============================================================

(use-package swift-mode)

(use-package typescript-mode
  :mode ("\\.ts\\'" . typescript-mode)
  :mode ("\\.tsx\\'" . tsx-ts-mode))


;;; ============================================================
;;; Git 関連
;;; ============================================================

;; Magit: Emacs上でGit全操作が行えるインターフェース
(use-package magit
  :bind ("C-c g" . magit-status))

;; forge: GitHub/GitLab のIssue・PRをMagitから操作する
;; 認証設定（~/.authinfo）が必要（READMEのセットアップ手順を参照）
(use-package forge
  :after magit)

;; git-gutter: バッファ左端にgitの差分を記号で表示する
;;   +  追加された行
;;   -  削除された行
;;   ~  変更された行
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.5)
  (setq git-gutter:added-sign    "+")
  (setq git-gutter:deleted-sign  "-")
  (setq git-gutter:modified-sign "~")
  :bind
  ("C-c v n" . git-gutter:next-hunk)
  ("C-c v p" . git-gutter:previous-hunk)
  ("C-c v r" . git-gutter:revert-hunk)
  ("C-c v s" . git-gutter:stage-hunk))


;;; ============================================================
;;; ファイルツリー
;;; ============================================================

;; treemacs: VSCodeのようなサイドバーのディレクトリツリー
(use-package treemacs
  :bind
  ("C-c t t" . treemacs)
  ("C-c t f" . treemacs-find-file)
  ("C-c t p" . treemacs-add-and-display-current-project)
  :config
  (setq treemacs-width 30)
  (treemacs-filewatch-mode t)
  (treemacs-git-mode 'simple))

;; treemacs-magit: magitでの操作結果をtreemacsに即時反映する
(use-package treemacs-magit
  :after (treemacs magit))


;;; ============================================================
;;; キーバインドガイド
;;; ============================================================

;; which-key: プレフィックスキーを押した後に
;; 続けて押せるキー一覧をポップアップ表示する
;; 例: C-c を押して待つと、C-c g / C-c t / C-c v ... が一覧表示される
(use-package which-key
  :config
  (setq which-key-idle-delay 0.8)
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-location 'bottom)
  (which-key-mode))


;;; ============================================================
;;; プロジェクト管理
;;; ============================================================

;; project.el: Emacs組み込みのプロジェクト管理
;; Gitリポジトリをプロジェクトとして認識する
(global-set-key (kbd "C-c p f") #'project-find-file)
(global-set-key (kbd "C-c p b") #'project-switch-to-buffer)


;;; ============================================================
;;; その他のキーバインド
;;; ============================================================

(global-set-key (kbd "C-c b") #'switch-to-buffer)
(global-set-key (kbd "M-o") #'other-window)
```

---

## Org-mode

Org-mode は Emacs 組み込みのタスク管理・ノート作成・文書作成ツールです。

### TODOキーワード

カスタムキーワードと状態遷移を設定しています。

| キーワード | 意味 | タイマー（org-clock）|
|-----------|------|---------------------|
| `TODO` | 未着手 | — |
| `DOING` | 実行中 | 自動開始 |
| `WAIT` | 停止中 | 自動停止 |
| `DONE` | 完了 | 自動停止 |

- `DONE` に変更すると完了時刻（`CLOSED:`）が自動記録されます
- `DOING` に変更するとタイマーが自動で開始し、`WAIT` / `DONE` で自動停止します

### アジェンダファイル

`~/org/note.org` がアジェンダファイルとして登録されています。

---

## Org-babel

Org-babel は Org-mode 内のコードブロックを直接実行できる機能です。ドキュメントとコードを一体化した「文芸的プログラミング」スタイルで作業できます。

### サポート言語

| 言語 | 提供元 |
|------|--------|
| Emacs Lisp | Emacs 組み込み |
| Shell | Emacs 組み込み |
| Swift | `ob-swift` パッケージ |
| Kotlin | `ob-kotlin` パッケージ |
| TypeScript | `ob-typescript` パッケージ |

### コードブロックの書き方

```
#+begin_src swift
  print("Hello, World!")
#+end_src
```

`C-c C-c` でカーソル下のコードブロックを実行し、結果を直下に挿入します。

---

## キーバインド一覧

### 基本操作

| キー | 動作 |
|------|------|
| `C-x C-f` | ファイルを開く |
| `C-x C-s` | 保存 |
| `C-x C-c` | Emacs を終了 |
| `M-x` | コマンド実行 |
| `C-g` | 操作キャンセル（困ったらこれ） |
| `M-o` | 次のウィンドウへ移動 |
| `C-c b` | バッファの切り替え |

### LSP（eglot）

| キー | 動作 |
|------|------|
| `M-.` | 定義へジャンプ |
| `M-,` | ジャンプ前に戻る |
| `C-c l r` | シンボルのリネーム |
| `C-c l a` | コードアクション |
| `C-c l f` | バッファをフォーマット |

### Git（Magit / git-gutter）

| キー | 動作 |
|------|------|
| `C-c g` | Magit ステータスを開く |
| `C-c v n` | 次の変更箇所へ移動 |
| `C-c v p` | 前の変更箇所へ移動 |
| `C-c v r` | この変更を元に戻す |
| `C-c v s` | この変更だけをステージング |

### Treemacs

| キー | 動作 |
|------|------|
| `C-c t t` | ツリーの表示 / 非表示 |
| `C-c t f` | 現在のファイルをツリーで選択 |
| `C-c t p` | 現在のプロジェクトをツリーに追加 |

### プロジェクト

| キー | 動作 |
|------|------|
| `C-c p f` | プロジェクト内のファイルを検索 |
| `C-c p b` | プロジェクト内のバッファを切り替え |

### Org-mode

| キー | 動作 |
|------|------|
| `C-c a` | アジェンダを開く |
| `C-c C-t` | TODO 状態を切り替える |
| `C-c C-s` | スケジュールを設定 |
| `C-c C-d` | 締切日（DEADLINE）を設定 |
| `TAB` | 見出しの折りたたみ / 展開 |
| `C-c C-n` | 次の見出しへ移動 |
| `C-c C-p` | 前の見出しへ移動 |
| `C-c C-x C-i` | タイマー開始（clock in） |
| `C-c C-x C-o` | タイマー停止（clock out） |
| `C-c C-x C-r` | クロックレポートを挿入 |

### Org-babel

| キー | 動作 |
|------|------|
| `C-c C-c` | コードブロックを実行 |
| `C-c '` | コードブロックを専用バッファで編集 |
| `C-c C-v t` | タングル（コードをファイルに書き出す） |
| `C-c C-v b` | バッファ内の全コードブロックを実行 |

---

## カスタムスニペットの作り方

`M-x yas-new-snippet` で作成します。Swift の `guard let` を例に示します。

```
# -*- mode: snippet -*-
# name: guard let
# key: gl
# --
guard let ${1:value} = ${2:optional} else {
    ${3:return}
}
$0
```

`gl<TAB>` と入力するとスニペットが展開され、`TAB` で `$1 → $2 → $3` の順にフォーカスが移動します。`$0` が最終カーソル位置です。

---

## トラブルシューティング

**LSP が起動しない（Swift）**

```bash
xcrun sourcekit-lsp --help
```

コマンドが動くか確認します。Xcode のコマンドラインツールが必要です。

```bash
xcode-select --install
```

**LSP が起動しない（TypeScript）**

```bash
typescript-language-server --version
```

コマンドが見つからない場合は npm でインストールします。

```bash
npm install -g typescript-language-server typescript
```

**パッケージのインストールに失敗する**

Emacs 上で以下を実行してパッケージリストを再取得します。

```
M-x package-refresh-contents
```

**設定を再読み込みしたい**

```
M-x eval-buffer   ; 現在のバッファ（init.el）を再読み込み
```

または Emacs を再起動します。

**エラーログを確認したい**

```
C-x b *Messages* RET
```
