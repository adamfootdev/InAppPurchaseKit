//
//  TipJarTierType.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import Foundation

public enum TipJarTierType: Int, Sendable {
    case small
    case medium
    case large
    case huge

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

extension TipJarTierType: Comparable {
    public static func <(lhs: TipJarTierType, rhs: TipJarTierType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
