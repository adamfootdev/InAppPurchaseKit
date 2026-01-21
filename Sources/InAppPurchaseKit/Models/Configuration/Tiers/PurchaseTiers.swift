//
//  PurchaseTiers.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/01/2026.
//

import Foundation

public struct PurchaseTiers: Sendable {
    /// The weekly optional `PurchaseTier`.
    public let weeklyTier: PurchaseTier?
    
    /// The monthly optional `PurchaseTier`.
    public let monthlyTier: PurchaseTier?
    
    /// The yearly optional `PurchaseTier`.
    public let yearlyTier: PurchaseTier?
    
    /// The lifetime optional `PurchaseTier`.
    public let lifetimeTier: PurchaseTier?
    
    /// Creates a new `PurchaseTiers` object.
    /// - Parameters:
    ///   - weeklyTier: The weekly optional `PurchaseTier`.
    ///   - monthlyTier: The monthly optional `PurchaseTier`.
    ///   - yearlyTier: The yearly optional `PurchaseTier`.
    ///   - lifetimeTier: The lifetime optional `PurchaseTier`.
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

    var allTierIDs: [String] {
        return orderedTiers.flatMap { $0.tierIDs }
    }


    // MARK: - Previews

    public static let example: PurchaseTiers = {
        let tiers = PurchaseTiers(
            weeklyTier: nil,
            monthlyTier: .init(id: "com.example.MyApp.Pro.Monthly", alwaysVisible: false),
            yearlyTier: .init(id: "com.example.MyApp.Pro.Yearly", alwaysVisible: true),
            lifetimeTier: .init(id: "com.example.MyApp.Pro.Lifetime", alwaysVisible: false)
        )

        return tiers
    }()
}
