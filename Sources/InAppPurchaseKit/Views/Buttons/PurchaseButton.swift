//
//  PurchaseButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI
import HapticsKit

struct PurchaseButton: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase
    
    /// The current selected tier.
    @Binding private var tier: PurchaseTier?
    
    /// Creates a new `PurchaseButton`
    /// - Parameter tier: The current selected tier.
    init(for tier: Binding<PurchaseTier?>) {
        _tier = tier
    }

    var body: some View {
        #if os(tvOS) || os(watchOS)
        if inAppPurchase.transactionState == .purchasing {
            ProgressView()
        } else {
            purchaseButton
        }

        #elseif os(iOS) || os(macOS)
        if #available(iOS 26.0, macOS 26.0, *) {
            purchaseButton
                .buttonStyle(.glassProminent)
        } else {
            purchaseButton
                .buttonStyle(.borderedProminent)
        }
        #else
        purchaseButton
        #endif
    }

    private var purchaseButton: some View {
        Button {
            #if os(iOS)
            HapticsKit.shared.perform(.selection)
            #elseif os(watchOS)
            HapticsKit.shared.perform(.click)
            #endif

            if let tier,
                let product = inAppPurchase.fetchProduct(for: tier) {
                Task {
                    await inAppPurchase.purchase(product)
                }
            }
        } label: {
            Text(title)
                #if os(iOS)
                .font(.headline)
                .frame(maxWidth: 400)
                #elseif os(macOS)
                .font(.system(.body, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(maxWidth: 160)
                #elseif os(tvOS)
                .frame(maxWidth: 400)
                #elseif os(visionOS)
                .frame(maxWidth: 400)
                #endif
        }
        #if os(iOS)
        .controlSize(.extraLarge)
        .tint(inAppPurchase.configuration.tintColor)
        #elseif os(macOS)
        .controlSize(.large)
        .tint(inAppPurchase.configuration.tintColor)
        #elseif os(watchOS)
        .tint(inAppPurchase.configuration.tintColor)
        #endif
        .disabled(inAppPurchase.transactionState != .pending)
        .overlay {
            if inAppPurchase.transactionState == .purchasing {
                ProgressView()
                    #if os(macOS)
                    .controlSize(.small)
                    #endif
            }
        }
    }

    private var title: String {
        if let tier {
            switch tier {
            case .weekly(_), .monthly(_), .yearly(_):
                if let product = inAppPurchase.fetchProduct(for: tier),
                   inAppPurchase.introOffer(for: product) != nil {
                    return String(
                        localized: "Redeem Free Trial",
                        bundle: .module
                    )
                } else {
                    return String(
                        localized: "Subscribe",
                        bundle: .module
                    )
                }

            case .lifetime(_):
                return String(
                    localized: "Purchase",
                    bundle: .module
                )
            }
        } else {
            return String(
                localized: "Purchase",
                bundle: .module
            )
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    PurchaseButton(
        for: .constant(.yearly(configuration: .example))
    )
    .environment(inAppPurchase)
}
