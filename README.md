# figma-restapi-skill

Figma REST API を使ってデザイン実装を進めるための汎用スキルです。

- Codex 向け: Skill としてインストール
- Claude Code 向け: Skill としてインストール
- グローバルインストール / プロジェクト単位インストールの両方に対応

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
