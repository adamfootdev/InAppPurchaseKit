//
//  TiersListView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 01/02/2024.
//

import SwiftUI

struct TiersListView: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    /// The current in-app purchase tier that has been selected in the list.
    @Binding private var selectedTier: PurchaseTier?

    /// A `Bool` indicating whether all in-app purchase options are visible.
    @Binding private var showingAllTiers: Bool
    
    /// Creates a new `TiersListView`.
    /// - Parameters:
    ///   - selectedTier: The current in-app purchase tier that has been selected in the list.
    ///   - showingAllTiers: A `Bool` indicating whether all in-app purchase options are visible.
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
                if showingAllTiers || inAppPurchase.primaryTier == tier || tier.configuration.alwaysVisible {
                    tierButton(for: tier)
                }
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
                      let legacyConfiguration = configuration.legacyConfiguration,
                      legacyConfiguration.visible {
                return .loyalty
            } else {
                return nil
            }
        default:
            if inAppPurchase.productsLoadState.isLegacyUser,
               let legacyConfiguration = tier.configuration.legacyConfiguration,
               legacyConfiguration.visible {
                return .loyalty
            } else {
                return nil
            }
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    TiersListView(
        selectedTier: .constant(.yearly(configuration: .example)),
        showingAllTiers: .constant(true)
    )
    .environment(inAppPurchase)
}
