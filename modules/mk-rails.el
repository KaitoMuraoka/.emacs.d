;; -*- lexical-binding: t; -*-

;;; ============================================================
;;; Ruby / Rails 開発支援
;;; ============================================================

;; inf-ruby: Ruby / Rails の REPL（irb / rails console）を Emacs 内で動かす
;; inf-ruby-console-auto はプロジェクト種別を自動判定して
;; rails console などの適切なコンソールを起動する
(use-package inf-ruby
  :hook
  ;; ruby-ts-mode で C-c C-s（送信）などの inf-ruby マイナーモードを有効化
  (ruby-ts-mode . inf-ruby-minor-mode))


;; robe: 起動中の Ruby プロセスに問い合わせる runtime-aware なコード探索
;; 理由: Solargraph は静的解析なので、Rails の動的定義（has_many が生やす
;;       メソッド、ActiveRecord の属性など）や RSpec の let で定義された
;;       ヘルパを追えない。実行中のプロセスに聞ける robe がそこを補う。
;; 補完は Solargraph に一本化し、robe は定義ジャンプとドキュメント参照に使う
;; 使い方: M-x inf-ruby（Rails なら M-x inf-ruby-console-auto）で REPL を
;;         起動してから M-x robe-start する
(use-package robe
  :hook (ruby-ts-mode . robe-mode)
  ;; M-. は eglot（Solargraph）の xref バックエンドが優先される
  ;; （robe も xref バックエンドを足すが、後から有効になる eglot が先に来る。
  ;;   robe を使ったジャンプは下のキーから明示的に呼ぶ）
  :bind (:map robe-mode-map
              ("C-c l j" . robe-jump)
              ("C-c l k" . robe-doc))
  :config
  ;; robe-mode は自身の補完関数を completion-at-point-functions に足すため、
  ;; そのままだと Solargraph と同じ候補が二重に出る。
  ;; 補完ソースは Solargraph に一本化し、robe は探索用途に限定する
  (defun mk/robe-disable-capf ()
    "robe の補完を completion-at-point から外す。"
    (remove-hook 'completion-at-point-functions #'robe-complete-at-point t))
  (add-hook 'robe-mode-hook #'mk/robe-disable-capf))


;;; ============================================================
;;; プロジェクト操作・Rails ナビゲーション
;;; ============================================================

;; projectile: プロジェクト単位の操作（projectile-rails の前提）
;; 注意: デフォルトプレフィックス C-c p は project.el の C-c p f/b と
;;       衝突するため、projectile 側は C-c j に逃がす
(use-package projectile
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c j" . projectile-command-map)))

;; projectile-rails: モデル↔ビュー↔コントローラ間ジャンプ、
;; generator / rake / console / dbconsole などを一通り提供する
;; コマンドマップは C-c r プレフィックスに割り当てる
;; 例: C-c r m（model）/ C-c r c（controller）/ C-c r v（view）
;;     C-c r g（generate）/ C-c r r（rake）/ C-c r R（routes）
(use-package projectile-rails
  :after projectile
  :init
  (projectile-rails-global-mode)
  :bind (:map projectile-rails-mode-map
              ("C-c r" . projectile-rails-command-map)))


;;; ============================================================
;;; テスト（RSpec）
;;; ============================================================

;; rspec-mode: spec の実行・再実行をバッファから行う
;; 例: C-c , v（verify file）/ C-c , s（verify single）/ C-c , r（rerun）
;; Gemfile に solargraph-rspec を追加すると Solargraph 側でも
;; describe / let などの RSpec DSL を解釈できるようになる
;;（Ruby 環境の解決は mk-lsp-manager.el を参照）
(use-package rspec-mode
  :hook (ruby-ts-mode . rspec-mode)
  :custom
  ;; Gemfile があれば bundle exec 経由で rspec を実行する
  (rspec-use-bundler-when-possible t))

;;; ============================================================
;;; Bundler
;;; ============================================================

;; bundler: Gemfile 操作（bundle-install / bundle-open / bundle-update など）
(use-package bundler)

(provide 'mk-rails)
