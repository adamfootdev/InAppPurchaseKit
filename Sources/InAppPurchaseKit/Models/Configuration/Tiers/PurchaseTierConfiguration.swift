//
//  PurchaseTierConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/01/2026.
//

import Foundation

public struct PurchaseTierConfiguration: Identifiable, Hashable, Sendable {
    /// A `String` containing the ID of the tier.
    public let id: String
    
    /// An array of `String` containing IDs that are also associated with this tier in the past.
    public let alternateIDs: [String]
    
    /// A `Bool` indicating whether this tier should always be shown regardless of whether
    /// hiding/showing all options.
    public let alwaysVisible: Bool
    
    /// A `Bool` indicating whether the tier is the primary tier to pre-select and show in
    /// locked feature views. This should only be set for one tier.
    public let isPrimary: Bool
    
    /// The optional `LegacyPurchaseTierConfiguration`. If set, this will be used for
    /// showing purchasing options to users if they meet the legacy user criteria in the main
    /// configuration.
    public let legacyConfiguration: LegacyPurchaseTierConfiguration?
    
    /// Creates a new `PurchaseTierConfiguration` object.
    /// - Parameters:
    ///   - id: A `String` containing the ID of the tier.
    ///   - alternateIDs: An array of `String` containing IDs that are also associated with this tier in the past.
    ///   - alwaysVisible: A `Bool` indicating whether this tier should always be shown regardless of whether
    ///   hiding/showing all options.
    ///   - isPrimary: A `Bool` indicating whether the tier is the primary tier to pre-select and show in
    ///   locked feature views. This should only be set for one tier.
    ///   - legacyConfiguration: The optional `LegacyPurchaseTierConfiguration`. If set, this will be used for
    ///   showing purchasing options to users if they meet the legacy user criteria in the main
    ///   configuration.
    public init(
        id: String,
        alternateIDs: [String]? = nil,
        alwaysVisible: Bool,
        isPrimary: Bool = false,
        legacyConfiguration: LegacyPurchaseTierConfiguration? = nil
    ) {
        self.id = id
        self.alternateIDs = alternateIDs ?? []
        self.alwaysVisible = alwaysVisible
        self.isPrimary = isPrimary
        self.legacyConfiguration = legacyConfiguration
    }


    // MARK: - Previews

    public static let example: PurchaseTierConfiguration = {
        let configuration = PurchaseTierConfiguration(
            id: "app.FootWare.Example.Pro.Yearly",
            alwaysVisible: true
        )

        return configuration
    }()
}
