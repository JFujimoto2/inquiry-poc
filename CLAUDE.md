# CLAUDE.md

## プロジェクト概要

施設向け問い合わせ・見積自動化システムのPoC。Rails 8 + Hotwire + PostgreSQL。

## セキュリティ・機密情報ルール

- **個人情報・社内情報を絶対にコミットしない**
- APIキー、パスワード、認証情報などのシークレットをコードやコミットに含めない
- クライアント名、担当者名、社内コスト情報などをソースコードやREADMEに記載しない
- `.env` ファイルは `.gitignore` に含め、リポジトリに上げない
- `docs/internal/` は社内機密ドキュメント置き場。ディレクトリごと `.gitignore` で除外済み
- コミット前に `git diff --cached` で機密情報の混入がないか確認すること

## 開発運用ルール

- mainへの直接push禁止。必ずPR経由でマージする（リポジトリAdminはバイパス可）
- ブランチ名: `feature/*`, `fix/*`, `hotfix/*`
- コミットメッセージ: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- 詳細は `docs/DEVELOPMENT.md` を参照

## 技術スタック

- Ruby on Rails 8.x / Hotwire（Turbo + Stimulus）
- PostgreSQL / Redis + Sidekiq
- SendGrid（メール送信）
- Prawn or WickedPDF（PDF生成）
- 認証: Rails 8 標準認証
- インフラ: Render.com

## コーディング規約

### 全般
- マジックナンバー・マジックストリングは禁止。定数（`CONSTANT`）として定義する
- メソッドは単一責任。1メソッド15行以内を目安にする
- ネストは最大3段階。早期return（guard clause）を活用する
- 命名は意図を明確に。略語は避ける（`calc` → `calculate`, `btn` → `button`）
- コメントは「なぜ（Why）」のみ記述。「何を（What）」はコードで表現する

### Ruby / Rails
- Rubyスタイルは `rubocop-rails-omakase` に準拠
- 文字列はダブルクォート（`"`）を使用
- ハッシュはシンボルキー + Ruby 3.1のショートハンド記法を適宜使用
- バリデーション値、ステータス値、区分値はモデル内に定数として定義する
  - 例: `ROLES = %w[staff admin].freeze`, `STATUSES = %w[pending generated sent failed].freeze`
- ビジネスロジックはモデルに書かず、Service Object（`app/services/`）に分離する
- N+1クエリを避ける。`includes` / `preload` を適切に使用する
- Strong Parametersを必ず使用する

### テスト
- TDDフロー: Red → Green → Refactor
- テストフレームワーク: RSpec + FactoryBot + Shoulda Matchers
- E2E: Capybara + Playwright
- セキュリティ: Brakeman + bundler-audit
- テスト内のマジックナンバーも定数化またはletで意図を明確にする
- テスト実行コマンド:
  ```bash
  bundle exec rspec                      # 全テスト
  bundle exec brakeman --no-pager -q     # セキュリティスキャン
  bundle exec bundler-audit check        # 依存脆弱性チェック
  ```
