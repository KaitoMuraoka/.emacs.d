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
