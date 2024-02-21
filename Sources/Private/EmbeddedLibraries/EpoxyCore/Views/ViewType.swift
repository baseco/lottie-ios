// Created by Cal Stephens on 6/26/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit

/// The platform's main view type.
/// Either `UIView` on iOS/tvOS or `NSView` on macOS.
internal typealias ViewType = UIView

/// The platform's SwiftUI view representable type.
/// Either `UIViewRepresentable` on iOS/tvOS or `NSViewRepresentable` on macOS.
internal typealias ViewRepresentableType = UIViewRepresentable

/// The platform's layout constraint priority type.
/// Either `UILayoutPriority` on iOS/tvOS or `NSLayoutConstraint.Priority` on macOS.
internal typealias LayoutPriorityType = UILayoutPriority

extension ViewRepresentableType {
  /// The platform's view type for `ViewRepresentableType`.
  /// Either `UIViewType` on iOS/tvOS or `NSViewType` on macOS.
  internal typealias RepresentableViewType = UIViewType
}

#elseif os(macOS)
import AppKit

/// The platform's main view type.
/// Either `UIView` on iOS/tvOS, or `NSView` on macOS.
internal typealias ViewType = NSView

/// The platform's SwiftUI view representable type.
/// Either `UIViewRepresentable` on iOS/tvOS, or `NSViewRepresentable` on macOS.
internal typealias ViewRepresentableType = NSViewRepresentable

/// The platform's layout constraint priority type.
/// Either `UILayoutPriority` on iOS/tvOS, or `NSLayoutConstraint.Priority` on macOS.
internal typealias LayoutPriorityType = NSLayoutConstraint.Priority

extension ViewRepresentableType {
  /// The platform's view type for `ViewRepresentableType`.
  /// Either `UIViewType` on iOS/tvOS or `NSViewType` on macOS.
  internal typealias RepresentableViewType = NSViewType
}
#endif
