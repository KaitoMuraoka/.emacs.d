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

;; cape: 複数の補完ソース(capf)を合成・拡張する
;; eglot 単独だと出ない「スニペット・バッファ内の語」を補うために使う
(use-package cape)

;; yasnippet-capf: yasnippet スニペットを補完候補(capf)として出す
;; これで def 等のスニペットが corfu のポップアップに出るようになる
(use-package yasnippet-capf
  :after (cape yasnippet))

;; corfu-popupinfo: 補完候補のドキュメントをポップアップ表示（VSCode 風）
;; corfu に同梱の拡張なので straight では取得しない
(use-package corfu-popupinfo
  :straight nil
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.4 . 0.2)))

;; LSP 非接続バッファでも最低限の補完が出るよう底上げする
;; （スニペット・バッファ内の語・ファイルパス）
;; 末尾(t)に追加し、各モード本来の capf を優先しつつフォールバックさせる
(add-to-list 'completion-at-point-functions #'yasnippet-capf t)
(add-to-list 'completion-at-point-functions #'cape-dabbrev t)
(add-to-list 'completion-at-point-functions #'cape-file t)


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
   (python-mode      . eglot-ensure)
   (python-ts-mode   . eglot-ensure)
   (ruby-ts-mode     . eglot-ensure)
   (web-mode         . eglot-ensure)
   (c++-ts-mode      . eglot-ensure)
   (c-ts-mode        . eglot-ensure))

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

  ;; Python: jedi-language-server を使用
  ;; インストール: pip install jedi-language-server
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("jedi-language-server")))

  ;; Ruby: ruby-lsp を使用（rbenv shim 経由で .ruby-version を尊重する）
  ;; Rails 専用機能はプロジェクトの Gemfile に ruby-lsp-rails を入れると
  ;; ruby-lsp が自動で addon として読み込む
  (add-to-list 'eglot-server-programs
               '(ruby-ts-mode . ("ruby-lsp")))

  ;; HTML/ERB: vscode-html-language-server を使用
  ;; web-mode で HTML タグ・属性の補完を corfu に出すため
  ;; インストール: npm install -g vscode-langservers-extracted
  (add-to-list 'eglot-server-programs
               '(web-mode . ("vscode-html-language-server" "--stdio")))

  ;; C/C++: clangd を使用（Apple clang に同梱、追加インストール不要）
  ;; --query-driver で Homebrew g++-15 の system include を参照させ、
  ;; macOS の clang では見つからない <bits/stdc++.h> を解決する
  (add-to-list 'eglot-server-programs
               '((c++-ts-mode c-ts-mode) .
                 ("clangd"
                  "--query-driver=/opt/homebrew/bin/g++-15"
                  "--header-insertion=never"   ; 競プロでは自動 include 不要
                  "--clang-tidy"
                  "--completion-style=detailed")))

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
;;; 保存時の自動フォーマット
;;; ============================================================

;; eglot が管理しているバッファのみフォーマットする
;; 理由: LSP 未接続のときに eglot-format-buffer を呼ぶとエラーになるため
(defun mk/eglot-format-on-save ()
  "eglot 管理下のバッファを保存前にフォーマットする。"
  (when (bound-and-true-p eglot--managed-mode)
    (eglot-format-buffer)))

;; Ruby: 保存時に ruby-lsp（RuboCop）で自動整形する
;; 手動整形は引き続き C-c l f が使える
(add-hook 'ruby-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'mk/eglot-format-on-save nil t)))


;;; ============================================================
;;; eglot の補完ソース合成（VSCode 風の補完体験）
;;; ============================================================

;; eglot は有効化時に completion-at-point-functions を自分のものだけに
;; 置き換えてしまい、yasnippet スニペットやバッファ内の語が corfu に出なくなる。
;;
;; ここでは eglot（LSP）を最優先にする:
;;   - 第1要素: cape-capf-super で「LSP + スニペット」を合成
;;     （LSP の Method 候補と def 等のスニペットを一緒に出す）
;;   - 第2要素: cape-dabbrev は LSP が候補を返せない箇所だけのフォールバック
;;     （第1要素が候補を返す間は Dabbrev は出ないので Method がノイズに埋もれない）
(defun mk/eglot-capf ()
  (setq-local completion-at-point-functions
              (list (cape-capf-super
                     #'eglot-completion-at-point
                     #'yasnippet-capf)
                    #'cape-dabbrev)))

(add-hook 'eglot-managed-mode-hook #'mk/eglot-capf)

(provide 'mk-lsp)
