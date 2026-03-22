# Tasks: setup-kuro

## Implementation Tasks

- [x] 1. Rust ビルド環境の確認
  - 詳細: `rustc --version` で Rust 1.84.0 以上がインストールされていることを確認する
  - 参照: requirements.md Story 1

- [x] 2. kuro を手動でビルド・インストール
  - 詳細: `git clone https://github.com/takeokunn/kuro.git` してから `make build && make install` を実行し、`~/.local/share/kuro/` にバイナリが生成されることを確認する
  - 参照: requirements.md Story 1 / design.md Data Model
  - [x] 2.1 `~/.local/share/kuro/libkuro_core.dylib`（macOS）が存在することを確認
  - [x] 2.2 クローンしたリポジトリは作業後に削除可（straight.el が再クローンする）

- [x] 3. init.el に kuro の use-package 設定を追加
  - 詳細: straight.el の `:pre-build` フックと `:files` を指定して kuro を宣言的に設定する
  - 参照: requirements.md Story 2 / design.md Implementation Notes
  - [x] 3.1 `eat` の設定ブロックの直後に kuro セクションを追加
  - [x] 3.2 `:pre-build` に `("make" "build")` と `("make" "install")` を設定
  - [x] 3.3 `:files` に `("emacs-lisp/*.el")` を指定

- [x] 4. kuro バッファの表示設定を追加
  - 詳細: kuro-mode-hook で行番号・カーソル行ハイライトを無効化する（eat と同様の設定）
  - 参照: requirements.md Story 3 / design.md kuro バッファの表示設定
  - [x] 4.1 `display-line-numbers-mode -1` を kuro-mode-hook に追加
  - [x] 4.2 `hl-line-mode -1` を kuro-mode-hook に追加

- [x] 5. キーバインドの設定
  - 詳細: `C-c v k` に `kuro-create` を割り当て、eat の `C-c v t` と共存させる
  - 参照: requirements.md Story 3, Story 4 / design.md キーバインド設計
  - [x] 5.1 `use-package :bind` で `C-c v k` → `kuro-create` を設定

- [ ] 6. 動作確認
  - 詳細: Emacs を再起動して kuro が正常に動作するか手動で確認する
  - 参照: design.md Testing Strategy
  - [ ] 6.1 `M-x kuro-create` でターミナルが開くことを確認
  - [ ] 6.2 `C-c v k` のキーバインドが動作することを確認
  - [ ] 6.3 kuro バッファで行番号・ハイライトが無効になっていることを確認
  - [ ] 6.4 `C-c v t` で eat が引き続き動作することを確認
  - [ ] 6.5 Emacs を再起動して2回目の起動でビルドがスキップされることを確認
