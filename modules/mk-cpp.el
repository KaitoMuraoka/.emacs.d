;;; mk-cpp.el --- 競技プログラミング (C++ / AtCoder) 環境 -*- lexical-binding: t; -*-

(require 'treesit)

;;; ============================================================
;;; tree-sitter grammar（cpp / c）
;;; ============================================================

;; c++-ts-mode / c-ts-mode が使う tree-sitter grammar を登録する
;; ruby と同じく ~/.emacs.d/tree-sitter/ にビルド配置される
(dolist (src '((cpp "https://github.com/tree-sitter/tree-sitter-cpp")
               (c   "https://github.com/tree-sitter/tree-sitter-c")))
  (add-to-list 'treesit-language-source-alist src))

;; 未導入なら自動でビルドして導入する
;; 注: ネイティブビルドが gcc-15 で失敗する場合は
;;     CC=/usr/bin/clang を付けて Emacs を起動して導入する
(dolist (lang '(cpp c))
  (unless (treesit-language-available-p lang)
    (ignore-errors (treesit-install-language-grammar lang))))


;;; ============================================================
;;; メジャーモード（c++-ts-mode / c-ts-mode）
;;; ============================================================

;; 拡張子と ts-mode の対応付け
;; .h は C/C++ 両用だが、競プロ用途では C++ として扱う
(add-to-list 'auto-mode-alist '("\\.\\(cpp\\|cc\\|cxx\\|hpp\\|hh\\)\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-ts-mode))

;; 旧 c++-mode / c-mode が呼ばれても ts-mode に置き換える
(add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
(add-to-list 'major-mode-remap-alist '(c-mode   . c-ts-mode))

;; インデント幅（AtCoder 提出コードでよく使う 4 スペース）
(setq c-ts-mode-indent-offset 4)


;;; ============================================================
;;; eshell 起動
;;; ============================================================

;; コンパイル・実行・テスト・提出はキーバインドや専用関数ではなく
;; eshell を開いてコマンドラインで直接実行する方針。
;; `mk/cpp-eshell' は現在のソースと同じディレクトリで eshell を開く。
;;
;; コマンドラインでの典型操作:
;;   g++-15 -std=gnu++20 -O2 -Wall -Wextra -DLOCAL -g main.cpp -o main && ./main < input.txt
;;   oj t -c ./main -d test      # acc/oj が取得したサンプルを全件テスト
;;   acc submit main.cpp -- -y   # 提出（-y は確認スキップ）
;;
;; 注意（macOS）:
;;   - ローカルは Homebrew g++-15 を使う（Apple clang は <bits/stdc++.h> 不可）
;;   - Homebrew GCC は asan/ubsan 非対応のため -fsanitize=... は使えない

(defun mk/cpp-eshell ()
  "現在のバッファのディレクトリで eshell を開く。
既存の *eshell* があればそのバッファに切り替え、カレントディレクトリを移動する。"
  (interactive)
  (let ((dir default-directory))
    (eshell)
    (unless (string= (expand-file-name default-directory)
                     (expand-file-name dir))
      (goto-char (point-max))
      (eshell/cd dir)
      (eshell-send-input))))

(provide 'mk-cpp)
;;; mk-cpp.el ends here
