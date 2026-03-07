#!/bin/sh

# Xcode Cloud post-clone script
# Installs Flutter SDK, dependencies, and CocoaPods before the build

set -e

# Install Flutter SDK via git clone (not pre-installed on Xcode Cloud runners)
FLUTTER_HOME="$HOME/flutter"
if [ ! -d "$FLUTTER_HOME" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"

# Navigate to the Flutter project root
cd "$CI_PRIMARY_REPOSITORY_PATH/my_app"

# Install Flutter dependencies and generate required files (Generated.xcconfig, etc.)
flutter pub get

# Install CocoaPods dependencies (generates xcfilelists, frameworks script, etc.)
cd ios
pod install
