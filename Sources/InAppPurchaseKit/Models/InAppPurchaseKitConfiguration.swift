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
    public let image: PlatformImage
    public let tiers: InAppPurchaseTiers
    public let features: [InAppPurchaseFeature]
    public let termsOfUseURL: URL
    public let privacyPolicyURL: URL
    public let loadProducts: Bool
    public let enableSinglePurchaseMode: Bool
    public let legacyUserThreshold: Int?
    public let fromAppExtension: Bool
    public let sharedUserDefaults: UserDefaults
    public let overridePurchased: Bool?
    public let enableHapticFeedback: Bool
    public let purchaseCompletionBlock: ((_ product: Product) -> Void)?
    public let updatedPurchasesCompletionBlock: (() -> Void)?

    public init(
        _ title: String,
        subtitle: String,
        image: PlatformImage,
        tiers: InAppPurchaseTiers,
        features: [InAppPurchaseFeature],
        termsOfUseURL: URL,
        privacyPolicyURL: URL,
        loadProducts: Bool = true,
        enableSinglePurchaseMode: Bool = true,
        legacyUserThreshold: Int? = nil,
        fromAppExtension: Bool = false,
        sharedUserDefaults: UserDefaults,
        overridePurchased: Bool? = nil,
        enableHapticFeedback: Bool = true,
        purchaseCompletionBlock: ((_ product: Product) -> Void)? = nil,
        updatedPurchasesCompletionBlock: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.tiers = tiers
        self.features = features
        self.termsOfUseURL = termsOfUseURL
        self.privacyPolicyURL = privacyPolicyURL
        self.loadProducts = loadProducts
        self.enableSinglePurchaseMode = enableSinglePurchaseMode
        self.legacyUserThreshold = legacyUserThreshold
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

    public static var preview: InAppPurchaseKitConfiguration = {
        let configuration = InAppPurchaseKitConfiguration(
            "Upgrade to My App Pro",
            subtitle: "Unlock all features.",
            image: previewImage,
            tiers:.example,
            features: [.example, .example, .example],
            termsOfUseURL: URL(string: "https://adamfoot.dev")!,
            privacyPolicyURL: URL(string: "https://adamfoot.dev")!,
            loadProducts: true,
            enableSinglePurchaseMode: true,
            legacyUserThreshold: nil,
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

    private static var previewImage: PlatformImage = {
        #if os(macOS)
        return NSImage()
        #else
        return UIImage()
        #endif
    }()
}
