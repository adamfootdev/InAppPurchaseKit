//
//  SubscribedFooterView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct SubscribedFooterView: View {
    var body: some View {
        Text("Subscribed - Thank You!")
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.secondary)
    }
}

#Preview {
    SubscribedFooterView()
}
