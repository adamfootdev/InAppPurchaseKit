//
//  InAppPurchaseTiers.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 05/02/2024.
//

import Foundation

public struct InAppPurchaseTiers {
    let weeklyTier: InAppPurchaseTier?
    let monthlyTier: InAppPurchaseTier?
    let yearlyTier: InAppPurchaseTier?
    let lifetimeTier: InAppPurchaseTier?
    let legacyUserLifetimeTier: InAppPurchaseTier?

    public init(
        weeklyTier: String? = nil,
        monthlyTier: String?,
        yearlyTier: String?,
        lifetimeTier: String?,
        legacyUserLifetimeTier: String? = nil
    ) {
        if let weeklyTier {
            self.weeklyTier = .init(id: weeklyTier, type: .weekly)
        } else {
            self.weeklyTier = nil
        }

        if let monthlyTier {
            self.monthlyTier = .init(id: monthlyTier, type: .monthly)
        } else {
            self.monthlyTier = nil
        }

        if let yearlyTier {
            self.yearlyTier = .init(id: yearlyTier, type: .yearly)
        } else {
            self.yearlyTier = nil
        }

        if let lifetimeTier {
            self.lifetimeTier = .init(id: lifetimeTier, type: .lifetime)
        } else {
            self.lifetimeTier = nil
        }

        if let legacyUserLifetimeTier {
            self.legacyUserLifetimeTier = .init(
                id: legacyUserLifetimeTier,
                type: .legacyUserLifetime
            )
        } else {
            self.legacyUserLifetimeTier = nil
        }
    }

    var allTiers: [InAppPurchaseTier] {
        let tiers = [weeklyTier, monthlyTier, yearlyTier, lifetimeTier, legacyUserLifetimeTier]
        return tiers.compactMap { $0 }
    }

    var tierIDs: [String] {
        allTiers.map { $0.id }
    }


    // MARK: - Previews

    public static var example: InAppPurchaseTiers = {
        let tiers = InAppPurchaseTiers(
            weeklyTier: nil,
            monthlyTier: "app.FootWare.Example.Pro.Monthly",
            yearlyTier: "app.FootWare.Example.Pro.Yearly",
            lifetimeTier: "app.FootWare.Example.Pro.Lifetime",
            legacyUserLifetimeTier: nil
        )

        return tiers
    }()
}
