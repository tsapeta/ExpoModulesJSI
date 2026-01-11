// Copyright 2025-present 650 Industries. All rights reserved.

import Foundation

internal import jsi
internal import ExpoModulesJSI_Cxx

open class JavaScriptRuntime: Equatable, @unchecked Sendable {
  internal/*!*/ let pointee: facebook.jsi.Runtime
  internal/*!*/ let scheduler: expo.RuntimeScheduler

  public init(provider: JavaScriptRuntimeProvider) {
    self.pointee = provider.consume()
    self.scheduler = expo.RuntimeScheduler(pointee)
  }

  /**
   Creates a runtime from a JSI runtime.
   */
  internal/*!*/ /*override*/ init(_ runtime: facebook.jsi.Runtime) {
    self.pointee = runtime
    self.scheduler = expo.RuntimeScheduler(runtime)
//    super.init(runtime)
  }

  /**
   Creates Hermes runtime.
   */
  public /*override*/ init() {
    self.pointee = expo.createHermesRuntime()
    self.scheduler = expo.RuntimeScheduler(pointee)
  }

  public init(_ runtime: UnsafeRawPointer) {
    self.pointee = runtime.load(as: facebook.jsi.Runtime.self)
    self.scheduler = expo.RuntimeScheduler(pointee)
  }

  /**
   DO NOT USE IT
   */
  public var unsafe_pointee: UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged<facebook.jsi.Runtime>.passUnretained(pointee).toOpaque())
  }

  /**
   Returns the runtime `global` object.
   */
  public func global() -> JavaScriptObject {
    return JavaScriptObject(self, pointee.global())
  }

  // MARK: - Creating objects

  /**
   Creates a plain JavaScript object.
   */
  public func createObject() -> JavaScriptObject {
    return JavaScriptObject(self, facebook.jsi.Object(pointee))
  }

  /**
   Creates a new JavaScript object, using the provided object as the prototype.
   Calls `Object.create(prototype)` under the hood.
   */
  public func createObject(prototype: consuming JavaScriptObject) -> JavaScriptObject {
    return JavaScriptObject(self, expo.common.createObjectWithPrototype(pointee, &prototype.pointee))
  }

  /**
   Creates a JavaScript host object with given implementations for property getter, property setter, property names getter and dealloc.
   */
  public func createHostObject(
    get: @escaping (_ propertyName: String) -> JavaScriptValue,
    set: @escaping (_ propertyName: String, _ value: consuming JavaScriptValue) -> Void,
    getPropertyNames: @escaping () -> [String],
    dealloc: @escaping () -> Void
  ) -> JavaScriptObject {
    func getter(context: UnsafeMutableRawPointer, propertyName: UnsafePointer<CChar>) -> facebook.jsi.Value {
      let context = Unmanaged<HostObjectContext>.fromOpaque(context).takeUnretainedValue()
      return context.get(String(cString: propertyName)).pointee
    }

    func setter(context: UnsafeMutableRawPointer, propertyName: UnsafePointer<CChar>, valuePointer: UnsafeMutableRawPointer) {
      let context = Unmanaged<HostObjectContext>.fromOpaque(context).takeUnretainedValue()
      let value = JavaScriptValue(context.runtime, valuePointer.assumingMemoryBound(to: facebook.jsi.Value.self).move())
      context.set(String(cString: propertyName), value)
    }

    func propertyNamesGetter(context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
      let context = Unmanaged<HostObjectContext>.fromOpaque(context).takeUnretainedValue()
      let propertyNames = context.getPropertyNames()
      var vector = expo.HostObjectCallbacks.StringVector()

      vector.reserve(propertyNames.count)

      for propertyName in propertyNames {
        vector.push_back(propertyName.cString(using: .utf8))
      }
      return withUnsafeMutablePointer(to: &vector) { ptr in
        return UnsafeMutableRawPointer(ptr)
      }
    }

    func deallocate(context: UnsafeMutableRawPointer) {
      Unmanaged<HostObjectContext>.fromOpaque(context).release()
    }

    let context = Unmanaged.passRetained(HostObjectContext(runtime: self, get, set, getPropertyNames, dealloc)).toOpaque()
    let callbacks = expo.HostObjectCallbacks(context, getter, setter, propertyNamesGetter, deallocate)
    let hostObject = expo.HostObject.makeObject(pointee, callbacks)

    return JavaScriptObject(self, hostObject)
  }

  // MARK: - Creating functions

  /**
   Type of the closure that is passed to the `createSyncFunction` function.
   */
  public typealias SyncFunctionClosure = (_ this: consuming JavaScriptValue, _ arguments: consuming JSValuesBuffer) throws -> JavaScriptValue

  /**
   Creates a synchronous host function that runs the given closure when it's called.
   The value returned by the closure is synchronously returned to JS.
   - Returns: A JavaScript function represented as a `JavaScriptFunction`.
   */
  public func createSyncFunction(_ name: String, _ fn: @escaping SyncFunctionClosure) -> JavaScriptFunction {
    class HostFunctionContext {
      let runtime: JavaScriptRuntime
      let call: SyncFunctionClosure

      init(runtime: JavaScriptRuntime, _ function: @escaping SyncFunctionClosure) {
        self.runtime = runtime
        self.call = function
      }
    }

    let context = Unmanaged.passRetained(HostFunctionContext(runtime: self, fn)).toOpaque()

    func call(context: UnsafeMutableRawPointer, thisPtr: UnsafePointer<facebook.jsi.Value>, argumentsPtr: UnsafePointer<facebook.jsi.Value>, argumentsCount: Int) -> facebook.jsi.Value {
      let context = Unmanaged<HostFunctionContext>.fromOpaque(context).takeUnretainedValue()
      let this = UnsafeMutablePointer(mutating: thisPtr).move()
      let arguments = JSValuesBuffer(context.runtime, start: argumentsPtr, count: argumentsCount)

      do {
        let result = try context.call(JavaScriptValue(context.runtime, this), arguments)
        return result.pointee
      } catch {
        // TODO: Implement throwing `facebook.jsi.JSError`, returns `undefined` until then
        return .undefined()
      }
    }

    func deallocate(context: UnsafeMutableRawPointer) {
      Unmanaged<HostFunctionContext>.fromOpaque(context).release()
    }

    let closure = expo.HostFunctionClosure(context, call, deallocate)
    let hostFunction = expo.createHostFunction(pointee, name.cString(using: .utf8), closure)

    return JavaScriptFunction(self, hostFunction)
  }

  /**
   Closure that modules use to resolve the JavaScript promise waiting for a result.
   */
  public typealias PromiseResolveClosure = @Sendable (_ result: borrowing JavaScriptValue) -> Void

  /**
   Closure that modules use to reject the JavaScript promise waiting for a result.
   The error may be nil but it is preferable to pass an `NSError` object for more precise error messages.
   */
  public typealias PromiseRejectClosure = @Sendable (_ code: String, _ message: String, _ error: (any Error)?) -> Void

  /**
   Type of the closure that is passed to the `createAsyncFunction` function.
   */
  public typealias AsyncFunctionClosure = @Sendable (
    _ this: consuming JavaScriptValue,
    _ arguments: consuming JSValuesBuffer,
    _ resolve: @escaping PromiseResolveClosure,
    _ reject: @escaping PromiseRejectClosure
  ) throws -> JavaScriptValue

  /**
   Creates an asynchronous host function that runs given block when it's called.
   The block receives a resolver that you should call when the asynchronous operation
   succeeds and a rejecter to call whenever it fails.
   \return A JavaScript function represented as a `JavaScriptObject`.
   */
  public func createAsyncFunction(_ name: String, _ fn: AsyncFunctionClosure) -> JavaScriptFunction {
    // TODO: Implement
    return createSyncFunction(name) { this, arguments in
//      let promiseSetup = { (runtime: facebook.jsi.Runtime, promise: Any) in
//        expo.callPromiseSetupWithBlock(runtime, callInvoker, promise) { (resolver, rejecter) in
//          fn(this, arguments, resolver, rejecter)
//        }
//      }
//      return facebook.react.createPromiseAsJSIValue(pointee, promiseSetup)
      return .undefined()
    }
  }

  // MARK: - Runtime execution

  /**
   Schedules a closure to be executed with granted synchronized access to the runtime.
   */
  public func schedule(priority: SchedulerPriority = .normal, @_implicitSelfCapture _ closure: @escaping () -> Void) {
    let reactPriority = facebook.react.SchedulerPriority(rawValue: priority.rawValue) ?? .NormalPriority
    scheduler.scheduleTask(reactPriority, closure)
  }

  /**
   Priority of the scheduled task.
   - Note: Keep it in sync with the equivalent C++ enum from React Native (see `SchedulerPriority.h` from `React-callinvoker`).
   */
  public enum SchedulerPriority: Int32 {
    case immediate = 1
    case userBlocking = 2
    case normal = 3
    case low = 4
    case idle = 5
  }

  // MARK: - Script evaluation

  /**
   Evaluates given JavaScript source code.
   */
  @discardableResult
  public func eval(_ source: String) throws -> JavaScriptValue {
    let stringBuffer = expo.makeSharedStringBuffer(std.string(source))
    return JavaScriptValue(self, pointee.evaluateJavaScript(stringBuffer, std.string("<<evaluated>>")))
  }

  /**
   Evaluates the given JavaScript source code made by joining an array of strings with a newline separator.
   */
  @available(*, deprecated, message: "Spread the array into arguments instead")
  @discardableResult
  public func eval(_ lines: [String]) throws -> JavaScriptValue {
    try eval(lines.joined(separator: "\n"))
  }

  /**
   Evaluates the given JavaScript source code made by joining arguments with a newline separator.
   */
  @discardableResult
  public func eval(_ lines: String...) throws -> JavaScriptValue {
    try eval(lines.joined(separator: "\n"))
  }

  // MARK: - Equatable

  public static func == (lhs: JavaScriptRuntime, rhs: JavaScriptRuntime) -> Bool {
    return lhs === rhs
  }
}
