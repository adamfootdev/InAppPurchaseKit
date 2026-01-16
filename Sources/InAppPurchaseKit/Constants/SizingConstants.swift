//
//  SizingConstants.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import Foundation

enum SizingConstants {
    static var mainSpacing: CGFloat {
        #if os(macOS) || os(watchOS)
        return 20
        #elseif os(tvOS)
        return 40
        #else
        return 32
        #endif
    }

    static var mainContentWidth: CGFloat {
        #if os(tvOS)
        return 800
        #else
        return 400
        #endif
    }

    static var purchaseButtonSpacing: CGFloat {
        #if os(macOS) || os(watchOS)
        return 8
        #elseif os(tvOS)
        return 20
        #else
        return 12
        #endif
    }
}
