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
        .scaledToFit()
        .frame(width: imageWidth, height: imageHeight)
        .accessibilityHidden(true)
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
