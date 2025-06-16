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
        _ purchasedTiers: Set<InAppPurchaseTier>,
        _ legacyUser: Bool
    )


    // MARK: - State

    public var hasLoaded: Bool {
        switch self {
        case .loaded(_, _, _, _):
            return true
        default:
            return false
        }
    }

    public var availableProducts: [Product] {
        switch self {
        case .loaded(let products, _, _, _):
            return products
        default:
            return []
        }
    }

    public var introOffers: [Product: Product.SubscriptionOffer] {
        switch self {
        case .loaded(_, let introOffers, _, _):
            return introOffers
        default:
            return [:]
        }
    }

    public var purchasedTiers: Set<InAppPurchaseTier> {
        switch self {
        case .loaded(_, _, let purchasedTiers, _):
            return purchasedTiers
        default:
            return []
        }
    }

    public var isLegacyUser: Bool {
        switch self {
        case .loaded(_, _, _, let legacy):
            return legacy
        default:
            return false
        }
    }


    // MARK: - Products

    func fetchProduct(for id: String) -> Product? {
        availableProducts.first(where: { $0.id == id })
    }

    func fetchIntroOffer(for product: Product) -> Product.SubscriptionOffer? {
        introOffers[product]
    }
}
