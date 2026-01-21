//
//  TiersView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import SwiftUI

struct TiersView: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    /// The current in-app purchase tier that has been selected in the list.
    @Binding private var selectedTier: PurchaseTier?

    /// A `Bool` indicating whether to ignore the current purchase state. This
    /// is used when a user chooses to change their tier after already purchasing.
    @Binding private var ignorePurchaseState: Bool

    /// A `Bool` indicating whether all in-app purchase options are visible.
    @State private var showingAllTiers: Bool = false

    /// A `Bool` indicating whether the sheet to manage an active subscription
    /// is visible.
    @State private var showingManageSubscriptionSheet: Bool = false

    /// A `Bool` indicating whether an alert is showing to ask the user if they
    /// would like to change their active tier.
    @State private var showingSwitchTierMessage: Bool = false
    
    /// Creates a new `TiersView`.
    /// - Parameters:
    ///   - selectedTier: The current in-app purchase tier that has been selected in the list.
    ///   - ignorePurchaseState: A `Bool` indicating whether to ignore the current purchase state. This
    ///   is used when a user chooses to change their tier after already purchasing.
    init(
        selectedTier: Binding<PurchaseTier?>,
        ignorePurchaseState: Binding<Bool>
    ) {
        _selectedTier = selectedTier
        _ignorePurchaseState = ignorePurchaseState
    }

    var body: some View {
        tiersList
            .frame(maxWidth: SizingConstants.mainContentWidth)
            .animation(
                .easeInOut(duration: 0.5),
                value: inAppPurchase.purchaseState
            )
            #if os(iOS) || os(visionOS)
            .manageSubscriptionsSheet(isPresented: $showingManageSubscriptionSheet)
            #endif
            .alert(String(localized: "Switch Tier", bundle: .module), isPresented: $showingSwitchTierMessage) {
                Button(String(localized: "Cancel", bundle: .module), role: .cancel) {}

                Button(String(localized: "Switch", bundle: .module)) {
                    ignorePurchaseState = true
                }
            } message: {
                Text("If you currently have an active subscription or free trial running, please remember to cancel it if switching to a lifetime tier.", bundle: .module)
            }
    }

    @ViewBuilder
    private var tiersList: some View {
        if inAppPurchase.purchaseState == .purchased && ignorePurchaseState == false {
            VStack(spacing: 20) {
                SubscribedFooterView()

                switch inAppPurchase.activeTier {
                case .weekly(_), .monthly(_), .yearly(_):
                    VStack(spacing: 8) {
                        #if os(iOS) || os(visionOS)
                        manageSubscriptionButton
                        #endif

                        switchTierButton
                    }
                default:
                    EmptyView()
                }
            }
        } else {
            if inAppPurchase.configuration.tiers.orderedTiers.count == 1 {
                SinglePurchaseButton()
            } else {
                VStack(spacing: tiersListSpacing) {
                    TiersListView(
                        selectedTier: $selectedTier,
                        showingAllTiers: $showingAllTiers
                    )

                    #if !os(watchOS)
                    if inAppPurchase.configuration.tiers.orderedTiers.count > 1 && (inAppPurchase.alwaysVisibleTiers.count != inAppPurchase.configuration.tiers.orderedTiers.count) {
                        toggleOptionsButton
                    }
                    #endif
                }

                #if os(macOS) || os(visionOS)
                if inAppPurchase.purchaseState != .purchased || ignorePurchaseState {
                    PurchaseButton(for: $selectedTier)
                        #if os(visionOS)
                        .frame(maxWidth: 280)
                        #endif
                }
                #endif
            }
        }
    }

    private var tiersListSpacing: CGFloat {
        #if os(tvOS)
        return 28
        #else
        return 12
        #endif
    }

    private var manageSubscriptionButton: some View {
        Button {
            showingManageSubscriptionSheet = true
        } label: {
            Text("Manage Subscription", bundle: .module)
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    private var switchTierButton: some View {
        Button {
            showingSwitchTierMessage = true
        } label: {
            Text("Switch Tier", bundle: .module)
                #if !os(macOS)
                .font(.headline)
                .frame(maxWidth: .infinity)
                #endif
        }
        #if os(iOS) || os(visionOS)
        .buttonStyle(.bordered)
        .controlSize(.large)
        #elseif os(watchOS)
        .tint(inAppPurchase.configuration.tintColor)
        #endif
    }

    private var toggleOptionsButton: some View {
        Button {
            withAnimation {
                showingAllTiers.toggle()
                selectedTier = inAppPurchase.primaryTier
            }
        } label: {
            Group {
                if showingAllTiers {
                    Text("Hide Options")
                } else {
                    Text("Show All Options")
                }
            }
            .font(.subheadline)
        }
        #if os(iOS) || os(macOS)
        .tint(inAppPurchase.configuration.tintColor)
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.configure(with: .example)

    TiersView(
        selectedTier: .constant(nil),
        ignorePurchaseState: .constant(false)
    )
    .environment(inAppPurchase)
}
