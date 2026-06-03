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
;;; コンパイル設定
;;; ============================================================

(defgroup mk/cpp nil
  "競技プログラミング (C++) 用の設定。"
  :group 'tools)

(defcustom mk/cpp-compiler "/opt/homebrew/bin/g++-15"
  "C++ のコンパイラ。
macOS の Apple clang は bits/stdc++.h が使えないため
Homebrew GCC (g++-15) を既定にしている。"
  :type 'string
  :group 'mk/cpp)

(defcustom mk/cpp-std "gnu++20"
  "C++ の言語標準。AtCoder に合わせて gnu++23 等に変更してよい。"
  :type 'string
  :group 'mk/cpp)

(defcustom mk/cpp-flags
  '("-O2" "-Wall" "-Wextra" "-DLOCAL" "-g")
  "コンパイルフラグ。
注: Homebrew GCC は macOS 向けの sanitizer ランタイム(asan/ubsan)を
同梱しておらず `-fsanitize=...' を付けるとリンクに失敗するため既定では付けない。"
  :type '(repeat string)
  :group 'mk/cpp)

(defcustom mk/cpp-input-file "input.txt"
  "`mk/cpp-compile-run' が標準入力として流すファイル名。
ソースと同じディレクトリにあれば使われる。"
  :type 'string
  :group 'mk/cpp)

(defun mk/cpp--exe-path ()
  "現在のソースに対応する実行ファイルのパスを返す。"
  (file-name-sans-extension (buffer-file-name)))

(defun mk/cpp--compile-command ()
  "現在のソースをビルドするシェルコマンド文字列を返す。"
  (let ((src (shell-quote-argument (buffer-file-name)))
        (exe (shell-quote-argument (mk/cpp--exe-path))))
    (mapconcat #'identity
               (append (list (shell-quote-argument mk/cpp-compiler)
                             (concat "-std=" mk/cpp-std))
                       mk/cpp-flags
                       (list src "-o" exe))
               " ")))

;;;###autoload
(defun mk/cpp-compile ()
  "現在の C++ ファイルを g++-15 でコンパイルする。"
  (interactive)
  (unless (buffer-file-name)
    (user-error "バッファがファイルに紐づいていません"))
  (save-buffer)
  (let ((default-directory (file-name-directory (buffer-file-name))))
    (compile (mk/cpp--compile-command))))

;;;###autoload
(defun mk/cpp-compile-run ()
  "現在の C++ ファイルをコンパイルし、続けて実行する。
ソースと同じディレクトリに `mk/cpp-input-file' があれば
それを標準入力として流す。無ければ対話実行する。"
  (interactive)
  (unless (buffer-file-name)
    (user-error "バッファがファイルに紐づいていません"))
  (save-buffer)
  (let* ((default-directory (file-name-directory (buffer-file-name)))
         (exe (shell-quote-argument (mk/cpp--exe-path)))
         (input (and (file-exists-p mk/cpp-input-file)
                     (concat " < " (shell-quote-argument mk/cpp-input-file))))
         (run (concat exe (or input "")))
         (cmd (concat (mk/cpp--compile-command) " && echo '--- run ---' && " run)))
    (if input
        ;; 入力ファイルがあるなら compilation バッファで完結させる
        (compile cmd)
      ;; 対話入力が要る場合は端末で実行する
      (compile (mk/cpp--compile-command))
      (when (file-exists-p (mk/cpp--exe-path))
        (async-shell-command run "*cpp-run*")))))


;;; ============================================================
;;; online-judge-tools (oj) / atcoder-cli (acc) 連携
;;; ============================================================

(defun mk/cpp--problem-dir ()
  "サンプルテスト (test/) があるディレクトリを返す。
ソースのあるディレクトリを既定とする。"
  (file-name-directory (buffer-file-name)))

;;;###autoload
(defun mk/cpp-oj-test ()
  "acc/oj が取得したサンプル (test/) を全件テストする。
事前にビルドして a.out 相当を作ってから oj test を呼ぶ。"
  (interactive)
  (unless (buffer-file-name)
    (user-error "バッファがファイルに紐づいていません"))
  (save-buffer)
  (let* ((default-directory (mk/cpp--problem-dir))
         (exe (shell-quote-argument (mk/cpp--exe-path)))
         (cmd (concat (mk/cpp--compile-command)
                      " && oj t -c " exe " -d test")))
    (compile cmd)))

;;;###autoload
(defun mk/cpp-oj-submit ()
  "現在のファイルを AtCoder に提出する (acc submit 経由)。"
  (interactive)
  (unless (buffer-file-name)
    (user-error "バッファがファイルに紐づいていません"))
  (save-buffer)
  (let ((default-directory (mk/cpp--problem-dir)))
    (async-shell-command
     ;; acc submit <filename> -- <oj options>
     ;; -y は oj submit に渡され提出確認をスキップする
     (concat "acc submit "
             (shell-quote-argument (file-name-nondirectory (buffer-file-name)))
             " -- -y")
     "*acc-submit*")))


;;; ============================================================
;;; キーバインド
;;; ============================================================

;; eglot の C-c l ... と衝突しないよう C-c c プレフィックスを使う
(with-eval-after-load 'c-ts-mode
  (define-key c++-ts-mode-map (kbd "C-c c c") #'mk/cpp-compile)
  (define-key c++-ts-mode-map (kbd "C-c c r") #'mk/cpp-compile-run)
  (define-key c++-ts-mode-map (kbd "C-c c t") #'mk/cpp-oj-test)
  (define-key c++-ts-mode-map (kbd "C-c c s") #'mk/cpp-oj-submit))

(provide 'mk-cpp)
;;; mk-cpp.el ends here
