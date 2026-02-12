# figma-restapi-skill

[English version](./README.md)

Figma REST API を使ってデザイン実装を進めるための汎用スキルです。

- Codex 向け: Skill としてインストール
- Claude Code 向け: Skill としてインストール
- グローバルインストール / プロジェクト単位インストールの両方に対応

## Figma公式MCPよりREST APIを利用するメリット

Figma公式MCPは対話的な実装には便利ですが、REST APIを直接使うと次のメリットがあります。

補足:

- Figma公式MCPは Dev Mode の機能として提供されており、利用には Dev Mode 側のアクセス条件（プラン/シート条件）を満たす必要があります。

- 自動化しやすい
  - `curl` やスクリプトで定期実行・バッチ実行でき、CI/CD に組み込みやすい
- ツール非依存で再利用しやすい
  - Codex/Claude Code 以外でも同じ API 呼び出しロジックを流用できる
- 大量処理に向いている
  - 複数ファイル・複数ノードをまとめて取得し、コード生成パイプラインに接続しやすい
- 制御性が高い
  - リトライ、レート制限対応、キャッシュ、ログ出力などを実装側で明示的に制御できる
- 監査とセキュリティ運用がしやすい
  - トークンスコープや有効期限を運用ポリシーに合わせて管理しやすい
- ヘッドレス環境で動かせる
  - GUI操作なしでサーバー環境から実行できる

実務では、対話的な試作はMCP、再現性が必要な本番ワークフローはREST API、のように使い分けるのが有効です。

## 含まれる内容

- `skills/figma-rest-api-coding/SKILL.md`
  - Figma REST API を使ったコーディング手順
- `skills/figma-rest-api-coding/references/*`
  - コーディング用途の主要エンドポイント、実装フロー、スニペット
- `skills/figma-rest-api-coding/scripts/figma-api.sh`
  - Figma API 呼び出し補助スクリプト

## インストール

### 1. リポジトリをクローン

```bash
git clone <this-repo-url>
cd figma-restapi-skill
```

### 2. インストール実行

```bash
./scripts/install.sh [options]
```

主なオプション:

- `--tool <codex|claude|both>` (default: `both`)
- `--scope <global|project>` (default: `global`)
- `--project-path <path>` (`--scope project` のときに利用)
- `--force` 既存インストールを上書き

例:

```bash
# Codex/Claude 両方にグローバルインストール
./scripts/install.sh --tool both --scope global

# 現在ディレクトリのプロジェクトへ Claude だけインストール
./scripts/install.sh --tool claude --scope project

# 指定プロジェクトへ Codex だけインストール
./scripts/install.sh --tool codex --scope project --project-path /path/to/project
```

## インストール先

- Codex global: `${CODEX_HOME:-~/.codex}/skills/figma-rest-api-coding`
- Codex project: `<project>/.codex/skills/figma-rest-api-coding`
- Claude global: `${CLAUDE_CONFIG_DIR:-~/.claude}/skills/figma-rest-api-coding`
- Claude project: `<project>/.claude/skills/figma-rest-api-coding`

## アンインストール

```bash
./scripts/uninstall.sh [options]
```

オプションは `install.sh` と同じです (`--force` は不要)。

例:

```bash
./scripts/uninstall.sh --tool both --scope global
./scripts/uninstall.sh --tool codex --scope project --project-path /path/to/project
```

## Figma API トークン

スキル利用時は `FIGMA_TOKEN` を設定してください。

### `FIGMA_TOKEN` の取得方法 (Personal Access Token)

1. Figma にログイン
2. ファイルブラウザ左上のアカウントメニューから `Settings` を開く
3. `Security` タブを開く
4. `Personal access tokens` セクションで `Generate new token` をクリック
5. 有効期限とスコープを設定してトークンを生成
6. 生成直後に表示されたトークンをコピーして安全に保管

注意:

- 生成時にしかトークン文字列をコピーできません
- 2025-04-28 の仕様更新以降、PAT は無期限にできず最大 90 日です
- `files:read` は非推奨なので、必要最小限の granular scope を選んでください

このスキル用途での代表的なスコープ例:

- `file_content:read` (ノード/ファイル内容の読み取り)
- `file_metadata:read` (ファイルメタデータの読み取り)
- `file_versions:read` (バージョン履歴の読み取り)
- `library_content:read` (公開コンポーネント/スタイルの読み取り)
- `file_dev_resources:read` (Dev Resources の読み取り)
- `file_variables:read` (Variables の読み取り: Enterprise プランのみ)

```bash
export FIGMA_TOKEN="your_token"
```

永続化する場合の例 (`~/.zshrc`):

```bash
export FIGMA_TOKEN="your_token"
```

## 補助スクリプト例

```bash
# URL から file_key/node_id を抽出
./skills/figma-rest-api-coding/scripts/figma-api.sh parse-url "https://www.figma.com/design/FILE_KEY/Example?node-id=1-2"

# 特定ノード JSON を取得
FIGMA_TOKEN=xxx ./skills/figma-rest-api-coding/scripts/figma-api.sh nodes FILE_KEY "1:2,3:4" "depth=2"
```
