//
//  LegacyUserThreshold.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/05/2025.
//

import Foundation

public struct LegacyUserThreshold: Sendable {
    let buildNumber: Int
    let version: String

    public init(buildNumber: Int, version: String) {
        self.buildNumber = buildNumber
        self.version = version
    }
}
