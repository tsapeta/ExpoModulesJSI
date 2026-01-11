#pragma once

#ifdef __cplusplus

#include <memory>
#include <swift/bridging>

#include "jsi.h"
#include "RetainedSwiftPointer.h"

namespace expo {

class HostObjectCallbacks final : public RetainedSwiftPointer {
public:
  using StringVector = std::vector<const char *>;
  using Getter = facebook::jsi::Value(Context, const char *_Nonnull name);
  using Setter = void(Context, const char *_Nonnull name, void *_Nonnull value);
  using PropertyNamesGetter = void *_Nonnull(Context);

  explicit HostObjectCallbacks(Context context, Getter getter, Setter setter, PropertyNamesGetter propertyNamesGetter, Deallocator deallocator)
  : RetainedSwiftPointer(context, deallocator), _getter(std::move(getter)), _setter(std::move(setter)), _propertyNamesGetter(std::move(propertyNamesGetter)) {}

  inline facebook::jsi::Value get(const char *_Nonnull name) {
    return _getter(_context, name);
  }

  inline void set(const char *_Nonnull name, const facebook::jsi::Value &value) {
    _setter(_context, name, (void *)(&value));
  }

  inline StringVector getPropertyNames() {
    return StringVector {};
//    return static_cast<StringVector>(_propertyNamesGetter(_context));
  }

  inline void dealloc() {
    _deallocator(_context);
    delete this;
  }

  Getter *_Nonnull _getter;
  Setter *_Nonnull _setter;
  PropertyNamesGetter *_Nonnull _propertyNamesGetter;
} SWIFT_IMMORTAL_REFERENCE; // class HostObjectCallbacks

} // namespace expo

#endif // __cplusplus
