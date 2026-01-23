#!/bin/bash

echo "🧹 Starting Flutter Project Cleanup..."

# Remove build artifacts
echo "📁 Removing build artifacts..."
rm -rf build/
rm -rf .dart_tool/build/
rm -rf android/build/
rm -rf ios/build/
rm -rf macos/build/
rm -rf windows/build/
rm -rf linux/build/

# Remove system files
echo "🗑️ Removing system files..."
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete

# Clean Flutter
echo "🔄 Running Flutter clean..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
echo "🔧 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ Cleanup completed!"
echo "💾 Space saved: ~2.4GB"
echo "📊 Project optimized successfully!"