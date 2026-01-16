//
//  LockedFeatureConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import SwiftUI

@MainActor
public struct LockedFeatureConfiguration: Sendable {
    /// An optional `LocalizedStringKey` to use as the title.
    public let titleKey: LocalizedStringKey?

    /// An optional `String` to use as the title.
    public let title: String?

    /// An optional `String` containing the system image name.
    public let systemImage: String?

    /// The `Color` to use for the title.
    public let titleColor: Color

    /// A `Bool` indicating whether legacy users should have access to the feature.
    public let enableIfLegacyUser: Bool

    /// An optional action to perform when a transaction is completed. This is separate
    /// to the action set in `InAppPurchaseKitConfiguration` but both
    /// will be performed. If an action is set, you will need to also dismiss the view. This
    /// is handled automatically when no action is set.
    public let onPurchaseAction: (@Sendable () -> Void)?

    /// Creates a new `LockedFeatureConfiguration` to use for locked feature views.
    /// - Parameters:
    ///   - titleKey: A `LocalizedStringKey` to use as the title.
    ///   - systemImage: A `String` containing the system image name.
    ///   - titleColor: The `Color` to use for the title.
    ///   - enableIfLegacyUser: <#enableIfLegacyUser description#>
    ///   - onPurchaseAction: An optional action to perform when a transaction is completed. This is separate
    ///   to the action set in `InAppPurchaseKitConfiguration` but both
    ///   will be performed. If an action is set, you will need to also dismiss the view. This
    ///   is handled automatically when no action is set. Defaults to `nil`.
    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = systemImage
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.onPurchaseAction = onPurchaseAction
    }
    
    /// Creates a new `LockedFeatureConfiguration` to use for locked feature views.
    /// - Parameters:
    ///   - titleKey: A `LocalizedStringKey` to use as the title.
    ///   - titleColor: The `Color` to use for the title.
    ///   - enableIfLegacyUser: A `Bool` indicating whether legacy users should have access to the feature.
    ///   - onPurchaseAction: An optional action to perform when a transaction is completed. This is separate
    ///   to the action set in `InAppPurchaseKitConfiguration` but both
    ///   will be performed. If an action is set, you will need to also dismiss the view. This
    ///   is handled automatically when no action is set. Defaults to `nil`.
    public init(
        _ titleKey: LocalizedStringKey,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = nil
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.onPurchaseAction = onPurchaseAction
    }
}

extension LockedFeatureConfiguration {
    /// Creates a new `LockedFeatureConfiguration` to use for locked feature views.
    /// - Parameters:
    ///   - title: A `String` to use as the title.
    ///   - systemImage: A `String` containing the system image name.
    ///   - titleColor: The `Color` to use for the title.
    ///   - enableIfLegacyUser: A `Bool` indicating whether legacy users should have access to the feature.
    ///   - onPurchaseAction: An optional action to perform when a transaction is completed. This is separate
    ///   to the action set in `InAppPurchaseKitConfiguration` but both
    ///   will be performed. If an action is set, you will need to also dismiss the view. This
    ///   is handled automatically when no action is set. Defaults to `nil`.
    public init(
        verbatim title: String,
        systemImage: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = systemImage
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.onPurchaseAction = onPurchaseAction
    }
    
    /// Creates a new `LockedFeatureConfiguration` to use for locked feature views.
    /// - Parameters:
    ///   - title: A `String` to use as the title.
    ///   - titleColor: The `Color` to use for the title.
    ///   - enableIfLegacyUser: A `Bool` indicating whether legacy users should have access to the feature.
    ///   - onPurchaseAction: An optional action to perform when a transaction is completed. This is separate
    ///   to the action set in `InAppPurchaseKitConfiguration` but both
    ///   will be performed. If an action is set, you will need to also dismiss the view. This
    ///   is handled automatically when no action is set. Defaults to `nil`.
    public init(
        verbatim title: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = nil
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.onPurchaseAction = onPurchaseAction
    }


    // MARK: - Previews

    public static let example: LockedFeatureConfiguration = {
        let configuration = LockedFeatureConfiguration(
            "Title",
            systemImage: "app"
        )

        return configuration
    }()
}
