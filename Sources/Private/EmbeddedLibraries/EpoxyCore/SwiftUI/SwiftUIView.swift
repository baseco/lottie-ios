// Created by eric_horacek on 9/8/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUIView

/// A `UIViewRepresentable` SwiftUI `View` that wraps its `Content` `UIView` within a
/// `SwiftUIMeasurementContainer`, used to size a UIKit view correctly within a SwiftUI view
/// hierarchy.
///
/// Includes an optional generic `Storage` value, which can be used to compare old and new values
/// across state changes to prevent redundant view updates.
internal struct SwiftUIView<Content: ViewType, Storage>: MeasuringViewRepresentable,
  UIViewConfiguringSwiftUIView
{

  // MARK: Lifecycle

  /// Creates a SwiftUI representation of the content view with the given storage and the provided
  /// `makeContent` closure to construct the content whenever `makeUIView(…)` is invoked.
  init(storage: Storage, makeContent: @escaping () -> Content) {
    self.storage = storage
    self.makeContent = makeContent
  }

  /// Creates a SwiftUI representation of the content view with the provided `makeContent` closure
  /// to construct it whenever `makeUIView(…)` is invoked.
  init(makeContent: @escaping () -> Content) where Storage == Void {
    storage = ()
    self.makeContent = makeContent
  }

  // MARK: Public

  internal var configurations: [Configuration] = []

  internal var sizing: SwiftUIMeasurementContainerStrategy = .automatic

  // MARK: Private

  /// The current stored value, with the previous value provided to the configuration closure as
  /// the `oldStorage`.
  private var storage: Storage

  /// A closure that's invoked to construct the represented content view.
  private var makeContent: () -> Content
}

// MARK: UIViewRepresentable

extension SwiftUIView {
  internal func makeCoordinator() -> Coordinator {
    Coordinator(storage: storage)
  }

  #if os(macOS)
  internal func makeNSView(context _: Context) -> SwiftUIMeasurementContainer<Content> {
    SwiftUIMeasurementContainer(content: makeContent(), strategy: sizing)
  }

  internal func updateNSView(_ uiView: SwiftUIMeasurementContainer<Content>, context: Context) {
    let oldStorage = context.coordinator.storage
    context.coordinator.storage = storage

    let configurationContext = ConfigurationContext(
      oldStorage: oldStorage,
      viewRepresentableContext: context,
      container: uiView)

    for configuration in configurations {
      configuration(configurationContext)
    }
  }
  #else
  internal func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Content> {
    SwiftUIMeasurementContainer(content: makeContent(), strategy: sizing)
  }

  internal func updateUIView(_ uiView: SwiftUIMeasurementContainer<Content>, context: Context) {
    let oldStorage = context.coordinator.storage
    context.coordinator.storage = storage

    let configurationContext = ConfigurationContext(
      oldStorage: oldStorage,
      viewRepresentableContext: context,
      container: uiView)

    for configuration in configurations {
      configuration(configurationContext)
    }
  }
  #endif
}

// MARK: SwiftUIView.ConfigurationContext

extension SwiftUIView {
  /// The configuration context that's available to configure the `Content` view whenever the
  /// `updateUIView()` method is invoked via a configuration closure.
  internal struct ConfigurationContext: ViewProviding {
    /// The previous value for the `Storage` of this `SwiftUIView`, which can be used to store
    /// values across state changes to prevent redundant view updates.
    internal var oldStorage: Storage

    /// The `UIViewRepresentable.Context`, with information about the transaction and environment.
    internal var viewRepresentableContext: Context

    /// The backing measurement container that contains the `Content`.
    internal var container: SwiftUIMeasurementContainer<Content>

    /// The `UIView` content that's being configured.
    ///
    /// Setting this to a new value updates the backing measurement container's `content`.
    internal var view: Content {
      get { container.content }
      nonmutating set { container.content = newValue }
    }

    /// A convenience accessor indicating whether this content update should be animated.
    internal var animated: Bool {
      viewRepresentableContext.transaction.animation != nil
    }
  }
}

// MARK: SwiftUIView.Coordinator

extension SwiftUIView {
  /// A coordinator that stores the `storage` associated with this view, enabling the old storage
  /// value to be accessed during the `updateUIView(…)`.
  internal final class Coordinator {

    // MARK: Lifecycle

    fileprivate init(storage: Storage) {
      self.storage = storage
    }

    // MARK: Internal

    fileprivate(set) var storage: Storage
  }
}
