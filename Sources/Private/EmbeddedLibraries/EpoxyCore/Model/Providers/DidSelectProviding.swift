// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - DidSelectProviding

/// A sentinel protocol for enabling an `CallbackContextEpoxyModeled` to provide a `didSelect`
/// closure property.
internal protocol DidSelectProviding { }

// MARK: - CallbackContextEpoxyModeled

extension CallbackContextEpoxyModeled where Self: DidSelectProviding {

  // MARK: Public

  /// A closure that's called to handle this model's view being selected.
  internal typealias DidSelect = (CallbackContext) -> Void

  /// A closure that's called to handle this model's view being selected.
  internal var didSelect: DidSelect? {
    get { self[didSelectProperty] }
    set { self[didSelectProperty] = newValue }
  }

  /// Returns a copy of this model with the given did select closure called after the current did
  /// select closure of this model, if there is one.
  internal func didSelect(_ value: DidSelect?) -> Self {
    copy(updating: didSelectProperty, to: value)
  }

  // MARK: Private

  private var didSelectProperty: EpoxyModelProperty<DidSelect?> {
    .init(keyPath: \Self.didSelect, defaultValue: nil, updateStrategy: .chain())
  }
}
