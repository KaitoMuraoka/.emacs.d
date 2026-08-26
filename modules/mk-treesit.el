;; -*- lexical-binding: t; -*-

;;; ============================================================
;;; Tree-sitter（treesit）
;;; ============================================================

;; Emacs 30 組み込みの treesit は grammar を動的ライブラリとして必要とするが、
;; treesit-language-source-alist の既定値は空なので入手先を自前で定義する。
;; ここで定義した grammar が無いまま *-ts-mode を開くと
;; 「Cannot activate tree-sitter, because language grammar for ... is unavailable」
;; という警告が出る。
;;
;; 初回セットアップや grammar 追加時に M-x mk/treesit-install-missing-grammars を
;; 一度実行すればよい（ビルドに時間がかかるため起動時の自動実行はしない）。
;; インストール先は treesit-extra-load-path 未設定のため ~/.emacs.d/tree-sitter/。

(use-package treesit
  :straight (:type built-in)
  :custom
  ;; バージョンは Emacs 30 の grammar ABI（15）で動作するタグに固定する
  (treesit-language-source-alist
   '((ruby       "https://github.com/tree-sitter/tree-sitter-ruby" "v0.23.1")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "typescript/src")
     (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "tsx/src"))))

(defun mk/treesit-install-missing-grammars ()
  "未導入の tree-sitter grammar だけをビルドしてインストールする。
既に導入済みのものは再ビルドしない。"
  (interactive)
  (let ((missing (seq-remove (lambda (lang) (treesit-language-available-p lang))
                             (mapcar #'car treesit-language-source-alist)))
        (failed nil))
    (if (null missing)
        (message "tree-sitter grammar は全て導入済みです")
      (dolist (lang missing)
        (condition-case err
            (treesit-install-language-grammar lang)
          (error (push (cons lang (error-message-string err)) failed))))
      (if failed
          (message "grammar のインストールに失敗: %s"
                   (mapconcat (lambda (f) (format "%s (%s)" (car f) (cdr f)))
                              (nreverse failed) ", "))
        (message "grammar をインストールしました: %s"
                 (mapconcat #'symbol-name missing ", "))))))

(provide 'mk-treesit)
