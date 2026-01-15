//
//  LegacyPurchaseTierConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/01/2026.
//

import Foundation

public struct LegacyPurchaseTierConfiguration: Identifiable, Hashable, Sendable {
    public let id: String
    public let visible: Bool

    init(id: String, visible: Bool) {
        self.id = id
        self.visible = visible
    }


    // MARK: - Previews

    public static let example: LegacyPurchaseTierConfiguration = {
        let configuration = LegacyPurchaseTierConfiguration(
            id: "app.FootWare.Example.Pro.LegacyYearly",
            visible: true
        )

        return configuration
    }()
}
