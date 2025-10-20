#!/bin/bash
# Cross-platform relative path resolver with configurable prefix.
# Usage:
#   resolve_path <path> [<prefix>]
# Examples:
#   resolve_path ./data          → /app/data
#   resolve_path ./data /mnt     → /mnt/data
#   resolve_path /abs/path       → /abs/path
#   resolve_path s3://bucket/foo → s3://bucket/foo

resolve_path() {
  local path="$1"
  local prefix="${2:-/app}"   # default prefix is /app

  # Empty input → return nothing
  if [[ -z "$path" ]]; then
    echo ""
    return
  fi

  # Already absolute or remote → return as-is
  if [[ "$path" == /* || "$path" == s3://* ]]; then
    echo "$path"
    return
  fi

  # Clean up leading "./" if present
  path="${path#./}"

  # Join prefix + path (handle trailing/leading slashes cleanly)
  echo "${prefix%/}/${path}"
}