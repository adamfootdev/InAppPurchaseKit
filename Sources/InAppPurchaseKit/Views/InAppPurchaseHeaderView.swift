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
        VStack(spacing: 8) {
//            Image(systemName: configuration.systemImage)
//                .resizable()
//                .scaledToFit()
//                .foregroundStyle(configuration.systemColor)
//                .frame(width: 48, height: 48)
//                .frame(width: 60, height: 60)
//                .accessibilityHidden(true)

            Text(String(localized: "Upgrade to \(configuration.title)"))
                .font(titleFont)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var titleFont: Font {
        #if os(visionOS)
        return Font.title3
        #elseif os(watchOS)
        return Font.headline
        #else
        return Font.title3.bold()
        #endif
    }
}

#Preview {
    InAppPurchaseHeaderView(configuration: .preview)
}
