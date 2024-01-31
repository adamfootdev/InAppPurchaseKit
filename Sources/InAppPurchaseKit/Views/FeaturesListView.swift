//
//  FeaturesListView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct FeaturesListView: View {
    private let features: [InAppPurchaseFeature]

    init(_ features: [InAppPurchaseFeature]) {
        self.features = features
    }

    var body: some View {
        VStack(alignment: .leading, spacing: listSpacing) {
            ForEach(Array(features.enumerated()), id: \.0) { _, feature in
                FeatureRow(feature)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var listSpacing: CGFloat {
        #if os(macOS)
        return 16
        #elseif os(tvOS)
        return 32
        #elseif os(watchOS)
        return 12
        #else
        return 24
        #endif
    }
}

#Preview {
    FeaturesListView([.example])
}
