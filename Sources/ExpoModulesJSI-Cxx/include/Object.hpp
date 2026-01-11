// Copyright 2025-present 650 Industries. All rights reserved.

#ifdef __cplusplus

#import <swift/bridging>
#import "jsi.h"
#import "JSIUtils.hpp"

namespace jsi = facebook::jsi;

namespace expo::jswift {

// `jsi::Object::setProperty` is a template function that Swift does not support. We need to provide specialized versions.
void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, bool value);
void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, double value);
void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, const jsi::Value value);
void setValueAtIndex(jsi::Runtime &runtime, const jsi::Array &array, size_t index, const jsi::Value value);
jsi::Value arrayToValue(jsi::Runtime &runtime, const jsi::Array &array);

} // namespace expo::jswift

#endif // __cplusplus
