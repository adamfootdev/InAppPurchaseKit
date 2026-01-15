//
//  PurchaseTier.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/01/2026.
//

import Foundation

public enum PurchaseTier: Identifiable, Hashable, Sendable {
    case weekly(configuration: PurchaseTierConfiguration)
    case monthly(configuration: PurchaseTierConfiguration)
    case yearly(configuration: PurchaseTierConfiguration)
    case lifetime(configuration: PurchaseTierConfiguration)

    public var id: String {
        switch self {
        case .weekly(let configuration),
                .monthly(let configuration),
                .yearly(let configuration),
                .lifetime(let configuration):
            return configuration.id
        }
    }

    public var configuration: PurchaseTierConfiguration {
        switch self {
        case .weekly(let configuration),
                .monthly(let configuration),
                .yearly(let configuration),
                .lifetime(let configuration):
            return configuration
        }
    }

    var legacyID: String? {
        switch self {
        case .weekly(let configuration),
                .monthly(let configuration),
                .yearly(let configuration),
                .lifetime(let configuration):
            return configuration.legacyConfiguration?.id
        }
    }

    var alternateIDs: [String] {
        switch self {
        case .weekly(let configuration),
                .monthly(let configuration),
                .yearly(let configuration),
                .lifetime(let configuration):
            return configuration.alternateIDs
        }
    }

    var tierIDs: [String] {
        var ids = [id]

        if let legacyID {
            ids.append(legacyID)
        }

        ids += alternateIDs

        return ids
    }

    public var title: String {
        switch self {
        case .weekly(_):
            return String(
                localized: "Weekly",
                bundle: .module
            )
        case .monthly(_):
            return String(
                localized: "Monthly",
                bundle: .module
            )
        case .yearly(_):
            return String(
                localized: "Yearly",
                bundle: .module
            )
        case .lifetime(_):
            return String(
                localized: "Lifetime",
                bundle: .module
            )
        }
    }

    public var paymentTimeTitle: String {
        switch self {
        case .weekly(_):
            return String(
                localized: "Week",
                bundle: .module
            )
        case .monthly(_):
            return String(
                localized: "Month",
                bundle: .module
            )
        case .yearly(_):
            return String(
                localized: "Year",
                bundle: .module
            )
        case .lifetime(_):
            return String(
                localized: "Lifetime",
                bundle: .module
            )
        }
    }
}
