;; ~/.emacs.d/elisp ディレクトリをロードパスに追加する
;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
(add-to-load-path "elisp" "conf" "public_repos")

(require 'init-loader)
(init-loader-load "~/.emacs.d/conf") 	;設定ファイルがあるディレクトリを指定
;; Mac だけに読み込ませる内容を書く
(when (eq system-type 'darwin)
  ;; Mac の Emacs でファイル名を正しく扱うための設定
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;; CocoaEmacs 以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-bar を非表示
  (menu-bar-mode 0))

;; cl-lib パッケージを読み込む
(require 'cl-lib)

;; php-mode を読み込み
(when (require 'php-mode nil t)
  ;; 読み込みに成功した場合のみ、拡張子 .ctp を php-mode で実行する
  (add-to-list 'auto-mode-alist '("\\.ctp$" . php-mode)))

;; run-ruby 関数の初呼び出し時に inf-ruby.el を読み込む
(autoload 'ruby-ruby "inf-ruby"
  "Run an inferior Ruby process")

(when (executable-find "git")
  (require 'magit nil t)
