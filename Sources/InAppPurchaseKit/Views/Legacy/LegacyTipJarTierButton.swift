//
//  LegacyTipJarTierButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import SwiftUI
import StoreKit

#if canImport(HapticsKit)
import HapticsKit
#endif

struct LegacyTipJarTierButton: View {
    @EnvironmentObject private var inAppPurchase: LegacyInAppPurchaseKit

    private let tier: TipJarTier
    private let imageScale: CGFloat

    init(
        _ tier: TipJarTier,
        imageScale: CGFloat = 1
    ) {
        self.tier = tier
        self.imageScale = imageScale
    }

    var body: some View {
        HStack(spacing: 4) {
            Label {
                Text(tier.type.title)
                    #if os(tvOS)
                    .font(.headline)
                    #endif
            } icon: {
                Image(systemName: "heart.fill")
                    #if os(tvOS)
                    .imageScale(.large)
                    #endif
                    .foregroundStyle(.pink)
                    .scaleEffect(imageScale)
            }

            Spacer(minLength: 1)

            Button {
                #if canImport(HapticsKit)
                if inAppPurchase.configuration.enableHapticFeedback {
                    #if os(iOS)
                    HapticsKit.performImpact(.soft, at: 0.6)
                    #elseif os(watchOS)
                    HapticsKit.perform(.click)
                    #endif
                }
                #endif

                if let product {
                    Task {
                        await inAppPurchase.purchase(
                            product,
                            with: nil
                        )
                    }
                }
            } label: {
                if let product {
                    Text(product.displayPrice)
                        #if os(iOS) || os(visionOS)
                        .font(.subheadline.bold())
                        #elseif os(tvOS)
                        .font(.callout)
                        #else
                        .font(.subheadline)
                        #endif
                        #if !os(tvOS) && !os(watchOS)
                        .padding(.horizontal, 8)
                        #endif
                } else {
                    Text(verbatim: "$1.99")
                        .foregroundStyle(Color.clear)
                        #if os(iOS) || os(visionOS)
                        .font(.subheadline.bold())
                        #elseif os(tvOS)
                        .font(.callout)
                        #else
                        .font(.subheadline)
                        #endif
                        #if !os(tvOS) && !os(watchOS)
                        .padding(.horizontal, 8)
                        #endif
                        .accessibilityHidden(true)
                }
            }
            #if !os(tvOS) && !os(watchOS)
            .buttonStyle(.borderedProminent)
            #if !os(macOS)
            .buttonBorderShape(.capsule)
            #endif
            #endif
            #if os(iOS)
            .controlSize(.small)
            #endif
            .disabled(disableButton)
            .overlay {
                if product == nil {
                    ProgressView()
                        #if !os(tvOS) && !os(watchOS)
                        .controlSize(.mini)
                        #endif
                        .padding(.horizontal, 20)
                        .padding(.vertical, 2)
                }
            }
        }
        #if os(tvOS)
        .padding(.vertical)
        #endif
    }

    private var product: Product? {
        inAppPurchase.fetchProduct(for: tier)
    }

    private var disableButton: Bool {
        if product == nil {
            return true
        } else {
            switch inAppPurchase.transactionState {
            case .purchased(let type):
                switch type {
                case .tipJar:
                    return true
                default:
                    return false
                }
            default:
                return false
            }
        }
    }
}

#Preview {
    let inAppPurchase = LegacyInAppPurchaseKit.configure(with: .preview)

    Form {
        LegacyTipJarTierButton(.example)
    }
    #if os(macOS)
    .formStyle(.grouped)
    .frame(width: 500, height: 500)
    #elseif os(visionOS)
    .frame(width: 500, height: 500)
    #endif
    .environmentObject(inAppPurchase)
}
