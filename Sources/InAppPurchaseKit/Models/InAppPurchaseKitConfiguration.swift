//
//  InAppPurchaseKitConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import SwiftUI
import StoreKit

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
    public let purchaseCompletionBlock: ((_ product: Product) -> Void)?
    public let updatedPurchasesCompletionBlock: (() -> Void)?

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
        enableHapticFeedback: Bool = true,
        purchaseCompletionBlock: ((_ product: Product) -> Void)? = nil,
        updatedPurchasesCompletionBlock: (() -> Void)? = nil
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
        self.purchaseCompletionBlock = purchaseCompletionBlock
        self.updatedPurchasesCompletionBlock = updatedPurchasesCompletionBlock
    }

    var tierIDs: [String] {
        tiers.map { $0.id }
    }

    var showSinglePurchaseMode: Bool {
        tiers.count == 1 && enableSinglePurchaseMode
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
        ) { product in
            print("Purchased \(product.displayName)")
        } updatedPurchasesCompletionBlock: {
            print("Updated Purchases")
        }

        return configuration
    }()
}
