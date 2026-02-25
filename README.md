# inquiry-poc

施設向け問い合わせ・見積自動化システムのPoCプロジェクト。

Webフォームからの問い合わせ受付 → 見積金額の自動計算 → 見積書PDF生成 → メール自動送付までを一気通貫で処理する。

## 技術スタック

| レイヤー | 技術 |
|---------|------|
| フレームワーク | Ruby on Rails 8.x |
| フロントエンド | Hotwire（Turbo + Stimulus） |
| データベース | PostgreSQL |
| メール送信 | SendGrid（API連携） |
| PDF生成 | Prawn or WickedPDF |
| 認証 | Rails 8 標準認証（Authentication Generator） |
| 非同期処理 | Sidekiq + Redis |
| インフラ | Render.com |

## システム構成

```
┌──────────────────────────┐
│    ブラウザ（顧客 / 管理者）    │
└──────────────────────────┘
            ↓ HTTPS
┌──────────────────────────┐
│   Rails 8 アプリケーション     │
│  Hotwire / 認証 / PDF生成    │
│  ActionMailer / Sidekiq     │
└──────────────────────────┘
     ↓          ↓          ↓
 PostgreSQL  Redis/Sidekiq  外部API
 （マスタ等） （メール非同期） （Phase 2〜）
     ↓
  SendGrid（メール送信）
```

## 主要機能

### Phase 1 — 問い合わせ・見積自動化
- 問い合わせフォーム（施設/日程/人数/オプション選択）
- 日程区分（平日/休日/休前日）の自動判定
- 料金マスタに基づく見積金額の自動計算
- 見積書PDF自動生成・メール送付
- マスタ管理画面（料金/日程/施設/メールテンプレート）

### Phase 2 — 予約管理・外部API連携
- 問い合わせ〜予約確定のステータス管理
- 外部PMS API連携
- 顧客向けマイページ

### Phase 3 — 請求・売上・運営管理
- 請求書発行
- 売上ダッシュボード
- 清掃ステータス管理

## DB設計（主要テーブル）

```
facilities        # 施設マスタ
calendar_types    # 日程マスタ（日付 → 平日/休日/休前日）
price_masters     # 料金マスタ（施設 × 日程区分 × 項目 → 単価）
inquiries         # 問い合わせ（フォーム入力内容・見積金額）
quotes            # 見積書（PDF・送付ステータス）
```

## セットアップ

```bash
# 依存パッケージのインストール
bundle install

# DB作成・マイグレーション
bin/rails db:setup

# サーバー起動
bin/dev
```

## 環境変数

| 変数名 | 用途 |
|--------|------|
| `DATABASE_URL` | PostgreSQL接続先 |
| `REDIS_URL` | Redis接続先 |
| `SENDGRID_API_KEY` | SendGrid APIキー |
