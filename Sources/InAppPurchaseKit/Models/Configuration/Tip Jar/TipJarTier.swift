//
//  TipJarTier.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import Foundation

public enum TipJarTier: Identifiable, Hashable, Sendable {
    case small(configuration: TipJarTierConfiguration)
    case medium(configuration: TipJarTierConfiguration)
    case large(configuration: TipJarTierConfiguration)
    case huge(configuration: TipJarTierConfiguration)

    public var configuration: TipJarTierConfiguration {
        switch self {
        case .small(let configuration),
                .medium(let configuration),
                .large(let configuration),
                .huge(let configuration):
            return configuration
        }
    }

    public var id: String {
        return configuration.id
    }

    public var title: String {
        switch self {
        case .small:
            return String(
                localized: "Small Tip",
                bundle: .module
            )
        case .medium:
            return String(
                localized: "Medium Tip",
                bundle: .module
            )
        case .large:
            return String(
                localized: "Large Tip",
                bundle: .module
            )
        case .huge:
            return String(
                localized: "Huge Tip",
                bundle: .module
            )
        }
    }
}
