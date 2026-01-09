
XCARCHIVE_DEVICE_PATH="Products/ExpoModulesJSI-iOS.xcarchive"
XCARCHIVE_SIMULATOR_PATH="Products/ExpoModulesJSI-iOS-Simulator.xcarchive"
XCFRAMEWORK_PATH="Products/ExpoModulesJSI.xcframework"
FRAMEWORKS_PATH="/Library/Frameworks"

# Build archive for iOS devices
xcodebuild \
  archive \
  -scheme "ExpoModulesJSI" \
  -destination "generic/platform=iOS" \
  -archivePath "$XCARCHIVE_DEVICE_PATH" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  INSTALL_PATH="$FRAMEWORKS_PATH"

# Build archive for simulator
xcodebuild \
  archive \
  -scheme "ExpoModulesJSI" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$XCARCHIVE_SIMULATOR_PATH" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  INSTALL_PATH="$FRAMEWORKS_PATH"

# Remove existing .xcframework
rm -rf $XCFRAMEWORK_PATH

# Create .xcframework
xcodebuild \
  -create-xcframework \
  -archive "$XCARCHIVE_DEVICE_PATH" \
  -framework "ExpoModulesJSI.framework" \
  -archive "$XCARCHIVE_SIMULATOR_PATH" \
  -framework "ExpoModulesJSI.framework" \
  -output "$XCFRAMEWORK_PATH"
