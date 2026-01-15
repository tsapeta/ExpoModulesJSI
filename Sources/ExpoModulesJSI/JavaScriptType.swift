/**
 Protocol conformed by the types that represent any JavaScript values.
 */
public protocol JavaScriptType: Sendable, ~Copyable {
  associatedtype Ref

  /**
   Returns a value that this instance represents as a `JavaScriptValue`.
   */
  func asValue() -> JavaScriptValue

  /**
   Creates a reference to this non-copyable buffer, transferring its ownership to the reference.
   */
  consuming func ref() -> JavaScriptRef<Self>
}

public extension JavaScriptType where Self: ~Copyable {
  typealias Ref = JavaScriptRef<Self>

  consuming func ref() -> JavaScriptRef<Self> {
    return JavaScriptRef(self)
  }
}
