#!/bin/sh
# Turns the JSON in l10n/ into the typed classes in lib/core/l10n/generated/
# and packs every language into assets/l10n/l10n.tar.bz2.
#
# The iOS and Android builds run this before Flutter compiles, so a build
# always ships the JSON as it is. Run it by hand after editing the JSON to
# get the new classes in the editor straight away:
#
#   sh tool/l10n.sh
#
# Files are only rewritten when their content changes, so an unchanged
# build does not recompile. A problem in the JSON stops the build and
# lists every one.
set -e
cd "$(dirname "$0")/.."
if [ -n "$FLUTTER_ROOT" ] && [ -x "$FLUTTER_ROOT/bin/dart" ]; then
  DART="$FLUTTER_ROOT/bin/dart"
else
  DART=dart
fi
exec "$DART" run keel_localisation:generate "$@"
