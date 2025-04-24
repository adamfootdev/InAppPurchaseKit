//
//  SwiftUIView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import SwiftUI

struct AppIconView: View {
    private let configuration: InAppPurchaseKitConfiguration

    init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        Image(
            configuration.imageName,
            bundle: .main
        )
        .resizable()
        .scaledToFill()
        #if os(iOS) || os(tvOS)
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
    AppIconView(configuration: .preview)
}
