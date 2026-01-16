//
//  InAppPurchaseView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import SwiftUI
import StoreKit
import HapticsKit

public struct InAppPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// Creates a new `InAppPurchaseKit` object to monitor.
    @State private var inAppPurchase: InAppPurchaseKit = .shared
    
    /// A `Bool` indicating whether the purchase view should be contained in
    /// its own `NavigationStack`.
    private let includeNavigationStack: Bool
    
    /// A `Bool` indicating whether the purchase view should be dismissed from
    /// the top toolbar.
    private let includeDismissButton: Bool

    /// An optional action to perform when a transaction is completed. This is separate
    /// to the action set in `InAppPurchaseKitConfiguration` but both
    /// will be performed. If an action is set, you will need to also dismiss the view. This
    /// is handled automatically when no action is set.
    private let onPurchaseAction: (@Sendable () -> Void)?
    
    /// The current in-app purchase tier that has been selected in the list.
    @State private var selectedTier: PurchaseTier?

    /// A `Bool` indicating whether to ignore the current purchase state. This
    /// is used when a user chooses to change their tier after already purchasing.
    @State private var ignorePurchaseState: Bool = false
    
    /// Creates a new `InAppPurchaseView`.
    /// - Parameters:
    ///   - includeNavigationStack: A `Bool` indicating whether the purchase view should be contained in
    ///   its own `NavigationStack`. Defaults to `true`.
    ///   - includeDismissButton: A `Bool` indicating whether the purchase view should be dismissed from
    ///   the top toolbar. Defaults to `true`.
    ///   - onPurchaseAction: An optional action to perform when a transaction is completed. This is separate
    ///   to the action set in `InAppPurchaseKitConfiguration` but both
    ///   will be performed. If an action is set, you will need to also dismiss the view. This
    ///   is handled automatically when no action is set. Defaults to `nil`.
    public init(
        includeNavigationStack: Bool = true,
        includeDismissButton: Bool = true,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.includeNavigationStack = includeNavigationStack
        self.includeDismissButton = includeDismissButton
        self.onPurchaseAction = onPurchaseAction
    }

    public var body: some View {
        Group {
            if includeNavigationStack {
                NavigationStack {
                    subscriptionView
                        #if os(macOS)
                        .frame(width: 650, height: 500)
                        #endif
                }
            } else {
                subscriptionView
            }
        }
        .environment(inAppPurchase)
    }

    private var subscriptionView: some View {
        Group {
            #if os(iOS)
            if #available(iOS 26.0, *) {
                subscriptionViewContents
                    .safeAreaBar(edge: .bottom) {
                        BottomSafeAreaPurchaseBar(
                            selectedTier: $selectedTier,
                            ignorePurchaseState: $ignorePurchaseState
                        )
                    }
            } else {
                subscriptionViewContents
                    .safeAreaInset(edge: .bottom) {
                        BottomSafeAreaPurchaseBar(
                            selectedTier: $selectedTier,
                            ignorePurchaseState: $ignorePurchaseState
                        )
                    }
            }
            #else
            subscriptionViewContents
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        #endif
        .toolbar {
            #if !os(tvOS)
            if includeDismissButton {
                doneToolbarItem
            }
            #endif
        }
        #if !os(tvOS)
        .accentColor(inAppPurchase.configuration.tintColor)
        #endif
        .onAppear {
            guard selectedTier == nil else { return }
            selectedTier = inAppPurchase.primaryTier
        }
        .onChange(of: inAppPurchase.transactionState) { _, transactionState in
            Task {
                await transactionStateUpdated(to: transactionState)
            }
        }
    }

    private var subscriptionViewContents: some View {
        ScrollView {
            VStack(spacing: SizingConstants.mainSpacing) {
                InAppPurchaseHeaderView(
                    configuration: inAppPurchase.configuration
                )
                .frame(maxWidth: .infinity)

                TiersView(
                    selectedTier: $selectedTier,
                    ignorePurchaseState: $ignorePurchaseState
                )

                VStack(spacing: SizingConstants.mainSpacing / 2) {
                    Group {
                        Divider()
                        FeaturesView(inAppPurchase.configuration.features)
                        Divider()
                    }
                    .frame(maxWidth: SizingConstants.mainContentWidth)

                    AdditionalOptionsView(
                        ignorePurchaseState: $ignorePurchaseState
                    )
                }
            }
            .frame(maxWidth: .infinity)
            #if os(iOS) || os(visionOS)
            .padding([.horizontal, .bottom])
            .padding(.top, 8)
            #elseif os(macOS)
            .padding(20)
            #elseif os(tvOS) || os(watchOS)
            .padding()
            #endif
        }
    }


    // MARK: - Update

    private func transactionStateUpdated(to transactionState: TransactionState) async {
        switch transactionState {
        case .purchased(let type):
            switch type {
            case .subscription:
                #if os(iOS)
                HapticsKit.shared.perform(.notification(.success))
                #elseif os(watchOS)
                HapticsKit.shared.perform(.success)
                #endif

                try? await Task.sleep(for: .seconds(1.0))

                if let onPurchaseAction {
                    onPurchaseAction()
                } else {
                    dismiss()
                }

            default:
                return
            }
        default:
            return
        }
    }


    // MARK: - Toolbar

    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: doneToolbarItemPlacement) {
            DoneToolbarButton {
                dismiss()
            }
        }
    }

    private var doneToolbarItemPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .confirmationAction
        #elseif os(watchOS)
        return .cancellationAction
        #else
        return .topBarTrailing
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.configure(with: .example)

    InAppPurchaseView()
        .environment(inAppPurchase)
}
