//
//  TipJarTiers.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import Foundation

public struct TipJarTiers: Sendable {
    /// The small optional `TipJarTier`.
    public let smallTier: TipJarTier?
    
    /// The medium optional `TipJarTier`.
    public let mediumTier: TipJarTier?
    
    /// The large optional `TipJarTier`.
    public let largeTier: TipJarTier?
    
    /// The huge optional `TipJarTier`.
    public let hugeTier: TipJarTier?
    
    /// Creates a new `TipJarTiers` object.
    /// - Parameters:
    ///   - smallTier: The small optional `TipJarTier`.
    ///   - mediumTier: The medium optional `TipJarTier`.
    ///   - largeTier: The large optional `TipJarTier`.
    ///   - hugeTier: The huge optional `TipJarTier`.
    public init(
        smallTier: TipJarTierConfiguration?,
        mediumTier: TipJarTierConfiguration?,
        largeTier: TipJarTierConfiguration?,
        hugeTier: TipJarTierConfiguration?
    ) {
        if let smallTier {
            self.smallTier = .small(configuration: smallTier)
        } else {
            self.smallTier = nil
        }

        if let mediumTier {
            self.mediumTier = .medium(configuration: mediumTier)
        } else {
            self.mediumTier = nil
        }

        if let largeTier {
            self.largeTier = .large(configuration: largeTier)
        } else {
            self.largeTier = nil
        }

        if let hugeTier {
            self.hugeTier = .huge(configuration: hugeTier)
        } else {
            self.hugeTier = nil
        }
    }

    public var orderedTiers: [TipJarTier] {
        let tiers = [smallTier, mediumTier, largeTier, hugeTier]
        return tiers.compactMap { $0 }
    }

    var allTierIDs: [String] {
        return orderedTiers.map { $0.id }
    }


    // MARK: - Previews

    public static let example: TipJarTiers = {
        let tiers = TipJarTiers(
            smallTier: .init(id: "app.FootWare.Example.Tip.Small"),
            mediumTier: .init(id: "app.FootWare.Example.Tip.Medium"),
            largeTier: .init(id: "app.FootWare.Example.Tip.Large"),
            hugeTier: .init(id: "app.FootWare.Example.Tip.Huge")
        )

        return tiers
    }()
}
