//
//  SinglePurchaseButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/02/2024.
//

import SwiftUI

struct SinglePurchaseButton: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    var body: some View {
        VStack(spacing: SizingConstants.purchaseButtonSpacing) {
            tierDetailsView
                .frame(maxWidth: .infinity, alignment: .leading)

            if let tier {
                PurchaseButton(for: .constant(tier))
                    #if os(iOS) || os(visionOS)
                    .frame(maxWidth: 280)
                    #endif
            }
        }
    }


    // MARK: - Details

    var tier: PurchaseTier? {
        inAppPurchase.primaryTier
    }

    @ViewBuilder
    private var tierDetailsView: some View {
        Group {
            if let tier, inAppPurchase.fetchProduct(for: tier) != nil {
                Text(inAppPurchase.fetchTierSubtitle(for: tier))
                    .font(subtitleFont)
                    .multilineTextAlignment(.center)

            } else {
                HStack {
                    ProgressView()
                        #if !os(tvOS)
                        .controlSize(.small)
                        #endif
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var subtitleFont: Font {
        #if os(tvOS)
        return Font.subheadline
        #elseif os(watchOS)
        return Font.subheadline
        #else
        return Font.callout.bold()
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    SinglePurchaseButton()
        .environment(inAppPurchase)
}
