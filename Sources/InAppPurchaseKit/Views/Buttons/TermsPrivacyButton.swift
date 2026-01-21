//
//  TermsPrivacyButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

struct TermsPrivacyButton: View {
    @Environment(\.openURL) private var openURL
    @Environment(InAppPurchaseKit.self) private var inAppPurchase
    
    /// A `String` containing the text to show on the button.
    private let title: String
    
    /// The `URL` to open when the button is selected.
    private let url: URL
    
    /// Creates a new `TermsPrivacyButton` view.
    /// - Parameters:
    ///   - title: A `String` containing the text to show on the button.
    ///   - url: The `URL` to open when the button is selected.
    init(_ title: String, url: URL) {
        self.title = title
        self.url = url
    }

    var body: some View {
        #if os(tvOS)
        Text(verbatim: "\(title): \(url.absoluteString)")
            .foregroundStyle(Color.primary)

        #elseif os(watchOS)
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .bold()
                .foregroundStyle(Color.secondary)

            Text(url.absoluteString)
                .foregroundStyle(Color.primary)
        }
        .font(.footnote)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(url.absoluteString)

        #else
        Button(title) {
            openURL(url)
        }
        #if os(iOS) || os(macOS)
        .tint(inAppPurchase.configuration.tintColor)
        #endif
        #endif
    }
}

#Preview {
    TermsPrivacyButton(
        String(localized: "Terms of Use", bundle: .module),
        url: URL(string: "https://adamfoot.dev")!
    )
}
