//
//  ProductsLoadState.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/05/2025.
//

import Foundation
import StoreKit

public enum ProductsLoadState: Sendable {
    case pending
    case loading

    case loaded(
        _ products: [Product],
        _ introOffers: [Product: Product.SubscriptionOffer],
        _ purchasedTiers: Set<PurchaseTier>,
        _ legacyUser: Bool,
        _ expiredUser: Bool
    )


    // MARK: - State

    public var hasLoaded: Bool {
        switch self {
        case .loaded(_, _, _, _, _):
            return true
        default:
            return false
        }
    }

    public var availableProducts: [Product] {
        switch self {
        case .loaded(let products, _, _, _, _):
            return products
        default:
            return []
        }
    }

    public var introOffers: [Product: Product.SubscriptionOffer] {
        switch self {
        case .loaded(_, let introOffers, _, _, _):
            return introOffers
        default:
            return [:]
        }
    }

    public var purchasedTiers: Set<PurchaseTier> {
        switch self {
        case .loaded(_, _, let purchasedTiers, _, _):
            return purchasedTiers
        default:
            return []
        }
    }

    public var isLegacyUser: Bool {
        switch self {
        case .loaded(_, _, _, let legacy, _):
            return legacy
        default:
            return false
        }
    }

    public var isExpiredUser: Bool {
        switch self {
        case .loaded(_, _, _, _, let expiredUser):
            return expiredUser
        default:
            return false
        }
    }


    // MARK: - Products

    public func fetchProduct(for id: String) -> Product? {
        availableProducts.first(where: { $0.id == id })
    }

    public func fetchIntroOffer(for product: Product) -> Product.SubscriptionOffer? {
        introOffers[product]
    }
}
