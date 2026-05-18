;;; ============================================================
;;; xwidgets (内蔵 WebKit ブラウザ)
;;; ============================================================

(defun mk-xwidgets-google (query)
  "QUERY を Google 検索し、結果を内蔵 WebKit で開く。"
  (interactive "sGoogle: ")
  (xwidget-webkit-browse-url
   (format "https://www.google.com/search?q=%s"
           (url-hexify-string query))))

;; Vimium 風 1〜2 キーでのリンクジャンプ実装。
;; ページに JS でラベル (aa, as, ad, ..., kl) を注入し、
;; ホームロー (a-s-d-f-g-h-j-k-l) の2文字を入力するとリンクが click される。
;; macOS の xwidget は xwidget-webkit-edit-mode 経由のキー入力が
;; WebKit に届かないため、Elisp 側でキーを読み JS に渡す方式を取る。
(defconst mk-xwidgets--hint-js
  "(function() {
  if (window.__mkXwidgetsHints) window.__mkXwidgetsHints.cleanup();
  const HOME = 'asdfghjkl'.split('');
  function inject() {
    cleanup();
    const els = Array.from(document.querySelectorAll(
      'a, button, [role=button], [role=link], input[type=submit], input[type=button]'));
    const visible = els.filter(a => {
      const r = a.getBoundingClientRect();
      return r.width > 0 && r.height > 0 &&
             r.bottom > 0 && r.right > 0 &&
             r.top < window.innerHeight && r.left < window.innerWidth;
    });
    visible.forEach((a, i) => {
      if (i >= HOME.length * HOME.length) return;
      const label = HOME[Math.floor(i / HOME.length)] + HOME[i % HOME.length];
      const r = a.getBoundingClientRect();
      const badge = document.createElement('span');
      badge.textContent = label.toUpperCase();
      badge.dataset.mkxwHint = label;
      badge.style.cssText = 'position:absolute;background:#fce96a;color:#000;font:bold 11px monospace;padding:1px 3px;border:1px solid #444;z-index:2147483647;line-height:1;border-radius:3px;pointer-events:none;';
      badge.style.left = (r.left + window.scrollX) + 'px';
      badge.style.top = (r.top + window.scrollY) + 'px';
      document.body.appendChild(badge);
      a.dataset.mkxwHintId = label;
    });
  }
  function narrow(prefix) {
    document.querySelectorAll('[data-mkxw-hint]').forEach(b => {
      b.style.display = b.dataset.mkxwHint.startsWith(prefix) ? '' : 'none';
    });
  }
  function click(label) {
    const el = document.querySelector('[data-mkxw-hint-id=\"' + label + '\"]');
    cleanup();
    if (el) el.click();
  }
  function cleanup() {
    document.querySelectorAll('[data-mkxw-hint]').forEach(b => b.remove());
    document.querySelectorAll('[data-mkxw-hint-id]').forEach(a => delete a.dataset.mkxwHintId);
  }
  window.__mkXwidgetsHints = { inject, narrow, click, cleanup };
  inject();
})();")

(defun mk-xwidgets-hint-jump ()
  "Vimium 風に2キーでリンクをクリックする。
ホームロー (a/s/d/f/g/h/j/k/l) の2文字ラベルがリンク上に表示され、
対応する2文字を入力するとそのリンクがクリックされる。C-g で中断。"
  (interactive)
  (unless (derived-mode-p 'xwidget-webkit-mode)
    (user-error "Not in an xwidget-webkit buffer"))
  (let ((xw (xwidget-webkit-current-session)))
    (cl-flet ((cleanup ()
                (xwidget-webkit-execute-script
                 xw "window.__mkXwidgetsHints && window.__mkXwidgetsHints.cleanup();")))
      (xwidget-webkit-execute-script xw mk-xwidgets--hint-js)
      (sit-for 0.05)
      (condition-case nil
          (let ((c1 (read-char "hint: ")))
            (xwidget-webkit-execute-script
             xw (format "window.__mkXwidgetsHints.narrow(%S);" (string c1)))
            (let ((c2 (read-char (format "hint: %c" c1))))
              (xwidget-webkit-execute-script
               xw (format "window.__mkXwidgetsHints.click(%S);" (string c1 c2)))))
        (quit (cleanup))))))

;; xwidgets は Emacs 同梱の機能で、GUI かつ xwidget サポート付きで
;; ビルドされている場合のみ動作する。TUI や非対応ビルドでロードしても
;; 害がないようガードする。
(use-package xwidget
  :ensure nil
  :if (and (display-graphic-p) (featurep 'xwidget-internal))
  :custom
  ;; browse-url 経由のリンク・検索結果を Emacs 内 WebKit で開く
  ;; engine-mode (mk-engine-mode) の検索結果もこちらに流れる
  (browse-url-browser-function #'xwidget-webkit-browse-url)
  ;; Cookie をセッション間で永続化する
  (xwidget-webkit-cookie-file
   (expand-file-name "xwidget-cookies" user-emacs-directory))
  :bind
  (("C-c w w" . xwidget-webkit-browse-url)
   ("C-c w b" . xwidget-webkit-bookmark-jump-new-session)
   ("C-c w g" . mk-xwidgets-google)
   :map xwidget-webkit-mode-map
   ("n" . xwidget-webkit-scroll-up-line)
   ("p" . xwidget-webkit-scroll-down-line)
   ("f" . mk-xwidgets-hint-jump)
   ("F" . xwidget-webkit-forward)
   ("b" . xwidget-webkit-back)
   ("r" . xwidget-webkit-reload)
   ("g" . xwidget-webkit-browse-url)
   ("y" . xwidget-webkit-copy-selection-as-kill)
   ("c" . xwidget-webkit-current-url)))

;; xwwp: WebKit ページに JavaScript でリンクヒントを注入し、
;; completing-read でリンクを選択して開けるようにする。
;; macOS の xwidget は xwidget-webkit-edit-mode 経由のキー入力が
;; WebKit に届かない問題があるため、キーボードでリンクをクリック
;; する手段として導入する。
(use-package xwwp-follow-link
  :straight (:host github :repo "canatella/xwwp")
  :if (and (display-graphic-p) (featurep 'xwidget-internal))
  :after xwidget
  :custom
  (xwwp-follow-link-completion-system 'default)
  :bind (:map xwidget-webkit-mode-map
              ("l" . xwwp-follow-link)))

(provide 'mk-xwidgets)
