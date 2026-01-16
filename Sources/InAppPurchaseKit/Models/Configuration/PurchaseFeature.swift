//
//  PurchaseFeature.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

public struct PurchaseFeature: Sendable {
    /// A `String` containing the feature title.
    public let title: String
    
    /// A `String` containing the feature description.
    public let description: String
    
    /// A `String` containing the name of the system image.
    public let systemImage: String
    
    /// The `Color` to tint the image.
    public let systemColor: Color
    
    /// Creates a new `PurchaseFeature` object.
    /// - Parameters:
    ///   - title: A `String` containing the feature title.
    ///   - description: A `String` containing the feature description.
    ///   - systemImage: A `String` containing the name of the system image.
    ///   - systemColor: The `Color` to tint the image.
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

    public static let example: PurchaseFeature = {
        let feature = PurchaseFeature(
            title: "Feature",
            description: "About this feature.",
            systemImage: "checkmark",
            systemColor: .blue
        )

        return feature
    }()
}
