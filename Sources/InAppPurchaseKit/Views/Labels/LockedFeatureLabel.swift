//
//  LockedFeatureLabel.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import SwiftUI

struct LockedFeatureLabel: View {
    /// The `LockedFeatureConfiguration` to use for the view.
    private let configuration: LockedFeatureConfiguration
    
    /// Creates a new `LockedFeatureLabel` view.
    /// - Parameter configuration: The `LockedFeatureConfiguration` to use for the view.
    init(configuration: LockedFeatureConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        if let titleKey = configuration.titleKey,
           let systemImage = configuration.systemImage {
            Label {
                Text(titleKey)
                    .foregroundStyle(configuration.titleColor)
            } icon: {
                Image(systemName: systemImage)
            }
        } else if let titleKey = configuration.titleKey {
            Text(titleKey)
                .foregroundStyle(configuration.titleColor)
        } else if let title = configuration.title,
                  let systemImage = configuration.systemImage {
            Label {
                Text(title)
                    .foregroundStyle(configuration.titleColor)
            } icon: {
                Image(systemName: systemImage)
            }
        } else if let title = configuration.title {
            Text(title)
                .foregroundStyle(configuration.titleColor)
        }
    }
}

#Preview {
    LockedFeatureLabel(configuration: .example)
}
