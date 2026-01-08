#pragma once

#ifdef __cplusplus

#import <functional>
#import <memory>

namespace expo {

template <typename ReturnType, typename... Args>
class CxxClosure final {
public:
  using CallFn = ReturnType(^)(Args...);
  using DeleterFn = void(void *_Nonnull);

  explicit CxxClosure(CallFn _Nonnull call) {//}, DeleterFn *_Nonnull deleter) {
    std::shared_ptr<CallFn> sharedCall = std::make_shared<CallFn>(call);

    _function = [sharedCall = std::move(sharedCall)](Args... args) {
      return (*sharedCall)(args...);
    };
  }

  inline ReturnType operator()(Args... args) {
    return _function(args...);
  }

private:
  std::function<ReturnType(Args...)> _function;
};

} // namespace expo

#endif
