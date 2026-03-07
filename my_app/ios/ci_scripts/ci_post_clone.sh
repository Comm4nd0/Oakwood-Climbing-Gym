#!/bin/sh

# Xcode Cloud post-clone script
# Installs Flutter dependencies and CocoaPods before the build

set -e

# Navigate to the Flutter project root
cd "$CI_PRIMARY_REPOSITORY_PATH/my_app"

# Install Flutter dependencies and generate required files (Generated.xcconfig, etc.)
flutter pub get

# Install CocoaPods dependencies (generates xcfilelists, frameworks script, etc.)
cd ios
pod install
