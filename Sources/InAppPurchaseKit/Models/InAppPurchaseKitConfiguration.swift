//
//  InAppPurchaseKitConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import SwiftUI
import StoreKit

public struct InAppPurchaseKitConfiguration: Sendable {
    public var title: String
    public var subtitle: String
    public var appName: String
    public var imageName: String
    public var systemImage: String
    public var tintColor: Color
    public var tiers: InAppPurchaseTiers
    public var tipJarTiers: Set<TipJarTier>?
    public var features: [InAppPurchaseFeature]
    public var termsOfUseURL: URL
    public var privacyPolicyURL: URL
    public var showPrimaryTierOnly: Bool
    public var legacyUserThreshold: LegacyUserThreshold?
    public var showLegacyTier: Bool
    public var fromAppExtension: Bool
    public var sharedUserDefaults: UserDefaults
    public var overridePurchased: Bool?
    public var enableHapticFeedback: Bool
    public var purchaseCompletionBlock: (@Sendable (_ product: Product) -> Void)?
    public var updatedPurchasesCompletionBlock: (@Sendable () -> Void)?

    public init(
        _ title: String,
        subtitle: String,
        appName: String,
        imageName: String,
        systemImage: String = "plus.app",
        tintColor: Color,
        tiers: InAppPurchaseTiers,
        tipJarTiers: Set<TipJarTier>? = nil,
        features: [InAppPurchaseFeature],
        termsOfUseURL: URL,
        privacyPolicyURL: URL,
        showPrimaryTierOnly: Bool = true,
        legacyUserThreshold: LegacyUserThreshold? = nil,
        showLegacyTier: Bool = true,
        fromAppExtension: Bool = false,
        sharedUserDefaults: UserDefaults,
        overridePurchased: Bool? = nil,
        enableHapticFeedback: Bool = true,
        purchaseCompletionBlock: (@Sendable (_ product: Product) -> Void)? = nil,
        updatedPurchasesCompletionBlock: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.appName = appName
        self.imageName = imageName
        self.systemImage = systemImage
        self.tintColor = tintColor
        self.tiers = tiers
        self.tipJarTiers = tipJarTiers
        self.features = features
        self.termsOfUseURL = termsOfUseURL
        self.privacyPolicyURL = privacyPolicyURL
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
        tiers.allTiers.count == 1
    }

    var sortedTipJarTiers: [TipJarTier] {
        guard let tipJarTiers else {
            return []
        }

        return tipJarTiers.sorted()
    }


    // MARK: - Previews

    public static let preview: InAppPurchaseKitConfiguration = {
        let configuration = InAppPurchaseKitConfiguration(
            "My App Pro",
            subtitle: "Unlock all features.",
            appName: "My App",
            imageName: "",
            systemImage: "plus.app",
            tintColor: .green,
            tiers: .example,
            tipJarTiers: TipJarTier.examples,
            features: [.example, .example, .example],
            termsOfUseURL: URL(string: "https://adamfoot.dev")!,
            privacyPolicyURL: URL(string: "https://adamfoot.dev")!,
            showPrimaryTierOnly: true,
            legacyUserThreshold: nil,
            showLegacyTier: true,
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
