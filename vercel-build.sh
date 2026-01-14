#!/bin/bash
# Assistant V3: Vercel Build Script
# This script bypasses the 256-char limit of Vercel's dashboard.

set -e # Exit on error

echo "--- 🔧 Configuring Git Safety ---"
git config --global --add safe.directory '*'

echo "--- 📦 Downloading Flutter SDK (3.24.5) ---"
curl -fL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz | tar xJ

echo "--- 🏗️ Building Flutter Web ---"
./flutter/bin/flutter build web --release --base-href "/"

echo "--- ✅ Build Complete ---"
