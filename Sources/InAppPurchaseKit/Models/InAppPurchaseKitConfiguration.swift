//
//  InAppPurchaseKitConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import SwiftUI

public struct InAppPurchaseKitConfiguration {
    public let title: String
    public let subtitle: String
    public let tiers: [InAppPurchaseTier]
    public let features: [InAppPurchaseFeature]
    public let termsOfUseURL: URL
    public let privacyPolicyURL: URL
    public let loadProducts: Bool
    public let enableSinglePurchaseMode: Bool
    public let fromAppExtension: Bool
    public let sharedUserDefaults: UserDefaults
    public let overridePurchased: Bool?
    public let enableHapticFeedback: Bool

    public init(
        _ title: String,
        subtitle: String,
        tiers: [InAppPurchaseTier],
        features: [InAppPurchaseFeature],
        termsOfUseURL: URL,
        privacyPolicyURL: URL,
        loadProducts: Bool = true,
        enableSinglePurchaseMode: Bool = true,
        fromAppExtension: Bool = false,
        sharedUserDefaults: UserDefaults,
        overridePurchased: Bool? = nil,
        enableHapticFeedback: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.tiers = tiers
        self.features = features
        self.termsOfUseURL = termsOfUseURL
        self.privacyPolicyURL = privacyPolicyURL
        self.loadProducts = loadProducts
        self.enableSinglePurchaseMode = enableSinglePurchaseMode
        self.fromAppExtension = fromAppExtension
        self.sharedUserDefaults = sharedUserDefaults
        self.overridePurchased = overridePurchased
        self.enableHapticFeedback = enableHapticFeedback
    }

    var tierIDs: [String] {
        tiers.map { $0.id }
    }


    // MARK: - Previews

    public static var preview: InAppPurchaseKitConfiguration = {
        let configuration = InAppPurchaseKitConfiguration(
            "Upgrade to My App Pro",
            subtitle: "Unlock all features.",
            tiers: [.monthlyExample, .yearlyExample, .lifetimeExample],
            features: [.example, .example, .example],
            termsOfUseURL: URL(string: "https://adamfoot.dev")!,
            privacyPolicyURL: URL(string: "https://adamfoot.dev")!,
            loadProducts: true,
            enableSinglePurchaseMode: true,
            fromAppExtension: false,
            sharedUserDefaults: .standard,
            overridePurchased: nil
        )

        return configuration
    }()
}
