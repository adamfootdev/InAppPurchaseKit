//
//  InAppPurchaseTierType.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation

public enum InAppPurchaseTierType {
    case weekly
    case monthly
    case yearly
    case lifetime
    case legacyUserLifetime

    public var title: String {
        switch self {
        case .weekly:
            return String(
                localized: "Weekly",
                bundle: .module
            )
        case .monthly:
            return String(
                localized: "Monthly",
                bundle: .module
            )
        case .yearly:
            return String(
                localized: "Yearly",
                bundle: .module
            )
        case .lifetime:
            return String(
                localized: "Lifetime",
                bundle: .module
            )
        case .legacyUserLifetime:
            return String(
                localized: "Lifetime",
                bundle: .module
            )
        }
    }

    public var paymentTimeTitle: String {
        switch self {
        case .weekly:
            return String(
                localized: "Week",
                bundle: .module
            )
        case .monthly:
            return String(
                localized: "Month",
                bundle: .module
            )
        case .yearly:
            return String(
                localized: "Year",
                bundle: .module
            )
        case .lifetime:
            return String(
                localized: "Lifetime",
                bundle: .module
            )
        case .legacyUserLifetime:
            return String(
                localized: "Lifetime",
                bundle: .module
            )
        }
    }
}
