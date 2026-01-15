#!/bin/bash

set -e

PACKAGE_NAME="ExpoModulesJSI"
XCFRAMEWORK_PATH="Products/$PACKAGE_NAME.xcframework"
DERIVED_DATA_PATH=".DerivedData"
PRODUCTS_PATH="$DERIVED_DATA_PATH/Build/Products"

# Clean products folder
rm -rf $PRODUCTS_PATH

#xcodebuild \
#  build \
#  -scheme "$PACKAGE_NAME" \
#  -destination "generic/platform=iOS" \
#  -derivedDataPath "$DERIVED_DATA_PATH" \
#  -configuration Release \
#  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
#  SKIP_INSTALL=NO \
#  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym

xcodebuild \
  build \
  -scheme "$PACKAGE_NAME" \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -configuration Debug \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym

# Remove existing .xcframework
rm -rf $XCFRAMEWORK_PATH

# Create .xcframework
xcodebuild \
  -create-xcframework \
  -framework "./$PRODUCTS_PATH/Debug-iphonesimulator/PackageFrameworks/$PACKAGE_NAME.framework" \
  -output "$XCFRAMEWORK_PATH"

#  -framework "./$PRODUCTS_PATH/Release-iphoneos/PackageFrameworks/$PACKAGE_NAME.framework"
#  -debug-symbols "./$PRODUCTS_PATH/Release-iphonesimulator/ExpoModulesJSI.framework.dSYM" \
#  -debug-symbols "./$PRODUCTS_PATH/Release-iphoneos/ExpoModulesJSI.framework.dSYM" \

for product_path in $PRODUCTS_PATH/*/; do
  swiftmodule_src_path="${product_path}${PACKAGE_NAME}.swiftmodule"

  for slice_path in $XCFRAMEWORK_PATH/*/; do
    framework_path="${slice_path}${PACKAGE_NAME}.framework"
    framework_modules_path="${framework_path}/Modules"
    swiftmodule_dest_path="${framework_modules_path}/${PACKAGE_NAME}.swiftmodule"

    # Make `Modules` directory and copy `.swiftmodule`
    mkdir -p $framework_modules_path
    cp -r $swiftmodule_src_path/ $swiftmodule_dest_path

    # Make `Headers` directory and put Swift header and modulemap there
    framework_headers_path="${framework_path}/Headers"
    generated_module_maps_path="${DERIVED_DATA_PATH}/Build/Intermediates.noindex/GeneratedModuleMaps-iphonesimulator"
    swift_header_path="${generated_module_maps_path}/${PACKAGE_NAME}-Swift.h"
    module_map_path="${generated_module_maps_path}/${PACKAGE_NAME}.modulemap"

    mkdir -p $framework_headers_path
    cp $swift_header_path "$framework_headers_path/"
    cp $module_map_path "$framework_headers_path/module.modulemap"

    # We don't need this dir
    rm -rf "${swiftmodule_dest_path}/Project"
  done
done

# Copy to my expo repo and touch the file, otherwise Xcode may use cached version
dest_xcframework_path="../expo/packages/expo-modules-core/$PACKAGE_NAME.xcframework"
cp -r $XCFRAMEWORK_PATH $(dirname $dest_xcframework_path)
echo "xcframework successfully copied to: $dest_xcframework_path"
#touch ../expo/$XCFRAMEWORK_PATH
