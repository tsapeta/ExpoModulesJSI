internal import jsi
internal import ExpoModulesJSI_Cxx

public struct JavaScriptPromise: JavaScriptType, ~Copyable {
  private weak var runtime: JavaScriptRuntime?
  private let task: Task<JavaScriptValue.Ref, any Error>
  private let object: JavaScriptObject

  nonisolated(unsafe) private let impl = PromiseImpl()

  public var state: State {
    return impl.state
  }

  public init(_ runtime: JavaScriptRuntime) {
    self.runtime = runtime

    self.task = Task.detached { [impl] in
      return try await withCheckedThrowingContinuation { continuation in
        impl.continuation = continuation
      }
    }

    let setup = runtime.createSyncFunction("setup") { [impl] this, arguments in
      impl.resolve = arguments[0].getFunction()
      impl.reject = arguments[1].getFunction()
      return this
    }
    self.object = try! runtime
      .global()
      .getPropertyAsFunction("Promise")
      .callAsConstructor(setup.ref())
      .getObject()
  }

  public func resolve(_ result: consuming JavaScriptValue) {
    impl.resolve(result)
  }

  public func reject(_ error: any Error) {
    impl.reject(error)
  }

  public func get() async throws -> JavaScriptValue {
    return try await task.value.take()
  }

  public func asValue() -> JavaScriptValue {
    return object.asValue()
  }

  /**
   Enum representing each of the possible Promise's state.
   */
  public enum State: Sendable {
    /**
     Initial state, neither fulfilled nor rejected.
     */
    case pending
    /**
     Operation was completed successfully.
     */
    case fulfilled
    /**
     Operation failed.
     */
    case rejected
  }

  /**
   Encapsulates Promise implementation and stores mutable data that must stay separated from
   `JavaScriptPromise` to make it a sendable and non-copyable struct, as other JavaScript types.
   Note that we can move away from it when `JavaScriptPromise` becomes isolated to the global JS actor.
   */
  internal final class PromiseImpl {
    var state: State = .pending
    var continuation: CheckedContinuation<JavaScriptValue.Ref, any Error>? = nil
    var resolve: JavaScriptFunction?
    var reject: JavaScriptFunction?

    func resolve(_ result: consuming JavaScriptValue) {
      guard state == .pending else {
        fatalError("Cannot settle a promise more than once")
      }
      guard let continuation else {
        fatalError("Continuation was not set yet")
      }
      // Continuations does not support non-copyable types, so the value is passed as a reference.
      let ref = result.ref()
      continuation.resume(returning: ref)
      state = .fulfilled

      // Call the actual `resolve` function in JS.
      let _ = try? resolve?.call(arguments: ref)
    }

    func reject(_ error: any Error) {
      guard state == .pending else {
        fatalError("Cannot settle a promise more than once")
      }
      guard let continuation else {
        fatalError("Continuation was not set yet")
      }
      continuation.resume(throwing: error)
      state = .rejected

      // Call the actual `reject` function in JS. TODO: Reject with JS error
      let _ = try? reject?.call()
    }
  }
}
