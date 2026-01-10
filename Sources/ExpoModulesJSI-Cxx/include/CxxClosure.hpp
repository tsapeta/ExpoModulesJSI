#pragma once

#ifdef __cplusplus

#import <functional>
#import <memory>

namespace expo {

template <typename Return, typename ...Args>
class CxxClosure final {
public:
  using Closure = Return(^_Nonnull)(void *_Nonnull, Args...);
  using Releaser = void(void *_Nonnull);

  explicit CxxClosure(void *_Nonnull context, Closure *_Nonnull closure, Releaser *_Nonnull releaser) {
    std::shared_ptr<void> sharedContext(context, releaser);

    // Create a std::function that captures the context pointer and the closure.
    // Once it gets destroyed, `releaser()` gets called.
    _function = [sharedContext = std::move(sharedContext), closure](Args... args) {
      return closure(sharedContext.get(), args...);
    };
  }

  inline Return operator()(Args... args) {
    return _function(args...);
  }

private:
  std::function<Return(Args...)> _function;

};

} // namespace expo

#endif
