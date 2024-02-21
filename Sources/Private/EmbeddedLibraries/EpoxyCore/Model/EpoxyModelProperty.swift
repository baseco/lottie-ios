// Created by eric_horacek on 11/18/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - EpoxyModelProperty

/// A property that can be stored in any concrete `EpoxyModeled` type.
///
/// Custom model properties can be declared in any module. It's recommended that properties are
/// declared as `var`s in extensions to `EpoxyModeled` with a `*Property` suffix.
///
/// For example, to declare a `EpoxyModelProperty` that fulfills the `TitleProviding` protocol:
///
/// ````
/// internal protocol TitleProviding {
///   var title: String? { get }
/// }
///
/// extension EpoxyModeled where Self: TitleProviding {
///   internal var title: String? {
///     get { self[titleProperty] }
///     set { self[titleProperty] = newValue }
///   }
///
///   internal func title(_ value: String?) -> Self {
///     copy(updating: titleProperty, to: value)
///   }
///
///   private var titleProperty: EpoxyModelProperty<String?> {
///     .init(keyPath: \TitleProviding.title, defaultValue: nil, updateStrategy: .replace)
///   }
/// }
/// ````
internal struct EpoxyModelProperty<Value> {

  // MARK: Lifecycle

  /// Creates a property identified by a `KeyPath` to its provided `value` and with its default
  /// value if not customized in content by consumers.
  ///
  /// The `updateStrategy` is used to update the value when updating from an old value to a new
  /// value.
  internal init<Model>(
    keyPath: KeyPath<Model, Value>,
    defaultValue: @escaping @autoclosure () -> Value,
    updateStrategy: UpdateStrategy)
  {
    self.keyPath = keyPath
    self.defaultValue = defaultValue
    self.updateStrategy = updateStrategy
  }

  // MARK: Public

  /// The `KeyPath` that uniquely identifies this property.
  internal let keyPath: AnyKeyPath

  /// A closure that produces the default property value when called.
  internal let defaultValue: () -> Value

  /// A closure used to update an `EpoxyModelProperty` from an old value to a new value.
  internal let updateStrategy: UpdateStrategy

}

// MARK: EpoxyModelProperty.UpdateStrategy

extension EpoxyModelProperty {
  /// A closure used to update an `EpoxyModelProperty` from an old value to a new value.
  internal struct UpdateStrategy {

    // MARK: Lifecycle

    internal init(update: @escaping (Value, Value) -> Value) {
      self.update = update
    }

    // MARK: Public

    /// A closure used to update an `EpoxyModelProperty` from an old value to a new value.
    internal var update: (_ old: Value, _ new: Value) -> Value
  }
}

// MARK: Defaults

extension EpoxyModelProperty.UpdateStrategy {
  /// Replaces the old value with the new value when an update occurs.
  internal static var replace: Self {
    .init { _, new in new }
  }

  /// Chains the new closure value onto the old closure value, returning a new closure that first
  /// calls the old closure and then subsequently calls the new closure.
  internal static func chain() -> EpoxyModelProperty<(() -> Void)?>.UpdateStrategy {
    .init { old, new in
      guard let new = new else { return old }
      guard let old = old else { return new }
      return {
        old()
        new()
      }
    }
  }

  /// Chains the new closure value onto the old closure value, returning a new closure that first
  /// calls the old closure and then subsequently calls the new closure.
  internal static func chain<A>() -> EpoxyModelProperty<((A) -> Void)?>.UpdateStrategy {
    .init { old, new in
      guard let new = new else { return old }
      guard let old = old else { return new }
      return { a in
        old(a)
        new(a)
      }
    }
  }

  /// Chains the new closure value onto the old closure value, returning a new closure that first
  /// calls the old closure and then subsequently calls the new closure.
  internal static func chain<A, B>() -> EpoxyModelProperty<((A, B) -> Void)?>.UpdateStrategy {
    .init { old, new in
      guard let new = new else { return old }
      guard let old = old else { return new }
      return { a, b in
        old(a, b)
        new(a, b)
      }
    }
  }

  /// Chains the new closure value onto the old closure value, returning a new closure that first
  /// calls the old closure and then subsequently calls the new closure.
  internal static func chain<A, B, C>() -> EpoxyModelProperty<((A, B, C) -> Void)?>.UpdateStrategy {
    .init { old, new in
      guard let new = new else { return old }
      guard let old = old else { return new }
      return { a, b, c in
        old(a, b, c)
        new(a, b, c)
      }
    }
  }

  /// Chains the new closure value onto the old closure value, returning a new closure that first
  /// calls the old closure and then subsequently calls the new closure.
  internal static func chain<A, B, C, D>() -> EpoxyModelProperty<((A, B, C, D) -> Void)?>.UpdateStrategy {
    .init { old, new in
      guard let new = new else { return old }
      guard let old = old else { return new }
      return { a, b, c, d in
        old(a, b, c, d)
        new(a, b, c, d)
      }
    }
  }

  // Add more arities as needed
}
