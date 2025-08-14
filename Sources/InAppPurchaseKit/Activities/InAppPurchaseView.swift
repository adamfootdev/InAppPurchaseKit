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

    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let includeNavigationStack: Bool
    private let includeDismissButton: Bool
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var selectedTier: InAppPurchaseTier?
    @State private var showingAllTiers: Bool = false
    
    @State private var showingManageSubscriptionSheet: Bool = false
    @State private var ignorePurchaseState: Bool = false
    @State private var showingSwitchTierMessage: Bool = false

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
                    embeddedSubscriptionView
                }
            } else {
                subscriptionView
            }
        }
        .environment(inAppPurchase)
    }

    @ViewBuilder
    private var embeddedSubscriptionView: some View {
        #if os(macOS)
        subscriptionView
            .frame(width: 650, height: 500)
        #else
        subscriptionView
        #endif
    }

    private var subscriptionView: some View {
        ScrollView {
            VStack(spacing: mainSpacing) {
                InAppPurchaseHeaderView(
                    configuration: inAppPurchase.configuration
                )
                .frame(maxWidth: .infinity)

                tiersView

                VStack(spacing: mainSpacing / 2) {
                    Divider()
                        .frame(maxWidth: mainWidth)

                    featuresView
                        .frame(maxWidth: mainWidth)

                    Divider()
                        .frame(maxWidth: mainWidth)

                    AdditionalOptionsView(ignorePurchaseState: $ignorePurchaseState)
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
        #if os(iOS)
        .safeAreaInset(edge: .bottom) {
            if (inAppPurchase.purchaseState != .purchased || ignorePurchaseState) && inAppPurchase.configuration.showSinglePurchaseMode == false {
                VStack(spacing: 16) {
                    Divider()

                    PurchaseButton(for: $selectedTier)
                        .frame(maxWidth: 400)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 16)
                }
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .edgesIgnoringSafeArea(.all)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        #elseif os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
        .toolbar {
            #if os(iOS) || os(macOS) || os(visionOS) || os(watchOS)
            if includeDismissButton {
                doneToolbarItem
            }
            #endif
        }
        .onAppear {
            configureInitialTier()
        }
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
        .onChange(of: inAppPurchase.transactionState) { _, transactionState in
            Task {
                await transactionStateUpdated(to: transactionState)
            }
        }
        #if !os(tvOS)
        .accentColor(inAppPurchase.configuration.tintColor)
        #endif
    }

    private var mainSpacing: CGFloat {
        #if os(macOS) || os(watchOS)
        return 20
        #elseif os(tvOS)
        return 40
        #else
        return 32
        #endif
    }

    private var tiersView: some View {
        Group {
            if inAppPurchase.purchaseState == .purchased && ignorePurchaseState == false {
                #if os(iOS) || os(visionOS)
                VStack(spacing: 20) {
                    SubscribedFooterView()

                    switch inAppPurchase.activeTier?.type {
                    case .weekly, .monthly, .yearly:
                        VStack(spacing: 8) {
                            Button {
                                showingManageSubscriptionSheet = true
                            } label: {
                                Text("Manage Subscription", bundle: .module)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)

                            Button {
                                showingSwitchTierMessage = true
                            } label: {
                                Text("Switch Tier", bundle: .module)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }

                    default:
                        EmptyView()
                    }
                }

                #else
                VStack(spacing: 20) {
                    SubscribedFooterView()

                    switch inAppPurchase.activeTier?.type {
                    case .weekly, .monthly, .yearly:
                        Button {
                            showingSwitchTierMessage = true
                        } label: {
                            Text("Switch Tier", bundle: .module)
                                #if !os(macOS)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                #endif
                        }
                        #if os(watchOS)
                        .tint(inAppPurchase.configuration.tintColor)
                        #endif

                    default:
                        EmptyView()
                    }
                }
                #endif

            } else {
                if inAppPurchase.configuration.showSinglePurchaseMode {
                    SinglePurchaseButton()
                } else {
                    VStack(spacing: 12) {
                        TiersView(
                            selectedTier: $selectedTier,
                            showingAllTiers: $showingAllTiers
                        )

                        #if !os(tvOS) && !os(watchOS)
                        if inAppPurchase.availableTiers.count > 1 && inAppPurchase.configuration.showPrimaryTierOnly {
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
                        #endif
                    }

                    #if os(macOS) || os(visionOS)
                    if inAppPurchase.purchaseState != .purchased || ignorePurchaseState {
                        PurchaseButton(for: $selectedTier)
                    }
                    #endif
                }
            }
        }
        .frame(maxWidth: mainWidth)
        .animation(
            .easeInOut(duration: 0.5),
            value: inAppPurchase.purchaseState
        )
    }


    // MARK: - Features

    private var featuresView: some View {
        VStack(spacing: mainSpacing / 2) {
            Text("Whatʼs Included", bundle: .module)
                .font(featuresTitleFont)
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            FeaturesListView(inAppPurchase.configuration.features)
        }
        .padding(.vertical, 8)
    }

    private var featuresTitleFont: Font {
        #if os(visionOS)
        return Font.title3
        #else
        return Font.title3.bold()
        #endif
    }


    // MARK: - Configuration

    private func configureInitialTier() {
        guard selectedTier == nil else { return }
        selectedTier = inAppPurchase.primaryTier
    }

    private var mainWidth: CGFloat {
        #if os(tvOS)
        return 800
        #else
        return 400
        #endif
    }


    // MARK: - Update

    private func transactionStateUpdated(to transactionState: TransactionState) async {
        switch transactionState {
        case .purchased(let type):
            switch type {
            case .subscription:
                break
            default:
                return
            }
        default:
            return
        }

        #if os(iOS)
        inAppPurchase.configuration.haptics.perform(.notification(.success))
        #elseif os(watchOS)
        inAppPurchase.configuration.haptics.perform(.success)
        #endif

        try? await Task.sleep(for: .seconds(1.0))

        if let onPurchaseAction {
            onPurchaseAction()
        } else {
            dismiss()
        }
    }


    // MARK: - Toolbar

    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: doneButtonPlacement) {
            doneToolbarButton
                #if os(iOS) || os(macOS) || os(visionOS)
                .background {
                    Button {
                        dismiss()
                    } label: {
                        Label {
                            Text("Close", bundle: .module)
                        } icon: {
                            Image(systemName: "xmark")
                        }
                    }
                    .hidden()
                    .keyboardShortcut(.cancelAction)
                }
                #endif
        }
    }

    @ViewBuilder
    private var doneToolbarButton: some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
            Button(role: .close) {
                dismiss()
            } label: {
                #if os(macOS)
                Text("Done", bundle: .module)
                #else
                Label {
                    Text("Done", bundle: .module)
                } icon: {
                    Image(systemName: "xmark")
                }
                #endif
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif

        } else {
            Group {
                #if os(iOS)
                DismissButton {
                    dismiss()
                }
                #else
                Button {
                    dismiss()
                } label: {
                    #if os(visionOS) || os(watchOS)
                    Label {
                        Text("Done", bundle: .module)
                    } icon: {
                        Image(systemName: "xmark")
                    }
                    #else
                    Text("Done", bundle: .module)
                    #endif
                }
                #if os(visionOS)
                .buttonBorderShape(.circle)
                #endif
                #endif
            }
        }
    }

    private var doneButtonPlacement: ToolbarItemPlacement {
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
    let inAppPurchase = InAppPurchaseKit.configure(with: .preview)

    InAppPurchaseView()
        .environment(inAppPurchase)
}
