//
//  AboutInAppPurchaseView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct AboutInAppPurchaseView: View {
    private let configuration: InAppPurchaseKitConfiguration

    init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: mainSpacing) {
            InAppPurchaseHeaderView(configuration: configuration)

            FeaturesListView(configuration.features)
                #if os(tvOS)
                .padding(.horizontal, 40)
                #elseif os(watchOS)
                .padding(.horizontal, 8)
                #endif
        }
        .frame(maxWidth: .infinity)
        .padding()
        #if os(tvOS)
        .padding(.vertical, 32)
        #elseif os(watchOS)
        .padding(.vertical)
        #endif
        .background {
            RoundedRectangle(
                cornerRadius: backgroundCornerRadius,
                style: .continuous
            )
            #if os(tvOS) || os(visionOS)
            .foregroundStyle(.regularMaterial)
            #else
            .foregroundStyle(backgroundColor)
            #endif
        }
        #if os(tvOS)
        .padding(.horizontal, 200)
        #endif
    }

    private var mainSpacing: CGFloat {
        #if os(macOS) || os(watchOS)
        return 20
        #elseif os(tvOS)
        return 48
        #else
        return 32
        #endif
    }

    private var backgroundColor: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #elseif os(macOS)
        return Color(.controlBackgroundColor)
        #elseif os(watchOS)
        return Color(red: 34/255, green: 34/255, blue: 35/255)
        #else
        return Color.gray
        #endif
    }

    private var backgroundCornerRadius: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 20
        #endif
    }
}

#Preview {
    AboutInAppPurchaseView(configuration: .preview)
}
