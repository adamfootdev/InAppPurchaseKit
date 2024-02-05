//
//  InAppPurchaseHeaderView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct InAppPurchaseHeaderView: View {
    private let configuration: InAppPurchaseKitConfiguration

    init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: mainSpacing) {
            Group {
                #if os(macOS)
                Image(nsImage: configuration.image)
                    .resizable()
                #else
                Image(uiImage: configuration.image)
                    .resizable()
                #endif
            }
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
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text(configuration.title)
                    .font(titleFont)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(configuration.subtitle)
                    .font(subtitleFont)
                    .foregroundStyle(.secondary)
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
