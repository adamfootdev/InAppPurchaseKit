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
    /// A `String` containing the name of the subscription.
    public var title: String
    
    /// A `String` containing the subtitle on the in-app purchase screen.
    public var subtitle: String
    
    /// A `String` containing the app name.
    public var appName: String
    
    /// A `String` containing the name of the app or subscription icon.
    /// This should be saved in your main Assets Catalog.
    public var imageName: String
    
    /// A `String` containing the name of a system image to use in rows.
    public var systemImage: String
    
    /// The `Color` to use for tinting buttons in the views.
    public var tintColor: Color
    
    /// A `URL` linking to the Terms of Use.
    public var termsOfUseURL: URL
    
    /// A `URL` linking to the Privacy Policy.
    public var privacyPolicyURL: URL
    
    /// An array of `PurchaseFeature` containing all of the features offered
    /// by the subscription.
    public var features: [PurchaseFeature]
    
    /// A `PurchaseTiers` object containing the subscription tiers.
    public var tiers: PurchaseTiers
    
    /// An optional `LegacyPurchaseThreshold` object containing the build & version
    /// numbers when a subscription was first offered. If the app has always been
    /// subscription-based or users are not grandfathered in, this can be set to `nil`.
    public var legacyPurchaseThreshold: LegacyPurchaseThreshold?
    
    /// An optional `TipJarTiers` object containing the Tip jar tiers.
    public var tipJarTiers: TipJarTiers?
    
    /// The `UserDefaults` storage location so that the subscription
    /// state can be accessed from widgets. This should be setup using App Groups.
    public var sharedUserDefaults: UserDefaults
    
    /// An optional action to perform when a purchase is completed.
    public var purchaseCompletionBlock: (@Sendable (_ product: Product) -> Void)?
    
    /// An optional action to perform when purchases are updated.
    public var updatedPurchasesCompletionBlock: (@Sendable () -> Void)?
    
    /// Creates a new `InAppPurchaseKitConfiguration` object.
    /// - Parameters:
    ///   - title: A `String` containing the name of the subscription.
    ///   - subtitle: A `String` containing the subtitle on the in-app purchase screen.
    ///   - appName: A `String` containing the app name.
    ///   - imageName: A `String` containing the name of the app or subscription icon.
    ///   This should be saved in your main Assets Catalog.
    ///   - systemImage: A `String` containing the name of a system image to use in rows.
    ///   Defaults to `"plus.app"`.
    ///   - tintColor: The `Color` to use for tinting buttons in the views.
    ///   - termsOfUseURL: A `URL` linking to the Terms of Use.
    ///   - privacyPolicyURL: A `URL` linking to the Privacy Policy.
    ///   - features: An array of `PurchaseFeature` containing all of the features offered
    ///   by the subscription.
    ///   - tiers: A `PurchaseTiers` object containing the subscription tiers.
    ///   - legacyPurchaseThreshold: An optional `LegacyPurchaseThreshold` object
    ///   containing the build & version numbers when a subscription was first offered. If the app has
    ///   always been subscription-based or users are not grandfathered in, this can be set to `nil`.
    ///   Defaults to `nil`.
    ///   - tipJarTiers: An optional `TipJarTiers` object containing the Tip jar tiers. Defaults
    ///   to `nil`.
    ///   - sharedUserDefaults: The `UserDefaults` storage location so that the subscription
    ///   state can be accessed from widgets. This should be setup using App Groups.
    ///   - purchaseCompletionBlock: An optional action to perform when a purchase is completed.
    ///   Defaults to `nil`.
    ///   - updatedPurchasesCompletionBlock: An optional action to perform when purchases are
    ///   updated. Defaults to `nil`.
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
        legacyPurchaseThreshold: LegacyPurchaseThreshold? = nil,
        tipJarTiers: TipJarTiers? = nil,
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
        self.legacyPurchaseThreshold = legacyPurchaseThreshold
        self.tipJarTiers = tipJarTiers
        self.sharedUserDefaults = sharedUserDefaults
        self.purchaseCompletionBlock = purchaseCompletionBlock
        self.updatedPurchasesCompletionBlock = updatedPurchasesCompletionBlock
    }


    // MARK: - Previews

    public static let example: InAppPurchaseKitConfiguration = {
        let configuration = InAppPurchaseKitConfiguration(
            "My App Pro",
            subtitle: "Unlock all features.",
            appName: "My App",
            imageName: "",
            systemImage: "plus.app",
            tintColor: .green,
            termsOfUseURL: URL(string: "https://example.com/terms-of-use")!,
            privacyPolicyURL: URL(string: "https://example.com/privacy-policy")!,
            features: [.example, .example, .example],
            tiers: .example,
            tipJarTiers: .example,
            sharedUserDefaults: .standard
        ) { product in
            print("Purchased \(product.displayName)")
        } onUpdatedPurchases: {
            print("Updated Purchases")
        }

        return configuration
    }()
}
