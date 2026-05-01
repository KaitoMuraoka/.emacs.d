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

(provide 'mk-path-from-shell)
