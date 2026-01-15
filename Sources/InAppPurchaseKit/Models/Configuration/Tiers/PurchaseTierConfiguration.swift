//
//  PurchaseTierConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/01/2026.
//

import Foundation

public struct PurchaseTierConfiguration: Identifiable, Hashable, Sendable {
    public let id: String
    public let alternateIDs: [String]
    public let alwaysVisible: Bool
    public let isPrimary: Bool
    public let legacyConfiguration: LegacyPurchaseTierConfiguration?

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
