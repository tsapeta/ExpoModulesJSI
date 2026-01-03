// Copyright 2022-present 650 Industries. All rights reserved.

#pragma once
#ifdef __cplusplus

#include <jsi.h>

namespace jsi = facebook::jsi;

namespace expo::common {

#pragma mark - Helpers

/**
 Gets the core Expo object, i.e. `global.expo`.
 */
inline jsi::Object getCoreObject(jsi::Runtime &runtime) {
  return runtime.global().getPropertyAsObject(runtime, "expo");
}

#pragma mark - Classes

/**
 Type of the native constructor of the JS classes.
 */
typedef std::function<jsi::Value(jsi::Runtime &runtime, const jsi::Value &thisValue, const jsi::Value *args, size_t count)> ClassConstructor;

/**
 Creates a class with the given name and native constructor.
 */
jsi::Function createClass(jsi::Runtime &runtime, const char *name, ClassConstructor constructor = nullptr);

/**
 Creates a class (function) that inherits from the provided base class.
 */
jsi::Function createInheritingClass(jsi::Runtime &runtime, const char *className, jsi::Function &baseClass, ClassConstructor constructor = nullptr);

/**
 Creates an object from the given prototype, without calling the constructor.
 */
jsi::Object createObjectWithPrototype(jsi::Runtime &runtime, jsi::Object *prototype);

#pragma mark - Conversions

/**
 Converts `jsi::Array` to a vector with prop name ids (`std::vector<jsi::PropNameID>`).
 */
std::vector<jsi::PropNameID> jsiArrayToPropNameIdsVector(jsi::Runtime &runtime, const jsi::Array &array);

#pragma mark - Properties

/**
 Represents a JS property descriptor used in the `Object.defineProperty` function.
 */
struct PropertyDescriptor {
  const bool configurable = false;
  const bool enumerable = false;
  const bool writable = false;
  const jsi::Value value = jsi::Value::undefined();
  const std::function<jsi::Value(jsi::Runtime &runtime, jsi::Object thisObject)> get = 0;
  const std::function<void(jsi::Runtime &runtime, jsi::Object thisObject, jsi::Value newValue)> set = 0;
}; // PropertyDescriptor

/**
 Defines the property on the object with the provided descriptor options.
 */
void defineProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, const PropertyDescriptor& descriptor);

/**
 Calls `Object.defineProperty(object, name, descriptor)`.
 */
void defineProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, jsi::Object descriptor);

} // namespace expo::common

namespace expo {

using HostFunctionBlock = jsi::Value (^)(jsi::Runtime &runtime, const jsi::Value &thisValue, const jsi::Value *args, size_t argsCount);

jsi::Function createHostFunction(jsi::Runtime &runtime, const char *name, HostFunctionBlock block);

inline jsi::Value valueFromFunction(jsi::Runtime &runtime, const jsi::Function &function) {
  return jsi::Value(runtime, function);
}

// `jsi::Object::setProperty` is a template function that Swift does not support. We need to provide specialized versions.
inline void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, bool value) {
  object.setProperty(runtime, name, value);
}

inline void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, double value) {
  object.setProperty(runtime, name, value);
}

inline void setProperty(jsi::Runtime &runtime, const jsi::Object &object, const char *name, const jsi::Value value) {
  object.setProperty(runtime, name, value);
}

inline void setValueAtIndex(jsi::Runtime &runtime, const jsi::Array &array, size_t index, const jsi::Value value) {
  array.setValueAtIndex(runtime, index, value);
}

inline jsi::Value valueFromArray(jsi::Runtime &runtime, const jsi::Array &array) {
  return jsi::Value(runtime, array);
}

inline std::shared_ptr<const jsi::Buffer> makeSharedStringBuffer(const std::string &source) noexcept {
  return std::make_shared<jsi::StringBuffer>(source);
}

jsi::Runtime &createHermesRuntime();

} // namespace expo

#endif // __cplusplus
