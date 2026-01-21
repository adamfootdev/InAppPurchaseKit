//
//  InAppPurchaseKit.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation
import StoreKit

@MainActor @Observable
public final class InAppPurchaseKit: NSObject {
    /// The current `InAppPurchaseKit` object.
    private static var initializedInAppPurchaseKit: InAppPurchaseKit?
    
    /// Access the current `InAppPurchaseKit` instance.
    public static var shared: InAppPurchaseKit {
        if let initializedInAppPurchaseKit {
            return initializedInAppPurchaseKit
        } else {
            fatalError("Please initialize InAppPurchaseKit by calling InAppPurchaseKit.configure(…) first.")
        }
    }
    
    /// The current `InAppPurchaseKitConfiguration` to use for the in-app purchase views.
    public private(set) var configuration: InAppPurchaseKitConfiguration
    
    /// A task to listen for updates to the transaction state.
    @ObservationIgnored
    private var updateListenerTask: Task<Void, Error>? = nil
    
    /// An enum containing the load state of the products.
    public private(set) var productsLoadState: ProductsLoadState = .pending
    
    /// A `Bool` indicating whether promoted purchases are currently being checked.
    @ObservationIgnored
    private var checkingPromotedPurchase: Bool = false
    
    /// An enum containing the current transaction state.
    public var transactionState: TransactionState = .pending {
        didSet {
            switch transactionState {
            case .purchased(_):
                // Reset the state back to pending so the user
                // can purchase another in-app purchase.
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    transactionState = .pending
                }
            default:
                break
            }
        }
    }


    // MARK: - Init
    
    /// Creates a new `InAppPurchaseKit` object.
    /// - Parameter configuration: The `InAppPurchaseKitConfiguration` to use for the in-app purchase views.
    private init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration

        super.init()

        updateListenerTask = listenForTransactions()

        Task {
            await updateProductLoadState()
            await checkForExternalPurchases()
        }
    }


    // MARK: - Configuration
    
    /// Configure `InAppPurchaseKit` with the set configuration.
    /// - Parameter configuration: The `InAppPurchaseKitConfiguration` to use for the in-app purchase views.
    /// - Returns: The initialized instance of `InAppPurchaseKit`.
    @discardableResult
    public static func configure(
        with configuration: InAppPurchaseKitConfiguration
    ) -> InAppPurchaseKit {
        if let initializedInAppPurchaseKit {
            initializedInAppPurchaseKit.configuration = configuration
            return initializedInAppPurchaseKit
        } else {
            let object = InAppPurchaseKit(configuration: configuration)
            initializedInAppPurchaseKit = object
            return object
        }
    }


    // MARK: - Products
    
    /// Refreshes the product load state by checking for purchases.
    /// - Parameter fromReload: A `Bool` indicating whether the refresh should be
    /// for a reload.
    private func updateProductLoadState(fromReload: Bool = false) async {
        if fromReload == false {
            productsLoadState = .loading
        }

        let products = await fetchProducts()
        let purchasedTiers = await fetchPurchasedTiers()
        let legacyUser = await fetchLegacyUserState()

        productsLoadState = .loaded(
            products.products,
            products.introOffers,
            purchasedTiers,
            legacyUser
        )

        if let updatedPurchasesCompletionBlock = configuration.updatedPurchasesCompletionBlock {
            updatedPurchasesCompletionBlock()
        }
    }
    
    /// Wait until purchases have been loaded.
    public func waitUntilLoadedPurchases() async {
        if productsLoadState.hasLoaded {
            return
        } else {
            try? await Task.sleep(for: .seconds(0.3))
            await waitUntilLoadedPurchases()
        }
    }
    
    /// Fetches StoreKit products based on the IDs in the configuration.
    /// - Returns: An array of `Product` with a dictionary of offers.
    private func fetchProducts() async -> (
        products: [Product],
        introOffers: [Product: Product.SubscriptionOffer]
    ) {
        do {
            let productIDs = (configuration.tiers.allTierIDs + (configuration.tipJarTiers?.allTierIDs ?? [])).map { $0 }
            let products = try await Product.products(for: productIDs)

            var introOffers: [Product: Product.SubscriptionOffer] = [:]

            for product in products {
                if let introOffer = await fetchIntroOffer(for: product) {
                    introOffers[product] = introOffer
                }
            }

            return (products, introOffers)

        } catch {
            return ([], [:])
        }
    }
    
    /// Checks whether the user has an active purchase for the provided identifier.
    /// - Parameter productIdentifier: A `String` containing the product ID.
    /// - Returns: A `Bool` indicating whether the user has purchased that product.
    private func fetchTransactionState(
        for productIdentifier: String
    ) async throws -> Bool {
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
    
    /// Fetches a StoreKit product based on a tier.
    /// - Parameter tier: The `PurchaseTier` to fetch the product for.
    /// - Returns: An optional StoreKit `Product` if available.
    public func fetchProduct(for tier: PurchaseTier) -> Product? {
        if productsLoadState.isLegacyUser,
           let configuration = tier.configuration.legacyConfiguration,
           configuration.visible,
           let product = productsLoadState.fetchProduct(
            for: configuration.id
           )  {
            return product
        }

        return productsLoadState.fetchProduct(for: tier.id)
    }
    
    /// Fetches a StoreKit product based on a Tip Jar tier.
    /// - Parameter tipJarTier: The `TipJarTier` to fetch the product for.
    /// - Returns: An optional StoreKit `Product` if available.
    public func fetchProduct(for tipJarTier: TipJarTier) -> Product? {
        productsLoadState.fetchProduct(for: tipJarTier.id)
    }


    // MARK: - External Purchases
    
    /// Checks if the user has made a purchase externally e.g. via the App Store.
    public func checkForExternalPurchases() async {
        guard checkingPromotedPurchase == false else { return }

        checkingPromotedPurchase = true

        #if os(iOS) || os(macOS)
        for await purchaseIntent in PurchaseIntent.intents {
            await purchase(purchaseIntent.product)
        }
        #endif

        checkingPromotedPurchase = false
    }


    // MARK: - Purchase Status
    
    /// The highest tier that the user has purchased.
    public var activeTier: PurchaseTier? {
        return configuration.tiers.orderedTiers.first(where: {
            productsLoadState.purchasedTiers.contains($0)
        })
    }
    
    /// The current purchase state for the user.
    public var purchaseState: PurchaseState {
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            let purchased = configuration.sharedUserDefaults.bool(
                forKey: StorageKey.extensionSubscribed
            )

            return purchased ? .purchased : .notPurchased

        } else {
            guard productsLoadState.hasLoaded else {
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
    
    /// Returns a `Bool` based on whether the user meets the criteria.
    /// - Returns: A `Bool` indicating whether they are a legacy user.
    private func fetchLegacyUserState() async -> Bool {
        guard let threshold = configuration.legacyPurchaseThreshold else {
            return false
        }

        do {
            let transactionResult = try await AppTransaction.shared

            switch transactionResult {
            case .unverified(_, _):
                return false
            case .verified(let transaction):
                let originalVersion = transaction.originalAppVersion

                guard Int(transaction.originalPurchaseDate.timeIntervalSince1970) != 0 else {
                    return false
                }

                if originalVersion.contains(".") {
                    let value = threshold.version
                    let valueComponents = value.split(separator: ".").map { Int($0) }
                    let originalVersionComponents = originalVersion.split(separator: ".").map { Int($0) }

                    guard valueComponents.count >= 1,
                          let valueMajor = valueComponents[0],
                          originalVersionComponents.count >= 1,
                          let originalVersionMajor = originalVersionComponents[0] else {
                        return false
                    }

                    if originalVersionMajor < valueMajor {
                        return true

                    } else if originalVersionMajor == valueMajor {
                        if valueComponents.count >= 2,
                           let valueMinor = valueComponents[1],
                           originalVersionComponents.count >= 2,
                           let originalVersionMinor = originalVersionComponents[1] {
                            if originalVersionMinor < valueMinor {
                                return true

                            } else if originalVersionMinor == valueMinor {
                                if valueComponents.count >= 3,
                                   let valuePatch = valueComponents[2],
                                   originalVersionComponents.count >= 3,
                                   let originalVersionPatch = originalVersionComponents[2] {
                                    if originalVersionPatch < valuePatch {
                                        return true
                                    } else {
                                        return false
                                    }

                                } else {
                                    return false
                                }

                            } else {
                                return false
                            }

                        } else {
                            return false
                        }

                    } else {
                        return false
                    }

                } else {
                    guard let originalVersion = Int(originalVersion) else {
                        return false
                    }

                    let value = threshold.buildNumber
                    return originalVersion < value
                }
            }

        } catch {
            return false
        }
    }


    // MARK: - Tiers
    
    /// The `PurchaseTier` to pre-select based on the configuration.
    public var primaryTier: PurchaseTier? {
        let tiers = configuration.tiers.orderedTiers

        if let tier = tiers.first(where: {
            $0.configuration.isPrimary
        }) {
            return tier
        } else if let tier = tiers.first(where: {
            $0.configuration.alwaysVisible
        }) {
            return tier
        } else {
            return tiers.first
        }
    }
    
    /// The tiers that should always be shown to the user.
    public var alwaysVisibleTiers: [PurchaseTier] {
        let tiers = configuration.tiers
        
        return tiers.orderedTiers.filter {
            $0.configuration.alwaysVisible
        }
    }
    
    /// Fetches the subtitle for a given tier.
    /// - Parameter tier: The `PurchaseTier` to fetch the subtitle for.
    /// - Returns: A `String` containing the subtitle.
    public func fetchTierSubtitle(for tier: PurchaseTier) -> String {
        guard let product = fetchProduct(for: tier) else {
            return ""
        }

        var message: String = ""

        switch tier {
        case .weekly(_), .monthly(_), .yearly(_):
            if let introOffer = introOffer(for: product),
               introOffer.paymentMode == .freeTrial {
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
                case .year:
                    message += String(
                        localized: "\(introOffer.period.value) Years Free, then ",
                        bundle: .module
                    )
                default:
                    message += ""
                }

                message += "\(product.displayPrice)/\(tier.paymentTimeTitle). No payment due today."

            } else {
                message += "\(product.displayPrice)/\(tier.paymentTimeTitle)"
            }

        case .lifetime(_):
            message += String(
                localized: "One-time payment, ",
                bundle: .module
            )

            message += "\(product.displayPrice)/\(tier.paymentTimeTitle)"
        }

        return message
    }
    
    /// Fetches a list of all the tiers a user has purchased.
    /// - Returns: A set of `PurchaseTier` that the user has purchased.
    private func fetchPurchasedTiers() async -> Set<PurchaseTier> {
        var purchasedTiers: Set<PurchaseTier> = []

        for tier in configuration.tiers.orderedTiers {
            if purchasedTiers.contains(tier) == false {
                for id in tier.tierIDs {
                    if (try? await fetchTransactionState(for: id)) ?? false {
                        purchasedTiers.insert(tier)
                    }
                }
            }
        }

        return purchasedTiers
    }
    
    /// Updates the purchased tiers based on a StoreKit transaction.
    /// - Parameter transaction: The StoreKit `Transaction` to update based on.
    private func updatePurchasedTiers(_ transaction: Transaction) async {
        var purchasedTiers: Set<PurchaseTier> = []

        switch productsLoadState {
        case .loaded(_, _, let tiers, _):
            purchasedTiers = tiers
        default:
            purchasedTiers = []
        }

        if transaction.revocationDate == nil {
            if let tier = configuration.tiers.orderedTiers.first(where: {
                $0.tierIDs.contains(transaction.productID)
            }) {
                purchasedTiers.insert(tier)
            }
        } else {
            let tiers = purchasedTiers.filter {
                $0.tierIDs.contains(transaction.productID)
            }

            for tier in tiers {
                purchasedTiers.remove(tier)
            }
        }

        switch productsLoadState {
        case .loaded(let products, let introOffers, _, let legacyUser):
            productsLoadState = .loaded(
                products,
                introOffers,
                purchasedTiers,
                legacyUser
            )
        default:
            break
        }

        if let updatedPurchasesCompletionBlock = configuration.updatedPurchasesCompletionBlock {
            updatedPurchasesCompletionBlock()
        }
    }


    // MARK: - Savings
    
    /// The percentage saving of a yearly plan vs a monthly one.
    public var yearlySaving: Int? {
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
    
    /// Fetches an intro offer for a StoreKit `Product` if available.
    /// - Parameter product: The StoreKit `Product` to fetch the intro offer for.
    /// - Returns: An optional intro offer if available.
    private func fetchIntroOffer(
        for product: Product
    ) async -> Product.SubscriptionOffer? {
        guard let renewableSubscription = product.subscription else {
            return nil
        }

        if await renewableSubscription.isEligibleForIntroOffer {
            return renewableSubscription.introductoryOffer
        }

        return nil
    }
    
    /// Fetches the stored intro offer for a StoreKit `Product` if available.
    /// - Parameter product: The StoreKit `Product` to fetch the intro offer for.
    /// - Returns: An optional intro offer if available.
    public func introOffer(
        for product: Product
    ) -> Product.SubscriptionOffer? {
        productsLoadState.fetchIntroOffer(for: product)
    }


    // MARK: - Purchase
    
    /// Asks the system to purchase the selected product.
    /// - Parameter product: The StoreKit `Product` to purchase.
    /// - Returns: An optional `Transaction` if the user purchased the product.
    @discardableResult
    public func purchase(_ product: Product) async -> Transaction? {
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

                if (configuration.tipJarTiers?.allTierIDs ?? []).contains(where: {
                    $0 == transaction.productID
                }) {
                    await transaction.finish()
                    transactionState = .purchased(.tipJar)

                } else {
                    await updatePurchasedTiers(transaction)
                    await transaction.finish()

                    transactionState = .purchased(.subscription)

                    if let purchaseCompletionBlock = configuration.purchaseCompletionBlock {
                        purchaseCompletionBlock(product)
                    }
                }

                #if os(iOS) || os(visionOS)
                if let scene = UIApplication.shared.connectedScenes.first(where: {
                    $0.activationState == .foregroundActive
                }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }

                #elseif os(macOS)
                SKStoreReviewController.requestReview()
                #endif

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
    
    /// Restores the purchases for the user.
    public func restorePurchases() async {
        try? await AppStore.sync()
        _ = try? await AppTransaction.refresh()
        await updateProductLoadState(fromReload: true)
    }


    // MARK: - Transactions
    
    /// Creates a task to listen for transactions.
    /// - Returns: The task to listen to transactions.
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedTiers(transaction)
                    await transaction.finish()

                    await MainActor.run {
                        self.transactionState = .purchased(.subscription)
                    }

                } catch {}
            }
        }
    }
    
    /// Checks if the transaction can be verified.
    /// - Parameter result: The verification result type.
    /// - Returns: The verification result.
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw InAppPurchaseKitError.failedStoreVerification
        case .verified(let safe):
            return safe
        }
    }


    // MARK: - Previews

    public static var preview: InAppPurchaseKit = {
        let inAppPurchase = InAppPurchaseKit.configure(with: .example)
        return inAppPurchase
    }()
}
