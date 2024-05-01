//
//  LegacyInAppPurchaseKit+Promoted.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import Foundation
import StoreKit

#if os(iOS) || os(visionOS)
extension LegacyInAppPurchaseKit: SKPaymentTransactionObserver {
    func configurePromotedListener() {
        SKPaymentQueue.default().add(self)
    }

    nonisolated public func paymentQueue(
        _ queue: SKPaymentQueue,
        shouldAddStorePayment payment: SKPayment,
        for product: SKProduct
    ) -> Bool {
        MainActor.assumeIsolated {
            guard purchaseState != .purchased else {
                return false
            }

            return true
        }
    }

    nonisolated public func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        Task { @MainActor in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchasing:
                    transactionState = .purchasing

                case .purchased:
                    queue.finishTransaction(transaction)
                    transactionState = .purchased

                case .restored:
                    queue.finishTransaction(transaction)
                    transactionState = .purchased

                case .failed, .deferred:
                    queue.finishTransaction(transaction)
                    transactionState = .pending

                default:
                    queue.finishTransaction(transaction)
                    transactionState = .pending
                }
            }

            await verifyExistingTransactions()
        }
    }
}
#endif
