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
        #if os(tvOS)
        Button {} label: {
            rowView
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        #else
        rowView
        #endif
    }

    private var rowView: some View {
        HStack(spacing: mainSpacing) {
            Image(systemName: feature.systemImage)
                .resizable()
                .scaledToFit()
                .font(imageFont)
                .foregroundStyle(imageTint)
                .frame(width: imageWidth, height: imageHeight)
                .padding(imagePadding)
                .background {
                    RoundedRectangle(cornerRadius: imageRadius)
                        .foregroundStyle(imageBackground)
                        .frame(
                            width: imageWidth + (imagePadding * 2),
                            height: imageWidth + (imagePadding * 2)
                        )
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: textSpacing) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
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
        return 40
        #else
        return 24
        #endif
    }

    private var imageHeight: CGFloat {
        #if os(tvOS)
        return 30
        #else
        return 18
        #endif
    }

    private var imagePadding: CGFloat {
        #if os(tvOS)
        return 10
        #else
        return 6
        #endif
    }

    private var imageRadius: CGFloat {
        imageWidth/2
    }

    private var imageBackground: Color {
        #if os(visionOS)
        return feature.systemColor.opacity(0.7)
        #else
        return feature.systemColor.opacity(0.2)
        #endif
    }

    private var imageTint: Color {
        #if os(visionOS)
        return .white
        #else
        return feature.systemColor
        #endif
    }
}

#Preview {
    FeatureRow(.example)
}
