//
//  TiersView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 01/02/2024.
//

import SwiftUI

struct TiersView: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    @Binding private var selectedTier: PurchaseTier?
    @Binding private var showingAllTiers: Bool

    init(
        selectedTier: Binding<PurchaseTier?>,
        showingAllTiers: Binding<Bool>
    ) {
        _selectedTier = selectedTier
        _showingAllTiers = showingAllTiers
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: tierSpacing) {
            ForEach(
                Array(inAppPurchase.configuration.tiers.orderedTiers.reversed().enumerated()),
                id: \.0
            ) { _, tier in
                #if os(tvOS) || os(watchOS)
                tierButton(for: tier)
                #else
                if showingAllTiers || inAppPurchase.primaryTier == tier || tier.configuration.alwaysVisible {
                    tierButton(for: tier)
                }
                #endif
            }
        }
    }

    private var tierSpacing: CGFloat {
        #if os(macOS)
        return 8
        #elseif os(tvOS)
        return 24
        #else
        return 12
        #endif
    }

    private func tierButton(
        for tier: PurchaseTier
    ) -> some View {
        TierSelectionButton(
            tier: tier,
            selectedTier: $selectedTier,
            accessoryType: accessoryType(for: tier)
        )
    }

    private func accessoryType(
        for tier: PurchaseTier
    ) -> PurchaseTierAccessoryType? {
        switch tier {
        case .yearly(let configuration):
            if let yearlySaving = inAppPurchase.yearlySaving {
                return .saving(value: yearlySaving)
            } else if inAppPurchase.productsLoadState.isLegacyUser,
                      configuration.legacyConfiguration != nil {
                return .loyalty
            } else {
                return nil
            }
        default:
            if inAppPurchase.productsLoadState.isLegacyUser,
               tier.configuration.legacyConfiguration != nil {
                return .loyalty
            } else {
                return nil
            }
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    TiersView(
        selectedTier: .constant(.yearly(configuration: .example)),
        showingAllTiers: .constant(true)
    )
    .environment(inAppPurchase)
}
