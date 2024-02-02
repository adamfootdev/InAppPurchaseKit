//
//  InAppPurchaseKit+Promoted.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import Foundation
import StoreKit

#if os(iOS) || os(visionOS)
@available(iOS 17.0, *)
extension InAppPurchaseKit: SKPaymentTransactionObserver {
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

        Task {
            await verifyExistingTransactions()
        }
    }
}
#endif
