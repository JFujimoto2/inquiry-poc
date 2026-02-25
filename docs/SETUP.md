# 開発環境構築ガイド

ローカル環境でアプリケーションを起動するための手順。

## 前提条件

| ツール | バージョン | 確認コマンド |
|--------|-----------|-------------|
| Ruby | 3.3.2 | `ruby -v` |
| Bundler | 2.6+ | `bundle -v` |
| PostgreSQL | 16+ | `psql --version` |
| Node.js | 不要（Importmap使用） | — |

### Ruby のインストール

rbenv を使用する場合:

```bash
rbenv install 3.3.2
rbenv local 3.3.2
```

### PostgreSQL のインストール

**macOS:**
```bash
brew install postgresql@16
brew services start postgresql@16
```

**Ubuntu / WSL2:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib libpq-dev
sudo service postgresql start
```

> **注意:** 本プロジェクトはデフォルトで **ポート 5433** に接続します。
> PostgreSQL が標準の 5432 で動作している場合は、環境変数で上書きしてください:
>
> ```bash
> export PGPORT=5432
> ```

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/JFujimoto2/inquiry-poc.git
cd inquiry-poc
```

### 2. 依存関係のインストール

```bash
bundle install
```

### 3. データベースの作成

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

シードデータにより以下が作成されます:

| データ | 内容 |
|--------|------|
| 管理者ユーザー | `admin@example.com` / `password123` |
| 施設 | Mountain Lodge, Seaside Resort |
| カレンダー種別 | 2026年GW期間の休日/平日設定 |
| 料金マスタ | 5品目 × 3日種 × 2施設 = 30件 |
| メールテンプレート | 見積/予約確認の各2件 × 2施設 |

### 4. 日本語フォントの配置（PDF生成用）

見積PDF生成に NotoSansJP フォントが必要です。

```bash
# Google Fonts からダウンロード
curl -L -o /tmp/NotoSansJP.zip \
  "https://fonts.google.com/download?family=Noto+Sans+JP"

# 解凍してコピー
unzip /tmp/NotoSansJP.zip -d /tmp/NotoSansJP
cp /tmp/NotoSansJP/static/NotoSansJP-Regular.ttf app/assets/fonts/
cp /tmp/NotoSansJP/static/NotoSansJP-Bold.ttf app/assets/fonts/
```

> フォントがなくてもアプリは起動しますが、PDF内の日本語が文字化けします。

### 5. 開発サーバーの起動

```bash
bin/dev
```

以下の2プロセスが起動します（Procfile.dev）:

| プロセス | 役割 |
|----------|------|
| `web` | Rails サーバー（Puma） |
| `css` | Tailwind CSS のウォッチビルド |

ブラウザで http://localhost:3000 にアクセスし、管理画面にログインしてください。

## ワンコマンドセットアップ

上記の手順 2〜5 をまとめて実行するには:

```bash
bin/setup
```

`bin/setup` は依存関係のインストール → DB準備 → ログクリア → サーバー起動を自動で行います。

DB をリセットしたい場合:

```bash
bin/setup --reset
```

## 環境変数

環境変数は `.env` ファイルで管理できます（`.gitignore` で除外済み）。

```bash
# .env（必要に応じて作成）
PGPORT=5433              # PostgreSQL ポート（デフォルト: 5433）
PORT=3000                # Web サーバーポート（デフォルト: 3000）
```

開発環境では以下は不要です（モック/デフォルト値が使われます）:

| 変数 | 用途 | 開発時の動作 |
|------|------|-------------|
| `AIPASS_BASE_URL` | aiPass API エンドポイント | MockClient が使われる |
| `AIPASS_API_KEY` | aiPass API 認証キー | 未設定でOK |
| `SENDGRID_API_KEY` | メール送信 | テスト配信（実送信なし） |

## テストの実行

```bash
# 全テスト実行
bundle exec rspec

# セキュリティスキャン
bundle exec brakeman --no-pager -q

# 依存脆弱性チェック
bundle exec bundler-audit check

# Lint
bundle exec rubocop

# CI 全チェック（上記すべて）
bin/ci
```

## メール確認

開発環境ではメールは実送信されません。送信されたメールはサーバーログに出力されます。

メールのプレビューを確認するには、`letter_opener` 等の gem を追加するか、ログで確認してください。

## アーキテクチャ概要

```
app/
├── controllers/
│   ├── admin/          # 管理画面（認証: Rails 8標準）
│   ├── mypage/         # 顧客マイページ（認証: マジックリンク）
│   └── concerns/       # AdminAuthorization, CustomerAuthentication
├── models/             # ActiveRecord モデル
├── services/           # ビジネスロジック（QuoteCalculator, ReservationStatusManager 等）
│   └── aipass/         # PMS連携アダプタ（MockClient / Client）
├── mailers/            # QuoteMailer, ReservationMailer, CustomerMailer 等
├── jobs/               # 非同期ジョブ（QuoteProcessingJob 等）
├── views/
│   ├── layouts/        # admin.html.erb, mypage.html.erb
│   ├── admin/          # 管理画面ビュー
│   └── mypage/         # マイページビュー
└── helpers/            # ステータスバッジ等のビューヘルパー
```

## トラブルシューティング

### PostgreSQL に接続できない

```bash
# サービスが起動しているか確認
sudo service postgresql status

# ポートを確認
sudo ss -tlnp | grep postgres

# ポートが 5432 の場合は環境変数を設定
export PGPORT=5432
```

### `bin/dev` で foreman が見つからない

```bash
gem install foreman
```

### Tailwind CSS が反映されない

`bin/dev` で `css` プロセスが起動しているか確認してください。手動でビルドするには:

```bash
bin/rails tailwindcss:build
```

### PDF の日本語が文字化けする

`app/assets/fonts/` に NotoSansJP フォントファイルが配置されているか確認してください。手順は「4. 日本語フォントの配置」を参照。
