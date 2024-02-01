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

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
public struct InAppPurchaseView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let embedInNavigationStack: Bool
    @ViewBuilder private let doneButton: (() -> Content)?
    private let doneButtonPlacement: ToolbarItemPlacement

    @State private var showingRedeemSheet: Bool = false
    @State private var showingManageSubscriptionSheet: Bool = false

    #if os(watchOS)
    public init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .cancellationAction,
        doneButton: (() -> Content)? = nil
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = doneButton
        self.doneButtonPlacement = doneButtonPlacement
    }

    #else
    init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .confirmationAction,
        doneButton: (() -> Content)? = nil
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = doneButton
        self.doneButtonPlacement = doneButtonPlacement
    }
    #endif

    public var body: some View {
        Group {
            #if os(macOS) || os(tvOS)
            subscriptionView
            #else
            if embedInNavigationStack {
                NavigationStack {
                    subscriptionView
                }
            } else {
                subscriptionView
            }
            #endif
        }
        .environment(inAppPurchase)
    }

    private var subscriptionView: some View {
        ScrollView {
            VStack(spacing: mainSpacing) {
                AboutInAppPurchaseView(
                    configuration: inAppPurchase.configuration
                )

                #if os(macOS) || os(tvOS) || os(watchOS)
                purchaseOptionsView
                #endif

                AdditionalOptionsView(
                    configuration: inAppPurchase.configuration,
                    purchased: inAppPurchase.purchased
                )
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
        #if os(iOS) || os(visionOS)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                Divider()

                purchaseOptionsView
                    .padding([.horizontal, .bottom])
            }
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .edgesIgnoringSafeArea(.all)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        #elseif os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        #endif
        .toolbar {
            #if os(iOS) || os(visionOS)
            redeemToolbarItem
            #endif

            #if os(iOS) || os(visionOS) || os(watchOS)
            doneToolbarItem
            #endif
        }
        #if os(iOS) || os(visionOS)
        .offerCodeRedemption(isPresented: $showingRedeemSheet)
        .manageSubscriptionsSheet(isPresented: $showingManageSubscriptionSheet)
        #endif
        .onChange(of: inAppPurchase.purchaseState) { _, purchaseState in
            if purchaseState == .purchased {
                #if canImport(HapticsKit)
                if inAppPurchase.configuration.enableHapticFeedback {
                    #if os(iOS)
                    HapticsKit.performNotification(.success)
                    #elseif os(watchOS)
                    HapticsKit.perform(.success)
                    #endif
                }
                #endif

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }
    }

    private var mainSpacing: CGFloat {
        #if os(macOS) || os(watchOS)
        return 28
        #elseif os(tvOS)
        return 60
        #else
        return 40
        #endif
    }

    private var purchaseOptionsView: some View {
        Group {
            if inAppPurchase.purchased {
                #if os(iOS) || os(visionOS)
                VStack(spacing: 20) {
                    SubscribedFooterView()

                    switch inAppPurchase.activeTier?.type {
                    case .weekly, .monthly, .yearly:
                        Button {
                            showingManageSubscriptionSheet.toggle()
                        } label: {
                            Text("Manage Subscription")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                    default:
                        EmptyView()
                    }
                }

                #else
                SubscribedFooterView()
                #endif

            } else {
                PurchaseView(configuration: inAppPurchase.configuration)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: inAppPurchase.purchased)
    }

    #if os(iOS) || os(visionOS)
    private var redeemToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if inAppPurchase.purchased == false {
                Button("Redeem") {
                    showingRedeemSheet.toggle()
                }
            }
        }
    }
    #endif

    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: doneButtonPlacement) {
            if let doneButton {
                doneButton()
            } else {
                Button {
                    dismiss()
                } label: {
                    #if os(watchOS)
                    Label("Done", systemImage: "xmark")
                    #else
                    Text("Done")
                    #endif
                }
            }
        }
    }
}

#if os(watchOS)
extension InAppPurchaseView where Content == EmptyView {
    public init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .cancellationAction
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = nil
        self.doneButtonPlacement = doneButtonPlacement
    }
}

#else
@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
extension InAppPurchaseView where Content == EmptyView {
    public init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .confirmationAction
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = nil
        self.doneButtonPlacement = doneButtonPlacement
    }
}
#endif

//#Preview {
//    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//        InAppPurchaseKit.configure(with: .preview)
//    }
//
//    return Group {
//        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//            InAppPurchaseView()
//        }
//    }
//}
