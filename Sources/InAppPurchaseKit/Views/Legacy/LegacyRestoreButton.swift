//
//  LegacyRestoreButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct LegacyRestoreButton: View {
    @EnvironmentObject private var inAppPurchase: LegacyInAppPurchaseKit

    var body: some View {
        Button("Restore") {
            Task {
                await inAppPurchase.restorePurchases()
            }
        }
    }
}

#Preview {
    LegacyRestoreButton()
        .environmentObject(LegacyInAppPurchaseKit.preview)
}
