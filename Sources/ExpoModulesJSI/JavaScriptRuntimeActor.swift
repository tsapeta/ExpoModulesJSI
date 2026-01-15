import Foundation

/**
 An actor that is dedicated for the specific runtime.
 */
internal actor JavaScriptRuntimeActor {
  private weak var runtime: JavaScriptRuntime?
  nonisolated private let executor: JavaScriptRuntimeSerialExecutor

  init(runtime: JavaScriptRuntime) {
    self.runtime = runtime
    self.executor = JavaScriptRuntimeSerialExecutor(runtime: runtime)
  }

  nonisolated var unownedExecutor: UnownedSerialExecutor {
    return executor.asUnownedSerialExecutor()
  }

  func execute<R: Sendable>(_ something: @escaping () async throws -> R) async rethrows -> sending R {
    runtime?.assertThread()
    let result = try await something()
    runtime?.assertThread()
    return result
  }
}

internal final class JavaScriptRuntimeSerialExecutor: JavaScriptSerialExecutor, @unchecked Sendable {
  nonisolated(unsafe) private weak var runtime: JavaScriptRuntime?

  init(runtime: JavaScriptRuntime?) {
    self.runtime = runtime
  }

  override func enqueue(_ job: UnownedJob) {
    runtime?.schedule(priority: .immediate) {
      job.runSynchronously(on: self.asUnownedSerialExecutor())
    }
  }

  override func asUnownedSerialExecutor() -> UnownedSerialExecutor {
    return UnownedSerialExecutor(ordinary: self)
  }
}
