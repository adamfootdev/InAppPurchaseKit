//
//  LegacyPurchaseButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

#if canImport(HapticsKit)
import HapticsKit
#endif

struct LegacyPurchaseButton: View {
    @EnvironmentObject private var inAppPurchase: LegacyInAppPurchaseKit

    @Binding private var tier: InAppPurchaseTier?
    private let configuration: InAppPurchaseKitConfiguration

    init(
        for tier: Binding<InAppPurchaseTier?>,
        configuration: InAppPurchaseKitConfiguration
    ) {
        _tier = tier
        self.configuration = configuration
    }

    var body: some View {
        #if os(tvOS) || os(watchOS)
        if inAppPurchase.purchaseState == .purchasing {
            ProgressView()
        } else {
            purchaseButton
        }

        #else
        purchaseButton
        #endif
    }

    private var purchaseButton: some View {
        Button {
            #if canImport(HapticsKit)
            if configuration.enableHapticFeedback {
                #if os(iOS)
                HapticsKit.performSelection()
                #elseif os(watchOS)
                HapticsKit.perform(.click)
                #endif
            }
            #endif

            if let tier, let product = inAppPurchase.fetchProduct(for: tier) {
                Task {
                    await inAppPurchase.purchase(product)
                }
            }
        } label: {
            Text(title)
                #if os(iOS)
                .font(.headline)
                .frame(maxWidth: .infinity)
                #elseif os(macOS)
                .font(.system(.body, weight: .medium))
                .padding(.horizontal, 20)
                #endif
        }
        #if os(iOS) || os(macOS)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        #elseif os(watchOS)
        .tint(.accentColor)
        #endif
        .disabled(inAppPurchase.purchaseState != .pending)
        .overlay {
            if inAppPurchase.purchaseState == .purchasing {
                ProgressView()
                    #if os(macOS)
                    .controlSize(.small)
                    #endif
            }
        }
    }

    private var title: String {
        if let tier {
            switch inAppPurchase.purchaseState {
            case .pending:
                switch tier.type {
                case .weekly, .monthly, .yearly:
                    if let product = inAppPurchase.fetchProduct(for: tier) {
                        if inAppPurchase.introOffer(for: product) == nil {
                            return String(localized: "Redeem Free Trial")
                        } else {
                            if (configuration.tiers.count == 1 && configuration.enableSinglePurchaseMode) {
                                return String(localized: "Subscribe - \(product.displayPrice) / \(tier.type.title.lowercased())")
                            } else {
                                return String(localized: "Subscribe")
                            }
                        }

                    } else {
                        return String(localized: "Subscribe")
                    }

                case .lifetime, .lifetimeExisting:
                    if (configuration.tiers.count == 1 && configuration.enableSinglePurchaseMode),
                       let product = inAppPurchase.fetchProduct(for: tier) {
                        return String(localized: "Purchase - \(product.displayPrice)")
                    } else {
                        return String(localized: "Purchase")
                    }
                }
            default:
                return String(localized: "Purchase")
            }
        } else {
            return String(localized: "Purchase")
        }
    }
}

#Preview {
    LegacyPurchaseButton(for: .constant(.example), configuration: .preview)
        .environmentObject(LegacyInAppPurchaseKit.preview)
}
