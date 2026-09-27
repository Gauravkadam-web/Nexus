#!/bin/bash
# ==============================================================================
# Nexus Frontend — Vercel Automated Build Script
# Downloads Flutter stable channel and compiles Flutter Web with environment API_BASE_URL
# ==============================================================================

set -e

echo "=== [1/4] Installing Flutter SDK on Vercel ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

echo "=== [2/4] Flutter Version Check ==="
flutter --version

echo "=== [3/4] Resolving Dependencies ==="
flutter config --enable-web
flutter pub get

API_URL="${API_BASE_URL:-https://nexus-backend.onrender.com/api/v1/}"
echo "=== [4/4] Compiling Flutter Web (Release) with API_BASE_URL: $API_URL ==="
flutter build web --release --dart-define=API_BASE_URL="$API_URL"

# Ensure vercel.json is in build/web output
cp vercel.json build/web/ 2>/dev/null || true

echo "=== Build Complete! Ready for Vercel Serving ==="
