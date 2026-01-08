
xcodebuild \
  build \
  -scheme 'ExpoModulesJSI' \
  -destination "generic/platform=iOS" \
  -derivedDataPath "./DerivedData" \
  -configuration Release \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym
