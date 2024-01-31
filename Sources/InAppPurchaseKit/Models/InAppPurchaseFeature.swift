//
//  InAppPurchaseFeature.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

public struct InAppPurchaseFeature {
    public let title: String
    public let description: String
    public let systemImage: String
    public let systemColor: Color

    public init(
        title: String,
        description: String,
        systemImage: String,
        systemColor: Color = .accentColor
    ) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.systemColor = systemColor
    }


    // MARK: - Previews

    public static var example: InAppPurchaseFeature = {
        let feature = InAppPurchaseFeature(
            title: "Feature",
            description: "About this feature.",
            systemImage: "checkmark",
            systemColor: .blue
        )

        return feature
    }()
}
