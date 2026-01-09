// Copyright 2025-present 650 Industries. All rights reserved.

#import "jsi.h"
#import "Object.hpp"

namespace jsi = facebook::jsi;

namespace expo::jswift {

void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, bool value) {
  object.setProperty(runtime, name, value);
}

void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, double value) {
  object.setProperty(runtime, name, value);
}

void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, const jsi::Value value) {
  object.setProperty(runtime, name, value);
}

void setValueAtIndex(jsi::Runtime &runtime, const jsi::Array &array, size_t index, const jsi::Value value) {
  array.setValueAtIndex(runtime, index, value);
}

jsi::Value arrayToValue(jsi::Runtime &runtime, const jsi::Array &array) {
  return jsi::Value(runtime, array);
}

} // namespace expo::jswift
