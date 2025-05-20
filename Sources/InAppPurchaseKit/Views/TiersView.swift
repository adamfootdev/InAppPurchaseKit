//
//  TiersView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 01/02/2024.
//

import SwiftUI

struct TiersView: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    @Binding private var selectedTier: InAppPurchaseTier?
    @Binding private var showingAllTiers: Bool

    init(
        selectedTier: Binding<InAppPurchaseTier?>,
        showingAllTiers: Binding<Bool>
    ) {
        _selectedTier = selectedTier
        _showingAllTiers = showingAllTiers
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: tierSpacing) {
            ForEach(
                Array(inAppPurchase.availableTiers.enumerated()),
                id: \.0
            ) { _, tier in
                #if os(tvOS) || os(watchOS)
                tierButton(for: tier)
                #else
                if showingAllTiers || inAppPurchase.primaryTier == tier || inAppPurchase.configuration.showPrimaryTierOnly == false {
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
        for tier: InAppPurchaseTier
    ) -> some View {
        TierSelectionButton(
            tier: tier,
            selectedTier: $selectedTier,
            accessoryType: accessoryType(for: tier)
        )
    }

    private func accessoryType(
        for tier: InAppPurchaseTier
    ) -> InAppPurchaseTierAccessoryType? {
        switch tier.type {
        case .yearly:
            if let yearlySaving = inAppPurchase.yearlySaving {
                return .saving(value: yearlySaving)
            } else {
                return nil
            }
        case .legacyUserLifetime:
            return .loyalty
        default:
            return nil
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    TiersView(
        selectedTier: .constant(.example),
        showingAllTiers: .constant(true)
    )
    .environment(inAppPurchase)
}
