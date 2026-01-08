// Copyright 2025-present 650 Industries. All rights reserved.

#ifdef __cplusplus

#import <string>
#import <vector>
#import "jsi.h"
#import "CxxClosure.hpp"

namespace jsi = facebook::jsi;

namespace expo {

class JSI_EXPORT HostObject : public jsi::HostObject {
public:
  using GetFunction = CxxClosure<jsi::Value, std::string>;
  using SetFunction = CxxClosure<void, std::string, const jsi::Value &>;
  using GetPropertyNamesFunction = CxxClosure<std::vector<std::string>>;
  using DeallocFunction = CxxClosure<void>;

  HostObject(GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc);

  virtual ~HostObject();

  jsi::Value get(jsi::Runtime &runtime, const jsi::PropNameID &name) override;

  void set(jsi::Runtime &runtime, const jsi::PropNameID &name, const jsi::Value &value) override;

  std::vector<jsi::PropNameID> getPropertyNames(jsi::Runtime &runtime) override;

  static jsi::Object makeObject(jsi::Runtime &runtime, GetFunction get, SetFunction set, GetPropertyNamesFunction getPropertyNames, DeallocFunction dealloc);

private:
  GetFunction _get;
  SetFunction _set;
  GetPropertyNamesFunction _getPropertyNames;
  DeallocFunction _dealloc;
}; // class HostObject

} // namespace expo

#endif // __cplusplus
