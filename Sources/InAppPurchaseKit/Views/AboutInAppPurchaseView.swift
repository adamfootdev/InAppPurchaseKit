//
//  AboutInAppPurchaseView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct AboutInAppPurchaseView: View {
    private let configuration: InAppPurchaseKitConfiguration

    init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: mainSpacing) {
            InAppPurchaseHeaderView(configuration: configuration)

            Button {

            } label: {
                Text("View Features", bundle: .module)
                    .font(titleFont)
            }
            #if !os(macOS) && !os(tvOS)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.small)
            #endif
        }
        .frame(maxWidth: .infinity)
    }

    private var mainSpacing: CGFloat {
        #if os(tvOS)
        return 32
        #else
        return 16
        #endif
    }

    private var titleFont: Font {
        #if os(macOS) || os(watchOS)
        return Font.body
        #else
        return Font.footnote.bold()
        #endif
    }
}

#Preview {
    AboutInAppPurchaseView(configuration: .preview)
}
