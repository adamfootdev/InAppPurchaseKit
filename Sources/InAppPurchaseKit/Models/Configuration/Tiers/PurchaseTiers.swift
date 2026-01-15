//
//  PurchaseTiers.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/01/2026.
//

import Foundation

public struct PurchaseTiers: Sendable {
    public let weeklyTier: PurchaseTier?
    public let monthlyTier: PurchaseTier?
    public let yearlyTier: PurchaseTier?
    public let lifetimeTier: PurchaseTier?

    public init(
        weeklyTier: PurchaseTierConfiguration?,
        monthlyTier: PurchaseTierConfiguration?,
        yearlyTier: PurchaseTierConfiguration?,
        lifetimeTier: PurchaseTierConfiguration?
    ) {
        if let weeklyTier {
            self.weeklyTier = .weekly(configuration: weeklyTier)
        } else {
            self.weeklyTier = nil
        }

        if let monthlyTier {
            self.monthlyTier = .monthly(configuration: monthlyTier)
        } else {
            self.monthlyTier = nil
        }

        if let yearlyTier {
            self.yearlyTier = .yearly(configuration: yearlyTier)
        } else {
            self.yearlyTier = nil
        }

        if let lifetimeTier {
            self.lifetimeTier = .lifetime(configuration: lifetimeTier)
        } else {
            self.lifetimeTier = nil
        }
    }

    public var orderedTiers: [PurchaseTier] {
        let tiers = [lifetimeTier, yearlyTier, monthlyTier, weeklyTier]
        return tiers.compactMap { $0 }
    }

    var tierIDs: [String] {
        orderedTiers.map { $0.id } + orderedTiers.compactMap { $0.legacyID } + orderedTiers.flatMap { $0.alternateIDs }
    }


    // MARK: - Previews

    public static let example: PurchaseTiers = {
        let tiers = PurchaseTiers(
            weeklyTier: nil,
            monthlyTier: .init(id: "app.FootWare.Example.Pro.Monthly", alwaysVisible: false),
            yearlyTier: .init(id: "app.FootWare.Example.Pro.Yearly", alwaysVisible: true),
            lifetimeTier: .init(id: "app.FootWare.Example.Pro.Lifetime", alwaysVisible: false)
        )

        return tiers
    }()
}
