//
//  InAppPurchaseKitConfiguration.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import SwiftUI
import StoreKit

@MainActor
public struct InAppPurchaseKitConfiguration: Sendable {
    public var title: String
    public var subtitle: String
    public var appName: String
    public var imageName: String
    public var systemImage: String
    public var tintColor: Color

    public var termsOfUseURL: URL
    public var privacyPolicyURL: URL
    public var features: [PurchaseFeature]

    public var tiers: PurchaseTiers
    public var preInAppPurchaseThreshold: PreInAppPurchaseThreshold?
    public var tipJarTiers: Set<TipJarTier>?

    public var sharedUserDefaults: UserDefaults

    public var purchaseCompletionBlock: (@Sendable (_ product: Product) -> Void)?
    public var updatedPurchasesCompletionBlock: (@Sendable () -> Void)?

    public init(
        _ title: String,
        subtitle: String,
        appName: String,
        imageName: String,
        systemImage: String = "plus.app",
        tintColor: Color,
        termsOfUseURL: URL,
        privacyPolicyURL: URL,
        features: [PurchaseFeature],
        tiers: PurchaseTiers,
        preInAppPurchaseThreshold: PreInAppPurchaseThreshold? = nil,
        tipJarTiers: Set<TipJarTier>? = nil,
        sharedUserDefaults: UserDefaults,
        onPurchase purchaseCompletionBlock: (@Sendable (_ product: Product) -> Void)? = nil,
        onUpdatedPurchases updatedPurchasesCompletionBlock: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.appName = appName
        self.imageName = imageName
        self.systemImage = systemImage
        self.tintColor = tintColor
        self.termsOfUseURL = termsOfUseURL
        self.privacyPolicyURL = privacyPolicyURL
        self.features = features
        self.tiers = tiers
        self.preInAppPurchaseThreshold = preInAppPurchaseThreshold
        self.tipJarTiers = tipJarTiers
        self.sharedUserDefaults = sharedUserDefaults
        self.purchaseCompletionBlock = purchaseCompletionBlock
        self.updatedPurchasesCompletionBlock = updatedPurchasesCompletionBlock
    }

    var showSinglePurchaseMode: Bool {
        tiers.orderedTiers.count == 1
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
            termsOfUseURL: URL(string: "https://adamfoot.dev")!,
            privacyPolicyURL: URL(string: "https://adamfoot.dev")!,
            features: [.example, .example, .example],
            tiers: .example,
            tipJarTiers: TipJarTier.examples,
            sharedUserDefaults: .standard
        ) { product in
            print("Purchased \(product.displayName)")
        } onUpdatedPurchases: {
            print("Updated Purchases")
        }

        return configuration
    }()
}
