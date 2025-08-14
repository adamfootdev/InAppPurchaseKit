//
//  AdditionalOptionsView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI
import StoreKit

struct AdditionalOptionsView: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    @Binding private var ignorePurchaseState: Bool

    @State private var showingRedeemSheet: Bool = false
    @State private var showingTipJarSheet: Bool = false

    init(ignorePurchaseState: Binding<Bool>) {
        _ignorePurchaseState = ignorePurchaseState
    }

    var body: some View {
        #if os(macOS)
        if #available(macOS 15.0, *) {
            additionalOptionsView
                .offerCodeRedemption(isPresented: $showingRedeemSheet)
        } else {
            additionalOptionsView
        }
        #else
        additionalOptionsView
        #endif
    }

    private var additionalOptionsView: some View {
        Group {
            #if os(iOS) || os(visionOS)
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    if inAppPurchase.purchaseState != .purchased || ignorePurchaseState {
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
                        .tint(inAppPurchase.configuration.tintColor)
                        #endif
                    }

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
                        .tint(inAppPurchase.configuration.tintColor)
                        #endif
                    }

                }

                ViewThatFits {
                    HStack(spacing: 12) {
                        additionalOptionsContent(useDivider: true)
                    }

                    VStack(spacing: 12) {
                        additionalOptionsContent(useDivider: false)
                    }
                }
            }
            .offerCodeRedemption(isPresented: $showingRedeemSheet)

            #elseif os(macOS)
            ViewThatFits {
                HStack(spacing: 16) {
                    if inAppPurchase.purchaseState != .purchased || ignorePurchaseState {
                        if #available(macOS 15.0, *) {
                            Button {
                                showingRedeemSheet = true
                            } label: {
                                Text("Redeem Code", bundle: .module)
                            }
                        }
                    }

                    additionalOptionsContent(useDivider: false)
                }

                VStack(spacing: 8) {
                    if inAppPurchase.purchaseState != .purchased || ignorePurchaseState {
                        if #available(macOS 15.0, *) {
                            Button {
                                showingRedeemSheet = true
                            } label: {
                                Text("Redeem Code", bundle: .module)
                            }
                        }
                    }

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
                        RestoreButton()
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
            #endif
        }
        #if os(tvOS)
        .fullScreenCover(isPresented: $showingTipJarSheet) {
            TipJarView(includeNavigationStack: true)
                .background(Material.regular)
                .environment(inAppPurchase)
        }
        #else
        .sheet(isPresented: $showingTipJarSheet) {
            TipJarView(includeNavigationStack: true)
                .environment(inAppPurchase)
        }
        #endif
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
                RestoreButton()

                if useDivider {
                    Divider()
                }
            }
            #endif

            Group {
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
        }
        #if os(iOS) || os(visionOS)
        .font(.subheadline)
        #elseif os(macOS)
        .buttonStyle(.bordered)
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    VStack {
        Spacer()
            .frame(maxHeight: .infinity)
            .layoutPriority(100)

        AdditionalOptionsView(ignorePurchaseState: .constant(false))
    }
    .environment(inAppPurchase)
}
