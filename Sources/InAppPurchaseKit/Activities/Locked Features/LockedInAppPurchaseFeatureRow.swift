//
//  SwiftUIView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/06/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureRow<Content: View>: View {
    /// Creates a new `InAppPurchaseKit` object to monitor.
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    /// The `LockedFeatureConfiguration` to use for the view.
    private let configuration: LockedFeatureConfiguration

    /// The feature to show if the user is subscribed.
    @ViewBuilder private let content: Content

    /// A `Bool` indicating whether the in-app purchase sheet is shown.
    @State private var showingPurchaseSheet: Bool = false
    
    /// Creates a new `LockedInAppPurchaseFeatureRow` view.
    /// - Parameters:
    ///   - configuration: The `LockedFeatureConfiguration` to use for the view.
    ///   - content: The feature to show if the user is subscribed.
    public init(
        configuration: LockedFeatureConfiguration,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.configuration = configuration
        self.content = content()
    }

    public var body: some View {
        if inAppPurchase.purchaseState == .purchased || (configuration.enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
            content
        } else {
            Button {
                showingPurchaseSheet = true
            } label: {
                LabeledContent {
                    Image(systemName: "lock.fill")
                } label: {
                    LockedFeatureLabel(configuration: configuration)
                }
                .contentShape(Rectangle())
            }
            #if os(macOS)
            .buttonStyle(.plain)
            #endif
            #if os(tvOS)
            .fullScreenCover(isPresented: $showingPurchaseSheet) {
                InAppPurchaseView(onPurchase: configuration.onPurchaseAction)
                    .background(Material.regular)
            }
            #else
            .sheet(isPresented: $showingPurchaseSheet) {
                InAppPurchaseView(onPurchase: configuration.onPurchaseAction)
            }
            #endif
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        Form {
            LockedInAppPurchaseFeatureRow(configuration: .example) {
                Toggle("Activated", isOn: .constant(true))
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
        .environment(inAppPurchase)
    }
}
