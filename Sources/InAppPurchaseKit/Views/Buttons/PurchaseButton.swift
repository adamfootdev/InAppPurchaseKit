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

    @Binding private var tier: InAppPurchaseTier?

    init(for tier: Binding<InAppPurchaseTier?>) {
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
            inAppPurchase.configuration.haptics.perform(.selection)
            #elseif os(watchOS)
            inAppPurchase.configuration.haptics.perform(.click)
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
                .frame(maxWidth: 280)
                #elseif os(macOS)
                .font(.system(.body, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(maxWidth: 160)
                #elseif os(tvOS)
                .frame(maxWidth: 400)
                #elseif os(visionOS)
                .frame(maxWidth: 280)
                #endif
        }
        #if os(iOS) || os(macOS)
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
            switch tier.type {
            case .weekly, .monthly, .yearly:
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

            case .lifetime, .legacyUserLifetime:
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
        for: .constant(.example)
    )
    .environment(inAppPurchase)
}
