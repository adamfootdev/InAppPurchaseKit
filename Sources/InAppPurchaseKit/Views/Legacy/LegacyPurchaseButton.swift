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
                .frame(maxWidth: 280)
                #elseif os(macOS)
                .font(.system(.body, weight: .medium))
                .padding(.horizontal, 20)
                .frame(maxWidth: 160)
                #elseif os(tvOS)
                .frame(maxWidth: 400)
                #elseif os(visionOS)
                .frame(maxWidth: 280)
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
                    if let product = inAppPurchase.fetchProduct(for: tier),
                       inAppPurchase.introOffer(for: product) == nil {
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

                case .lifetime, .lifetimeExisting:
                    return String(
                        localized: "Purchase",
                        bundle: .module
                    )
                }
            default:
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
    LegacyPurchaseButton(for: .constant(.example), configuration: .preview)
        .environmentObject(LegacyInAppPurchaseKit.preview)
}
