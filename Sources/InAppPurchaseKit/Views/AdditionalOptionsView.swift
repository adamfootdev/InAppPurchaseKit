//
//  AdditionalOptionsView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI
import StoreKit

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
struct AdditionalOptionsView: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    private let configuration: InAppPurchaseKitConfiguration

    @State private var showingRedeemSheet: Bool = false

    init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        #if os(iOS) || os(visionOS)
        VStack(spacing: 16) {
            if inAppPurchase.purchased == false {
                Button {
                    showingRedeemSheet.toggle()
                } label: {
                    Text("Redeem Code")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                #if os(iOS)
                .tint(.accentColor)
                #endif
                .frame(maxWidth: 400)
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
                additionalOptionsContent(useDivider: false)
            }

            VStack(spacing: 8) {
                additionalOptionsContent(useDivider: false)
            }
        }

        #elseif os(tvOS)
        HStack(spacing: 64) {
            if inAppPurchase.purchased == false {
                RestoreButton()
            }

            VStack(alignment: .leading, spacing: 12) {
                additionalOptionsContent(useDivider: false)
            }
            .foregroundStyle(.secondary)
        }

        #elseif os(watchOS)
        VStack(alignment: .leading, spacing: 16) {
            additionalOptionsContent(useDivider: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        #endif
    }

    private func additionalOptionsContent(useDivider: Bool) -> some View {
        Group {
            #if !os(tvOS)
            if inAppPurchase.purchased == false {
                RestoreButton()

                if useDivider {
                    Divider()
                }
            }
            #endif

            TermsPrivacyButton(
                String(localized: "Terms"),
                url: configuration.termsOfUseURL
            )

            if useDivider {
                Divider()
            }

            TermsPrivacyButton(
                String(localized: "Privacy Policy"),
                url: configuration.privacyPolicyURL
            )
        }
        #if os(iOS) || os(visionOS)
        .font(.subheadline)
        #elseif os(macOS)
        .buttonStyle(.bordered)
        #endif
    }
}

//#Preview {
//    Group {
//        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//            AdditionalOptionsView(configuration: .preview, purchased: false)
//                .environment(InAppPurchaseKit.preview)
//        }
//    }
//}
