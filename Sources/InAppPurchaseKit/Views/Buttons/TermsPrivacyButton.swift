//
//  TermsPrivacyButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct TermsPrivacyButton: View {
    @Environment(\.openURL) private var openURL

    private let title: String
    private let url: URL

    init(_ title: String, url: URL) {
        self.title = title
        self.url = url
    }

    var body: some View {
        #if os(tvOS)
        Text(verbatim: "\(title): \(url.absoluteString)")

        #elseif os(watchOS)
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .bold()
                .foregroundStyle(Color.secondary)

            Text(url.absoluteString)
        }
        .font(.footnote)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(url.absoluteString)

        #else
        Button(title) {
            openURL(url)
        }
        #endif
    }
}

#Preview {
    TermsPrivacyButton(
        "Terms",
        url: URL(string: "https://adamfoot.dev")!
    )
}
