# システム設計概要

## 技術スタック

| レイヤー | 技術 | 選定理由 |
|---------|------|---------|
| フレームワーク | Ruby on Rails 8.x | 安定性・開発速度・日本語情報が豊富 |
| フロントエンド | Hotwire（Turbo + Stimulus） | Rails標準・SPA不要でシンプル設計 |
| データベース | PostgreSQL | Render対応・信頼性が高い |
| メール送信 | SendGrid（API連携） | 任意ドメイン対応・信頼性が高い |
| PDF生成 | Prawn or WickedPDF | 見積書・請求書のPDF出力 |
| 認証 | Rails 8 標準認証（Authentication Generator） | 外部gem不要 |
| 非同期処理 | Sidekiq + Redis | メール送信の非同期化 |
| インフラ | Render.com | 低コスト・管理不要 |

## システム構成図

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

## DB設計（主要テーブル）

```
facilities        # 施設マスタ
calendar_types    # 日程マスタ（日付 → 平日/休日/休前日）
price_masters     # 料金マスタ（施設 × 日程区分 × 項目 → 単価）
inquiries         # 問い合わせ（フォーム入力内容・見積金額）
quotes            # 見積書（PDF・送付ステータス）
```

## 共通・管理者機能

- **ログイン認証（Rails 8標準認証）:** スタッフ・管理者の役割別アクセス制御
- **操作ログ:** 誰がいつ何を変更したかのトレーサビリティ
