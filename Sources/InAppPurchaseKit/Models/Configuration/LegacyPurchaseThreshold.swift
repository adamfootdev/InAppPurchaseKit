//
//  LegacyPurchaseThreshold.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/05/2025.
//

import Foundation

public struct LegacyPurchaseThreshold: Sendable {
    /// An `Int` containing the build number where a subscription was first offered.
    let buildNumber: Int
    
    /// A `String` containing the version number where a subscription was first offered.
    let version: String
    
    /// Creates a new `LegacyPurchaseThreshold` object.
    /// - Parameters:
    ///   - buildNumber: An `Int` containing the build number where a subscription was first offered.
    ///   - version: A `String` containing the version number where a subscription was first offered.
    public init(buildNumber: Int, version: String) {
        self.buildNumber = buildNumber
        self.version = version
    }
}
