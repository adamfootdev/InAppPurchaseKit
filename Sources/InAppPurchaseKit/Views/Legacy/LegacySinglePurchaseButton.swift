//
//  LegacySinglePurchaseButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/02/2024.
//

import SwiftUI

#if canImport(HapticsKit)
import HapticsKit
#endif

struct LegacySinglePurchaseButton: View {
    @EnvironmentObject private var inAppPurchase: LegacyInAppPurchaseKit

    private let purchaseMetadata: [String: String]?
    private let configuration: InAppPurchaseKitConfiguration

    init(
        purchaseMetadata: [String: String]?,
        configuration: InAppPurchaseKitConfiguration
    ) {
        self.purchaseMetadata = purchaseMetadata
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: mainSpacing) {
            tierDetailsView
                .frame(maxWidth: .infinity, alignment: .leading)

            if let tier {
                LegacyPurchaseButton(
                    for: .constant(tier),
                    purchaseMetadata: purchaseMetadata,
                    configuration: configuration
                )
            }
        }
    }

    private var mainSpacing: CGFloat {
        #if os(macOS) || os(watchOS)
        return 8
        #elseif os(tvOS)
        return 20
        #else
        return 12
        #endif
    }


    // MARK: - Details

    var tier: InAppPurchaseTier? {
        inAppPurchase.primaryTier
    }

    @ViewBuilder private var tierDetailsView: some View {
        Group {
            if let tier, inAppPurchase.fetchProduct(for: tier) != nil {
                Text(inAppPurchase.fetchTierSubtitle(for: tier))
                    .font(subtitleFont)
                    .multilineTextAlignment(.center)

            } else {
                HStack {
                    if #available(watchOS 9.0, *) {
                        ProgressView()
                            #if !os(tvOS)
                            .controlSize(.small)
                            #endif
                    } else {
                        ProgressView()
                    }
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
    LegacySinglePurchaseButton(
        purchaseMetadata: nil,
        configuration: .preview
    )
    .environmentObject(LegacyInAppPurchaseKit.preview)
}
