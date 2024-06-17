//
//  InAppPurchaseView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import SwiftUI
import StoreKit

#if canImport(HapticsKit)
import HapticsKit
#endif

@available(iOS 17.0, macOS 14.4, tvOS 17.0, watchOS 10.0, *)
public struct InAppPurchaseView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let embedInNavigationStack: Bool
    private let purchaseMetadata: [String: Any]?
    private let onPurchaseAction: (@MainActor @Sendable () -> Void)?
    @ViewBuilder private let doneButton: (() -> Content)?
    private let doneButtonPlacement: ToolbarItemPlacement

    @State private var selectedTier: InAppPurchaseTier?
    @State private var showingAllTiers: Bool = false
    
    @State private var showingManageSubscriptionSheet: Bool = false
    @State private var ignorePurchaseState: Bool = false
    @State private var showingSwitchTierMessage: Bool = false

    #if os(watchOS)
    public init(
        embedInNavigationStack: Bool = true,
        purchaseMetadata: [String: Any]? = nil,
        onPurchase onPurchaseAction: (@MainActor @Sendable () -> Void)? = nil,
        doneButtonPlacement: ToolbarItemPlacement = .cancellationAction,
        doneButton: (() -> Content)? = nil
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.purchaseMetadata = purchaseMetadata
        self.onPurchaseAction = onPurchaseAction
        self.doneButton = doneButton
        self.doneButtonPlacement = doneButtonPlacement
    }

    #else
    public init(
        embedInNavigationStack: Bool = true,
        purchaseMetadata: [String: Any]? = nil,
        onPurchase onPurchaseAction: (@MainActor @Sendable () -> Void)? = nil,
        doneButtonPlacement: ToolbarItemPlacement = .confirmationAction,
        doneButton: (() -> Content)? = nil
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.purchaseMetadata = purchaseMetadata
        self.onPurchaseAction = onPurchaseAction
        self.doneButton = doneButton
        self.doneButtonPlacement = doneButtonPlacement
    }
    #endif

    public var body: some View {
        Group {
            if embedInNavigationStack {
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

                    AdditionalOptionsView(
                        configuration: inAppPurchase.configuration
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
        #if os(iOS)
        .safeAreaInset(edge: .bottom) {
            if (inAppPurchase.purchaseState != .purchased || ignorePurchaseState) && inAppPurchase.configuration.showSinglePurchaseMode == false {
                VStack(spacing: 16) {
                    Divider()

                    PurchaseButton(
                        for: $selectedTier,
                        purchaseMetadata: purchaseMetadata,
                        configuration: inAppPurchase.configuration
                    )
                    .padding([.horizontal, .bottom])
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
        .frame(height: 500)
        #endif
        .toolbar {
            #if os(iOS) || os(macOS) || os(visionOS) || os(watchOS)
            if embedInNavigationStack || doneButton != nil {
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
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        #if os(watchOS)
                        .tint(.accentColor)
                        #endif

                    default:
                        EmptyView()
                    }
                }
                #endif

            } else {
                if inAppPurchase.configuration.showSinglePurchaseMode {
                    SinglePurchaseButton(
                        purchaseMetadata: purchaseMetadata,
                        configuration: inAppPurchase.configuration
                    )
                } else {
                    VStack(spacing: 12) {
                        TiersView(
                            selectedTier: $selectedTier,
                            showingAllTiers: $showingAllTiers,
                            purchaseMetadata: purchaseMetadata,
                            configuration: inAppPurchase.configuration
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
                        }
                        #endif
                    }

                    #if os(macOS) || os(visionOS)
                    if inAppPurchase.purchaseState != .purchased || ignorePurchaseState {
                        PurchaseButton(
                            for: $selectedTier,
                            purchaseMetadata: purchaseMetadata,
                            configuration: inAppPurchase.configuration
                        )
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
        guard transactionState == .purchased else {
            return
        }

        #if canImport(HapticsKit)
        if inAppPurchase.configuration.enableHapticFeedback {
            #if os(iOS)
            HapticsKit.performNotification(.success)
            #elseif os(watchOS)
            HapticsKit.perform(.success)
            #endif
        }
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
            if let doneButton {
                doneButton()
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
                .background {
                    #if os(iOS) || os(macOS) || os(visionOS)
                    Button {
                        dismiss()
                    } label: {
                        Text("Close", bundle: .module)
                    }
                    .hidden()
                    .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
        }
    }
}

#if os(watchOS)
@available(watchOS 10.0, *)
extension InAppPurchaseView where Content == EmptyView {
    public init(
        embedInNavigationStack: Bool = true,
        purchaseMetadata: [String: Any]? = nil,
        onPurchase onPurchaseAction: (@MainActor @Sendable () -> Void)? = nil,
        doneButtonPlacement: ToolbarItemPlacement = .cancellationAction
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.purchaseMetadata = purchaseMetadata
        self.onPurchaseAction = onPurchaseAction
        self.doneButton = nil
        self.doneButtonPlacement = doneButtonPlacement
    }
}

#else
@available(iOS 17.0, macOS 14.4, tvOS 17.0, *)
extension InAppPurchaseView where Content == EmptyView {
    public init(
        embedInNavigationStack: Bool = true,
        purchaseMetadata: [String: Any]? = nil,
        onPurchase onPurchaseAction: (@MainActor @Sendable () -> Void)? = nil,
        doneButtonPlacement: ToolbarItemPlacement = .confirmationAction
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.purchaseMetadata = purchaseMetadata
        self.onPurchaseAction = onPurchaseAction
        self.doneButton = nil
        self.doneButtonPlacement = doneButtonPlacement
    }
}
#endif

//#Preview {
//    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//        _ = InAppPurchaseKit.configure(with: .preview)
//    }
//
//    return Group {
//        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//            InAppPurchaseView()
//        }
//    }
//}
