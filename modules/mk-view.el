;;; ============================================================
;;; 外観（透明化・ガラス効果）
;;; ============================================================
(set-default-coding-systems 'utf-8)
;; フォント（HackGen は日本語グリフ内包のため fontset 設定不要）
(set-face-attribute 'default nil :family "HackGen Console" :height 125)

;; GUI/TUI の外観
(use-package color-theme-sanityinc-tomorrow
  :config
  (load-theme 'sanityinc-tomorrow-night t))

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
