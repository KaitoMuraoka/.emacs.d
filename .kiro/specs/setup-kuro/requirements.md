# Requirements: setup-kuro

## Overview
Rust バックエンド + Emacs Lisp フロントエンドで動作する高性能ターミナルエミュレータ「kuro」を、既存の Emacs 設定（straight.el + use-package）に統合する。

## User Stories

### Story 1: kuro のビルドと配置
**As a** Emacs ユーザー
**I want** kuro の Rust バイナリをビルドして PATH に配置したい
**So that** Emacs から kuro バックエンドを呼び出せるようにしたい

#### Acceptance Criteria
- WHEN ユーザーが `make build` を実行する THE SYSTEM SHALL Rust バイナリが `rust-core/target/` 以下にビルドされる
- WHEN ビルドが完了する THE SYSTEM SHALL バイナリが Emacs の `exec-path` から参照できる場所に存在する
- WHEN Rust が 1.84.0 未満である THE SYSTEM SHALL ビルドが失敗し、バージョン不足のエラーが出る

### Story 2: straight.el による kuro パッケージの管理
**As a** Emacs ユーザー
**I want** straight.el で kuro の Emacs Lisp 部分を管理したい
**So that** 他のパッケージと同様に `init.el` で宣言的に設定できる

#### Acceptance Criteria
- WHEN Emacs が起動する THE SYSTEM SHALL straight.el が GitHub から `takeokunn/kuro` をクローンまたは更新する
- WHEN `(require 'kuro)` が評価される THE SYSTEM SHALL kuro の Emacs Lisp モジュールが正常にロードされる
- WHEN ネットワークが利用できない THE SYSTEM SHALL すでにクローン済みのリポジトリからロードする

### Story 3: kuro の基本設定と起動
**As a** Emacs ユーザー
**I want** キーバインドで kuro ターミナルを起動したい
**So that** ターミナルをすばやく開いて作業できる

#### Acceptance Criteria
- WHEN 設定したキーバインドを押す THE SYSTEM SHALL 新しい kuro ターミナルバッファが開く
- WHEN kuro ターミナルが開く THE SYSTEM SHALL デフォルトシェル（zsh）が起動する
- WHEN kuro バッファが表示される THE SYSTEM SHALL 行番号・カーソル行ハイライトが無効化される（ターミナル表示を壊さないため）

### Story 4: eat との共存
**As a** Emacs ユーザー
**I want** 既存の eat 設定を壊さずに kuro を追加したい
**So that** 必要に応じて eat と kuro を使い分けられる

#### Acceptance Criteria
- WHEN kuro の設定を追加する THE SYSTEM SHALL 既存の eat の設定・キーバインドが変わらず動作する
- WHEN eat のキーバインド（`C-c v t`）を押す THE SYSTEM SHALL eat ターミナルが開く（kuro ではない）
- WHEN kuro のキーバインドを押す THE SYSTEM SHALL kuro ターミナルが開く（eat ではない）

## Out of Scope
- eat を kuro に置き換える（両方を並存させる）
- kuro の高度な機能（Kitty Graphics Protocol, Sixel）の設定
- kuro を claude-code-ide のバックエンドとして使用する設定
- kuro の独自ビルドスクリプトの作成
