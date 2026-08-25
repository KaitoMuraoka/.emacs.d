;; -*- lexical-binding: t; -*-

;;; ============================================================
;;; Language Server Manager
;;; ============================================================
;;
;; Neovim の mason.nvim / mason-lspconfig.nvim に相当する層。
;; Eglot（LSP クライアント）とは責務を分ける:
;;
;;   mk-lsp-manager … Language Server の検出・インストール・実行環境の解決
;;   eglot          … 解決済みのコマンドで LSP サーバーと通信する
;;
;; ファイルを開く
;;   → mk-lsp-manager-ensure（major-mode からサーバーを解決）
;;   → 未インストールなら確認のうえ自動インストール
;;   → eglot-ensure
;;
;; 言語ごとの処理は `mk-lsp-manager-register-server' で登録するため、
;; 新しい言語の追加は登録を 1 つ増やすだけで済む。

(require 'cl-lib)
(require 'subr-x)
(require 'project)

;; eglot は遅延ロードのままにしたいので、宣言だけしておく
(declare-function eglot-ensure "eglot")
(defvar eglot-server-programs)


;;; ============================================================
;;; 設定
;;; ============================================================

(defgroup mk-lsp-manager nil
  "Language Server の自動検出・自動インストール。"
  :group 'tools
  :prefix "mk-lsp-manager-")

(defcustom mk-lsp-manager-auto-install t
  "非 nil なら未インストールの Language Server を自動でインストールする。"
  :type 'boolean
  :group 'mk-lsp-manager)

(defcustom mk-lsp-manager-auto-start t
  "非 nil なら Language Server が利用可能になった時点で Eglot を起動する。"
  :type 'boolean
  :group 'mk-lsp-manager)

(defcustom mk-lsp-manager-confirm-install t
  "非 nil ならインストール前にユーザーへ確認する。"
  :type 'boolean
  :group 'mk-lsp-manager)

(defcustom mk-lsp-manager-extra-program-directories
  '("~/.local/bin" "~/.rbenv/bin" "~/.asdf/bin" "/opt/homebrew/bin" "/usr/local/bin")
  "`exec-path' に見つからないコマンドを補助的に探すディレクトリ。

GUI Emacs ではシェルと PATH が異なることがあるため、mise / rbenv /
asdf 本体だけはここからも探す。PATH 全体をハードコードするのではなく、
バージョンマネージャの入口を見つけるためだけに使う。"
  :type '(repeat directory)
  :group 'mk-lsp-manager)


;;; ============================================================
;;; サーバーレジストリ（言語非依存）
;;; ============================================================

(cl-defstruct (mk-lsp-manager-server
               (:constructor mk-lsp-manager-server--create)
               (:conc-name mk-lsp-manager-server--)
               (:copier nil))
  "Language Server 1 つ分の定義。

LOCATE   … 引数なし。実行可能ファイルのパス（表示用）を返す。nil なら未インストール
COMMAND  … 引数なし。Eglot に渡すコマンドリストを返す
INSTALL  … CALLBACK を 1 つ取る。インストール完了後に (funcall CALLBACK 成否) を呼ぶ
DESCRIBE … 引数なし。status 表示用の (ラベル . 値) リストを返す"
  id name modes locate command install describe)

(defvar mk-lsp-manager-servers nil
  "登録済み Language Server の alist。要素は (ID . `mk-lsp-manager-server')。")

(cl-defun mk-lsp-manager-register-server (&key id name modes locate command install describe)
  "Language Server を登録する。

例:
  (mk-lsp-manager-register-server
   :id \\='rust-analyzer :name \"Rust\" :modes \\='(rust-mode rust-ts-mode)
   :locate  (lambda () (executable-find \"rust-analyzer\"))
   :command (lambda () (list (executable-find \"rust-analyzer\")))
   :install (lambda (cb) ...))"
  (setf (alist-get id mk-lsp-manager-servers)
        (mk-lsp-manager-server--create
         :id id :name (or name (symbol-name id)) :modes modes
         :locate locate :command command :install install :describe describe)))

(defun mk-lsp-manager-server (id)
  "ID で登録済みサーバーを取得する。"
  (alist-get id mk-lsp-manager-servers))

(defun mk-lsp-manager-server-for-mode (mode)
  "MODE を担当するサーバーを返す。派生モードも辿る。"
  (cl-loop for (_id . server) in mk-lsp-manager-servers
           when (cl-some (lambda (m) (provided-mode-derived-p mode m))
                         (mk-lsp-manager-server--modes server))
           return server))

(defun mk-lsp-manager--resolve (server-or-id)
  (if (mk-lsp-manager-server-p server-or-id)
      server-or-id
    (or (mk-lsp-manager-server server-or-id)
        (user-error "[mk-lsp-manager] 未登録のサーバーです: %s" server-or-id))))

(defun mk-lsp-manager-server-installed-p (server-or-id)
  "SERVER-OR-ID がインストール済みなら実行ファイルのパスを返す。"
  (let ((server (mk-lsp-manager--resolve server-or-id)))
    (funcall (mk-lsp-manager-server--locate server))))

(defun mk-lsp-manager-server-command (server-or-id)
  "SERVER-OR-ID を起動するコマンドリストを返す。"
  (let ((server (mk-lsp-manager--resolve server-or-id)))
    (funcall (mk-lsp-manager-server--command server))))


;;; ============================================================
;;; 外部コマンド実行のヘルパー
;;; ============================================================

(defconst mk-lsp-manager--process-buffer "*mk-lsp-manager*"
  "インストール処理の出力先バッファ。")

(defun mk-lsp-manager--find-program (name)
  "NAME を `exec-path' と `mk-lsp-manager-extra-program-directories' から探す。"
  (or (executable-find name)
      (cl-some (lambda (dir)
                 (let ((file (expand-file-name name (expand-file-name dir))))
                   (and (file-executable-p file) file)))
               mk-lsp-manager-extra-program-directories)))

(defun mk-lsp-manager--call (program &rest args)
  "PROGRAM を同期実行し、成功時に標準出力（trim 済み）を返す。失敗時は nil。"
  (when program
    (with-temp-buffer
      (when (eq 0 (apply #'process-file program nil t nil args))
        (let ((out (string-trim (buffer-string))))
          (unless (string-empty-p out) out))))))

(defun mk-lsp-manager--run-async (label command directory callback)
  "COMMAND を DIRECTORY で非同期実行し、終了時に (funcall CALLBACK 成否) を呼ぶ。"
  (let ((buffer (get-buffer-create mk-lsp-manager--process-buffer))
        (default-directory (file-name-as-directory directory)))
    (with-current-buffer buffer
      (goto-char (point-max))
      (let ((inhibit-read-only t))
        (insert (format "\n$ cd %s\n$ %s\n" default-directory
                        (mapconcat #'shell-quote-argument command " ")))))
    (make-process
     :name (format "mk-lsp-manager/%s" label)
     :buffer buffer
     :command command
     :noquery t
     :sentinel
     (lambda (process _event)
       (when (memq (process-status process) '(exit signal))
         (funcall callback (eq 0 (process-exit-status process))))))))


;;; ============================================================
;;; Ruby バックエンド
;;; ============================================================
;;
;; ruby-lsp は「プロジェクトが使っている Ruby」で起動する必要がある。
;; そのため PATH 先頭の ruby ではなく、mise / rbenv / asdf / chruby に
;; プロジェクトディレクトリで問い合わせて実行環境を決める。
;;
;; Rails / RSpec 専用機能は addon gem として提供され、プロジェクトの
;; Gemfile に追加すると ruby-lsp が自動で検出して読み込む:
;;
;;   group :development do
;;     gem "ruby-lsp-rails", require: false
;;     gem "ruby-lsp-rspec", require: false
;;   end
;;
;; 注意: eglot は LSP の CodeLens に未対応のため、ruby-lsp-rspec が提供する
;; 「spec 実行ボタン」自体は表示されない。spec の実行は引き続き
;; rspec-mode（mk-rails.el）の C-c , v 等を使う。

(defconst mk-lsp-manager--ruby-system-regexp
  "\\`\\(/usr/bin/\\|/System/\\|/Library/Ruby/\\)"
  "macOS の system Ruby を判定する正規表現。ここには gem を入れない。")

(defvar mk-lsp-manager--ruby-cache (make-hash-table :test #'equal)
  "プロジェクトルートごとの Ruby 環境キャッシュ。")

(defun mk-lsp-manager--ruby-project-root ()
  "現在のバッファが属する Ruby プロジェクトのルートを返す。"
  (expand-file-name
   (or (when-let* ((pr (project-current nil))) (project-root pr))
       (cl-some (lambda (file) (locate-dominating-file default-directory file))
                '("Gemfile" ".ruby-version"))
       default-directory)))

(defun mk-lsp-manager--ruby-version-file (root)
  "ROOT 以上の階層にある .ruby-version の中身を返す。"
  (when-let* ((dir (locate-dominating-file root ".ruby-version"))
              (file (expand-file-name ".ruby-version" dir)))
    (when (file-readable-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (let ((v (string-trim (buffer-string))))
          (unless (string-empty-p v) v))))))

(defun mk-lsp-manager--ruby-chruby-env (root)
  "chruby 形式（~/.rubies/ruby-<version>）の Ruby を探す。"
  (when-let* ((version (mk-lsp-manager--ruby-version-file root))
              (name (string-remove-prefix "ruby-" version))
              (ruby (expand-file-name (format "~/.rubies/ruby-%s/bin/ruby" name))))
    (when (file-executable-p ruby)
      (list :manager 'chruby :ruby ruby))))

(defun mk-lsp-manager--ruby-detect (root)
  "ROOT で使うべき Ruby を検出し、(:manager SYM :ruby PATH) を返す。"
  (let ((default-directory (file-name-as-directory root)))
    (cl-flet ((probe (manager program args)
                (when-let* ((exe (mk-lsp-manager--find-program program))
                            (path (apply #'mk-lsp-manager--call exe args)))
                  (when (file-executable-p path)
                    (list :manager manager :ruby path)))))
      (or (probe 'mise  "mise"  '("which" "ruby"))
          (probe 'rbenv "rbenv" '("which" "ruby"))
          (probe 'asdf  "asdf"  '("which" "ruby"))
          (mk-lsp-manager--ruby-chruby-env root)
          (when-let* ((ruby (mk-lsp-manager--find-program "ruby")))
            (list :manager 'path :ruby ruby))))))

(defun mk-lsp-manager--ruby-bin-directories (ruby)
  "RUBY に対して gem の実行ファイルが置かれるディレクトリを返す。"
  (when-let* ((out (mk-lsp-manager--call
                    ruby "-e"
                    "require 'rubygems'; puts Gem.bindir; puts File.join(Gem.user_dir, 'bin')")))
    (split-string out "\n" t)))

(defun mk-lsp-manager--ruby-bundled-p (root)
  "ROOT の Gemfile.lock に ruby-lsp が含まれるなら非 nil。"
  (let ((lock (expand-file-name "Gemfile.lock" root)))
    (and (file-readable-p lock)
         (with-temp-buffer
           (insert-file-contents lock)
           (goto-char (point-min))
           (and (re-search-forward "^ +ruby-lsp (" nil t) t)))))

(defun mk-lsp-manager--ruby-state (&optional force)
  "現在のバッファに対応する Ruby / ruby-lsp の状態を plist で返す。

FORCE が非 nil ならキャッシュを無視して再検出する。
外部コマンドを数回呼ぶため、プロジェクトルート単位でキャッシュする。"
  (let* ((root (mk-lsp-manager--ruby-project-root))
         (cached (unless force (gethash root mk-lsp-manager--ruby-cache))))
    (or cached
        (let* ((env (mk-lsp-manager--ruby-detect root))
               (ruby (plist-get env :ruby))
               (default-directory (file-name-as-directory root))
               (version (and ruby (mk-lsp-manager--call ruby "-e" "print RUBY_VERSION")))
               (system (and ruby (string-match-p mk-lsp-manager--ruby-system-regexp
                                                 (file-truename ruby))))
               (bin-dirs (and ruby (mk-lsp-manager--ruby-bin-directories ruby)))
               (gem-exe (mk-lsp-manager--ruby-gem-executable ruby bin-dirs))
               (ruby-lsp (mk-lsp-manager--ruby-sibling ruby bin-dirs "ruby-lsp"))
               ;; Gemfile.lock に ruby-lsp があり、かつ実際に gem が入っている
               ;; ときだけ bundle exec を使う。lock に載っているだけの状態で
               ;; bundle exec を選ぶと、bundler が解決のためにネットワークへ
               ;; 出ていき Eglot の起動が固まるため、ここでは外部コマンドを叩かない
               (bundle-exe (and ruby-lsp
                                (mk-lsp-manager--ruby-bundled-p root)
                                (mk-lsp-manager--ruby-sibling ruby bin-dirs "bundle")))
               (state (list :root root
                            :manager (or (plist-get env :manager) 'none)
                            :ruby ruby
                            :version version
                            :system (and system t)
                            :gem gem-exe
                            :bundler (and bundle-exe t)
                            :executable (or bundle-exe ruby-lsp)
                            :command (cond (bundle-exe (list bundle-exe "exec" "ruby-lsp"))
                                           (ruby-lsp (list ruby-lsp))))))
          (puthash root state mk-lsp-manager--ruby-cache)
          state))))

(defun mk-lsp-manager--ruby-sibling (ruby bin-dirs name)
  "NAME という実行ファイルを RUBY と同じ環境の中から探す。"
  (cl-some (lambda (dir)
             (let ((file (expand-file-name name dir)))
               (and (file-executable-p file) file)))
           (append bin-dirs
                   (and ruby (list (file-name-directory ruby))))))

(defun mk-lsp-manager--ruby-gem-executable (ruby bin-dirs)
  "RUBY に対応する gem コマンドを返す。"
  (or (mk-lsp-manager--ruby-sibling ruby bin-dirs "gem")
      (mk-lsp-manager--find-program "gem")))

(defun mk-lsp-manager-refresh ()
  "検出済みの Ruby 環境キャッシュを破棄して再検出させる。"
  (interactive)
  (clrhash mk-lsp-manager--ruby-cache)
  (message "[mk-lsp-manager] 環境情報を再取得します"))

(defun mk-lsp-manager--ruby-locate ()
  (plist-get (mk-lsp-manager--ruby-state) :executable))

(defun mk-lsp-manager--ruby-command ()
  (plist-get (mk-lsp-manager--ruby-state) :command))

(defun mk-lsp-manager--ruby-failure-help (state command)
  "インストール失敗時に表示する診断メッセージを組み立てる。"
  (concat
   "[mk-lsp-manager] ruby-lsp のインストールに失敗しました\n"
   (format "  使用した Ruby : %s\n" (or (plist-get state :ruby) "(見つかりません)"))
   (format "  Ruby バージョン: %s\n" (or (plist-get state :version) "(不明)"))
   (format "  バージョン管理 : %s\n" (plist-get state :manager))
   (format "  作業ディレクトリ: %s\n" (plist-get state :root))
   (format "  実行コマンド   : %s\n" (mapconcat #'shell-quote-argument command " "))
   "  対処方法:\n"
   (format "    1. ターミナルで `cd %s` してから上記コマンドを手動実行し、エラーを確認する\n"
           (plist-get state :root))
   "    2. Gemfile で管理する場合は Gemfile に gem \"ruby-lsp\", require: false を追加して bundle install する\n"
   (format "    3. 詳しい出力は %s バッファを参照する" mk-lsp-manager--process-buffer)))

(defun mk-lsp-manager--ruby-install (callback)
  "現在のプロジェクトの Ruby に ruby-lsp をインストールする。"
  (let* ((state (mk-lsp-manager--ruby-state t))
         (ruby (plist-get state :ruby))
         (gem (plist-get state :gem)))
    (cond
     ((null ruby)
      (message "[mk-lsp-manager] Ruby が見つかりません。mise / rbenv などで Ruby を導入してください")
      (funcall callback nil))
     ;; macOS の system Ruby には絶対にインストールしない（sudo も実行しない）
     ((plist-get state :system)
      (message (concat "[mk-lsp-manager] 現在の Ruby は macOS system Ruby です（%s）。\n"
                       "  ruby-lsp をインストールするには mise / rbenv などの Ruby 環境を使用してください。\n"
                       "  例: rbenv install 3.4.5 && rbenv local 3.4.5\n"
                       "  （sudo gem install は実行しません）")
               ruby)
      (funcall callback nil))
     ((null gem)
      (message "[mk-lsp-manager] gem コマンドが見つかりません（Ruby: %s）" ruby)
      (funcall callback nil))
     (t
      (let ((command (list gem "install" "ruby-lsp")))
        (message "Installing ruby-lsp...")
        (mk-lsp-manager--run-async
         "ruby-lsp" command (plist-get state :root)
         (lambda (success)
           (when (and success (eq 'rbenv (plist-get state :manager)))
             ;; rbenv は shim を作り直さないと新しい実行ファイルが見えない
             (when-let* ((rbenv (mk-lsp-manager--find-program "rbenv")))
               (mk-lsp-manager--call rbenv "rehash")))
           (clrhash mk-lsp-manager--ruby-cache)
           (if success
               (message "ruby-lsp installed successfully.")
             (message "%s" (mk-lsp-manager--ruby-failure-help state command)))
           (funcall callback success))))))))

(defun mk-lsp-manager--ruby-describe ()
  "status 表示用の (ラベル . 値) リストを返す。"
  (let* ((state (mk-lsp-manager--ruby-state))
         (root (plist-get state :root)))
    (list
     (cons "major-mode" (symbol-name major-mode))
     (cons "project root" root)
     (cons "version manager" (symbol-name (plist-get state :manager)))
     (cons ".ruby-version" (or (mk-lsp-manager--ruby-version-file root) "(なし)"))
     (cons "Ruby" (or (plist-get state :ruby) "(見つかりません)"))
     (cons "Ruby version" (or (plist-get state :version) "(不明)"))
     (cons "system Ruby" (if (plist-get state :system) "yes（インストール禁止）" "no"))
     (cons "Gemfile" (if (file-readable-p (expand-file-name "Gemfile" root)) "yes" "no"))
     (cons "ruby-lsp in Gemfile.lock" (if (plist-get state :bundler) "yes" "no"))
     (cons "ruby-lsp" (if (plist-get state :executable) "installed" "not installed"))
     (cons "ruby-lsp path" (or (plist-get state :executable) "-"))
     (cons "command" (if-let* ((cmd (plist-get state :command)))
                         (mapconcat #'shell-quote-argument cmd " ")
                       "-")))))

(mk-lsp-manager-register-server
 :id 'ruby-lsp
 :name "Ruby"
 :modes '(ruby-ts-mode ruby-mode)
 :locate #'mk-lsp-manager--ruby-locate
 :command #'mk-lsp-manager--ruby-command
 :install #'mk-lsp-manager--ruby-install
 :describe #'mk-lsp-manager--ruby-describe)


;;; ============================================================
;;; Eglot 連携
;;; ============================================================

(defun mk-lsp-manager-eglot-contact (&optional _interactive _project)
  "`eglot-server-programs' に登録する動的コンタクト。

バッファごとに `bundle exec ruby-lsp' と実体パスを出し分ける。"
  (when-let* ((server (mk-lsp-manager-server-for-mode major-mode)))
    (mk-lsp-manager-server-command server)))

(defun mk-lsp-manager--start-eglot (buffer)
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (unless (bound-and-true-p eglot--managed-mode)
        (message "Starting Eglot...")
        (eglot-ensure)))))

(defun mk-lsp-manager--install-and-start (server buffer)
  (funcall (mk-lsp-manager-server--install server)
           (lambda (success)
             (when (and success mk-lsp-manager-auto-start)
               (mk-lsp-manager--start-eglot buffer)))))

;;;###autoload
(defun mk-lsp-manager-ensure ()
  "現在のバッファに対応する Language Server を用意し、Eglot を起動する。

各言語モードの hook から呼ぶ。"
  (interactive)
  (when-let* ((server (mk-lsp-manager-server-for-mode major-mode))
              (id (mk-lsp-manager-server--id server))
              (name (mk-lsp-manager-server--name server)))
    (cond
     ((mk-lsp-manager-server-installed-p server)
      (when mk-lsp-manager-auto-start
        (mk-lsp-manager--start-eglot (current-buffer))))
     ((not mk-lsp-manager-auto-install)
      (message "%s Language Server '%s' is not installed.  M-x mk-lsp-manager-install で導入できます"
               name id))
     ((and mk-lsp-manager-confirm-install
           (not (y-or-n-p (format "%s Language Server '%s' is not installed.  Install %s automatically? "
                                  name id id))))
      (message "%s のインストールを見送りました。M-x mk-lsp-manager-install で後から導入できます" id))
     (t
      (mk-lsp-manager--install-and-start server (current-buffer))))))

;;;###autoload
(defun mk-lsp-manager-install (id)
  "ID の Language Server をインストールする。"
  (interactive
   (list (intern (completing-read
                  "Install language server: "
                  (mapcar (lambda (entry) (symbol-name (car entry))) mk-lsp-manager-servers)
                  nil t nil nil
                  (when-let* ((server (mk-lsp-manager-server-for-mode major-mode)))
                    (symbol-name (mk-lsp-manager-server--id server)))))))
  (let ((server (mk-lsp-manager--resolve id)))
    (mk-lsp-manager--install-and-start server (current-buffer))))


;;; ============================================================
;;; 状態表示
;;; ============================================================

;;;###autoload
(defun mk-lsp-manager-status ()
  "登録済み Language Server の状態を表示する。"
  (interactive)
  (let ((source (current-buffer))
        (mode major-mode))
    (with-current-buffer (get-buffer-create "*mk-lsp-manager-status*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (special-mode)
        (insert "Language Server Manager Status\n\n")
        (dolist (entry mk-lsp-manager-servers)
          (let* ((server (cdr entry))
                 (active (cl-some (lambda (m) (provided-mode-derived-p mode m))
                                  (mk-lsp-manager-server--modes server)))
                 (rows (with-current-buffer source
                         (funcall (mk-lsp-manager-server--describe server)))))
            (insert (format "%s%s\n"
                            (mk-lsp-manager-server--name server)
                            (if active "  (current buffer)" "")))
            (dolist (row rows)
              (insert (format "  %-24s %s\n" (concat (car row) ":") (cdr row))))
            (insert (format "  %-24s %s\n" "Eglot:"
                            (if (with-current-buffer source
                                  (and active (bound-and-true-p eglot--managed-mode)))
                                "running" "not running")))
            (insert "\n")))
        (insert (format "auto-install: %s / auto-start: %s / confirm-install: %s\n"
                        mk-lsp-manager-auto-install
                        mk-lsp-manager-auto-start
                        mk-lsp-manager-confirm-install))
        (goto-char (point-min)))
      (display-buffer (current-buffer)))))


;;; ============================================================
;;; フック登録
;;; ============================================================

(with-eval-after-load 'eglot
  ;; コマンドは関数で動的に解決する（bundle exec / 実体パスの出し分け）
  (add-to-list 'eglot-server-programs
               '((ruby-ts-mode ruby-mode) . mk-lsp-manager-eglot-contact)))

;; ruby-mode / ruby-ts-mode の共通の親フックに登録する
;; （tree-sitter の有無を問わず 1 箇所で済む）
(add-hook 'ruby-base-mode-hook #'mk-lsp-manager-ensure)

(provide 'mk-lsp-manager)
