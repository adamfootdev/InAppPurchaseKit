//
//  RestoreButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
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
