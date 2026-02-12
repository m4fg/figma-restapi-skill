#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILL_NAME="figma-rest-api-coding"
SKILL_SOURCE="${REPO_ROOT}/skills/${SKILL_NAME}"

TOOL="both"
SCOPE="global"
PROJECT_PATH=""
FORCE=0

print_usage() {
  cat <<'USAGE'
Install figma-rest-api-coding skill for Codex and/or Claude Code.

Usage:
  ./scripts/install.sh [options]

Options:
  --tool <codex|claude|both>      Target tool (default: both)
  --scope <global|project>        Install scope (default: global)
  --project-path <path>           Target project root for project scope (default: current directory)
  --force                         Overwrite if destination already exists
  -h, --help                      Show this help

Install paths:
  Codex global:   ${CODEX_HOME:-~/.codex}/skills/<skill-name>
  Codex project:  <project>/.codex/skills/<skill-name>
  Claude global:  ${CLAUDE_CONFIG_DIR:-~/.claude}/skills/<skill-name>
  Claude project: <project>/.claude/skills/<skill-name>
USAGE
}

log() {
  printf '[install] %s\n' "$*"
}

fail() {
  printf '[install] ERROR: %s\n' "$*" >&2
  exit 1
}

require_value() {
  local flag="$1"
  local value="${2:-}"
  if [[ -z "$value" ]]; then
    fail "${flag} requires a value"
  fi
}

resolve_claude_home() {
  if [[ -n "${CLAUDE_CONFIG_DIR:-}" ]]; then
    printf '%s\n' "${CLAUDE_CONFIG_DIR}"
    return
  fi

  if [[ -d "${HOME}/.claude" ]]; then
    printf '%s\n' "${HOME}/.claude"
    return
  fi

  if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
    printf '%s\n' "${XDG_CONFIG_HOME}/claude"
    return
  fi

  printf '%s\n' "${HOME}/.claude"
}

install_dir() {
  local src="$1"
  local dst="$2"

  if [[ ! -d "$src" ]]; then
    fail "source directory does not exist: $src"
  fi

  if [[ -e "$dst" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -rf "$dst"
    else
      fail "destination already exists: $dst (use --force to overwrite)"
    fi
  fi

  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      require_value "$1" "${2:-}"
      TOOL="$2"
      shift 2
      ;;
    --scope)
      require_value "$1" "${2:-}"
      SCOPE="$2"
      shift 2
      ;;
    --project-path)
      require_value "$1" "${2:-}"
      PROJECT_PATH="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      fail "unknown option: $1"
      ;;
  esac
done

case "$TOOL" in
  codex|claude|both) ;;
  *) fail "--tool must be codex, claude, or both" ;;
esac

case "$SCOPE" in
  global|project) ;;
  *) fail "--scope must be global or project" ;;
esac

if [[ "$SCOPE" == "project" ]]; then
  if [[ -z "$PROJECT_PATH" ]]; then
    PROJECT_PATH="$(pwd)"
  fi
  if [[ ! -d "$PROJECT_PATH" ]]; then
    fail "project path does not exist: $PROJECT_PATH"
  fi
  PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
fi

installed_paths=()

if [[ "$TOOL" == "codex" || "$TOOL" == "both" ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    codex_home="${CODEX_HOME:-${HOME}/.codex}"
    codex_dest="${codex_home}/skills/${SKILL_NAME}"
  else
    codex_dest="${PROJECT_PATH}/.codex/skills/${SKILL_NAME}"
  fi
  install_dir "$SKILL_SOURCE" "$codex_dest"
  installed_paths+=("codex:${codex_dest}")
fi

if [[ "$TOOL" == "claude" || "$TOOL" == "both" ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    claude_home="$(resolve_claude_home)"
    claude_dest="${claude_home}/skills/${SKILL_NAME}"
  else
    claude_dest="${PROJECT_PATH}/.claude/skills/${SKILL_NAME}"
  fi
  install_dir "$SKILL_SOURCE" "$claude_dest"
  installed_paths+=("claude:${claude_dest}")
fi

for entry in "${installed_paths[@]}"; do
  log "installed ${entry}"
done

log "done. restart Codex/Claude Code if the skill is not visible immediately."
