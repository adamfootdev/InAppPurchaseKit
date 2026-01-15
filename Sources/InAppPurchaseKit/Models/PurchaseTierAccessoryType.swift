//
//  PurchaseTierAccessoryType.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

enum PurchaseTierAccessoryType {
    case saving(value: Int)
    case loyalty

    var title: String {
        switch self {
        case .saving(let value):
            return String(
                localized: "Save \(value)%",
                bundle: .module
            )
        case .loyalty:
            return String(
                localized: "Loyalty",
                bundle: .module
            )
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
