//
//  TipJarTier.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import Foundation

public struct TipJarTier: Identifiable, Hashable, Sendable {
    public let id: String
    public let type: TipJarTierType

    public init(
        id: String,
        type: TipJarTierType
    ) {
        self.id = id
        self.type = type
    }


    // MARK: - Previews

    public static let example: TipJarTier = {
        let tier = TipJarTier(
            id: "app.FootWare.Example.Tip.Small",
            type: .small
        )

        return tier
    }()

    public static let examples: Set<TipJarTier> = {
        return [
            .init(
                id: "app.FootWare.Example.Tip.Small",
                type: .small
            ),
            .init(
                id: "app.FootWare.Example.Tip.Medium",
                type: .medium
            ),
            .init(
                id: "app.FootWare.Example.Tip.Large",
                type: .large
            ),
            .init(
                id: "app.FootWare.Example.Tip.Huge",
                type: .huge
            )
        ]
    }()
}
