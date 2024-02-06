//
//  InAppPurchaseTier.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation

public struct InAppPurchaseTier: Identifiable, Hashable {
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

    public static var example: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Yearly",
            type: .yearly
        )

        return tier
    }()

    public static var yearlyExample: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Yearly",
            type: .yearly
        )

        return tier
    }()

    public static var monthlyExample: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Monthly",
            type: .monthly
        )

        return tier
    }()

    public static var lifetimeExample: InAppPurchaseTier = {
        let tier = InAppPurchaseTier(
            id: "app.FootWare.Example.Pro.Lifetime",
            type: .lifetime
        )

        return tier
    }()
}
