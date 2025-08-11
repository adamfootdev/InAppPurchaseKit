//
//  RestoreButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct RestoreButton: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase

    var body: some View {
        Button {
            Task {
                await inAppPurchase.restorePurchases()
            }
        } label: {
            Text("Restore", bundle: .module)
        }
        #if os(iOS)
        .tint(inAppPurchase.configuration.tintColor)
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    RestoreButton()
        .environment(inAppPurchase)
}
