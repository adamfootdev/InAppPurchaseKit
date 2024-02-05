//
//  InAppPurchaseKit.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation
import StoreKit
import TPInAppReceipt

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
    private(set) var hasLoaded: Bool = false

    var transactionState: TransactionState = .pending {
        didSet {
            if transactionState == .purchased {
                Task {
                    try? await Task.sleep(for: .seconds(2))

                    await MainActor.run {
                        transactionState = .pending
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
            await configurePurchases()
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

    @MainActor private func configurePurchases() async {
        if configuration.loadProducts {
            await requestProducts()
        }

        await verifyExistingTransactions()

        await MainActor.run {
            hasLoaded = true
        }
    }


    // MARK: - Purchase Status

    public var activeTier: InAppPurchaseTier? {
        return configuration.tiers.allTiers.first(where: {
            purchasedTiers.contains($0)
        })
    }

    public var purchaseState: PurchaseState {
        if let overridePurchased = configuration.overridePurchased {
            return overridePurchased ? .purchased : .notPurchased
        } else if Bundle.main.bundlePath.hasSuffix(".appex") || configuration.fromAppExtension {
            let purchased = configuration.sharedUserDefaults.bool(
                forKey: StorageKey.extensionSubscribed
            )

            return purchased ? .purchased : .notPurchased

        } else {
            guard hasLoaded else {
                return .pending
            }

            let purchased = activeTier != nil

            configuration.sharedUserDefaults.set(
                purchased,
                forKey: StorageKey.extensionSubscribed
            )

            return purchased ? .purchased : .notPurchased
        }
    }


    // MARK: - Legacy Users

    public var legacyUser: Bool {
        guard let receipt = try? InAppReceipt.localReceipt() else {
            return false
        }

        guard let legacyUserThreshold = configuration.legacyUserThreshold else {
            return false
        }

        let originalVersion = receipt.originalAppVersion

        guard originalVersion != "1.0",
              let originalVersion = Int(originalVersion) else {
            return false
        }

        return originalVersion < legacyUserThreshold
    }


    // MARK: - Tiers

    var primaryTier: InAppPurchaseTier? {
        let tiers = configuration.tiers

        if legacyUser {
            return tiers.yearlyTier ?? tiers.monthlyTier ?? tiers.weeklyTier ?? tiers.legacyUserLifetimeTier ?? tiers.lifetimeTier
        } else {
            return tiers.yearlyTier ?? tiers.monthlyTier ?? tiers.weeklyTier ?? tiers.lifetimeTier ?? tiers.legacyUserLifetimeTier
        }
    }

    var availableTiers: [InAppPurchaseTier] {
        let tiers = configuration.tiers

        if legacyUser {
            let availableTiers = [
                tiers.weeklyTier,
                tiers.monthlyTier,
                tiers.yearlyTier,
                tiers.legacyUserLifetimeTier
            ]

            return availableTiers.compactMap { $0 }

        } else {
            let availableTiers = [
                tiers.weeklyTier,
                tiers.monthlyTier,
                tiers.yearlyTier,
                tiers.lifetimeTier
            ]

            return availableTiers.compactMap { $0 }
        }
    }

    func fetchTierSubtitle(for tier: InAppPurchaseTier) -> String {
        guard let product = fetchProduct(for: tier) else {
            return ""
        }

        var message: String = ""

        switch tier.type {
        case .weekly, .monthly, .yearly:
            if let introOffer = introOffer(for: product) {
                switch introOffer.period.unit {
                case .day:
                    message += String(
                        localized: "\(introOffer.period.value) Days Free, then ",
                        bundle: .module
                    )
                case .week:
                    message += String(
                        localized: "\(introOffer.period.value) Weeks Free, then ",
                        bundle: .module
                    )
                case .month:
                    message += String(
                        localized: "\(introOffer.period.value) Months Free, then ",
                        bundle: .module
                    )
                default:
                    message += ""
                }
            }

        case .lifetime, .legacyUserLifetime:
            message += String(
                localized: "One-time payment, ",
                bundle: .module
            )
        }

        message += "\(product.displayPrice)/\(tier.type.paymentTimeTitle.lowercased())"

        return message
    }


    // MARK: - Products

    @MainActor func requestProducts() async {
        do {
            availableProducts = try await Product.products(for: configuration.tiers.tierIDs)

            for product in availableProducts {
                if let introOffer = await fetchIntroOffer(for: product) {
                    productsWithIntroOffer[product] = introOffer
                }
            }

        } catch {
            print("Failed product request: \(error.localizedDescription)")
        }
    }

    func fetchTransactionState(for productIdentifier: String) async throws -> Bool {
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
        guard let monthlyTier = configuration.tiers.monthlyTier,
                let yearlyTier = configuration.tiers.yearlyTier else {
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


    // MARK: - Intro Offers

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


    // MARK: - Purchase

    @MainActor func purchase(
        _ product: Product
    ) async -> Transaction? {
        transactionState = .purchasing

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

                await updatePurchasedTiers(transaction)
                await transaction.finish()

                transactionState = .purchased

                if let purchaseCompletionBlock = configuration.purchaseCompletionBlock {
                    purchaseCompletionBlock(product)
                }

                return transaction

            case .userCancelled, .pending:
                transactionState = .pending
                return nil

            default:
                transactionState = .pending
                return nil
            }

        } catch {
            transactionState = .pending
            return nil
        }
    }

    @MainActor func restorePurchases() async {
        try? await AppStore.sync()
    }


    // MARK: - Transactions

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedTiers(transaction)
                    await transaction.finish()

                    await MainActor.run {
                        self.transactionState = .purchased
                    }

                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    @MainActor func verifyExistingTransactions() async {
        for tier in configuration.tiers.allTiers {
            do {
                if try await fetchTransactionState(for: tier.id) {
                    purchasedTiers.insert(tier)
                }
            } catch {
                print("Transaction failed verification")
            }
        }

        if let updatedPurchasesCompletionBlock = configuration.updatedPurchasesCompletionBlock {
            updatedPurchasesCompletionBlock()
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

    @MainActor func updatePurchasedTiers(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            if let tier = configuration.tiers.allTiers.first(where: {
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

        if let updatedPurchasesCompletionBlock = configuration.updatedPurchasesCompletionBlock {
            updatedPurchasesCompletionBlock()
        }
    }


    // MARK: - Previews

    public static var preview: InAppPurchaseKit = {
        InAppPurchaseKit.configure(with: .preview)
        return InAppPurchaseKit.shared
    }()
}
