//
//  TipJarView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import SwiftUI
import HapticsKit

public struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss

    /// Creates a new `InAppPurchaseKit` object to monitor.
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    /// A `Bool` indicating whether the purchase view should be contained in
    /// its own `NavigationStack`.
    private let includeNavigationStack: Bool

    /// A `Bool` indicating whether the purchase view should be dismissed from
    /// the top toolbar.
    private let includeDismissButton: Bool

    /// A `Bool` indicating whether the purchased message alert should be shown.
    @State private var showingPurchasedMessage: Bool = false
    
    /// Creates a new `TipJarView`.
    /// - Parameters:
    ///   - includeNavigationStack: A `Bool` indicating whether the purchase view should be contained in
    ///   its own `NavigationStack`. Defaults to `true`.
    ///   - includeDismissButton: A `Bool` indicating whether the purchase view should be dismissed from
    ///   the top toolbar. Defaults to `true`.
    public init(
        includeNavigationStack: Bool = true,
        includeDismissButton: Bool = true,
    ) {
        self.includeNavigationStack = includeNavigationStack
        self.includeDismissButton = includeDismissButton
    }

    public var body: some View {
        Group {
            if includeNavigationStack {
                NavigationStack {
                    tipJarView
                        #if os(macOS)
                        .frame(width: 650, height: 500)
                        #endif
                }
            } else {
                tipJarView
            }
        }
        #if !os(tvOS)
        .accentColor(inAppPurchase.configuration.tintColor)
        #endif
        .environment(inAppPurchase)
    }

    private var tipJarView: some View {
        Form {
            Section {
                VStack(spacing: headerSpacing) {
                    AppIconView(
                        named: inAppPurchase.configuration.imageName
                    )

                    Text("Thank you for using \(inAppPurchase.configuration.appName)! If youʼre enjoying the app, please consider supporting it with a tip. Anything you can spare helps me to continue building this and other indie apps!", bundle: .module)
                        #if os(tvOS)
                        .font(.caption)
                        .padding(.horizontal, 200)
                        #elseif os(watchOS)
                        .font(.footnote)
                        #else
                        .font(.callout)
                        #endif
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                #if os(tvOS)
                .padding(.bottom, 32)
                #endif
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
            }

            if let tiers = inAppPurchase.configuration.tipJarTiers?.orderedTiers {
                Section {
                    ForEach(
                        Array(tiers.enumerated()),
                        id: \.0
                    ) { index, tier in
                        TipJarTierButton(
                            tier,
                            imageScale: 1 - (
                                CGFloat(tiers.count - index) * 0.1
                            )
                        )
                    }
                }
            }

            Section {
                #if os(macOS)
                HStack {
                    Text(String(localized: "Terms of Use", bundle: .module))

                    Spacer()

                    TermsPrivacyButton(
                        String(localized: "View Terms of Use…", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )
                }

                HStack {
                    Text(String(localized: "Privacy Policy", bundle: .module))

                    Spacer()

                    TermsPrivacyButton(
                        String(localized: "View Privacy Policy…", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )
                }

                #elseif os(tvOS)
                VStack(spacing: 12) {
                    TermsPrivacyButton(
                        String(localized: "Terms of Use", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )

                    TermsPrivacyButton(
                        String(localized: "Privacy Policy", bundle: .module),
                        url: inAppPurchase.configuration.privacyPolicyURL
                    )

                    Text("Please note that these purchases do not unlock additional features.", bundle: .module)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))

                #else
                TermsPrivacyButton(
                    String(localized: "Terms of Use", bundle: .module),
                    url: inAppPurchase.configuration.termsOfUseURL
                )

                TermsPrivacyButton(
                    String(localized: "Privacy Policy", bundle: .module),
                    url: inAppPurchase.configuration.privacyPolicyURL
                )
                #endif
            } footer: {
                #if !os(tvOS)
                Text("Please note that these purchases do not unlock additional features.", bundle: .module)
                    #if os(macOS)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    #endif
                #endif
            }
        }
        .navigationTitle(String(localized: "Tip Jar", bundle: .module))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        #elseif os(macOS)
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        #endif
        .toolbar {
            #if !os(tvOS)
            if includeDismissButton {
                doneToolbarItem
            }
            #endif
        }
        .alert(String(localized: "Thank You", bundle: .module), isPresented: $showingPurchasedMessage) {
            Button(String(localized: "Continue", bundle: .module), role: .cancel) {}
        } message: {
            Text("Thank you for the tip – it means a lot!", bundle: .module)
        }
        .onChange(of: inAppPurchase.transactionState) { _, transactionState in
            Task {
                await transactionStateUpdated(to: transactionState)
            }
        }
    }

    private var headerSpacing: CGFloat {
        #if os(tvOS)
        return 40
        #else
        return 20
        #endif
    }


    // MARK: - Update

    private func transactionStateUpdated(to transactionState: TransactionState) async {
        switch transactionState {
        case .purchased(let type):
            switch type {
            case .tipJar:
                #if os(iOS)
                HapticsKit.shared.perform(.notification(.success))
                #elseif os(watchOS)
                HapticsKit.shared.perform(.success)
                #endif

                showingPurchasedMessage = true

            default:
                return
            }
        default:
            return
        }
    }


    // MARK: - Toolbar

    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: doneButtonPlacement) {
            DoneToolbarButton {
                dismiss()
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
    let inAppPurchase = InAppPurchaseKit.preview

    TipJarView()
        .environment(inAppPurchase)
}
