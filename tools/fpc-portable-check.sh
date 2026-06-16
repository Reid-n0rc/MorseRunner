#!/usr/bin/env bash
#
# Cross-platform port progress check.
#
# Compiles (with FPC) the units that have been ported to build cleanly under
# Free Pascal on non-Windows targets. This is an interim verification harness
# used while the full Lazarus project (MorseRunner.lpi) is being assembled:
# the Windows/Delphi build is unaffected (all port changes are {$IFDEF}-guarded).
#
# Add a unit to PORTED_UNITS once it compiles cleanly under FPC.
#
set -euo pipefail

cd "$(dirname "$0")/.."

PORTED_UNITS=(
  VCL/SndTypes.pas
  VCL/MorseTbl.pas
  VCL/MorseKey.pas
  VCL/FarnsKeyer.pas
  VCL/Mixers.pas
  ExchFields.pas
  Util/ArrlSections.pas
  VCL/Crc32.pas
)

OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

fail=0
for u in "${PORTED_UNITS[@]}"; do
  echo "== compiling $u =="
  if ! fpc -Fu. -FuVCL -FuUtil -FU"$OUT" "$u"; then
    echo "FAILED: $u"
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "One or more ported units failed to compile under FPC." >&2
  exit 1
fi
echo "All ${#PORTED_UNITS[@]} ported units compiled cleanly under FPC."
