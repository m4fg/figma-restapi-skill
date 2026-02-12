#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="figma-rest-api-coding"

TOOL="both"
SCOPE="global"
PROJECT_PATH=""

print_usage() {
  cat <<'USAGE'
Uninstall figma-rest-api-coding skill from Codex and/or Claude Code.

Usage:
  ./scripts/uninstall.sh [options]

Options:
  --tool <codex|claude|both>      Target tool (default: both)
  --scope <global|project>        Uninstall scope (default: global)
  --project-path <path>           Target project root for project scope (default: current directory)
  -h, --help                      Show this help
USAGE
}

log() {
  printf '[uninstall] %s\n' "$*"
}

fail() {
  printf '[uninstall] ERROR: %s\n' "$*" >&2
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

remove_if_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    rm -rf "$path"
    log "removed $path"
  else
    log "not found (skip): $path"
  fi
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

if [[ "$TOOL" == "codex" || "$TOOL" == "both" ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    codex_home="${CODEX_HOME:-${HOME}/.codex}"
    codex_target="${codex_home}/skills/${SKILL_NAME}"
  else
    codex_target="${PROJECT_PATH}/.codex/skills/${SKILL_NAME}"
  fi
  remove_if_exists "$codex_target"
fi

if [[ "$TOOL" == "claude" || "$TOOL" == "both" ]]; then
  if [[ "$SCOPE" == "global" ]]; then
    claude_home="$(resolve_claude_home)"
    claude_target="${claude_home}/skills/${SKILL_NAME}"
  else
    claude_target="${PROJECT_PATH}/.claude/skills/${SKILL_NAME}"
  fi
  remove_if_exists "$claude_target"
fi

log "done"
