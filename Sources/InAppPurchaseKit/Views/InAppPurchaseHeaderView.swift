//
//  InAppPurchaseHeaderView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct InAppPurchaseHeaderView: View {
    private let subtitle: String
    private let configuration: InAppPurchaseKitConfiguration

    init(
        subtitle: String? = nil,
        configuration: InAppPurchaseKitConfiguration
    ) {
        self.subtitle = subtitle ?? configuration.subtitle
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: mainSpacing) {
            Image(
                configuration.imageName,
                bundle: .main
            )
            .resizable()
            .scaledToFill()
            #if os(iOS) || os(macOS) || os(tvOS)
            .clipShape(RoundedRectangle(
                cornerRadius: imageCornerRadius,
                style: .continuous
            ))
            #elseif os(visionOS) || os(watchOS)
            .clipShape(Circle())
            #endif
            .frame(width: imageWidth, height: imageHeight)
            .overlay {
                #if os(iOS) || os(tvOS)
                RoundedRectangle(
                    cornerRadius: imageCornerRadius,
                    style: .continuous
                )
                .stroke(Color.appIconBorder, lineWidth: 1)
                #elseif os(visionOS) || os(watchOS)
                Circle()
                    .stroke(Color.appIconBorder, lineWidth: 1)
                #endif
            }
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text(
                    "Upgrade to \(configuration.title)",
                    bundle: .module
                )
                .font(titleFont)
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(subtitleFont)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
        }
    }

    private var mainSpacing: CGFloat {
        #if os(tvOS)
        return 40
        #else
        return 20
        #endif
    }

    private var titleFont: Font {
        #if os(visionOS)
        return Font.title2
        #elseif os(watchOS)
        return Font.headline
        #else
        return Font.title2.bold()
        #endif
    }

    private var subtitleFont: Font {
        #if os(watchOS)
        return Font.footnote
        #else
        return Font.subheadline
        #endif
    }

    private var imageCornerRadius: CGFloat {
        #if os(tvOS)
        return 32
        #else
        return 16
        #endif
    }

    private var imageWidth: CGFloat {
        #if os(tvOS)
        return 267
        #else
        return 72
        #endif
    }

    private var imageHeight: CGFloat {
        #if os(tvOS)
        return 160
        #else
        return 72
        #endif
    }
}

#Preview {
    InAppPurchaseHeaderView(configuration: .preview)
}
