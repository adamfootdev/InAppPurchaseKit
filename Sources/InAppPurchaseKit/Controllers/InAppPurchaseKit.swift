//
//  InAppPurchaseKit.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation
import StoreKit

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
@Observable
public final class InAppPurchaseKit: NSObject {
    private static var initializedInAppPurchaseKit: InAppPurchaseKit?

    public static var shared: InAppPurchaseKit {
        if let initializedInAppPurchaseKit {
            return initializedInAppPurchaseKit
        } else {
            fatalError("Please initialize InAppPurchaseKit by calling InAppPurchaseKit.configure(…) first.")
        }
    }

    let configuration: InAppPurchaseKitConfiguration
    private var updateListenerTask: Task<Void, Error>? = nil

    private(set) var availableProducts: [Product] = []
    private(set) var productsWithIntroOffer: [Product: Product.SubscriptionOffer] = [:]
    private(set) var purchasedTiers: Set<InAppPurchaseTier> = []

    var purchaseState: PurchaseState = .pending {
        didSet {
            if purchaseState == .purchased {
                Task {
                    try? await Task.sleep(for: .seconds(2))

                    await MainActor.run {
                        purchaseState = .pending
                    }
                }
            }
        }
    }


    // MARK: - Init

    private init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration

        super.init()

        #if os(iOS) || os(visionOS)
        configurePromotedListener()
        #endif

        updateListenerTask = listenForTransactions()

        Task {
            await fetchTransactionDetails()
        }
    }


    // MARK: - Deinit

    deinit {
        updateListenerTask?.cancel()
    }


    // MARK: - Configuration

    public static func configure(with configuration: InAppPurchaseKitConfiguration) {
        initializedInAppPurchaseKit = InAppPurchaseKit(configuration: configuration)
    }

    @MainActor private func fetchTransactionDetails() async {
        if configuration.loadProducts {
            await requestProducts()
        }

        await verifyExistingTransactions()
    }


    // MARK: - Purchase Status

    public var activeTier: InAppPurchaseTier? {
        return configuration.tiers.first(where: {
            purchasedTiers.contains($0)
        })
    }

    public var purchased: Bool {
        if let overridePurchased = configuration.overridePurchased {
            return overridePurchased
        } else if Bundle.main.bundlePath.hasSuffix(".appex") || configuration.fromAppExtension {
            let purchased = configuration.sharedUserDefaults.bool(
                forKey: StorageKey.extensionSubscribed
            )

            return purchased

        } else {
            let purchased = activeTier != nil

            configuration.sharedUserDefaults.set(
                purchased,
                forKey: StorageKey.extensionSubscribed
            )

            return purchased
        }
    }


    // MARK: - Products

    @MainActor func requestProducts() async {
        do {
            availableProducts = try await Product.products(for: configuration.tierIDs)

            for product in availableProducts {
                if let introOffer = await fetchIntroOffer(for: product) {
                    productsWithIntroOffer[product] = introOffer
                }
            }

        } catch {
            print("Failed product request: \(error.localizedDescription)")
        }
    }

    func fetchPurchaseState(for productIdentifier: String) async throws -> Bool {
        guard let result = await Transaction.latest(for: productIdentifier) else {
            return false
        }

        let transaction = try checkVerified(result)

        if let expirationDate = transaction.expirationDate,
           expirationDate < .now {
            return false
        } else {
            return transaction.revocationDate == nil && !transaction.isUpgraded
        }
    }

    func fetchProduct(for tier: InAppPurchaseTier) -> Product? {
        availableProducts.first(where: { $0.id == tier.id })
    }

    public var productsLoaded: Bool {
        availableProducts.isEmpty == false
    }

    var yearlySaving: Int? {
        guard (configuration.tiers.filter {
            $0.type == .monthly || $0.type == .yearly
        }.count == 2) else {
            return nil
        }

        guard let monthlyTier = configuration.tiers.first(where: {
            $0.type == .monthly
        }), let yearlyTier = configuration.tiers.first(where: {
            $0.type == .yearly
        }) else {
            return nil
        }

        guard let monthlyProduct = fetchProduct(for: monthlyTier),
              let yearlyProduct = fetchProduct(for: yearlyTier) else {
            return nil
        }

        let monthlyPrice = NSDecimalNumber(decimal: monthlyProduct.price).doubleValue
        let yearlyPrice = NSDecimalNumber(decimal: yearlyProduct.price).doubleValue

        let monthlyAnnualPrice = monthlyPrice * 12

        guard monthlyAnnualPrice > yearlyPrice else {
            return nil
        }

        let discount = monthlyAnnualPrice - yearlyPrice
        let discountDecimal = discount / monthlyAnnualPrice
        let discountPercentage = discountDecimal * 100

        return Int(String(format: "%.0f", discountPercentage))
    }


    // MARK: - Purchase

    @MainActor func purchase(
        _ product: Product
    ) async -> Transaction? {
        purchaseState = .purchasing

        do {
            #if os(visionOS)
            guard let scene = UIApplication.shared.connectedScenes.first(where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene else { return nil }

            let result = try await product.purchase(confirmIn: scene)
            #else
            let result = try await product.purchase()
            #endif

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)

                await updatePurchasedIdentifiers(transaction)
                await transaction.finish()

                purchaseState = .purchased
                return transaction

            case .userCancelled, .pending:
                purchaseState = .pending
                return nil

            default:
                purchaseState = .pending
                return nil
            }

        } catch {
            purchaseState = .pending
            return nil
        }
    }

    @MainActor func restorePurchases() async {
        try? await AppStore.sync()
    }

    private func fetchIntroOffer(for product: Product) async -> Product.SubscriptionOffer? {
        guard let renewableSubscription = product.subscription else {
            return nil
        }

        if await renewableSubscription.isEligibleForIntroOffer {
            return renewableSubscription.introductoryOffer
        }

        return nil
    }

    func introOffer(for product: Product) -> Product.SubscriptionOffer? {
        productsWithIntroOffer[product]
    }


    // MARK: - Transactions

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedIdentifiers(transaction)
                    await transaction.finish()

                    await MainActor.run {
                        self.purchaseState = .purchased
                    }

                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    @MainActor func verifyExistingTransactions() async {
        for tier in configuration.tiers {
            do {
                if try await fetchPurchaseState(for: tier.id) {
                    purchasedTiers.insert(tier)
                }
            } catch {
                print("Transaction failed verification")
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw InAppPurchaseKitError.failedStoreVerification
        case .verified(let safe):
            return safe
        }
    }

    @MainActor func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            if let tier = configuration.tiers.first(where: {
                $0.id == transaction.productID
            }) {
                purchasedTiers.insert(tier)
            }
        } else {
            let tiers = purchasedTiers.filter {
                $0.id == transaction.productID
            }

            for tier in tiers {
                purchasedTiers.remove(tier)
            }
        }
    }


    // MARK: - Previews

    static var preview: InAppPurchaseKit = {
        InAppPurchaseKit.configure(with: .preview)
        return InAppPurchaseKit.shared
    }()
}
