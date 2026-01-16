//
//  LegacyPurchaseTierConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/01/2026.
//

import Foundation

public struct LegacyPurchaseTierConfiguration: Identifiable, Hashable, Sendable {
    /// A `String` containing the ID of the tier.
    public let id: String
    
    /// A `Bool` indicating whether the tier should be available to purchase.
    public let visible: Bool
    
    /// Creates a new `LegacyPurchaseTierConfiguration` object.
    /// - Parameters:
    ///   - id: A `String` containing the ID of the tier.
    ///   - visible: A `Bool` indicating whether the tier should be available to purchase.
    init(id: String, visible: Bool) {
        self.id = id
        self.visible = visible
    }


    // MARK: - Previews

    public static let example: LegacyPurchaseTierConfiguration = {
        let configuration = LegacyPurchaseTierConfiguration(
            id: "app.FootWare.Example.Pro.LegacyYearly",
            visible: true
        )

        return configuration
    }()
}
