//
//  InAppPurchaseTier.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation

public struct InAppPurchaseTier: Identifiable, Hashable, Sendable {
    public let id: String
    public let type: InAppPurchaseTierType

    public init(
        id: String,
        type: InAppPurchaseTierType
    ) {
        self.id = id
        self.type = type
    }


    // MARK: - Previews

    public static let example: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Yearly",
            type: .yearly
        )

        return tier
    }()

    public static let yearlyExample: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Yearly",
            type: .yearly
        )

        return tier
    }()

    public static let monthlyExample: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Monthly",
            type: .monthly
        )

        return tier
    }()

    public static let lifetimeExample: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Lifetime",
            type: .lifetime
        )

        return tier
    }()
}

extension InAppPurchaseTier: Comparable {
    public static func <(lhs: InAppPurchaseTier, rhs: InAppPurchaseTier) -> Bool {
        lhs.type < rhs.type
    }
}
