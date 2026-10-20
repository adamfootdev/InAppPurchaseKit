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

    /// The order that content should be displayed in the purchase view.
    private let contentOrder: [InAppPurchaseViewContent]

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
    ///   - contentOrder: The order that content should be displayed in the purchase view.
    ///   Defaults to `InAppPurchaseViewContent.defaultOrder`.
    ///   - onPurchaseAction: An optional action to perform when a transaction is completed. This is separate
    ///   to the action set in `InAppPurchaseKitConfiguration` but both
    ///   will be performed. If an action is set, you will need to also dismiss the view. This
    ///   is handled automatically when no action is set. Defaults to `nil`.
    public init(
        includeNavigationStack: Bool = true,
        includeDismissButton: Bool = true,
        contentOrder: [InAppPurchaseViewContent] = InAppPurchaseViewContent.defaultOrder,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.includeNavigationStack = includeNavigationStack
        self.includeDismissButton = includeDismissButton
        self.contentOrder = contentOrder
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
                    .scrollEdgeEffectHidden(true, for: .bottom)
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
                #if os(iOS) && !targetEnvironment(macCatalyst)
                if #available(iOS 27.1, *) {
                    doneToolbarItem
                        .axisBehavior(.verticalPreferred)
                } else {
                    doneToolbarItem
                }
                #else
                doneToolbarItem
                #endif
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
                ForEach(contentOrder.indices, id: \.self) { index in
                    renderView(for: contentOrder[index])
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

    @ViewBuilder
    private func renderView(for content: InAppPurchaseViewContent) -> some View {
        switch content {
        case .header:
            InAppPurchaseHeaderView(
                configuration: inAppPurchase.configuration
            )
            .frame(maxWidth: .infinity)

        case .tiers:
            TiersView(
                selectedTier: $selectedTier,
                ignorePurchaseState: $ignorePurchaseState
            )

        case .features:
            VStack(spacing: SizingConstants.mainSpacing / 2) {
                Group {
                    Divider()
                    FeaturesView(inAppPurchase.configuration.features)
                    Divider()
                }
            }
            .frame(maxWidth: SizingConstants.mainContentWidth)

        case .additionalOptions:
            AdditionalOptionsView(
                ignorePurchaseState: $ignorePurchaseState
            )

        case .custom(let customContent):
            customContent
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

#Preview("InAppPurchaseView+CustomContent") {
    let inAppPurchase = InAppPurchaseKit.configure(with: .example)

    InAppPurchaseView(
        contentOrder: [
            .header,
            .custom {
                VStack(spacing: 8) {
                    Text("Limited-time discount")
                        .font(.headline)
                    Text("Save 20% with App Store Code XYZ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            },
            .tiers,
            .features,
            .additionalOptions
        ]
    )
    .environment(inAppPurchase)
}
