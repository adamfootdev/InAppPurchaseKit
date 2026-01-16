//
//  FeaturesView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import SwiftUI

struct FeaturesView: View {
    /// An array of `PurchaseFeature` to display.
    private let features: [PurchaseFeature]
    
    /// Creates a new `FeaturesView`.
    /// - Parameter features: An array of `PurchaseFeature` to display.
    init(_ features: [PurchaseFeature]) {
        self.features = features
    }

    var body: some View {
        VStack(spacing: SizingConstants.mainSpacing / 2) {
            Text("Whatʼs Included", bundle: .module)
                .font(titleFont)
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            FeaturesListView(features)
        }
        .padding(.vertical, 8)
    }

    private var titleFont: Font {
        #if os(visionOS)
        return Font.title3
        #else
        return Font.title3.bold()
        #endif
    }
}

#Preview {
    FeaturesView([.example])
}
