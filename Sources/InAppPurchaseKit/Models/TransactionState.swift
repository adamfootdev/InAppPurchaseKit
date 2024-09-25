//
//  TransactionState.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 30/01/2024.
//

import Foundation

public enum TransactionState: Equatable {
    case pending
    case purchasing
    case purchased(_ type: TransactionPurchasedType)
}
