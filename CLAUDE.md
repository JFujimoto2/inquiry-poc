# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

施設向け問い合わせ・見積自動化システムのPoC。
公開問い合わせフォームから見積→予約→変更依頼までのフローを自動化する。

## 開発コマンド

```bash
# サーバー起動（Rails + Tailwind CSS watch）
bin/dev

# テスト
bundle exec rspec                          # 全テスト
bundle exec rspec spec/models/             # ディレクトリ単位
bundle exec rspec spec/models/user_spec.rb # ファイル単位
bundle exec rspec spec/models/user_spec.rb:15  # 行番号指定

# Lint・静的解析
bundle exec rubocop                        # RuboCop（rubocop-rails-omakase準拠）
bundle exec rubocop -a                     # 自動修正
bundle exec brakeman --no-pager -q         # セキュリティスキャン
bundle exec bundler-audit check            # 依存脆弱性チェック

# CI全ステップ実行
bin/ci

# DB
bin/rails db:migrate
bin/rails db:migrate RAILS_ENV=test
```

PostgreSQLポートは `5433`（`ENV["PGPORT"]` で変更可）。

## アーキテクチャ

### 3つの認証領域

| 領域 | ベースコントローラ | 認証方式 | レイアウト |
|------|-------------------|----------|-----------|
| Admin (`/admin/`) | `Admin::BaseController` | Rails 8標準（パスワード） + `AdminAuthorization` concern（admin roleのみ許可） | `admin` |
| Mypage (`/mypage/`) | `Mypage::BaseController` | マジックリンク（`CustomerAuthentication` concern） | `mypage` |
| Public (`/`) | `ApplicationController` | 認証なし（`skip_before_action :require_authentication`） | `application` |

Admin認証は `Authentication` concern → `Current.session.user` で管理。
Customer認証は `CustomerAuthentication` concern → `cookies.signed[:customer_session_id]` → `CustomerSession`（30日有効、マジックリンク30分有効）。

### ビジネスフロー

```
問い合わせ(Inquiry) → 見積生成(Quote/QuoteProcessingJob)
                       → PDF生成(QuotePdfGenerator) + メール送信(QuoteMailer)
                    → 予約作成(CreateReservationFromInquiry → Reservation)
                       → 確認メール(ReservationConfirmationJob)
                    → 変更依頼(ChangeRequest) → 管理者対応
                       → 通知(ChangeRequestNotificationJob)
```

### Service Objectパターン

ビジネスロジックはモデルではなく `app/services/` に分離する。

- `QuoteCalculator` — PriceMaster + CalendarTypeから料金計算。`Result = Struct.new`で結果返却
- `QuotePdfGenerator` — Prawnで見積PDF生成
- `ReservationStatusManager` — `VALID_TRANSITIONS`定数で状態遷移を定義。`InvalidTransitionError`例外
- `CreateReservationFromInquiry` — Inquiry→Customer＋Reservation変換（トランザクション内）
- `CustomerMagicLinkSender` — マジックリンクメール送信
- `Aipass::Client` / `Aipass::MockClient` — 外部連携（dev/testではMock使用）

### メールテンプレート

`EmailTemplate`モデルで施設ごとにメールテンプレートを管理。`{{variable_name}}`形式のプレースホルダーを`interpolate`メソッドで展開する。未定義のプレースホルダーは元の文字列を保持。

## セキュリティ・機密情報ルール

- **個人情報・社内情報を絶対にコミットしない**
- APIキー、パスワード、認証情報などのシークレットをコードやコミットに含めない
- クライアント名、担当者名、社内コスト情報などをソースコードやREADMEに記載しない
- `.env` は `.gitignore` で除外済み。`docs/internal/` も同様
- コミット前に `git diff --cached` で機密情報の混入がないか確認すること

## 開発運用ルール

- mainへの直接push禁止。必ずPR経由でマージする
- ブランチ名: `feature/*`, `fix/*`, `hotfix/*`
- コミットメッセージ: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- 詳細は `docs/DEVELOPMENT.md` を参照

## コーディング規約

詳細は `docs/CODING_STANDARDS.md` を参照。以下は要点のみ。

- マジックナンバー・マジックストリング禁止。定数（`.freeze`）として定義する
- メソッドは単一責任。1メソッド15行以内、ネスト最大3段階
- モデル内の構成順序: 定数 → アソシエーション → バリデーション → スコープ → メソッド
- ビジネスロジックはService Objectに分離。エントリポイントは `call` メソッド
- N+1クエリを避ける（`includes` / `preload`）
- Tailwind CSSユーティリティクラスでスタイリング
- テスト: RSpec + FactoryBot + Shoulda Matchers。TDDフロー (Red → Green → Refactor)
- Zeitwerkオートロード命名規約に従う（例: `app/services/aipass/client.rb` → `Aipass::Client`）
