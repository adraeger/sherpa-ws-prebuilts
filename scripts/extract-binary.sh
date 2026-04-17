#!/usr/bin/env bash
# extract-binary.sh — extrahiert WS-Server-Binary + Libs aus sherpa-onnx-Tarball
#
# Usage: extract-binary.sh <upstream-tarball> <binary-name> <lib-glob> <out-dir>
#
# Beispiel (macOS):
#   extract-binary.sh upstream.tar.bz2 sherpa-onnx-offline-websocket-server "*.dylib" stage/
#
# Das Script legt Binary + alle passenden Libs FLACH im out-dir ab (keine
# Unterverzeichnisse), sodass das Ziel-`.tar.gz` einen einfachen Extract
# ermöglicht.

set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <tarball> <binary> <lib-glob> <out-dir>" >&2
  exit 2
fi

TARBALL="$1"
BINARY="$2"
LIB_GLOB="$3"
OUT_DIR="$4"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Extract $TARBALL to $TMP_DIR"
tar -xjf "$TARBALL" -C "$TMP_DIR"

mkdir -p "$OUT_DIR"

# Binary suchen (rekursiv, erster Treffer)
BIN_PATH="$(find "$TMP_DIR" -type f -name "$BINARY" | head -n 1)"
if [ -z "$BIN_PATH" ]; then
  echo "FEHLER: Binary '$BINARY' nicht im Tarball gefunden" >&2
  find "$TMP_DIR" -maxdepth 3 -type f | head -30 >&2
  exit 1
fi
cp "$BIN_PATH" "$OUT_DIR/$BINARY"
echo "Binary kopiert: $OUT_DIR/$BINARY"

# Libs suchen (rekursiv, flach kopieren)
LIB_COUNT=0
while IFS= read -r -d '' lib; do
  LIB_NAME="$(basename "$lib")"
  # Symlinks auflösen + Ziel mit kopieren, damit alle nötigen Versionen da sind
  if [ -L "$lib" ]; then
    cp -a "$lib" "$OUT_DIR/$LIB_NAME"
  else
    cp "$lib" "$OUT_DIR/$LIB_NAME"
  fi
  LIB_COUNT=$((LIB_COUNT + 1))
done < <(find "$TMP_DIR" -type f -name "$LIB_GLOB" -print0)

# Symlinks ebenfalls kopieren (find -type f ignoriert sie)
while IFS= read -r -d '' lib; do
  LIB_NAME="$(basename "$lib")"
  if [ ! -e "$OUT_DIR/$LIB_NAME" ]; then
    cp -a "$lib" "$OUT_DIR/$LIB_NAME"
    LIB_COUNT=$((LIB_COUNT + 1))
  fi
done < <(find "$TMP_DIR" -type l -name "$LIB_GLOB" -print0)

echo "Libs kopiert: $LIB_COUNT"
ls -la "$OUT_DIR"
