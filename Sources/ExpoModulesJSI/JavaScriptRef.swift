internal import jsi

/**
 Copyable reference to a non-copyable `JavaScriptValue`. Use it only when necessary.
 Swift (v6.2 at the time of writing) still has very limited support for non-copyable types.
 Many built-in types (including collections, containers, tuples) and protocols are not supporting them.
 There is a new ``InlineArray`` that supports them, but it requires iOS 26.
 - TODO: Annotate `value` and `take` with `@JavaScriptActor`.
 */
public final class JavaScriptRef<T: JavaScriptType & ~Copyable>: JavaScriptType, Sendable, Copyable, Escapable {
  /**
   The referenced value. It is borrowed forever, so it cannot be accessed from the outside.
   The only way to read this value is by making an explicit copy (see `getValue`).
   */
  nonisolated(unsafe) private var value: T?

  /**
   Makes a reference to the value. The value is consumed and cannot be used anymore in the calling scope.
   */
  public init(_ value: consuming sending T) {
    self.value = consume value
  }

  public func take() throws -> sending T {
    // TODO: Throw JS error instead of force unwrapping
    let value = value.take()
    return value!
  }

  public func take() -> sending T? {
    let value = value.take()
    return value
  }

  /**
   Takes the value as a `JavaScriptValue`.
   */
  public func asValue() -> JavaScriptValue {
    return take()?.asValue() ?? .undefined()
  }
}

extension JavaScriptRef: JSRepresentable where T: JSRepresentable & ~Copyable {}
extension JavaScriptRef: JSIRepresentable where T: JSIRepresentable & ~Copyable {
  internal static func fromJSIValue(_ value: borrowing facebook.jsi.Value, in runtime: facebook.jsi.Runtime) -> JavaScriptValue {
    fatalError("Unimplemented")
  }

  internal func toJSIValue(in runtime: facebook.jsi.Runtime) -> facebook.jsi.Value {
    return take()?.toJSIValue(in: runtime) ?? .undefined()
  }
}
