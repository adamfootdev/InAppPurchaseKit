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

    public func paymentQueue(
        _ queue: SKPaymentQueue,
        shouldAddStorePayment payment: SKPayment,
        for product: SKProduct
    ) -> Bool {
        guard purchased == false else {
            return false
        }

        return true
    }

    public func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                purchaseState = .purchasing

            case .purchased:
                queue.finishTransaction(transaction)
                purchaseState = .purchased

            case .restored:
                queue.finishTransaction(transaction)
                purchaseState = .purchased

            case .failed, .deferred:
                queue.finishTransaction(transaction)
                purchaseState = .pending

            default:
                queue.finishTransaction(transaction)
                purchaseState = .pending
            }
        }

        Task {
            await verifyExistingTransactions()
        }
    }
}
#endif
