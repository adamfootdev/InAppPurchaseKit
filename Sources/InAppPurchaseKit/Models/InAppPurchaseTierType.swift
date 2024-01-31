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
    case lifetimeExisting

    var title: String {
        switch self {
        case .weekly:
            return String(localized: "Week")
        case .monthly:
            return String(localized: "Month")
        case .yearly:
            return String(localized: "Year")
        case .lifetime:
            return String(localized: "Lifetime")
        case .lifetimeExisting:
            return String(localized: "Lifetime")
        }
    }
}
