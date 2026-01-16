//
//  InAppPurchaseHeaderView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct InAppPurchaseHeaderView: View {
    /// A `String` containing the subtitle for the view.
    private let subtitle: String
    
    /// The current `InAppPurchaseKitConfiguration`.
    private let configuration: InAppPurchaseKitConfiguration
    
    /// Creates a new `InAppPurchaseHeaderView`.
    /// - Parameters:
    ///   - subtitle: An optional `String` containing the subtitle for the view. If
    ///   a value is not supplied, the configuration subtitle will be used instead.
    ///   - configuration: The current `InAppPurchaseKitConfiguration`.
    init(
        subtitle: String? = nil,
        configuration: InAppPurchaseKitConfiguration
    ) {
        self.subtitle = subtitle ?? configuration.subtitle
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: mainSpacing) {
            AppIconView(
                named: configuration.imageName
            )

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
}

#Preview {
    InAppPurchaseHeaderView(configuration: .example)
}
