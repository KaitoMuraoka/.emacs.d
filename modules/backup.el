;;; backup.el --- -*- lexical-binding: t -*-
(setq make-backup-files nil) ;; バックアップファイルを作成しない
(setq auto-save-default nil) ;; オートセーブファイルを作成しない
(global-auto-revert-mode t) ;; 更新されたファイルを自動的に読み込み直す

(provide 'backup)
;;; backup.el ends here
