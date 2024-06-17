//
//  InAppPurchaseKitConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import SwiftUI
import StoreKit

public struct InAppPurchaseKitConfiguration: Sendable {
    public let title: String
    public let subtitle: String
    public let imageName: String
    public let systemImage: String
    public let tiers: InAppPurchaseTiers
    public let features: [InAppPurchaseFeature]
    public let termsOfUseURL: URL
    public let privacyPolicyURL: URL
    public let loadProducts: Bool
    public let enableSinglePurchaseMode: Bool
    public let showPrimaryTierOnly: Bool
    public let legacyUserThreshold: Int?
    public let showLegacyTier: Bool
    public let fromAppExtension: Bool
    public let sharedUserDefaults: UserDefaults
    public let overridePurchased: Bool?
    public let enableHapticFeedback: Bool
    public let purchaseCompletionBlock: (@MainActor @Sendable (_ product: Product, _ metadata: [String: Any]?) -> Void)?
    public let updatedPurchasesCompletionBlock: (@MainActor @Sendable () -> Void)?

    public init(
        _ title: String,
        subtitle: String,
        imageName: String,
        systemImage: String = "plus.app",
        tiers: InAppPurchaseTiers,
        features: [InAppPurchaseFeature],
        termsOfUseURL: URL,
        privacyPolicyURL: URL,
        loadProducts: Bool = true,
        enableSinglePurchaseMode: Bool = true,
        showPrimaryTierOnly: Bool = true,
        legacyUserThreshold: Int? = nil,
        showLegacyTier: Bool = true,
        fromAppExtension: Bool = false,
        sharedUserDefaults: UserDefaults,
        overridePurchased: Bool? = nil,
        enableHapticFeedback: Bool = true,
        purchaseCompletionBlock: (@MainActor @Sendable (_ product: Product, _ metadata: [String: Any]?) -> Void)? = nil,
        updatedPurchasesCompletionBlock: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.systemImage = systemImage
        self.tiers = tiers
        self.features = features
        self.termsOfUseURL = termsOfUseURL
        self.privacyPolicyURL = privacyPolicyURL
        self.loadProducts = loadProducts
        self.enableSinglePurchaseMode = enableSinglePurchaseMode
        self.showPrimaryTierOnly = showPrimaryTierOnly
        self.legacyUserThreshold = legacyUserThreshold
        self.showLegacyTier = showLegacyTier
        self.fromAppExtension = fromAppExtension
        self.sharedUserDefaults = sharedUserDefaults
        self.overridePurchased = overridePurchased
        self.enableHapticFeedback = enableHapticFeedback
        self.purchaseCompletionBlock = purchaseCompletionBlock
        self.updatedPurchasesCompletionBlock = updatedPurchasesCompletionBlock
    }

    var showSinglePurchaseMode: Bool {
        tiers.allTiers.count == 1 && enableSinglePurchaseMode
    }


    // MARK: - Previews

    public static let preview: InAppPurchaseKitConfiguration = {
        let configuration = InAppPurchaseKitConfiguration(
            "My App Pro",
            subtitle: "Unlock all features.",
            imageName: "",
            systemImage: "plus.app",
            tiers: .example,
            features: [.example, .example, .example],
            termsOfUseURL: URL(string: "https://adamfoot.dev")!,
            privacyPolicyURL: URL(string: "https://adamfoot.dev")!,
            loadProducts: true,
            enableSinglePurchaseMode: true,
            showPrimaryTierOnly: true,
            legacyUserThreshold: nil,
            showLegacyTier: true,
            fromAppExtension: false,
            sharedUserDefaults: .standard,
            overridePurchased: nil
        ) { product, metadata in
            print("Purchased \(product.displayName) with \(metadata ?? [:])")
        } updatedPurchasesCompletionBlock: {
            print("Updated Purchases")
        }

        return configuration
    }()
}
