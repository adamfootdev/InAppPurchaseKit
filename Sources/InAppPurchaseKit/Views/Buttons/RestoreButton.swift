//
//  RestoreButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
struct RestoreButton: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    var body: some View {
        Button("Restore") {
            Task {
                await inAppPurchase.restorePurchases()
            }
        }
    }
}

//#Preview {
//    Group {
//        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//            RestoreButton()
//                .environment(InAppPurchaseKit.preview)
//        }
//    }
//}
