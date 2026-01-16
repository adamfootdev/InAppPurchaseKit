//
//  LockedInAppPurchaseFeatureButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/06/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureButton: View {
    /// Creates a new `InAppPurchaseKit` object to monitor.
    @State private var inAppPurchase: InAppPurchaseKit = .shared
    
    /// The `LockedFeatureConfiguration` to use for the view.
    private let configuration: LockedFeatureConfiguration
    
    /// The action to perform if the user is subscribed.
    private let action: (() -> Void)
    
    /// A `Bool` indicating whether the in-app purchase sheet is shown.
    @State private var showingPurchaseSheet: Bool = false
    
    /// Creates a new `LockedInAppPurchaseFeatureButton` view.
    /// - Parameters:
    ///   - configuration: The `LockedFeatureConfiguration` to use for the view.
    ///   - action: The action to perform if the user is subscribed.
    public init(
        configuration: LockedFeatureConfiguration,
        action: (@escaping () -> Void)
    ) {
        self.configuration = configuration
        self.action = action
    }

    public var body: some View {
        Button {
            if inAppPurchase.purchaseState == .purchased || (configuration.enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
                action()
            } else {
                showingPurchaseSheet = true
            }
        } label: {
            if inAppPurchase.purchaseState == .purchased || (configuration.enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
                LockedFeatureLabel(configuration: configuration)
            } else {
                LabeledContent {
                    Image(systemName: "lock.fill")
                } label: {
                    LockedFeatureLabel(configuration: configuration)
                }
            }
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

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        Form {
            LockedInAppPurchaseFeatureButton(configuration: .example) {
                print("Pressed")
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
        .environment(inAppPurchase)
    }
}
