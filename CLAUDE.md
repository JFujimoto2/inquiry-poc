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
