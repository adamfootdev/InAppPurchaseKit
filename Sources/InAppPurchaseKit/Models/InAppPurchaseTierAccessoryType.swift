//
//  InAppPurchaseTierAccessoryType.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

enum InAppPurchaseTierAccessoryType {
    case saving(value: Int)
    case loyalty

    var title: String {
        switch self {
        case .saving(let value):
            return String(localized: "Save \(value)%")
        case .loyalty:
            return String(localized: "Loyalty")
        }
    }

    var tintColor: Color {
        switch self {
        case .saving(_):
            return .orange
        case .loyalty:
            return .green
        }
    }
}
