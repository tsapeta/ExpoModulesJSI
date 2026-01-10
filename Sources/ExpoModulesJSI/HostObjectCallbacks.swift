internal import jsi
internal import CxxStdlib

@_expose(Cxx)
public class HostObjectCallbacks {
  typealias Getter = (std.string) -> facebook.jsi.Value
  typealias Setter = (std.string, consuming facebook.jsi.Value) -> Void
  typealias PropertyNamesGetter = () -> [std.string]

  private let getter: Getter
  private let setter: Setter
  private let propertyNamesGetter: PropertyNamesGetter

  init(get: @escaping Getter, set: @escaping Setter, getPropertyNames: @escaping PropertyNamesGetter) {
    self.getter = get
    self.setter = set
    self.propertyNamesGetter = getPropertyNames
  }

  func get(property: std.string) -> facebook.jsi.Value {
    return getter(property)
  }

  func set(property: std.string, value: consuming facebook.jsi.Value) {
    return setter(property, value)
  }
}
