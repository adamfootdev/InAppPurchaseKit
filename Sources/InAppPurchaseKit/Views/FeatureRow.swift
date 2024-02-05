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
                .font(imageFont)
                .foregroundStyle(feature.systemColor)
                .frame(width: imageWidth, height: imageHeight)
                .padding(imagePadding)
                .background {
                    Circle()
                        .foregroundStyle(feature.systemColor.opacity(0.2))
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: textSpacing) {
                Text(feature.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Text(feature.description)
                    .font(descriptionFont)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var mainSpacing: CGFloat {
        #if os(tvOS)
        return 20
        #else
        return 12
        #endif
    }

    private var textSpacing: CGFloat {
        #if os(watchOS)
        return 0
        #else
        return 4
        #endif
    }

    private var descriptionFont: Font {
        #if os(watchOS)
        return Font.footnote
        #else
        return Font.subheadline
        #endif
    }

    private var imageFont: Font {
        #if os(macOS) || os(tvOS)
        return Font.headline
        #elseif os(watchOS)
        return Font.headline
        #else
        return Font.callout.bold()
        #endif
    }

    private var imageWidth: CGFloat {
        #if os(tvOS)
        return 36
        #else
        return 18
        #endif
    }

    private var imageHeight: CGFloat {
        #if os(tvOS)
        return 28
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
