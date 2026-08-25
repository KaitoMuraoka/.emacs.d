;;; ============================================================
;;; 外観（透明化・ガラス効果）
;;; ============================================================
(set-default-coding-systems 'utf-8)
;; フォントは fontaine のプリセットで管理する
;; 既定は fontaine 標準の regular。M-x fontaine-set-preset で切り替える
(use-package fontaine
  :custom
  ;; regular プリセットの文字サイズを大きくする（デフォルト100だと小さいため）
  ;; macOS には "Monospace" という実フォントが無く courier にフォールバックし、
  ;; 罫線（U+2500 系）が途切れて端末バッファの表示が崩れるため実名で指定する
  (fontaine-presets '((regular)
                       (t :default-family "HackGen Console"
                          :fixed-pitch-family "HackGen Console"
                          :default-weight regular
                          :default-slant normal
                          :default-width normal
                          :default-height 125)))
  :config
  ;; fontaine は端末では動作せず警告を出すため GUI のときだけ適用する
  (when (display-graphic-p)
    ;; 選択したプリセットを次回起動時に復元する
    (fontaine-mode 1)
    (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))))

;; GUI/TUI の外観
;; nano-theme は MELPA 未収録のため straight に GitHub リポジトリを直接指定する
(use-package nano-theme
  :straight (nano-theme :type git :host github :repo "rougier/nano-theme")
  :init
  (defun mk-load-theme-for-appearance (appearance)
    "APPEARANCE (`light' / `dark') に対応する nano-theme を読み込む。"
    (mapc #'disable-theme custom-enabled-themes)
    (if (eq appearance 'light)
        (load-theme 'nano-light t)
      (load-theme 'nano-dark t)))
  :config
  ;; macOS のライト/ダークモードに追従する。
  ;; TUI では ns-system-appearance が nil のため dark にフォールバックし、
  ;; 背景は下の unspecified-bg 設定でターミナル側のテーマに従わせる。
  (mk-load-theme-for-appearance
   (or (and (boundp 'ns-system-appearance) ns-system-appearance) 'dark))
  (when (boundp 'ns-system-appearance-change-functions)
    (add-hook 'ns-system-appearance-change-functions
              #'mk-load-theme-for-appearance)))

;;; ------------------------------------------------------------
;;; フレーム種別ごとの外観設定
;;; ------------------------------------------------------------
;; 理由: daemon 起動時はグラフィカルフレームが存在せず (display-graphic-p) が
;;       nil を返す。ロード時に一度だけ判定して設定すると TUI 用の設定が
;;       グローバル指定として残り、後から emacsclient -c で作られる
;;       GUI フレームまで壊してしまう。
;;       そのため判定と適用はフレーム生成のたびに、そのフレームに対して行う。

(defvar mk--emoji-fontset-configured nil
  "絵文字 fontset を設定済みかどうか。
fontset は全フレーム共通のため一度だけ実行すればよい。")

(defun mk--setup-gui-frame (frame)
  "グラフィカルな FRAME 向けの外観設定を適用する。"
  (unless mk--emoji-fontset-configured
    ;; 絵文字・天気記号（☁ ⛅ 🌧 等）は HackGen 非収録のため Apple Color Emoji へフォールバック
    (with-demoted-errors "mk-view: emoji fontset の設定に失敗: %S"
      (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") frame 'prepend)
      (set-fontset-font t '(#x2600 . #x26FF) (font-spec :family "Apple Color Emoji") frame 'prepend)
      (set-fontset-font t '(#x1F300 . #x1FAFF) (font-spec :family "Apple Color Emoji") frame 'prepend)
      (setq mk--emoji-fontset-configured t))))

(defun mk--setup-tty-frame (frame)
  "端末上の FRAME 向けの外観設定を適用する。
`set-face-background' に FRAME を渡すことが重要。省略すると default フェイスの
グローバル指定と `default-frame-alist' が \"unspecified-bg\" で上書きされ、
以降に作られる GUI フレームが Unknown color で生成に失敗する。"
  (set-face-background 'default "unspecified-bg" frame)
  (set-face-background 'line-number "unspecified-bg" frame)
  (set-face-background 'line-number-current-line "unspecified-bg" frame)
  ;; ターミナルのマウスイベントを受け取る
  (xterm-mouse-mode 1))

(defun mk-setup-frame-appearance (frame)
  "FRAME の表示種別に応じた外観設定を適用する。"
  (if (display-graphic-p frame)
      (mk--setup-gui-frame frame)
    (mk--setup-tty-frame frame)))

(defun mk--setup-initial-frame-appearance ()
  "起動時の初期フレームへ外観設定を適用する。"
  (mk-setup-frame-appearance (selected-frame)))

(add-hook 'after-make-frame-functions #'mk-setup-frame-appearance)
;; 初期フレームには after-make-frame-functions が走らないため別途適用する。
;; ロード時ではなく window-setup-hook を使うのは、起動処理の終盤で走る
;; `frame-notice-user-settings' がフレームのフェイスを再初期化し、
;; それより前に設定した内容が失われるため。
(add-hook 'window-setup-hook #'mk--setup-initial-frame-appearance)

;; 本文を中央寄せして執筆に集中する
(use-package olivetti
  :custom
  (olivetti-body-width 100)
  :hook (text-mode . olivetti-mode)
  :init
  ;; 起動画面 (*GNU Emacs*) は text-mode 派生ではなくフックが効かないため、
  ;; 画面生成後に明示的に有効化する
  (defun mk-olivetti-enable-in-splash (&rest _)
    (when-let* ((buf (get-buffer "*GNU Emacs*")))
      (with-current-buffer buf
        (olivetti-mode 1))))
  (advice-add 'fancy-startup-screen :after #'mk-olivetti-enable-in-splash)
  (advice-add 'normal-splash-screen :after #'mk-olivetti-enable-in-splash))

;; メニューバーを非表示
(menu-bar-mode 0)

;; スクロールバーを非表示
(scroll-bar-mode -1)

;; ツールバーを非表示
(tool-bar-mode 0)

;; ピンチジェスチャーによるフォントサイズ変更を無効化
(global-set-key (kbd "<pinch>") 'ignore)

;; splash.svg の :scale default が Retina 環境でフレーム高を超え
;; use-fancy-splash-screens-p が nil を返す問題を修正する。
;; SVG が描画可能な場合は常にロゴを表示するよう advice でバイパスする。
;; advice 本体が実行時に display-graphic-p を見るため登録は無条件でよい。
(advice-add 'use-fancy-splash-screens-p :override
            (lambda ()
              (and (display-graphic-p)
                   (ignore-errors
                     (create-image (fancy-splash-image-file))))))

(provide 'mk-view)
