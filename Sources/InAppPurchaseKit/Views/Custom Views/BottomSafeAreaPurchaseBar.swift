//
//  BottomSafeAreaPurchaseBar.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import SwiftUI

struct BottomSafeAreaPurchaseBar: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    /// The current in-app purchase tier that has been selected in the list.
    @Binding private var selectedTier: PurchaseTier?

    /// A `Bool` indicating whether to ignore the current purchase state. This
    /// is used when a user chooses to change their tier after already purchasing.
    @Binding private var ignorePurchaseState: Bool

    init(
        selectedTier: Binding<PurchaseTier?>,
        ignorePurchaseState: Binding<Bool>
    ) {
        _selectedTier = selectedTier
        _ignorePurchaseState = ignorePurchaseState
    }

    var body: some View {
        if showPurchaseButton {
            if #available(iOS 26.0, *) {
                safeAreaPurchaseButton
            } else {
                VStack(spacing: 16) {
                    Divider()
                    safeAreaPurchaseButton
                }
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(.all)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                }
            }
        }
    }

    private var showPurchaseButton: Bool {
        return (inAppPurchase.purchaseState != .purchased || ignorePurchaseState) && inAppPurchase.configuration.tiers.orderedTiers.count != 1
    }

    private var safeAreaPurchaseButton: some View {
        PurchaseButton(for: $selectedTier)
            .frame(maxWidth: 400)
            .padding(.horizontal, 40)
            .padding(.bottom, 16)
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.configure(with: .example)

    BottomSafeAreaPurchaseBar(
        selectedTier: .constant(nil),
        ignorePurchaseState: .constant(false)
    )
        .environment(inAppPurchase)
}
