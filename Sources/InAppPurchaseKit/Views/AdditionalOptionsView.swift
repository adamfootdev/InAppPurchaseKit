//
//  AdditionalOptionsView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct AdditionalOptionsView: View {
    private let configuration: InAppPurchaseKitConfiguration
    private let purchased: Bool

    init(configuration: InAppPurchaseKitConfiguration, purchased: Bool) {
        self.configuration = configuration
        self.purchased = purchased
    }

    var body: some View {
        #if os(macOS)
        ViewThatFits {
            HStack(spacing: 16) {
                additionalOptionsContent(useDivider: false)
            }

            VStack(spacing: 8) {
                additionalOptionsContent(useDivider: false)
            }
        }

        #elseif os(tvOS)
        VStack(spacing: 12) {
            additionalOptionsContent(useDivider: false)
        }
        .foregroundStyle(.secondary)

        #elseif os(watchOS)
        VStack(alignment: .leading, spacing: 16) {
            additionalOptionsContent(useDivider: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        #else
        ViewThatFits {
            HStack(spacing: 12) {
                additionalOptionsContent(useDivider: true)
            }

            VStack(spacing: 12) {
                additionalOptionsContent(useDivider: false)
            }
        }
        #endif
    }

    private func additionalOptionsContent(useDivider: Bool) -> some View {
        Group {
            #if !os(tvOS)
            if purchased == false {
                if #available(iOS 17.0, macOS 14.0, *) {
                    RestoreButton()
                } else {
                    LegacyRestoreButton()
                }

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
//        } else {
//            AdditionalOptionsView(configuration: .preview, purchased: false)
//                .environmentObject(LegacyInAppPurchaseKit.preview)
//        }
//    }
//}
