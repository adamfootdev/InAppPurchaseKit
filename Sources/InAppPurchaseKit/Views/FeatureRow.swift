//
//  FeatureRow.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct FeatureRow: View {
    private let feature: InAppPurchaseFeature

    init(_ feature: InAppPurchaseFeature) {
        self.feature = feature
    }

    var body: some View {
        HStack(spacing: mainSpacing) {
            Image(systemName: feature.systemImage)
                .resizable()
                .scaledToFit()
                #if !os(watchOS)
                .font(imageFont)
                #endif
                .foregroundStyle(feature.systemColor)
                .frame(width: imageWidth, height: imageHeight)
                #if !os(watchOS)
                .padding(imagePadding)
                .background {
                    Circle()
                        .foregroundStyle(feature.systemColor.opacity(0.2))
                }
                #endif
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(titleFont)
                    .fixedSize(horizontal: false, vertical: true)

                #if !os(watchOS)
                Text(feature.description)
                    .font(descriptionFont)
                    .foregroundStyle(Color.secondary)
                #endif
            }
        }
    }

    private var mainSpacing: CGFloat {
        #if os(tvOS)
        return 20
        #elseif os(watchOS)
        return 10
        #else
        return 12
        #endif
    }

    private var titleFont: Font {
        #if os(macOS) || os(tvOS)
        return Font.headline
        #elseif os(watchOS)
        return Font.system(.footnote, weight: .medium)
        #else
        return Font.subheadline.bold()
        #endif
    }

    private var descriptionFont: Font {
        #if os(macOS)
        return Font.footnote
        #elseif os(tvOS)
        return Font.subheadline
        #else
        return Font.caption
        #endif
    }

    private var imageFont: Font {
        #if os(macOS) || os(tvOS)
        return Font.headline
        #else
        return Font.callout.bold()
        #endif
    }

    private var imageWidth: CGFloat {
        #if os(tvOS)
        return 36
        #elseif os(watchOS)
        return 20
        #else
        return 18
        #endif
    }

    private var imageHeight: CGFloat {
        #if os(tvOS)
        return 28
        #elseif os(watchOS)
        return 16
        #else
        return 14
        #endif
    }

    private var imagePadding: CGFloat {
        #if os(tvOS)
        return 20
        #else
        return 8
        #endif
    }
}

#Preview {
    FeatureRow(.example)
}
