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
        Button {
            Task {
                await inAppPurchase.restorePurchases()
            }
        } label: {
            Text("Restore", bundle: .module)
        }
    }
}

#Preview {
    LegacyRestoreButton()
        .environmentObject(LegacyInAppPurchaseKit.preview)
}
