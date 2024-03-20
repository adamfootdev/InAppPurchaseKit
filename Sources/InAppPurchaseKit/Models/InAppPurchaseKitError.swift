//
//  InAppPurchaseKitError.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation

public enum InAppPurchaseKitError: Error, LocalizedError, CustomLocalizedStringResourceConvertible {
    case failedStoreVerification

    public var errorDescription: String? {
        switch self {
        case .failedStoreVerification:
            return String(
                localized: "There was an error verifying your request. Please try again.",
                bundle: .module
            )
        }
    }

    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public var localizedStringResource: LocalizedStringResource {
        guard let errorDescription else {
            return "An unknown error occurred."
        }

        return .init(stringLiteral: errorDescription)
    }
}
