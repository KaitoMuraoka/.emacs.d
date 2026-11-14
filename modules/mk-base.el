;;; mk-base.el --- -*- lexical-binding: t -*-
(setq make-backup-files nil) ;; バックアップファイルを作成しない
(setq auto-save-default nil) ;; オートセーブファイルを作成しない
(setq-default tab-width 4) ;; TAB の表示幅。初期値は8
(global-auto-revert-mode t) ;; 更新されたファイルを自動的に読み込み直す

;; Macだけに読み込ませる内容を書く
(when (eq system-type 'darwin)
  ;; MacのEmacsでファイル名を正しく扱うための設定
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs)
  ;; Xcode 26 の ld は MacOSX27 SDK の tbd を読めず native-comp が失敗するため、MacOSX26 SDK を優先させる
  (let ((sdk-lib "/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk/usr/lib"))
    (when (file-directory-p sdk-lib)
      (setq native-comp-driver-options (list "-Wl,-w" (concat "-L" sdk-lib))))))

(provide 'mk-base)
;;; mk-base.el ends here
