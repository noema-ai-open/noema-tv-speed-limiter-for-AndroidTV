#!/usr/bin/env bash
set -euo pipefail

AAB="${1:-app/build/outputs/bundle/release/app-release.aab}"
READELF="${2:-llvm-readelf}"

if [[ ! -f "$AAB" ]]; then
  echo "AAB not found: $AAB" >&2
  exit 1
fi

if [[ ! -x "$READELF" ]] && ! command -v "$READELF" >/dev/null 2>&1; then
  echo "llvm-readelf not found: $READELF" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

unzip -q "$AAB" -d "$TMP"

required_abis=(armeabi-v7a arm64-v8a x86 x86_64)
for abi in "${required_abis[@]}"; do
  if ! compgen -G "$TMP/base/lib/$abi/*.so" >/dev/null; then
    echo "Missing native libraries for required ABI: $abi" >&2
    exit 1
  fi
  echo "ABI present: $abi"
done

for abi in arm64-v8a x86_64; do
  for so in "$TMP"/base/lib/"$abi"/*.so; do
    echo "Checking native library: $so"

    header_file="$TMP/readelf-header.txt"
    header_err="$TMP/readelf-header.err"
    if ! "$READELF" -h "$so" >"$header_file" 2>"$header_err"; then
      echo "llvm-readelf could not read ELF header for: $so" >&2
      cat "$header_err" >&2 || true
      exit 1
    fi

    elf_class="$(awk -F: '/Class:/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$header_file")"
    echo "  ELF class: $elf_class"
    if [[ "$elf_class" != "ELF64" ]]; then
      echo "Expected ELF64 for $so, got: $elf_class" >&2
      exit 1
    fi

    phdr_file="$TMP/readelf-phdr.txt"
    phdr_err="$TMP/readelf-phdr.err"
    if ! "$READELF" -lW "$so" >"$phdr_file" 2>"$phdr_err"; then
      echo "llvm-readelf could not read program headers for: $so" >&2
      cat "$phdr_err" >&2 || true
      exit 1
    fi

    mapfile -t load_alignments < <(awk '$1 == "LOAD" {print $NF}' "$phdr_file")
    if (( ${#load_alignments[@]} == 0 )); then
      echo "No LOAD segments found in $so" >&2
      exit 1
    fi

    for align in "${load_alignments[@]}"; do
      echo "  LOAD alignment: $align"
      if [[ ! "$align" =~ ^0x[0-9A-Fa-f]+$ && ! "$align" =~ ^[0-9]+$ ]]; then
        echo "Unexpected LOAD alignment value '$align' in $so" >&2
        exit 1
      fi
      align_value=$((align))
      if (( align_value < 16384 )); then
        echo "16 KB page-size check failed: $so has LOAD alignment $align (< 0x4000)" >&2
        exit 1
      fi
    done

    echo "16 KB ELF alignment OK: $so"
  done
done

echo "AAB native compatibility checks passed."
