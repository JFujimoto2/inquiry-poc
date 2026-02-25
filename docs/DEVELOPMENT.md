# 開発運用ルール

## ブランチ戦略

```
main          ← 本番デプロイ対象。直接pushは禁止
  └── feature/*   ← 機能開発用ブランチ
  └── fix/*       ← バグ修正用ブランチ
  └── hotfix/*    ← 緊急修正用ブランチ
```

### ルール

- `main` への直接pushは禁止。必ずPull Request経由でマージする
- `main` ブランチの削除は禁止（GitHub Rulesetで保護済み）
- ブランチ名は `feature/`, `fix/`, `hotfix/` のプレフィックスを付ける
  - 例: `feature/inquiry-form`, `fix/pdf-layout`, `hotfix/sendgrid-auth`

## コミットルール

### コミットメッセージ

```
<type>: <概要>

<詳細（任意）>
```

| type | 用途 |
|------|------|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `refactor` | リファクタリング |
| `docs` | ドキュメント |
| `test` | テスト |
| `chore` | 設定・雑務 |

### コミット前チェック

- `git diff --cached` で機密情報（APIキー、個人情報、社内情報）が含まれていないか確認
- `.env` ファイルがステージングに含まれていないか確認

## Pull Request ルール

1. PRタイトルはコミットメッセージと同じ形式で記述
2. PRの説明に「何を変更したか」「なぜ変更したか」を記載
3. レビュー後にマージ（現時点ではapproval不要だがレビュー推奨）
4. マージ後、featureブランチは削除する

## 機密情報の取り扱い

- APIキー・パスワード等は `.env` で管理し、リポジトリにはコミットしない
- クライアント名・担当者名・社内コスト情報はソースコードに記載しない
- `docs/システム刷新計画書.md` は `.gitignore` で除外済み
- 新たに機密情報を含むファイルが増えた場合は `.gitignore` に追記すること

## 開発フロー

```
1. mainから新ブランチを作成
   git checkout -b feature/xxx main

2. 開発・コミット
   git add <files>
   git diff --cached  ← 機密情報チェック
   git commit -m "feat: xxx"

3. リモートにpush
   git push -u origin feature/xxx

4. Pull Requestを作成・レビュー

5. mainにマージ → featureブランチ削除
```

## 環境構成

| 環境 | 用途 | デプロイ元 |
|------|------|-----------|
| development | ローカル開発 | - |
| production | 本番 | main ブランチ |
