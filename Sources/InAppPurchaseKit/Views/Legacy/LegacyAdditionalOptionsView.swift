//
//  LegacyAdditionalOptionsView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI
import StoreKit

struct LegacyAdditionalOptionsView: View {
    @EnvironmentObject private var inAppPurchase: LegacyInAppPurchaseKit

    @State private var showingRedeemSheet: Bool = false
    @State private var showingTipJarSheet: Bool = false

    var body: some View {
        #if os(iOS) || os(visionOS)
        if #available(iOS 16.0, *) {
            additionalOptionsView
                .offerCodeRedemption(isPresented: $showingRedeemSheet)
        } else {
            additionalOptionsView
        }

        #else
        additionalOptionsView
        #endif
    }

    @ViewBuilder
    private var additionalOptionsView: some View {
        Group {
            #if os(iOS) || os(visionOS)
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    #if !targetEnvironment(macCatalyst)
                    if #available(iOS 16.0, *) {
                        if inAppPurchase.purchaseState != .purchased {
                            Button {
                                showingRedeemSheet = true
                            } label: {
                                Text("Redeem Code", bundle: .module)
                                    #if os(iOS)
                                    .font(.headline)
                                    #endif
                                    .frame(maxWidth: 280)
                            }
                            #if os(iOS)
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .tint(.accentColor)
                            #endif
                        }
                    }
                    #endif

                    if inAppPurchase.configuration.sortedTipJarTiers.isEmpty == false {
                        Button {
                            showingTipJarSheet = true
                        } label: {
                            Text("Tip Jar", bundle: .module)
                                #if os(iOS)
                                .font(.headline)
                                #endif
                                .frame(maxWidth: 280)
                        }
                        #if os(iOS)
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .tint(.accentColor)
                        #endif
                    }
                }

                if #available(iOS 16.0, *) {
                    ViewThatFits {
                        HStack(spacing: 12) {
                            additionalOptionsContent(useDivider: true)
                        }

                        VStack(spacing: 12) {
                            additionalOptionsContent(useDivider: false)
                        }
                    }

                } else {
                    HStack(spacing: 12) {
                        additionalOptionsContent(useDivider: true)
                    }
                }
            }

            #elseif os(macOS)
            ViewThatFits {
                HStack(spacing: 16) {
                    additionalOptionsContent(useDivider: false)
                }

                VStack(spacing: 8) {
                    additionalOptionsContent(useDivider: false)
                }
            }

            #elseif os(tvOS)
            HStack(spacing: 64) {
                HStack(spacing: 32) {
                    if inAppPurchase.configuration.sortedTipJarTiers.isEmpty == false {
                        Button {
                            showingTipJarSheet = true
                        } label: {
                            Text("Tip Jar", bundle: .module)
                        }
                    }

                    if inAppPurchase.purchaseState != .purchased {
                        LegacyRestoreButton()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    additionalOptionsContent(useDivider: false)
                }
                .foregroundStyle(Color.secondary)
            }

            #elseif os(watchOS)
            VStack(alignment: .leading, spacing: 16) {
                additionalOptionsContent(useDivider: false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            #endif
        }
        .sheet(isPresented: $showingTipJarSheet) {
            LegacyTipJarView(embedInNavigationStack: true)
                .accentColor(inAppPurchase.configuration.tintColor)
                .environmentObject(inAppPurchase)
        }
    }

    private func additionalOptionsContent(useDivider: Bool) -> some View {
        Group {
            #if os(macOS) || os(watchOS)
            if inAppPurchase.configuration.sortedTipJarTiers.isEmpty == false {
                Button {
                    showingTipJarSheet = true
                } label: {
                    Text("Tip Jar", bundle: .module)
                }
                
                if useDivider {
                    Divider()
                }
            }
            #endif

            #if !os(tvOS)
            if inAppPurchase.purchaseState != .purchased {
                LegacyRestoreButton()

                if useDivider {
                    Divider()
                }
            }
            #endif

            TermsPrivacyButton(
                String(localized: "Terms of Use", bundle: .module),
                url: inAppPurchase.configuration.termsOfUseURL
            )

            if useDivider {
                Divider()
            }

            TermsPrivacyButton(
                String(localized: "Privacy Policy", bundle: .module),
                url: inAppPurchase.configuration.privacyPolicyURL
            )
        }
        #if os(iOS) || os(visionOS)
        .font(.subheadline)
        #elseif os(macOS)
        .buttonStyle(.bordered)
        #endif
    }
}

#Preview {
    LegacyAdditionalOptionsView()
        .environmentObject(LegacyInAppPurchaseKit.preview)
}
