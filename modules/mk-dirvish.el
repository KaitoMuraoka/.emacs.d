;;; ============================================================
;;; ファイル管理 (Dirvish)
;;; ============================================================

;; nerd-icons: ファイルタイプに応じたアイコンを提供するパッケージ
;; GUI 環境でのみ有意義なため、グラフィカル環境限定でロードする
(use-package nerd-icons
  :if (display-graphic-p)
  :config
  ;; Nerd Font がシステム未インストールの場合は自動でインストールする
  ;; NFM.ttf をパッケージ同梱のものから ~/Library/Fonts/ にコピーする
  (unless (find-font (font-spec :name "Symbols Nerd Font Mono"))
    (nerd-icons-install-fonts t))
  ;; Emacs の fontset に Nerd Font を登録して文字化けを防ぐ
  (nerd-icons-set-font))

;; Dirvish: dired を大幅に強化するファイルマネージャー
;; dired の全機能・設定を保持しつつ、プレビュー・アイコン・
;; バージョン管理情報などモダンな機能を追加する
(use-package dirvish
  :init
  ;; dired を起動するたびに dirvish が代わりに使われるようにする
  (dirvish-override-dired-mode)
  :custom
  ;; よくアクセスするディレクトリのショートカット定義
  ;; dirvish-quick-access (`) で呼び出せる
  (dirvish-quick-access-entries
   '(("h" "~/"          "Home")
     ("d" "~/Downloads/" "Downloads")
     ("p" "~/Projects/"  "Projects")))
  ;; ディレクトリバッファに表示するインライン属性
  ;; nerd-icons: ファイルタイプアイコン（GUI 時のみ有効）
  ;; file-size:  ファイルサイズ
  ;; vc-state:   バージョン管理の変更状態
  (dirvish-attributes
   '(nerd-icons file-size vc-state))
  :bind
  ;; C-c d でファイルマネージャーを開く（C-c g magit に倣った命名）
  ("C-c d d" . dirvish)
  ("C-c d s" . dirvish-side)        ; サイドパネルでディレクトリツリー表示
  (:map dirvish-mode-map
        ("?"   . dirvish-dispatch)  ; transient ヘルプメニューを表示
        ("TAB" . dirvish-subtree-toggle))) ; ディレクトリをインライン展開

(provide 'mk-dirvish)
