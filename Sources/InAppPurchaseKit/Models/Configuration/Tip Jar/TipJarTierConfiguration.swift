//
//  TipJarTierConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import Foundation

public struct TipJarTierConfiguration: Identifiable, Hashable, Sendable {
    /// A `String` containing the ID of the tier.
    public let id: String
    
    /// Creates a new `TipJarTierConfiguration` object.
    /// - Parameter id: A `String` containing the ID of the tier.
    public init(id: String) {
        self.id = id
    }


    // MARK: - Previews

    public static let example: TipJarTierConfiguration = {
        let configuration = TipJarTierConfiguration(
            id: "app.FootWare.Example.Tip.Small"
        )

        return configuration
    }()
}
